//=============================================================================
// Player: Corresponds to a real player (a local camera or remote net player).
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Player extends Object
    native
    noexport;

// --- Constants ---
const IDC_WAIT; // value unavailable in binary
const IDC_SIZEWE; // value unavailable in binary
const IDC_SIZENWSE; // value unavailable in binary
const IDC_SIZENS; // value unavailable in binary
const IDC_SIZENESW; // value unavailable in binary
const IDC_SIZEALL; // value unavailable in binary
const IDC_ARROW; // value unavailable in binary

// --- Variables ---
// Holds a listing of all local Interactions
var transient array<array> LocalInteractions;
// The actor this player controls.
var transient const PlayerController Actor;
var transient Interaction Console;
var int CurrentNetSpeed;
// Callback to the IM
var transient InteractionMaster InteractionMaster;
//R6ARMPATCHES
var Guid m_ArmPatchGUID;
//R6CODE
var byte u8WaitLaunchStatingSound;
var byte SelectedCursor;
var config globalconfig int ConfiguredLanSpeed;
var config globalconfig int ConfiguredInternetSpeed;
// ^ NEW IN 1.60
var transient const float WindowsMouseY;
var transient const float WindowsMouseX;
var bool bSuspendPrecaching;
var bool bShowWindowsMouse;
// Window input variables
var transient const bool bWindowsMouseAvailable;
var native const int vfExec;
// Internal.
var native const int vfOut;

defaultproperties
{
}
