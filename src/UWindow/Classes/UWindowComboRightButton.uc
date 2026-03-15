//=============================================================================
// UWindowComboRightButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowComboRightButton extends UWindowButton;

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.Combo_SetupRightButton(self);
	return;
}

function LMouseDown(float X, float Y)
{
	local int i;

	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x8C
	if((!bDisabled))
	{
		i = UWindowComboControl(OwnerWindow).GetSelectedIndex();
		(i++);
		// End:0x73
		if((i >= UWindowComboControl(OwnerWindow).List.Items.Count()))
		{
			i = 0;
		}
		UWindowComboControl(OwnerWindow).SetSelectedIndex(i);
	}
	return;
}

