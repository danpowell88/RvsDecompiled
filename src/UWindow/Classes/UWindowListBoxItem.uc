// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowListBoxItem extends UWindowList;

// --- Structs ---
struct stItemProperties
{
	var string			szText;
	var Font			TextFont;
	var FLOAT			fXPos;
	var FLOAT			fYPos;
	var FLOAT			fWidth;
	var FLOAT			fHeigth;
	var INT				iLineNumber;
	var TextAlign	    eAlignment;
};

struct stSubTextBox
{
    var string          szGameTypeSelect;
	var FLOAT			fXOffset;
    var FLOAT           fHeight;				// the height of the section
    var Font            FontSubText;
};

struct stCoordItem
{
	var FLOAT			fXPos;
	var FLOAT			fWidth;
};

// --- Variables ---
// var ? FontSubText; // REMOVED IN 1.60
// var ? TextFont; // REMOVED IN 1.60
// var ? eAlignment; // REMOVED IN 1.60
// var ? fHeight; // REMOVED IN 1.60
// var ? fHeigth; // REMOVED IN 1.60
// var ? fWidth; // REMOVED IN 1.60
// var ? fXOffset; // REMOVED IN 1.60
// var ? fXPos; // REMOVED IN 1.60
// var ? fYPos; // REMOVED IN 1.60
// var ? iLineNumber; // REMOVED IN 1.60
// var ? szGameTypeSelect; // REMOVED IN 1.60
// var ? szText; // REMOVED IN 1.60
// the text of the item (what's diplaying)
var string HelpText;
// this item is selected or not
var bool bSelected;
// array of all properties of an item
var array<array> m_AItemProperties;
// if we need more than 1 sub text line, change this in a array
var stSubTextBox m_stSubText;
// the default item color
var Color m_vItemColor;
// the tooltipstring
var string m_szToolTip;
// specific to input
// the value of the fake edit box to display
var string m_szFakeEditBoxValue;
// the value of the action key in user.ini
var string m_szActionKey;
// X pos , this is to fake and edit box -- see options/controls
var float m_fXFakeEditBox;
// Width, this is to fake and edit box -- see options/controls
var float m_fWFakeEditBox;
// the font see uwindowbase for value
var int m_iFontIndex;
// the item ID
var int m_iItemID;
// use sub text -- and by the way sub text struct
var bool m_bUseSubText;
// to draw a line at this item
var bool m_bImALine;
// this item is not affected by notify
var bool m_bNotAffectByNotify;
// the item is disable but displaying
var bool m_bDisabled;

// --- Functions ---
function SetItemParameters(int _index, string _szText, Font _TextFont, float _fX, float _fY, float _fW, float _fH, int _iLineNumber, optional TextAlign _eAlignement) {}
function int Compare(UWindowList t, UWindowList B) {}
// ^ NEW IN 1.60
//=====================================================================================
// ClearItem: clear the appropriate item values except the link with the list
//=====================================================================================
function ClearItem() {}

defaultproperties
{
}
