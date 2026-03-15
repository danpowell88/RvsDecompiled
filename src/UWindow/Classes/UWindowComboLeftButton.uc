//=============================================================================
// UWindowComboLeftButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowComboLeftButton extends UWindowButton;

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.Combo_SetupLeftButton(self);
	return;
}

function LMouseDown(float X, float Y)
{
	local int i;

	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x8F
	if((!bDisabled))
	{
		i = UWindowComboControl(OwnerWindow).GetSelectedIndex();
		(i--);
		// End:0x76
		if((i < 0))
		{
			i = (UWindowComboControl(OwnerWindow).List.Items.Count() - 1);
		}
		UWindowComboControl(OwnerWindow).SetSelectedIndex(i);
	}
	return;
}

