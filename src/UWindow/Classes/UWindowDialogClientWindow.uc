//=============================================================================
// UWindowDialogClientWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowDialogClientWindow extends UWindowClientWindow;

// Used for scrolling
var float DesiredWidth;
var float DesiredHeight;
var UWindowDialogControl TabLast;

function OKPressed()
{
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	return;
}

function UWindowDialogControl CreateControl(Class<UWindowDialogControl> ControlClass, float X, float Y, float W, float H, optional UWindowWindow OwnerWindow, optional bool _bNotTabRegister)
{
	local UWindowDialogControl C;

	C = UWindowDialogControl(CreateWindow(ControlClass, X, Y, W, H, OwnerWindow));
	C.Register(self);
	C.Notify(C.0);
	// End:0x112
	if(__NFUN_129__(_bNotTabRegister))
	{
		// End:0xA5
		if(__NFUN_114__(TabLast, none))
		{
			TabLast = C;
			C.TabNext = C;
			C.TabPrev = C;			
		}
		else
		{
			C.TabNext = TabLast.TabNext;
			C.TabPrev = TabLast;
			TabLast.TabNext.TabPrev = C;
			TabLast.TabNext = C;
			TabLast = C;
		}
	}
	return C;
	return;
}

function GetDesiredDimensions(out float W, out float H)
{
	W = DesiredWidth;
	H = DesiredHeight;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function Paint
