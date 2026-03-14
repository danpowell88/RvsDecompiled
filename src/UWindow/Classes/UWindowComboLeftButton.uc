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
	if(__NFUN_129__(bDisabled))
	{
		i = UWindowComboControl(OwnerWindow).GetSelectedIndex();
		__NFUN_166__(i);
		// End:0x76
		if(__NFUN_150__(i, 0))
		{
			i = __NFUN_147__(UWindowComboControl(OwnerWindow).List.Items.Count(), 1);
		}
		UWindowComboControl(OwnerWindow).SetSelectedIndex(i);
	}
	return;
}

