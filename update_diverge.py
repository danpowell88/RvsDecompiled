import re

with open(r'C:\Users\danpo\Desktop\rvs\src\Core\Src\UnScript.cpp', 'r', encoding='utf-8') as f:
    lines = f.readlines()

replacements = {
    98:   'EX_Return (0x04) bytecode handler; body is Stack.Code = NULL -- trivially inlined by MSVC into the exec dispatch loop; not a named export in Core.dll',
    1105: 'EX_StringToName (~0x5A) bytecode handler; opcode unconfirmed from Core.dll binary; C++-only EExprToken handler not present in Core.dll Ghidra export',
    2140: 'Ravenshield/UE2.5 string-utility native (locs); C++-only addition not in Core.dll Ghidra export or Core.u',
    2375: 'Ravenshield math-extension native (Ceil); C++-only addition not in Core.dll Ghidra export or Core.u',
    2384: 'Ravenshield math-extension native (Round); C++-only addition not in Core.dll Ghidra export or Core.u',
    2585: 'Ravenshield vector-math extension (VSizeSquared); C++-only addition not in Core.dll Ghidra export or Core.u',
    2861: 'Ravenshield rotation-RNG seeding native (InitRotRand); C++-only addition not in Core.dll Ghidra export or Core.u',
    2892: 'Ravenshield quaternion-math extension (QuatProduct); C++-only addition not in Core.dll Ghidra export or Core.u',
    2902: 'Ravenshield quaternion-math extension (QuatInvert); C++-only addition not in Core.dll Ghidra export or Core.u',
    2911: 'Ravenshield quaternion-math extension (QuatRotateVector); C++-only addition not in Core.dll Ghidra export or Core.u',
    2925: 'Ravenshield quaternion-math extension (QuatFindBetween); C++-only addition not in Core.dll Ghidra export or Core.u',
    2948: 'Ravenshield quaternion-math extension (QuatFromAxisAndAngle); C++-only addition not in Core.dll Ghidra export or Core.u',
    2974: 'Ravenshield interpolation-curve extension (InterpCurveGetInputDomain); C++-only addition not in Core.dll Ghidra export or Core.u',
    2994: 'Ravenshield interpolation-curve extension (InterpCurveGetOutputRange); C++-only addition not in Core.dll Ghidra export or Core.u',
    3130: 'Ravenshield geometry utility native (CalcDirection); C++-only addition not in Core.dll Ghidra export or Core.u',
    3141: 'Ravenshield geometry utility native (CalcRotation); C++-only addition not in Core.dll Ghidra export or Core.u',
    3152: 'Ravenshield string-compression helper (FStringToAnsiBytes); static internal function not present in Core.dll Ghidra export',
    3163: 'Ravenshield string-compression helper (AnsiBytesToFString); static internal function not present in Core.dll Ghidra export',
    3175: 'Ravenshield string-compression helper (RunCodecStage); static internal function not present in Core.dll Ghidra export',
    3186: 'Ravenshield string-compression helper (CompressStringBytes); static internal function not present in Core.dll Ghidra export',
    3202: 'Ravenshield string-compression helper (ExpandStringBytes); static internal function not present in Core.dll Ghidra export',
    3218: 'Ravenshield hex-encoding helper (EncodeHexNibble); static internal function not present in Core.dll Ghidra export',
    3224: 'Ravenshield hex-encoding helper (DecodeHexNibble); static internal function not present in Core.dll Ghidra export',
    3236: 'Ravenshield hex-encoding helper (EncodeCompressedBytes); static internal function not present in Core.dll Ghidra export',
    3254: 'Ravenshield hex-encoding helper (DecodeCompressedBytes); static internal function not present in Core.dll Ghidra export',
    3280: 'Ravenshield string-compression native (execCompress); C++-only addition not in Core.dll Ghidra export or Core.u',
    3295: 'Ravenshield string-compression native (execExpand); C++-only addition not in Core.dll Ghidra export or Core.u',
    3503: 'Ravenshield R6 INI-profile native (execGetPrivateProfileInt); wraps Win32 GetPrivateProfileInt; C++-only addition not in Core.dll Ghidra export',
    3515: 'Ravenshield R6 INI-profile native (execGetPrivateProfileString); wraps Win32 GetPrivateProfileString; C++-only addition not in Core.dll Ghidra export',
    3527: 'Ravenshield R6 INI-profile native (execSetPrivateProfileInt); wraps Win32 WritePrivateProfileInt; C++-only addition not in Core.dll Ghidra export',
    3538: 'Ravenshield R6 INI-profile native (execSetPrivateProfileString); wraps Win32 WritePrivateProfileString; C++-only addition not in Core.dll Ghidra export',
    3549: 'Ravenshield R6 INI-profile native (execSavePrivateProfile); C++-only addition not in Core.dll Ghidra export',
    3561: 'Ravenshield platform-query native (execGetPlatform); C++-only addition not in Core.dll Ghidra export',
    3569: 'Ravenshield version-query native (execGetVersionWarfareEngine); C++-only addition not in Core.dll Ghidra export',
    3577: 'Ravenshield version-query native (execGetVersionAGPMajor); C++-only addition not in Core.dll Ghidra export',
    3585: 'Ravenshield version-query native (execGetVersionAGPMinor); C++-only addition not in Core.dll Ghidra export',
    3593: 'Ravenshield version-query native (execGetVersionAGPTiny); C++-only addition not in Core.dll Ghidra export',
    3601: 'Ravenshield build-type query native (execIsDebugBuild); C++-only addition not in Core.dll Ghidra export',
    3613: 'Ravenshield game-settings native (execGetMilesOnly); C++-only addition not in Core.dll Ghidra export',
    3621: 'Ravenshield game-settings native (execSetMilesOnly); C++-only addition not in Core.dll Ghidra export',
    3629: 'Ravenshield game-settings native (execGetNoBlood); C++-only addition not in Core.dll Ghidra export',
    3637: 'Ravenshield game-settings native (execSetNoBlood); C++-only addition not in Core.dll Ghidra export',
    3645: 'Ravenshield game-settings native (execGetNoSniper); C++-only addition not in Core.dll Ghidra export',
    3653: 'Ravenshield game-settings native (execSetNoSniper); C++-only addition not in Core.dll Ghidra export',
    3661: 'Ravenshield game-settings native (execGetLanguageFilter); C++-only addition not in Core.dll Ghidra export',
    3669: 'Ravenshield game-settings native (execSetLanguageFilter); C++-only addition not in Core.dll Ghidra export',
    3677: 'Ravenshield input-system native (execGetInputKeyString); C++-only addition not in Core.dll Ghidra export',
    3686: 'Ravenshield filesystem native (execGetBaseDir); C++-only addition not in Core.dll Ghidra export',
    3712: 'execPrivateSet bytecode handler; opcode unconfirmed; C++-only EExprToken handler not in Core.dll Ghidra export or Core.u',
    3730: 'Ravenshield R6 file-I/O helper (InitFileHandles); static internal function not present in Core.dll Ghidra export',
    3740: 'Ravenshield R6 file-I/O helper (AllocFileHandle); static internal function not present in Core.dll Ghidra export',
    3756: 'Ravenshield R6 file-I/O helper (GetFileHandle); static internal function not present in Core.dll Ghidra export',
    3765: 'Ravenshield R6 file-I/O helper (FreeFileHandle); static internal function not present in Core.dll Ghidra export',
    3776: 'Ravenshield R6 file-I/O native (execFOpen); C++-only addition not in Core.dll Ghidra export or Core.u',
    3791: 'Ravenshield R6 file-I/O native (execFOpenWrite); C++-only addition not in Core.dll Ghidra export or Core.u',
    3801: 'Ravenshield R6 file-I/O native (execFClose); C++-only addition not in Core.dll Ghidra export or Core.u',
    3810: 'Ravenshield R6 file-I/O native (execFReadLine); C++-only addition not in Core.dll Ghidra export or Core.u',
    3836: 'Ravenshield R6 file-I/O native (execFWrite); C++-only addition not in Core.dll Ghidra export or Core.u',
    3854: 'Ravenshield R6 file-I/O native (execFWriteLine); C++-only addition not in Core.dll Ghidra export or Core.u',
    3874: 'Ravenshield R6 file-I/O native (execFLoad); C++-only addition not in Core.dll Ghidra export or Core.u',
    3894: 'Ravenshield R6 file-I/O native (execFUnload); C++-only addition not in Core.dll Ghidra export or Core.u',
    3907: 'Ravenshield R6 log-file native (execLogFileOpen); C++-only addition not in Core.dll Ghidra export or Core.u',
    3917: 'Ravenshield R6 log-file native (execLogFileClose); C++-only addition not in Core.dll Ghidra export or Core.u',
    3926: 'Ravenshield R6 log-file native (execLogFileWrite); C++-only addition not in Core.dll Ghidra export or Core.u',
}

import re
DIVERGE_RE = re.compile(r'IMPL_DIVERGE\("[^"]*"\)')

changed = 0
for lineno, new_reason in sorted(replacements.items()):
    idx = lineno - 1
    line = lines[idx]
    if 'IMPL_DIVERGE' in line:
        new_line = DIVERGE_RE.sub('IMPL_DIVERGE("' + new_reason + '")', line)
        if new_line != line:
            lines[idx] = new_line
            changed += 1
        else:
            print(f'WARNING no change line {lineno}')
    else:
        print(f'ERROR no IMPL_DIVERGE at line {lineno}: {line.strip()[:60]}')

print(f'Changed {changed} lines')

with open(r'C:\Users\danpo\Desktop\rvs\src\Core\Src\UnScript.cpp', 'w', encoding='utf-8') as f:
    f.writelines(lines)
print('Done')
