//=============================================================================
// R6WindowButtonGear - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowButtonGear.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/15 * Created by Alexandre Dionne
//=============================================================================
class R6WindowButtonGear extends R6WindowButton;

var bool m_HighLight;
var bool m_bForceMouseOver;  // force a mouse over
var float m_fAlpha;
var Texture m_HighLightTexture;

function RMouseDown(float X, float Y)
{
	bRMouseDown = true;
	return;
}

function MMouseDown(float X, float Y)
{
	bMMouseDown = true;
	return;
}

function LMouseDown(float X, float Y)
{
	bMouseDown = true;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 5;
	// End:0xD8
	if(bDisabled)
	{
		// End:0xD5
		if(__NFUN_119__(DisabledTexture, none))
		{
			// End:0x61
			if(__NFUN_129__(m_HighLight))
			{
				C.__NFUN_2626__(m_vButtonColor.R, m_vButtonColor.G, m_vButtonColor.B, byte(m_fAlpha));
			}
			DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_186__(__NFUN_171__(float(DisabledRegion.W), RegionScale)), __NFUN_186__(__NFUN_171__(float(DisabledRegion.H), RegionScale)), float(DisabledRegion.X), float(DisabledRegion.Y), float(DisabledRegion.W), float(DisabledRegion.H), DisabledTexture);
		}		
	}
	else
	{
		// End:0x12F
		if(m_HighLight)
		{
			DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, 0.0000000, 0.0000000, float(m_HighLightTexture.USize), float(m_HighLightTexture.VSize), m_HighLightTexture);
		}
		// End:0x1E4
		if(bMouseDown)
		{
			// End:0x1E1
			if(__NFUN_119__(DownTexture, none))
			{
				C.__NFUN_2626__(m_vButtonColor.R, m_vButtonColor.G, m_vButtonColor.B);
				DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_186__(__NFUN_171__(float(DownRegion.W), RegionScale)), __NFUN_186__(__NFUN_171__(float(DownRegion.H), RegionScale)), float(DownRegion.X), float(DownRegion.Y), float(DownRegion.W), float(DownRegion.H), DownTexture);
			}			
		}
		else
		{
			// End:0x2A4
			if(__NFUN_132__(MouseIsOver(), m_bForceMouseOver))
			{
				// End:0x2A1
				if(__NFUN_119__(OverTexture, none))
				{
					C.__NFUN_2626__(m_vButtonColor.R, m_vButtonColor.G, m_vButtonColor.B);
					DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_186__(__NFUN_171__(float(OverRegion.W), RegionScale)), __NFUN_186__(__NFUN_171__(float(OverRegion.H), RegionScale)), float(OverRegion.X), float(OverRegion.Y), float(OverRegion.W), float(OverRegion.H), OverTexture);
				}				
			}
			else
			{
				// End:0x35F
				if(__NFUN_119__(UpTexture, none))
				{
					// End:0x2EB
					if(__NFUN_129__(m_HighLight))
					{
						C.__NFUN_2626__(m_vButtonColor.R, m_vButtonColor.G, m_vButtonColor.B, byte(m_fAlpha));
					}
					DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_186__(__NFUN_171__(float(UpRegion.W), RegionScale)), __NFUN_186__(__NFUN_171__(float(UpRegion.H), RegionScale)), float(UpRegion.X), float(UpRegion.Y), float(UpRegion.W), float(UpRegion.H), UpTexture);
				}
			}
		}
	}
	// End:0x373
	if(m_bDrawSimpleBorder)
	{
		DrawSimpleBorder(C);
	}
	return;
}

function ForceMouseOver(bool _bForceMouseOver)
{
	m_bForceMouseOver = _bForceMouseOver;
	return;
}

defaultproperties
{
	m_fAlpha=128.0000000
	m_HighLightTexture=Texture'R6TextureMenuEquipment.Highlight_gearroom'
	ImageX=1.0000000
	ImageY=1.0000000
}
