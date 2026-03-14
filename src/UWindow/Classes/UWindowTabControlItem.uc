//=============================================================================
// UWindowTabControlItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowTabControlItem extends UWindowList;

var int RowNumber;
var int m_iItemID;
var bool bFlash;
var bool m_bMouseOverItem;
var float TabTop;
var float TabLeft;
var float TabWidth;
var float TabHeight;
var float m_fFixWidth;  // a fix size for the tab, by default 0 (the tab size equal the the text size in this case)
var UWindowTabControl Owner;
// border and text have the same color (selected or not)
var Color m_vSelectedColor;
var Color m_vNormalColor;
var string Caption;
var string HelpText;

function SetCaption(string NewCaption)
{
	Caption = NewCaption;
	return;
}

function RightClickTab()
{
	return;
}

function SetFixTabSize(float _fFixTabWidth)
{
	m_fFixWidth = _fFixTabWidth;
	return;
}

function SetItemColor(Color _vSelected, Color _vNormal)
{
	m_vSelectedColor = _vSelected;
	m_vNormalColor = _vNormal;
	return;
}

