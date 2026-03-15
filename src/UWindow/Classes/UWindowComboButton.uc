//=============================================================================
// UWindowComboButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowComboButton extends UWindowButton;

var UWindowComboControl Owner;

function Created()
{
	super.Created();
	LookAndFeel.Combo_SetupButton(self);
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	bMouseDown = Owner.bListVisible;
	return;
}

function LMouseDown(float X, float Y)
{
	// End:0x5B
	if((!bDisabled))
	{
		// End:0x2F
		if(Owner.bListVisible)
		{
			Owner.CloseUp();			
		}
		else
		{
			Owner.DropDown();
			Root.CaptureMouse(Owner.List);
		}
	}
	return;
}

function Click(float X, float Y)
{
	return;
}

function FocusOtherWindow(UWindowWindow W)
{
	super(UWindowWindow).FocusOtherWindow(W);
	// End:0x95
	if((((Owner.bListVisible && (W.ParentWindow != Owner)) && (W.ParentWindow != Owner.List)) && (W.ParentWindow.ParentWindow != Owner.List)))
	{
		Owner.CloseUp();
	}
	return;
}

