//=============================================================================
// R6MenuMPRestKitMain - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPRestKitMain.uc : Display the server option depending if you are an admin or a client
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/09  * Create by Yannick Joly
//=============================================================================
class R6MenuMPRestKitMain extends UWindowDialogClientWindow;

const K_HALFWINDOWWIDTH = 310;

var bool m_bUpdateInBetRound;
var bool m_bUpdateGameProgress;
var bool m_bImAnAdmin;  // if the client can change the settings
var R6MenuButtonsDefines m_pButtonsDef;
var R6MenuSimpleWindow m_pRestKitOptFakeW;  // fake window to hide all access buttons
// RESTRICTION KIT
var R6WindowTextLabelExt m_pKitText;
var R6WindowButtonBox m_pKitSubMachinesGuns;
var R6WindowButtonBox m_pKitShotGuns;
var R6WindowButtonBox m_pKitAssaultRifles;
var R6WindowButtonBox m_pKitMachinesGuns;
var R6WindowButtonBox m_pKitSniperRifles;
var R6WindowButtonBox m_pKitPistols;
var R6WindowButtonBox m_pKitMachinePistols;
var R6WindowButtonBox m_pKitPrimaryWeapon;
var R6WindowButtonBox m_pKitSecWeapon;
var R6WindowButtonBox m_pKitMisc;
var R6MenuMPRestKitSub m_pSubMachinesGunsTab;
var R6MenuMPRestKitSub m_pShotgunsTab;
var R6MenuMPRestKitSub m_pAssaultRifleTab;
var R6MenuMPRestKitSub m_pMachineGunsTab;
var R6MenuMPRestKitSub m_pSniperRifleTab;
var R6MenuMPRestKitSub m_pPistolTab;
var R6MenuMPRestKitSub m_pMachinePistolTab;
var R6MenuMPRestKitSub m_pPriWpnGadgetTab;
var R6MenuMPRestKitSub m_pSecWpnGadgetTab;
var R6MenuMPRestKitSub m_pMiscGadgetTab;
var R6MenuMPRestKitSub m_pCurrentSubKit;
var array<string> m_SrvRestSubMachineGunsACopy;
var array<string> m_SrvRestShotGunsACopy;
var array<string> m_SrvRestAssultRiflesACopy;
var array<string> m_SrvRestMachineGunsACopy;
var array<string> m_SrvRestSniperRiflesACopy;
var array<string> m_SrvRestPistolsACopy;
var array<string> m_SrvRestMachinePistolsACopy;
var array<string> m_SrvRestPrimaryACopy;
var array<string> m_SrvRestSecondaryACopy;
var array<string> m_SrvRestMiscGadgetsACopy;
var string m_ATextBoxLoc[2];

//=====================================================================================
// KIT TAB
//=====================================================================================
function CreateKitRestriction()
{
	local string szTemp;
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local Font ButtonFont;
	local bool bInGame;
	local R6GameReplicationInfo pGameRepInfo;

	GetR6GameReplicationInfo(pGameRepInfo);
	m_pKitText = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, (2.0000000 * float(310)), WinHeight, self));
	m_pKitText.bAlwaysBehind = true;
	m_pKitText.ActiveBorder(0, false);
	m_pKitText.ActiveBorder(1, false);
	m_pKitText.SetBorderParam(2, 310.0000000, 1.0000000, 1.0000000, Root.Colors.White);
	m_pKitText.ActiveBorder(3, false);
	m_pKitText.m_Font = Root.Fonts[5];
	m_pKitText.m_vTextColor = Root.Colors.White;
	fXOffset = 3.0000000;
	fYOffset = 5.0000000;
	fWidth = 310.0000000;
	m_pKitText.AddTextLabel(Localize("MPCreateGame", "Kit_PrimaryWeapon", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	fYOffset = 125.0000000;
	m_pKitText.AddTextLabel(Localize("MPCreateGame", "Kit_SecWeapon", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	fYOffset = 200.0000000;
	m_pKitText.AddTextLabel(Localize("MPCreateGame", "Kit_Gadgets", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	ButtonFont = Root.Fonts[5];
	fXOffset = 5.0000000;
	fYOffset = 20.0000000;
	fWidth = ((310.0000000 - fXOffset) - float(10));
	fYStep = 15.0000000;
	fHeight = 15.0000000;
	m_ATextBoxLoc[0] = Localize("MultiPlayer", "BoutonMsgBox", "R6Menu");
	m_ATextBoxLoc[1] = Localize("MultiPlayer", "BoutonMsgBoxInGame", "R6Menu");
	bInGame = false;
	// End:0x2FC
	if((pGameRepInfo != none))
	{
		bInGame = true;
	}
	m_pKitSubMachinesGuns = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pKitSubMachinesGuns.m_TextFont = ButtonFont;
	m_pKitSubMachinesGuns.m_vTextColor = Root.Colors.White;
	m_pKitSubMachinesGuns.m_vBorder = Root.Colors.White;
	m_pKitSubMachinesGuns.m_eButtonType = 2;
	szTemp = Localize("Tip", "Kit_SubMachGuns", "R6Menu");
	// End:0x3D5
	if((pGameRepInfo != none))
	{
		szTemp = "";
	}
	m_pKitSubMachinesGuns.CreateTextAndMsgBox(Localize("MPCreateGame", "Kit_SubMachGuns", "R6Menu"), szTemp, m_ATextBoxLoc[0], 0.0000000, 0);
	(fYOffset += fYStep);
	m_pKitShotGuns = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pKitShotGuns.m_TextFont = ButtonFont;
	m_pKitShotGuns.m_vTextColor = Root.Colors.White;
	m_pKitShotGuns.m_vBorder = Root.Colors.White;
	m_pKitShotGuns.m_eButtonType = 2;
	szTemp = Localize("Tip", "Kit_ShotGun", "R6Menu");
	// End:0x504
	if((pGameRepInfo != none))
	{
		szTemp = "";
	}
	m_pKitShotGuns.CreateTextAndMsgBox(Localize("MPCreateGame", "Kit_ShotGun", "R6Menu"), szTemp, m_ATextBoxLoc[0], 0.0000000, 1);
	(fYOffset += fYStep);
	m_pKitAssaultRifles = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pKitAssaultRifles.m_TextFont = ButtonFont;
	m_pKitAssaultRifles.m_vTextColor = Root.Colors.White;
	m_pKitAssaultRifles.m_vBorder = Root.Colors.White;
	m_pKitAssaultRifles.m_eButtonType = 2;
	szTemp = Localize("Tip", "Kit_Assault", "R6Menu");
	// End:0x62F
	if((pGameRepInfo != none))
	{
		szTemp = "";
	}
	m_pKitAssaultRifles.CreateTextAndMsgBox(Localize("MPCreateGame", "Kit_Assault", "R6Menu"), szTemp, m_ATextBoxLoc[0], 0.0000000, 2);
	(fYOffset += fYStep);
	m_pKitMachinesGuns = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pKitMachinesGuns.m_TextFont = ButtonFont;
	m_pKitMachinesGuns.m_vTextColor = Root.Colors.White;
	m_pKitMachinesGuns.m_vBorder = Root.Colors.White;
	m_pKitMachinesGuns.m_eButtonType = 2;
	szTemp = Localize("Tip", "Kit_MachGuns", "R6Menu");
	// End:0x75C
	if((pGameRepInfo != none))
	{
		szTemp = "";
	}
	m_pKitMachinesGuns.CreateTextAndMsgBox(Localize("MPCreateGame", "Kit_MachGuns", "R6Menu"), szTemp, m_ATextBoxLoc[0], 0.0000000, 3);
	(fYOffset += fYStep);
	m_pKitSniperRifles = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pKitSniperRifles.m_TextFont = ButtonFont;
	m_pKitSniperRifles.m_vTextColor = Root.Colors.White;
	m_pKitSniperRifles.m_vBorder = Root.Colors.White;
	m_pKitSniperRifles.m_eButtonType = 2;
	szTemp = Localize("Tip", "Kit_Sniper", "R6Menu");
	// End:0x888
	if((pGameRepInfo != none))
	{
		szTemp = "";
	}
	m_pKitSniperRifles.CreateTextAndMsgBox(Localize("MPCreateGame", "Kit_Sniper", "R6Menu"), szTemp, m_ATextBoxLoc[0], 0.0000000, 4);
	fYOffset = 140.0000000;
	m_pKitPistols = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pKitPistols.m_TextFont = ButtonFont;
	m_pKitPistols.m_vTextColor = Root.Colors.White;
	m_pKitPistols.m_vBorder = Root.Colors.White;
	m_pKitPistols.m_eButtonType = 2;
	szTemp = Localize("Tip", "Kit_Pistols", "R6Menu");
	// End:0x9B2
	if((pGameRepInfo != none))
	{
		szTemp = "";
	}
	m_pKitPistols.CreateTextAndMsgBox(Localize("MPCreateGame", "Kit_Pistols", "R6Menu"), szTemp, m_ATextBoxLoc[0], 0.0000000, 5);
	(fYOffset += fYStep);
	m_pKitMachinePistols = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pKitMachinePistols.m_TextFont = ButtonFont;
	m_pKitMachinePistols.m_vTextColor = Root.Colors.White;
	m_pKitMachinePistols.m_vBorder = Root.Colors.White;
	m_pKitMachinePistols.m_eButtonType = 2;
	szTemp = Localize("Tip", "Kit_MachPistols", "R6Menu");
	// End:0xAE2
	if((pGameRepInfo != none))
	{
		szTemp = "";
	}
	m_pKitMachinePistols.CreateTextAndMsgBox(Localize("MPCreateGame", "Kit_MachPistols", "R6Menu"), szTemp, m_ATextBoxLoc[0], 0.0000000, 6);
	fYOffset = 215.0000000;
	m_pKitPrimaryWeapon = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pKitPrimaryWeapon.m_TextFont = ButtonFont;
	m_pKitPrimaryWeapon.m_vTextColor = Root.Colors.White;
	m_pKitPrimaryWeapon.m_vBorder = Root.Colors.White;
	m_pKitPrimaryWeapon.m_eButtonType = 2;
	szTemp = Localize("Tip", "Kit_PrimaryWeaponMin", "R6Menu");
	// End:0xC1A
	if((pGameRepInfo != none))
	{
		szTemp = "";
	}
	m_pKitPrimaryWeapon.CreateTextAndMsgBox(Localize("MPCreateGame", "Kit_PrimaryWeaponMin", "R6Menu"), szTemp, m_ATextBoxLoc[0], 0.0000000, 7);
	(fYOffset += fYStep);
	m_pKitSecWeapon = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pKitSecWeapon.m_TextFont = ButtonFont;
	m_pKitSecWeapon.m_vTextColor = Root.Colors.White;
	m_pKitSecWeapon.m_vBorder = Root.Colors.White;
	m_pKitSecWeapon.m_eButtonType = 2;
	szTemp = Localize("Tip", "Kit_SecWeaponMin", "R6Menu");
	// End:0xD54
	if((pGameRepInfo != none))
	{
		szTemp = "";
	}
	m_pKitSecWeapon.CreateTextAndMsgBox(Localize("MPCreateGame", "Kit_SecWeaponMin", "R6Menu"), szTemp, m_ATextBoxLoc[0], 0.0000000, 8);
	(fYOffset += fYStep);
	m_pKitMisc = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pKitMisc.m_TextFont = ButtonFont;
	m_pKitMisc.m_vTextColor = Root.Colors.White;
	m_pKitMisc.m_vBorder = Root.Colors.White;
	m_pKitMisc.m_eButtonType = 2;
	szTemp = Localize("Tip", "Kit_Misc", "R6Menu");
	// End:0xE82
	if((pGameRepInfo != none))
	{
		szTemp = "";
	}
	m_pKitMisc.CreateTextAndMsgBox(Localize("MPCreateGame", "Kit_Misc", "R6Menu"), szTemp, m_ATextBoxLoc[0], 0.0000000, 9);
	InitRightPart();
	return;
}

function InitRightPart()
{
	local R6GameReplicationInfo pGameRepInfo;
	local float fXOffset, fYOffset, fWidth, fHeight;
	local bool bInGame;

	fXOffset = 310.0000000;
	fYOffset = 0.0000000;
	fWidth = 310.0000000;
	fHeight = WinHeight;
	GetR6GameReplicationInfo(pGameRepInfo);
	bInGame = false;
	// End:0x52
	if((pGameRepInfo != none))
	{
		bInGame = true;
	}
	m_pSubMachinesGunsTab = R6MenuMPRestKitSub(CreateWindow(Class'R6Menu.R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pSubMachinesGunsTab.InitSelectButtons(bInGame);
	m_pSubMachinesGunsTab.InitSubMachineGunsTab(pGameRepInfo);
	m_pSubMachinesGunsTab.HideWindow();
	m_pShotgunsTab = R6MenuMPRestKitSub(CreateWindow(Class'R6Menu.R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pShotgunsTab.InitSelectButtons(bInGame);
	m_pShotgunsTab.InitShotGunsTab(pGameRepInfo);
	m_pShotgunsTab.HideWindow();
	m_pAssaultRifleTab = R6MenuMPRestKitSub(CreateWindow(Class'R6Menu.R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pAssaultRifleTab.InitSelectButtons(bInGame);
	m_pAssaultRifleTab.InitAssaultRifleTab(pGameRepInfo);
	m_pAssaultRifleTab.HideWindow();
	m_pMachineGunsTab = R6MenuMPRestKitSub(CreateWindow(Class'R6Menu.R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pMachineGunsTab.InitSelectButtons(bInGame);
	m_pMachineGunsTab.InitMachineGunsTab(pGameRepInfo);
	m_pMachineGunsTab.HideWindow();
	m_pSniperRifleTab = R6MenuMPRestKitSub(CreateWindow(Class'R6Menu.R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pSniperRifleTab.InitSelectButtons(bInGame);
	m_pSniperRifleTab.InitSniperRifleTab(pGameRepInfo);
	m_pSniperRifleTab.HideWindow();
	m_pPistolTab = R6MenuMPRestKitSub(CreateWindow(Class'R6Menu.R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pPistolTab.InitSelectButtons(bInGame);
	m_pPistolTab.InitPistolTab(pGameRepInfo);
	m_pPistolTab.HideWindow();
	m_pMachinePistolTab = R6MenuMPRestKitSub(CreateWindow(Class'R6Menu.R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pMachinePistolTab.InitSelectButtons(bInGame);
	m_pMachinePistolTab.InitMachinePistolTab(pGameRepInfo);
	m_pMachinePistolTab.HideWindow();
	m_pPriWpnGadgetTab = R6MenuMPRestKitSub(CreateWindow(Class'R6Menu.R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pPriWpnGadgetTab.InitSelectButtons(bInGame);
	m_pPriWpnGadgetTab.InitPriWpnGadgetTab(pGameRepInfo);
	m_pPriWpnGadgetTab.HideWindow();
	m_pSecWpnGadgetTab = R6MenuMPRestKitSub(CreateWindow(Class'R6Menu.R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pSecWpnGadgetTab.InitSelectButtons(bInGame);
	m_pSecWpnGadgetTab.InitSecWpnGadgetTab(pGameRepInfo);
	m_pSecWpnGadgetTab.HideWindow();
	m_pMiscGadgetTab = R6MenuMPRestKitSub(CreateWindow(Class'R6Menu.R6MenuMPRestKitSub', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pMiscGadgetTab.InitSelectButtons(bInGame);
	m_pMiscGadgetTab.InitMiscGadgetTab(pGameRepInfo);
	m_pMiscGadgetTab.HideWindow();
	m_pRestKitOptFakeW = R6MenuSimpleWindow(CreateWindow(Class'R6Menu.R6MenuSimpleWindow', (WinWidth * 0.5000000), 0.0000000, (WinWidth * 0.5000000), WinHeight, self));
	m_pRestKitOptFakeW.bAlwaysOnTop = true;
	m_pRestKitOptFakeW.m_bDrawSimpleBorder = false;
	m_pRestKitOptFakeW.pAdviceParent = self;
	// End:0x61F
	if(bInGame)
	{
		Refresh();
		(m_pSubMachinesGunsTab.m_pRestKitButList.m_VertSB.WinLeft -= float(1));
		(m_pShotgunsTab.m_pRestKitButList.m_VertSB.WinLeft -= float(1));
		(m_pAssaultRifleTab.m_pRestKitButList.m_VertSB.WinLeft -= float(1));
		(m_pMachineGunsTab.m_pRestKitButList.m_VertSB.WinLeft -= float(1));
		(m_pSniperRifleTab.m_pRestKitButList.m_VertSB.WinLeft -= float(1));
		(m_pPistolTab.m_pRestKitButList.m_VertSB.WinLeft -= float(1));
		(m_pMachinePistolTab.m_pRestKitButList.m_VertSB.WinLeft -= float(1));
		(m_pPriWpnGadgetTab.m_pRestKitButList.m_VertSB.WinLeft -= float(1));
		(m_pSecWpnGadgetTab.m_pRestKitButList.m_VertSB.WinLeft -= float(1));
		(m_pMiscGadgetTab.m_pRestKitButList.m_VertSB.WinLeft -= float(1));		
	}
	else
	{
		m_pRestKitOptFakeW.HideWindow();
		RefreshCreateGameKitRest();
		// End:0x64E
		if((m_pCurrentSubKit != none))
		{
			m_pCurrentSubKit.HideWindow();
		}
	}
	return;
}

function RefreshCreateGameKitRest()
{
	m_pSubMachinesGunsTab.UpdateSubMachineGunsTab(none);
	m_pShotgunsTab.UpdateShotGunsTab(none);
	m_pAssaultRifleTab.UpdateAssaultRifleTab(none);
	m_pMachineGunsTab.UpdateMachineGunsTab(none);
	m_pSniperRifleTab.UpdateSniperRifleTab(none);
	m_pPistolTab.UpdatePistolsTab(none);
	m_pMachinePistolTab.UpdateMachinePistolTab(none);
	m_pPriWpnGadgetTab.UpdatePriWpnGadgetTab(none);
	m_pSecWpnGadgetTab.UpdateSecWpnGadgetTab(none);
	m_pMiscGadgetTab.UpdateMiscGadgetTab(none);
	return;
}

//=======================================================================================
// Refresh : Verify is the client is now an admin only in-game
//=======================================================================================
function Refresh()
{
	local string szTextBox;

	// End:0x70
	if(R6PlayerController(GetPlayerOwner()).CheckAuthority(R6PlayerController(GetPlayerOwner()).1))
	{
		// End:0x51
		if((m_bImAnAdmin == false))
		{
			m_bImAnAdmin = true;
			R6PlayerController(GetPlayerOwner()).ServerPausePreGameRoundTime();
		}
		szTextBox = m_ATextBoxLoc[0];
		m_pRestKitOptFakeW.HideWindow();		
	}
	else
	{
		m_bImAnAdmin = false;
		szTextBox = m_ATextBoxLoc[1];
		m_pRestKitOptFakeW.ShowWindow();
	}
	m_pKitSubMachinesGuns.ModifyMsgBox(szTextBox);
	m_pKitShotGuns.ModifyMsgBox(szTextBox);
	m_pKitAssaultRifles.ModifyMsgBox(szTextBox);
	m_pKitMachinesGuns.ModifyMsgBox(szTextBox);
	m_pKitSniperRifles.ModifyMsgBox(szTextBox);
	m_pKitPistols.ModifyMsgBox(szTextBox);
	m_pKitMachinePistols.ModifyMsgBox(szTextBox);
	m_pKitPrimaryWeapon.ModifyMsgBox(szTextBox);
	m_pKitSecWeapon.ModifyMsgBox(szTextBox);
	m_pKitMisc.ModifyMsgBox(szTextBox);
	m_pSubMachinesGunsTab.RefreshSubKit(m_bImAnAdmin);
	m_pShotgunsTab.RefreshSubKit(m_bImAnAdmin);
	m_pAssaultRifleTab.RefreshSubKit(m_bImAnAdmin);
	m_pMachineGunsTab.RefreshSubKit(m_bImAnAdmin);
	m_pSniperRifleTab.RefreshSubKit(m_bImAnAdmin);
	m_pPistolTab.RefreshSubKit(m_bImAnAdmin);
	m_pMachinePistolTab.RefreshSubKit(m_bImAnAdmin);
	m_pPriWpnGadgetTab.RefreshSubKit(m_bImAnAdmin);
	m_pSecWpnGadgetTab.RefreshSubKit(m_bImAnAdmin);
	m_pMiscGadgetTab.RefreshSubKit(m_bImAnAdmin);
	return;
}

//=================================================================================
// RefreshKitRest: Refresh the kit restrictions according the value on the server side 
//=================================================================================
function RefreshKitRest()
{
	local R6GameReplicationInfo pGameRepInfo;
	local R6MenuInGameMultiPlayerRootWindow R6CurrentRoot;

	R6CurrentRoot = R6MenuInGameMultiPlayerRootWindow(Root);
	pGameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);
	m_pSubMachinesGunsTab.UpdateSubMachineGunsTab(pGameRepInfo);
	m_pShotgunsTab.UpdateShotGunsTab(pGameRepInfo);
	m_pAssaultRifleTab.UpdateAssaultRifleTab(pGameRepInfo);
	m_pMachineGunsTab.UpdateMachineGunsTab(pGameRepInfo);
	m_pSniperRifleTab.UpdateSniperRifleTab(pGameRepInfo);
	m_pPistolTab.UpdatePistolsTab(pGameRepInfo);
	m_pMachinePistolTab.UpdateMachinePistolTab(pGameRepInfo);
	m_pPriWpnGadgetTab.UpdatePriWpnGadgetTab(pGameRepInfo);
	m_pSecWpnGadgetTab.UpdateSecWpnGadgetTab(pGameRepInfo);
	m_pMiscGadgetTab.UpdateMiscGadgetTab(pGameRepInfo);
	CopyStaticAToDynA(pGameRepInfo.m_szSubMachineGunsRes, m_SrvRestSubMachineGunsACopy);
	CopyStaticAToDynA(pGameRepInfo.m_szShotGunRes, m_SrvRestShotGunsACopy);
	CopyStaticAToDynA(pGameRepInfo.m_szAssRifleRes, m_SrvRestAssultRiflesACopy);
	CopyStaticAToDynA(pGameRepInfo.m_szMachGunRes, m_SrvRestMachineGunsACopy);
	CopyStaticAToDynA(pGameRepInfo.m_szSnipRifleRes, m_SrvRestSniperRiflesACopy);
	CopyStaticAToDynA(pGameRepInfo.m_szPistolRes, m_SrvRestPistolsACopy);
	CopyStaticAToDynA(pGameRepInfo.m_szMachPistolRes, m_SrvRestMachinePistolsACopy);
	CopyStaticAToDynA(pGameRepInfo.m_szGadgPrimaryRes, m_SrvRestPrimaryACopy);
	CopyStaticAToDynA(pGameRepInfo.m_szGadgSecondayRes, m_SrvRestSecondaryACopy);
	CopyStaticAToDynA(pGameRepInfo.m_szGadgMiscRes, m_SrvRestMiscGadgetsACopy);
	return;
}

function CopyStaticAToDynA(string _ASrvRest[32], out array<string> _ASrvRestCopy)
{
	local int i;

	_ASrvRestCopy.Remove(0, _ASrvRestCopy.Length);
	i = 0;
	J0x14:

	// End:0x55 [Loop If]
	if(((_ASrvRest[i] != "") && (i < 32)))
	{
		_ASrvRestCopy[i] = _ASrvRest[i];
		(i++);
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

//=================================================================================
// SendNewRestrictionsKit: Send the new restrictions kit settings to the server, only the change values. 
//						   If no modification was made return false 
//=================================================================================
function bool SendNewRestrictionsKit()
{
	local R6GameReplicationInfo R6GameRepInfo;
	local bool bSettingsChange;

	R6GameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);
	bSettingsChange = CompareARestKit(0, m_SrvRestSubMachineGunsACopy, m_pSubMachinesGunsTab.m_ASubMachineGuns, m_pSubMachinesGunsTab.m_pSubMachineGuns);
	bSettingsChange = (CompareARestKit(1, m_SrvRestShotGunsACopy, m_pShotgunsTab.m_AShotguns, m_pShotgunsTab.m_pShotguns) || bSettingsChange);
	bSettingsChange = (CompareARestKit(2, m_SrvRestAssultRiflesACopy, m_pAssaultRifleTab.m_AAssaultRifle, m_pAssaultRifleTab.m_pAssaultRifle) || bSettingsChange);
	bSettingsChange = (CompareARestKit(3, m_SrvRestMachineGunsACopy, m_pMachineGunsTab.m_AMachineGuns, m_pMachineGunsTab.m_pMachineGuns) || bSettingsChange);
	bSettingsChange = (CompareARestKit(4, m_SrvRestSniperRiflesACopy, m_pSniperRifleTab.m_ASniperRifle, m_pSniperRifleTab.m_pSniperRifle) || bSettingsChange);
	bSettingsChange = (CompareARestKit(5, m_SrvRestPistolsACopy, m_pPistolTab.m_APistol, m_pPistolTab.m_pPistol) || bSettingsChange);
	bSettingsChange = (CompareARestKit(6, m_SrvRestMachinePistolsACopy, m_pMachinePistolTab.m_AMachinePistol, m_pMachinePistolTab.m_pMachinePistol) || bSettingsChange);
	bSettingsChange = (CompareARestKit(7, m_SrvRestPrimaryACopy, m_pPriWpnGadgetTab.m_APriWpnGadget, m_pPriWpnGadgetTab.m_pPriWpnGadget, true) || bSettingsChange);
	bSettingsChange = (CompareARestKit(8, m_SrvRestSecondaryACopy, m_pSecWpnGadgetTab.m_ASecWpnGadget, m_pSecWpnGadgetTab.m_pSecWpnGadget, true) || bSettingsChange);
	bSettingsChange = (CompareARestKit(9, m_SrvRestMiscGadgetsACopy, m_pMiscGadgetTab.m_AMiscGadget, m_pMiscGadgetTab.m_pMiscGadget, true) || bSettingsChange);
	Log(("SendNewRestrictionsKit --> bSettingsChange: " $ string(bSettingsChange)));
	return bSettingsChange;
	return;
}

function bool CompareARestKit(UWindowBase.ERestKitID _eRestKitID, out array<string> _ANextSrvRestriction, array< Class > _ACurServerRestKit, R6WindowButtonBox _pAButtonBox[20], optional bool _bStringArray)
{
	local array< Class > ARestToRemove, ARestToAdd;
	local array<string> szAOldCopyOfSrvRest;
	local int i, j, iTotOldMenuRest, iRestToRemove, iRestToAdd;

	local bool bSettingsChange, bFindRes;

	i = 0;
	J0x07:

	// End:0x38 [Loop If]
	if((i < _ANextSrvRestriction.Length))
	{
		szAOldCopyOfSrvRest[i] = _ANextSrvRestriction[i];
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	iTotOldMenuRest = i;
	_ANextSrvRestriction.Remove(0, _ANextSrvRestriction.Length);
	iRestToRemove = 0;
	iRestToAdd = 0;
	i = 0;
	J0x65:

	// End:0x1CA [Loop If]
	if((i < 20))
	{
		// End:0x85
		if((_pAButtonBox[i] == none))
		{
			// [Explicit Break]
			goto J0x1CA;
		}
		// End:0x1A2
		if(_pAButtonBox[i].m_bSelected)
		{
			_ANextSrvRestriction[iRestToAdd] = Class<R6Description>(_ACurServerRestKit[i]).default.m_NameID;
			bFindRes = false;
			j = 0;
			J0xD1:

			// End:0x123 [Loop If]
			if((j < iTotOldMenuRest))
			{
				// End:0x119
				if((_ANextSrvRestriction[iRestToAdd] == szAOldCopyOfSrvRest[j]))
				{
					szAOldCopyOfSrvRest.Remove(j, 1);
					(iTotOldMenuRest--);
					bFindRes = true;
					// [Explicit Break]
					goto J0x123;
				}
				(j++);
				// [Loop Continue]
				goto J0xD1;
			}
			J0x123:

			(iRestToAdd++);
			// End:0x19F
			if((!bFindRes))
			{
				bSettingsChange = true;
				// End:0x179
				if(_bStringArray)
				{
					R6PlayerController(GetPlayerOwner()).ServerNewKitRestSettings(_eRestKitID, false,, _pAButtonBox[i].m_szMiscText);					
				}
				else
				{
					R6PlayerController(GetPlayerOwner()).ServerNewKitRestSettings(_eRestKitID, false, _ACurServerRestKit[i]);
				}
			}
			// [Explicit Continue]
			goto J0x1C0;
		}
		ARestToRemove[iRestToRemove] = _ACurServerRestKit[i];
		(iRestToRemove++);
		J0x1C0:

		(i++);
		// [Loop Continue]
		goto J0x65;
	}
	J0x1CA:

	// End:0x265
	if((iTotOldMenuRest > 0))
	{
		i = 0;
		J0x1DC:

		// End:0x265 [Loop If]
		if((i < ARestToRemove.Length))
		{
			bSettingsChange = true;
			// End:0x235
			if(_bStringArray)
			{
				R6PlayerController(GetPlayerOwner()).ServerNewKitRestSettings(_eRestKitID, true,, Class<R6Description>(ARestToRemove[i]).default.m_NameID);
				// [Explicit Continue]
				goto J0x25B;
			}
			R6PlayerController(GetPlayerOwner()).ServerNewKitRestSettings(_eRestKitID, true, ARestToRemove[i]);
			J0x25B:

			(i++);
			// [Loop Continue]
			goto J0x1DC;
		}
	}
	return bSettingsChange;
	return;
}

/////////////////////////////////////////////////////////////////
// notify the parent window by using the appropriate parent function
/////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	// End:0x2D
	if((int(E) == 2))
	{
		// End:0x2D
		if(C.IsA('R6WindowButtonBox'))
		{
			ManageR6ButtonBoxNotify(C);
		}
	}
	return;
}

/////////////////////////////////////////////////////////////////
// manage the R6WindowButtonBox notify message
/////////////////////////////////////////////////////////////////
function ManageR6ButtonBoxNotify(UWindowDialogControl C)
{
	local R6GameReplicationInfo pGameRepInfo;

	// End:0x11B
	if((m_pSubMachinesGunsTab != none))
	{
		GetR6GameReplicationInfo(pGameRepInfo);
		// End:0x30
		if((m_pCurrentSubKit != none))
		{
			m_pCurrentSubKit.HideWindow();
		}
		switch(R6WindowButtonBox(C))
		{
			// End:0x52
			case m_pKitSubMachinesGuns:
				m_pCurrentSubKit = m_pSubMachinesGunsTab;
				// End:0x11B
				break;
			// End:0x68
			case m_pKitShotGuns:
				m_pCurrentSubKit = m_pShotgunsTab;
				// End:0x11B
				break;
			// End:0x7E
			case m_pKitAssaultRifles:
				m_pCurrentSubKit = m_pAssaultRifleTab;
				// End:0x11B
				break;
			// End:0x94
			case m_pKitMachinesGuns:
				m_pCurrentSubKit = m_pMachineGunsTab;
				// End:0x11B
				break;
			// End:0xAA
			case m_pKitSniperRifles:
				m_pCurrentSubKit = m_pSniperRifleTab;
				// End:0x11B
				break;
			// End:0xC0
			case m_pKitPistols:
				m_pCurrentSubKit = m_pPistolTab;
				// End:0x11B
				break;
			// End:0xD6
			case m_pKitMachinePistols:
				m_pCurrentSubKit = m_pMachinePistolTab;
				// End:0x11B
				break;
			// End:0xEC
			case m_pKitPrimaryWeapon:
				m_pCurrentSubKit = m_pPriWpnGadgetTab;
				// End:0x11B
				break;
			// End:0x102
			case m_pKitSecWeapon:
				m_pCurrentSubKit = m_pSecWpnGadgetTab;
				// End:0x11B
				break;
			// End:0x118
			case m_pKitMisc:
				m_pCurrentSubKit = m_pMiscGadgetTab;
				// End:0x11B
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		// End:0x135
		if((m_pCurrentSubKit != none))
		{
			m_pCurrentSubKit.ShowWindow();
		}
		return;
	}
}

function GetR6GameReplicationInfo(out R6GameReplicationInfo pGameRepInfo)
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x7A
	if((((r6Root != none) && (r6Root.m_R6GameMenuCom != none)) && (R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo) != none)))
	{
		pGameRepInfo = R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo);		
	}
	else
	{
		pGameRepInfo = none;
	}
	return;
}

function Tick(float _fDelta)
{
	// End:0x8A
	if((m_pCurrentSubKit != none))
	{
		// End:0x8A
		if(m_pRestKitOptFakeW.bWindowVisible)
		{
			// End:0x5F
			if(m_pCurrentSubKit.m_pRestKitButList.m_VertSB.isHidden())
			{
				m_pRestKitOptFakeW.WinWidth = (WinWidth * 0.5000000);				
			}
			else
			{
				m_pRestKitOptFakeW.WinWidth = ((WinWidth * 0.5000000) - LookAndFeel.Size_ScrollbarWidth);
			}
		}
	}
	return;
}

function MouseWheelDown(float X, float Y)
{
	// End:0x2D
	if((m_pCurrentSubKit != none))
	{
		m_pCurrentSubKit.m_pRestKitButList.MouseWheelDown(X, Y);
	}
	return;
}

function MouseWheelUp(float X, float Y)
{
	// End:0x2D
	if((m_pCurrentSubKit != none))
	{
		m_pCurrentSubKit.m_pRestKitButList.MouseWheelUp(X, Y);
	}
	return;
}

