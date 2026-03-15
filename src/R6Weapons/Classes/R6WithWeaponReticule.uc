//=============================================================================
// R6WithWeaponReticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WithWeaponReticule.uc : Simple cross reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6WithWeaponReticule extends R6Reticule
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
	local float fAjustedAccuracy, fPositionAjustment, fCenterOffsetX, fCenterOffsetY;

	iWidth = c_iLineWidth;
	iHeight = c_iLineHeight;
	fAjustedAccuracy = (m_fAccuracy - 0.2500000);
	// End:0x42
	if((fAjustedAccuracy < 0.0000000))
	{
		fAjustedAccuracy = 0.0000000;
	}
	(iHeight += int(((float(c_iLineHeight) * fAjustedAccuracy) * 0.0200000)));
	SetReticuleInfo(C);
	C.Style = 1;
	C.UseVirtualSize(false);
	fCenterOffsetX = (float(C.SizeX) / 640.0000000);
	fCenterOffsetY = (float(C.SizeY) / 480.0000000);
	C.SetPos((m_fReticuleOffsetX + fCenterOffsetX), (m_fReticuleOffsetY + fCenterOffsetY));
	C.DrawRect(m_LineTexture, float(c_iLineWidth), float(c_iLineWidth));
	fPositionAjustment = ((m_fReticuleOffsetY * fAjustedAccuracy) * 0.0200000);
	C.SetPos((m_fReticuleOffsetX + fCenterOffsetX), (((m_fReticuleOffsetY - float(iHeight)) - fPositionAjustment) + fCenterOffsetY));
	C.DrawRect(m_LineTexture, float(iWidth), float(iHeight));
	C.SetPos((m_fReticuleOffsetX + fCenterOffsetX), (((m_fReticuleOffsetY + fPositionAjustment) + fCenterOffsetY) + float(1)));
	C.DrawRect(m_LineTexture, float(iWidth), float(iHeight));
	C.SetPos((((m_fReticuleOffsetX - float(iHeight)) - fPositionAjustment) + fCenterOffsetX), (m_fReticuleOffsetY + fCenterOffsetY));
	C.DrawRect(m_LineTexture, float(iHeight), float(iWidth));
	C.SetPos((((m_fReticuleOffsetX + fPositionAjustment) + fCenterOffsetX) + float(1)), (m_fReticuleOffsetY + fCenterOffsetY));
	C.DrawRect(m_LineTexture, float(iHeight), float(iWidth));
	return;
}

defaultproperties
{
	c_iLineWidth=1
	c_iLineHeight=8
	m_LineTexture=Texture'UWindow.WhiteTexture'
}
