//=============================================================================
// R6WindowPopUpButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowPopUpButton.uc : PopUp button with specific border texture
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowPopUpButton extends UWindowButton;

var bool m_bDrawRedBG;
var bool m_bDrawGreenBG;
var Texture m_TButBorderTex;
var Region m_RButBorder;

function Paint(Canvas C, float X, float Y)
{
	C.Style = 5;
	// End:0x83
	if(m_bDrawRedBG)
	{
		C.__NFUN_2626__(Root.Colors.TeamColorLight[0].R, Root.Colors.TeamColorLight[0].G, Root.Colors.TeamColorLight[0].B);		
	}
	else
	{
		// End:0xF5
		if(m_bDrawGreenBG)
		{
			C.__NFUN_2626__(Root.Colors.TeamColorLight[1].R, Root.Colors.TeamColorLight[1].G, Root.Colors.TeamColorLight[1].B);			
		}
		else
		{
			C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
		}
	}
	super.Paint(C, X, Y);
	// End:0x1CA
	if(__NFUN_122__(Text, ""))
	{
		DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, float(m_RButBorder.X), float(m_RButBorder.Y), float(m_RButBorder.W), float(m_RButBorder.H), m_TButBorderTex);
	}
	return;
}

defaultproperties
{
	m_TButBorderTex=Texture'R6MenuTextures.Gui_BoxScroll'
	m_RButBorder=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=6690,ZoneNumber=0)
	m_bWaitSoundFinish=true
}
