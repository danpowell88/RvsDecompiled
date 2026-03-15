//=============================================================================
// R6MenuOptionsTab - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuOptionsTab.uc : Manage the options window. Not a real tab... plus a page system
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/11  * Create by Yannick Joly
//=============================================================================
class R6MenuOptionsTab extends UWindowDialogClientWindow;

const C_fSCROLLBAR_WIDTH = 140;
const C_fSCROLLBAR_HEIGHT = 14;
const C_fXPOS_SCROLLBAR = 250;
const C_fXPOS_COMBOCONTROL = 250;
const C_ICOMBOCONTROL_WIDTH = 140;

var bool m_bDrawLineOverButton;
var bool m_bInitComplete;
// NEW IN 1.60
var bool m_bInGame;
var R6WindowButton m_pGeneralButUse;  // the button under the line, use for reset default button, activate mods...
var Region SimpleBorderRegion;
// NEW IN 1.60
var string m_szGeneralButLoc;
// NEW IN 1.60
var string m_szGeneralButTip;

//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================
function Created()
{
	m_bInGame = R6MenuOptionsWidget(OwnerWindow).m_bInGame;
	m_szGeneralButLoc = Localize("Options", "ResetToDefault", "R6Menu");
	m_szGeneralButTip = Localize("Tip", "ResetToDefault", "R6Menu");
	return;
}

// NEW IN 1.60
function InitPageOptions()
{
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x90
	if(m_bDrawLineOverButton)
	{
		C.SetDrawColor(byte(255), byte(255), byte(255));
		DrawStretchedTextureSegment(C, 0.0000000, (WinHeight - float(15)), WinWidth, float(SimpleBorderRegion.H), float(SimpleBorderRegion.X), float(SimpleBorderRegion.Y), float(SimpleBorderRegion.W), float(SimpleBorderRegion.H), R6MenuRSLookAndFeel(LookAndFeel).m_R6ScrollTexture);
	}
	return;
}

// GENERAL
function InitResetButton()
{
	m_bDrawLineOverButton = true;
	m_pGeneralButUse = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 0.0000000, (WinHeight - float(15)), WinWidth, 15.0000000, self));
	m_pGeneralButUse.Text = m_szGeneralButLoc;
	m_pGeneralButUse.ToolTipString = m_szGeneralButTip;
	m_pGeneralButUse.Align = 2;
	m_pGeneralButUse.m_iButtonID = 0;
	return;
}

// NEW IN 1.60
function UpdateOptionsInPage()
{
	return;
}

// NEW IN 1.60
function UpdateOptionsInEngine()
{
	return;
}

// NEW IN 1.60
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	// End:0x28
	if((int(Result) == int(3)))
	{
		switch(_ePopUpID)
		{
			// End:0x25
			case 55:
				RestoreDefaultValue();
				// End:0x28
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		// End:0x4E
		if((R6MenuInGameRootWindow(Root) != none))
		{
			R6MenuInGameRootWindow(Root).m_bInPopUp = false;
		}
		return;
	}
}

//=============================================================================================
// RestoreDefaultValue: Restore the default value of the current window
//=============================================================================================
function RestoreDefaultValue()
{
	return;
}

/////////////////////////////////////////////////////////////////
// notify the parent window by using the appropriate parent function
/////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	return;
}

function R6WindowComboControl SetComboControlButton(Region _RDefaultW, string _szTitle, string _szTip)
{
	local R6WindowComboControl _pR6WindowComboControl;

	_pR6WindowComboControl = R6WindowComboControl(CreateControl(Class'R6Window.R6WindowComboControl', float(_RDefaultW.X), float(_RDefaultW.Y), float(_RDefaultW.W), LookAndFeel.Size_ComboHeight, self));
	_pR6WindowComboControl.AdjustTextW(_szTitle, 0.0000000, 0.0000000, (float(_RDefaultW.W) * 0.5000000), LookAndFeel.Size_ComboHeight);
	_pR6WindowComboControl.AdjustEditBoxW(0.0000000, 140.0000000, LookAndFeel.Size_ComboHeight);
	_pR6WindowComboControl.SetEditBoxTip(_szTip);
	return _pR6WindowComboControl;
	return;
}

defaultproperties
{
	SimpleBorderRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=16418,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pComboLevel4
// REMOVED IN 1.60: var m_pSndLocEnum3
// REMOVED IN 1.60: var m_pConnectionSpeed5
// REMOVED IN 1.60: var m_ePageOptID
// REMOVED IN 1.60: var m_pOptionAlwaysRun
// REMOVED IN 1.60: var m_pOptionInvertMouse
// REMOVED IN 1.60: var m_pPopUpLoadPlan
// REMOVED IN 1.60: var m_pPopUpQuickPlay
// REMOVED IN 1.60: var m_pAutoAim
// REMOVED IN 1.60: var m_pAutoAimTexture
// REMOVED IN 1.60: var m_pAutoAimTextReg4
// REMOVED IN 1.60: var m_pOptionMouseSens
// REMOVED IN 1.60: var m_iRefMouseSens
// REMOVED IN 1.60: var m_pAmbientVolume
// REMOVED IN 1.60: var m_pVoicesVolume
// REMOVED IN 1.60: var m_pMusicVolume
// REMOVED IN 1.60: var m_pSndQuality
// REMOVED IN 1.60: var m_pAudioVirtual
// REMOVED IN 1.60: var m_pSndHardware
// REMOVED IN 1.60: var m_pEAX
// REMOVED IN 1.60: var m_EaxLogo
// REMOVED IN 1.60: var m_EaxTexture
// REMOVED IN 1.60: var m_EaxTextureReg
// REMOVED IN 1.60: var m_bEAXNotSupported
// REMOVED IN 1.60: var m_iRefAmbientVolume
// REMOVED IN 1.60: var m_iRefVoicesVolume
// REMOVED IN 1.60: var m_iRefMusicVolume
// REMOVED IN 1.60: var m_pVideoRes
// REMOVED IN 1.60: var m_pTextureDetail
// REMOVED IN 1.60: var m_pLightmapDetail
// REMOVED IN 1.60: var m_pRainbowsDetail
// REMOVED IN 1.60: var m_pHostagesDetail
// REMOVED IN 1.60: var m_pTerrosDetail
// REMOVED IN 1.60: var m_pRainbowsShadowLevel
// REMOVED IN 1.60: var m_pHostagesShadowLevel
// REMOVED IN 1.60: var m_pTerrosShadowLevel
// REMOVED IN 1.60: var m_pGoreLevel
// REMOVED IN 1.60: var m_pDecalsDetail
// REMOVED IN 1.60: var m_pAnimGeometry
// REMOVED IN 1.60: var m_pHideDeadBodies
// REMOVED IN 1.60: var m_pLowDetailSmoke
// REMOVED IN 1.60: var m_pHudWeaponName
// REMOVED IN 1.60: var m_pHudShowFPWeapon
// REMOVED IN 1.60: var m_pHudOtherTInfo
// REMOVED IN 1.60: var m_pHudCurTInfo
// REMOVED IN 1.60: var m_pHudCircumIcon
// REMOVED IN 1.60: var m_pHudWpInfo
// REMOVED IN 1.60: var m_pHudReticule
// REMOVED IN 1.60: var m_pHudShowTNames
// REMOVED IN 1.60: var m_pHudCharInfo
// REMOVED IN 1.60: var m_pHudShowRadar
// REMOVED IN 1.60: var m_pHudBGTex
// REMOVED IN 1.60: var m_pHudWeaponNameTex
// REMOVED IN 1.60: var m_pHudShowFPWeaponTex
// REMOVED IN 1.60: var m_pHudOtherTInfoTex
// REMOVED IN 1.60: var m_pHudCurTInfoTex
// REMOVED IN 1.60: var m_pHudCircumIconTex
// REMOVED IN 1.60: var m_pHudWpInfoTex
// REMOVED IN 1.60: var m_pHudReticuleTex
// REMOVED IN 1.60: var m_pHudCharInfoTex
// REMOVED IN 1.60: var m_pHudShowTNamesTex
// REMOVED IN 1.60: var m_pHudShowRadarTex
// REMOVED IN 1.60: var m_pOptionPlayerName
// REMOVED IN 1.60: var m_pSpeedConnection
// REMOVED IN 1.60: var m_pOptionGender
// REMOVED IN 1.60: var m_pArmpatchChooser
// REMOVED IN 1.60: var m_pOptionAutoPatchDownload
// REMOVED IN 1.60: var m_pStartDownloadButton
// REMOVED IN 1.60: var m_pPatchStatus
// REMOVED IN 1.60: var m_RArmpatchBitmapPos
// REMOVED IN 1.60: var m_RArmpatchListPos
// REMOVED IN 1.60: var m_bTriggerLagWanted
// REMOVED IN 1.60: var m_pPunkBusterOpt
// REMOVED IN 1.60: var m_bPBNotInstalled
// REMOVED IN 1.60: var m_pListControls
// REMOVED IN 1.60: var m_pCurItem
// REMOVED IN 1.60: var m_pOptControls
// REMOVED IN 1.60: var m_pPopUpKeyBG
// REMOVED IN 1.60: var m_pKeyMenuReAssignPopUp
// REMOVED IN 1.60: var m_szOldActionKey
// REMOVED IN 1.60: var m_iKeyToAssign
// REMOVED IN 1.60: var m_pListOfMODS
// REMOVED IN 1.60: var m_pInfo
// REMOVED IN 1.60: function InitActivateButton
// REMOVED IN 1.60: function InitOptionGame
// REMOVED IN 1.60: function SetGameValues
// REMOVED IN 1.60: function SetMenuGameValues
// REMOVED IN 1.60: function InitOptionSound
// REMOVED IN 1.60: function SetSoundValues
// REMOVED IN 1.60: function SetMenuSoundValues
// REMOVED IN 1.60: function ConvertToSndQuality
// REMOVED IN 1.60: function ConvertToSndQualityString
// REMOVED IN 1.60: function ConvertToAudioString
// REMOVED IN 1.60: function InitOptionGraphic
// REMOVED IN 1.60: function SetGraphicValues
// REMOVED IN 1.60: function SetMenuGraphicValues
// REMOVED IN 1.60: function ConvertToGraphicString
// REMOVED IN 1.60: function AddGraphComboControlItem
// REMOVED IN 1.60: function AddVideoResolution
// REMOVED IN 1.60: function GetResolutionXY
// REMOVED IN 1.60: function InitOptionHud
// REMOVED IN 1.60: function SetHudValues
// REMOVED IN 1.60: function SetMenuHudValues
// REMOVED IN 1.60: function CreateHudOptionsTex
// REMOVED IN 1.60: function CreateHudBitmapWindow
// REMOVED IN 1.60: function UpdateHudOptionsTex
// REMOVED IN 1.60: function InitOptionMulti
// REMOVED IN 1.60: function SetMultiValues
// REMOVED IN 1.60: function SetMenuMultiValues
// REMOVED IN 1.60: function SetPBOptValue
// REMOVED IN 1.60: function SetPBOptDisable
// REMOVED IN 1.60: function ConvertToNetSpeedString
// REMOVED IN 1.60: function InitOptionControls
// REMOVED IN 1.60: function AddLineItem
// REMOVED IN 1.60: function AddTitleItem
// REMOVED IN 1.60: function AddKeyItem
// REMOVED IN 1.60: function RefreshKeyList
// REMOVED IN 1.60: function GetLocKeyNameByActionKey
// REMOVED IN 1.60: function CreateKeyPopUp
// REMOVED IN 1.60: function ManagePopUpKey
// REMOVED IN 1.60: function CloseAllKeyPopUp
// REMOVED IN 1.60: function GetCurrentKeyItem
// REMOVED IN 1.60: function GetCurActionKey
// REMOVED IN 1.60: function GetCurKeyName
// REMOVED IN 1.60: function GetCurKeyInputClass
// REMOVED IN 1.60: function RefreshKeyItem
// REMOVED IN 1.60: function KeyPressed
// REMOVED IN 1.60: function IsKeyValid
// REMOVED IN 1.60: function InitOptionMODS
// REMOVED IN 1.60: function SetMenuMODS
// REMOVED IN 1.60: function InitOptionPatchService
// REMOVED IN 1.60: function SetPatchServiceValues
// REMOVED IN 1.60: function SetMenuPatchServiceValues
// REMOVED IN 1.60: function GetDownloadMetric
// REMOVED IN 1.60: function GetDownloadPercentageStringValues
// REMOVED IN 1.60: function GetDownloadString
// REMOVED IN 1.60: function UpdatePatchStatus
// REMOVED IN 1.60: function ManageNotifyForSound
// REMOVED IN 1.60: function ManageNotifyForNetwork
