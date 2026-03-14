//=============================================================================
// UWindowBase - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowBase extends Object;

const F_Normal = 0;
const F_Bold = 1;
const F_Large = 2;
const F_LargeBold = 3;
const F_ocraext17 = 0;
const F_MenuMainTitle = 4;
const F_SmallTitle = 5;
const F_VerySmallTitle = 6;
const F_TabMainTitle = 7;
const F_PopUpTitle = 8;
const F_IntelTitle = 9;
const F_ListItemSmall = 10;
const F_ListItemBig = 11;
const F_HelpWindow = 12;
const F_FirstMenuButton = 14;
const F_MainButton = 15;
const F_PrincipalButton = 16;
const F_CheckBoxButton = 17;

enum TextAlign
{
	TA_Left,                        // 0
	TA_Right,                       // 1
	TA_Center                       // 2
};

enum FrameHitTest
{
	HT_NW,                          // 0
	HT_N,                           // 1
	HT_NE,                          // 2
	HT_W,                           // 3
	HT_E,                           // 4
	HT_SW,                          // 5
	HT_S,                           // 6
	HT_SE,                          // 7
	HT_TitleBar,                    // 8
	HT_DragHandle,                  // 9
	HT_None                         // 10
};

enum MenuSound
{
	MS_MenuPullDown,                // 0
	MS_MenuCloseUp,                 // 1
	MS_MenuItem,                    // 2
	MS_WindowOpen,                  // 3
	MS_WindowClose,                 // 4
	MS_ChangeTab                    // 5
};

enum MessageBoxButtons
{
	MB_YesNo,                       // 0
	MB_OKCancel,                    // 1
	MB_OK,                          // 2
	MB_YesNoCancel,                 // 3
	MB_Cancel,                      // 4
	MB_None                         // 5
};

enum MessageBoxResult
{
	MR_None,                        // 0
	MR_Yes,                         // 1
	MR_No,                          // 2
	MR_OK,                          // 3
	MR_Cancel                       // 4
};

enum PropertyCondition
{
	PC_None,                        // 0
	PC_LessThan,                    // 1
	PC_Equal,                       // 2
	PC_GreaterThan,                 // 3
	PC_NotEqual,                    // 4
	PC_Contains,                    // 5
	PC_NotContains                  // 6
};

enum EButtonName
{
	EBN_None,                       // 0
	EBN_RoundPerMatch,              // 1
	EBN_RoundTime,                  // 2
	EBN_NB_Players,                 // 3
	EBN_BombTimer,                  // 4
	EBN_Spectator,                  // 5
	EBN_RoundPerMission,            // 6
	EBN_TimeBetRound,               // 7
	EBN_NB_of_Terro,                // 8
	EBN_InternetServer,             // 9
	EBN_DedicatedServer,            // 10
	EBN_FriendlyFire,               // 11
	EBN_AllowTeamNames,             // 12
	EBN_AutoBalTeam,                // 13
	EBN_TKPenalty,                  // 14
	EBN_AllowRadar,                 // 15
	EBN_RotateMap,                  // 16
	EBN_AIBkp,                      // 17
	EBN_ForceFPersonWp,             // 18
	EBN_Recruit,                    // 19
	EBN_Veteran,                    // 20
	EBN_Elite,                      // 21
	EBN_PunkBuster,                 // 22
	EBN_DiffLevel,                  // 23
	EBN_CamFirstPerson,             // 24
	EBN_CamThirdPerson,             // 25
	EBN_CamFreeThirdP,              // 26
	EBN_CamGhost,                   // 27
	EBN_CamFadeToBk,                // 28
	EBN_CamTeamOnly,                // 29
	EBN_LogIn,                      // 30
	EBN_LogOut,                     // 31
	EBN_Join,                       // 32
	EBN_JoinIP,                     // 33
	EBN_Refresh,                    // 34
	EBN_Create,                     // 35
	EBN_Cancel,                     // 36
	EBN_Launch,                     // 37
	EBN_EditMsg,                    // 38
	EBN_CancelUbiCom,               // 39
	EBN_EditSkinSel,                // 40
	EBN_Max                         // 41
};

enum EPopUpID
{
	EPopUpID_None,                  // 0
	EPopUpID_MsgOfTheDay,           // 1
	EPopUpID_FileWriteError,        // 2
	EPopUpID_FileWriteErrorBackupPln,// 3
	EPopUpID_SaveFileExist,         // 4
	EPopUpID_PlanDeleteError,       // 5
	EPopUpID_InvalidLoad,           // 6
	EPopUpID_MPServerOpt,           // 7
	EPopUpID_MPKitRest,             // 8
	EPopUpID_MPGearRoom,            // 9
	EPopUpID_EnterIP,               // 10
	EPopUpID_JoinIPError,           // 11
	EPopUpID_JoinIPWait,            // 12
	EPopUpID_UbiAccount,            // 13
	EPopUpID_LoginError,            // 14
	EPopUpID_UbiComDisconnected,    // 15
	EPopUpID_CDKeyPleaseWait,       // 16
	EPopUpID_EnterCDKey,            // 17
	EPopUpID_Password,              // 18
	EPopUpID_JoinRoomError,         // 19
	EPopUpID_JoinRoomErrorCDKeyInUse,// 20
	EPopUpID_JoinRoomErrorCDKeySrvNotResp,// 21
	EPopUpID_JoinRoomErrorPassWd,   // 22
	EPopUpID_JoinRoomErrorSrvFull,  // 23
	EPopUpID_ErrorConnect,          // 24
	EPopUpID_PunkBusterOnlyError,   // 25
	EPopUpID_PunkBusterDisabledServerWarn,// 26
	EPopUpID_InvalidPassword,       // 27
	EPopUpID_QueryServerWait,       // 28
	EPopUpID_QueryServerError,      // 29
	EPopUpID_TKPenalty,             // 30
	EPopUpID_LeaveInGameToMultiMenu,// 31
	EPopUpID_RefreshServerList,     // 32
	EPopUpID_DownLoadingInProgress, // 33
	EPopUpID_AdvFilters,            // 34
	EPopUpID_CoopFilters,           // 35
	EPopUpID_InvalidMod,            // 36
	EPopUp_ID_GSCoOpMaxError,       // 37
	EPopUpID_UniformSel,            // 38
	EPopUpID_QuickPlay,             // 39
	EPopUpID_LoadDelPlan,           // 40
	EPopUpID_SaveDelPlan,           // 41
	EPopUpID_DeleteCampaign,        // 42
	EPopUpID_OverWriteCampaign,     // 43
	EPopUpID_DelAllWayPoints,       // 44
	EPopUpID_DelAllTeamsWayPoints,  // 45
	EPopUpID_LeavePlanningToMain,   // 46
	EPopUpID_SavePlanning,          // 47
	EPopUpID_LoadPlanning,          // 48
	EPopUpID_PlanningIncomplete,    // 49
	EPopUpID_LeaveInGameToMain,     // 50
	EPopUpID_LeaveInGameToQuit,     // 51
	EPopUpID_AbortMissionRetryAction,// 52
	EPopUpID_AbortMissionRetryPlan, // 53
	EPopUpID_QuitTraining,          // 54
	EPopUpID_OptionsResetDefault,   // 55
	EPopUpID_TextOnly,              // 56
	EPopUpID_Max                    // 57
};

enum ERestKitID
{
	ERestKit_SubMachineGuns,        // 0
	ERestKit_Shotguns,              // 1
	ERestKit_AssaultRifle,          // 2
	ERestKit_MachineGuns,           // 3
	ERestKit_SniperRifle,           // 4
	ERestKit_Pistol,                // 5
	ERestKit_MachinePistol,         // 6
	ERestKit_PriWpnGadget,          // 7
	ERestKit_SecWpnGadget,          // 8
	ERestKit_MiscGadget,            // 9
	ERestKit_Max                    // 10
};

enum ERenderStyle
{
	STY_None,                       // 0
	STY_Normal,                     // 1
	STY_Masked,                     // 2
	STY_Translucent,                // 3
	STY_Modulated,                  // 4
	STY_Alpha,                      // 5
	STY_Particle,                   // 6
	STY_Highlight                   // 7
};

struct TexRegion
{
	var() int X;
	var() int Y;
	var() int W;
	var() int H;
	var() Texture t;
};

struct RegionButton
{
	var Region Up;
	var Region Down;
	var Region Over;
	var Region Disabled;
};

struct HTMLStyle
{
	var int BulletLevel;  // 0 = no bullet depth
	var string LinkDestination;
	var Color TextColor;
	var Color BGColor;
	var bool bCenter;
	var bool bLink;
	var bool bUnderline;
	var bool bNoBR;
	var bool bHeading;
	var bool bBold;
	var bool bBlink;
};

// NEW IN 1.60
var(Display) UWindowBase.ERenderStyle Style;

function Region NewRegion(float X, float Y, float W, float H)
{
	local Region R;

	R.X = int(X);
	R.Y = int(Y);
	R.W = int(W);
	R.H = int(H);
	return R;
	return;
}

function TexRegion NewTexRegion(float X, float Y, float W, float H, Texture t)
{
	local TexRegion R;

	R.X = int(X);
	R.Y = int(Y);
	R.W = int(W);
	R.H = int(H);
	R.t = t;
	return R;
	return;
}

function Region GetRegion(TexRegion t)
{
	local Region R;

	R.X = t.X;
	R.Y = t.Y;
	R.W = t.W;
	R.H = t.H;
	return R;
	return;
}

static function int InStrAfter(string Text, string Match, int pos)
{
	local int i;

	i = __NFUN_126__(__NFUN_127__(Text, pos), Match);
	// End:0x35
	if(__NFUN_155__(i, -1))
	{
		return __NFUN_146__(i, pos);
	}
	return -1;
	return;
}

static function Object BuildObjectWithProperties(string Text)
{
	local int i;
	local string ObjectClass, PropertyName, PropertyValue, temp;
	local Class C;
	local Object o;

	i = __NFUN_126__(Text, ",");
	// End:0x35
	if(__NFUN_154__(i, -1))
	{
		ObjectClass = Text;
		Text = "";		
	}
	else
	{
		ObjectClass = __NFUN_128__(Text, i);
		Text = __NFUN_127__(Text, __NFUN_146__(i, 1));
	}
	C = Class<Object>(DynamicLoadObject(ObjectClass, Class'Core.Class'));
	o = new C;
	J0x86:

	// End:0x296 [Loop If]
	if(__NFUN_123__(Text, ""))
	{
		i = __NFUN_126__(Text, "=");
		// End:0xF9
		if(__NFUN_154__(i, -1))
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Missing value for property ", ObjectClass), "."), Text));
			PropertyName = Text;
			PropertyValue = "";			
		}
		else
		{
			PropertyName = __NFUN_128__(Text, i);
			Text = __NFUN_127__(Text, __NFUN_146__(i, 1));
		}
		// End:0x21E
		if(__NFUN_122__(__NFUN_128__(Text, 1), "\""))
		{
			i = InStrAfter(Text, "\"", 1);
			// End:0x183
			if(__NFUN_154__(i, -1))
			{
				__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Missing quote for ", ObjectClass), "."), PropertyName));
				return o;
			}
			PropertyValue = __NFUN_127__(Text, 1, __NFUN_147__(i, 1));
			temp = __NFUN_127__(Text, __NFUN_146__(i, 1), 1);
			// End:0x205
			if(__NFUN_130__(__NFUN_123__(temp, ""), __NFUN_123__(temp, ",")))
			{
				__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Missing comma after close quote for ", ObjectClass), "."), PropertyName));
			}
			Text = __NFUN_127__(Text, __NFUN_146__(i, 2));			
		}
		else
		{
			i = __NFUN_126__(Text, ",");
			// End:0x253
			if(__NFUN_154__(i, -1))
			{
				PropertyValue = Text;
				Text = "";				
			}
			else
			{
				PropertyValue = __NFUN_128__(Text, i);
				Text = __NFUN_127__(Text, __NFUN_146__(i, 1));
			}
		}
		o.SetPropertyText(PropertyName, PropertyValue);
		// [Loop Continue]
		goto J0x86;
	}
	return o;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var ERenderStyle
// REMOVED IN 1.60: function GetEPopUpID
