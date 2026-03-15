//=============================================================================
// R6GameMenuCom - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6GameMenuCom.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created by Aristomenis Kolokathis
//=============================================================================
class R6GameMenuCom extends Object
    native;

enum eClientMenuState
{
	CMS_Initial,                    // 0
	CMS_SpecMenu,                   // 1
	CMS_BetRoundmenu,               // 2
	CMS_DisplayStat,                // 3
	CMS_DisplayForceStat,           // 4
	CMS_PlayerDead,                 // 5
	CMS_DisplayForceStatLocked,     // 6
	CMS_InPreGameState              // 7
};

struct PlayerPrefInfo
{
	var string m_CharacterName;
	var string m_ArmorName;
	var string m_WeaponName[2];
	var string m_WeaponGadgetName[2];
	var string m_BulletType[2];
	var string m_GadgetName[2];
};

var R6GameMenuCom.eClientMenuState m_eStatMenuState;
var int m_iLastValidIndex;
var int m_iOldMapIndex;  // used to determine if map has been rotated
var bool m_bImCurrentlyDisconnect;  // when we are in disconnecting process
var bool bShowLog;
var PlayerController m_PlayerController;
var GameReplicationInfo m_GameRepInfo;
var PlayerPrefInfo m_PlayerPrefInfo;  // when this is updated, make sure to call SavePlayerSetupInfo() after;
//Weapons Descriptions
var string m_szPrimaryWeapon;  // R6PrimaryWeaponDescription class name
var string m_szPrimaryWeaponGadget;  // Token representing type of weapon gadget
var string m_szPrimaryWeaponBullet;  // Token representing type of bullets
var string m_szPrimaryGadget;  // R6GadgetDescription class name
var string m_szSecondaryWeapon;  // R6SecondaryWeaponDescription class name
var string m_szSecondaryWeaponGadget;  // Token representing type of weapon gadget
var string m_szSecondaryWeaponBullet;  // /Token representing type of bullets
var string m_szSecondaryGadget;  // R6GadgetDescription class name
var string m_szArmor;  // R6ArmorDescription class name
var string m_szServerName;
var string m_szPreviousGameType;  // this was the mode played in the last round

// PostBeginPlays are generally called on actors by native code
// since this is now an object it's PostBeginPlay get's called by
// R6MenuInGameMultiPlayerRootWindow.uc, this is the object that
// created this instance
function PostBeginPlay()
{
	InitialisePlayerSetupInfo();
	return;
}

function ClearLevelReferences()
{
	m_PlayerController = none;
	m_GameRepInfo = none;
	return;
}

//====================================================================================
// IsInitialisationComplete: true when the initialisation is complete
//====================================================================================
function bool IsInitialisationCompleted()
{
	return ((m_PlayerController != none) && (m_GameRepInfo != none));
	return;
}

//=======================================================================================
// GetGameType: Get the game mode (game type for the menus) of the game
//=======================================================================================
simulated function string GetGameType()
{
	return;
}

simulated function InitialisePlayerSetupInfo()
{
	return;
}

simulated function SavePlayerSetupInfo()
{
	return;
}

simulated function SelectTeam()
{
	return;
}

function SetupPlayerPrefs()
{
	return;
}

function TKPopUpBox(string _KillerName)
{
	return;
}

function TKPopUpDone(bool _bApplyTeamKillerPenalty)
{
	return;
}

function ActiveVoteMenu(bool _bActiveMenu, optional string _szPlayerNameToKick)
{
	return;
}

function SetClientServerSettings(bool _bCanChangeOptions)
{
	return;
}

function CountDownPopUpBox()
{
	return;
}

function CountDownPopUpBoxDone()
{
	return;
}

function PlayerSelection(Object.ePlayerTeamSelection newTeam)
{
	local int _TeamACount, _TeamBCount;

	// End:0x4F
	if((int(newTeam) == int(0)))
	{
		Log("ERROR: Menu engine returned PTS_UnSelected as player team");
		return;
	}
	RefreshReadyButtonStatus();
	// End:0x7B
	if((int(newTeam) == int(m_PlayerController.m_TeamSelection)))
	{
		SetStatMenuState(2);
		return;
	}
	// End:0x108
	if(m_GameRepInfo.IsInAGameState())
	{
		// End:0xFD
		if(((int(newTeam) == int(4)) || (!m_GameRepInfo.m_bRestartableByJoin)))
		{
			// End:0xEC
			if((m_PlayerController.Pawn == none))
			{
				m_PlayerController.m_bReadyToEnterSpectatorMode = true;
				m_PlayerController.Fire(0.0000000);
			}
			LoadSoundBankInSpectator();
			SetStatMenuState(1);			
		}
		else
		{
			SetStatMenuState(2);
		}		
	}
	else
	{
		SetStatMenuState(2);
		// End:0x126
		if((int(newTeam) == int(4)))
		{
			LoadSoundBankInSpectator();
		}
	}
	m_PlayerController.ServerTeamRequested(newTeam);
	SavePlayerSetupInfo();
	m_szPreviousGameType = GetGameType();
	return;
}

function LoadSoundBankInSpectator()
{
	// End:0x34
	if((!m_PlayerController.m_bLoadSoundGun))
	{
		m_PlayerController.m_bLoadSoundGun = true;
		m_PlayerController.ServerReadyToLoadWeaponSound();
	}
	return;
}

function Object.ePlayerTeamSelection IntToPTS(int InInt)
{
	switch(InInt)
	{
		// End:0x0E
		case 0:
			return 0;
		// End:0x15
		case 1:
			return 1;
		// End:0x1D
		case 2:
			return 2;
		// End:0x25
		case 3:
			return 3;
		// End:0x2D
		case 4:
			return 4;
		// End:0xFFFF
		default:
			return;
			break;
	}
}

function int PTSToInt(Object.ePlayerTeamSelection inEnum)
{
	local byte bCast;

	bCast = inEnum;
	return int(bCast);
	return;
}

function RefreshMPlayerInfo()
{
	// End:0x1A
	if((m_GameRepInfo != none))
	{
		m_GameRepInfo.RefreshMPlayerInfo();
	}
	return;
}

// this returns an INT so that we can know where to display the player on
// the tab menu page
function int GeTTeamSelection(int _iIndex)
{
	return;
}

function NewServerState()
{
	// End:0x0D
	if((m_GameRepInfo == none))
	{
		return;
	}
	RefreshReadyButtonStatus();
	// End:0x5D
	if(((int(m_GameRepInfo.m_eCurrectServerState) == m_GameRepInfo.1) || (int(m_GameRepInfo.m_eCurrectServerState) == m_GameRepInfo.0)))
	{
		SetPlayerReadyStatus(false);		
	}
	else
	{
		// End:0x88
		if((int(m_GameRepInfo.m_eCurrectServerState) == m_GameRepInfo.2))
		{
			SetStatMenuState(7);			
		}
		else
		{
			// End:0x10D
			if((int(m_GameRepInfo.m_eCurrectServerState) == m_GameRepInfo.3))
			{
				// End:0x102
				if(((int(m_PlayerController.m_TeamSelection) == int(2)) || (int(m_PlayerController.m_TeamSelection) == int(3))))
				{
					SetPlayerReadyStatus(true);
					// End:0xFF
					if((!m_PlayerController.bOnlySpectator))
					{
						SetStatMenuState(3);
					}					
				}
				else
				{
					SetStatMenuState(1);
				}				
			}
			else
			{
				// End:0x1CB
				if((int(m_GameRepInfo.m_eCurrectServerState) == m_GameRepInfo.4))
				{
					SetPlayerReadyStatus(false);
					// End:0x189
					if(((m_PlayerController.Pawn != none) && (m_PlayerController.Pawn.EngineWeapon != none)))
					{
						m_PlayerController.Pawn.EngineWeapon.GotoState('None');
					}
					// End:0x1C3
					if(bShowLog)
					{
						Log("NewServerState() m_GameRepInfo.RSS_EndOfMatch");
					}
					SetStatMenuState(4);
				}
			}
		}
	}
	return;
}

//=====================================================================
// SetStatMenuState : set the new statmenustate
//=====================================================================
function SetStatMenuState(R6GameMenuCom.eClientMenuState _eNewClientMenuState)
{
	return;
}

//====================================================================================
// SetPlayerReadyStatus: Set the ready button status of the player
//====================================================================================
function SetPlayerReadyStatus(bool _bPlayerReady)
{
	// End:0x25
	if((_bPlayerReady == m_PlayerController.PlayerReplicationInfo.m_bPlayerReady))
	{
		return;
	}
	m_PlayerController.PlayerReplicationInfo.m_bPlayerReady = _bPlayerReady;
	m_PlayerController.ServerSetPlayerReadyStatus(_bPlayerReady);
	return;
}

//====================================================================================
// SetReadyButton: Set the ready button state in the menu (disable when the player play or  -- spectator)
// set this to true when the game is in session, or someone joins as spectator, false otherwise
//====================================================================================
function RefreshReadyButtonStatus()
{
	return;
}

function SetReadyButton(bool _bDisable)
{
	return;
}

//====================================================================================
// GetPlayerReadyStatus: Get the ready button status of the player
//====================================================================================
function bool GetPlayerReadyStatus()
{
	return m_PlayerController.PlayerReplicationInfo.m_bPlayerReady;
	return;
}

//====================================================================================
// GetPlayerDidASelection: 
//====================================================================================
function bool GetPlayerDidASelection()
{
	return;
}

//====================================================================================
// DisconnectClient: Disconnect the client from the server
//====================================================================================
function DisconnectClient(LevelInfo _Level)
{
	return;
}

simulated function bool IsInGame()
{
	return false;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function IntToPTS
