// ====================================================================
//  Class:  Engine.Interaction
//  
//  Each individual Interaction is a jumping point in UScript.  The should
//  be the foundatation for any subsystem that requires interaction with
//  the player (such as a menu).  
//
//  Interactions take on two forms, the Global Interaction and the Local
//  Interaction.  The GI get's to process data before the LI and get's
//  render time after the LI, so in essence the GI wraps the LI.
//
//  A dynamic array of GI's are stored in the InteractionMaster while
//  each Viewport contains an array of LIs.
//
//
// (c) 2001, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class Interaction extends Interactions
    native;

// --- Variables ---
// Pointer to the ViewPort that "Owns" this interaction or none if it's Global
var Player ViewportOwner;
// Is this interaction being Displayed
var bool bVisible;
// Is this interaction Getting Input
var bool bActive;
// Pointer to the Interaction Master
var InteractionMaster Master;
// Does this interaction require game TICK
var bool bRequiresTick;

// --- Functions ---
function bool KeyType(out EInputKey Key) {}
// ^ NEW IN 1.60
function bool KeyEvent(out EInputKey Key, out EInputAction Action, float Delta) {}
// ^ NEW IN 1.60
function PostRender(Canvas Canvas) {}
function Message(coerce string Msg, float MsgLife) {}
native function bool ConsoleCommand(coerce string S) {}
// ^ NEW IN 1.60
// ====================================================================
// WorldToScreen - Returns the X/Y screen coordinates in to a viewport of a given vector
// in the world.
// ====================================================================
native function Vector WorldToScreen(optional Rotator CameraRotation, optional Vector CameraLocation, Vector Location) {}
// ^ NEW IN 1.60
// ====================================================================
// ScreenToWorld - Converts an X/Y screen coordinate in to a world vector
// ====================================================================
native function Vector ScreenToWorld(optional Rotator CameraRotation, optional Vector CameraLocation, Vector Location) {}
// ^ NEW IN 1.60
//#ifdef R6CODE
// ====================================================================
// ConvertKeyToLocalisation: This is convert a key to the name of the key localization
// Ex: english to french : A is A -- Space is Espace -- Backspace is reculer etc...
//	   the localization is in R6Menu.int
// ====================================================================
event string ConvertKeyToLocalisation(byte _Key, string _szEnumKeyName) {}
// ^ NEW IN 1.60
native function Initialize() {}
event Initialized() {}
event ServerDisconnected() {}
//#ifdef R6CODE
event UserDisconnected() {}
//#endif // #ifdef R6CODE
event ConnectionFailed() {}
//#ifdef R6CODE
event R6ConnectionFailed(string szError) {}
event R6ConnectionSuccess() {}
event R6ConnectionInterrupted() {}
event R6ConnectionInProgress() {}
event R6ProgressMsg(string _Str1, string _Str2, float Seconds) {}
function Object SetGameServiceLinks(PlayerController _localPlayer) {}
// ^ NEW IN 1.60
event NotifyLevelChange() {}
event NotifyAfterLevelChange() {}
event MenuLoadProfile(bool _bServerProfile) {}
event LaunchR6MainMenu() {}
event string GetStoreGamePwd() {}
// ^ NEW IN 1.60
function SendGoCode(EGoCode eGo) {}
function PreRender(Canvas Canvas) {}
function SetFocus() {}
function Tick(float DeltaTime) {}

defaultproperties
{
}
