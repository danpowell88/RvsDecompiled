//=============================================================================
// R6MenuMissionDescription - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MenuMissionDescription extends UWindowBitmap;

var float m_fHBorderHeight;
// NEW IN 1.60
var float m_fVBorderWidth;
var float m_fHBorderPadding;
// NEW IN 1.60
var float m_fVBorderPadding;
var Texture m_Texture;
var Sound m_MissionSound;
var Texture m_HBorderTexture;
// NEW IN 1.60
var Texture m_VBorderTexture;
var Region m_HBorderTextureRegion;
// NEW IN 1.60
var Region m_VBorderTextureRegion;

function Created()
{
	super(UWindowDialogControl).Created();
	m_Texture = Texture(DynamicLoadObject("R6BlackSnow.Mission.Wide_scr", Class'Engine.Texture'));
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = byte(m_BorderStyle);
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	// End:0x114
	if((m_HBorderTexture != none))
	{
		DrawStretchedTextureSegment(C, m_fHBorderPadding, 0.0000000, (WinWidth - (float(2) * m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
		DrawStretchedTextureSegment(C, m_fHBorderPadding, (WinHeight - m_fHBorderHeight), (WinWidth - (float(2) * m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
	}
	// End:0x210
	if((m_VBorderTexture != none))
	{
		DrawStretchedTextureSegment(C, 0.0000000, (m_fHBorderHeight + m_fVBorderPadding), m_fVBorderWidth, ((WinHeight - (float(2) * m_fHBorderHeight)) - (float(2) * m_fVBorderPadding)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
		DrawStretchedTextureSegment(C, (WinWidth - m_fVBorderWidth), (m_fHBorderHeight + m_fVBorderPadding), m_fVBorderWidth, ((WinHeight - (float(2) * m_fHBorderHeight)) - (float(2) * m_fVBorderPadding)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
	}
	C.SetDrawColor(byte(255), byte(255), byte(255));
	DrawStretchedTextureSegment(C, m_fVBorderWidth, m_fHBorderHeight, 434.0000000, 226.0000000, 0.0000000, 0.0000000, 434.0000000, 226.0000000, m_Texture);
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var g
