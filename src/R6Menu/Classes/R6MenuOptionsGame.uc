//=============================================================================
// R6MenuOptionsGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuOptionsGame extends R6MenuOptionsTab;

var int m_iRefMouseSens;
var R6WindowButtonBox m_pOptionAlwaysRun;
var R6WindowButtonBox m_pOptionInvertMouse;
var R6WindowButtonBox m_pPopUpLoadPlan;
var R6WindowButtonBox m_pPopUpQuickPlay;
var R6WindowTextureBrowser m_pAutoAim;
var Texture m_pAutoAimTexture;
var R6WindowHScrollbar m_pOptionMouseSens;
var Region m_pAutoAimTextReg[4];

function InitPageOptions()
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp,
		fSizeOfCounter, fXRightOffset;

	local Font ButtonFont;
	local int iAutoAimBitmapHeight, iAutoAimVPadding, iSBButtonWidth;

	ButtonFont = Root.Fonts[5];
	fXOffset = 5.0000000;
	fXRightOffset = 26.0000000;
	fYOffset = 5.0000000;
	fWidth = ((WinWidth - fXOffset) - float(40));
	fHeight = 15.0000000;
	fYStep = 27.0000000;
	iSBButtonWidth = 14;
	iAutoAimBitmapHeight = 73;
	iAutoAimVPadding = 5;
	m_pOptionAlwaysRun = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pOptionAlwaysRun.SetButtonBox(false);
	m_pOptionAlwaysRun.CreateTextAndBox(Localize("Options", "Opt_GameAlways", "R6Menu"), Localize("Tip", "Opt_GameAlways", "R6Menu"), 0.0000000, 2);
	(fYOffset += fYStep);
	m_pOptionInvertMouse = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pOptionInvertMouse.SetButtonBox(false);
	m_pOptionInvertMouse.CreateTextAndBox(Localize("Options", "Opt_GameInvertM", "R6Menu"), Localize("Tip", "Opt_GameInvertM", "R6Menu"), 0.0000000, 3);
	(fYOffset += fYStep);
	m_pOptionMouseSens = R6WindowHScrollbar(CreateControl(Class'R6Window.R6WindowHScrollbar', fXOffset, fYOffset, ((WinWidth - fXOffset) - fXRightOffset), 14.0000000, self));
	m_pOptionMouseSens.CreateSB(0, 250.0000000, 0.0000000, 140.0000000, 14.0000000, self);
	m_pOptionMouseSens.CreateSBTextLabel(Localize("Options", "Opt_GameMouseSens", "R6Menu"), Localize("Tip", "Opt_GameMouseSens", "R6Menu"));
	m_pOptionMouseSens.SetScrollBarRange(0.0000000, 120.0000000, 20.0000000);
	(fYOffset += fYStep);
	m_pPopUpLoadPlan = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pPopUpLoadPlan.SetButtonBox(false);
	m_pPopUpLoadPlan.CreateTextAndBox(Localize("Options", "Opt_GamePopUpLoadPlan", "R6Menu"), Localize("Tip", "Opt_GamePopUpLoadPlan", "R6Menu"), 0.0000000, 5);
	(fYOffset += fYStep);
	m_pPopUpQuickPlay = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pPopUpQuickPlay.SetButtonBox(false);
	m_pPopUpQuickPlay.CreateTextAndBox(Localize("Options", "Opt_GamePopUpQuickPlay", "R6Menu"), Localize("Tip", "Opt_GamePopUpQuickPlay", "R6Menu"), 0.0000000, 5);
	(fYOffset += fYStep);
	m_pAutoAim = R6WindowTextureBrowser(CreateWindow(Class'R6Window.R6WindowTextureBrowser', fXOffset, fYOffset, (WinWidth - fXOffset), ((14.0000000 + float(iAutoAimBitmapHeight)) + float(iAutoAimVPadding)), self));
	m_pAutoAim.CreateSB(250, int((m_pAutoAim.WinHeight - float(14))), 140, 14);
	m_pAutoAim.CreateBitmap((250 + iSBButtonWidth), 0, (140 - (2 * iSBButtonWidth)), iAutoAimBitmapHeight);
	m_pAutoAim.SetBitmapProperties(false, true, 5, false);
	m_pAutoAim.SetBitmapBorder(true, Root.Colors.White);
	m_pAutoAim.CreateTextLabel(0, 0, int((m_pAutoAim.WinWidth - m_pAutoAim.m_CurrentSelection.WinLeft)), int(m_pAutoAim.WinHeight), Localize("Options", "Opt_AutoTarget", "R6Menu"), Localize("Tip", "Opt_AutoTarget", "R6Menu"));
	m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[0]);
	m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[1]);
	m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[2]);
	m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[3]);
	InitResetButton();
	UpdateOptionsInPage();
	m_bInitComplete = true;
	return;
}

function UpdateOptionsInEngine()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	pGameOptions.AlwaysRun = m_pOptionAlwaysRun.m_bSelected;
	pGameOptions.InvertMouse = m_pOptionInvertMouse.m_bSelected;
	pGameOptions.PopUpLoadPlan = m_pPopUpLoadPlan.m_bSelected;
	pGameOptions.PopUpQuickPlay = m_pPopUpQuickPlay.m_bSelected;
	pGameOptions.AutoTargetSlider = m_pAutoAim.GetCurrentTextureIndex();
	pGameOptions.MouseSensitivity = m_pOptionMouseSens.GetScrollBarValue();
	return;
}

function UpdateOptionsInPage()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	m_pOptionAlwaysRun.SetButtonBox(pGameOptions.AlwaysRun);
	m_pOptionInvertMouse.SetButtonBox(pGameOptions.InvertMouse);
	m_pPopUpLoadPlan.SetButtonBox(pGameOptions.PopUpLoadPlan);
	m_pPopUpQuickPlay.SetButtonBox(pGameOptions.PopUpQuickPlay);
	m_pAutoAim.SetCurrentTextureFromIndex(pGameOptions.AutoTargetSlider);
	m_pOptionMouseSens.SetScrollBarValue(pGameOptions.MouseSensitivity);
	return;
}

function RestoreDefaultValue()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	pGameOptions.ResetGameToDefault();
	UpdateOptionsInPage();
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6MenuOptionsWidget OptionsWidget;
	local bool bUpdateGameOptions;
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	OptionsWidget = R6MenuOptionsWidget(OwnerWindow);
	// End:0x120
	if((int(E) == 2))
	{
		// End:0x91
		if(C.IsA('R6WindowButtonBox'))
		{
			// End:0x8E
			if(R6WindowButtonBox(C).GetSelectStatus())
			{
				R6WindowButtonBox(C).m_bSelected = (!R6WindowButtonBox(C).m_bSelected);
				bUpdateGameOptions = true;
			}			
		}
		else
		{
			// End:0x11D
			if(C.IsA('R6WindowButton'))
			{
				// End:0x11D
				if((C == m_pGeneralButUse))
				{
					Root.SimplePopUp(Localize("Options", "ResetToDefault", "R6Menu"), Localize("Options", "ResetToDefaultConfirm", "R6Menu"), 55, 0, false, self);
				}
			}
		}		
	}
	else
	{
		// End:0x1B8
		if(C.IsA('UWindowHScrollbar'))
		{
			// End:0x17F
			if((int(E) == 9))
			{
				// End:0x17C
				if((float(m_iRefMouseSens) != m_pOptionMouseSens.GetScrollBarValue()))
				{
					m_iRefMouseSens = int(m_pOptionMouseSens.GetScrollBarValue());
					bUpdateGameOptions = true;
				}				
			}
			else
			{
				// End:0x1B5
				if(((int(E) == 1) && m_bInitComplete))
				{
					pGameOptions.MouseSensitivity = m_pOptionMouseSens.GetScrollBarValue();
				}
			}			
		}
		else
		{
			// End:0x203
			if(C.IsA('R6WindowComboControl'))
			{
				// End:0x203
				if((int(E) == 1))
				{
					// End:0x203
					if((m_bInitComplete && R6WindowComboControl(C).m_bSelectedByUser))
					{
						bUpdateGameOptions = true;
					}
				}
			}
		}
	}
	// End:0x21E
	if(bUpdateGameOptions)
	{
		UpdateOptionsInEngine();
		pGameOptions.SaveConfig();
	}
	return;
}

defaultproperties
{
	m_pAutoAimTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_pAutoAimTextReg[0]=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=26658,ZoneNumber=0)
	m_pAutoAimTextReg[1]=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=45346,ZoneNumber=0)
	m_pAutoAimTextReg[2]=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=64034,ZoneNumber=0)
	m_pAutoAimTextReg[3]=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=82722,ZoneNumber=0)
}