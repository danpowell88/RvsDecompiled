#!/usr/bin/env python3
"""
resolve_nfun.py - Resolve __NFUN_NNN__ placeholders in decompiled UnrealScript files.

UE-Explorer left native function calls as __NFUN_NNN__(args) placeholders.
This script replaces them with their proper names/operators.
"""

import re
import sys
from pathlib import Path

# Complete mapping from native ordinal → (kind, name)
# kind is one of: 'binop', 'compound', 'preop', 'postop', 'func'
# binop:    __NFUN_NNN__(A, B)  →  (A OP B)
# compound: __NFUN_NNN__(A, B)  →  (A OP B)   (compound assignments like +=)
# preop:    __NFUN_NNN__(A)     →  (OPA)
# postop:   __NFUN_NNN__(A)     →  (AOP)
# func:     __NFUN_NNN__(args)  →  Name(args)

NFUN_MAP = {
    # ── Bool operators ───────────────────────────────────────────────────────
    129: ('preop',    '!'),
    130: ('binop',    '&&'),
    131: ('binop',    '^^'),
    132: ('binop',    '||'),
    242: ('binop',    '=='),
    243: ('binop',    '!='),

    # ── Byte operators ───────────────────────────────────────────────────────
    133: ('compound', '*='),
    134: ('compound', '/='),
    135: ('compound', '+='),
    136: ('compound', '-='),
    137: ('preop',    '++'),
    138: ('preop',    '--'),
    139: ('postop',   '++'),
    140: ('postop',   '--'),

    # ── Int operators ────────────────────────────────────────────────────────
    141: ('preop',    '~'),
    143: ('preop',    '-'),
    144: ('binop',    '*'),
    145: ('binop',    '/'),
    146: ('binop',    '+'),
    147: ('binop',    '-'),
    148: ('binop',    '<<'),
    149: ('binop',    '>>'),
    150: ('binop',    '<'),
    151: ('binop',    '>'),
    152: ('binop',    '<='),
    153: ('binop',    '>='),
    154: ('binop',    '=='),
    155: ('binop',    '!='),
    156: ('binop',    '&'),
    157: ('binop',    '^'),
    158: ('binop',    '|'),
    159: ('compound', '*='),
    160: ('compound', '/='),
    161: ('compound', '+='),
    162: ('compound', '-='),
    163: ('preop',    '++'),
    164: ('preop',    '--'),
    165: ('postop',   '++'),
    166: ('postop',   '--'),
    167: ('func',     'Rand'),
    196: ('binop',    '>>>'),

    # ── Float operators ──────────────────────────────────────────────────────
    169: ('preop',    '-'),
    170: ('binop',    '**'),
    171: ('binop',    '*'),
    172: ('binop',    '/'),
    173: ('binop',    '%'),
    174: ('binop',    '+'),
    175: ('binop',    '-'),
    176: ('binop',    '<'),
    177: ('binop',    '>'),
    178: ('binop',    '<='),
    179: ('binop',    '>='),
    180: ('binop',    '=='),
    181: ('binop',    '!='),
    182: ('compound', '*='),
    183: ('compound', '/='),
    184: ('compound', '+='),
    185: ('compound', '-='),
    186: ('func',     'Abs'),
    187: ('func',     'Sin'),
    188: ('func',     'Cos'),
    189: ('func',     'Tan'),
    190: ('func',     'Atan'),
    191: ('func',     'Exp'),
    192: ('func',     'Loge'),
    193: ('func',     'Sqrt'),
    194: ('func',     'Square'),
    195: ('func',     'FRand'),
    210: ('binop',    '~='),
    244: ('func',     'FMin'),
    245: ('func',     'FMax'),
    246: ('func',     'FClamp'),
    247: ('func',     'Lerp'),
    248: ('func',     'Smerp'),

    # ── Int math functions ───────────────────────────────────────────────────
    249: ('func',     'Min'),
    250: ('func',     'Max'),
    251: ('func',     'Clamp'),

    # ── String operators / functions ─────────────────────────────────────────
    112: ('binop',    '$'),     # string concatenation
    123: ('binop',    '!='),
    124: ('binop',    '~='),
    125: ('func',     'Len'),
    126: ('func',     'InStr'),
    127: ('func',     'Mid'),
    128: ('func',     'Left'),
    168: ('binop',    '@'),     # string concatenation with space
    234: ('func',     'Right'),
    235: ('func',     'Caps'),
    236: ('func',     'Chr'),
    237: ('func',     'Asc'),
    238: ('func',     'RemoveInvalidChars'),

    # ── Name operators ───────────────────────────────────────────────────────
    114: ('binop',    '=='),
    115: ('binop',    '<'),
    116: ('binop',    '>'),
    254: ('binop',    '=='),
    255: ('binop',    '!='),

    # ── Object / reference operators ─────────────────────────────────────────
    119: ('binop',    '!='),
    122: ('binop',    '=='),

    # ── Vector operators / functions ─────────────────────────────────────────
    203: ('binop',    '!='),
    211: ('preop',    '-'),
    212: ('binop',    '*'),
    213: ('binop',    '*'),
    214: ('binop',    '/'),
    215: ('binop',    '+'),
    216: ('binop',    '-'),
    217: ('binop',    '=='),
    218: ('binop',    '!='),
    219: ('func',     'Dot'),
    220: ('func',     'Cross'),
    221: ('compound', '*='),
    222: ('compound', '/='),
    223: ('compound', '+='),
    224: ('compound', '-='),
    225: ('func',     'VSize'),
    226: ('func',     'Normal'),
    229: ('func',     'GetAxes'),
    230: ('func',     'GetUnAxes'),
    252: ('func',     'VRand'),
    275: ('binop',    '<<'),
    276: ('binop',    '>>'),
    296: ('binop',    '*'),
    297: ('compound', '*='),
    300: ('func',     'MirrorVectorByNormal'),

    # ── Rotator operators / functions ────────────────────────────────────────
    287: ('binop',    '*'),
    290: ('compound', '*='),
    316: ('binop',    '+'),
    317: ('binop',    '-'),
    318: ('compound', '+='),
    319: ('compound', '-='),
    320: ('func',     'RotRand'),

    # ── Core Object / Actor functions ────────────────────────────────────────
    113: ('func',     'GotoState'),
    117: ('func',     'Enable'),
    118: ('func',     'Disable'),
    231: ('func',     'Log'),
    232: ('func',     'Warn'),
    233: ('func',     'Error'),
    256: ('func',     'Sleep'),
    258: ('func',     'ClassIsChildOf'),
    259: ('func',     'PlayAnim'),
    260: ('func',     'LoopAnim'),
    261: ('func',     'FinishAnim'),
    262: ('func',     'SetCollision'),
    263: ('func',     'HasAnim'),
    266: ('func',     'Move'),
    272: ('func',     'SetOwner'),
    277: ('func',     'Trace'),
    278: ('func',     'Spawn'),
    279: ('func',     'Destroy'),
    280: ('func',     'SetTimer'),
    281: ('func',     'IsInState'),
    282: ('func',     'IsAnimating'),
    283: ('func',     'SetCollisionSize'),
    284: ('func',     'GetStateName'),
    294: ('func',     'TweenAnim'),
    298: ('func',     'SetBase'),
    299: ('func',     'SetRotation'),
    301: ('func',     'FinishInterpolation'),
    303: ('func',     'IsA'),
    314: ('func',     'Warp'),
    315: ('func',     'UnWarp'),
    536: ('func',     'SaveConfig'),
    1010: ('func',    'LoadConfig'),

    # ── Actor iterator functions ──────────────────────────────────────────────
    304: ('func',     'AllActors'),
    306: ('func',     'BasedActors'),
    307: ('func',     'TouchingActors'),
    310: ('func',     'RadiusActors'),
    311: ('func',     'VisibleActors'),
    312: ('func',     'VisibleCollidingActors'),
    313: ('func',     'DynamicActors'),
    321: ('func',     'CollidingActors'),

    # ── Pawn / Controller AI functions ───────────────────────────────────────
    500: ('func',     'MoveTo'),
    502: ('func',     'MoveToward'),
    508: ('func',     'FinishRotation'),
    512: ('func',     'MakeNoise'),
    514: ('func',     'LineOfSightTo'),
    517: ('func',     'FindPathToward'),
    518: ('func',     'FindPathTo'),
    520: ('func',     'actorReachable'),
    521: ('func',     'pointReachable'),
    525: ('func',     'FindRandomDest'),
    527: ('func',     'WaitForLanding'),
    529: ('func',     'AddController'),
    530: ('func',     'RemoveController'),
    532: ('func',     'PlayerCanSeeMe'),
    533: ('func',     'CanSee'),
    539: ('func',     'GetMapName'),
    544: ('func',     'ResetKeyboard'),
    546: ('func',     'UpdateURL'),
    547: ('func',     'GetURLMap'),
    548: ('func',     'FastTrace'),

    # ── Canvas functions ─────────────────────────────────────────────────────
    464: ('func',     'StrLen'),
    465: ('func',     'DrawText'),
    466: ('func',     'DrawTile'),
    467: ('func',     'DrawActor'),
    468: ('func',     'DrawTileClipped'),
    469: ('func',     'DrawTextClipped'),
    470: ('func',     'TextSize'),
    473: ('func',     'DrawTile'),
    474: ('func',     'DrawColoredText'),

    # ── R6 / Game-specific functions (1000+) ─────────────────────────────────
    1003: ('func',    'LoadCampaign'),
    1004: ('func',    'SaveCampaign'),
    1005: ('func',    'GetFirstPackageClass'),
    1006: ('func',    'GetNextClass'),
    1007: ('func',    'FreePackageObjects'),
    1009: ('func',    'GetGameOptions'),
    1012: ('func',    'GetTime'),
    1201: ('func',    'NativeInit'),
    1202: ('func',    'NativeGetPingTimeOut'),
    1203: ('func',    'NativeGetSeconds'),
    1204: ('func',    'NativeGetServerRegistered'),
    1205: ('func',    'NativePollCallbacks'),
    1206: ('func',    'SortServers'),
    1207: ('func',    'NativeInitModInfo'),
    1210: ('func',    'AbortScoreSubmission'),
    1214: ('func',    'NativeReceiveServer'),
    1218: ('func',    'RequestGSCDKeyAuthID'),
    1219: ('func',    'CancelGSCDKeyActID'),
    1220: ('func',    'NativeMSClientReqAltInfo'),
    1221: ('func',    'GetMaxAvailPorts'),
    1222: ('func',    'NativeInitFavorites'),
    1223: ('func',    'NativeUpdateFavorites'),
    1224: ('func',    'FindPlayer'),
    1225: ('func',    'NativeGetPingTime'),
    1226: ('func',    'RequestGSCDKeyActID'),
    1227: ('func',    'Itoa'),
    1228: ('func',    'Atoi'),
    1229: ('func',    'NativeFillSvrContainer'),
    1230: ('func',    'GetFPlayerMenuInfo'),
    1231: ('func',    'SetFPlayerMenuInfo'),
    1232: ('func',    'GetPlayerSetupInfo'),
    1233: ('func',    'SetPlayerSetupInfo'),
    1234: ('func',    'NativeInitMSClient'),
    1235: ('func',    'NativeRequestMSList'),
    1236: ('func',    'NativeResetSvrContainer'),
    1237: ('func',    'NativeReceiveAltInfo'),
    1238: ('func',    'AddPlayerToIDList'),
    1239: ('func',    'PlayerIsInIDList'),
    1240: ('func',    'NativeInitRegServer'),
    1241: ('func',    'NativeRegServerRouterLogin'),
    1242: ('func',    'NativeRegServerGetLobbies'),
    1243: ('func',    'NativeRegisterServer'),
    1244: ('func',    'NativeRouterDisconnect'),
    1245: ('func',    'NativeServerLogin'),
    1246: ('func',    'SetGameServiceRequestState'),
    1247: ('func',    'GetGameServiceRequestState'),
    1248: ('func',    'NativeGetInitialized'),
    1249: ('func',    'NativeUnInitMSClient'),
    1250: ('func',    'NativeUpdateServer'),
    1251: ('func',    'SetRegisteredWithMS'),
    1252: ('func',    'GetRegisteredWithMS'),
    1253: ('func',    'SetLastServerQueried'),
    1254: ('func',    'NativePingReq'),
    1255: ('func',    'NativeRefreshServer'),
    1256: ('func',    'ConvertGameTypeIntToString'),
    1259: ('func',    'NativeInitCDKey'),
    1260: ('func',    'NativeUnInitCDKey'),
    1261: ('func',    'NativeCDKeyValidateUser'),
    1263: ('func',    'NativeCDKeyDisconnecUser'),
    1264: ('func',    'NativeReceiveValidation'),
    1265: ('func',    'SetCDKeyInitialised'),
    1266: ('func',    'GetCDKeyInitialised'),
    1267: ('func',    'NativeGetMSClientInitialized'),
    1268: ('func',    'NativeGetLoggedInUbiDotCom'),
    1269: ('func',    'NativeRegServerMemberJoin'),
    1270: ('func',    'NativeRegServerMemberLeave'),
    1272: ('func',    'NativeMSCLientLeaveServer'),
    1273: ('func',    'GetServerOptions'),
    1274: ('func',    'NativeRegServerServerClose'),
    1275: ('func',    'NativeGetRegServerIntialized'),
    1276: ('func',    'NativeRegServerShutDown'),
    1277: ('func',    'NativeMSCLientJoinServer'),
    1278: ('func',    'NativeGetMilliSeconds'),
    1279: ('func',    'SortFPlayerMenuInfo'),
    1280: ('func',    'GetCurrentMapNum'),
    1281: ('func',    'SetCurrentMapNum'),
    1282: ('func',    'SpecialDestroy'),
    1283: ('func',    'SaveServerOptions'),
    1284: ('func',    'GetIDListIPAddr'),
    1285: ('func',    'GetIDListAuthID'),
    1286: ('func',    'GetIDListSize'),
    1287: ('func',    'ConnectionInterrupted'),
    1288: ('func',    'NativeInitGSClient'),
    1289: ('func',    'NativeGSClientPostMessage'),
    1290: ('func',    'RemoveFromIDList'),
    1293: ('func',    'NativeGSClientUpdateServerInfo'),
    1294: ('func',    'NativeServerRoundStart'),
    1295: ('func',    'NativeServerRoundFinish'),
    1296: ('func',    'NativeSetMatchResult'),
    1297: ('func',    'NativeSubmitMatchResult'),
    1298: ('func',    'NativeProcessIcmpPing'),
    1299: ('func',    'SetGSClientComInterface'),
    1300: ('func',    'LogGSVersion'),
    1301: ('func',    'RewindToFirstClass'),
    1302: ('func',    'GetMissionDescription'),
    1303: ('func',    'NativeNonUbiMatchMaking'),
    1304: ('func',    'NativeNonUbiMatchMakingAddress'),
    1305: ('func',    'NativeNonUbiMatchMakingPassword'),
    1306: ('func',    'Strnicmp'),
    1307: ('func',    'DisconnectAllCDKeyPlayers'),
    1308: ('func',    'CleanPlayerIDList'),
    1309: ('func',    'ResetAuthId'),
    1310: ('func',    'HandleAnyLobbyConnectionFail'),
    1311: ('func',    'SetServerBeacon'),
    1312: ('func',    'GetServerBeacon'),
    1313: ('func',    'OnSameSubNet'),
    1314: ('func',    'GetDisplayListSize'),
    1315: ('func',    'GetGlobalIdFromPlayerIDList'),
    1317: ('func',    'GetPBConnectStatus'),
    1318: ('func',    'IsPBEnabled'),
    1319: ('func',    'PBNotifyServerTravel'),
    1320: ('func',    'PB_CanPlayerSpawn'),
    1350: ('func',    'NativeCheckGSClientAlive'),
    1351: ('func',    'NativeGetLobbyID'),
    1352: ('func',    'NativeGetGroupID'),
    1353: ('func',    'TestRegServerLobbyDisconnect'),
    1354: ('func',    'NativeMSClientServerConnected'),
    1355: ('func',    'NativeGetMaxPlayers'),
    1356: ('func',    'NativeRunAllTests'),
    1400: ('func',    'IsPBClientEnabled'),
    1401: ('func',    'SetPBStatus'),
    1402: ('func',    'IsPBServerEnabled'),
    1411: ('func',    'AddToTeam'),
    1412: ('func',    'InsertToTeam'),
    1413: ('func',    'DeletePoint'),
    1416: ('func',    'LoadPlanning'),
    1417: ('func',    'SavePlanning'),
    1418: ('func',    'GetNumberOfFiles'),
    1419: ('func',    'GetGameVersion'),
    1500: ('func',    'GetAnimGroup'),
    1501: ('func',    'WasSkeletonUpdated'),
    1502: ('func',    'EnableCollision'),
    1503: ('func',    'EnableCollision'),
    1504: ('func',    'GetSystemUserName'),
    1506: ('func',    'DbgVectorAdd'),
    1507: ('func',    'CheckCylinderTranslation'),
    1508: ('func',    'GetPeekingRatioNorm'),
    1509: ('func',    'NeedToOpenDoor'),
    1510: ('func',    'GotoOpenDoorState'),
    1511: ('func',    'WillOpenOnTouch'),
    1512: ('func',    'GetMaxRotationOffset'),
    1513: ('func',    'IsAvailableInGameType'),
    1515: ('func',    'ResetLevelInNative'),
    1517: ('func',    'GetMovementDirection'),
    1518: ('func',    'GetCampaignNameFromParam'),
    1519: ('func',    'GetMapNameExt'),
    1520: ('func',    'ConvertIntTimeToString'),
    1521: ('func',    'GetLocStringWithActionKey'),
    1524: ('func',    'GetModMgr'),
    1525: ('func',    'GetNbFile'),
    1526: ('func',    'GetFileName'),
    1527: ('func',    'DeleteFile'),
    1528: ('func',    'FindFile'),
    1550: ('func',    'InitGSClient'),
    1551: ('func',    'GetGameManager'),
    1603: ('func',    'StopLipSynch'),
    1604: ('func',    'FinalizeLoading'),
    1605: ('func',    'DrawNativeHUD'),
    1606: ('func',    'UseVirtualSize'),
    1607: ('func',    'SetVirtualSize'),
    1608: ('func',    'AddWritableMapIcon'),
    1609: ('func',    'HudStep'),

    # ── R6 AI / Navigation / Physics ─────────────────────────────────────────
    1800: ('func',    'FindSpot'),
    1802: ('func',    'RenderBones'),
    1803: ('func',    'FirstInit'),
    1804: ('func',    'AddImpulseToBone'),
    1805: ('func',    'ClearChannel'),
    1806: ('func',    'R6Trace'),
    1810: ('func',    'MakePathToRun'),
    1811: ('func',    'FindPlaceToTakeCover'),
    1812: ('func',    'FollowPath'),
    1813: ('func',    'PickActorAdjust'),
    1814: ('func',    'FollowPathTo'),
    1815: ('func',    'CanWalkTo'),
    1816: ('func',    'FindGrenadeDirectionToHitActor'),
    1817: ('func',    'FindPlaceToFire'),
    1818: ('func',    'FindInvestigationPoint'),
    1820: ('func',    'GetNextRandomNode'),
    1821: ('func',    'CallBackupForAttack'),
    1822: ('func',    'MakeBackupList'),
    1823: ('func',    'CallBackupForInvestigation'),
    1824: ('func',    'FindBetterShotLocation'),
    1825: ('func',    'Init'),
    1826: ('func',    'FindNearestZoneForHostage'),
    1827: ('func',    'HaveAClearShot'),
    1828: ('func',    'CallVisibleTerrorist'),
    1829: ('func',    'IsAttackSpotStillValid'),
    1830: ('func',    'FirstInit'),
    1831: ('func',    'FindRandomPointInArea'),
    1832: ('func',    'IsPointInZone'),
    1833: ('func',    'FindClosestPointTo'),
    1834: ('func',    'HaveTerrorist'),
    1835: ('func',    'HaveHostage'),
    1836: ('func',    'AddHostage'),
    1837: ('func',    'OrderTerroListFromDistanceTo'),
    1838: ('func',    'GetClosestHostage'),
    1840: ('func',    'DebugFunction'),
    1841: ('func',    'R6GetViewRotation'),
    1842: ('func',    'GetRotationOffset'),
    1843: ('func',    'UpdateReticule'),
    1844: ('func',    'FootStep'),
    1845: ('func',    'PawnCanBeHurtFrom'),
    1846: ('func',    'MoveHitBone'),
    1850: ('func',    'ClearOuter'),
    1851: ('func',    'ShortestAngle2D'),
    1854: ('func',    'GetRegistryKey'),

    # ── R6 Bullet / World ────────────────────────────────────────────────────
    2001: ('func',    'BulletGoesThroughSurface'),
    2002: ('func',    'GetKillResult'),
    2003: ('func',    'GetStunResult'),
    2004: ('func',    'ToggleHeatProperties'),
    2005: ('func',    'SetMotionBlurIntensity'),
    2006: ('func',    'GetThroughResult'),
    2007: ('func',    'FindPathToNextPoint'),
    2008: ('func',    'GetTagInformations'),
    2010: ('func',    'SetController'),
    2011: ('func',    'SetPlanningMode'),
    2012: ('func',    'SetFloorToDraw'),
    2013: ('func',    'GetClickResult'),
    2014: ('func',    'InPlanningMode'),
    2015: ('func',    'ConvertGameTypeToInt'),
    2016: ('func',    'GetXYPoint'),
    2017: ('func',    'PlanningTrace'),
    2018: ('func',    'AddBreach'),
    2019: ('func',    'RemoveBreach'),
    2020: ('func',    'AddNewModExtraPath'),
    2021: ('func',    'SetSystemMod'),
    2022: ('func',    'SetGeneralModSettings'),
    2023: ('func',    'IsOfficialMod'),
    2024: ('func',    'GetASBuildVersion'),
    2025: ('func',    'GetIWBuildVersion'),

    # ── R6 Pawn movement / look ───────────────────────────────────────────────
    2200: ('func',    'AdjustFluidCollisionCylinder'),
    2201: ('func',    'MoveToPosition'),
    2202: ('func',    'GetTargetPosition'),
    2203: ('func',    'GetLadderPosition'),
    2205: ('func',    'GetEntryPosition'),
    2206: ('func',    'CheckEnvironment'),
    2207: ('func',    'SetOrientation'),
    2209: ('func',    'FindNearbyWaitSpot'),
    2210: ('func',    'UnLinkSkelAnim'),
    2211: ('func',    'UpdateCircumstantialAction'),
    2212: ('func',    'SetPawnScale'),
    2213: ('func',    'UpdateSpectatorReticule'),
    2214: ('func',    'PawnLook'),
    2216: ('func',    'PawnLookAt'),
    2218: ('func',    'UpdatePawnTrackActor'),
    2219: ('func',    'LookAroundRoom'),
    2220: ('func',    'ActorReachableFromLocation'),
    2221: ('func',    'FindSafeSpot'),
    2222: ('func',    'AClearShotIsAvailable'),
    2223: ('func',    'ClearToSnipe'),
    2403: ('func',    'Draw3DLine'),

    # ── R6 Graphics / Video / HUD ─────────────────────────────────────────────
    2600: ('func',    'ToggleNightProperties'),
    2601: ('func',    'VideoOpen'),
    2603: ('func',    'VideoPlay'),
    2604: ('func',    'VideoStop'),
    2605: ('func',    'ToggleScopeProperties'),
    2607: ('func',    'LoadRandomBackgroundImage'),
    2608: ('func',    'DrawDashedLine'),
    2609: ('func',    'DrawText3D'),
    2610: ('func',    'RenderLevelFromMe'),
    2612: ('func',    'NotifyMatchStart'),
    2614: ('func',    'GetNbAvailableResolutions'),
    2615: ('func',    'GetAvailableResolution'),
    2616: ('func',    'ReplaceTexture'),
    2617: ('func',    'IsVideoHardwareAtLeast64M'),
    2618: ('func',    'GetCanvas'),
    2619: ('func',    'EnableLoadingScreen'),
    2620: ('func',    'AddMessageToConsole'),
    2621: ('func',    'UpdateGraphicOptions'),
    2622: ('func',    'GarbageCollect'),
    2623: ('func',    'SetPos'),
    2624: ('func',    'SetOrigin'),
    2625: ('func',    'SetClip'),
    2626: ('func',    'SetDrawColor'),
    2627: ('func',    'DrawStretchedTextureSegmentNative'),
    2628: ('func',    'ClipTextNative'),

    # ── R6 Sound ──────────────────────────────────────────────────────────────
    2700: ('func',    'ToggleHeartBeatProperties'),
    2701: ('func',    'LoadCustomMissionAvailable'),
    2702: ('func',    'SaveCustomMissionAvailable'),
    2703: ('func',    'IsPlayingSound'),
    2704: ('func',    'ResetVolume_AllTypeSound'),
    2706: ('func',    'GetKey'),
    2707: ('func',    'GetActionKey'),
    2708: ('func',    'GetEnumName'),
    2709: ('func',    'ChangeInputSet'),
    2710: ('func',    'SetKey'),
    2711: ('func',    'SetBankSound'),
    2712: ('func',    'StopAllSounds'),
    2713: ('func',    'SetSoundOptions'),
    2714: ('func',    'ChangeVolumeTypeLinear'),
    2716: ('func',    'AddSoundBank'),
    2717: ('func',    'AddAndFindBankInSound'),
    2719: ('func',    'StopAllSoundsActor'),
    2720: ('func',    'ResetVolume_TypeSound'),
    2721: ('func',    'FadeSound'),
    2722: ('func',    'SaveCurrentFadeValue'),
    2723: ('func',    'ReturnSavedFadeValue'),
    2724: ('func',    'LocalizeTraining'),
    2725: ('func',    'StopSound'),
    2726: ('func',    'PlayVoicesPriority'),
    2727: ('func',    'PlayWeaponSound'),
    2728: ('func',    'StopWeaponSound'),
    2729: ('func',    'SendPlaySound'),
    2730: ('func',    'PlayVoices'),
    2731: ('func',    'SetAudioInfo'),
    2732: ('func',    'UseSound'),

    # ── R6 Writable Map ───────────────────────────────────────────────────────
    2800: ('func',    'DrawWritableMap'),
    2801: ('func',    'AddWritableMapPoint'),
    2802: ('func',    'AddEncodedWritableMapStrip'),

    # ── R6 Decals / Groups / Matinee ──────────────────────────────────────────
    2900: ('func',    'AddDecal'),
    2907: ('func',    'GetBoneInformation'),
    2909: ('func',    'SceneDestroyed'),

    # ── R6 Weapon Sound ───────────────────────────────────────────────────────
    3000: ('func',    'PlayLocalWeaponSound'),
    3003: ('func',    'CallSndEngineInit'),

    # ── R6 CD Key / Patch service ─────────────────────────────────────────────
    3102: ('func',    'StartPatch'),
    3105: ('func',    'GetDownloadProgress'),
    3106: ('func',    'AbortPatchService'),
    3107: ('func',    'GetExitCause'),
    3109: ('func',    'IsCDKeyValidOnMachine'),

    # ── R6 Internet Game Service (R6AbstractGameService) ─────────────────────
    3500: ('func',    'Initialize'),
    3501: ('func',    'InitGSCDKey'),
    3502: ('func',    'InitializeMSClient'),
    3510: ('func',    'UnInitializeMSClient'),
    3520: ('func',    'RefreshServers'),
    3521: ('func',    'RefreshOneServer'),
    3522: ('func',    'IsRefreshServersInProgress'),
    3523: ('func',    'StopRefreshServers'),
    3530: ('func',    'NativeGetSeconds'),
    3531: ('func',    'NativeGetMSClientInitialized'),
    3532: ('func',    'GetMaxUbiServerNameSize'),
    3540: ('func',    'NativeSetMatchResult'),
    3541: ('func',    'SetLastServerQueried'),
    3550: ('func',    'NativeIsRouterDisconnect'),
    3551: ('func',    'NativeIsWaitingForGSInit'),
    3560: ('func',    'NativeUpdateServer'),
    3561: ('func',    'NativeLogOutServer'),
    3562: ('func',    'NativeProcessIcmpPing'),
    3563: ('func',    'HandleAnyLobbyConnectionFail'),
    3564: ('func',    'EnterCDKey'),
    3570: ('func',    'NativeMSClientReqAltInfo'),
    3571: ('func',    'NativeMSCLientJoinServer'),

    # ── Core physics (UE2 built-ins at high ordinals) ─────────────────────────
    3969: ('func',    'MoveSmooth'),
    3970: ('func',    'SetPhysics'),
    3971: ('func',    'AutonomousPhysics'),

    # ── Karma physics wrapper ─────────────────────────────────────────────────
    4010: ('func',    'MP2IOKarmaAllNativeFct'),
    4042: ('func',    'KMP2IOKarmaAllNativeFct'),
}


def split_args(s: str) -> list[str]:
    """Split an argument string on top-level commas (respecting nested parens)."""
    args = []
    depth = 0
    current: list[str] = []
    for ch in s:
        if ch == ',' and depth == 0:
            args.append(''.join(current).strip())
            current = []
        else:
            if ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
            current.append(ch)
    if current:
        args.append(''.join(current).strip())
    return [a for a in args if a]


def transform_nfun(nfun_num: int, args_str: str, nfun_map: dict) -> str:
    """Transform __NFUN_NNN__(args_str) to proper UnrealScript."""
    args = split_args(args_str)
    if nfun_num not in nfun_map:
        return f"__NFUN_{nfun_num}__({args_str}) /*unknown*/"

    kind, name = nfun_map[nfun_num]

    if kind in ('binop', 'compound'):
        if len(args) >= 2:
            return f"({args[0]} {name} {args[1]})"
        elif len(args) == 1:
            return f"({args[0]} {name} ???)"
        return f"(??? {name} ???)"
    elif kind == 'preop':
        if args:
            return f"({name}{args[0]})"
        return f"({name}???)"
    elif kind == 'postop':
        if args:
            return f"({args[0]}{name})"
        return f"(???{name})"
    else:  # func
        return f"{name}({args_str})"


_NFUN_PATTERN = re.compile(r'__NFUN_(\d+)__\(')


def resolve_all(text: str, nfun_map: dict) -> str:
    """
    Iteratively replace all __NFUN_NNN__(...) calls in text.
    Works inside-out: each pass resolves the innermost calls first
    (those whose argument lists contain no further __NFUN__ references),
    repeating until no calls remain.
    """
    while True:
        m = _NFUN_PATTERN.search(text)
        if m is None:
            break

        nfun_num = int(m.group(1))
        paren_start = m.end() - 1  # index of the opening '('

        # Walk forward to find the matching closing paren.
        depth = 1
        i = paren_start + 1
        while i < len(text) and depth > 0:
            if text[i] == '(':
                depth += 1
            elif text[i] == ')':
                depth -= 1
            i += 1
        # text[paren_start+1 : i-1] is the raw args string.
        args_str = text[paren_start + 1:i - 1]

        # Recursively resolve any nested NFUN calls inside the args first.
        resolved_args = resolve_all(args_str, nfun_map)

        replacement = transform_nfun(nfun_num, resolved_args, nfun_map)
        text = text[:m.start()] + replacement + text[i:]

    return text


def process_file(path: Path, nfun_map: dict) -> bool:
    """Resolve NFUN placeholders in a single file. Returns True if the file was changed."""
    try:
        original = path.read_text(encoding='utf-8', errors='replace')
    except Exception as e:
        print(f"  SKIP (read error): {path}: {e}")
        return False

    if '__NFUN_' not in original:
        return False

    resolved = resolve_all(original, nfun_map)

    if resolved == original:
        return False

    path.write_text(resolved, encoding='utf-8')
    return True


def main(src_root: str) -> None:
    root = Path(src_root)
    if not root.is_dir():
        print(f"ERROR: '{src_root}' is not a directory.")
        sys.exit(1)

    uc_files = sorted(root.rglob('*.uc'))
    print(f"Processing {len(uc_files)} .uc files in {root} ...")

    changed = 0
    skipped = 0
    for path in uc_files:
        if process_file(path, NFUN_MAP):
            changed += 1
        else:
            skipped += 1

    print(f"Done. {changed} files updated, {skipped} files unchanged.")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python resolve_nfun.py <src_directory>")
        sys.exit(1)
    main(sys.argv[1])
