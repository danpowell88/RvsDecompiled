// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowDialogClientWindow extends UWindowClientWindow;

// --- Variables ---
var UWindowDialogControl TabLast;
var float DesiredHeight;
// Used for scrolling
var float DesiredWidth;

// --- Functions ---
// function ? Paint(...); // REMOVED IN 1.60
function Notify(UWindowDialogControl C, byte E) {}
function UWindowDialogControl CreateControl(optional bool _bNotTabRegister, optional UWindowWindow OwnerWindow, float H, float W, float Y, float X, class<UWindowDialogControl> ControlClass) {}
// ^ NEW IN 1.60
function GetDesiredDimensions(out float H, out float W) {}
function OKPressed() {}

defaultproperties
{
}
