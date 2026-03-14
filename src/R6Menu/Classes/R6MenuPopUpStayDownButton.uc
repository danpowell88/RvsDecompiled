//=============================================================================
// R6MenuPopUpStayDownButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MenuPopUpStayDownButton extends R6WindowButton;

var bool m_bSubMenu;

function Created()
{
	bNoKeyboard = true;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0xBF
	if(LookAndFeel.__NFUN_303__('R6MenuRSLookAndFeel'))
	{
		C.Font = m_buttonFont;
		// End:0x4E
		if(bDisabled)
		{
			R6MenuRSLookAndFeel(LookAndFeel).DrawPopupButtonDisable(self, C);			
		}
		else
		{
			// End:0x7F
			if(__NFUN_132__(bMouseDown, m_bSelected))
			{
				R6MenuRSLookAndFeel(LookAndFeel).DrawPopupButtonDown(self, C);				
			}
			else
			{
				// End:0xA5
				if(MouseIsOver())
				{
					R6MenuRSLookAndFeel(LookAndFeel).DrawPopupButtonOver(self, C);					
				}
				else
				{
					R6MenuRSLookAndFeel(LookAndFeel).DrawPopupButtonUp(self, C);
				}
			}
		}
	}
	return;
}

function LMouseDown(float X, float Y)
{
	local float fGlobalX, fGlobalY;

	// End:0x76
	if(__NFUN_129__(bDisabled))
	{
		GetMouseXY(fGlobalX, fGlobalY);
		WindowToGlobal(fGlobalX, fGlobalY, fGlobalX, fGlobalY);
		OwnerWindow.GlobalToWindow(fGlobalX, fGlobalY, fGlobalX, fGlobalY);
		R6WindowListRadio(OwnerWindow).SetSelected(fGlobalX, fGlobalY);
	}
	super(UWindowWindow).LMouseDown(X, Y);
	return;
}

function Tick(float fDelta)
{
	return;
}

