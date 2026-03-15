//=============================================================================
// R6WindowBitMap - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6WindowBitMap extends UWindowBitmap;

var bool m_bUseColor;
var bool m_bDrawBorder;
var Color m_TextureColor;

function Paint(Canvas C, float X, float Y)
{
	// End:0x33
	if(m_bUseColor)
	{
		C.SetDrawColor(m_TextureColor.R, m_TextureColor.G, m_TextureColor.B);
	}
	super.Paint(C, X, Y);
	// End:0x5C
	if(m_bDrawBorder)
	{
		DrawSimpleBorder(C);
	}
	return;
}

