//=============================================================================
// R6MenuCarreerOperative - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuCarreerOperative.uc : In debriefing room the little control bottom right with face
//                              of the operative and his carreer stats
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/02 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCarreerOperative extends UWindowWindow;

var float m_fXPos;
// NEW IN 1.60
var float m_fXFacePos;
// NEW IN 1.60
var float m_fYFacePos;
// NEW IN 1.60
var float m_fTileHeight;
var R6WindowBitMap m_OperativeFace;
//Borders Region
var Region RTopRight;
// NEW IN 1.60
var Region RMidRight;
// NEW IN 1.60
var Region RTopLeft;
// NEW IN 1.60
var Region RMidLeft;

function Created()
{
	m_fXPos = __NFUN_172__(__NFUN_175__(__NFUN_175__(WinWidth, float(RTopLeft.W)), float(RTopRight.W)), float(2));
	m_OperativeFace = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', __NFUN_174__(m_fXPos, m_fXFacePos), m_fYFacePos, __NFUN_175__(__NFUN_175__(WinWidth, m_fXPos), m_fXFacePos), __NFUN_175__(WinHeight, __NFUN_171__(float(2), m_fYFacePos)), self));
	m_OperativeFace.m_iDrawStyle = 5;
	m_BorderColor = Root.Colors.Yellow;
	m_fTileHeight = __NFUN_175__(__NFUN_175__(WinHeight, float(RTopLeft.H)), float(RTopLeft.H));
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	local int i, j;

	C.Style = 5;
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B, m_BorderColor.A);
	DrawStretchedTextureSegment(C, m_fXPos, 0.0000000, float(RTopLeft.W), float(RTopLeft.H), float(RTopLeft.X), float(RTopLeft.Y), float(RTopLeft.W), float(RTopLeft.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, __NFUN_174__(m_fXPos, float(RTopLeft.W)), 0.0000000, float(RTopRight.W), float(RTopRight.H), float(RTopRight.X), float(RTopRight.Y), float(RTopRight.W), float(RTopRight.H), m_BorderTexture);
	i = 0;
	J0x11E:

	// End:0x23D [Loop If]
	if(__NFUN_176__(float(__NFUN_146__(i, RMidLeft.H)), m_fTileHeight))
	{
		DrawStretchedTextureSegment(C, m_fXPos, float(__NFUN_146__(RTopLeft.H, i)), float(RMidLeft.W), float(RMidLeft.H), float(RMidLeft.X), float(RMidLeft.Y), float(RMidLeft.W), float(RMidLeft.H), m_BorderTexture);
		DrawStretchedTextureSegment(C, __NFUN_174__(m_fXPos, float(RMidLeft.W)), float(__NFUN_146__(RTopLeft.H, i)), float(RMidRight.W), float(RMidRight.H), float(RMidRight.X), float(RMidRight.Y), float(RMidRight.W), float(RMidRight.H), m_BorderTexture);
		__NFUN_161__(i, RMidLeft.H);
		// [Loop Continue]
		goto J0x11E;
	}
	j = int(__NFUN_175__(m_fTileHeight, float(i)));
	// End:0x338
	if(__NFUN_151__(j, 0))
	{
		DrawStretchedTextureSegment(C, m_fXPos, float(__NFUN_146__(RTopLeft.H, i)), float(RMidLeft.W), float(j), float(RMidLeft.X), float(RMidLeft.Y), float(RMidLeft.W), float(j), m_BorderTexture);
		DrawStretchedTextureSegment(C, __NFUN_174__(m_fXPos, float(RMidLeft.W)), float(__NFUN_146__(RTopLeft.H, i)), float(RMidRight.W), float(j), float(RMidRight.X), float(RMidRight.Y), float(RMidRight.W), float(j), m_BorderTexture);
	}
	DrawStretchedTextureSegment(C, m_fXPos, __NFUN_175__(WinHeight, float(RTopLeft.H)), float(RTopLeft.W), float(RTopLeft.H), float(RTopLeft.X), float(__NFUN_146__(RTopLeft.Y, RTopLeft.H)), float(RTopLeft.W), float(__NFUN_143__(RTopLeft.H)), m_BorderTexture);
	DrawStretchedTextureSegment(C, __NFUN_174__(m_fXPos, float(RTopLeft.W)), __NFUN_175__(WinHeight, float(RTopRight.H)), float(RTopRight.W), float(RTopRight.H), float(RTopRight.X), float(__NFUN_146__(RTopRight.Y, RTopRight.H)), float(RTopRight.W), float(__NFUN_143__(RTopRight.H)), m_BorderTexture);
	return;
}

function setFace(Texture _OperativeFace, Region _FaceRegion)
{
	m_OperativeFace.t = _OperativeFace;
	m_OperativeFace.R = _FaceRegion;
	return;
}

function SetTeam(int _Team)
{
	m_BorderColor = Root.Colors.TeamColor[_Team];
	return;
}

defaultproperties
{
	m_fXFacePos=2.0000000
	m_fYFacePos=2.0000000
	RTopRight=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=22818,ZoneNumber=0)
	RMidRight=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=23586,ZoneNumber=0)
	RTopLeft=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=24354,ZoneNumber=0)
	RMidLeft=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=25122,ZoneNumber=0)
	m_BorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var s
