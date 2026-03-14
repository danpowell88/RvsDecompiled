//=============================================================================
// R6MPGameMenuCom - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MPGameMenuCom.uc : the interface between server and menu 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/29 * Created by Yannick Joly
//=============================================================================
class R6MPGameMenuCom extends R6GameMenuCom;

var R6MenuInGameMultiPlayerRootWindow m_pCurrentRoot;

simulated function SelectTeam()
{
	// End:0x68
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("SelectTeam: currently m_TeamSelection=", string(m_PlayerController.m_TeamSelection)), " m_PlayerController = "), string(m_PlayerController)));
	}
	// End:0xDA
	if(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(m_PlayerController.m_TeamSelection), int(0)), __NFUN_123__(GetGameType(), m_szPreviousGameType)), __NFUN_155__(m_iOldMapIndex, m_GameRepInfo.m_iMapIndex)))
	{
		m_iOldMapIndex = m_GameRepInfo.m_iMapIndex;
		SetStatMenuState(0);
		m_PlayerController.m_TeamSelection = 0;
	}
	return;
}

function PlayerSelection(Object.ePlayerTeamSelection newTeam)
{
	m_pCurrentRoot.m_bPlayerDidASelection = true;
	super.PlayerSelection(newTeam);
	return;
}

function Object.ePlayerTeamSelection GetPlayerSelection()
{
	// End:0x1A
	if(__NFUN_119__(m_PlayerController, none))
	{
		return m_PlayerController.m_TeamSelection;
	}
	return 0;
	return;
}

function bool IsAPlayerSelection()
{
	return __NFUN_132__(__NFUN_154__(int(GetPlayerSelection()), int(2)), __NFUN_154__(int(GetPlayerSelection()), int(3)));
	return;
}

//=====================================================================
// SetStatMenuState : Overloaded from Parent. Set the new client menu state
//=====================================================================
function SetStatMenuState(R6GameMenuCom.eClientMenuState _eNewClientMenuState)
{
	local bool bCloseSimplePopUpBox;

	bCloseSimplePopUpBox = true;
	m_pCurrentRoot.m_bActiveBar = false;
	// End:0x7A
	if(__NFUN_243__(m_pCurrentRoot.m_bPlayerDidASelection, true))
	{
		// End:0x65
		if(__NFUN_154__(int(_eNewClientMenuState), int(0)))
		{
			// End:0x62
			if(__NFUN_154__(int(m_pCurrentRoot.m_eCurWidgetInUse), int(m_pCurrentRoot.24)))
			{
				return;
			}			
		}
		else
		{
			// End:0x78
			if(__NFUN_154__(int(_eNewClientMenuState), int(6)))
			{				
			}
			else
			{
				return;
			}
		}
	}
	switch(_eNewClientMenuState)
	{
		// End:0xD5
		case 0:
			m_pCurrentRoot.m_bPreventMenuSwitch = false;
			// End:0xC1
			if(__NFUN_154__(int(m_PlayerController.m_TeamSelection), int(0)))
			{
				m_pCurrentRoot.m_bPlayerDidASelection = false;
			}
			m_pCurrentRoot.ChangeCurrentWidget(24);
			// End:0x355
			break;
		// End:0x17B
		case 5:
			// End:0x146
			if(__NFUN_119__(m_pCurrentRoot.m_pSimplePopUp, none))
			{
				// End:0x146
				if(m_pCurrentRoot.m_pSimplePopUp.bWindowVisible)
				{
					// End:0x146
					if(__NFUN_154__(int(m_pCurrentRoot.m_pSimplePopUp.m_ePopUpID), int(30)))
					{
						m_pCurrentRoot.m_iWidgetKA = m_pCurrentRoot.0;
						return;
					}
				}
			}
			m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.SetNavBarState(false, true);
			// End:0x17B
			if(__NFUN_154__(int(m_eStatMenuState), int(4)))
			{
				return;
			}
		// End:0x1CA
		case 1:
			m_pCurrentRoot.m_bActiveBar = true;
			m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.SetNavBarState(false, true);
			m_pCurrentRoot.ChangeWidget(0, false, true);
			// End:0x355
			break;
		// End:0x242
		case 2:
			m_pCurrentRoot.m_bActiveBar = true;
			m_pCurrentRoot.GetLevel().__NFUN_2711__(0);
			// End:0x226
			if(m_GameRepInfo.IsInAGameState())
			{
				m_pCurrentRoot.ChangeCurrentWidget(25);
				_eNewClientMenuState = 1;				
			}
			else
			{
				m_pCurrentRoot.ChangeCurrentWidget(26);
				bCloseSimplePopUpBox = false;
			}
			// End:0x355
			break;
		// End:0x24A
		case 3:
			// End:0x355
			break;
		// End:0x2B6
		case 4:
			// End:0x28A
			if(__NFUN_132__(__NFUN_154__(int(m_PlayerController.m_TeamSelection), int(2)), __NFUN_154__(int(m_PlayerController.m_TeamSelection), int(3))))
			{
				SetReadyButton(false);
			}
			m_pCurrentRoot.ChangeCurrentWidget(26);
			m_pCurrentRoot.GetLevel().__NFUN_2711__(0);
			// End:0x355
			break;
		// End:0x327
		case 6:
			m_pCurrentRoot.ChangeCurrentWidget(26);
			m_pCurrentRoot.m_bPreventMenuSwitch = true;
			Class'Engine.Actor'.static.__NFUN_2619__(false);
			m_pCurrentRoot.GetLevel().__NFUN_2711__(0);
			m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.SetNavBarState(true);
			// End:0x355
			break;
		// End:0x347
		case 7:
			m_pCurrentRoot.m_pIntermissionMenuWidget.ForceClosePopUp();
			// End:0x355
			break;
		// End:0xFFFF
		default:
			bCloseSimplePopUpBox = false;
			// End:0x355
			break;
			break;
	}
	// End:0x36D
	if(bCloseSimplePopUpBox)
	{
		m_pCurrentRoot.CloseSimplePopUpBox();
	}
	m_eStatMenuState = _eNewClientMenuState;
	return;
}

function SetupPlayerPrefs()
{
	local string Tag;
	local Class<R6PrimaryWeaponDescription> PrimaryWeaponClass;
	local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
	local Class<R6BulletDescription> PrimaryWeaponBulletClass, SecondaryWeaponBulletClass;
	local Class<R6GadgetDescription> PrimaryGadgetClass, SecondaryGadgetClass;
	local Class<R6WeaponGadgetDescription> PrimaryWeaponGadgetClass, SecondaryWeaponGadgetClass;
	local Class<R6ArmorDescription> ArmorDescriptionClass;
	local bool Found;
	local int k;
	local Class<R6GadgetDescription> replaceGadgetClass;

	PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(m_szPrimaryWeapon, Class'Core.Class'));
	PrimaryWeaponBulletClass = Class'R6Description.R6DescriptionManager'.static.GetPrimaryBulletDesc(PrimaryWeaponClass, m_szPrimaryWeaponBullet);
	PrimaryWeaponGadgetClass = Class'R6Description.R6DescriptionManager'.static.GetPrimaryWeaponGadgetDesc(PrimaryWeaponClass, m_szPrimaryWeaponGadget);
	SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(DynamicLoadObject(m_szSecondaryWeapon, Class'Core.Class'));
	SecondaryWeaponBulletClass = Class'R6Description.R6DescriptionManager'.static.GetSecondaryBulletDesc(SecondaryWeaponClass, m_szSecondaryWeaponBullet);
	SecondaryWeaponGadgetClass = Class'R6Description.R6DescriptionManager'.static.GetSecondaryWeaponGadgetDesc(SecondaryWeaponClass, m_szSecondaryWeaponGadget);
	PrimaryGadgetClass = Class<R6GadgetDescription>(DynamicLoadObject(m_szPrimaryGadget, Class'Core.Class'));
	SecondaryGadgetClass = Class<R6GadgetDescription>(DynamicLoadObject(m_szSecondaryGadget, Class'Core.Class'));
	// End:0x117
	if(Class'R6Menu.R6MenuMPAdvGearWidget'.static.CheckGadget(string(PrimaryGadgetClass), m_pCurrentRoot, false, replaceGadgetClass))
	{
		PrimaryGadgetClass = replaceGadgetClass;
	}
	// End:0x14D
	if(Class'R6Menu.R6MenuMPAdvGearWidget'.static.CheckGadget(string(SecondaryGadgetClass), m_pCurrentRoot, false, replaceGadgetClass, string(PrimaryGadgetClass)))
	{
		SecondaryGadgetClass = replaceGadgetClass;
	}
	// End:0x18D
	if(__NFUN_123__(m_szArmor, ""))
	{
		ArmorDescriptionClass = Class<R6ArmorDescription>(DynamicLoadObject(m_szArmor, Class'Core.Class'));
		m_PlayerPrefInfo.m_ArmorName = ArmorDescriptionClass.default.m_ClassName;
	}
	m_PlayerPrefInfo.m_WeaponGadgetName[0] = PrimaryWeaponGadgetClass.default.m_ClassName;
	m_PlayerPrefInfo.m_WeaponGadgetName[1] = SecondaryWeaponGadgetClass.default.m_ClassName;
	m_PlayerPrefInfo.m_GadgetName[0] = PrimaryGadgetClass.default.m_ClassName;
	m_PlayerPrefInfo.m_GadgetName[1] = SecondaryGadgetClass.default.m_ClassName;
	Found = false;
	k = 0;
	J0x208:

	// End:0x310 [Loop If]
	if(__NFUN_130__(__NFUN_150__(k, PrimaryWeaponClass.default.m_WeaponTags.Length), __NFUN_242__(Found, false)))
	{
		// End:0x29C
		if(__NFUN_122__(PrimaryWeaponClass.default.m_WeaponTags[k], PrimaryWeaponGadgetClass.default.m_NameTag))
		{
			Found = true;
			m_PlayerPrefInfo.m_WeaponName[0] = PrimaryWeaponClass.default.m_WeaponClasses[k];
			Tag = PrimaryWeaponClass.default.m_WeaponTags[k];
			// [Explicit Continue]
			goto J0x306;
		}
		// End:0x306
		if(__NFUN_122__(PrimaryWeaponClass.default.m_WeaponTags[k], PrimaryWeaponBulletClass.default.m_NameTag))
		{
			Found = true;
			m_PlayerPrefInfo.m_WeaponName[0] = PrimaryWeaponClass.default.m_WeaponClasses[k];
			Tag = PrimaryWeaponClass.default.m_WeaponTags[k];
		}
		J0x306:

		__NFUN_165__(k);
		// [Loop Continue]
		goto J0x208;
	}
	// End:0x3B8
	if(__NFUN_242__(Found, false))
	{
		// End:0x385
		if(__NFUN_155__(__NFUN_126__(string(PrimaryWeaponClass), "PrimaryWeaponNone"), -1))
		{
			m_PlayerPrefInfo.m_WeaponName[0] = "R6Description.R6DescPrimaryWeaponNone";
			Tag = "NONE";			
		}
		else
		{
			m_PlayerPrefInfo.m_WeaponName[0] = PrimaryWeaponClass.default.m_WeaponClasses[0];
			Tag = PrimaryWeaponClass.default.m_WeaponTags[0];
		}
	}
	// End:0x3EA
	if(__NFUN_122__(Tag, "SILENCED"))
	{
		m_PlayerPrefInfo.m_BulletType[0] = PrimaryWeaponBulletClass.default.m_SubsonicClassName;		
	}
	else
	{
		m_PlayerPrefInfo.m_BulletType[0] = PrimaryWeaponBulletClass.default.m_ClassName;
	}
	Found = false;
	k = 0;
	J0x414:

	// End:0x51C [Loop If]
	if(__NFUN_130__(__NFUN_150__(k, SecondaryWeaponClass.default.m_WeaponTags.Length), __NFUN_242__(Found, false)))
	{
		// End:0x4A8
		if(__NFUN_122__(SecondaryWeaponClass.default.m_WeaponTags[k], SecondaryWeaponGadgetClass.default.m_NameTag))
		{
			Found = true;
			m_PlayerPrefInfo.m_WeaponName[1] = SecondaryWeaponClass.default.m_WeaponClasses[k];
			Tag = SecondaryWeaponClass.default.m_WeaponTags[k];
			// [Explicit Continue]
			goto J0x512;
		}
		// End:0x512
		if(__NFUN_122__(SecondaryWeaponClass.default.m_WeaponTags[k], SecondaryWeaponBulletClass.default.m_NameTag))
		{
			Found = true;
			m_PlayerPrefInfo.m_WeaponName[1] = SecondaryWeaponClass.default.m_WeaponClasses[k];
			Tag = SecondaryWeaponClass.default.m_WeaponTags[k];
		}
		J0x512:

		__NFUN_165__(k);
		// [Loop Continue]
		goto J0x414;
	}
	// End:0x55B
	if(__NFUN_242__(Found, false))
	{
		m_PlayerPrefInfo.m_WeaponName[1] = SecondaryWeaponClass.default.m_WeaponClasses[0];
		Tag = SecondaryWeaponClass.default.m_WeaponTags[0];
	}
	// End:0x58D
	if(__NFUN_122__(Tag, "SILENCED"))
	{
		m_PlayerPrefInfo.m_BulletType[1] = SecondaryWeaponBulletClass.default.m_SubsonicClassName;		
	}
	else
	{
		m_PlayerPrefInfo.m_BulletType[1] = SecondaryWeaponBulletClass.default.m_ClassName;
	}
	return;
}

//====================================================================================
// DisconnectClient: Disconnect the client from the server
//====================================================================================
function DisconnectClient(LevelInfo _Level)
{
	local UdpBeacon aBeacon;

	m_bImCurrentlyDisconnect = true;
	// End:0x66
	if(__NFUN_154__(int(_Level.NetMode), int(NM_ListenServer)))
	{
		R6MultiPlayerGameInfo(_Level.Game).m_GameService.__NFUN_3561__(m_GameRepInfo);
		R6GameInfo(_Level.Game).DestroyBeacon();
	}
	return;
}

//====================================================================================
// SetPlayerReadyStatus: Set the ready button status of the player
//====================================================================================
function SetPlayerReadyStatus(bool _bPlayerReady)
{
	super.SetPlayerReadyStatus(_bPlayerReady);
	// End:0x48
	if(__NFUN_119__(m_pCurrentRoot, none))
	{
		m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.m_pPlayerReady.m_bSelected = _bPlayerReady;
	}
	return;
}

function RefreshReadyButtonStatus()
{
	// End:0x9B
	if(__NFUN_132__(__NFUN_154__(int(m_GameRepInfo.m_eCurrectServerState), m_GameRepInfo.1), __NFUN_154__(int(m_GameRepInfo.m_eCurrectServerState), m_GameRepInfo.0)))
	{
		// End:0x91
		if(__NFUN_132__(m_PlayerController.IsPlayerPassiveSpectator(), __NFUN_130__(m_PlayerController.bOnlySpectator, __NFUN_155__(int(m_GameRepInfo.m_eCurrectServerState), m_GameRepInfo.1))))
		{
			SetReadyButton(true);			
		}
		else
		{
			SetReadyButton(false);
		}		
	}
	else
	{
		// End:0x106
		if(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(m_GameRepInfo.m_eCurrectServerState), m_GameRepInfo.2), __NFUN_154__(int(m_GameRepInfo.m_eCurrectServerState), m_GameRepInfo.3)), __NFUN_154__(int(m_GameRepInfo.m_eCurrectServerState), m_GameRepInfo.4)))
		{
			SetReadyButton(true);
		}
	}
	return;
}

//====================================================================================
// SetReadyButton: Set the ready button state in the menu (disable when the player play, or enable -- spectator)
//====================================================================================
function SetReadyButton(bool _bDisable)
{
	// End:0x6F
	if(__NFUN_119__(m_pCurrentRoot, none))
	{
		// End:0x43
		if(_bDisable)
		{
			m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.m_pPlayerReady.bDisabled = true;			
		}
		else
		{
			m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.m_pPlayerReady.bDisabled = false;
		}
	}
	return;
}

function bool IsInBetweenRoundMenu(optional bool _bIncludeCMSInit)
{
	// End:0x1B
	if(_bIncludeCMSInit)
	{
		// End:0x1B
		if(__NFUN_154__(int(m_eStatMenuState), int(0)))
		{
			return true;
		}
	}
	// End:0x28
	if(__NFUN_114__(m_GameRepInfo, none))
	{
		return false;
	}
	// End:0x49
	if(__NFUN_154__(int(m_GameRepInfo.m_eCurrectServerState), m_GameRepInfo.1))
	{
		return true;
	}
	return false;
	return;
}

// this returns an INT so that we can know where to display the player on
// the tab menu page
function int GeTTeamSelection(int _iIndex)
{
	local PlayerMenuInfo _PlayerMenuInfo;

	// End:0x2B
	if(__NFUN_122__(GetGameType(), "RGM_DeathmatchMode"))
	{
		return PTSToInt(2);		
	}
	else
	{
		m_pCurrentRoot.GetLevel().__NFUN_1230__(_iIndex, _PlayerMenuInfo);
		// End:0x91
		if(__NFUN_132__(__NFUN_154__(int(IntToPTS(_PlayerMenuInfo.iTeamSelection)), int(2)), __NFUN_154__(int(IntToPTS(_PlayerMenuInfo.iTeamSelection)), int(3))))
		{
			return _PlayerMenuInfo.iTeamSelection;			
		}
		else
		{
			return PTSToInt(4);
		}
	}
	return;
}

simulated function SavePlayerSetupInfo()
{
	// End:0x0D
	if(__NFUN_114__(m_PlayerController, none))
	{
		return;
	}
	m_pCurrentRoot.GetLevel().__NFUN_1233__(m_PlayerPrefInfo.m_CharacterName, m_szArmor, m_szPrimaryWeapon, m_szPrimaryWeaponGadget, m_szPrimaryWeaponBullet, m_szSecondaryWeapon, m_szSecondaryWeaponGadget, m_szSecondaryWeaponBullet, m_szPrimaryGadget, m_szSecondaryGadget);
	SetupPlayerPrefs();
	m_PlayerController.m_PlayerPrefs.m_CharacterName = m_PlayerPrefInfo.m_CharacterName;
	m_PlayerController.m_PlayerPrefs.m_ArmorName = m_PlayerPrefInfo.m_ArmorName;
	m_PlayerController.m_PlayerPrefs.m_WeaponName1 = m_PlayerPrefInfo.m_WeaponName[0];
	m_PlayerController.m_PlayerPrefs.m_WeaponGadgetName1 = m_PlayerPrefInfo.m_WeaponGadgetName[0];
	m_PlayerController.m_PlayerPrefs.m_BulletType1 = m_PlayerPrefInfo.m_BulletType[0];
	m_PlayerController.m_PlayerPrefs.m_WeaponName2 = m_PlayerPrefInfo.m_WeaponName[1];
	m_PlayerController.m_PlayerPrefs.m_WeaponGadgetName2 = m_PlayerPrefInfo.m_WeaponGadgetName[1];
	m_PlayerController.m_PlayerPrefs.m_BulletType2 = m_PlayerPrefInfo.m_BulletType[1];
	m_PlayerController.m_PlayerPrefs.m_GadgetName1 = m_PlayerPrefInfo.m_GadgetName[0];
	m_PlayerController.m_PlayerPrefs.m_GadgetName2 = m_PlayerPrefInfo.m_GadgetName[1];
	m_PlayerController.ServerPlayerPref(m_PlayerController.m_PlayerPrefs);
	return;
}

simulated function InitialisePlayerSetupInfo()
{
	// End:0x36
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__("In ", string(self)), "::InitialisePlayerSetupInfo()"));
	}
	m_pCurrentRoot.GetLevel().__NFUN_1232__(m_PlayerPrefInfo.m_CharacterName, m_szArmor, m_szPrimaryWeapon, m_szPrimaryWeaponGadget, m_szPrimaryWeaponBullet, m_szSecondaryWeapon, m_szSecondaryWeaponGadget, m_szSecondaryWeaponBullet, m_szPrimaryGadget, m_szSecondaryGadget);
	SetupPlayerPrefs();
	return;
}

simulated function string GetGameType()
{
	// End:0x20
	if(__NFUN_114__(m_GameRepInfo, none))
	{
		return "RGM_NoRulesMode";		
	}
	else
	{
		return m_GameRepInfo.m_szGameTypeFlagRep;
	}
	return;
}

//this function is called when team killer options are on and I have been killed by my team mate
function TKPopUpBox(string _KillerName)
{
	// End:0xEA
	if(__NFUN_242__(R6PlayerController(m_PlayerController).m_bAlreadyPoppedTKPopUpBox, false))
	{
		// End:0x52
		if(__NFUN_129__(m_pCurrentRoot.Console.__NFUN_281__('Game')))
		{
			m_pCurrentRoot.Console.__NFUN_113__('Game');
		}
		m_pCurrentRoot.SimplePopUp(Localize("MPMiscMessages", "TKPopUpBoxTitle", "R6GameInfo"), __NFUN_168__(_KillerName, Localize("MPMiscMessages", "DoYouWantToPenalize", "R6GameInfo")), 30);
		R6PlayerController(m_PlayerController).m_bAlreadyPoppedTKPopUpBox = true;
	}
	return;
}

function TKPopUpDone(bool _bApplyTeamKillerPenalty)
{
	m_PlayerController.ServerTKPopUpDone(_bApplyTeamKillerPenalty);
	R6PlayerController(m_PlayerController).m_bProcessingRequestTKPopUp = false;
	return;
}

event CountDownPopUpBox()
{
	m_pCurrentRoot.Console.ViewportOwner.u8WaitLaunchStatingSound = 0;
	// End:0x68
	if(__NFUN_132__(__NFUN_154__(int(m_PlayerController.m_TeamSelection), int(2)), __NFUN_154__(int(m_PlayerController.m_TeamSelection), int(3))))
	{
		m_pCurrentRoot.ChangeCurrentWidget(34);
	}
	return;
}

function CountDownPopUpBoxDone()
{
	// End:0x6C
	if(__NFUN_155__(int(m_pCurrentRoot.m_eCurWidgetInUse), int(m_pCurrentRoot.34)))
	{
		// End:0x6A
		if(__NFUN_130__(__NFUN_119__(m_pCurrentRoot.GetPlayerOwner().Pawn, none), m_pCurrentRoot.GetPlayerOwner().Pawn.IsAlive()))
		{			
		}
		else
		{
			return;
		}
	}
	m_pCurrentRoot.ChangeWidget(0, false, true);
	return;
}

//============================================================================================
// ActiveVoteMenu: Active the vote menu -- kick or not the player
//============================================================================================
function ActiveVoteMenu(bool _bActiveMenu, optional string _szPlayerNameToKick)
{
	m_pCurrentRoot.VoteMenu(_szPlayerNameToKick, _bActiveMenu);
	return;
}

//============================================================================================
// SetVoteResult: Set the vote result
//============================================================================================
function SetVoteResult(bool _bKickPlayer)
{
	// End:0x34
	if(_bKickPlayer)
	{
		R6PlayerController(m_PlayerController).Vote(1);
		__NFUN_231__("KICK PLAYER YES");		
	}
	else
	{
		R6PlayerController(m_PlayerController).Vote(2);
		__NFUN_231__("KICK PLAYER NO");
	}
	return;
}

function NewServerState()
{
	local R6PlayerController _localPlayer;

	// End:0x0D
	if(__NFUN_114__(m_GameRepInfo, none))
	{
		return;
	}
	super.NewServerState();
	// End:0x54
	if(__NFUN_154__(int(m_GameRepInfo.m_eCurrectServerState), m_GameRepInfo.4))
	{
		m_pCurrentRoot.m_pIntermissionMenuWidget.m_pMPInterHeader.RefreshRoundInfo();
	}
	return;
}

function SetClientServerSettings(bool _bCanChangeOptions)
{
	m_pCurrentRoot.m_pIntermissionMenuWidget.SetClientServerSettings(_bCanChangeOptions);
	return;
}

//===========================================================================================
// GetNbOfTeamPlayer: get the number of player of a specific team, spectator include
//===========================================================================================
function int GetNbOfTeamPlayer(bool _bGreenTeam)
{
	local int i, iGreenTeam, iRedTeam, iNbOfPlayer, iIndex;

	RefreshMPlayerInfo();
	iGreenTeam = int(2);
	iRedTeam = int(3);
	iNbOfPlayer = 0;
	i = 0;
	J0x28:

	// End:0x8C [Loop If]
	if(__NFUN_150__(i, m_iLastValidIndex))
	{
		iIndex = GeTTeamSelection(i);
		// End:0x6B
		if(_bGreenTeam)
		{
			// End:0x68
			if(__NFUN_154__(iIndex, iGreenTeam))
			{
				__NFUN_161__(iNbOfPlayer, 1);
			}
			// [Explicit Continue]
			goto J0x82;
		}
		// End:0x82
		if(__NFUN_154__(iIndex, iRedTeam))
		{
			__NFUN_161__(iNbOfPlayer, 1);
		}
		J0x82:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x28;
	}
	return __NFUN_249__(iNbOfPlayer, 8);
	return;
}

simulated function bool IsInGame()
{
	return __NFUN_154__(int(m_pCurrentRoot.m_eCurWidgetInUse), int(0));
	return;
}

//====================================================================================
// GetPlayerDidASelection: 
//====================================================================================
function bool GetPlayerDidASelection()
{
	return m_pCurrentRoot.m_bPlayerDidASelection;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_eLogOldCurrectServerState
// REMOVED IN 1.60: function GetPlayerSelection
// REMOVED IN 1.60: function LogServerState
