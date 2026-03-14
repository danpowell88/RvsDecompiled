// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowTabControl extends UWindowListControl;

// --- Variables ---
var UWindowTabControlItem SelectedTab;
var UWindowTabControlTabArea TabArea;
var bool bMultiLine;
var UWindowTabControlLeftButton LeftButton;
var UWindowTabControlRightButton RightButton;
// tab button or not
var bool m_bTabButton;
var bool bSelectNearestTabOnRemove;

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}
function BeforePaint(Canvas C, float X, float Y) {}
function GotoTab(UWindowTabControlItem NewSelected, optional bool bByUser) {}
function SetMultiLine(bool InMultiLine) {}
function DeleteTab(UWindowTabControlItem Tab) {}
function UWindowTabControlItem GetTab(string Caption) {}
// ^ NEW IN 1.60
function UWindowTabControlItem AddTab(string Caption, optional int _iItemID) {}
// ^ NEW IN 1.60
function UWindowTabControlItem InsertTab(UWindowTabControlItem BeforeTab, string Caption, optional int _iItemID) {}
// ^ NEW IN 1.60
function Created() {}

defaultproperties
{
}
