//=============================================================================
// R6MenuLegendPage - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuLegendPage.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/29 * Created by Joel Tremblay
//=============================================================================
class R6MenuLegendPage extends R6MenuPopupListButton;

var int m_iTextureSize;  // Texture will be displayed as 32x32
var int m_iSpaceBetweenTextureNText;
var int m_iSpaceEnd;  // little space at the end of the text
var float m_fTitleWidth;
var localized string m_szPageTitle;

function Created()
{
	super(R6WindowListRadioButton).Created();
	m_fItemHeight = float(m_iTextureSize);
	return;
}

function BeforePaint(Canvas C, float MouseX, float MouseY)
{
	local int i, iCurrentNbButton;
	local float fTitleHeight, fWidth, fHeight, fMaxWidth;

	// End:0x299
	if((bInitialized == false))
	{
		bInitialized = true;
		C.Font = Root.Fonts[12];
		i = 0;
		J0x3B:

		// End:0xDC [Loop If]
		if((i < m_iNbButton))
		{
			// End:0xD2
			if(((m_ButtonItem[i] != none) && (m_ButtonItem[i].m_Button != none)))
			{
				TextSize(C, m_ButtonItem[i].m_Button.Text, fWidth, fHeight);
				(fWidth += float(m_iSpaceEnd));
				// End:0xD2
				if((fWidth > fMaxWidth))
				{
					fMaxWidth = fWidth;
				}
			}
			(i++);
			// [Loop Continue]
			goto J0x3B;
		}
		WinWidth = ((fMaxWidth + float(m_iTextureSize)) + float(m_iSpaceBetweenTextureNText));
		// End:0x16D
		if((m_szPageTitle != ""))
		{
			C.Font = Root.Fonts[8];
			TextSize(C, m_szPageTitle, m_fTitleWidth, fTitleHeight);
			fMaxWidth = ((m_fTitleWidth + 12.0000000) + float((R6WindowLegend(ParentWindow).m_NavButtonSize * 2)));
		}
		// End:0x187
		if((WinWidth < fMaxWidth))
		{
			WinWidth = fMaxWidth;
		}
		m_fItemHeight = float(m_iTextureSize);
		iCurrentNbButton = 0;
		i = 0;
		J0x1A2:

		// End:0x26A [Loop If]
		if((i < m_iNbButton))
		{
			// End:0x260
			if(((m_ButtonItem[i] != none) && (m_ButtonItem[i].m_Button != none)))
			{
				m_ButtonItem[i].m_Button.TextColor = Root.Colors.White;
				m_ButtonItem[i].m_Button.WinWidth = WinWidth;
				m_ButtonItem[i].m_Button.WinHeight = m_fItemHeight;
				(iCurrentNbButton++);
			}
			(i++);
			// [Loop Continue]
			goto J0x1A2;
		}
		WinHeight = ((m_fItemHeight * float(iCurrentNbButton)) + float((iCurrentNbButton - 1)));
		ParentWindow.Resized();
	}
	return;
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y;
	local UWindowList CurItem;
	local Color lcolor;

	C.SetDrawColor(byte(255), byte(255), byte(255));
	// End:0x30
	if((m_fItemWidth == float(0)))
	{
		m_fItemWidth = WinWidth;
	}
	X = ((WinWidth - m_fItemWidth) / float(2));
	C.Style = GetPlayerOwner().5;
	CurItem = Items.Next;
	J0x77:

	// End:0x1FE [Loop If]
	if((CurItem != none))
	{
		R6WindowListButtonItem(CurItem).m_Button.ShowWindow();
		DrawItem(C, CurItem, X, Y, m_fItemWidth, m_fItemHeight);
		(Y += m_fItemHeight);
		// End:0x1E7
		if((Y < WinHeight))
		{
			lcolor = Root.Colors.TeamColorLight[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam];
			C.SetDrawColor(lcolor.R, lcolor.G, lcolor.B, byte(Root.Colors.PopUpAlphaFactor));
			DrawStretchedTextureSegment(C, X, Y, float((m_SeperatorLineRegion.W + m_iTextureSize)), float(m_SeperatorLineRegion.H), float(m_SeperatorLineRegion.X), float(m_SeperatorLineRegion.Y), float(m_SeperatorLineRegion.W), float(m_SeperatorLineRegion.H), m_SeperatorLineTexture);
			(Y += float(m_SeperatorLineRegion.H));
			C.SetDrawColor(byte(255), byte(255), byte(255));
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x77;
	}
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local R6MenuLegendItem pR6MenuLegendItem;
	local R6WindowListButtonItem pListButtonItem;

	pR6MenuLegendItem = R6MenuLegendItem(Item);
	pListButtonItem = R6WindowListButtonItem(Item);
	// End:0xCC
	if((pR6MenuLegendItem.m_pObjectIcon != none))
	{
		// End:0x96
		if((pR6MenuLegendItem.m_bOtherTextureHeight == true))
		{
			DrawStretchedTextureSegment(C, X, Y, float(m_iTextureSize), float(m_iTextureSize), 0.0000000, 0.0000000, 128.0000000, 148.0000000, R6MenuLegendItem(Item).m_pObjectIcon);			
		}
		else
		{
			DrawStretchedTexture(C, X, Y, float(m_iTextureSize), float(m_iTextureSize), R6MenuLegendItem(Item).m_pObjectIcon);
		}
	}
	// End:0x149
	if((pListButtonItem.m_Button != none))
	{
		pListButtonItem.m_Button.WinLeft = ((X + float(m_iTextureSize)) + float(m_iSpaceBetweenTextureNText));
		pListButtonItem.m_Button.WinTop = Y;
		pListButtonItem.m_Button.WinHeight = H;
	}
	return;
}

defaultproperties
{
	m_iTextureSize=32
	m_iSpaceBetweenTextureNText=2
	m_iSpaceEnd=12
	m_iNbButton=6
	ListClass=Class'R6Menu.R6MenuLegendItem'
}
