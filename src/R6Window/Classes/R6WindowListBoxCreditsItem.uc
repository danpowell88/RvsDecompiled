//=============================================================================
// R6WindowListBoxCreditsItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowListBoxCreditsItem.uc : list box credits item
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/01/08 * Created by Yannick Joly
//=============================================================================
class R6WindowListBoxCreditsItem extends UWindowList;

var int m_iFont;  // a int because we not have access to root to specify the font
var int m_iColor;  // a int because we not have access to root to specify the color
var int m_iXPosOffset;  // the offset of the text in this item
var int m_iYPosOffset;  // the offset of the text in this item
var bool m_bDrawALineUnderText;
var bool m_bConvertItemValue;
var float m_fHeight;
var Font m_Font;
var Color m_TextColor;
var string m_szName;

function Init(string _szCreditsLine)
{
	local string szTemp;
	local int iMarkerPos1, iMarkerPos2;

	szTemp = _szCreditsLine;
	iMarkerPos1 = InStr(szTemp, "[");
	// End:0x2C
	if((iMarkerPos1 == -1))
	{
		return;
	}
	iMarkerPos2 = InStr(szTemp, "]");
	// End:0x4D
	if((iMarkerPos2 == -1))
	{
		return;
	}
	(iMarkerPos1 += 1);
	szTemp = Mid(szTemp, iMarkerPos1, (iMarkerPos2 - iMarkerPos1));
	(iMarkerPos2 += 1);
	switch(szTemp)
	{
		// End:0xC0
		case "T0":
			m_szName = Mid(_szCreditsLine, iMarkerPos2);
			m_fHeight = 40.0000000;
			m_iFont = 4;
			m_iColor = 0;
			m_bDrawALineUnderText = true;
			// End:0x147
			break;
		// End:0xF6
		case "T1":
			m_szName = Mid(_szCreditsLine, iMarkerPos2);
			m_fHeight = 20.0000000;
			m_iFont = 16;
			m_iColor = 0;
			// End:0x147
			break;
		// End:0x12C
		case "T2":
			m_szName = Mid(_szCreditsLine, iMarkerPos2);
			m_fHeight = 20.0000000;
			m_iFont = 5;
			m_iColor = 1;
			// End:0x147
			break;
		// End:0xFFFF
		default:
			m_szName = "";
			m_fHeight = float(szTemp);
			// End:0x147
			break;
			break;
	}
	return;
}

