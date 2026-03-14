// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowPageControl extends UWindowTabControl;

// --- Functions ---
function UWindowPageControlPage GetPage(string Caption) {}
// ^ NEW IN 1.60
function Paint(Canvas C, float X, float Y) {}
function ResolutionChanged(float W, float H) {}
function UWindowPageControlPage AddPage(string Caption, class<UWindowPageWindow> PageClass, optional name ObjectName) {}
// ^ NEW IN 1.60
function UWindowPageControlPage InsertPage(UWindowPageControlPage BeforePage, string Caption, class<UWindowPageWindow> PageClass, optional name ObjectName) {}
// ^ NEW IN 1.60
function GotoTab(UWindowTabControlItem NewSelected, optional bool bByUser) {}
function Close(optional bool bByParent) {}
function GetDesiredDimensions(out float W, out float H) {}
function NotifyAfterLevelChange() {}
function NotifyBeforeLevelChange() {}
function NotifyQuitUnreal() {}
function BeforePaint(Canvas C, float X, float Y) {}
function DeletePage(UWindowPageControlPage P) {}
function UWindowPageControlPage FirstPage() {}
// ^ NEW IN 1.60

defaultproperties
{
}
