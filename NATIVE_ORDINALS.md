# Native Ordinal Mapping — Ravenshield Core.u

**Source of truth:** Retail `Core.u` package (v118) iNative values, extracted by
reading each UFunction's last 7 bytes: `iNative(WORD) + OperPrecedence(BYTE) + FunctionFlags(DWORD)`.

**Summary:**
- **113** existing IMPLEMENT_FUNCTION entries are **correct**
- **42** existing IMPLEMENT_FUNCTION entries have **wrong ordinals** (decompilation errors)
- **6** Core.u functions are **missing** IMPLEMENT_FUNCTION with **known ordinals**
- **9** bare native functions are **missing** IMPLEMENT_FUNCTION with **unknown ordinals** (need binary analysis)
- **~51** C++-only functions not in Core.u or any .uc file (need Core.dll binary analysis)

Parser tool: `tools/parse_core_u.py`

---

## 1. IMPLEMENT_FUNCTION Entries with WRONG Ordinals (42 total)

These entries exist in `src/core/UnScript.cpp` but register at the **wrong**
GNatives[] slot. They must be corrected to match Core.u.

### Byte operators (swapped, delta ±2 to ±6)

| exec Function | C++ (wrong) | Core.u (correct) | Delta |
|---|---|---|---|
| `execMultiplyEqual_ByteByte` | 137 | **133** | +4 |
| `execDivideEqual_ByteByte` | 138 | **134** | +4 |
| `execAddEqual_ByteByte` | 135 | **135** | ✓ |
| `execSubtractEqual_ByteByte` | 136 | **136** | ✓ |
| `execAddAdd_PreByte` | 139 | **137** | +2 |
| `execSubtractSubtract_PreByte` | 140 | **138** | +2 |
| `execAddAdd_Byte` | 133 | **139** | -6 |
| `execSubtractSubtract_Byte` | 134 | **140** | -6 |

### Int assignment operators (swapped, delta ±2 to ±6)

| exec Function | C++ (wrong) | Core.u (correct) | Delta |
|---|---|---|---|
| `execMultiplyEqual_IntFloat` | 165 | **159** | +6 |
| `execDivideEqual_IntFloat` | 166 | **160** | +6 |
| `execAddEqual_IntInt` | 159 | **161** | -2 |
| `execSubtractEqual_IntInt` | 160 | **162** | -2 |
| `execAddAdd_Int` | 161 | **165** | -4 |
| `execSubtractSubtract_Int` | 162 | **166** | -4 |

### String operators (shifted +79 to +82)

| exec Function | C++ (wrong) | Core.u (correct) | Delta |
|---|---|---|---|
| `execLess_StringString` | 197 | **115** | +82 |
| `execGreater_StringString` | 198 | **116** | +82 |
| `execLessEqual_StringString` | 199 | **120** | +79 |
| `execGreaterEqual_StringString` | 200 | **121** | +79 |
| `execEqualEqual_StringString` | 201 | **122** | +79 |
| `execNotEqual_StringString` | 202 | **123** | +79 |
| `execComplementEqual_StringString` | 203 | **124** | +79 |
| `execLen` | 204 | **125** | +79 |
| `execInStr` | 205 | **126** | +79 |
| `execMid` | 206 | **127** | +79 |
| `execLeft` | 207 | **128** | +79 |
| `execRight` | 208 | **234** | -26 |
| `execCaps` | 209 | **235** | -26 |

### Vector operators (shifted +1)

| exec Function | C++ (wrong) | Core.u (correct) | Delta |
|---|---|---|---|
| `execDot_VectorVector` | 220 | **219** | +1 |
| `execCross_VectorVector` | 221 | **220** | +1 |
| `execMultiplyEqual_VectorFloat` | 222 | **221** | +1 |
| `execDivideEqual_VectorFloat` | 223 | **222** | +1 |
| `execAddEqual_VectorVector` | 224 | **223** | +1 |
| `execSubtractEqual_VectorVector` | 225 | **224** | +1 |
| `execVSize` | 225+1=226 | **225** | +1 |
| `execNormal` | 226+1=227 | **226** | +1 |

### Rotator operators (shifted +26 to +28)

| exec Function | C++ (wrong) | Core.u (correct) | Delta |
|---|---|---|---|
| `execMultiply_RotatorFloat` | 313 | **287** | +26 |
| `execMultiply_FloatRotator` | 314 | **288** | +26 |
| `execDivide_RotatorFloat` | 315 | **289** | +26 |
| `execMultiplyEqual_RotatorFloat` | 318 | **290** | +28 |
| `execDivideEqual_RotatorFloat` | 319 | **291** | +28 |
| `execAddEqual_RotatorRotator` | 320 | **318** | +2 |
| `execSubtractEqual_RotatorRotator` | 321 | **319** | +2 |
| `execNotEqual_RotatorRotator` | 203+100=303 | **203** | +100 |

### Other wrong entries

| exec Function | C++ (wrong) | Core.u (correct) | Delta |
|---|---|---|---|
| `execWarn` | 232+3=235 | **232** | +3 |

---

## 2. Functions MISSING IMPLEMENT_FUNCTION — Ordinals Known from Core.u (6)

These exec functions have implementations in UnScript.cpp but no IMPLEMENT_FUNCTION
registration. Core.u provides the correct ordinal:

| Ordinal | IMPLEMENT_FUNCTION to add |
|---|---|
| **169** | `IMPLEMENT_FUNCTION( UObject, 169, execSubtract_PreFloat );` |
| **211** | `IMPLEMENT_FUNCTION( UObject, 211, execSubtract_PreVector );` |
| **227** | `IMPLEMENT_FUNCTION( UObject, 227, execInvert );` |
| **238** | `IMPLEMENT_FUNCTION( UObject, 238, execRemoveInvalidChars );` |
| **258** | `IMPLEMENT_FUNCTION( UObject, 258, execClassIsChildOf );` |
| **320** | `IMPLEMENT_FUNCTION( UObject, 320, execRotRand );` |

**Note:** Ordinal 320 currently occupied by wrong `execAddEqual_RotatorRotator`
(should be 318). Fix AddEqual first, then add RotRand at 320.

---

## 3. Bare Native Functions — iNative=0 in Core.u (ordinals unknown)

These are declared `native` (no number) in Object.uc. Core.u has iNative=0
meaning ordinals are auto-assigned and embedded only in call-site bytecodes.
Some have existing C++ ordinals that may or may not be correct.

| Function | Existing C++ | Status |
|---|---|---|
| `execOrthoRotation` | 253 | Possibly correct; verify from Core.dll |
| `execClockwiseFrom_IntInt` | 246+100=346 | Possibly correct; verify from Core.dll |
| `execDynamicLoadObject` | 232 | **Conflicts** with Warn=232 in Core.u |
| `execLocalize` | 238 | **Conflicts** with RemoveInvalidChars=238 in Core.u |
| `execGetPropertyText` | 462 | Possibly correct; verify from Core.dll |
| `execStaticSaveConfig` | 537 | Possibly correct; verify from Core.dll |
| `execAcos` | — | **Needs ordinal from Core.dll** |
| `execAsin` | — | **Needs ordinal from Core.dll** |
| `execNormalize` (rotator) | — | **Needs ordinal from Core.dll** |
| `execFindObject` | — | **Needs ordinal from Core.dll** |
| `execGetEnum` | — | **Needs ordinal from Core.dll** |
| `execSetPropertyText` | — | **Needs ordinal from Core.dll** |
| `execResetConfig` | — | **Needs ordinal from Core.dll** |
| `execInterpCurveEval` | — | **Needs ordinal from Core.dll** |

**How to find:** Disassemble `Core.dll`, find the `GNatives[]` table initialization
or look for `GRegisterNative(N, &UObject::execXxx)` calls to determine N.

---

## 4. Functions NOT in Core.u — C++-Only Natives (~51 functions)

These exec functions exist in UnScript.cpp but are absent from Core.u and all SDK
.uc files. They are C++-only additions whose ordinals can only come from Core.dll
binary analysis.

### Math / Utility (9)
`execCeil`, `execRound`, `execVSizeSquared`, `execLocs`, `execInitRotRand`,
`execCalcDirection`, `execCalcRotation`, `execCompress`, `execExpand`

### Quaternion Operations (4)
`execQuatProduct`, `execQuatInvert`, `execQuatRotateVector`, `execQuatFindBetween`

### Interp Curve (2)
`execInterpCurveGetInputDomain`, `execInterpCurveGetOutputRange`

### Dynamic Array Operations (3) — likely EX_* bytecodes
`execDynArrayLength`, `execDynArrayInsert`, `execDynArrayRemove`

### R6 File I/O (8)
`execFOpen`, `execFOpenWrite`, `execFClose`, `execFReadLine`,
`execFWrite`, `execFWriteLine`, `execFLoad`, `execFUnload`

### R6 Log File (3)
`execLogFileOpen`, `execLogFileClose`, `execLogFileWrite`

### R6 INI Profile (5)
`execGetPrivateProfileInt`, `execGetPrivateProfileString`,
`execSetPrivateProfileInt`, `execSetPrivateProfileString`, `execSavePrivateProfile`

### R6 Platform / Version (6)
`execGetPlatform`, `execGetVersionWarfareEngine`,
`execGetVersionAGPMajor`, `execGetVersionAGPMinor`, `execGetVersionAGPTiny`,
`execIsDebugBuild`

### R6 Settings (10)
`execGetMilesOnly`, `execSetMilesOnly`, `execGetNoBlood`, `execSetNoBlood`,
`execGetNoSniper`, `execSetNoSniper`, `execGetLanguageFilter`,
`execSetLanguageFilter`, `execGetInputKeyString`, `execGetBaseDir`

---

## 5. UE2 Bytecode Handlers — Missing from EExprToken enum

These bytecode handlers exist in UnScript.cpp but the EExprToken enum values are
not defined in the SDK headers. They need opcode values from Core.dll binary
analysis and corresponding IMPLEMENT_FUNCTION entries.

| Function | Likely Opcode | Notes |
|---|---|---|
| `execDebugInfo` | ~0x26 | Script debug line/file tracking |
| `execDelegateFunction` | ~0x2C | Delegate invocation |
| `execDelegateProperty` | ~0x2D | Delegate property access |
| `execPrimitiveCast` | ~0x36 | Primitive type cast dispatcher |
| `execStringToName` | ~0x5A | String→Name conversion |
| `execPrivateSet` | TBD | Private variable assignment |

---

## 6. Complete Core.u Ordinal Reference (161 non-bare + 15 bare)

All native functions from retail Core.u, sorted by iNative:

```
Ordinal  Function
-------  --------
    112  Concat_StrStr
    113  GotoState
    114  EqualEqual_ObjectObject
    115  Less_StrStr
    116  Greater_StrStr
    117  Enable
    118  Disable
    119  NotEqual_ObjectObject
    120  LessEqual_StrStr
    121  GreaterEqual_StrStr
    122  EqualEqual_StrStr
    123  NotEqual_StrStr
    124  ComplementEqual_StrStr
    125  Len
    126  InStr
    127  Mid
    128  Left
    129  Not_PreBool
    130  AndAnd_BoolBool
    131  XorXor_BoolBool
    132  OrOr_BoolBool
    133  MultiplyEqual_ByteByte
    134  DivideEqual_ByteByte
    135  AddEqual_ByteByte
    136  SubtractEqual_ByteByte
    137  AddAdd_PreByte
    138  SubtractSubtract_PreByte
    139  AddAdd_Byte
    140  SubtractSubtract_Byte
    141  Complement_PreInt
    142  EqualEqual_RotatorRotator
    143  Subtract_PreInt
    144  Multiply_IntInt
    145  Divide_IntInt
    146  Add_IntInt
    147  Subtract_IntInt
    148  LessLess_IntInt
    149  GreaterGreater_IntInt
    150  Less_IntInt
    151  Greater_IntInt
    152  LessEqual_IntInt
    153  GreaterEqual_IntInt
    154  EqualEqual_IntInt
    155  NotEqual_IntInt
    156  And_IntInt
    157  Xor_IntInt
    158  Or_IntInt
    159  MultiplyEqual_IntFloat
    160  DivideEqual_IntFloat
    161  AddEqual_IntInt
    162  SubtractEqual_IntInt
    163  AddAdd_PreInt
    164  SubtractSubtract_PreInt
    165  AddAdd_Int
    166  SubtractSubtract_Int
    167  Rand
    168  At_StrStr
    169  Subtract_PreFloat
    170  MultiplyMultiply_FloatFloat
    171  Multiply_FloatFloat
    172  Divide_FloatFloat
    173  Percent_FloatFloat
    174  Add_FloatFloat
    175  Subtract_FloatFloat
    176  Less_FloatFloat
    177  Greater_FloatFloat
    178  LessEqual_FloatFloat
    179  GreaterEqual_FloatFloat
    180  EqualEqual_FloatFloat
    181  NotEqual_FloatFloat
    182  MultiplyEqual_FloatFloat
    183  DivideEqual_FloatFloat
    184  AddEqual_FloatFloat
    185  SubtractEqual_FloatFloat
    186  Abs
    187  Sin
    188  Cos
    189  Tan
    190  Atan
    191  Exp
    192  Loge
    193  Sqrt
    194  Square
    195  FRand
    196  GreaterGreaterGreater_IntInt
    203  NotEqual_RotatorRotator
    210  ComplementEqual_FloatFloat
    211  Subtract_PreVector
    212  Multiply_VectorFloat
    213  Multiply_FloatVector
    214  Divide_VectorFloat
    215  Add_VectorVector
    216  Subtract_VectorVector
    217  EqualEqual_VectorVector
    218  NotEqual_VectorVector
    219  Dot_VectorVector
    220  Cross_VectorVector
    221  MultiplyEqual_VectorFloat
    222  DivideEqual_VectorFloat
    223  AddEqual_VectorVector
    224  SubtractEqual_VectorVector
    225  VSize
    226  Normal
    227  Invert
    229  GetAxes
    230  GetUnAxes
    231  Log
    232  Warn
    234  Right
    235  Caps
    236  Chr
    237  Asc
    238  RemoveInvalidChars
    242  EqualEqual_BoolBool
    243  NotEqual_BoolBool
    244  FMin
    245  FMax
    246  FClamp
    247  Lerp
    248  Smerp
    249  Min
    250  Max
    251  Clamp
    252  VRand
    254  EqualEqual_NameName
    255  NotEqual_NameName
    258  ClassIsChildOf
    275  LessLess_VectorRotator
    276  GreaterGreater_VectorRotator
    281  IsInState
    284  GetStateName
    287  Multiply_RotatorFloat
    288  Multiply_FloatRotator
    289  Divide_RotatorFloat
    290  MultiplyEqual_RotatorFloat
    291  DivideEqual_RotatorFloat
    296  Multiply_VectorVector
    297  MultiplyEqual_VectorVector
    300  MirrorVectorByNormal
    303  IsA
    316  Add_RotatorRotator
    317  Subtract_RotatorRotator
    318  AddEqual_RotatorRotator
    319  SubtractEqual_RotatorRotator
    320  RotRand
    536  SaveConfig
   1005  GetFirstPackageClass
   1006  GetNextClass
   1007  FreePackageObjects
   1010  LoadConfig
   1227  Itoa
   1228  Atoi
   1301  RewindToFirstClass
   1306  Strnicmp
   1850  ClearOuter
   1851  ShortestAngle2D
   1852  Clock
   1853  Unclock
   1854  GetRegistryKey
   1855  SetRegistryKey
   2718  LogSnd
```

### Gaps in the ordinal sequence (unused slots)

```
197-202, 204-209, 228, 233, 239-241, 253, 256-257, 259-274,
277-280, 282-283, 285-286, 292-295, 298-299, 301-302, 304-315, 321+
```

Some of these gaps are filled by bare native auto-assigned ordinals.

### Bare natives (iNative=0)

```
Acos, Asin, ClockwiseFrom_IntInt, DynamicLoadObject, FindObject,
GetEnum, GetPropertyText, InterpCurveEval, Localize, Main (Commandlet),
Normalize (rotator), OrthoRotation, ResetConfig, SetPropertyText,
StaticSaveConfig
```

---

## 7. Methodology

The iNative value was read from the **end** of each UFunction's serial data in
Core.u, bypassing complex variable-length compact index parsing:

```
UFunction serial layout:
[UField][UStruct...][Script bytecode] iNative(WORD) OperPrec(BYTE) FuncFlags(DWORD)
                                      ^-- serial_offset + serial_size - 7
```

Validated against 5 known ordinals: IsA(303), Enable(117), Log(231), GotoState(113), SaveConfig(536).

Cross-referenced against 244 IMPLEMENT_FUNCTION entries parsed from `src/core/UnScript.cpp`
using regex extraction of `IMPLEMENT_FUNCTION( ClassName, ordinal_expr, exec_funcname )`.

### Next steps for remaining unknowns

1. **Bare native ordinals** (14 functions): Disassemble `retail/system/Core.dll`,
   find `GRegisterNative()` calls to map exec function pointers to ordinals.
2. **C++-only native ordinals** (51 functions): Same Core.dll disassembly approach.
3. **EX_* bytecodes** (6 handlers): Find the GNatives[] table in Core.dll to
   identify which opcode slots these handlers occupy.
