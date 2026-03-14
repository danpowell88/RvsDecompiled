//=============================================================================
// UWindowHotkeyWindowList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowHotkeyWindowList extends UWindowList;

var UWindowWindow Window;

function UWindowHotkeyWindowList FindWindow(UWindowWindow W)
{
	local UWindowHotkeyWindowList L;

	L = UWindowHotkeyWindowList(Next);
	J0x10:

	// End:0x55 [Loop If]
	if(__NFUN_119__(L, none))
	{
		// End:0x39
		if(__NFUN_114__(L.Window, W))
		{
			return L;
		}
		L = UWindowHotkeyWindowList(L.Next);
		// [Loop Continue]
		goto J0x10;
	}
	return none;
	return;
}

