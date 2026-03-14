#!/usr/bin/env python3
"""
extract_uc.py - Extract UnrealScript .uc skeletons from retail RavenShield 1.60 .u packages.

Parses UE2 binary package format directly — retail builds strip ScriptText so UCC
batchexport fails.  For each UClass we:
  1. Build the class declaration from the export table (name, parent, native flag).
  2. List var declarations from UProperty child-exports.
  3. List function/event/delegate stubs from UFunction child-exports.
  4. Correlate with sdk/1.56 Source Code/ to pull comments, headers, #exec lines,
     struct/enum bodies and mark NEW-IN-1.60 / REMOVED-IN-1.60 differences.

Usage: python tools/extract_uc.py
Output: src/{Module}/Classes/{ClassName}.uc  (overwrites existing 1.56 placeholders)
"""

import struct
import os
import re
import sys
from pathlib import Path
from collections import defaultdict

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

UE2_MAGIC = 0x9E2A83C1

# EObjectFlags (subset we care about)
RF_Native    = 0x04000000
RF_Transient = 0x00004000

# EPropertyFlags
CPF_Edit          = 0x00000001
CPF_Const         = 0x00000002
CPF_OptionalParm  = 0x00000010
CPF_Net           = 0x00000020   # replicated
CPF_Parm          = 0x00000080
CPF_OutParm       = 0x00000100
CPF_SkipParm      = 0x00000200
CPF_ReturnParm    = 0x00000400
CPF_CoerceParm    = 0x00000800
CPF_Native        = 0x00001000
CPF_Transient     = 0x00002000
CPF_Config        = 0x00004000
CPF_Localized     = 0x00008000
CPF_Travel        = 0x00010000
CPF_EditConst     = 0x00020000
CPF_GlobalConfig  = 0x00040000

# EFunctionFlags
FUNC_Final       = 0x00000001
FUNC_Iterator    = 0x00000004
FUNC_Latent      = 0x00000008
FUNC_Singular    = 0x00000020
FUNC_Net         = 0x00000040
FUNC_NetReliable = 0x00000080
FUNC_Simulated   = 0x00000100
FUNC_Exec        = 0x00000200
FUNC_Native      = 0x00000400
FUNC_Event       = 0x00000800
FUNC_Operator    = 0x00001000
FUNC_Static      = 0x00002000
FUNC_Const       = 0x00008000
FUNC_Public      = 0x00020000
FUNC_Private     = 0x00040000
FUNC_Protected   = 0x00080000
FUNC_Delegate    = 0x00100000

PACKAGE_MAP = {
    'Core.u':            'src/Core/Classes',
    'Engine.u':          'src/Engine/Classes',
    'Editor.u':          'src/Editor/Classes',
    'Fire.u':            'src/Fire/Classes',
    'IpDrv.u':           'src/IpDrv/Classes',
    'Gameplay.u':        'src/Gameplay/Classes',
    'UWindow.u':         'src/UWindow/Classes',
    'R6Abstract.u':      'src/R6Abstract/Classes',
    'R6Engine.u':        'src/R6Engine/Classes',
    'R6Game.u':          'src/R6Game/Classes',
    'R6Weapons.u':       'src/R6Weapons/Classes',
    'R6GameService.u':   'src/R6GameService/Classes',
    'R6Menu.u':          'src/R6Menu/Classes',
    'R6Window.u':        'src/R6Window/Classes',
    'R6SFX.u':           'src/R6SFX/Classes',
    'R6Characters.u':    'src/R6Characters/Classes',
    'R6Description.u':   'src/R6Description/Classes',
    'R6WeaponGadgets.u': 'src/R6WeaponGadgets/Classes',
    'R61stWeapons.u':    'src/R61stWeapons/Classes',
    'R63rdWeapons.u':    'src/R63rdWeapons/Classes',
    'UnrealEd.u':        'src/UnrealEd/Classes',
}

GAMEFILES_DIR  = Path(r'C:\Ravenshield\gamefiles\system')
SDK_SOURCE_DIR = Path(r'C:\Users\danpo\Desktop\rvs\sdk\1.56 Source Code')
REPO_ROOT      = Path(r'C:\Users\danpo\Desktop\rvs')

# ---------------------------------------------------------------------------
# Binary helpers
# ---------------------------------------------------------------------------

def read_index(data: bytes, pos: int):
    """Read a UE2 compact index (variable-length signed integer)."""
    b0 = data[pos]; pos += 1
    neg = (b0 & 0x80) != 0
    val = b0 & 0x3F
    if b0 & 0x40:
        b1 = data[pos]; pos += 1
        val |= (b1 & 0x7F) << 6
        if b1 & 0x80:
            b2 = data[pos]; pos += 1
            val |= (b2 & 0x7F) << 13
            if b2 & 0x80:
                b3 = data[pos]; pos += 1
                val |= (b3 & 0x7F) << 20
                if b3 & 0x80:
                    b4 = data[pos]; pos += 1
                    val |= (b4 & 0x1F) << 27
    if neg:
        val = -val
    return val, pos


def read_fstring(data: bytes, pos: int):
    """Read a length-prefixed FString (int32 length + chars). Returns (str, new_pos)."""
    length = struct.unpack_from('<i', data, pos)[0]
    pos += 4
    if length == 0:
        return '', pos
    if length < 0:
        # Unicode — take even bytes
        byte_len = (-length) * 2
        raw = data[pos:pos + byte_len]
        pos += byte_len
        return raw[::2].decode('latin-1', errors='replace').rstrip('\x00'), pos
    else:
        raw = data[pos:pos + length]
        pos += length
        return raw.decode('latin-1', errors='replace').rstrip('\x00'), pos


# ---------------------------------------------------------------------------
# Package parser
# ---------------------------------------------------------------------------

class Package:
    def __init__(self):
        self.names   = []
        self.imports = []   # list of dicts
        self.exports = []   # list of dicts
        self.version = 0
        self.filename = ''

    def resolve_name(self, idx: int) -> str:
        """Resolve an object index to a human-readable name."""
        if idx == 0:
            return 'None'
        if idx > 0:
            i = idx - 1
            if 0 <= i < len(self.exports):
                return self.exports[i]['name']
        else:
            i = (-idx) - 1
            if 0 <= i < len(self.imports):
                return self.imports[i]['name']
        return f'?{idx}'

    def resolve_class_name(self, idx: int) -> str:
        """Resolve class_index to the metaclass name (e.g. 'Function', 'IntProperty')."""
        if idx == 0:
            return 'Class'   # class_index 0 = this IS a Class object
        return self.resolve_name(idx)


def parse_package(filepath: Path) -> Package:
    data = filepath.read_bytes()
    pkg  = Package()
    pkg.filename = str(filepath)

    magic = struct.unpack_from('<I', data, 0)[0]
    if magic != UE2_MAGIC:
        raise ValueError(f'{filepath.name}: bad magic {magic:#010x}')

    version      = struct.unpack_from('<H', data, 4)[0]
    pkg.version  = version
    # licensee_version at 6, pkg_flags at 8 — unused here
    name_count   = struct.unpack_from('<I', data, 12)[0]
    name_offset  = struct.unpack_from('<I', data, 16)[0]
    export_count = struct.unpack_from('<I', data, 20)[0]
    export_offset= struct.unpack_from('<I', data, 24)[0]
    import_count = struct.unpack_from('<I', data, 28)[0]
    import_offset= struct.unpack_from('<I', data, 32)[0]

    # --- Name table ---
    pos = name_offset
    for _ in range(name_count):
        if version >= 64:
            length, pos = read_index(data, pos)
            if length < 0:
                length = -length
            name_str = data[pos:pos + length - 1].decode('latin-1', errors='replace') if length > 0 else ''
            pos += length
        else:
            end = data.index(b'\x00', pos)
            name_str = data[pos:end].decode('latin-1', errors='replace')
            pos = end + 1
        _flags = struct.unpack_from('<I', data, pos)[0]
        pos += 4
        pkg.names.append(name_str)

    def name(idx):
        return pkg.names[idx] if 0 <= idx < len(pkg.names) else f'?{idx}'

    # --- Import table ---
    pos = import_offset
    for _ in range(import_count):
        class_package, pos = read_index(data, pos)
        class_name,    pos = read_index(data, pos)
        _outer = struct.unpack_from('<i', data, pos)[0]; pos += 4
        object_name,   pos = read_index(data, pos)
        pkg.imports.append({
            'class_pkg':  name(class_package),
            'class_name': name(class_name),
            'name':       name(object_name),
        })

    # --- Export table ---
    pos = export_offset
    for _ in range(export_count):
        class_index, pos  = read_index(data, pos)
        super_index, pos  = read_index(data, pos)
        outer_index       = struct.unpack_from('<i', data, pos)[0]; pos += 4
        name_index,  pos  = read_index(data, pos)
        object_flags      = struct.unpack_from('<I', data, pos)[0]; pos += 4
        serial_size, pos  = read_index(data, pos)
        serial_offset = 0
        if serial_size > 0:
            serial_offset, pos = read_index(data, pos)
        pkg.exports.append({
            'ci':     class_index,
            'si':     super_index,
            'outer':  outer_index,
            'name':   name(name_index),
            'flags':  object_flags,
            'size':   serial_size,
            'offset': serial_offset,
        })

    pkg._data = data
    return pkg


# ---------------------------------------------------------------------------
# Property serial data parser
# ---------------------------------------------------------------------------

PROP_TYPE_MAP = {
    'ByteProperty':        'byte',
    'IntProperty':         'int',
    'BoolProperty':        'bool',
    'FloatProperty':       'float',
    'NameProperty':        'name',
    'StrProperty':         'string',
    'StringProperty':      'string',
    'ObjectProperty':      'Object',
    'ClassProperty':       'Class',
    'StructProperty':      'struct',
    'ArrayProperty':       'array',
    'FixedArrayProperty':  'array',
    'MapProperty':         'map',
    'DelegateProperty':    'delegate',
}


def parse_uproperty(pkg: Package, exp: dict) -> dict:
    """
    Parse UProperty serial data.
    Returns dict with keys: array_dim, prop_flags, type_ref, meta_ref, ok
    type_ref: compact-index pointing to the referenced type (ObjectProperty→class,
              StructProperty→struct, ByteProperty→enum, ClassProperty→base class,
              ArrayProperty→inner property).
    meta_ref: for ClassProperty, the MetaClass CI.
    """
    result = {'array_dim': 1, 'prop_flags': 0, 'type_ref': 0, 'meta_ref': 0, 'ok': False}
    data = pkg._data
    off, sz = exp['offset'], exp['size']
    if sz < 8:
        return result

    p = off
    end = off + sz
    try:
        # Skip tagged properties (FName = 2 CIs: name_index + number)
        while p < end:
            name_idx, p2 = read_index(data, p)
            num_idx,  p3 = read_index(data, p2)
            if name_idx == 0:   # None → end of tagged props
                p = p3
                break
            # Skip this tagged property value — read info byte to determine size
            info = data[p3]
            p4 = p3 + 1
            tag_type      = info & 0x0F
            size_code     = (info >> 4) & 0x07
            is_array_elem = (info & 0x80) != 0

            # Struct-type tags have an extra FName (2 CIs)
            if tag_type == 10:  # Struct
                _, p4 = read_index(data, p4)
                _, p4 = read_index(data, p4)
            # Bool type has no separate size / value bytes (value in info)
            if tag_type == 4:   # Bool
                val_size = 0
            elif size_code == 0: val_size = 1
            elif size_code == 1: val_size = 2
            elif size_code == 2: val_size = 4
            elif size_code == 3: val_size = 12
            elif size_code == 4: val_size = 16
            elif size_code == 5:
                val_size = data[p4]; p4 += 1
            elif size_code == 6:
                val_size = struct.unpack_from('<H', data, p4)[0]; p4 += 2
            else:
                val_size = struct.unpack_from('<I', data, p4)[0]; p4 += 4

            # Array-element tag has extra CI for array index
            if is_array_elem:
                _, p4 = read_index(data, p4)

            p = p4 + val_size

        # UField.Next (compact_index)
        _, p = read_index(data, p)

        # ArrayDim (int16) — how many elements (1 = scalar, >1 = fixed array)
        result['array_dim'] = struct.unpack_from('<h', data, p)[0]; p += 2

        # ElementSize (int16) — runtime size, not useful here
        p += 2

        # PropertyFlags (uint32)
        result['prop_flags'] = struct.unpack_from('<I', data, p)[0]; p += 4

        # Category (compact_index name)
        _, p = read_index(data, p)

        # RepOffset (uint16) — only present when CPF_Net is set
        if (result['prop_flags'] & CPF_Net) and (p + 2 <= end):
            p += 2

        # Subclass-specific type reference (CI)
        if p < end:
            result['type_ref'], p = read_index(data, p)

        # ClassProperty has a second CI: MetaClass
        prop_class = pkg.resolve_class_name(exp['ci'])
        if prop_class == 'ClassProperty' and p < end:
            result['meta_ref'], p = read_index(data, p)

        result['ok'] = True
    except Exception:
        pass

    return result


def resolve_prop_type(pkg: Package, exp: dict, prop_info: dict) -> str:
    """Return an UnrealScript type string for a property export."""
    raw_class = pkg.resolve_class_name(exp['ci'])
    type_ref  = prop_info.get('type_ref', 0)
    meta_ref  = prop_info.get('meta_ref', 0)
    array_dim = prop_info.get('array_dim', 1)

    if raw_class == 'BoolProperty':
        return 'bool'
    if raw_class == 'IntProperty':
        return 'int'
    if raw_class == 'FloatProperty':
        return 'float'
    if raw_class == 'NameProperty':
        return 'name'
    if raw_class in ('StrProperty', 'StringProperty'):
        return 'string'

    if raw_class == 'ByteProperty':
        if type_ref != 0:
            enum_name = pkg.resolve_name(type_ref)
            if enum_name and enum_name != 'None':
                return enum_name
        return 'byte'

    if raw_class == 'ObjectProperty':
        if type_ref != 0:
            return pkg.resolve_name(type_ref)
        return 'Object'

    if raw_class == 'ClassProperty':
        if meta_ref != 0:
            return f'class<{pkg.resolve_name(meta_ref)}>'
        if type_ref != 0:
            return f'class<{pkg.resolve_name(type_ref)}>'
        return 'class<Object>'

    if raw_class == 'StructProperty':
        if type_ref != 0:
            return pkg.resolve_name(type_ref)
        return 'struct'

    if raw_class in ('ArrayProperty', 'FixedArrayProperty'):
        if type_ref != 0:
            # type_ref points to the inner property export
            inner_name = pkg.resolve_name(type_ref)
            # Try to get the inner property's type by finding its export
            for inner_exp in pkg.exports:
                if inner_exp['name'] == inner_name:
                    inner_class = pkg.resolve_class_name(inner_exp['ci'])
                    inner_base  = PROP_TYPE_MAP.get(inner_class, inner_class)
                    return f'array<{inner_base}>'
        return 'array<Object>'

    if raw_class == 'DelegateProperty':
        return 'delegate'

    return PROP_TYPE_MAP.get(raw_class, raw_class)


def prop_flags_to_qualifiers(prop_flags: int, is_param: bool = False) -> list:
    """Return a list of UnrealScript keyword tokens for a property's flags."""
    q = []
    if is_param:
        if prop_flags & CPF_OutParm    and not (prop_flags & CPF_ReturnParm): q.append('out')
        if prop_flags & CPF_OptionalParm: q.append('optional')
        if prop_flags & CPF_CoerceParm:   q.append('coerce')
    else:
        if prop_flags & CPF_Config:     q.append('config')
        if prop_flags & CPF_GlobalConfig: q.append('globalconfig')
        if prop_flags & CPF_Transient:  q.append('transient')
        if prop_flags & CPF_Native:     q.append('native')
        if prop_flags & CPF_Const:      q.append('const')
        if prop_flags & CPF_EditConst:  q.append('editconst')
        if prop_flags & CPF_Localized:  q.append('localized')
        if prop_flags & CPF_Travel:     q.append('travel')
        if prop_flags & CPF_Net:        q.append('/* replicated */')
    return q


# ---------------------------------------------------------------------------
# Function serial data parser
# ---------------------------------------------------------------------------

def parse_ufunction_flags(pkg: Package, exp: dict) -> int:
    """Read UFunction flags from the tail of the serial data block."""
    data = pkg._data
    off, sz = exp['offset'], exp['size']
    if sz < 4:
        return 0
    try:
        return struct.unpack_from('<I', data, off + sz - 4)[0]
    except Exception:
        return 0


# ---------------------------------------------------------------------------
# UConst serial data parser
# ---------------------------------------------------------------------------

def parse_uconst_value(pkg: Package, exp: dict) -> str:
    """Read the string value from a UConst serial block."""
    data = pkg._data
    off, sz = exp['offset'], exp['size']
    if sz < 4:
        return ''
    try:
        p = off
        end = off + sz
        # Skip tagged props (None = 0x00 0x00)
        name_idx, p2 = read_index(data, p)
        _num, p3 = read_index(data, p2)
        if name_idx == 0:
            p = p3
        # UField.Next CI
        _, p = read_index(data, p)
        # UConst.Value = FString
        if p + 4 <= end:
            value, _ = read_fstring(data, p)
            return value
    except Exception:
        pass
    return ''


# ---------------------------------------------------------------------------
# Class tree builder
# ---------------------------------------------------------------------------

def build_class_tree(pkg: Package) -> list:
    """
    Walk the export table and build a list of ClassInfo dicts.
    Each ClassInfo has: name, super, flags, properties, functions, states,
                         structs, enums, consts
    """
    exports = pkg.exports

    # Build outer → children map (1-based export indices)
    children_of = defaultdict(list)
    for i, exp in enumerate(exports):
        outer = exp['outer']
        if outer > 0:
            children_of[outer].append(i)

    classes = []
    for i, exp in enumerate(exports):
        class_type = pkg.resolve_class_name(exp['ci'])
        if class_type != 'Class':
            continue

        class_idx = i + 1   # 1-based

        class_info = {
            'name':       exp['name'],
            'super':      pkg.resolve_name(exp['si']),
            'obj_flags':  exp['flags'],
            'properties': [],
            'functions':  [],
            'states':     [],
            'structs':    [],
            'enums':      [],
            'consts':     [],
        }

        # Walk direct children
        for child_idx in children_of[class_idx]:
            child = exports[child_idx]
            child_class = pkg.resolve_class_name(child['ci'])
            child_1based = child_idx + 1

            if child_class.endswith('Property'):
                prop_info = parse_uproperty(pkg, child)
                prop_flags = prop_info.get('prop_flags', 0)
                # Skip function parameters that accidentally show up here
                if prop_flags & CPF_Parm:
                    continue
                type_str = resolve_prop_type(pkg, child, prop_info) if prop_info['ok'] else '?'
                class_info['properties'].append({
                    'name':      child['name'],
                    'type':      type_str,
                    'flags':     prop_flags,
                    'array_dim': prop_info.get('array_dim', 1),
                })

            elif child_class == 'Function':
                func_flags = parse_ufunction_flags(pkg, child)
                # Gather parameters (children of the function)
                params = []
                ret_type = 'void'
                for param_idx in children_of[child_1based]:
                    param_exp = exports[param_idx]
                    param_class = pkg.resolve_class_name(param_exp['ci'])
                    if not param_class.endswith('Property'):
                        continue
                    pinfo = parse_uproperty(pkg, param_exp)
                    pfl   = pinfo.get('prop_flags', 0)
                    if not (pfl & CPF_Parm):
                        continue
                    ptype = resolve_prop_type(pkg, param_exp, pinfo) if pinfo['ok'] else '?'
                    if pfl & CPF_ReturnParm:
                        ret_type = ptype
                    else:
                        qualifiers = prop_flags_to_qualifiers(pfl, is_param=True)
                        params.append({
                            'name':       param_exp['name'],
                            'type':       ptype,
                            'qualifiers': qualifiers,
                        })
                class_info['functions'].append({
                    'name':     child['name'],
                    'flags':    func_flags,
                    'params':   params,
                    'ret_type': ret_type,
                })

            elif child_class == 'State':
                # Collect state functions
                state_funcs = []
                for sf_idx in children_of[child_1based]:
                    sf = exports[sf_idx]
                    if pkg.resolve_class_name(sf['ci']) == 'Function':
                        sf_flags = parse_ufunction_flags(pkg, sf)
                        sf_params = []
                        sf_ret = 'void'
                        sf_1based = sf_idx + 1
                        for sp_idx in children_of[sf_1based]:
                            sp = exports[sp_idx]
                            if not pkg.resolve_class_name(sp['ci']).endswith('Property'):
                                continue
                            spinfo = parse_uproperty(pkg, sp)
                            spfl   = spinfo.get('prop_flags', 0)
                            if not (spfl & CPF_Parm):
                                continue
                            sptype = resolve_prop_type(pkg, sp, spinfo) if spinfo['ok'] else '?'
                            if spfl & CPF_ReturnParm:
                                sf_ret = sptype
                            else:
                                sq = prop_flags_to_qualifiers(spfl, is_param=True)
                                sf_params.append({'name': sp['name'], 'type': sptype, 'qualifiers': sq})
                        state_funcs.append({
                            'name':     sf['name'],
                            'flags':    sf_flags,
                            'params':   sf_params,
                            'ret_type': sf_ret,
                        })
                class_info['states'].append({
                    'name':      child['name'],
                    'functions': state_funcs,
                })

            elif child_class == 'Struct':
                # Collect struct members
                struct_members = []
                for sm_idx in children_of[child_1based]:
                    sm = exports[sm_idx]
                    if not pkg.resolve_class_name(sm['ci']).endswith('Property'):
                        continue
                    sminfo = parse_uproperty(pkg, sm)
                    smfl   = sminfo.get('prop_flags', 0)
                    if smfl & CPF_Parm:
                        continue
                    smtype = resolve_prop_type(pkg, sm, sminfo) if sminfo['ok'] else '?'
                    struct_members.append({
                        'name':      sm['name'],
                        'type':      smtype,
                        'flags':     smfl,
                        'array_dim': sminfo.get('array_dim', 1),
                    })
                class_info['structs'].append({
                    'name':    child['name'],
                    'members': struct_members,
                    'super':   pkg.resolve_name(child['si']),
                })

            elif child_class == 'Enum':
                class_info['enums'].append({'name': child['name'], 'values': []})

            elif child_class == 'Const':
                cval = parse_uconst_value(pkg, child)
                class_info['consts'].append({'name': child['name'], 'value': cval})

        classes.append(class_info)

    return classes


# ---------------------------------------------------------------------------
# .uc skeleton generator
# ---------------------------------------------------------------------------

def func_keyword(func_flags: int) -> str:
    """Return the primary keyword for a function (function/event/delegate/operator)."""
    if func_flags & FUNC_Delegate:  return 'delegate'
    if func_flags & FUNC_Event:     return 'event'
    if func_flags & FUNC_Operator:  return 'operator'
    return 'function'


def func_modifiers(func_flags: int) -> list:
    """Return modifier keywords for a function declaration."""
    mods = []
    if func_flags & FUNC_Static:     mods.append('static')
    if func_flags & FUNC_Final:      mods.append('final')
    if func_flags & FUNC_Singular:   mods.append('singular')
    if func_flags & FUNC_Simulated:  mods.append('simulated')
    if func_flags & FUNC_Exec:       mods.append('exec')
    if func_flags & FUNC_Native:     mods.append('native')
    if func_flags & FUNC_Const:      mods.append('const')
    if func_flags & FUNC_Iterator:   mods.append('iterator')
    if func_flags & FUNC_Latent:     mods.append('latent')
    return mods


def format_param(p: dict) -> str:
    parts = p['qualifiers'] + [p['type'], p['name']]
    return ' '.join(parts)


def format_function(f: dict) -> str:
    kw    = func_keyword(f['flags'])
    mods  = func_modifiers(f['flags'])
    ret   = f['ret_type']
    name  = f['name']
    params = ', '.join(format_param(p) for p in f['params'])

    parts = mods
    if kw != 'function':
        parts.append(kw)
    else:
        parts.append('function')

    if ret != 'void':
        parts.append(ret)
    parts.append(name)
    return ' '.join(parts) + f'({params})'


def format_var(v: dict) -> str:
    qualifiers = prop_flags_to_qualifiers(v['flags'])
    type_str   = v['type']
    name       = v['name']
    arr        = v['array_dim']
    if arr > 1:
        name = f'{name}[{arr}]'
    parts = ['var'] + qualifiers + [type_str, name + ';']
    return ' '.join(parts)


def format_struct_var(m: dict) -> str:
    type_str = m['type']
    name     = m['name']
    arr      = m['array_dim']
    if arr > 1:
        name = f'{name}[{arr}]'
    return f'    var {type_str} {name};'


def generate_uc_skeleton(pkg_name: str, pkg_path: str, cls: dict) -> str:
    """Generate a .uc skeleton string for a class."""
    lines = []

    # File header
    lines.append(f'// Extracted from retail RavenShield 1.60 -- {pkg_path}')
    lines.append(f'// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)')

    # Class declaration
    name  = cls['name']
    super = cls['super']
    mods  = []
    if cls['obj_flags'] & RF_Native:
        mods.append('native')
    # (abstract / nativereplication / config come from 1.56 correlation)

    if mods:
        mod_str = '\n    ' + '\n    '.join(mods)
        lines.append(f'class {name} extends {super}{mod_str};')
    else:
        lines.append(f'class {name} extends {super};')
    lines.append('')

    # Consts
    if cls['consts']:
        lines.append('// --- Constants ---')
        for c in cls['consts']:
            val = c['value']
            if val:
                lines.append(f'const {c["name"]} = {val};')
            else:
                lines.append(f'const {c["name"]}; // value unavailable in binary')
        lines.append('')

    # Enums (names only — values not stored as sub-exports)
    if cls['enums']:
        lines.append('// --- Enums ---')
        for e in cls['enums']:
            lines.append(f'enum {e["name"]}')
            lines.append('{')
            lines.append('    // enum values not recoverable from binary — see 1.56 source')
            lines.append('};')
        lines.append('')

    # Structs
    if cls['structs']:
        lines.append('// --- Structs ---')
        for s in cls['structs']:
            super_s = s['super']
            if super_s and super_s != 'None':
                lines.append(f'struct {s["name"]} extends {super_s}')
            else:
                lines.append(f'struct {s["name"]}')
            lines.append('{')
            for m in s['members']:
                lines.append(format_struct_var(m))
            lines.append('};')
            lines.append('')

    # Variables
    if cls['properties']:
        lines.append('// --- Variables ---')
        for v in cls['properties']:
            lines.append(format_var(v))
        lines.append('')

    # Functions (top-level)
    if cls['functions']:
        lines.append('// --- Functions ---')
        for f in cls['functions']:
            lines.append(format_function(f) + ' {}')
        lines.append('')

    # State blocks
    for state in cls['states']:
        lines.append(f'state {state["name"]}')
        lines.append('{')
        for f in state['functions']:
            lines.append('    ' + format_function(f) + ' {}')
        lines.append('}')
        lines.append('')

    # Default properties
    lines.append('defaultproperties')
    lines.append('{')
    lines.append('}')

    return '\n'.join(lines) + '\n'


# ---------------------------------------------------------------------------
# 1.56 SDK source parser & comment merger
# ---------------------------------------------------------------------------

def find_sdk_file(class_name: str) -> Path | None:
    """Search for class_name.uc in any of the 1.56 SDK source directories."""
    for module_dir in SDK_SOURCE_DIR.iterdir():
        if not module_dir.is_dir():
            continue
        classes_dir = module_dir / 'Classes'
        if not classes_dir.is_dir():
            continue
        candidate = classes_dir / f'{class_name}.uc'
        if candidate.exists():
            return candidate
    return None


def parse_sdk_class_decl(sdk_text: str) -> dict:
    """
    Extract the class declaration modifiers from a 1.56 .uc file.
    Returns dict with keys: modifiers (list of modifier keywords)
    """
    # Match the class declaration block (may span multiple lines before the semicolon)
    m = re.search(
        r'^\s*class\s+\w+\s+extends\s+\w+(.*?);',
        sdk_text, re.MULTILINE | re.DOTALL
    )
    if not m:
        return {'modifiers': []}
    decl_tail = m.group(1)
    # Extract modifier keywords
    known = {'native', 'abstract', 'nativereplication', 'transient', 'noexport',
             'notplaceable', 'instanced', 'safereplace', 'perobjectconfig', 'hidedropdown'}
    mods = []
    for token in re.findall(r'\b(\w+)\b', decl_tail):
        if token.lower() in known:
            mods.append(token.lower())
    # Handle config(ClassName) specially
    cm = re.search(r'\bconfig\s*\(\s*(\w+)\s*\)', decl_tail, re.IGNORECASE)
    if cm:
        mods.append(f'config({cm.group(1)})')
    elif re.search(r'\bconfig\b', decl_tail, re.IGNORECASE):
        mods.append('config')
    return {'modifiers': mods}


def parse_sdk_header_comment(sdk_text: str) -> str:
    """Extract the file header comment block (//===...=== style)."""
    m = re.match(r'(//={5,}.*?//={5,}[^\n]*\n)', sdk_text, re.DOTALL)
    if m:
        return m.group(1)
    # Fallback: grab leading // lines
    lines = []
    for line in sdk_text.splitlines():
        if line.strip().startswith('//'):
            lines.append(line)
        elif line.strip() == '':
            if lines:
                break
        else:
            break
    return '\n'.join(lines) + '\n' if lines else ''


def parse_sdk_execs(sdk_text: str) -> list:
    """Extract #exec directives from 1.56 source."""
    return [line.rstrip() for line in sdk_text.splitlines()
            if line.strip().startswith('#exec')]


def parse_sdk_var_comments(sdk_text: str) -> dict:
    """
    Build a dict: var_name → comment_string that precedes it in the 1.56 source.
    Handles both single-line `// comment` above var and inline `// comment` after var.
    """
    comments = {}
    lines = sdk_text.splitlines()
    pending = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith('//'):
            pending.append(line.rstrip())
        elif stripped.startswith('var ') or re.match(r'^var\s+', stripped):
            # Extract variable name from the var declaration
            m = re.search(r'\bvar\b.*?\b(\w+)\s*(?:\[.*?\])?\s*;', stripped)
            if m:
                vname = m.group(1)
                # Also check for inline comment after semicolon
                inline_m = re.search(r';\s*(//.*)$', stripped)
                inline = ''
                if inline_m:
                    inline = inline_m.group(1)
                if pending:
                    comments[vname] = '\n'.join(pending)
                    if inline:
                        comments[vname] += '\n' + inline
                elif inline:
                    comments[vname] = inline
            pending = []
        elif stripped == '' or stripped.startswith('struct') or stripped.startswith('enum') \
                or stripped.startswith('function') or stripped.startswith('event') \
                or stripped.startswith('state') or stripped.startswith('delegate') \
                or stripped.startswith('class') or stripped.startswith('#'):
            pending = []
        # else: keep building pending (multi-line comment block)
    return comments


def parse_sdk_func_comments(sdk_text: str) -> dict:
    """Build a dict: func_name → comment_string preceding it in the 1.56 source."""
    comments = {}
    lines = sdk_text.splitlines()
    pending = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith('//'):
            pending.append(line.rstrip())
        elif re.match(r'^(function|event|simulated|static|exec|native|operator|delegate|iterator|latent)\b', stripped):
            # Extract function name
            m = re.search(r'\b(\w+)\s*\(', stripped)
            if m:
                fname = m.group(1)
                # Skip keywords that aren't names
                skip = {'function','event','simulated','static','exec','native',
                        'operator','delegate','iterator','latent','singular','final'}
                if fname not in skip:
                    if pending:
                        comments[fname] = '\n'.join(pending)
            pending = []
        elif stripped == '':
            pending = []
        else:
            if not stripped.startswith('//'):
                pending = []
    return comments


def parse_sdk_items(sdk_text: str) -> dict:
    """
    Parse the 1.56 source and return a dict of discovered item names:
      'vars': set of var names
      'funcs': set of function names
      'structs': set of struct names
      'enums': set of enum names
      'consts': set of const names
      'execs': list of #exec strings
    """
    result = {
        'vars':    set(),
        'funcs':   set(),
        'structs': set(),
        'enums':   set(),
        'consts':  set(),
        'execs':   [],
    }
    for line in sdk_text.splitlines():
        s = line.strip()
        if s.startswith('#exec'):
            result['execs'].append(s)
        m = re.match(r'^var\s+', s)
        if m:
            vm = re.search(r'\b(\w+)\s*(?:\[.*?\])?\s*;', s[m.end():])
            if vm:
                result['vars'].add(vm.group(1))
        fm = re.match(r'^(?:(?:simulated|static|exec|native|event|function|delegate|operator|iterator|latent|singular|final)\s+)+(\w+)\s*\(', s)
        if fm:
            fname = fm.group(1)
            skip = {'function','event','simulated','static','exec','native',
                    'operator','delegate','iterator','latent','singular','final'}
            if fname not in skip:
                result['funcs'].add(fname)
        sm = re.match(r'^struct\s+(\w+)', s)
        if sm:
            result['structs'].add(sm.group(1))
        em = re.match(r'^enum\s+(\w+)', s)
        if em:
            result['enums'].add(em.group(1))
        cm = re.match(r'^const\s+(\w+)', s)
        if cm:
            result['consts'].add(cm.group(1))
    return result


def parse_sdk_struct_body(sdk_text: str, struct_name: str) -> str:
    """Extract the full struct definition body from 1.56 source."""
    m = re.search(
        r'(struct\s+' + re.escape(struct_name) + r'\b.*?\{.*?\});',
        sdk_text, re.DOTALL
    )
    return m.group(0) if m else ''


def parse_sdk_enum_body(sdk_text: str, enum_name: str) -> str:
    """Extract the full enum definition body from 1.56 source."""
    m = re.search(
        r'(enum\s+' + re.escape(enum_name) + r'\b.*?\{.*?\});',
        sdk_text, re.DOTALL
    )
    return m.group(0) if m else ''


def merge_sdk_comments(generated_uc: str, sdk_path: Path, cls: dict) -> str:
    """
    Merge comments, #exec directives, class modifiers and struct/enum bodies
    from the 1.56 SDK source into the generated 1.60 skeleton.
    """
    try:
        sdk_text = sdk_path.read_text(encoding='utf-8', errors='replace')
    except Exception:
        try:
            sdk_text = sdk_path.read_text(encoding='latin-1', errors='replace')
        except Exception:
            return generated_uc

    sdk_header   = parse_sdk_header_comment(sdk_text)
    sdk_decl     = parse_sdk_class_decl(sdk_text)
    sdk_execs    = parse_sdk_execs(sdk_text)
    sdk_var_cmt  = parse_sdk_var_comments(sdk_text)
    sdk_func_cmt = parse_sdk_func_comments(sdk_text)
    sdk_items    = parse_sdk_items(sdk_text)

    lines     = generated_uc.splitlines()
    out_lines = []

    # Replace generic header comment with 1.56 header
    if sdk_header:
        # Drop the first two generated comment lines
        skip_until_class = True
        for line in lines:
            if skip_until_class and (line.startswith('// Extracted') or line.startswith('// Class structure')):
                continue
            skip_until_class = False
            out_lines.append(line)
        lines = out_lines
        out_lines = [sdk_header.rstrip()] + lines
        lines = out_lines
        out_lines = []

    # Add class modifiers from 1.56 (abstract, nativereplication, config, etc.)
    mods_to_add = [m for m in sdk_decl['modifiers']
                   if m not in ('native',)]   # native comes from binary

    new_lines = []
    for line in lines:
        if re.match(r'^class\s+\w+\s+extends\s+\w+', line):
            # Rewrite class declaration with merged modifiers
            # Already has 'native' if binary says so; add SDK extras
            existing = line
            # Build modifier list from the binary-extracted line
            bin_mods = []
            if '    native' in existing or existing.rstrip().endswith('native;'):
                bin_mods.append('native')
            # Add SDK extras
            all_mods = bin_mods + [m for m in mods_to_add if m not in bin_mods]

            # Reconstruct
            class_name  = cls['name']
            super_name  = cls['super']
            if all_mods:
                mod_lines = '\n    ' + '\n    '.join(all_mods)
                new_lines.append(f'class {class_name} extends {super_name}{mod_lines};')
            else:
                new_lines.append(f'class {class_name} extends {super_name};')
            # Swallow any continuation lines that were part of the original declaration
            continue
        # Skip bare modifier lines (they come from our plain generator)
        if line.strip() in ('native', 'abstract', 'nativereplication') and new_lines and \
                re.match(r'^class\s', new_lines[-1] if new_lines else ''):
            continue
        new_lines.append(line)
    lines = new_lines

    # Inject #exec directives after class declaration
    if sdk_execs:
        new_lines2 = []
        inserted = False
        for line in lines:
            new_lines2.append(line)
            if not inserted and re.match(r'^class\s+\w+\s+extends\s+\w+', line) and line.rstrip().endswith(';'):
                new_lines2.append('')
                for ex in sdk_execs:
                    new_lines2.append(ex)
                inserted = True
        lines = new_lines2

    # Add var comments from 1.56 and mark NEW/REMOVED
    new_lines3 = []
    in_vars_section = False
    sdk_vars  = sdk_items['vars']
    sdk_funcs = sdk_items['funcs']
    bin_vars  = {v['name'] for v in cls['properties']}
    bin_funcs = {f['name'] for f in cls['functions']}

    for stt in cls['states']:
        for sf in stt['functions']:
            bin_funcs.add(sf['name'])

    # Find removed vars/funcs (in 1.56 but not 1.60)
    removed_vars  = sdk_vars - bin_vars
    removed_funcs = sdk_funcs - bin_funcs

    removed_vars_added  = set()
    removed_funcs_added = set()

    for line in lines:
        stripped = line.strip()

        # Variables section
        if stripped == '// --- Variables ---':
            in_vars_section = True
            new_lines3.append(line)
            # Emit REMOVED vars at top of section
            for rvar in sorted(removed_vars):
                new_lines3.append(f'// var ? {rvar}; // REMOVED IN 1.60')
                removed_vars_added.add(rvar)
            continue

        if in_vars_section:
            if stripped == '' or stripped.startswith('//') and not stripped.startswith('// ---'):
                new_lines3.append(line)
                continue
            if stripped.startswith('var ') or re.match(r'^var\s+', stripped):
                # Find var name and add comment if available
                vm = re.search(r'\bvar\b.*?\b(\w+)\s*(?:\[.*?\])?\s*;', stripped)
                if vm:
                    vname = vm.group(1)
                    is_new = vname not in sdk_vars and sdk_vars  # not empty sdk means we can judge
                    cmt = sdk_var_cmt.get(vname, '')
                    if cmt:
                        for cline in cmt.splitlines():
                            new_lines3.append(cline)
                    new_lines3.append(line)
                    if is_new:
                        new_lines3.append(f'// ^ NEW IN 1.60')
                    continue
                in_vars_section = False
            else:
                in_vars_section = False

        # Functions section — add comments
        if stripped == '// --- Functions ---':
            new_lines3.append(line)
            # Emit REMOVED funcs
            for rfunc in sorted(removed_funcs):
                new_lines3.append(f'// function ? {rfunc}(...); // REMOVED IN 1.60')
                removed_funcs_added.add(rfunc)
            continue

        # Annotate individual function lines
        func_match = re.match(
            r'^((?:(?:static|final|singular|simulated|exec|native|const|iterator|latent)\s+)*'
            r'(?:function|event|delegate|operator)\s+)', stripped)
        if func_match:
            # Extract function name
            rest = stripped[func_match.end():]
            fname_m = re.search(r'\b(\w+)\s*\(', rest)
            if fname_m:
                fname = fname_m.group(1)
                is_new = fname not in sdk_funcs and sdk_funcs
                cmt = sdk_func_cmt.get(fname, '')
                if cmt:
                    for cline in cmt.splitlines():
                        new_lines3.append(cline)
                new_lines3.append(line)
                if is_new:
                    new_lines3.append(f'// ^ NEW IN 1.60')
                continue

        new_lines3.append(line)

    # Replace enum/struct placeholders with full SDK bodies where available
    final_lines = []
    i = 0
    in_enum_block = False
    in_struct_block = False
    block_name = ''
    brace_depth = 0

    for line in new_lines3:
        s = line.strip()
        # Replace "enum X { // enum values not recoverable..." with SDK body
        em = re.match(r'^enum\s+(\w+)\s*$', s)
        if em:
            ename = em.group(1)
            body = parse_sdk_enum_body(sdk_text, ename)
            if body:
                for bl in body.splitlines():
                    final_lines.append(bl)
                # Skip until closing brace
                in_enum_block = True
                block_name = ename
                brace_depth = 0
                continue
        if in_enum_block:
            brace_depth += s.count('{') - s.count('}')
            if brace_depth <= 0 and s.endswith(';'):
                in_enum_block = False
            continue

        # Replace struct bodies with SDK bodies
        sm = re.match(r'^struct\s+(\w+)', s)
        if sm:
            sname = sm.group(1)
            body = parse_sdk_struct_body(sdk_text, sname)
            if body:
                for bl in body.splitlines():
                    final_lines.append(bl)
                in_struct_block = True
                block_name = sname
                brace_depth = 0
                continue
        if in_struct_block:
            brace_depth += s.count('{') - s.count('}')
            if brace_depth <= 0 and (s.endswith(';') or s == '};'):
                in_struct_block = False
            continue

        final_lines.append(line)

    return '\n'.join(final_lines) + '\n'


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    stats = {'packages': 0, 'classes': 0, 'errors': 0}
    error_log = []

    for pkg_filename, src_rel_path in PACKAGE_MAP.items():
        pkg_path = GAMEFILES_DIR / pkg_filename
        if not pkg_path.exists():
            print(f'  SKIP (not found): {pkg_filename}')
            continue

        out_dir = REPO_ROOT / src_rel_path
        out_dir.mkdir(parents=True, exist_ok=True)

        print(f'Processing {pkg_filename} → {src_rel_path}/')

        try:
            pkg = parse_package(pkg_path)
        except Exception as e:
            print(f'  ERROR parsing {pkg_filename}: {e}')
            error_log.append(f'{pkg_filename}: parse error: {e}')
            stats['errors'] += 1
            continue

        classes = build_class_tree(pkg)
        print(f'  Found {len(classes)} classes')

        for cls in classes:
            try:
                uc_text = generate_uc_skeleton(pkg_filename, str(pkg_path), cls)

                # Try to merge with 1.56 source
                sdk_file = find_sdk_file(cls['name'])
                if sdk_file:
                    uc_text = merge_sdk_comments(uc_text, sdk_file, cls)

                out_file = out_dir / f'{cls["name"]}.uc'
                out_file.write_text(uc_text, encoding='utf-8')
                stats['classes'] += 1
            except Exception as e:
                msg = f'  ERROR generating {cls["name"]}: {e}'
                print(msg)
                error_log.append(msg)
                stats['errors'] += 1

        stats['packages'] += 1
        print(f'  Done')

    print()
    print(f'=== Summary ===')
    print(f'Packages processed : {stats["packages"]}')
    print(f'Classes written    : {stats["classes"]}')
    print(f'Errors             : {stats["errors"]}')
    if error_log:
        print()
        print('Error log:')
        for e in error_log:
            print(f'  {e}')


if __name__ == '__main__':
    main()
