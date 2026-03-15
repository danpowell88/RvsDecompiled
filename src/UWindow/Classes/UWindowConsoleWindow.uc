//=============================================================================
// UWindowConsoleWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowConsoleWindow extends UWindowFramedWindow;

var float OldParentWidth;
// NEW IN 1.60
var float OldParentHeight;

function Created()
{
	super.Created();
	bSizable = true;
	bStatusBar = true;
	bLeaveOnscreen = true;
	OldParentWidth = ParentWindow.WinWidth;
	OldParentHeight = ParentWindow.WinHeight;
	SetDimensions();
	SetAcceptsFocus();
	return;
}

function ShowWindow()
{
	super(UWindowWindow).ShowWindow();
	// End:0x66
	if(((ParentWindow.WinWidth != OldParentWidth) || (ParentWindow.WinHeight != OldParentHeight)))
	{
		SetDimensions();
		OldParentWidth = ParentWindow.WinWidth;
		OldParentHeight = ParentWindow.WinHeight;
	}
	return;
}

function ResolutionChanged(float W, float H)
{
	SetDimensions();
	return;
}

function SetDimensions()
{
	// End:0x2D
	if((ParentWindow.WinWidth < float(500)))
	{
		SetSize(200.0000000, 150.0000000);		
	}
	else
	{
		SetSize(410.0000000, 310.0000000);
	}
	WinLeft = ((ParentWindow.WinWidth / float(2)) - (WinWidth / float(2)));
	WinTop = ((ParentWindow.WinHeight / float(2)) - (WinHeight / float(2)));
	return;
}

function Close(optional bool bByParent)
{
	ClientArea.Close(true);
	Root.Console.HideConsole();
	return;
}

defaultproperties
{
	ClientClass=Class'UWindow.UWindowConsoleClientWindow'
	WindowTitle="System Console"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
