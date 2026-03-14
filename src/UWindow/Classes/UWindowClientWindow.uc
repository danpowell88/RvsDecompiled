//=============================================================================
// UWindowClientWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UWindowClientWindow - a blanked client-area window.
//=============================================================================
class UWindowClientWindow extends UWindowWindow;

function Close(optional bool bByParent)
{
	// End:0x20
	if(__NFUN_129__(bByParent))
	{
		ParentWindow.Close(bByParent);
	}
	super.Close(bByParent);
	return;
}

