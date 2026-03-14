// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowTabControlItem extends UWindowList;

// --- Variables ---
var float TabWidth;
var float TabLeft;
var int RowNumber;
var float TabTop;
var float TabHeight;
var string Caption;
var bool m_bMouseOverItem;
// a fix size for the tab, by default 0 (the tab size equal the the text size in this case)
var float m_fFixWidth;
var string HelpText;
var UWindowTabControl Owner;
// border and text have the same color (selected or not)
var Color m_vSelectedColor;
var Color m_vNormalColor;
var int m_iItemID;
var bool bFlash;

// --- Functions ---
function RightClickTab() {}
function SetItemColor(Color _vSelected, Color _vNormal) {}
function SetFixTabSize(float _fFixTabWidth) {}
function SetCaption(string NewCaption) {}

defaultproperties
{
}
