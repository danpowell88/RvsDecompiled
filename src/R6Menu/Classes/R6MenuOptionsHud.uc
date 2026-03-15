//=============================================================================
// R6MenuOptionsHud - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuOptionsHud extends R6MenuOptionsTab;

var R6WindowButtonBox m_pHudWeaponName;
var R6WindowButtonBox m_pHudShowFPWeapon;
var R6WindowButtonBox m_pHudOtherTInfo;
var R6WindowButtonBox m_pHudCurTInfo;
var R6WindowButtonBox m_pHudCircumIcon;
var R6WindowButtonBox m_pHudWpInfo;
var R6WindowButtonBox m_pHudReticule;
var R6WindowButtonBox m_pHudShowTNames;
var R6WindowButtonBox m_pHudCharInfo;
var R6WindowButtonBox m_pHudShowRadar;
var R6WindowBitMap m_pHudBGTex;
var R6WindowBitMap m_pHudWeaponNameTex;
var R6WindowBitMap m_pHudShowFPWeaponTex;
var R6WindowBitMap m_pHudOtherTInfoTex;
var R6WindowBitMap m_pHudCurTInfoTex;
var R6WindowBitMap m_pHudCircumIconTex;
var R6WindowBitMap m_pHudWpInfoTex;
var R6WindowBitMap m_pHudReticuleTex;
var R6WindowBitMap m_pHudCharInfoTex;
var R6WindowBitMap m_pHudShowTNamesTex;
var R6WindowBitMap m_pHudShowRadarTex;

function InitPageOptions()
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp,
		fSizeOfCounter;

	local Font ButtonFont;

	ButtonFont = Root.Fonts[5];
	fXOffset = 5.0000000;
	fYOffset = 5.0000000;
	fWidth = ((WinWidth * 0.5000000) - (float(2) * fXOffset));
	fHeight = 15.0000000;
	fYStep = 17.0000000;
	m_pHudWeaponName = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pHudWeaponName.SetButtonBox(true);
	m_pHudWeaponName.CreateTextAndBox(Localize("Options", "Opt_HudWeapon", "R6Menu"), Localize("Tip", "Opt_HudWeapon", "R6Menu"), 0.0000000, 0);
	(fYOffset += fYStep);
	m_pHudShowFPWeapon = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pHudShowFPWeapon.SetButtonBox(false);
	m_pHudShowFPWeapon.CreateTextAndBox(Localize("Options", "Opt_HudShowFPWeapon", "R6Menu"), Localize("Tip", "Opt_HudShowFPWeapon", "R6Menu"), 0.0000000, 1);
	(fYOffset += fYStep);
	m_pHudOtherTInfo = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pHudOtherTInfo.SetButtonBox(true);
	m_pHudOtherTInfo.CreateTextAndBox(Localize("Options", "Opt_HudOtherTInfo", "R6Menu"), Localize("Tip", "Opt_HudOtherTInfo", "R6Menu"), 0.0000000, 2);
	(fYOffset += fYStep);
	m_pHudCurTInfo = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pHudCurTInfo.SetButtonBox(true);
	m_pHudCurTInfo.CreateTextAndBox(Localize("Options", "Opt_HudCurTInfo", "R6Menu"), Localize("Tip", "Opt_HudCurTInfo", "R6Menu"), 0.0000000, 3);
	(fYOffset += fYStep);
	m_pHudCircumIcon = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pHudCircumIcon.SetButtonBox(true);
	m_pHudCircumIcon.CreateTextAndBox(Localize("Options", "Opt_HudCircumIcon", "R6Menu"), Localize("Tip", "Opt_HudCircumIcon", "R6Menu"), 0.0000000, 4);
	fXOffset = ((WinWidth * 0.5000000) + fXOffset);
	fYOffset = 5.0000000;
	m_pHudWpInfo = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pHudWpInfo.SetButtonBox(true);
	m_pHudWpInfo.CreateTextAndBox(Localize("Options", "Opt_HudWPInfo", "R6Menu"), Localize("Tip", "Opt_HudWPInfo", "R6Menu"), 0.0000000, 5);
	(fYOffset += fYStep);
	m_pHudReticule = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pHudReticule.SetButtonBox(true);
	m_pHudReticule.CreateTextAndBox(Localize("Options", "Opt_HudCrossHair", "R6Menu"), Localize("Tip", "Opt_HudCrossHair", "R6Menu"), 0.0000000, 6);
	(fYOffset += fYStep);
	m_pHudShowTNames = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pHudShowTNames.SetButtonBox(true);
	m_pHudShowTNames.CreateTextAndBox(Localize("Options", "Opt_HudShowTNames", "R6Menu"), Localize("Tip", "Opt_HudShowTNames", "R6Menu"), 0.0000000, 7);
	(fYOffset += fYStep);
	m_pHudCharInfo = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pHudCharInfo.SetButtonBox(true);
	m_pHudCharInfo.CreateTextAndBox(Localize("Options", "Opt_HudCharInfo", "R6Menu"), Localize("Tip", "Opt_HudCharInfo", "R6Menu"), 0.0000000, 8);
	(fYOffset += fYStep);
	m_pHudShowRadar = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pHudShowRadar.SetButtonBox(true);
	m_pHudShowRadar.CreateTextAndBox(Localize("Options", "Opt_HudShowRadar", "R6Menu"), Localize("Tip", "Opt_HudShowRadar", "R6Menu"), 0.0000000, 9);
	CreateHudOptionsTex();
	InitResetButton();
	UpdateOptionsInPage();
	m_bInitComplete = true;
	return;
}

function UpdateOptionsInEngine()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	pGameOptions.HUDShowWeaponInfo = m_pHudWeaponName.m_bSelected;
	pGameOptions.HUDShowFPWeapon = m_pHudShowFPWeapon.m_bSelected;
	pGameOptions.HUDShowOtherTeamInfo = m_pHudOtherTInfo.m_bSelected;
	pGameOptions.HUDShowCurrentTeamInfo = m_pHudCurTInfo.m_bSelected;
	pGameOptions.HUDShowActionIcon = m_pHudCircumIcon.m_bSelected;
	pGameOptions.HUDShowWaypointInfo = m_pHudWpInfo.m_bSelected;
	pGameOptions.HUDShowReticule = m_pHudReticule.m_bSelected;
	pGameOptions.HUDShowCharacterInfo = m_pHudCharInfo.m_bSelected;
	pGameOptions.HUDShowPlayersName = m_pHudShowTNames.m_bSelected;
	pGameOptions.ShowRadar = m_pHudShowRadar.m_bSelected;
	UpdateHudOptionsTex();
	return;
}

function UpdateOptionsInPage()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	m_pHudWeaponName.SetButtonBox(pGameOptions.HUDShowWeaponInfo);
	m_pHudShowFPWeapon.SetButtonBox(pGameOptions.HUDShowFPWeapon);
	m_pHudOtherTInfo.SetButtonBox(pGameOptions.HUDShowOtherTeamInfo);
	m_pHudCurTInfo.SetButtonBox(pGameOptions.HUDShowCurrentTeamInfo);
	m_pHudCircumIcon.SetButtonBox(pGameOptions.HUDShowActionIcon);
	m_pHudWpInfo.SetButtonBox(pGameOptions.HUDShowWaypointInfo);
	m_pHudReticule.SetButtonBox(pGameOptions.HUDShowReticule);
	m_pHudCharInfo.SetButtonBox(pGameOptions.HUDShowCharacterInfo);
	m_pHudShowTNames.SetButtonBox(pGameOptions.HUDShowPlayersName);
	m_pHudShowRadar.SetButtonBox(pGameOptions.ShowRadar);
	UpdateHudOptionsTex();
	return;
}

function CreateHudOptionsTex()
{
	m_pHudBGTex = CreateHudBitmapWindow(Texture'R6MenuTextures.DisplayBackground', true);
	m_pHudBGTex.bAlwaysBehind = true;
	m_pHudBGTex.m_BorderColor = Root.Colors.White;
	m_pHudWeaponNameTex = CreateHudBitmapWindow(Texture'R6MenuTextures.DisplayWeaponInfo');
	m_pHudShowFPWeaponTex = CreateHudBitmapWindow(Texture'R6MenuTextures.Display1stPersonWeapon');
	m_pHudOtherTInfoTex = CreateHudBitmapWindow(Texture'R6MenuTextures.DisplayOtherTeamInfo');
	m_pHudCurTInfoTex = CreateHudBitmapWindow(Texture'R6MenuTextures.DisplayCurrentTeamInfo');
	m_pHudCircumIconTex = CreateHudBitmapWindow(Texture'R6MenuTextures.DisplayActionIcon');
	m_pHudWpInfoTex = CreateHudBitmapWindow(Texture'R6MenuTextures.DisplayWaypointInfo');
	m_pHudReticuleTex = CreateHudBitmapWindow(Texture'R6MenuTextures.DisplayReticule');
	m_pHudCharInfoTex = CreateHudBitmapWindow(Texture'R6MenuTextures.DisplayCharacterInfo');
	m_pHudShowTNamesTex = CreateHudBitmapWindow(Texture'R6MenuTextures.DisplayTeammateNames');
	m_pHudShowRadarTex = CreateHudBitmapWindow(Texture'R6MenuTextures.DisplayMPRadar');
	return;
}

function R6WindowBitMap CreateHudBitmapWindow(Texture _Tex, optional bool _bDrawSimpleBorder)
{
	local R6WindowBitMap _NewR6WindowBitMap;

	_NewR6WindowBitMap = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', 77.0000000, 96.0000000, 262.0000000, 198.0000000, self));
	_NewR6WindowBitMap.t = _Tex;
	_NewR6WindowBitMap.R = NewRegion(0.0000000, 0.0000000, 260.0000000, 196.0000000);
	_NewR6WindowBitMap.m_iDrawStyle = int(5);
	_NewR6WindowBitMap.m_bDrawBorder = _bDrawSimpleBorder;
	_NewR6WindowBitMap.m_ImageX = 1.0000000;
	_NewR6WindowBitMap.m_ImageY = 1.0000000;
	return _NewR6WindowBitMap;
	return;
}

function UpdateHudOptionsTex()
{
	m_pHudWeaponNameTex.HideWindow();
	m_pHudShowFPWeaponTex.HideWindow();
	m_pHudOtherTInfoTex.HideWindow();
	m_pHudCurTInfoTex.HideWindow();
	m_pHudCircumIconTex.HideWindow();
	m_pHudWpInfoTex.HideWindow();
	m_pHudReticuleTex.HideWindow();
	m_pHudCharInfoTex.HideWindow();
	m_pHudShowTNamesTex.HideWindow();
	m_pHudShowRadarTex.HideWindow();
	// End:0xB7
	if(m_pHudWeaponName.m_bSelected)
	{
		m_pHudWeaponNameTex.ShowWindow();
	}
	// End:0xD8
	if(m_pHudShowTNames.m_bSelected)
	{
		m_pHudShowTNamesTex.ShowWindow();
	}
	// End:0xF9
	if(m_pHudShowFPWeapon.m_bSelected)
	{
		m_pHudShowFPWeaponTex.ShowWindow();
	}
	// End:0x11A
	if(m_pHudOtherTInfo.m_bSelected)
	{
		m_pHudOtherTInfoTex.ShowWindow();
	}
	// End:0x13B
	if(m_pHudCurTInfo.m_bSelected)
	{
		m_pHudCurTInfoTex.ShowWindow();
	}
	// End:0x15C
	if(m_pHudCircumIcon.m_bSelected)
	{
		m_pHudCircumIconTex.ShowWindow();
	}
	// End:0x17D
	if(m_pHudWpInfo.m_bSelected)
	{
		m_pHudWpInfoTex.ShowWindow();
	}
	// End:0x19E
	if(m_pHudReticule.m_bSelected)
	{
		m_pHudReticuleTex.ShowWindow();
	}
	// End:0x1BF
	if(m_pHudCharInfo.m_bSelected)
	{
		m_pHudCharInfoTex.ShowWindow();
	}
	// End:0x1E0
	if(m_pHudShowRadar.m_bSelected)
	{
		m_pHudShowRadarTex.ShowWindow();
	}
	return;
}

function RestoreDefaultValue()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	pGameOptions.ResetHudToDefault();
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
	// End:0x11D
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
	// End:0x138
	if(bUpdateGameOptions)
	{
		UpdateOptionsInEngine();
		pGameOptions.SaveConfig();
	}
	return;
}
