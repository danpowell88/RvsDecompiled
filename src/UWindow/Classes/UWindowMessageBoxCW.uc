//=============================================================================
// UWindowMessageBoxCW - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowMessageBoxCW extends UWindowDialogClientWindow;

var UWindowBase.MessageBoxButtons Buttons;
var UWindowBase.MessageBoxResult EnterResult;
var UWindowSmallButton YesButton;
// NEW IN 1.60
var UWindowSmallButton NoButton;
// NEW IN 1.60
var UWindowSmallButton OKButton;
// NEW IN 1.60
var UWindowSmallButton CancelButton;
var UWindowMessageBoxArea MessageArea;
var localized string YesText;
// NEW IN 1.60
var localized string NoText;
// NEW IN 1.60
var localized string OKText;
// NEW IN 1.60
var localized string CancelText;

function Created()
{
	super(UWindowWindow).Created();
	SetAcceptsFocus();
	MessageArea = UWindowMessageBoxArea(CreateWindow(Class'UWindow.UWindowMessageBoxArea', 10.0000000, 10.0000000, (WinWidth - float(20)), (WinHeight - float(44))));
	return;
}

function KeyDown(int Key, float X, float Y)
{
	local UWindowMessageBox P;

	P = UWindowMessageBox(ParentWindow);
	// End:0x7F
	if(((Key == int(GetPlayerOwner().Player.Console.13)) && (int(EnterResult) != int(0))))
	{
		P = UWindowMessageBox(ParentWindow);
		P.Result = EnterResult;
		P.Close();
	}
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	super(UWindowWindow).BeforePaint(C, X, Y);
	MessageArea.SetSize((WinWidth - float(20)), (WinHeight - float(44)));
	switch(Buttons)
	{
		// End:0xE5
		case 3:
			CancelButton.WinLeft = (WinWidth - float(52));
			CancelButton.WinTop = (WinHeight - float(20));
			NoButton.WinLeft = (WinWidth - float(104));
			NoButton.WinTop = (WinHeight - float(20));
			YesButton.WinLeft = (WinWidth - float(156));
			YesButton.WinTop = (WinHeight - float(20));
			// End:0x204
			break;
		// End:0x155
		case 0:
			NoButton.WinLeft = (WinWidth - float(52));
			NoButton.WinTop = (WinHeight - float(20));
			YesButton.WinLeft = (WinWidth - float(104));
			YesButton.WinTop = (WinHeight - float(20));
			// End:0x204
			break;
		// End:0x1C5
		case 1:
			CancelButton.WinLeft = (WinWidth - float(52));
			CancelButton.WinTop = (WinHeight - float(20));
			OKButton.WinLeft = (WinWidth - float(104));
			OKButton.WinTop = (WinHeight - float(20));
			// End:0x204
			break;
		// End:0x201
		case 2:
			OKButton.WinLeft = (WinWidth - float(52));
			OKButton.WinTop = (WinHeight - float(20));
			// End:0x204
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function Resized()
{
	super(UWindowWindow).Resized();
	MessageArea.SetSize((WinWidth - float(20)), (WinHeight - float(44)));
	return;
}

function float GetHeight(Canvas C)
{
	return (44.0000000 + MessageArea.GetHeight(C));
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture t;

	super(UWindowWindow).Paint(C, X, Y);
	t = GetLookAndFeelTexture();
	DrawUpBevel(C, 0.0000000, (WinHeight - float(24)), WinWidth, 24.0000000, t);
	return;
}

function SetupMessageBoxClient(string InMessage, UWindowBase.MessageBoxButtons InButtons, UWindowBase.MessageBoxResult InEnterResult)
{
	MessageArea.Message = InMessage;
	Buttons = InButtons;
	EnterResult = InEnterResult;
	switch(Buttons)
	{
		// End:0x1B0
		case 3:
			CancelButton = UWindowSmallButton(CreateControl(Class'UWindow.UWindowSmallButton', (WinWidth - float(52)), (WinHeight - float(20)), 48.0000000, 16.0000000));
			CancelButton.SetText(CancelText);
			// End:0xA3
			if((int(EnterResult) == int(4)))
			{
				CancelButton.SetFont(1);				
			}
			else
			{
				CancelButton.SetFont(0);
			}
			NoButton = UWindowSmallButton(CreateControl(Class'UWindow.UWindowSmallButton', (WinWidth - float(104)), (WinHeight - float(20)), 48.0000000, 16.0000000));
			NoButton.SetText(NoText);
			// End:0x120
			if((int(EnterResult) == int(2)))
			{
				NoButton.SetFont(1);				
			}
			else
			{
				NoButton.SetFont(0);
			}
			YesButton = UWindowSmallButton(CreateControl(Class'UWindow.UWindowSmallButton', (WinWidth - float(156)), (WinHeight - float(20)), 48.0000000, 16.0000000));
			YesButton.SetText(YesText);
			// End:0x19D
			if((int(EnterResult) == int(1)))
			{
				YesButton.SetFont(1);				
			}
			else
			{
				YesButton.SetFont(0);
			}
			// End:0x43C
			break;
		// End:0x2B2
		case 0:
			NoButton = UWindowSmallButton(CreateControl(Class'UWindow.UWindowSmallButton', (WinWidth - float(52)), (WinHeight - float(20)), 48.0000000, 16.0000000));
			NoButton.SetText(NoText);
			// End:0x222
			if((int(EnterResult) == int(2)))
			{
				NoButton.SetFont(1);				
			}
			else
			{
				NoButton.SetFont(0);
			}
			YesButton = UWindowSmallButton(CreateControl(Class'UWindow.UWindowSmallButton', (WinWidth - float(104)), (WinHeight - float(20)), 48.0000000, 16.0000000));
			YesButton.SetText(YesText);
			// End:0x29F
			if((int(EnterResult) == int(1)))
			{
				YesButton.SetFont(1);				
			}
			else
			{
				YesButton.SetFont(0);
			}
			// End:0x43C
			break;
		// End:0x3B4
		case 1:
			CancelButton = UWindowSmallButton(CreateControl(Class'UWindow.UWindowSmallButton', (WinWidth - float(52)), (WinHeight - float(20)), 48.0000000, 16.0000000));
			CancelButton.SetText(CancelText);
			// End:0x324
			if((int(EnterResult) == int(4)))
			{
				CancelButton.SetFont(1);				
			}
			else
			{
				CancelButton.SetFont(0);
			}
			OKButton = UWindowSmallButton(CreateControl(Class'UWindow.UWindowSmallButton', (WinWidth - float(104)), (WinHeight - float(20)), 48.0000000, 16.0000000));
			OKButton.SetText(OKText);
			// End:0x3A1
			if((int(EnterResult) == int(3)))
			{
				OKButton.SetFont(1);				
			}
			else
			{
				OKButton.SetFont(0);
			}
			// End:0x43C
			break;
		// End:0x439
		case 2:
			OKButton = UWindowSmallButton(CreateControl(Class'UWindow.UWindowSmallButton', (WinWidth - float(52)), (WinHeight - float(20)), 48.0000000, 16.0000000));
			OKButton.SetText(OKText);
			// End:0x426
			if((int(EnterResult) == int(3)))
			{
				OKButton.SetFont(1);				
			}
			else
			{
				OKButton.SetFont(0);
			}
			// End:0x43C
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local UWindowMessageBox P;

	P = UWindowMessageBox(ParentWindow);
	// End:0xD4
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0x50
			case YesButton:
				P.Result = 1;
				P.Close();
				// End:0xD4
				break;
			// End:0x7B
			case NoButton:
				P.Result = 2;
				P.Close();
				// End:0xD4
				break;
			// End:0xA6
			case OKButton:
				P.Result = 3;
				P.Close();
				// End:0xD4
				break;
			// End:0xD1
			case CancelButton:
				P.Result = 4;
				P.Close();
				// End:0xD4
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

defaultproperties
{
	YesText="YES"
	NoText="NO"
	OKText="OK"
	CancelText="CANCEL"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var t
