//=============================================================================
// UWindowTabControlLeftButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowTabControlLeftButton extends UWindowButton;

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.Tab_SetupLeftButton(self);
	return;
}

function LMouseDown(float X, float Y)
{
	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x39
	if((!bDisabled))
	{
		(UWindowTabControl(ParentWindow).TabArea.TabOffset--);
	}
	return;
}

