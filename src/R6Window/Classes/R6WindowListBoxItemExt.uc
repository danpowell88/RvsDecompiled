//=============================================================================
// R6WindowListBoxItemExt - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6WindowListBoxItemExt extends UWindowListBoxItem;

struct stItemDesc
{
	var string szText;
	var string szMisc;
	var Font TextFont;
	var float fXPos;
	var float fYPos;
	var float fWidth;
	var float fHeigth;
	var int iLineNumber;
	var UWindowBase.TextAlign eAlignment;
	var bool bDisplay;
};

var array<stItemDesc> m_AItemDesc;
var stItemDesc m_DescTemp;

function ClearItem()
{
	__NFUN_231__("+++++++++++++++++++++++++++++++++++++++++++++++ ClearItem()++++++++++++++++++++++++++++++");
	bSelected = false;
	m_bShowThisItem = false;
	return;
}

function SetItemParameters(int _index, string _szText, Font _TextFont, float _fX, float _fY, float _fW, float _fH, int _iLineNumber, optional UWindowBase.TextAlign _eAlignement)
{
	local stItemDesc ItemDesc;

	// End:0xAE
	if(__NFUN_152__(_index, m_AItemDesc.Length))
	{
		ItemDesc.szText = _szText;
		ItemDesc.TextFont = _TextFont;
		ItemDesc.fXPos = _fX;
		ItemDesc.fYPos = _fY;
		ItemDesc.fWidth = _fW;
		ItemDesc.fHeigth = _fH;
		ItemDesc.iLineNumber = _iLineNumber;
		ItemDesc.eAlignment = _eAlignement;
		ItemDesc.bDisplay = true;
		m_AItemDesc[_index] = ItemDesc;
	}
	return;
}

function SetItemParam(int _index, stItemDesc _ItemParam)
{
	// End:0x21
	if(__NFUN_152__(_index, m_AItemDesc.Length))
	{
		m_AItemDesc[_index] = _ItemParam;
	}
	return;
}

function bool SetItemDescriptionIndex(int _iIndex)
{
	// End:0x23
	if(__NFUN_150__(_iIndex, m_AItemDesc.Length))
	{
		m_DescTemp = m_AItemDesc[_iIndex];
		return true;
	}
	return false;
	return;
}

function string GetItemText(int _iIndex)
{
	// End:0x24
	if(__NFUN_150__(_iIndex, m_AItemDesc.Length))
	{
		return m_AItemDesc[_iIndex].szText;		
	}
	else
	{
		return "";
	}
	return;
}

function string GetItemMisc(int _iIndex)
{
	// End:0x24
	if(__NFUN_150__(_iIndex, m_AItemDesc.Length))
	{
		return m_AItemDesc[_iIndex].szMisc;		
	}
	else
	{
		return "";
	}
	return;
}

function SetItemMisc(int _index, string _szMisc)
{
	local stItemDesc ItemDesc;

	// End:0x42
	if(__NFUN_152__(_index, m_AItemDesc.Length))
	{
		ItemDesc = m_AItemDesc[_index];
		ItemDesc.szMisc = _szMisc;
		m_AItemDesc[_index] = ItemDesc;
	}
	return;
}

function SetItemText(int _index, string _szText)
{
	local stItemDesc ItemDesc;

	// End:0x42
	if(__NFUN_152__(_index, m_AItemDesc.Length))
	{
		ItemDesc = m_AItemDesc[_index];
		ItemDesc.szText = _szText;
		m_AItemDesc[_index] = ItemDesc;
	}
	return;
}

function HideLine(int _iLineNb)
{
	// End:0x23
	if(__NFUN_150__(_iLineNb, m_AItemDesc.Length))
	{
		m_AItemDesc[_iLineNb].bDisplay = false;
	}
	return;
}

function int Compare(UWindowList t, UWindowList B)
{
	local string TS, BS;

	TS = R6WindowListBoxItemExt(t).GetItemText(0);
	BS = R6WindowListBoxItemExt(B).GetItemText(0);
	// End:0x4F
	if(__NFUN_122__(TS, "NONE"))
	{
		return -1;		
	}
	else
	{
		// End:0x61
		if(__NFUN_122__(BS, "NONE"))
		{
			return 1;
		}
	}
	// End:0x72
	if(__NFUN_122__(TS, BS))
	{
		return 0;
	}
	// End:0x87
	if(__NFUN_115__(TS, BS))
	{
		return -1;
	}
	return 1;
	return;
}
