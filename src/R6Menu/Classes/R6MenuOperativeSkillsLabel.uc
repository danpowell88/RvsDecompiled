//=============================================================================
// R6MenuOperativeSkillsLabel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuOperativeSkillsLabel.uc : Set Default Properties for the labels on the 
//                                  skills page
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeSkillsLabel extends R6WindowTextLabel;

var float m_fWidthOfFixArea;  // use a fix area width for the numeric value
var Color m_NumericValueColor;  // the color of the numeric value
var string m_szNumericValue;  // the numeric value

function Created()
{
	m_Font = Root.Fonts[6];
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x8F
	if((Text != ""))
	{
		C.Font = m_Font;
		C.SpaceX = m_fFontSpacing;
		C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
		C.Style = byte(m_TextDrawstyle);
		ClipText(C, TextX, TextY, Text, true);
	}
	// End:0xA6
	if((m_szNumericValue != ""))
	{
		DrawNumericValue(C);
	}
	return;
}

function DrawNumericValue(Canvas C)
{
	local float fX, fW, fH, fSizeOfBG;

	C.Font = m_Font;
	C.SpaceX = m_fFontSpacing;
	C.Style = 5;
	C.SetDrawColor(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	TextSize(C, m_szNumericValue, fW, fH);
	// End:0x153
	if((m_fWidthOfFixArea == float(0)))
	{
		fSizeOfBG = (fW + float(6));
		DrawStretchedTextureSegment(C, (WinWidth - fSizeOfBG), 0.0000000, fSizeOfBG, WinHeight, float(m_BGTextureRegion.X), float(m_BGTextureRegion.Y), float(m_BGTextureRegion.W), float(m_BGTextureRegion.H), m_BGTexture);
		C.SetPos(((WinWidth - fSizeOfBG) + float(3)), m_fHBorderHeight);		
	}
	else
	{
		DrawStretchedTextureSegment(C, (WinWidth - m_fWidthOfFixArea), 0.0000000, m_fWidthOfFixArea, WinHeight, float(m_BGTextureRegion.X), float(m_BGTextureRegion.Y), float(m_BGTextureRegion.W), float(m_BGTextureRegion.H), m_BGTexture);
		fX = ((WinWidth - m_fWidthOfFixArea) + ((m_fWidthOfFixArea - fW) / float(2)));
		C.SetPos(fX, m_fHBorderHeight);
	}
	C.SetDrawColor(m_NumericValueColor.R, m_NumericValueColor.G, m_NumericValueColor.B);
	C.DrawText(m_szNumericValue);
	return;
}

function SetNumericValue(int _iOriginalValue, int _iLastValue)
{
	local int ITemp, iOriginalValue;

	iOriginalValue = Min(_iOriginalValue, 100);
	m_szNumericValue = string(Max(iOriginalValue, 0));
	ITemp = (Min(_iLastValue, 100) - iOriginalValue);
	// End:0x9A
	if((ITemp != 0))
	{
		// End:0x71
		if((ITemp > 0))
		{
			m_szNumericValue = (((m_szNumericValue $ "(+")) $ ")" $ ???);			
		}
		else
		{
			m_szNumericValue = (((m_szNumericValue $ "(-")) $ ")" $ ???);
		}
	}
	return;
}

defaultproperties
{
	m_bDrawBorders=false
	m_BGTextureRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28962,ZoneNumber=0)
}
