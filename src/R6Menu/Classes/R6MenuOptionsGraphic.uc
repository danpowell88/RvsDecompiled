//=============================================================================
// R6MenuOptionsGraphic - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuOptionsGraphic extends R6MenuOptionsTab;

const C_szEGameOptionsGraphicLevel = "EGameOptionsGraphicLevel";
const C_szEGameOptionsEffectLevel = "EGameOptionsEffectLevel";
const C_iITEM_NONE = 0x01;
const C_iITEM_LOW = 0x02;
const C_iITEM_MEDIUM = 0x04;
const C_iITEM_HIGH = 0x08;
const C_iGORE_ITEMS = 0x0A;
const C_iSHADOW_ITEMS = 0x0B;
const C_iALL_ITEMS = 0x0F;

var bool m_bUpdateFileOnly;
var R6WindowComboControl m_pVideoRes;
var R6WindowComboControl m_pTextureDetail;
var R6WindowComboControl m_pLightmapDetail;
var R6WindowComboControl m_pRainbowsDetail;
var R6WindowComboControl m_pHostagesDetail;
var R6WindowComboControl m_pTerrosDetail;
var R6WindowComboControl m_pRainbowsShadowLevel;
var R6WindowComboControl m_pHostagesShadowLevel;
var R6WindowComboControl m_pTerrosShadowLevel;
var R6WindowComboControl m_pGoreLevel;
var R6WindowComboControl m_pDecalsDetail;
var R6WindowButtonBox m_pAnimGeometry;
var R6WindowButtonBox m_pHideDeadBodies;
var R6WindowButtonBox m_pLowDetailSmoke;
var string m_pComboLevel[4];

function Created()
{
	super.Created();
	m_pComboLevel[0] = Localize("Options", "Level_None", "R6Menu");
	m_pComboLevel[1] = Localize("Options", "Level_Low", "R6Menu");
	m_pComboLevel[2] = Localize("Options", "Level_Medium", "R6Menu");
	m_pComboLevel[3] = Localize("Options", "Level_Hi", "R6Menu");
	return;
}

function InitPageOptions()
{
	local Region rRegionW;
	local float fYStep;
	local Font ButtonFont;
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	ButtonFont = Root.Fonts[5];
	rRegionW.X = 5;
	rRegionW.Y = 5;
	rRegionW.W = int(((WinWidth - float(rRegionW.X)) - float(20)));
	rRegionW.H = 14;
	fYStep = 19.0000000;
	m_pVideoRes = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapVideoRes", "R6Menu"), Localize("Tip", "Opt_GrapVideoRes", "R6Menu"));
	AddVideoResolution(m_pVideoRes);
	// End:0x114
	if(m_bInGame)
	{
		m_pVideoRes.SetDisableButton((!pGameOptions.AllowChangeResInGame));
	}
	(rRegionW.Y += int(fYStep));
	m_pTextureDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapTexDetail", "R6Menu"), Localize("Tip", "Opt_GrapTexDetail", "R6Menu"));
	AddGraphComboControlItem(15, m_pTextureDetail, "EGameOptionsGraphicLevel");
	(rRegionW.Y += int(fYStep));
	m_pLightmapDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapLightMap", "R6Menu"), Localize("Tip", "Opt_GrapLightMap", "R6Menu"));
	AddGraphComboControlItem(15, m_pLightmapDetail, "EGameOptionsGraphicLevel", true);
	(rRegionW.Y += int(fYStep));
	m_pRainbowsDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapRainbowDetail", "R6Menu"), Localize("Tip", "Opt_GrapRainbowDetail", "R6Menu"));
	AddGraphComboControlItem(15, m_pRainbowsDetail, "EGameOptionsGraphicLevel");
	(rRegionW.Y += int(fYStep));
	m_pHostagesDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapHostDetail", "R6Menu"), Localize("Tip", "Opt_GrapHostDetail", "R6Menu"));
	AddGraphComboControlItem(15, m_pHostagesDetail, "EGameOptionsGraphicLevel");
	(rRegionW.Y += int(fYStep));
	m_pTerrosDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapTerroDetail", "R6Menu"), Localize("Tip", "Opt_GrapTerroDetail", "R6Menu"));
	AddGraphComboControlItem(15, m_pTerrosDetail, "EGameOptionsGraphicLevel");
	(rRegionW.Y += int(fYStep));
	m_pRainbowsShadowLevel = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapRainbowShadow", "R6Menu"), Localize("Tip", "Opt_GrapRainbowShadow", "R6Menu"));
	AddGraphComboControlItem(11, m_pRainbowsShadowLevel, "EGameOptionsEffectLevel", true);
	m_pRainbowsShadowLevel.SetDisableButton(m_bInGame);
	(rRegionW.Y += int(fYStep));
	m_pHostagesShadowLevel = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapHostShadow", "R6Menu"), Localize("Tip", "Opt_GrapHostShadow", "R6Menu"));
	AddGraphComboControlItem(11, m_pHostagesShadowLevel, "EGameOptionsEffectLevel", true);
	m_pHostagesShadowLevel.SetDisableButton(m_bInGame);
	(rRegionW.Y += int(fYStep));
	m_pTerrosShadowLevel = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapTerroShadow", "R6Menu"), Localize("Tip", "Opt_GrapTerroShadow", "R6Menu"));
	AddGraphComboControlItem(11, m_pTerrosShadowLevel, "EGameOptionsEffectLevel", true);
	m_pTerrosShadowLevel.SetDisableButton(m_bInGame);
	// End:0x70A
	if((!pGameOptions.SplashScreen))
	{
		(rRegionW.Y += int(fYStep));
		m_pGoreLevel = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapGoreLevel", "R6Menu"), Localize("Tip", "Opt_GrapGoreLevel", "R6Menu"));
		AddGraphComboControlItem(10, m_pGoreLevel, "EGameOptionsGraphicLevel");
		m_pGoreLevel.SetDisableButton(m_bInGame);
	}
	(rRegionW.Y += int(fYStep));
	m_pDecalsDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapDecalsDetail", "R6Menu"), Localize("Tip", "Opt_GrapDecalsDetail", "R6Menu"));
	AddGraphComboControlItem(15, m_pDecalsDetail, "EGameOptionsEffectLevel");
	m_pDecalsDetail.SetDisableButton(m_bInGame);
	(rRegionW.Y += int(fYStep));
	(rRegionW.W -= 20);
	m_pAnimGeometry = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', float(rRegionW.X), float(rRegionW.Y), float(rRegionW.W), float(rRegionW.H), self));
	m_pAnimGeometry.SetButtonBox(true);
	m_pAnimGeometry.CreateTextAndBox(Localize("Options", "Opt_GrapAnimGeometry", "R6Menu"), Localize("Tip", "Opt_GrapAnimGeometry", "R6Menu"), 0.0000000, 0);
	// End:0x98F
	if((!pGameOptions.SplashScreen))
	{
		(rRegionW.Y += int(fYStep));
		m_pHideDeadBodies = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', float(rRegionW.X), float(rRegionW.Y), float(rRegionW.W), float(rRegionW.H), self));
		m_pHideDeadBodies.SetButtonBox(true);
		m_pHideDeadBodies.CreateTextAndBox(Localize("Options", "Opt_GrapHideDeadBodies", "R6Menu"), Localize("Tip", "Opt_GrapHideDeadBodies", "R6Menu"), 0.0000000, 0);
	}
	(rRegionW.Y += int(fYStep));
	m_pLowDetailSmoke = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', float(rRegionW.X), float(rRegionW.Y), float(rRegionW.W), float(rRegionW.H), self));
	m_pLowDetailSmoke.SetButtonBox(false);
	m_pLowDetailSmoke.CreateTextAndBox(Localize("Options", "Opt_GrapLowDetailSmoke", "R6Menu"), Localize("Tip", "Opt_GrapLowDetailSmoke", "R6Menu"), 0.0000000, 0);
	InitResetButton();
	UpdateOptionsInPage();
	m_bInitComplete = true;
	return;
}

function UpdateOptionsInEngine()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	GetResolutionXY(pGameOptions.R6ScreenSizeX, pGameOptions.R6ScreenSizeY, pGameOptions.R6ScreenRefreshRate);
	pGameOptions.TextureDetail = ConvertToGLEnum(m_pTextureDetail.GetValue());
	pGameOptions.LightmapDetail = ConvertToGLEnum(m_pLightmapDetail.GetValue());
	pGameOptions.RainbowsDetail = ConvertToGLEnum(m_pRainbowsDetail.GetValue());
	pGameOptions.RainbowsShadowLevel = ConvertToELEnum(m_pRainbowsShadowLevel.GetValue());
	pGameOptions.HostagesDetail = ConvertToGLEnum(m_pHostagesDetail.GetValue());
	pGameOptions.TerrosDetail = ConvertToGLEnum(m_pTerrosDetail.GetValue());
	pGameOptions.HostagesShadowLevel = ConvertToELEnum(m_pHostagesShadowLevel.GetValue());
	pGameOptions.TerrosShadowLevel = ConvertToELEnum(m_pTerrosShadowLevel.GetValue());
	// End:0x191
	if(pGameOptions.SplashScreen)
	{
		pGameOptions.GoreLevel = pGameOptions.0;		
	}
	else
	{
		pGameOptions.GoreLevel = ConvertToELEnum(m_pGoreLevel.GetValue());
	}
	pGameOptions.DecalsDetail = ConvertToELEnum(m_pDecalsDetail.GetValue());
	pGameOptions.AnimatedGeometry = m_pAnimGeometry.m_bSelected;
	// End:0x21E
	if(pGameOptions.SplashScreen)
	{
		pGameOptions.HideDeadBodies = true;		
	}
	else
	{
		pGameOptions.HideDeadBodies = m_pHideDeadBodies.m_bSelected;
	}
	pGameOptions.LowDetailSmoke = m_pLowDetailSmoke.m_bSelected;
	// End:0x28C
	if((R6MenuOptionsWidget(OwnerWindow).m_bInGame && (!m_bUpdateFileOnly)))
	{
		Class'Engine.Actor'.static.UpdateGraphicOptions();
	}
	return;
}

function UpdateOptionsInPage()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	// End:0x8E
	if((pGameOptions.ShowRefreshRates && (pGameOptions.R6ScreenRefreshRate != -1)))
	{
		m_pVideoRes.SetValue(((((string(pGameOptions.R6ScreenSizeX) $ "x") $ string(pGameOptions.R6ScreenSizeY)) $ "@") $ string(pGameOptions.R6ScreenRefreshRate)));		
	}
	else
	{
		m_pVideoRes.SetValue(((string(pGameOptions.R6ScreenSizeX) $ "x") $ string(pGameOptions.R6ScreenSizeY)));
	}
	m_pTextureDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.TextureDetail), "EGameOptionsGraphicLevel"));
	m_pLightmapDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.LightmapDetail), "EGameOptionsGraphicLevel", true));
	m_pRainbowsDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.RainbowsDetail), "EGameOptionsGraphicLevel"));
	m_pRainbowsShadowLevel.SetValue(ConvertToGraphicString(11, int(pGameOptions.RainbowsShadowLevel), "EGameOptionsEffectLevel", true));
	m_pHostagesDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.HostagesDetail), "EGameOptionsGraphicLevel"));
	m_pTerrosDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.TerrosDetail), "EGameOptionsGraphicLevel"));
	m_pHostagesShadowLevel.SetValue(ConvertToGraphicString(11, int(pGameOptions.HostagesShadowLevel), "EGameOptionsEffectLevel", true));
	m_pTerrosShadowLevel.SetValue(ConvertToGraphicString(11, int(pGameOptions.TerrosShadowLevel), "EGameOptionsEffectLevel", true));
	// End:0x321
	if((!pGameOptions.SplashScreen))
	{
		m_pGoreLevel.SetValue(ConvertToGraphicString(10, int(pGameOptions.GoreLevel), "EGameOptionsEffectLevel"));
	}
	m_pDecalsDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.DecalsDetail), "EGameOptionsEffectLevel"));
	m_pAnimGeometry.SetButtonBox(pGameOptions.AnimatedGeometry);
	// End:0x3B1
	if((!pGameOptions.SplashScreen))
	{
		m_pHideDeadBodies.SetButtonBox(pGameOptions.HideDeadBodies);
	}
	m_pLowDetailSmoke.SetButtonBox(pGameOptions.LowDetailSmoke);
	return;
}

function R6GameOptions.EGameOptionsGraphicLevel ConvertToGLEnum(string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsGraphicLevel eGLResult;

	switch(_szValueToConvert)
	{
		// End:0x1C
		case m_pComboLevel[1]:
			eGLResult = 0;
			// End:0x4E
			break;
		// End:0x32
		case m_pComboLevel[2]:
			eGLResult = 1;
			// End:0x4E
			break;
		// End:0x48
		case m_pComboLevel[3]:
			eGLResult = 2;
			// End:0x4E
			break;
		// End:0xFFFF
		default:
			// End:0x4E
			break;
			break;
	}
	return eGLResult;
	return;
}

function R6GameOptions.EGameOptionsEffectLevel ConvertToELEnum(string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsEffectLevel eELResult;

	switch(_szValueToConvert)
	{
		// End:0x1C
		case m_pComboLevel[0]:
			eELResult = 0;
			// End:0x63
			break;
		// End:0x31
		case m_pComboLevel[1]:
			eELResult = 1;
			// End:0x63
			break;
		// End:0x47
		case m_pComboLevel[2]:
			eELResult = 2;
			// End:0x63
			break;
		// End:0x5D
		case m_pComboLevel[3]:
			eELResult = 3;
			// End:0x63
			break;
		// End:0xFFFF
		default:
			// End:0x63
			break;
			break;
	}
	return eELResult;
	return;
}

function string ConvertToGraphicString(int _iAddItemMask, int _iValueToConvert, string _szGraphicsEnumName, optional bool _bCheckFor32MegVideoCard)
{
	local string szResult;

	// End:0xED
	if((_szGraphicsEnumName == "EGameOptionsGraphicLevel"))
	{
		switch(_iValueToConvert)
		{
			// End:0x4E
			case 0:
				// End:0x4B
				if(((_iAddItemMask & 2) > 0))
				{
					szResult = m_pComboLevel[1];
				}
				// End:0xEA
				break;
			// End:0x92
			case 1:
				// End:0x72
				if(((_iAddItemMask & 4) > 0))
				{
					szResult = m_pComboLevel[2];					
				}
				else
				{
					szResult = ConvertToGraphicString(_iAddItemMask, 0, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				}
				// End:0xEA
				break;
			// End:0xD7
			case 2:
				// End:0xB7
				if(((_iAddItemMask & 8) > 0))
				{
					szResult = m_pComboLevel[3];					
				}
				else
				{
					szResult = ConvertToGraphicString(_iAddItemMask, 1, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				}
				// End:0xEA
				break;
			// End:0xFFFF
			default:
				szResult = m_pComboLevel[1];
				// End:0xEA
				break;
				break;
		}		
	}
	else
	{
		switch(_iValueToConvert)
		{
			// End:0x116
			case 0:
				// End:0x113
				if(((_iAddItemMask & 1) > 0))
				{
					szResult = m_pComboLevel[0];
				}
				// End:0x1F7
				break;
			// End:0x159
			case 1:
				// End:0x139
				if(((_iAddItemMask & 2) > 0))
				{
					szResult = m_pComboLevel[1];					
				}
				else
				{
					szResult = ConvertToGraphicString(_iAddItemMask, 0, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				}
				// End:0x1F7
				break;
			// End:0x19E
			case 2:
				// End:0x17E
				if(((_iAddItemMask & 4) > 0))
				{
					szResult = m_pComboLevel[2];					
				}
				else
				{
					szResult = ConvertToGraphicString(_iAddItemMask, 1, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				}
				// End:0x1F7
				break;
			// End:0x1E4
			case 3:
				// End:0x1C3
				if(((_iAddItemMask & 8) > 0))
				{
					szResult = m_pComboLevel[3];					
				}
				else
				{
					szResult = ConvertToGraphicString(_iAddItemMask, 2, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				}
				// End:0x1F7
				break;
			// End:0xFFFF
			default:
				szResult = m_pComboLevel[0];
				// End:0x1F7
				break;
				break;
		}
	}
	// End:0x297
	if(_bCheckFor32MegVideoCard)
	{
		// End:0x297
		if((!Class'Engine.Actor'.static.IsVideoHardwareAtLeast64M()))
		{
			// End:0x267
			if((_szGraphicsEnumName == "EGameOptionsGraphicLevel"))
			{
				// End:0x264
				if((szResult == m_pComboLevel[3]))
				{
					szResult = ConvertToGraphicString(_iAddItemMask, 1, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				}				
			}
			else
			{
				// End:0x297
				if((szResult == m_pComboLevel[3]))
				{
					szResult = ConvertToGraphicString(_iAddItemMask, 2, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				}
			}
		}
	}
	return szResult;
	return;
}

function AddGraphComboControlItem(int _iAddItemMask, R6WindowComboControl _pR6WindowComboControl, string _szGraphicsEnumName, optional bool _bCheckFor32MegVideoCard)
{
	local bool bAddHiItem;

	bAddHiItem = true;
	// End:0x51
	if((_szGraphicsEnumName == "EGameOptionsEffectLevel"))
	{
		// End:0x51
		if(((_iAddItemMask & 1) > 0))
		{
			_pR6WindowComboControl.AddItem(m_pComboLevel[0], "");
		}
	}
	// End:0x78
	if(((_iAddItemMask & 2) > 0))
	{
		_pR6WindowComboControl.AddItem(m_pComboLevel[1], "");
	}
	// End:0xA0
	if(((_iAddItemMask & 4) > 0))
	{
		_pR6WindowComboControl.AddItem(m_pComboLevel[2], "");
	}
	// End:0xC2
	if(_bCheckFor32MegVideoCard)
	{
		// End:0xC2
		if((!Class'Engine.Actor'.static.IsVideoHardwareAtLeast64M()))
		{
			bAddHiItem = false;
		}
	}
	// End:0xF5
	if((bAddHiItem && ((_iAddItemMask & 8) > 0)))
	{
		_pR6WindowComboControl.AddItem(m_pComboLevel[3], "");
	}
	return;
}

function AddVideoResolution(R6WindowComboControl _pR6WindowComboControl)
{
	local int i, j, iWidth, iHeight, iRefreshRate;

	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	i = Class'Engine.Actor'.static.GetNbAvailableResolutions();
	j = 0;
	J0x2B:

	// End:0xD3 [Loop If]
	if((j < i))
	{
		Class'Engine.Actor'.static.GetAvailableResolution(j, iWidth, iHeight, iRefreshRate);
		// End:0xA3
		if(pGameOptions.ShowRefreshRates)
		{
			_pR6WindowComboControl.AddItem(((((string(iWidth) $ "x") $ string(iHeight)) $ "@") $ string(iRefreshRate)), "");
			// [Explicit Continue]
			goto J0xC9;
		}
		_pR6WindowComboControl.AddItem(((string(iWidth) $ "x") $ string(iHeight)), "");
		J0xC9:

		(j++);
		// [Loop Continue]
		goto J0x2B;
	}
	return;
}

function GetResolutionXY(out int iSX, out int iSY, out int iRR)
{
	local int iX;
	local string szTemp, szTemp2;
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	szTemp = m_pVideoRes.GetValue();
	iX = InStr(szTemp, "x");
	szTemp2 = Left(szTemp, iX);
	iSX = int(szTemp2);
	szTemp = Right(szTemp, ((Len(szTemp) - iX) - 1));
	// End:0xE3
	if(pGameOptions.ShowRefreshRates)
	{
		iX = InStr(szTemp, "@");
		szTemp2 = Left(szTemp, iX);
		iSY = int(szTemp2);
		szTemp = Right(szTemp, ((Len(szTemp) - iX) - 1));
		iRR = int(szTemp);		
	}
	else
	{
		iSY = int(szTemp);
		iRR = -1;
	}
	return;
}

function RestoreDefaultValue()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	pGameOptions.ResetGraphicsToDefault(m_bInGame);
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
		// End:0x16B
		if(C.IsA('R6WindowComboControl'))
		{
			// End:0x16B
			if((int(E) == 1))
			{
				// End:0x16B
				if((m_bInitComplete && R6WindowComboControl(C).m_bSelectedByUser))
				{
					bUpdateGameOptions = true;
				}
			}
		}
	}
	// End:0x196
	if(bUpdateGameOptions)
	{
		m_bUpdateFileOnly = true;
		UpdateOptionsInEngine();
		m_bUpdateFileOnly = false;
		pGameOptions.SaveConfig();
	}
	return;
}
