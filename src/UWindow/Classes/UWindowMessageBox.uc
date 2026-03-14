// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowMessageBox extends UWindowFramedWindow;

// --- Variables ---
var MessageBoxResult Result;
var float TimeOutTime;
var int TimeOut;
var int FrameCount;
var bool bSetupSize;

// --- Functions ---
function Close(optional bool bByParent) {}
function SetupMessageBox(string Title, string Message, MessageBoxButtons Buttons, MessageBoxResult InESCResult, optional MessageBoxResult InEnterResult, optional int InTimeOut) {}
function BeforePaint(Canvas C, float X, float Y) {}
function AfterPaint(float Y, float X, Canvas C) {}

defaultproperties
{
}
