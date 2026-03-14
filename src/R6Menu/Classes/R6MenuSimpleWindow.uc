//=============================================================================
// R6MenuSimpleWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowSimpleWindow.uc : Draw a simple window (opportunity to create a empty box)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/20 * Created by Yannick Joly
//=============================================================================
class R6MenuSimpleWindow extends UWindowWindow;

var bool m_bDrawSimpleBorder;
var UWindowWindow pAdviceParent;

function Paint(Canvas C, float X, float Y)
{
	// End:0x14
	if(m_bDrawSimpleBorder)
	{
		DrawSimpleBorder(C);
	}
	return;
}

function MouseWheelDown(float X, float Y)
{
	// End:0x24
	if(__NFUN_119__(pAdviceParent, none))
	{
		pAdviceParent.MouseWheelDown(X, Y);
	}
	return;
}

function MouseWheelUp(float X, float Y)
{
	// End:0x24
	if(__NFUN_119__(pAdviceParent, none))
	{
		pAdviceParent.MouseWheelUp(X, Y);
	}
	return;
}

defaultproperties
{
	m_bDrawSimpleBorder=true
}
