//=============================================================================
// R6WindowIGPlayerInfoListBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowIGPlayerInfoListBox : Class used to manage the "list box" of players
//      in the in game menus.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/27 * Created by John Bennett
//=============================================================================
class R6WindowIGPlayerInfoListBox extends R6WindowListBox;

var UWindowBase.ERenderStyle m_BGRenderStyle;
var int m_fYOffSet;  // the initial Y offset
var Texture m_BGSelTexture;  // BackGround texture under item when selected
var Font m_Font;
var Color m_BGSelColor;  // BackGround color when selected
var Region m_BGSelRegion;  // BackGround texture Region under item when selected
//var color   TextColor;          // color for text            N.B. var already define in class UWindowDialogControl
var Color m_SelTextColor;  // color for selected text
var Color m_SpectatorColor;  // if the player is a spectator

function Created()
{
	super.Created();
	m_Font = Root.Fonts[11];
	m_VertSB.LookAndFeel = LookAndFeel;
	m_VertSB.UpButton.LookAndFeel = LookAndFeel;
	m_VertSB.DownButton.LookAndFeel = LookAndFeel;
	m_VertSB.SetHideWhenDisable(true);
	TextColor = Root.Colors.m_LisBoxNormalTextColor;
	m_SelTextColor = Root.Colors.m_LisBoxSelectedTextColor;
	m_SpectatorColor = Root.Colors.m_LisBoxSpectatorTextColor;
	m_BGSelColor = Root.Colors.m_LisBoxSelectionColor;
	m_BGRenderStyle = 5;
	return;
}

function BeforePaint(Canvas C, float fMouseX, float fMouseY)
{
	m_VertSB.SetBorderColor(m_BorderColor);
	super(UWindowDialogControl).BeforePaint(C, fMouseX, fMouseY);
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local string szTemp;
	local float TextY, tW, tH, fTemp, fYPos;

	local R6WindowListIGPlayerInfoItem pItem;

	pItem = R6WindowListIGPlayerInfoItem(Item);
	// End:0x85
	if(pItem.bOwnPlayer)
	{
		C.SetDrawColor(Root.Colors.BlueLight.R, Root.Colors.BlueLight.G, Root.Colors.BlueLight.B);		
	}
	else
	{
		// End:0xD4
		if((int(pItem.eStatus) == int(pItem.4)))
		{
			C.SetDrawColor(m_SpectatorColor.R, m_SpectatorColor.G, m_SpectatorColor.B);			
		}
		else
		{
			C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
		}
	}
	C.Style = 5;
	C.Font = m_Font;
	szTemp = TextSize(C, pItem.szPlName, tW, tH, int((pItem.stTagCoord[int(pItem.2)].fWidth - float(2))));
	TextY = ((H - tH) / float(2));
	TextY = float(int((TextY + 0.5000000)));
	fYPos = ((Y + TextY) + float(m_fYOffSet));
	// End:0x22C
	if(pItem.bReady)
	{
		DrawIcon(C, 6, pItem.stTagCoord[int(pItem.0)].fXPos, fYPos, pItem.stTagCoord[int(pItem.0)].fWidth, H);		
	}
	else
	{
		DrawIcon(C, 5, pItem.stTagCoord[int(pItem.0)].fXPos, fYPos, pItem.stTagCoord[int(pItem.0)].fWidth, H);
	}
	// End:0x31B
	if((int(pItem.eStatus) != int(pItem.5)))
	{
		DrawIcon(C, pItem.GetHealth(pItem.eStatus), pItem.stTagCoord[int(pItem.1)].fXPos, fYPos, pItem.stTagCoord[int(pItem.1)].fWidth, H);
	}
	C.SetPos((pItem.stTagCoord[int(pItem.2)].fXPos + float(2)), fYPos);
	C.DrawText(szTemp);
	// End:0x453
	if(pItem.stTagCoord[int(pItem.3)].bDisplay)
	{
		szTemp = TextSize(C, pItem.szRoundsWon, tW, tH, int(pItem.stTagCoord[int(pItem.3)].fWidth));
		fTemp = (pItem.stTagCoord[int(pItem.3)].fXPos + float(GetCenterXPos(pItem.stTagCoord[int(pItem.3)].fWidth, tW)));
		C.SetPos(fTemp, fYPos);
		C.DrawText(szTemp);
	}
	szTemp = TextSize(C, string(pItem.iKills), tW, tH, int(pItem.stTagCoord[int(pItem.4)].fWidth));
	fTemp = (pItem.stTagCoord[int(pItem.4)].fXPos + float(GetCenterXPos(pItem.stTagCoord[int(pItem.4)].fWidth, tW)));
	C.SetPos(fTemp, fYPos);
	C.DrawText(szTemp);
	szTemp = TextSize(C, string(pItem.iMyDeadCounter), tW, tH, int(pItem.stTagCoord[int(pItem.5)].fWidth));
	fTemp = (pItem.stTagCoord[int(pItem.5)].fXPos + float(GetCenterXPos(pItem.stTagCoord[int(pItem.5)].fWidth, tW)));
	C.SetPos(fTemp, fYPos);
	C.DrawText(szTemp);
	szTemp = TextSize(C, string(pItem.iEfficiency), tW, tH, int(pItem.stTagCoord[int(pItem.6)].fWidth));
	fTemp = (pItem.stTagCoord[int(pItem.6)].fXPos + float(GetCenterXPos(pItem.stTagCoord[int(pItem.6)].fWidth, tW)));
	C.SetPos(fTemp, fYPos);
	C.DrawText(szTemp);
	szTemp = TextSize(C, string(pItem.iRoundsFired), tW, tH, int(pItem.stTagCoord[int(pItem.7)].fWidth));
	fTemp = (pItem.stTagCoord[int(pItem.7)].fXPos + float(GetCenterXPos(pItem.stTagCoord[int(pItem.7)].fWidth, tW)));
	C.SetPos(fTemp, fYPos);
	C.DrawText(szTemp);
	szTemp = TextSize(C, string(pItem.iRoundsHit), tW, tH, int(pItem.stTagCoord[int(pItem.8)].fWidth));
	fTemp = (pItem.stTagCoord[int(pItem.8)].fXPos + float(GetCenterXPos(pItem.stTagCoord[int(pItem.8)].fWidth, tW)));
	C.SetPos(fTemp, fYPos);
	C.DrawText(szTemp);
	szTemp = TextSize(C, pItem.szKillBy, tW, tH, int((pItem.stTagCoord[int(pItem.9)].fWidth - float(2))));
	C.SetPos((pItem.stTagCoord[int(pItem.9)].fXPos + float(2)), fYPos);
	C.DrawText(szTemp);
	szTemp = TextSize(C, string(pItem.iPingTime), tW, tH, int((pItem.stTagCoord[int(pItem.10)].fWidth - float(2))));
	fTemp = (pItem.stTagCoord[int(pItem.10)].fXPos + float(GetCenterXPos(pItem.stTagCoord[int(pItem.10)].fWidth, tW)));
	C.SetPos(fTemp, fYPos);
	C.DrawText(szTemp);
	return;
}

function DrawIcon(Canvas C, int _iPlayerStats, float _fX, float _fY, float _fWidth, float _fHeight)
{
	local Region RIconRegion, RIconToDraw;

	switch(_iPlayerStats)
	{
		// End:0x42
		case 0:
			RIconToDraw.X = 31;
			RIconToDraw.Y = 29;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			// End:0x175
			break;
		// End:0x7D
		case 1:
			RIconToDraw.X = 42;
			RIconToDraw.Y = 29;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			// End:0x175
			break;
		// End:0x82
		case 2:
		// End:0xBE
		case 3:
			RIconToDraw.X = 53;
			RIconToDraw.Y = 29;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			// End:0x175
			break;
		// End:0xFA
		case 4:
			RIconToDraw.X = 13;
			RIconToDraw.Y = 53;
			RIconToDraw.W = 13;
			RIconToDraw.H = 11;
			// End:0x175
			break;
		// End:0x136
		case 5:
			RIconToDraw.X = 42;
			RIconToDraw.Y = 40;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			// End:0x175
			break;
		// End:0x172
		case 6:
			RIconToDraw.X = 53;
			RIconToDraw.Y = 40;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			// End:0x175
			break;
		// End:0xFFFF
		default:
			break;
	}
	RIconRegion = CenterIconInBox(_fX, _fY, _fWidth, _fHeight, RIconToDraw);
	DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	return;
}

defaultproperties
{
	m_fYOffSet=1
	m_BGSelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_BGSelRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=64802,ZoneNumber=0)
	m_SelTextColor=(R=255,G=255,B=255,A=0)
	m_SpectatorColor=(R=255,G=255,B=255,A=0)
	m_fItemHeight=11.0000000
	m_fSpaceBetItem=0.0000000
	ListClass=Class'R6Window.R6WindowListIGPlayerInfoItem'
}
