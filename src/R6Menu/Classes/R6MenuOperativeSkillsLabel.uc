//=============================================================================
// R6MenuOperativeSkillsLabel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
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
	if(__NFUN_123__(Text, ""))
	{
		C.Font = m_Font;
		C.SpaceX = m_fFontSpacing;
		C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
		C.Style = byte(m_TextDrawstyle);
		ClipText(C, TextX, TextY, Text, true);
	}
	// End:0xA6
	if(__NFUN_123__(m_szNumericValue, ""))
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
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	TextSize(C, m_szNumericValue, fW, fH);
	// End:0x153
	if(__NFUN_180__(m_fWidthOfFixArea, float(0)))
	{
		fSizeOfBG = __NFUN_174__(fW, float(6));
		DrawStretchedTextureSegment(C, __NFUN_175__(WinWidth, fSizeOfBG), 0.0000000, fSizeOfBG, WinHeight, float(m_BGTextureRegion.X), float(m_BGTextureRegion.Y), float(m_BGTextureRegion.W), float(m_BGTextureRegion.H), m_BGTexture);
		C.__NFUN_2623__(__NFUN_174__(__NFUN_175__(WinWidth, fSizeOfBG), float(3)), m_fHBorderHeight);		
	}
	else
	{
		DrawStretchedTextureSegment(C, __NFUN_175__(WinWidth, m_fWidthOfFixArea), 0.0000000, m_fWidthOfFixArea, WinHeight, float(m_BGTextureRegion.X), float(m_BGTextureRegion.Y), float(m_BGTextureRegion.W), float(m_BGTextureRegion.H), m_BGTexture);
		fX = __NFUN_174__(__NFUN_175__(WinWidth, m_fWidthOfFixArea), __NFUN_172__(__NFUN_175__(m_fWidthOfFixArea, fW), float(2)));
		C.__NFUN_2623__(fX, m_fHBorderHeight);
	}
	C.__NFUN_2626__(m_NumericValueColor.R, m_NumericValueColor.G, m_NumericValueColor.B);
	C.__NFUN_465__(m_szNumericValue);
	return;
}

function SetNumericValue(int _iOriginalValue, int _iLastValue)
{
	local int ITemp, iOriginalValue;

	iOriginalValue = __NFUN_249__(_iOriginalValue, 100);
	m_szNumericValue = string(__NFUN_250__(iOriginalValue, 0));
	ITemp = __NFUN_147__(__NFUN_249__(_iLastValue, 100), iOriginalValue);
	// End:0x9A
	if(__NFUN_155__(ITemp, 0))
	{
		// End:0x71
		if(__NFUN_151__(ITemp, 0))
		{
			m_szNumericValue = __NFUN_112__(__NFUN_112__(__NFUN_112__(m_szNumericValue, "(+"), string(__NFUN_249__(ITemp, 100))), ")");			
		}
		else
		{
			m_szNumericValue = __NFUN_112__(__NFUN_112__(__NFUN_112__(m_szNumericValue, "(-"), string(__NFUN_249__(int(__NFUN_186__(float(ITemp))), 100))), ")");
		}
	}
	return;
}

defaultproperties
{
	m_bDrawBorders=false
	m_BGTextureRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28962,ZoneNumber=0)
}
