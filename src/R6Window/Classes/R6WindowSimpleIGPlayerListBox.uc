//=============================================================================
// R6WindowSimpleIGPlayerListBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowSimpleIGPlayerListBox.uc : This version of the list box is for single player
//                                      Rainbow team stats, the parent class is for multi-player
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/19 * Created by Alexandre Dionne
//=============================================================================
class R6WindowSimpleIGPlayerListBox extends R6WindowIGPlayerInfoListBox;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local float TextY, tW, tH, fTemp, fYPos;

	local Color co;
	local R6WindowListIGPlayerInfoItem pListIGPlayerInfoItem;
	local R6WindowLookAndFeel pLookAndFeel;

	pListIGPlayerInfoItem = R6WindowListIGPlayerInfoItem(Item);
	pLookAndFeel = R6WindowLookAndFeel(LookAndFeel);
	// End:0x106
	if(pListIGPlayerInfoItem.bSelected)
	{
		// End:0x106
		if(__NFUN_119__(m_BGSelTexture, none))
		{
			C.Style = m_BGRenderStyle;
			C.__NFUN_2626__(m_BGSelColor.R, m_BGSelColor.G, m_BGSelColor.B, m_BGSelColor.A);
			fYPos = __NFUN_174__(Y, __NFUN_172__(__NFUN_175__(H, float(m_BGSelRegion.H)), float(2)));
			DrawStretchedTextureSegment(C, X, fYPos, W, float(m_BGSelRegion.H), float(m_BGSelRegion.X), float(m_BGSelRegion.Y), float(m_BGSelRegion.W), float(m_BGSelRegion.H), m_BGSelTexture);
		}
	}
	C.Style = 5;
	C.Font = m_Font;
	TextSize(C, pListIGPlayerInfoItem.szPlName, tW, tH);
	TextY = __NFUN_172__(__NFUN_175__(H, tH), float(2));
	TextY = float(int(__NFUN_174__(TextY, 0.5000000)));
	fYPos = __NFUN_174__(Y, TextY);
	// End:0x1D0
	if(pListIGPlayerInfoItem.bSelected)
	{
		co = Root.Colors.TeamColorLight[pListIGPlayerInfoItem.m_iRainbowTeam];		
	}
	else
	{
		co = Root.Colors.TeamColor[pListIGPlayerInfoItem.m_iRainbowTeam];
	}
	C.__NFUN_2626__(co.R, co.G, co.B, co.A);
	pLookAndFeel.DrawInGamePlayerStats(self, C, 4, pListIGPlayerInfoItem.stTagCoord[0].fXPos, Y, H, pListIGPlayerInfoItem.stTagCoord[0].fWidth);
	switch(pListIGPlayerInfoItem.eStatus)
	{
		// End:0x2DF
		case 0:
			pLookAndFeel.DrawInGamePlayerStats(self, C, 1, pListIGPlayerInfoItem.stTagCoord[2].fXPos, Y, H, pListIGPlayerInfoItem.stTagCoord[2].fWidth);
			// End:0x391
			break;
		// End:0x334
		case 1:
			pLookAndFeel.DrawInGamePlayerStats(self, C, 2, pListIGPlayerInfoItem.stTagCoord[2].fXPos, Y, H, pListIGPlayerInfoItem.stTagCoord[2].fWidth);
			// End:0x391
			break;
		// End:0x339
		case 2:
		// End:0x38E
		case 3:
			pLookAndFeel.DrawInGamePlayerStats(self, C, 3, pListIGPlayerInfoItem.stTagCoord[2].fXPos, Y, H, pListIGPlayerInfoItem.stTagCoord[2].fWidth);
			// End:0x391
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0x3D0
	if(pListIGPlayerInfoItem.bSelected)
	{
		C.__NFUN_2626__(m_SelTextColor.R, m_SelTextColor.G, m_SelTextColor.B);		
	}
	else
	{
		C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
	}
	C.__NFUN_2623__(pListIGPlayerInfoItem.stTagCoord[1].fXPos, fYPos);
	C.__NFUN_465__(pListIGPlayerInfoItem.szPlName);
	TextSize(C, string(pListIGPlayerInfoItem.iKills), tW, tH);
	fTemp = __NFUN_174__(pListIGPlayerInfoItem.stTagCoord[3].fXPos, float(GetCenterXPos(pListIGPlayerInfoItem.stTagCoord[3].fWidth, tW)));
	C.__NFUN_2623__(fTemp, fYPos);
	C.__NFUN_465__(string(pListIGPlayerInfoItem.iKills));
	TextSize(C, string(pListIGPlayerInfoItem.iEfficiency), tW, tH);
	fTemp = __NFUN_174__(pListIGPlayerInfoItem.stTagCoord[4].fXPos, float(GetCenterXPos(pListIGPlayerInfoItem.stTagCoord[4].fWidth, tW)));
	C.__NFUN_2623__(fTemp, fYPos);
	C.__NFUN_465__(string(pListIGPlayerInfoItem.iEfficiency));
	TextSize(C, string(pListIGPlayerInfoItem.iRoundsFired), tW, tH);
	fTemp = __NFUN_174__(pListIGPlayerInfoItem.stTagCoord[5].fXPos, float(GetCenterXPos(pListIGPlayerInfoItem.stTagCoord[5].fWidth, tW)));
	C.__NFUN_2623__(fTemp, fYPos);
	C.__NFUN_465__(string(pListIGPlayerInfoItem.iRoundsFired));
	TextSize(C, string(pListIGPlayerInfoItem.iRoundsHit), tW, tH);
	fTemp = __NFUN_174__(pListIGPlayerInfoItem.stTagCoord[6].fXPos, float(GetCenterXPos(pListIGPlayerInfoItem.stTagCoord[6].fWidth, tW)));
	C.__NFUN_2623__(fTemp, fYPos);
	C.__NFUN_465__(string(pListIGPlayerInfoItem.iRoundsHit));
	return;
}

defaultproperties
{
	m_fItemHeight=14.0000000
}
