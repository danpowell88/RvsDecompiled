//=============================================================================
// HUD: Superclass of the heads-up display.
//=============================================================================
class HUD extends Actor
    native
    config(user);

#exec Texture Import File=Textures\Border.pcx

// --- Constants ---
const c_iTextMessagesMax =  6;
const c_iTextKillMessagesMax =  4;
const c_iTextServerMessagesMax =  3;

// --- Structs ---
struct HUDLocalizedMessage
{
	var Class<LocalMessage> Message;
	var int Switch;
	var PlayerReplicationInfo RelatedPRI;
	var Object OptionalObject;
	var float EndOfLife;
	var float LifeTime;
	var bool bDrawing;
	var int numLines;
	var string StringMessage;
	var color DrawColor;
	var font StringFont;
	var float XL, YL;
	var float YPos;
};

// --- Variables ---
// var ? DrawColor; // REMOVED IN 1.60
// var ? EndOfLife; // REMOVED IN 1.60
// var ? LifeTime; // REMOVED IN 1.60
// var ? Message; // REMOVED IN 1.60
// var ? OptionalObject; // REMOVED IN 1.60
// var ? RelatedPRI; // REMOVED IN 1.60
// var ? StringFont; // REMOVED IN 1.60
// var ? StringMessage; // REMOVED IN 1.60
// var ? Switch; // REMOVED IN 1.60
// var ? YL; // REMOVED IN 1.60
// var ? YPos; // REMOVED IN 1.60
// var ? bDrawing; // REMOVED IN 1.60
// var ? numLines; // REMOVED IN 1.60
// always the actual owner
var PlayerController PlayerOwner;
//R6CODE: epic version
//var string TextMessages[4];
//var float MessageLife[4];
var string TextMessages[6];
//R6CODE
var string TextKillMessages[4];
var string TextServerMessages[3];
var float MessageServerLife[3];
//#ifndef R6CODE
//var ScoreBoard Scoreboard;
//#endif
var bool bShowScores;
// Stock fonts.
// Small system font.
var Font SmallFont;
var float MessageLife[6];
var float MessageKillLife[4];
var byte MessageUseBigFont[3];
// ^ NEW IN 1.60
// list of huds which render to the canvas
var HUD nextHUD;
// Largest system font.
var Font LargeFont;
// Big system font.
var Font BigFont;
// Medium system font.
var Font MedFont;
var Font m_FontRainbow6_22pt;
// Should the hud display itself.
var bool bHideHUD;
// if true, show properties of current ViewTarget
var bool bShowDebugInfo;
var Color m_ServerMessagesColor;
var Color m_KillMessagesColor;
//R6CONSOLE
var Color m_ChatMessagesColor;
var Font m_FontRainbow6_36pt;
var Font m_FontRainbow6_17pt;
//R6CODE
var Font m_FontRainbow6_14pt;
// display warning about bad connection
var bool bBadConnectionAlert;
// don't draw centered messages (screen center being used)
var bool bHideCenterMessages;
//#ifdef R6CODE
var R6GameColors Colors;
var string HUDConfigWindowType;
var localized string LoadingMessage;
var localized string SavingMessage;
var localized string ConnectingMessage;
var localized string PausedMessage;
var localized string PrecachingMessage;
var Material m_ConsoleBackground;

// --- Functions ---
// function ? ShowDebug(...); // REMOVED IN 1.60
// function ? ShowScores(...); // REMOVED IN 1.60
final native function Draw3DLine(Color LineColor, Vector End, Vector Start) {}
simulated function PlayReceivedMessage(string S, string PName, ZoneInfo PZone) {}
function bool ProcessKeyEvent(float Delta, int Action, int Key) {}
// ^ NEW IN 1.60
function UseHugeFont(Canvas Canvas) {}
function UseLargeFont(Canvas Canvas) {}
function UseMediumFont(Canvas Canvas) {}
function UseSmallFont(Canvas Canvas) {}
simulated function Message(coerce string Msg, name MsgType, PlayerReplicationInfo PRI) {}
event RenderFirstPersonGun(Canvas Canvas) {}
// ^ NEW IN 1.60
simulated event PostRender(Canvas Canvas) {}
function ClearMessage(out HUDLocalizedMessage M) {}
simulated function DisplayProgressMessage(Canvas Canvas) {}
function AddTextMessage(string M, class<LocalMessage> MessageClass) {}
//R6CODE
function AddDeathTextMessage(string M, class<LocalMessage> MessageClass) {}
function CopyMessage(out HUDLocalizedMessage M1, HUDLocalizedMessage M2) {}
//function AddTextServerMessage(string M, class<LocalMessage> MessageClass)
// R6CODE
function AddTextServerMessage(optional byte bMessageUseBigFont, string M, optional int iLifeTime, class<LocalMessage> MessageClass) {}
simulated function DrawRoute() {}
simulated event PostBeginPlay() {}
simulated event Destroyed() {}
event ShowUpgradeMenu() {}
function PlayStartupMessage(byte Stage) {}
simulated event WorldSpaceOverlays() {}
// R6CODE
simulated event PostFadeRender(Canvas Canvas) {}
function DrawHUD(Canvas Canvas) {}
function DisplayBadConnectionAlert() {}
simulated function LocalizedMessage(class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString) {}
function DisplayMessages(Canvas Canvas) {}

defaultproperties
{
}
