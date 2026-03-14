//=============================================================================
// R6WindowSimpleFramedWindowExt - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowSimpleFramedWindow.uc : This provides a simple frame for a window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/04 * Created by Yannick Joly
//=============================================================================
class R6WindowSimpleFramedWindowExt extends UWindowWindow;

enum eBorderType
{
	Border_Top,                     // 0
	Border_Bottom,                  // 1
	Border_Left,                    // 2
	Border_Right                    // 3
};

enum eCornerType
{
	No_Corners,                     // 0
	Top_Corners,                    // 1
	Bottom_Corners,                 // 2
	All_Corners                     // 3
};

struct stBorderForm
{
	var Color vColor;
	var float fXPos;
	var float fYPos;
	var float fWidth;
	var bool bActive;
};

// NEW IN 1.60
var R6WindowSimpleFramedWindowExt.eCornerType m_eCornerType;
var int m_DrawStyle;
var bool m_bNoBorderToDraw;
var bool m_bDrawBackGround;
var float m_fHBorderHeight;  // Border size
// NEW IN 1.60
var float m_fVBorderWidth;
//////////////////////////////
//Please make sure you set the Padding correctly if you use the offsets values
//////////////////////////////
var float m_fHBorderPadding;  // Allow the borders not to start in corners
// NEW IN 1.60
var float m_fVBorderPadding;
var float m_fHBorderOffset;  // Border offset if you want the borders to
// NEW IN 1.60
var float m_fVBorderOffset;
var Texture m_BGTexture;  // Put = None when no background is needed
var Texture m_HBorderTexture;
// NEW IN 1.60
var Texture m_VBorderTexture;
var Texture m_topLeftCornerT;
var UWindowWindow m_ClientArea;
//This is to create the window that needs the frame
var Class<UWindowWindow> m_ClientClass;
var Region m_BGTextureRegion;  // the background texture region
var Region m_HBorderTextureRegion;
// NEW IN 1.60
var Region m_VBorderTextureRegion;
var Region m_topLeftCornerR;
var stBorderForm m_sBorderForm[4];  // 0 = top ; 1 = down ; 2 = Left ; 3 = Right
var Color m_eCornerColor[4];
var Color m_vBGColor;  // the back ground color, default black

// default initialisation
// we have to set after the create window the parameters you want
function Created()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x9A [Loop If]
	if(__NFUN_150__(i, 4))
	{
		m_sBorderForm[i].vColor = Root.Colors.BlueLight;
		m_sBorderForm[i].fXPos = 0.0000000;
		m_sBorderForm[i].fYPos = 0.0000000;
		m_sBorderForm[i].fWidth = 1.0000000;
		m_sBorderForm[i].bActive = false;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	m_eCornerColor[int(3)] = Root.Colors.BlueLight;
	m_eCornerColor[int(1)] = Root.Colors.BlueLight;
	m_eCornerColor[int(2)] = Root.Colors.BlueLight;
	return;
}

//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow(Class<UWindowWindow> ClientClass)
{
	m_ClientClass = ClientClass;
	m_ClientArea = CreateWindow(m_ClientClass, 0.0000000, 0.0000000, WinWidth, WinHeight, OwnerWindow);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0xA2
	if(m_bDrawBackGround)
	{
		C.Style = byte(m_DrawStyle);
		C.__NFUN_2626__(m_vBGColor.R, m_vBGColor.G, m_vBGColor.B);
		DrawStretchedTextureSegment(C, 0.0000000, 1.0000000, WinWidth, __NFUN_175__(WinHeight, float(1)), float(m_BGTextureRegion.X), float(m_BGTextureRegion.Y), float(m_BGTextureRegion.W), float(m_BGTextureRegion.H), m_BGTexture);
	}
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	local Color vBorderColor, vCornerColor;

	C.Style = byte(m_DrawStyle);
	vBorderColor = Root.Colors.BlueLight;
	C.__NFUN_2626__(vBorderColor.R, vBorderColor.G, vBorderColor.B);
	// End:0x154
	if(m_sBorderForm[int(0)].bActive)
	{
		// End:0xCB
		if(m_sBorderForm[int(0)].vColor != vBorderColor)
		{
			vBorderColor = m_sBorderForm[int(0)].vColor;
			C.__NFUN_2626__(vBorderColor.R, vBorderColor.G, vBorderColor.B);
		}
		DrawStretchedTextureSegment(C, m_sBorderForm[int(0)].fXPos, m_sBorderForm[int(0)].fYPos, __NFUN_175__(WinWidth, __NFUN_171__(float(2), m_sBorderForm[int(0)].fXPos)), m_sBorderForm[int(0)].fWidth, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
	}
	// End:0x263
	if(m_sBorderForm[int(1)].bActive)
	{
		// End:0x1C2
		if(m_sBorderForm[int(1)].vColor != vBorderColor)
		{
			vBorderColor = m_sBorderForm[int(1)].vColor;
			C.__NFUN_2626__(vBorderColor.R, vBorderColor.G, vBorderColor.B);
		}
		DrawStretchedTextureSegment(C, m_sBorderForm[int(1)].fXPos, __NFUN_175__(__NFUN_175__(WinHeight, m_sBorderForm[int(1)].fWidth), m_sBorderForm[int(1)].fYPos), __NFUN_175__(WinWidth, __NFUN_171__(float(2), m_sBorderForm[int(1)].fXPos)), m_sBorderForm[int(1)].fWidth, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
	}
	// End:0x35A
	if(m_sBorderForm[int(2)].bActive)
	{
		// End:0x2D1
		if(m_sBorderForm[int(2)].vColor != vBorderColor)
		{
			vBorderColor = m_sBorderForm[int(2)].vColor;
			C.__NFUN_2626__(vBorderColor.R, vBorderColor.G, vBorderColor.B);
		}
		DrawStretchedTextureSegment(C, m_sBorderForm[int(2)].fXPos, m_sBorderForm[int(2)].fYPos, m_sBorderForm[int(2)].fWidth, __NFUN_175__(WinHeight, __NFUN_171__(float(2), m_sBorderForm[int(2)].fYPos)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
	}
	// End:0x469
	if(m_sBorderForm[int(3)].bActive)
	{
		// End:0x3C8
		if(m_sBorderForm[int(3)].vColor != vBorderColor)
		{
			vBorderColor = m_sBorderForm[int(3)].vColor;
			C.__NFUN_2626__(vBorderColor.R, vBorderColor.G, vBorderColor.B);
		}
		DrawStretchedTextureSegment(C, __NFUN_175__(__NFUN_175__(WinWidth, m_sBorderForm[int(3)].fWidth), m_sBorderForm[int(3)].fXPos), m_sBorderForm[int(3)].fYPos, m_sBorderForm[int(3)].fWidth, __NFUN_175__(WinHeight, __NFUN_171__(float(2), m_sBorderForm[int(3)].fYPos)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
	}
	vCornerColor = Root.Colors.BlueLight;
	// End:0x7C9
	if(__NFUN_155__(int(m_eCornerType), int(0)))
	{
		switch(m_eCornerType)
		{
			// End:0x4F3
			case 3:
				// End:0x4F3
				if(m_eCornerColor[int(3)] != vCornerColor)
				{
					vCornerColor = m_eCornerColor[int(3)];
					C.__NFUN_2626__(vCornerColor.R, vCornerColor.G, vCornerColor.B);
				}
			// End:0x647
			case 1:
				// End:0x549
				if(m_eCornerColor[int(1)] != vCornerColor)
				{
					vCornerColor = m_eCornerColor[int(1)];
					C.__NFUN_2626__(vCornerColor.R, vCornerColor.G, vCornerColor.B);
				}
				// End:0x634
				if(__NFUN_119__(m_topLeftCornerT, none))
				{
					DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(m_topLeftCornerR.Y), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), m_topLeftCornerT);
					DrawStretchedTextureSegment(C, __NFUN_175__(WinWidth, float(m_topLeftCornerR.W)), 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(__NFUN_146__(m_topLeftCornerR.X, m_topLeftCornerR.W)), float(m_topLeftCornerR.Y), float(__NFUN_143__(m_topLeftCornerR.W)), float(m_topLeftCornerR.H), m_topLeftCornerT);
				}
				// End:0x647
				if(__NFUN_155__(int(m_eCornerType), int(3)))
				{
					// End:0x7C9
					break;
				}
			// End:0x7C3
			case 2:
				// End:0x69D
				if(m_eCornerColor[int(2)] != vCornerColor)
				{
					vCornerColor = m_eCornerColor[int(2)];
					C.__NFUN_2626__(vCornerColor.R, vCornerColor.G, vCornerColor.B);
				}
				// End:0x7C0
				if(__NFUN_119__(m_topLeftCornerT, none))
				{
					DrawStretchedTextureSegment(C, 0.0000000, __NFUN_175__(WinHeight, float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(__NFUN_146__(m_topLeftCornerR.Y, m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(__NFUN_143__(m_topLeftCornerR.H)), m_topLeftCornerT);
					DrawStretchedTextureSegment(C, __NFUN_175__(WinWidth, float(m_topLeftCornerR.W)), __NFUN_175__(WinHeight, float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(__NFUN_146__(m_topLeftCornerR.X, m_topLeftCornerR.W)), float(__NFUN_146__(m_topLeftCornerR.Y, m_topLeftCornerR.H)), float(__NFUN_143__(m_topLeftCornerR.W)), float(__NFUN_143__(m_topLeftCornerR.H)), m_topLeftCornerT);
				}
				// End:0x7C9
				break;
			// End:0xFFFF
			default:
				// End:0x7C9
				break;
				break;
		}
	}
	return;
}

function SetBorderParam(int _iBorderType, float _X, float _Y, float _fWidth, Color _vColor)
{
	m_sBorderForm[_iBorderType].fXPos = _X;
	m_sBorderForm[_iBorderType].fYPos = _Y;
	m_sBorderForm[_iBorderType].vColor = _vColor;
	m_sBorderForm[_iBorderType].fWidth = _fWidth;
	m_sBorderForm[_iBorderType].bActive = true;
	m_bNoBorderToDraw = false;
	return;
}

// active border or not
function ActiveBorder(int _iBorderType, bool _Active)
{
	local int i;
	local bool bNoBorderToDraw;

	m_sBorderForm[_iBorderType].bActive = _Active;
	bNoBorderToDraw = true;
	i = 0;
	J0x27:

	// End:0x59 [Loop If]
	if(__NFUN_150__(i, 4))
	{
		// End:0x4F
		if(m_sBorderForm[i].bActive)
		{
			bNoBorderToDraw = false;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x27;
	}
	m_bNoBorderToDraw = bNoBorderToDraw;
	return;
}

function SetNoBorder()
{
	m_bNoBorderToDraw = true;
	return;
}

function ActiveBackGround(bool _bActivate, Color _vBGColor)
{
	m_bDrawBackGround = _bActivate;
	m_vBGColor = _vBGColor;
	return;
}

// set the corner color
function SetCornerColor(int _iCornerType, Color _Color)
{
	// End:0x2E
	if(__NFUN_154__(_iCornerType, int(3)))
	{
		m_eCornerColor[int(1)] = _Color;
		m_eCornerColor[int(2)] = _Color;
	}
	m_eCornerColor[_iCornerType] = _Color;
	return;
}

// verify if you at least one border to draw
function bool GetActivateBorder()
{
	return m_bNoBorderToDraw;
	return;
}

defaultproperties
{
	m_DrawStyle=5
	m_fHBorderHeight=2.0000000
	m_fVBorderWidth=2.0000000
	m_fHBorderPadding=7.0000000
	m_fVBorderPadding=2.0000000
	m_fVBorderOffset=1.0000000
	m_BGTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_HBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_VBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_topLeftCornerT=Texture'R6MenuTextures.Gui_BoxScroll'
	m_ClientClass=Class'UWindow.UWindowClientWindow'
	m_BGTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=19746,ZoneNumber=0)
	m_HBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
	m_VBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
	m_topLeftCornerR=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=3106,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eCornerType
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var t
