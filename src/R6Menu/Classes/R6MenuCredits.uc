//=============================================================================
// R6MenuCredits - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuCredits.uc : Auto-scroll and display of the credits
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/01/08 * Created by Yannick Joly
//=============================================================================
class R6MenuCredits extends UWindowListControl;

var int m_iScrollIndex;  // The index of the scroll
var int m_iScrollStep;
var bool m_bStopScroll;
var float m_fScrollSpeed;
var float m_fTexScrollSpeed;
var float m_fScrollIndex;
var float m_fYScrollEffect;
var float m_fDelta;
var UWindowList m_FirstItemOnScreen;

function Tick(float fDelta)
{
	m_fDelta = fDelta;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	PaintCredits(C);
	PaintTexEffect(C);
	return;
}

function PaintTexEffect(Canvas C)
{
	local Texture TexScrollEffect;

	C.Style = 7;
	TexScrollEffect = Texture'R6MenuTextures.Credits.Line';
	// End:0x73
	if((!m_bStopScroll))
	{
		(m_fYScrollEffect -= ((m_fDelta * m_fScrollSpeed) * float(2)));
		// End:0x73
		if((m_fYScrollEffect < float((-TexScrollEffect.VSize))))
		{
			(m_fYScrollEffect += float(TexScrollEffect.VSize));
		}
	}
	C.SetDrawColor(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	C.SetPos(0.0000000, 0.0000000);
	C.DrawTile(TexScrollEffect, WinWidth, WinHeight, 0.0000000, m_fYScrollEffect, float(TexScrollEffect.USize), float(TexScrollEffect.VSize));
	return;
}

function PaintCredits(Canvas C)
{
	local UWindowList CurItem;
	local R6WindowListBoxCreditsItem R6CurItem;
	local float y1, iCurrentYPos;
	local bool bStopNextTime;

	// End:0x29
	if((m_FirstItemOnScreen == none))
	{
		m_FirstItemOnScreen = Items.Next;
		m_iScrollIndex = 0;		
	}
	else
	{
		// End:0xB1
		if((!m_bStopScroll))
		{
			(m_fScrollIndex += (m_fDelta * m_fScrollSpeed));
			(m_iScrollIndex -= int(m_fScrollIndex));
			// End:0x71
			if((m_fScrollIndex > float(m_iScrollStep)))
			{
				m_fScrollIndex = 0.0000000;
			}
			// End:0xB1
			if((Abs(float(m_iScrollIndex)) > R6WindowListBoxCreditsItem(m_FirstItemOnScreen).m_fHeight))
			{
				m_FirstItemOnScreen = m_FirstItemOnScreen.Next;
				m_iScrollIndex = -1;
			}
		}
	}
	CurItem = m_FirstItemOnScreen;
	R6CurItem = R6WindowListBoxCreditsItem(CurItem);
	y1 = float(m_iScrollIndex);
	J0xD9:

	// End:0x193 [Loop If]
	if((CurItem != none))
	{
		DrawItem(C, CurItem, 0.0000000, y1, WinWidth, R6CurItem.m_fHeight);
		y1 = (y1 + R6CurItem.m_fHeight);
		CurItem = CurItem.Next;
		// End:0x159
		if(((CurItem == none) || bStopNextTime))
		{
			// [Explicit Break]
			goto J0x193;
		}
		R6CurItem = R6WindowListBoxCreditsItem(CurItem);
		// End:0x190
		if(((y1 + R6CurItem.m_fHeight) > WinHeight))
		{
			bStopNextTime = true;
		}
		// [Loop Continue]
		goto J0xD9;
	}
	J0x193:

	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local float fXPos, fYPos, fW, fH;
	local R6WindowListBoxCreditsItem pItem;

	pItem = R6WindowListBoxCreditsItem(Item);
	// End:0x4C
	if((!pItem.m_bConvertItemValue))
	{
		// End:0x3B
		if((!ConvertItemValue(C, pItem)))
		{
			return;
		}
		pItem.m_bConvertItemValue = true;
	}
	C.Style = 5;
	C.Font = pItem.m_Font;
	C.SetDrawColor(pItem.m_TextColor.R, pItem.m_TextColor.G, pItem.m_TextColor.B, 225);
	fXPos = (X + float(pItem.m_iXPosOffset));
	fYPos = (Y + float(pItem.m_iYPosOffset));
	ClipText(C, fXPos, fYPos, pItem.m_szName);
	// End:0x1D9
	if(pItem.m_bDrawALineUnderText)
	{
		TextSize(C, pItem.m_szName, fW, fH);
		(fYPos += fH);
		// End:0x1D9
		if(((fYPos > float(0)) && (fYPos < WinHeight)))
		{
			DrawStretchedTextureSegment(C, fXPos, fYPos, fW, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
		}
	}
	return;
}

function bool ConvertItemValue(Canvas C, out R6WindowListBoxCreditsItem _pItemToConvert)
{
	local string szTemp;
	local float fTemp, fTextW, fTextH;

	// End:0x0D
	if((_pItemToConvert == none))
	{
		return false;
	}
	_pItemToConvert.m_Font = Root.Fonts[_pItemToConvert.m_iFont];
	switch(_pItemToConvert.m_iColor)
	{
		// End:0x76
		case 0:
			_pItemToConvert.m_TextColor = Root.Colors.BlueLight;
			// End:0xCF
			break;
		// End:0xA3
		case 1:
			_pItemToConvert.m_TextColor = Root.Colors.White;
			// End:0xCF
			break;
		// End:0xFFFF
		default:
			_pItemToConvert.m_TextColor = Root.Colors.White;
			// End:0xCF
			break;
			break;
	}
	C.Font = _pItemToConvert.m_Font;
	szTemp = _pItemToConvert.m_szName;
	szTemp = TextSize(C, szTemp, fTextW, fTextH, int(WinWidth));
	_pItemToConvert.m_szName = szTemp;
	fTemp = ((WinWidth - fTextW) / float(2));
	_pItemToConvert.m_iXPosOffset = int((fTemp + 0.5000000));
	fTemp = ((_pItemToConvert.m_fHeight - fTextH) / float(2));
	_pItemToConvert.m_iYPosOffset = int((fTemp + 0.5000000));
	return true;
	return;
}

function ResetCredits()
{
	m_FirstItemOnScreen = none;
	m_fScrollIndex = 0.0000000;
	m_fYScrollEffect = 0.0000000;
	m_bStopScroll = false;
	return;
}

defaultproperties
{
	m_iScrollStep=1
	m_fScrollSpeed=25.0000000
	m_fTexScrollSpeed=1.0000000
	ListClass=Class'R6Window.R6WindowListBoxCreditsItem'
}
