//=============================================================================
// UWindowMessageBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowMessageBox extends UWindowFramedWindow;

var UWindowBase.MessageBoxResult Result;
var int TimeOut;
var int FrameCount;
var bool bSetupSize;
var float TimeOutTime;

function SetupMessageBox(string Title, string Message, UWindowBase.MessageBoxButtons Buttons, UWindowBase.MessageBoxResult InESCResult, optional UWindowBase.MessageBoxResult InEnterResult, optional int InTimeOut)
{
	WindowTitle = Title;
	UWindowMessageBoxCW(ClientArea).SetupMessageBoxClient(Message, Buttons, InEnterResult);
	Result = InESCResult;
	TimeOutTime = 0.0000000;
	TimeOut = InTimeOut;
	FrameCount = 0;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local Region R;

	// End:0xBC
	if((!bSetupSize))
	{
		SetSize(200.0000000, WinHeight);
		R = LookAndFeel.FW_GetClientArea(self);
		SetSize(200.0000000, ((WinHeight - float(R.H)) + UWindowMessageBoxCW(ClientArea).GetHeight(C)));
		WinLeft = float(int(((Root.WinWidth - WinWidth) / float(2))));
		WinTop = float(int(((Root.WinHeight - WinHeight) / float(2))));
		bSetupSize = true;
	}
	super.BeforePaint(C, X, Y);
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	super(UWindowWindow).AfterPaint(C, X, Y);
	// End:0x58
	if((TimeOut != 0))
	{
		(FrameCount++);
		// End:0x58
		if((FrameCount >= 5))
		{
			TimeOutTime = (GetEntryLevel().TimeSeconds + float(TimeOut));
			TimeOut = 0;
		}
	}
	// End:0x91
	if(((TimeOutTime != float(0)) && (GetEntryLevel().TimeSeconds > TimeOutTime)))
	{
		TimeOutTime = 0.0000000;
		Close();
	}
	return;
}

function Close(optional bool bByParent)
{
	super(UWindowWindow).Close(bByParent);
	OwnerWindow.MessageBoxDone(self, Result);
	return;
}

defaultproperties
{
	ClientClass=Class'UWindow.UWindowMessageBoxCW'
}
