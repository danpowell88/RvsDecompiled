// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowBase extends Object;

// --- Constants ---
const F_CheckBoxButton =  17;
const F_PrincipalButton =  16;
const F_MainButton =  15;
const F_FirstMenuButton =  14;
const F_HelpWindow =  12;
const F_ListItemBig =  11;
const F_ListItemSmall =  10;
const F_IntelTitle =  9;
const F_PopUpTitle =  8;
const F_TabMainTitle =  7;
const F_VerySmallTitle =  6;
const F_SmallTitle =  5;
const F_MenuMainTitle =  4;
const F_ocraext17 =  0;
const F_LargeBold =  3;
const F_Large =  2;
const F_Bold =  1;
const F_Normal =  0;

// --- Enums ---
enum MessageBoxResult
{
	MR_None,
	MR_Yes,
	MR_No,
	MR_OK,
	MR_Cancel	// also if you press the Close box.
};
enum FrameHitTest
{
	HT_NW,
	HT_N,
	HT_NE,
	HT_W,
	HT_E,
	HT_SW,
	HT_S,
	HT_SE,
	HT_TitleBar,
	HT_DragHandle,
	HT_None
};
enum MessageBoxButtons
{
	MB_YesNo,
	MB_OKCancel,
	MB_OK,
	MB_YesNoCancel,
	MB_Cancel,
    MB_None
};
enum EPopUpID
{
	EPopUpID_None,
	EPopUpID_MsgOfTheDay,
    EPopUpID_FileWriteError,
    EPopUpID_FileWriteErrorBackupPln,
	EPopUpID_SaveFileExist,
    EPopUpID_PlanDeleteError,
    EPopUpID_InvalidLoad,

	// MULTI
	EPopUpID_MPServerOpt,
	EPopUpID_MPKitRest,
	EPopUpID_MPGearRoom,
    EPopUpID_EnterIP,
    EPopUpID_JoinIPError,
    EPopUpID_JoinIPWait,
    EPopUpID_UbiAccount,
    EPopUpID_LoginError,
    EPopUpID_UbiComDisconnected,
    EPopUpID_CDKeyPleaseWait,
    EPopUpID_EnterCDKey,
    EPopUpID_Password,
    EPopUpID_JoinRoomError,
    EPopUpID_JoinRoomErrorCDKeyInUse,
    EPopUpID_JoinRoomErrorCDKeySrvNotResp,
    EPopUpID_JoinRoomErrorPassWd,
    EPopUpID_JoinRoomErrorSrvFull,
    EPopUpID_ErrorConnect,
    EPopUpID_PunkBusterOnlyError,
    EPopUpID_PunkBusterDisabledServerWarn,
	EPopUpID_InvalidPassword,
    EPopUpID_QueryServerWait,
    EPopUpID_QueryServerError,
	EPopUpID_TKPenalty,
	EPopUpID_LeaveInGameToMultiMenu,
    EPopUpID_RefreshServerList,
	EPopUpID_DownLoadingInProgress,
	EPopUpID_AdvFilters,
	EPopUpID_CoopFilters,
//Single
    EPopUpID_QuickPlay,
    EPopUpID_LoadDelPlan,
    EPopUpID_SaveDelPlan,
    EPopUpID_DeleteCampaign,
    EPopUpID_OverWriteCampaign,
    EPopUpID_DelAllWayPoints,
    EPopUpID_DelAllTeamsWayPoints,
    EPopUpID_LeavePlanningToMain,
    EPopUpID_SavePlanning,
    EPopUpID_LoadPlanning,
    EPopUpID_PlanningIncomplete,
    EPopUpID_LeaveInGameToMain,
    EPopUpID_LeaveInGameToQuit,
    EPopUpID_AbortMissionRetryAction,
	EPopUpID_AbortMissionRetryPlan,
    EPopUpID_QuitTraining,
    EPopUpID_OptionsResetDefault,
    EPopUpID_TextOnly,              //Allow you to do a message box without buttons

	EPopUpID_Max		// always the last one
};
enum TextAlign
{
	TA_Left,
	TA_Right,
	TA_Center
};
enum MenuSound
{
	MS_MenuPullDown,
	MS_MenuCloseUp,
	MS_MenuItem,
	MS_WindowOpen,
	MS_WindowClose,
	MS_ChangeTab
};
enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_Alpha,
	STY_Particle,
    STY_Highlight
} Style;


// This variable is used to enable/disble functrionality
// that will be used only for the multi-player demo version

//-----------------------------------------------------------------------------

struct HTMLStyle
{
	var int BulletLevel;			// 0 = no bullet depth
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
enum ERestKitID
{
	ERestKit_SubMachineGuns,
	ERestKit_Shotguns,
	ERestKit_AssaultRifle,
	ERestKit_MachineGuns,
	ERestKit_SniperRifle,
	ERestKit_Pistol,
	ERestKit_MachinePistol,
	ERestKit_PriWpnGadget,
	ERestKit_SecWpnGadget,
	ERestKit_MiscGadget,

	ERestKit_Max		// always the last one
};
enum EButtonName
{
	EBN_None,
	// Counter Button
	EBN_RoundPerMatch,
	EBN_RoundTime,
	EBN_NB_Players,
	EBN_BombTimer,
	EBN_Spectator,
	EBN_RoundPerMission,
	EBN_TimeBetRound,
	EBN_NB_of_Terro,
	// Button Box
	EBN_InternetServer,
	EBN_DedicatedServer,
	EBN_FriendlyFire,
	EBN_AllowTeamNames,
	EBN_AutoBalTeam,
	EBN_TKPenalty,
	EBN_AllowRadar,
	EBN_RotateMap,
	EBN_AIBkp,
	EBN_ForceFPersonWp,
	EBN_Recruit,
	EBN_Veteran,
	EBN_Elite,
//#ifdefR6PUNKBUSTER
	EBN_PunkBuster,
//#endif
	// Combo Box
	EBN_DiffLevel,
	// camera
	EBN_CamFirstPerson,
	EBN_CamThirdPerson,
	EBN_CamFreeThirdP,
	EBN_CamGhost,
	EBN_CamFadeToBk,
	EBN_CamTeamOnly,
	// main multi page
	EBN_LogIn,
	EBN_LogOut,
    EBN_Join,
    EBN_JoinIP,
    EBN_Refresh,
    EBN_Create,
    EBN_Cancel,
    EBN_Launch,	
	// other
	EBN_EditMsg,
    EBN_CancelUbiCom,

	EBN_Max				// always the last one
};
enum PropertyCondition
{
	PC_None,
	PC_LessThan,
	PC_Equal,
	PC_GreaterThan,
	PC_NotEqual,
	PC_Contains,
	PC_NotContains
};

// --- Structs ---
struct TexRegion
{
	var() int X;
	var() int Y;
	var() int W;
	var() int H;
	var() Texture T;
};

struct HTMLStyle
{
	var int BulletLevel;			// 0 = no bullet depth
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

struct RegionButton
{
    var Region Up;
    var Region Down;
    var Region Over;
    var Region Disabled;
};

// --- Variables ---
// var ? BGColor; // REMOVED IN 1.60
// var ? BulletLevel; // REMOVED IN 1.60
// var ? Disabled; // REMOVED IN 1.60
// var ? Down; // REMOVED IN 1.60
// var ? LinkDestination; // REMOVED IN 1.60
// var ? Over; // REMOVED IN 1.60
// var ? TextColor; // REMOVED IN 1.60
// var ? Up; // REMOVED IN 1.60
// var ? bBlink; // REMOVED IN 1.60
// var ? bBold; // REMOVED IN 1.60
// var ? bCenter; // REMOVED IN 1.60
// var ? bHeading; // REMOVED IN 1.60
// var ? bLink; // REMOVED IN 1.60
// var ? bNoBR; // REMOVED IN 1.60
// var ? bUnderline; // REMOVED IN 1.60
var ERenderStyle Style;
// ^ NEW IN 1.60

// --- Functions ---
static function Object BuildObjectWithProperties(string Text) {}
function TexRegion NewTexRegion(float X, float Y, float W, float H, Texture t) {}
static function int InStrAfter(int pos, string Text, string Match) {}
function Region GetRegion(TexRegion t) {}
function Region NewRegion(float X, float Y, float W, float H) {}

defaultproperties
{
}
