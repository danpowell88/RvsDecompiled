//=============================================================================
// UWindowRootWindow - the root window.
//=============================================================================
class UWindowRootWindow extends UWindowWindow;

#exec TEXTURE IMPORT NAME=MouseMove FILE=Textures\MouseMove.bmp GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseDiag1 FILE=Textures\MouseDiag1.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseDiag2 FILE=Textures\MouseDiag2.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseNS FILE=Textures\MouseNS.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseWE FILE=Textures\MouseWE.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseHand FILE=Textures\MouseHand.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseHSplit FILE=Textures\MouseHSplit.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=MouseVSplit FILE=Textures\MouseVSplit.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF
#exec OBJ LOAD FILE=..\Textures\R6MenuTextures.utx PACKAGE=R6MenuTextures
#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning
#exec OBJ LOAD FILE=..\Textures\R6Font.utx PACKAGE=R6Font

// --- Enums ---
enum eGameWidgetID
{
    WidgetID_None,    
    InGameID_EscMenu,
    InGameID_Debriefing,
	InGameID_TrainingInstruction,
    TrainingWidgetID,
    SinglePlayerWidgetID,
    CampaignPlanningID,
	MainMenuWidgetID,       
	IntelWidgetID,    
	PlanningWidgetID,
    RetryCampaignPlanningID,
    RetryCustomMissionPlanningID,
	GearRoomWidgetID,
    ExecuteWidgetID,
	CustomMissionWidgetID,
	MultiPlayerWidgetID,
	OptionsWidgetID,
    PreviousWidgetID,	
	CreditsWidgetID,
    MPCreateGameWidgetID,    
    UbiComWidgetID,
    NonUbiWidgetID,
	InGameMPWID_Writable,
    InGameMPWID_TeamJoin,
    InGameMPWID_Intermission,
    InGameMPWID_InterEndRound,
    InGameMPWID_EscMenu,
    InGameMpWID_RecMessages,
    InGameMpWID_MsgOffensive,
    InGameMpWID_MsgDefensive,
    InGameMpWID_MsgReply,
    InGameMpWID_MsgStatus,
	InGameMPWID_Vote,
    InGameMPWID_CountDown,
    InGameID_OperativeSelector,
    MultiPlayerError,
    MultiPlayerErrorUbiCom,
    MenuQuitID    
};
enum eRootID
{
    RootID_UWindow,
    RootID_R6Menu,
    RootID_R6MenuInGame,
    RootID_R6MenuInGameMulti
} m_eRootId;

//Mainly to provide the R6Console the ability to change the current Widget
enum eGameWidgetID
{
    WidgetID_None,    
    InGameID_EscMenu,
    InGameID_Debriefing,
	InGameID_TrainingInstruction,
    TrainingWidgetID,
    SinglePlayerWidgetID,
    CampaignPlanningID,
	MainMenuWidgetID,       
	IntelWidgetID,    
	PlanningWidgetID,
    RetryCampaignPlanningID,
    RetryCustomMissionPlanningID,
	GearRoomWidgetID,
    ExecuteWidgetID,
	CustomMissionWidgetID,
	MultiPlayerWidgetID,
	OptionsWidgetID,
    PreviousWidgetID,	
	CreditsWidgetID,
    MPCreateGameWidgetID,    
    UbiComWidgetID,
    NonUbiWidgetID,
	InGameMPWID_Writable,
    InGameMPWID_TeamJoin,
    InGameMPWID_Intermission,
    InGameMPWID_InterEndRound,
    InGameMPWID_EscMenu,
    InGameMpWID_RecMessages,
    InGameMpWID_MsgOffensive,
    InGameMpWID_MsgDefensive,
    InGameMpWID_MsgReply,
    InGameMpWID_MsgStatus,
	InGameMPWID_Vote,
    InGameMPWID_CountDown,
    InGameID_OperativeSelector,
    MultiPlayerError,
    MultiPlayerErrorUbiCom,
    MenuQuitID    
};

// --- Variables ---
var WindowConsole Console;
var Font Fonts[30];
//var config float		GUIScale;
//Alex- This is to prevent set res call to ovewrite this value in config file
var float GUIScale;
// The window the mouse is over
var UWindowWindow MouseWindow;
var UWindowHotkeyWindowList HotkeyWindows;
var MouseCursor WECursor;
// ^ NEW IN 1.60
var R6GameColors Colors;
var MouseCursor NSCursor;
// ^ NEW IN 1.60
var MouseCursor DiagCursor2;
// ^ NEW IN 1.60
var MouseCursor DiagCursor1;
// ^ NEW IN 1.60
var bool bMouseCapture;
var MouseCursor NormalCursor;
// ^ NEW IN 1.60
var UWindowLookAndFeel LooksAndFeels[20];
var float MouseX;
// ^ NEW IN 1.60
var float MouseY;
// window with keyboard focus
var UWindowWindow KeyFocusWindow;
var UWindowWindow FocusedWindow;
var MouseCursor MoveCursor;
// ^ NEW IN 1.60
var MouseCursor HandCursor;
// ^ NEW IN 1.60
var MouseCursor HSplitCursor;
// ^ NEW IN 1.60
var MouseCursor VSplitCursor;
// ^ NEW IN 1.60
var float RealWidth;
// ^ NEW IN 1.60
var float RealHeight;
var UWindowWindow m_NotifyMsgWindow;
// ^ NEW IN 1.60
var float QuitTime;
var MouseCursor AimCursor;
var MouseCursor DragCursor;
var UWindowMenuClassDefines MenuClassDefines;
var bool bRequestQuit;
var config string LookAndFeelClass;
var float OldMouseY;
var float OldMouseX;
// ^ NEW IN 1.60
var eRootID m_eRootId;
// ^ NEW IN 1.60
var bool m_bScaleWindowToRoot;
var float m_fWindowScaleY;
// ^ NEW IN 1.60
var float m_fWindowScaleX;
// ^ NEW IN 1.60
var bool bAllowConsole;
var MouseCursor WaitCursor;
//R6Code
var bool m_bUseAimIcon;
var bool m_bUseDragIcon;
// Current widget ID display on screen
var eGameWidgetID m_eCurWidgetInUse;
// Previous widget ID display on screen
var eGameWidgetID m_ePrevWidgetInUse;
// this is set in root by a widget to tell to the options if resolution is fix or not
var bool m_bWidgetResolutionFix;

// --- Functions ---
// function ? SaveTrainingPlanning(...); // REMOVED IN 1.60
function AddHotkeyWindow(UWindowWindow W) {}
function SetResolution(float _NewHeight, float _NewWidth) {}
function ChangeLookAndFeel(string NewLookAndFeel) {}
function SetMousePos(float Y, float X) {}
function RegisterMsgWindow(UWindowWindow _NotifyMsgWindow) {}
// ^ NEW IN 1.60
function ProcessGSMsg(string _szMsg) {}
// ^ NEW IN 1.60
function Tick(float Delta) {}
function bool IsAHotKeyWindow(UWindowWindow W) {}
// ^ NEW IN 1.60
function CaptureMouse(optional UWindowWindow W) {}
function bool CheckCaptureMouseDown() {}
// ^ NEW IN 1.60
function bool CheckCaptureMouseUp() {}
// ^ NEW IN 1.60
//===================================================================
// DrawBackGroundEffect: draw a background fullscreen -- need for pop-up
//===================================================================
function DrawBackGroundEffect(Canvas C, Color _BGColor) {}
function UWindowLookAndFeel GetLookAndFeel(string LFClassName) {}
// ^ NEW IN 1.60
function bool HotKeyDown(float Y, float X, int Key) {}
// ^ NEW IN 1.60
function bool HotKeyUp(float Y, float X, int Key) {}
// ^ NEW IN 1.60
function bool MouseUpDown(float Y, float X, int Key) {}
// ^ NEW IN 1.60
function MoveMouse(float Y, float X) {}
function SetScale(float NewScale) {}
function RemoveHotkeyWindow(UWindowWindow W) {}
function DrawMouse(Canvas C) {}
function WindowEvent(float X, float Y, int Key, WinMessage Msg, Canvas C) {}
function ChangeCurrentWidget(eGameWidgetID widgetID) {}
function ResetMenus(optional bool _bConnectionFailed) {}
function UpdateMenus(int iWhatToUpdate) {}
function ChangeInstructionWidget(Actor pISV, bool bShow, int iBox, int iParagraph) {}
function StopPlayMode() {}
function bool PlanningShouldProcessKey() {}
// ^ NEW IN 1.60
function bool PlanningShouldDrawPath() {}
// ^ NEW IN 1.60
// SimplePopUp fct
function EPopUpID GetSimplePopUpID() {}
// ^ NEW IN 1.60
function SimplePopUp(string _szTitle, string _szText, EPopUpID _ePopUpID, optional int _iButtonsType, optional bool bAddDisableDlg, optional UWindowWindow OwnerWindow) {}
function ModifyPopUpInsideText(array<array> _ANewText) {}
function bool GetMapNameLocalisation(string _szMapName, out string _szMapNameLoc, optional bool _bReturnInitName) {}
// ^ NEW IN 1.60
function BeginPlay() {}
function Created() {}
function CancelCapture() {}
function Texture GetLookAndFeelTexture() {}
// ^ NEW IN 1.60
function bool IsActive() {}
// ^ NEW IN 1.60
function CloseActiveWindow() {}
function Resized() {}
function SetupFonts() {}
function HideWindow() {}
function QuitGame() {}
function DoQuitGame() {}
//ifdef R6CODE
// MPF Yannick
function SetNewMODS(string _szNewBkgFolder, optional bool _bForceRefresh) {}
function SetLoadRandomBackgroundImage(string _szFolder) {}
function PaintBackground(Canvas C, UWindowWindow _WidgetWindow) {}
//===================================================================
// TrapKey: Menu trap the key
//===================================================================
function bool TrapKey(bool _bIncludeMouseMove) {}
// ^ NEW IN 1.60
function UnRegisterMsgWindow() {}
// ^ NEW IN 1.60

defaultproperties
{
}
