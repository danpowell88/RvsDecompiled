//=============================================================================
// R6WindowconfirmationButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6WindowconfirmationButton extends R6WindowButton;

function Paint(Canvas C, float X, float Y)
{
	// End:0x22
	if((m_buttonFont != none))
	{
		C.Font = m_buttonFont;		
	}
	else
	{
		C.Font = Root.Fonts[Font];
	}
	super.Paint(C, X, Y);
	C.Style = 1;
	R6WindowLookAndFeel(LookAndFeel).DrawButtonBorder(self, C);
	return;
}

