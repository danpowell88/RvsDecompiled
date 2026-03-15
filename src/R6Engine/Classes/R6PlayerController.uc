//=============================================================================
// R6PlayerController - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6PlayerController.uc : This is the Player Controller class for all Rainbow 6
//                          characters.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    02 May 2001  Aristo Kolokathis        Added varibles for needed by R6Weapons
//    2001/07/24   Joel Tremblay            Add Shake view and Damage Attitude to
//  Note: if you make R6PlayerController native then you will need to take care so
//  that the names in eDefaultCircumstantialAction do not conflict with other enums
//=============================================================================
class R6PlayerController extends PlayerController
    native
    config(User);

const MAX_Pitch = 2000;
const MAX_ProneSpeedRotation = 6600;
const K_MinVote = 0;
const K_CanNotVote = 0;
const K_VotedYes = 1;
const K_VotedNo = 2;
const K_EmptyBallot = 3;
const K_MaxVote = 3;
const K_KickFreqTime = 300;
const Authority_None = 0;
const Authority_Admin = 1;
const Authority_Max = 1;
const K_MaxBanPageSize = 10;

enum eDeathCameraMode
{
	eDCM_FIRSTPERSON,               // 0
	eDCM_THIRDPERSON,               // 1
	eDCM_FREETHIRDPERSON,           // 2
	eDCM_GHOST,                     // 3
	eDCM_FADETOBLACK                // 4
};

enum eDefaultCircumstantialAction
{
	PCA_None,                       // 0
	PCA_TeamRegroup,                // 1
	PCA_TeamMoveTo,                 // 2
	PCA_MoveAndGrenade,             // 3
	PCA_GrenadeFrag,                // 4
	PCA_GrenadeGas,                 // 5
	PCA_GrenadeFlash,               // 6
	PCA_GrenadeSmoke                // 7
};

enum eGamePasswordRes
{
	GPR_None,                       // 0
	GPR_MissingPasswd,              // 1
	GPR_PasswdSet,                  // 2
	GPR_PasswdCleared               // 3
};

struct STImpactShake
{
	var() int iBlurIntensity;
	var() float fWaveTime;  // Time to wave
	var() float fRollMax;  // Max Roll Angle �(0-16384)
	var() float fRollSpeed;  // Current Roll Speed
	var() float fReturnTime;  // Effect on character Position
};

struct stSoundPriority
{
	var R6SoundReplicationInfo aSoundRepInfo;
	var Sound sndPlayVoice;
	var int iPriority;
	var byte eSlotUse;
	var byte EPawnType;
	var float fTimeStart;
	var bool bIsPlaying;
	var bool bWaitToFinishSound;
};

struct stSoundPriorityPtr
{
// NEW IN 1.60
	var int Ptr;
};

struct STBanPage
{
// NEW IN 1.60
	var string szBanID[10];
};

var input byte m_bSpecialCrouch;
var input byte m_bSpeedUpDoor;
var input byte m_bPeekLeft;
var input byte m_bPeekRight;
var input byte m_bReloading;
var byte m_bOldPeekLeft;
var byte m_bOldPeekRight;
//  Auto Aim
var byte m_wAutoAim;  // 0 (off), 1(low), 2(medium) or 3(high)
var input byte m_bPlayerRun;
var Actor.EPawnType m_ePenaltyForKillingAPawn;
var config int m_iDoorSpeed;
var config int m_iFastDoorSpeed;
var config int m_iFluidMovementSpeed;
// this is where we hardcode the walk, fastwalk and run speeds.
// these values are compared with the pawn's velocity in order to determine what accuracy it has
var() int m_iSpeedLevels[3];  // 0 -> slowest 2 -> fastest
var int m_iShakeBlurIntensity;  // Blur intensity when hit by a bullet
//Fire Shake values
var int m_iReturnSpeed;  // Current Weapon return speed for shake
var int m_iPitchReturn;
var int m_iYawReturn;  // speed the yaw is returning to his original position
var int m_iSpectatorYaw;
var int m_iSpectatorPitch;
var int m_iPlayerCAProgress;  // Player action progress (0-100)
var int m_iTeamId;  // for spectator camera when player dies and is restricted to team only camera
var int m_iVoteResult;
//============================================================================
// END Vars and consts used in kicking
//============================================================================
var int m_iAdmin;  // this player is logged in as an administrator
var int m_iBanPage;
var bool m_bHelmetCameraOn;  // false by default: helmet camera for the rainbow 6 player
var bool m_bScopeZoom;  // to switch between 3x and 9x zoom
var bool m_bSniperMode;  // Character activated the zoom with a sniper rifle
var bool m_bShowFPWeapon;  // True by default: display of not the FP Weapon
var bool m_bShowHitLogs;  // True will display all the hit logs
// rbrek 30 aug 2001  
// this flag will prevent attempting to initiate another circumstantial action while one is in progress...
// also hides the circumstantial info during this time...
var bool m_bCircumstantialActionInProgress;
var bool m_bAllTeamsHold;
var bool m_bFixCamera;  // R6DEBUG
// For Debug Purposes
var() bool bShowLog;
//shake Camera values
var bool m_bShakeActive;
var bool m_bDisplayMilestoneMessage;
var bool m_bUseFirstPersonWeapon;  // set to display or not to display the first person weapons.
var bool m_bPlacedExplosive;
var bool m_bAttachCameraToEyes;
var bool m_bCameraGhost;
var bool m_bCameraFirstPerson;
var bool m_bCameraThirdPersonFixed;
var bool m_bCameraThirdPersonFree;
var bool m_bFadeToBlack;
var bool m_bSpectatorCameraTeamOnly;
var bool m_bSkipBeginState;
// Variable for the training
var bool m_bPreventTeamMemberUse;
var bool m_bDisplayMessage;
// this flag tells the server if the client sent the end of round data to the server
var bool m_bEndOfRoundDataReceived;
// this flag used to keep track of which admins are in the server options or kit restriction page
// only valid for admins
var bool m_bInAnOptionsPage;
var bool m_bPawnInitialized;
var bool m_bCanChangeMember;
var bool m_bDisplayActionProgress;
var bool m_bAMenuIsDisplayed;  // Used to prevent display two menu at the same time
//R6Matinee:
var bool m_bMatineeRunning;
var bool m_bHasAPenalty;  // this player broke the rules and killed a team-mate
var bool m_bPenaltyBox;  // at the next round, if m_bHasAPenalty, we set this flag to true
var bool m_bRequestTKPopUp;  // request if this player wants to apply penalty to team-mate killer
var bool m_bProcessingRequestTKPopUp;  // client side, waiting on pop-up
var bool m_bAlreadyPoppedTKPopUpBox;  // denotes if this pop-up box was already popped
var bool m_bPlayDeathMusic;
var bool m_bDeadAfterTeamSel;  // go to dead state after team selection
var bool m_bShowCompleteHUD;
var bool m_bWantTriggerLag;
// NEW IN 1.60
var bool m_bQuitToUpdateServerDisplayed;
var bool m_bIsSecuringRainbow;  // MissionPack1 true if is Secure action, false if is Free action
var bool m_bBombSearched;  // true if a self detonating bomb has been detected in the level (temporary? It's like a patch)
// NEW IN 1.60
var float m_fOxygeneLevel;
// NEW IN 1.60
var float m_fCompteurFrameDetection;
var config float m_fTeamMoveToDistance;  // used for the
//R6MOTIONBLUR
var float m_fTimedBlurValue;  // Current Blur value with a specific timer to reach 0
var float m_fBlurReturnTime;  // Time to recover from the intensity
// For shake
var float m_fHitEffectTime;
var float m_fShakeTime;
var float m_fMaxShake;
var float m_fCurrentShake;
var float m_fMaxShakeTime;
// fluid movement key is used to set the posture as well as reset it to normal (double click)... need to make sure that
// the double click does not restart the fluid movement mode.
var float m_fPostFluidMovementDelay;
var float m_fRetLockPosX;  // Desired Reticule X position on screen
var float m_fRetLockPosY;  // Desired Reticule Y position on screen
var float m_fCurrRetPosX;  // Current Reticule X position on screen
var float m_fCurrRetPosY;  // Current Reticule Y position on screen
var float m_fRetLockTime;  // Time remaining before the reticule hit the lock pos
var float m_fShakeReturnTime;
//Tweak shaking
var float m_fDesignerSpeedFactor;
var float m_fDesignerJumpFactor;
var float m_fMilestoneMessageDuration;
var float m_fMilestoneMessageLeft;
var float m_fCurrentDeltaTime;
var float LastDoorUpdateTime;
// NEW IN 1.60
var float m_fLastUpdateServerCheckTime;
// NEW IN 1.60
var float m_fLastVoteTime;
// MPF1
var float m_fStartSurrenderTime;  // MissionPack1
var R6Rainbow m_pawn;
var R6RainbowTeam m_TeamManager;
var R6Pawn m_targetedPawn;  // Currently targeted pawn
var R6CircumstantialActionQuery m_CurrentCircumstantialAction;  // CA of the object that the player is currently looking at
var R6CircumstantialActionQuery m_RequestedCircumstantialAction;  // Action sent to the team (or to self)
var R6CircumstantialActionQuery m_PlayerCurrentCA;  // Player current action
// Interactions (registered to the InteractionMaster)
var InteractionMaster m_InteractionMaster;
var R6InteractionCircumstantialAction m_InteractionCA;  // server can't access the client's RoseDesVents class
var R6InteractionInventoryMnu m_InteractionInventory;
var R6Rainbow m_BackupTeamLeader;  // used to remove an Access None when
var Actor m_PrevViewTarget;
// this is used on server side to remember where controller was spawned so that pawn will be spawned at the same place
var NavigationPoint StartSpot;
var R6GameMenuCom m_MenuCommunication;
var R6GameOptions m_GameOptions;
var R6PlayerController m_TeamKiller;
var Sound m_sndUpdateWritableMap;
var Sound m_sndDeathMusic;
var Sound m_sndMissionComplete;
var R6CommonRainbowVoices m_CommonPlayerVoicesMgr;
var R6AbstractGameService m_GameService;  // points to the local player's GameService class
// MissionPack1 2
var R6IOSelfDetonatingBomb m_pSelfDetonatingBomb;
var R6Pawn m_pInteractingRainbow;  // equal to the pawn which is arresting/rescuing this
var array<stSoundPriorityPtr> m_PlayVoicesPriority;
var Rotator m_rHitRotation;
var Vector m_vAutoAimTarget;  // Position of targeted pawn.  Only valid when target pawn != none
// DEBUG - for freezing the position of the camera...
var Vector m_vCameraLocation;
var Rotator m_rCameraRotation;
var Rotator m_rCurrentShakeRotation;
var Rotator m_rTotalShake;
var(R6Impact) STImpactShake m_stImpactHit;
var(R6Impact) STImpactShake m_stImpactStun;
var(R6Impact) STImpactShake m_stImpactDazed;
var(R6Impact) STImpactShake m_stImpactKO;
var Vector m_vNewReturnValue;  // new pitch the camera will return to when the firing is over.
var Rotator m_rLastBulletDirection;  // direction of the last bullet to shake the camera in that direction
// For default action : Move Team To
var Vector m_vDefaultLocation;
var Vector m_vRequestedLocation;
var Color m_SpectatorColor;
var STBanPage m_BanPage;
var config string m_szLastAdminPassword;
var string m_szMileStoneMessage;
var string m_CharacterName;
var string m_szBanSearch;
// Spam Filter Variables
var transient float m_fLastBroadcastTimeStamp;  // Time of last "say"
var transient float m_fPreviousBroadcastTimeStamp;  // Time of the "say" before the last one
var transient float m_fEndOfChatLockTime;  // Set to -1.0 to unlock chatlock
var transient float m_fLastVoteEmoteTimeStamp;  // Time of the last "vote" message sent

replication
{
	// Pos:0x000
	unreliable if((int(Role) == int(ROLE_Authority)))
		ClientActionProgressDone, ClientAdminBanOff, 
		ClientAdminKickOff, ClientCantRequestChangeMapYet, 
		ClientCantRequestKickYet, ClientDisableFirstPersonViewEffects, 
		ClientHideReticule, ClientMPMiscMessage, 
		ClientNewPassword, ClientNoAuthority, 
		ClientNoKickAdmin, ClientPasswordMessage, 
		ClientPasswordTooLong, ClientResetGameMsg, 
		ClientShowWeapon, ClientVoteInProgress, 
		ClientVoteSessionAbort, R6ClientWeaponShake, 
		R6Shake, ResetBlur;

	// Pos:0x034
	unreliable if((int(Role) < int(ROLE_Authority)))
		RegroupOnMe, ServerActionKeyReleased, 
		ServerActionProgressStop, ServerBroadcast, 
		ServerChangeOperative, ServerChangeTeams, 
		ServerExecFire, ServerGraduallyCloseDoor, 
		ServerGraduallyOpenDoor, ServerLogBandWidth, 
		ServerNetLogActor, ServerNewPing, 
		ServerNextMember, ServerPlayerActionProgress, 
		ServerPreviousMember, ServerReloadWeapon, 
		ServerSendGoCode, ServerSetBipodRotation, 
		ServerSetCrouchBlend, ServerSetHelmetParams, 
		ServerSetPeekingInfoLeft, ServerSetPeekingInfoRight, 
		ServerSetPlayerStartInfo, ServerUpdatePeeking, 
		ServerWeaponUpAnimDone, ToggleAllTeamsHold, 
		ToggleTeamHold;

	// Pos:0x00D
	reliable if((int(Role) == int(ROLE_Authority)))
		ClientAdminLogin, ClientBanMatches, 
		ClientBanned, ClientChangeMap, 
		ClientChatAbuseMsg, ClientChatDisabledMsg, 
		ClientDeathMessage, ClientEndSurrended, 
		ClientFadeCommonSound, ClientFadeSound, 
		ClientFinalizeLoading, ClientForceUnlockWeapon, 
		ClientGameMsg, ClientGameTypeDescription, 
		ClientKickBadId, ClientKickVoteMessage, 
		ClientKickedOut, ClientMissionObjMsg, 
		ClientNewLobbyConnection, ClientNextMapVoteMessage, 
		ClientNoBanMatches, ClientNotifySendMatchResults, 
		ClientNotifySendStartMatch, ClientPBVersionMismatch, 
		ClientPlayMusic, ClientPlayVoices, 
		ClientPlayerUnbanned, ClientPlayerVoteMessage, 
		ClientRestartMatchMsg, ClientRestartRoundMsg, 
		ClientServerChangingInfo, ClientServerMap, 
		ClientSetMultiplayerSkins, ClientSetWeaponSound, 
		ClientStopFadeToBlack, ClientTeamFullMessage, 
		ClientTeamIsDead, ClientUpdateLadderStat, 
		ClientVoteResult, CountDownPopUpBox, 
		CountDownPopUpBoxDone, ServerIndicatesInvalidCDKey, 
		TKPopUpBox, ToggleHelmetCameraZoom;

	// Pos:0x01A
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bRequestTKPopUp, m_bSkipBeginState, 
		m_iAdmin;

	// Pos:0x027
	reliable if((int(Role) == int(ROLE_Authority)))
		m_CurrentCircumstantialAction, m_TeamManager, 
		m_iPlayerCAProgress, m_pawn, 
		m_rCurrentShakeRotation;

	// Pos:0x041
	reliable if((int(Role) < int(ROLE_Authority)))
		Admin, AutoAdminLogin, 
		Ban, BanId, 
		Kick, KickId, 
		LoadServer, LockServer, 
		NewPassword, ReplicateTriggerLagInfo, 
		RestartMatch, RestartRound, 
		SendSettingsAndRestartServer, ServerActionKeyPressed, 
		ServerAdminLogin, ServerBanList, 
		ServerEndOfRoundDataSent, ServerMap, 
		ServerNewGeneralSettings, ServerNewKitRestSettings, 
		ServerNewMapListSettings, ServerPausePreGameRoundTime, 
		ServerPlayRecordedMsg, ServerRequestSkins, 
		ServerSetGender, ServerSetUbiID, 
		ServerStartChangingInfo, ServerStartClimbingLadder, 
		ServerStartSurrended, ServerSwitchWeapon, 
		ServerUnPausePreGameRoundTime, UnBan, 
		Vote, VoteKick, 
		VoteKickID, VoteNextMap;
}

// Export UR6PlayerController::execUpdateCircumstantialAction(FFrame&, void* const)
native(2211) final function UpdateCircumstantialAction();

// Export UR6PlayerController::execUpdateReticule(FFrame&, void* const)
native(1843) final function UpdateReticule(float fDeltaTime);

// Export UR6PlayerController::execUpdateSpectatorReticule(FFrame&, void* const)
native(2213) final function UpdateSpectatorReticule();

// Export UR6PlayerController::execDebugFunction(FFrame&, void* const)
native(1840) final function DebugFunction();

// Export UR6PlayerController::execFindPlayer(FFrame&, void* const)
native(1224) final function PlayerController FindPlayer(string inPlayerIdent, bool bIsIdInt);

// Export UR6PlayerController::execLocalizeTraining(FFrame&, void* const)
native(2724) final function string LocalizeTraining(string SectionName, string KeyName, string PackageName, int iBox, int iParagraph);

// Export UR6PlayerController::execGetLocStringWithActionKey(FFrame&, void* const)
native(1521) final function string GetLocStringWithActionKey(string szText, string szActionKey);

// Export UR6PlayerController::execPlayVoicesPriority(FFrame&, void* const)
native(2726) final function PlayVoicesPriority(R6SoundReplicationInfo aAudioRepInfo, Sound sndPlayVoice, Actor.ESoundSlot eSlotUse, int iPriority, optional bool bWaitToFinishSound, optional float fTime);

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super(Actor).ResetOriginalData();
	m_GameOptions = Class'Engine.Actor'.static.GetGameOptions();
	m_bPawnInitialized = false;
	m_bEndOfRoundDataReceived = false;
	m_bCircumstantialActionInProgress = false;
	m_iPlayerCAProgress = 0;
	m_TeamManager = none;
	m_bAMenuIsDisplayed = false;
	m_PrevViewTarget = none;
	LastDoorUpdateTime = default.LastDoorUpdateTime;
	m_bShakeActive = true;
	CancelShake();
	m_bSniperMode = false;
	m_bCircumstantialActionInProgress = false;
	DesiredFOV = default.DesiredFOV;
	DefaultFOV = default.DefaultFOV;
	ResetFOV();
	m_bOldPeekLeft = 0;
	m_bOldPeekRight = 0;
	m_bHelmetCameraOn = false;
	m_bUseFirstPersonWeapon = default.m_bUseFirstPersonWeapon;
	m_bHideReticule = default.m_bHideReticule;
	m_bScopeZoom = false;
	m_bAllTeamsHold = false;
	m_bFixCamera = default.m_bFixCamera;
	m_bAttachCameraToEyes = default.m_bAttachCameraToEyes;
	bCheatFlying = default.bCheatFlying;
	m_bInitFirstTick = default.m_bInitFirstTick;
	m_eCameraMode = 0;
	m_bCrawl = false;
	bDuck = 0;
	Enemy = none;
	Target = none;
	LastSeenPos = vect(0.0000000, 0.0000000, 0.0000000);
	LastSeeingPos = vect(0.0000000, 0.0000000, 0.0000000);
	LastSeenTime = 0.0000000;
	m_bRequestTKPopUp = false;
	m_bProcessingRequestTKPopUp = false;
	m_TeamKiller = none;
	m_bPlayDeathMusic = false;
	m_bFirstTimeInZone = true;
	m_bLoadSoundGun = false;
	m_bInstructionTouch = false;
	UpdateTriggerLagInfo();
	// End:0x1CB
	if((PlayerReplicationInfo != none))
	{
		PlayerReplicationInfo.iOperativeID = -1;
	}
	// End:0x228
	if(((int(Level.NetMode) == int(NM_Client)) || ((int(Level.NetMode) == int(NM_ListenServer)) && (Viewport(Player) != none))))
	{
		ServerSetGender((m_GameOptions.Gender > 0));
	}
	ResetBlur();
	// End:0x25A
	if(((m_CurrentCircumstantialAction == none) && (int(Role) == int(ROLE_Authority))))
	{
		m_CurrentCircumstantialAction = Spawn(Class'R6Engine.R6CircumstantialActionQuery', self);
	}
	// End:0x275
	if((m_CurrentCircumstantialAction != none))
	{
		m_CurrentCircumstantialAction.aQueryOwner = self;
	}
	// End:0x2A1
	if((m_InteractionCA != none))
	{
		m_InteractionCA.DisplayMenu(false);
		m_InteractionCA.m_bActionKeyDown = false;
	}
	// End:0x2CD
	if((m_InteractionInventory != none))
	{
		m_InteractionInventory.DisplayMenu(false);
		m_InteractionInventory.m_bActionKeyDown = false;
	}
	m_bAlreadyPoppedTKPopUpBox = false;
	return;
}

//------------------------------------------------------------------
// ResettingLevel
//	the server inform the client to reset the level
//------------------------------------------------------------------
simulated function ResettingLevel(int iNbOfRestart)
{
	Pawn = none;
	m_pawn = none;
	SetViewTarget(none);
	// End:0x2F
	if((m_TeamManager != none))
	{
		m_TeamManager.ResetTeam();
	}
	// End:0x4B
	if((m_MenuCommunication != none))
	{
		m_MenuCommunication.SetStatMenuState(4);
	}
	// End:0x78
	if((int(Level.NetMode) == int(NM_Client)))
	{
		Level.ResetLevel(iNbOfRestart);
	}
	UpdateTriggerLagInfo();
	return;
}

simulated function FirstPassReset()
{
	SetViewTarget(none);
	// End:0x28
	if((m_TeamManager != none))
	{
		m_TeamManager.ResetTeam();
		m_TeamManager = none;
	}
	return;
}

function Reset()
{
	super.Reset();
	UpdateTriggerLagInfo();
	m_bFirstTimeInZone = true;
	return;
}

function bool ShouldDisplayIncomingMessages()
{
	// End:0x1B
	if((m_MenuCommunication != none))
	{
		return m_MenuCommunication.GetPlayerDidASelection();
	}
	return true;
	return;
}

function ClientChangeMap()
{
	// End:0x34
	if((m_MenuCommunication != none))
	{
		m_TeamSelection = 0;
		m_MenuCommunication.SetStatMenuState(6);
		m_MenuCommunication.SetPlayerReadyStatus(false);
	}
	return;
}

function ClearReferences()
{
	// End:0x1A
	if((m_MenuCommunication != none))
	{
		m_MenuCommunication.ClearLevelReferences();
	}
	DestroyInteractions();
	return;
}

function ClientNewLobbyConnection(int iLobbyID, int iGroupID)
{
	GameReplicationInfo.m_iGameSvrGroupID = iGroupID;
	GameReplicationInfo.m_iGameSvrLobbyID = iLobbyID;
	m_GameService.m_bMSClientRouterDisconnect = true;
	return;
}

function ClientDeathMessage(string Killer, string killed, byte bSuicideType)
{
	// End:0x1B
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		return;
	}
	// End:0x177
	if((myHUD != none))
	{
		// End:0x68
		if((int(bSuicideType) == 1))
		{
			myHUD.AddTextMessage(Class'R6Engine.R6Pawn'.static.BuildDeathMessage(Killer, killed, bSuicideType), Class'Engine.LocalMessage');			
		}
		else
		{
			// End:0x177
			if((int(bSuicideType) != 4))
			{
				// End:0x145
				if((GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CaptureTheEnemyAdvMode"))
				{
					myHUD.AddDeathTextMessage(((((((killed $ " ") $ Localize("MPDeathMessages", "PlayerHasBeenShot", "ASGameMode")) $ " ") $ Killer) $ " ") $ Localize("MPDeathMessages", "PlayerSurrender", "ASGameMode")), Class'Engine.LocalMessage');					
				}
				else
				{
					myHUD.AddDeathTextMessage(Class'R6Engine.R6Pawn'.static.BuildDeathMessage(Killer, killed, bSuicideType), Class'Engine.LocalMessage');
				}
			}
		}
	}
	return;
}

function ClientMPMiscMessage(string szMsgID, string Name, optional string szEndOfMsg)
{
	local string szMsg;

	// End:0xBC
	if((myHUD != none))
	{
		// End:0x53
		if((Name != ""))
		{
			szMsg = ((Name $ " ") $ Localize("MPMiscMessages", szMsgID, "R6GameInfo"));			
		}
		else
		{
			szMsg = Localize("MPMiscMessages", szMsgID, "R6GameInfo");
		}
		// End:0xA3
		if((szEndOfMsg != ""))
		{
			szMsg = ((szMsg $ " ") $ szEndOfMsg);
		}
		myHUD.AddTextMessage(szMsg, Class'Engine.LocalMessage');
	}
	return;
}

function ClientPlayMusic(Sound Sound)
{
	// End:0x28
	if(((Sound != none) && (Viewport(Player) != none)))
	{
		PlayMusic(Sound);
	}
	return;
}

function ServerReadyToLoadWeaponSound()
{
	local Controller aController;
	local R6Terrorist aTerrorist;
	local R6Rainbow aRainbow;
	local ZoneInfo aZoneInfo;

	aController = Level.ControllerList;
	J0x14:

	// End:0x197 [Loop If]
	if((aController != none))
	{
		// End:0x100
		if((aController.IsA('R6PlayerController') || aController.IsA('R6RainbowAI')))
		{
			aRainbow = R6Rainbow(aController.Pawn);
			// End:0xFD
			if((aRainbow != none))
			{
				SetWeaponSound(aController.m_PawnRepInfo, aRainbow.m_szPrimaryWeapon, 0);
				SetWeaponSound(aController.m_PawnRepInfo, aRainbow.m_szSecondaryWeapon, 1);
				SetWeaponSound(aController.m_PawnRepInfo, aRainbow.m_szPrimaryItem, 2);
				SetWeaponSound(aController.m_PawnRepInfo, aRainbow.m_szSecondaryItem, 3);
			}			
		}
		else
		{
			// End:0x180
			if(aController.IsA('R6TerroristAI'))
			{
				aTerrorist = R6Terrorist(aController.Pawn);
				// End:0x180
				if((aTerrorist != none))
				{
					SetWeaponSound(aController.m_PawnRepInfo, aTerrorist.m_szPrimaryWeapon, 0);
					SetWeaponSound(aController.m_PawnRepInfo, aTerrorist.m_szGrenadeWeapon, 2);
				}
			}
		}
		aController = aController.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	// End:0x1BE
	if((Pawn != none))
	{
		aZoneInfo = Pawn.Region.Zone;		
	}
	else
	{
		aZoneInfo = Region.Zone;
	}
	ClientFinalizeLoading(aZoneInfo);
	return;
}

function SetWeaponSound(R6PawnReplicationInfo PawnRepInfo, string szCurrentWeaponTxt, byte u8CurrentWepon)
{
	local Class<R6EngineWeapon> WeaponClass;
	local string caps_szWeaponName;

	caps_szWeaponName = Caps(szCurrentWeaponTxt);
	// End:0xE4
	if((((((((((caps_szWeaponName == "R6WEAPONGADGETS.NONE") || (caps_szWeaponName == "PRIMARYMAGS")) || (caps_szWeaponName == "SECONDARYMAGS")) || (caps_szWeaponName == "LOCKPICKKIT")) || (caps_szWeaponName == "DIFFUSEKIT")) || (caps_szWeaponName == "ELECTRONICKIT")) || (caps_szWeaponName == "GASMASK")) || (caps_szWeaponName == "NONE")) || (caps_szWeaponName == "")))
	{
		return;
	}
	WeaponClass = Class<R6EngineWeapon>(DynamicLoadObject(szCurrentWeaponTxt, Class'Core.Class'));
	// End:0x11F
	if((WeaponClass != none))
	{
		ClientSetWeaponSound(PawnRepInfo, WeaponClass, u8CurrentWepon);
	}
	return;
}

function ClientSetWeaponSound(R6PawnReplicationInfo PawnRepInfo, Class<R6EngineWeapon> PrimaryWeaponClass, byte u8CurrentWeapon)
{
	// End:0x24
	if((PawnRepInfo != none))
	{
		PawnRepInfo.AssignSound(PrimaryWeaponClass, u8CurrentWeapon);
	}
	return;
}

function ClientFinalizeLoading(ZoneInfo aZoneInfo)
{
	Level.FinalizeLoading();
	m_CurrentAmbianceObject = aZoneInfo;
	Level.m_bCanStartStartingSound = true;
	return;
}

function ServerIndicatesInvalidCDKey(string _szErrorMsgKey)
{
	Player.Console.R6ConnectionFailed(_szErrorMsgKey);
	return;
}

event InitInputSystem()
{
	super.InitInputSystem();
	InitInteractions();
	return;
}

event InitMultiPlayerOptions()
{
	super.InitMultiPlayerOptions();
	ToggleRadar(GetGameOptions().ShowRadar);
	AutoAdminLogin(m_szLastAdminPassword);
	ServerSetGender((m_GameOptions.Gender > 0));
	m_GameService = R6AbstractGameService(Player.Console.SetGameServiceLinks(self));
	ServerSetUbiID(m_GameService.m_szUserID);
	return;
}

simulated function ClientHideReticule(bool bNewReticuleValue)
{
	m_bHideReticule = bNewReticuleValue;
	return;
}

function ClientShowWeapon()
{
	// End:0x37
	if(((m_GameOptions.HUDShowFPWeapon == true) || (R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon == true)))
	{
		ShowWeapon();
	}
	return;
}

simulated function bool ShouldDrawWeapon()
{
	// End:0x23
	if(((m_pawn != none) && (!m_pawn.IsAlive())))
	{
		return false;
	}
	// End:0x57
	if(((int(Level.NetMode) != int(NM_Standalone)) && R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon))
	{
		return true;
	}
	// End:0x6D
	if((!m_GameOptions.HUDShowFPWeapon))
	{
		return false;
	}
	return (m_bShowFPWeapon || m_bShowCompleteHUD);
	return;
}

exec function ShowWeapon()
{
	m_GameOptions.HUDShowFPWeapon = true;
	m_bShowFPWeapon = true;
	// End:0x4F
	if((Pawn.m_WeaponsCarried[0] != none))
	{
		R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
	}
	// End:0x85
	if((Pawn.m_WeaponsCarried[1] != none))
	{
		R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
	}
	return;
}

function Set1stWeaponDisplay(bool bShowWeapon)
{
	m_bShowFPWeapon = bShowWeapon;
	// End:0x84
	if((Pawn != none))
	{
		// End:0x4E
		if((Pawn.m_WeaponsCarried[0] != none))
		{
			R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
		}
		// End:0x84
		if((Pawn.m_WeaponsCarried[1] != none))
		{
			R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
		}
	}
	return;
}

simulated event SetMatchResult(string _UserUbiID, int iField, int iValue)
{
	// End:0x28
	if(((int(Level.NetMode) == int(NM_DedicatedServer)) || (m_GameService == none)))
	{
		return;
	}
	m_GameService.CallNativeSetMatchResult(_UserUbiID, iField, iValue);
	return;
}

// 
event ClientUpdateLadderStat(string _UserUbiID, int _iKillStat, int _iDeathStat, float fPlayTime)
{
	// End:0x3F
	if((((int(Level.NetMode) == int(NM_DedicatedServer)) || (m_GameService == none)) || (PlayerReplicationInfo.m_bClientWillSubmitResult == false)))
	{
		return;
	}
	m_GameService.CallNativeSetMatchResult(_UserUbiID, 0, _iKillStat);
	m_GameService.CallNativeSetMatchResult(_UserUbiID, 1, _iDeathStat);
	m_GameService.CallNativeSetMatchResult(_UserUbiID, 2, 0);
	m_GameService.CallNativeSetMatchResult(_UserUbiID, 3, 0);
	m_GameService.CallNativeSetMatchResult(_UserUbiID, 4, int(fPlayTime));
	return;
}

event ClientNotifySendMatchResults()
{
	local PlayerReplicationInfo aPRI;

	// End:0x43
	if(bShowLog)
	{
		Log(("Received ClientNotifySendMatchResults for player " $ string(self)));
	}
	// End:0x82
	if((((int(Level.NetMode) == int(NM_DedicatedServer)) || (m_GameService == none)) || (PlayerReplicationInfo.m_bClientWillSubmitResult == false)))
	{
		return;
	}
	m_GameService.NativeSubmitMatchResult();
	return;
}

event ClientNotifySendStartMatch()
{
	m_GameService.m_bClientWaitMatchStartReply = true;
	m_GameService.m_bClientWillSubmitResult = true;
	return;
}

function ServerEndOfRoundDataSent()
{
	local Controller _itController;
	local R6PlayerController _playerController;

	m_bEndOfRoundDataReceived = true;
	PlayerReplicationInfo.m_bClientWillSubmitResult = false;
	return;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	m_fLastUpdateServerCheckTime = Level.TimeSeconds;
	// End:0x13F
	if((int(Role) == int(ROLE_Authority)))
	{
		PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, self,, vect(0.0000000, 0.0000000, 0.0000000), rot(0, 0, 0));
		InitPlayerReplicationInfo();
		bIsPlayer = true;
		m_CommonPlayerVoicesMgr = R6CommonRainbowVoices(R6AbstractGameInfo(Level.Game).GetCommonRainbowPlayerVoicesMgr());
		// End:0x13F
		if(((int(Level.NetMode) == int(NM_Standalone)) || Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag)))
		{
			// End:0x11B
			if((Level.m_sndMissionComplete == none))
			{
				Level.m_sndMissionComplete = m_sndMissionComplete;
				AddSoundBankName("Voices_Control_MissionSuccess");
			}
			AddSoundBankName("Voices_Control_MissionFailed");
		}
	}
	Level.m_bAllow3DRendering = true;
	SetPlanningMode(false);
	m_GameOptions = Class'Engine.Actor'.static.GetGameOptions();
	return;
}

function UpdateTriggerLagInfo()
{
	// End:0x69
	if(((m_GameOptions != none) && ((int(Level.NetMode) == int(NM_Client)) || ((Pawn != none) && Pawn.IsLocallyControlled()))))
	{
		m_bWantTriggerLag = m_GameOptions.WantTriggerLag;
		ReplicateTriggerLagInfo(m_bWantTriggerLag);
	}
	return;
}

function ReplicateTriggerLagInfo(bool _value)
{
	m_bWantTriggerLag = _value;
	return;
}

//once a game is started, this function is called once
simulated function HidePlanningActors()
{
	local R6AbstractInsertionZone NavPoint;
	local R6AbstractExtractionZone ExtZone;
	local R6ReferenceIcons RefIco;
	local R6IORotatingDoor RotDoor;
	local string szCurrentGameType;
	local bool bInTraining;

	szCurrentGameType = GameReplicationInfo.m_szGameTypeFlagRep;
	// End:0x36
	foreach AllActors(Class'R6Abstract.R6AbstractInsertionZone', NavPoint)
	{
		NavPoint.bHidden = true;		
	}	
	// End:0x6F
	foreach AllActors(Class'R6Abstract.R6AbstractExtractionZone', ExtZone)
	{
		// End:0x6E
		if((!ExtZone.IsAvailableInGameType(szCurrentGameType)))
		{
			ExtZone.bHidden = true;
		}		
	}	
	// End:0xAA
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		bInTraining = Level.Game.IsA('R6TrainingMgr');
	}
	// End:0x1D8
	foreach AllActors(Class'R6Engine.R6ReferenceIcons', RefIco)
	{
		// End:0xF3
		if((RefIco.IsA('R6DoorIcon') || RefIco.IsA('R6DoorLockedIcon')))
		{
			RefIco.Destroy();
			// End:0x1D7
			continue;
		}
		// End:0x1D7
		if((((!RefIco.IsA('R6ObjectiveIcon')) && (!(bInTraining && (RefIco.IsA('R6HostageIcon') || RefIco.IsA('R6TerroristIcon'))))) && (!((int(Level.NetMode) != int(NM_Standalone)) && RefIco.IsA('R6HostageIcon')))))
		{
			RefIco.bHidden = true;
			// End:0x1D7
			if((((R6ActionPointAbstract(RefIco.Owner) != none) || RefIco.IsA('R6CameraDirection')) || RefIco.IsA('R6ArrowIcon')))
			{
				RefIco.Destroy();
			}
		}		
	}	
	// End:0x1FB
	foreach AllActors(Class'R6Engine.R6IORotatingDoor', RotDoor)
	{
		RotDoor.m_eDisplayFlag = 2;		
	}	
	return;
}

simulated event PostNetBeginPlay()
{
	super(Actor).PostNetBeginPlay();
	// End:0x30
	if((Pawn != none))
	{
		Pawn.Controller = self;
		Pawn.PostNetBeginPlay();
	}
	UpdateTriggerLagInfo();
	return;
}

function ServerSetUbiID(string _szUBIUserID)
{
	// End:0x29
	if((PlayerReplicationInfo.m_szUbiUserID == ""))
	{
		PlayerReplicationInfo.m_szUbiUserID = _szUBIUserID;
	}
	return;
}

function ServerPlayRecordedMsg(string Msg, Pawn.EPreRecordedMsgVoices eRainbowVoices)
{
	Level.Game.BroadcastTeam(self, Msg, 'PreRecMsg');
	// End:0x30
	if((m_TeamManager == none))
	{
		return;
	}
	// End:0x46
	if((m_TeamManager.m_PreRecMsgVoicesMgr == none))
	{
		return;
	}
	// End:0x7F
	if(Pawn.IsAlive())
	{
		m_TeamManager.m_PreRecMsgVoicesMgr.PlayRecordedMsgVoices(R6Pawn(Pawn), eRainbowVoices);
	}
	return;
}

event Destroyed()
{
	// End:0x1B
	if((m_CurrentCircumstantialAction != none))
	{
		m_CurrentCircumstantialAction.aQueryOwner = none;
	}
	ClearReferences();
	// End:0x5B
	if(((Player != none) && (Player.Console != none)))
	{
		Player.Console.SetGameServiceLinks(none);
	}
	// End:0x92
	if((R6AbstractGameInfo(Level.Game) != none))
	{
		R6AbstractGameInfo(Level.Game).RemoveController(self);
	}
	super.Destroyed();
	return;
}

function ServerSetGender(bool bIsFemale)
{
	// End:0x23
	if(((PlayerReplicationInfo == none) || (PlayerReplicationInfo.iOperativeID >= 0)))
	{
		return;
	}
	PlayerReplicationInfo.bIsFemale = bIsFemale;
	PlayerReplicationInfo.iOperativeID = Level.Game.MPSelectOperativeFace(bIsFemale);
	return;
}

//------------------------------------------------------------------
// GetPrefixToMsg
// "(DEAD) Pago "
// "(DEAD) Pago [ALPHA]"
//------------------------------------------------------------------
function string GetPrefixToMsg(PlayerReplicationInfo PRI, name MsgType)
{
	local string szMsg, szLifeState, szTeam;

	// End:0x0E
	if((PRI == none))
	{
		return "";
	}
	// End:0x89
	if(((PRI.bIsSpectator || (PRI.TeamID == int(0))) || (PRI.TeamID == int(4))))
	{
		szLifeState = (("(", Localize("Game", "SPECTATOR", "R6GameInfo")) $ ") " $ ???);		
	}
	else
	{
		// End:0xCC
		if((PRI.m_iHealth > 1))
		{
			szLifeState = (("(", Localize("Game", "DEAD", "R6GameInfo")) $ ") " $ ???);
		}
	}
	// End:0x1C1
	if(((MsgType == 'TeamSay') && (PRI.TeamID == PlayerReplicationInfo.TeamID)))
	{
		// End:0x148
		if((PlayerReplicationInfo.TeamID == int(2)))
		{
			szTeam = ((" [" $ Localize("Game", "GREEN", "R6GameInfo")) $ "]");			
		}
		else
		{
			// End:0x190
			if((PlayerReplicationInfo.TeamID == int(3)))
			{
				szTeam = ((" [" $ Localize("Game", "RED", "R6GameInfo")) $ "]");				
			}
			else
			{
				szTeam = ((" [" $ Localize("Game", "NOTEAM", "R6GameInfo")) $ "]");
			}
		}
	}
	szMsg = ((((szLifeState $ "") $ PRI.PlayerName) $ " ") $ szTeam);
	return szMsg;
	return;
}

//------------------------------------------------------------------
// TeamMessage: inherited
//	
//------------------------------------------------------------------
event TeamMessage(PlayerReplicationInfo PRI, coerce string Msg, name MsgType)
{
	local R6Pawn Sender;
	local string szGroup, szID;
	local int pos;

	// End:0x64
	foreach AllActors(Class'R6Engine.R6Pawn', Sender)
	{
		// End:0x63
		if((Sender.PlayerReplicationInfo == PRI))
		{
			// End:0x60
			if(((Pawn != none) && Pawn.IsFriend(Sender)))
			{
				Sender.m_fLastCommunicationTime = 5.0000000;
			}
			// End:0x64
			break;
		}		
	}	
	// End:0x118
	if((MsgType == 'Line'))
	{
		// End:0x115
		if((PRI != PlayerReplicationInfo))
		{
			Level.AddEncodedWritableMapStrip(Msg);
			// End:0x115
			if((Player != none))
			{
				Player.Console.Message(((Localize("Game", "MapUpdatedBy", "R6GameInfo") $ " ") $ PRI.PlayerName), 6.0000000);
				// End:0x115
				if((m_pawn != none))
				{
					m_pawn.PlaySound(m_sndUpdateWritableMap, 3);
				}
			}
		}		
	}
	else
	{
		// End:0x1CD
		if((MsgType == 'Icon'))
		{
			Level.AddWritableMapIcon(Msg);
			// End:0x1CA
			if(((PRI != PlayerReplicationInfo) && (Player != none)))
			{
				Player.Console.Message(((Localize("Game", "MapUpdatedBy", "R6GameInfo") $ " ") $ PRI.PlayerName), 6.0000000);
				// End:0x1CA
				if((m_pawn != none))
				{
					m_pawn.PlaySound(m_sndUpdateWritableMap, 3);
				}
			}			
		}
		else
		{
			// End:0x213
			if(((MsgType == 'Say') || (MsgType == 'TeamSay')))
			{
				Msg = ((GetPrefixToMsg(PRI, MsgType) $ ": ") $ Msg);				
			}
			else
			{
				// End:0x29F
				if((MsgType == 'PreRecMsg'))
				{
					pos = InStr(Msg, " ");
					szGroup = Left(Msg, pos);
					szID = Right(Msg, ((Len(Msg) - pos) - 1));
					Msg = ((GetPrefixToMsg(PRI, 'TeamSay') $ ": ") $ Localize(szGroup, szID, "R6RecMessages"));
				}
			}
			// End:0x2DA
			if((Player != none))
			{
				Player.InteractionMaster.Process_Message(Msg, 6.0000000, Player.LocalInteractions);
			}
		}
	}
	return;
}

function InitInteractions()
{
	// End:0xCE
	if((Player != none))
	{
		// End:0x2A
		if((m_InteractionMaster == none))
		{
			m_InteractionMaster = Player.InteractionMaster;
		}
		// End:0x80
		if((m_InteractionCA == none))
		{
			m_InteractionCA = R6InteractionCircumstantialAction(m_InteractionMaster.AddInteraction("R6Engine.R6InteractionCircumstantialAction", Player));
		}
		// End:0xCE
		if((m_InteractionInventory == none))
		{
			m_InteractionInventory = R6InteractionInventoryMnu(m_InteractionMaster.AddInteraction("R6Engine.R6InteractionInventoryMnu", Player));
		}
	}
	return;
}

function DestroyInteractions()
{
	// End:0x57
	if((m_InteractionMaster != none))
	{
		// End:0x31
		if((m_InteractionCA != none))
		{
			m_InteractionMaster.RemoveInteraction(m_InteractionCA);
			m_InteractionCA = none;
		}
		// End:0x57
		if((m_InteractionInventory != none))
		{
			m_InteractionMaster.RemoveInteraction(m_InteractionInventory);
			m_InteractionInventory = none;
		}
	}
	return;
}

simulated function SetPlayerStartInfo()
{
	return;
}

function ServerSetPlayerStartInfo(string _armorName, string _WeaponName0, string _WeaponName1, string _BulletName0, string _BulletName1, string _WeaponGadgetName0, string _WeaponGadgetName1, string _GadgetName0, string _GadgetName1)
{
	// End:0x19
	if((m_PlayerStartInfo == none))
	{
		m_PlayerStartInfo = Spawn(Class'Engine.R6RainbowStartInfo');
	}
	m_PlayerStartInfo.m_ArmorName = _armorName;
	m_PlayerStartInfo.m_WeaponName[0] = _WeaponName0;
	m_PlayerStartInfo.m_WeaponName[1] = _WeaponName1;
	m_PlayerStartInfo.m_BulletType[0] = _BulletName0;
	m_PlayerStartInfo.m_BulletType[1] = _BulletName1;
	m_PlayerStartInfo.m_WeaponGadgetName[0] = _WeaponGadgetName0;
	m_PlayerStartInfo.m_WeaponGadgetName[1] = _WeaponGadgetName1;
	m_PlayerStartInfo.m_GadgetName[0] = _GadgetName0;
	m_PlayerStartInfo.m_GadgetName[1] = _GadgetName1;
	// End:0x142
	if(bShowLog)
	{
		Log(((((string(self) @ "SERVERSETPLAYERSTARTINFO weapons are :") $ m_PlayerStartInfo.m_WeaponName[0]) $ " and ") $ m_PlayerStartInfo.m_WeaponName[1]));
	}
	return;
}

event PostRender(Canvas Canvas)
{
	local int iBlurValue;
	local R6IOSelfDetonatingBomb AIt;

	// End:0x24
	if((CheatManager != none))
	{
		R6CheatManager(CheatManager).PostRender(Canvas);
	}
	// End:0xAA
	if((Pawn != none))
	{
		// End:0x60
		if((Pawn.EngineWeapon != none))
		{
			Pawn.EngineWeapon.PostRender(Canvas);
		}
		iBlurValue = int((Pawn.m_fBlurValue + Pawn.m_fDecrementalBlurValue));
		iBlurValue = Clamp(iBlurValue, 0, 235);
		Canvas.SetMotionBlurIntensity(iBlurValue);		
	}
	else
	{
		Canvas.SetMotionBlurIntensity(0);
	}
	// End:0x1AD
	if((!m_bBombSearched))
	{
		// End:0xDE
		foreach AllActors(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
		{
			m_pSelfDetonatingBomb = AIt;			
		}		
		// End:0x1A5
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			// End:0x14A
			if(((m_pSelfDetonatingBomb != none) && (int(Level.NetMode) != int(NM_Client))))
			{
				// End:0x149
				foreach AllActors(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
				{
					m_pSelfDetonatingBomb = AIt;
					m_pSelfDetonatingBomb.StartTimer();					
				}				
			}
			// End:0x1A5
			if((m_pSelfDetonatingBomb == none))
			{
				// End:0x1A5
				if(((GameReplicationInfo != none) && (GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CountDownMode")))
				{
					R6AbstractGameInfo(Level.Game).StartTimer();
				}
			}
		}
		m_bBombSearched = true;
	}
	// End:0x232
	if((m_pSelfDetonatingBomb != none))
	{
		// End:0x1FD
		foreach AllActors(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
		{
			m_pSelfDetonatingBomb = AIt;
			// End:0x1FC
			if(m_pSelfDetonatingBomb.m_bIsActivated)
			{
				m_pSelfDetonatingBomb.PostRender(Canvas);
				// End:0x1FD
				break;
			}			
		}		
		// End:0x22E
		foreach AllActors(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
		{
			m_pSelfDetonatingBomb = AIt;
			m_pSelfDetonatingBomb.PostRender2(Canvas);			
		}				
	}
	else
	{
		// End:0x270
		if(((GameReplicationInfo != none) && (GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CountDownMode")))
		{
			RenderTimeLeft(Canvas);
		}
	}
	return;
}

// --- MissionPack1 2
simulated function RenderTimeLeft(Canvas C)
{
	local float fStrSizeX, fStrSizeY;
	local int X, Y;
	local string sTime;
	local int iTimeLeft;

	iTimeLeft = int((R6AbstractGameInfo(Level.Game).m_fEndingTime - Level.TimeSeconds));
	// End:0x46
	if((iTimeLeft < 0))
	{
		iTimeLeft = 0;
	}
	sTime = (Localize("Game", "TimeLeft", "R6GameInfo") $ " ");
	sTime = (sTime $ ConvertIntTimeToString(iTimeLeft, true));
	C.UseVirtualSize(true, 640.0000000, 480.0000000);
	X = int(C.HalfClipX);
	Y = int((C.HalfClipY / float(8)));
	C.Font = Font'R6Font.Rainbow6_14pt';
	// End:0x10D
	if((iTimeLeft > 20))
	{
		C.SetDrawColor(byte(255), byte(255), byte(255));		
	}
	else
	{
		// End:0x132
		if((iTimeLeft > 10))
		{
			C.SetDrawColor(byte(255), byte(255), 0);			
		}
		else
		{
			C.SetDrawColor(byte(255), 0, 0);
		}
	}
	C.StrLen(sTime, fStrSizeX, fStrSizeY);
	C.SetPos((float(X) - (fStrSizeX / float(2))), float((Y + 24)));
	C.DrawText(sTime);
	return;
}

simulated function ServerActionKeyPressed()
{
	SetRequestedCircumstantialAction();
	return;
}

simulated function ServerActionKeyReleased()
{
	SetRequestedCircumstantialAction();
	return;
}

function ServerNewPing(int iNewPing)
{
	PlayerReplicationInfo.Ping = iNewPing;
	return;
}

event Tick(float fDeltaTime)
{
	local R6AbstractEviLPatchService.PatchState PatchState;

	// End:0x9E
	if((m_bQuitToUpdateServerDisplayed == false))
	{
		// End:0x9E
		if(((Level.TimeSeconds - m_fLastUpdateServerCheckTime) > float(5)))
		{
			m_fLastUpdateServerCheckTime = Level.TimeSeconds;
			PatchState = Class'R6Abstract.R6AbstractEviLPatchService'.static.GetState();
			// End:0x9E
			if((int(PatchState) == int(6)))
			{
				m_bQuitToUpdateServerDisplayed = true;
				HandleServerMsg(Localize("Options", "PatchStatus_RunPatch", "R6Menu"));
			}
		}
	}
	// End:0x102
	if(((m_pawn != none) && (Pawn != none)))
	{
		UpdateCircumstantialAction();
		UpdateReticule(fDeltaTime);
		// End:0x102
		if(m_pawn.bInvulnerableBody)
		{
			// End:0x102
			if(((Level.TimeSeconds - m_fStartSurrenderTime) > float(3)))
			{
				m_pawn.bInvulnerableBody = false;
			}
		}
	}
	return;
}

simulated event ZoneChange(ZoneInfo NewZone)
{
	local int i;

	// End:0x48
	if((((Level.m_WeatherEmitter == none) || (Level.m_WeatherEmitter.Emitters.Length == 0)) || (Viewport(Player) == none)))
	{
		return;
	}
	// End:0x122
	if(Region.Zone.m_bAlternateEmittersActive)
	{
		i = 0;
		J0x66:

		// End:0x10C [Loop If]
		if((i < Region.Zone.m_AlternateWeatherEmitters.Length))
		{
			// End:0x102
			if((Region.Zone.m_AlternateWeatherEmitters[i] != none))
			{
				Region.Zone.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 1;
				Region.Zone.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
			}
			(i++);
			// [Loop Continue]
			goto J0x66;
		}
		Region.Zone.m_bAlternateEmittersActive = false;
	}
	// End:0x1E0
	if((!NewZone.m_bAlternateEmittersActive))
	{
		i = 0;
		J0x13D:

		// End:0x1CF [Loop If]
		if((i < NewZone.m_AlternateWeatherEmitters.Length))
		{
			// End:0x1C5
			if((NewZone.m_AlternateWeatherEmitters[i] != none))
			{
				NewZone.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 0;
				NewZone.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
			}
			(i++);
			// [Loop Continue]
			goto J0x13D;
		}
		NewZone.m_bAlternateEmittersActive = true;
	}
	return;
}

simulated function UpdateWeatherEmitter()
{
	local int i;
	local bool bInDoor;
	local Vector vViewDirection, vWeatherEmitterPos;
	local R6WeatherEmitter WE;
	local ZoneInfo WZ;

	// End:0x16
	if((Level.m_WeatherEmitter == none))
	{
		return;
	}
	// End:0x48
	if(((Level.m_WeatherEmitter.Emitters.Length == 0) || (Viewport(Player) == none)))
	{
		return;
	}
	// End:0xEC
	if((Level.m_WeatherViewTarget != ViewTarget))
	{
		// End:0xD7
		foreach AllActors(Class'Engine.R6WeatherEmitter', WE)
		{
			// End:0xD6
			if(((WE != Level.m_WeatherEmitter) && (WE.Emitters.Length != 0)))
			{
				WE.Emitters[0].m_iPaused = 1;
				WE.Emitters[0].AllParticlesDead = false;
			}			
		}		
		Level.m_WeatherViewTarget = ViewTarget;
	}
	// End:0x203
	if(ViewTarget.Region.Zone.m_bInDoor)
	{
		Level.SetWeatherActive(false);
		WZ = ViewTarget.Region.Zone;
		// End:0x1FE
		if((WZ.m_bAlternateEmittersActive == false))
		{
			i = 0;
			J0x151:

			// End:0x1ED [Loop If]
			if((i < WZ.m_AlternateWeatherEmitters.Length))
			{
				// End:0x1E3
				if((WZ.m_AlternateWeatherEmitters[i].Emitters.Length != 0))
				{
					WZ.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 0;
					WZ.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
				}
				(i++);
				// [Loop Continue]
				goto J0x151;
			}
			WZ.m_bAlternateEmittersActive = true;
		}
		return;		
	}
	else
	{
		// End:0x22A
		if((ViewTarget.m_bInWeatherVolume > 0))
		{
			Level.SetWeatherActive(false);			
		}
		else
		{
			// End:0x2EE
			if((ViewTarget.m_bInWeatherVolume == 0))
			{
				vWeatherEmitterPos = ViewTarget.Location;
				vViewDirection = (vect(1.0000000, 0.0000000, 0.0000000) >> ViewTarget.Rotation);
				(vWeatherEmitterPos.X += (float(256) * vViewDirection.X));
				(vWeatherEmitterPos.Y += (float(256) * vViewDirection.Y));
				(vWeatherEmitterPos.Z += float(100));
				Level.m_WeatherEmitter.SetLocation(vWeatherEmitterPos);
				Level.SetWeatherActive(true);
			}
		}
	}
	return;
}

simulated function R6Shake(float fTime, float fMaxShake, float fMaxShakeTime)
{
	m_fShakeTime = fTime;
	m_fMaxShake = fMaxShake;
	m_fMaxShakeTime = fMaxShakeTime;
	m_fCurrentShake = 0.0000000;
	return;
}

function SetEyeLocation(Pawn pViewTarget, float fDeltaTime)
{
	local Coords cEyesPos;

	cEyesPos = pViewTarget.GetBoneCoords('R6 PonyTail1');
	pViewTarget.m_vEyeLocation = cEyesPos.Origin;
	// End:0x145
	if((m_fShakeTime > float(0)))
	{
		// End:0x124
		if((m_fShakeTime > fDeltaTime))
		{
			(m_fShakeTime -= fDeltaTime);
			// End:0x94
			if((m_fCurrentShake > fDeltaTime))
			{
				(m_rHitRotation *= ((m_fCurrentShake - fDeltaTime) / m_fCurrentShake));
				(m_fCurrentShake -= fDeltaTime);				
			}
			else
			{
				m_rHitRotation.Pitch = int(RandRange((-m_fMaxShake), m_fMaxShake));
				m_rHitRotation.Yaw = int(RandRange((-m_fMaxShake), m_fMaxShake));
				m_rHitRotation.Roll = int(RandRange((-m_fMaxShake), m_fMaxShake));
				m_fCurrentShake = RandRange(0.0000000, m_fMaxShakeTime);
			}
			(m_fMaxShake *= ((m_fShakeTime - fDeltaTime) / m_fShakeTime));			
		}
		else
		{
			m_rHitRotation = rot(0, 0, 0);
			m_fShakeTime = 0.0000000;
		}		
	}
	else
	{
		// End:0x1A9
		if((m_fHitEffectTime > float(0)))
		{
			// End:0x18B
			if((m_fHitEffectTime > fDeltaTime))
			{
				(m_rHitRotation *= ((m_fHitEffectTime - fDeltaTime) / m_fHitEffectTime));
				(m_fHitEffectTime -= fDeltaTime);				
			}
			else
			{
				m_rHitRotation = rot(0, 0, 0);
				m_fHitEffectTime = 0.0000000;
			}
		}
	}
	// End:0x1F5
	if(((!pViewTarget.IsAlive()) && (!IsInState('PenaltyBox'))))
	{
		SetRotation(OrthoRotation(cEyesPos.XAxis, (-cEyesPos.ZAxis), cEyesPos.YAxis));
	}
	AdjustView(fDeltaTime);
	return;
}

event PlayerTick(float fDeltaTime)
{
	local int _iPingTime;

	// End:0x60
	if((((m_GameService != none) && (Viewport(Player) != none)) && (m_GameService.CallNativeProcessIcmpPing(WindowConsole(Player.Console).szStoreIP, _iPingTime) == true)))
	{
		ServerNewPing(_iPingTime);
	}
	// End:0xB9
	if((m_fBlurReturnTime != float(0)))
	{
		(m_fTimedBlurValue -= ((fDeltaTime * float(m_iShakeBlurIntensity)) / m_fBlurReturnTime));
		// End:0xAC
		if((m_fTimedBlurValue <= float(0)))
		{
			m_fTimedBlurValue = 0.0000000;
			m_fBlurReturnTime = 0.0000000;
		}
		Blur(int(m_fTimedBlurValue));
	}
	// End:0xF2
	if((m_fMilestoneMessageLeft > float(0)))
	{
		(m_fMilestoneMessageLeft -= fDeltaTime);
		// End:0xF2
		if((m_fMilestoneMessageLeft < float(0)))
		{
			m_fMilestoneMessageLeft = 0.0000000;
			m_bDisplayMilestoneMessage = false;
		}
	}
	// End:0x141
	if(((GameReplicationInfo != none) && (int(GameReplicationInfo.m_eCurrectServerState) != GameReplicationInfo.3)))
	{
		// End:0x139
		if((m_MenuCommunication != none))
		{
			m_MenuCommunication.RefreshReadyButtonStatus();
		}
		m_bReadyToEnterSpectatorMode = false;
	}
	// End:0x1A2
	if((m_bAttachCameraToEyes && (!bBehindView)))
	{
		// End:0x175
		if((m_pawn != none))
		{
			SetEyeLocation(m_pawn, fDeltaTime);			
		}
		else
		{
			// End:0x1A2
			if(((ViewTarget != none) && (ViewTarget != self)))
			{
				SetEyeLocation(R6Pawn(ViewTarget), fDeltaTime);
			}
		}
	}
	// End:0x1EB
	if(((Pawn != none) && (!bOnlySpectator)))
	{
		// End:0x1DA
		if(PlayerIsFiring())
		{
			Pawn.m_bIsFiringWeapon = bFire;			
		}
		else
		{
			Pawn.m_bIsFiringWeapon = 0;
		}
	}
	UpdateWeatherEmitter();
	super.PlayerTick(fDeltaTime);
	return;
}

function InitMatineeCamera()
{
	m_bMatineeRunning = true;
	m_BackupTeamLeader = m_TeamManager.m_TeamLeader;
	m_TeamManager.m_TeamLeader = none;
	return;
}

function EndMatineeCamera()
{
	m_bMatineeRunning = false;
	m_TeamManager.m_TeamLeader = m_BackupTeamLeader;
	return;
}

function DisplayMilestoneMessage(int iWhoReached, int iMilestoneNumber)
{
	local R6RainbowTeam aRainbowTeam;
	local Pawn.ERainbowOtherTeamVoices eVoices;

	aRainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetRainbowTeam(iWhoReached));
	// End:0x134
	if((((!aRainbowTeam.m_bLeaderIsAPlayer) && (aRainbowTeam.m_iMemberCount > 0)) && (aRainbowTeam.m_OtherTeamVoicesMgr != none)))
	{
		switch(iMilestoneNumber)
		{
			// End:0x83
			case 1:
				eVoices = 5;
				// End:0x106
				break;
			// End:0x93
			case 2:
				eVoices = 6;
				// End:0x106
				break;
			// End:0xA3
			case 3:
				eVoices = 7;
				// End:0x106
				break;
			// End:0xB3
			case 4:
				eVoices = 8;
				// End:0x106
				break;
			// End:0xC3
			case 5:
				eVoices = 9;
				// End:0x106
				break;
			// End:0xD3
			case 6:
				eVoices = 10;
				// End:0x106
				break;
			// End:0xE3
			case 7:
				eVoices = 11;
				// End:0x106
				break;
			// End:0xF3
			case 8:
				eVoices = 12;
				// End:0x106
				break;
			// End:0x103
			case 9:
				eVoices = 13;
				// End:0x106
				break;
			// End:0xFFFF
			default:
				break;
		}
		aRainbowTeam.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(aRainbowTeam.m_TeamLeader, eVoices);		
	}
	else
	{
		m_szMileStoneMessage = (Localize("Order", "MilestoneReached", "R6Menu") $ string(iMilestoneNumber));
		m_bDisplayMilestoneMessage = true;
		m_fMilestoneMessageLeft = m_fMilestoneMessageDuration;
	}
	return;
}

// we need to do the appropriate animations for weapons,
simulated event RenderOverlays(Canvas Canvas)
{
	// End:0x3C
	if((Pawn != none))
	{
		// End:0x3C
		if((Pawn.EngineWeapon != none))
		{
			Pawn.EngineWeapon.RenderOverlays(Canvas);
		}
	}
	// End:0x5B
	if((myHUD != none))
	{
		myHUD.RenderOverlays(Canvas);
	}
	return;
}

function ReloadWeapon()
{
	// End:0x16
	if((Pawn.EngineWeapon == none))
	{
		return;
	}
	// End:0xA8
	if(((((!m_bLockWeaponActions) && (!m_pawn.m_bPostureTransition)) && (!Pawn.EngineWeapon.IsA('R6Gadget'))) && (int(m_pawn.m_eEquipWeapon) == int(m_pawn.3))))
	{
		ToggleHelmetCameraZoom(true);
		m_pawn.ServerSwitchReloadingWeapon(true);
		ServerReloadWeapon();
		m_pawn.ReloadWeapon();
	}
	return;
}

function ServerReloadWeapon()
{
	// End:0x3B
	if(((int(Level.NetMode) == int(NM_Standalone)) || (int(Role) == int(ROLE_Authority))))
	{
		m_pawn.ServerSwitchReloadingWeapon(true);
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// GetFacingDirection()
// returns direction faced relative to movement dir
// 0 = forward, 16384 = right, 32768 = back, 49152 = left
// RBrek - 14 Aug 2001 - made a modification so that if player is 
//      strafing and moving forward the facing direction is forward...
///////////////////////////////////////////////////////////////////////////////////////
function int GetFacingDirection()
{
	local Vector X, Y, Z, Dir;

	GetAxes(Pawn.Rotation, X, Y, Z);
	Dir = Normal(Pawn.Acceleration);
	// End:0xA6
	if(((Dot(Dir, X) < 0.2500000) && (Dir != vect(0.0000000, 0.0000000, 0.0000000))))
	{
		// End:0x83
		if((Dot(Dir, X) < -0.2500000))
		{
			return 32768;			
		}
		else
		{
			// End:0xA0
			if((Dot(Dir, Y) > float(0)))
			{
				return 16384;				
			}
			else
			{
				return 49152;
			}
		}
	}
	return 0;
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// CalcSmoothedRotation()
// used for spectator camera to smooth turning
///////////////////////////////////////////////////////////////////////////////////////
function CalcSmoothedRotation()
{
	local Rotator rCurrent;
	local int iDesiredYaw, iDesiredPitch, iOldYaw, iOldPitch, iMaximum;

	iMaximum = int((float(100000) * m_fCurrentDeltaTime));
	rCurrent = Rotation;
	iOldPitch = m_iSpectatorPitch;
	iDesiredPitch = Rotation.Pitch;
	// End:0x5A
	if((iDesiredPitch > 32768))
	{
		(iDesiredPitch -= 65536);		
	}
	else
	{
		// End:0x75
		if((iDesiredPitch < -32768))
		{
			(iDesiredPitch += 65536);
		}
	}
	// End:0x93
	if((iOldPitch > 32768))
	{
		(iOldPitch -= 65536);		
	}
	else
	{
		// End:0xAE
		if((iOldPitch < -32768))
		{
			(iOldPitch += 65536);
		}
	}
	// End:0xD8
	if((Abs(float((iDesiredPitch - iOldPitch))) < float(iMaximum)))
	{
		m_iSpectatorPitch = iDesiredPitch;		
	}
	else
	{
		// End:0xFC
		if((iDesiredPitch > iOldPitch))
		{
			m_iSpectatorPitch = (iOldPitch + iMaximum);			
		}
		else
		{
			m_iSpectatorPitch = (iOldPitch - iMaximum);
		}
	}
	rCurrent.Pitch = m_iSpectatorPitch;
	iOldYaw = (m_iSpectatorYaw & 65535);
	iDesiredYaw = (Rotation.Yaw & 65535);
	// End:0x1EA
	if((iDesiredYaw < iOldYaw))
	{
		// End:0x1A5
		if(((iOldYaw - iDesiredYaw) < 32768))
		{
			// End:0x190
			if(((iOldYaw - iDesiredYaw) < iMaximum))
			{
				m_iSpectatorYaw = iDesiredYaw;				
			}
			else
			{
				m_iSpectatorYaw = (iOldYaw - iMaximum);
			}			
		}
		else
		{
			(iOldYaw -= 65536);
			// End:0x1D5
			if(((iDesiredYaw - iOldYaw) < iMaximum))
			{
				m_iSpectatorYaw = iDesiredYaw;				
			}
			else
			{
				m_iSpectatorYaw = (iOldYaw + iMaximum);
			}
		}		
	}
	else
	{
		// End:0x239
		if(((iDesiredYaw - iOldYaw) < 32768))
		{
			// End:0x224
			if(((iDesiredYaw - iOldYaw) < iMaximum))
			{
				m_iSpectatorYaw = iDesiredYaw;				
			}
			else
			{
				m_iSpectatorYaw = (iOldYaw + iMaximum);
			}			
		}
		else
		{
			(iDesiredYaw -= 65536);
			// End:0x269
			if(((iOldYaw - iDesiredYaw) < iMaximum))
			{
				m_iSpectatorYaw = iDesiredYaw;				
			}
			else
			{
				m_iSpectatorYaw = (iOldYaw - iMaximum);
			}
		}
	}
	rCurrent.Yaw = m_iSpectatorYaw;
	SetRotation(rCurrent);
	return;
}

function CalcFirstPersonView(out Vector CameraLocation, out Rotator CameraRotation)
{
	local Rotator rAdjust, rPitchOnly;

	// End:0x77
	if(bOnlySpectator)
	{
		// End:0x3D
		if(R6Pawn(ViewTarget).m_bIsPlayer)
		{
			// End:0x3D
			if(R6Pawn(ViewTarget).IsAlive())
			{
				CalcSmoothedRotation();
			}
		}
		CameraRotation = Rotation;
		CameraLocation = (ViewTarget.Location + Pawn(ViewTarget).EyePosition());
		return;		
	}
	else
	{
		// End:0xC0
		if((Pawn == none))
		{
			// End:0xBE
			if(((ViewTarget != none) && (ViewTarget != self)))
			{
				CameraRotation = Rotation;
				CameraLocation = R6Pawn(ViewTarget).m_vEyeLocation;
			}
			return;
		}
	}
	// End:0xF0
	if(bRotateToDesired)
	{
		CameraRotation = ((DesiredRotation + Pawn.m_rRotationOffset) + m_rHitRotation);		
	}
	else
	{
		CameraRotation = ((Rotation + Pawn.m_rRotationOffset) + m_rHitRotation);
	}
	// End:0x134
	if(m_bAttachCameraToEyes)
	{
		CameraLocation = Pawn.m_vEyeLocation;		
	}
	else
	{
		CameraLocation = (CameraLocation + Pawn.EyePosition());
	}
	return;
}

function CheckBob(float DeltaTime, float Speed2D, Vector Y)
{
	return;
	return;
}

// Bobbing is only used for rotation, to bring the weapon down when the character is walking
// All weapons are using only rotation, except pistols, where BobOffset is used
function WeaponBob(float BobDamping, out Rotator BobRotation, out Vector bobOffset)
{
	return;
	return;
}

function CalcBehindView(out Vector CameraLocation, out Rotator CameraRotation, float Dist)
{
	local Vector View, HitLocation, HitNormal;
	local float ViewDist;

	// End:0x4C
	if((bOnlySpectator && (ViewTarget != none)))
	{
		// End:0x3E
		if((R6Pawn(ViewTarget).m_bIsPlayer && bFixedCamera))
		{
			CalcSmoothedRotation();
		}
		CameraRotation = Rotation;		
	}
	else
	{
		// End:0x9B
		if((Pawn != none))
		{
			// End:0x7F
			if(bRotateToDesired)
			{
				CameraRotation = (DesiredRotation + Pawn.m_rRotationOffset);				
			}
			else
			{
				CameraRotation = (Rotation + Pawn.m_rRotationOffset);
			}
		}
	}
	View = (vect(1.0000000, 0.0000000, 0.0000000) >> CameraRotation);
	// End:0x106
	if((Trace(HitLocation, HitNormal, (CameraLocation - (Dist * Vector(CameraRotation))), CameraLocation) != none))
	{
		ViewDist = FMin(Dot((CameraLocation - HitLocation), View), Dist);		
	}
	else
	{
		ViewDist = Dist;
	}
	(CameraLocation -= (ViewDist * View));
	m_vCameraLocation = CameraLocation;
	m_rCameraRotation = CameraRotation;
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// DirectionChanged()
//   rbrek 25 oct 2001 
//   this function determines what the current diagonal direction is and return a bool
//   indicating whether the direction has changed.
///////////////////////////////////////////////////////////////////////////////////////
function bool DirectionChanged()
{
	local R6Pawn.eStrafeDirection eSDir;

	// End:0x30
	if((aForward > float(0)))
	{
		// End:0x25
		if((aStrafe > float(0)))
		{
			eSDir = 1;			
		}
		else
		{
			eSDir = 2;
		}		
	}
	else
	{
		// End:0x48
		if((aStrafe > float(0)))
		{
			eSDir = 3;			
		}
		else
		{
			eSDir = 4;
		}
	}
	// End:0x6E
	if((int(eSDir) == int(m_pawn.m_eStrafeDirection)))
	{
		return false;
	}
	m_pawn.m_eStrafeDirection = eSDir;
	return true;
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// AdjustViewPitch()
///////////////////////////////////////////////////////////////////////////////////////
simulated function AdjustViewPitch(out int iPitch)
{
	iPitch = (iPitch & 65535);
	// End:0x58
	if(((iPitch > 16384) && (iPitch < 49152)))
	{
		// End:0x4D
		if((aLookUp > float(0)))
		{
			iPitch = 16384;			
		}
		else
		{
			iPitch = 49152;
		}
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// AdjustViewYaw()
///////////////////////////////////////////////////////////////////////////////////////
simulated function AdjustViewYaw(out int iYaw)
{
	iYaw = (iYaw & 65535);
	// End:0x6A
	if(m_pawn.m_bIsClimbingLadder)
	{
		// End:0x6A
		if(((iYaw > 10923) && (iYaw < 54613)))
		{
			// End:0x5F
			if((aTurn > float(0)))
			{
				iYaw = 10923;				
			}
			else
			{
				iYaw = 54613;
			}
		}
	}
	// End:0x88
	if((iYaw > 32768))
	{
		(iYaw -= 65536);		
	}
	else
	{
		// End:0xA3
		if((iYaw < -32768))
		{
			(iYaw += 65536);
		}
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// HandleDiagonalStrafing()
// rbrek - 24 oct 2001
//   if the player is both strafing and moving forward/backward, bone rotation is used improve the appearance of the movement.
//   the entire skeleton (using root bone 'R6') is rotated to match the direction of the diagonal movement, and then the torso 
//   is rotated back to reflect the direction that the player is looking (which remains straight ahead).
//   returns true if bone rotation is done, false otherwise...
///////////////////////////////////////////////////////////////////////////////////////
function HandleDiagonalStrafing()
{
	// End:0x5E
	if(((aForward != float(0)) && (aStrafe != float(0))))
	{
		// End:0x5B
		if((DirectionChanged() || (!m_pawn.m_bMovingDiagonally)))
		{
			m_pawn.m_bMovingDiagonally = true;
			m_pawn.AdjustPawnForDiagonalStrafing();
		}		
	}
	else
	{
		// End:0x7F
		if(m_pawn.m_bMovingDiagonally)
		{
			m_pawn.ResetDiagonalStrafing();
		}
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// PassedYawLimit()
// rbrek - 10 april 2002
///////////////////////////////////////////////////////////////////////////////////////
simulated function bool PassedYawLimit(Rotator rRotationOffset)
{
	// End:0x17
	if(m_pawn.m_bIsClimbingLadder)
	{
		return false;		
	}
	else
	{
		// End:0x2F
		if((Abs(float(rRotationOffset.Yaw)) > float(0)))
		{
			return true;
		}
	}
	return false;
	return;
}

//------------------------------------------------------------------
// SetCrouchBlend: set peeking info (single player and multiplayed)
//	
//------------------------------------------------------------------
event SetCrouchBlend(float fCrouchBlend)
{
	m_pawn.SetCrouchBlend(fCrouchBlend);
	// End:0x38
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		ServerSetCrouchBlend(fCrouchBlend);
	}
	return;
}

function ServerSetCrouchBlend(float fCrouchBlend)
{
	// End:0x0D
	if((m_pawn == none))
	{
		return;
	}
	m_pawn.SetCrouchBlend(fCrouchBlend);
	return;
}

//------------------------------------------------------------------
// SetPeekingInfo: set peeking info (single player and multiplayed)
//	
//------------------------------------------------------------------
function SetPeekingInfo(Pawn.ePeekingMode eMode, float fPeekingRatio, optional bool bPeekLeft)
{
	local byte PackedPeekingRatio;
	local float fNormalizedPeekingRatio;

	// End:0x0D
	if((m_pawn == none))
	{
		return;
	}
	m_pawn.SetPeekingInfo(eMode, fPeekingRatio, bPeekLeft);
	// End:0xC0
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		fNormalizedPeekingRatio = (((fPeekingRatio - m_pawn.0.0000000) / (m_pawn.2000.0000000 - m_pawn.0.0000000)) * 254.0000000);
		PackedPeekingRatio = byte(fNormalizedPeekingRatio);
		// End:0xB0
		if(bPeekLeft)
		{
			ServerSetPeekingInfoLeft(eMode, PackedPeekingRatio);			
		}
		else
		{
			ServerSetPeekingInfoRight(eMode, PackedPeekingRatio);
		}
	}
	return;
}

//------------------------------------------------------------------
// SetPeekingInfo: set peeking info 
//	
//------------------------------------------------------------------
function ServerSetPeekingInfoLeft(Pawn.ePeekingMode eMode, byte PackedPeekingRatio)
{
	local float fPeekingRatio;

	// End:0x0D
	if((m_pawn == none))
	{
		return;
	}
	fPeekingRatio = float(PackedPeekingRatio);
	fPeekingRatio = (((fPeekingRatio / 254.0000000) * (m_pawn.2000.0000000 - m_pawn.0.0000000)) + m_pawn.0.0000000);
	m_pawn.SetPeekingInfo(eMode, fPeekingRatio, true);
	return;
}

function ServerSetPeekingInfoRight(Pawn.ePeekingMode eMode, byte PackedPeekingRatio)
{
	local float fPeekingRatio;

	// End:0x0D
	if((m_pawn == none))
	{
		return;
	}
	fPeekingRatio = float(PackedPeekingRatio);
	fPeekingRatio = (((fPeekingRatio / 254.0000000) * (m_pawn.2000.0000000 - m_pawn.0.0000000)) + m_pawn.0.0000000);
	m_pawn.SetPeekingInfo(eMode, fPeekingRatio, false);
	return;
}

//------------------------------------------------------------------
// ServerSetBipodRotation: set the int for replication
//	
//------------------------------------------------------------------
function ServerSetBipodRotation(float fRotation)
{
	// End:0x39
	if((m_pawn != none))
	{
		m_pawn.m_iRepBipodRotationRatio = int(((fRotation / float(m_pawn.5600)) * float(100)));
	}
	return;
}

function bool PlayerIsFiring()
{
	// End:0x16
	if((Pawn.EngineWeapon == none))
	{
		return false;
	}
	// End:0x45
	if(((int(bFire) > 0) && (Pawn.EngineWeapon.NumberOfBulletsLeftInClip() > 0)))
	{
		return true;
	}
	return false;
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// UpdateRotation()
///////////////////////////////////////////////////////////////////////////////////////
simulated function UpdateRotation(float DeltaTime, float maxPitch)
{
	local Rotator rNewRotation, rViewRotation, rRotationOffset;
	local bool bBoneRotationIsDone;
	local float fOffset, fBipodRotationToAdd;
	local R6AbstractWeapon AWeapon;

	// End:0x1B
	if(bCheatFlying)
	{
		super.UpdateRotation(DeltaTime, maxPitch);
		return;
	}
	// End:0x47
	if((bInterpolating || ((Pawn != none) && Pawn.bInterpolating)))
	{
		return;
	}
	// End:0x54
	if((m_pawn == none))
	{
		return;
	}
	rRotationOffset = Pawn.m_rRotationOffset;
	// End:0x85
	if(m_pawn.m_bPostureTransition)
	{
		aTurn = 0.0000000;
	}
	// End:0x26B
	if(m_pawn.m_bUsingBipod)
	{
		fBipodRotationToAdd = (32.0000000 * DeltaTime);
		DesiredRotation.Yaw = Rotation.Yaw;
		// End:0x1AF
		if((Pawn.Velocity != vect(0.0000000, 0.0000000, 0.0000000)))
		{
			(fBipodRotationToAdd *= float(2000));
			// End:0x105
			if((m_pawn.m_fBipodRotation == float(0)))
			{				
			}
			else
			{
				// End:0x165
				if((m_pawn.m_fBipodRotation > float(0)))
				{
					(m_pawn.m_fBipodRotation -= fBipodRotationToAdd);
					m_pawn.m_fBipodRotation = FClamp(m_pawn.m_fBipodRotation, 0.0000000, m_pawn.m_fBipodRotation);					
				}
				else
				{
					(m_pawn.m_fBipodRotation += fBipodRotationToAdd);
					m_pawn.m_fBipodRotation = FClamp(m_pawn.m_fBipodRotation, m_pawn.m_fBipodRotation, 0.0000000);
				}
			}			
		}
		else
		{
			(m_pawn.m_fBipodRotation += (fBipodRotationToAdd * aTurn));
			// End:0x20E
			if((m_pawn.m_fBipodRotation > float(m_pawn.5600)))
			{
				m_pawn.m_fBipodRotation = m_pawn.5600.0000000;				
			}
			else
			{
				// End:0x254
				if((m_pawn.m_fBipodRotation < float((-m_pawn.5600))))
				{
					m_pawn.m_fBipodRotation = float((-m_pawn.5600));
				}
			}
		}
		ServerSetBipodRotation(m_pawn.m_fBipodRotation);		
	}
	else
	{
		// End:0x2A4
		if(((int(m_bSpecialCrouch) > 0) && (!m_pawn.m_bIsProne)))
		{
			aTurn = 0.0000000;
			aLookUp = 0.0000000;
		}
	}
	AWeapon = R6AbstractWeapon(Pawn.EngineWeapon);
	rViewRotation = (Rotation + rRotationOffset);
	(rViewRotation.Yaw += int(((32.0000000 * DeltaTime) * aTurn)));
	// End:0x326
	if((!Level.m_bInGamePlanningActive))
	{
		(rViewRotation.Pitch += int(((32.0000000 * DeltaTime) * aLookUp)));
	}
	AdjustViewPitch(rViewRotation.Pitch);
	rViewRotation.Roll = 0;
	// End:0x3A0
	if(((!bBehindView) && (m_pawn.m_fPeeking != m_pawn.1000.0000000)))
	{
		rViewRotation.Roll = int((m_pawn.GetPeekingRatioNorm(m_pawn.m_fPeeking) * float(2049)));
	}
	rRotationOffset = (rViewRotation - Rotation);
	AdjustViewYaw(rRotationOffset.Yaw);
	// End:0x417
	if(bRotateToDesired)
	{
		DesiredRotation.Yaw = (DesiredRotation.Yaw & 65535);
		// End:0x417
		if((Rotation.Yaw != DesiredRotation.Yaw))
		{
			Pawn.m_rRotationOffset = rRotationOffset;
			return;
		}
	}
	bRotateToDesired = false;
	// End:0x789
	if(((((Pawn.Acceleration != vect(0.0000000, 0.0000000, 0.0000000)) || (aForward != float(0))) || (aStrafe != float(0))) && (!m_pawn.m_bIsClimbingLadder)))
	{
		// End:0x5F6
		if(m_pawn.m_bIsProne)
		{
			rRotationOffset.Yaw = Clamp(rRotationOffset.Yaw, (-m_pawn.m_iMaxRotationOffset), m_pawn.m_iMaxRotationOffset);
			// End:0x540
			if(m_pawn.m_bUsingBipod)
			{
				// End:0x506
				if(((rRotationOffset.Pitch > 5461) && (rRotationOffset.Pitch < 18001)))
				{
					rRotationOffset.Pitch = 5461;
				}
				// End:0x540
				if(((rRotationOffset.Pitch < 60075) && (rRotationOffset.Pitch > 49000)))
				{
					rRotationOffset.Pitch = 60075;
				}
			}
			// End:0x5F3
			if((rRotationOffset.Yaw != 0))
			{
				DesiredRotation.Yaw = m_pawn.Rotation.Yaw;
				// End:0x5A6
				if((rRotationOffset.Yaw > 0))
				{
					fOffset = float(Clamp(rRotationOffset.Yaw, 0, int((float(6600) * DeltaTime))));					
				}
				else
				{
					fOffset = float(Clamp(rRotationOffset.Yaw, int((float((-6600)) * DeltaTime)), 0));
				}
				(rRotationOffset.Yaw -= int(fOffset));
				(DesiredRotation.Yaw += int(fOffset));
			}			
		}
		else
		{
			rRotationOffset.Yaw = 0;
			DesiredRotation.Yaw = rViewRotation.Yaw;
		}
		DesiredRotation.Pitch = 0;
		DesiredRotation.Roll = 0;
		HandleDiagonalStrafing();
		// End:0x661
		if((Rotation.Yaw != DesiredRotation.Yaw))
		{
			SetRotation(DesiredRotation);
			bRotateToDesired = true;			
		}
		else
		{
			// End:0x685
			if((!bBehindView))
			{
				Pawn.FaceRotation(DesiredRotation, DeltaTime);
			}
		}
		// End:0x738
		if((((!bBoneRotationIsDone) && m_pawn.m_bMovingDiagonally) && (!m_pawn.m_bIsProne)))
		{
			// End:0x701
			if(((int(m_pawn.m_eStrafeDirection) == int(1)) || (int(m_pawn.m_eStrafeDirection) == int(4))))
			{
				rRotationOffset.Yaw = -6000;				
			}
			else
			{
				rRotationOffset.Yaw = 6000;
			}
			m_pawn.PawnLook(rRotationOffset, true, true);
			rRotationOffset.Yaw = 0;
			bBoneRotationIsDone = true;
		}
		// End:0x786
		if(((!m_pawn.m_bMovingDiagonally) && (PlayerIsFiring() || m_pawn.GunShouldFollowHead())))
		{
			m_pawn.PawnLook(rRotationOffset, true, true);
			bBoneRotationIsDone = true;
		}		
	}
	else
	{
		// End:0x87D
		if(m_pawn.m_bIsProne)
		{
			rRotationOffset.Yaw = Clamp(rRotationOffset.Yaw, (-m_pawn.m_iMaxRotationOffset), m_pawn.m_iMaxRotationOffset);
			// End:0x856
			if(m_pawn.m_bUsingBipod)
			{
				// End:0x81C
				if(((rRotationOffset.Pitch > 5461) && (rRotationOffset.Pitch < 18001)))
				{
					rRotationOffset.Pitch = 5461;
				}
				// End:0x856
				if(((rRotationOffset.Pitch < 60075) && (rRotationOffset.Pitch > 49000)))
				{
					rRotationOffset.Pitch = 60075;
				}
			}
			// End:0x87A
			if(PlayerIsFiring())
			{
				m_pawn.PawnLook(rRotationOffset, true, false);
				bBoneRotationIsDone = true;
			}			
		}
		else
		{
			// End:0x8B6
			if((((aForward == float(0)) && (aStrafe == float(0))) && m_pawn.m_bMovingDiagonally))
			{
				HandleDiagonalStrafing();				
			}
			else
			{
				// End:0x96E
				if((PassedYawLimit(rRotationOffset) || ((rRotationOffset.Yaw != 0) && m_pawn.IsPeeking())))
				{
					rNewRotation = (Rotation + rRotationOffset);
					rNewRotation.Pitch = 0;
					rNewRotation.Roll = 0;
					SetRotation(rNewRotation);
					DesiredRotation = rViewRotation;
					DesiredRotation.Pitch = 0;
					DesiredRotation.Roll = 0;
					bRotateToDesired = true;
					rRotationOffset.Yaw = 0;
					m_pawn.PawnLook(rRotationOffset);
					bBoneRotationIsDone = true;
				}
			}
		}
	}
	// End:0x98A
	if((m_bShakeActive == true))
	{
		R6ViewShake(DeltaTime, rRotationOffset);
	}
	// End:0x9A8
	if((!bBoneRotationIsDone))
	{
		m_pawn.PawnLook(rRotationOffset,, true);
	}
	ViewFlash(DeltaTime);
	rNewRotation = rViewRotation;
	rNewRotation.Roll = 0;
	// End:0xA2B
	if((((!bRotateToDesired) && (Pawn != none)) && ((!bFreeCamera) || (!bBehindView))))
	{
		// End:0xA2B
		if((float(rRotationOffset.Yaw) == 0.0000000))
		{
			Pawn.FaceRotation(rNewRotation, DeltaTime);
		}
	}
	Pawn.m_rRotationOffset = rRotationOffset;
	return;
}

function ResetFluidPeeking()
{
	// End:0x3A
	if((int(m_pawn.m_ePeekingMode) == int(2)))
	{
		SetPeekingInfo(0, m_pawn.1000.0000000);
		SetCrouchBlend(0.0000000);
	}
	return;
}

function HandleFluidMovement(float DeltaTime)
{
	local float fCrouchRate, fPeekingRate, fBlendAlpha;

	// End:0x0D
	if((m_pawn == none))
	{
		return;
	}
	// End:0x3E
	if(((int(m_pawn.m_ePeekingMode) == int(1)) || (!m_pawn.CanPeek())))
	{
		return;
	}
	// End:0x1C4
	if(((int(m_bSpecialCrouch) > 0) && (!m_pawn.m_bIsProne)))
	{
		// End:0xBF
		if((int(m_pawn.m_ePeekingMode) == int(0)))
		{
			// End:0x9A
			if(Pawn.bIsCrouched)
			{
				SetCrouchBlend(1.0000000);				
			}
			else
			{
				SetCrouchBlend(0.0000000);
			}
			// End:0xBF
			if(Pawn.bIsCrouched)
			{
				bDuck = 0;
			}
		}
		fCrouchRate = m_pawn.m_fCrouchBlendRate;
		(fCrouchRate -= ((aMouseY * DeltaTime) / float(m_iFluidMovementSpeed)));
		fCrouchRate = FClamp(fCrouchRate, 0.0000000, 1.0000000);
		fPeekingRate = m_pawn.GetPeekingRatioNorm(m_pawn.m_fPeeking);
		(fPeekingRate += ((aMouseX * DeltaTime) / float(m_iFluidMovementSpeed)));
		fPeekingRate = FClamp(fPeekingRate, -1.0000000, 1.0000000);
		(fPeekingRate *= m_pawn.1000.0000000);
		(fPeekingRate += m_pawn.1000.0000000);
		fPeekingRate = FClamp(fPeekingRate, m_pawn.0.0000000, m_pawn.2000.0000000);
		SetPeekingInfo(2, fPeekingRate);
		SetCrouchBlend(fCrouchRate);
	}
	return;
}

//---------------------------------------------------------------------------------------//
//                          INPUT exec() functions (controls)                            //
//---------------------------------------------------------------------------------------//
exec function ToggleTeamHold()
{
	// End:0x0D
	if((m_TeamManager == none))
	{
		return;
	}
	// End:0x23
	if((m_TeamManager.m_iMemberCount == 1))
	{
		return;
	}
	// End:0x39
	if((bOnlySpectator || bCheatFlying))
	{
		return;
	}
	// End:0x89
	if((m_TeamManager.m_bTeamIsHoldingPosition && (!m_TeamManager.m_Team[1].Controller.IsInState('FollowLeader'))))
	{
		m_TeamManager.InstructPlayerTeamToFollowLead();		
	}
	else
	{
		m_TeamManager.InstructPlayerTeamToHoldPosition();
	}
	return;
}

exec function ToggleAllTeamsHold()
{
	local R6RainbowTeam AITeam;

	ToggleTeamHold();
	// End:0x21
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		return;
	}
	// End:0x6B
	if(m_bAllTeamsHold)
	{
		m_bAllTeamsHold = false;
		// End:0x68
		if((R6AbstractGameInfo(Level.Game) != none))
		{
			R6AbstractGameInfo(Level.Game).InstructAllTeamsToFollowPlanning();
		}		
	}
	else
	{
		m_bAllTeamsHold = true;
		// End:0xA9
		if((R6AbstractGameInfo(Level.Game) != none))
		{
			R6AbstractGameInfo(Level.Game).InstructAllTeamsToHoldPosition();
		}
	}
	return;
}

exec function ToggleSniperControl()
{
	local R6RainbowTeam aRainbowTeam;
	local int i, iNbTeam;

	// End:0xC6
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		i = 0;
		J0x20:

		// End:0xAC [Loop If]
		if((i < 3))
		{
			aRainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetRainbowTeam(i));
			// End:0xA2
			if(((aRainbowTeam != none) && (aRainbowTeam.m_iMemberCount > 0)))
			{
				aRainbowTeam.m_bSniperHold = (!aRainbowTeam.m_bSniperHold);
				(iNbTeam++);
			}
			(i++);
			// [Loop Continue]
			goto J0x20;
		}
		// End:0xC6
		if((iNbTeam > 1))
		{
			m_TeamManager.PlaySniperOrder();
		}
	}
	return;
}

exec function TeamsStatus()
{
	local R6RainbowTeam aRainbowTeam[3];
	local int i, iNbTeam;

	// End:0x111
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		i = 0;
		J0x20:

		// End:0x9D [Loop If]
		if((i < 3))
		{
			aRainbowTeam[i] = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetRainbowTeam(i));
			// End:0x93
			if(((aRainbowTeam[i] != none) && (aRainbowTeam[i].m_iMemberCount > 0)))
			{
				(iNbTeam++);
			}
			(i++);
			// [Loop Continue]
			goto J0x20;
		}
		// End:0x111
		if((iNbTeam > 1))
		{
			m_TeamManager.PlaySoundTeamStatusReport();
			i = 0;
			J0xBE:

			// End:0x111 [Loop If]
			if((i < 3))
			{
				// End:0x107
				if(((aRainbowTeam[i] != none) && (m_TeamManager != aRainbowTeam[i])))
				{
					aRainbowTeam[i].PlaySoundTeamStatusReport();
				}
				(i++);
				// [Loop Continue]
				goto J0xBE;
			}
		}
	}
	return;
}

exec function GoCodeAlpha()
{
	// End:0x21
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		ServerSendGoCode(NM_Standalone);
	}
	return;
}

exec function GoCodeBravo()
{
	// End:0x21
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		ServerSendGoCode(NM_DedicatedServer);
	}
	return;
}

exec function GoCodeCharlie()
{
	// End:0x21
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		ServerSendGoCode(NM_ListenServer);
	}
	return;
}

exec function GoCodeZulu()
{
	ServerSendGoCode(3);
	return;
}

function ServerSendGoCode(Object.EGoCode eGo)
{
	local R6RainbowTeam aRainbowTeam;
	local int i;

	m_TeamManager.PlayGoCode(eGo);
	Player.Console.SendGoCode(eGo);
	// End:0xDB
	if((int(eGo) == int(3)))
	{
		// End:0xC1
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			i = 0;
			J0x61:

			// End:0xBE [Loop If]
			if((i < 3))
			{
				aRainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetRainbowTeam(i));
				// End:0xB4
				if((aRainbowTeam != none))
				{
					aRainbowTeam.ReceivedZuluGoCode();
				}
				(i++);
				// [Loop Continue]
				goto J0x61;
			}			
		}
		else
		{
			// End:0xDB
			if((m_TeamManager != none))
			{
				m_TeamManager.ReceivedZuluGoCode();
			}
		}
	}
	return;
}

exec function SkipDestination()
{
	// End:0x2E
	if((bOnlySpectator == false))
	{
		m_pawn.GetTeamMgr().m_TeamPlanning.SkipCurrentDestination();
	}
	return;
}

exec function NextTeam()
{
	ChangeTeams(true);
	return;
}

exec function PreviousTeam()
{
	ChangeTeams(false);
	return;
}

exec function RegroupOnMe()
{
	// End:0x0D
	if((m_TeamManager == none))
	{
		return;
	}
	// End:0x23
	if((bOnlySpectator || bCheatFlying))
	{
		return;
	}
	// End:0x91
	if((!m_TeamManager.m_Team[0].IsAlive()))
	{
		// End:0x87
		if((m_TeamManager.m_iMemberCount > 0))
		{
			// End:0x75
			if((int(Level.NetMode) != int(NM_Standalone)))
			{
				ClientShowWeapon();
			}
			m_TeamManager.SwitchPlayerControlToNextMember();			
		}
		else
		{
			ChangeTeams(true);
		}		
	}
	else
	{
		// End:0xB4
		if((!m_TeamManager.m_bTeamIsClimbingLadder))
		{
			m_TeamManager.InstructPlayerTeamToFollowLead();
		}
	}
	return;
}

exec function NextMember()
{
	// End:0x55
	if((m_bCanChangeMember == true))
	{
		Pawn.EngineWeapon.StopFire(false);
		ServerNextMember();
		// End:0x55
		if((int(Level.NetMode) != int(NM_Standalone)))
		{
			m_bCanChangeMember = false;
			SetTimer(1.0000000, false);
		}
	}
	return;
}

exec function PreviousMember()
{
	// End:0x55
	if((m_bCanChangeMember == true))
	{
		Pawn.EngineWeapon.StopFire(false);
		ServerPreviousMember();
		// End:0x55
		if((int(Level.NetMode) != int(NM_Standalone)))
		{
			m_bCanChangeMember = false;
			SetTimer(1.0000000, false);
		}
	}
	return;
}

function Timer()
{
	m_bCanChangeMember = true;
	return;
}

function ChangeOperative(int iTeamId, int iOperativeID)
{
	ServerChangeOperative(iTeamId, iOperativeID);
	return;
}

function ServerChangeOperative(int iTeamId, int iOperativeID)
{
	R6AbstractGameInfo(Level.Game).ChangeOperatives(self, iTeamId, iOperativeID);
	return;
}

exec function GraduallyOpenDoor()
{
	// End:0x0D
	if((m_pawn == none))
	{
		return;
	}
	// End:0x6E
	if(((((!m_pawn.m_bIsProne) && (!m_pawn.m_bChangingWeapon)) && (!m_pawn.m_bReloadingWeapon)) && (!Level.m_bInGamePlanningActive)))
	{
		ServerGraduallyOpenDoor(m_bSpeedUpDoor);
	}
	return;
}

exec function GraduallyCloseDoor()
{
	// End:0x0D
	if((m_pawn == none))
	{
		return;
	}
	// End:0x6E
	if(((((!m_pawn.m_bIsProne) && (!m_pawn.m_bChangingWeapon)) && (!m_pawn.m_bReloadingWeapon)) && (!Level.m_bInGamePlanningActive)))
	{
		ServerGraduallyCloseDoor(m_bSpeedUpDoor);
	}
	return;
}

exec function RaisePosture()
{
	// End:0x0D
	if((m_pawn == none))
	{
		return;
	}
	// End:0x1C
	if((int(m_bSpecialCrouch) > 0))
	{
		return;
	}
	// End:0xC5
	if((((m_pawn.m_bPostureTransition && (!m_pawn.m_bIsLanding)) || (((m_pawn.m_bIsProne && (m_pawn.EngineWeapon != none)) && R6AbstractWeapon(m_pawn.EngineWeapon).GotBipod()) && m_bLockWeaponActions)) || (m_pawn.m_bIsProne && m_pawn.m_bChangingWeapon)))
	{
		return;
	}
	// End:0x114
	if(m_pawn.m_bIsProne)
	{
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aTurn = 0.0000000;
		Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	}
	// End:0x15D
	if((int(m_pawn.m_ePeekingMode) == int(2)))
	{
		// End:0x146
		if((!m_pawn.AdjustFluidCollisionCylinder(0.0000000, true)))
		{
			return;
		}
		m_pawn.AdjustFluidCollisionCylinder(0.0000000);
		ResetFluidPeeking();
	}
	// End:0x1A8
	if(m_bCrawl)
	{
		m_bCrawl = false;
		bDuck = 1;
		// End:0x1A5
		if((int(m_pawn.m_ePeekingMode) == int(1)))
		{
			SetPeekingInfo(0, m_pawn.1000.0000000);
		}		
	}
	else
	{
		// End:0x1D1
		if((int(bDuck) == 1))
		{
			bDuck = 0;
			R6Pawn(Pawn).CrouchToStand();
		}
	}
	return;
}

exec function LowerPosture()
{
	// End:0x0D
	if((m_pawn == none))
	{
		return;
	}
	// End:0x1C
	if((int(m_bSpecialCrouch) > 0))
	{
		return;
	}
	// End:0x6E
	if(((((int(bDuck) == 1) && (m_pawn.EngineWeapon != none)) && R6AbstractWeapon(m_pawn.EngineWeapon).GotBipod()) && m_bLockWeaponActions))
	{
		return;
	}
	// End:0xAB
	if((int(m_pawn.m_ePeekingMode) == int(2)))
	{
		// End:0xA5
		if((int(bDuck) == 0))
		{
			m_pawn.AdjustFluidCollisionCylinder(0.9600000);
		}
		ResetFluidPeeking();
	}
	// End:0xD7
	if((int(bDuck) == 0))
	{
		bDuck = 1;
		R6Pawn(Pawn).StandToCrouch();		
	}
	else
	{
		// End:0x119
		if((!m_bCrawl))
		{
			// End:0x111
			if((int(m_pawn.m_ePeekingMode) == int(1)))
			{
				SetPeekingInfo(0, m_pawn.1000.0000000);
			}
			m_bCrawl = true;
		}
	}
	return;
}

exec function Zoom()
{
	ToggleHelmetCameraZoom();
	return;
}

exec function ToggleAutoAim()
{
	// End:0x72
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		(m_wAutoAim++);
		// End:0x36
		if((int(m_wAutoAim) > 3))
		{
			m_wAutoAim = 0;
		}
		ClientGameMsg("", "", ("AutoAim" $ string(m_wAutoAim)));
		Class'Engine.Actor'.static.GetGameOptions().AutoTargetSlider = int(m_wAutoAim);		
	}
	else
	{
		m_wAutoAim = 0;
	}
	return;
}

exec function ChangeRateOfFire()
{
	// End:0x2C
	if((Pawn.EngineWeapon != none))
	{
		Pawn.EngineWeapon.SetNextRateOfFire();
	}
	return;
}

exec function PrimaryWeapon()
{
	SwitchWeapon(1);
	return;
}

exec function SecondaryWeapon()
{
	SwitchWeapon(2);
	return;
}

exec function GadgetOne()
{
	SwitchWeapon(3);
	return;
}

exec function GadgetTwo()
{
	SwitchWeapon(4);
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// rbrek 26 oct 2001
// TeamMovementMode()  
//   player can change the current movement mode 
//   cycles through the ROE: SPEED_Blitz, SPEED_Normal, SPEED_Cautious
///////////////////////////////////////////////////////////////////////////////////////
exec function TeamMovementMode()
{
	// End:0x0D
	if((m_TeamManager == none))
	{
		return;
	}
	switch(m_TeamManager.m_eMovementSpeed)
	{
		// End:0x36
		case 0:
			m_TeamManager.m_eMovementSpeed = 1;
			// End:0x6B
			break;
		// End:0x4F
		case 1:
			m_TeamManager.m_eMovementSpeed = 2;
			// End:0x6B
			break;
		// End:0x68
		case 2:
			m_TeamManager.m_eMovementSpeed = 0;
			// End:0x6B
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// rbrek 26 oct 2001
// RulesOfEngagement()  
//   player can change the current rule of engagement 
//   cycles through the ROE: MOVE_Assault, MOVE_Infiltrate, MOVE_Recon
///////////////////////////////////////////////////////////////////////////////////////
exec function RulesOfEngagement()
{
	// End:0x0D
	if((m_TeamManager == none))
	{
		return;
	}
	switch(m_TeamManager.m_eMovementMode)
	{
		// End:0x36
		case 0:
			m_TeamManager.m_eMovementMode = 1;
			// End:0x6B
			break;
		// End:0x4F
		case 1:
			m_TeamManager.m_eMovementMode = 2;
			// End:0x6B
			break;
		// End:0x68
		case 2:
			m_TeamManager.m_eMovementMode = 0;
			// End:0x6B
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// ResetSpecialCrouch() 
// reset the Special Crouch mode:  stop peeking, and return to either upright or crouching,
// depending on which position is closer
///////////////////////////////////////////////////////////////////////////////////////
function ResetSpecialCrouch()
{
	// End:0x1B
	if((int(m_pawn.m_ePeekingMode) != int(2)))
	{
		return;
	}
	// End:0x3E
	if((m_pawn.m_fCrouchBlendRate >= 0.5000000))
	{
		bDuck = 1;		
	}
	else
	{
		// End:0x5E
		if(m_pawn.AdjustFluidCollisionCylinder(0.0000000, true))
		{
			bDuck = 0;			
		}
		else
		{
			bDuck = 1;
		}
	}
	// End:0x87
	if((int(bDuck) == 1))
	{
		m_pawn.AdjustFluidCollisionCylinder(0.9600000);		
	}
	else
	{
		m_pawn.AdjustFluidCollisionCylinder(0.0000000);
	}
	ResetFluidPeeking();
	return;
}

exec function PlayFiring()
{
	// End:0x3F
	if(((Pawn != none) && (GameReplicationInfo.m_bGameOverRep == false)))
	{
		Pawn.EngineWeapon.Fire(0.0000000);
	}
	return;
}

exec function PlayAltFiring()
{
	// End:0x31
	if((Pawn.EngineWeapon != none))
	{
		Pawn.EngineWeapon.AltFire(0.0000000);
	}
	return;
}

exec function CycleHUDLayer()
{
	R6AbstractHUD(myHUD).CycleHUDLayer();
	return;
}

exec function ToggleHelmet()
{
	R6AbstractHUD(myHUD).ToggleHelmet();
	return;
}

function ChangeTeams(bool bNextTeam)
{
	Pawn.EngineWeapon.StopFire(false);
	ServerChangeTeams(bNextTeam);
	return;
}

function ServerChangeTeams(bool bNextTeam)
{
	R6AbstractGameInfo(Level.Game).ChangeTeams(self, bNextTeam);
	return;
}

function ServerNextMember()
{
	// End:0x0D
	if((m_TeamManager == none))
	{
		return;
	}
	m_TeamManager.SwitchPlayerControlToNextMember();
	return;
}

function ServerPreviousMember()
{
	// End:0x0D
	if((m_TeamManager == none))
	{
		return;
	}
	m_TeamManager.SwitchPlayerControlToPreviousMember();
	return;
}

function UpdatePlayerPostureAfterSwitch()
{
	// End:0x25
	if(Pawn.m_bIsProne)
	{
		m_bCrawl = true;
		bDuck = 1;		
	}
	else
	{
		// End:0x4A
		if(Pawn.bIsCrouched)
		{
			bDuck = 1;
			m_bCrawl = false;			
		}
		else
		{
			bDuck = 0;
			m_bCrawl = false;
		}
	}
	return;
}

function bool PlayerIsInFrontOfDoubleDoors()
{
	// End:0x2C
	if(((m_pawn.m_Door != none) && (m_pawn.m_Door2 != none)))
	{
		return true;
	}
	return false;
	return;
}

function bool PlayerLookingAtFirstDoor()
{
	local Vector vLookDir, vCenter, vCutOff, vResult;
	local R6Door rightDoor, leftDoor;
	local Vector vDoor1, vDoor2;

	vDoor1 = Normal((m_pawn.m_Door.m_RotatingDoor.m_vCenterOfDoor - (Pawn.Location + Pawn.EyePosition())));
	vDoor2 = Normal((m_pawn.m_Door2.m_RotatingDoor.m_vCenterOfDoor - (Pawn.Location + Pawn.EyePosition())));
	vResult = Cross(vDoor1, vDoor2);
	// End:0xE1
	if((vResult.Z > float(0)))
	{
		rightDoor = m_pawn.m_Door;
		leftDoor = m_pawn.m_Door2;		
	}
	else
	{
		rightDoor = m_pawn.m_Door2;
		leftDoor = m_pawn.m_Door;
	}
	vLookDir = Vector(Pawn.GetViewRotation());
	vCenter = ((leftDoor.m_RotatingDoor.m_vCenterOfDoor + rightDoor.m_RotatingDoor.m_vCenterOfDoor) / float(2));
	vCutOff = Normal((vCenter - (Pawn.Location + Pawn.EyePosition())));
	vResult = Cross(vCutOff, vLookDir);
	// End:0x1D0
	if((vResult.Z > float(0)))
	{
		// End:0x1CB
		if((leftDoor == m_pawn.m_Door))
		{
			return true;			
		}
		else
		{
			return false;
		}		
	}
	else
	{
		// End:0x1ED
		if((rightDoor == m_pawn.m_Door))
		{
			return true;			
		}
		else
		{
			return false;
		}
	}
	return;
}

function bool GraduallyControlDoor(out R6Door aDoor)
{
	local bool bIsLookingAtFirstDoor;

	bIsLookingAtFirstDoor = true;
	// End:0x1E
	if((m_pawn.m_Door == none))
	{
		return false;
	}
	// End:0x3D
	if((m_pawn.m_Door.m_RotatingDoor == none))
	{
		return false;
	}
	// End:0x63
	if(m_pawn.m_Door.m_RotatingDoor.m_bIsDoorLocked)
	{
		return false;
	}
	// End:0xE3
	if(PlayerIsInFrontOfDoubleDoors())
	{
		// End:0xA1
		if((m_CurrentCircumstantialAction.aQueryTarget == m_pawn.m_Door.m_RotatingDoor))
		{
			bIsLookingAtFirstDoor = true;			
		}
		else
		{
			// End:0xD6
			if((m_CurrentCircumstantialAction.aQueryTarget == m_pawn.m_Door2.m_RotatingDoor))
			{
				bIsLookingAtFirstDoor = false;				
			}
			else
			{
				bIsLookingAtFirstDoor = PlayerLookingAtFirstDoor();
			}
		}
	}
	// End:0x107
	if((LastDoorUpdateTime == float(0)))
	{
		LastDoorUpdateTime = Level.TimeSeconds;		
	}
	else
	{
		// End:0x15C
		if(((Level.TimeSeconds - LastDoorUpdateTime) >= 0.5000000))
		{
			// End:0x146
			if(bIsLookingAtFirstDoor)
			{
				aDoor = m_pawn.m_Door;				
			}
			else
			{
				aDoor = m_pawn.m_Door2;
			}
			return true;
		}
	}
	return false;
	return;
}

function ServerGraduallyOpenDoor(byte bSpeedUpDoor)
{
	local int speed;
	local R6Door aDoor;
	local bool bStatus;

	bStatus = GraduallyControlDoor(aDoor);
	// End:0x1F
	if((!bStatus))
	{
		return;
	}
	speed = m_iDoorSpeed;
	// End:0x42
	if((int(bSpeedUpDoor) > 0))
	{
		speed = m_iFastDoorSpeed;
	}
	aDoor.m_RotatingDoor.updateAction(float(speed), Pawn);
	return;
}

function ServerGraduallyCloseDoor(byte bSpeedUpDoor)
{
	local int speed;
	local R6Door aDoor;
	local bool bStatus;

	bStatus = GraduallyControlDoor(aDoor);
	// End:0x1F
	if((!bStatus))
	{
		return;
	}
	speed = (-m_iDoorSpeed);
	// End:0x46
	if((int(bSpeedUpDoor) > 0))
	{
		speed = (-m_iFastDoorSpeed);
	}
	aDoor.m_RotatingDoor.updateAction(float(speed), Pawn);
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// rbrek 27 nov 2001  
// UpdatePlayerPeeking()  
//   new full peeking controls, now there is one button to peek left and one button
//   to peek right.  a peek button must be held down to continue peeking, when the
//	 button is released, the player returns to normal posture.
// note:  using either the peekleft or peekright buttons while in a 
//		  fluid-set position will reset the player's posture.
///////////////////////////////////////////////////////////////////////////////////////
function UpdatePlayerPeeking()
{
	local bool bPeekingLeft, bPeekingRight;

	// End:0x65
	if((m_pawn.m_bIsProne && (Pawn.Acceleration != vect(0.0000000, 0.0000000, 0.0000000))))
	{
		// End:0x63
		if((int(m_pawn.m_ePeekingMode) != int(0)))
		{
			SetPeekingInfo(0, m_pawn.1000.0000000);
		}
		return;
	}
	// End:0x135
	if((((int(m_bPeekLeft) == 1) && (int(m_bOldPeekLeft) == 1)) || ((int(m_bPeekRight) == 1) && (int(m_bOldPeekRight) == 1))))
	{
		// End:0x135
		if(((!m_pawn.IsPeeking()) && (!m_pawn.m_bPostureTransition)))
		{
			// End:0x135
			if((((m_pawn.bIsCrouched && m_pawn.bWantsToCrouch) && (m_bCrawl == false)) || (m_pawn.m_bWantsToProne && m_pawn.m_bIsProne)))
			{
				m_bOldPeekRight = 0;
				m_bOldPeekLeft = 0;
			}
		}
	}
	// End:0x1CE
	if(((int(m_bOldPeekLeft) != int(m_bPeekLeft)) || (int(m_bOldPeekRight) != int(m_bPeekRight))))
	{
		// End:0x171
		if(m_pawn.m_bPostureTransition)
		{
			return;
		}
		CommonUpdatePeeking(m_bPeekLeft, m_bPeekRight);
		// End:0x1CE
		if((int(Level.NetMode) != int(NM_Standalone)))
		{
			bPeekingLeft = (int(m_bPeekLeft) != 0);
			bPeekingRight = (int(m_bPeekRight) != 0);
			ServerUpdatePeeking(bPeekingLeft, bPeekingRight);
		}
	}
	m_bOldPeekLeft = m_bPeekLeft;
	m_bOldPeekRight = m_bPeekRight;
	return;
}

function CommonUpdatePeeking(byte bPeekLeftButton, byte bPeekRightButton)
{
	// End:0xC4
	if((int(m_pawn.m_ePeekingMode) == int(1)))
	{
		// End:0x77
		if(m_pawn.IsPeekingLeft())
		{
			// End:0x74
			if((int(bPeekLeftButton) == 0))
			{
				// End:0x5E
				if((int(bPeekRightButton) == 1))
				{
					SetPeekingInfo(1, m_pawn.2000.0000000);					
				}
				else
				{
					SetPeekingInfo(0, m_pawn.1000.0000000);
				}
			}			
		}
		else
		{
			// End:0xC1
			if((int(bPeekRightButton) == 0))
			{
				// End:0xAB
				if((int(bPeekLeftButton) == 1))
				{
					SetPeekingInfo(1, m_pawn.0.0000000, true);					
				}
				else
				{
					SetPeekingInfo(0, m_pawn.1000.0000000);
				}
			}
		}		
	}
	else
	{
		// End:0x14A
		if(((!(int(m_pawn.m_ePeekingMode) == int(1))) && m_pawn.CanPeek()))
		{
			// End:0x120
			if((int(bPeekLeftButton) > 0))
			{
				ResetSpecialCrouch();
				SetPeekingInfo(1, m_pawn.0.0000000, true);				
			}
			else
			{
				// End:0x14A
				if((int(bPeekRightButton) > 0))
				{
					ResetSpecialCrouch();
					SetPeekingInfo(1, m_pawn.2000.0000000, false);
				}
			}
		}
	}
	return;
}

function ServerUpdatePeeking(bool bPeekLeft, bool bPeekRight)
{
	local byte PeekLeftButton, PeekRightButton;

	// End:0x11
	if(bPeekLeft)
	{
		PeekLeftButton = 1;
	}
	// End:0x22
	if(bPeekRight)
	{
		PeekRightButton = 1;
	}
	CommonUpdatePeeking(PeekLeftButton, PeekRightButton);
	return;
}

function HandleWalking()
{
	// End:0x0B
	if(bOnlySpectator)
	{
		return;
	}
	// End:0x4B
	if((Pawn != none))
	{
		Pawn.bIsWalking = ((int(bRun) == 0) || (int(m_pawn.m_eHealth) != int(0)));
	}
	return;
}

function TKPopUpBox(string _KillerName)
{
	m_MenuCommunication.TKPopUpBox(_KillerName);
	return;
}

function ServerTKPopUpDone(bool _bApplyTeamKillerPenalty)
{
	// End:0x36
	if(((int(Level.NetMode) == int(NM_Standalone)) || (int(Level.NetMode) == int(NM_Client))))
	{
		return;
	}
	m_bRequestTKPopUp = false;
	// End:0x59
	if(((_bApplyTeamKillerPenalty == false) || (m_TeamKiller == none)))
	{
		return;
	}
	m_TeamKiller.m_bHasAPenalty = true;
	m_TeamKiller.m_ePenaltyForKillingAPawn = 1;
	m_TeamKiller = none;
	return;
}

function ServerExecFire(optional float f)
{
	Fire(f);
	return;
}

exec function LogSpecialValues()
{
	return;
}

function InitializeMenuCom()
{
	// End:0x30
	if(((GameReplicationInfo == none) || ((m_MenuCommunication != none) && (m_MenuCommunication.m_GameRepInfo != none))))
	{
		return;
	}
	// End:0x144
	if((Viewport(Player) != none))
	{
		m_MenuCommunication = Player.Console.Master.m_MenuCommunication;
		// End:0x73
		if((m_MenuCommunication == none))
		{
			return;
		}
		m_MenuCommunication.m_GameRepInfo = GameReplicationInfo;
		m_MenuCommunication.m_PlayerController = self;
		ServerRequestSkins();
		GameReplicationInfo.ControllerStarted(m_MenuCommunication);
		m_MenuCommunication.SelectTeam();
		// End:0xDA
		if(bOnlySpectator)
		{
			m_MenuCommunication.PlayerSelection(4);
		}
		// End:0x144
		if(((int(Level.NetMode) != int(NM_Standalone)) && (int(Level.NetMode) != int(NM_DedicatedServer))))
		{
			// End:0x144
			if((int(m_TeamSelection) != int(0)))
			{
				ServerTeamRequested(m_TeamSelection);
				// End:0x144
				if((m_bDeadAfterTeamSel == true))
				{
					m_bDeadAfterTeamSel = false;
					GotoState('Dead');
				}
			}
		}
	}
	return;
}

function ServerTeamRequested(Object.ePlayerTeamSelection eTeamSelected, optional bool bForceSelection)
{
	local string szMessageLocTag;
	local bool bSameTeam;
	local int iTeamA, iTeamB, iMaxPlayerOnTeam;
	local PlayerReplicationInfo PRI;
	local Controller _P;
	local R6PlayerController P;

	// End:0x2F
	if(((!bForceSelection) && R6AbstractGameInfo(Level.Game).IsTeamSelectionLocked()))
	{
		return;
	}
	// End:0x64
	if(((GameReplicationInfo.IsInAGameState() && (Pawn != none)) && Pawn.IsAlive()))
	{
		return;
	}
	_P = Level.ControllerList;
	J0x78:

	// End:0x126 [Loop If]
	if((_P != none))
	{
		// End:0x10F
		if((_P.IsA('PlayerController') && (_P.PlayerReplicationInfo != none)))
		{
			PRI = _P.PlayerReplicationInfo;
			// End:0x10F
			if((PRI != PlayerReplicationInfo))
			{
				// End:0xF1
				if((PRI.TeamID == int(2)))
				{
					(iTeamA++);					
				}
				else
				{
					// End:0x10F
					if((PRI.TeamID == int(3)))
					{
						(iTeamB++);
					}
				}
			}
		}
		_P = _P.nextController;
		// [Loop Continue]
		goto J0x78;
	}
	// End:0x186
	if((PB_CanPlayerSpawn() == false))
	{
		eTeamSelected = 4;
		ClientPBVersionMismatch();
		// End:0x186
		if(bShowLog)
		{
			Log((("PlayerController " $ string(self)) $ " has a PunkBuster version mismatch"));
		}
	}
	// End:0x1B8
	if((int(eTeamSelected) == int(1)))
	{
		// End:0x1B0
		if((iTeamA > iTeamB))
		{
			eTeamSelected = 3;			
		}
		else
		{
			eTeamSelected = 2;
		}
	}
	bSameTeam = (PlayerReplicationInfo.TeamID == int(eTeamSelected));
	iMaxPlayerOnTeam = GetMissionDescription().GetMaxNbPlayers(GameReplicationInfo.m_szGameTypeFlagRep);
	// End:0x263
	if((iMaxPlayerOnTeam <= (iTeamA + iTeamB)))
	{
		// End:0x23D
		if(((int(m_TeamSelection) == int(2)) || (int(m_TeamSelection) == int(3))))
		{
			eTeamSelected = m_TeamSelection;			
		}
		else
		{
			eTeamSelected = 4;
		}
		bSameTeam = (PlayerReplicationInfo.TeamID == int(eTeamSelected));
	}
	// End:0x313
	if((!bSameTeam))
	{
		iMaxPlayerOnTeam = GetMissionDescription().GetMaxNbPlayers(GameReplicationInfo.m_szGameTypeFlagRep);
		// End:0x2C7
		if(Level.IsGameTypeTeamAdversarial(Level.Game.m_szCurrGameType))
		{
			iMaxPlayerOnTeam = (iMaxPlayerOnTeam / 2);
		}
		// End:0x313
		if((((int(eTeamSelected) == int(2)) && (iTeamA >= iMaxPlayerOnTeam)) || ((int(eTeamSelected) == int(3)) && (iTeamB >= iMaxPlayerOnTeam))))
		{
			ClientTeamFullMessage();
			return;
		}
	}
	m_TeamSelection = eTeamSelected;
	PlayerReplicationInfo.TeamID = int(eTeamSelected);
	// End:0x3B8
	if(((int(Level.NetMode) != int(NM_Standalone)) && (Level.Game != none)))
	{
		// End:0x389
		if(GameReplicationInfo.IsInAGameState())
		{
			PlayerReplicationInfo.m_bJoinedTeamLate = true;			
		}
		else
		{
			PlayerReplicationInfo.m_bJoinedTeamLate = false;
		}
		R6AbstractGameInfo(Level.Game).PlayerReadySelected(self);
	}
	// End:0x4B8
	if((!bSameTeam))
	{
		szMessageLocTag = "ChangedTeamSpectator";
		// End:0x45C
		if(Level.IsGameTypeTeamAdversarial(Level.Game.m_szCurrGameType))
		{
			// End:0x433
			if((int(eTeamSelected) == int(2)))
			{
				szMessageLocTag = "ChangedGreenTeam";				
			}
			else
			{
				// End:0x459
				if((int(eTeamSelected) == int(3)))
				{
					szMessageLocTag = "ChangedRedTeam";
				}
			}			
		}
		else
		{
			// End:0x484
			if((int(eTeamSelected) == int(2)))
			{
				szMessageLocTag = "HasJoinedTheGame";
			}
		}
		// End:0x4B7
		foreach DynamicActors(Class'R6Engine.R6PlayerController', P)
		{
			P.ClientMPMiscMessage(szMessageLocTag, PlayerReplicationInfo.PlayerName);			
		}		
	}
	// End:0x4CE
	if((Viewport(Player) != none))
	{
		PlayerTeamSelectionReceived();
	}
	return;
}

simulated event bool IsPlayerPassiveSpectator()
{
	return ((int(m_TeamSelection) == int(0)) || (int(m_TeamSelection) == int(4)));
	return;
}

event PlayerTeamSelectionReceived()
{
	m_MenuCommunication.RefreshReadyButtonStatus();
	return;
}

function EnterSpectatorMode()
{
	return;
}

function ResetCurrentState()
{
	return;
}

function ClientGotoState(name NewState, name NewLabel)
{
	// End:0x28
	if(((GetStateName() == 'BaseSpectating') && (NewState == 'Dead')))
	{
		m_bDeadAfterTeamSel = true;
		return;
	}
	// End:0x3D
	if((GetStateName() == NewState))
	{
		ResetCurrentState();
		return;
	}
	// End:0x56
	if((NewLabel == 'None'))
	{
		GotoState(NewState);		
	}
	else
	{
		GotoState(NewState, NewLabel);
	}
	return;
}

exec function Suicide()
{
	// End:0x12
	if((R6Pawn(Pawn) == none))
	{
		return;
	}
	// End:0x28
	if((!m_pawn.IsAlive()))
	{
		return;
	}
	// End:0x35
	if((GameReplicationInfo == none))
	{
		return;
	}
	// End:0x66
	if((GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CaptureTheEnemyAdvMode"))
	{
		return;
	}
	// End:0xA3
	if(((int(Level.NetMode) != int(NM_Standalone)) && (int(GameReplicationInfo.m_eCurrectServerState) != GameReplicationInfo.3)))
	{
		return;
	}
	// End:0xCB
	if((GameReplicationInfo.m_bInPostBetweenRoundTime || GameReplicationInfo.m_bGameOverRep))
	{
		return;
	}
	R6Pawn(Pawn).ServerSuicidePawn(3);
	// End:0x124
	if((Player.Console != none))
	{
		Player.Console.Message("Commited suicide", 6.0000000);
	}
	return;
}

function ClientDisableFirstPersonViewEffects(optional bool bChangingPawn)
{
	DisableFirstPersonViewEffects(bChangingPawn);
	m_bLockWeaponActions = false;
	return;
}

function DisableFirstPersonViewEffects(optional bool bChangingPawn)
{
	local R6AbstractWeapon AWeapon;

	// End:0x257
	if((Pawn != none))
	{
		// End:0x243
		if(Pawn.IsLocallyControlled())
		{
			DoZoom(true);
			bZooming = false;
			m_bHelmetCameraOn = false;
			DefaultFOV = default.DefaultFOV;
			DesiredFOV = default.DesiredFOV;
			FovAngle = default.DesiredFOV;
			HelmetCameraZoom(1.0000000);
			R6Pawn(Pawn).ToggleHeatProperties(false, none, none);
			R6Pawn(Pawn).ToggleNightProperties(false, none, none);
			R6Pawn(Pawn).ToggleScopeProperties(false, none, none);
			Level.m_bHeartBeatOn = false;
			ResetBlur();
			Level.m_bInGamePlanningActive = false;
			SetPlanningMode(false);
			// End:0x15C
			if(((int(Level.NetMode) == int(NM_Standalone)) || (!PlayerCanSwitchToAIBackup())))
			{
				AWeapon = R6AbstractWeapon(Pawn.EngineWeapon);
				// End:0x159
				if((AWeapon != none))
				{
					AWeapon.GotoState('None');
					AWeapon.DisableWeaponOrGadget();
					// End:0x159
					if((int(Level.NetMode) != int(NM_DedicatedServer)))
					{
						AWeapon.RemoveFirstPersonWeapon();
					}
				}				
			}
			else
			{
				// End:0x1BA
				if((!bChangingPawn))
				{
					m_bShowFPWeapon = false;
					m_bHideReticule = true;
					R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
					R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);					
				}
				else
				{
					// End:0x243
					if(((m_GameOptions.HUDShowFPWeapon == true) || (R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon == true)))
					{
						m_bShowFPWeapon = true;
						m_bHideReticule = false;
						m_bUseFirstPersonWeapon = true;
						R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
						R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
					}
				}
			}
		}
		Pawn.m_fRemainingGrenadeTime = 0.0000000;
	}
	bBehindView = false;
	return;
}

function ServerStartSurrenderSequence()
{
	m_bSkipBeginState = false;
	GotoState('PlayerStartSurrenderSequence');
	return;
}

function ServerStartSurrended()
{
	m_bSkipBeginState = false;
	GotoState('PlayerSurrended');
	return;
}

function ClientEndSurrended()
{
	m_bSkipBeginState = false;
	m_pawn.m_eHealth = 0;
	m_pawn.m_bIsSurrended = false;
	GotoState('PlayerEndSurrended');
	return;
}

//============================================================================
// DispatchOrder - 
//============================================================================
function DispatchOrder(int iOrder, R6Pawn pSource)
{
	switch(iOrder)
	{
		// End:0x25
		case int(m_pawn.1):
			SecureRainbow(pSource);
			// End:0x4A
			break;
		// End:0x43
		case int(m_pawn.2):
			FreeRainbow(pSource);
			// End:0x4A
			break;
		// End:0xFFFF
		default:
			assert(false);
			break;
	}
	return;
}

function SecureRainbow(R6Pawn pOther)
{
	m_pawn.m_bIsBeingArrestedOrFreed = true;
	m_pInteractingRainbow = pOther;
	return;
}

function FreeRainbow(R6Pawn pOther)
{
	m_pInteractingRainbow = pOther;
	m_pawn.SetFree();
	return;
}

simulated function R6PlayerMove(float DeltaTime)
{
	local Vector X, Y, Z, NewAccel;
	local Actor.EDoubleClickDir DoubleClickMove;
	local Rotator OldRotation, ViewRotation;
	local float Speed2D;
	local bool bSaveJump;

	// End:0x2A
	if((Pawn != none))
	{
		GetAxes(Pawn.Rotation, X, Y, Z);
	}
	NewAccel = ((aForward * X) + (aStrafe * Y));
	NewAccel.Z = 0.0000000;
	DoubleClickMove = getPlayerInput().CheckForDoubleClickMove(DeltaTime);
	GroundPitch = 0;
	// End:0xBE
	if((Pawn != none))
	{
		ViewRotation = Pawn.Rotation;
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1.0000000);
	}
	// End:0xF3
	if((int(Role) < int(ROLE_Authority)))
	{
		ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, (OldRotation - Rotation));		
	}
	else
	{
		ProcessMove(DeltaTime, NewAccel, DoubleClickMove, (OldRotation - Rotation));
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
//                     -- state PLAYERACTIONPROGRESS --               
///////////////////////////////////////////////////////////////////////////////////////
//function ServerPlayerActionProgress(R6CircumstantialActionQuery newActionQuery)
function ServerPlayerActionProgress()
{
	m_PlayerCurrentCA = m_RequestedCircumstantialAction;
	// End:0x32
	if(m_PlayerCurrentCA.aQueryTarget.IsA('R6Terrorist'))
	{
		GotoState('PlayerSecureTerrorist');		
	}
	else
	{
		// End:0xC0
		if((Class'Engine.Actor'.static.GetModMgr().IsMissionPack() && m_PlayerCurrentCA.aQueryTarget.IsA('R6Rainbow')))
		{
			// End:0xB6
			if(bShowLog)
			{
				Log(((("Log " $ string(self)) $ "  I'm going to secure rainbow : ") $ string(m_PlayerCurrentCA.aQueryTarget)));
			}
			GotoState('PlayerSecureRainbow');			
		}
		else
		{
			GotoState('PlayerActionProgress');
		}
	}
	return;
}

function ClientActionProgressDone()
{
	m_InteractionCA.ActionProgressDone();
	return;
}

function ServerActionProgressStop()
{
	m_RequestedCircumstantialAction.aQueryTarget.R6CircumstantialActionCancel();
	m_iPlayerCAProgress = 0;
	// End:0x6A
	if(Class'Engine.Actor'.static.GetModMgr().IsMissionPack())
	{
		// End:0x67
		if((m_pawn.IsAlive() && (!m_pawn.m_bIsSurrended)))
		{
			GotoState('PlayerWalking');
		}		
	}
	else
	{
		// End:0x83
		if(m_pawn.IsAlive())
		{
			GotoState('PlayerWalking');
		}
	}
	// End:0x9D
	if((m_InteractionCA != none))
	{
		m_InteractionCA.ActionProgressStop();
	}
	return;
}

function ServerStartClimbingLadder()
{
	m_bSkipBeginState = false;
	GotoState('PlayerBeginClimbingLadder');
	return;
}

function ExtractMissingLadderInformation()
{
	// End:0x5D
	if(((m_pawn.m_Ladder == none) && (Pawn.OnLadder != none)))
	{
		m_pawn.m_Ladder = R6Ladder(m_pawn.LocateLadderActor(Pawn.OnLadder));
		return;
	}
	// End:0xAD
	if(((Pawn.OnLadder == none) && (m_pawn.m_Ladder != none)))
	{
		Pawn.OnLadder = m_pawn.m_Ladder.MyLadder;
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//R6MOTIONBLUR
simulated function ResetBlur()
{
	local Canvas C;

	m_fBlurReturnTime = 0.0000000;
	C = Class'Engine.Actor'.static.GetCanvas();
	// End:0x35
	if((C != none))
	{
		C.SetMotionBlurIntensity(0);
	}
	return;
}

// 0 is no blur, 100 is full blur
function Blur(int iValue)
{
	// End:0x38
	if((Pawn != none))
	{
		iValue = Clamp(iValue, 0, 100);
		Pawn.m_fBlurValue = (float(iValue) * 2.3500000);
	}
	return;
}

// set the zoom level of the camera on the helmet
function HelmetCameraZoom(float fZoomLevel)
{
	DefaultFOV = (default.DesiredFOV / fZoomLevel);
	DesiredFOV = DefaultFOV;
	m_bHelmetCameraOn = (fZoomLevel != float(1));
	// End:0x58
	if((int(Level.NetMode) == int(NM_Client)))
	{
		ServerSetHelmetParams(fZoomLevel, m_bScopeZoom);
	}
	return;
}

function ServerSetHelmetParams(float fZoomLevel, bool bScopeZoom)
{
	// End:0x23
	if(((m_pawn != none) && (!m_pawn.IsAlive())))
	{
		return;
	}
	m_bHelmetCameraOn = (fZoomLevel != float(1));
	// End:0x50
	if((fZoomLevel > 2.0000000))
	{
		m_bSniperMode = m_bHelmetCameraOn;
	}
	m_bScopeZoom = bScopeZoom;
	return;
}

function ToggleHelmetCameraZoom(optional bool bTurnOff)
{
	// End:0x19
	if(((bTurnOff == false) && m_bLockWeaponActions))
	{
		return;
	}
	// End:0x85
	if(((((Pawn.EngineWeapon != none) && (Pawn.EngineWeapon.HasScope() == true)) && (m_bSniperMode == false)) && (bTurnOff == false)))
	{
		Pawn.EngineWeapon.GotoState('ZoomIn');		
	}
	else
	{
		DoZoom(bTurnOff);
	}
	return;
}

function DoZoom(optional bool bTurnOff)
{
	// End:0x23
	if(((Pawn == none) || (Pawn.EngineWeapon == none)))
	{
		return;
	}
	// End:0x194
	if(m_bHelmetCameraOn)
	{
		// End:0xE8
		if((((Pawn.EngineWeapon.IsSniperRifle() == true) && (m_bScopeZoom == false)) && (bTurnOff == false)))
		{
			m_bScopeZoom = true;
			Pawn.EngineWeapon.WeaponZoomSound(false);
			HelmetCameraZoom(Pawn.EngineWeapon.m_fMaxZoom);
			m_pawn.m_fWeaponJump = (Pawn.EngineWeapon.GetWeaponJump() / float(2));
			m_pawn.m_fZoomJumpReturn = 0.2000000;			
		}
		else
		{
			// End:0x127
			if((Pawn.EngineWeapon.HasScope() == true))
			{
				Pawn.EngineWeapon.GotoState('ZoomOut');
				m_bScopeZoom = false;
			}
			m_bSniperMode = false;
			m_bUseFirstPersonWeapon = true;
			R6Pawn(Pawn).ToggleScopeVision();
			HelmetCameraZoom(1.0000000);
			m_pawn.m_fWeaponJump = Pawn.EngineWeapon.GetWeaponJump();
			m_pawn.m_fZoomJumpReturn = 1.0000000;
		}		
	}
	else
	{
		// End:0x1A2
		if((bTurnOff == true))
		{
			return;
		}
		R6Pawn(Pawn).ToggleScopeVision();
		// End:0x234
		if((Pawn.EngineWeapon.IsSniperRifle() == true))
		{
			HelmetCameraZoom(3.5000000);
			m_bUseFirstPersonWeapon = false;
			m_bSniperMode = true;
			m_pawn.m_fWeaponJump = (Pawn.EngineWeapon.GetWeaponJump() / 1.5000000);
			m_pawn.m_fZoomJumpReturn = 0.5000000;			
		}
		else
		{
			// End:0x2A3
			if((Pawn.EngineWeapon.m_ScopeTexture != none))
			{
				m_bSniperMode = true;
				m_bUseFirstPersonWeapon = false;
				m_pawn.m_fWeaponJump = (Pawn.EngineWeapon.GetWeaponJump() / 1.5000000);
				m_pawn.m_fZoomJumpReturn = 0.5000000;
			}
			HelmetCameraZoom(Pawn.EngineWeapon.m_fMaxZoom);
		}
	}
	return;
}

event float GetZoomMultiplyFactor(float fWeaponMaxZoom)
{
	// End:0x63
	if(((Pawn != none) && (Pawn.EngineWeapon.IsSniperRifle() == true)))
	{
		// End:0x60
		if((m_bHelmetCameraOn == true))
		{
			// End:0x53
			if((m_bScopeZoom == true))
			{
				return (fWeaponMaxZoom * 0.5000000);				
			}
			else
			{
				return (fWeaponMaxZoom * 0.2500000);
			}
		}		
	}
	else
	{
		// End:0x7C
		if((m_bHelmetCameraOn == true))
		{
			return (fWeaponMaxZoom * 0.5000000);
		}
	}
	return 1.0000000;
	return;
}

function ShakeView(float fWaveTime, float fRollMax, Vector vImpactDirection, float fRollSpeed, Vector vPositionOffset, float fReturnTime)
{
	local Vector vRotationX, vRotationY, vRotationZ;
	local float fCosValue, fCosValueRoll, fAngle;
	local int iPitchOrientation, iRollOrientation;

	// End:0x28
	if(((vImpactDirection.X == float(0)) && (vImpactDirection.Y == float(0))))
	{
		return;
	}
	ShakeRollTime = (fWaveTime + m_pawn.m_fStunShakeTime);
	// End:0x5D
	if((m_fShakeReturnTime < fReturnTime))
	{
		m_fShakeReturnTime = fReturnTime;
	}
	// End:0x77
	if((MaxShakeRoll < fRollMax))
	{
		MaxShakeRoll = fRollMax;
	}
	GetAxes(Rotation, vRotationX, vRotationY, vRotationZ);
	vRotationX.Z = 0.0000000;
	vRotationX = Normal(vRotationX);
	vRotationY.Z = 0.0000000;
	vRotationY = Normal(vRotationY);
	MaxShakeOffset = (-vImpactDirection);
	MaxShakeOffset.Z = 0.0000000;
	MaxShakeOffset = Normal(MaxShakeOffset);
	iPitchOrientation = 1;
	fCosValue = Dot(MaxShakeOffset, vRotationX);
	// End:0x122
	if((fCosValue < float(0)))
	{
		iPitchOrientation = -1;
	}
	iRollOrientation = 1;
	fCosValueRoll = Dot(MaxShakeOffset, vRotationY);
	// End:0x153
	if((fCosValueRoll > float(0)))
	{
		iRollOrientation = -1;
	}
	MaxShakeOffset.X = ((fCosValue * fCosValue) * float(iPitchOrientation));
	MaxShakeOffset.Z = ((1.0000000 - Abs(MaxShakeOffset.X)) * float(iRollOrientation));
	ShakeRollRate = fRollSpeed;
	ShakeOffsetRate = vPositionOffset;
	return;
}

function CancelShake()
{
	ShakeRollTime = 0.0000000;
	ShakeRollRate = 0.0000000;
	MaxShakeRoll = 0.0000000;
	m_fShakeReturnTime = 0.0000000;
	ShakeOffsetRate = vect(0.0000000, 0.0000000, 0.0000000);
	m_vNewReturnValue = vect(0.0000000, 0.0000000, 0.0000000);
	return;
}

function ResetPlayerVisualEffects()
{
	ToggleHelmetCameraZoom(true);
	// End:0x35
	if(((m_pawn != none) && m_pawn.m_bActivateNightVision))
	{
		m_pawn.ToggleNightVision();
	}
	CancelShake();
	ResetBlur();
	return;
}

function R6ViewShake(float fDeltaTime, out Rotator rRotationOffset)
{
	local Rotator rOriginalFiringDirection;
	local int iYawDifference;
	local float fJumpByStance, fStanceDeltaTime;

	// End:0x31
	if((ShakeRollTime > float(0)))
	{
		(ShakeRollTime -= fDeltaTime);
		// End:0x31
		if((ShakeRollTime < float(0)))
		{
			ShakeRollTime = 0.0000000;
		}
	}
	// End:0x140
	if(((((MaxShakeRoll != float(0)) && (Abs(float(m_rTotalShake.Pitch)) < MaxShakeRoll)) && (Abs(float(m_rTotalShake.Yaw)) < MaxShakeRoll)) && (Abs(float(m_rTotalShake.Roll)) < MaxShakeRoll)))
	{
		m_rCurrentShakeRotation.Pitch = int(((ShakeRollRate * fDeltaTime) * MaxShakeOffset.X));
		(m_rTotalShake.Pitch += m_rCurrentShakeRotation.Pitch);
		m_rCurrentShakeRotation.Yaw = int(((ShakeRollRate * fDeltaTime) * MaxShakeOffset.Y));
		(m_rTotalShake.Yaw += m_rCurrentShakeRotation.Yaw);
		m_rCurrentShakeRotation.Roll = int(((ShakeRollRate * fDeltaTime) * MaxShakeOffset.Z));
		(m_rTotalShake.Roll += m_rCurrentShakeRotation.Roll);		
	}
	else
	{
		// End:0x3F0
		if((ShakeRollTime != float(0)))
		{
			MaxShakeOffset.X = FRand();
			MaxShakeOffset.Y = FRand();
			MaxShakeOffset.Z = FRand();
			// End:0x1E9
			if((Abs(float(m_rTotalShake.Pitch)) >= MaxShakeRoll))
			{
				// End:0x1CD
				if((m_rTotalShake.Pitch > 0))
				{
					m_rTotalShake.Pitch = int((MaxShakeRoll - float(1)));
					MaxShakeOffset.X = (-MaxShakeOffset.X);					
				}
				else
				{
					m_rTotalShake.Pitch = int(((-MaxShakeRoll) + float(1)));
				}				
			}
			else
			{
				// End:0x20C
				if((FRand() < 0.5000000))
				{
					MaxShakeOffset.X = (-MaxShakeOffset.X);
				}
			}
			// End:0x281
			if((Abs(float(m_rTotalShake.Yaw)) >= MaxShakeRoll))
			{
				// End:0x265
				if((m_rTotalShake.Yaw > 0))
				{
					m_rTotalShake.Yaw = int((MaxShakeRoll - float(1)));
					MaxShakeOffset.Y = (-MaxShakeOffset.Y);					
				}
				else
				{
					m_rTotalShake.Yaw = int(((-MaxShakeRoll) + float(1)));
				}				
			}
			else
			{
				// End:0x2A4
				if((FRand() < 0.5000000))
				{
					MaxShakeOffset.Y = (-MaxShakeOffset.Y);
				}
			}
			// End:0x319
			if((Abs(float(m_rTotalShake.Roll)) >= MaxShakeRoll))
			{
				// End:0x2FD
				if((m_rTotalShake.Roll > 0))
				{
					m_rTotalShake.Roll = int((MaxShakeRoll - float(1)));
					MaxShakeOffset.Z = (-MaxShakeOffset.Z);					
				}
				else
				{
					m_rTotalShake.Roll = int(((-MaxShakeRoll) + float(1)));
				}				
			}
			else
			{
				// End:0x33C
				if((FRand() < 0.5000000))
				{
					MaxShakeOffset.Z = (-MaxShakeOffset.Z);
				}
			}
			m_rCurrentShakeRotation.Pitch = int(((ShakeRollRate * fDeltaTime) * MaxShakeOffset.X));
			(m_rTotalShake.Pitch += m_rCurrentShakeRotation.Pitch);
			m_rCurrentShakeRotation.Yaw = int(((ShakeRollRate * fDeltaTime) * MaxShakeOffset.Y));
			(m_rTotalShake.Yaw += m_rCurrentShakeRotation.Yaw);
			m_rCurrentShakeRotation.Roll = int(((ShakeRollRate * fDeltaTime) * MaxShakeOffset.Z));
			(m_rTotalShake.Roll += m_rCurrentShakeRotation.Roll);			
		}
		else
		{
			// End:0x468
			if((MaxShakeRoll != float(0)))
			{
				MaxShakeRoll = 0.0000000;
				MaxShakeOffset.X = (float((-m_rTotalShake.Pitch)) / m_fShakeReturnTime);
				MaxShakeOffset.Y = (float((-m_rTotalShake.Yaw)) / m_fShakeReturnTime);
				MaxShakeOffset.Z = (float((-m_rTotalShake.Roll)) / m_fShakeReturnTime);
			}
			// End:0x4C0
			if((m_fShakeReturnTime <= float(0)))
			{
				m_rCurrentShakeRotation.Pitch = 0;
				m_rCurrentShakeRotation.Yaw = 0;
				m_rCurrentShakeRotation.Roll = 0;
				m_rTotalShake.Pitch = 0;
				m_rTotalShake.Yaw = 0;
				m_rTotalShake.Roll = 0;				
			}
			else
			{
				(m_fShakeReturnTime -= fDeltaTime);
				m_rCurrentShakeRotation.Pitch = int((fDeltaTime * MaxShakeOffset.X));
				m_rCurrentShakeRotation.Yaw = int((fDeltaTime * MaxShakeOffset.Y));
				m_rCurrentShakeRotation.Roll = int((fDeltaTime * MaxShakeOffset.Z));
			}
		}
	}
	// End:0x816
	if((m_vNewReturnValue != vect(0.0000000, 0.0000000, 0.0000000)))
	{
		// End:0x731
		if((m_rLastBulletDirection != rot(0, 0, 0)))
		{
			fJumpByStance = ((-1.0000000 * m_pawn.m_fWeaponJump) * m_pawn.GetStanceJumpModifier());
			(fJumpByStance *= m_fDesignerJumpFactor);
			m_rCurrentShakeRotation.Pitch = int((fJumpByStance * 50.0000000));
			// End:0x5C9
			if((m_rCurrentShakeRotation.Pitch > -250))
			{
				m_rCurrentShakeRotation.Pitch = -250;
			}
			// End:0x5FD
			if((m_rLastBulletDirection.Yaw < 0))
			{
				m_rCurrentShakeRotation.Yaw = Clamp(m_rLastBulletDirection.Yaw, -1570, -140);				
			}
			else
			{
				m_rCurrentShakeRotation.Yaw = Clamp(m_rLastBulletDirection.Yaw, 140, 1570);
			}
			m_vNewReturnValue.X = float(m_rCurrentShakeRotation.Pitch);
			m_vNewReturnValue.Y = float(m_rCurrentShakeRotation.Yaw);
			// End:0x69F
			if((Abs(m_vNewReturnValue.X) > Abs(m_vNewReturnValue.Y)))
			{
				m_iPitchReturn = m_iReturnSpeed;
				m_iYawReturn = int(((Abs(m_vNewReturnValue.Y) * float(m_iReturnSpeed)) / Abs(m_vNewReturnValue.X)));				
			}
			else
			{
				m_iPitchReturn = int(Abs(((m_vNewReturnValue.X * float(m_iReturnSpeed)) / m_vNewReturnValue.Y)));
				m_iYawReturn = m_iReturnSpeed;
			}
			(m_iPitchReturn *= m_fDesignerSpeedFactor);
			(m_iYawReturn *= m_fDesignerSpeedFactor);
			// End:0x70B
			if((m_vNewReturnValue.Y > float(0)))
			{
				(m_iYawReturn *= float(-1));
			}
			m_rLastBulletDirection = rot(0, 0, 0);
			m_vNewReturnValue.Z = 0.0000000;			
		}
		else
		{
			fStanceDeltaTime = ((m_pawn.GetStanceReticuleModifier() * m_pawn.m_fZoomJumpReturn) * fDeltaTime);
			// End:0x7EB
			if((Abs(m_vNewReturnValue.X) > (float(m_iPitchReturn) * fStanceDeltaTime)))
			{
				(m_vNewReturnValue.X += (float(m_iPitchReturn) * fStanceDeltaTime));
				(m_rCurrentShakeRotation.Pitch += int((float(m_iPitchReturn) * fStanceDeltaTime)));
				(m_vNewReturnValue.Y += (float(m_iYawReturn) * fStanceDeltaTime));
				(m_rCurrentShakeRotation.Yaw += int((float(m_iYawReturn) * fStanceDeltaTime)));				
			}
			else
			{
				(m_rCurrentShakeRotation.Pitch -= int(m_vNewReturnValue.X));
				m_vNewReturnValue = vect(0.0000000, 0.0000000, 0.0000000);
			}
		}
	}
	(rRotationOffset -= m_rCurrentShakeRotation);
	// End:0x85D
	if(((rRotationOffset.Pitch > 16384) && (rRotationOffset.Pitch < 32000)))
	{
		rRotationOffset.Pitch = 16384;
	}
	return;
}

//Force the client to set unlock weapon to false.
simulated function ClientForceUnlockWeapon()
{
	m_bLockWeaponActions = false;
	return;
}

function ResetCameraShake()
{
	m_vNewReturnValue = vect(0.0000000, 0.0000000, 0.0000000);
	return;
}

//R6ClientWeaponShake()
//Function called on client to shake view.
//Only R6WeaponShake() should call R6ClientWeaponShake()
private function R6ClientWeaponShake()
{
	m_vNewReturnValue.Z = 1.0000000;
	return;
}

function R6WeaponShake()
{
	R6ClientWeaponShake();
	return;
}

simulated function R6DamageAttitudeTo(Pawn Other, Actor.eKillResult eKillResultFromTable, Actor.eStunResult eStunFromTable, Vector vBulletMomentum)
{
	// End:0x13D
	if(((int(eKillResultFromTable) != int(3)) && (int(eKillResultFromTable) != int(2))))
	{
		// End:0x65
		if((int(eStunFromTable) == int(0)))
		{
			// End:0x42
			if(bShowLog)
			{
				Log("Hit");
			}
			m_iShakeBlurIntensity = m_stImpactHit.iBlurIntensity;
			m_fBlurReturnTime = m_stImpactHit.fReturnTime;			
		}
		else
		{
			// End:0xAC
			if((int(eStunFromTable) == int(1)))
			{
				// End:0x89
				if(bShowLog)
				{
					Log("Stunned");
				}
				m_iShakeBlurIntensity = m_stImpactStun.iBlurIntensity;
				m_fBlurReturnTime = m_stImpactStun.fReturnTime;				
			}
			else
			{
				// End:0xF1
				if((int(eStunFromTable) == int(2)))
				{
					// End:0xCE
					if(bShowLog)
					{
						Log("Dazed");
					}
					m_iShakeBlurIntensity = m_stImpactDazed.iBlurIntensity;
					m_fBlurReturnTime = m_stImpactDazed.fReturnTime;					
				}
				else
				{
					// End:0x130
					if((int(eStunFromTable) == int(3)))
					{
						// End:0x110
						if(bShowLog)
						{
							Log("KO");
						}
						m_iShakeBlurIntensity = m_stImpactKO.iBlurIntensity;
						m_fBlurReturnTime = m_stImpactKO.fReturnTime;
					}
				}
			}
		}
		m_fTimedBlurValue = float(m_iShakeBlurIntensity);
	}
	return;
}

//------------------------------------------------------------------
// NotifyLanded
//	
//------------------------------------------------------------------
event bool NotifyLanded(Vector HitNormal)
{
	return false;
	return;
}

// make camera fall
function PawnDied()
{
	StopZoom();
	// End:0xAD
	if((Pawn != none))
	{
		// End:0x45
		if(Level.Game.m_bGameStarted)
		{
			Pawn.EngineWeapon.StopFire(true);
		}
		Pawn.RemoteRole = ROLE_SimulatedProxy;
		m_iTeamId = Pawn.m_iTeam;
		m_bPlayDeathMusic = (!m_bPlayDeathMusic);
		// End:0x8D
		if(m_bPlayDeathMusic)
		{
			ClientPlayMusic(m_sndDeathMusic);
		}
		Pawn.m_fRemainingGrenadeTime = 0.0000000;
		ClientFadeCommonSound(5.0000000, 0);
	}
	ClientDisableFirstPersonViewEffects();
	// End:0xE9
	if((!PlayerCanSwitchToAIBackup()))
	{
		// End:0xE9
		if((Pawn != none))
		{
			SetLocation(Pawn.Location);
			Pawn.UnPossessed();
		}
	}
	GotoState('Dead');
	return;
}

function bool PlayerCanSwitchToAIBackup()
{
	// End:0x40
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		// End:0x3E
		if(R6AbstractGameInfo(Level.Game).RainbowOperativesStillAlive())
		{
			return true;			
		}
		else
		{
			return false;
		}
	}
	// End:0x5B
	if((!R6GameReplicationInfo(GameReplicationInfo).m_bAIBkp))
	{
		return false;
	}
	// End:0x68
	if((m_TeamManager == none))
	{
		return false;
	}
	// End:0x7E
	if((m_TeamManager.m_iMemberCount == 0))
	{
		return false;
	}
	return true;
	return;
}

simulated function ClientFadeSound(float fTime, int iVolume, Actor.ESoundSlot eSlot)
{
	// End:0x22
	if((Viewport(Player) != none))
	{
		FadeSound(fTime, iVolume, eSlot);
	}
	return;
}

simulated function ClientFadeCommonSound(float fTime, int iVolume)
{
	// End:0x88
	if((Viewport(Player) != none))
	{
		FadeSound(fTime, iVolume, 1);
		FadeSound(fTime, iVolume, 2);
		FadeSound(fTime, iVolume, 3);
		FadeSound(fTime, iVolume, 4);
		FadeSound(fTime, iVolume, 6);
		FadeSound(fTime, iVolume, 8);
		FadeSound(fTime, iVolume, 10);
		FadeSound(fTime, iVolume, 11);
	}
	return;
}

function SwitchWeapon(byte f)
{
	local R6EngineWeapon NewWeapon;

	// End:0x49
	if(bShowLog)
	{
		Log(((("IN: SwitchWeapon() to " $ string(f)) @ string(m_bLockWeaponActions)) @ string(m_pawn.m_bWeaponTransition)));
	}
	// End:0x56
	if((m_pawn == none))
	{
		return;
	}
	// End:0x1B8
	if((((!m_bLockWeaponActions) && (!m_pawn.m_bPostureTransition)) && (!R6GameReplicationInfo(GameReplicationInfo).m_bGameOverRep)))
	{
		NewWeapon = m_pawn.GetWeaponInGroup(int(f));
		// End:0x1B8
		if(((NewWeapon != none) && (NewWeapon != Pawn.EngineWeapon)))
		{
			// End:0xE9
			if((!NewWeapon.CanSwitchToWeapon()))
			{
				return;
			}
			m_pawn.m_bChangingWeapon = true;
			m_pawn.m_iCurrentWeapon = int(f);
			ToggleHelmetCameraZoom(true);
			// End:0x168
			if(((!(int(Level.NetMode) == int(NM_Standalone))) && (!(int(Level.NetMode) == int(NM_ListenServer)))))
			{
				m_pawn.GetWeapon(R6AbstractWeapon(NewWeapon));
			}
			ServerSwitchWeapon(NewWeapon, f);
			// End:0x1B8
			if(((bBehindView == false) || (int(Level.NetMode) != int(NM_Standalone))))
			{
				Pawn.EngineWeapon.GotoState('DiscardWeapon');
			}
		}
	}
	return;
}

simulated function ServerSwitchWeapon(R6EngineWeapon NewWeapon, byte u8CurrentWeapon)
{
	Pawn.R6MakeNoise(11);
	// End:0x75
	if(bShowLog)
	{
		Log(((("IN: ServerSwitchWeapon() - CurrentWeapon: " $ string(Pawn.EngineWeapon)) $ " - NewWeapon: ") $ string(NewWeapon)));
	}
	m_pawn.m_bChangingWeapon = true;
	m_pawn.GetWeapon(R6AbstractWeapon(NewWeapon));
	m_pawn.m_ePlayerIsUsingHands = 0;
	m_pawn.PlayWeaponAnimation();
	m_pawn.m_iCurrentWeapon = int(u8CurrentWeapon);
	// End:0x10D
	if((m_pawn.m_SoundRepInfo != none))
	{
		m_pawn.m_SoundRepInfo.m_CurrentWeapon = byte((int(u8CurrentWeapon) - 1));
	}
	return;
}

function WeaponUpState()
{
	// End:0x4E
	if(bShowLog)
	{
		Log(((("IN: WeaponUpState() : " $ string(Pawn.EngineWeapon)) $ " : ") $ string(Pawn.PendingWeapon)));
	}
	// End:0x64
	if((Pawn.PendingWeapon == none))
	{
		return;
	}
	Pawn.PendingWeapon.m_bPawnIsWalking = Pawn.EngineWeapon.m_bPawnIsWalking;
	Pawn.EngineWeapon = Pawn.PendingWeapon;
	// End:0xEA
	if(Pawn.EngineWeapon.IsInState('RaiseWeapon'))
	{
		Pawn.EngineWeapon.BeginState();		
	}
	else
	{
		Pawn.EngineWeapon.GotoState('RaiseWeapon');
	}
	// End:0x12A
	if(bShowLog)
	{
		Log("OUT: ClientWeaponUpState()");
	}
	return;
}

function ServerWeaponUpAnimDone()
{
	// End:0x0D
	if((m_pawn == none))
	{
		return;
	}
	// End:0x30
	if(m_pawn.m_bUsingBipod)
	{
		m_pawn.m_ePlayerIsUsingHands = 3;
	}
	m_pawn.m_bChangingWeapon = false;
	return;
}

simulated function bool TeamMemberHasGrenadeType(R6EngineWeapon.eWeaponGrenadeType grenadeType)
{
	return (m_TeamManager.FindRainbowWithGrenadeType(grenadeType, true) != none);
	return;
}

///////////////////////////////////////////////////////////////////////////////
// SetRequestedCircumstantialAction()
// rbrek 22 jan 2002 
//   Set the current object being pointed to as the requested one so that even 
//    if player immediately changes focus, the correct action is done. 
///////////////////////////////////////////////////////////////////////////////
function SetRequestedCircumstantialAction()
{
	m_RequestedCircumstantialAction = m_CurrentCircumstantialAction;
	m_vRequestedLocation = m_vDefaultLocation;
	return;
}

function bool CanIssueTeamOrder()
{
	// End:0x4B
	if(((((m_TeamManager == none) || (m_TeamManager.m_iMemberCount <= 1)) || m_TeamManager.m_bTeamIsClimbingLadder) || Level.m_bInGamePlanningActive))
	{
		return false;
	}
	return true;
	return;
}

///////////////////////////////////////////////////////////////////////////////
// DEFAULT CIRCUMSTANTIAL ACTIONS
// R6QueryCircumstantialAction()
///////////////////////////////////////////////////////////////////////////////
event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	local bool bIsOpen;

	Query.iHasAction = 1;
	// End:0xB1
	if(bOnlySpectator)
	{
		Query.iInRange = 1;
		Query.textureIcon = Texture'R6ActionIcons.Spectator';
		Query.iPlayerActionID = 0;
		Query.iTeamActionID = 0;
		Query.iTeamActionIDList[0] = 0;
		Query.iTeamActionIDList[1] = 0;
		Query.iTeamActionIDList[2] = 0;
		Query.iTeamActionIDList[3] = 0;
		return;
	}
	// End:0xF0
	if((((m_TeamManager == none) || (m_TeamManager.m_iMemberCount <= 1)) || m_bPreventTeamMemberUse))
	{
		Query.iHasAction = 0;
		return;
	}
	// End:0x127
	if((fDistance < m_fCircumstantialActionRange))
	{
		Query.iInRange = 1;
		Query.textureIcon = Texture'R6ActionIcons.RegroupOnMe';		
	}
	else
	{
		Query.iInRange = 0;
		Query.textureIcon = Texture'R6ActionIcons.TeamMoveTo';
	}
	Query.iPlayerActionID = 1;
	Query.iTeamActionID = 2;
	Query.iTeamActionIDList[0] = 2;
	Query.iTeamActionIDList[1] = 3;
	Query.iTeamActionIDList[2] = 0;
	Query.iTeamActionIDList[3] = 0;
	R6FillSubAction(Query, 0, int(0));
	R6FillGrenadeSubAction(Query, 1);
	R6FillSubAction(Query, 2, int(0));
	R6FillSubAction(Query, 3, int(0));
	return;
}

function R6FillGrenadeSubAction(out R6AbstractCircumstantialActionQuery Query, int iSubMenu)
{
	local int i, j;

	// End:0x37
	if(R6ActionCanBeExecuted(int(4), self))
	{
		Query.iTeamSubActionsIDList[((iSubMenu * 4) + i)] = 4;
		(i++);
	}
	// End:0x6E
	if(R6ActionCanBeExecuted(int(5), self))
	{
		Query.iTeamSubActionsIDList[((iSubMenu * 4) + i)] = 5;
		(i++);
	}
	// End:0xA5
	if(R6ActionCanBeExecuted(int(6), self))
	{
		Query.iTeamSubActionsIDList[((iSubMenu * 4) + i)] = 6;
		(i++);
	}
	// End:0xDC
	if(R6ActionCanBeExecuted(int(7), self))
	{
		Query.iTeamSubActionsIDList[((iSubMenu * 4) + i)] = 7;
		(i++);
	}
	j = i;
	J0xE7:

	// End:0x11F [Loop If]
	if((j < 4))
	{
		Query.iTeamSubActionsIDList[((iSubMenu * 4) + j)] = 0;
		(j++);
		// [Loop Continue]
		goto J0xE7;
	}
	return;
}

simulated function bool R6ActionCanBeExecuted(int iAction, PlayerController PlayerController)
{
	// End:0x10
	if((iAction == int(0)))
	{
		return false;
	}
	switch(iAction)
	{
		// End:0x33
		case int(4):
			return m_TeamManager.HaveRainbowWithGrenadeType(1);
			// End:0x8A
			break;
		// End:0x4F
		case int(5):
			return m_TeamManager.HaveRainbowWithGrenadeType(2);
			// End:0x8A
			break;
		// End:0x6B
		case int(6):
			return m_TeamManager.HaveRainbowWithGrenadeType(3);
			// End:0x8A
			break;
		// End:0x87
		case int(7):
			return m_TeamManager.HaveRainbowWithGrenadeType(4);
			// End:0x8A
			break;
		// End:0xFFFF
		default:
			break;
	}
	return true;
	return;
}

///////////////////////////////////////////////////////////////////////////////
// DEFAULT CIRCUMSTANTIAL ACTIONS
// R6GetCircumstantialActionString()
///////////////////////////////////////////////////////////////////////////////
simulated function string R6GetCircumstantialActionString(int iAction)
{
	switch(iAction)
	{
		// End:0x36
		case int(1):
			return Localize("RDVOrder", "Order_Regroup", "R6Menu");
		// End:0x68
		case int(2):
			return Localize("RDVOrder", "Order_TeamMoveTo", "R6Menu");
		// End:0x9B
		case int(3):
			return Localize("RDVOrder", "Order_MoveGrenade", "R6Menu");
		// End:0xCE
		case int(4):
			return Localize("RDVOrder", "Order_FragGrenade", "R6Menu");
		// End:0x100
		case int(5):
			return Localize("RDVOrder", "Order_GasGrenade", "R6Menu");
		// End:0x134
		case int(6):
			return Localize("RDVOrder", "Order_FlashGrenade", "R6Menu");
		// End:0x168
		case int(7):
			return Localize("RDVOrder", "Order_SmokeGrenade", "R6Menu");
		// End:0xFFFF
		default:
			return "";
			break;
	}
	return;
}

function DoDbgLogActor(Actor anActor)
{
	// End:0x3C
	if((R6Pawn(anActor) != none))
	{
		// End:0x39
		if((CheatManager != none))
		{
			R6CheatManager(CheatManager).LogR6Pawn(R6Pawn(anActor));
		}		
	}
	else
	{
		anActor.dbgLogActor(false);
	}
	// End:0x70
	if((int(Level.NetMode) == int(NM_Client)))
	{
		ServerDbgLogActor(anActor);
	}
	return;
}

function ServerDbgLogActor(Actor anActor)
{
	local R6Pawn P;

	P = R6Pawn(anActor);
	// End:0x7C
	if((P != none))
	{
		// End:0x79
		if((CheatManager != none))
		{
			// End:0x60
			if((int(P.m_ePawnType) == int(2)))
			{
				R6CheatManager(CheatManager).LogTerro(R6Terrorist(P));				
			}
			else
			{
				R6CheatManager(CheatManager).LogR6Pawn(P);
			}
		}		
	}
	else
	{
		anActor.dbgLogActor(false);
	}
	return;
}

exec function LogPawn()
{
	DoLogPawn();
	// End:0x25
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		ServerLogPawn();
	}
	return;
}

function DoLogPawn()
{
	// End:0x24
	if((CheatManager != none))
	{
		R6CheatManager(CheatManager).LogR6Pawn(m_pawn);
	}
	return;
}

function ServerLogPawn()
{
	DoLogPawn();
	return;
}

function DoLogActors()
{
	local Actor ActorIterator;

	Log("--- Actor List Begin ---");
	// End:0x41
	foreach AllActors(Class'Engine.Actor', ActorIterator)
	{
		Log((" Actor:" @ string(ActorIterator)));		
	}	
	Log("--- Actor List End ---");
	return;
}

function ServerLogActors()
{
	DoLogActors();
	return;
}

function PossessInit(Pawn aPawn)
{
	SetRotation(aPawn.Rotation);
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	m_pawn = R6Rainbow(Pawn);
	m_pawn.SetFriendlyFire();
	// End:0x93
	if(((int(Level.NetMode) != int(NM_Standalone)) && (int(Level.NetMode) != int(NM_ListenServer))))
	{
		Pawn.RemoteRole = ROLE_AutonomousProxy;		
	}
	else
	{
		Pawn.RemoteRole = RemoteRole;
	}
	return;
}

function Possess(Pawn aPawn)
{
	// End:0x0B
	if(bOnlySpectator)
	{
		return;
	}
	PossessInit(aPawn);
	Pawn.bStasis = false;
	Restart();
	return;
}

function UnPossess()
{
	super.UnPossess();
	m_pawn = none;
	return;
}

function ServerBroadcast(PlayerController Sender, coerce string Msg, optional name type)
{
	Level.Game.BroadcastTeam(Sender, Msg, type);
	return;
}

function ServerMove(float TimeStamp, Vector InAccel, Vector ClientLoc, bool NewbRun, bool NewbDuck, bool NewbCrawl, int View, int iNewRotOffset, optional byte OldTimeDelta, optional int OldAccel)
{
	super.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbCrawl, View, iNewRotOffset, OldTimeDelta, OldAccel);
	return;
}

function ServerPlayerPref(PlayerPrefInfo newPlayerPrefs)
{
	m_PlayerPrefs = newPlayerPrefs;
	PawnClass = Class<Pawn>(DynamicLoadObject(m_PlayerPrefs.m_ArmorName, Class'Core.Class'));
	return;
}

function ServerNetLogActor(Actor InActor)
{
	InActor.m_bLogNetTraffic = true;
	return;
}

function ServerLogBandWidth(bool bLogBandWidth)
{
	Level.m_bLogBandWidth = bLogBandWidth;
	return;
}

function ServerSetPlayerReadyStatus(bool _bPlayerReady)
{
	PlayerReplicationInfo.m_bPlayerReady = _bPlayerReady;
	return;
}

function PlaySoundAffectedByGrenade(Pawn.EGrenadeType eType)
{
	switch(eType)
	{
		// End:0x25
		case 2:
			m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, 4);
			// End:0x46
			break;
		// End:0x43
		case 1:
			m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, 3);
			// End:0x46
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

event ClientPlayVoices(R6SoundReplicationInfo aAudioRepInfo, Sound sndPlayVoice, Actor.ESoundSlot eSlotUse, int iPriority, optional bool bWaitToFinishSound, optional float fTime)
{
	// End:0x31
	if((((aAudioRepInfo == none) && (int(eSlotUse) != int(8))) && (int(eSlotUse) != int(7))))
	{
		return;
	}
	// End:0x84
	if(((aAudioRepInfo != none) && (aAudioRepInfo.m_pawnOwner != none)))
	{
		aAudioRepInfo.m_pawnOwner.SetAudioInfo();
		aAudioRepInfo.m_pawnOwner.m_fLastCommunicationTime = 5.0000000;
	}
	PlayVoicesPriority(aAudioRepInfo, sndPlayVoice, eSlotUse, iPriority, bWaitToFinishSound, fTime);
	return;
}

function PlaySoundActionCompleted(R6Pawn.eDeviceAnimToPlay eAnimToPlay)
{
	// End:0xE6
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		switch(eAnimToPlay)
		{
			// End:0x47
			case 2:
				m_TeamManager.m_MultiCoopPlayerVoicesMgr.PlayRainbowTeamVoices(m_pawn, 9);
				// End:0xE6
				break;
			// End:0x6E
			case 3:
				m_TeamManager.m_MultiCoopPlayerVoicesMgr.PlayRainbowTeamVoices(m_pawn, 1);
				// End:0xE6
				break;
			// End:0x95
			case 4:
				m_TeamManager.m_MultiCoopPlayerVoicesMgr.PlayRainbowTeamVoices(m_pawn, 3);
				// End:0xE6
				break;
			// End:0xBC
			case 0:
				m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(m_pawn, 5);
				// End:0xE6
				break;
			// End:0xE3
			case 1:
				m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(m_pawn, 7);
				// End:0xE6
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

function PlaySoundInflictedDamage(Pawn DeadPawn)
{
	switch(R6Pawn(DeadPawn).m_ePawnType)
	{
		// End:0x33
		case 2:
			m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, 0);
			// End:0x7C
			break;
		// End:0x79
		case 3:
			// End:0x76
			if((m_TeamManager.m_iMemberCount > 1))
			{
				m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_TeamManager.m_Team[1], 25);
			}
			// End:0x7C
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function PlaySoundCurrentAction(Pawn.ERainbowTeamVoices eVoices)
{
	// End:0x8D
	if((int(Role) == int(ROLE_Authority)))
	{
		// End:0x5E
		if(Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
		{
			m_TeamManager.m_MultiCoopPlayerVoicesMgr.PlayRainbowTeamVoices(m_pawn, eVoices);			
		}
		else
		{
			// End:0x8D
			if((int(eVoices) == int(5)))
			{
				m_TeamManager.m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_pawn, 41);
			}
		}
	}
	return;
}

function PlaySoundDamage(Pawn instigatedBy)
{
	m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, 1);
	switch(m_pawn.m_eHealth)
	{
		// End:0x2B
		case 2:
		// End:0x9D
		case 3:
			m_CommonPlayerVoicesMgr.PlayCommonRainbowVoices(m_pawn, 2);
			// End:0x9A
			if(((m_TeamManager.m_iMemberCount > 0) && (m_TeamManager.m_MemberVoicesMgr != none)))
			{
				m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_TeamManager.m_Team[0], 13);
			}
			// End:0xA0
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

// Basic Command
exec function MapList()
{
	local R6GameReplicationInfo _GRI;
	local int iIterator;
	local string szMapId, szMapName, szLocGameType, szGameType, szMapLoc;

	_GRI = R6GameReplicationInfo(GameReplicationInfo);
	szMapId = Localize("Game", "MapId", "R6GameInfo");
	szMapName = Localize("Game", "MapName", "R6GameInfo");
	szLocGameType = Localize("Game", "GameType", "R6GameInfo");
	iIterator = 0;
	J0x8B:

	// End:0x1A3 [Loop If]
	if(((iIterator < _GRI.32) && (_GRI.m_mapArray[iIterator] != "")))
	{
		szGameType = _GRI.Level.GetGameTypeFromClassName(_GRI.m_gameModeArray[iIterator]);
		szMapLoc = _GRI.Level.GetCampaignNameFromParam(_GRI.m_mapArray[iIterator]);
		Class'Engine.Actor'.static.AddMessageToConsole(((((((((((szMapId $ ": ") $ string((iIterator + 1))) $ " ") $ szMapName) $ ": ") $ szMapLoc) $ " ") $ szLocGameType) $ ": ") $ _GRI.Level.GetGameNameLocalization(szGameType)), myHUD.m_ServerMessagesColor);
		(iIterator++);
		// [Loop Continue]
		goto J0x8B;
	}
	return;
}

// Admin Command
exec function Map(int iGotoMapId, string explanation)
{
	local R6GameReplicationInfo _GRI;
	local string szMapLoc;

	(iGotoMapId--);
	_GRI = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x94
	if((((iGotoMapId >= _GRI.32) || (iGotoMapId < 0)) || (_GRI.m_mapArray[iGotoMapId] == "")))
	{
		Class'Engine.Actor'.static.AddMessageToConsole(Localize("Game", "BadMapId", "R6GameInfo"), myHUD.m_ServerMessagesColor);
		return;
	}
	szMapLoc = _GRI.Level.GetCampaignNameFromParam(_GRI.m_mapArray[iGotoMapId]);
	Class'Engine.Actor'.static.AddMessageToConsole(((Localize("Game", "RequestingMap", "R6GameInfo") $ ": ") $ szMapLoc), myHUD.m_ServerMessagesColor);
	ServerMap(iGotoMapId, explanation);
	return;
}

function ServerMap(int iGotoMapId, string explanation)
{
	local R6GameReplicationInfo _GRI;
	local R6PlayerController _playerController;
	local string _mapName, _PlayerName;

	_GRI = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x3C
	if(((CheckAuthority(1) == false) || (iGotoMapId >= _GRI.32)))
	{
		ClientNoAuthority();
		return;
	}
	_mapName = _GRI.Level.GetCampaignNameFromParam(_GRI.m_mapArray[iGotoMapId]);
	_PlayerName = PlayerReplicationInfo.PlayerName;
	// End:0xAE
	foreach AllActors(Class'R6Engine.R6PlayerController', _playerController)
	{
		_playerController.ClientServerMap(_PlayerName, _mapName, explanation);		
	}	
	R6AbstractGameInfo(Level.Game).EndGameAndJumpToMapID(iGotoMapId);
	return;
}

// NEW IN 1.60
exec function VoteNextMap()
{
	ProcessVoteNextRequest();
	return;
}

// NEW IN 1.60
simulated function ProcessVoteNextRequest()
{
	// End:0x3C
	if(((int(Level.NetMode) == int(NM_Client)) || (int(Level.NetMode) == int(NM_Standalone))))
	{
		ClientNoAuthority();
		return;
	}
	// End:0xE0
	if(((m_fLastVoteTime > float(0)) && (Level.TimeSeconds < (m_fLastVoteTime + float(300)))))
	{
		// End:0xD8
		if(bShowLog)
		{
			Log(((("Next possible NextMap request time is " $ string((m_fLastVoteTime + float(300)))) $ " current time is ") $ string(Level.TimeSeconds)));
		}
		ClientCantRequestChangeMapYet();
		return;
	}
	// End:0x11A
	if((R6AbstractGameInfo(Level.Game).ProcessChangeMapVote(PlayerReplicationInfo.PlayerName) == false))
	{
		ClientVoteInProgress();		
	}
	else
	{
		m_fLastVoteTime = Level.TimeSeconds;
	}
	return;
}

// Basic Command
exec function PlayerList()
{
	local PlayerReplicationInfo _PRI;
	local string szID, szName;

	szID = Localize("Game", "Id", "R6GameInfo");
	szName = Localize("Game", "Name", "R6GameInfo");
	// End:0xB0
	foreach AllActors(Class'Engine.PlayerReplicationInfo', _PRI)
	{
		Class'Engine.Actor'.static.AddMessageToConsole(((((((szID $ ": ") $ string(_PRI.PlayerID)) $ " ") $ szName) $ ": ") $ _PRI.PlayerName), myHUD.m_ServerMessagesColor);		
	}	
	return;
}

// this function is sent and executed directly to the server.
// Basic Command
exec function VoteKick(string szKickName)
{
	ProcessVoteKickRequest(R6PlayerController(FindPlayer(szKickName, false)));
	return;
}

exec function VoteKickID(string szKickName)
{
	ProcessVoteKickRequest(R6PlayerController(FindPlayer(szKickName, true)));
	return;
}

simulated function ProcessVoteKickRequest(R6PlayerController _playerController)
{
	// End:0x3C
	if(((int(Level.NetMode) == int(NM_Client)) || (int(Level.NetMode) == int(NM_Standalone))))
	{
		ClientNoAuthority();
		return;
	}
	// End:0xE1
	if(((m_fLastVoteTime > float(0)) && (Level.TimeSeconds < (m_fLastVoteTime + float(300)))))
	{
		// End:0xD9
		if(bShowLog)
		{
			Log(((("Next possible votekick request time is " $ string((m_fLastVoteTime + float(300)))) $ " current time is ") $ string(Level.TimeSeconds)));
		}
		ClientCantRequestKickYet();
		return;
	}
	// End:0x134
	if(bShowLog)
	{
		Log(((("<<KICK>> " $ string(self)) $ ": calling StartVoteKick on ") $ _playerController.PlayerReplicationInfo.PlayerName));
	}
	// End:0x1D4
	if((_playerController != none))
	{
		// End:0x160
		if((Viewport(_playerController.Player) != none))
		{
			ClientNoAuthority();
			return;
		}
		// End:0x17E
		if((_playerController.CheckAuthority(1) == true))
		{
			ClientNoKickAdmin();
			return;
		}
		// End:0x1BD
		if((R6AbstractGameInfo(Level.Game).ProcessKickVote(_playerController, PlayerReplicationInfo.PlayerName) == false))
		{
			ClientVoteInProgress();			
		}
		else
		{
			m_fLastVoteTime = Level.TimeSeconds;
		}		
	}
	else
	{
		ClientKickBadId();
	}
	return;
}

// Basic Command
exec function Vote(int _bVoteResult)
{
	local Controller _itController;
	local R6PlayerController _playerController;
	local string _PlayerNameOne, _PlayerNameTwo;
	local int _iForKickVotes, _iAgainstKickVotes, _iTotalPlayers;
	local R6ServerInfo pServerInfo;
	local bool _VoteSpamCheckOk;

	// End:0x26
	if((R6AbstractGameInfo(Level.Game).m_fEndVoteTime == float(0)))
	{
		return;
	}
	// End:0x41
	if(((_bVoteResult <= 0) || (_bVoteResult >= 3)))
	{
		return;
	}
	// End:0x27F
	if(bShowLog)
	{
		switch(_bVoteResult)
		{
			// End:0xF1
			case 1:
				// End:0x9F
				if((R6AbstractGameInfo(Level.Game).m_PlayerKick == none))
				{
					Log((string(self) $ " set vote yes to change Map "));					
				}
				else
				{
					Log(((string(self) $ " set vote yes to kick ") $ R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName));
				}
				// End:0x27F
				break;
			// End:0x190
			case 2:
				// End:0x13F
				if((R6AbstractGameInfo(Level.Game).m_PlayerKick == none))
				{
					Log((string(self) $ " set vote no to change Map "));					
				}
				else
				{
					Log(((string(self) $ " set vote no to kick ") $ R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName));
				}
				// End:0x27F
				break;
			// End:0xFFFF
			default:
				// End:0x205
				if((R6AbstractGameInfo(Level.Game).m_PlayerKick == none))
				{
					Log((((string(self) $ " how did we get here? Set invalid  vote ") $ string(_bVoteResult)) $ " to change Map "));					
				}
				else
				{
					Log(((((string(self) $ " how did we get here? Set invalid  vote ") $ string(_bVoteResult)) $ " to kick ") $ R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName));
				}
				// End:0x27F
				break;
				break;
		}
	}
	m_iVoteResult = _bVoteResult;
	pServerInfo = Class'Engine.Actor'.static.GetServerOptions();
	_PlayerNameOne = PlayerReplicationInfo.PlayerName;
	_PlayerNameTwo = R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName;
	_VoteSpamCheckOk = ((m_fLastVoteEmoteTimeStamp + pServerInfo.VoteBroadcastMaxFrequency) <= Level.TimeSeconds);
	_itController = Level.ControllerList;
	J0x324:

	// End:0x3BF [Loop If]
	if((_itController != none))
	{
		_playerController = R6PlayerController(_itController);
		// End:0x3A8
		if((_playerController != none))
		{
			(_iTotalPlayers++);
			switch(_playerController.m_iVoteResult)
			{
				// End:0x36F
				case 1:
					(_iForKickVotes++);
					// End:0x381
					break;
				// End:0x37E
				case 2:
					(_iAgainstKickVotes++);
					// End:0x381
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x3A8
			if(_VoteSpamCheckOk)
			{
				_playerController.ClientPlayerVoteMessage(_PlayerNameOne, m_iVoteResult, _PlayerNameTwo);
			}
		}
		_itController = _itController.nextController;
		// [Loop Continue]
		goto J0x324;
	}
	// End:0x3DF
	if(_VoteSpamCheckOk)
	{
		m_fLastVoteEmoteTimeStamp = Level.TimeSeconds;		
	}
	else
	{
		ClientPlayerVoteMessage(_PlayerNameOne, m_iVoteResult, _PlayerNameTwo);
	}
	// End:0x453
	if(((float(_iAgainstKickVotes) >= (float(_iTotalPlayers) / float(2))) || (float(_iForKickVotes) > (float(_iTotalPlayers) / float(2)))))
	{
		R6AbstractGameInfo(Level.Game).m_fEndVoteTime = Level.TimeSeconds;
	}
	return;
}

// allows the client to exit gracefully
function ClientBanned()
{
	Player.Console.R6ConnectionFailed("BannedIP");
	return;
}

function ClientKickedOut()
{
	Player.Console.R6ConnectionFailed("YouWereKicked");
	return;
}

function AutoAdminLogin(string _Password)
{
	// End:0x57
	if(((Viewport(Player) != none) || (Level.m_ServerSettings.UseAdminPassword && (_Password == Level.m_ServerSettings.AdminPassword))))
	{
		m_iAdmin = 1;
	}
	return;
}

exec function AdminLogin(string _Password)
{
	m_szLastAdminPassword = _Password;
	SaveConfig();
	ServerAdminLogin(_Password);
	return;
}

function ServerAdminLogin(string _Password)
{
	// End:0x9C
	if(((Viewport(Player) != none) || (Level.m_ServerSettings.UseAdminPassword && (_Password == Level.m_ServerSettings.AdminPassword))))
	{
		m_iAdmin = 1;
		ClientAdminLogin(true);
		// End:0x99
		if(bShowLog)
		{
			Log((PlayerReplicationInfo.PlayerName $ " logged in as an Administrator"));
		}		
	}
	else
	{
		ClientAdminLogin(false);
	}
	return;
}

function ClientAdminLogin(bool _loginRes)
{
	// End:0x67
	if((_loginRes == true))
	{
		m_iAdmin = 1;
		Player.InteractionMaster.Process_Message(Localize("Game", "AdminSuccess", "R6GameInfo"), 7.0000000, Player.LocalInteractions);		
	}
	else
	{
		m_iAdmin = 0;
		Player.InteractionMaster.Process_Message(Localize("Game", "AdminFailure", "R6GameInfo"), 7.0000000, Player.LocalInteractions);
	}
	return;
}

// Admin Command
exec function LockServer(bool _bFlagSetting, optional string _NewPassword)
{
	// End:0x6B
	if((Console(Player.Console).m_bStartedByGSClient == true))
	{
		Player.Console.Message(Localize("Errors", "DisabledCommand", "R6Engine"), 6.0000000);
		return;
	}
	// End:0x80
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	// End:0x96
	if((Len(_NewPassword) > 16))
	{
		ClientPasswordTooLong();
		return;
	}
	// End:0xE1
	if((_bFlagSetting == true))
	{
		// End:0xB9
		if((_NewPassword == ""))
		{
			ClientPasswordMessage(1);			
		}
		else
		{
			ClientPasswordMessage(2);
			Level.Game.SetGamePassword(_NewPassword);
		}		
	}
	else
	{
		ClientPasswordMessage(3);
		Level.Game.SetGamePassword("");
	}
	return;
}

function ClientPasswordMessage(R6PlayerController.eGamePasswordRes iMessageType)
{
	switch(iMessageType)
	{
		// End:0x4D
		case 1:
			AddMessageToConsole(Localize("Game", "GamePasswordMissing", "R6GameInfo"), myHUD.m_ServerMessagesColor);
			// End:0xD8
			break;
		// End:0x8F
		case 2:
			AddMessageToConsole(Localize("Game", "GamePasswordSet", "R6GameInfo"), myHUD.m_ServerMessagesColor);
			// End:0xD8
			break;
		// End:0xD5
		case 3:
			AddMessageToConsole(Localize("Game", "GamePasswordCleared", "R6GameInfo"), myHUD.m_ServerMessagesColor);
			// End:0xD8
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

exec function NewPassword(string _NewPassword)
{
	local R6PlayerController _playerController;
	local string _PlayerName;

	// End:0x15
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	// End:0x2B
	if((Len(_NewPassword) > 16))
	{
		ClientPasswordTooLong();
		return;
	}
	Level.m_ServerSettings.AdminPassword = _NewPassword;
	Level.m_ServerSettings.SaveConfig();
	_PlayerName = PlayerReplicationInfo.PlayerName;
	// End:0xA1
	if(bShowLog)
	{
		Log(((_PlayerName $ " changed password to ") $ _NewPassword));
	}
	// End:0xC6
	foreach AllActors(Class'R6Engine.R6PlayerController', _playerController)
	{
		_playerController.ClientNewPassword(_PlayerName);		
	}	
	return;
}

function bool CheckAuthority(int _LevelNeeded)
{
	// End:0x1B
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		return false;
	}
	return ((m_iAdmin >= _LevelNeeded) || ((int(Level.NetMode) == int(NM_ListenServer)) && (Viewport(Player) != none)));
	return;
}

// this is executed on the server
// Admin Command
exec function Kick(string szKickName)
{
	ProcessKickRequest(R6PlayerController(FindPlayer(szKickName, false)));
	return;
}

exec function KickId(string szKickName)
{
	ProcessKickRequest(R6PlayerController(FindPlayer(szKickName, true)));
	return;
}

exec function Ban(string szKickName)
{
	local R6PlayerController PC;

	PC = R6PlayerController(FindPlayer(szKickName, false));
	ProcessKickRequest(PC, true);
	return;
}

exec function BanId(string szKickName)
{
	local R6PlayerController PC;

	PC = R6PlayerController(FindPlayer(szKickName, true));
	ProcessKickRequest(PC, true);
	return;
}

function ClientNoBanMatches()
{
	local int iPos;

	AddMessageToConsole(Localize("Game", "NoBanMatchFound", "R6GameInfo"), myHUD.m_ServerMessagesColor);
	iPos = 0;
	J0x41:

	// End:0x6A [Loop If]
	if((iPos < 10))
	{
		m_BanPage.szBanID[iPos] = "";
		(iPos++);
		// [Loop Continue]
		goto J0x41;
	}
	m_iBanPage = 0;
	m_szBanSearch = "";
	return;
}

function ClientPlayerUnbanned()
{
	AddMessageToConsole(Localize("Game", "PlayerUnBanned", "R6GameInfo"), myHUD.m_ServerMessagesColor);
	return;
}

//#ifdef R6PUNKBUSTER
function ClientPBVersionMismatch()
{
	AddMessageToConsole(Localize("Game", "PBVersionMismatch", "R6GameInfo"), myHUD.m_ServerMessagesColor);
	return;
}

function ClientBanMatches(STBanPage banPage, string _BanPrefix)
{
	local int iPos;

	m_BanPage = banPage;
	m_szBanSearch = _BanPrefix;
	iPos = 0;
	J0x1D:

	// End:0x7D [Loop If]
	if((iPos < 10))
	{
		// End:0x43
		if((m_BanPage.szBanID[iPos] == ""))
		{
			// [Explicit Break]
			goto J0x7D;
		}
		AddMessageToConsole(((string(iPos) $ "> ") $ m_BanPage.szBanID[iPos]), myHUD.m_ServerMessagesColor);
		(iPos++);
		// [Loop Continue]
		goto J0x1D;
	}
	J0x7D:

	(m_iBanPage++);
	return;
}

exec function UnBanPos(int iPosition)
{
	local int iPos;

	// End:0x15
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	// End:0x66
	if((m_BanPage.szBanID[iPosition] == ""))
	{
		AddMessageToConsole(Localize("Game", "NoBannedInPos", "R6GameInfo"), myHUD.m_ServerMessagesColor);
		return;
	}
	UnBan(m_BanPage.szBanID[iPosition]);
	iPos = 0;
	J0x83:

	// End:0xAC [Loop If]
	if((iPos < 10))
	{
		m_BanPage.szBanID[iPos] = "";
		(iPos++);
		// [Loop Continue]
		goto J0x83;
	}
	m_iBanPage = 0;
	m_szBanSearch = "";
	return;
}

exec function BanList(string szPrefixBanID)
{
	// End:0x15
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	m_iBanPage = 0;
	m_szBanSearch = szPrefixBanID;
	ServerBanList(m_iBanPage, szPrefixBanID);
	return;
}

exec function NextBanList()
{
	// End:0x15
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	// End:0x5A
	if((m_iBanPage == 0))
	{
		AddMessageToConsole(Localize("Game", "BanListFirst", "R6GameInfo"), myHUD.m_ServerMessagesColor);		
	}
	else
	{
		ServerBanList(m_iBanPage, m_szBanSearch);
	}
	return;
}

function ServerBanList(int _iPageNumber, string szPrefixBanID)
{
	local int i, iMatchesFound, iPosFound;
	local STBanPage banPage;

	// End:0x15
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	i = -1;
	J0x20:

	// End:0xBA [Loop If]
	if((_iPageNumber > 0))
	{
		iMatchesFound = 0;
		J0x32:

		(i++);
		i = Level.Game.AccessControl.NextMatchingID(szPrefixBanID, i);
		// End:0x7C
		if((i >= 0))
		{
			(iMatchesFound++);
		}
		// End:0x32
		if(!(((iMatchesFound == 10) || (i == -1))))
			goto J0x32;
		// End:0xB0
		if((i == -1))
		{
			ClientNoBanMatches();
			return;
		}
		(_iPageNumber--);
		// [Loop Continue]
		goto J0x20;
	}
	iMatchesFound = 0;
	J0xC1:

	(i++);
	i = Level.Game.AccessControl.NextMatchingID(szPrefixBanID, i);
	// End:0x13D
	if((i >= 0))
	{
		banPage.szBanID[(iMatchesFound++)] = Level.Game.AccessControl.Banned[i];
	}
	// End:0xC1
	if(!(((iMatchesFound == 10) || (i == -1))))
		goto J0xC1;
	// End:0x178
	if((iMatchesFound > 0))
	{
		ClientBanMatches(banPage, szPrefixBanID);		
	}
	else
	{
		ClientNoBanMatches();
	}
	return;
}

//client to server
exec function UnBan(string szPrefixBanID)
{
	local int _iMatchesFound;

	// End:0x15
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	_iMatchesFound = Level.Game.AccessControl.RemoveBan(szPrefixBanID);
	// End:0x55
	if((_iMatchesFound == 0))
	{
		ClientNoBanMatches();		
	}
	else
	{
		// End:0x69
		if((_iMatchesFound == 1))
		{
			ClientPlayerUnbanned();			
		}
		else
		{
			BanList(szPrefixBanID);
		}
	}
	return;
}

exec function Admin(string CommandLine)
{
	local string Result;

	// End:0x55
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		Log((((("Admin command <<" $ CommandLine) $ ">> issued by:") $ GetPlayerNetworkAddress()) $ " ignored"));
		return;
	}
	Result = ConsoleCommand(CommandLine);
	Log((((("Admin command <<" $ CommandLine) $ ">> issued by:") $ GetPlayerNetworkAddress()) $ " accepted"));
	// End:0xE8
	if((Result != ""))
	{
		Log((("Admin command returned <<" $ Result) $ ">>"));
		ClientMessage(Result);
	}
	return;
}

simulated function ProcessKickRequest(R6PlayerController _playerController, optional bool bBan)
{
	local R6PlayerController _pcIterator;
	local string _AdminName, _KickeeName;

	// End:0x15
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	// End:0x28
	if((_playerController == none))
	{
		ClientKickBadId();
		return;
	}
	// End:0x61
	if(((Viewport(_playerController.Player) != none) || (_playerController.CheckAuthority(1) == true)))
	{
		ClientNoKickAdmin();
		return;
	}
	// End:0xBF
	if(bShowLog)
	{
		Log((((("<AdminKick> " $ PlayerReplicationInfo.PlayerName) $ " kicked ") $ _playerController.PlayerReplicationInfo.PlayerName) $ " from server"));
	}
	_AdminName = PlayerReplicationInfo.PlayerName;
	_KickeeName = _playerController.PlayerReplicationInfo.PlayerName;
	// End:0x13F
	foreach AllActors(Class'R6Engine.R6PlayerController', _pcIterator)
	{
		// End:0x125
		if(bBan)
		{
			_pcIterator.ClientAdminBanOff(_AdminName, _KickeeName);
			// End:0x13E
			continue;
		}
		_pcIterator.ClientAdminKickOff(_AdminName, _KickeeName);		
	}	
	// End:0x181
	if(bBan)
	{
		Level.Game.AccessControl.KickBan(_KickeeName);
		_playerController.ClientBanned();		
	}
	else
	{
		_playerController.ClientKickedOut();
	}
	_playerController.SpecialDestroy();
	return;
}

// Admin Command
exec function LoadServer(string FileName)
{
	local R6PlayerController _playerController;

	// End:0x15
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	ConsoleCommand(("INGAMELOADSERVER " $ FileName));
	return;
}

//=================================================================================
// INTERACTION WITH MENU FOR SERVER SETTINGS
//=================================================================================
function ServerPausePreGameRoundTime()
{
	m_bInAnOptionsPage = CheckAuthority(1);
	// End:0x37
	if((m_bInAnOptionsPage == true))
	{
		R6AbstractGameInfo(Level.Game).PauseCountDown();
	}
	return;
}

function ServerUnPausePreGameRoundTime()
{
	// End:0x31
	if((m_bInAnOptionsPage == true))
	{
		m_bInAnOptionsPage = false;
		R6AbstractGameInfo(Level.Game).UnPauseCountDown();
	}
	return;
}

function ServerStartChangingInfo()
{
	// End:0x1C
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		ClientServerChangingInfo(false);
		return;
	}
	// End:0x6B
	if(((R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != self) && (R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != none)))
	{
		ClientServerChangingInfo(false);
		return;
	}
	R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo = self;
	// End:0xF4
	if(bShowLog)
	{
		Log(("ServerStartChangingInfo: Setting m_pCurPlayerCtrlMdfSrvInfo = " $ string(R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo)));
	}
	ClientServerChangingInfo(true);
	return;
}

function ClientServerChangingInfo(bool _bCanChangeOptions)
{
	m_MenuCommunication.SetClientServerSettings(_bCanChangeOptions);
	return;
}

//=======================================
// SendSettingsAndRestartServer: This save new settings and restart the server
//=======================================
function SendSettingsAndRestartServer(bool _bRestrictionKitChange, bool _bChangeWasMade)
{
	local R6ServerInfo pServerInfo;

	// End:0x24
	if((R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != self))
	{
		return;
	}
	pServerInfo = Class'Engine.Actor'.static.GetServerOptions();
	// End:0x102
	if(_bChangeWasMade)
	{
		pServerInfo.SaveConfig(Class'Engine.Actor'.static.GetModMgr().GetServerIni());
		pServerInfo.m_ServerMapList.SaveConfig(Class'Engine.Actor'.static.GetModMgr().GetServerIni());
		// End:0xA9
		if((!_bRestrictionKitChange))
		{
			pServerInfo.RestartServer();			
		}
		else
		{
			R6AbstractGameInfo(Level.Game).UpdateRepResArrays();
			R6AbstractGameInfo(Level.Game).BroadcastGameMsg("", PlayerReplicationInfo.PlayerName, "RestOption");
		}		
	}
	else
	{
		R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo = none;
	}
	return;
}

exec function LogRest()
{
	local int i;
	local R6GameReplicationInfo _GRI;

	return;
}

//===========================================================================================
// ServerNewGeneralSettings: This set the new settings of the server, values are store in R6ServerInfo unique instance
//							 return true if a value was change
//===========================================================================================
function bool ServerNewGeneralSettings(UWindowBase.EButtonName _eButName, optional bool _bNewValue, optional int _iNewValue)
{
	local R6ServerInfo pServerInfo;
	local bool bValueChange;

	// End:0x24
	if((R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != self))
	{
		return false;
	}
	pServerInfo = Class'Engine.Actor'.static.GetServerOptions();
	bValueChange = true;
	switch(_eButName)
	{
		// End:0x4A
		case 1:
		// End:0x66
		case 6:
			pServerInfo.RoundsPerMatch = _iNewValue;
			// End:0x2CD
			break;
		// End:0x82
		case 2:
			pServerInfo.RoundTime = _iNewValue;
			// End:0x2CD
			break;
		// End:0x9E
		case 3:
			pServerInfo.MaxPlayers = _iNewValue;
			// End:0x2CD
			break;
		// End:0xBA
		case 4:
			pServerInfo.BombTime = _iNewValue;
			// End:0x2CD
			break;
		// End:0xD6
		case 7:
			pServerInfo.BetweenRoundTime = _iNewValue;
			// End:0x2CD
			break;
		// End:0xF2
		case 8:
			pServerInfo.NbTerro = _iNewValue;
			// End:0x2CD
			break;
		// End:0x110
		case 11:
			pServerInfo.FriendlyFire = _bNewValue;
			// End:0x2CD
			break;
		// End:0x12E
		case 12:
			pServerInfo.ShowNames = _bNewValue;
			// End:0x2CD
			break;
		// End:0x14C
		case 13:
			pServerInfo.Autobalance = _bNewValue;
			// End:0x2CD
			break;
		// End:0x154
		case 22:
			// End:0x2CD
			break;
		// End:0x172
		case 14:
			pServerInfo.TeamKillerPenalty = _bNewValue;
			// End:0x2CD
			break;
		// End:0x190
		case 15:
			pServerInfo.AllowRadar = _bNewValue;
			// End:0x2CD
			break;
		// End:0x1AE
		case 16:
			pServerInfo.RotateMap = _bNewValue;
			// End:0x2CD
			break;
		// End:0x1CC
		case 17:
			pServerInfo.AIBkp = _bNewValue;
			// End:0x2CD
			break;
		// End:0x1EA
		case 18:
			pServerInfo.ForceFPersonWeapon = _bNewValue;
			// End:0x2CD
			break;
		// End:0x206
		case 23:
			pServerInfo.DiffLevel = _iNewValue;
			// End:0x2CD
			break;
		// End:0x224
		case 24:
			pServerInfo.CamFirstPerson = _bNewValue;
			// End:0x2CD
			break;
		// End:0x242
		case 25:
			pServerInfo.CamThirdPerson = _bNewValue;
			// End:0x2CD
			break;
		// End:0x260
		case 26:
			pServerInfo.CamFreeThirdP = _bNewValue;
			// End:0x2CD
			break;
		// End:0x27E
		case 27:
			pServerInfo.CamGhost = _bNewValue;
			// End:0x2CD
			break;
		// End:0x29C
		case 28:
			pServerInfo.CamFadeToBlack = _bNewValue;
			// End:0x2CD
			break;
		// End:0x2BA
		case 29:
			pServerInfo.CamTeamOnly = _bNewValue;
			// End:0x2CD
			break;
		// End:0x2BF
		case 0:
		// End:0xFFFF
		default:
			bValueChange = false;
			// End:0x2CD
			break;
			break;
	}
	return bValueChange;
	return;
}

//===========================================================================================
// ServerNewMapsListSettings: This set the new map list settings of the server, values are store in R6ServerInfo unique instance
//===========================================================================================
function ServerNewMapListSettings(int iMapIndex, optional int iUpdateGameType, optional string _GameType, optional string _Map, optional int _iLastItem)
{
	local R6ServerInfo pServerInfo;
	local int i, iArrayCount;
	local bool bValueChange;

	// End:0x24
	if((R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != self))
	{
		return;
	}
	pServerInfo = Class'Engine.Actor'.static.GetServerOptions();
	// End:0xAF
	if((_iLastItem != 0))
	{
		iArrayCount = 32;
		i = _iLastItem;
		J0x54:

		// End:0xAD [Loop If]
		if((i < iArrayCount))
		{
			pServerInfo.m_ServerMapList.GameType[i] = "";
			pServerInfo.m_ServerMapList.Maps[i] = "";
			(i++);
			// [Loop Continue]
			goto J0x54;
		}
		return;
	}
	switch(iUpdateGameType)
	{
		// End:0xE0
		case 1:
			pServerInfo.m_ServerMapList.Maps[iMapIndex] = _Map;
			// End:0x157
			break;
		// End:0x10B
		case 2:
			pServerInfo.m_ServerMapList.GameType[iMapIndex] = _GameType;
			// End:0x157
			break;
		// End:0xFFFF
		default:
			pServerInfo.m_ServerMapList.GameType[iMapIndex] = _GameType;
			pServerInfo.m_ServerMapList.Maps[iMapIndex] = _Map;
			// End:0x157
			break;
			break;
	}
	return;
}

//===========================================================================================
// ServerNewKitRestSettings: This set the kit rest settings of the server, values are store in R6ServerInfo unique instance
//							  return true if a value was change
//===========================================================================================
function ServerNewKitRestSettings(UWindowBase.ERestKitID _eKitRestID, bool _bRemoveRest, optional Class _pANewClassValue, optional string _szNewValue)
{
	local R6ServerInfo pServerInfo;
	local bool bValueChange;

	// End:0x24
	if((R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo != self))
	{
		return;
	}
	pServerInfo = Class'Engine.Actor'.static.GetServerOptions();
	switch(_eKitRestID)
	{
		// End:0x64
		case 0:
			SetRestKitWithAClass(_bRemoveRest, _pANewClassValue, pServerInfo.RestrictedSubMachineGuns);
			// End:0x1C6
			break;
		// End:0x8B
		case 1:
			SetRestKitWithAClass(_bRemoveRest, _pANewClassValue, pServerInfo.RestrictedShotGuns);
			// End:0x1C6
			break;
		// End:0xB2
		case 2:
			SetRestKitWithAClass(_bRemoveRest, _pANewClassValue, pServerInfo.RestrictedAssultRifles);
			// End:0x1C6
			break;
		// End:0xD9
		case 3:
			SetRestKitWithAClass(_bRemoveRest, _pANewClassValue, pServerInfo.RestrictedMachineGuns);
			// End:0x1C6
			break;
		// End:0x100
		case 4:
			SetRestKitWithAClass(_bRemoveRest, _pANewClassValue, pServerInfo.RestrictedSniperRifles);
			// End:0x1C6
			break;
		// End:0x127
		case 5:
			SetRestKitWithAClass(_bRemoveRest, _pANewClassValue, pServerInfo.RestrictedPistols);
			// End:0x1C6
			break;
		// End:0x14E
		case 6:
			SetRestKitWithAClass(_bRemoveRest, _pANewClassValue, pServerInfo.RestrictedMachinePistols);
			// End:0x1C6
			break;
		// End:0x175
		case 7:
			SetRestKitWithAsz(_bRemoveRest, _szNewValue, pServerInfo.RestrictedPrimary);
			// End:0x1C6
			break;
		// End:0x19C
		case 8:
			SetRestKitWithAsz(_bRemoveRest, _szNewValue, pServerInfo.RestrictedSecondary);
			// End:0x1C6
			break;
		// End:0x1C3
		case 9:
			SetRestKitWithAsz(_bRemoveRest, _szNewValue, pServerInfo.RestrictedMiscGadgets);
			// End:0x1C6
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function SetRestKitWithAClass(bool _bRemoveRest, Class _pANewClassValue, out array< Class > _pARestKit)
{
	local int i;

	// End:0x4E
	if(_bRemoveRest)
	{
		i = 0;
		J0x10:

		// End:0x4B [Loop If]
		if((i < _pARestKit.Length))
		{
			// End:0x41
			if((_pARestKit[i] == _pANewClassValue))
			{
				_pARestKit.Remove(i, 1);
			}
			(i++);
			// [Loop Continue]
			goto J0x10;
		}		
	}
	else
	{
		_pARestKit[_pARestKit.Length] = _pANewClassValue;
	}
	return;
}

function SetRestKitWithAsz(bool _bRemoveRest, string _szNewValue, out array<string> _szARestKit)
{
	local int i;

	// End:0x4E
	if(_bRemoveRest)
	{
		i = 0;
		J0x10:

		// End:0x4B [Loop If]
		if((i < _szARestKit.Length))
		{
			// End:0x41
			if((_szARestKit[i] == _szNewValue))
			{
				_szARestKit.Remove(i, 1);
			}
			(i++);
			// [Loop Continue]
			goto J0x10;
		}		
	}
	else
	{
		_szARestKit[_szARestKit.Length] = _szNewValue;
	}
	return;
}

exec function RestartMatch(string explanation)
{
	local R6PlayerController _playerController;
	local string _AdminName;

	// End:0x15
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	_AdminName = PlayerReplicationInfo.PlayerName;
	DisableFirstPersonViewEffects();
	// End:0x68
	foreach AllActors(Class'R6Engine.R6PlayerController', _playerController)
	{
		_playerController.ClientDisableFirstPersonViewEffects();
		_playerController.ClientRestartMatchMsg(_AdminName, explanation);		
	}	
	Level.Game.AbortScoreSubmission();
	Level.Game.RestartGame();
	return;
}

// Admin Command
exec function RestartRound(string explanation)
{
	local R6PlayerController _playerController;
	local string _AdminName;

	// End:0x15
	if((CheckAuthority(1) == false))
	{
		ClientNoAuthority();
		return;
	}
	_AdminName = PlayerReplicationInfo.PlayerName;
	DisableFirstPersonViewEffects();
	// End:0x68
	foreach AllActors(Class'R6Engine.R6PlayerController', _playerController)
	{
		_playerController.ClientDisableFirstPersonViewEffects();
		_playerController.ClientRestartRoundMsg(_AdminName, explanation);		
	}	
	Level.Game.AbortScoreSubmission();
	R6AbstractGameInfo(Level.Game).AdminResetRound();
	R6AbstractGameInfo(Level.Game).ResetRound();
	R6AbstractGameInfo(Level.Game).ResetPenalty();
	return;
}

//====
// Server Broadcasted messages
//====
function ClientTeamFullMessage()
{
	HandleServerMsg(Localize("MPMiscMessages", "TeamIsFull", "R6GameInfo"));
	return;
}

function ClientServerMap(string _szPlayerName, string szNewMapname, string explanation)
{
	HandleServerMsg(((((_szPlayerName $ " ") $ Localize("Game", "AdminSwitchMap", "R6GameInfo")) $ " ") $ szNewMapname));
	// End:0x5D
	if((explanation != ""))
	{
		HandleServerMsg(explanation);
	}
	return;
}

function ClientKickBadId()
{
	HandleServerMsg(Localize("Game", "BadNameOrId", "R6GameInfo"));
	return;
}

// NEW IN 1.60
function ClientNextMapVoteMessage(string szRequestingPlayer)
{
	// End:0x68
	if(bShowLog)
	{
		Log(((("ClientMextMapVoteMessage displaying: " $ szRequestingPlayer) $ ": ") $ Localize("Game", "LetsChangeMap", "R6GameInfo")));
	}
	m_MenuCommunication.ActiveVoteMenu(true, "");
	HandleServerMsg(((szRequestingPlayer $ ": ") $ Localize("Game", "LetsChangeMap", "R6GameInfo")));
	return;
}

function ClientKickVoteMessage(PlayerReplicationInfo PRIKickPlayer, string szRequestingPlayer)
{
	// End:0x73
	if(bShowLog)
	{
		Log((((("ClientKickVoteMessage displaying: " $ szRequestingPlayer) $ ": ") $ Localize("Game", "LetsKickOut", "R6GameInfo")) @ PRIKickPlayer.PlayerName));
	}
	m_MenuCommunication.ActiveVoteMenu(true, PRIKickPlayer.PlayerName);
	HandleServerMsg((((szRequestingPlayer $ ": ") $ Localize("Game", "LetsKickOut", "R6GameInfo")) @ PRIKickPlayer.PlayerName));
	return;
}

function ClientPlayerVoteMessage(string _playerOne, int iResult, string _playerTwo)
{
	local string szVoteMessage;

	switch(iResult)
	{
		// End:0x8D
		case 1:
			// End:0x53
			if((_playerTwo != ""))
			{
				szVoteMessage = ((_playerOne @ Localize("Game", "YesVoteKick", "R6GameInfo")) @ _playerTwo);				
			}
			else
			{
				szVoteMessage = (_playerOne @ Localize("Game", "YesVoteChangeMap", "R6GameInfo"));
			}
			// End:0x117
			break;
		// End:0x112
		case 2:
			// End:0xD9
			if((_playerTwo != ""))
			{
				szVoteMessage = ((_playerOne @ Localize("Game", "NoVoteKick", "R6GameInfo")) @ _playerTwo);				
			}
			else
			{
				szVoteMessage = (_playerOne @ Localize("Game", "NoVoteChangeMap", "R6GameInfo"));
			}
			// End:0x117
			break;
		// End:0xFFFF
		default:
			return;
			break;
	}
	Player.InteractionMaster.Process_Message(szVoteMessage, 7.0000000, Player.LocalInteractions);
	return;
}

function ClientVoteResult(bool VoteResult, optional string _PlayerName)
{
	local string _stringOne, _stringTwo;

	// End:0xFA
	if((_PlayerName != ""))
	{
		// End:0x76
		if(VoteResult)
		{
			_stringOne = Localize("Game", "KickVotePassOne", "R6GameInfo");
			_stringTwo = Localize("Game", "KickVotePassTwo", "R6GameInfo");			
		}
		else
		{
			_stringOne = Localize("Game", "KickVoteFailOne", "R6GameInfo");
			_stringTwo = Localize("Game", "KickVoteFailTwo", "R6GameInfo");
		}
		HandleServerMsg(((((_stringOne $ " ") $ _PlayerName) $ " ") $ _stringTwo));		
	}
	else
	{
		// End:0x137
		if(VoteResult)
		{
			_stringOne = Localize("Game", "ChangeMapVotePass", "R6GameInfo");			
		}
		else
		{
			_stringOne = Localize("Game", "ChangeMapVoteFailed", "R6GameInfo");
		}
		HandleServerMsg(_stringOne);
	}
	m_MenuCommunication.ActiveVoteMenu(false);
	return;
}

event ClientVoteSessionAbort(string _PlayerName)
{
	HandleServerMsg((_PlayerName @ Localize("Game", "LeftTheServerVoteAborted", "R6GameInfo")));
	m_MenuCommunication.ActiveVoteMenu(false);
	return;
}

function ClientNewPassword(string _AdminName)
{
	HandleServerMsg(((_AdminName $ ": ") $ Localize("Game", "AdminPasswordChange", "R6GameInfo")));
	return;
}

function ClientPasswordTooLong()
{
	HandleServerMsg(Localize("Game", "PasswordTooLong", "R6GameInfo"));
	return;
}

function ClientNoAuthority()
{
	HandleServerMsg(Localize("Game", "NoAuthority", "R6GameInfo"));
	return;
}

function ClientVoteInProgress()
{
	HandleServerMsg(Localize("Game", "VoteInProgress", "R6GameInfo"));
	return;
}

// NEW IN 1.60
function ClientCantRequestChangeMapYet()
{
	HandleServerMsg(Localize("Game", "CantRequestChangeMapYet", "R6GameInfo"));
	return;
}

function ClientCantRequestKickYet()
{
	HandleServerMsg(Localize("Game", "CantRequestKickYet", "R6GameInfo"));
	return;
}

function ClientNoKickAdmin()
{
	HandleServerMsg(Localize("Game", "CantKickAdmin", "R6GameInfo"));
	return;
}

function ClientAdminKickOff(string _AdminName, string _KickedName)
{
	HandleServerMsg(((((_KickedName $ " ") $ Localize("Game", "AdminKickOff", "R6GameInfo")) $ " ") $ _AdminName));
	return;
}

function ClientAdminBanOff(string _AdminName, string _KickedName)
{
	HandleServerMsg(((((_KickedName $ " ") $ Localize("Game", "AdminBanOff", "R6GameInfo")) $ " ") $ _AdminName));
	return;
}

// NEW IN 1.60
function ClientVoteChangeMap(string _AdminName)
{
	HandleServerMsg(((_AdminName $ " ") $ Localize("Game", "VoteChangeMap", "R6GameInfo")));
	return;
}

function ClientRestartRoundMsg(string _AdminName, string explanation)
{
	HandleServerMsg(((_AdminName $ " ") $ Localize("Game", "RestartsTheRound", "R6GameInfo")));
	// End:0x53
	if((explanation != ""))
	{
		HandleServerMsg(explanation);
	}
	m_MenuCommunication.SetPlayerReadyStatus(false);
	return;
}

function ClientRestartMatchMsg(string _AdminName, string explanation)
{
	HandleServerMsg(((_AdminName $ " ") $ Localize("Game", "RestartsTheMatch", "R6GameInfo")));
	// End:0x53
	if((explanation != ""))
	{
		HandleServerMsg(explanation);
	}
	m_MenuCommunication.SetPlayerReadyStatus(false);
	return;
}

//------------------------------------------------------------------
// ClientResetGameMsg
//	
//------------------------------------------------------------------
function ClientResetGameMsg()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x57 [Loop If]
	if((i < myHUD.3))
	{
		myHUD.TextServerMessages[i] = "";
		myHUD.MessageServerLife[i] = 0.0000000;
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//------------------------------------------------------------------
// ClientGameTypeDescription: display the short game type description
//	
//------------------------------------------------------------------
function ClientGameTypeDescription(string szGameTypeFlag)
{
	local string szObjective;

	// End:0x4B
	if((PlayerReplicationInfo.TeamID == int(3)))
	{
		szObjective = Level.GetRedShortDescription(szGameTypeFlag);
		// End:0x48
		if((szObjective != ""))
		{
			HandleServerMsg(szObjective);
		}		
	}
	else
	{
		szObjective = Level.GetGreenShortDescription(szGameTypeFlag);
		// End:0x7C
		if((szObjective != ""))
		{
			HandleServerMsg(szObjective);
		}
	}
	return;
}

//------------------------------------------------------------------
// Dispatch game msg: Default RavenShield and MissionObjective
//	
//------------------------------------------------------------------
function ClientMissionObjMsg(string szLocFile, string szPreMsg, string szMsgID, optional Sound sndSound, optional int iLifeTime)
{
	// End:0x20
	if((szLocFile == ""))
	{
		szLocFile = Level.m_szMissionObjLocalization;
	}
	SetGameMsg(szLocFile, szPreMsg, szMsgID, sndSound, iLifeTime);
	return;
}

function ClientGameMsg(string szLocFile, string szPreMsg, string szMsgID, optional Sound sndSound, optional int iLifeTime)
{
	// End:0x1E
	if((szLocFile == ""))
	{
		szLocFile = "R6GameInfo";
	}
	SetGameMsg(szLocFile, szPreMsg, szMsgID, sndSound, iLifeTime);
	return;
}

//------------------------------------------------------------------
// SetGameMsg
//	the server broadcast game msg to client
//------------------------------------------------------------------
function SetGameMsg(string szLocalization, string szPreMsg, string szMsgID, optional Sound sndSound, optional int iLifeTime)
{
	// End:0x4A
	if(((szPreMsg != "") && (szMsgID != "")))
	{
		HandleServerMsg(((szPreMsg $ " ") $ Localize("Game", szMsgID, szLocalization)), iLifeTime);		
	}
	else
	{
		// End:0x77
		if(((szPreMsg != "") && (szMsgID == "")))
		{
			HandleServerMsg(szPreMsg, iLifeTime);			
		}
		else
		{
			// End:0xA7
			if((szMsgID != ""))
			{
				HandleServerMsg(Localize("Game", szMsgID, szLocalization), iLifeTime);				
			}
			else
			{
				HandleServerMsg("", iLifeTime);
			}
		}
	}
	// End:0xD5
	if((sndSound != none))
	{
		ClientPlayVoices(none, sndSound, 7, 5, true, 1.0000000);
	}
	return;
}

function ServerGhost(Pawn aPawn)
{
	// End:0x24
	if((CheatManager != none))
	{
		R6CheatManager(CheatManager).DoGhost(aPawn);
	}
	return;
}

function ServerCompleteMission()
{
	// End:0x1F
	if((CheatManager != none))
	{
		R6CheatManager(CheatManager).DoCompleteMission();
	}
	return;
}

function ServerAbortMission()
{
	// End:0x1F
	if((CheatManager != none))
	{
		R6CheatManager(CheatManager).DoAbortMission();
	}
	return;
}

function ServerWalk(Pawn aPawn)
{
	// End:0x24
	if((CheatManager != none))
	{
		R6CheatManager(CheatManager).DoWalk(aPawn);
	}
	return;
}

function ServerPlayerInvisible(bool bIsVisible)
{
	// End:0x25
	if((CheatManager != none))
	{
		R6CheatManager(CheatManager).DoPlayerInvisible(bIsVisible);
	}
	return;
}

function ClientTeamIsDead()
{
	// End:0x1C
	if((m_MenuCommunication != none))
	{
		m_MenuCommunication.SetStatMenuState(5);
	}
	return;
}

//------------------------------------------------------------------
// ServerRequestSkins
//	Client request the skin on the server
//------------------------------------------------------------------
simulated function ServerRequestSkins()
{
	local Class<R6Rainbow> TempGreenClass, TempRedClass;

	// End:0x191
	if((int(Level.NetMode) != int(NM_Client)))
	{
		// End:0x56
		if((Level.GreenTeamPawnClass != "none"))
		{
			TempGreenClass = Class<R6Rainbow>(DynamicLoadObject(Level.GreenTeamPawnClass, Class'Core.Class'));
		}
		// End:0xA8
		if((TempGreenClass != none))
		{
			R6AbstractGameInfo(Level.Game).Find2DTexture(Level.GreenTeamPawnClass, Level.GreenMenuSkin, Level.GreenMenuRegion);
		}
		// End:0xE5
		if((Level.RedTeamPawnClass != "none"))
		{
			TempRedClass = Class<R6Rainbow>(DynamicLoadObject(Level.RedTeamPawnClass, Class'Core.Class'));
		}
		// End:0x137
		if((TempRedClass != none))
		{
			R6AbstractGameInfo(Level.Game).Find2DTexture(Level.RedTeamPawnClass, Level.RedMenuSkin, Level.RedMenuRegion);
		}
		ClientSetMultiplayerSkins(Level.GreenTeamPawnClass, Level.RedTeamPawnClass, Level.GreenMenuSkin, Level.GreenMenuRegion, Level.RedMenuSkin, Level.RedMenuRegion);
	}
	return;
}

//------------------------------------------------------------------
// ClientSetMultiplayerSkins
//	Server set the skin on the client
//------------------------------------------------------------------
simulated function ClientSetMultiplayerSkins(string G, string R, Material GreenMenuSkin, Region GreenMenuRegion, Material RedMenuSkin, Region RedMenuRegion)
{
	local Class<Pawn> TempGreenClass, TempRedClass;

	Level.GreenTeamPawnClass = G;
	Level.RedTeamPawnClass = R;
	// End:0x305
	if((int(Level.NetMode) == int(NM_Client)))
	{
		// End:0x7E
		if((Level.GreenTeamPawnClass != "none"))
		{
			TempGreenClass = Class<Pawn>(DynamicLoadObject(Level.GreenTeamPawnClass, Class'Core.Class'));
		}
		// End:0x1A3
		if((TempGreenClass != none))
		{
			Level.GreenTeamSkin = TempGreenClass.default.Skins[0];
			Level.GreenHeadSkin = TempGreenClass.default.Skins[1];
			Level.GreenGogglesSkin = TempGreenClass.default.Skins[2];
			Level.GreenHandSkin = TempGreenClass.default.Skins[5];
			Level.GreenMesh = TempGreenClass.default.Mesh;
			Level.GreenHelmet = TempGreenClass.default.m_HelmetClass;
			// End:0x1A3
			if((Level.GreenHelmet != none))
			{
				Level.GreenHelmetMesh = Level.GreenHelmet.default.StaticMesh;
				Level.GreenHelmetSkin = Level.GreenHelmet.default.Skins[0];
			}
		}
		// End:0x1E0
		if((Level.RedTeamPawnClass != "none"))
		{
			TempRedClass = Class<Pawn>(DynamicLoadObject(Level.RedTeamPawnClass, Class'Core.Class'));
		}
		// End:0x305
		if((TempRedClass != none))
		{
			Level.RedTeamSkin = TempRedClass.default.Skins[0];
			Level.RedHeadSkin = TempRedClass.default.Skins[1];
			Level.RedGogglesSkin = TempRedClass.default.Skins[2];
			Level.RedHandSkin = TempRedClass.default.Skins[5];
			Level.RedMesh = TempRedClass.default.Mesh;
			Level.RedHelmet = TempRedClass.default.m_HelmetClass;
			// End:0x305
			if((TempRedClass.default.m_HelmetClass != none))
			{
				Level.RedHelmetMesh = Level.RedHelmet.default.StaticMesh;
				Level.RedHelmetSkin = Level.RedHelmet.default.Skins[0];
			}
		}
	}
	Level.GreenMenuSkin = GreenMenuSkin;
	Level.GreenMenuRegion = GreenMenuRegion;
	Level.RedMenuSkin = RedMenuSkin;
	Level.RedMenuRegion = RedMenuRegion;
	return;
}

function ClientStopFadeToBlack()
{
	// End:0x31
	if(((myHUD != none) && (Viewport(Player) != none)))
	{
		R6AbstractHUD(myHUD).StopFadeToBlack();
	}
	return;
}

// NEW IN 1.60
function addToOxygenLevel(float f)
{
	return;
}

function CountDownPopUpBox()
{
	// End:0x1A
	if((m_MenuCommunication != none))
	{
		m_MenuCommunication.CountDownPopUpBox();
	}
	return;
}

function CountDownPopUpBoxDone()
{
	// End:0x1A
	if((m_MenuCommunication != none))
	{
		m_MenuCommunication.CountDownPopUpBoxDone();
	}
	return;
}

exec function MyID()
{
	Player.Console.Message(m_GameService.MyID(), 6.0000000);
	return;
}

// NEW IN 1.60
function ClientChatDisabledMsg(int iTimeRem)
{
	ClientMessage(((Localize("Game", "ChatDisabledMessage1", "R6GameInfo") @ string(iTimeRem)) @ Localize("Game", "ChatDisabledMessage2", "R6GameInfo")));
	return;
}

// NEW IN 1.60
function ClientChatAbuseMsg(int iChatLockDuration)
{
	ClientMessage(((Localize("Game", "AbuseDetectedMessage1", "R6GameInfo") @ string(iChatLockDuration)) @ Localize("Game", "AbuseDetectedMessage2", "R6GameInfo")));
	return;
}

	// no chit chat while surrended/arrested
exec function Say(string Msg)
{
	local R6ServerInfo pServerInfo;

	// End:0x29
	if(((Msg == "") || (int(Level.NetMode) == int(NM_Standalone))))
	{
		return;
	}
	pServerInfo = Class'Engine.Actor'.static.GetServerOptions();
	// End:0xE0
	if((m_fPreviousBroadcastTimeStamp <= (Level.TimeSeconds - pServerInfo.SpamThreshold)))
	{
		// End:0xC0
		if((Level.TimeSeconds >= m_fEndOfChatLockTime))
		{
			m_fPreviousBroadcastTimeStamp = m_fLastBroadcastTimeStamp;
			m_fLastBroadcastTimeStamp = Level.TimeSeconds;
			Level.Game.Broadcast(self, Msg, 'Say');			
		}
		else
		{
			ClientChatDisabledMsg(int((m_fEndOfChatLockTime - Level.TimeSeconds)));
		}		
	}
	else
	{
		m_fEndOfChatLockTime = (Level.TimeSeconds + pServerInfo.ChatLockDuration);
		m_fPreviousBroadcastTimeStamp = -99.0000000;
		m_fLastBroadcastTimeStamp = -99.0000000;
		ClientChatAbuseMsg(int(pServerInfo.ChatLockDuration));
	}
	return;
}

exec function TeamSay(string Msg)
{
	local R6ServerInfo pServerInfo;

	// End:0x29
	if(((Msg == "") || (int(Level.NetMode) == int(NM_Standalone))))
	{
		return;
	}
	pServerInfo = Class'Engine.Actor'.static.GetServerOptions();
	// End:0xE0
	if((m_fPreviousBroadcastTimeStamp <= (Level.TimeSeconds - pServerInfo.SpamThreshold)))
	{
		// End:0xC0
		if((Level.TimeSeconds >= m_fEndOfChatLockTime))
		{
			m_fPreviousBroadcastTimeStamp = m_fLastBroadcastTimeStamp;
			m_fLastBroadcastTimeStamp = Level.TimeSeconds;
			Level.Game.BroadcastTeam(self, Msg, 'TeamSay');			
		}
		else
		{
			ClientChatDisabledMsg(int((m_fEndOfChatLockTime - Level.TimeSeconds)));
		}		
	}
	else
	{
		m_fEndOfChatLockTime = (Level.TimeSeconds + pServerInfo.ChatLockDuration);
		m_fPreviousBroadcastTimeStamp = -99.0000000;
		m_fLastBroadcastTimeStamp = -99.0000000;
		ClientChatAbuseMsg(int(pServerInfo.ChatLockDuration));
	}
	return;
}

event string GetLocalPlayerIp()
{
	return WindowConsole(Player.Console).szStoreIP;
	return;
}

// NEW IN 1.60
exec function HideWeapon()
{
	// End:0x73
	if((R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon == false))
	{
		m_GameOptions.HUDShowFPWeapon = false;
		m_bShowFPWeapon = false;
		R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
		R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
	}
	return;
}

state PlayerFlying
{
	function BeginState()
	{
		// End:0x6A
		if((Pawn != none))
		{
			SetRotation((Rotation + Pawn.m_rRotationOffset));
			Pawn.m_rRotationOffset = rot(0, 0, 0);
			m_pawn.PawnLook(Pawn.m_rRotationOffset,, true);
			Pawn.SetPhysics(4);
		}
		return;
	}
	stop;
}

state GameEnded
{	stop;
}

state PenaltyBox
{
	ignores KilledBy;

	function BeginState()
	{
		m_pawn.m_eHealth = 2;
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	exec function ToggleHelmetCameraZoom(optional bool bTurnOff)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	function SwitchWeapon(byte f)
	{
		return;
	}
Begin:

	// End:0x9F
	if((R6AbstractGameInfo(Level.Game) != none))
	{
		// End:0x50
		if((int(m_ePenaltyForKillingAPawn) == int(3)))
		{
			ClientGameMsg("", "", "PenaltyYouKilledAHostage");			
		}
		else
		{
			ClientGameMsg("", "", "PenaltyYouKilledATeamMate");
		}
		Sleep(1.0000000);
		R6AbstractGameInfo(Level.Game).ApplyTeamKillerPenalty(Pawn);
	}
	stop;				
}

state PlayerWalking
{
	function PlayerMove(float DeltaTime)
	{
		// End:0x8A
		if((WindowConsole(Player.Console).ConsoleState == 'UWindow'))
		{
			// End:0x60
			if((int(Role) < int(ROLE_Authority)))
			{
				ReplicateMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));				
			}
			else
			{
				ProcessMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));
			}			
		}
		else
		{
			super.PlayerMove(DeltaTime);
		}
		return;
	}

	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		// End:0x1A
		if(((Pawn == none) || (m_pawn == none)))
		{
			return;
		}
		Pawn.Acceleration = NewAccel;
		// End:0x4C
		if(bPressedJump)
		{
			Pawn.DoJump(bUpdating);
		}
		// End:0x1C4
		if((int(Pawn.Physics) != int(2)))
		{
			// End:0xCA
			if((m_pawn.m_bPostureTransition && (!m_pawn.m_bIsLanding)))
			{
				aForward = 0.0000000;
				aStrafe = 0.0000000;
				aTurn = 0.0000000;
				Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			}
			// End:0xEE
			if((int(DoubleClickMove) == int(3)))
			{
				m_fPostFluidMovementDelay = 0.1000000;
				ResetSpecialCrouch();				
			}
			else
			{
				// End:0x114
				if((m_fPostFluidMovementDelay <= float(0)))
				{
					m_fPostFluidMovementDelay = 0.0000000;
					HandleFluidMovement(DeltaTime);					
				}
				else
				{
					(m_fPostFluidMovementDelay -= DeltaTime);
				}
			}
			// End:0x140
			if((int(bDuck) == 0))
			{
				Pawn.ShouldCrouch(false);				
			}
			else
			{
				// End:0x162
				if(Pawn.bCanCrouch)
				{
					Pawn.ShouldCrouch(true);
				}
			}
			// End:0x17F
			if(m_bCrawl)
			{
				Pawn.m_bWantsToProne = true;				
			}
			else
			{
				Pawn.m_bWantsToProne = false;
			}
			UpdatePlayerPeeking();
			// End:0x1C4
			if(Pawn.m_bIsLanding)
			{
				Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			}
		}
		// End:0x1F2
		if(((int(m_bReloading) == 1) && (!R6GameReplicationInfo(GameReplicationInfo).m_bGameOverRep)))
		{
			ReloadWeapon();
		}
		return;
	}

	function BeginState()
	{
		m_pawn = R6Rainbow(Pawn);
		// End:0x24
		if((Pawn == none))
		{
			GotoState('BaseSpectating');
			return;
		}
		// End:0x47
		if((Pawn.Mesh == none))
		{
			Pawn.SetMesh();
		}
		DoubleClickDir = 0;
		bPressedJump = false;
		// End:0x99
		if(((int(Pawn.Physics) != int(2)) && (int(Pawn.Physics) != int(14))))
		{
			Pawn.SetPhysics(1);
		}
		GroundPitch = 0;
		// End:0xB8
		if(m_GameOptions.HUDShowFPWeapon)
		{
			ShowWeapon();
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		GroundPitch = 0;
		return;
	}
	stop;
}

auto state BaseSpectating
{
	simulated function BeginState()
	{
		return;
	}

    // overwritten: don't reset should crouch
	simulated function EndState()
	{
		InitializeMenuCom();
		// End:0x6A
		if(((((Player != none) && (Viewport(Player) != none)) && (m_GameService == none)) && (Player.Console != none)))
		{
			m_GameService = R6AbstractGameService(Player.Console.SetGameServiceLinks(self));
		}
		return;
	}

	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		Acceleration = NewAccel;
		MoveSmooth((Acceleration * DeltaTime));
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Rotator NewRotation, OldRotation, ViewRotation;
		local Vector X, Y, Z;

		GetAxes(Rotation, X, Y, Z);
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aUp = 0.0000000;
		aTurn = 0.0000000;
		Acceleration = (0.0200000 * (((aForward * X) + (aStrafe * Y)) + (aUp * vect(0.0000000, 0.0000000, 1.0000000))));
		ViewRotation = Rotation;
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1.0000000);
		// End:0xDF
		if((int(Role) < int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, Acceleration, 0, (OldRotation - Rotation));			
		}
		else
		{
			ProcessMove(DeltaTime, Acceleration, 0, (OldRotation - Rotation));
		}
		return;
	}

	function Tick(float DeltaTime)
	{
		InitializeMenuCom();
		return;
	}
	stop;
}

state PauseController extends PlayerWalking
{
	ignores KilledBy;

	function BeginState()
	{
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		return;
	}

	exec function ToggleHelmetCameraZoom(optional bool bTurnOff)
	{
		return;
	}

	simulated function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		bFire = 0;
		super.ProcessMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, DeltaRot);
		return;
	}

	simulated function PlayFiring()
	{
		return;
	}

	simulated function AltFiring()
	{
		return;
	}

	simulated function bool PlayerIsFiring()
	{
		return false;
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		R6PlayerMove(DeltaTime);
		return;
	}

	simulated function Tick(float fDeltaTime)
	{
		// End:0x1B
		if(((Pawn == none) || (m_bPawnInitialized == true)))
		{
			return;
		}
		m_bPawnInitialized = true;
		Pawn.m_bIsFiringWeapon = 0;
		Pawn.SetPhysics(1);
		// End:0x5A
		if(m_GameOptions.HUDShowFPWeapon)
		{
			ShowWeapon();
		}
		return;
	}

// NEW IN 1.60
	function VeryShortClientAdjustPosition(float TimeStamp, float NewLocX, float NewLocY, float NewLocZ, Actor NewBase)
	{
		local Vector Floor;

		// End:0x1F
		if((Pawn != none))
		{
			Floor = Pawn.Floor;
		}
		LongClientAdjustPosition(TimeStamp, 'PauseController', 1, NewLocX, NewLocY, NewLocZ, 0.0000000, 0.0000000, 0.0000000, NewBase, Floor.X, Floor.Y, Floor.Z);
		return;
	}
	stop;
}

state WaitForGameRepInfo
{
	function BeginState()
	{
		m_bReadyToEnterSpectatorMode = false;
		return;
	}

	event Tick(float fDeltaTime)
	{
		super(Actor).Tick(fDeltaTime);
		// End:0x8C
		if((GameReplicationInfo != none))
		{
			InitializeMenuCom();
			// End:0x6C
			if((((!m_bReadyToEnterSpectatorMode) && (int(m_TeamSelection) == int(0))) && (int(GameReplicationInfo.m_eCurrectServerState) == GameReplicationInfo.3)))
			{
				m_bReadyToEnterSpectatorMode = true;
				SetTimer(5.0000000, false);
			}
			// End:0x8C
			if((int(m_TeamSelection) != int(0)))
			{
				SetTimer(0.0000000, false);
				GotoState('Dead');
			}
		}
		return;
	}

	function Timer()
	{
		SetTimer(0.0000000, false);
		GotoState('Dead');
		return;
	}
	stop;
}

state Dead
{
	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	exec function GraduallyOpenDoor()
	{
		return;
	}

	exec function GraduallyCloseDoor()
	{
		return;
	}

	exec function ToggleHelmetCameraZoom(optional bool bTurnOff)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		local Class<R6Rainbow> rainbowPawnClass;

		// End:0x1B
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			return;
		}
		// End:0x28
		if((!m_bReadyToEnterSpectatorMode))
		{
			return;
		}
		ResetBlur();
		m_eCameraMode = 0;
		m_bCameraFirstPerson = false;
		m_bCameraThirdPersonFree = false;
		m_bCameraThirdPersonFixed = false;
		m_bCameraGhost = false;
		m_bFadeToBlack = false;
		m_bSpectatorCameraTeamOnly = false;
		// End:0xC4
		if(((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.1) > 0))
		{
			m_bCameraFirstPerson = true;
			// End:0xC4
			if(bShowLog)
			{
				Log("Death Camera Mode = eDCM_FIRSTPERSON");
			}
		}
		// End:0x123
		if(((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.2) > 0))
		{
			m_bCameraThirdPersonFixed = true;
			// End:0x123
			if(bShowLog)
			{
				Log("Death Camera Mode = eDCM_THIRDPERSON");
			}
		}
		// End:0x186
		if(((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.4) > 0))
		{
			m_bCameraThirdPersonFree = true;
			// End:0x186
			if(bShowLog)
			{
				Log("Death Camera Mode = eDCM_FREETHIRDPERSON");
			}
		}
		// End:0x1DF
		if(((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.8) > 0))
		{
			m_bCameraGhost = true;
			// End:0x1DF
			if(bShowLog)
			{
				Log("Death Camera Mode = eDCM_GHOST");
			}
		}
		// End:0x23E
		if(((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.16) > 0))
		{
			m_bFadeToBlack = true;
			// End:0x23E
			if(bShowLog)
			{
				Log("Death Camera Mode = eDCM_FADETOBLACK");
			}
		}
		// End:0x2C6
		if(((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.32) > 0))
		{
			m_bSpectatorCameraTeamOnly = true;
			// End:0x2BE
			if(bShowLog)
			{
				Log(("Spectator Camera is restricted to Team Only m_TeamSelection=" $ string(m_TeamSelection)));
			}
			m_bCameraGhost = false;
		}
		// End:0x3E8
		if((int(Level.NetMode) != int(NM_Standalone)))
		{
			// End:0x3E8
			if(((IsPlayerPassiveSpectator() || (m_TeamManager == none)) || (m_TeamManager.m_iMemberCount == 0)))
			{
				// End:0x326
				if((int(Role) < int(ROLE_Authority)))
				{
					ServerExecFire(f);
				}
				// End:0x36B
				if((int(Level.NetMode) != int(NM_DedicatedServer)))
				{
					// End:0x35E
					if((Pawn != none))
					{
						Pawn.m_fRemainingGrenadeTime = 0.0000000;
					}
					ClientFadeCommonSound(0.5000000, 100);
				}
				// End:0x39F
				if((((m_bCameraFirstPerson || m_bCameraThirdPersonFixed) || m_bCameraThirdPersonFree) || m_bCameraGhost))
				{
					GotoState('CameraPlayer');					
				}
				else
				{
					// End:0x3E8
					if(((myHUD != none) && (Viewport(Player) != none)))
					{
						R6AbstractHUD(myHUD).StartFadeToBlack(0, 100);
						R6AbstractHUD(myHUD).ActivateNoDeathCameraMsg(true);
					}
				}
			}
		}
		return;
	}

	simulated function ResetCurrentState()
	{
		// End:0x30
		if((m_bSpectatorCameraTeamOnly && ((m_MenuCommunication != none) && (int(m_TeamSelection) == int(4)))))
		{
			BeginState();
			return;
		}
		// End:0x9F
		if(((int(Level.NetMode) == int(NM_Client)) || ((int(Level.NetMode) == int(NM_ListenServer)) && (Viewport(Player) != none))))
		{
			// End:0x9F
			if(((m_MenuCommunication != none) && IsPlayerPassiveSpectator()))
			{
				m_bReadyToEnterSpectatorMode = true;
				Fire(0.0000000);
			}
		}
		return;
	}

	simulated function BeginState()
	{
		local bool bCanEnterSpectator;

		// End:0x4E
		if((((int(Level.NetMode) != int(NM_Standalone)) && (Viewport(Player) != none)) && ((GameReplicationInfo == none) || (m_MenuCommunication == none))))
		{
			GotoState('WaitForGameRepInfo');
			return;
		}
		bCanEnterSpectator = true;
		// End:0x82
		if((bPendingDelete || ((Pawn != none) && Pawn.bPendingDelete)))
		{
			return;
		}
		// End:0xAE
		if((bDeleteMe || ((Pawn != none) && Pawn.bDeleteMe)))
		{
			return;
		}
		m_bReadyToEnterSpectatorMode = true;
		// End:0xE7
		if(((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.32) > 0))
		{
			m_bSpectatorCameraTeamOnly = true;			
		}
		else
		{
			m_bSpectatorCameraTeamOnly = false;
		}
		// End:0x145
		if(((int(Level.NetMode) == int(NM_DedicatedServer)) || ((int(Level.NetMode) == int(NM_ListenServer)) && (Viewport(Player) == none))))
		{
			ClientGotoState('Dead', 'None');
		}
		super.BeginState();
		ClientDisableFirstPersonViewEffects();
		Blur(75);
		// End:0x331
		if(((int(Level.NetMode) == int(NM_Client)) || ((int(Level.NetMode) == int(NM_ListenServer)) && (Viewport(Player) != none))))
		{
			// End:0x23B
			if((((m_MenuCommunication != none) && (int(m_TeamSelection) != int(4))) && ((!GameReplicationInfo.IsInAGameState()) || (Pawn != none))))
			{
				// End:0x205
				if((int(m_TeamSelection) == int(0)))
				{
					m_MenuCommunication.SetStatMenuState(0);
					return;					
				}
				else
				{
					// End:0x238
					if((!Level.IsGameTypeCooperative(GameReplicationInfo.m_szGameTypeFlagRep)))
					{
						m_MenuCommunication.SetStatMenuState(5);
					}
				}				
			}
			else
			{
				// End:0x28C
				if((((int(Level.NetMode) == int(NM_ListenServer)) && (Viewport(Player) != none)) && (int(m_TeamSelection) != int(4))))
				{
					// End:0x289
					if((m_MenuCommunication == none))
					{
						InitializeMenuCom();
					}					
				}
				else
				{
					// End:0x321
					if(((!m_bSpectatorCameraTeamOnly) || ((int(m_TeamSelection) != int(0)) && (int(m_TeamSelection) != int(4)))))
					{
						// End:0x30B
						if(((GameReplicationInfo.IsInAGameState() && (Pawn == none)) && (int(m_TeamSelection) != int(0))))
						{
							m_MenuCommunication.SetStatMenuState(5);
							Fire(0.0000000);							
						}
						else
						{
							m_MenuCommunication.SetStatMenuState(0);
						}
						return;						
					}
					else
					{
						bCanEnterSpectator = false;
						m_bReadyToEnterSpectatorMode = false;
					}
				}
			}
		}
		// End:0x3EE
		if(((myHUD != none) && (Viewport(Player) != none)))
		{
			// End:0x382
			if((int(Level.NetMode) == int(NM_Standalone)))
			{
				R6AbstractHUD(myHUD).StartFadeToBlack(5, 80);				
			}
			else
			{
				// End:0x3BC
				if((!bCanEnterSpectator))
				{
					R6AbstractHUD(myHUD).ActivateNoDeathCameraMsg(true);
					R6AbstractHUD(myHUD).StartFadeToBlack(1, 100);					
				}
				else
				{
					R6AbstractHUD(myHUD).StartFadeToBlack(5, 100);
				}
			}
			// End:0x3EE
			if(bCanEnterSpectator)
			{
				m_bReadyToEnterSpectatorMode = false;
				SetTimer(3.0000000, false);
			}
		}
		return;
	}

	function EnterSpectatorMode()
	{
		// End:0x24
		if((int(Level.NetMode) != int(NM_Standalone)))
		{
			Fire(0.0000000);
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		// End:0x46
		if(((myHUD != none) && (Viewport(Player) != none)))
		{
			R6AbstractHUD(myHUD).StopFadeToBlack();
			R6AbstractHUD(myHUD).ActivateNoDeathCameraMsg(false);
		}
		m_bReadyToEnterSpectatorMode = false;
		ResetBlur();
		SetTimer(0.0000000, false);
		return;
	}

	function Timer()
	{
		// End:0x14
		if(PlayerCanSwitchToAIBackup())
		{
			SetTimer(2.0000000, false);
			return;
		}
		InitializeMenuCom();
		// End:0x44
		if((m_bSpectatorCameraTeamOnly && ((m_MenuCommunication != none) && (int(m_TeamSelection) == int(4)))))
		{
			return;
		}
		m_bReadyToEnterSpectatorMode = true;
		// End:0x114
		if((int(Level.NetMode) != int(NM_Standalone)))
		{
			// End:0xA3
			if(((R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode & Level.16) > 0))
			{
				R6AbstractHUD(myHUD).ActivateNoDeathCameraMsg(true);				
			}
			else
			{
				Fire(0.0000000);
				// End:0x114
				if((((GameReplicationInfo != none) && (int(GameReplicationInfo.m_eCurrectServerState) == GameReplicationInfo.3)) && (int(m_TeamSelection) != int(0))))
				{
					ClientGameMsg("", "", "PressFireToGoInObserverMode");
				}
			}
		}
		return;
	}
	stop;
}

state CameraPlayer
{
	simulated function BeginState()
	{
		local R6RainbowTeam rainbowTeam;

		PlayerReplicationInfo.bIsSpectator = true;
		bOnlySpectator = true;
		// End:0x35
		if((Pawn != none))
		{
			Pawn.bOwnerNoSee = false;
		}
		Pawn = none;
		m_pawn = none;
		SetViewTarget(self);
		Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		SetPhysics(4);
		m_PrevViewTarget = none;
		m_eCameraMode = 0;
		// End:0x83
		if((!CameraIsAvailable()))
		{
			SelectCameraMode(true);
		}
		// End:0x117
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			rainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetRainbowTeam(Player.Console.Master.m_StartGameInfo.m_iTeamStart));
			SetNewViewTarget(rainbowTeam.m_Team[0]);
			// End:0x114
			if((ViewTarget != none))
			{
				SetCameraMode();
			}			
		}
		else
		{
			// End:0x148
			if((int(Level.NetMode) != int(NM_Client)))
			{
				SpectatorChangeTeams(true);
				// End:0x148
				if((ViewTarget != none))
				{
					SetCameraMode();
				}
			}
		}
		return;
	}

    // overwritten: don't reset should crouch
	simulated function EndState()
	{
		PlayerReplicationInfo.bIsSpectator = false;
		bOnlySpectator = false;
		bBehindView = false;
		SetViewTarget(self);
		return;
	}

	simulated function SetSpectatorRotation()
	{
		local Rotator rViewRotation;

		// End:0x8A
		if((ViewTarget != none))
		{
			// End:0x3E
			if((!bBehindView))
			{
				SetRotation((ViewTarget.Rotation + R6Pawn(ViewTarget).GetRotationOffset()));				
			}
			else
			{
				rViewRotation = ViewTarget.Rotation;
				rViewRotation.Pitch = -6000;
				SetRotation(rViewRotation);
			}
			m_iSpectatorPitch = Rotation.Pitch;
			m_iSpectatorYaw = Rotation.Yaw;
		}
		return;
	}

	function NextCameraMode()
	{
		switch(m_eCameraMode)
		{
			// End:0x17
			case 0:
				m_eCameraMode = 1;
				// End:0x47
				break;
			// End:0x27
			case 1:
				m_eCameraMode = 2;
				// End:0x47
				break;
			// End:0x37
			case 2:
				m_eCameraMode = 3;
				// End:0x47
				break;
			// End:0x44
			case 3:
				m_eCameraMode = 0;
			// End:0xFFFF
			default:
				break;
		}
		return;
	}

	function PreviousCameraMode()
	{
		switch(m_eCameraMode)
		{
			// End:0x17
			case 0:
				m_eCameraMode = 3;
				// End:0x47
				break;
			// End:0x27
			case 1:
				m_eCameraMode = 0;
				// End:0x47
				break;
			// End:0x37
			case 2:
				m_eCameraMode = 1;
				// End:0x47
				break;
			// End:0x44
			case 3:
				m_eCameraMode = 2;
			// End:0xFFFF
			default:
				break;
		}
		return;
	}

	function SelectCameraMode(bool bNext)
	{
		// End:0x26
		if(bNext)
		{
			NextCameraMode();
			J0x0F:

			// End:0x23 [Loop If]
			if((!CameraIsAvailable()))
			{
				NextCameraMode();
				// [Loop Continue]
				goto J0x0F;
			}			
		}
		else
		{
			PreviousCameraMode();
			J0x2C:

			// End:0x40 [Loop If]
			if((!CameraIsAvailable()))
			{
				PreviousCameraMode();
				// [Loop Continue]
				goto J0x2C;
			}
		}
		return;
	}

	function bool CameraIsAvailable()
	{
		switch(m_eCameraMode)
		{
			// End:0x1A
			case 0:
				// End:0x17
				if(m_bCameraFirstPerson)
				{
					return true;
				}
				// End:0x56
				break;
			// End:0x2D
			case 1:
				// End:0x2A
				if(m_bCameraThirdPersonFixed)
				{
					return true;
				}
				// End:0x56
				break;
			// End:0x40
			case 2:
				// End:0x3D
				if(m_bCameraThirdPersonFree)
				{
					return true;
				}
				// End:0x56
				break;
			// End:0x53
			case 3:
				// End:0x50
				if(m_bCameraGhost)
				{
					return true;
				}
				// End:0x56
				break;
			// End:0xFFFF
			default:
				break;
		}
		return false;
		return;
	}

	exec function ToggleHelmetCameraZoom(optional bool bTurnOff)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		// End:0x1B
		if((int(Role) < int(ROLE_Authority)))
		{
			ServerExecFire(f);
		}
		// End:0x28
		if((ViewTarget == none))
		{
			return;
		}
		// End:0x65
		if((int(Level.NetMode) != int(NM_Client)))
		{
			// End:0x58
			if((f == float(0)))
			{
				SelectCameraMode(true);				
			}
			else
			{
				SelectCameraMode(false);
			}
			SetCameraMode();
		}
		return;
	}

	exec function AltFire(optional float f)
	{
		Fire(1.0000000);
		return;
	}

	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		// End:0x12
		if((int(m_eCameraMode) != int(3)))
		{
			return;
		}
		// End:0x34
		if((int(bRun) > 0))
		{
			Acceleration = (1.6000000 * NewAccel);			
		}
		else
		{
			Acceleration = NewAccel;
		}
		MoveSmooth((Acceleration * DeltaTime));
		return;
	}

	simulated function PlayerMove(float DeltaTime)
	{
		local Vector X, Y, Z;
		local Rotator rViewRotation;

		// End:0x76
		if((int(m_eCameraMode) == int(3)))
		{
			GetAxes(Rotation, X, Y, Z);
			Acceleration = (0.0500000 * (((aForward * X) + (aStrafe * Y)) + (aUp * vect(0.0000000, 0.0000000, 1.0000000))));
			UpdateRotation(DeltaTime, 1.0000000);			
		}
		else
		{
			m_fCurrentDeltaTime = DeltaTime;
			// End:0x1B0
			if(bBehindView)
			{
				// End:0x179
				if((!bFixedCamera))
				{
					GetAxes(Rotation, X, Y, Z);
					rViewRotation = Rotation;
					(rViewRotation.Yaw += int(((32.0000000 * DeltaTime) * aTurn)));
					(rViewRotation.Pitch += int(((32.0000000 * DeltaTime) * aLookUp)));
					rViewRotation.Pitch = (rViewRotation.Pitch & 65535);
					// End:0x16E
					if(((rViewRotation.Pitch > 16384) && (rViewRotation.Pitch < 49152)))
					{
						// End:0x15E
						if((aLookUp > float(0)))
						{
							rViewRotation.Pitch = 16384;							
						}
						else
						{
							rViewRotation.Pitch = 49152;
						}
					}
					SetRotation(rViewRotation);					
				}
				else
				{
					// End:0x1B0
					if((ViewTarget != none))
					{
						rViewRotation = ViewTarget.Rotation;
						rViewRotation.Pitch = -6000;
						SetRotation(rViewRotation);
					}
				}
			}
			// End:0x1C7
			if((m_bShakeActive == true))
			{
				ViewShake(DeltaTime);
			}
			ViewFlash(DeltaTime);
			Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		}
		// End:0x2F4
		if(Class'Engine.Actor'.static.GetModMgr().IsMissionPack())
		{
			// End:0x2A0
			if(((m_pawn != none) && m_pawn.m_bIsSurrended))
			{
				Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
				aForward = 0.0000000;
				aStrafe = 0.0000000;
				aTurn = 0.0000000;
				bRun = 0;
				Pawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
				ProcessMove(DeltaTime, Acceleration, 0, rot(0, 0, 0));				
			}
			else
			{
				// End:0x2D2
				if((int(Role) < int(ROLE_Authority)))
				{
					ReplicateMove(DeltaTime, Acceleration, 0, rot(0, 0, 0));					
				}
				else
				{
					ProcessMove(DeltaTime, Acceleration, 0, rot(0, 0, 0));
				}
			}			
		}
		else
		{
			// End:0x326
			if((int(Role) < int(ROLE_Authority)))
			{
				ReplicateMove(DeltaTime, Acceleration, 0, rot(0, 0, 0));				
			}
			else
			{
				ProcessMove(DeltaTime, Acceleration, 0, rot(0, 0, 0));
			}
		}
		return;
	}

	function ServerMove(float TimeStamp, Vector Accel, Vector ClientLoc, bool NewbRun, bool NewbDuck, bool NewbCrawl, int View, int iNewRotOffset, optional byte OldTimeDelta, optional int OldAccel)
	{
		// End:0x26
		if((int(m_eCameraMode) != int(3)))
		{
			Accel = vect(0.0000000, 0.0000000, 0.0000000);			
		}
		else
		{
			// End:0x50
			if((Accel == vect(0.0000000, 0.0000000, 0.0000000)))
			{
				Velocity = vect(0.0000000, 0.0000000, 0.0000000);
			}
			// End:0x6B
			if(NewbRun)
			{
				Accel = (1.6000000 * Accel);
			}
		}
		super(PlayerController).ServerMove(TimeStamp, Accel, ClientLoc, false, false, false, View, iNewRotOffset);
		return;
	}

	simulated function Tick(float fDeltaTime)
	{
		local Rotator rPitchOffset;

		m_iTeamId = PlayerReplicationInfo.TeamID;
		// End:0x26
		if((int(m_eCameraMode) == int(3)))
		{
			return;
		}
		// End:0x7E
		if(((ViewTarget == none) || (ViewTarget == self)))
		{
			// End:0x7C
			if((int(Level.NetMode) != int(NM_Client)))
			{
				SpectatorChangeTeams(true);
				// End:0x7C
				if(((ViewTarget != none) && (ViewTarget != self)))
				{
					SetCameraMode();
				}
			}
			return;
		}
		// End:0x113
		if((((m_bSpectatorCameraTeamOnly && ((m_iTeamId == int(2)) || (m_iTeamId == int(3)))) && (ViewTarget != none)) && (Pawn(ViewTarget).m_iTeam != m_iTeamId)))
		{
			// End:0x111
			if((int(Level.NetMode) != int(NM_Client)))
			{
				SpectatorChangeTeams(true);
				// End:0x111
				if(((ViewTarget != none) && (ViewTarget != self)))
				{
					SetCameraMode();
				}
			}
			return;
		}
		// End:0x146
		if((!bBehindView))
		{
			SetRotation((ViewTarget.Rotation + R6Pawn(ViewTarget).GetRotationOffset()));			
		}
		else
		{
			// End:0x160
			if(bFixedCamera)
			{
				SetRotation(ViewTarget.Rotation);
			}
		}
		SetLocation(ViewTarget.Location);
		return;
	}

	function SetCameraMode()
	{
		local Rotator rViewRotation;
		local Actor CamSpot;

		// End:0x70
		if((int(m_eCameraMode) != int(3)))
		{
			// End:0x70
			if((ViewTarget == self))
			{
				// End:0x28
				if((m_PrevViewTarget == none))
				{
					return;
				}
				// End:0x65
				if((int(Level.NetMode) == int(NM_Standalone)))
				{
					m_TeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, true);
				}
				SetNewViewTarget(m_PrevViewTarget);
			}
		}
		switch(m_eCameraMode)
		{
			// End:0xA3
			case 0:
				bBehindView = false;
				m_bAttachCameraToEyes = true;
				bCheatFlying = false;
				SetSpectatorRotation();
				DisplayClientMessage();
				// End:0x26F
				break;
			// End:0xD7
			case 1:
				bBehindView = true;
				bFixedCamera = true;
				m_bAttachCameraToEyes = true;
				bCheatFlying = false;
				SetSpectatorRotation();
				DisplayClientMessage();
				// End:0x26F
				break;
			// End:0x10B
			case 2:
				bBehindView = true;
				bFixedCamera = false;
				m_bAttachCameraToEyes = true;
				bCheatFlying = false;
				SetSpectatorRotation();
				DisplayClientMessage();
				// End:0x26F
				break;
			// End:0x26C
			case 3:
				// End:0x126
				if((ViewTarget != self))
				{
					m_PrevViewTarget = ViewTarget;
				}
				SetViewTarget(self);
				// End:0x18B
				if((m_PrevViewTarget == none))
				{
					CamSpot = Level.GetCamSpot(GameReplicationInfo.m_szGameTypeFlagRep);
					// End:0x188
					if((CamSpot != none))
					{
						SetRotation(CamSpot.Rotation);
						SetLocation(CamSpot.Location);
					}					
				}
				else
				{
					rViewRotation = m_PrevViewTarget.Rotation;
					rViewRotation.Pitch = -6000;
					SetRotation(rViewRotation);
					SetLocation((m_PrevViewTarget.Location - ((CameraDist * R6Pawn(m_PrevViewTarget).default.CollisionRadius) * Vector(Rotation))));
				}
				bBehindView = false;
				bFixedCamera = false;
				m_bAttachCameraToEyes = false;
				bCheatFlying = true;
				// End:0x25C
				if((int(Level.NetMode) == int(NM_Standalone)))
				{
					m_TeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, false, m_TeamManager.m_iIDVoicesMgr, true);					
				}
				else
				{
					m_TeamManager = none;
				}
				DisplayClientMessage();
				// End:0x26F
				break;
			// End:0xFFFF
			default:
				break;
		}
		return;
	}

	simulated function ChangeTeams(bool bNextTeam)
	{
		local R6RainbowTeam rainbowTeam;

		// End:0x1B
		if((int(Level.NetMode) != int(NM_Standalone)))
		{
			return;
		}
		// End:0x2D
		if((int(m_eCameraMode) == int(3)))
		{
			return;
		}
		rainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetNewTeam(m_TeamManager, bNextTeam));
		// End:0x6D
		if((rainbowTeam == none))
		{
			return;
		}
		SetNewViewTarget(rainbowTeam.m_Team[0]);
		DisplayClientMessage();
		return;
	}

	function ServerChangeTeams(bool bNextTeam)
	{
		SpectatorChangeTeams(bNextTeam);
		return;
	}

	function ValidateCameraTeamId()
	{
		// End:0x2A
		if(((m_MenuCommunication != none) && (int(m_TeamSelection) != int(2))))
		{
			m_iTeamId = int(2);			
		}
		else
		{
			m_iTeamId = int(3);
		}
		return;
	}

	function SpectatorChangeTeams(bool bNextTeam)
	{
		local R6Rainbow Other, first, Last;
		local bool bFound;

		// End:0x35
		if(((Level.Game != none) && (!Level.Game.bCanViewOthers)))
		{
			return;
		}
		// End:0x51
		if((m_bSpectatorCameraTeamOnly && (m_iTeamId == 0)))
		{
			ValidateCameraTeamId();
		}
		// End:0x10E
		if(bNextTeam)
		{
			first = none;
			// End:0xEF
			foreach AllActors(Class'R6Engine.R6Rainbow', Other)
			{
				// End:0xEE
				if(Other.IsAlive())
				{
					// End:0xAA
					if((m_bSpectatorCameraTeamOnly && (Other.m_iTeam != m_iTeamId)))
					{
						continue;						
					}
					// End:0xD7
					if((bFound || (first == none)))
					{
						first = Other;
						// End:0xD7
						if(bFound)
						{
							// End:0xEF
							break;
						}
					}
					// End:0xEE
					if((Other == ViewTarget))
					{
						bFound = true;
					}
				}				
			}			
			// End:0x109
			if((first != none))
			{
				SetNewViewTarget(first);				
			}
			else
			{
				return;
			}			
		}
		else
		{
			Last = none;
			// End:0x189
			foreach AllActors(Class'R6Engine.R6Rainbow', Other)
			{
				// End:0x188
				if(Other.IsAlive())
				{
					// End:0x15E
					if((m_bSpectatorCameraTeamOnly && (Other.m_iTeam != m_iTeamId)))
					{
						continue;						
					}
					// End:0x17D
					if(((Other == ViewTarget) && (Last != none)))
					{
						// End:0x189
						break;
					}
					Last = Other;
				}				
			}			
			// End:0x1A3
			if((Last != none))
			{
				SetNewViewTarget(Last);				
			}
			else
			{
				return;
			}
		}
		return;
	}

	event ClientSetNewViewTarget()
	{
		// End:0x1B
		if((int(Level.NetMode) != int(NM_Client)))
		{
			return;
		}
		// End:0x31
		if((ViewTarget != self))
		{
			m_PrevViewTarget = ViewTarget;
		}
		SetNewViewTarget(ViewTarget);
		// End:0x4D
		if((ViewTarget != none))
		{
			SetCameraMode();
		}
		return;
	}

	simulated function SetNewViewTarget(Actor aViewTarget)
	{
		local R6Rainbow aPawn;
		local R6RainbowTeam aOldTeamManager;

		// End:0x12
		if((int(m_eCameraMode) == int(3)))
		{
			return;
		}
		aPawn = R6Rainbow(aViewTarget);
		// End:0x2F
		if((aPawn == none))
		{
			return;
		}
		SetViewTarget(aPawn);
		// End:0x164
		if((aPawn.Controller != none))
		{
			aOldTeamManager = m_TeamManager;
			// End:0x92
			if((!aPawn.m_bIsPlayer))
			{
				m_TeamManager = R6RainbowAI(aPawn.Controller).m_TeamManager;				
			}
			else
			{
				m_TeamManager = R6PlayerController(aPawn.Controller).m_TeamManager;
			}
			// End:0x164
			if((((((int(Role) == int(ROLE_Authority)) && (aOldTeamManager != none)) && (aOldTeamManager != m_TeamManager)) && (!aOldTeamManager.m_bLeaderIsAPlayer)) && (!m_TeamManager.m_bLeaderIsAPlayer)))
			{
				aOldTeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, false, m_TeamManager.m_iIDVoicesMgr);
				m_TeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, true);
			}
		}
		SetSpectatorRotation();
		FixFOV();
		// End:0x1A1
		if(((int(Level.NetMode) == int(NM_ListenServer)) && (Viewport(Player) != none)))
		{
			DisplayClientMessage();
		}
		return;
	}

	exec function NextMember()
	{
		local int i;

		// End:0x12
		if((int(m_eCameraMode) == int(3)))
		{
			return;
		}
		// End:0x9D
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			// End:0x9A
			if((m_TeamManager.m_iMemberCount > 0))
			{
				i = (R6Pawn(ViewTarget).m_iID + 1);
				// End:0x7A
				if((i >= m_TeamManager.m_iMemberCount))
				{
					i = 0;
				}
				SetViewTarget(m_TeamManager.m_Team[i]);
				DisplayClientMessage();
			}			
		}
		else
		{
			ServerChangeTeams(true);
		}
		return;
	}

	exec function PreviousMember()
	{
		local int i;

		// End:0x12
		if((int(m_eCameraMode) == int(3)))
		{
			return;
		}
		// End:0xA0
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			// End:0x9D
			if((m_TeamManager.m_iMemberCount > 0))
			{
				i = (R6Pawn(ViewTarget).m_iID - 1);
				// End:0x7D
				if((i < 0))
				{
					i = (m_TeamManager.m_iMemberCount - 1);
				}
				SetViewTarget(m_TeamManager.m_Team[i]);
				DisplayClientMessage();
			}			
		}
		else
		{
			ServerChangeTeams(false);
		}
		return;
	}

	function string GetViewTargetName()
	{
		local R6Pawn targetPawn;

		// End:0x0E
		if((ViewTarget == none))
		{
			return "";
		}
		targetPawn = R6Pawn(ViewTarget);
		// End:0x2C
		if((targetPawn == none))
		{
			return "";
		}
		// End:0x98
		if(targetPawn.m_bIsPlayer)
		{
			// End:0x69
			if((int(Level.NetMode) == int(NM_Standalone)))
			{
				return targetPawn.m_CharacterName;				
			}
			else
			{
				// End:0x95
				if((targetPawn.PlayerReplicationInfo != none))
				{
					return targetPawn.PlayerReplicationInfo.PlayerName;
				}
			}			
		}
		else
		{
			return targetPawn.m_CharacterName;
		}
		return;
	}

	function DisplayClientMessage()
	{
		local string targetName;

		// End:0x0D
		if((ViewTarget == none))
		{
			return;
		}
		// End:0x1E9
		if((((int(Level.NetMode) == int(NM_Client)) || (int(Level.NetMode) == int(NM_Standalone))) || ((int(Level.NetMode) == int(NM_ListenServer)) && (Viewport(Player) != none))))
		{
			// End:0xA4
			if(bCheatFlying)
			{
				ClientMessage(Localize("Game", "GhostCamera", "R6GameInfo"));
				return;
			}
			targetName = GetViewTargetName();
			// End:0xBE
			if((targetName == ""))
			{
				return;
			}
			// End:0x124
			if((!bBehindView))
			{
				ClientMessage(((Localize("Game", "NowViewing", "R6GameInfo") @ targetName) @ Localize("Game", "FirstCamera", "R6GameInfo")));				
			}
			else
			{
				// End:0x18D
				if(bFixedCamera)
				{
					ClientMessage(((Localize("Game", "NowViewing", "R6GameInfo") @ targetName) @ Localize("Game", "FixedThirdCamera", "R6GameInfo")));					
				}
				else
				{
					ClientMessage(((Localize("Game", "NowViewing", "R6GameInfo") @ targetName) @ Localize("Game", "FreeThirdCamera", "R6GameInfo")));
				}
			}
		}
		return;
	}
	stop;
}

state PlayerStartSurrenderSequence extends PlayerWalking
{
	function BeginState()
	{
		local SavedMove Next, Current;

		// End:0x13
		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
		Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		Pawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		// End:0x82
		if(m_pawn.m_bMovingDiagonally)
		{
			m_pawn.ResetDiagonalStrafing();
		}
		bRun = 0;
		m_bPeekLeft = 0;
		m_bPeekRight = 0;
		m_fStartSurrenderTime = Level.TimeSeconds;
		// End:0xD6
		if((int(m_pawn.m_eGrenadeThrow) != int(0)))
		{
			m_pawn.GrenadeAnimEnd();
		}
		// End:0xF6
		if(Pawn.IsLocallyControlled())
		{
			ToggleHelmetCameraZoom(true);
			DoZoom(true);
		}
		ToggleHelmetCameraZoom(true);
		SetPeekingInfo(0, m_pawn.1000.0000000);
		ResetFluidPeeking();
		// End:0x1D0
		if(m_pawn.m_bIsClimbingLadder)
		{
			Pawn.SetPhysics(2);
			Pawn.OnLadder = none;
			m_pawn.m_bSlideEnd = false;
			m_pawn.m_bIsClimbingLadder = false;
			m_pawn.m_bPostureTransition = false;
			m_pawn.m_Ladder = none;
			Pawn.SetLocation((Pawn.Location + (float(25) * Vector(Pawn.Rotation))));
			m_pawn.PlayFalling();			
		}
		else
		{
			// End:0x23C
			if(m_bCrawl)
			{
				m_pawn.m_bWantsToProne = false;
				// End:0x213
				if((int(Level.NetMode) == int(NM_Client)))
				{
					m_pawn.ServerSetCrouch(true);
				}
				m_pawn.bWantsToCrouch = true;
				RaisePosture();
				m_pawn.EndCrawl();				
			}
			else
			{
				// End:0x2E7
				if((int(bDuck) != 0))
				{
					// End:0x275
					if((int(Level.NetMode) == int(NM_Client)))
					{
						m_pawn.ServerSetCrouch(false);						
					}
					else
					{
						m_pawn.ClientSetCrouch(false);
					}
					m_pawn.bWantsToCrouch = false;
					m_pawn.m_bPostureTransition = false;
					RaisePosture();
					// End:0x2DD
					if((m_pawn.m_bReloadingWeapon || m_pawn.m_bChangingWeapon))
					{
						GotoState('PlayerFinishReloadingBeforeSurrender');						
					}
					else
					{
						GotoState('PlayerPreBeginSurrending');
					}					
				}
				else
				{
					// End:0x317
					if((m_pawn.m_bReloadingWeapon || m_pawn.m_bChangingWeapon))
					{
						GotoState('PlayerFinishReloadingBeforeSurrender');						
					}
					else
					{
						// End:0x337
						if((int(Pawn.Physics) != int(2)))
						{
							GotoState('PlayerPreBeginSurrending');
						}
					}
				}
			}
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		// End:0x2C
		if((int(Level.NetMode) == int(NM_Client)))
		{
			m_pawn.ServerSetCrouch(false);			
		}
		else
		{
			m_pawn.ClientSetCrouch(false);
		}
		m_pawn.bWantsToCrouch = false;
		return;
	}

	event Tick(float fDiffTime)
	{
		// End:0x74
		if((((((int(Role) == int(ROLE_Authority)) && (int(Pawn.Physics) != int(2))) && (!Pawn.m_bIsLanding)) && (!m_bCrawl)) && (int(bDuck) == 0)))
		{
			GotoState('PlayerPreBeginSurrending');
			ClientGotoState('PlayerPreBeginSurrending', 'None');
		}
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		// End:0x51
		if((int(Pawn.Physics) != int(2)))
		{
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			Pawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		}
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aTurn = 0.0000000;
		bRun = 0;
		m_bPeekLeft = 0;
		m_bPeekRight = 0;
		// End:0xC4
		if((int(Role) < int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));			
		}
		else
		{
			ProcessMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));
		}
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	// no chit chat while surrended/arrested
	exec function Say(string Msg)
	{
		return;
	}

	exec function TeamSay(string Msg)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x74
		if(((iChannel == m_pawn.1) && (int(bDuck) != 0)))
		{
			m_pawn.m_bPostureTransition = false;
			RaisePosture();
			// End:0x6A
			if((m_pawn.m_bReloadingWeapon || m_pawn.m_bChangingWeapon))
			{
				GotoState('PlayerFinishReloadingBeforeSurrender');				
			}
			else
			{
				GotoState('PlayerPreBeginSurrending');
			}			
		}
		else
		{
			m_pawn.AnimEnd(iChannel);
		}
		return;
	}

// NEW IN 1.60
	function VeryShortClientAdjustPosition(float TimeStamp, float NewLocX, float NewLocY, float NewLocZ, Actor NewBase)
	{
		local Vector Floor;

		// End:0x1F
		if((Pawn != none))
		{
			Floor = Pawn.Floor;
		}
		// End:0x3A
		if((int(Pawn.Physics) != int(1)))
		{
			return;
		}
		m_bSkipBeginState = true;
		LongClientAdjustPosition(TimeStamp, 'PlayerStartSurrenderSequence', 1, NewLocX, NewLocY, NewLocZ, 0.0000000, 0.0000000, 0.0000000, NewBase, Floor.X, Floor.Y, Floor.Z);
		m_bSkipBeginState = false;
		return;
	}
	stop;
}

state PlayerFinishReloadingBeforeSurrender
{
	function BeginState()
	{
		return;
	}

	event AnimEnd(int iChannel)
	{
		m_pawn.AnimEnd(iChannel);
		// End:0x30
		if((iChannel == m_pawn.14))
		{
			GotoState('PlayerPreBeginSurrending');
		}
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	// no chit chat while surrended/arrested
	exec function Say(string Msg)
	{
		return;
	}

	exec function TeamSay(string Msg)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	function ServerMove(float TimeStamp, Vector Accel, Vector ClientLoc, bool NewbRun, bool NewbDuck, bool NewbCrawl, int View, int iNewRotOffset, optional byte OldTimeDelta, optional int OldAccel)
	{
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aTurn = 0.0000000;
		bRun = 0;
		m_bPeekLeft = 0;
		m_bPeekRight = 0;
		// End:0x8F
		if((int(Role) < int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));			
		}
		else
		{
			ProcessMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));
		}
		return;
	}
	stop;
}

state PlayerPreBeginSurrending extends CameraPlayer
{
	function BeginState()
	{
		local R6AbstractWeapon AWeapon;
		local Rotator newRot;

		// End:0x15D
		if(((Pawn.IsLocallyControlled() && (int(m_eCameraMode) == int(0))) && (int(Level.NetMode) != int(NM_DedicatedServer))))
		{
			newRot.Pitch = ViewTarget.Rotation.Pitch;
			newRot.Yaw = ViewTarget.Rotation.Yaw;
			newRot.Roll = 0;
			ViewTarget.SetRotation(newRot);
			DoZoom(true);
			bZooming = false;
			m_bHelmetCameraOn = false;
			DefaultFOV = default.DefaultFOV;
			DesiredFOV = default.DesiredFOV;
			FovAngle = default.DesiredFOV;
			HelmetCameraZoom(1.0000000);
			R6Pawn(Pawn).ToggleHeatProperties(false, none, none);
			R6Pawn(Pawn).ToggleNightProperties(false, none, none);
			R6Pawn(Pawn).ToggleScopeProperties(false, none, none);
			Level.m_bHeartBeatOn = false;
			Level.m_bInGamePlanningActive = false;
			SetPlanningMode(false);
			m_eCameraMode = 2;
			// End:0x157
			if((!CameraIsAvailable()))
			{
				SelectCameraMode(true);
			}
			SetCameraMode();
		}
		Pawn.m_fRemainingGrenadeTime = 0.0000000;
		// End:0x289
		if(((m_pawn.EngineWeapon != none) && (!((Pawn.EngineWeapon.IsA('R6GrenadeWeapon') || Pawn.EngineWeapon.IsA('R6HBSSAJammerGadget')) && (!Pawn.EngineWeapon.HasAmmo())))))
		{
			// End:0x212
			if((int(m_pawn.m_bIsFiringWeapon) != 0))
			{
				m_pawn.EngineWeapon.ServerStopFire();
			}
			// End:0x277
			if((!m_pawn.EngineWeapon.IsInState('PutWeaponDown')))
			{
				m_pawn.EngineWeapon.GotoState('PutWeaponDown');
				// End:0x274
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(27);
				}				
			}
			else
			{
				m_bSkipBeginState = false;
				GotoState('PlayerStartSurrending');
			}			
		}
		else
		{
			m_bSkipBeginState = false;
			GotoState('PlayerStartSurrending');
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		m_pawn.m_bWeaponTransition = false;
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	// no chit chat while surrended/arrested
	exec function Say(string Msg)
	{
		return;
	}

	exec function TeamSay(string Msg)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x27
		if((iChannel == m_pawn.14))
		{
			m_bSkipBeginState = false;
			GotoState('PlayerStartSurrending');			
		}
		else
		{
			m_pawn.AnimEnd(iChannel);
		}
		return;
	}

	function SwitchWeapon(byte f)
	{
		return;
	}

	exec function PreviousMember()
	{
		return;
	}

	exec function NextMember()
	{
		return;
	}

	simulated function ChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ServerChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ValidateCameraTeamId()
	{
		return;
	}

	function SpectatorChangeTeams(bool bNextTeam)
	{
		return;
	}

	event ClientSetNewViewTarget()
	{
		return;
	}

	simulated function SetNewViewTarget(Actor aViewTarget)
	{
		return;
	}
	stop;
}

state PlayerStartSurrending extends CameraPlayer
{
	function BeginState()
	{
		// End:0x13
		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
		// End:0x3D
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_pawn.SetNextPendingAction(40);
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		m_pawn.m_bPostureTransition = false;
		m_pawn.m_bPawnSpecificAnimInProgress = false;
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x1F
		if((iChannel == m_pawn.16))
		{
			GotoState('PlayerSurrended');			
		}
		else
		{
			// End:0x5C
			if(((Level.TimeSeconds - m_fStartSurrenderTime) > float(2)))
			{
				m_pawn.EngineWeapon.ServerStopFire();
				GotoState('PlayerSurrended');
			}
		}
		return;
	}

	function SwitchWeapon(byte f)
	{
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	// no chit chat while surrended/arrested
	exec function Say(string Msg)
	{
		return;
	}

	exec function TeamSay(string Msg)
	{
		return;
	}

	exec function PreviousMember()
	{
		return;
	}

	exec function NextMember()
	{
		return;
	}

	simulated function ChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ServerChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ValidateCameraTeamId()
	{
		return;
	}

	function SpectatorChangeTeams(bool bNextTeam)
	{
		return;
	}

	event ClientSetNewViewTarget()
	{
		return;
	}

	simulated function SetNewViewTarget(Actor aViewTarget)
	{
		return;
	}
	stop;
}

state PlayerSurrended extends CameraPlayer
{
	function BeginState()
	{
		m_pawn.bInvulnerableBody = false;
		// End:0x3B
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_pawn.SetNextPendingAction(31);
		}
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x3F
		if((iChannel == m_pawn.16))
		{
			// End:0x3F
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(31);
			}
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		m_pawn.m_bPawnSpecificAnimInProgress = false;
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	exec function ToggleHelmetCameraZoom(optional bool bTurnOff)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	// no chit chat while surrended/arrested
	exec function Say(string Msg)
	{
		return;
	}

	exec function TeamSay(string Msg)
	{
		return;
	}

	function SwitchWeapon(byte f)
	{
		return;
	}

	event Tick(float fDeltaTime)
	{
		// End:0xA6
		if(((((int(Role) == int(ROLE_Authority)) && ((Level.TimeSeconds - m_fStartSurrenderTime) > float(10))) && (!m_pawn.m_bIsUnderArrest)) && (!m_pawn.m_bIsBeingArrestedOrFreed)))
		{
			m_bSkipBeginState = false;
			m_pawn.m_eHealth = 0;
			m_pawn.m_bIsSurrended = false;
			// End:0x9C
			if((int(Role) == int(ROLE_Authority)))
			{
				ClientEndSurrended();
			}
			GotoState('PlayerEndSurrended');			
		}
		else
		{
			// End:0xBF
			if(m_pawn.m_bIsBeingArrestedOrFreed)
			{
				GotoState('PlayerStartArrest');
			}
		}
		return;
	}

	exec function PreviousMember()
	{
		return;
	}

	exec function NextMember()
	{
		return;
	}

	simulated function ChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ServerChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ValidateCameraTeamId()
	{
		return;
	}

	function SpectatorChangeTeams(bool bNextTeam)
	{
		return;
	}

	event ClientSetNewViewTarget()
	{
		return;
	}

	simulated function SetNewViewTarget(Actor aViewTarget)
	{
		return;
	}
	stop;
}

state PlayerEndSurrended extends CameraPlayer
{
	function BeginState()
	{
		// End:0x13
		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
		m_fStartSurrenderTime = Level.TimeSeconds;
		m_pawn.bInvulnerableBody = true;
		// End:0x62
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_pawn.SetNextPendingAction(39);
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		EndSurrenderSetUp();
		// End:0x4A
		if((Pawn.IsLocallyControlled() && (int(m_eCameraMode) == int(2))))
		{
			m_eCameraMode = 0;
			// End:0x44
			if((!CameraIsAvailable()))
			{
				SelectCameraMode(true);
			}
			SetCameraMode();
		}
		m_pawn.m_bPawnSpecificAnimInProgress = false;
		// End:0x153
		if(((m_pawn.EngineWeapon != none) && (!((Pawn.EngineWeapon.IsA('R6GrenadeWeapon') || Pawn.EngineWeapon.IsA('R6HBSSAJammerGadget')) && (!Pawn.EngineWeapon.HasAmmo())))))
		{
			// End:0x110
			if((Pawn.EngineWeapon.IsA('R6GrenadeWeapon') || Pawn.EngineWeapon.IsA('R6HBSSAJammerGadget')))
			{
				WeaponUpState();
			}
			Pawn.EngineWeapon.GotoState('BringWeaponUp');
			// End:0x153
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(28);
			}
		}
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x46
		if((iChannel == m_pawn.16))
		{
			// End:0x3F
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(41);
			}
			GotoState('PlayerWalking');
		}
		return;
	}

	function EndSurrenderSetUp()
	{
		m_pawn.m_bPostureTransition = false;
		// End:0x35
		if((int(Role) == int(ROLE_Authority)))
		{
			m_fStartSurrenderTime = Level.TimeSeconds;
		}
		return;
	}

	function SwitchWeapon(byte f)
	{
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	// no chit chat while surrended/arrested
	exec function Say(string Msg)
	{
		return;
	}

	exec function TeamSay(string Msg)
	{
		return;
	}

	function ValidateCameraTeamId()
	{
		return;
	}

	exec function PreviousMember()
	{
		return;
	}

	exec function NextMember()
	{
		return;
	}

	simulated function ChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ServerChangeTeams(bool bNextTeam)
	{
		return;
	}

	function SpectatorChangeTeams(bool bNextTeam)
	{
		return;
	}

	event ClientSetNewViewTarget()
	{
		return;
	}

	simulated function SetNewViewTarget(Actor aViewTarget)
	{
		return;
	}
	stop;
}

state PlayerSecureRainbow
{
	function BeginState()
	{
		// End:0x4D
		if((m_PlayerCurrentCA.aQueryTarget != none))
		{
			R6PlayerController(R6Rainbow(m_PlayerCurrentCA.aQueryTarget).Controller).m_fStartSurrenderTime = Level.TimeSeconds;
		}
		// End:0x162
		if((m_pawn.EngineWeapon != none))
		{
			// End:0x11F
			if(Pawn.IsLocallyControlled())
			{
				ToggleHelmetCameraZoom(true);
				DoZoom(true);
				bZooming = false;
				m_bHelmetCameraOn = false;
				DefaultFOV = default.DefaultFOV;
				DesiredFOV = default.DesiredFOV;
				FovAngle = default.DesiredFOV;
				HelmetCameraZoom(1.0000000);
				R6Pawn(Pawn).ToggleHeatProperties(false, none, none);
				R6Pawn(Pawn).ToggleNightProperties(false, none, none);
				R6Pawn(Pawn).ToggleScopeProperties(false, none, none);
				Level.m_bHeartBeatOn = false;
				Level.m_bInGamePlanningActive = false;
				SetPlanningMode(false);
			}
			Pawn.EngineWeapon.GotoState('PutWeaponDown');
			// End:0x162
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(27);
			}
		}
		SetPeekingInfo(0, m_pawn.1000.0000000);
		ResetFluidPeeking();
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		local R6AbstractGameInfo pGameInfo;
		local string arrestorName;

		// End:0x70
		if((m_iPlayerCAProgress < 100))
		{
			m_pawn.R6ResetAnimBlendParams(m_pawn.1);
			// End:0x6D
			if((m_bIsSecuringRainbow && R6Rainbow(m_PlayerCurrentCA.aQueryTarget).m_bIsSurrended))
			{
				R6Rainbow(m_PlayerCurrentCA.aQueryTarget).ResetArrest();
			}			
		}
		else
		{
			// End:0x37B
			if((int(Level.NetMode) != int(NM_Client)))
			{
				// End:0x33B
				if(m_bIsSecuringRainbow)
				{
					R6Rainbow(m_PlayerCurrentCA.aQueryTarget).m_bIsBeingArrestedOrFreed = false;
					// End:0x338
					if(R6Rainbow(m_PlayerCurrentCA.aQueryTarget).m_bIsSurrended)
					{
						R6Rainbow(m_PlayerCurrentCA.aQueryTarget).m_bIsUnderArrest = true;
						R6AbstractGameInfo(Level.Game).PawnSecure(R6Rainbow(m_PlayerCurrentCA.aQueryTarget));
						m_pawn.IncrementFragCount();
						// End:0x163
						if((m_pawn.PlayerReplicationInfo != none))
						{
							arrestorName = m_pawn.PlayerReplicationInfo.PlayerName;							
						}
						else
						{
							arrestorName = m_pawn.m_CharacterName;
						}
						pGameInfo = R6AbstractGameInfo(Level.Game);
						// End:0x338
						if((pGameInfo != none))
						{
							// End:0x338
							if(((pGameInfo.m_bCompilingStats == true) || (pGameInfo.m_bGameOver && pGameInfo.m_bGameOverButAllowDeath)))
							{
								// End:0x338
								if((R6Pawn(m_PlayerCurrentCA.aQueryTarget).PlayerReplicationInfo != none))
								{
									R6Pawn(m_PlayerCurrentCA.aQueryTarget).PlayerReplicationInfo.m_szKillersName = arrestorName;
									(R6Pawn(m_PlayerCurrentCA.aQueryTarget).PlayerReplicationInfo.Deaths += 1.0000000);
									// End:0x338
									if(((((!R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_bSuicided) && (R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy != none)) && (R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy.Controller != none)) && (R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy.Controller.PlayerReplicationInfo != none)))
									{
										(R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy.Controller.PlayerReplicationInfo.Score += 1.0000000);
									}
								}
							}
						}
					}					
				}
				else
				{
					R6PlayerController(R6Rainbow(m_PlayerCurrentCA.aQueryTarget).Controller).DispatchOrder(int(m_PlayerCurrentCA.iPlayerActionID), m_pawn);
				}
			}
		}
		m_iPlayerCAProgress = 0;
		m_pawn.m_bPostureTransition = false;
		// End:0x41E
		if((!m_pawn.m_bIsSurrended))
		{
			m_pawn.m_ePlayerIsUsingHands = 0;
			// End:0x41E
			if((m_pawn.EngineWeapon != none))
			{
				Pawn.EngineWeapon.GotoState('BringWeaponUp');
				// End:0x40F
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(28);
				}
				m_pawn.RainbowEquipWeapon();
			}
		}
		return;
	}

	function PlayerMove(float fDeltaTime)
	{
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aMouseX = 0.0000000;
		aMouseY = 0.0000000;
		aTurn = 0.0000000;
		m_bPeekLeft = 0;
		m_bPeekRight = 0;
		global.PlayerMove(fDeltaTime);
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x11C
		if(((iChannel == m_pawn.1) && m_pawn.m_bPostureTransition))
		{
			// End:0x84
			if(bShowLog)
			{
				Log("SecureRainbow: AnimEnd, END Secure/Free rainbow animation, switch playerwalking");
			}
			m_pawn.m_bPostureTransition = false;
			m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
			m_iPlayerCAProgress = 100;
			// End:0xDF
			if((int(Level.NetMode) == int(NM_DedicatedServer)))
			{
				ClientActionProgressDone();
			}
			// End:0xF9
			if((m_InteractionCA != none))
			{
				m_InteractionCA.ActionProgressDone();
			}
			// End:0x119
			if((int(Level.NetMode) != int(NM_Client)))
			{
				GotoState('PlayerWalking');
			}			
		}
		else
		{
			// End:0x328
			if(((iChannel == m_pawn.14) && (int(m_pawn.m_eEquipWeapon) == int(m_pawn.2))))
			{
				// End:0x19D
				if(bShowLog)
				{
					Log("SecureRainbow: AnimEnd, start Secure/Free rainbow animation");
				}
				m_pawn.m_bWeaponTransition = false;
				m_pawn.m_bPostureTransition = false;
				m_pawn.PlaySecureTerrorist();
				m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
				m_bIsSecuringRainbow = (int(m_PlayerCurrentCA.iPlayerActionID) == int(m_pawn.1));
				// End:0x29C
				if(bShowLog)
				{
					Log(((("SecureRainbow: AnimEnd $ start Secure/Free rainbow animation. CircAction=") $ " m_bIsSecuringRainbow=") $ string(m_bIsSecuringRainbow)));
				}
				// End:0x328
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(29);
					// End:0x328
					if((int(m_PlayerCurrentCA.iPlayerActionID) == int(m_pawn.1)))
					{
						R6PlayerController(R6Rainbow(m_PlayerCurrentCA.aQueryTarget).Controller).DispatchOrder(int(m_PlayerCurrentCA.iPlayerActionID), m_pawn);
					}
				}
			}
		}
		return;
	}

	event Tick(float fDeltaTime)
	{
		// End:0x3A
		if(((m_pawn.EngineWeapon != none) && (int(m_pawn.m_eEquipWeapon) != int(m_pawn.2))))
		{
			return;
		}
		// End:0x50
		if((!m_pawn.m_bPostureTransition))
		{
			return;
		}
		// End:0x88
		if((int(Role) == int(ROLE_Authority)))
		{
			m_iPlayerCAProgress = m_PlayerCurrentCA.aQueryTarget.R6GetCircumstantialActionProgress(m_PlayerCurrentCA, m_pawn);
		}
		return;
	}
	stop;
}

state PlayerStartArrest extends CameraPlayer
{
	function BeginState()
	{
		// End:0x13
		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
		// End:0x3D
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_pawn.SetNextPendingAction(33);
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		m_pawn.m_bIsBeingArrestedOrFreed = false;
		m_pawn.m_bPawnSpecificAnimInProgress = false;
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	exec function ToggleHelmetCameraZoom(optional bool bTurnOff)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	// no chit chat while surrended/arrested
	exec function Say(string Msg)
	{
		return;
	}

	exec function TeamSay(string Msg)
	{
		return;
	}

	function SwitchWeapon(byte f)
	{
		return;
	}

	event AnimEnd(int iChannel)
	{
		local name Anim;
		local float fFrame, fRate;

		// End:0x81
		if((iChannel == m_pawn.16))
		{
			Pawn.GetAnimParams(m_pawn.16, Anim, fFrame, fRate);
			// End:0x7A
			if((Anim == 'SurrenderToKneel'))
			{
				// End:0x77
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(43);
				}				
			}
			else
			{
				GotoState('PlayerArrested');
			}
		}
		return;
	}

	exec function PreviousMember()
	{
		return;
	}

	exec function NextMember()
	{
		return;
	}

	simulated function ChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ServerChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ValidateCameraTeamId()
	{
		return;
	}

	function SpectatorChangeTeams(bool bNextTeam)
	{
		return;
	}

	event ClientSetNewViewTarget()
	{
		return;
	}

	simulated function SetNewViewTarget(Actor aViewTarget)
	{
		return;
	}
	stop;
}

state PlayerArrested extends CameraPlayer
{
	function BeginState()
	{
		local string myName, arrestorName;

		// End:0x13
		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
		// End:0x47
		if((m_pawn.PlayerReplicationInfo != none))
		{
			myName = m_pawn.PlayerReplicationInfo.PlayerName;			
		}
		else
		{
			myName = m_pawn.m_CharacterName;
		}
		// End:0x112
		if((m_pInteractingRainbow != none))
		{
			// End:0x9A
			if((m_pInteractingRainbow.PlayerReplicationInfo != none))
			{
				arrestorName = m_pInteractingRainbow.PlayerReplicationInfo.PlayerName;				
			}
			else
			{
				arrestorName = m_pInteractingRainbow.m_CharacterName;
			}
			myHUD.AddDeathTextMessage(((((arrestorName $ " ") $ Localize("MPMiscMessages", "PlayerArrestedPlayer", "ASGameMode")) $ " ") $ myName), Class'Engine.LocalMessage');
		}
		// End:0x13C
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_pawn.SetNextPendingAction(44);
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		m_pawn.m_bPawnSpecificAnimInProgress = false;
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	exec function ToggleHelmetCameraZoom(optional bool bTurnOff)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	// no chit chat while surrended/arrested
	exec function Say(string Msg)
	{
		return;
	}

	exec function TeamSay(string Msg)
	{
		return;
	}

	function SwitchWeapon(byte f)
	{
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x4E
		if((iChannel == m_pawn.16))
		{
			// End:0x3F
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(44);
			}
			m_pawn.SetCollision(true, false, false);
		}
		return;
	}

	exec function PreviousMember()
	{
		return;
	}

	exec function NextMember()
	{
		return;
	}

	simulated function ChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ServerChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ValidateCameraTeamId()
	{
		return;
	}

	function SpectatorChangeTeams(bool bNextTeam)
	{
		return;
	}

	event ClientSetNewViewTarget()
	{
		return;
	}

	simulated function SetNewViewTarget(Actor aViewTarget)
	{
		return;
	}
	stop;
}

state PlayerSetFree extends CameraPlayer
{
	function BeginState()
	{
		local string myName, rescuerName;

		// End:0x44
		if((Pawn.IsLocallyControlled() && (int(m_eCameraMode) == int(2))))
		{
			m_eCameraMode = 0;
			// End:0x3E
			if((!CameraIsAvailable()))
			{
				SelectCameraMode(true);
			}
			SetCameraMode();
		}
		// End:0x57
		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
		m_pawn.m_bIsUnderArrest = false;
		m_pawn.m_bIsSurrended = false;
		m_fStartSurrenderTime = Level.TimeSeconds;
		m_pawn.bInvulnerableBody = true;
		// End:0xD9
		if((int(Level.NetMode) != int(NM_Client)))
		{
			R6AbstractGameInfo(Level.Game).PawnSecure(m_pawn);
		}
		// End:0x103
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_pawn.SetNextPendingAction(45);
		}
		m_pawn.SetCollision(true, true, true);
		// End:0x146
		if((m_pawn.PlayerReplicationInfo != none))
		{
			myName = m_pawn.PlayerReplicationInfo.PlayerName;			
		}
		else
		{
			myName = m_pawn.m_CharacterName;
		}
		// End:0x20A
		if((m_pInteractingRainbow != none))
		{
			// End:0x199
			if((m_pInteractingRainbow.PlayerReplicationInfo != none))
			{
				rescuerName = m_pInteractingRainbow.PlayerReplicationInfo.PlayerName;				
			}
			else
			{
				rescuerName = m_pInteractingRainbow.m_CharacterName;
			}
			myHUD.AddDeathTextMessage(((((myName $ " ") $ Localize("MPMiscMessages", "PlayerRescued", "ASGameMode")) $ " ") $ rescuerName), Class'Engine.LocalMessage');
		}
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	// no chit chat while surrended/arrested
	exec function Say(string Msg)
	{
		return;
	}

	exec function TeamSay(string Msg)
	{
		return;
	}

	exec function ToggleHelmetCameraZoom(optional bool bTurnOff)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		// End:0x111
		if(((m_pawn.EngineWeapon != none) && (!((Pawn.EngineWeapon.IsA('R6GrenadeWeapon') || Pawn.EngineWeapon.IsA('R6HBSSAJammerGadget')) && (!Pawn.EngineWeapon.HasAmmo())))))
		{
			// End:0xB5
			if((Pawn.EngineWeapon.IsA('R6GrenadeWeapon') || Pawn.EngineWeapon.IsA('R6HBSSAJammerGadget')))
			{
				WeaponUpState();
			}
			// End:0xE7
			if((int(Level.NetMode) != int(NM_Client)))
			{
				Pawn.EngineWeapon.GotoState('BringWeaponUp');
			}
			// End:0x111
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(28);
			}
		}
		m_fStartSurrenderTime = Level.TimeSeconds;
		m_pawn.m_bPawnSpecificAnimInProgress = false;
		m_pawn.m_bIsBeingArrestedOrFreed = false;
		m_pawn.m_bPostureTransition = false;
		return;
	}

	event AnimEnd(int iChannel)
	{
		local name Anim;
		local float fFrame, fRate;

		// End:0xAB
		if((iChannel == m_pawn.16))
		{
			Pawn.GetAnimParams(m_pawn.16, Anim, fFrame, fRate);
			// End:0x7A
			if((Anim == 'KneelArrest'))
			{
				// End:0x77
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(42);
				}				
			}
			else
			{
				// End:0xA4
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(41);
				}
				GotoState('PlayerWalking');
			}
		}
		return;
	}

	function SwitchWeapon(byte f)
	{
		return;
	}

	exec function PreviousMember()
	{
		return;
	}

	exec function NextMember()
	{
		return;
	}

	simulated function ChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ServerChangeTeams(bool bNextTeam)
	{
		return;
	}

	function ValidateCameraTeamId()
	{
		return;
	}

	function SpectatorChangeTeams(bool bNextTeam)
	{
		return;
	}

	event ClientSetNewViewTarget()
	{
		return;
	}

	simulated function SetNewViewTarget(Actor aViewTarget)
	{
		return;
	}
Begin:

	stop;			
}

state PlayerActionProgress extends PlayerWalking
{
	function BeginState()
	{
		m_bHideReticule = true;
		m_bDisplayActionProgress = true;
		// End:0xBD
		if((((int(Level.NetMode) != int(NM_Standalone)) && (int(Role) == int(ROLE_Authority))) && m_PlayerCurrentCA.aQueryTarget.IsA('R6IOBomb')))
		{
			// End:0x9E
			if((!R6IOObject(m_PlayerCurrentCA.aQueryTarget).m_bIsActivated))
			{
				m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(m_pawn, 4);				
			}
			else
			{
				m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(m_pawn, 6);
			}
		}
		// End:0x11E
		if((m_pawn.EngineWeapon != none))
		{
			ToggleHelmetCameraZoom(true);
			m_pawn.EngineWeapon.GotoState('PutWeaponDown');
			// End:0x11B
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(27);
			}			
		}
		else
		{
			StartProgressAction();
		}
		Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		return;
	}

// NEW IN 1.60
	function LongClientAdjustPosition(float TimeStamp, name NewState, Actor.EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase, float NewFloorX, float NewFloorY, float NewFloorZ)
	{
		super(PlayerController).LongClientAdjustPosition(TimeStamp, 'PlayerActionProgress', newPhysics, NewLocX, NewLocY, NewLocZ, NewVelX, NewVelY, NewVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ);
		return;
	}

	function PlayerMove(float fDeltaTime)
	{
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aMouseX = 0.0000000;
		aMouseY = 0.0000000;
		aTurn = 0.0000000;
		global.PlayerMove(fDeltaTime);
		return;
	}

	function StartProgressAction()
	{
		m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
		// End:0xA3
		if(m_RequestedCircumstantialAction.aQueryTarget.IsA('R6IOObject'))
		{
			m_pawn.m_bInteractingWithDevice = true;
			m_pawn.m_eDeviceAnim = R6IOObject(m_RequestedCircumstantialAction.aQueryTarget).m_eAnimToPlay;
			// End:0xA0
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(18);
			}			
		}
		else
		{
			// End:0xFB
			if(m_RequestedCircumstantialAction.aQueryTarget.IsA('R6IORotatingDoor'))
			{
				m_pawn.m_bIsLockPicking = true;
				// End:0xFB
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(19);
				}
			}
		}
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x50
		if(((iChannel == m_pawn.14) && (int(m_pawn.m_eEquipWeapon) == int(m_pawn.2))))
		{
			m_pawn.m_bWeaponTransition = false;
			StartProgressAction();
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		m_bDisplayActionProgress = false;
		// End:0x110
		if((m_pawn != none))
		{
			m_pawn.m_bPostureTransition = false;
			m_pawn.m_bIsLockPicking = false;
			m_pawn.m_bInteractingWithDevice = false;
			m_pawn.m_ePlayerIsUsingHands = 0;
			// End:0xC4
			if(((m_pawn.EngineWeapon != none) && (!m_pawn.m_bIsSurrended)))
			{
				m_pawn.EngineWeapon.GotoState('BringWeaponUp');
				// End:0xC4
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(28);
				}
			}
			// End:0x110
			if((((int(Role) == int(ROLE_Authority)) && (!m_pawn.IsAlive())) && (m_iPlayerCAProgress < 105)))
			{
				m_RequestedCircumstantialAction.aQueryTarget.R6CircumstantialActionCancel();
			}
		}
		m_iPlayerCAProgress = 0;
		return;
	}

	event Tick(float fDeltaTime)
	{
		// End:0x3A
		if(((m_pawn.EngineWeapon != none) && (int(m_pawn.m_eEquipWeapon) != int(m_pawn.2))))
		{
			return;
		}
		// End:0x66
		if(((!m_pawn.m_bIsLockPicking) && (!m_pawn.m_bInteractingWithDevice)))
		{
			return;
		}
		// End:0x13F
		if((int(Role) == int(ROLE_Authority)))
		{
			// End:0x8B
			if((m_PlayerCurrentCA == none))
			{
				m_iPlayerCAProgress = 0;				
			}
			else
			{
				// End:0xA9
				if((m_PlayerCurrentCA.aQueryTarget == none))
				{
					m_iPlayerCAProgress = 0;					
				}
				else
				{
					m_iPlayerCAProgress = m_PlayerCurrentCA.aQueryTarget.R6GetCircumstantialActionProgress(m_PlayerCurrentCA, m_pawn);
				}
			}
			// End:0x13F
			if((m_iPlayerCAProgress >= 105))
			{
				m_iPlayerCAProgress = 0;
				// End:0x11E
				if(((int(Level.NetMode) != int(NM_Standalone)) && (int(Level.NetMode) != int(NM_Client))))
				{
					ClientActionProgressDone();
				}
				// End:0x138
				if((m_InteractionCA != none))
				{
					m_InteractionCA.ActionProgressDone();
				}
				GotoState('PlayerWalking');
			}
		}
		return;
	}
	stop;
}

state PlayerSecureTerrorist extends PlayerWalking
{
	function BeginState()
	{
		m_bHideReticule = true;
		m_bDisplayActionProgress = true;
		// End:0x6E
		if((m_pawn.EngineWeapon != none))
		{
			ToggleHelmetCameraZoom(true);
			Pawn.EngineWeapon.GotoState('PutWeaponDown');
			// End:0x6E
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(27);
			}
		}
		SetPeekingInfo(0, m_pawn.1000.0000000);
		ResetFluidPeeking();
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		m_bDisplayActionProgress = false;
		// End:0x5A
		if((m_iPlayerCAProgress < 100))
		{
			m_pawn.R6ResetAnimBlendParams(m_pawn.1);
			// End:0x5A
			if((int(Role) == int(ROLE_Authority)))
			{
				R6Terrorist(m_PlayerCurrentCA.aQueryTarget).ResetArrest();
			}
		}
		m_pawn.m_bPostureTransition = false;
		m_iPlayerCAProgress = 0;
		m_pawn.m_ePlayerIsUsingHands = 0;
		// End:0xDA
		if((m_pawn.EngineWeapon != none))
		{
			Pawn.EngineWeapon.GotoState('BringWeaponUp');
			// End:0xDA
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(28);
			}
		}
		return;
	}

	function PlayerMove(float fDeltaTime)
	{
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aMouseX = 0.0000000;
		aMouseY = 0.0000000;
		aTurn = 0.0000000;
		m_bPeekLeft = 0;
		m_bPeekRight = 0;
		global.PlayerMove(fDeltaTime);
		return;
	}

// NEW IN 1.60
	function LongClientAdjustPosition(float TimeStamp, name NewState, Actor.EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase, float NewFloorX, float NewFloorY, float NewFloorZ)
	{
		super(PlayerController).LongClientAdjustPosition(TimeStamp, 'PlayerSecureTerrorist', newPhysics, NewLocX, NewLocY, NewLocZ, NewVelX, NewVelY, NewVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ);
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0xA7
		if(((iChannel == m_pawn.1) && m_pawn.m_bPostureTransition))
		{
			m_pawn.m_bPostureTransition = false;
			m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
			m_iPlayerCAProgress = 100;
			// End:0x83
			if((int(Level.NetMode) == int(NM_DedicatedServer)))
			{
				ClientActionProgressDone();
			}
			// End:0x9D
			if((m_InteractionCA != none))
			{
				m_InteractionCA.ActionProgressDone();
			}
			GotoState('PlayerWalking');			
		}
		else
		{
			// End:0x193
			if(((iChannel == m_pawn.14) && (int(m_pawn.m_eEquipWeapon) == int(m_pawn.2))))
			{
				m_pawn.m_bWeaponTransition = false;
				m_pawn.m_bPostureTransition = false;
				m_pawn.PlaySecureTerrorist();
				m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
				// End:0x193
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(29);
					R6Terrorist(m_PlayerCurrentCA.aQueryTarget).m_controller.DispatchOrder(int(m_PlayerCurrentCA.iPlayerActionID), m_pawn);
				}
			}
		}
		return;
	}

	event Tick(float fDeltaTime)
	{
		// End:0x3A
		if(((m_pawn.EngineWeapon != none) && (int(m_pawn.m_eEquipWeapon) != int(m_pawn.2))))
		{
			return;
		}
		// End:0x50
		if((!m_pawn.m_bPostureTransition))
		{
			return;
		}
		// End:0x88
		if((int(Role) == int(ROLE_Authority)))
		{
			m_iPlayerCAProgress = m_PlayerCurrentCA.aQueryTarget.R6GetCircumstantialActionProgress(m_PlayerCurrentCA, m_pawn);
		}
		return;
	}
	stop;
}

state PlayerSetExplosive extends PlayerWalking
{
	function PlayerMove(float fDeltaTime)
	{
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aMouseX = 0.0000000;
		aMouseY = 0.0000000;
		aTurn = 0.0000000;
		global.PlayerMove(fDeltaTime);
		return;
	}

	function BeginState()
	{
		Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		m_iPlayerCAProgress = 0;
		m_bPlacedExplosive = false;
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		m_iPlayerCAProgress = 0;
		m_pawn.m_bPostureTransition = false;
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x2D
		if((iChannel == m_pawn.1))
		{
			// End:0x2D
			if(m_pawn.IsAlive())
			{
				GotoState('PlayerWalking');
			}
		}
		return;
	}

	function int GetActionProgress()
	{
		local name Anim;
		local float fFrame, fRate;

		Pawn.GetAnimParams(m_pawn.1, Anim, fFrame, fRate);
		Clamp(int(fFrame), 0, 100);
		return int((fFrame * float(110)));
		return;
	}

	event Tick(float fDeltaTime)
	{
		m_iPlayerCAProgress = GetActionProgress();
		// End:0x20
		if((m_iPlayerCAProgress > 75))
		{
			m_bPlacedExplosive = true;
		}
		return;
	}
	stop;
}

state PreBeginClimbingLadder
{
	function BeginState()
	{
		ToggleHelmetCameraZoom(true);
		RaisePosture();
		SetPeekingInfo(0, m_pawn.1000.0000000);
		ResetFluidPeeking();
		// End:0xD9
		if(((Pawn.EngineWeapon != none) && (!(Pawn.EngineWeapon.IsA('R6GrenadeWeapon') && (!Pawn.EngineWeapon.HasAmmo())))))
		{
			DoZoom(true);
			Pawn.EngineWeapon.GotoState('PutWeaponDown');
			// End:0xC7
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(27);
			}
			m_pawn.RainbowSecureWeapon();			
		}
		else
		{
			m_bSkipBeginState = false;
			GotoState('PlayerBeginClimbingLadder');
			// End:0x107
			if((int(Level.NetMode) == int(NM_Client)))
			{
				ServerStartClimbingLadder();
			}
		}
		// End:0x17B
		if((int(Level.NetMode) != int(NM_Client)))
		{
			// End:0x150
			if(((m_pawn.m_Ladder == none) || (m_pawn.OnLadder == none)))
			{
				ExtractMissingLadderInformation();
			}
			R6LadderVolume(m_pawn.OnLadder).EnableCollisions(m_pawn.m_Ladder);
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		m_pawn.m_bWeaponTransition = false;
		return;
	}

	function PlayFiring()
	{
		return;
	}

	function AltFiring()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		return;
	}

	exec function ToggleHelmetCameraZoom(optional bool bTurnOff)
	{
		return;
	}

	exec function Fire(optional float f)
	{
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x61
		if(((int(Level.NetMode) != int(NM_DedicatedServer)) && (iChannel == m_pawn.14)))
		{
			m_bSkipBeginState = false;
			GotoState('PlayerBeginClimbingLadder');
			// End:0x5E
			if((int(Level.NetMode) == int(NM_Client)))
			{
				ServerStartClimbingLadder();
			}			
		}
		else
		{
			m_pawn.AnimEnd(iChannel);
		}
		return;
	}

	function SwitchWeapon(byte f)
	{
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aTurn = 0.0000000;
		bRun = 0;
		m_bPeekLeft = 0;
		m_bPeekRight = 0;
		// End:0x8F
		if((int(Role) < int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));			
		}
		else
		{
			ProcessMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));
		}
		return;
	}
	stop;
}

state PlayerBeginClimbingLadder
{
	function BeginState()
	{
		// End:0x30
		if(((m_pawn.m_Ladder == none) || (m_pawn.OnLadder == none)))
		{
			ExtractMissingLadderInformation();
		}
		// End:0x8A
		if(m_pawn.m_Ladder.m_bIsTopOfLadder)
		{
			Pawn.SetRotation((Pawn.OnLadder.LadderList.Rotation + rot(0, 32768, 0)));			
		}
		else
		{
			Pawn.SetRotation(Pawn.OnLadder.LadderList.Rotation);
		}
		// End:0xC9
		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
		// End:0xE3
		if((m_TeamManager != none))
		{
			m_TeamManager.TeamLeaderIsClimbingLadder();
		}
		m_bHideReticule = true;
		m_pawn.m_bIsClimbingLadder = true;
		Pawn.LockRootMotion(1, true);
		// End:0x137
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_pawn.SetNextPendingAction(5);
		}
		m_pawn.PlayStartClimbing();
		// End:0x1A0
		if(m_pawn.m_Ladder.m_bIsTopOfLadder)
		{
			Pawn.SetRotation((Pawn.OnLadder.LadderList.Rotation + rot(0, 32768, 0)));			
		}
		else
		{
			Pawn.SetRotation(Pawn.OnLadder.LadderList.Rotation);
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		// End:0xB7
		if((m_pawn.OnLadder != none))
		{
			// End:0x73
			if((Pawn.Rotation != Pawn.OnLadder.LadderList.Rotation))
			{
				Pawn.SetRotation(Pawn.OnLadder.LadderList.Rotation);
			}
			// End:0xB7
			if((int(Level.NetMode) != int(NM_Client)))
			{
				R6LadderVolume(m_pawn.OnLadder).DisableCollisions(m_pawn.m_Ladder);
			}
		}
		m_pawn.m_bPostureTransition = false;
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x9A
		if((iChannel == 0))
		{
			// End:0x35
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(6);
			}
			m_pawn.PlayPostStartLadder();
			Pawn.SetRotation(Pawn.OnLadder.LadderList.Rotation);
			SetRotation(Pawn.OnLadder.LadderList.Rotation);
			GotoState('PlayerClimbing');
		}
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aTurn = 0.0000000;
		R6PlayerMove(DeltaTime);
		return;
	}
	stop;
}

state PlayerClimbing
{
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		return false;
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		// End:0x3A
		if(((!m_bLockWeaponActions) && (m_pawn.EngineWeapon != none)))
		{
			m_pawn.EngineWeapon.GotoState('PutWeaponDown');
		}
		// End:0xC4
		if((WindowConsole(Player.Console).ConsoleState == 'UWindow'))
		{
			// End:0x9A
			if((int(Role) < int(ROLE_Authority)))
			{
				ReplicateMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));				
			}
			else
			{
				ProcessMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));
			}			
		}
		else
		{
			super.PlayerMove(DeltaTime);
		}
		return;
	}
	stop;
}

state PlayerEndClimbingLadder
{
	function BeginState()
	{
		// End:0x13
		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
		// End:0x91
		if((m_pawn.m_Ladder.m_bIsTopOfLadder || (!m_pawn.EndOfLadderSlide())))
		{
			Pawn.LockRootMotion(1, true);
			// End:0x7F
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(7);
			}
			m_pawn.PlayEndClimbing();			
		}
		else
		{
			// End:0xBB
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(7);
			}
			m_pawn.PlayEndClimbing();
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		m_pawn.m_bSlideEnd = false;
		// End:0x29
		if(m_pawn.m_bIsClimbingLadder)
		{
			EndClimbingSetUp();
		}
		// End:0xF2
		if(Class'Engine.Actor'.static.GetModMgr().IsMissionPack())
		{
			// End:0xEF
			if((((!m_pawn.m_bIsSurrended) && (m_pawn.EngineWeapon != none)) && (!(Pawn.EngineWeapon.IsA('R6GrenadeWeapon') && (!Pawn.EngineWeapon.HasAmmo())))))
			{
				Pawn.EngineWeapon.GotoState('BringWeaponUp');
				// End:0xEF
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(28);
				}
			}			
		}
		else
		{
			// End:0x189
			if(((m_pawn.EngineWeapon != none) && (!(Pawn.EngineWeapon.IsA('R6GrenadeWeapon') && (!Pawn.EngineWeapon.HasAmmo())))))
			{
				Pawn.EngineWeapon.GotoState('BringWeaponUp');
				// End:0x189
				if((int(Level.NetMode) != int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(28);
				}
			}
		}
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x141
		if(((iChannel == 0) || (iChannel == m_pawn.1)))
		{
			// End:0x134
			if((iChannel == 0))
			{
				// End:0xB5
				if(m_pawn.m_Ladder.m_bIsTopOfLadder)
				{
					// End:0x71
					if((int(Level.NetMode) != int(NM_Client)))
					{
						m_pawn.SetNextPendingAction(8);
					}
					m_pawn.PlayPostEndLadder();
					Pawn.SetLocation((Pawn.Location + (float(20) * Vector(Pawn.Rotation))));					
				}
				else
				{
					// End:0x134
					if((!m_pawn.m_bSlideEnd))
					{
						// End:0xF3
						if((int(Level.NetMode) != int(NM_Client)))
						{
							m_pawn.SetNextPendingAction(8);
						}
						m_pawn.PlayPostEndLadder();
						Pawn.SetLocation((Pawn.Location + (float(25) * Vector(Pawn.Rotation))));
					}
				}
			}
			EndClimbingSetUp();
			GotoState('PlayerWalking');
		}
		return;
	}

	function EndClimbingSetUp()
	{
		Pawn.SetPhysics(1);
		Pawn.OnLadder = none;
		m_pawn.m_bIsClimbingLadder = false;
		m_pawn.m_bPostureTransition = false;
		// End:0x5F
		if((m_TeamManager != none))
		{
			m_TeamManager.MemberFinishedClimbingLadder(m_pawn);
		}
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aTurn = 0.0000000;
		R6PlayerMove(DeltaTime);
		return;
	}
	stop;
}

defaultproperties
{
	m_iDoorSpeed=20
	m_iFastDoorSpeed=100
	m_iFluidMovementSpeed=900
	m_iSpeedLevels[0]=7500
	m_iSpeedLevels[1]=15500
	m_iSpeedLevels[2]=23500
	m_iReturnSpeed=3000
	m_bShowFPWeapon=true
	m_bShakeActive=true
	m_bUseFirstPersonWeapon=true
	m_bAttachCameraToEyes=true
	m_bCameraGhost=true
	m_bCameraFirstPerson=true
	m_bCameraThirdPersonFixed=true
	m_bCameraThirdPersonFree=true
	m_bFadeToBlack=true
	m_bSpectatorCameraTeamOnly=true
	m_bCanChangeMember=true
	m_fTeamMoveToDistance=6000.0000000
	m_fDesignerSpeedFactor=1.0000000
	m_fDesignerJumpFactor=1.0000000
	m_fMilestoneMessageDuration=2.0000000
	LastDoorUpdateTime=1.0000000
	m_sndUpdateWritableMap=Sound'Common_Multiplayer.Play_DrawingTool_Receive'
	m_sndDeathMusic=Sound'Music.Play_themes_Death'
	m_sndMissionComplete=Sound'Voices_Control_MissionSuccess.Play_Control_MissionCompleted'
	m_stImpactHit=(iBlurIntensity=10,fRollMax=300.0000000,fRollSpeed=5000.0000000,fReturnTime=0.2500000)
	m_stImpactStun=(iBlurIntensity=20,fRollMax=500.0000000,fRollSpeed=5000.0000000,fReturnTime=0.3000000)
	m_stImpactDazed=(iBlurIntensity=40,fRollMax=1000.0000000,fRollSpeed=7500.0000000,fReturnTime=0.4000000)
	m_stImpactKO=(iBlurIntensity=75,fWaveTime=2.0000000,fRollMax=1500.0000000,fRollSpeed=8000.0000000,fReturnTime=0.5000000)
	m_SpectatorColor=(R=255,G=255,B=255,A=210)
	EnemyTurnSpeed=100000
	DesiredFOV=90.0000000
	DefaultFOV=90.0000000
	CheatClass=Class'R6Engine.R6CheatManager'
	InputClass=Class'R6Engine.R6PlayerInput'
	m_bFirstTimeInZone=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_fLastVoteKickTime
// REMOVED IN 1.60: var szBanIDK_MaxBanPageSize
// REMOVED IN 1.60: function ShowMe
// REMOVED IN 1.60: function ToggleRestart
// REMOVED IN 1.60: function SetFragStat
// REMOVED IN 1.60: function SetDeathsStat
// REMOVED IN 1.60: function SetHealthStat
// REMOVED IN 1.60: function SetRoundsHitStat
// REMOVED IN 1.60: function SetRoundsFiredStat
// REMOVED IN 1.60: function SetRoundsPlayedStat
// REMOVED IN 1.60: function SetRoundsWonStat
// REMOVED IN 1.60: function LogAllPlayerInfo
// REMOVED IN 1.60: function LogPlayerInfo
// REMOVED IN 1.60: function ClientPreBeginSurrending
// REMOVED IN 1.60: function ServerStartSurrending
// REMOVED IN 1.60: function LogVoteInfo
// REMOVED IN 1.60: function UnlockCheat
// REMOVED IN 1.60: function ServerUnlockCheat
