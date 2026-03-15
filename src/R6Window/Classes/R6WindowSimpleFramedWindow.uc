//=============================================================================
// R6WindowSimpleFramedWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowSimpleFramedWindow.uc : This provides a simple frame for a window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/19 * Created by Alexandre Dionne
//=============================================================================
class R6WindowSimpleFramedWindow extends UWindowWindow;

enum eCornerType
{
	No_Corners,                     // 0
	Top_Corners,                    // 1
	Bottom_Corners,                 // 2
	All_Corners                     // 3
};

// NEW IN 1.60
var R6WindowSimpleFramedWindow.eCornerType m_eCornerType;
var int m_DrawStyle;
var bool bShowLog;
var float m_fHBorderHeight;  // Border size
// NEW IN 1.60
var float m_fVBorderWidth;
var float m_fHBorderPadding;  // Allow the borders not to start in corners
// NEW IN 1.60
var float m_fVBorderPadding;
var float m_fHBorderOffset;  // Border offset if you want the borders to
// NEW IN 1.60
var float m_fVBorderOffset;
var Texture m_HBorderTexture;
// NEW IN 1.60
var Texture m_VBorderTexture;
var Texture m_topLeftCornerT;
var UWindowWindow m_ClientArea;
//This is to create the window that needs the frame
var Class<UWindowWindow> m_ClientClass;
var Region m_HBorderTextureRegion;
// NEW IN 1.60
var Region m_VBorderTextureRegion;
var Region m_topLeftCornerR;

//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow(Class<UWindowWindow> ClientClass)
{
	m_ClientClass = ClientClass;
	m_ClientArea = CreateWindow(m_ClientClass, (m_fVBorderWidth + m_fVBorderOffset), (m_fHBorderHeight + m_fHBorderOffset), ((WinWidth - (float(2) * m_fVBorderWidth)) - (float(2) * m_fVBorderOffset)), ((WinHeight - (float(2) * m_fHBorderHeight)) - (float(2) * m_fHBorderOffset)), OwnerWindow);
	// End:0x151
	if(bShowLog)
	{
		Log("Creating Client window");
		Log(("m_ClientClass" @ string(m_ClientClass)));
		Log(("x:" @ string((m_fVBorderWidth + m_fVBorderOffset))));
		Log(("y:" @ string((m_fHBorderHeight + m_fHBorderOffset))));
		Log(("w:" @ string(((WinWidth - (float(2) * m_fVBorderWidth)) - (float(2) * m_fVBorderOffset)))));
		Log(("h:" @ string(((WinHeight - (float(2) * m_fHBorderHeight)) - (float(2) * m_fHBorderOffset)))));
		Log("Done Creating Client window");
	}
	return;
}

function SetCornerType(R6WindowSimpleFramedWindow.eCornerType _eCornerType)
{
	m_eCornerType = _eCornerType;
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	local float tempSpace;

	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	C.Style = byte(m_DrawStyle);
	switch(m_eCornerType)
	{
		// End:0x2EB
		case 1:
			// End:0x120
			if((m_HBorderTexture != none))
			{
				DrawStretchedTextureSegment(C, m_fHBorderPadding, m_fHBorderOffset, (WinWidth - (float(2) * m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
				DrawStretchedTextureSegment(C, m_fVBorderOffset, (WinHeight - m_fHBorderHeight), (WinWidth - (float(2) * m_fVBorderOffset)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
			}
			// End:0x1FD
			if((m_VBorderTexture != none))
			{
				DrawStretchedTextureSegment(C, m_fVBorderOffset, m_fVBorderPadding, m_fVBorderWidth, ((WinHeight - m_fVBorderPadding) - m_fHBorderHeight), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
				DrawStretchedTextureSegment(C, ((WinWidth - m_fVBorderWidth) - m_fVBorderOffset), m_fVBorderPadding, m_fVBorderWidth, ((WinHeight - m_fVBorderPadding) - m_fHBorderHeight), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
			}
			// End:0x2E8
			if((m_topLeftCornerT != none))
			{
				DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(m_topLeftCornerR.Y), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), m_topLeftCornerT);
				DrawStretchedTextureSegment(C, (WinWidth - float(m_topLeftCornerR.W)), 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float((m_topLeftCornerR.X + m_topLeftCornerR.W)), float(m_topLeftCornerR.Y), float((-m_topLeftCornerR.W)), float(m_topLeftCornerR.H), m_topLeftCornerT);
			}
			// End:0x992
			break;
		// End:0x5CE
		case 2:
			// End:0x3CB
			if((m_HBorderTexture != none))
			{
				DrawStretchedTextureSegment(C, m_fVBorderOffset, 0.0000000, (WinWidth - (float(2) * m_fVBorderOffset)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
				DrawStretchedTextureSegment(C, m_fHBorderPadding, ((WinHeight - m_fHBorderHeight) - m_fHBorderOffset), (WinWidth - (float(2) * m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
			}
			// End:0x4A8
			if((m_VBorderTexture != none))
			{
				DrawStretchedTextureSegment(C, m_fVBorderOffset, m_fHBorderHeight, m_fVBorderWidth, ((WinHeight - m_fVBorderPadding) - m_fHBorderHeight), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
				DrawStretchedTextureSegment(C, ((WinWidth - m_fVBorderWidth) - m_fVBorderOffset), m_fHBorderHeight, m_fVBorderWidth, ((WinHeight - m_fVBorderPadding) - m_fHBorderHeight), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
			}
			// End:0x5CB
			if((m_topLeftCornerT != none))
			{
				DrawStretchedTextureSegment(C, 0.0000000, (WinHeight - float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float((m_topLeftCornerR.Y + m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float((-m_topLeftCornerR.H)), m_topLeftCornerT);
				DrawStretchedTextureSegment(C, (WinWidth - float(m_topLeftCornerR.W)), (WinHeight - float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float((m_topLeftCornerR.X + m_topLeftCornerR.W)), float((m_topLeftCornerR.Y + m_topLeftCornerR.H)), float((-m_topLeftCornerR.W)), float((-m_topLeftCornerR.H)), m_topLeftCornerT);
			}
			// End:0x992
			break;
		// End:0x98F
		case 3:
			// End:0x6AE
			if((m_HBorderTexture != none))
			{
				DrawStretchedTextureSegment(C, m_fHBorderPadding, m_fHBorderOffset, (WinWidth - (float(2) * m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
				DrawStretchedTextureSegment(C, m_fHBorderPadding, ((WinHeight - m_fHBorderHeight) - m_fHBorderOffset), (WinWidth - (float(2) * m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
			}
			// End:0x789
			if((m_VBorderTexture != none))
			{
				DrawStretchedTextureSegment(C, m_fVBorderOffset, m_fVBorderPadding, m_fVBorderWidth, (WinHeight - (float(2) * m_fVBorderPadding)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
				DrawStretchedTextureSegment(C, ((WinWidth - m_fVBorderWidth) - m_fVBorderOffset), m_fVBorderPadding, m_fVBorderWidth, (WinHeight - (float(2) * m_fVBorderPadding)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
			}
			// End:0x98C
			if(__NFUN_119__(m_topLeftCornerT, none))
			{
				DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(m_topLeftCornerR.Y), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), m_topLeftCornerT);
				DrawStretchedTextureSegment(C, __NFUN_175__(WinWidth, float(m_topLeftCornerR.W)), 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(__NFUN_146__(m_topLeftCornerR.X, m_topLeftCornerR.W)), float(m_topLeftCornerR.Y), float(__NFUN_143__(m_topLeftCornerR.W)), float(m_topLeftCornerR.H), m_topLeftCornerT);
				DrawStretchedTextureSegment(C, 0.0000000, __NFUN_175__(WinHeight, float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(__NFUN_146__(m_topLeftCornerR.Y, m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(__NFUN_143__(m_topLeftCornerR.H)), m_topLeftCornerT);
				DrawStretchedTextureSegment(C, __NFUN_175__(WinWidth, float(m_topLeftCornerR.W)), __NFUN_175__(WinHeight, float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(__NFUN_146__(m_topLeftCornerR.X, m_topLeftCornerR.W)), float(__NFUN_146__(m_topLeftCornerR.Y, m_topLeftCornerR.H)), float(__NFUN_143__(m_topLeftCornerR.W)), float(__NFUN_143__(m_topLeftCornerR.H)), m_topLeftCornerT);
			}
			// End:0x992
			break;
		// End:0xFFFF
		default:
			break;
	}
	C.Style = 1;
	return;
}

defaultproperties
{
	m_eCornerType=3
	m_DrawStyle=5
	m_fHBorderHeight=1.0000000
	m_fVBorderWidth=1.0000000
	m_fHBorderPadding=7.0000000
	m_fVBorderPadding=8.0000000
	m_fVBorderOffset=1.0000000
	m_HBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_VBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_topLeftCornerT=Texture'R6MenuTextures.Gui_BoxScroll'
	m_ClientClass=Class'UWindow.UWindowClientWindow'
	m_HBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
	m_VBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
	m_topLeftCornerR=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=3106,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var eCornerType
