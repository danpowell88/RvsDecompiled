//=============================================================================
// R6WindowPopUpBoxCW - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6WindowPopUpBoxCW extends UWindowDialogClientWindow;

const C_fBUT_HEIGHT = 17;

var UWindowBase.MessageBoxButtons Buttons;
var UWindowBase.MessageBoxResult EnterResult;
// NEW IN 1.60
var UWindowBase.MessageBoxResult ESCResult;
var R6WindowPopUpButton m_pOKButton;
// NEW IN 1.60
var R6WindowPopUpButton m_pCancelButton;
var R6WindowButtonBox m_pDisablePopUpButton;

function KeyDown(int Key, float X, float Y)
{
	local R6WindowPopUpBox P;

	P = R6WindowPopUpBox(ParentWindow);
	// End:0x72
	if(__NFUN_130__(__NFUN_154__(Key, int(GetPlayerOwner().Player.Console.13)), __NFUN_155__(int(EnterResult), int(0))))
	{
		P.Result = EnterResult;
		P.Close();		
	}
	else
	{
		// End:0xBF
		if(__NFUN_154__(Key, int(GetPlayerOwner().Player.Console.27)))
		{
			P.Result = ESCResult;
			P.Close();
		}
	}
	return;
}

function Resized()
{
	return;
}

function SetupPopUpBoxClient(UWindowBase.MessageBoxButtons InButtons, UWindowBase.MessageBoxResult InESCResult, optional UWindowBase.MessageBoxResult InEnterResult)
{
	local float fXBut, fYBut, fWidthBut, fHeightBut;
	local bool bButtonsValid;

	fWidthBut = 23.0000000;
	fHeightBut = 17.0000000;
	Buttons = InButtons;
	EnterResult = InEnterResult;
	ESCResult = InESCResult;
	// End:0x51
	if(__NFUN_119__(m_pOKButton, none))
	{
		m_pOKButton.HideWindow();
	}
	// End:0x6B
	if(__NFUN_119__(m_pCancelButton, none))
	{
		m_pCancelButton.HideWindow();
	}
	bButtonsValid = true;
	switch(Buttons)
	{
		// End:0x23D
		case 1:
			fXBut = __NFUN_175__(__NFUN_175__(WinWidth, fWidthBut), float(20));
			// End:0xC8
			if(__NFUN_119__(m_pCancelButton, none))
			{
				m_pCancelButton.WinLeft = fXBut;
				m_pCancelButton.ShowWindow();				
			}
			else
			{
				fYBut = __NFUN_171__(__NFUN_175__(WinHeight, fHeightBut), 0.5000000);
				fYBut = float(int(__NFUN_174__(fYBut, 0.5000000)));
				m_pCancelButton = R6WindowPopUpButton(CreateControl(Class'R6Window.R6WindowPopUpButton', fXBut, fYBut, fWidthBut, fHeightBut));
				m_pCancelButton.ImageX = 2.0000000;
				m_pCancelButton.ImageY = 2.0000000;
				m_pCancelButton.m_bDrawRedBG = true;
				R6WindowLookAndFeel(LookAndFeel).Button_SetupEnumSignChoice(m_pCancelButton, 1);
			}
			fXBut = __NFUN_175__(__NFUN_175__(fXBut, fWidthBut), float(20));
			// End:0x1BD
			if(__NFUN_119__(m_pOKButton, none))
			{
				m_pOKButton.WinLeft = fXBut;
				m_pOKButton.ShowWindow();				
			}
			else
			{
				m_pOKButton = R6WindowPopUpButton(CreateControl(Class'R6Window.R6WindowPopUpButton', fXBut, fYBut, fWidthBut, fHeightBut));
				m_pOKButton.ImageX = 2.0000000;
				m_pOKButton.ImageY = 2.0000000;
				m_pOKButton.m_bDrawGreenBG = true;
				R6WindowLookAndFeel(LookAndFeel).Button_SetupEnumSignChoice(m_pOKButton, 0);
			}
			// End:0x414
			break;
		// End:0x309
		case 2:
			fXBut = __NFUN_175__(__NFUN_175__(WinWidth, fWidthBut), float(20));
			fYBut = __NFUN_171__(__NFUN_175__(WinHeight, fHeightBut), 0.5000000);
			fYBut = float(int(__NFUN_174__(fYBut, 0.5000000)));
			m_pOKButton = R6WindowPopUpButton(CreateControl(Class'R6Window.R6WindowPopUpButton', fXBut, fYBut, fWidthBut, fHeightBut));
			m_pOKButton.ImageX = 2.0000000;
			m_pOKButton.ImageY = 2.0000000;
			m_pOKButton.m_bDrawGreenBG = true;
			R6WindowLookAndFeel(LookAndFeel).Button_SetupEnumSignChoice(m_pOKButton, 0);
			// End:0x414
			break;
		// End:0x406
		case 4:
			fXBut = __NFUN_175__(__NFUN_175__(WinWidth, fWidthBut), float(20));
			// End:0x357
			if(__NFUN_119__(m_pCancelButton, none))
			{
				m_pCancelButton.WinLeft = fXBut;
				m_pCancelButton.ShowWindow();				
			}
			else
			{
				fYBut = __NFUN_171__(__NFUN_175__(WinHeight, fHeightBut), 0.5000000);
				fYBut = float(int(__NFUN_174__(fYBut, 0.5000000)));
				m_pCancelButton = R6WindowPopUpButton(CreateControl(Class'R6Window.R6WindowPopUpButton', fXBut, fYBut, fWidthBut, fHeightBut));
				m_pCancelButton.ImageX = 2.0000000;
				m_pCancelButton.ImageY = 2.0000000;
				m_pCancelButton.m_bDrawRedBG = true;
				R6WindowLookAndFeel(LookAndFeel).Button_SetupEnumSignChoice(m_pCancelButton, 1);
			}
			// End:0x414
			break;
		// End:0xFFFF
		default:
			bButtonsValid = false;
			// End:0x414
			break;
			break;
	}
	// End:0x423
	if(bButtonsValid)
	{
		SetAcceptsFocus();
	}
	return;
}

function AddDisablePopUpButton()
{
	local float fXBut, fYBut;

	// End:0xE6
	if(__NFUN_114__(m_pDisablePopUpButton, none))
	{
		fXBut = 5.0000000;
		fYBut = 0.0000000;
		fYBut = float(int(__NFUN_174__(fYBut, 0.5000000)));
		m_pDisablePopUpButton = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXBut, fYBut, WinWidth, WinHeight, self));
		m_pDisablePopUpButton.SetButtonBox(false);
		m_pDisablePopUpButton.CreateTextAndBox(Localize("POPUP", "DISABLEPOPUP", "R6Menu"), "", 0.0000000, int(R6WindowPopUpBox(ParentWindow).m_ePopUpID), true);
		m_pDisablePopUpButton.bAlwaysOnTop = true;
		m_pDisablePopUpButton.m_bResizeToText = true;		
	}
	else
	{
		m_pDisablePopUpButton.ShowWindow();
	}
	return;
}

function RemoveDisablePopUpButton()
{
	// End:0x1A
	if(__NFUN_119__(m_pDisablePopUpButton, none))
	{
		m_pDisablePopUpButton.HideWindow();
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6WindowPopUpBox P;

	P = R6WindowPopUpBox(ParentWindow);
	switch(E)
	{
		// End:0xC1
		case 2:
			// End:0x5E
			if(C.__NFUN_303__('R6WindowButtonBox'))
			{
				R6WindowButtonBox(C).m_bSelected = __NFUN_129__(R6WindowButtonBox(C).m_bSelected);				
			}
			else
			{
				switch(C)
				{
					// End:0x90
					case m_pOKButton:
						P.Result = 3;
						P.Close();
						// End:0xBE
						break;
					// End:0xBB
					case m_pCancelButton:
						P.Result = 4;
						P.Close();
						// End:0xBE
						break;
					// End:0xFFFF
					default:
						break;
				}
			}
			// End:0xC7
			break;
		// End:0xFFFF
		default:
			// End:0xC7
			break;
			break;
	}
	return;
}

