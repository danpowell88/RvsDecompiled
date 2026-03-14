// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowMessageBoxCW extends UWindowDialogClientWindow;

// --- Variables ---
var UWindowSmallButton CancelButton;
var UWindowSmallButton NoButton;
// ^ NEW IN 1.60
var UWindowSmallButton YesButton;
// ^ NEW IN 1.60
var UWindowSmallButton OKButton;
// ^ NEW IN 1.60
var MessageBoxResult EnterResult;
var UWindowMessageBoxArea MessageArea;
var MessageBoxButtons Buttons;
var localized string CancelText;
var localized string OKText;
// ^ NEW IN 1.60
var localized string NoText;
// ^ NEW IN 1.60
var localized string YesText;
// ^ NEW IN 1.60

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}
function SetupMessageBoxClient(MessageBoxResult InEnterResult, MessageBoxButtons InButtons, string InMessage) {}
function float GetHeight(Canvas C) {}
// ^ NEW IN 1.60
function BeforePaint(float Y, float X, Canvas C) {}
function Notify(byte E, UWindowDialogControl C) {}
function KeyDown(int Key, float X, float Y) {}
function Created() {}
function Resized() {}

defaultproperties
{
}
