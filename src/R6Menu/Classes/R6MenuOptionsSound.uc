//=============================================================================
// R6MenuOptionsSound - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuOptionsSound extends R6MenuOptionsTab;

var int m_iRefAmbientVolume;
var int m_iRefVoicesVolume;
var int m_iRefMusicVolume;
var bool m_bEAXNotSupported;
var R6WindowHScrollbar m_pAmbientVolume;
var R6WindowHScrollbar m_pVoicesVolume;
var R6WindowHScrollbar m_pMusicVolume;
var R6WindowComboControl m_pSndQuality;
var R6WindowComboControl m_pAudioVirtual;
var R6WindowButtonBox m_pSndHardware;
var R6WindowButtonBox m_pEAX;
var R6WindowBitMap m_EaxLogo;
var Texture m_EaxTexture;
var Region m_EaxTextureReg;
var string m_pComboLevel[4];
var string m_pSndLocEnum[3];

function Created()
{
	super.Created();
	m_pComboLevel[0] = Localize("Options", "Level_None", "R6Menu");
	m_pComboLevel[1] = Localize("Options", "Level_Low", "R6Menu");
	m_pComboLevel[2] = Localize("Options", "Level_Medium", "R6Menu");
	m_pComboLevel[3] = Localize("Options", "Level_Hi", "R6Menu");
	m_pSndLocEnum[0] = Localize("Options", "Opt_SndVirtualHigh", "R6Menu");
	m_pSndLocEnum[1] = Localize("Options", "Opt_SndVirtualLow", "R6Menu");
	m_pSndLocEnum[2] = Localize("Options", "Opt_SndVirtualOff", "R6Menu");
	return;
}

function InitPageOptions()
{
	local Region rRegionW;
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp,
		fSizeOfCounter, fXRightOffset;

	local Font ButtonFont;

	ButtonFont = Root.Fonts[5];
	fXOffset = 5.0000000;
	fXRightOffset = 26.0000000;
	fYOffset = 5.0000000;
	fWidth = __NFUN_175__(__NFUN_175__(WinWidth, fXOffset), float(40));
	fHeight = 14.0000000;
	fYStep = 27.0000000;
	m_pAmbientVolume = R6WindowHScrollbar(CreateControl(Class'R6Window.R6WindowHScrollbar', fXOffset, fYOffset, __NFUN_175__(__NFUN_175__(WinWidth, fXOffset), fXRightOffset), 14.0000000, self));
	m_pAmbientVolume.CreateSB(int(GetPlayerOwner().1), 250.0000000, 0.0000000, 140.0000000, 14.0000000, self);
	m_pAmbientVolume.CreateSBTextLabel(Localize("Options", "Opt_SndAmbient", "R6Menu"), Localize("Tip", "Opt_SndAmbient", "R6Menu"));
	m_pAmbientVolume.SetScrollBarRange(0.0000000, 100.0000000, 20.0000000);
	__NFUN_184__(fYOffset, fYStep);
	m_pVoicesVolume = R6WindowHScrollbar(CreateControl(Class'R6Window.R6WindowHScrollbar', fXOffset, fYOffset, __NFUN_175__(__NFUN_175__(WinWidth, fXOffset), fXRightOffset), 14.0000000, self));
	m_pVoicesVolume.CreateSB(int(GetPlayerOwner().6), 250.0000000, 0.0000000, 140.0000000, 14.0000000, self);
	m_pVoicesVolume.CreateSBTextLabel(Localize("Options", "Opt_SndVoices", "R6Menu"), Localize("Tip", "Opt_SndVoices", "R6Menu"));
	m_pVoicesVolume.SetScrollBarRange(0.0000000, 100.0000000, 20.0000000);
	__NFUN_184__(fYOffset, fYStep);
	m_pMusicVolume = R6WindowHScrollbar(CreateControl(Class'R6Window.R6WindowHScrollbar', fXOffset, fYOffset, __NFUN_175__(__NFUN_175__(WinWidth, fXOffset), fXRightOffset), 14.0000000, self));
	m_pMusicVolume.CreateSB(int(GetPlayerOwner().5), 250.0000000, 0.0000000, 140.0000000, 14.0000000, self);
	m_pMusicVolume.CreateSBTextLabel(Localize("Options", "Opt_SndMusic", "R6Menu"), Localize("Tip", "Opt_SndMusic", "R6Menu"));
	m_pMusicVolume.SetScrollBarRange(0.0000000, 100.0000000, 20.0000000);
	__NFUN_184__(fYOffset, fYStep);
	rRegionW.X = int(fXOffset);
	rRegionW.Y = int(fYOffset);
	rRegionW.W = int(__NFUN_174__(fWidth, float(20)));
	rRegionW.H = int(fHeight);
	m_pSndQuality = SetComboControlButton(rRegionW, Localize("Options", "Opt_SndQuality", "R6Menu"), Localize("Tip", "Opt_SndQuality", "R6Menu"));
	m_pSndQuality.AddItem(m_pComboLevel[1], "");
	m_pSndQuality.AddItem(m_pComboLevel[3], "");
	m_pSndQuality.SetDisableButton(m_bInGame);
	__NFUN_184__(fYOffset, fYStep);
	rRegionW.Y = int(fYOffset);
	m_pAudioVirtual = SetComboControlButton(rRegionW, Localize("Options", "Opt_SndVirtual", "R6Menu"), Localize("Tip", "Opt_SndVirtual", "R6Menu"));
	m_pAudioVirtual.AddItem(m_pSndLocEnum[2], "");
	m_pAudioVirtual.AddItem(m_pSndLocEnum[1], "");
	m_pAudioVirtual.AddItem(m_pSndLocEnum[0], "");
	__NFUN_184__(fYOffset, fYStep);
	m_pSndHardware = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pSndHardware.SetButtonBox(false);
	m_pSndHardware.CreateTextAndBox(Localize("Options", "Opt_SndHardware", "R6Menu"), Localize("Tip", "Opt_SndHardware", "R6Menu"), 0.0000000, 0);
	__NFUN_184__(fYOffset, fYStep);
	m_pEAX = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pEAX.SetButtonBox(false);
	m_pEAX.CreateTextAndBox(Localize("Options", "Opt_SndEAX", "R6Menu"), Localize("Tip", "Opt_SndEAX", "R6Menu"), 0.0000000, 1);
	__NFUN_184__(fYOffset, fYStep);
	m_EaxLogo = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', 0.0000000, fYOffset, WinWidth, float(m_EaxTextureReg.H), self));
	m_EaxLogo.bCenter = true;
	m_EaxLogo.m_iDrawStyle = 5;
	m_EaxLogo.t = m_EaxTexture;
	m_EaxLogo.R = m_EaxTextureReg;
	m_EaxLogo.m_bUseColor = true;
	m_EaxLogo.m_TextureColor = Root.Colors.GrayLight;
	InitResetButton();
	UpdateOptionsInPage();
	m_bInitComplete = true;
	return;
}

function UpdateOptionsInEngine()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	pGameOptions.AmbientVolume = int(m_pAmbientVolume.GetScrollBarValue());
	pGameOptions.VoicesVolume = int(m_pVoicesVolume.GetScrollBarValue());
	pGameOptions.MusicVolume = int(m_pMusicVolume.GetScrollBarValue());
	pGameOptions.SndHardware = m_pSndHardware.m_bSelected;
	pGameOptions.EAX = m_pEAX.m_bSelected;
	pGameOptions.SndQuality = ConvertToSndQuality(m_pSndQuality.GetValue());
	pGameOptions.AudioVirtual = ConvertToAVEnum(m_pAudioVirtual.GetValue());
	return;
}

function UpdateOptionsInPage()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	m_pAmbientVolume.SetScrollBarValue(float(pGameOptions.AmbientVolume));
	m_pVoicesVolume.SetScrollBarValue(float(pGameOptions.VoicesVolume));
	m_pMusicVolume.SetScrollBarValue(float(pGameOptions.MusicVolume));
	m_iRefAmbientVolume = int(m_pAmbientVolume.GetScrollBarValue());
	m_iRefVoicesVolume = int(m_pVoicesVolume.GetScrollBarValue());
	m_iRefMusicVolume = int(m_pMusicVolume.GetScrollBarValue());
	m_pSndHardware.SetButtonBox(pGameOptions.SndHardware);
	// End:0x105
	if(pGameOptions.EAXCompatible)
	{
		m_pEAX.SetButtonBox(pGameOptions.EAX);		
	}
	else
	{
		m_bEAXNotSupported = true;
		m_pEAX.bDisabled = true;
		m_pEAX.SetButtonBox(false);
	}
	ManageNotifyForSound(m_pSndHardware, 1);
	ManageNotifyForSound(m_pEAX, 1);
	m_pAudioVirtual.SetValue(ConvertToAudioString(int(pGameOptions.AudioVirtual)));
	m_pSndQuality.SetValue(ConvertToSndQualityString(pGameOptions.SndQuality));
	return;
}

function int ConvertToSndQuality(string _szValue)
{
	// End:0x17
	if(__NFUN_122__(_szValue, m_pComboLevel[3]))
	{
		return 1;		
	}
	else
	{
		return 0;
	}
	return;
}

function string ConvertToSndQualityString(int _iValue)
{
	// End:0x17
	if(__NFUN_154__(_iValue, 1))
	{
		return m_pComboLevel[3];		
	}
	else
	{
		return m_pComboLevel[1];
	}
	return;
}

function R6GameOptions.EGameOptionsAudioVirtual ConvertToAVEnum(string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsAudioVirtual eAVResult;

	switch(_szValueToConvert)
	{
		// End:0x1C
		case m_pSndLocEnum[0]:
			eAVResult = 0;
			// End:0x4D
			break;
		// End:0x31
		case m_pSndLocEnum[1]:
			eAVResult = 1;
			// End:0x4D
			break;
		// End:0x47
		case m_pSndLocEnum[2]:
			eAVResult = 2;
			// End:0x4D
			break;
		// End:0xFFFF
		default:
			// End:0x4D
			break;
			break;
	}
	return eAVResult;
	return;
}

function string ConvertToAudioString(int _iValueToConvert)
{
	local string szResult;

	switch(_iValueToConvert)
	{
		// End:0x1B
		case 0:
			szResult = m_pSndLocEnum[0];
			// End:0x4B
			break;
		// End:0x2F
		case 1:
			szResult = m_pSndLocEnum[1];
			// End:0x4B
			break;
		// End:0x45
		case 2:
			szResult = m_pSndLocEnum[2];
			// End:0x4B
			break;
		// End:0xFFFF
		default:
			// End:0x4B
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
	pGameOptions.ResetSoundToDefault(m_bInGame);
	UpdateOptionsInPage();
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local bool bUpdateGameOptions;
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	// End:0x120
	if(__NFUN_154__(int(E), 2))
	{
		// End:0x91
		if(C.__NFUN_303__('R6WindowButtonBox'))
		{
			// End:0x7E
			if(R6WindowButtonBox(C).GetSelectStatus())
			{
				R6WindowButtonBox(C).m_bSelected = __NFUN_129__(R6WindowButtonBox(C).m_bSelected);
				bUpdateGameOptions = true;
			}
			ManageNotifyForSound(C, E);			
		}
		else
		{
			// End:0x11D
			if(C.__NFUN_303__('R6WindowButton'))
			{
				// End:0x11D
				if(__NFUN_114__(C, m_pGeneralButUse))
				{
					Root.SimplePopUp(Localize("Options", "ResetToDefault", "R6Menu"), Localize("Options", "ResetToDefaultConfirm", "R6Menu"), 55, 0, false, self);
				}
			}
		}		
	}
	else
	{
		// End:0x337
		if(C.__NFUN_303__('UWindowHScrollbar'))
		{
			switch(UWindowHScrollbar(C).m_iScrollBarID)
			{
				// End:0x1E8
				case int(GetPlayerOwner().1):
					// End:0x1A5
					if(__NFUN_154__(int(E), 9))
					{
						// End:0x1A2
						if(__NFUN_181__(float(m_iRefAmbientVolume), m_pAmbientVolume.GetScrollBarValue()))
						{
							m_iRefAmbientVolume = int(m_pAmbientVolume.GetScrollBarValue());
							bUpdateGameOptions = true;
						}						
					}
					else
					{
						// End:0x1E5
						if(__NFUN_130__(__NFUN_154__(int(E), 1), m_bInitComplete))
						{
							GetPlayerOwner().__NFUN_2714__(GetPlayerOwner().1, m_pAmbientVolume.GetScrollBarValue());
						}
					}
					// End:0x334
					break;
				// End:0x287
				case int(GetPlayerOwner().5):
					// End:0x244
					if(__NFUN_154__(int(E), 9))
					{
						// End:0x241
						if(__NFUN_181__(float(m_iRefMusicVolume), m_pMusicVolume.GetScrollBarValue()))
						{
							m_iRefMusicVolume = int(m_pMusicVolume.GetScrollBarValue());
							bUpdateGameOptions = true;
						}						
					}
					else
					{
						// End:0x284
						if(__NFUN_130__(__NFUN_154__(int(E), 1), m_bInitComplete))
						{
							GetPlayerOwner().__NFUN_2714__(GetPlayerOwner().5, m_pMusicVolume.GetScrollBarValue());
						}
					}
					// End:0x334
					break;
				// End:0x326
				case int(GetPlayerOwner().6):
					// End:0x2E3
					if(__NFUN_154__(int(E), 9))
					{
						// End:0x2E0
						if(__NFUN_181__(float(m_iRefVoicesVolume), m_pVoicesVolume.GetScrollBarValue()))
						{
							m_iRefVoicesVolume = int(m_pVoicesVolume.GetScrollBarValue());
							bUpdateGameOptions = true;
						}						
					}
					else
					{
						// End:0x323
						if(__NFUN_130__(__NFUN_154__(int(E), 1), m_bInitComplete))
						{
							GetPlayerOwner().__NFUN_2714__(GetPlayerOwner().6, m_pVoicesVolume.GetScrollBarValue());
						}
					}
					// End:0x334
					break;
				// End:0xFFFF
				default:
					bUpdateGameOptions = false;
					// End:0x334
					break;
					break;
			}			
		}
		else
		{
			// End:0x382
			if(C.__NFUN_303__('R6WindowComboControl'))
			{
				// End:0x382
				if(__NFUN_154__(int(E), 1))
				{
					// End:0x382
					if(__NFUN_130__(m_bInitComplete, R6WindowComboControl(C).m_bSelectedByUser))
					{
						bUpdateGameOptions = true;
					}
				}
			}
		}
	}
	// End:0x39D
	if(bUpdateGameOptions)
	{
		UpdateOptionsInEngine();
		pGameOptions.__NFUN_536__();
	}
	return;
}

function ManageNotifyForSound(UWindowDialogControl C, byte E)
{
	// End:0x8B
	if(__NFUN_114__(C, m_pSndHardware))
	{
		// End:0x88
		if(__NFUN_129__(m_bEAXNotSupported))
		{
			// End:0x45
			if(R6WindowButtonBox(C).m_bSelected)
			{
				m_pEAX.bDisabled = false;				
			}
			else
			{
				m_pEAX.bDisabled = true;
				m_pEAX.m_bSelected = false;
			}
			m_EaxLogo.m_bUseColor = __NFUN_129__(m_pEAX.m_bSelected);
		}		
	}
	else
	{
		// End:0xBB
		if(__NFUN_114__(C, m_pEAX))
		{
			m_EaxLogo.m_bUseColor = __NFUN_129__(m_pEAX.m_bSelected);
		}
	}
	return;
}

defaultproperties
{
	m_EaxTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_EaxTextureReg=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=101410,ZoneNumber=0)
}