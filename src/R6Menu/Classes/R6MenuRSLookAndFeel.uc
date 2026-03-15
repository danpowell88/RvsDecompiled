//=============================================================================
// R6MenuRSLookAndFeel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuRSLookAndFeel.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuRSLookAndFeel extends R6WindowLookAndFeel;

const SIZEBORDER = 3;
const BRSIZEBORDER = 15;
const RadioButtonHeight = 17;
const RadioButtonWidth = 16;

enum ERSBLButton
{
	ERSBL_BLActive,                 // 0
	ERSBL_BLLeft,                   // 1
	ERSBL_BLRight                   // 2
};

enum ENavBarButton
{
	NBB_Home,                       // 0
	NBB_Option,                     // 1
	NBB_Archive,                    // 2
	NBB_TeleCom,                    // 3
	NBB_Roster,                     // 4
	NBB_Gear,                       // 5
	NBB_Planning,                   // 6
	NBB_Play,                       // 7
	NBB_Load,                       // 8
	NBB_Save                        // 9
};

enum eSignChoiceButton
{
	eSCB_Accept,                    // 0
	eSCB_Cancel                     // 1
};

struct STWindowFrame
{
	var Region TL;
	var Region t;
	var Region TR;
	var Region L;
	var Region R;
	var Region BL;
	var Region B;
	var Region BR;
};

struct STFrameColor
{
	var Color TextColor;
	var Color SelTextColor;
	var Color DisableColor;
	var Color TitleColor;
	var Color TitleBack;
	var Color ButtonBack;
	var Color SelButtonBack;
	var Color ButtonLine;
};

struct STLapTopFrame
{
	var Region TL;
	var Region t;
	var Region TR;
	var Region L;
	var Region R;
	var Region BL;
	var Region B;
	var Region BR;
	var Region L2;
	var Region R2;
	var Region L3;
	var Region R3;
	var Region L4;
	var Region R4;
};

struct STLapTopFramePlus
{
	var Region T1;
	var Region T2;
	var Region T3;
	var Region T4On;
	var Region T4Off;
};

var int m_iMultiplyer;
//-----------------------------------------------
//Scroll Bar
var int m_fVSBButtonImageX;
// NEW IN 1.60
var int m_fHSBButtonImageX;
var int m_fVSBButtonImageY;
// NEW IN 1.60
var int m_fHSBButtonImageY;
//-----------------------------------------------
//Combo
var int m_fComboImageX;
// NEW IN 1.60
var int m_fComboImageY;
//-----------------------------------------------
//R6WindowButtonMainMenu
var float m_fCurrentPct;
// NEW IN 1.60
var float m_fScrollRate;
var float m_fTextHeaderHeight;  // the in-game menu intermission text header
// Menu Texture
var Texture m_NavBarTex;
//-----------------------------------------------
// In-Game Menu
var Texture m_TIcon;
var Texture m_TSquareBg;
var Region m_FrameSBL;
var Region m_FrameSB;
var Region m_FrameSBR;
var RegionButton m_BLTitleL;
var RegionButton m_BLTitleC;
var RegionButton m_BLTitleR;
// Popup ActionPoint menu
var Region m_PopupArrowUp;
var Region m_PopupArrowDown;
//-----------------------------------------------
// Laptop frame
var STLapTopFrame m_stLapTopFrame;
var STLapTopFramePlus m_stLapTopFramePlus;
//-----------------------------------------------
// Navigation Bar
var Region m_NavBarBack[12];
//-----------------------------------------------
//ListBox
var Region m_topLeftCornerR;
//-----------------------------------------------
// Simple Pop-up Window (ex. JoinIp window with an edit box)
var RegionButton m_RBAcceptCancel[2];  // accept button, cancel button
//-----------------------------------------------
// Create game menu
var RegionButton m_RArrow[2];  // the region of the arrow button for map list
var Region m_SBScrollerActive;
var Region m_SBUpGear;
var Region m_SBDownGear;
//-----------------------------------------------
//Square Border
var Region m_RSquareBgLeft;
var Region m_RSquareBgMid;
var Region m_RSquareBgRight;

function Setup()
{
	super(UWindowLookAndFeel).Setup();
	m_NavBarTex = Texture(DynamicLoadObject("R6MenuTextures.GUI_01", Class'Engine.Texture'));
	m_R6ScrollTexture = Texture(DynamicLoadObject("R6MenuTextures.Gui_BoxScroll", Class'Engine.Texture'));
	m_TIcon = Texture(DynamicLoadObject("R6MenuTextures.TeamBarIcon", Class'Engine.Texture'));
	return;
}

//===================================================================
// Set the region for the accept and cancel(X) button
//===================================================================
function Button_SetupEnumSignChoice(UWindowButton W, int eRegionId)
{
	W.bUseRegion = true;
	W.UpTexture = m_R6ScrollTexture;
	W.DownTexture = m_R6ScrollTexture;
	W.OverTexture = m_R6ScrollTexture;
	W.DisabledTexture = m_R6ScrollTexture;
	W.UpRegion = m_RBAcceptCancel[eRegionId].Up;
	W.DownRegion = m_RBAcceptCancel[eRegionId].Down;
	W.OverRegion = m_RBAcceptCancel[eRegionId].Over;
	W.DisabledRegion = m_RBAcceptCancel[eRegionId].Disabled;
	return;
}

function Button_SetupMapList(UWindowButton W, bool _bInverseTex)
{
	local RegionButton RTemp;

	W.bUseRegion = true;
	W.UpTexture = m_R6ScrollTexture;
	W.DownTexture = m_R6ScrollTexture;
	W.OverTexture = m_R6ScrollTexture;
	W.DisabledTexture = m_R6ScrollTexture;
	// End:0xED
	if(_bInverseTex)
	{
		W.RegionScale = -1.0000000;
		W.UpRegion = m_RArrow[1].Up;
		W.DownRegion = m_RArrow[1].Down;
		W.OverRegion = m_RArrow[1].Over;
		W.DisabledRegion = m_RArrow[1].Disabled;		
	}
	else
	{
		W.RegionScale = 1.0000000;
		W.UpRegion = m_RArrow[0].Up;
		W.DownRegion = m_RArrow[0].Down;
		W.OverRegion = m_RArrow[0].Over;
		W.DisabledRegion = m_RArrow[0].Disabled;
	}
	return;
}

function Texture R6GetTexture(R6WindowFramedWindow W)
{
	// End:0x1B
	if(W.IsActive())
	{
		return Active;		
	}
	else
	{
		return Inactive;
	}
	return;
}

function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C)
{
	local Texture t;
	local Region R, temp;

	C.SetDrawColor(byte(255), byte(255), byte(255));
	t = W.GetLookAndFeelTexture();
	R = FrameTL;
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameT;
	W.DrawStretchedTextureSegment(C, float(FrameTL.W), 0.0000000, ((W.WinWidth - float(FrameTL.W)) - float(FrameTR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameTR;
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), 0.0000000, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0x1EB
	if(W.bStatusBar)
	{
		temp = m_FrameSBL;		
	}
	else
	{
		temp = FrameBL;
	}
	R = FrameL;
	W.DrawStretchedTextureSegment(C, 0.0000000, float(FrameTL.H), float(R.W), ((W.WinHeight - float(FrameTL.H)) - float(temp.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameR;
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), float(FrameTL.H), float(R.W), ((W.WinHeight - float(FrameTL.H)) - float(temp.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0x363
	if(W.bStatusBar)
	{
		R = m_FrameSBL;		
	}
	else
	{
		R = FrameBL;
	}
	W.DrawStretchedTextureSegment(C, 0.0000000, (W.WinHeight - float(R.H)), float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0x4B7
	if(W.bStatusBar)
	{
		R = m_FrameSB;
		W.DrawStretchedTextureSegment(C, float(FrameBL.W), (W.WinHeight - float(R.H)), ((W.WinWidth - float(m_FrameSBL.W)) - float(m_FrameSBR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);		
	}
	else
	{
		R = FrameB;
		W.DrawStretchedTextureSegment(C, float(FrameBL.W), (W.WinHeight - float(R.H)), ((W.WinWidth - float(FrameBL.W)) - float(FrameBR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	}
	// End:0x589
	if(W.bStatusBar)
	{
		R = m_FrameSBR;		
	}
	else
	{
		R = FrameBR;
	}
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), (W.WinHeight - float(R.H)), float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	C.Font = W.Root.Fonts[W.0];
	// End:0x6AC
	if((W.ParentWindow.ActiveWindow == W))
	{
		C.SetDrawColor(FrameActiveTitleColor.R, FrameActiveTitleColor.G, FrameActiveTitleColor.B);		
	}
	else
	{
		C.SetDrawColor(FrameInactiveTitleColor.R, FrameInactiveTitleColor.G, FrameInactiveTitleColor.B);
	}
	W.ClipTextWidth(C, float(FrameTitleX), float(FrameTitleY), W.WindowTitle, W.WinWidth);
	// End:0x799
	if(W.bStatusBar)
	{
		C.SetDrawColor(0, 0, 0);
		W.ClipTextWidth(C, 6.0000000, (W.WinHeight - float(13)), W.StatusBarText, W.WinWidth);
		C.SetDrawColor(byte(255), byte(255), byte(255));
	}
	return;
}

function R6FW_DrawWindowFrame(R6WindowFramedWindow W, Canvas C)
{
	local Texture t;
	local Region R;

	C.SetDrawColor(byte(255), byte(255), byte(255));
	t = W.GetLookAndFeelTexture();
	R = FrameTL;
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameT;
	W.DrawStretchedTextureSegment(C, float(FrameTL.W), 0.0000000, ((W.WinWidth - float(FrameTL.W)) - float(FrameTR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameTR;
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), 0.0000000, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameL;
	W.DrawStretchedTextureSegment(C, 0.0000000, float(FrameTL.H), float(R.W), ((W.WinHeight - float(FrameTL.H)) - float(FrameBL.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameR;
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), float(FrameTL.H), float(R.W), ((W.WinHeight - float(FrameTL.H)) - float(FrameBL.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameBL;
	W.DrawStretchedTextureSegment(C, 0.0000000, (W.WinHeight - float(R.H)), float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameB;
	W.DrawStretchedTextureSegment(C, float(FrameBL.W), (W.WinHeight - float(R.H)), ((W.WinWidth - float(FrameBL.W)) - float(FrameBR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameBR;
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), (W.WinHeight - float(R.H)), float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	C.Font = W.Root.Fonts[W.0];
	// End:0x57A
	if((W.ParentWindow.ActiveWindow == W))
	{
		C.SetDrawColor(FrameActiveTitleColor.R, FrameActiveTitleColor.G, FrameActiveTitleColor.B);		
	}
	else
	{
		C.SetDrawColor(FrameInactiveTitleColor.R, FrameInactiveTitleColor.G, FrameInactiveTitleColor.B);
	}
	W.ClipTextWidth(C, W.m_fTitleOffSet, float(FrameTitleY), W.m_szWindowTitle, W.WinWidth);
	return;
}

//======================================================================================
// Draw the pop-up frame
// IMPORTANT: the parameters for the window are set in R6WindowPopUpBox
//======================================================================================
function DrawPopUpFrameWindow(R6WindowPopUpBox W, Canvas C)
{
	local Texture TBackGround;
	local Color vBorderColor, vCornerColor;

	TBackGround = Texture'UWindow.WhiteTexture';
	C.Style = 5;
	// End:0x59
	if(W.m_bBGFullScreen)
	{
		W.Root.DrawBackGroundEffect(C, W.m_vFullBGColor);
	}
	// End:0x172
	if(W.m_bBGClientArea)
	{
		C.SetDrawColor(W.m_vClientAreaColor.R, W.m_vClientAreaColor.G, W.m_vClientAreaColor.B, W.m_vClientAreaColor.A);
		W.DrawStretchedTextureSegment(C, float((W.m_RWindowBorder.X + 2)), (W.m_pTextLabel.WinTop + float(1)), float((W.m_RWindowBorder.W - 4)), ((W.m_pTextLabel.WinHeight + float(W.m_RWindowBorder.H)) - float(2)), 0.0000000, 0.0000000, 10.0000000, 10.0000000, TBackGround);
	}
	// End:0x7FE
	if((!W.m_bNoBorderToDraw))
	{
		// End:0x324
		if(W.m_sBorderForm[int(W.0)].bActive)
		{
			// End:0x22A
			if(W.m_sBorderForm[int(W.0)].vColor != vBorderColor)
			{
				vBorderColor = W.m_sBorderForm[int(W.0)].vColor;
				C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
			}
			W.DrawStretchedTextureSegment(C, W.m_sBorderForm[int(W.0)].fXPos, W.m_sBorderForm[int(W.0)].fYPos, W.m_sBorderForm[int(W.0)].fWidth, W.m_sBorderForm[int(W.0)].fHeight, float(W.m_HBorderTextureRegion.X), float(W.m_HBorderTextureRegion.Y), float(W.m_HBorderTextureRegion.W), float(W.m_HBorderTextureRegion.H), W.m_HBorderTexture);
		}
		// End:0x4C2
		if(W.m_sBorderForm[int(W.1)].bActive)
		{
			// End:0x3C8
			if(W.m_sBorderForm[int(W.1)].vColor != vBorderColor)
			{
				vBorderColor = W.m_sBorderForm[int(W.1)].vColor;
				C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
			}
			W.DrawStretchedTextureSegment(C, W.m_sBorderForm[int(W.1)].fXPos, W.m_sBorderForm[int(W.1)].fYPos, W.m_sBorderForm[int(W.1)].fWidth, W.m_sBorderForm[int(W.1)].fHeight, float(W.m_HBorderTextureRegion.X), float(W.m_HBorderTextureRegion.Y), float(W.m_HBorderTextureRegion.W), float(W.m_HBorderTextureRegion.H), W.m_HBorderTexture);
		}
		// End:0x660
		if(W.m_sBorderForm[int(W.2)].bActive)
		{
			// End:0x566
			if(W.m_sBorderForm[int(W.2)].vColor != vBorderColor)
			{
				vBorderColor = W.m_sBorderForm[int(W.2)].vColor;
				C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
			}
			W.DrawStretchedTextureSegment(C, W.m_sBorderForm[int(W.2)].fXPos, W.m_sBorderForm[int(W.2)].fYPos, W.m_sBorderForm[int(W.2)].fWidth, W.m_sBorderForm[int(W.2)].fHeight, float(W.m_VBorderTextureRegion.X), float(W.m_VBorderTextureRegion.Y), float(W.m_VBorderTextureRegion.W), float(W.m_VBorderTextureRegion.H), W.m_VBorderTexture);
		}
		// End:0x7FE
		if(W.m_sBorderForm[int(W.3)].bActive)
		{
			// End:0x704
			if(W.m_sBorderForm[int(W.3)].vColor != vBorderColor)
			{
				vBorderColor = W.m_sBorderForm[int(W.3)].vColor;
				C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
			}
			W.DrawStretchedTextureSegment(C, W.m_sBorderForm[int(W.3)].fXPos, W.m_sBorderForm[int(W.3)].fYPos, W.m_sBorderForm[int(W.3)].fWidth, W.m_sBorderForm[int(W.3)].fHeight, float(W.m_VBorderTextureRegion.X), float(W.m_VBorderTextureRegion.Y), float(W.m_VBorderTextureRegion.W), float(W.m_VBorderTextureRegion.H), W.m_VBorderTexture);
		}
	}
	vCornerColor.R = 0;
	vCornerColor.G = 0;
	vCornerColor.B = 0;
	// End:0xE23
	if((int(W.m_eCornerType) != int(0)))
	{
		switch(W.m_eCornerType)
		{
			// End:0x8C8
			case 3:
				// End:0x8C8
				if(W.m_eCornerColor[int(W.3)] != vCornerColor)
				{
					vCornerColor = W.m_eCornerColor[int(W.3)];
					C.SetDrawColor(vCornerColor.R, vCornerColor.G, vCornerColor.B);
				}
			// End:0xB3E
			case 1:
				// End:0x942
				if(W.m_eCornerColor[int(W.1)] != vCornerColor)
				{
					vCornerColor = W.m_eCornerColor[int(W.1)];
					C.SetDrawColor(vCornerColor.R, vCornerColor.G, vCornerColor.B);
				}
				// End:0xB22
				if((W.m_topLeftCornerT != none))
				{
					W.DrawStretchedTextureSegment(C, float(W.m_RWindowBorder.X), float(W.m_RWindowBorder.Y), float(W.m_topLeftCornerR.W), float(W.m_topLeftCornerR.H), float(W.m_topLeftCornerR.X), float(W.m_topLeftCornerR.Y), float(W.m_topLeftCornerR.W), float(W.m_topLeftCornerR.H), W.m_topLeftCornerT);
					W.DrawStretchedTextureSegment(C, float(((W.m_RWindowBorder.X + W.m_RWindowBorder.W) - m_topLeftCornerR.W)), float(W.m_RWindowBorder.Y), float(W.m_topLeftCornerR.W), float(W.m_topLeftCornerR.H), float((W.m_topLeftCornerR.X + W.m_topLeftCornerR.W)), float(W.m_topLeftCornerR.Y), float((-W.m_topLeftCornerR.W)), float(W.m_topLeftCornerR.H), W.m_topLeftCornerT);
				}
				// End:0xB3E
				if(__NFUN_155__(int(W.m_eCornerType), int(3)))
				{
					// End:0xE23
					break;
				}
			// End:0xE1D
			case 2:
				// End:0xBB8
				if(W.m_eCornerColor[int(W.2)] != vCornerColor)
				{
					vCornerColor = W.m_eCornerColor[int(W.2)];
					C.__NFUN_2626__(vCornerColor.R, vCornerColor.G, vCornerColor.B);
				}
				// End:0xE1A
				if(__NFUN_119__(W.m_topLeftCornerT, none))
				{
					W.DrawStretchedTextureSegment(C, float(W.m_RWindowBorder.X), float(__NFUN_147__(__NFUN_146__(W.m_RWindowBorder.Y, W.m_RWindowBorder.H), m_topLeftCornerR.H)), float(W.m_topLeftCornerR.W), float(W.m_topLeftCornerR.H), float(W.m_topLeftCornerR.X), float(__NFUN_146__(W.m_topLeftCornerR.Y, W.m_topLeftCornerR.H)), float(W.m_topLeftCornerR.W), float(__NFUN_143__(W.m_topLeftCornerR.H)), W.m_topLeftCornerT);
					W.DrawStretchedTextureSegment(C, float(__NFUN_147__(__NFUN_146__(W.m_RWindowBorder.X, W.m_RWindowBorder.W), W.m_topLeftCornerR.W)), float(__NFUN_147__(__NFUN_146__(W.m_RWindowBorder.Y, W.m_RWindowBorder.H), W.m_topLeftCornerR.H)), float(W.m_topLeftCornerR.W), float(W.m_topLeftCornerR.H), float(__NFUN_146__(W.m_topLeftCornerR.X, W.m_topLeftCornerR.W)), float(__NFUN_146__(W.m_topLeftCornerR.Y, W.m_topLeftCornerR.H)), float(__NFUN_143__(W.m_topLeftCornerR.W)), float(__NFUN_143__(W.m_topLeftCornerR.H)), W.m_topLeftCornerT);
				}
				// End:0xE23
				break;
			// End:0xFFFF
			default:
				// End:0xE23
				break;
				break;
		}
	}
	return;
}

function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.CloseBox.WinLeft = __NFUN_175__(__NFUN_175__(W.WinWidth, float(m_iCloseBoxOffsetX)), float(m_CloseBoxUp.W));
	W.CloseBox.WinTop = float(m_iCloseBoxOffsetY);
	W.CloseBox.SetSize(float(m_CloseBoxUp.W), float(m_CloseBoxUp.H));
	W.CloseBox.bUseRegion = true;
	W.CloseBox.UpTexture = t;
	W.CloseBox.DownTexture = t;
	W.CloseBox.OverTexture = t;
	W.CloseBox.DisabledTexture = t;
	W.CloseBox.UpRegion = m_CloseBoxUp;
	W.CloseBox.DownRegion = m_CloseBoxDown;
	W.CloseBox.OverRegion = m_CloseBoxUp;
	W.CloseBox.DisabledRegion = m_CloseBoxUp;
	return;
}

function R6FW_SetupFrameButtons(R6WindowFramedWindow W, Canvas C)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.m_CloseBoxButton.SetSize(float(m_CloseBoxUp.W), float(m_CloseBoxUp.H));
	W.m_CloseBoxButton.bUseRegion = true;
	W.m_CloseBoxButton.UpTexture = t;
	W.m_CloseBoxButton.DownTexture = t;
	W.m_CloseBoxButton.OverTexture = t;
	W.m_CloseBoxButton.DisabledTexture = t;
	W.m_CloseBoxButton.UpRegion = m_CloseBoxUp;
	W.m_CloseBoxButton.DownRegion = m_CloseBoxDown;
	W.m_CloseBoxButton.OverRegion = m_CloseBoxUp;
	W.m_CloseBoxButton.DisabledRegion = m_CloseBoxUp;
	return;
}

function Region FW_GetClientArea(UWindowFramedWindow W)
{
	local Region R;

	R.X = FrameL.W;
	R.Y = FrameT.H;
	R.W = int(__NFUN_175__(W.WinWidth, float(__NFUN_146__(FrameL.W, FrameR.W))));
	// End:0xA9
	if(W.bStatusBar)
	{
		R.H = int(__NFUN_175__(W.WinHeight, float(__NFUN_146__(FrameT.H, m_FrameSB.H))));		
	}
	else
	{
		R.H = int(__NFUN_175__(W.WinHeight, float(__NFUN_146__(FrameT.H, FrameB.H))));
	}
	return R;
	return;
}

function Region R6FW_GetClientArea(R6WindowFramedWindow W)
{
	local Region R;

	R.X = FrameL.W;
	R.Y = FrameT.H;
	R.W = int(__NFUN_175__(W.WinWidth, float(__NFUN_146__(FrameL.W, FrameR.W))));
	R.H = int(__NFUN_175__(W.WinHeight, float(__NFUN_146__(FrameT.H, FrameB.H))));
	return R;
	return;
}

function UWindowBase.FrameHitTest FW_HitTest(UWindowFramedWindow W, float X, float Y)
{
	// End:0x51
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_179__(X, float(3)), __NFUN_178__(X, __NFUN_175__(W.WinWidth, float(3)))), __NFUN_179__(Y, float(3))), __NFUN_178__(Y, float(14))))
	{
		return 8;
	}
	// End:0x92
	if(__NFUN_132__(__NFUN_130__(__NFUN_176__(X, float(15)), __NFUN_176__(Y, float(3))), __NFUN_130__(__NFUN_176__(X, float(3)), __NFUN_176__(Y, float(15)))))
	{
		return 0;
	}
	// End:0xF3
	if(__NFUN_132__(__NFUN_130__(__NFUN_177__(X, __NFUN_175__(W.WinWidth, float(3))), __NFUN_176__(Y, float(15))), __NFUN_130__(__NFUN_177__(X, __NFUN_175__(W.WinWidth, float(15))), __NFUN_176__(Y, float(3)))))
	{
		return 2;
	}
	// End:0x154
	if(__NFUN_132__(__NFUN_130__(__NFUN_176__(X, float(15)), __NFUN_177__(Y, __NFUN_175__(W.WinHeight, float(3)))), __NFUN_130__(__NFUN_176__(X, float(3)), __NFUN_177__(Y, __NFUN_175__(W.WinHeight, float(15))))))
	{
		return 5;
	}
	// End:0x195
	if(__NFUN_130__(__NFUN_177__(X, __NFUN_175__(W.WinWidth, float(15))), __NFUN_177__(Y, __NFUN_175__(W.WinHeight, float(15)))))
	{
		return 7;
	}
	// End:0x1A6
	if(__NFUN_176__(Y, float(3)))
	{
		return 1;
	}
	// End:0x1C7
	if(__NFUN_177__(Y, __NFUN_175__(W.WinHeight, float(3))))
	{
		return 6;
	}
	// End:0x1D8
	if(__NFUN_176__(X, float(3)))
	{
		return 3;
	}
	// End:0x1F9
	if(__NFUN_177__(X, __NFUN_175__(W.WinWidth, float(3))))
	{
		return 4;
	}
	return 10;
	return;
}

function UWindowBase.FrameHitTest R6FW_HitTest(R6WindowFramedWindow W, float X, float Y)
{
	// End:0x51
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_179__(X, float(3)), __NFUN_178__(X, __NFUN_175__(W.WinWidth, float(3)))), __NFUN_179__(Y, float(3))), __NFUN_178__(Y, float(14))))
	{
		return 8;
	}
	// End:0x92
	if(__NFUN_132__(__NFUN_130__(__NFUN_176__(X, float(15)), __NFUN_176__(Y, float(3))), __NFUN_130__(__NFUN_176__(X, float(3)), __NFUN_176__(Y, float(15)))))
	{
		return 0;
	}
	// End:0xF3
	if(__NFUN_132__(__NFUN_130__(__NFUN_177__(X, __NFUN_175__(W.WinWidth, float(3))), __NFUN_176__(Y, float(15))), __NFUN_130__(__NFUN_177__(X, __NFUN_175__(W.WinWidth, float(15))), __NFUN_176__(Y, float(3)))))
	{
		return 2;
	}
	// End:0x154
	if(__NFUN_132__(__NFUN_130__(__NFUN_176__(X, float(15)), __NFUN_177__(Y, __NFUN_175__(W.WinHeight, float(3)))), __NFUN_130__(__NFUN_176__(X, float(3)), __NFUN_177__(Y, __NFUN_175__(W.WinHeight, float(15))))))
	{
		return 5;
	}
	// End:0x195
	if(__NFUN_130__(__NFUN_177__(X, __NFUN_175__(W.WinWidth, float(15))), __NFUN_177__(Y, __NFUN_175__(W.WinHeight, float(15)))))
	{
		return 7;
	}
	// End:0x1A6
	if(__NFUN_176__(Y, float(3)))
	{
		return 1;
	}
	// End:0x1C7
	if(__NFUN_177__(Y, __NFUN_175__(W.WinHeight, float(3))))
	{
		return 6;
	}
	// End:0x1D8
	if(__NFUN_176__(X, float(3)))
	{
		return 3;
	}
	// End:0x1F9
	if(__NFUN_177__(X, __NFUN_175__(W.WinWidth, float(3))))
	{
		return 4;
	}
	return 10;
	return;
}

// ****** Client Area Drawing Functions *******
function DrawClientArea(UWindowClientWindow W, Canvas C)
{
	W.DrawStretchedTexture(C, 0.0000000, 0.0000000, W.WinWidth, W.WinHeight, Texture'UWindow.BlackTexture');
	return;
}

// ****** Combo Drawing Functions ******
function Combo_SetupSizes(UWindowComboControl W, Canvas C)
{
	local float fTW, fTH;

	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, fTW, fTH);
	switch(W.Align)
	{
		// End:0xBB
		case 0:
			W.EditAreaDrawX = __NFUN_175__(W.WinWidth, W.EditBoxWidth);
			W.TextX = 0.0000000;
			// End:0x163
			break;
		// End:0xFB
		case 1:
			W.EditAreaDrawX = 0.0000000;
			W.TextX = __NFUN_175__(W.WinWidth, fTW);
			// End:0x163
			break;
		// End:0x160
		case 2:
			W.EditAreaDrawX = __NFUN_172__(__NFUN_175__(W.WinWidth, W.EditBoxWidth), float(2));
			W.TextX = __NFUN_172__(__NFUN_175__(W.WinWidth, fTW), float(2));
			// End:0x163
			break;
		// End:0xFFFF
		default:
			break;
	}
	W.EditAreaDrawY = __NFUN_172__(__NFUN_175__(W.WinHeight, float(2)), float(2));
	W.TextY = __NFUN_172__(__NFUN_175__(W.WinHeight, fTH), float(2));
	W.EditBox.WinLeft = __NFUN_174__(W.EditAreaDrawX, float(MiscBevelL[2].W));
	W.EditBox.WinTop = float(MiscBevelT[2].H);
	W.Button.WinWidth = float(ComboBtnUp.W);
	// End:0x554
	if(W.bButtons)
	{
		W.EditBox.WinWidth = __NFUN_175__(__NFUN_175__(__NFUN_175__(__NFUN_175__(__NFUN_175__(W.EditBoxWidth, float(MiscBevelL[2].W)), float(MiscBevelR[2].W)), float(ComboBtnUp.W)), float(m_SBLeft.Up.W)), float(m_SBRight.Up.W));
		W.EditBox.WinHeight = __NFUN_175__(__NFUN_175__(W.WinHeight, float(MiscBevelT[2].H)), float(MiscBevelB[2].H));
		W.Button.WinLeft = __NFUN_175__(__NFUN_175__(__NFUN_175__(__NFUN_175__(W.WinWidth, float(ComboBtnUp.W)), float(MiscBevelR[2].W)), float(m_SBLeft.Up.W)), float(m_SBRight.Up.W));
		W.Button.WinTop = W.EditBox.WinTop;
		W.LeftButton.WinLeft = __NFUN_175__(__NFUN_175__(__NFUN_175__(W.WinWidth, float(MiscBevelR[2].W)), float(m_SBLeft.Up.W)), float(m_SBRight.Up.W));
		W.LeftButton.WinTop = W.EditBox.WinTop;
		W.RightButton.WinLeft = __NFUN_175__(__NFUN_175__(W.WinWidth, float(MiscBevelR[2].W)), float(m_SBRight.Up.W));
		W.RightButton.WinTop = W.EditBox.WinTop;
		W.LeftButton.WinWidth = float(m_SBLeft.Up.W);
		W.LeftButton.WinHeight = float(m_SBLeft.Up.H);
		W.RightButton.WinWidth = float(m_SBRight.Up.W);
		W.RightButton.WinHeight = float(m_SBRight.Up.H);		
	}
	else
	{
		W.EditBox.WinWidth = __NFUN_175__(__NFUN_175__(__NFUN_175__(W.EditBoxWidth, float(MiscBevelL[2].W)), float(MiscBevelR[2].W)), float(ComboBtnUp.W));
		W.EditBox.WinHeight = __NFUN_175__(__NFUN_175__(W.WinHeight, float(MiscBevelT[2].H)), float(MiscBevelB[2].H));
		W.Button.WinLeft = __NFUN_175__(__NFUN_175__(W.WinWidth, float(ComboBtnUp.W)), float(MiscBevelR[2].W));
		W.Button.WinTop = W.EditBox.WinTop;
	}
	W.Button.WinHeight = W.EditBox.WinHeight;
	return;
}

function Combo_Draw(UWindowComboControl W, Canvas C)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	C.Style = 5;
	C.__NFUN_2626__(120, 120, 120);
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, W.WinWidth, float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	W.DrawStretchedTextureSegment(C, 0.0000000, __NFUN_175__(W.WinHeight, float(W.m_BorderTextureRegion.H)), W.WinWidth, float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	W.DrawStretchedTextureSegment(C, 0.0000000, float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.W), __NFUN_175__(W.WinHeight, float(__NFUN_144__(2, W.m_BorderTextureRegion.H))), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(W.m_BorderTextureRegion.W)), float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.W), __NFUN_175__(W.WinHeight, float(__NFUN_144__(2, W.m_BorderTextureRegion.H))), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	// End:0x3F2
	if(__NFUN_123__(W.Text, ""))
	{
		C.__NFUN_2626__(W.TextColor.R, W.TextColor.G, W.TextColor.B);
		W.ClipText(C, W.TextX, W.TextY, W.Text);
	}
	return;
}

function R6List_DrawBackground(R6WindowListBox W, Canvas C)
{
	local Texture t;

	t = m_R6ScrollTexture;
	C.__NFUN_2626__(W.m_BorderColor.R, W.m_BorderColor.G, W.m_BorderColor.B);
	C.Style = 5;
	switch(W.m_eCornerType)
	{
		// End:0x8D
		case 0:
			W.DrawSimpleBorder(C);
			// End:0xEFF
			break;
		// End:0x4CD
		case 2:
			W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(m_topLeftCornerR.Y), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), m_R6ScrollTexture);
			W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(m_topLeftCornerR.W)), 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(__NFUN_146__(m_topLeftCornerR.X, m_topLeftCornerR.W)), float(m_topLeftCornerR.Y), float(__NFUN_143__(m_topLeftCornerR.W)), float(m_topLeftCornerR.H), m_R6ScrollTexture);
			W.DrawStretchedTextureSegment(C, float(__NFUN_146__(m_topLeftCornerR.W, m_iListHPadding)), 0.0000000, __NFUN_175__(__NFUN_175__(W.WinWidth, float(__NFUN_144__(2, m_iListHPadding))), float(__NFUN_144__(2, m_topLeftCornerR.W))), float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			W.DrawStretchedTextureSegment(C, float(m_iListVPadding), __NFUN_175__(W.WinHeight, float(W.m_BorderTextureRegion.H)), __NFUN_175__(W.WinWidth, float(__NFUN_144__(2, m_iListVPadding))), float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			W.DrawStretchedTextureSegment(C, float(m_iListVPadding), float(m_topLeftCornerR.H), float(W.m_BorderTextureRegion.W), __NFUN_175__(W.WinHeight, float(m_topLeftCornerR.H)), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			W.DrawStretchedTextureSegment(C, __NFUN_175__(__NFUN_175__(W.WinWidth, float(W.m_BorderTextureRegion.W)), float(m_iListVPadding)), float(m_topLeftCornerR.H), float(W.m_BorderTextureRegion.W), __NFUN_175__(W.WinHeight, float(m_topLeftCornerR.H)), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			// End:0xEFF
			break;
		// End:0x949
		case 3:
			W.DrawStretchedTextureSegment(C, 0.0000000, __NFUN_175__(W.WinHeight, float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(__NFUN_146__(m_topLeftCornerR.Y, m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(__NFUN_143__(m_topLeftCornerR.H)), m_R6ScrollTexture);
			W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(m_topLeftCornerR.W)), __NFUN_175__(W.WinHeight, float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(__NFUN_146__(m_topLeftCornerR.X, m_topLeftCornerR.W)), float(__NFUN_146__(m_topLeftCornerR.Y, m_topLeftCornerR.H)), float(__NFUN_143__(m_topLeftCornerR.W)), float(__NFUN_143__(m_topLeftCornerR.H)), m_R6ScrollTexture);
			W.DrawStretchedTextureSegment(C, float(m_iListVPadding), 0.0000000, __NFUN_175__(W.WinWidth, float(__NFUN_144__(2, m_iListVPadding))), float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			W.DrawStretchedTextureSegment(C, float(__NFUN_146__(m_topLeftCornerR.W, m_iListHPadding)), __NFUN_175__(W.WinHeight, float(W.m_BorderTextureRegion.H)), __NFUN_175__(__NFUN_175__(W.WinWidth, float(__NFUN_144__(2, m_iListHPadding))), float(__NFUN_144__(2, m_topLeftCornerR.W))), float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			W.DrawStretchedTextureSegment(C, float(m_iListVPadding), 0.0000000, float(W.m_BorderTextureRegion.W), __NFUN_175__(W.WinHeight, float(m_topLeftCornerR.H)), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			W.DrawStretchedTextureSegment(C, __NFUN_175__(__NFUN_175__(W.WinWidth, float(W.m_BorderTextureRegion.W)), float(m_iListVPadding)), 0.0000000, float(W.m_BorderTextureRegion.W), __NFUN_175__(W.WinHeight, float(m_topLeftCornerR.H)), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			// End:0xEFF
			break;
		// End:0xEF4
		case 4:
			W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(m_topLeftCornerR.Y), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), m_R6ScrollTexture);
			W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(m_topLeftCornerR.W)), 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(__NFUN_146__(m_topLeftCornerR.X, m_topLeftCornerR.W)), float(m_topLeftCornerR.Y), float(__NFUN_143__(m_topLeftCornerR.W)), float(m_topLeftCornerR.H), m_R6ScrollTexture);
			W.DrawStretchedTextureSegment(C, 0.0000000, __NFUN_175__(W.WinHeight, float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(__NFUN_146__(m_topLeftCornerR.Y, m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(__NFUN_143__(m_topLeftCornerR.H)), m_R6ScrollTexture);
			W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(m_topLeftCornerR.W)), __NFUN_175__(W.WinHeight, float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(__NFUN_146__(m_topLeftCornerR.X, m_topLeftCornerR.W)), float(__NFUN_146__(m_topLeftCornerR.Y, m_topLeftCornerR.H)), float(__NFUN_143__(m_topLeftCornerR.W)), float(__NFUN_143__(m_topLeftCornerR.H)), m_R6ScrollTexture);
			W.DrawStretchedTextureSegment(C, float(__NFUN_146__(m_topLeftCornerR.W, m_iListHPadding)), 0.0000000, __NFUN_175__(__NFUN_175__(W.WinWidth, float(__NFUN_144__(2, m_iListHPadding))), float(__NFUN_144__(2, m_topLeftCornerR.W))), float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			W.DrawStretchedTextureSegment(C, float(__NFUN_146__(m_topLeftCornerR.W, m_iListHPadding)), __NFUN_175__(W.WinHeight, float(W.m_BorderTextureRegion.H)), __NFUN_175__(__NFUN_175__(W.WinWidth, float(__NFUN_144__(2, m_iListHPadding))), float(__NFUN_144__(2, m_topLeftCornerR.W))), float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			W.DrawStretchedTextureSegment(C, float(m_iListVPadding), float(m_topLeftCornerR.H), float(W.m_BorderTextureRegion.W), __NFUN_175__(W.WinHeight, float(__NFUN_144__(2, m_topLeftCornerR.H))), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			W.DrawStretchedTextureSegment(C, __NFUN_175__(__NFUN_175__(W.WinWidth, float(W.m_BorderTextureRegion.W)), float(m_iListVPadding)), float(m_topLeftCornerR.H), float(W.m_BorderTextureRegion.W), __NFUN_175__(W.WinHeight, float(__NFUN_144__(2, m_topLeftCornerR.H))), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
			// End:0xEFF
			break;
		// End:0xEFC
		case 1:
			// End:0xEFF
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function List_DrawBackground(UWindowListControl W, Canvas C)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.DrawUpBevel(C, 0.0000000, 0.0000000, W.WinWidth, W.WinHeight, Active);
	return;
}

//=================================================================================
// This is draw the border of a combo list item
//=================================================================================
function ComboList_DrawBackground(UWindowComboList W, Canvas C)
{
	W.DrawSimpleBorder(C);
	return;
}

//=================================================================================
// This is draw a combo list item
//=================================================================================
function ComboList_DrawItem(UWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected)
{
	local Texture t;

	t = Combo.GetLookAndFeelTexture();
	// End:0x8C
	if(bSelected)
	{
		C.__NFUN_2626__(0, 0, 0);
		Combo.DrawStretchedTextureSegment(C, X, Y, W, H, 4.0000000, 16.0000000, 1.0000000, 1.0000000, t);
		C.__NFUN_2626__(byte(255), byte(255), byte(255));		
	}
	else
	{
		C.__NFUN_2626__(22, 22, 22);
		Combo.DrawStretchedTextureSegment(C, X, Y, W, H, 4.0000000, 16.0000000, 1.0000000, 1.0000000, t);
		C.__NFUN_2626__(15, 136, 176);
	}
	Combo.ClipText(C, __NFUN_174__(__NFUN_174__(X, float(Combo.TextBorder)), float(2)), __NFUN_174__(Y, float(3)), Text);
	return;
}

function Combo_SetupButton(UWindowComboButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = Texture'R6MenuTextures.Gui_BoxScroll';
	W.DownTexture = Texture'R6MenuTextures.Gui_BoxScroll';
	W.OverTexture = Texture'R6MenuTextures.Gui_BoxScroll';
	W.DisabledTexture = Texture'R6MenuTextures.Gui_BoxScroll';
	W.UpRegion = ComboBtnUp;
	W.DownRegion = ComboBtnDown;
	W.OverRegion = ComboBtnOver;
	W.DisabledRegion = ComboBtnDisabled;
	W.ImageX = float(m_fComboImageX);
	W.ImageY = float(m_fComboImageY);
	return;
}

function Editbox_SetupSizes(UWindowEditControl W, Canvas C)
{
	local float fTW, fTH;
	local int B;

	B = EditBoxBevel;
	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, fTW, fTH);
	W.WinHeight = __NFUN_174__(__NFUN_174__(12.0000000, float(MiscBevelT[B].H)), float(MiscBevelB[B].H));
	switch(W.Align)
	{
		// End:0x102
		case 0:
			W.EditAreaDrawX = __NFUN_175__(W.WinWidth, W.EditBoxWidth);
			W.TextX = 0.0000000;
			// End:0x19E
			break;
		// End:0x142
		case 1:
			W.EditAreaDrawX = 0.0000000;
			W.TextX = __NFUN_175__(W.WinWidth, fTW);
			// End:0x19E
			break;
		// End:0x19B
		case 2:
			W.EditAreaDrawX = __NFUN_175__(W.WinWidth, W.EditBoxWidth);
			W.TextX = __NFUN_175__(W.WinWidth, fTW);
			// End:0x19E
			break;
		// End:0xFFFF
		default:
			break;
	}
	W.EditAreaDrawY = __NFUN_175__(W.WinHeight, float(2));
	W.TextY = __NFUN_175__(W.WinHeight, fTH);
	W.EditBox.WinLeft = __NFUN_174__(W.EditAreaDrawX, float(MiscBevelL[B].W));
	W.EditBox.WinTop = float(MiscBevelT[B].H);
	W.EditBox.WinWidth = __NFUN_175__(__NFUN_175__(W.EditBoxWidth, float(MiscBevelL[B].W)), float(MiscBevelR[B].W));
	W.EditBox.WinHeight = __NFUN_175__(__NFUN_175__(W.WinHeight, float(MiscBevelT[B].H)), float(MiscBevelB[B].H));
	return;
}

function Editbox_Draw(UWindowEditControl W, Canvas C)
{
	W.DrawMiscBevel(C, W.EditAreaDrawX, 0.0000000, W.EditBoxWidth, W.WinHeight, Active, EditBoxBevel);
	return;
}

function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText)
{
	local Region R, Temp_RTabLeft, Temp_RTabRight;
	local string szText;
	local float fTW, fTH, fXOffset;

	fXOffset = Size_TabTextOffset;
	C.Style = 5;
	szText = Text;
	// End:0x39D
	if(bActiveTab)
	{
		C.__NFUN_2626__(Tab.m_vEffectColor.R, Tab.m_vEffectColor.G, Tab.m_vEffectColor.B);
		// End:0x102
		if(Tab.m_bDisplayToolTip)
		{
			C.__NFUN_2626__(Tab.Root.Colors.BlueLight.R, Tab.Root.Colors.BlueLight.G, Tab.Root.Colors.BlueLight.B);
		}
		R = TabSelectedL;
		Tab.DrawStretchedTextureSegment(C, X, Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), m_R6ScrollTexture);
		R = TabSelectedM;
		Tab.DrawStretchedTextureSegment(C, __NFUN_174__(X, float(TabSelectedL.W)), Y, __NFUN_175__(__NFUN_175__(W, float(TabSelectedL.W)), float(TabSelectedR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), m_R6ScrollTexture);
		R = TabSelectedR;
		Tab.DrawStretchedTextureSegment(C, __NFUN_175__(__NFUN_174__(X, W), float(R.W)), Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), m_R6ScrollTexture);
		// End:0x39A
		if(bShowText)
		{
			C.Style = 1;
			C.Font = Tab.Root.Fonts[7];
			C.SpaceX = 0.0000000;
			szText = Tab.TextSize(C, szText, fTW, fTH, int(__NFUN_175__(__NFUN_175__(W, fXOffset), float(TabSelectedR.W))));
			Y = __NFUN_172__(__NFUN_175__(Tab.WinHeight, fTH), float(2));
			Y = float(int(__NFUN_174__(Y, 0.5000000)));
			Tab.ClipText(C, __NFUN_174__(X, fXOffset), Y, szText, true);
		}		
	}
	else
	{
		switch(Tab.m_eTabCase)
		{
			// End:0x3D4
			case Tab.0:
				Temp_RTabLeft = TabSelectedL;
				Temp_RTabRight = TabSelectedR;
				// End:0x465
				break;
			// End:0x3FB
			case Tab.3:
				Temp_RTabLeft = TabSelectedL;
				Temp_RTabRight = TabUnselectedR;
				// End:0x465
				break;
			// End:0x422
			case Tab.1:
				Temp_RTabLeft = TabUnselectedL;
				Temp_RTabRight = TabSelectedR;
				// End:0x465
				break;
			// End:0x449
			case Tab.4:
				Temp_RTabLeft = TabUnselectedL;
				Temp_RTabRight = TabUnselectedR;
				// End:0x465
				break;
			// End:0xFFFF
			default:
				Temp_RTabLeft = TabUnselectedL;
				Temp_RTabRight = TabSelectedR;
				// End:0x465
				break;
				break;
		}
		C.__NFUN_2626__(Tab.m_vEffectColor.R, Tab.m_vEffectColor.G, Tab.m_vEffectColor.B);
		// End:0x537
		if(Tab.m_bDisplayToolTip)
		{
			C.__NFUN_2626__(Tab.Root.Colors.BlueLight.R, Tab.Root.Colors.BlueLight.G, Tab.Root.Colors.BlueLight.B);
		}
		R = Temp_RTabLeft;
		Tab.DrawStretchedTextureSegment(C, X, Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), m_R6ScrollTexture);
		R = TabSelectedM;
		Tab.DrawStretchedTextureSegment(C, __NFUN_174__(X, float(TabSelectedL.W)), Y, __NFUN_175__(__NFUN_175__(W, float(TabSelectedL.W)), float(TabSelectedR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), m_R6ScrollTexture);
		R = Temp_RTabRight;
		Tab.DrawStretchedTextureSegment(C, __NFUN_175__(__NFUN_174__(X, W), float(R.W)), Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), m_R6ScrollTexture);
		// End:0x7CF
		if(bShowText)
		{
			C.Style = 1;
			C.Font = Tab.Root.Fonts[7];
			C.SpaceX = 0.0000000;
			szText = Tab.TextSize(C, szText, fTW, fTH, int(__NFUN_175__(__NFUN_175__(W, fXOffset), float(TabSelectedR.W))));
			Y = __NFUN_172__(__NFUN_175__(Tab.WinHeight, fTH), float(2));
			Y = float(int(__NFUN_174__(Y, 0.5000000)));
			Tab.ClipText(C, __NFUN_174__(X, fXOffset), Y, szText, true);
		}
	}
	return;
}

// ****** Scroll Bar ******
function SB_SetupUpButton(UWindowSBUpButton W)
{
	local Texture t;

	t = m_R6ScrollTexture;
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	// End:0xA6
	if(__NFUN_242__(UWindowVScrollbar(W.OwnerWindow).m_bUseSpecialEffect, true))
	{
		W.UpRegion = m_SBUpGear;		
	}
	else
	{
		W.UpRegion = m_SBUp.Up;
	}
	W.DownRegion = m_SBUp.Down;
	W.OverRegion = m_SBUp.Over;
	W.DisabledRegion = m_SBUp.Disabled;
	W.m_bDrawButtonBorders = true;
	W.ImageX = float(m_fVSBButtonImageX);
	W.ImageY = float(m_fVSBButtonImageY);
	return;
}

function SB_SetupDownButton(UWindowSBDownButton W)
{
	local Texture t;

	t = m_R6ScrollTexture;
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	// End:0xA6
	if(__NFUN_242__(UWindowVScrollbar(W.OwnerWindow).m_bUseSpecialEffect, true))
	{
		W.UpRegion = m_SBDownGear;		
	}
	else
	{
		W.UpRegion = m_SBDown.Up;
	}
	W.DownRegion = m_SBDown.Down;
	W.OverRegion = m_SBDown.Over;
	W.DisabledRegion = m_SBDown.Disabled;
	W.m_bDrawButtonBorders = true;
	W.ImageX = float(m_fVSBButtonImageX);
	W.ImageY = float(m_fVSBButtonImageY);
	return;
}

function SB_SetupLeftButton(UWindowSBLeftButton W)
{
	local Texture t;

	t = m_R6ScrollTexture;
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = m_SBLeft.Up;
	W.DownRegion = m_SBLeft.Down;
	W.OverRegion = m_SBLeft.Up;
	W.DisabledRegion = m_SBLeft.Disabled;
	W.m_bDrawButtonBorders = true;
	W.ImageX = float(m_fHSBButtonImageX);
	W.ImageY = float(m_fHSBButtonImageY);
	return;
}

function SB_SetupRightButton(UWindowSBRightButton W)
{
	local Texture t;

	t = m_R6ScrollTexture;
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = m_SBRight.Up;
	W.DownRegion = m_SBRight.Down;
	W.OverRegion = m_SBRight.Up;
	W.DisabledRegion = m_SBRight.Disabled;
	W.m_bDrawButtonBorders = true;
	W.ImageX = float(m_fHSBButtonImageX);
	W.ImageY = float(m_fHSBButtonImageY);
	return;
}

function SB_VDraw(UWindowVScrollbar W, Canvas C)
{
	local int BoxHeight;

	BoxHeight = int(__NFUN_174__(__NFUN_174__(__NFUN_175__(__NFUN_175__(W.WinHeight, W.UpButton.WinHeight), W.DownButton.WinHeight), float(W.UpButton.m_BorderTextureRegion.H)), float(W.DownButton.m_BorderTextureRegion.H)));
	C.__NFUN_2626__(W.m_BorderColor.R, W.m_BorderColor.G, W.m_BorderColor.B);
	DrawBox(W, C, 0.0000000, __NFUN_175__(W.UpButton.WinHeight, float(W.UpButton.m_BorderTextureRegion.H)), W.WinWidth, float(BoxHeight));
	C.Style = 5;
	C.__NFUN_2626__(W.Root.Colors.White.R, W.Root.Colors.White.G, W.Root.Colors.White.B, W.Root.Colors.White.A);
	// End:0x291
	if(W.m_bUseSpecialEffect)
	{
		C.__NFUN_2626__(W.Root.Colors.GrayLight.R, W.Root.Colors.GrayLight.G, W.Root.Colors.GrayLight.B, W.Root.Colors.GrayLight.A);
	}
	W.DrawStretchedTextureSegment(C, float(__NFUN_146__(m_iSize_ScrollBarFrameW, m_iScrollerOffset)), W.ThumbStart, float(m_iVScrollerWidth), W.ThumbHeight, float(m_SBScroller.X), float(m_SBScroller.Y), float(m_SBScroller.W), float(m_SBScroller.H), m_R6ScrollTexture);
	return;
}

function SB_HDraw(UWindowHScrollbar W, Canvas C)
{
	local int BoxWidth;

	C.__NFUN_2626__(W.m_BorderColor.R, W.m_BorderColor.G, W.m_BorderColor.B);
	BoxWidth = int(__NFUN_174__(__NFUN_174__(__NFUN_175__(__NFUN_175__(W.WinWidth, W.LeftButton.WinWidth), W.RightButton.WinWidth), float(W.LeftButton.m_BorderTextureRegion.W)), float(W.RightButton.m_BorderTextureRegion.W)));
	DrawBox(W, C, __NFUN_175__(W.LeftButton.WinWidth, float(W.LeftButton.m_BorderTextureRegion.W)), 0.0000000, float(BoxWidth), W.WinHeight);
	W.DrawStretchedTextureSegment(C, W.ThumbStart, float(__NFUN_146__(m_iSize_ScrollBarFrameW, m_iScrollerOffset)), W.ThumbWidth, float(m_iVScrollerWidth), float(m_SBScroller.X), float(m_SBScroller.Y), float(m_SBScroller.W), float(m_SBScroller.H), m_R6ScrollTexture);
	return;
}

function Tab_SetupLeftButton(UWindowTabControlLeftButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.WinWidth = Size_ScrollbarButtonHeight;
	W.WinHeight = Size_ScrollbarWidth;
	W.WinTop = __NFUN_175__(Size_TabAreaHeight, W.WinHeight);
	W.WinLeft = __NFUN_175__(W.ParentWindow.WinWidth, __NFUN_171__(float(2), W.WinWidth));
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = m_SBLeft.Up;
	W.DownRegion = m_SBLeft.Down;
	W.OverRegion = m_SBLeft.Up;
	W.DisabledRegion = m_SBLeft.Disabled;
	return;
}

function Tab_SetupRightButton(UWindowTabControlRightButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.WinWidth = Size_ScrollbarButtonHeight;
	W.WinHeight = Size_ScrollbarWidth;
	W.WinTop = __NFUN_175__(Size_TabAreaHeight, W.WinHeight);
	W.WinLeft = __NFUN_175__(W.ParentWindow.WinWidth, W.WinWidth);
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = m_SBRight.Up;
	W.DownRegion = m_SBRight.Down;
	W.OverRegion = m_SBRight.Up;
	W.DisabledRegion = m_SBRight.Disabled;
	return;
}

function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P)
{
	P.WinLeft = 2.0000000;
	P.WinTop = __NFUN_174__(__NFUN_175__(W.TabArea.WinHeight, float(__NFUN_147__(TabSelectedM.H, TabUnselectedM.H))), float(3));
	P.SetSize(__NFUN_175__(W.WinWidth, float(4)), __NFUN_175__(__NFUN_175__(W.WinHeight, __NFUN_175__(W.TabArea.WinHeight, float(__NFUN_147__(TabSelectedM.H, TabUnselectedM.H)))), float(6)));
	return;
}

function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P)
{
	W.DrawUpBevel(C, 0.0000000, Size_TabAreaHeight, W.WinWidth, __NFUN_175__(W.WinHeight, Size_TabAreaHeight), Active);
	return;
}

function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H)
{
	local float fTW, fTH;

	C.Font = Tab.Root.Fonts[Tab.7];
	Tab.TextSize(C, Text, fTW, fTH);
	W = __NFUN_174__(__NFUN_174__(__NFUN_174__(fTW, Size_TabSpacing), Size_TabTextOffset), float(TabSelectedR.W));
	H = fTH;
	return;
}

function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C)
{
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, W.WinWidth, 16.0000000, 11.0000000, 0.0000000, 106.0000000, 16.0000000, Active);
	return;
}

function Menu_DrawMenuBarItem(UWindowMenuBar B, UWindowMenuBarItem i, float X, float Y, float W, float H, Canvas C)
{
	// End:0xA2
	if(__NFUN_114__(B.Selected, i))
	{
		B.DrawClippedTexture(C, X, 1.0000000, Texture'UWindow.BlackTexture');
		B.DrawClippedTexture(C, __NFUN_175__(__NFUN_174__(X, W), float(1)), 1.0000000, Texture'UWindow.BlackTexture');
		B.DrawStretchedTexture(C, __NFUN_174__(X, float(1)), 1.0000000, __NFUN_175__(W, float(2)), 16.0000000, Texture'UWindow.BlackTexture');
	}
	C.Font = B.Root.Fonts[0];
	C.__NFUN_2626__(0, 0, 0);
	B.ClipText(C, __NFUN_174__(X, float(__NFUN_145__(B.Spacing, 2))), 2.0000000, i.Caption, true);
	return;
}

function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C)
{
	return;
}

function Menu_DrawPulldownMenuItem(UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected)
{
	return;
}

// ****** R6 Add-On ******
function DrawWinTop(R6WindowHSplitter W, Canvas C)
{
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(FrameTL.W), W.WinHeight, float(FrameTL.X), float(FrameTL.Y), float(FrameTL.W), float(FrameTL.H), Active);
	W.DrawStretchedTextureSegment(C, float(FrameTL.W), 0.0000000, __NFUN_175__(__NFUN_175__(W.WinWidth, float(FrameTL.W)), float(FrameTR.W)), W.WinHeight, float(FrameT.X), float(FrameT.Y), float(FrameT.W), float(FrameT.H), Active);
	W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(FrameTR.W)), 0.0000000, float(FrameTR.W), W.WinHeight, float(FrameTR.X), float(FrameTR.Y), float(FrameTR.W), float(FrameTR.H), Active);
	return;
}

function DrawHSplitterT(R6WindowHSplitter W, Canvas C)
{
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, 12.0000000, W.WinHeight, 30.0000000, 5.0000000, 12.0000000, 6.0000000, Active);
	W.DrawStretchedTextureSegment(C, 12.0000000, 0.0000000, __NFUN_175__(W.WinWidth, float(24)), W.WinHeight, 42.0000000, 5.0000000, 2.0000000, 6.0000000, Active);
	W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(12)), 0.0000000, 12.0000000, W.WinHeight, 49.0000000, 5.0000000, 12.0000000, 6.0000000, Active);
	return;
}

function DrawHSplitterB(R6WindowHSplitter W, Canvas C)
{
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, 12.0000000, W.WinHeight, 61.0000000, 5.0000000, 12.0000000, 6.0000000, Active);
	W.DrawStretchedTextureSegment(C, 12.0000000, 0.0000000, __NFUN_175__(W.WinWidth, float(24)), W.WinHeight, 73.0000000, 5.0000000, 2.0000000, 6.0000000, Active);
	W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(12)), 0.0000000, 12.0000000, W.WinHeight, 80.0000000, 5.0000000, 12.0000000, 6.0000000, Active);
	return;
}

function DrawPopupButtonDown(R6MenuPopUpStayDownButton W, Canvas C)
{
	local int iColor;
	local Color MenuColor;

	iColor = R6PlanningCtrl(W.GetPlayerOwner()).m_iCurrentTeam;
	C.Style = 1;
	MenuColor = W.Root.Colors.TeamColorLight[iColor];
	__NFUN_134__(MenuColor.R, byte(2));
	__NFUN_134__(MenuColor.G, byte(2));
	__NFUN_134__(MenuColor.B, byte(2));
	C.__NFUN_2626__(MenuColor.R, MenuColor.G, MenuColor.B);
	W.DrawStretchedTexture(C, 0.0000000, 0.0000000, W.WinWidth, W.WinHeight, Texture'UWindow.WhiteTexture');
	MenuColor = W.Root.Colors.White;
	C.__NFUN_2626__(MenuColor.R, MenuColor.G, MenuColor.B);
	// End:0x19D
	if(__NFUN_123__(W.Text, ""))
	{
		W.ClipText(C, W.TextX, W.TextY, W.Text, true);
	}
	C.Style = 5;
	// End:0x264
	if(W.m_bSubMenu)
	{
		W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(__NFUN_146__(2, m_PopupArrowDown.H))), __NFUN_171__(__NFUN_175__(W.WinHeight, float(m_PopupArrowDown.H)), 0.5000000), float(m_PopupArrowDown.W), float(m_PopupArrowDown.H), float(m_PopupArrowDown.X), float(m_PopupArrowDown.Y), float(m_PopupArrowDown.W), float(m_PopupArrowDown.H), m_R6ScrollTexture);
	}
	C.__NFUN_2626__(byte(255), byte(255), byte(255));
	return;
}

function DrawPopupButtonUp(R6MenuPopUpStayDownButton W, Canvas C)
{
	local Color MenuColor;

	MenuColor = W.Root.Colors.White;
	C.__NFUN_2626__(MenuColor.R, MenuColor.G, MenuColor.B, byte(W.Root.Colors.PopUpAlphaFactor));
	C.Style = 5;
	// End:0xD7
	if(__NFUN_123__(W.Text, ""))
	{
		W.ClipText(C, W.TextX, W.TextY, W.Text, true);
	}
	// End:0x18D
	if(W.m_bSubMenu)
	{
		W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(__NFUN_146__(2, m_PopupArrowDown.H))), __NFUN_171__(__NFUN_175__(W.WinHeight, float(m_PopupArrowUp.H)), 0.5000000), float(m_PopupArrowUp.W), float(m_PopupArrowUp.H), float(m_PopupArrowUp.X), float(m_PopupArrowUp.Y), float(m_PopupArrowUp.W), float(m_PopupArrowUp.H), m_R6ScrollTexture);
	}
	C.Style = 1;
	C.__NFUN_2626__(byte(255), byte(255), byte(255));
	return;
}

function DrawPopupButtonOver(R6MenuPopUpStayDownButton W, Canvas C)
{
	local Color MenuColor;

	MenuColor = W.Root.Colors.White;
	C.__NFUN_2626__(MenuColor.R, MenuColor.G, MenuColor.B);
	C.Style = 1;
	// End:0xB5
	if(__NFUN_123__(W.Text, ""))
	{
		W.ClipText(C, W.TextX, W.TextY, W.Text, true);
	}
	C.Style = 5;
	// End:0x17C
	if(W.m_bSubMenu)
	{
		W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(__NFUN_146__(2, m_PopupArrowDown.H))), __NFUN_171__(__NFUN_175__(W.WinHeight, float(m_PopupArrowUp.H)), 0.5000000), float(m_PopupArrowUp.W), float(m_PopupArrowUp.H), float(m_PopupArrowUp.X), float(m_PopupArrowUp.Y), float(m_PopupArrowUp.W), float(m_PopupArrowUp.H), m_R6ScrollTexture);
	}
	C.__NFUN_2626__(byte(255), byte(255), byte(255));
	return;
}

function DrawPopupButtonDisable(R6MenuPopUpStayDownButton W, Canvas C)
{
	local Color MenuColor;

	MenuColor = W.Root.Colors.White;
	C.__NFUN_2626__(MenuColor.R, MenuColor.G, MenuColor.B, 50);
	C.Style = 5;
	// End:0xB7
	if(__NFUN_123__(W.Text, ""))
	{
		W.ClipText(C, W.TextX, W.TextY, W.Text, true);
	}
	// End:0x16D
	if(W.m_bSubMenu)
	{
		W.DrawStretchedTextureSegment(C, __NFUN_175__(W.WinWidth, float(__NFUN_146__(2, m_PopupArrowDown.H))), __NFUN_171__(__NFUN_175__(W.WinHeight, float(m_PopupArrowUp.H)), 0.5000000), float(m_PopupArrowUp.W), float(m_PopupArrowUp.H), float(m_PopupArrowUp.X), float(m_PopupArrowUp.Y), float(m_PopupArrowUp.W), float(m_PopupArrowUp.H), m_R6ScrollTexture);
	}
	C.Style = 1;
	C.__NFUN_2626__(byte(255), byte(255), byte(255));
	return;
}

//===================================================================================================
// Draw the navigation bar (ex.: in briefing menu, at the bottom of the page
//===================================================================================================
function DrawNavigationBar(R6MenuNavigationBar W, Canvas C)
{
	local int iXStart, iXTexSize, iXWidth, iYTexSize;
	local Region R;
	local Color cTemp;

	cTemp = W.m_BorderColor;
	W.m_BorderColor = W.Root.Colors.BlueLight;
	W.DrawSimpleBorder(C);
	W.m_BorderColor = cTemp;
	C.Style = 5;
	C.__NFUN_2626__(W.Root.Colors.BlueLight.R, W.Root.Colors.BlueLight.G, W.Root.Colors.BlueLight.B);
	W.DrawStretchedTextureSegment(C, 120.0000000, 0.0000000, 1.0000000, 33.0000000, float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	W.DrawStretchedTextureSegment(C, 414.0000000, 0.0000000, 1.0000000, 33.0000000, float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	W.DrawStretchedTextureSegment(C, 450.0000000, 0.0000000, 1.0000000, 33.0000000, float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	W.DrawStretchedTextureSegment(C, 554.0000000, 0.0000000, 1.0000000, 33.0000000, float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	iXStart = 120;
	iXTexSize = 12;
	iXWidth = 318;
	iYTexSize = 34;
	R = m_NavBarBack[0];
	W.DrawStretchedTextureSegment(C, float(__NFUN_146__(iXStart, iXTexSize)), -1.0000000, float(__NFUN_147__(iXWidth, iXTexSize)), float(iYTexSize), float(R.X), float(R.Y), float(R.W), float(R.H), m_NavBarTex);
	R = m_NavBarBack[1];
	W.DrawStretchedTextureSegment(C, float(iXStart), -1.0000000, float(iXTexSize), float(iYTexSize), float(R.X), float(R.Y), float(R.W), float(R.H), m_NavBarTex);
	W.DrawStretchedTextureSegment(C, float(__NFUN_146__(iXStart, iXWidth)), -1.0000000, float(iXTexSize), float(iYTexSize), float(__NFUN_146__(R.X, iXTexSize)), float(R.Y), float(__NFUN_143__(R.W)), float(R.H), m_NavBarTex);
	C.Style = 1;
	return;
}

function DrawButtonBorder(UWindowWindow W, Canvas C, optional bool _bDefineBorderColor)
{
	// End:0x106
	if(__NFUN_119__(m_TButtonBackGround, none))
	{
		C.Style = 5;
		// End:0x6D
		if(_bDefineBorderColor)
		{
			C.__NFUN_2626__(W.m_BorderColor.R, W.m_BorderColor.G, W.m_BorderColor.B);			
		}
		else
		{
			C.__NFUN_2626__(m_CBorder.R, m_CBorder.G, m_CBorder.B);
		}
		W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, W.WinWidth, W.WinHeight, float(m_RButtonBackGround.X), float(m_RButtonBackGround.Y), float(m_RButtonBackGround.W), float(m_RButtonBackGround.H), m_TButtonBackGround);
	}
	return;
}

//Function to draw a different background then the basic SimpleBorder
function DrawSpecialButtonBorder(R6WindowButton Button, Canvas C, float X, float Y)
{
	local int XPos, MidWidth;

	C.Style = 5;
	C.__NFUN_2626__(Button.m_BorderColor.R, Button.m_BorderColor.G, Button.m_BorderColor.B);
	XPos = 0;
	Button.DrawStretchedTextureSegment(C, float(XPos), 0.0000000, float(m_RSquareBgLeft.W), float(m_RSquareBgLeft.H), float(m_RSquareBgLeft.X), float(m_RSquareBgLeft.Y), float(m_RSquareBgLeft.W), float(m_RSquareBgLeft.H), m_TSquareBg);
	__NFUN_161__(XPos, m_RSquareBgLeft.W);
	MidWidth = int(__NFUN_175__(__NFUN_175__(Button.WinWidth, float(m_RSquareBgLeft.W)), float(m_RSquareBgRight.W)));
	Button.DrawStretchedTextureSegment(C, float(XPos), 0.0000000, float(MidWidth), float(m_RSquareBgMid.H), float(m_RSquareBgMid.X), float(m_RSquareBgMid.Y), float(m_RSquareBgMid.W), float(m_RSquareBgMid.H), m_TSquareBg);
	XPos = int(__NFUN_175__(Button.WinWidth, float(m_RSquareBgRight.W)));
	Button.DrawStretchedTextureSegment(C, float(XPos), 0.0000000, float(m_RSquareBgRight.W), float(m_RSquareBgRight.H), float(m_RSquareBgRight.X), float(m_RSquareBgRight.Y), float(m_RSquareBgRight.W), float(m_RSquareBgRight.H), m_TSquareBg);
	return;
}

function DrawBox(UWindowWindow W, Canvas C, float X, float Y, float Width, float Height)
{
	C.Style = 5;
	C.__NFUN_2626__(W.m_BorderColor.R, W.m_BorderColor.G, W.m_BorderColor.B);
	W.DrawStretchedTextureSegment(C, X, Y, Width, float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	W.DrawStretchedTextureSegment(C, X, __NFUN_175__(__NFUN_174__(Y, Height), float(W.m_BorderTextureRegion.H)), Width, float(W.m_BorderTextureRegion.H), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	W.DrawStretchedTextureSegment(C, X, __NFUN_174__(Y, float(W.m_BorderTextureRegion.H)), float(W.m_BorderTextureRegion.W), __NFUN_175__(Height, float(__NFUN_144__(2, W.m_BorderTextureRegion.H))), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	W.DrawStretchedTextureSegment(C, __NFUN_175__(__NFUN_174__(X, Width), float(W.m_BorderTextureRegion.W)), __NFUN_174__(Y, float(W.m_BorderTextureRegion.H)), float(W.m_BorderTextureRegion.W), __NFUN_175__(Height, float(__NFUN_144__(2, W.m_BorderTextureRegion.H))), float(W.m_BorderTextureRegion.X), float(W.m_BorderTextureRegion.Y), float(W.m_BorderTextureRegion.W), float(W.m_BorderTextureRegion.H), W.m_BorderTexture);
	return;
}

function DrawBGShading(UWindowWindow Window, Canvas C, float X, float Y, float W, float H)
{
	C.Style = 5;
	C.__NFUN_2626__(Window.Root.Colors.Black.R, Window.Root.Colors.Black.G, Window.Root.Colors.Black.B, byte(Window.Root.Colors.DarkBGAlpha));
	Window.DrawStretchedTexture(C, X, Y, W, H, Texture'UWindow.WhiteTexture');
	return;
}

function DrawPopUpTextBackGround(UWindowWindow W, Canvas C, float _fHeight)
{
	local Region RTexture;
	local float fY, fHeight;

	RTexture.X = 114;
	RTexture.Y = 47;
	RTexture.W = 2;
	RTexture.H = 13;
	C.Style = 5;
	fHeight = _fHeight;
	// End:0x8C
	if(__NFUN_176__(fHeight, W.WinHeight))
	{
		fY = __NFUN_172__(__NFUN_175__(W.WinHeight, fHeight), float(2));		
	}
	else
	{
		fY = 0.0000000;
	}
	// End:0xBF
	if(__NFUN_176__(fHeight, float(RTexture.H)))
	{
		fHeight = float(RTexture.H);
	}
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, W.WinWidth, 13.0000000, float(RTexture.X), float(RTexture.Y), float(RTexture.W), float(RTexture.H), m_R6ScrollTexture);
	return;
}

function DrawInGamePlayerStats(UWindowWindow W, Canvas C, int _iPlayerStats, float _fX, float _fY, float _fHeight, float _fWidth)
{
	local float fXOffset;
	local Region RIconRegion, RIconToDraw;

	RIconToDraw.Y = 29;
	RIconToDraw.W = 10;
	RIconToDraw.H = 10;
	fXOffset = _fX;
	switch(_iPlayerStats)
	{
		// End:0x72
		case 1:
			RIconToDraw.X = 31;
			RIconRegion = CenterIconInBox(fXOffset, _fY, _fWidth, _fHeight, RIconToDraw);
			// End:0x1A6
			break;
		// End:0xAC
		case 2:
			RIconToDraw.X = 42;
			RIconRegion = CenterIconInBox(fXOffset, _fY, _fWidth, _fHeight, RIconToDraw);
			// End:0x1A6
			break;
		// End:0xE6
		case 3:
			RIconToDraw.X = 53;
			RIconRegion = CenterIconInBox(fXOffset, _fY, _fWidth, _fHeight, RIconToDraw);
			// End:0x1A6
			break;
		// End:0x147
		case 4:
			RIconToDraw.X = 53;
			RIconToDraw.Y = 40;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			RIconRegion = CenterIconInBox(fXOffset, _fY, _fWidth, _fHeight, RIconToDraw);
			// End:0x1A6
			break;
		// End:0xFFFF
		default:
			RIconToDraw.X = 49;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			RIconRegion = CenterIconInBox(fXOffset, _fY, _fWidth, _fHeight, RIconToDraw);
			// End:0x1A6
			break;
			break;
	}
	W.DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	return;
}

//=======================================================================================================
// This function return the region where to draw the icon X and Y depending of window region
// (W and H are 0)
//=======================================================================================================
function Region CenterIconInBox(float _fX, float _fY, float _fWidth, float _fHeight, Region _RIconRegion)
{
	local Region RTemp;
	local float fTemp;

	fTemp = __NFUN_172__(__NFUN_175__(_fWidth, float(_RIconRegion.W)), float(2));
	RTemp.X = int(__NFUN_174__(_fX, float(int(__NFUN_174__(fTemp, 0.5000000)))));
	fTemp = __NFUN_172__(__NFUN_175__(_fHeight, float(_RIconRegion.H)), float(2));
	RTemp.Y = int(float(int(__NFUN_174__(fTemp, 0.5000000))));
	__NFUN_161__(RTemp.Y, int(_fY));
	return RTemp;
	return;
}

//=================================================================================================
// Get the size (height) of the header window (interwidget menu)
//=================================================================================================
function float GetTextHeaderSize()
{
	return m_fTextHeaderHeight;
	return;
}

defaultproperties
{
	m_iMultiplyer=-1
	m_fVSBButtonImageX=1
	m_fHSBButtonImageX=2
	m_fVSBButtonImageY=2
	m_fHSBButtonImageY=2
	m_fComboImageX=1
	m_fComboImageY=2
	m_fScrollRate=200.0000000
	m_fTextHeaderHeight=30.0000000
	m_TSquareBg=Texture'R6MenuTextures.Gui_BoxScroll'
	m_FrameSBL=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=290,ZoneNumber=0)
	m_FrameSB=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=27426,ZoneNumber=0)
	m_FrameSBR=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=290,ZoneNumber=0)
	m_BLTitleL=(Up=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=802,ZoneNumber=0),H=22)
	m_BLTitleC=(Up=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=802,ZoneNumber=0),W=2,H=22)
	m_BLTitleR=(Up=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=4642,ZoneNumber=0),W=3,H=22)
	m_PopupArrowUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_PopupArrowDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=20514,ZoneNumber=0)
	m_stLapTopFrame=(TL=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=65570,ZoneNumber=0),H=32)
	m_stLapTopFramePlus=(T1=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=8226,ZoneNumber=0),W=38,H=32)
	m_NavBarBack[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=63010,ZoneNumber=0)
	m_NavBarBack[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=62498,ZoneNumber=0)
	m_NavBarBack[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=56354,ZoneNumber=0)
	m_NavBarBack[3]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=58658,ZoneNumber=0)
	m_NavBarBack[4]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=61474,ZoneNumber=0)
	m_NavBarBack[5]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=56354,ZoneNumber=0)
	m_NavBarBack[6]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=60194,ZoneNumber=0)
	m_NavBarBack[7]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=63522,ZoneNumber=0)
	m_NavBarBack[8]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=56354,ZoneNumber=0)
	m_NavBarBack[9]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=58914,ZoneNumber=0)
	m_NavBarBack[10]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=57890,ZoneNumber=0)
	m_NavBarBack[11]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=57890,ZoneNumber=0)
	m_topLeftCornerR=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=3106,ZoneNumber=0)
	m_RBAcceptCancel[0]=(Up=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0),W=19,H=13)
	m_RBAcceptCancel[1]=(Up=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=7714,ZoneNumber=0),W=19,H=13)
	m_RArrow[0]=(Up=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=24098,ZoneNumber=0),Y=47,W=10,H=7)
	m_RArrow[1]=(Up=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=26658,ZoneNumber=0),Y=47,W=-10,H=7)
	m_SBScrollerActive=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=16418,ZoneNumber=0)
	m_SBUpGear=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_SBDownGear=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22306,ZoneNumber=0)
	m_RSquareBgLeft=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=6690,ZoneNumber=0)
	m_RSquareBgMid=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=7714,ZoneNumber=0)
	m_RSquareBgRight=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=11554,ZoneNumber=0)
	m_iCloseBoxOffsetX=3
	m_iCloseBoxOffsetY=5
	m_iListHPadding=1
	m_iListVPadding=1
	m_iSize_ScrollBarFrameW=1
	m_iVScrollerWidth=9
	m_iScrollerOffset=1
	m_TButtonBackGround=Texture'R6MenuTextures.Gui_BoxScroll'
	m_SBUp=(Up=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=2850,ZoneNumber=0),H=8)
	m_SBDown=(Up=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=2082,ZoneNumber=0),W=11,H=-8)
	m_SBRight=(Up=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2338,ZoneNumber=0),Y=25,W=-8,H=9)
	m_SBLeft=(Up=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=290,ZoneNumber=0),Y=25,W=8,H=9)
	m_SBBackground=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=3874,ZoneNumber=0)
	m_SBVBorder=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=16418,ZoneNumber=0)
	m_SBHBorder=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=16418,ZoneNumber=0)
	m_SBScroller=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=13090,ZoneNumber=0)
	m_CloseBoxUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=21026,ZoneNumber=0)
	m_CloseBoxDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=21026,ZoneNumber=0)
	m_RButtonBackGround=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=3106,ZoneNumber=0)
	m_CBorder=(R=15,G=136,B=176,A=0)
	FrameTitleX=6
	FrameTitleY=4
	ColumnHeadingHeight=13
	EditBoxBevel=2
	Size_ComboHeight=12.0000000
	Size_ComboButtonWidth=13.0000000
	Size_ScrollbarWidth=13.0000000
	Size_ScrollbarButtonHeight=12.0000000
	Size_MinScrollbarHeight=6.0000000
	Size_TabAreaHeight=15.0000000
	Size_TabAreaOverhangHeight=2.0000000
	Size_TabXOffset=1.0000000
	Size_TabTextOffset=12.0000000
	Pulldown_ItemHeight=15.0000000
	Pulldown_VBorder=3.0000000
	Pulldown_HBorder=3.0000000
	Pulldown_TextBorder=9.0000000
	FrameTL=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=3106,ZoneNumber=0)
	FrameT=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=3106,ZoneNumber=0)
	FrameTR=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29730,ZoneNumber=0)
	FrameL=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=4386,ZoneNumber=0)
	FrameR=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=4386,ZoneNumber=0)
	FrameBL=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=32290,ZoneNumber=0)
	FrameB=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=546,ZoneNumber=0)
	FrameBR=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=31778,ZoneNumber=0)
	FrameActiveTitleColor=(R=255,G=255,B=255,A=0)
	FrameInactiveTitleColor=(R=255,G=255,B=255,A=0)
	BevelUpTL=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=1058,ZoneNumber=0)
	BevelUpT=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2594,ZoneNumber=0)
	BevelUpTR=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=4642,ZoneNumber=0)
	BevelUpL=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=1058,ZoneNumber=0)
	BevelUpR=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=4642,ZoneNumber=0)
	BevelUpBL=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=1058,ZoneNumber=0)
	BevelUpB=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2594,ZoneNumber=0)
	BevelUpBR=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=4642,ZoneNumber=0)
	BevelUpArea=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2082,ZoneNumber=0)
	MiscBevelTL[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelTL[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelTL[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelT[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelT[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelT[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelTR[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelTR[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelTR[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelL[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelL[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelL[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelR[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelR[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelR[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelBL[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelBL[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelBL[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelB[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelB[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelB[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelBR[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelBR[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelBR[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2850,ZoneNumber=0)
	MiscBevelArea[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=3106,ZoneNumber=0)
	MiscBevelArea[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=5154,ZoneNumber=0)
	MiscBevelArea[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=5154,ZoneNumber=0)
	ComboBtnUp=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=2082,ZoneNumber=0)
	ComboBtnDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=6178,ZoneNumber=0)
	ComboBtnDisabled=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=6178,ZoneNumber=0)
	ComboBtnOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=4130,ZoneNumber=0)
	HLine=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=1314,ZoneNumber=0)
	EditBoxTextColor=(R=255,G=255,B=255,A=0)
	TabSelectedL=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=16418,ZoneNumber=0)
	TabSelectedM=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=10530,ZoneNumber=0)
	TabSelectedR=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=13858,ZoneNumber=0)
	TabUnselectedL=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22050,ZoneNumber=0)
	TabUnselectedM=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=15394,ZoneNumber=0)
	TabUnselectedR=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=35874,ZoneNumber=0)
	TabBackground=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=1058,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var X
// REMOVED IN 1.60: var Y
// REMOVED IN 1.60: function FW_HitTest
// REMOVED IN 1.60: function R6FW_HitTest
