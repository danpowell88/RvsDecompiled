//=============================================================================
// UWindowListBoxItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowListBoxItem extends UWindowList;

struct stSubTextBox
{
	var string szGameTypeSelect;
	var float fXOffset;
	var float fHeight;  // the height of the section
	var Font FontSubText;
};

struct stCoordItem
{
	var float fXPos;
	var float fWidth;
};

struct stItemProperties
{
	var string szText;
	var Font TextFont;
	var float fXPos;
	var float fYPos;
	var float fWidth;
	var float fHeigth;
	var int iLineNumber;
	var UWindowBase.TextAlign eAlignment;
};

var int m_iFontIndex;  // the font see uwindowbase for value
var int m_iItemID;  // the item ID
var bool bSelected;  // this item is selected or not
var bool m_bUseSubText;  // use sub text -- and by the way sub text struct
var bool m_bImALine;  // to draw a line at this item
var bool m_bNotAffectByNotify;  // this item is not affected by notify
var bool m_bDisabled;  // the item is disable but displaying
var float m_fXFakeEditBox;  // X pos , this is to fake and edit box -- see options/controls
var float m_fWFakeEditBox;  // Width, this is to fake and edit box -- see options/controls
var array<stItemProperties> m_AItemProperties;  // array of all properties of an item
var stSubTextBox m_stSubText;  // if we need more than 1 sub text line, change this in a array
var Color m_vItemColor;  // the default item color
var string HelpText;  // the text of the item (what's diplaying)
var string m_szToolTip;  // the tooltipstring
// specific to input
var string m_szFakeEditBoxValue;  // the value of the fake edit box to display
var string m_szActionKey;  // the value of the action key in user.ini

function int Compare(UWindowList t, UWindowList B)
{
	local string TS, BS;

	TS = UWindowListBoxItem(t).HelpText;
	BS = UWindowListBoxItem(B).HelpText;
	// End:0x4B
	if(__NFUN_122__(TS, "NONE"))
	{
		return -1;		
	}
	else
	{
		// End:0x5D
		if(__NFUN_122__(BS, "NONE"))
		{
			return 1;
		}
	}
	// End:0x6E
	if(__NFUN_122__(TS, BS))
	{
		return 0;
	}
	// End:0x83
	if(__NFUN_115__(TS, BS))
	{
		return -1;
	}
	return 1;
	return;
}

//=====================================================================================
// ClearItem: clear the appropriate item values except the link with the list
//=====================================================================================
function ClearItem()
{
	bSelected = false;
	m_bShowThisItem = false;
	return;
}

function SetItemParameters(int _index, string _szText, Font _TextFont, float _fX, float _fY, float _fW, float _fH, int _iLineNumber, optional UWindowBase.TextAlign _eAlignement)
{
	local stItemProperties stItemParam;

	// End:0xA1
	if(__NFUN_152__(_index, m_AItemProperties.Length))
	{
		stItemParam.szText = _szText;
		stItemParam.TextFont = _TextFont;
		stItemParam.fXPos = _fX;
		stItemParam.fYPos = _fY;
		stItemParam.fWidth = _fW;
		stItemParam.fHeigth = _fH;
		stItemParam.iLineNumber = _iLineNumber;
		stItemParam.eAlignment = _eAlignement;
		m_AItemProperties[_index] = stItemParam;
	}
	return;
}

