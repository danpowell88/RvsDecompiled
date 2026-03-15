//=============================================================================
// R6CrossReticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6CrossReticule.uc : Simple cross reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CrossReticule extends R6Reticule
    config(User)
    notplaceable;

var const int c_iLineWidth;
var const int c_iLineHeight;
var(Textures) Texture m_LineTexture;

// Speed gives us the current speed.
simulated function PostRender(Canvas C)
{
	local float fScale;
	local int iWidth, iHeight;
	local float fPositionAjustment;

	iWidth = c_iLineWidth;
	iHeight = c_iLineHeight;
	SetReticuleInfo(C);
	C.Style = 1;
	C.UseVirtualSize(false);
	(m_fAccuracy -= 0.1400000);
	// End:0x65
	if((m_fAccuracy < 0.0000000))
	{
		m_fAccuracy = 0.0000000;
	}
	fPositionAjustment = ((m_fReticuleOffsetY * m_fAccuracy) * 0.0200000);
	(iHeight += int(((float(c_iLineHeight) * m_fAccuracy) * 0.0200000)));
	C.SetPos((m_fReticuleOffsetX - 1.0000000), ((m_fReticuleOffsetY - float(iHeight)) - fPositionAjustment));
	C.DrawRect(m_LineTexture, float(iWidth), float(iHeight));
	C.SetPos((m_fReticuleOffsetX - 1.0000000), (m_fReticuleOffsetY + fPositionAjustment));
	C.DrawRect(m_LineTexture, float(iWidth), float(iHeight));
	C.SetPos(((m_fReticuleOffsetX - float(iHeight)) - fPositionAjustment), (m_fReticuleOffsetY - 1.0000000));
	C.DrawRect(m_LineTexture, float(iHeight), float(iWidth));
	C.SetPos((m_fReticuleOffsetX + fPositionAjustment), (m_fReticuleOffsetY - 1.0000000));
	C.DrawRect(m_LineTexture, float(iHeight), float(iWidth));
	return;
}

defaultproperties
{
	c_iLineWidth=2
	c_iLineHeight=16
	m_LineTexture=Texture'UWindow.WhiteTexture'
}
