//=============================================================================
// R6MultiPlayerGameInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MultiPlayerGameInfo.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/21 * Created by Aristomenis Kolokathis 
//                      Base GameInfo class for MP Games
//=============================================================================
class R6MultiPlayerGameInfo extends R6GameInfo
	native
	config
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

const K_VoteTime = 90;
const K_RefreshCheckPlayerReadyFreq = 1;

var bool m_TeamSelectionLocked;
var float m_fNextCheckPlayerReadyTime;  // place holder for time of next CheckPlayerReady
var float m_fLastUpdateTime;  // Time of lat update sent to ubi.com
var R6MObjTimer m_missionObjTimer;  // mission objective timer
var Sound m_sndSoundTimeFailure;

//============================================================================
// PlayerController Login
//============================================================================
function int GetSpawnPointNum(string Options)
{
	return;
}

function int GetRainbowTeamColourIndex(int eTeamName)
{
	return;
}

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
	local int Index;

	// End:0x79
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		Index = m_missionMgr.m_aMissionObjectives.Length;
		m_missionObjTimer = new (none) Class'R6Game.R6MObjTimer';
		m_missionObjTimer.m_bVisibleInMenu = false;
		m_missionObjTimer.m_bMoralityObjective = true;
		m_missionMgr.m_aMissionObjectives[Index] = m_missionObjTimer;
	}
	super.InitObjectives();
	return;
}

function bool AtCapacity(bool bSpectator)
{
	// End:0x1B
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		return false;
	}
	return __NFUN_153__(NumPlayers, MaxPlayers);
	return;
}

// NEW IN 1.60
event PlayerController Login(string Portal, string Options, out string Error)
{
	local R6AbstractInsertionZone StartSpot;
	local Actor CamSpot;
	local Vector CamLoc;
	local Rotator CamRot;
	local PlayerController NewPlayer;
	local R6PlayerController P;
	local string InClass, InName, InPassword, InChecksum;
	local byte InTeam;
	local int iSpawnPointNum;
	local string szJoinMessage;
	local R6ModMgr pModManager;
	local int _iPBEnabled;

	// End:0x2F
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		return super.Login(Portal, Options, Error);
	}
	__NFUN_231__(__NFUN_112__("Login: received string: ", Options));
	// End:0x94
	if(AtCapacity(false))
	{
		Error = Localize("MPMiscMessages", "ServerIsFull", "R6GameInfo");
		return none;
	}
	m_GameService.__NFUN_3560__();
	InName = __NFUN_128__(ParseOption(Options, "Name"), 20);
	ReplaceText(InName, " ", "_");
	ReplaceText(InName, "~", "_");
	ReplaceText(InName, "?", "_");
	ReplaceText(InName, ",", "_");
	ReplaceText(InName, "#", "_");
	ReplaceText(InName, "/", "_");
	InName = __NFUN_238__(InName);
	// End:0x162
	if(__NFUN_122__(InName, "UbiPlayer"))
	{
		InName = __NFUN_128__(ParseOption(Options, "UserName"), 20);
	}
	// End:0x19B
	foreach __NFUN_313__(Class'R6Engine.R6PlayerController', P)
	{
		P.ClientMPMiscMessage("PlayerJoinedServer", InName);		
	}	
	InTeam = byte(GetIntOption(Options, "Team", 255));
	InPassword = ParseOption(Options, "Password");
	InChecksum = ParseOption(Options, "Checksum");
	_iPBEnabled = GetIntOption(Options, "iPB", 0);
	iSpawnPointNum = GetSpawnPointNum(Options);
	__NFUN_231__(__NFUN_168__("Login:", InName));
	CamSpot = Level.GetCamSpot(m_szGameTypeFlag);
	// End:0x2DA
	if(__NFUN_114__(CamSpot, none))
	{
		StartSpot = GetAStartSpot();
		// End:0x2A3
		if(__NFUN_114__(StartSpot, none))
		{
			Error = Localize("MPMiscMessages", "FailedPlaceMessage", "R6GameInfo");
			return none;			
		}
		else
		{
			CamLoc = StartSpot.Location;
			CamRot = StartSpot.Rotation;
			CamRot.Roll = 0;
		}		
	}
	else
	{
		CamLoc = CamSpot.Location;
		CamRot = CamSpot.Rotation;
	}
	pModManager = Class'Engine.Actor'.static.__NFUN_1524__();
	bDelayedStart = true;
	// End:0x36A
	if(__NFUN_123__(pModManager.m_pCurrentMod.m_PlayerCtrlToSpawn, ""))
	{
		PlayerControllerClass = Class<PlayerController>(DynamicLoadObject(pModManager.m_pCurrentMod.m_PlayerCtrlToSpawn, Class'Core.Class'));		
	}
	else
	{
		PlayerControllerClass = Class<PlayerController>(DynamicLoadObject("R6Engine.R6PlayerController", Class'Core.Class'));
	}
	// End:0x40C
	if(__NFUN_119__(PlayerControllerClass, none))
	{
		NewPlayer = __NFUN_278__(PlayerControllerClass,,, CamLoc, CamRot);
		NewPlayer.ClientSetLocation(CamLoc, CamRot);
		NewPlayer.StartSpot = StartSpot;
		NewPlayer.m_fLoginTime = Level.TimeSeconds;
	}
	// End:0x48C
	if(__NFUN_114__(NewPlayer, none))
	{
		__NFUN_231__(__NFUN_112__("Couldn't spawn player controller of class ", string(PlayerControllerClass)));
		Error = Localize("MPMiscMessages", "FailedSpawnMessage", "R6GameInfo");
		return none;
	}
	// End:0x4A3
	if(__NFUN_122__(InName, ""))
	{
		InName = DefaultPlayerName;
	}
	// End:0x507
	if(__NFUN_132__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_130__(__NFUN_119__(NewPlayer.PlayerReplicationInfo, none), __NFUN_122__(NewPlayer.PlayerReplicationInfo.PlayerName, DefaultPlayerName))))
	{
		ChangeName(NewPlayer, InName, false, true);
	}
	NewPlayer.GameReplicationInfo = GameReplicationInfo;
	// End:0x5BA
	if(__NFUN_130__(IsBetweenRoundTimeOver(), __NFUN_123__(m_szGameTypeFlag, "RGM_NoRulesMode")))
	{
		// End:0x5AA
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("In login for ", string(NewPlayer)), " m_bGameStarted==true sending it to dead state"));
			R6PlayerController(NewPlayer).LogSpecialValues();
		}
		NewPlayer.__NFUN_113__('Dead');
	}
	// End:0x5D9
	if(__NFUN_119__(StatLog, none))
	{
		StatLog.LogPlayerConnect(NewPlayer);
	}
	NewPlayer.ReceivedSecretChecksum = __NFUN_129__(__NFUN_124__(InChecksum, "NoChecksum"));
	// End:0x64C
	if(__NFUN_119__(Viewport(NewPlayer.Player), none))
	{
		// End:0x639
		if(NewPlayer.__NFUN_1400__())
		{
			NewPlayer.iPBEnabled = 1;			
		}
		else
		{
			NewPlayer.iPBEnabled = 0;
		}		
	}
	else
	{
		NewPlayer.iPBEnabled = _iPBEnabled;
	}
	__NFUN_165__(NumPlayers);
	// End:0x6B5
	if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_154__(int(Level.NetMode), int(NM_ListenServer))))
	{
		BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);
	}
	// End:0x6F4
	if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_122__(InClass, "")))
	{
		InClass = ParseOption(Options, "Class");
	}
	// End:0x724
	if(__NFUN_123__(InClass, ""))
	{
		NewPlayer.PawnClass = Class<Pawn>(DynamicLoadObject(InClass, Class'Core.Class'));
	}
	return NewPlayer;
	return;
}

function bool IsBetweenRoundTimeOver()
{
	return __NFUN_132__(__NFUN_242__(m_bGameStarted, true), __NFUN_281__('PostBetweenRoundTime'));
	return;
}

event PostLogin(PlayerController NewPlayer)
{
	local R6PlayerController _NewPlayer;

	super.PostLogin(NewPlayer);
	// End:0x26
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		return;
	}
	_NewPlayer = R6PlayerController(NewPlayer);
	// End:0x43
	if(__NFUN_114__(_NewPlayer, none))
	{
		return;
	}
	// End:0xF1
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(Viewport(_NewPlayer.Player), none), __NFUN_119__(_NewPlayer.Player.Console, none)), __NFUN_114__(_NewPlayer.m_GameService, none)))
	{
		_NewPlayer.m_GameService = R6GSServers(_NewPlayer.Player.Console.SetGameServiceLinks(NewPlayer));
		_NewPlayer.ServerSetUbiID(_NewPlayer.m_GameService.m_szUserID);
	}
	// End:0x176
	if(__NFUN_181__(m_fEndVoteTime, float(0)))
	{
		// End:0x148
		if(__NFUN_119__(m_PlayerKick, none))
		{
			_NewPlayer.m_iVoteResult = _NewPlayer.3;
			_NewPlayer.ClientKickVoteMessage(m_PlayerKick.PlayerReplicationInfo, m_VoteInstigatorName);			
		}
		else
		{
			_NewPlayer.m_iVoteResult = _NewPlayer.3;
			_NewPlayer.ClientNextMapVoteMessage(m_VoteInstigatorName);
		}
	}
	return;
}

function ResetPlayerTeam(Controller aPlayer)
{
	// End:0x4A
	if(__NFUN_114__(R6Pawn(aPlayer.Pawn), none))
	{
		RestartPlayer(aPlayer);
		aPlayer.Pawn.PlayerReplicationInfo = aPlayer.PlayerReplicationInfo;
	}
	// End:0x6A
	if(__NFUN_119__(PlayerController(aPlayer), none))
	{
		DeployRainbowTeam(PlayerController(aPlayer));
	}
	AcceptInventory(aPlayer.Pawn);
	return;
}

function bool CanAutoBalancePlayer(R6PlayerController pCtrl)
{
	return true;
	return;
}

//------------------------------------------------------------------
// ProcessAutoBalanceTeam
//	
//------------------------------------------------------------------
function ProcessAutoBalanceTeam()
{
	local int iAlphaNb, iBravoNb;
	local bool _gameTypeTeamAdversarial;
	local Controller P;

	_gameTypeTeamAdversarial = Level.IsGameTypeTeamAdversarial(m_szGameTypeFlag);
	// End:0x29F
	if(__NFUN_130__(m_bAutoBalance, _gameTypeTeamAdversarial))
	{
		GetNbHumanPlayerInTeam(iAlphaNb, iBravoNb);
		// End:0x17A
		if(__NFUN_151__(iAlphaNb, __NFUN_146__(iBravoNb, 1)))
		{
			// End:0x7C
			if(bShowLog)
			{
				__NFUN_231__("AutoBalance: Green to Red Team");
			}
			P = Level.ControllerList;
			J0x90:

			// End:0x177 [Loop If]
			if(__NFUN_130__(__NFUN_119__(P, none), __NFUN_151__(iAlphaNb, __NFUN_146__(iBravoNb, 1))))
			{
				// End:0x160
				if(__NFUN_130__(__NFUN_130__(P.__NFUN_303__('R6PlayerController'), __NFUN_154__(int(R6PlayerController(P).m_TeamSelection), int(2))), CanAutoBalancePlayer(R6PlayerController(P))))
				{
					// End:0x13B
					if(bShowLog)
					{
						__NFUN_231__(__NFUN_112__(__NFUN_112__("AutoBalance: ", P.PlayerReplicationInfo.PlayerName), " to Red Team"));
					}
					__NFUN_166__(iAlphaNb);
					__NFUN_165__(iBravoNb);
					R6PlayerController(P).ServerTeamRequested(3, true);
				}
				P = P.nextController;
				// [Loop Continue]
				goto J0x90;
			}			
		}
		else
		{
			// End:0x29F
			if(__NFUN_151__(iBravoNb, __NFUN_146__(iAlphaNb, 1)))
			{
				// End:0x1B7
				if(bShowLog)
				{
					__NFUN_231__("AutoBalance: Red to Green Team");
				}
				P = Level.ControllerList;
				J0x1CB:

				// End:0x29F [Loop If]
				if(__NFUN_130__(__NFUN_119__(P, none), __NFUN_151__(iBravoNb, __NFUN_146__(iAlphaNb, 1))))
				{
					// End:0x288
					if(__NFUN_130__(P.__NFUN_303__('R6PlayerController'), __NFUN_154__(int(R6PlayerController(P).m_TeamSelection), int(3))))
					{
						// End:0x263
						if(bShowLog)
						{
							__NFUN_231__(__NFUN_112__(__NFUN_112__("AutoBalance: ", P.PlayerReplicationInfo.PlayerName), " to Green Team"));
						}
						__NFUN_165__(iAlphaNb);
						__NFUN_166__(iBravoNb);
						R6PlayerController(P).ServerTeamRequested(2, true);
					}
					P = P.nextController;
					// [Loop Continue]
					goto J0x1CB;
				}
			}
		}
	}
	return;
}

function SetLockOnTeamSelection(bool _bLocked)
{
	m_TeamSelectionLocked = _bLocked;
	return;
}

function bool IsTeamSelectionLocked()
{
	return m_TeamSelectionLocked;
	return;
}

function SetCompilingStats(bool bStatsSetting)
{
	super(GameInfo).SetCompilingStats(bStatsSetting);
	__NFUN_1240__(bStatsSetting);
	return;
}

function Logout(Controller Exiting)
{
	local int iIdx;

	// End:0xDD
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		UnPauseCountDown();
		// End:0xD0
		if(__NFUN_130__(Level.IsGameTypeCooperative(m_szGameTypeFlag), __NFUN_151__(m_RainbowAIBackup.Length, 0)))
		{
			// End:0xD0
			if(__NFUN_129__(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)), __NFUN_154__(int(Level.NetMode), int(NM_Client)))))
			{
				// End:0xD0
				if(__NFUN_130__(__NFUN_119__(R6PlayerController(Exiting), none), __NFUN_119__(R6PlayerController(Exiting).m_TeamManager, none)))
				{
					m_RainbowAIBackup.Remove(0, __NFUN_249__(m_RainbowAIBackup.Length, R6PlayerController(Exiting).m_TeamManager.m_iMemberCount));
				}
			}
		}
		__NFUN_1502__(PlayerController(Exiting));
	}
	super.Logout(Exiting);
	return;
}

function Tick(float Delta)
{
	local R6PlayerController PlayerController;
	local Controller C;

	super.Tick(Delta);
	// End:0x18
	if(__NFUN_281__('InBetweenRoundMenu'))
	{
		return;
	}
	// End:0xF1
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		HandleVotesTick();
		R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = int(__NFUN_175__(R6GameInfo(Level.Game).m_fEndingTime, Level.TimeSeconds));
		__NFUN_184__(R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTimeLastUpdate, Delta);
		// End:0xF1
		if(__NFUN_179__(R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTimeLastUpdate, float(10)))
		{
			R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTimeLastUpdate = 0.0000000;
			R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = float(R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime);
		}
	}
	// End:0x1DB
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_missionObjTimer, none), __NFUN_177__(m_fEndingTime, float(0))), __NFUN_177__(Level.m_fTimeLimit, float(0))), __NFUN_177__(Level.TimeSeconds, m_fEndingTime)))
	{
		// End:0x1DB
		if(__NFUN_129__(m_missionObjTimer.m_bFailed))
		{
			C = Level.ControllerList;
			J0x165:

			// End:0x1C1 [Loop If]
			if(__NFUN_119__(C, none))
			{
				PlayerController = R6PlayerController(C);
				// End:0x1AA
				if(__NFUN_119__(PlayerController, none))
				{
					PlayerController.ClientPlayVoices(none, m_sndSoundTimeFailure, 7, 5, true, 1.0000000);
				}
				C = C.nextController;
				// [Loop Continue]
				goto J0x165;
			}
			m_missionObjTimer.TimerCallback(0.0000000);
			TimerCountdown();
		}
	}
	return;
}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	ResetPlayerReady();
	super.EndGame(Winner, Reason);
	return;
}

function ResetPlayerReady()
{
	local Controller P;

	P = Level.ControllerList;
	J0x14:

	// End:0x65 [Loop If]
	if(__NFUN_119__(P, none))
	{
		// End:0x4E
		if(__NFUN_119__(R6PlayerController(P), none))
		{
			R6PlayerController(P).PlayerReplicationInfo.m_bPlayerReady = false;
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

//------------------------------------------------------------------
// GetNbHumanPlayerInTeam
//	
//------------------------------------------------------------------
function GetNbHumanPlayerInTeam(out int iAlphaNb, out int iBravoNb)
{
	local Controller P;

	iAlphaNb = 0;
	iBravoNb = 0;
	P = Level.ControllerList;
	J0x22:

	// End:0x9E [Loop If]
	if(__NFUN_119__(P, none))
	{
		// End:0x87
		if(__NFUN_119__(R6PlayerController(P), none))
		{
			// End:0x62
			if(__NFUN_154__(int(R6PlayerController(P).m_TeamSelection), int(2)))
			{
				__NFUN_163__(iAlphaNb);
			}
			// End:0x87
			if(__NFUN_154__(int(R6PlayerController(P).m_TeamSelection), int(3)))
			{
				__NFUN_163__(iBravoNb);
			}
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x22;
	}
	return;
}

function IncrementRoundsPlayed()
{
	local Controller P;
	local R6PlayerController _aPlayerController;

	P = Level.ControllerList;
	J0x14:

	// End:0xD3 [Loop If]
	if(__NFUN_119__(P, none))
	{
		_aPlayerController = R6PlayerController(P);
		// End:0xBC
		if(__NFUN_130__(__NFUN_119__(_aPlayerController, none), __NFUN_132__(__NFUN_154__(int(_aPlayerController.m_TeamSelection), int(2)), __NFUN_154__(int(_aPlayerController.m_TeamSelection), int(3)))))
		{
			// End:0x92
			if(m_bCompilingStats)
			{
				__NFUN_165__(_aPlayerController.PlayerReplicationInfo.m_iRoundsPlayed);
			}
			_aPlayerController.ServerSetPlayerReadyStatus(true);
			_aPlayerController.PlayerReplicationInfo.bIsSpectator = false;
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

// NEW IN 1.60
function bool ProcessChangeMapVote(string InstigatorName)
{
	local Controller _itController;
	local R6PlayerController _playerController;

	// End:0x0F
	if(__NFUN_181__(m_fEndVoteTime, float(0)))
	{
		return false;
	}
	_itController = Level.ControllerList;
	J0x23:

	// End:0x93 [Loop If]
	if(__NFUN_119__(_itController, none))
	{
		_playerController = R6PlayerController(_itController);
		// End:0x7C
		if(__NFUN_119__(_playerController, none))
		{
			_playerController.m_iVoteResult = R6PlayerController(_itController).3;
			_playerController.ClientNextMapVoteMessage(InstigatorName);
		}
		_itController = _itController.nextController;
		// [Loop Continue]
		goto J0x23;
	}
	m_fEndVoteTime = __NFUN_174__(Level.TimeSeconds, float(90));
	return true;
	return;
}

function bool ProcessKickVote(PlayerController _KickPlayer, string InstigatorName)
{
	local Controller _itController;
	local R6PlayerController _playerController;

	// End:0x0F
	if(__NFUN_181__(m_fEndVoteTime, float(0)))
	{
		return false;
	}
	m_PlayerKick = _KickPlayer;
	m_VoteInstigatorName = InstigatorName;
	_itController = Level.ControllerList;
	J0x39:

	// End:0xB7 [Loop If]
	if(__NFUN_119__(_itController, none))
	{
		_playerController = R6PlayerController(_itController);
		// End:0xA0
		if(__NFUN_119__(_playerController, none))
		{
			_playerController.m_iVoteResult = R6PlayerController(_itController).3;
			_playerController.ClientKickVoteMessage(m_PlayerKick.PlayerReplicationInfo, InstigatorName);
		}
		_itController = _itController.nextController;
		// [Loop Continue]
		goto J0x39;
	}
	m_fEndVoteTime = __NFUN_174__(Level.TimeSeconds, float(90));
	return true;
	return;
}

// NEW IN 1.60
function HandleVotesTick()
{
	local int _iForVotes, _iAgainstVotes;
	local Controller _itController;
	local R6PlayerController _playerController;
	local string szResultString, szPlayerName;
	local bool _bResult, bChangeMapVote;
	local R6GameReplicationInfo pGRI;

	// End:0x36
	if(__NFUN_132__(__NFUN_132__(__NFUN_180__(m_fEndVoteTime, float(0)), __NFUN_177__(m_fEndVoteTime, Level.TimeSeconds)), __NFUN_154__(NumPlayers, 0)))
	{
		return;
	}
	m_fEndVoteTime = 0.0000000;
	_iForVotes = 0;
	_iAgainstVotes = 0;
	_itController = Level.ControllerList;
	J0x63:

	// End:0xF2 [Loop If]
	if(__NFUN_119__(_itController, none))
	{
		_playerController = R6PlayerController(_itController);
		// End:0xDB
		if(__NFUN_119__(_playerController, none))
		{
			switch(_playerController.m_iVoteResult)
			{
				// End:0xB0
				case _playerController.1:
					__NFUN_165__(_iForVotes);
					// End:0xDB
					break;
				// End:0xBE
				case _playerController.3:
				// End:0xD6
				case _playerController.2:
					__NFUN_165__(_iAgainstVotes);
					// End:0xDB
					break;
				// End:0xFFFF
				default:
					return;
					break;
			}
		}
		_itController = _itController.nextController;
		// [Loop Continue]
		goto J0x63;
	}
	bChangeMapVote = __NFUN_114__(m_PlayerKick, none);
	// End:0x256
	if(__NFUN_151__(_iForVotes, __NFUN_145__(__NFUN_146__(_iForVotes, _iAgainstVotes), 2)))
	{
		_bResult = true;
		// End:0x1C2
		if(__NFUN_242__(bChangeMapVote, true))
		{
			// End:0x1A5
			if(bShowLog)
			{
				__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("<<ChangeMap>> HandleVotesTick ", string(_iForVotes)), " voted yes "), string(_iAgainstVotes)), " considered as voted no -- VOTE PASSES"));
			}
			bChangeLevels = true;
			EndGame(none, "");
			__NFUN_1210__();
			RestartGame();			
		}
		else
		{
			// End:0x233
			if(bShowLog)
			{
				__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("<<KICK>> HandleVotesTick ", string(_iForVotes)), " voted yes "), string(_iAgainstVotes)), " considered as voted no -- VOTE PASSES"));
			}
			R6PlayerController(m_PlayerKick).ClientKickedOut();
			m_PlayerKick.__NFUN_1282__();
		}		
	}
	else
	{
		_bResult = false;
		// End:0x2D9
		if(__NFUN_242__(bChangeMapVote, true))
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("<<ChangeMap>> HandleVotesTick ", string(_iForVotes)), " voted yes "), string(_iAgainstVotes)), " considered as voted no -- VOTE FAILS"));			
		}
		else
		{
			// End:0x349
			if(bShowLog)
			{
				__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("<<KICK>> HandleVotesTick ", string(_iForVotes)), " voted yes "), string(_iAgainstVotes)), " considered as voted no -- VOTE FAILS"));
			}
		}
	}
	// End:0x3BC
	if(__NFUN_242__(bChangeMapVote, true))
	{
		_itController = Level.ControllerList;
		J0x369:

		// End:0x3B9 [Loop If]
		if(__NFUN_119__(_itController, none))
		{
			// End:0x3A2
			if(_itController.__NFUN_303__('R6PlayerController'))
			{
				R6PlayerController(_itController).ClientVoteResult(_bResult);
			}
			_itController = _itController.nextController;
			// [Loop Continue]
			goto J0x369;
		}		
	}
	else
	{
		szPlayerName = m_PlayerKick.PlayerReplicationInfo.PlayerName;
		_itController = Level.ControllerList;
		J0x3ED:

		// End:0x442 [Loop If]
		if(__NFUN_119__(_itController, none))
		{
			// End:0x42B
			if(_itController.__NFUN_303__('R6PlayerController'))
			{
				R6PlayerController(_itController).ClientVoteResult(_bResult, szPlayerName);
			}
			_itController = _itController.nextController;
			// [Loop Continue]
			goto J0x3ED;
		}
	}
	m_PlayerKick = none;
	m_VoteInstigatorName = "";
	return;
}

function LogVoteInfo()
{
	return;
}

auto state InBetweenRoundMenu
{
	function BeginState()
	{
		local Controller P;
		local Actor CamSpot;
		local R6PlayerController PC;
		local R6IOSelfDetonatingBomb AIt;

		// End:0x22
		foreach __NFUN_304__(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
		{
			AIt.m_bIsActivated = false;			
		}		
		m_bGameStarted = false;
		// End:0x4E
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			__NFUN_113__('None');			
		}
		else
		{
			Level.__NFUN_1319__();
			// End:0x82
			if(__NFUN_130__(m_bAIBkp, Level.IsGameTypeCooperative(m_szGameTypeFlag)))
			{
				CreateBackupRainbowAI();
			}
			GameReplicationInfo.SetServerState(GameReplicationInfo.0);
			SpawnAIandInitGoInGame();
		}
		HandleVotesTick();
		// End:0x127
		if(__NFUN_177__(m_fTimeBetRounds, float(0)))
		{
			m_fRoundStartTime = __NFUN_174__(Level.TimeSeconds, m_fTimeBetRounds);
			R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = int(__NFUN_175__(m_fRoundStartTime, Level.TimeSeconds));
			R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = float(R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime);			
		}
		else
		{
			m_fRoundStartTime = 0.0000000;
			R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimeUnlimited = true;
			R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = 0;
			R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = 0.0000000;
		}
		m_fNextCheckPlayerReadyTime = __NFUN_174__(Level.TimeSeconds, float(1));
		// End:0x1BE
		if(bShowLog)
		{
			__NFUN_231__("GameInfo: begin InBetweenRoundMenu");
		}
		CamSpot = Level.GetCamSpot(m_szGameTypeFlag);
		// End:0x288
		if(__NFUN_119__(CamSpot, none))
		{
			P = Level.ControllerList;
			J0x1F7:

			// End:0x288 [Loop If]
			if(__NFUN_119__(P, none))
			{
				PC = R6PlayerController(P);
				// End:0x271
				if(__NFUN_119__(PC, none))
				{
					PC.__NFUN_267__(CamSpot.Location);
					PC.ClientSetLocation(CamSpot.Location, CamSpot.Rotation);
					PC.ClientStopFadeToBlack();
				}
				P = P.nextController;
				// [Loop Continue]
				goto J0x1F7;
			}
		}
		return;
	}

    // Precondition: We are in the time between rounds stage
    // Postcondition: Returns true if we are no longer waiting because of unlimited time between round
    //                Returns true if we do not have time between round
    // Modifies: nothing
    // depends on begin state of InBetweenRoundMenu
	function bool UnlimitedTBRPassed()
	{
		return __NFUN_181__(m_fRoundStartTime, float(0));
		return;
	}

	function Tick(float DeltaTime)
	{
		local bool _bAllActivePlayersReady;
		local Controller _playerController;

		HandleVotesTick();
		_bAllActivePlayersReady = false;
		// End:0x97
		if(__NFUN_130__(__NFUN_176__(m_fNextCheckPlayerReadyTime, Level.TimeSeconds), __NFUN_132__(__NFUN_176__(Level.TimeSeconds, m_fRoundStartTime), __NFUN_129__(UnlimitedTBRPassed()))))
		{
			_bAllActivePlayersReady = ProcessPlayerReadyStatus();
			m_fNextCheckPlayerReadyTime = __NFUN_174__(Level.TimeSeconds, float(1));
			// End:0x97
			if(_bAllActivePlayersReady)
			{
				SetLockOnTeamSelection(true);
				m_fRoundStartTime = Level.TimeSeconds;
			}
		}
		// End:0x24A
		if(__NFUN_130__(__NFUN_129__(R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimePaused), __NFUN_132__(__NFUN_132__(__NFUN_129__(R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimeUnlimited), _bAllActivePlayersReady), __NFUN_177__(m_fRoundStartTime, float(0)))))
		{
			R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = int(__NFUN_175__(m_fRoundStartTime, Level.TimeSeconds));
			R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = float(R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime);
			// End:0x16E
			if(__NFUN_176__(Level.TimeSeconds, m_fRoundStartTime))
			{
				GameReplicationInfo.SetServerState(GameReplicationInfo.1);				
			}
			else
			{
				// End:0x1A8
				if(__NFUN_176__(Level.TimeSeconds, __NFUN_174__(m_fRoundStartTime, float(1))))
				{
					GameReplicationInfo.SetServerState(GameReplicationInfo.2);					
				}
				else
				{
					__NFUN_113__('PostBetweenRoundTime');
					_playerController = Level.ControllerList;
					J0x1C3:

					// End:0x247 [Loop If]
					if(__NFUN_119__(_playerController, none))
					{
						// End:0x230
						if(__NFUN_130__(_playerController.__NFUN_303__('R6PlayerController'), __NFUN_129__(R6PlayerController(_playerController).IsPlayerPassiveSpectator())))
						{
							R6PlayerController(_playerController).__NFUN_113__('PauseController');
							R6PlayerController(_playerController).ClientGotoState('PauseController', 'None');
						}
						_playerController = _playerController.nextController;
						// [Loop Continue]
						goto J0x1C3;
					}
				}
			}			
		}
		else
		{
			GameReplicationInfo.SetServerState(GameReplicationInfo.1);
		}
		return;
	}

	function PauseCountDown()
	{
		// End:0x1C
		if(__NFUN_242__(R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimePaused, true))
		{
			return;
		}
		m_fPausedAtTime = Level.TimeSeconds;
		R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimePaused = true;
		return;
	}

	function UnPauseCountDown()
	{
		local Controller _Player;

		// End:0x1C
		if(__NFUN_242__(R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimePaused, false))
		{
			return;
		}
		_Player = Level.ControllerList;
		J0x30:

		// End:0x84 [Loop If]
		if(__NFUN_119__(_Player, none))
		{
			// End:0x6D
			if(__NFUN_130__(_Player.__NFUN_303__('R6PlayerController'), __NFUN_242__(R6PlayerController(_Player).m_bInAnOptionsPage, true)))
			{
				return;
			}
			_Player = _Player.nextController;
			// [Loop Continue]
			goto J0x30;
		}
		// End:0xF1
		if(__NFUN_129__(R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimeUnlimited))
		{
			m_fRoundStartTime = __NFUN_174__(float(R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime), Level.TimeSeconds);
			R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = float(R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime);
		}
		R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimePaused = false;
		m_fPausedAtTime = 0.0000000;
		return;
	}

	function EndState()
	{
		local int iAlphaNb, iBravoNb, i, j;
		local Controller P;
		local bool _gameTypeTeamAdversarial;
		local array<R6PlayerController> R6PlayerControllerList;
		local array<R6TerroristAI> R6TerroristAIList;
		local array<R6RainbowAI> R6RainbowAIList;
		local R6Rainbow aRainbow;
		local R6Terrorist aTerrorist;
		local ZoneInfo aZoneInfo;

		_gameTypeTeamAdversarial = Level.IsGameTypeTeamAdversarial(m_szGameTypeFlag);
		// End:0x89
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("GameInfo: EndState InBetweenRoundMenu m_GameService = ", string(m_GameService)), " m_iUbiComGameMode = "), string(m_iUbiComGameMode)));
		}
		R6GameReplicationInfo(GameReplicationInfo).m_bRepMenuCountDownTimeUnlimited = false;
		ProcessAutoBalanceTeam();
		P = Level.ControllerList;
		J0xB9:

		// End:0x333 [Loop If]
		if(__NFUN_119__(P, none))
		{
			// End:0x31C
			if(P.__NFUN_303__('R6PlayerController'))
			{
				// End:0x1ED
				if(__NFUN_129__(R6PlayerController(P).IsPlayerPassiveSpectator()))
				{
					R6PlayerController(P).bOnlySpectator = false;
					ResetPlayerTeam(P);
					R6PlayerController(P).m_TeamManager.SetTeamColor(GetRainbowTeamColourIndex(R6Pawn(P.Pawn).m_iTeam));
					// End:0x1A6
					if(__NFUN_119__(R6PlayerController(P).m_TeamManager, none))
					{
						R6PlayerController(P).m_TeamManager.SetMemberTeamID(R6Pawn(P.Pawn).m_iTeam);						
					}
					else
					{
						R6AbstractGameInfo(Level.Game).SetPawnTeamFriendlies(P.Pawn);
					}
					P.PlayerReplicationInfo.SetWaitingPlayer(false);					
				}
				else
				{
					// End:0x264
					if(bShowLog)
					{
						__NFUN_231__(__NFUN_112__(__NFUN_112__("In InBetweenRoundMenu::EndState() sending PlayerController ", string(P)), " to dead state"));
						R6PlayerController(P).LogSpecialValues();
					}
					P.__NFUN_113__('Dead');
				}
				// End:0x2E8
				if(__NFUN_119__(P.Pawn, none))
				{
					P.m_PawnRepInfo.m_PawnType = P.Pawn.m_ePawnType;
					P.m_PawnRepInfo.m_bSex = P.Pawn.bIsFemale;
				}
				P.PlayerReplicationInfo.m_szKillersName = "";
				P.PlayerReplicationInfo.m_bJoinedTeamLate = false;
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0xB9;
		}
		P = Level.ControllerList;
		J0x347:

		// End:0x3F0 [Loop If]
		if(__NFUN_119__(P, none))
		{
			// End:0x380
			if(P.__NFUN_303__('R6PlayerController'))
			{
				R6PlayerControllerList[R6PlayerControllerList.Length] = R6PlayerController(P);				
			}
			else
			{
				// End:0x3AE
				if(P.__NFUN_303__('R6RainbowAI'))
				{
					R6RainbowAIList[R6RainbowAIList.Length] = R6RainbowAI(P);					
				}
				else
				{
					// End:0x3D9
					if(P.__NFUN_303__('R6TerroristAI'))
					{
						R6TerroristAIList[R6TerroristAIList.Length] = R6TerroristAI(P);
					}
				}
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x347;
		}
		i = 0;
		J0x3F7:

		// End:0x810 [Loop If]
		if(__NFUN_150__(i, R6PlayerControllerList.Length))
		{
			// End:0x46D
			if(bShowLog)
			{
				__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__(__NFUN_168__(__NFUN_168__("Nb Terrorist =", string(R6TerroristAIList.Length)), "Nb RainbowAI ="), string(R6RainbowAIList.Length)), "Nb R6PlayerController ="), string(R6PlayerControllerList.Length)));
			}
			j = 0;
			J0x474:

			// End:0x52A [Loop If]
			if(__NFUN_150__(j, R6TerroristAIList.Length))
			{
				aTerrorist = R6Terrorist(R6TerroristAIList[j].Pawn);
				// End:0x520
				if(__NFUN_119__(aTerrorist, none))
				{
					R6PlayerControllerList[i].SetWeaponSound(R6TerroristAIList[j].m_PawnRepInfo, aTerrorist.m_szPrimaryWeapon, 0);
					R6PlayerControllerList[i].SetWeaponSound(R6TerroristAIList[j].m_PawnRepInfo, aTerrorist.m_szGrenadeWeapon, 2);
				}
				__NFUN_165__(j);
				// [Loop Continue]
				goto J0x474;
			}
			j = 0;
			J0x531:

			// End:0x659 [Loop If]
			if(__NFUN_150__(j, R6RainbowAIList.Length))
			{
				aRainbow = R6Rainbow(R6RainbowAIList[j].Pawn);
				// End:0x64F
				if(__NFUN_119__(aRainbow, none))
				{
					R6PlayerControllerList[i].SetWeaponSound(R6RainbowAIList[j].m_PawnRepInfo, aRainbow.m_szPrimaryWeapon, 0);
					R6PlayerControllerList[i].SetWeaponSound(R6RainbowAIList[j].m_PawnRepInfo, aRainbow.m_szSecondaryWeapon, 1);
					R6PlayerControllerList[i].SetWeaponSound(R6RainbowAIList[j].m_PawnRepInfo, aRainbow.m_szPrimaryItem, 2);
					R6PlayerControllerList[i].SetWeaponSound(R6RainbowAIList[j].m_PawnRepInfo, aRainbow.m_szSecondaryItem, 3);
				}
				__NFUN_165__(j);
				// [Loop Continue]
				goto J0x531;
			}
			j = 0;
			J0x660:

			// End:0x788 [Loop If]
			if(__NFUN_150__(j, R6PlayerControllerList.Length))
			{
				aRainbow = R6Rainbow(R6PlayerControllerList[j].Pawn);
				// End:0x77E
				if(__NFUN_119__(aRainbow, none))
				{
					R6PlayerControllerList[i].SetWeaponSound(R6PlayerControllerList[j].m_PawnRepInfo, aRainbow.m_szPrimaryWeapon, 0);
					R6PlayerControllerList[i].SetWeaponSound(R6PlayerControllerList[j].m_PawnRepInfo, aRainbow.m_szSecondaryWeapon, 1);
					R6PlayerControllerList[i].SetWeaponSound(R6PlayerControllerList[j].m_PawnRepInfo, aRainbow.m_szPrimaryItem, 2);
					R6PlayerControllerList[i].SetWeaponSound(R6PlayerControllerList[j].m_PawnRepInfo, aRainbow.m_szSecondaryItem, 3);
				}
				__NFUN_165__(j);
				// [Loop Continue]
				goto J0x660;
			}
			// End:0x7CD
			if(__NFUN_119__(R6PlayerControllerList[i].Pawn, none))
			{
				aZoneInfo = R6PlayerControllerList[i].Pawn.Region.Zone;				
			}
			else
			{
				aZoneInfo = R6PlayerControllerList[i].Region.Zone;
			}
			R6PlayerControllerList[i].ClientFinalizeLoading(aZoneInfo);
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x3F7;
		}
		NotifyMatchStart();
		Level.__NFUN_2612__();
		GetNbHumanPlayerInTeam(iAlphaNb, iBravoNb);
		// End:0x868
		if(Level.IsGameTypeCooperative(m_szGameTypeFlag))
		{
			SetCompilingStats(__NFUN_151__(iAlphaNb, 0));
			SetRoundRestartedByJoinFlag(__NFUN_150__(iAlphaNb, 1));			
		}
		else
		{
			// End:0x8AA
			if(_gameTypeTeamAdversarial)
			{
				SetCompilingStats(__NFUN_130__(__NFUN_151__(iAlphaNb, 0), __NFUN_151__(iBravoNb, 0)));
				SetRoundRestartedByJoinFlag(__NFUN_132__(__NFUN_154__(iAlphaNb, 0), __NFUN_154__(iBravoNb, 0)));				
			}
			else
			{
				SetCompilingStats(__NFUN_151__(iAlphaNb, 1));
				SetRoundRestartedByJoinFlag(__NFUN_150__(iAlphaNb, 2));
			}
		}
		__NFUN_1241__();
		IncrementRoundsPlayed();
		SetGameTypeInLocal();
		BroadcastGameTypeDescription();
		return;
	}
	stop;
}

state PostBetweenRoundTime
{
	function BeginState()
	{
		local Controller P;

		m_bStopPostBetweenRoundCountdown = false;
		SetLockOnTeamSelection(false);
		// End:0x2C
		if(Level.IsGameTypeCooperative(m_szGameTypeFlag))
		{
			ResetMatchStat();
		}
		m_fInGameStartTime = __NFUN_174__(Level.TimeSeconds, float(5));
		P = Level.ControllerList;
		J0x5A:

		// End:0xA4 [Loop If]
		if(__NFUN_119__(P, none))
		{
			// End:0x8D
			if(P.__NFUN_303__('R6PlayerController'))
			{
				R6PlayerController(P).CountDownPopUpBox();
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x5A;
		}
		R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = 5;
		R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = 5.0000000;
		GameReplicationInfo.m_bInPostBetweenRoundTime = true;
		return;
	}

	function Tick(float DeltaTime)
	{
		local Controller P;

		// End:0x0B
		if(m_bStopPostBetweenRoundCountdown)
		{
			return;
		}
		HandleVotesTick();
		R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = int(__NFUN_175__(m_fInGameStartTime, Level.TimeSeconds));
		R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = float(R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime);
		// End:0x6D
		if(__NFUN_1242__())
		{
			return;
		}
		// End:0x90
		if(__NFUN_179__(Level.TimeSeconds, __NFUN_175__(m_fInGameStartTime, float(1))))
		{
			PostBetweenRoundTimeDone();
		}
		return;
	}

	function PostBetweenRoundTimeDone()
	{
		local Controller P;

		m_bGameStarted = true;
		GameReplicationInfo.SetServerState(GameReplicationInfo.3);
		P = Level.ControllerList;
		J0x36:

		// End:0x122 [Loop If]
		if(__NFUN_119__(P, none))
		{
			// End:0x10B
			if(__NFUN_130__(__NFUN_130__(P.__NFUN_303__('R6PlayerController'), __NFUN_129__(PlayerController(P).bOnlySpectator)), __NFUN_129__(R6PlayerController(P).IsPlayerPassiveSpectator())))
			{
				// End:0xD8
				if(R6PlayerController(P).m_bPenaltyBox)
				{
					R6PlayerController(P).__NFUN_113__('PenaltyBox');
					R6PlayerController(P).ClientGotoState('PenaltyBox', 'None');					
				}
				else
				{
					R6PlayerController(P).__NFUN_113__('PlayerWalking');
					R6PlayerController(P).ClientGotoState('PlayerWalking', 'None');
				}
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x36;
		}
		// End:0x13B
		if(__NFUN_151__(m_RainbowAIBackup.Length, 0))
		{
			m_RainbowAIBackup.Remove(0, m_RainbowAIBackup.Length);
		}
		__NFUN_113__('None');
		return;
	}

	function EndState()
	{
		local Controller P;
		local R6IOSelfDetonatingBomb AIt;

		GameReplicationInfo.m_bInPostBetweenRoundTime = false;
		m_fEndingTime = __NFUN_174__(Level.TimeSeconds, Level.m_fTimeLimit);
		R6GameReplicationInfo(GameReplicationInfo).m_iMenuCountDownTime = int(Level.m_fTimeLimit);
		R6GameReplicationInfo(GameReplicationInfo).m_fRepMenuCountDownTime = Level.m_fTimeLimit;
		P = Level.ControllerList;
		J0x8F:

		// End:0xD9 [Loop If]
		if(__NFUN_119__(P, none))
		{
			// End:0xC2
			if(P.__NFUN_303__('R6PlayerController'))
			{
				R6PlayerController(P).CountDownPopUpBoxDone();
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x8F;
		}
		// End:0x130
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
		{
			// End:0x12F
			foreach __NFUN_304__(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
			{
				AIt.m_fSelfDetonationTime = Level.m_fTimeLimit;
				AIt.StartTimer();				
			}			
		}
		return;
	}
	stop;
}

defaultproperties
{
	m_bCompilingStats=false
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_fInGameStartTime
// REMOVED IN 1.60: var m_bMSCLientActive
// REMOVED IN 1.60: var m_iUbiComGameMode
// REMOVED IN 1.60: var m_bDoLadderInit
// REMOVED IN 1.60: function PostBeginPlay
// REMOVED IN 1.60: function InitGame
// REMOVED IN 1.60: function MasterServerManager
// REMOVED IN 1.60: function HandleKickVotesTick
