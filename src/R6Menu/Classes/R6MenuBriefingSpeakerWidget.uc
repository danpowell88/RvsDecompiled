//=============================================================================
// R6MenuBriefingSpeakerWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MenuBriefingSpeakerWidget extends UWindowWindow;

var float m_fHBorderHeight;
// NEW IN 1.60
var float m_fVBorderWidth;
var float m_fHBorderPadding;
// NEW IN 1.60
var float m_fVBorderPadding;
var Texture m_Texture[4];
var Texture m_HBorderTexture;
// NEW IN 1.60
var Texture m_VBorderTexture;
var Region m_TextureRegion[4];
var Region m_HBorderTextureRegion;
// NEW IN 1.60
var Region m_VBorderTextureRegion;

function Created()
{
	m_Texture[0] = Texture(DynamicLoadObject("R6BlackSnow.Mission.3dmodel", Class'Engine.Texture'));
	m_TextureRegion[0] = NewRegion(0.0000000, 0.0000000, 151.0000000, 113.0000000);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	C.Style = byte(m_BorderStyle);
	// End:0x178
	if(__NFUN_119__(m_HBorderTexture, none))
	{
		DrawStretchedTextureSegment(C, m_fHBorderPadding, 0.0000000, __NFUN_175__(WinWidth, __NFUN_171__(float(2), m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
		DrawStretchedTextureSegment(C, m_fHBorderPadding, __NFUN_175__(WinHeight, m_fHBorderHeight), __NFUN_175__(WinWidth, __NFUN_171__(float(2), m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
		DrawStretchedTextureSegment(C, m_fHBorderPadding, __NFUN_174__(m_fHBorderHeight, float(m_TextureRegion[0].H)), WinWidth, m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
	}
	// End:0x274
	if(__NFUN_119__(m_VBorderTexture, none))
	{
		DrawStretchedTextureSegment(C, 0.0000000, __NFUN_174__(m_fHBorderHeight, m_fVBorderPadding), m_fVBorderWidth, __NFUN_175__(__NFUN_175__(WinHeight, __NFUN_171__(float(2), m_fHBorderHeight)), __NFUN_171__(float(2), m_fVBorderPadding)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
		DrawStretchedTextureSegment(C, __NFUN_175__(WinWidth, m_fVBorderWidth), __NFUN_174__(m_fHBorderHeight, m_fVBorderPadding), m_fVBorderWidth, __NFUN_175__(__NFUN_175__(WinHeight, __NFUN_171__(float(2), m_fHBorderHeight)), __NFUN_171__(float(2), m_fVBorderPadding)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
	}
	C.__NFUN_2626__(byte(255), byte(255), byte(255));
	DrawStretchedTextureSegment(C, m_fVBorderWidth, m_fHBorderHeight, float(m_TextureRegion[0].W), float(m_TextureRegion[0].H), float(m_TextureRegion[0].X), float(m_TextureRegion[0].Y), float(m_TextureRegion[0].W), float(m_TextureRegion[0].H), m_Texture[0]);
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var g
