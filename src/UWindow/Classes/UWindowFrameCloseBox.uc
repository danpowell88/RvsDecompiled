//=============================================================================
// UWindowFrameCloseBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowFrameCloseBox extends UWindowButton;

function Created()
{
	bNoKeyboard = true;
	super.Created();
	return;
}

function Click(float X, float Y)
{
	ParentWindow.Close();
	return;
}

// No keyboard support
function KeyDown(int Key, float X, float Y)
{
	return;
}

