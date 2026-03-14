#!/usr/bin/env python
# Patch remaining IMPL_DIVERGE entries in R6Pawn.cpp
import re

PATH = r'C:\Users\danpo\Desktop\rvs\src\R6Engine\Src\R6Pawn.cpp'

with open(PATH, 'r') as f:
    content = f.read()

replacements = [
    # PickActorAdjust comment update
    (
        'IMPL_DIVERGE("FUN_ blocker: FUN_10001750 (Karma physics helper)")\n'
        'INT AR6Pawn::PickActorAdjust',
        'IMPL_DIVERGE("0x10026140: FUN_10001750 initializes FCheckResult; loop uses dual line-check per direction with sizes from this+0x118; FocalPoint taken directly from Controller+0x480 not FocusActor")\n'
        'INT AR6Pawn::PickActorAdjust',
    ),
    # UpdateColBox comment update
    (
        'IMPL_DIVERGE("FUN_ blockers: FUN_10016b00, FUN_1003e330, FUN_1003e3d0 (R6Hostage/pawn lookup helpers)")\n'
        'void AR6Pawn::UpdateColBox',
        'IMPL_DIVERGE("0x10028920: large function using FUN_10042934 (bone angle from FPU), FUN_10016b00 (FString copy), FUN_1003e330 (hostage pick), FUN_1003e3d0 (bool pick); full implementation pending")\n'
        'void AR6Pawn::UpdateColBox',
    ),
    # UpdateMovementAnimation comment update
    (
        'IMPL_DIVERGE("FUN_ blocker: FUN_100017a0 (acos angle check for diagonal stride detection)")\n'
        'void AR6Pawn::UpdateMovementAnimation',
        'IMPL_DIVERGE("large animation state machine (~6245 bytes); FUN_100017a0 is Abs(float); full implementation pending - too complex for single decompilation pass")\n'
        'void AR6Pawn::UpdateMovementAnimation',
    ),
    # WeaponFollow comment update
    (
        'IMPL_DIVERGE("FUN_ blocker: FUN_10042934 (bone rotation cache accessor)")\n'
        'void AR6Pawn::WeaponFollow',
        'IMPL_DIVERGE("0x10022e40: FUN_10042934 (x87 ftol2) reads cached clavicle bone rotation from FPU - 3 values per bone cannot be recovered from Ghidra decompilation")\n'
        'void AR6Pawn::WeaponFollow',
    ),
    # WeaponLock comment update
    (
        'IMPL_DIVERGE("FUN_ blocker: FUN_10042934 (bone rotation cache accessor)")\n'
        'void AR6Pawn::WeaponLock',
        'IMPL_DIVERGE("0x10023580: FUN_10042934 (x87 ftol2) reads cached clavicle bone rotation from FPU - values not recoverable from Ghidra decompilation")\n'
        'void AR6Pawn::WeaponLock',
    ),
    # execGetKillResult comment update
    (
        'IMPL_DIVERGE("FUN_ blocker: FUN_10042934 (bone rotation cache accessor)")\n'
        'void AR6Pawn::execGetKillResult',
        'IMPL_DIVERGE("0x100402e0: FUN_10042934 (x87 ftol2) computes armor-modified damage (iKillDamage * armor_factor * appFrand()); formula not recoverable from Ghidra decompilation")\n'
        'void AR6Pawn::execGetKillResult',
    ),
    # execGetStunResult comment update
    (
        'IMPL_DIVERGE("FUN_ blocker: FUN_10042934 (bone rotation cache accessor)")\n'
        'void AR6Pawn::execGetStunResult',
        'IMPL_DIVERGE("0x100406c0: FUN_10042934 (x87 ftol2) computes armor-modified stun damage; same pattern as execGetKillResult - formula not recoverable from Ghidra decompilation")\n'
        'void AR6Pawn::execGetStunResult',
    ),
    # execMoveHitBone comment update
    (
        'IMPL_DIVERGE("FUN_ blocker: FUN_10042934 (bone rotation cache accessor)")\n'
        'void AR6Pawn::execMoveHitBone',
        'IMPL_DIVERGE("0x1002c140: FUN_10042934 (x87 ftol2) computes cross-product-derived bone rotation pitch/yaw from hit direction; values depend on FPU state not visible in Ghidra decompilation")\n'
        'void AR6Pawn::execMoveHitBone',
    ),
    # execSendPlaySound comment update
    (
        'IMPL_DIVERGE("FUN_ blocker: FUN_10024560 (network replication helper)")\n'
        'void AR6Pawn::execSendPlaySound',
        'IMPL_DIVERGE("0x1002e120: server network loop walks controller list at Level+0x4d4; proximity check uses vtable[0x100] with pawn+0x5e4..0x5ec fields; FUN_10024560 and FUN_1002ba20 unresolved")\n'
        'void AR6Pawn::execSendPlaySound',
    ),
    # moveToPosition: DIVERGE -> MATCH
    (
        'IMPL_DIVERGE("FUN_ blocker: FUN_100015a0 (pathfinding helper)")\n'
        'INT AR6Pawn::moveToPosition',
        'IMPL_MATCH("R6Engine.dll", 0x10025e20)\n'
        'INT AR6Pawn::moveToPosition',
    ),
    # physicsRotation: update DIVERGE comment
    (
        'IMPL_DIVERGE("FUN_ blocker: FUN_1001bc10 (unlisted AController accessor)")\n'
        'void AR6Pawn::physicsRotation',
        'IMPL_DIVERGE("FUN_10042934 reads x87 FPU rotation cache (bone angles computed via FPU ops not visible to Ghidra decompiler)")\n'
        'void AR6Pawn::physicsRotation',
    ),
]

for old, new in replacements:
    if old in content:
        content = content.replace(old, new, 1)
        print('OK: ' + old[:70].replace('\n', ' // '))
    else:
        print('MISS: ' + old[:70].replace('\n', ' // '))

# m_vInitNewLipSynch: remove null guard on pNew, change to IMPL_MATCH
OLD_LIP = (
    'IMPL_DIVERGE("FUN_ blocker: FUN_100015a0 (ECLipSynchData helper)")\n'
    'void AR6Pawn::m_vInitNewLipSynch(USound* pStartSound, USound* pStopSound)\n'
    '{\n'
    '\tguard(AR6Pawn::m_vInitNewLipSynch);\n'
    '\tif (m_hLipSynchData)\n'
    '\t{\n'
    '\t\tGMalloc->Free((void*)m_hLipSynchData);\n'
    '\t\tm_hLipSynchData = 0;\n'
    '\t}\n'
    '\t// Allocate ECLipSynchData (size 0x18 = 24 bytes) via global new\n'
    '\tUMeshInstance* MeshInst = Mesh ? (UMeshInstance*)Mesh->MeshGetInstance(this) : NULL;\n'
    '\t// DIVERGENCE: ECLipSynchData constructor param order uncertain from Ghidra;\n'
    '\t// using (MeshInst, pStartSound, pStopSound, this) based on execStartLipSynch call site.\n'
    '\tECLipSynchData* pNew = new ECLipSynchData(MeshInst, pStartSound, pStopSound, (AActor*)this);\n'
    '\tm_hLipSynchData = (INT)pNew;\n'
    '\tif (pNew)\n'
    '\t\tpNew->m_vStartLipsynch();\n'
    '\tunguard;\n'
    '}'
)
NEW_LIP = (
    'IMPL_MATCH("R6Engine.dll", 0x100228f0)\n'
    'void AR6Pawn::m_vInitNewLipSynch(USound* pStartSound, USound* pStopSound)\n'
    '{\n'
    '\tguard(AR6Pawn::m_vInitNewLipSynch);\n'
    '\tif (m_hLipSynchData)\n'
    '\t{\n'
    '\t\tGMalloc->Free((void*)m_hLipSynchData);\n'
    '\t\tm_hLipSynchData = 0;\n'
    '\t}\n'
    '\tUMeshInstance* MeshInst = Mesh ? (UMeshInstance*)Mesh->MeshGetInstance(this) : NULL;\n'
    '\tECLipSynchData* pNew = new ECLipSynchData(MeshInst, pStartSound, pStopSound, (AActor*)this);\n'
    '\tm_hLipSynchData = (INT)pNew;\n'
    '\tpNew->m_vStartLipsynch();\n'
    '\tunguard;\n'
    '}'
)
if OLD_LIP in content:
    content = content.replace(OLD_LIP, NEW_LIP, 1)
    print('OK: m_vInitNewLipSynch')
else:
    print('MISS: m_vInitNewLipSynch')

# UpdateFullPeekingMode: full reimplementation
OLD_PEEK = (
    'IMPL_DIVERGE("FUN_ blocker: FUN_10017320 (raw bit test at this+0x3E8)")\n'
    'void AR6Pawn::UpdateFullPeekingMode(FLOAT DeltaTime)\n'
    '{\n'
    '\tguard(AR6Pawn::UpdateFullPeekingMode);\n'
    '\n'
    '\tDWORD bIsOver = eventIsFullPeekingOver();\n'
    '\n'
    '\tif (bIsOver != 0)\n'
    '\t{\n'
    '\t\t// Full peeking has ended\n'
    '\t\t// DIVERGENCE: raw bit check at this+0x3E8 bit 4; approximated with m_bWantsToProne\n'
    '\t\tif (!m_bWantsToProne)\n'
    '\t\t\treturn;\n'
    '\n'
    '\t\t// If still moving (and not in special follow mode), don\'t transition yet\n'
    '\t\tif ((Velocity.X != 0.0f || Velocity.Y != 0.0f || Velocity.Z != 0.0f) &&\n'
    '\t\t\t(*(DWORD*)((BYTE*)this + 0xAC) & 2) == 0)\n'
    '\t\t\treturn;\n'
    '\n'
    '\t\t// Use current peeking as target (return-to-centre)\n'
    '\t\t*(FLOAT*)((BYTE*)this + 0x734) = UpdateColBoxPeeking(*(FLOAT*)((BYTE*)this + 0x734));\n'
    '\t\treturn;\n'
    '\t}\n'
    '\n'
    '\t// Peeking still active: determine target peeking value\n'
    '\tFLOAT TargetPeeking;\n'
    '\tDWORD bFreeAim = (*(DWORD*)((BYTE*)this + 0x3E0) >> 5) & 1;\n'
    '\tif (bFreeAim == 0 || (*(DWORD*)((BYTE*)this + 0x6C4) & 0x2000000) != 0)\n'
    '\t{\n'
    '\t\tTargetPeeking = *(FLOAT*)((BYTE*)this + 0x730);\n'
    '\t}\n'
    '\telse\n'
    '\t{\n'
    '\t\t// Free-aim: clamp peek goal to [400, 1600]\n'
    '\t\tFLOAT Goal = *(FLOAT*)((BYTE*)this + 0x730);\n'
    '\t\tif (Goal < 400.0f)\n'
    '\t\t\tTargetPeeking = 400.0f;\n'
    '\t\telse if (Goal < 1600.0f)\n'
    '\t\t\tTargetPeeking = Goal;\n'
    '\t\telse\n'
    '\t\t\tTargetPeeking = 1600.0f;\n'
    '\t}\n'
    '\n'
    '\t*(FLOAT*)((BYTE*)this + 0x734) = UpdateColBoxPeeking(TargetPeeking);\n'
    '\tunguard;\n'
    '}'
)
NEW_PEEK = (
    'IMPL_MATCH("R6Engine.dll", 0x1002be50)\n'
    'void AR6Pawn::UpdateFullPeekingMode(FLOAT DeltaTime)\n'
    '{\n'
    '\tguard(AR6Pawn::UpdateFullPeekingMode);\n'
    '\n'
    '\tDWORD bIsOver = eventIsFullPeekingOver();\n'
    '\n'
    '\tif (bIsOver != 0)\n'
    '\t{\n'
    '\t\t// Peeking is over\n'
    '\t\tif ((*(BYTE*)((BYTE*)this + 0x3e8) & 0x10) == 0)\n'
    '\t\t\treturn;\n'
    '\n'
    '\t\t// Return if moving in ALL directions and not in follow mode\n'
    '\t\tif (Velocity.X != 0.0f &&\n'
    '\t\t\tVelocity.Y != 0.0f &&\n'
    '\t\t\tVelocity.Z != 0.0f &&\n'
    '\t\t\t(*(DWORD*)((BYTE*)this + 0xac) & 2) == 0)\n'
    '\t\t\treturn;\n'
    '\n'
    '\t\tFLOAT fResult = UpdateColBoxPeeking(*(FLOAT*)((BYTE*)this + 0x734));\n'
    '\t\t*(FLOAT*)((BYTE*)this + 0x734) = fResult;\n'
    '\t\treturn;\n'
    '\t}\n'
    '\n'
    '\t// Peeking still active: determine target\n'
    '\tDWORD bFreeAim = (*(DWORD*)((BYTE*)this + 0x3e0) >> 5) & 1;\n'
    '\tFLOAT TargetPeeking;\n'
    '\tif (bFreeAim == 0 || (*(DWORD*)((BYTE*)this + 0x6c4) & 0x2000000) != 0)\n'
    '\t{\n'
    '\t\tTargetPeeking = *(FLOAT*)((BYTE*)this + 0x730);\n'
    '\t}\n'
    '\telse if (*(FLOAT*)((BYTE*)this + 0x730) < 400.0f)\n'
    '\t{\n'
    '\t\tTargetPeeking = 400.0f;\n'
    '\t}\n'
    '\telse if (*(FLOAT*)((BYTE*)this + 0x730) < 1600.0f)\n'
    '\t{\n'
    '\t\tTargetPeeking = *(FLOAT*)((BYTE*)this + 0x730);\n'
    '\t}\n'
    '\telse\n'
    '\t{\n'
    '\t\tTargetPeeking = 1600.0f;\n'
    '\t}\n'
    '\n'
    '\tFLOAT fOld = *(FLOAT*)((BYTE*)this + 0x734);\n'
    '\tFLOAT fStep = DeltaTime * 3000.0f;\n'
    '\tFLOAT fDiff = *(FLOAT*)((BYTE*)this + 0x734) - TargetPeeking;\n'
    '\tif (fDiff < 0.0f) fDiff = -fDiff;\n'
    '\tif (fDiff >= 1000.0f)\n'
    '\t\tfStep += fStep;\n'
    '\n'
    '\tif (TargetPeeking <= *(FLOAT*)((BYTE*)this + 0x734))\n'
    '\t\t*(FLOAT*)((BYTE*)this + 0x734) -= fStep;\n'
    '\telse\n'
    '\t\t*(FLOAT*)((BYTE*)this + 0x734) += fStep;\n'
    '\n'
    '\tFLOAT fClamped;\n'
    '\tif ((*(DWORD*)((BYTE*)this + 0x6c4) & 0x2000000) == 0)\n'
    '\t{\n'
    '\t\tFLOAT fLo = TargetPeeking, fHi = TargetPeeking;\n'
    '\t\tFLOAT fVal;\n'
    '\t\tif (bFreeAim == 0)\n'
    '\t\t{\n'
    '\t\t\tif (*(INT*)((BYTE*)this + 0x3e4) >= 0)\n'
    '\t\t\t{\n'
    '\t\t\t\tfLo = 0.0f;\n'
    '\t\t\t\tfVal = *(FLOAT*)((BYTE*)this + 0x734);\n'
    '\t\t\t}\n'
    '\t\t\telse\n'
    '\t\t\t{\n'
    '\t\t\t\tfVal = *(FLOAT*)((BYTE*)this + 0x734);\n'
    '\t\t\t\tfHi = 2000.0f;\n'
    '\t\t\t}\n'
    '\t\t}\n'
    '\t\telse if (*(INT*)((BYTE*)this + 0x3e4) < 0)\n'
    '\t\t{\n'
    '\t\t\tfHi = 1600.0f;\n'
    '\t\t\tfVal = *(FLOAT*)((BYTE*)this + 0x734);\n'
    '\t\t}\n'
    '\t\telse\n'
    '\t\t{\n'
    '\t\t\tfVal = *(FLOAT*)((BYTE*)this + 0x734);\n'
    '\t\t\tfLo = 400.0f;\n'
    '\t\t}\n'
    '\t\tif (fVal < fLo) fClamped = fLo;\n'
    '\t\telse if (fVal > fHi) fClamped = fHi;\n'
    '\t\telse fClamped = fVal;\n'
    '\t}\n'
    '\telse\n'
    '\t{\n'
    '\t\tfClamped = *(FLOAT*)((BYTE*)this + 0x734);\n'
    '\t\tif (fOld >= 1000.0f)\n'
    '\t\t{\n'
    '\t\t\tif (fClamped >= 1000.0f)\n'
    '\t\t\t\tfClamped = 1000.0f;\n'
    '\t\t\telse if (fClamped >= 2000.0f)\n'
    '\t\t\t\tfClamped = 2000.0f;\n'
    '\t\t}\n'
    '\t\telse\n'
    '\t\t{\n'
    '\t\t\tif (fClamped >= 0.0f)\n'
    '\t\t\t\tfClamped = 0.0f;\n'
    '\t\t\telse if (fClamped < 1000.0f)\n'
    '\t\t\t\tfClamped = 1000.0f;\n'
    '\t\t}\n'
    '\t}\n'
    '\t*(FLOAT*)((BYTE*)this + 0x734) = fClamped;\n'
    '\n'
    '\tif ((*(BYTE*)((BYTE*)this + 0x3e8) & 0x10) == 0)\n'
    '\t\treturn;\n'
    '\n'
    '\tif (fOld != *(FLOAT*)((BYTE*)this + 0x734))\n'
    '\t\treturn;\n'
    '\n'
    '\tFLOAT fResult = UpdateColBoxPeeking(*(FLOAT*)((BYTE*)this + 0x734));\n'
    '\t*(FLOAT*)((BYTE*)this + 0x734) = fResult;\n'
    '\n'
    '\tunguard;\n'
    '}'
)
if OLD_PEEK in content:
    content = content.replace(OLD_PEEK, NEW_PEEK, 1)
    print('OK: UpdateFullPeekingMode')
else:
    print('MISS: UpdateFullPeekingMode')
    # Debug: find partial match
    idx = content.find('UpdateFullPeekingMode')
    if idx >= 0:
        print('  Found at index', idx)
        print('  Context: ' + repr(content[idx-50:idx+200]))

# physicsRotation: fix Controller+0x50C offset
OLD_PHYS = (
    '\t\t\t// DIVERGENCE: FUN_1001bc10 on Controller is an unknown accessor; approximate\n'
    '\t\t\t// TurnRate from offset 0x50C (RotationRate or similar stored field).\n'
    '\t\t\tINT LR = *(INT*)((BYTE*)this + 0x50C);\n'
    '\t\t\tRotSpeed = appRound((FLOAT)(LR << 1) * DeltaTime);'
)
NEW_PHYS = (
    '\t\t\t// FUN_1001bc10 is the IsA walk for AR6PlayerController; for human controllers it\n'
    '\t\t\t// always returns Controller unchanged. Read the turn-rate from Controller+0x50C.\n'
    '\t\t\tINT LR = *(INT*)((BYTE*)Controller + 0x50C) << 1;\n'
    '\t\t\tRotSpeed = appRound((FLOAT)LR * DeltaTime);'
)
if OLD_PHYS in content:
    content = content.replace(OLD_PHYS, NEW_PHYS, 1)
    print('OK: physicsRotation fix')
else:
    print('MISS: physicsRotation fix')

with open(PATH, 'w') as f:
    f.write(content)
print('File written.')
