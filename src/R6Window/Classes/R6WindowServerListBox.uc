//=============================================================================
// R6WindowServerListBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowServerListBox.uc : Class used to manage the "list box" of servers.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/27 * Created by John Bennett
//=============================================================================
class R6WindowServerListBox extends R6WindowListBox;

var UWindowBase.ERenderStyle m_BGRenderStyle;
var int m_iPingTimeOut;  // Time at which the ping time times out
var bool m_bDrawBorderAndBkg;  // draw the border and the background
var Texture m_BGSelTexture;  // BackGround texture under item when selected
var Font m_Font;
var Color m_BGSelColor;  // BackGround color when selected
var Region m_BGSelRegion;  // BackGround texture Region under item when selected
var Color m_SelTextColor;  // color for selected text

function Created()
{
	super.Created();
	m_VertSB.SetHideWhenDisable(true);
	TextColor = Root.Colors.m_LisBoxNormalTextColor;
	m_SelTextColor = Root.Colors.m_LisBoxSelectedTextColor;
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

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	// End:0x23
	if(m_bDrawBorderAndBkg)
	{
		R6WindowLookAndFeel(LookAndFeel).R6List_DrawBackground(self, C);
	}
	super.Paint(C, fMouseX, fMouseY);
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local R6WindowListServerItem pSItem;
	local float TextY, fYPos, fTemp, tW, tH;

	local string szTemp;

	pSItem = R6WindowListServerItem(Item);
	// End:0xEC
	if(pSItem.bSelected)
	{
		// End:0xBF
		if((m_BGSelTexture != none))
		{
			C.Style = m_BGRenderStyle;
			C.SetDrawColor(m_BGSelColor.R, m_BGSelColor.G, m_BGSelColor.B);
			DrawStretchedTextureSegment(C, X, Y, W, H, float(m_BGSelRegion.X), float(m_BGSelRegion.Y), float(m_BGSelRegion.W), float(m_BGSelRegion.H), m_BGSelTexture);
		}
		C.SetDrawColor(m_SelTextColor.R, m_SelTextColor.G, m_SelTextColor.B);		
	}
	else
	{
		C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
	}
	C.Font = m_Font;
	C.Style = 5;
	// End:0x1AF
	if((!pSItem.bSameVersion))
	{
		C.SetDrawColor(Root.Colors.GrayLight.R, Root.Colors.GrayLight.G, Root.Colors.GrayLight.B);
	}
	TextSize(C, "A", tW, tH);
	TextY = ((H - tH) / float(2));
	TextY = float(int((TextY + 0.5000000)));
	fYPos = (Y + TextY);
	// End:0x27E
	if(pSItem.bFavorite)
	{
		DrawIcon(C, int(pSItem.0), pSItem.m_stServerItemPos[int(pSItem.0)].fXPos, fYPos, pSItem.m_stServerItemPos[int(pSItem.0)].fWidth, tH);
	}
	// End:0x2F4
	if(pSItem.bLocked)
	{
		DrawIcon(C, int(pSItem.1), pSItem.m_stServerItemPos[int(pSItem.1)].fXPos, fYPos, pSItem.m_stServerItemPos[int(pSItem.1)].fWidth, tH);
	}
	// End:0x36A
	if(pSItem.bDedicated)
	{
		DrawIcon(C, int(pSItem.2), pSItem.m_stServerItemPos[int(pSItem.2)].fXPos, fYPos, pSItem.m_stServerItemPos[int(pSItem.2)].fWidth, tH);
	}
	// End:0x3E0
	if(pSItem.bPunkBuster)
	{
		DrawIcon(C, int(pSItem.3), pSItem.m_stServerItemPos[int(pSItem.3)].fXPos, fYPos, pSItem.m_stServerItemPos[int(pSItem.3)].fWidth, tH);
	}
	// End:0x447
	if(pSItem.m_bNewItem)
	{
		pSItem.szName = TextSize(C, pSItem.szName, tW, tH, int(pSItem.m_stServerItemPos[int(pSItem.4)].fWidth));
	}
	C.SetPos((pSItem.m_stServerItemPos[int(pSItem.4)].fXPos + float(2)), fYPos);
	C.DrawText(pSItem.szName);
	// End:0x4CA
	if((pSItem.iPing < m_iPingTimeOut))
	{
		szTemp = string(pSItem.iPing);		
	}
	else
	{
		szTemp = "-";
	}
	TextSize(C, szTemp, tW, tH);
	fTemp = (pSItem.m_stServerItemPos[int(pSItem.5)].fXPos + float(GetCenterXPos(pSItem.m_stServerItemPos[int(pSItem.5)].fWidth, tW)));
	C.SetPos(fTemp, fYPos);
	C.DrawText(szTemp);
	pSItem.szGameType = TextSize(C, pSItem.szGameType, tW, tH, int(pSItem.m_stServerItemPos[int(pSItem.6)].fWidth));
	fTemp = (pSItem.m_stServerItemPos[int(pSItem.6)].fXPos + float(GetCenterXPos(pSItem.m_stServerItemPos[int(pSItem.6)].fWidth, tW)));
	C.SetPos(fTemp, fYPos);
	C.DrawText(pSItem.szGameType);
	pSItem.szGameMode = TextSize(C, pSItem.szGameMode, tW, tH, int(pSItem.m_stServerItemPos[int(pSItem.7)].fWidth));
	fTemp = (pSItem.m_stServerItemPos[int(pSItem.7)].fXPos + float(GetCenterXPos(pSItem.m_stServerItemPos[int(pSItem.7)].fWidth, tW)));
	C.SetPos(fTemp, fYPos);
	C.DrawText(pSItem.szGameMode);
	pSItem.szMap = TextSize(C, pSItem.szMap, tW, tH, int(pSItem.m_stServerItemPos[int(pSItem.8)].fWidth));
	fTemp = (pSItem.m_stServerItemPos[int(pSItem.8)].fXPos + float(GetCenterXPos(pSItem.m_stServerItemPos[int(pSItem.8)].fWidth, tW)));
	C.SetPos(fTemp, fYPos);
	C.DrawText(pSItem.szMap);
	// End:0x8F0
	if(((pSItem.iMaxPlayers > 0) && (pSItem.iNumPlayers >= 0)))
	{
		szTemp = ((string(pSItem.iNumPlayers) $ "/") $ string(pSItem.iMaxPlayers));
		TextSize(C, szTemp, tW, tH);
		fTemp = (pSItem.m_stServerItemPos[int(pSItem.9)].fXPos + float(GetCenterXPos(pSItem.m_stServerItemPos[int(pSItem.9)].fWidth, tW)));
		C.SetPos(fTemp, fYPos);
		C.DrawText(szTemp);
	}
	pSItem.m_bNewItem = false;
	return;
}

function DrawIcon(Canvas C, int _iPlayerStats, float _fX, float _fY, float _fWidth, float _fHeight)
{
	local Region RIconRegion, RIconToDraw;

	switch(_iPlayerStats)
	{
		// End:0x41
		case 0:
			RIconToDraw.X = 0;
			RIconToDraw.Y = 42;
			RIconToDraw.W = 13;
			RIconToDraw.H = 11;
			// End:0x144
			break;
		// End:0x7C
		case 1:
			RIconToDraw.X = 13;
			RIconToDraw.Y = 42;
			RIconToDraw.W = 13;
			RIconToDraw.H = 11;
			// End:0x144
			break;
		// End:0xB7
		case 2:
			RIconToDraw.X = 0;
			RIconToDraw.Y = 53;
			RIconToDraw.W = 13;
			RIconToDraw.H = 11;
			// End:0x144
			break;
		// End:0xF3
		case 3:
			RIconToDraw.X = 26;
			RIconToDraw.Y = 53;
			RIconToDraw.W = 13;
			RIconToDraw.H = 11;
			// End:0x144
			break;
		// End:0xFFFF
		default:
			Log((("R6WindowServerListBox DrawIcon() --> This icon " @ string(_iPlayerStats)) @ "don't exist"));
			// End:0x144
			break;
			break;
	}
	RIconRegion = CenterIconInBox(_fX, _fY, _fWidth, _fHeight, RIconToDraw);
	DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	return;
}

//=============================================================================
// RMouseDown - If the user right clicks on a server, we call the notify
// function so that the right-click menu can be displayed.
//=============================================================================
function RMouseDown(float X, float Y)
{
	super(UWindowWindow).RMouseDown(X, Y);
	// End:0x3E
	if((GetItemAt(X, Y) != none))
	{
		SetSelected(X, Y);
		Notify(6);
	}
	return;
}

//=============================================================================
// SetSelectedItem - We were getting recursion problems caused by
// the Notify(DE_Click) function, so this function was overloaded and the 
// call to Notify(DE_Click) was removed (not needed in this application).
//=============================================================================
function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	// End:0x5F
	if(((NewSelected != none) && (m_SelectedItem != NewSelected)))
	{
		// End:0x38
		if((m_SelectedItem != none))
		{
			m_SelectedItem.bSelected = false;
		}
		m_SelectedItem = NewSelected;
		// End:0x5F
		if((m_SelectedItem != none))
		{
			m_SelectedItem.bSelected = true;
		}
	}
	return;
}

defaultproperties
{
	m_iPingTimeOut=1000
	m_BGSelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_BGSelColor=(R=0,G=0,B=128,A=0)
	m_BGSelRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=64802,ZoneNumber=0)
	m_SelTextColor=(R=255,G=255,B=255,A=0)
	m_fItemHeight=14.0000000
	ListClass=Class'R6Window.R6WindowListServerItem'
}
