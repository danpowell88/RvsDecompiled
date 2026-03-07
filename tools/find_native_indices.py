"""Extract native function indices from IpDrv.u bytecode."""
import struct

data = open(r'C:\Users\danpo\Desktop\rvs\retail\system\IpDrv.u', 'rb').read()

# Search for known function names
funcs = [
    'IsDataPending', 'Resolve', 'GetLastError', 'IpAddrToString',
    'StringToIpAddr', 'GetLocalIP', 'ParseURL', 'Validate',
    'BindPort', 'SendText', 'SendBinary', 'ReadText', 'ReadBinary',
    'Open', 'Close', 'IsConnected', 'Listen',
    'CheckForPlayerTimeouts', 'GetMaxAvailPorts', 'SetPlayingTime', 'GetPlayingTime'
]

for name in funcs:
    needle = name.encode('ascii')
    idx = 0
    while True:
        idx = data.find(needle, idx)
        if idx == -1:
            break
        # Show surrounding context (32 bytes before and after)
        start = max(0, idx - 32)
        end = min(len(data), idx + len(needle) + 32)
        chunk = data[start:end]
        hex_str = ' '.join(f'{b:02x}' for b in chunk)
        print(f'{name} at 0x{idx:04x}: ...{hex_str}...')
        idx += 1
    
print("\n--- Looking for native function flag pattern ---")
# In UE2 .u files, native functions have iNative stored as a WORD
# Let's look for the name table entries and nearby native indices

# First find the name table
# UE2 package format: tag(4), file_ver(4), licensee_ver(4), pkg_flags(4),
# name_count(4), name_offset(4), ...
if len(data) > 36:
    tag = struct.unpack_from('<I', data, 0)[0]
    file_ver = struct.unpack_from('<I', data, 4)[0]
    print(f"Package tag: 0x{tag:08x}, file version: {file_ver}")
    
    # For UE2 (version ~123-128), header layout:
    # 0: tag, 4: file_ver, 8: pkg_flags, 12: name_count, 16: name_offset,
    # 20: export_count, 24: export_offset, 28: import_count, 32: import_offset
    pkg_flags = struct.unpack_from('<I', data, 8)[0]
    name_count = struct.unpack_from('<I', data, 12)[0]
    name_offset = struct.unpack_from('<I', data, 16)[0]
    export_count = struct.unpack_from('<I', data, 20)[0]
    export_offset = struct.unpack_from('<I', data, 24)[0]
    import_count = struct.unpack_from('<I', data, 28)[0]
    import_offset = struct.unpack_from('<I', data, 32)[0]
    
    print(f"Names: {name_count} at 0x{name_offset:x}")
    print(f"Exports: {export_count} at 0x{export_offset:x}")
    print(f"Imports: {import_count} at 0x{import_offset:x}")
