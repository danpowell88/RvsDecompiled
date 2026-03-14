//=============================================================================
// R6MenuOptionsMulti - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuOptionsMulti extends R6MenuOptionsTab;

var bool m_bPBNotInstalled;
var bool m_bPBWaitForInit;
var R6WindowEditControl m_pOptionPlayerName;
var R6WindowComboControl m_pSpeedConnection;
var R6WindowButtonExt m_pOptionGender;
var R6MenuArmpatchSelect m_pArmpatchChooser;
var R6WindowButtonBox m_bTriggerLagWanted;
var R6WindowButtonBox m_pPunkBusterOpt;
var Region m_RArmpatchBitmapPos;
var Region m_RArmpatchListPos;
var string m_pConnectionSpeed[5];

function Created()
{
	super.Created();
	m_pConnectionSpeed[0] = Localize("Options", "Opt_NetSpeedT1", "R6Menu");
	m_pConnectionSpeed[1] = Localize("Options", "Opt_NetSpeedT3", "R6Menu");
	m_pConnectionSpeed[2] = Localize("Options", "Opt_NetSpeedCable", "R6Menu");
	m_pConnectionSpeed[3] = Localize("Options", "Opt_NetSpeedADSL", "R6Menu");
	m_pConnectionSpeed[4] = Localize("Options", "Opt_NetSpeedModem", "R6Menu");
	return;
}

function InitPageOptions()
{
	local Region rRegionW;
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp,
		fSizeOfCounter;

	local Font ButtonFont;

	ButtonFont = Root.Fonts[5];
	fXOffset = 5.0000000;
	fYOffset = 5.0000000;
	fWidth = __NFUN_175__(__NFUN_175__(WinWidth, fXOffset), float(20));
	fHeight = 15.0000000;
	fYStep = 27.0000000;
	m_pOptionPlayerName = R6WindowEditControl(CreateWindow(Class'R6Window.R6WindowEditControl', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pOptionPlayerName.SetValue("");
	m_pOptionPlayerName.CreateTextLabel(Localize("Options", "Opt_NetPlayerName", "R6Menu"), 0.0000000, 0.0000000, __NFUN_171__(fWidth, 0.5000000), fHeight);
	m_pOptionPlayerName.SetEditBoxTip(Localize("Tip", "Opt_NetPlayerName", "R6Menu"));
	m_pOptionPlayerName.ModifyEditBoxW(250.0000000, 0.0000000, 135.0000000, fHeight);
	m_pOptionPlayerName.EditBox.MaxLength = 15;
	__NFUN_184__(fYOffset, fYStep);
	rRegionW.X = int(fXOffset);
	rRegionW.Y = int(fYOffset);
	rRegionW.W = int(fWidth);
	rRegionW.H = int(fHeight);
	m_pSpeedConnection = SetComboControlButton(rRegionW, Localize("Options", "Opt_NetConnecSpeed", "R6Menu"), Localize("Tip", "Opt_NetConnecSpeed", "R6Menu"));
	m_pSpeedConnection.AddItem(m_pConnectionSpeed[0], "");
	m_pSpeedConnection.AddItem(m_pConnectionSpeed[1], "");
	m_pSpeedConnection.AddItem(m_pConnectionSpeed[2], "");
	m_pSpeedConnection.AddItem(m_pConnectionSpeed[3], "");
	m_pSpeedConnection.AddItem(m_pConnectionSpeed[4], "");
	__NFUN_184__(fYOffset, fYStep);
	__NFUN_185__(fWidth, float(20));
	m_pOptionGender = R6WindowButtonExt(CreateControl(Class'R6Window.R6WindowButtonExt', fXOffset, fYOffset, __NFUN_175__(WinWidth, fXOffset), fHeight, self));
	m_pOptionGender.CreateTextAndBox(Localize("Options", "Opt_NetGender", "R6Menu"), Localize("Tip", "Opt_NetGender", "R6Menu"), 0.0000000, 0, 2);
	m_pOptionGender.SetCheckBox(Localize("Options", "Opt_NetGenderMale", "R6Menu"), 250.0000000, true, 0);
	m_pOptionGender.SetCheckBox(Localize("Options", "Opt_NetGenderFemale", "R6Menu"), 356.0000000, false, 1);
	__NFUN_184__(fYOffset, fYStep);
	m_pArmpatchChooser = R6MenuArmpatchSelect(CreateWindow(Class'R6Menu.R6MenuArmpatchSelect', fXOffset, fYOffset, __NFUN_175__(WinWidth, fXOffset), float(m_RArmpatchListPos.H), self));
	m_pArmpatchChooser.CreateTextLabel(0, 0, m_RArmpatchListPos.X, int(m_pArmpatchChooser.WinHeight), Localize("Options", "Opt_NetUArmP", "R6Menu"), Localize("Tip", "Opt_NetUArmP", "R6Menu"));
	m_pArmpatchChooser.CreateListBox(m_RArmpatchListPos.X, m_RArmpatchListPos.Y, m_RArmpatchListPos.W, m_RArmpatchListPos.H);
	m_pArmpatchChooser.CreateArmPatchBitmap(m_RArmpatchBitmapPos.X, m_RArmpatchBitmapPos.Y, m_RArmpatchBitmapPos.W, m_RArmpatchBitmapPos.H);
	m_pArmpatchChooser.RefreshListBox();
	m_pArmpatchChooser.SetToolTip(Localize("Tip", "Opt_NetUArmP", "R6Menu"));
	fYOffset = __NFUN_174__(__NFUN_174__(m_pArmpatchChooser.WinTop, m_pArmpatchChooser.WinHeight), float(15));
	m_pPunkBusterOpt = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pPunkBusterOpt.SetButtonBox(false);
	m_pPunkBusterOpt.CreateTextAndBox(Localize("Options", "Opt_NetPunkBuster", "R6Menu"), Localize("Tip", "Opt_NetPunkBuster", "R6Menu"), 0.0000000, 0);
	m_pPunkBusterOpt.m_szToolTipWhenDisable = Localize("Tip", "Opt_NetPunkBuster", "R6Menu");
	__NFUN_184__(fYOffset, fYStep);
	m_bTriggerLagWanted = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_bTriggerLagWanted.SetButtonBox(false);
	m_bTriggerLagWanted.CreateTextAndBox(Localize("Options", "Opt_TriggerLag", "R6Menu"), Localize("Tip", "Opt_TriggerLag", "R6Menu"), 0.0000000, 2);
	InitResetButton();
	UpdateOptionsInPage();
	m_bInitComplete = true;
	return;
}

function UpdateOptionsInEngine()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	// End:0x81
	if(__NFUN_123__(m_pOptionPlayerName.GetValue(), m_pOptionPlayerName.GetValue2()))
	{
		GetPlayerOwner().Name(m_pOptionPlayerName.GetValue());
		m_pOptionPlayerName.SetValue(m_pOptionPlayerName.GetValue(), m_pOptionPlayerName.GetValue());
	}
	pGameOptions.NetSpeed = ConvertToNSEnum(m_pSpeedConnection.GetValue());
	switch(pGameOptions.NetSpeed)
	{
		// End:0xE5
		case 0:
			Root.Console.ConsoleCommand("NETSPEED 20000");
			// End:0x1CF
			break;
		// End:0x115
		case 1:
			Root.Console.ConsoleCommand("NETSPEED 20000");
			// End:0x1CF
			break;
		// End:0x144
		case 2:
			Root.Console.ConsoleCommand("NETSPEED 4000");
			// End:0x1CF
			break;
		// End:0x173
		case 3:
			Root.Console.ConsoleCommand("NETSPEED 5000");
			// End:0x1CF
			break;
		// End:0x1A2
		case 4:
			Root.Console.ConsoleCommand("NETSPEED 1500");
			// End:0x1CF
			break;
		// End:0xFFFF
		default:
			Root.Console.ConsoleCommand("NETSPEED 5000");
			// End:0x1CF
			break;
			break;
	}
	pGameOptions.Gender = m_pOptionGender.GetCheckBoxStatus();
	pGameOptions.ArmPatchTexture = m_pArmpatchChooser.GetSelectedArmpatch();
	pGameOptions.ActivePunkBuster = m_pPunkBusterOpt.m_bSelected;
	pGameOptions.WantTriggerLag = __NFUN_129__(m_bTriggerLagWanted.m_bSelected);
	return;
}

function UpdateOptionsInPage()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	// End:0x4B
	if(__NFUN_129__(m_bInitComplete))
	{
		m_pOptionPlayerName.SetValue(pGameOptions.characterName, pGameOptions.characterName);		
	}
	else
	{
		m_pOptionPlayerName.SetValue(pGameOptions.characterName, m_pOptionPlayerName.GetValue2());
	}
	m_pOptionPlayerName.EditBox.MoveHome();
	m_pSpeedConnection.SetValue(ConvertToNetSpeedString(int(pGameOptions.NetSpeed)));
	m_pOptionGender.SetCheckBoxStatus(pGameOptions.Gender);
	m_pArmpatchChooser.SetDesiredSelectedArmpatch(pGameOptions.ArmPatchTexture);
	// End:0x156
	if(m_bInitComplete)
	{
		// End:0x138
		if(__NFUN_243__(pGameOptions.ActivePunkBuster, Class'Engine.Actor'.static.__NFUN_1400__()))
		{
			pGameOptions.ActivePunkBuster = __NFUN_129__(pGameOptions.ActivePunkBuster);
		}
		m_pPunkBusterOpt.SetButtonBox(pGameOptions.ActivePunkBuster);
	}
	m_bTriggerLagWanted.SetButtonBox(__NFUN_129__(pGameOptions.WantTriggerLag));
	return;
}

function SetPBOptValue()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	// End:0xA0
	if(pGameOptions.m_bPBInstalled)
	{
		// End:0x80
		if(pGameOptions.ActivePunkBuster)
		{
			// End:0x7D
			if(__NFUN_129__(Class'Engine.Actor'.static.__NFUN_1400__()))
			{
				Class'Engine.Actor'.static.__NFUN_1401__(false, false);
				// End:0x7D
				if(__NFUN_129__(Class'Engine.Actor'.static.__NFUN_1400__()))
				{
					SetPBOptDisable();
					pGameOptions.ActivePunkBuster = false;
				}
			}			
		}
		else
		{
			// End:0x9D
			if(Class'Engine.Actor'.static.__NFUN_1400__())
			{
				Class'Engine.Actor'.static.__NFUN_1401__(true, false);
			}
		}		
	}
	else
	{
		SetPBOptDisable();
		pGameOptions.ActivePunkBuster = false;
	}
	m_pPunkBusterOpt.SetButtonBox(pGameOptions.ActivePunkBuster);
	return;
}

function SetPBOptDisable()
{
	m_bPBNotInstalled = true;
	m_pPunkBusterOpt.bDisabled = true;
	return;
}

function Tick(float DeltaTime)
{
	// End:0x19
	if(__NFUN_129__(m_bPBWaitForInit))
	{
		m_bPBWaitForInit = true;
		SetPBOptValue();
	}
	// End:0x66
	if(__NFUN_130__(bWindowVisible, __NFUN_243__(m_pPunkBusterOpt.m_bSelected, Class'Engine.Actor'.static.__NFUN_1400__())))
	{
		__NFUN_231__("Tick UpdateOptionsInPage");
		UpdateOptionsInPage();
	}
	return;
}

function R6GameOptions.EGameOptionsNetSpeed ConvertToNSEnum(string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsNetSpeed eNSResult;

	switch(_szValueToConvert)
	{
		// End:0x1C
		case m_pConnectionSpeed[0]:
			eNSResult = 0;
			// End:0x81
			break;
		// End:0x31
		case m_pConnectionSpeed[1]:
			eNSResult = 1;
			// End:0x81
			break;
		// End:0x47
		case m_pConnectionSpeed[2]:
			eNSResult = 2;
			// End:0x81
			break;
		// End:0x5D
		case m_pConnectionSpeed[3]:
			eNSResult = 3;
			// End:0x81
			break;
		// End:0x73
		case m_pConnectionSpeed[4]:
			eNSResult = 4;
			// End:0x81
			break;
		// End:0xFFFF
		default:
			eNSResult = 0;
			// End:0x81
			break;
			break;
	}
	return eNSResult;
	return;
}

function string ConvertToNetSpeedString(int _iValueToConvert)
{
	local string szResult;

	switch(_iValueToConvert)
	{
		// End:0x1B
		case 0:
			szResult = m_pConnectionSpeed[0];
			// End:0x84
			break;
		// End:0x2F
		case 1:
			szResult = m_pConnectionSpeed[1];
			// End:0x84
			break;
		// End:0x45
		case 2:
			szResult = m_pConnectionSpeed[2];
			// End:0x84
			break;
		// End:0x5B
		case 3:
			szResult = m_pConnectionSpeed[3];
			// End:0x84
			break;
		// End:0x71
		case 4:
			szResult = m_pConnectionSpeed[4];
			// End:0x84
			break;
		// End:0xFFFF
		default:
			szResult = m_pConnectionSpeed[0];
			// End:0x84
			break;
			break;
	}
	return szResult;
	return;
}

function RestoreDefaultValue()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	pGameOptions.ResetMultiToDefault();
	UpdateOptionsInPage();
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6MenuOptionsWidget OptionsWidget;
	local bool bUpdateGameOptions;
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	OptionsWidget = R6MenuOptionsWidget(OwnerWindow);
	// End:0x17A
	if(__NFUN_154__(int(E), 2))
	{
		// End:0xA1
		if(C.__NFUN_303__('R6WindowButtonBox'))
		{
			// End:0x8E
			if(R6WindowButtonBox(C).GetSelectStatus())
			{
				R6WindowButtonBox(C).m_bSelected = __NFUN_129__(R6WindowButtonBox(C).m_bSelected);
				bUpdateGameOptions = true;
			}
			ManageNotifyForNetwork(C, E);			
		}
		else
		{
			// End:0xEB
			if(C.__NFUN_303__('R6WindowButtonExt'))
			{
				// End:0xE8
				if(R6WindowButtonExt(C).GetSelectStatus())
				{
					R6WindowButtonExt(C).ChangeCheckBoxStatus();
					bUpdateGameOptions = true;
				}				
			}
			else
			{
				// End:0x177
				if(C.__NFUN_303__('R6WindowButton'))
				{
					// End:0x177
					if(__NFUN_114__(C, m_pGeneralButUse))
					{
						Root.SimplePopUp(Localize("Options", "ResetToDefault", "R6Menu"), Localize("Options", "ResetToDefaultConfirm", "R6Menu"), 55, 0, false, self);
					}
				}
			}
		}		
	}
	else
	{
		// End:0x1C5
		if(C.__NFUN_303__('R6WindowComboControl'))
		{
			// End:0x1C5
			if(__NFUN_154__(int(E), 1))
			{
				// End:0x1C5
				if(__NFUN_130__(m_bInitComplete, R6WindowComboControl(C).m_bSelectedByUser))
				{
					bUpdateGameOptions = true;
				}
			}
		}
	}
	// End:0x1E0
	if(bUpdateGameOptions)
	{
		UpdateOptionsInEngine();
		pGameOptions.__NFUN_536__();
	}
	return;
}

function ManageNotifyForNetwork(UWindowDialogControl C, byte E)
{
	// End:0x6C
	if(__NFUN_114__(C, m_pPunkBusterOpt))
	{
		// End:0x5E
		if(R6WindowButtonBox(C).m_bSelected)
		{
			Class'Engine.Actor'.static.__NFUN_1401__(false, false);
			// End:0x5B
			if(__NFUN_129__(Class'Engine.Actor'.static.__NFUN_1400__()))
			{
				R6WindowButtonBox(C).m_bSelected = false;
			}			
		}
		else
		{
			Class'Engine.Actor'.static.__NFUN_1401__(true, false);
		}
	}
	return;
}

defaultproperties
{
	m_RArmpatchBitmapPos=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=14114,ZoneNumber=0)
	m_RArmpatchListPos=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=58914,ZoneNumber=0)
}