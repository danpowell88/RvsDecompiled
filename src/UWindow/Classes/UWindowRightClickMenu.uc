//=============================================================================
// UWindowRightClickMenu - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowRightClickMenu extends UWindowPulldownMenu;

function Created()
{
	bTransient = true;
	super.Created();
	return;
}

function RMouseDown(float X, float Y)
{
	LMouseDown(X, Y);
	return;
}

function RMouseUp(float X, float Y)
{
	LMouseUp(X, Y);
	return;
}

function CloseUp(optional bool bByOwner)
{
	super.CloseUp(bByOwner);
	HideWindow();
	return;
}

