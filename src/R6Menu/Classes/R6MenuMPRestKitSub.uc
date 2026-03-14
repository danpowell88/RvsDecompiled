//=============================================================================
// R6MenuMPRestKitSub - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPRestKitSub.uc : Restriction kit tab menus
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/20/6  * Create by John Bennett
//=============================================================================
class R6MenuMPRestKitSub extends UWindowDialogClientWindow;

const K_HALFWINDOWWIDTH = 310;
const K_X_BORDER_OFF = 5;
const K_BOX_HEIGHT = 16;
const K_MAX_WINDOWBUTTONBOX = 20;
const K_Y_LIST_OFF = 23;
const K_Y_BUTTON_OFF = 4;
const K_X_BUTTON_OFF = 30;

var bool m_bIsInGame;
var R6WindowButton m_pSelectAll;
var R6WindowButton m_pUnSelectAll;
// NEW IN 1.60
var R6WindowButtonBox m_pSubMachineGuns[20];
// NEW IN 1.60
var R6WindowButtonBox m_pShotguns[20];
// NEW IN 1.60
var R6WindowButtonBox m_pAssaultRifle[20];
// NEW IN 1.60
var R6WindowButtonBox m_pMachineGuns[20];
// NEW IN 1.60
var R6WindowButtonBox m_pSniperRifle[20];
// NEW IN 1.60
var R6WindowButtonBox m_pPistol[20];
// NEW IN 1.60
var R6WindowButtonBox m_pMachinePistol[20];
// NEW IN 1.60
var R6WindowButtonBox m_pPriWpnGadget[20];
// NEW IN 1.60
var R6WindowButtonBox m_pSecWpnGadget[20];
// NEW IN 1.60
var R6WindowButtonBox m_pMiscGadget[20];
var R6WindowListRestKit m_pRestKitButList;
var array< Class > m_ASubMachineGuns;
var array< Class > m_AShotguns;
var array< Class > m_AAssaultRifle;
var array< Class > m_AMachineGuns;
var array< Class > m_ASniperRifle;
var array< Class > m_APistol;
var array< Class > m_AMachinePistol;
var array< Class > m_APriWpnGadget;
var array< Class > m_ASecWpnGadget;
var array< Class > m_AMiscGadget;
var array<byte> m_ASelected;

function Created()
{
	m_pRestKitButList = R6WindowListRestKit(CreateWindow(Class'R6Window.R6WindowListRestKit', 0.0000000, 23.0000000, __NFUN_175__(310.0000000, float(1)), __NFUN_175__(WinHeight, float(23)), self));
	m_pRestKitButList.m_fXItemOffset = 5.0000000;
	m_pRestKitButList.bAlwaysBehind = true;
	return;
}

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	DrawStretchedTextureSegment(C, 0.0000000, 23.0000000, __NFUN_175__(310.0000000, float(1)), float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	return;
}

function InitSelectButtons(bool _bInGame)
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local Font ButtonFont;
	local int i;

	m_bIsInGame = _bInGame;
	fYOffset = 4.0000000;
	fWidth = 100.0000000;
	fXOffset = __NFUN_172__(__NFUN_175__(__NFUN_172__(310.0000000, float(2)), fWidth), float(2));
	fHeight = 16.0000000;
	ButtonFont = Root.Fonts[5];
	m_pSelectAll = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pSelectAll.m_vButtonColor = Root.Colors.White;
	m_pSelectAll.SetButtonBorderColor(Root.Colors.White);
	m_pSelectAll.m_bDrawBorders = true;
	m_pSelectAll.Align = 2;
	m_pSelectAll.ImageX = 2.0000000;
	m_pSelectAll.ImageY = 2.0000000;
	m_pSelectAll.m_bDrawSimpleBorder = true;
	m_pSelectAll.bStretched = true;
	m_pSelectAll.SetText(Localize("MPCreateGame", "Kit_SelectAll", "R6Menu"));
	m_pSelectAll.SetFont(0);
	m_pSelectAll.TextColor = Root.Colors.White;
	m_pSelectAll.ToolTipString = Localize("Tip", "Kit_SelectAll", "R6Menu");
	fXOffset = __NFUN_174__(__NFUN_172__(310.0000000, float(2)), __NFUN_172__(__NFUN_175__(float(__NFUN_145__(310, 2)), fWidth), float(2)));
	m_pUnSelectAll = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pUnSelectAll.m_vButtonColor = Root.Colors.White;
	m_pUnSelectAll.SetButtonBorderColor(Root.Colors.White);
	m_pUnSelectAll.m_bDrawBorders = true;
	m_pUnSelectAll.Align = 2;
	m_pUnSelectAll.ImageX = 2.0000000;
	m_pUnSelectAll.ImageY = 2.0000000;
	m_pUnSelectAll.m_bDrawSimpleBorder = true;
	m_pUnSelectAll.bStretched = true;
	m_pUnSelectAll.SetText(Localize("MPCreateGame", "Kit_UnselectAll", "R6Menu"));
	m_pUnSelectAll.SetFont(0);
	m_pUnSelectAll.TextColor = Root.Colors.White;
	m_pUnSelectAll.ToolTipString = Localize("Tip", "Kit_UnselectAll", "R6Menu");
	return;
}

//=================================================================================================
//========================= SUB MACHINES GUNS =====================================================
//=================================================================================================
function InitSubMachineGunsTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local int i;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASubMachineGuns.Remove(0, m_ASubMachineGuns.Length);
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x5E
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_ASubMachineGuns = GetRestrictionKit(Class'R6Description.R6SubGunDescription', pServerOptions.RestrictedSubMachineGuns, _pR6GameRepInfo);		
	}
	else
	{
		m_ASubMachineGuns = GetRestrictionKit(Class'R6Description.R6SubGunDescription', pServerOptions.RestrictedSubMachineGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szSubMachineGunsRes);
	}
	CreateRestKitButtons(m_ASubMachineGuns, m_ASelected, "R6Weapons", m_pSubMachineGuns);
	i = __NFUN_146__(m_ASubMachineGuns.Length, 1);
	J0xBF:

	// End:0xE2 [Loop If]
	if(__NFUN_150__(i, 20))
	{
		m_pSubMachineGuns[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xBF;
	}
	return;
}

function UpdateSubMachineGunsTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x51
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_ASubMachineGuns = GetRestrictionKit(Class'R6Description.R6SubGunDescription', pServerOptions.RestrictedSubMachineGuns, _pR6GameRepInfo);		
	}
	else
	{
		m_ASubMachineGuns = GetRestrictionKit(Class'R6Description.R6SubGunDescription', pServerOptions.RestrictedSubMachineGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szSubMachineGunsRes);
	}
	UpdateRestKitButtonSel(m_ASelected, m_pSubMachineGuns);
	return;
}

//=================================================================================================
//========================= SHOT GUNS =====================================================
//=================================================================================================
function InitShotGunsTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local int i;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_AShotguns.Remove(0, m_AShotguns.Length);
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x5E
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_AShotguns = GetRestrictionKit(Class'R6Description.R6ShotgunDescription', pServerOptions.RestrictedShotGuns, _pR6GameRepInfo);		
	}
	else
	{
		m_AShotguns = GetRestrictionKit(Class'R6Description.R6ShotgunDescription', pServerOptions.RestrictedShotGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szShotGunRes);
	}
	CreateRestKitButtons(m_AShotguns, m_ASelected, "R6Weapons", m_pShotguns);
	i = __NFUN_146__(m_AShotguns.Length, 1);
	J0xBF:

	// End:0xE2 [Loop If]
	if(__NFUN_150__(i, 20))
	{
		m_pShotguns[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xBF;
	}
	return;
}

function UpdateShotGunsTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x51
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_AShotguns = GetRestrictionKit(Class'R6Description.R6ShotgunDescription', pServerOptions.RestrictedShotGuns, _pR6GameRepInfo);		
	}
	else
	{
		m_AShotguns = GetRestrictionKit(Class'R6Description.R6ShotgunDescription', pServerOptions.RestrictedShotGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szShotGunRes);
	}
	UpdateRestKitButtonSel(m_ASelected, m_pShotguns);
	return;
}

//=================================================================================================
//========================= ASSAULT RIFLES =====================================================
//=================================================================================================
function InitAssaultRifleTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local int i;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_AAssaultRifle.Remove(0, m_AAssaultRifle.Length);
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x5E
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_AAssaultRifle = GetRestrictionKit(Class'R6Description.R6AssaultDescription', pServerOptions.RestrictedAssultRifles, _pR6GameRepInfo);		
	}
	else
	{
		m_AAssaultRifle = GetRestrictionKit(Class'R6Description.R6AssaultDescription', pServerOptions.RestrictedAssultRifles, _pR6GameRepInfo, _pR6GameRepInfo.m_szAssRifleRes);
	}
	CreateRestKitButtons(m_AAssaultRifle, m_ASelected, "R6Weapons", m_pAssaultRifle);
	i = __NFUN_146__(m_AAssaultRifle.Length, 1);
	J0xBF:

	// End:0xE2 [Loop If]
	if(__NFUN_150__(i, 20))
	{
		m_pAssaultRifle[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xBF;
	}
	return;
}

function UpdateAssaultRifleTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x51
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_AAssaultRifle = GetRestrictionKit(Class'R6Description.R6AssaultDescription', pServerOptions.RestrictedAssultRifles, _pR6GameRepInfo);		
	}
	else
	{
		m_AAssaultRifle = GetRestrictionKit(Class'R6Description.R6AssaultDescription', pServerOptions.RestrictedAssultRifles, _pR6GameRepInfo, _pR6GameRepInfo.m_szAssRifleRes);
	}
	UpdateRestKitButtonSel(m_ASelected, m_pAssaultRifle);
	return;
}

//=================================================================================================
//========================= MACHINE GUNS =====================================================
//=================================================================================================
function InitMachineGunsTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local int i;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_AMachineGuns.Remove(0, m_AMachineGuns.Length);
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x5E
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_AMachineGuns = GetRestrictionKit(Class'R6Description.R6LMGDescription', pServerOptions.RestrictedMachineGuns, _pR6GameRepInfo);		
	}
	else
	{
		m_AMachineGuns = GetRestrictionKit(Class'R6Description.R6LMGDescription', pServerOptions.RestrictedMachineGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szMachGunRes);
	}
	CreateRestKitButtons(m_AMachineGuns, m_ASelected, "R6Weapons", m_pMachineGuns);
	i = __NFUN_146__(m_AMachineGuns.Length, 1);
	J0xBF:

	// End:0xE2 [Loop If]
	if(__NFUN_150__(i, 20))
	{
		m_pMachineGuns[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xBF;
	}
	return;
}

function UpdateMachineGunsTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x51
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_AMachineGuns = GetRestrictionKit(Class'R6Description.R6LMGDescription', pServerOptions.RestrictedMachineGuns, _pR6GameRepInfo);		
	}
	else
	{
		m_AMachineGuns = GetRestrictionKit(Class'R6Description.R6LMGDescription', pServerOptions.RestrictedMachineGuns, _pR6GameRepInfo, _pR6GameRepInfo.m_szMachGunRes);
	}
	UpdateRestKitButtonSel(m_ASelected, m_pMachineGuns);
	return;
}

//=================================================================================================
//========================= SNIPER RIFLE =====================================================
//=================================================================================================
function InitSniperRifleTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local int i;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASniperRifle.Remove(0, m_ASniperRifle.Length);
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x5E
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_ASniperRifle = GetRestrictionKit(Class'R6Description.R6SniperDescription', pServerOptions.RestrictedSniperRifles, _pR6GameRepInfo);		
	}
	else
	{
		m_ASniperRifle = GetRestrictionKit(Class'R6Description.R6SniperDescription', pServerOptions.RestrictedSniperRifles, _pR6GameRepInfo, _pR6GameRepInfo.m_szSnipRifleRes);
	}
	CreateRestKitButtons(m_ASniperRifle, m_ASelected, "R6Weapons", m_pSniperRifle);
	i = __NFUN_146__(m_ASniperRifle.Length, 1);
	J0xBF:

	// End:0xE2 [Loop If]
	if(__NFUN_150__(i, 20))
	{
		m_pSniperRifle[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xBF;
	}
	return;
}

function UpdateSniperRifleTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x51
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_ASniperRifle = GetRestrictionKit(Class'R6Description.R6SniperDescription', pServerOptions.RestrictedSniperRifles, _pR6GameRepInfo);		
	}
	else
	{
		m_ASniperRifle = GetRestrictionKit(Class'R6Description.R6SniperDescription', pServerOptions.RestrictedSniperRifles, _pR6GameRepInfo, _pR6GameRepInfo.m_szSnipRifleRes);
	}
	UpdateRestKitButtonSel(m_ASelected, m_pSniperRifle);
	return;
}

//=================================================================================================
//========================= PISTOLS =====================================================
//=================================================================================================
function InitPistolTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local int i;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_APistol.Remove(0, m_APistol.Length);
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x5E
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_APistol = GetRestrictionKit(Class'R6Description.R6PistolsDescription', pServerOptions.RestrictedPistols, _pR6GameRepInfo);		
	}
	else
	{
		m_APistol = GetRestrictionKit(Class'R6Description.R6PistolsDescription', pServerOptions.RestrictedPistols, _pR6GameRepInfo, _pR6GameRepInfo.m_szPistolRes);
	}
	CreateRestKitButtons(m_APistol, m_ASelected, "R6Weapons", m_pPistol);
	m_pPistol[0].m_bSelected = false;
	m_pPistol[0].bDisabled = true;
	i = __NFUN_146__(m_APistol.Length, 1);
	J0xE5:

	// End:0x108 [Loop If]
	if(__NFUN_150__(i, 20))
	{
		m_pPistol[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xE5;
	}
	return;
}

function UpdatePistolsTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x51
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_APistol = GetRestrictionKit(Class'R6Description.R6PistolsDescription', pServerOptions.RestrictedPistols, _pR6GameRepInfo);		
	}
	else
	{
		m_APistol = GetRestrictionKit(Class'R6Description.R6PistolsDescription', pServerOptions.RestrictedPistols, _pR6GameRepInfo, _pR6GameRepInfo.m_szPistolRes);
	}
	UpdateRestKitButtonSel(m_ASelected, m_pPistol);
	return;
}

//=================================================================================================
//========================= MACHINE PISTOLS =====================================================
//=================================================================================================
function InitMachinePistolTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local int i;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_AMachinePistol.Remove(0, m_AMachinePistol.Length);
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x5E
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_AMachinePistol = GetRestrictionKit(Class'R6Description.R6MachinePistolsDescription', pServerOptions.RestrictedMachinePistols, _pR6GameRepInfo);		
	}
	else
	{
		m_AMachinePistol = GetRestrictionKit(Class'R6Description.R6MachinePistolsDescription', pServerOptions.RestrictedMachinePistols, _pR6GameRepInfo, _pR6GameRepInfo.m_szMachPistolRes);
	}
	CreateRestKitButtons(m_AMachinePistol, m_ASelected, "R6Weapons", m_pMachinePistol);
	i = __NFUN_146__(m_AMachinePistol.Length, 1);
	J0xBF:

	// End:0xE2 [Loop If]
	if(__NFUN_150__(i, 20))
	{
		m_pMachinePistol[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xBF;
	}
	return;
}

function UpdateMachinePistolTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x51
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_AMachinePistol = GetRestrictionKit(Class'R6Description.R6MachinePistolsDescription', pServerOptions.RestrictedMachinePistols, _pR6GameRepInfo);		
	}
	else
	{
		m_AMachinePistol = GetRestrictionKit(Class'R6Description.R6MachinePistolsDescription', pServerOptions.RestrictedMachinePistols, _pR6GameRepInfo, _pR6GameRepInfo.m_szMachPistolRes);
	}
	UpdateRestKitButtonSel(m_ASelected, m_pMachinePistol);
	return;
}

//=================================================================================================
//========================= PRIMARY WEAPON GADGETS =====================================================
//=================================================================================================
function InitPriWpnGadgetTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local Font ButtonFont;
	local int i, j, k;
	local Class<R6WeaponGadgetDescription> DescriptionClass;
	local bool bFound;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_APriWpnGadget.Remove(0, m_APriWpnGadget.Length);
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x5E
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_APriWpnGadget = GetGadgetRestrictionKit(Class'R6Description.R6WeaponGadgetDescription', pServerOptions.RestrictedPrimary, _pR6GameRepInfo);		
	}
	else
	{
		m_APriWpnGadget = GetGadgetRestrictionKit(Class'R6Description.R6WeaponGadgetDescription', pServerOptions.RestrictedPrimary, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgPrimaryRes);
	}
	CreateRestKitButtons(m_APriWpnGadget, m_ASelected, "R6WeaponGadgets", m_pPriWpnGadget);
	i = __NFUN_146__(m_APriWpnGadget.Length, 1);
	J0xC5:

	// End:0xE8 [Loop If]
	if(__NFUN_150__(i, 20))
	{
		m_pPriWpnGadget[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xC5;
	}
	return;
}

function UpdatePriWpnGadgetTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x51
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_APriWpnGadget = GetGadgetRestrictionKit(Class'R6Description.R6WeaponGadgetDescription', pServerOptions.RestrictedPrimary, _pR6GameRepInfo);		
	}
	else
	{
		m_APriWpnGadget = GetGadgetRestrictionKit(Class'R6Description.R6WeaponGadgetDescription', pServerOptions.RestrictedPrimary, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgPrimaryRes);
	}
	UpdateRestKitButtonSel(m_ASelected, m_pPriWpnGadget);
	return;
}

//=================================================================================================
//========================= SECONDARY WEAPON GADGETS =====================================================
//=================================================================================================
function InitSecWpnGadgetTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local Font ButtonFont;
	local int i, j, k;
	local Class<R6WeaponGadgetDescription> DescriptionClass;
	local bool bFound;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASecWpnGadget.Remove(0, m_ASecWpnGadget.Length);
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x60
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_ASecWpnGadget = GetGadgetRestrictionKit(Class'R6Description.R6WeaponGadgetDescription', pServerOptions.RestrictedSecondary, _pR6GameRepInfo,, true);		
	}
	else
	{
		m_ASecWpnGadget = GetGadgetRestrictionKit(Class'R6Description.R6WeaponGadgetDescription', pServerOptions.RestrictedSecondary, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgSecondayRes, true);
	}
	CreateRestKitButtons(m_ASecWpnGadget, m_ASelected, "R6WeaponGadgets", m_pSecWpnGadget);
	i = __NFUN_146__(m_ASecWpnGadget.Length, 1);
	J0xC8:

	// End:0xEB [Loop If]
	if(__NFUN_150__(i, 20))
	{
		m_pSecWpnGadget[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xC8;
	}
	return;
}

function UpdateSecWpnGadgetTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x53
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_ASecWpnGadget = GetGadgetRestrictionKit(Class'R6Description.R6WeaponGadgetDescription', pServerOptions.RestrictedSecondary, _pR6GameRepInfo,, true);		
	}
	else
	{
		m_ASecWpnGadget = GetGadgetRestrictionKit(Class'R6Description.R6WeaponGadgetDescription', pServerOptions.RestrictedSecondary, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgSecondayRes, true);
	}
	UpdateRestKitButtonSel(m_ASelected, m_pSecWpnGadget);
	return;
}

//=================================================================================================
//========================= MISC GADGETS =====================================================
//=================================================================================================
function InitMiscGadgetTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local int i;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_AMiscGadget.Remove(0, m_AMiscGadget.Length);
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x5E
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_AMiscGadget = GetGadgetRestrictionKit(Class'R6Description.R6GadgetDescription', pServerOptions.RestrictedMiscGadgets, _pR6GameRepInfo);		
	}
	else
	{
		m_AMiscGadget = GetGadgetRestrictionKit(Class'R6Description.R6GadgetDescription', pServerOptions.RestrictedMiscGadgets, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgMiscRes);
	}
	CreateRestKitButtons(m_AMiscGadget, m_ASelected, "R6Gadgets", m_pMiscGadget);
	i = __NFUN_146__(m_AMiscGadget.Length, 1);
	J0xBF:

	// End:0xE2 [Loop If]
	if(__NFUN_150__(i, 20))
	{
		m_pMiscGadget[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xBF;
	}
	return;
}

function UpdateMiscGadgetTab(R6GameReplicationInfo _pR6GameRepInfo)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	m_ASelected.Remove(0, m_ASelected.Length);
	// End:0x51
	if(__NFUN_114__(_pR6GameRepInfo, none))
	{
		m_AMiscGadget = GetGadgetRestrictionKit(Class'R6Description.R6GadgetDescription', pServerOptions.RestrictedMiscGadgets, _pR6GameRepInfo);		
	}
	else
	{
		m_AMiscGadget = GetGadgetRestrictionKit(Class'R6Description.R6GadgetDescription', pServerOptions.RestrictedMiscGadgets, _pR6GameRepInfo, _pR6GameRepInfo.m_szGadgMiscRes);
	}
	UpdateRestKitButtonSel(m_ASelected, m_pMiscGadget);
	return;
}

function array< Class > GetRestrictionKit(Class pClassRestriction, array< Class > _pInitialRest, R6GameReplicationInfo _pR6GameRepInfo, optional string _szInGameRestriction[32])
{
	local array< Class > m_AOfRestrictions;
	local Class<R6Description> DescriptionClass;
	local int i, j, iNbOfRest;
	local bool bFindRes;
	local int k;
	local R6Mod pCurrentMod;

	pCurrentMod = Class'Engine.Actor'.static.__NFUN_1524__().m_pCurrentMod;
	// End:0x43
	if(__NFUN_114__(pCurrentMod, none))
	{
		__NFUN_231__("pCurrentMod == None");
		return m_AOfRestrictions;
	}
	k = 0;
	J0x4A:

	// End:0x10E [Loop If]
	if(__NFUN_150__(k, pCurrentMod.m_aDescriptionPackage.Length))
	{
		DescriptionClass = Class<R6Description>(__NFUN_1005__(__NFUN_112__(pCurrentMod.m_aDescriptionPackage[k], ".u"), pClassRestriction));
		J0x90:

		// End:0xF6 [Loop If]
		if(__NFUN_119__(DescriptionClass, none))
		{
			bFindRes = false;
			// End:0xC4
			if(__NFUN_123__(DescriptionClass.default.m_NameID, "NONE"))
			{
				bFindRes = true;
			}
			// End:0xE5
			if(bFindRes)
			{
				m_AOfRestrictions[i] = DescriptionClass;
				__NFUN_165__(i);
			}
			DescriptionClass = Class<R6Description>(__NFUN_1006__());
			// [Loop Continue]
			goto J0x90;
		}
		iNbOfRest = i;
		__NFUN_1007__();
		__NFUN_165__(k);
		// [Loop Continue]
		goto J0x4A;
	}
	m_AOfRestrictions = SortRestrictionKit(m_AOfRestrictions);
	i = 0;
	J0x126:

	// End:0x1FF [Loop If]
	if(__NFUN_150__(i, iNbOfRest))
	{
		m_ASelected[i] = 0;
		// End:0x19E
		if(__NFUN_114__(_pR6GameRepInfo, none))
		{
			j = 0;
			J0x155:

			// End:0x19B [Loop If]
			if(__NFUN_150__(j, _pInitialRest.Length))
			{
				// End:0x191
				if(__NFUN_114__(_pInitialRest[j], m_AOfRestrictions[i]))
				{
					m_ASelected[i] = 1;
					// [Explicit Break]
					goto J0x19B;
				}
				__NFUN_165__(j);
				// [Loop Continue]
				goto J0x155;
			}
			J0x19B:

			// [Explicit Continue]
			goto J0x1F5;
		}
		j = 0;
		J0x1A5:

		// End:0x1F5 [Loop If]
		if(__NFUN_150__(j, 32))
		{
			// End:0x1EB
			if(__NFUN_122__(_szInGameRestriction[j], Class<R6Description>(m_AOfRestrictions[i]).default.m_NameID))
			{
				m_ASelected[i] = 1;
				// [Explicit Break]
				goto J0x1F5;
			}
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x1A5;
		}
		J0x1F5:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x126;
	}
	return m_AOfRestrictions;
	return;
}

function array< Class > GetGadgetRestrictionKit(Class pClassRestriction, array<string> _pInitialRest, R6GameReplicationInfo _pR6GameRepInfo, optional string _szInGameRestriction[32], optional bool _bSecWeaponGadget)
{
	local array< Class > m_AOfRestrictions;
	local Class<R6Description> DescriptionClass;
	local int i, j, k, iNbOfRest;
	local bool bFindRes;
	local int L;
	local R6Mod pCurrentMod;

	pCurrentMod = Class'Engine.Actor'.static.__NFUN_1524__().m_pCurrentMod;
	L = 0;
	J0x22:

	// End:0x17D [Loop If]
	if(__NFUN_150__(L, pCurrentMod.m_aDescriptionPackage.Length))
	{
		DescriptionClass = Class<R6Description>(__NFUN_1005__(__NFUN_112__(pCurrentMod.m_aDescriptionPackage[L], ".u"), pClassRestriction));
		J0x68:

		// End:0x165 [Loop If]
		if(__NFUN_119__(DescriptionClass, none))
		{
			bFindRes = false;
			// End:0xC7
			if(__NFUN_123__(DescriptionClass.default.m_NameID, "NONE"))
			{
				// End:0xBF
				if(_bSecWeaponGadget)
				{
					// End:0xBC
					if(Class<R6WeaponGadgetDescription>(DescriptionClass).default.m_bSecGadgetWAvailable)
					{
						bFindRes = true;
					}					
				}
				else
				{
					bFindRes = true;
				}
			}
			// End:0x154
			if(bFindRes)
			{
				k = m_AOfRestrictions.Length;
				j = 0;
				J0xE3:

				// End:0x133 [Loop If]
				if(__NFUN_150__(j, k))
				{
					// End:0x129
					if(__NFUN_122__(Class<R6Description>(m_AOfRestrictions[j]).default.m_NameID, DescriptionClass.default.m_NameID))
					{
						bFindRes = false;
						// [Explicit Break]
						goto J0x133;
					}
					__NFUN_165__(j);
					// [Loop Continue]
					goto J0xE3;
				}
				J0x133:

				// End:0x154
				if(bFindRes)
				{
					m_AOfRestrictions[i] = DescriptionClass;
					__NFUN_165__(i);
				}
			}
			DescriptionClass = Class<R6Description>(__NFUN_1006__());
			// [Loop Continue]
			goto J0x68;
		}
		iNbOfRest = i;
		__NFUN_1007__();
		__NFUN_165__(L);
		// [Loop Continue]
		goto J0x22;
	}
	m_AOfRestrictions = SortRestrictionKit(m_AOfRestrictions);
	i = 0;
	J0x195:

	// End:0x27C [Loop If]
	if(__NFUN_150__(i, iNbOfRest))
	{
		m_ASelected[i] = 0;
		// End:0x21B
		if(__NFUN_114__(_pR6GameRepInfo, none))
		{
			j = 0;
			J0x1C4:

			// End:0x218 [Loop If]
			if(__NFUN_150__(j, _pInitialRest.Length))
			{
				// End:0x20E
				if(__NFUN_122__(_pInitialRest[j], Class<R6Description>(m_AOfRestrictions[i]).default.m_NameID))
				{
					m_ASelected[i] = 1;
					// [Explicit Break]
					goto J0x218;
				}
				__NFUN_165__(j);
				// [Loop Continue]
				goto J0x1C4;
			}
			J0x218:

			// [Explicit Continue]
			goto J0x272;
		}
		j = 0;
		J0x222:

		// End:0x272 [Loop If]
		if(__NFUN_150__(j, 32))
		{
			// End:0x268
			if(__NFUN_122__(_szInGameRestriction[j], Class<R6Description>(m_AOfRestrictions[i]).default.m_NameID))
			{
				m_ASelected[i] = 1;
				// [Explicit Break]
				goto J0x272;
			}
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x222;
		}
		J0x272:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x195;
	}
	return m_AOfRestrictions;
	return;
}

function array< Class > SortRestrictionKit(array< Class > _pAToSort)
{
	local int i, j;
	local Class sTemp;
	local bool bSwap;

	i = 0;
	J0x07:

	// End:0xD5 [Loop If]
	if(__NFUN_150__(i, __NFUN_147__(_pAToSort.Length, 1)))
	{
		j = 0;
		J0x21:

		// End:0xCB [Loop If]
		if(__NFUN_150__(j, __NFUN_147__(__NFUN_147__(_pAToSort.Length, 1), i)))
		{
			bSwap = __NFUN_116__(Class<R6Description>(_pAToSort[j]).default.m_NameID, Class<R6Description>(_pAToSort[static.__NFUN_146__(j, 1)]).default.m_NameID);
			// End:0xC1
			if(bSwap)
			{
				sTemp = _pAToSort[j];
				_pAToSort[j] = _pAToSort[__NFUN_146__(j, 1)];
				_pAToSort[__NFUN_146__(j, 1)] = sTemp;
			}
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x21;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return _pAToSort;
	return;
}

function CreateRestKitButtons(array< Class > pRestKitClass, array<byte> pRestKitSelect, string _szLocFile, out R6WindowButtonBox _ButtonsBox[20])
{
	local R6WindowListGeneralItem NewItem;
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local Font ButtonFont;
	local int i, j;
	local string ButtonTag;

	fXOffset = 5.0000000;
	fYOffset = 23.0000000;
	fWidth = __NFUN_175__(__NFUN_175__(310.0000000, __NFUN_171__(float(2), fXOffset)), float(15));
	fHeight = 16.0000000;
	ButtonFont = Root.Fonts[5];
	i = 0;
	J0x5D:

	// End:0x246 [Loop If]
	if(__NFUN_150__(i, pRestKitClass.Length))
	{
		NewItem = R6WindowListGeneralItem(m_pRestKitButList.GetItemAtIndex(i));
		NewItem.m_pR6WindowButtonBox = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
		NewItem.m_pR6WindowButtonBox.m_TextFont = ButtonFont;
		NewItem.m_pR6WindowButtonBox.m_vTextColor = Root.Colors.White;
		NewItem.m_pR6WindowButtonBox.m_vBorder = Root.Colors.White;
		NewItem.m_pR6WindowButtonBox.m_bSelected = bool(pRestKitSelect[i]);
		NewItem.m_pR6WindowButtonBox.m_szMiscText = Class<R6Description>(pRestKitClass[i]).default.m_NameID;
		NewItem.m_pR6WindowButtonBox.m_AdviceWindow = m_pRestKitButList;
		NewItem.m_pR6WindowButtonBox.CreateTextAndBox(Localize(Class<R6Description>(pRestKitClass[i]).default.m_NameID, "ID_NAME", _szLocFile), Localize("Tip", "Kit_Restriction", "R6Menu"), 0.0000000, i);
		_ButtonsBox[i] = NewItem.m_pR6WindowButtonBox;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x5D;
	}
	return;
}

function UpdateRestKitButtonSel(array<byte> pRestKitSelect, out R6WindowButtonBox _ButtonsBox[20])
{
	local int i;

	i = 0;
	J0x07:

	// End:0x58 [Loop If]
	if(__NFUN_150__(i, pRestKitSelect.Length))
	{
		// End:0x2B
		if(__NFUN_114__(_ButtonsBox[i], none))
		{
			// [Explicit Break]
			goto J0x58;
		}
		_ButtonsBox[i].m_bSelected = bool(pRestKitSelect[i]);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	J0x58:

	return;
}

function SelectAllSubMachineGuns(bool bSelected)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(i, m_ASubMachineGuns.Length))
	{
		m_pSubMachineGuns[i].m_bSelected = bSelected;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SelectAllShotguns(bool bSelected)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(i, m_AShotguns.Length))
	{
		m_pShotguns[i].m_bSelected = bSelected;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SelectAllAssaultRifle(bool bSelected)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(i, m_AAssaultRifle.Length))
	{
		m_pAssaultRifle[i].m_bSelected = bSelected;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SelectAllMachineGuns(bool bSelected)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(i, m_AMachineGuns.Length))
	{
		m_pMachineGuns[i].m_bSelected = bSelected;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SelectAllSniperRifle(bool bSelected)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(i, m_ASniperRifle.Length))
	{
		m_pSniperRifle[i].m_bSelected = bSelected;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SelectAllPistol(bool bSelected)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x57 [Loop If]
	if(__NFUN_150__(i, m_APistol.Length))
	{
		// End:0x4D
		if(__NFUN_129__(m_pPistol[i].bDisabled))
		{
			m_pPistol[i].m_bSelected = bSelected;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SelectAllMachinePistol(bool bSelected)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(i, m_AMachinePistol.Length))
	{
		m_pMachinePistol[i].m_bSelected = bSelected;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SelectAllPriWpnGadget(bool bSelected)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(i, m_APriWpnGadget.Length))
	{
		m_pPriWpnGadget[i].m_bSelected = bSelected;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SelectAllSecWpnGadget(bool bSelected)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(i, m_ASecWpnGadget.Length))
	{
		m_pSecWpnGadget[i].m_bSelected = bSelected;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SelectAllMiscGadget(bool bSelected)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(i, m_AMiscGadget.Length))
	{
		m_pMiscGadget[i].m_bSelected = bSelected;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local bool bSelect;
	local R6MenuMPRestKitMain R6RestKit;

	// End:0x35
	if(m_bIsInGame)
	{
		// End:0x35
		if(__NFUN_129__(R6PlayerController(GetPlayerOwner()).CheckAuthority(R6PlayerController(GetPlayerOwner()).1)))
		{
			return;
		}
	}
	// End:0x2C0
	if(C.__NFUN_303__('R6WindowButton'))
	{
		bSelect = __NFUN_114__(C, m_pSelectAll);
		switch(E)
		{
			// End:0x1FE
			case 2:
				R6RestKit = R6MenuMPRestKitMain(OwnerWindow);
				// End:0x9B
				if(__NFUN_114__(self, R6RestKit.m_pSubMachinesGunsTab))
				{
					SelectAllSubMachineGuns(bSelect);					
				}
				else
				{
					// End:0xBE
					if(__NFUN_114__(self, R6RestKit.m_pShotgunsTab))
					{
						SelectAllShotguns(bSelect);						
					}
					else
					{
						// End:0xE1
						if(__NFUN_114__(self, R6RestKit.m_pAssaultRifleTab))
						{
							SelectAllAssaultRifle(bSelect);							
						}
						else
						{
							// End:0x104
							if(__NFUN_114__(self, R6RestKit.m_pMachineGunsTab))
							{
								SelectAllMachineGuns(bSelect);								
							}
							else
							{
								// End:0x127
								if(__NFUN_114__(self, R6RestKit.m_pSniperRifleTab))
								{
									SelectAllSniperRifle(bSelect);									
								}
								else
								{
									// End:0x14A
									if(__NFUN_114__(self, R6RestKit.m_pPistolTab))
									{
										SelectAllPistol(bSelect);										
									}
									else
									{
										// End:0x16D
										if(__NFUN_114__(self, R6RestKit.m_pMachinePistolTab))
										{
											SelectAllMachinePistol(bSelect);											
										}
										else
										{
											// End:0x190
											if(__NFUN_114__(self, R6RestKit.m_pPriWpnGadgetTab))
											{
												SelectAllPriWpnGadget(bSelect);												
											}
											else
											{
												// End:0x1B3
												if(__NFUN_114__(self, R6RestKit.m_pSecWpnGadgetTab))
												{
													SelectAllSecWpnGadget(bSelect);													
												}
												else
												{
													// End:0x1D3
													if(__NFUN_114__(self, R6RestKit.m_pMiscGadgetTab))
													{
														SelectAllMiscGadget(bSelect);
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
				// End:0x1FB
				if(__NFUN_129__(m_bIsInGame))
				{
					R6MenuMPCreateGameTabKitRest(R6RestKit.OwnerWindow).SetServerOptions();
				}
				// End:0x2BD
				break;
			// End:0x25C
			case 9:
				R6WindowButton(C).SetButtonBorderColor(Root.Colors.White);
				R6WindowButton(C).TextColor = Root.Colors.White;
				// End:0x2BD
				break;
			// End:0x2BA
			case 12:
				R6WindowButton(C).SetButtonBorderColor(Root.Colors.BlueLight);
				R6WindowButton(C).TextColor = Root.Colors.BlueLight;
				// End:0x2BD
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		// End:0x35C
		if(C.__NFUN_303__('R6WindowButtonBox'))
		{
			// End:0x35C
			if(__NFUN_154__(int(E), 2))
			{
				// End:0x35C
				if(R6WindowButtonBox(C).GetSelectStatus())
				{
					R6WindowButtonBox(C).m_bSelected = __NFUN_129__(R6WindowButtonBox(C).m_bSelected);
					// End:0x35C
					if(__NFUN_129__(m_bIsInGame))
					{
						R6RestKit = R6MenuMPRestKitMain(OwnerWindow);
						R6MenuMPCreateGameTabKitRest(R6RestKit.OwnerWindow).SetServerOptions();
					}
				}
			}
		}
	}
	return;
}

//=======================================================================================
// Refresh : Verify is the client is now an admin only in-game
//=======================================================================================
function RefreshSubKit(bool _bAdmin)
{
	// End:0x2E
	if(_bAdmin)
	{
		m_pSelectAll.bDisabled = false;
		m_pUnSelectAll.bDisabled = false;		
	}
	else
	{
		m_pSelectAll.bDisabled = true;
		m_pUnSelectAll.bDisabled = true;
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pSubMachineGunsK_MAX_WINDOWBUTTONBOX
// REMOVED IN 1.60: var m_pShotgunsK_MAX_WINDOWBUTTONBOX
// REMOVED IN 1.60: var m_pAssaultRifleK_MAX_WINDOWBUTTONBOX
// REMOVED IN 1.60: var m_pMachineGunsK_MAX_WINDOWBUTTONBOX
// REMOVED IN 1.60: var m_pSniperRifleK_MAX_WINDOWBUTTONBOX
// REMOVED IN 1.60: var m_pPistolK_MAX_WINDOWBUTTONBOX
// REMOVED IN 1.60: var m_pMachinePistolK_MAX_WINDOWBUTTONBOX
// REMOVED IN 1.60: var m_pPriWpnGadgetK_MAX_WINDOWBUTTONBOX
// REMOVED IN 1.60: var m_pSecWpnGadgetK_MAX_WINDOWBUTTONBOX
// REMOVED IN 1.60: var m_pMiscGadgetK_MAX_WINDOWBUTTONBOX
