//=============================================================================
// R6MenuOptionsMapKeys - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuOptionsMapKeys extends UWindowDialogControl;

var int m_iLastKeyPressed;
var R6WindowButton m_pCancelButton;

function Created()
{
	super.Created();
	m_pCancelButton = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', 180.0000000, 225.0000000, 280.0000000, 25.0000000, self));
	m_pCancelButton.ToolTipString = "";
	m_pCancelButton.Text = Localize("MultiPlayer", "PopUp_Cancel", "R6Menu");
	m_pCancelButton.Align = 2;
	m_pCancelButton.m_fFontSpacing = 0.0000000;
	m_pCancelButton.m_buttonFont = Root.Fonts[5];
	m_pCancelButton.ResizeToText();
	return;
}

function Register(UWindowDialogClientWindow W)
{
	super.Register(W);
	m_pCancelButton.Register(W);
	SetAcceptsFocus();
	m_pCancelButton.CancelAcceptsFocus();
	return;
}

function ShowWindow()
{
	SetAcceptsFocus();
	m_pCancelButton.CancelAcceptsFocus();
	super(UWindowWindow).ShowWindow();
	return;
}

function HideWindow()
{
	CancelAcceptsFocus();
	super(UWindowWindow).HideWindow();
	return;
}

function KeyDown(int Key, float X, float Y)
{
	m_iLastKeyPressed = Key;
	NotifyWindow.Notify(self, 2);
	return;
}

function LMouseDown(float X, float Y)
{
	super(UWindowWindow).LMouseDown(X, Y);
	m_iLastKeyPressed = int(GetPlayerOwner().Player.Console.1);
	NotifyWindow.Notify(self, 2);
	return;
}

function MMouseDown(float X, float Y)
{
	super(UWindowWindow).MMouseDown(X, Y);
	m_iLastKeyPressed = int(GetPlayerOwner().Player.Console.4);
	NotifyWindow.Notify(self, 2);
	return;
}

function RMouseDown(float X, float Y)
{
	super(UWindowWindow).RMouseDown(X, Y);
	m_iLastKeyPressed = int(GetPlayerOwner().Player.Console.2);
	NotifyWindow.Notify(self, 2);
	return;
}

function MouseWheelDown(float X, float Y)
{
	m_iLastKeyPressed = int(GetPlayerOwner().Player.Console.237);
	NotifyWindow.Notify(self, 2);
	return;
}

function MouseWheelUp(float X, float Y)
{
	m_iLastKeyPressed = int(GetPlayerOwner().Player.Console.236);
	NotifyWindow.Notify(self, 2);
	return;
}
