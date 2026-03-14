//=============================================================================
// Player - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Player: Corresponds to a real player (a local camera or remote net player).
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Player extends Object
    native
    config
    noexport;

const IDC_ARROW = 0;
const IDC_SIZEALL = 1;
const IDC_SIZENESW = 2;
const IDC_SIZENS = 3;
const IDC_SIZENWSE = 4;
const IDC_SIZEWE = 5;
const IDC_WAIT = 6;

// Internal.
var native const int vfOut;
var native const int vfExec;
// The actor this player controls.
var const transient PlayerController Actor;
var transient Interaction Console;
// Window input variables
var const transient bool bWindowsMouseAvailable;
var bool bShowWindowsMouse;
var bool bSuspendPrecaching;
var const transient float WindowsMouseX;
var const transient float WindowsMouseY;
var int CurrentNetSpeed;
var globalconfig int ConfiguredInternetSpeed;
// NEW IN 1.60
var globalconfig int ConfiguredLanSpeed;
var byte SelectedCursor;
var transient InteractionMaster InteractionMaster;  // Callback to the IM
var transient array<Interaction> LocalInteractions;  // Holds a listing of all local Interactions
//R6ARMPATCHES
var Guid m_ArmPatchGUID;
//R6CODE
var byte u8WaitLaunchStatingSound;

defaultproperties
{
    ConfiguredInternetSpeed=20000
    ConfiguredLanSpeed=20000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var d
