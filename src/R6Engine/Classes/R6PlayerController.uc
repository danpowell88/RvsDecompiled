//=============================================================================
// R6PlayerController - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
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
	if(__NFUN_129__(m_GameOptions.HUDShowFPWeapon))
	{
		return false;
	}
	return __NFUN_132__(m_bShowFPWeapon, m_bShowCompleteHUD);
	return;
}

exec function ShowWeapon()
{
	m_GameOptions.HUDShowFPWeapon = true;
	m_bShowFPWeapon = true;
	// End:0x4F
	if(__NFUN_119__(Pawn.m_WeaponsCarried[0], none))
	{
		R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
	}
	// End:0x85
	if(__NFUN_119__(Pawn.m_WeaponsCarried[1], none))
	{
		R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
	}
	return;
}

function Set1stWeaponDisplay(bool bShowWeapon)
{
	m_bShowFPWeapon = bShowWeapon;
	// End:0x84
	if(__NFUN_119__(Pawn, none))
	{
		// End:0x4E
		if(__NFUN_119__(Pawn.m_WeaponsCarried[0], none))
		{
			R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
		}
		// End:0x84
		if(__NFUN_119__(Pawn.m_WeaponsCarried[1], none))
		{
			R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);
		}
	}
	return;
}

simulated event SetMatchResult(string _UserUbiID, int iField, int iValue)
{
	// End:0x28
	if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_114__(m_GameService, none)))
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
	if(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_114__(m_GameService, none)), __NFUN_242__(PlayerReplicationInfo.m_bClientWillSubmitResult, false)))
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
		__NFUN_231__(__NFUN_112__("Received ClientNotifySendMatchResults for player ", string(self)));
	}
	// End:0x82
	if(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_114__(m_GameService, none)), __NFUN_242__(PlayerReplicationInfo.m_bClientWillSubmitResult, false)))
	{
		return;
	}
	m_GameService.__NFUN_1297__();
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
	if(__NFUN_154__(int(Role), int(ROLE_Authority)))
	{
		PlayerReplicationInfo = __NFUN_278__(PlayerReplicationInfoClass, self,, vect(0.0000000, 0.0000000, 0.0000000), rot(0, 0, 0));
		InitPlayerReplicationInfo();
		bIsPlayer = true;
		m_CommonPlayerVoicesMgr = R6CommonRainbowVoices(R6AbstractGameInfo(Level.Game).GetCommonRainbowPlayerVoicesMgr());
		// End:0x13F
		if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)), Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag)))
		{
			// End:0x11B
			if(__NFUN_114__(Level.m_sndMissionComplete, none))
			{
				Level.m_sndMissionComplete = m_sndMissionComplete;
				AddSoundBankName("Voices_Control_MissionSuccess");
			}
			AddSoundBankName("Voices_Control_MissionFailed");
		}
	}
	Level.m_bAllow3DRendering = true;
	__NFUN_2011__(false);
	m_GameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	return;
}

function UpdateTriggerLagInfo()
{
	// End:0x69
	if(__NFUN_130__(__NFUN_119__(m_GameOptions, none), __NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Client)), __NFUN_130__(__NFUN_119__(Pawn, none), Pawn.IsLocallyControlled()))))
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
	foreach __NFUN_304__(Class'R6Abstract.R6AbstractInsertionZone', NavPoint)
	{
		NavPoint.bHidden = true;		
	}	
	// End:0x6F
	foreach __NFUN_304__(Class'R6Abstract.R6AbstractExtractionZone', ExtZone)
	{
		// End:0x6E
		if(__NFUN_129__(ExtZone.__NFUN_1513__(szCurrentGameType)))
		{
			ExtZone.bHidden = true;
		}		
	}	
	// End:0xAA
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		bInTraining = Level.Game.__NFUN_303__('R6TrainingMgr');
	}
	// End:0x1D8
	foreach __NFUN_304__(Class'R6Engine.R6ReferenceIcons', RefIco)
	{
		// End:0xF3
		if(__NFUN_132__(RefIco.__NFUN_303__('R6DoorIcon'), RefIco.__NFUN_303__('R6DoorLockedIcon')))
		{
			RefIco.__NFUN_279__();
			// End:0x1D7
			continue;
		}
		// End:0x1D7
		if(__NFUN_130__(__NFUN_130__(__NFUN_129__(RefIco.__NFUN_303__('R6ObjectiveIcon')), __NFUN_129__(__NFUN_130__(bInTraining, __NFUN_132__(RefIco.__NFUN_303__('R6HostageIcon'), RefIco.__NFUN_303__('R6TerroristIcon'))))), __NFUN_129__(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), RefIco.__NFUN_303__('R6HostageIcon')))))
		{
			RefIco.bHidden = true;
			// End:0x1D7
			if(__NFUN_132__(__NFUN_132__(__NFUN_119__(R6ActionPointAbstract(RefIco.Owner), none), RefIco.__NFUN_303__('R6CameraDirection')), RefIco.__NFUN_303__('R6ArrowIcon')))
			{
				RefIco.__NFUN_279__();
			}
		}		
	}	
	// End:0x1FB
	foreach __NFUN_304__(Class'R6Engine.R6IORotatingDoor', RotDoor)
	{
		RotDoor.m_eDisplayFlag = 2;		
	}	
	return;
}

simulated event PostNetBeginPlay()
{
	super(Actor).PostNetBeginPlay();
	// End:0x30
	if(__NFUN_119__(Pawn, none))
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
	if(__NFUN_122__(PlayerReplicationInfo.m_szUbiUserID, ""))
	{
		PlayerReplicationInfo.m_szUbiUserID = _szUBIUserID;
	}
	return;
}

function ServerPlayRecordedMsg(string Msg, Pawn.EPreRecordedMsgVoices eRainbowVoices)
{
	Level.Game.BroadcastTeam(self, Msg, 'PreRecMsg');
	// End:0x30
	if(__NFUN_114__(m_TeamManager, none))
	{
		return;
	}
	// End:0x46
	if(__NFUN_114__(m_TeamManager.m_PreRecMsgVoicesMgr, none))
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
	if(__NFUN_119__(m_CurrentCircumstantialAction, none))
	{
		m_CurrentCircumstantialAction.aQueryOwner = none;
	}
	ClearReferences();
	// End:0x5B
	if(__NFUN_130__(__NFUN_119__(Player, none), __NFUN_119__(Player.Console, none)))
	{
		Player.Console.SetGameServiceLinks(none);
	}
	// End:0x92
	if(__NFUN_119__(R6AbstractGameInfo(Level.Game), none))
	{
		R6AbstractGameInfo(Level.Game).RemoveController(self);
	}
	super.Destroyed();
	return;
}

function ServerSetGender(bool bIsFemale)
{
	// End:0x23
	if(__NFUN_132__(__NFUN_114__(PlayerReplicationInfo, none), __NFUN_153__(PlayerReplicationInfo.iOperativeID, 0)))
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
	if(__NFUN_114__(PRI, none))
	{
		return "";
	}
	// End:0x89
	if(__NFUN_132__(__NFUN_132__(PRI.bIsSpectator, __NFUN_154__(PRI.TeamID, int(0))), __NFUN_154__(PRI.TeamID, int(4))))
	{
		szLifeState = __NFUN_112__(__NFUN_112__("(", Localize("Game", "SPECTATOR", "R6GameInfo")), ") ");		
	}
	else
	{
		// End:0xCC
		if(__NFUN_151__(PRI.m_iHealth, 1))
		{
			szLifeState = __NFUN_112__(__NFUN_112__("(", Localize("Game", "DEAD", "R6GameInfo")), ") ");
		}
	}
	// End:0x1C1
	if(__NFUN_130__(__NFUN_254__(MsgType, 'TeamSay'), __NFUN_154__(PRI.TeamID, PlayerReplicationInfo.TeamID)))
	{
		// End:0x148
		if(__NFUN_154__(PlayerReplicationInfo.TeamID, int(2)))
		{
			szTeam = __NFUN_112__(__NFUN_112__(" [", Localize("Game", "GREEN", "R6GameInfo")), "]");			
		}
		else
		{
			// End:0x190
			if(__NFUN_154__(PlayerReplicationInfo.TeamID, int(3)))
			{
				szTeam = __NFUN_112__(__NFUN_112__(" [", Localize("Game", "RED", "R6GameInfo")), "]");				
			}
			else
			{
				szTeam = __NFUN_112__(__NFUN_112__(" [", Localize("Game", "NOTEAM", "R6GameInfo")), "]");
			}
		}
	}
	szMsg = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(szLifeState, ""), PRI.PlayerName), " "), szTeam);
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
	foreach __NFUN_304__(Class'R6Engine.R6Pawn', Sender)
	{
		// End:0x63
		if(__NFUN_114__(Sender.PlayerReplicationInfo, PRI))
		{
			// End:0x60
			if(__NFUN_130__(__NFUN_119__(Pawn, none), Pawn.IsFriend(Sender)))
			{
				Sender.m_fLastCommunicationTime = 5.0000000;
			}
			// End:0x64
			break;
		}		
	}	
	// End:0x118
	if(__NFUN_254__(MsgType, 'Line'))
	{
		// End:0x115
		if(__NFUN_119__(PRI, PlayerReplicationInfo))
		{
			Level.__NFUN_2802__(Msg);
			// End:0x115
			if(__NFUN_119__(Player, none))
			{
				Player.Console.Message(__NFUN_112__(__NFUN_112__(Localize("Game", "MapUpdatedBy", "R6GameInfo"), " "), PRI.PlayerName), 6.0000000);
				// End:0x115
				if(__NFUN_119__(m_pawn, none))
				{
					m_pawn.__NFUN_264__(m_sndUpdateWritableMap, 3);
				}
			}
		}		
	}
	else
	{
		// End:0x1CD
		if(__NFUN_254__(MsgType, 'Icon'))
		{
			Level.__NFUN_1608__(Msg);
			// End:0x1CA
			if(__NFUN_130__(__NFUN_119__(PRI, PlayerReplicationInfo), __NFUN_119__(Player, none)))
			{
				Player.Console.Message(__NFUN_112__(__NFUN_112__(Localize("Game", "MapUpdatedBy", "R6GameInfo"), " "), PRI.PlayerName), 6.0000000);
				// End:0x1CA
				if(__NFUN_119__(m_pawn, none))
				{
					m_pawn.__NFUN_264__(m_sndUpdateWritableMap, 3);
				}
			}			
		}
		else
		{
			// End:0x213
			if(__NFUN_132__(__NFUN_254__(MsgType, 'Say'), __NFUN_254__(MsgType, 'TeamSay')))
			{
				Msg = __NFUN_112__(__NFUN_112__(GetPrefixToMsg(PRI, MsgType), ": "), Msg);				
			}
			else
			{
				// End:0x29F
				if(__NFUN_254__(MsgType, 'PreRecMsg'))
				{
					pos = __NFUN_126__(Msg, " ");
					szGroup = __NFUN_128__(Msg, pos);
					szID = __NFUN_234__(Msg, __NFUN_147__(__NFUN_147__(__NFUN_125__(Msg), pos), 1));
					Msg = __NFUN_112__(__NFUN_112__(GetPrefixToMsg(PRI, 'TeamSay'), ": "), Localize(szGroup, szID, "R6RecMessages"));
				}
			}
			// End:0x2DA
			if(__NFUN_119__(Player, none))
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
	if(__NFUN_119__(Player, none))
	{
		// End:0x2A
		if(__NFUN_114__(m_InteractionMaster, none))
		{
			m_InteractionMaster = Player.InteractionMaster;
		}
		// End:0x80
		if(__NFUN_114__(m_InteractionCA, none))
		{
			m_InteractionCA = R6InteractionCircumstantialAction(m_InteractionMaster.AddInteraction("R6Engine.R6InteractionCircumstantialAction", Player));
		}
		// End:0xCE
		if(__NFUN_114__(m_InteractionInventory, none))
		{
			m_InteractionInventory = R6InteractionInventoryMnu(m_InteractionMaster.AddInteraction("R6Engine.R6InteractionInventoryMnu", Player));
		}
	}
	return;
}

function DestroyInteractions()
{
	// End:0x57
	if(__NFUN_119__(m_InteractionMaster, none))
	{
		// End:0x31
		if(__NFUN_119__(m_InteractionCA, none))
		{
			m_InteractionMaster.RemoveInteraction(m_InteractionCA);
			m_InteractionCA = none;
		}
		// End:0x57
		if(__NFUN_119__(m_InteractionInventory, none))
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
	if(__NFUN_114__(m_PlayerStartInfo, none))
	{
		m_PlayerStartInfo = __NFUN_278__(Class'Engine.R6RainbowStartInfo');
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
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_168__(string(self), "SERVERSETPLAYERSTARTINFO weapons are :"), m_PlayerStartInfo.m_WeaponName[0]), " and "), m_PlayerStartInfo.m_WeaponName[1]));
	}
	return;
}

event PostRender(Canvas Canvas)
{
	local int iBlurValue;
	local R6IOSelfDetonatingBomb AIt;

	// End:0x24
	if(__NFUN_119__(CheatManager, none))
	{
		R6CheatManager(CheatManager).PostRender(Canvas);
	}
	// End:0xAA
	if(__NFUN_119__(Pawn, none))
	{
		// End:0x60
		if(__NFUN_119__(Pawn.EngineWeapon, none))
		{
			Pawn.EngineWeapon.PostRender(Canvas);
		}
		iBlurValue = int(__NFUN_174__(Pawn.m_fBlurValue, Pawn.m_fDecrementalBlurValue));
		iBlurValue = __NFUN_251__(iBlurValue, 0, 235);
		Canvas.__NFUN_2005__(iBlurValue);		
	}
	else
	{
		Canvas.__NFUN_2005__(0);
	}
	// End:0x1AD
	if(__NFUN_129__(m_bBombSearched))
	{
		// End:0xDE
		foreach __NFUN_304__(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
		{
			m_pSelfDetonatingBomb = AIt;			
		}		
		// End:0x1A5
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			// End:0x14A
			if(__NFUN_130__(__NFUN_119__(m_pSelfDetonatingBomb, none), __NFUN_155__(int(Level.NetMode), int(NM_Client))))
			{
				// End:0x149
				foreach __NFUN_304__(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
				{
					m_pSelfDetonatingBomb = AIt;
					m_pSelfDetonatingBomb.StartTimer();					
				}				
			}
			// End:0x1A5
			if(__NFUN_114__(m_pSelfDetonatingBomb, none))
			{
				// End:0x1A5
				if(__NFUN_130__(__NFUN_119__(GameReplicationInfo, none), __NFUN_122__(GameReplicationInfo.m_szGameTypeFlagRep, "RGM_CountDownMode")))
				{
					R6AbstractGameInfo(Level.Game).StartTimer();
				}
			}
		}
		m_bBombSearched = true;
	}
	// End:0x232
	if(__NFUN_119__(m_pSelfDetonatingBomb, none))
	{
		// End:0x1FD
		foreach __NFUN_304__(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
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
		foreach __NFUN_304__(Class'R6Engine.R6IOSelfDetonatingBomb', AIt)
		{
			m_pSelfDetonatingBomb = AIt;
			m_pSelfDetonatingBomb.PostRender2(Canvas);			
		}				
	}
	else
	{
		// End:0x270
		if(__NFUN_130__(__NFUN_119__(GameReplicationInfo, none), __NFUN_122__(GameReplicationInfo.m_szGameTypeFlagRep, "RGM_CountDownMode")))
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

	iTimeLeft = int(__NFUN_175__(R6AbstractGameInfo(Level.Game).m_fEndingTime, Level.TimeSeconds));
	// End:0x46
	if(__NFUN_150__(iTimeLeft, 0))
	{
		iTimeLeft = 0;
	}
	sTime = __NFUN_112__(Localize("Game", "TimeLeft", "R6GameInfo"), " ");
	sTime = __NFUN_112__(sTime, __NFUN_1520__(iTimeLeft, true));
	C.__NFUN_1606__(true, 640.0000000, 480.0000000);
	X = int(C.HalfClipX);
	Y = int(__NFUN_172__(C.HalfClipY, float(8)));
	C.Font = Font'R6Font.Rainbow6_14pt';
	// End:0x10D
	if(__NFUN_151__(iTimeLeft, 20))
	{
		C.__NFUN_2626__(byte(255), byte(255), byte(255));		
	}
	else
	{
		// End:0x132
		if(__NFUN_151__(iTimeLeft, 10))
		{
			C.__NFUN_2626__(byte(255), byte(255), 0);			
		}
		else
		{
			C.__NFUN_2626__(byte(255), 0, 0);
		}
	}
	C.__NFUN_464__(sTime, fStrSizeX, fStrSizeY);
	C.__NFUN_2623__(__NFUN_175__(float(X), __NFUN_172__(fStrSizeX, float(2))), float(__NFUN_146__(Y, 24)));
	C.__NFUN_465__(sTime);
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
	if(__NFUN_242__(m_bQuitToUpdateServerDisplayed, false))
	{
		// End:0x9E
		if(__NFUN_177__(__NFUN_175__(Level.TimeSeconds, m_fLastUpdateServerCheckTime), float(5)))
		{
			m_fLastUpdateServerCheckTime = Level.TimeSeconds;
			PatchState = Class'R6Abstract.R6AbstractEviLPatchService'.static.GetState();
			// End:0x9E
			if(__NFUN_154__(int(PatchState), int(6)))
			{
				m_bQuitToUpdateServerDisplayed = true;
				HandleServerMsg(Localize("Options", "PatchStatus_RunPatch", "R6Menu"));
			}
		}
	}
	// End:0x102
	if(__NFUN_130__(__NFUN_119__(m_pawn, none), __NFUN_119__(Pawn, none)))
	{
		__NFUN_2211__();
		__NFUN_1843__(fDeltaTime);
		// End:0x102
		if(m_pawn.bInvulnerableBody)
		{
			// End:0x102
			if(__NFUN_177__(__NFUN_175__(Level.TimeSeconds, m_fStartSurrenderTime), float(3)))
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
	if(__NFUN_132__(__NFUN_132__(__NFUN_114__(Level.m_WeatherEmitter, none), __NFUN_154__(Level.m_WeatherEmitter.Emitters.Length, 0)), __NFUN_114__(Viewport(Player), none)))
	{
		return;
	}
	// End:0x122
	if(Region.Zone.m_bAlternateEmittersActive)
	{
		i = 0;
		J0x66:

		// End:0x10C [Loop If]
		if(__NFUN_150__(i, Region.Zone.m_AlternateWeatherEmitters.Length))
		{
			// End:0x102
			if(__NFUN_119__(Region.Zone.m_AlternateWeatherEmitters[i], none))
			{
				Region.Zone.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 1;
				Region.Zone.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x66;
		}
		Region.Zone.m_bAlternateEmittersActive = false;
	}
	// End:0x1E0
	if(__NFUN_129__(NewZone.m_bAlternateEmittersActive))
	{
		i = 0;
		J0x13D:

		// End:0x1CF [Loop If]
		if(__NFUN_150__(i, NewZone.m_AlternateWeatherEmitters.Length))
		{
			// End:0x1C5
			if(__NFUN_119__(NewZone.m_AlternateWeatherEmitters[i], none))
			{
				NewZone.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 0;
				NewZone.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
			}
			__NFUN_165__(i);
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
	if(__NFUN_114__(Level.m_WeatherEmitter, none))
	{
		return;
	}
	// End:0x48
	if(__NFUN_132__(__NFUN_154__(Level.m_WeatherEmitter.Emitters.Length, 0), __NFUN_114__(Viewport(Player), none)))
	{
		return;
	}
	// End:0xEC
	if(__NFUN_119__(Level.m_WeatherViewTarget, ViewTarget))
	{
		// End:0xD7
		foreach __NFUN_304__(Class'Engine.R6WeatherEmitter', WE)
		{
			// End:0xD6
			if(__NFUN_130__(__NFUN_119__(WE, Level.m_WeatherEmitter), __NFUN_155__(WE.Emitters.Length, 0)))
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
		if(__NFUN_242__(WZ.m_bAlternateEmittersActive, false))
		{
			i = 0;
			J0x151:

			// End:0x1ED [Loop If]
			if(__NFUN_150__(i, WZ.m_AlternateWeatherEmitters.Length))
			{
				// End:0x1E3
				if(__NFUN_155__(WZ.m_AlternateWeatherEmitters[i].Emitters.Length, 0))
				{
					WZ.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 0;
					WZ.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
				}
				__NFUN_165__(i);
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
		if(__NFUN_151__(ViewTarget.m_bInWeatherVolume, 0))
		{
			Level.SetWeatherActive(false);			
		}
		else
		{
			// End:0x2EE
			if(__NFUN_154__(ViewTarget.m_bInWeatherVolume, 0))
			{
				vWeatherEmitterPos = ViewTarget.Location;
				vViewDirection = __NFUN_276__(vect(1.0000000, 0.0000000, 0.0000000), ViewTarget.Rotation);
				__NFUN_184__(vWeatherEmitterPos.X, __NFUN_171__(float(256), vViewDirection.X));
				__NFUN_184__(vWeatherEmitterPos.Y, __NFUN_171__(float(256), vViewDirection.Y));
				__NFUN_184__(vWeatherEmitterPos.Z, float(100));
				Level.m_WeatherEmitter.__NFUN_267__(vWeatherEmitterPos);
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
	if(__NFUN_177__(m_fShakeTime, float(0)))
	{
		// End:0x124
		if(__NFUN_177__(m_fShakeTime, fDeltaTime))
		{
			__NFUN_185__(m_fShakeTime, fDeltaTime);
			// End:0x94
			if(__NFUN_177__(m_fCurrentShake, fDeltaTime))
			{
				__NFUN_290__(m_rHitRotation, __NFUN_172__(__NFUN_175__(m_fCurrentShake, fDeltaTime), m_fCurrentShake));
				__NFUN_185__(m_fCurrentShake, fDeltaTime);				
			}
			else
			{
				m_rHitRotation.Pitch = int(RandRange(__NFUN_169__(m_fMaxShake), m_fMaxShake));
				m_rHitRotation.Yaw = int(RandRange(__NFUN_169__(m_fMaxShake), m_fMaxShake));
				m_rHitRotation.Roll = int(RandRange(__NFUN_169__(m_fMaxShake), m_fMaxShake));
				m_fCurrentShake = RandRange(0.0000000, m_fMaxShakeTime);
			}
			__NFUN_182__(m_fMaxShake, __NFUN_172__(__NFUN_175__(m_fShakeTime, fDeltaTime), m_fShakeTime));			
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
		if(__NFUN_177__(m_fHitEffectTime, float(0)))
		{
			// End:0x18B
			if(__NFUN_177__(m_fHitEffectTime, fDeltaTime))
			{
				__NFUN_290__(m_rHitRotation, __NFUN_172__(__NFUN_175__(m_fHitEffectTime, fDeltaTime), m_fHitEffectTime));
				__NFUN_185__(m_fHitEffectTime, fDeltaTime);				
			}
			else
			{
				m_rHitRotation = rot(0, 0, 0);
				m_fHitEffectTime = 0.0000000;
			}
		}
	}
	// End:0x1F5
	if(__NFUN_130__(__NFUN_129__(pViewTarget.IsAlive()), __NFUN_129__(__NFUN_281__('PenaltyBox'))))
	{
		__NFUN_299__(OrthoRotation(cEyesPos.XAxis, __NFUN_211__(cEyesPos.ZAxis), cEyesPos.YAxis));
	}
	AdjustView(fDeltaTime);
	return;
}

event PlayerTick(float fDeltaTime)
{
	local int _iPingTime;

	// End:0x60
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_GameService, none), __NFUN_119__(Viewport(Player), none)), __NFUN_242__(m_GameService.CallNativeProcessIcmpPing(WindowConsole(Player.Console).szStoreIP, _iPingTime), true)))
	{
		ServerNewPing(_iPingTime);
	}
	// End:0xB9
	if(__NFUN_181__(m_fBlurReturnTime, float(0)))
	{
		__NFUN_185__(m_fTimedBlurValue, __NFUN_172__(__NFUN_171__(fDeltaTime, float(m_iShakeBlurIntensity)), m_fBlurReturnTime));
		// End:0xAC
		if(__NFUN_178__(m_fTimedBlurValue, float(0)))
		{
			m_fTimedBlurValue = 0.0000000;
			m_fBlurReturnTime = 0.0000000;
		}
		Blur(int(m_fTimedBlurValue));
	}
	// End:0xF2
	if(__NFUN_177__(m_fMilestoneMessageLeft, float(0)))
	{
		__NFUN_185__(m_fMilestoneMessageLeft, fDeltaTime);
		// End:0xF2
		if(__NFUN_176__(m_fMilestoneMessageLeft, float(0)))
		{
			m_fMilestoneMessageLeft = 0.0000000;
			m_bDisplayMilestoneMessage = false;
		}
	}
	// End:0x141
	if(__NFUN_130__(__NFUN_119__(GameReplicationInfo, none), __NFUN_155__(int(GameReplicationInfo.m_eCurrectServerState), GameReplicationInfo.3)))
	{
		// End:0x139
		if(__NFUN_119__(m_MenuCommunication, none))
		{
			m_MenuCommunication.RefreshReadyButtonStatus();
		}
		m_bReadyToEnterSpectatorMode = false;
	}
	// End:0x1A2
	if(__NFUN_130__(m_bAttachCameraToEyes, __NFUN_129__(bBehindView)))
	{
		// End:0x175
		if(__NFUN_119__(m_pawn, none))
		{
			SetEyeLocation(m_pawn, fDeltaTime);			
		}
		else
		{
			// End:0x1A2
			if(__NFUN_130__(__NFUN_119__(ViewTarget, none), __NFUN_119__(ViewTarget, self)))
			{
				SetEyeLocation(R6Pawn(ViewTarget), fDeltaTime);
			}
		}
	}
	// End:0x1EB
	if(__NFUN_130__(__NFUN_119__(Pawn, none), __NFUN_129__(bOnlySpectator)))
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
	if(__NFUN_130__(__NFUN_130__(__NFUN_129__(aRainbowTeam.m_bLeaderIsAPlayer), __NFUN_151__(aRainbowTeam.m_iMemberCount, 0)), __NFUN_119__(aRainbowTeam.m_OtherTeamVoicesMgr, none)))
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
		m_szMileStoneMessage = __NFUN_112__(Localize("Order", "MilestoneReached", "R6Menu"), string(iMilestoneNumber));
		m_bDisplayMilestoneMessage = true;
		m_fMilestoneMessageLeft = m_fMilestoneMessageDuration;
	}
	return;
}

// we need to do the appropriate animations for weapons,
simulated event RenderOverlays(Canvas Canvas)
{
	// End:0x3C
	if(__NFUN_119__(Pawn, none))
	{
		// End:0x3C
		if(__NFUN_119__(Pawn.EngineWeapon, none))
		{
			Pawn.EngineWeapon.RenderOverlays(Canvas);
		}
	}
	// End:0x5B
	if(__NFUN_119__(myHUD, none))
	{
		myHUD.RenderOverlays(Canvas);
	}
	return;
}

function ReloadWeapon()
{
	// End:0x16
	if(__NFUN_114__(Pawn.EngineWeapon, none))
	{
		return;
	}
	// End:0xA8
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_bLockWeaponActions), __NFUN_129__(m_pawn.m_bPostureTransition)), __NFUN_129__(Pawn.EngineWeapon.__NFUN_303__('R6Gadget'))), __NFUN_154__(int(m_pawn.m_eEquipWeapon), int(m_pawn.3))))
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
	if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)), __NFUN_154__(int(Role), int(ROLE_Authority))))
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

	__NFUN_229__(Pawn.Rotation, X, Y, Z);
	Dir = __NFUN_226__(Pawn.Acceleration);
	// End:0xA6
	if(__NFUN_130__(__NFUN_176__(__NFUN_219__(Dir, X), 0.2500000), __NFUN_218__(Dir, vect(0.0000000, 0.0000000, 0.0000000))))
	{
		// End:0x83
		if(__NFUN_176__(__NFUN_219__(Dir, X), -0.2500000))
		{
			return 32768;			
		}
		else
		{
			// End:0xA0
			if(__NFUN_177__(__NFUN_219__(Dir, Y), float(0)))
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

	iMaximum = int(__NFUN_171__(float(100000), m_fCurrentDeltaTime));
	rCurrent = Rotation;
	iOldPitch = m_iSpectatorPitch;
	iDesiredPitch = Rotation.Pitch;
	// End:0x5A
	if(__NFUN_151__(iDesiredPitch, 32768))
	{
		__NFUN_162__(iDesiredPitch, 65536);		
	}
	else
	{
		// End:0x75
		if(__NFUN_150__(iDesiredPitch, -32768))
		{
			__NFUN_161__(iDesiredPitch, 65536);
		}
	}
	// End:0x93
	if(__NFUN_151__(iOldPitch, 32768))
	{
		__NFUN_162__(iOldPitch, 65536);		
	}
	else
	{
		// End:0xAE
		if(__NFUN_150__(iOldPitch, -32768))
		{
			__NFUN_161__(iOldPitch, 65536);
		}
	}
	// End:0xD8
	if(__NFUN_176__(__NFUN_186__(float(__NFUN_147__(iDesiredPitch, iOldPitch))), float(iMaximum)))
	{
		m_iSpectatorPitch = iDesiredPitch;		
	}
	else
	{
		// End:0xFC
		if(__NFUN_151__(iDesiredPitch, iOldPitch))
		{
			m_iSpectatorPitch = __NFUN_146__(iOldPitch, iMaximum);			
		}
		else
		{
			m_iSpectatorPitch = __NFUN_147__(iOldPitch, iMaximum);
		}
	}
	rCurrent.Pitch = m_iSpectatorPitch;
	iOldYaw = __NFUN_156__(m_iSpectatorYaw, 65535);
	iDesiredYaw = __NFUN_156__(Rotation.Yaw, 65535);
	// End:0x1EA
	if(__NFUN_150__(iDesiredYaw, iOldYaw))
	{
		// End:0x1A5
		if(__NFUN_150__(__NFUN_147__(iOldYaw, iDesiredYaw), 32768))
		{
			// End:0x190
			if(__NFUN_150__(__NFUN_147__(iOldYaw, iDesiredYaw), iMaximum))
			{
				m_iSpectatorYaw = iDesiredYaw;				
			}
			else
			{
				m_iSpectatorYaw = __NFUN_147__(iOldYaw, iMaximum);
			}			
		}
		else
		{
			__NFUN_162__(iOldYaw, 65536);
			// End:0x1D5
			if(__NFUN_150__(__NFUN_147__(iDesiredYaw, iOldYaw), iMaximum))
			{
				m_iSpectatorYaw = iDesiredYaw;				
			}
			else
			{
				m_iSpectatorYaw = __NFUN_146__(iOldYaw, iMaximum);
			}
		}		
	}
	else
	{
		// End:0x239
		if(__NFUN_150__(__NFUN_147__(iDesiredYaw, iOldYaw), 32768))
		{
			// End:0x224
			if(__NFUN_150__(__NFUN_147__(iDesiredYaw, iOldYaw), iMaximum))
			{
				m_iSpectatorYaw = iDesiredYaw;				
			}
			else
			{
				m_iSpectatorYaw = __NFUN_146__(iOldYaw, iMaximum);
			}			
		}
		else
		{
			__NFUN_162__(iDesiredYaw, 65536);
			// End:0x269
			if(__NFUN_150__(__NFUN_147__(iOldYaw, iDesiredYaw), iMaximum))
			{
				m_iSpectatorYaw = iDesiredYaw;				
			}
			else
			{
				m_iSpectatorYaw = __NFUN_147__(iOldYaw, iMaximum);
			}
		}
	}
	rCurrent.Yaw = m_iSpectatorYaw;
	__NFUN_299__(rCurrent);
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
		CameraLocation = __NFUN_215__(ViewTarget.Location, Pawn(ViewTarget).EyePosition());
		return;		
	}
	else
	{
		// End:0xC0
		if(__NFUN_114__(Pawn, none))
		{
			// End:0xBE
			if(__NFUN_130__(__NFUN_119__(ViewTarget, none), __NFUN_119__(ViewTarget, self)))
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
		CameraRotation = __NFUN_316__(__NFUN_316__(DesiredRotation, Pawn.m_rRotationOffset), m_rHitRotation);		
	}
	else
	{
		CameraRotation = __NFUN_316__(__NFUN_316__(Rotation, Pawn.m_rRotationOffset), m_rHitRotation);
	}
	// End:0x134
	if(m_bAttachCameraToEyes)
	{
		CameraLocation = Pawn.m_vEyeLocation;		
	}
	else
	{
		CameraLocation = __NFUN_215__(CameraLocation, Pawn.EyePosition());
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
	if(__NFUN_130__(bOnlySpectator, __NFUN_119__(ViewTarget, none)))
	{
		// End:0x3E
		if(__NFUN_130__(R6Pawn(ViewTarget).m_bIsPlayer, bFixedCamera))
		{
			CalcSmoothedRotation();
		}
		CameraRotation = Rotation;		
	}
	else
	{
		// End:0x9B
		if(__NFUN_119__(Pawn, none))
		{
			// End:0x7F
			if(bRotateToDesired)
			{
				CameraRotation = __NFUN_316__(DesiredRotation, Pawn.m_rRotationOffset);				
			}
			else
			{
				CameraRotation = __NFUN_316__(Rotation, Pawn.m_rRotationOffset);
			}
		}
	}
	View = __NFUN_276__(vect(1.0000000, 0.0000000, 0.0000000), CameraRotation);
	// End:0x106
	if(__NFUN_119__(__NFUN_277__(HitLocation, HitNormal, __NFUN_216__(CameraLocation, __NFUN_213__(Dist, Vector(CameraRotation))), CameraLocation), none))
	{
		ViewDist = __NFUN_244__(__NFUN_219__(__NFUN_216__(CameraLocation, HitLocation), View), Dist);		
	}
	else
	{
		ViewDist = Dist;
	}
	__NFUN_224__(CameraLocation, __NFUN_213__(ViewDist, View));
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
	if(__NFUN_177__(aForward, float(0)))
	{
		// End:0x25
		if(__NFUN_177__(aStrafe, float(0)))
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
		if(__NFUN_177__(aStrafe, float(0)))
		{
			eSDir = 3;			
		}
		else
		{
			eSDir = 4;
		}
	}
	// End:0x6E
	if(__NFUN_154__(int(eSDir), int(m_pawn.m_eStrafeDirection)))
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
	iPitch = __NFUN_156__(iPitch, 65535);
	// End:0x58
	if(__NFUN_130__(__NFUN_151__(iPitch, 16384), __NFUN_150__(iPitch, 49152)))
	{
		// End:0x4D
		if(__NFUN_177__(aLookUp, float(0)))
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
	iYaw = __NFUN_156__(iYaw, 65535);
	// End:0x6A
	if(m_pawn.m_bIsClimbingLadder)
	{
		// End:0x6A
		if(__NFUN_130__(__NFUN_151__(iYaw, 10923), __NFUN_150__(iYaw, 54613)))
		{
			// End:0x5F
			if(__NFUN_177__(aTurn, float(0)))
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
	if(__NFUN_151__(iYaw, 32768))
	{
		__NFUN_162__(iYaw, 65536);		
	}
	else
	{
		// End:0xA3
		if(__NFUN_150__(iYaw, -32768))
		{
			__NFUN_161__(iYaw, 65536);
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
	if(__NFUN_130__(__NFUN_181__(aForward, float(0)), __NFUN_181__(aStrafe, float(0))))
	{
		// End:0x5B
		if(__NFUN_132__(DirectionChanged(), __NFUN_129__(m_pawn.m_bMovingDiagonally)))
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
		if(__NFUN_177__(__NFUN_186__(float(rRotationOffset.Yaw)), float(0)))
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
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		ServerSetCrouchBlend(fCrouchBlend);
	}
	return;
}

function ServerSetCrouchBlend(float fCrouchBlend)
{
	// End:0x0D
	if(__NFUN_114__(m_pawn, none))
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
	if(__NFUN_114__(m_pawn, none))
	{
		return;
	}
	m_pawn.SetPeekingInfo(eMode, fPeekingRatio, bPeekLeft);
	// End:0xC0
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		fNormalizedPeekingRatio = __NFUN_171__(__NFUN_172__(__NFUN_175__(fPeekingRatio, m_pawn.0.0000000), __NFUN_175__(m_pawn.2000.0000000, m_pawn.0.0000000)), 254.0000000);
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
	if(__NFUN_114__(m_pawn, none))
	{
		return;
	}
	fPeekingRatio = float(PackedPeekingRatio);
	fPeekingRatio = __NFUN_174__(__NFUN_171__(__NFUN_172__(fPeekingRatio, 254.0000000), __NFUN_175__(m_pawn.2000.0000000, m_pawn.0.0000000)), m_pawn.0.0000000);
	m_pawn.SetPeekingInfo(eMode, fPeekingRatio, true);
	return;
}

function ServerSetPeekingInfoRight(Pawn.ePeekingMode eMode, byte PackedPeekingRatio)
{
	local float fPeekingRatio;

	// End:0x0D
	if(__NFUN_114__(m_pawn, none))
	{
		return;
	}
	fPeekingRatio = float(PackedPeekingRatio);
	fPeekingRatio = __NFUN_174__(__NFUN_171__(__NFUN_172__(fPeekingRatio, 254.0000000), __NFUN_175__(m_pawn.2000.0000000, m_pawn.0.0000000)), m_pawn.0.0000000);
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
	if(__NFUN_119__(m_pawn, none))
	{
		m_pawn.m_iRepBipodRotationRatio = int(__NFUN_171__(__NFUN_172__(fRotation, float(m_pawn.5600)), float(100)));
	}
	return;
}

function bool PlayerIsFiring()
{
	// End:0x16
	if(__NFUN_114__(Pawn.EngineWeapon, none))
	{
		return false;
	}
	// End:0x45
	if(__NFUN_130__(__NFUN_151__(int(bFire), 0), __NFUN_151__(Pawn.EngineWeapon.NumberOfBulletsLeftInClip(), 0)))
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
	if(__NFUN_132__(bInterpolating, __NFUN_130__(__NFUN_119__(Pawn, none), Pawn.bInterpolating)))
	{
		return;
	}
	// End:0x54
	if(__NFUN_114__(m_pawn, none))
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
		fBipodRotationToAdd = __NFUN_171__(32.0000000, DeltaTime);
		DesiredRotation.Yaw = Rotation.Yaw;
		// End:0x1AF
		if(__NFUN_218__(Pawn.Velocity, vect(0.0000000, 0.0000000, 0.0000000)))
		{
			__NFUN_182__(fBipodRotationToAdd, float(2000));
			// End:0x105
			if(__NFUN_180__(m_pawn.m_fBipodRotation, float(0)))
			{				
			}
			else
			{
				// End:0x165
				if(__NFUN_177__(m_pawn.m_fBipodRotation, float(0)))
				{
					__NFUN_185__(m_pawn.m_fBipodRotation, fBipodRotationToAdd);
					m_pawn.m_fBipodRotation = __NFUN_246__(m_pawn.m_fBipodRotation, 0.0000000, m_pawn.m_fBipodRotation);					
				}
				else
				{
					__NFUN_184__(m_pawn.m_fBipodRotation, fBipodRotationToAdd);
					m_pawn.m_fBipodRotation = __NFUN_246__(m_pawn.m_fBipodRotation, m_pawn.m_fBipodRotation, 0.0000000);
				}
			}			
		}
		else
		{
			__NFUN_184__(m_pawn.m_fBipodRotation, __NFUN_171__(fBipodRotationToAdd, aTurn));
			// End:0x20E
			if(__NFUN_177__(m_pawn.m_fBipodRotation, float(m_pawn.5600)))
			{
				m_pawn.m_fBipodRotation = m_pawn.5600.0000000;				
			}
			else
			{
				// End:0x254
				if(__NFUN_176__(m_pawn.m_fBipodRotation, float(__NFUN_143__(m_pawn.5600))))
				{
					m_pawn.m_fBipodRotation = float(__NFUN_143__(m_pawn.5600));
				}
			}
		}
		ServerSetBipodRotation(m_pawn.m_fBipodRotation);		
	}
	else
	{
		// End:0x2A4
		if(__NFUN_130__(__NFUN_151__(int(m_bSpecialCrouch), 0), __NFUN_129__(m_pawn.m_bIsProne)))
		{
			aTurn = 0.0000000;
			aLookUp = 0.0000000;
		}
	}
	AWeapon = R6AbstractWeapon(Pawn.EngineWeapon);
	rViewRotation = __NFUN_316__(Rotation, rRotationOffset);
	__NFUN_161__(rViewRotation.Yaw, int(__NFUN_171__(__NFUN_171__(32.0000000, DeltaTime), aTurn)));
	// End:0x326
	if(__NFUN_129__(Level.m_bInGamePlanningActive))
	{
		__NFUN_161__(rViewRotation.Pitch, int(__NFUN_171__(__NFUN_171__(32.0000000, DeltaTime), aLookUp)));
	}
	AdjustViewPitch(rViewRotation.Pitch);
	rViewRotation.Roll = 0;
	// End:0x3A0
	if(__NFUN_130__(__NFUN_129__(bBehindView), __NFUN_181__(m_pawn.m_fPeeking, m_pawn.1000.0000000)))
	{
		rViewRotation.Roll = int(__NFUN_171__(m_pawn.__NFUN_1508__(m_pawn.m_fPeeking), float(2049)));
	}
	rRotationOffset = __NFUN_317__(rViewRotation, Rotation);
	AdjustViewYaw(rRotationOffset.Yaw);
	// End:0x417
	if(bRotateToDesired)
	{
		DesiredRotation.Yaw = __NFUN_156__(DesiredRotation.Yaw, 65535);
		// End:0x417
		if(__NFUN_155__(Rotation.Yaw, DesiredRotation.Yaw))
		{
			Pawn.m_rRotationOffset = rRotationOffset;
			return;
		}
	}
	bRotateToDesired = false;
	// End:0x789
	if(__NFUN_130__(__NFUN_132__(__NFUN_132__(__NFUN_218__(Pawn.Acceleration, vect(0.0000000, 0.0000000, 0.0000000)), __NFUN_181__(aForward, float(0))), __NFUN_181__(aStrafe, float(0))), __NFUN_129__(m_pawn.m_bIsClimbingLadder)))
	{
		// End:0x5F6
		if(m_pawn.m_bIsProne)
		{
			rRotationOffset.Yaw = __NFUN_251__(rRotationOffset.Yaw, __NFUN_143__(m_pawn.m_iMaxRotationOffset), m_pawn.m_iMaxRotationOffset);
			// End:0x540
			if(m_pawn.m_bUsingBipod)
			{
				// End:0x506
				if(__NFUN_130__(__NFUN_151__(rRotationOffset.Pitch, 5461), __NFUN_150__(rRotationOffset.Pitch, 18001)))
				{
					rRotationOffset.Pitch = 5461;
				}
				// End:0x540
				if(__NFUN_130__(__NFUN_150__(rRotationOffset.Pitch, 60075), __NFUN_151__(rRotationOffset.Pitch, 49000)))
				{
					rRotationOffset.Pitch = 60075;
				}
			}
			// End:0x5F3
			if(__NFUN_155__(rRotationOffset.Yaw, 0))
			{
				DesiredRotation.Yaw = m_pawn.Rotation.Yaw;
				// End:0x5A6
				if(__NFUN_151__(rRotationOffset.Yaw, 0))
				{
					fOffset = float(__NFUN_251__(rRotationOffset.Yaw, 0, int(__NFUN_171__(float(6600), DeltaTime))));					
				}
				else
				{
					fOffset = float(__NFUN_251__(rRotationOffset.Yaw, int(__NFUN_171__(float(__NFUN_143__(6600)), DeltaTime)), 0));
				}
				__NFUN_162__(rRotationOffset.Yaw, int(fOffset));
				__NFUN_161__(DesiredRotation.Yaw, int(fOffset));
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
		if(__NFUN_155__(Rotation.Yaw, DesiredRotation.Yaw))
		{
			__NFUN_299__(DesiredRotation);
			bRotateToDesired = true;			
		}
		else
		{
			// End:0x685
			if(__NFUN_129__(bBehindView))
			{
				Pawn.FaceRotation(DesiredRotation, DeltaTime);
			}
		}
		// End:0x738
		if(__NFUN_130__(__NFUN_130__(__NFUN_129__(bBoneRotationIsDone), m_pawn.m_bMovingDiagonally), __NFUN_129__(m_pawn.m_bIsProne)))
		{
			// End:0x701
			if(__NFUN_132__(__NFUN_154__(int(m_pawn.m_eStrafeDirection), int(1)), __NFUN_154__(int(m_pawn.m_eStrafeDirection), int(4))))
			{
				rRotationOffset.Yaw = -6000;				
			}
			else
			{
				rRotationOffset.Yaw = 6000;
			}
			m_pawn.__NFUN_2214__(rRotationOffset, true, true);
			rRotationOffset.Yaw = 0;
			bBoneRotationIsDone = true;
		}
		// End:0x786
		if(__NFUN_130__(__NFUN_129__(m_pawn.m_bMovingDiagonally), __NFUN_132__(PlayerIsFiring(), m_pawn.GunShouldFollowHead())))
		{
			m_pawn.__NFUN_2214__(rRotationOffset, true, true);
			bBoneRotationIsDone = true;
		}		
	}
	else
	{
		// End:0x87D
		if(m_pawn.m_bIsProne)
		{
			rRotationOffset.Yaw = __NFUN_251__(rRotationOffset.Yaw, __NFUN_143__(m_pawn.m_iMaxRotationOffset), m_pawn.m_iMaxRotationOffset);
			// End:0x856
			if(m_pawn.m_bUsingBipod)
			{
				// End:0x81C
				if(__NFUN_130__(__NFUN_151__(rRotationOffset.Pitch, 5461), __NFUN_150__(rRotationOffset.Pitch, 18001)))
				{
					rRotationOffset.Pitch = 5461;
				}
				// End:0x856
				if(__NFUN_130__(__NFUN_150__(rRotationOffset.Pitch, 60075), __NFUN_151__(rRotationOffset.Pitch, 49000)))
				{
					rRotationOffset.Pitch = 60075;
				}
			}
			// End:0x87A
			if(PlayerIsFiring())
			{
				m_pawn.__NFUN_2214__(rRotationOffset, true, false);
				bBoneRotationIsDone = true;
			}			
		}
		else
		{
			// End:0x8B6
			if(__NFUN_130__(__NFUN_130__(__NFUN_180__(aForward, float(0)), __NFUN_180__(aStrafe, float(0))), m_pawn.m_bMovingDiagonally))
			{
				HandleDiagonalStrafing();				
			}
			else
			{
				// End:0x96E
				if(__NFUN_132__(PassedYawLimit(rRotationOffset), __NFUN_130__(__NFUN_155__(rRotationOffset.Yaw, 0), m_pawn.IsPeeking())))
				{
					rNewRotation = __NFUN_316__(Rotation, rRotationOffset);
					rNewRotation.Pitch = 0;
					rNewRotation.Roll = 0;
					__NFUN_299__(rNewRotation);
					DesiredRotation = rViewRotation;
					DesiredRotation.Pitch = 0;
					DesiredRotation.Roll = 0;
					bRotateToDesired = true;
					rRotationOffset.Yaw = 0;
					m_pawn.__NFUN_2214__(rRotationOffset);
					bBoneRotationIsDone = true;
				}
			}
		}
	}
	// End:0x98A
	if(__NFUN_242__(m_bShakeActive, true))
	{
		R6ViewShake(DeltaTime, rRotationOffset);
	}
	// End:0x9A8
	if(__NFUN_129__(bBoneRotationIsDone))
	{
		m_pawn.__NFUN_2214__(rRotationOffset,, true);
	}
	ViewFlash(DeltaTime);
	rNewRotation = rViewRotation;
	rNewRotation.Roll = 0;
	// End:0xA2B
	if(__NFUN_130__(__NFUN_130__(__NFUN_129__(bRotateToDesired), __NFUN_119__(Pawn, none)), __NFUN_132__(__NFUN_129__(bFreeCamera), __NFUN_129__(bBehindView))))
	{
		// End:0xA2B
		if(__NFUN_180__(float(rRotationOffset.Yaw), 0.0000000))
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
	if(__NFUN_154__(int(m_pawn.m_ePeekingMode), int(2)))
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
	if(__NFUN_114__(m_pawn, none))
	{
		return;
	}
	// End:0x3E
	if(__NFUN_132__(__NFUN_154__(int(m_pawn.m_ePeekingMode), int(1)), __NFUN_129__(m_pawn.CanPeek())))
	{
		return;
	}
	// End:0x1C4
	if(__NFUN_130__(__NFUN_151__(int(m_bSpecialCrouch), 0), __NFUN_129__(m_pawn.m_bIsProne)))
	{
		// End:0xBF
		if(__NFUN_154__(int(m_pawn.m_ePeekingMode), int(0)))
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
		__NFUN_185__(fCrouchRate, __NFUN_172__(__NFUN_171__(aMouseY, DeltaTime), float(m_iFluidMovementSpeed)));
		fCrouchRate = __NFUN_246__(fCrouchRate, 0.0000000, 1.0000000);
		fPeekingRate = m_pawn.__NFUN_1508__(m_pawn.m_fPeeking);
		__NFUN_184__(fPeekingRate, __NFUN_172__(__NFUN_171__(aMouseX, DeltaTime), float(m_iFluidMovementSpeed)));
		fPeekingRate = __NFUN_246__(fPeekingRate, -1.0000000, 1.0000000);
		__NFUN_182__(fPeekingRate, m_pawn.1000.0000000);
		__NFUN_184__(fPeekingRate, m_pawn.1000.0000000);
		fPeekingRate = __NFUN_246__(fPeekingRate, m_pawn.0.0000000, m_pawn.2000.0000000);
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
	if(__NFUN_114__(m_TeamManager, none))
	{
		return;
	}
	// End:0x23
	if(__NFUN_154__(m_TeamManager.m_iMemberCount, 1))
	{
		return;
	}
	// End:0x39
	if(__NFUN_132__(bOnlySpectator, bCheatFlying))
	{
		return;
	}
	// End:0x89
	if(__NFUN_130__(m_TeamManager.m_bTeamIsHoldingPosition, __NFUN_129__(m_TeamManager.m_Team[1].Controller.__NFUN_281__('FollowLeader'))))
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
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		return;
	}
	// End:0x6B
	if(m_bAllTeamsHold)
	{
		m_bAllTeamsHold = false;
		// End:0x68
		if(__NFUN_119__(R6AbstractGameInfo(Level.Game), none))
		{
			R6AbstractGameInfo(Level.Game).InstructAllTeamsToFollowPlanning();
		}		
	}
	else
	{
		m_bAllTeamsHold = true;
		// End:0xA9
		if(__NFUN_119__(R6AbstractGameInfo(Level.Game), none))
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
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		i = 0;
		J0x20:

		// End:0xAC [Loop If]
		if(__NFUN_150__(i, 3))
		{
			aRainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetRainbowTeam(i));
			// End:0xA2
			if(__NFUN_130__(__NFUN_119__(aRainbowTeam, none), __NFUN_151__(aRainbowTeam.m_iMemberCount, 0)))
			{
				aRainbowTeam.m_bSniperHold = __NFUN_129__(aRainbowTeam.m_bSniperHold);
				__NFUN_165__(iNbTeam);
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x20;
		}
		// End:0xC6
		if(__NFUN_151__(iNbTeam, 1))
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
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		i = 0;
		J0x20:

		// End:0x9D [Loop If]
		if(__NFUN_150__(i, 3))
		{
			aRainbowTeam[i] = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetRainbowTeam(i));
			// End:0x93
			if(__NFUN_130__(__NFUN_119__(aRainbowTeam[i], none), __NFUN_151__(aRainbowTeam[i].m_iMemberCount, 0)))
			{
				__NFUN_165__(iNbTeam);
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x20;
		}
		// End:0x111
		if(__NFUN_151__(iNbTeam, 1))
		{
			m_TeamManager.PlaySoundTeamStatusReport();
			i = 0;
			J0xBE:

			// End:0x111 [Loop If]
			if(__NFUN_150__(i, 3))
			{
				// End:0x107
				if(__NFUN_130__(__NFUN_119__(aRainbowTeam[i], none), __NFUN_119__(m_TeamManager, aRainbowTeam[i])))
				{
					aRainbowTeam[i].PlaySoundTeamStatusReport();
				}
				__NFUN_165__(i);
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
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		ServerSendGoCode(NM_Standalone);
	}
	return;
}

exec function GoCodeBravo()
{
	// End:0x21
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		ServerSendGoCode(NM_DedicatedServer);
	}
	return;
}

exec function GoCodeCharlie()
{
	// End:0x21
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
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
	if(__NFUN_154__(int(eGo), int(3)))
	{
		// End:0xC1
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			i = 0;
			J0x61:

			// End:0xBE [Loop If]
			if(__NFUN_150__(i, 3))
			{
				aRainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetRainbowTeam(i));
				// End:0xB4
				if(__NFUN_119__(aRainbowTeam, none))
				{
					aRainbowTeam.ReceivedZuluGoCode();
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x61;
			}			
		}
		else
		{
			// End:0xDB
			if(__NFUN_119__(m_TeamManager, none))
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
	if(__NFUN_242__(bOnlySpectator, false))
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
	if(__NFUN_114__(m_TeamManager, none))
	{
		return;
	}
	// End:0x23
	if(__NFUN_132__(bOnlySpectator, bCheatFlying))
	{
		return;
	}
	// End:0x91
	if(__NFUN_129__(m_TeamManager.m_Team[0].IsAlive()))
	{
		// End:0x87
		if(__NFUN_151__(m_TeamManager.m_iMemberCount, 0))
		{
			// End:0x75
			if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
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
		if(__NFUN_129__(m_TeamManager.m_bTeamIsClimbingLadder))
		{
			m_TeamManager.InstructPlayerTeamToFollowLead();
		}
	}
	return;
}

exec function NextMember()
{
	// End:0x55
	if(__NFUN_242__(m_bCanChangeMember, true))
	{
		Pawn.EngineWeapon.StopFire(false);
		ServerNextMember();
		// End:0x55
		if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
		{
			m_bCanChangeMember = false;
			__NFUN_280__(1.0000000, false);
		}
	}
	return;
}

exec function PreviousMember()
{
	// End:0x55
	if(__NFUN_242__(m_bCanChangeMember, true))
	{
		Pawn.EngineWeapon.StopFire(false);
		ServerPreviousMember();
		// End:0x55
		if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
		{
			m_bCanChangeMember = false;
			__NFUN_280__(1.0000000, false);
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
	if(__NFUN_114__(m_pawn, none))
	{
		return;
	}
	// End:0x6E
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_pawn.m_bIsProne), __NFUN_129__(m_pawn.m_bChangingWeapon)), __NFUN_129__(m_pawn.m_bReloadingWeapon)), __NFUN_129__(Level.m_bInGamePlanningActive)))
	{
		ServerGraduallyOpenDoor(m_bSpeedUpDoor);
	}
	return;
}

exec function GraduallyCloseDoor()
{
	// End:0x0D
	if(__NFUN_114__(m_pawn, none))
	{
		return;
	}
	// End:0x6E
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_pawn.m_bIsProne), __NFUN_129__(m_pawn.m_bChangingWeapon)), __NFUN_129__(m_pawn.m_bReloadingWeapon)), __NFUN_129__(Level.m_bInGamePlanningActive)))
	{
		ServerGraduallyCloseDoor(m_bSpeedUpDoor);
	}
	return;
}

exec function RaisePosture()
{
	// End:0x0D
	if(__NFUN_114__(m_pawn, none))
	{
		return;
	}
	// End:0x1C
	if(__NFUN_151__(int(m_bSpecialCrouch), 0))
	{
		return;
	}
	// End:0xC5
	if(__NFUN_132__(__NFUN_132__(__NFUN_130__(m_pawn.m_bPostureTransition, __NFUN_129__(m_pawn.m_bIsLanding)), __NFUN_130__(__NFUN_130__(__NFUN_130__(m_pawn.m_bIsProne, __NFUN_119__(m_pawn.EngineWeapon, none)), R6AbstractWeapon(m_pawn.EngineWeapon).GotBipod()), m_bLockWeaponActions)), __NFUN_130__(m_pawn.m_bIsProne, m_pawn.m_bChangingWeapon)))
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
	if(__NFUN_154__(int(m_pawn.m_ePeekingMode), int(2)))
	{
		// End:0x146
		if(__NFUN_129__(m_pawn.__NFUN_2200__(0.0000000, true)))
		{
			return;
		}
		m_pawn.__NFUN_2200__(0.0000000);
		ResetFluidPeeking();
	}
	// End:0x1A8
	if(m_bCrawl)
	{
		m_bCrawl = false;
		bDuck = 1;
		// End:0x1A5
		if(__NFUN_154__(int(m_pawn.m_ePeekingMode), int(1)))
		{
			SetPeekingInfo(0, m_pawn.1000.0000000);
		}		
	}
	else
	{
		// End:0x1D1
		if(__NFUN_154__(int(bDuck), 1))
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
	if(__NFUN_114__(m_pawn, none))
	{
		return;
	}
	// End:0x1C
	if(__NFUN_151__(int(m_bSpecialCrouch), 0))
	{
		return;
	}
	// End:0x6E
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(bDuck), 1), __NFUN_119__(m_pawn.EngineWeapon, none)), R6AbstractWeapon(m_pawn.EngineWeapon).GotBipod()), m_bLockWeaponActions))
	{
		return;
	}
	// End:0xAB
	if(__NFUN_154__(int(m_pawn.m_ePeekingMode), int(2)))
	{
		// End:0xA5
		if(__NFUN_154__(int(bDuck), 0))
		{
			m_pawn.__NFUN_2200__(0.9600000);
		}
		ResetFluidPeeking();
	}
	// End:0xD7
	if(__NFUN_154__(int(bDuck), 0))
	{
		bDuck = 1;
		R6Pawn(Pawn).StandToCrouch();		
	}
	else
	{
		// End:0x119
		if(__NFUN_129__(m_bCrawl))
		{
			// End:0x111
			if(__NFUN_154__(int(m_pawn.m_ePeekingMode), int(1)))
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
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		__NFUN_139__(m_wAutoAim);
		// End:0x36
		if(__NFUN_151__(int(m_wAutoAim), 3))
		{
			m_wAutoAim = 0;
		}
		ClientGameMsg("", "", __NFUN_112__("AutoAim", string(m_wAutoAim)));
		Class'Engine.Actor'.static.__NFUN_1009__().AutoTargetSlider = int(m_wAutoAim);		
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
	if(__NFUN_119__(Pawn.EngineWeapon, none))
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
	if(__NFUN_114__(m_TeamManager, none))
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
	if(__NFUN_114__(m_TeamManager, none))
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
	if(__NFUN_155__(int(m_pawn.m_ePeekingMode), int(2)))
	{
		return;
	}
	// End:0x3E
	if(__NFUN_179__(m_pawn.m_fCrouchBlendRate, 0.5000000))
	{
		bDuck = 1;		
	}
	else
	{
		// End:0x5E
		if(m_pawn.__NFUN_2200__(0.0000000, true))
		{
			bDuck = 0;			
		}
		else
		{
			bDuck = 1;
		}
	}
	// End:0x87
	if(__NFUN_154__(int(bDuck), 1))
	{
		m_pawn.__NFUN_2200__(0.9600000);		
	}
	else
	{
		m_pawn.__NFUN_2200__(0.0000000);
	}
	ResetFluidPeeking();
	return;
}

exec function PlayFiring()
{
	// End:0x3F
	if(__NFUN_130__(__NFUN_119__(Pawn, none), __NFUN_242__(GameReplicationInfo.m_bGameOverRep, false)))
	{
		Pawn.EngineWeapon.Fire(0.0000000);
	}
	return;
}

exec function PlayAltFiring()
{
	// End:0x31
	if(__NFUN_119__(Pawn.EngineWeapon, none))
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
	if(__NFUN_114__(m_TeamManager, none))
	{
		return;
	}
	m_TeamManager.SwitchPlayerControlToNextMember();
	return;
}

function ServerPreviousMember()
{
	// End:0x0D
	if(__NFUN_114__(m_TeamManager, none))
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
	if(__NFUN_130__(__NFUN_119__(m_pawn.m_Door, none), __NFUN_119__(m_pawn.m_Door2, none)))
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

	vDoor1 = __NFUN_226__(__NFUN_216__(m_pawn.m_Door.m_RotatingDoor.m_vCenterOfDoor, __NFUN_215__(Pawn.Location, Pawn.EyePosition())));
	vDoor2 = __NFUN_226__(__NFUN_216__(m_pawn.m_Door2.m_RotatingDoor.m_vCenterOfDoor, __NFUN_215__(Pawn.Location, Pawn.EyePosition())));
	vResult = __NFUN_220__(vDoor1, vDoor2);
	// End:0xE1
	if(__NFUN_177__(vResult.Z, float(0)))
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
	vCenter = __NFUN_214__(__NFUN_215__(leftDoor.m_RotatingDoor.m_vCenterOfDoor, rightDoor.m_RotatingDoor.m_vCenterOfDoor), float(2));
	vCutOff = __NFUN_226__(__NFUN_216__(vCenter, __NFUN_215__(Pawn.Location, Pawn.EyePosition())));
	vResult = __NFUN_220__(vCutOff, vLookDir);
	// End:0x1D0
	if(__NFUN_177__(vResult.Z, float(0)))
	{
		// End:0x1CB
		if(__NFUN_114__(leftDoor, m_pawn.m_Door))
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
		if(__NFUN_114__(rightDoor, m_pawn.m_Door))
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
	if(__NFUN_114__(m_pawn.m_Door, none))
	{
		return false;
	}
	// End:0x3D
	if(__NFUN_114__(m_pawn.m_Door.m_RotatingDoor, none))
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
		if(__NFUN_114__(m_CurrentCircumstantialAction.aQueryTarget, m_pawn.m_Door.m_RotatingDoor))
		{
			bIsLookingAtFirstDoor = true;			
		}
		else
		{
			// End:0xD6
			if(__NFUN_114__(m_CurrentCircumstantialAction.aQueryTarget, m_pawn.m_Door2.m_RotatingDoor))
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
	if(__NFUN_180__(LastDoorUpdateTime, float(0)))
	{
		LastDoorUpdateTime = Level.TimeSeconds;		
	}
	else
	{
		// End:0x15C
		if(__NFUN_179__(__NFUN_175__(Level.TimeSeconds, LastDoorUpdateTime), 0.5000000))
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
	if(__NFUN_129__(bStatus))
	{
		return;
	}
	speed = m_iDoorSpeed;
	// End:0x42
	if(__NFUN_151__(int(bSpeedUpDoor), 0))
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
	if(__NFUN_129__(bStatus))
	{
		return;
	}
	speed = __NFUN_143__(m_iDoorSpeed);
	// End:0x46
	if(__NFUN_151__(int(bSpeedUpDoor), 0))
	{
		speed = __NFUN_143__(m_iFastDoorSpeed);
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
	if(__NFUN_130__(m_pawn.m_bIsProne, __NFUN_218__(Pawn.Acceleration, vect(0.0000000, 0.0000000, 0.0000000))))
	{
		// End:0x63
		if(__NFUN_155__(int(m_pawn.m_ePeekingMode), int(0)))
		{
			SetPeekingInfo(0, m_pawn.1000.0000000);
		}
		return;
	}
	// End:0x135
	if(__NFUN_132__(__NFUN_130__(__NFUN_154__(int(m_bPeekLeft), 1), __NFUN_154__(int(m_bOldPeekLeft), 1)), __NFUN_130__(__NFUN_154__(int(m_bPeekRight), 1), __NFUN_154__(int(m_bOldPeekRight), 1))))
	{
		// End:0x135
		if(__NFUN_130__(__NFUN_129__(m_pawn.IsPeeking()), __NFUN_129__(m_pawn.m_bPostureTransition)))
		{
			// End:0x135
			if(__NFUN_132__(__NFUN_130__(__NFUN_130__(m_pawn.bIsCrouched, m_pawn.bWantsToCrouch), __NFUN_242__(m_bCrawl, false)), __NFUN_130__(m_pawn.m_bWantsToProne, m_pawn.m_bIsProne)))
			{
				m_bOldPeekRight = 0;
				m_bOldPeekLeft = 0;
			}
		}
	}
	// End:0x1CE
	if(__NFUN_132__(__NFUN_155__(int(m_bOldPeekLeft), int(m_bPeekLeft)), __NFUN_155__(int(m_bOldPeekRight), int(m_bPeekRight))))
	{
		// End:0x171
		if(m_pawn.m_bPostureTransition)
		{
			return;
		}
		CommonUpdatePeeking(m_bPeekLeft, m_bPeekRight);
		// End:0x1CE
		if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
		{
			bPeekingLeft = __NFUN_155__(int(m_bPeekLeft), 0);
			bPeekingRight = __NFUN_155__(int(m_bPeekRight), 0);
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
	if(__NFUN_154__(int(m_pawn.m_ePeekingMode), int(1)))
	{
		// End:0x77
		if(m_pawn.IsPeekingLeft())
		{
			// End:0x74
			if(__NFUN_154__(int(bPeekLeftButton), 0))
			{
				// End:0x5E
				if(__NFUN_154__(int(bPeekRightButton), 1))
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
			if(__NFUN_154__(int(bPeekRightButton), 0))
			{
				// End:0xAB
				if(__NFUN_154__(int(bPeekLeftButton), 1))
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
		if(__NFUN_130__(__NFUN_129__(__NFUN_154__(int(m_pawn.m_ePeekingMode), int(1))), m_pawn.CanPeek()))
		{
			// End:0x120
			if(__NFUN_151__(int(bPeekLeftButton), 0))
			{
				ResetSpecialCrouch();
				SetPeekingInfo(1, m_pawn.0.0000000, true);				
			}
			else
			{
				// End:0x14A
				if(__NFUN_151__(int(bPeekRightButton), 0))
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
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.bIsWalking = __NFUN_132__(__NFUN_154__(int(bRun), 0), __NFUN_155__(int(m_pawn.m_eHealth), int(0)));
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
	if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)), __NFUN_154__(int(Level.NetMode), int(NM_Client))))
	{
		return;
	}
	m_bRequestTKPopUp = false;
	// End:0x59
	if(__NFUN_132__(__NFUN_242__(_bApplyTeamKillerPenalty, false), __NFUN_114__(m_TeamKiller, none)))
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
	if(__NFUN_132__(__NFUN_114__(GameReplicationInfo, none), __NFUN_130__(__NFUN_119__(m_MenuCommunication, none), __NFUN_119__(m_MenuCommunication.m_GameRepInfo, none))))
	{
		return;
	}
	// End:0x144
	if(__NFUN_119__(Viewport(Player), none))
	{
		m_MenuCommunication = Player.Console.Master.m_MenuCommunication;
		// End:0x73
		if(__NFUN_114__(m_MenuCommunication, none))
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
		if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer))))
		{
			// End:0x144
			if(__NFUN_155__(int(m_TeamSelection), int(0)))
			{
				ServerTeamRequested(m_TeamSelection);
				// End:0x144
				if(__NFUN_242__(m_bDeadAfterTeamSel, true))
				{
					m_bDeadAfterTeamSel = false;
					__NFUN_113__('Dead');
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
	if(__NFUN_130__(__NFUN_129__(bForceSelection), R6AbstractGameInfo(Level.Game).IsTeamSelectionLocked()))
	{
		return;
	}
	// End:0x64
	if(__NFUN_130__(__NFUN_130__(GameReplicationInfo.IsInAGameState(), __NFUN_119__(Pawn, none)), Pawn.IsAlive()))
	{
		return;
	}
	_P = Level.ControllerList;
	J0x78:

	// End:0x126 [Loop If]
	if(__NFUN_119__(_P, none))
	{
		// End:0x10F
		if(__NFUN_130__(_P.__NFUN_303__('PlayerController'), __NFUN_119__(_P.PlayerReplicationInfo, none)))
		{
			PRI = _P.PlayerReplicationInfo;
			// End:0x10F
			if(__NFUN_119__(PRI, PlayerReplicationInfo))
			{
				// End:0xF1
				if(__NFUN_154__(PRI.TeamID, int(2)))
				{
					__NFUN_165__(iTeamA);					
				}
				else
				{
					// End:0x10F
					if(__NFUN_154__(PRI.TeamID, int(3)))
					{
						__NFUN_165__(iTeamB);
					}
				}
			}
		}
		_P = _P.nextController;
		// [Loop Continue]
		goto J0x78;
	}
	// End:0x186
	if(__NFUN_242__(__NFUN_1320__(), false))
	{
		eTeamSelected = 4;
		ClientPBVersionMismatch();
		// End:0x186
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("PlayerController ", string(self)), " has a PunkBuster version mismatch"));
		}
	}
	// End:0x1B8
	if(__NFUN_154__(int(eTeamSelected), int(1)))
	{
		// End:0x1B0
		if(__NFUN_151__(iTeamA, iTeamB))
		{
			eTeamSelected = 3;			
		}
		else
		{
			eTeamSelected = 2;
		}
	}
	bSameTeam = __NFUN_154__(PlayerReplicationInfo.TeamID, int(eTeamSelected));
	iMaxPlayerOnTeam = __NFUN_1302__().GetMaxNbPlayers(GameReplicationInfo.m_szGameTypeFlagRep);
	// End:0x263
	if(__NFUN_152__(iMaxPlayerOnTeam, __NFUN_146__(iTeamA, iTeamB)))
	{
		// End:0x23D
		if(__NFUN_132__(__NFUN_154__(int(m_TeamSelection), int(2)), __NFUN_154__(int(m_TeamSelection), int(3))))
		{
			eTeamSelected = m_TeamSelection;			
		}
		else
		{
			eTeamSelected = 4;
		}
		bSameTeam = __NFUN_154__(PlayerReplicationInfo.TeamID, int(eTeamSelected));
	}
	// End:0x313
	if(__NFUN_129__(bSameTeam))
	{
		iMaxPlayerOnTeam = __NFUN_1302__().GetMaxNbPlayers(GameReplicationInfo.m_szGameTypeFlagRep);
		// End:0x2C7
		if(Level.IsGameTypeTeamAdversarial(Level.Game.m_szCurrGameType))
		{
			iMaxPlayerOnTeam = __NFUN_145__(iMaxPlayerOnTeam, 2);
		}
		// End:0x313
		if(__NFUN_132__(__NFUN_130__(__NFUN_154__(int(eTeamSelected), int(2)), __NFUN_153__(iTeamA, iMaxPlayerOnTeam)), __NFUN_130__(__NFUN_154__(int(eTeamSelected), int(3)), __NFUN_153__(iTeamB, iMaxPlayerOnTeam))))
		{
			ClientTeamFullMessage();
			return;
		}
	}
	m_TeamSelection = eTeamSelected;
	PlayerReplicationInfo.TeamID = int(eTeamSelected);
	// End:0x3B8
	if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_119__(Level.Game, none)))
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
	if(__NFUN_129__(bSameTeam))
	{
		szMessageLocTag = "ChangedTeamSpectator";
		// End:0x45C
		if(Level.IsGameTypeTeamAdversarial(Level.Game.m_szCurrGameType))
		{
			// End:0x433
			if(__NFUN_154__(int(eTeamSelected), int(2)))
			{
				szMessageLocTag = "ChangedGreenTeam";				
			}
			else
			{
				// End:0x459
				if(__NFUN_154__(int(eTeamSelected), int(3)))
				{
					szMessageLocTag = "ChangedRedTeam";
				}
			}			
		}
		else
		{
			// End:0x484
			if(__NFUN_154__(int(eTeamSelected), int(2)))
			{
				szMessageLocTag = "HasJoinedTheGame";
			}
		}
		// End:0x4B7
		foreach __NFUN_313__(Class'R6Engine.R6PlayerController', P)
		{
			P.ClientMPMiscMessage(szMessageLocTag, PlayerReplicationInfo.PlayerName);			
		}		
	}
	// End:0x4CE
	if(__NFUN_119__(Viewport(Player), none))
	{
		PlayerTeamSelectionReceived();
	}
	return;
}

simulated event bool IsPlayerPassiveSpectator()
{
	return __NFUN_132__(__NFUN_154__(int(m_TeamSelection), int(0)), __NFUN_154__(int(m_TeamSelection), int(4)));
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
	if(__NFUN_130__(__NFUN_254__(__NFUN_284__(), 'BaseSpectating'), __NFUN_254__(NewState, 'Dead')))
	{
		m_bDeadAfterTeamSel = true;
		return;
	}
	// End:0x3D
	if(__NFUN_254__(__NFUN_284__(), NewState))
	{
		ResetCurrentState();
		return;
	}
	// End:0x56
	if(__NFUN_254__(NewLabel, 'None'))
	{
		__NFUN_113__(NewState);		
	}
	else
	{
		__NFUN_113__(NewState, NewLabel);
	}
	return;
}

exec function Suicide()
{
	// End:0x12
	if(__NFUN_114__(R6Pawn(Pawn), none))
	{
		return;
	}
	// End:0x28
	if(__NFUN_129__(m_pawn.IsAlive()))
	{
		return;
	}
	// End:0x35
	if(__NFUN_114__(GameReplicationInfo, none))
	{
		return;
	}
	// End:0x66
	if(__NFUN_122__(GameReplicationInfo.m_szGameTypeFlagRep, "RGM_CaptureTheEnemyAdvMode"))
	{
		return;
	}
	// End:0xA3
	if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_155__(int(GameReplicationInfo.m_eCurrectServerState), GameReplicationInfo.3)))
	{
		return;
	}
	// End:0xCB
	if(__NFUN_132__(GameReplicationInfo.m_bInPostBetweenRoundTime, GameReplicationInfo.m_bGameOverRep))
	{
		return;
	}
	R6Pawn(Pawn).ServerSuicidePawn(3);
	// End:0x124
	if(__NFUN_119__(Player.Console, none))
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
	if(__NFUN_119__(Pawn, none))
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
			R6Pawn(Pawn).__NFUN_2004__(false, none, none);
			R6Pawn(Pawn).__NFUN_2600__(false, none, none);
			R6Pawn(Pawn).__NFUN_2605__(false, none, none);
			Level.m_bHeartBeatOn = false;
			ResetBlur();
			Level.m_bInGamePlanningActive = false;
			__NFUN_2011__(false);
			// End:0x15C
			if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)), __NFUN_129__(PlayerCanSwitchToAIBackup())))
			{
				AWeapon = R6AbstractWeapon(Pawn.EngineWeapon);
				// End:0x159
				if(__NFUN_119__(AWeapon, none))
				{
					AWeapon.__NFUN_113__('None');
					AWeapon.DisableWeaponOrGadget();
					// End:0x159
					if(__NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer)))
					{
						AWeapon.RemoveFirstPersonWeapon();
					}
				}				
			}
			else
			{
				// End:0x1BA
				if(__NFUN_129__(bChangingPawn))
				{
					m_bShowFPWeapon = false;
					m_bHideReticule = true;
					R6AbstractWeapon(Pawn.m_WeaponsCarried[0]).R6SetReticule(self);
					R6AbstractWeapon(Pawn.m_WeaponsCarried[1]).R6SetReticule(self);					
				}
				else
				{
					// End:0x243
					if(__NFUN_132__(__NFUN_242__(m_GameOptions.HUDShowFPWeapon, true), __NFUN_242__(R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon, true)))
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
	__NFUN_113__('PlayerStartSurrenderSequence');
	return;
}

function ServerStartSurrended()
{
	m_bSkipBeginState = false;
	__NFUN_113__('PlayerSurrended');
	return;
}

function ClientEndSurrended()
{
	m_bSkipBeginState = false;
	m_pawn.m_eHealth = 0;
	m_pawn.m_bIsSurrended = false;
	__NFUN_113__('PlayerEndSurrended');
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
	if(__NFUN_119__(Pawn, none))
	{
		__NFUN_229__(Pawn.Rotation, X, Y, Z);
	}
	NewAccel = __NFUN_215__(__NFUN_213__(aForward, X), __NFUN_213__(aStrafe, Y));
	NewAccel.Z = 0.0000000;
	DoubleClickMove = getPlayerInput().CheckForDoubleClickMove(DeltaTime);
	GroundPitch = 0;
	// End:0xBE
	if(__NFUN_119__(Pawn, none))
	{
		ViewRotation = Pawn.Rotation;
		__NFUN_299__(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1.0000000);
	}
	// End:0xF3
	if(__NFUN_150__(int(Role), int(ROLE_Authority)))
	{
		ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, __NFUN_317__(OldRotation, Rotation));		
	}
	else
	{
		ProcessMove(DeltaTime, NewAccel, DoubleClickMove, __NFUN_317__(OldRotation, Rotation));
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
	if(m_PlayerCurrentCA.aQueryTarget.__NFUN_303__('R6Terrorist'))
	{
		__NFUN_113__('PlayerSecureTerrorist');		
	}
	else
	{
		// End:0xC0
		if(__NFUN_130__(Class'Engine.Actor'.static.__NFUN_1524__().IsMissionPack(), m_PlayerCurrentCA.aQueryTarget.__NFUN_303__('R6Rainbow')))
		{
			// End:0xB6
			if(bShowLog)
			{
				__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Log ", string(self)), "  I'm going to secure rainbow : "), string(m_PlayerCurrentCA.aQueryTarget)));
			}
			__NFUN_113__('PlayerSecureRainbow');			
		}
		else
		{
			__NFUN_113__('PlayerActionProgress');
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
	if(Class'Engine.Actor'.static.__NFUN_1524__().IsMissionPack())
	{
		// End:0x67
		if(__NFUN_130__(m_pawn.IsAlive(), __NFUN_129__(m_pawn.m_bIsSurrended)))
		{
			__NFUN_113__('PlayerWalking');
		}		
	}
	else
	{
		// End:0x83
		if(m_pawn.IsAlive())
		{
			__NFUN_113__('PlayerWalking');
		}
	}
	// End:0x9D
	if(__NFUN_119__(m_InteractionCA, none))
	{
		m_InteractionCA.ActionProgressStop();
	}
	return;
}

function ServerStartClimbingLadder()
{
	m_bSkipBeginState = false;
	__NFUN_113__('PlayerBeginClimbingLadder');
	return;
}

function ExtractMissingLadderInformation()
{
	// End:0x5D
	if(__NFUN_130__(__NFUN_114__(m_pawn.m_Ladder, none), __NFUN_119__(Pawn.OnLadder, none)))
	{
		m_pawn.m_Ladder = R6Ladder(m_pawn.LocateLadderActor(Pawn.OnLadder));
		return;
	}
	// End:0xAD
	if(__NFUN_130__(__NFUN_114__(Pawn.OnLadder, none), __NFUN_119__(m_pawn.m_Ladder, none)))
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
	C = Class'Engine.Actor'.static.__NFUN_2618__();
	// End:0x35
	if(__NFUN_119__(C, none))
	{
		C.__NFUN_2005__(0);
	}
	return;
}

// 0 is no blur, 100 is full blur
function Blur(int iValue)
{
	// End:0x38
	if(__NFUN_119__(Pawn, none))
	{
		iValue = __NFUN_251__(iValue, 0, 100);
		Pawn.m_fBlurValue = __NFUN_171__(float(iValue), 2.3500000);
	}
	return;
}

// set the zoom level of the camera on the helmet
function HelmetCameraZoom(float fZoomLevel)
{
	DefaultFOV = __NFUN_172__(default.DesiredFOV, fZoomLevel);
	DesiredFOV = DefaultFOV;
	m_bHelmetCameraOn = __NFUN_181__(fZoomLevel, float(1));
	// End:0x58
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
	{
		ServerSetHelmetParams(fZoomLevel, m_bScopeZoom);
	}
	return;
}

function ServerSetHelmetParams(float fZoomLevel, bool bScopeZoom)
{
	// End:0x23
	if(__NFUN_130__(__NFUN_119__(m_pawn, none), __NFUN_129__(m_pawn.IsAlive())))
	{
		return;
	}
	m_bHelmetCameraOn = __NFUN_181__(fZoomLevel, float(1));
	// End:0x50
	if(__NFUN_177__(fZoomLevel, 2.0000000))
	{
		m_bSniperMode = m_bHelmetCameraOn;
	}
	m_bScopeZoom = bScopeZoom;
	return;
}

function ToggleHelmetCameraZoom(optional bool bTurnOff)
{
	// End:0x19
	if(__NFUN_130__(__NFUN_242__(bTurnOff, false), m_bLockWeaponActions))
	{
		return;
	}
	// End:0x85
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(Pawn.EngineWeapon, none), __NFUN_242__(Pawn.EngineWeapon.HasScope(), true)), __NFUN_242__(m_bSniperMode, false)), __NFUN_242__(bTurnOff, false)))
	{
		Pawn.EngineWeapon.__NFUN_113__('ZoomIn');		
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
	if(__NFUN_132__(__NFUN_114__(Pawn, none), __NFUN_114__(Pawn.EngineWeapon, none)))
	{
		return;
	}
	// End:0x194
	if(m_bHelmetCameraOn)
	{
		// End:0xE8
		if(__NFUN_130__(__NFUN_130__(__NFUN_242__(Pawn.EngineWeapon.IsSniperRifle(), true), __NFUN_242__(m_bScopeZoom, false)), __NFUN_242__(bTurnOff, false)))
		{
			m_bScopeZoom = true;
			Pawn.EngineWeapon.WeaponZoomSound(false);
			HelmetCameraZoom(Pawn.EngineWeapon.m_fMaxZoom);
			m_pawn.m_fWeaponJump = __NFUN_172__(Pawn.EngineWeapon.GetWeaponJump(), float(2));
			m_pawn.m_fZoomJumpReturn = 0.2000000;			
		}
		else
		{
			// End:0x127
			if(__NFUN_242__(Pawn.EngineWeapon.HasScope(), true))
			{
				Pawn.EngineWeapon.__NFUN_113__('ZoomOut');
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
		if(__NFUN_242__(bTurnOff, true))
		{
			return;
		}
		R6Pawn(Pawn).ToggleScopeVision();
		// End:0x234
		if(__NFUN_242__(Pawn.EngineWeapon.IsSniperRifle(), true))
		{
			HelmetCameraZoom(3.5000000);
			m_bUseFirstPersonWeapon = false;
			m_bSniperMode = true;
			m_pawn.m_fWeaponJump = __NFUN_172__(Pawn.EngineWeapon.GetWeaponJump(), 1.5000000);
			m_pawn.m_fZoomJumpReturn = 0.5000000;			
		}
		else
		{
			// End:0x2A3
			if(__NFUN_119__(Pawn.EngineWeapon.m_ScopeTexture, none))
			{
				m_bSniperMode = true;
				m_bUseFirstPersonWeapon = false;
				m_pawn.m_fWeaponJump = __NFUN_172__(Pawn.EngineWeapon.GetWeaponJump(), 1.5000000);
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
	if(__NFUN_130__(__NFUN_119__(Pawn, none), __NFUN_242__(Pawn.EngineWeapon.IsSniperRifle(), true)))
	{
		// End:0x60
		if(__NFUN_242__(m_bHelmetCameraOn, true))
		{
			// End:0x53
			if(__NFUN_242__(m_bScopeZoom, true))
			{
				return __NFUN_171__(fWeaponMaxZoom, 0.5000000);				
			}
			else
			{
				return __NFUN_171__(fWeaponMaxZoom, 0.2500000);
			}
		}		
	}
	else
	{
		// End:0x7C
		if(__NFUN_242__(m_bHelmetCameraOn, true))
		{
			return __NFUN_171__(fWeaponMaxZoom, 0.5000000);
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
	if(__NFUN_130__(__NFUN_180__(vImpactDirection.X, float(0)), __NFUN_180__(vImpactDirection.Y, float(0))))
	{
		return;
	}
	ShakeRollTime = __NFUN_174__(fWaveTime, m_pawn.m_fStunShakeTime);
	// End:0x5D
	if(__NFUN_176__(m_fShakeReturnTime, fReturnTime))
	{
		m_fShakeReturnTime = fReturnTime;
	}
	// End:0x77
	if(__NFUN_176__(MaxShakeRoll, fRollMax))
	{
		MaxShakeRoll = fRollMax;
	}
	__NFUN_229__(Rotation, vRotationX, vRotationY, vRotationZ);
	vRotationX.Z = 0.0000000;
	vRotationX = __NFUN_226__(vRotationX);
	vRotationY.Z = 0.0000000;
	vRotationY = __NFUN_226__(vRotationY);
	MaxShakeOffset = __NFUN_211__(vImpactDirection);
	MaxShakeOffset.Z = 0.0000000;
	MaxShakeOffset = __NFUN_226__(MaxShakeOffset);
	iPitchOrientation = 1;
	fCosValue = __NFUN_219__(MaxShakeOffset, vRotationX);
	// End:0x122
	if(__NFUN_176__(fCosValue, float(0)))
	{
		iPitchOrientation = -1;
	}
	iRollOrientation = 1;
	fCosValueRoll = __NFUN_219__(MaxShakeOffset, vRotationY);
	// End:0x153
	if(__NFUN_177__(fCosValueRoll, float(0)))
	{
		iRollOrientation = -1;
	}
	MaxShakeOffset.X = __NFUN_171__(__NFUN_171__(fCosValue, fCosValue), float(iPitchOrientation));
	MaxShakeOffset.Z = __NFUN_171__(__NFUN_175__(1.0000000, __NFUN_186__(MaxShakeOffset.X)), float(iRollOrientation));
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
	if(__NFUN_130__(__NFUN_119__(m_pawn, none), m_pawn.m_bActivateNightVision))
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
	if(__NFUN_177__(ShakeRollTime, float(0)))
	{
		__NFUN_185__(ShakeRollTime, fDeltaTime);
		// End:0x31
		if(__NFUN_176__(ShakeRollTime, float(0)))
		{
			ShakeRollTime = 0.0000000;
		}
	}
	// End:0x140
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_181__(MaxShakeRoll, float(0)), __NFUN_176__(__NFUN_186__(float(m_rTotalShake.Pitch)), MaxShakeRoll)), __NFUN_176__(__NFUN_186__(float(m_rTotalShake.Yaw)), MaxShakeRoll)), __NFUN_176__(__NFUN_186__(float(m_rTotalShake.Roll)), MaxShakeRoll)))
	{
		m_rCurrentShakeRotation.Pitch = int(__NFUN_171__(__NFUN_171__(ShakeRollRate, fDeltaTime), MaxShakeOffset.X));
		__NFUN_161__(m_rTotalShake.Pitch, m_rCurrentShakeRotation.Pitch);
		m_rCurrentShakeRotation.Yaw = int(__NFUN_171__(__NFUN_171__(ShakeRollRate, fDeltaTime), MaxShakeOffset.Y));
		__NFUN_161__(m_rTotalShake.Yaw, m_rCurrentShakeRotation.Yaw);
		m_rCurrentShakeRotation.Roll = int(__NFUN_171__(__NFUN_171__(ShakeRollRate, fDeltaTime), MaxShakeOffset.Z));
		__NFUN_161__(m_rTotalShake.Roll, m_rCurrentShakeRotation.Roll);		
	}
	else
	{
		// End:0x3F0
		if(__NFUN_181__(ShakeRollTime, float(0)))
		{
			MaxShakeOffset.X = __NFUN_195__();
			MaxShakeOffset.Y = __NFUN_195__();
			MaxShakeOffset.Z = __NFUN_195__();
			// End:0x1E9
			if(__NFUN_179__(__NFUN_186__(float(m_rTotalShake.Pitch)), MaxShakeRoll))
			{
				// End:0x1CD
				if(__NFUN_151__(m_rTotalShake.Pitch, 0))
				{
					m_rTotalShake.Pitch = int(__NFUN_175__(MaxShakeRoll, float(1)));
					MaxShakeOffset.X = __NFUN_169__(MaxShakeOffset.X);					
				}
				else
				{
					m_rTotalShake.Pitch = int(__NFUN_174__(__NFUN_169__(MaxShakeRoll), float(1)));
				}				
			}
			else
			{
				// End:0x20C
				if(__NFUN_176__(__NFUN_195__(), 0.5000000))
				{
					MaxShakeOffset.X = __NFUN_169__(MaxShakeOffset.X);
				}
			}
			// End:0x281
			if(__NFUN_179__(__NFUN_186__(float(m_rTotalShake.Yaw)), MaxShakeRoll))
			{
				// End:0x265
				if(__NFUN_151__(m_rTotalShake.Yaw, 0))
				{
					m_rTotalShake.Yaw = int(__NFUN_175__(MaxShakeRoll, float(1)));
					MaxShakeOffset.Y = __NFUN_169__(MaxShakeOffset.Y);					
				}
				else
				{
					m_rTotalShake.Yaw = int(__NFUN_174__(__NFUN_169__(MaxShakeRoll), float(1)));
				}				
			}
			else
			{
				// End:0x2A4
				if(__NFUN_176__(__NFUN_195__(), 0.5000000))
				{
					MaxShakeOffset.Y = __NFUN_169__(MaxShakeOffset.Y);
				}
			}
			// End:0x319
			if(__NFUN_179__(__NFUN_186__(float(m_rTotalShake.Roll)), MaxShakeRoll))
			{
				// End:0x2FD
				if(__NFUN_151__(m_rTotalShake.Roll, 0))
				{
					m_rTotalShake.Roll = int(__NFUN_175__(MaxShakeRoll, float(1)));
					MaxShakeOffset.Z = __NFUN_169__(MaxShakeOffset.Z);					
				}
				else
				{
					m_rTotalShake.Roll = int(__NFUN_174__(__NFUN_169__(MaxShakeRoll), float(1)));
				}				
			}
			else
			{
				// End:0x33C
				if(__NFUN_176__(__NFUN_195__(), 0.5000000))
				{
					MaxShakeOffset.Z = __NFUN_169__(MaxShakeOffset.Z);
				}
			}
			m_rCurrentShakeRotation.Pitch = int(__NFUN_171__(__NFUN_171__(ShakeRollRate, fDeltaTime), MaxShakeOffset.X));
			__NFUN_161__(m_rTotalShake.Pitch, m_rCurrentShakeRotation.Pitch);
			m_rCurrentShakeRotation.Yaw = int(__NFUN_171__(__NFUN_171__(ShakeRollRate, fDeltaTime), MaxShakeOffset.Y));
			__NFUN_161__(m_rTotalShake.Yaw, m_rCurrentShakeRotation.Yaw);
			m_rCurrentShakeRotation.Roll = int(__NFUN_171__(__NFUN_171__(ShakeRollRate, fDeltaTime), MaxShakeOffset.Z));
			__NFUN_161__(m_rTotalShake.Roll, m_rCurrentShakeRotation.Roll);			
		}
		else
		{
			// End:0x468
			if(__NFUN_181__(MaxShakeRoll, float(0)))
			{
				MaxShakeRoll = 0.0000000;
				MaxShakeOffset.X = __NFUN_172__(float(__NFUN_143__(m_rTotalShake.Pitch)), m_fShakeReturnTime);
				MaxShakeOffset.Y = __NFUN_172__(float(__NFUN_143__(m_rTotalShake.Yaw)), m_fShakeReturnTime);
				MaxShakeOffset.Z = __NFUN_172__(float(__NFUN_143__(m_rTotalShake.Roll)), m_fShakeReturnTime);
			}
			// End:0x4C0
			if(__NFUN_178__(m_fShakeReturnTime, float(0)))
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
				__NFUN_185__(m_fShakeReturnTime, fDeltaTime);
				m_rCurrentShakeRotation.Pitch = int(__NFUN_171__(fDeltaTime, MaxShakeOffset.X));
				m_rCurrentShakeRotation.Yaw = int(__NFUN_171__(fDeltaTime, MaxShakeOffset.Y));
				m_rCurrentShakeRotation.Roll = int(__NFUN_171__(fDeltaTime, MaxShakeOffset.Z));
			}
		}
	}
	// End:0x816
	if(__NFUN_218__(m_vNewReturnValue, vect(0.0000000, 0.0000000, 0.0000000)))
	{
		// End:0x731
		if(__NFUN_203__(m_rLastBulletDirection, rot(0, 0, 0)))
		{
			fJumpByStance = __NFUN_171__(__NFUN_171__(-1.0000000, m_pawn.m_fWeaponJump), m_pawn.GetStanceJumpModifier());
			__NFUN_182__(fJumpByStance, m_fDesignerJumpFactor);
			m_rCurrentShakeRotation.Pitch = int(__NFUN_171__(fJumpByStance, 50.0000000));
			// End:0x5C9
			if(__NFUN_151__(m_rCurrentShakeRotation.Pitch, -250))
			{
				m_rCurrentShakeRotation.Pitch = -250;
			}
			// End:0x5FD
			if(__NFUN_150__(m_rLastBulletDirection.Yaw, 0))
			{
				m_rCurrentShakeRotation.Yaw = __NFUN_251__(m_rLastBulletDirection.Yaw, -1570, -140);				
			}
			else
			{
				m_rCurrentShakeRotation.Yaw = __NFUN_251__(m_rLastBulletDirection.Yaw, 140, 1570);
			}
			m_vNewReturnValue.X = float(m_rCurrentShakeRotation.Pitch);
			m_vNewReturnValue.Y = float(m_rCurrentShakeRotation.Yaw);
			// End:0x69F
			if(__NFUN_177__(__NFUN_186__(m_vNewReturnValue.X), __NFUN_186__(m_vNewReturnValue.Y)))
			{
				m_iPitchReturn = m_iReturnSpeed;
				m_iYawReturn = int(__NFUN_172__(__NFUN_171__(__NFUN_186__(m_vNewReturnValue.Y), float(m_iReturnSpeed)), __NFUN_186__(m_vNewReturnValue.X)));				
			}
			else
			{
				m_iPitchReturn = int(__NFUN_186__(__NFUN_172__(__NFUN_171__(m_vNewReturnValue.X, float(m_iReturnSpeed)), m_vNewReturnValue.Y)));
				m_iYawReturn = m_iReturnSpeed;
			}
			__NFUN_159__(m_iPitchReturn, m_fDesignerSpeedFactor);
			__NFUN_159__(m_iYawReturn, m_fDesignerSpeedFactor);
			// End:0x70B
			if(__NFUN_177__(m_vNewReturnValue.Y, float(0)))
			{
				__NFUN_159__(m_iYawReturn, float(-1));
			}
			m_rLastBulletDirection = rot(0, 0, 0);
			m_vNewReturnValue.Z = 0.0000000;			
		}
		else
		{
			fStanceDeltaTime = __NFUN_171__(__NFUN_171__(m_pawn.GetStanceReticuleModifier(), m_pawn.m_fZoomJumpReturn), fDeltaTime);
			// End:0x7EB
			if(__NFUN_177__(__NFUN_186__(m_vNewReturnValue.X), __NFUN_171__(float(m_iPitchReturn), fStanceDeltaTime)))
			{
				__NFUN_184__(m_vNewReturnValue.X, __NFUN_171__(float(m_iPitchReturn), fStanceDeltaTime));
				__NFUN_161__(m_rCurrentShakeRotation.Pitch, int(__NFUN_171__(float(m_iPitchReturn), fStanceDeltaTime)));
				__NFUN_184__(m_vNewReturnValue.Y, __NFUN_171__(float(m_iYawReturn), fStanceDeltaTime));
				__NFUN_161__(m_rCurrentShakeRotation.Yaw, int(__NFUN_171__(float(m_iYawReturn), fStanceDeltaTime)));				
			}
			else
			{
				__NFUN_162__(m_rCurrentShakeRotation.Pitch, int(m_vNewReturnValue.X));
				m_vNewReturnValue = vect(0.0000000, 0.0000000, 0.0000000);
			}
		}
	}
	__NFUN_319__(rRotationOffset, m_rCurrentShakeRotation);
	// End:0x85D
	if(__NFUN_130__(__NFUN_151__(rRotationOffset.Pitch, 16384), __NFUN_150__(rRotationOffset.Pitch, 32000)))
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
	if(__NFUN_130__(__NFUN_155__(int(eKillResultFromTable), int(3)), __NFUN_155__(int(eKillResultFromTable), int(2))))
	{
		// End:0x65
		if(__NFUN_154__(int(eStunFromTable), int(0)))
		{
			// End:0x42
			if(bShowLog)
			{
				__NFUN_231__("Hit");
			}
			m_iShakeBlurIntensity = m_stImpactHit.iBlurIntensity;
			m_fBlurReturnTime = m_stImpactHit.fReturnTime;			
		}
		else
		{
			// End:0xAC
			if(__NFUN_154__(int(eStunFromTable), int(1)))
			{
				// End:0x89
				if(bShowLog)
				{
					__NFUN_231__("Stunned");
				}
				m_iShakeBlurIntensity = m_stImpactStun.iBlurIntensity;
				m_fBlurReturnTime = m_stImpactStun.fReturnTime;				
			}
			else
			{
				// End:0xF1
				if(__NFUN_154__(int(eStunFromTable), int(2)))
				{
					// End:0xCE
					if(bShowLog)
					{
						__NFUN_231__("Dazed");
					}
					m_iShakeBlurIntensity = m_stImpactDazed.iBlurIntensity;
					m_fBlurReturnTime = m_stImpactDazed.fReturnTime;					
				}
				else
				{
					// End:0x130
					if(__NFUN_154__(int(eStunFromTable), int(3)))
					{
						// End:0x110
						if(bShowLog)
						{
							__NFUN_231__("KO");
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
	if(__NFUN_119__(Pawn, none))
	{
		// End:0x45
		if(Level.Game.m_bGameStarted)
		{
			Pawn.EngineWeapon.StopFire(true);
		}
		Pawn.RemoteRole = ROLE_SimulatedProxy;
		m_iTeamId = Pawn.m_iTeam;
		m_bPlayDeathMusic = __NFUN_129__(m_bPlayDeathMusic);
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
	if(__NFUN_129__(PlayerCanSwitchToAIBackup()))
	{
		// End:0xE9
		if(__NFUN_119__(Pawn, none))
		{
			__NFUN_267__(Pawn.Location);
			Pawn.UnPossessed();
		}
	}
	__NFUN_113__('Dead');
	return;
}

function bool PlayerCanSwitchToAIBackup()
{
	// End:0x40
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
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
	if(__NFUN_129__(R6GameReplicationInfo(GameReplicationInfo).m_bAIBkp))
	{
		return false;
	}
	// End:0x68
	if(__NFUN_114__(m_TeamManager, none))
	{
		return false;
	}
	// End:0x7E
	if(__NFUN_154__(m_TeamManager.m_iMemberCount, 0))
	{
		return false;
	}
	return true;
	return;
}

simulated function ClientFadeSound(float fTime, int iVolume, Actor.ESoundSlot eSlot)
{
	// End:0x22
	if(__NFUN_119__(Viewport(Player), none))
	{
		__NFUN_2721__(fTime, iVolume, eSlot);
	}
	return;
}

simulated function ClientFadeCommonSound(float fTime, int iVolume)
{
	// End:0x88
	if(__NFUN_119__(Viewport(Player), none))
	{
		__NFUN_2721__(fTime, iVolume, 1);
		__NFUN_2721__(fTime, iVolume, 2);
		__NFUN_2721__(fTime, iVolume, 3);
		__NFUN_2721__(fTime, iVolume, 4);
		__NFUN_2721__(fTime, iVolume, 6);
		__NFUN_2721__(fTime, iVolume, 8);
		__NFUN_2721__(fTime, iVolume, 10);
		__NFUN_2721__(fTime, iVolume, 11);
	}
	return;
}

function SwitchWeapon(byte f)
{
	local R6EngineWeapon NewWeapon;

	// End:0x49
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_112__("IN: SwitchWeapon() to ", string(f)), string(m_bLockWeaponActions)), string(m_pawn.m_bWeaponTransition)));
	}
	// End:0x56
	if(__NFUN_114__(m_pawn, none))
	{
		return;
	}
	// End:0x1B8
	if(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_bLockWeaponActions), __NFUN_129__(m_pawn.m_bPostureTransition)), __NFUN_129__(R6GameReplicationInfo(GameReplicationInfo).m_bGameOverRep)))
	{
		NewWeapon = m_pawn.GetWeaponInGroup(int(f));
		// End:0x1B8
		if(__NFUN_130__(__NFUN_119__(NewWeapon, none), __NFUN_119__(NewWeapon, Pawn.EngineWeapon)))
		{
			// End:0xE9
			if(__NFUN_129__(NewWeapon.CanSwitchToWeapon()))
			{
				return;
			}
			m_pawn.m_bChangingWeapon = true;
			m_pawn.m_iCurrentWeapon = int(f);
			ToggleHelmetCameraZoom(true);
			// End:0x168
			if(__NFUN_130__(__NFUN_129__(__NFUN_154__(int(Level.NetMode), int(NM_Standalone))), __NFUN_129__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)))))
			{
				m_pawn.GetWeapon(R6AbstractWeapon(NewWeapon));
			}
			ServerSwitchWeapon(NewWeapon, f);
			// End:0x1B8
			if(__NFUN_132__(__NFUN_242__(bBehindView, false), __NFUN_155__(int(Level.NetMode), int(NM_Standalone))))
			{
				Pawn.EngineWeapon.__NFUN_113__('DiscardWeapon');
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
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("IN: ServerSwitchWeapon() - CurrentWeapon: ", string(Pawn.EngineWeapon)), " - NewWeapon: "), string(NewWeapon)));
	}
	m_pawn.m_bChangingWeapon = true;
	m_pawn.GetWeapon(R6AbstractWeapon(NewWeapon));
	m_pawn.m_ePlayerIsUsingHands = 0;
	m_pawn.PlayWeaponAnimation();
	m_pawn.m_iCurrentWeapon = int(u8CurrentWeapon);
	// End:0x10D
	if(__NFUN_119__(m_pawn.m_SoundRepInfo, none))
	{
		m_pawn.m_SoundRepInfo.m_CurrentWeapon = byte(__NFUN_147__(int(u8CurrentWeapon), 1));
	}
	return;
}

function WeaponUpState()
{
	// End:0x4E
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("IN: WeaponUpState() : ", string(Pawn.EngineWeapon)), " : "), string(Pawn.PendingWeapon)));
	}
	// End:0x64
	if(__NFUN_114__(Pawn.PendingWeapon, none))
	{
		return;
	}
	Pawn.PendingWeapon.m_bPawnIsWalking = Pawn.EngineWeapon.m_bPawnIsWalking;
	Pawn.EngineWeapon = Pawn.PendingWeapon;
	// End:0xEA
	if(Pawn.EngineWeapon.__NFUN_281__('RaiseWeapon'))
	{
		Pawn.EngineWeapon.BeginState();		
	}
	else
	{
		Pawn.EngineWeapon.__NFUN_113__('RaiseWeapon');
	}
	// End:0x12A
	if(bShowLog)
	{
		__NFUN_231__("OUT: ClientWeaponUpState()");
	}
	return;
}

function ServerWeaponUpAnimDone()
{
	// End:0x0D
	if(__NFUN_114__(m_pawn, none))
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
	return __NFUN_119__(m_TeamManager.FindRainbowWithGrenadeType(grenadeType, true), none);
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
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_114__(m_TeamManager, none), __NFUN_152__(m_TeamManager.m_iMemberCount, 1)), m_TeamManager.m_bTeamIsClimbingLadder), Level.m_bInGamePlanningActive))
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
	if(__NFUN_132__(__NFUN_132__(__NFUN_114__(m_TeamManager, none), __NFUN_152__(m_TeamManager.m_iMemberCount, 1)), m_bPreventTeamMemberUse))
	{
		Query.iHasAction = 0;
		return;
	}
	// End:0x127
	if(__NFUN_176__(fDistance, m_fCircumstantialActionRange))
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
		Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), i)] = 4;
		__NFUN_165__(i);
	}
	// End:0x6E
	if(R6ActionCanBeExecuted(int(5), self))
	{
		Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), i)] = 5;
		__NFUN_165__(i);
	}
	// End:0xA5
	if(R6ActionCanBeExecuted(int(6), self))
	{
		Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), i)] = 6;
		__NFUN_165__(i);
	}
	// End:0xDC
	if(R6ActionCanBeExecuted(int(7), self))
	{
		Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), i)] = 7;
		__NFUN_165__(i);
	}
	j = i;
	J0xE7:

	// End:0x11F [Loop If]
	if(__NFUN_150__(j, 4))
	{
		Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), j)] = 0;
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0xE7;
	}
	return;
}

simulated function bool R6ActionCanBeExecuted(int iAction, PlayerController PlayerController)
{
	// End:0x10
	if(__NFUN_154__(iAction, int(0)))
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
	if(__NFUN_119__(R6Pawn(anActor), none))
	{
		// End:0x39
		if(__NFUN_119__(CheatManager, none))
		{
			R6CheatManager(CheatManager).LogR6Pawn(R6Pawn(anActor));
		}		
	}
	else
	{
		anActor.dbgLogActor(false);
	}
	// End:0x70
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
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
	if(__NFUN_119__(P, none))
	{
		// End:0x79
		if(__NFUN_119__(CheatManager, none))
		{
			// End:0x60
			if(__NFUN_154__(int(P.m_ePawnType), int(2)))
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
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		ServerLogPawn();
	}
	return;
}

function DoLogPawn()
{
	// End:0x24
	if(__NFUN_119__(CheatManager, none))
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

	__NFUN_231__("--- Actor List Begin ---");
	// End:0x41
	foreach __NFUN_304__(Class'Engine.Actor', ActorIterator)
	{
		__NFUN_231__(__NFUN_168__(" Actor:", string(ActorIterator)));		
	}	
	__NFUN_231__("--- Actor List End ---");
	return;
}

function ServerLogActors()
{
	DoLogActors();
	return;
}

function PossessInit(Pawn aPawn)
{
	__NFUN_299__(aPawn.Rotation);
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	m_pawn = R6Rainbow(Pawn);
	m_pawn.SetFriendlyFire();
	// End:0x93
	if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_155__(int(Level.NetMode), int(NM_ListenServer))))
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
	if(__NFUN_130__(__NFUN_130__(__NFUN_114__(aAudioRepInfo, none), __NFUN_155__(int(eSlotUse), int(8))), __NFUN_155__(int(eSlotUse), int(7))))
	{
		return;
	}
	// End:0x84
	if(__NFUN_130__(__NFUN_119__(aAudioRepInfo, none), __NFUN_119__(aAudioRepInfo.m_pawnOwner, none)))
	{
		aAudioRepInfo.m_pawnOwner.__NFUN_2731__();
		aAudioRepInfo.m_pawnOwner.m_fLastCommunicationTime = 5.0000000;
	}
	__NFUN_2726__(aAudioRepInfo, sndPlayVoice, eSlotUse, iPriority, bWaitToFinishSound, fTime);
	return;
}

function PlaySoundActionCompleted(R6Pawn.eDeviceAnimToPlay eAnimToPlay)
{
	// End:0xE6
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
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
			if(__NFUN_151__(m_TeamManager.m_iMemberCount, 1))
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
	if(__NFUN_154__(int(Role), int(ROLE_Authority)))
	{
		// End:0x5E
		if(Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
		{
			m_TeamManager.m_MultiCoopPlayerVoicesMgr.PlayRainbowTeamVoices(m_pawn, eVoices);			
		}
		else
		{
			// End:0x8D
			if(__NFUN_154__(int(eVoices), int(5)))
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
			if(__NFUN_130__(__NFUN_151__(m_TeamManager.m_iMemberCount, 0), __NFUN_119__(m_TeamManager.m_MemberVoicesMgr, none)))
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
	if(__NFUN_130__(__NFUN_150__(iIterator, _GRI.32), __NFUN_123__(_GRI.m_mapArray[iIterator], "")))
	{
		szGameType = _GRI.Level.GetGameTypeFromClassName(_GRI.m_gameModeArray[iIterator]);
		szMapLoc = _GRI.Level.__NFUN_1518__(_GRI.m_mapArray[iIterator]);
		Class'Engine.Actor'.static.__NFUN_2620__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(szMapId, ": "), string(__NFUN_146__(iIterator, 1))), " "), szMapName), ": "), szMapLoc), " "), szLocGameType), ": "), _GRI.Level.GetGameNameLocalization(szGameType)), myHUD.m_ServerMessagesColor);
		__NFUN_165__(iIterator);
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

	__NFUN_166__(iGotoMapId);
	_GRI = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x94
	if(__NFUN_132__(__NFUN_132__(__NFUN_153__(iGotoMapId, _GRI.32), __NFUN_150__(iGotoMapId, 0)), __NFUN_122__(_GRI.m_mapArray[iGotoMapId], "")))
	{
		Class'Engine.Actor'.static.__NFUN_2620__(Localize("Game", "BadMapId", "R6GameInfo"), myHUD.m_ServerMessagesColor);
		return;
	}
	szMapLoc = _GRI.Level.__NFUN_1518__(_GRI.m_mapArray[iGotoMapId]);
	Class'Engine.Actor'.static.__NFUN_2620__(__NFUN_112__(__NFUN_112__(Localize("Game", "RequestingMap", "R6GameInfo"), ": "), szMapLoc), myHUD.m_ServerMessagesColor);
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
	if(__NFUN_132__(__NFUN_242__(CheckAuthority(1), false), __NFUN_153__(iGotoMapId, _GRI.32)))
	{
		ClientNoAuthority();
		return;
	}
	_mapName = _GRI.Level.__NFUN_1518__(_GRI.m_mapArray[iGotoMapId]);
	_PlayerName = PlayerReplicationInfo.PlayerName;
	// End:0xAE
	foreach __NFUN_304__(Class'R6Engine.R6PlayerController', _playerController)
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
	if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Client)), __NFUN_154__(int(Level.NetMode), int(NM_Standalone))))
	{
		ClientNoAuthority();
		return;
	}
	// End:0xE0
	if(__NFUN_130__(__NFUN_177__(m_fLastVoteTime, float(0)), __NFUN_176__(Level.TimeSeconds, __NFUN_174__(m_fLastVoteTime, float(300)))))
	{
		// End:0xD8
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Next possible NextMap request time is ", string(__NFUN_174__(m_fLastVoteTime, float(300)))), " current time is "), string(Level.TimeSeconds)));
		}
		ClientCantRequestChangeMapYet();
		return;
	}
	// End:0x11A
	if(__NFUN_242__(R6AbstractGameInfo(Level.Game).ProcessChangeMapVote(PlayerReplicationInfo.PlayerName), false))
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
	foreach __NFUN_304__(Class'Engine.PlayerReplicationInfo', _PRI)
	{
		Class'Engine.Actor'.static.__NFUN_2620__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(szID, ": "), string(_PRI.PlayerID)), " "), szName), ": "), _PRI.PlayerName), myHUD.m_ServerMessagesColor);		
	}	
	return;
}

// this function is sent and executed directly to the server.
// Basic Command
exec function VoteKick(string szKickName)
{
	ProcessVoteKickRequest(R6PlayerController(__NFUN_1224__(szKickName, false)));
	return;
}

exec function VoteKickID(string szKickName)
{
	ProcessVoteKickRequest(R6PlayerController(__NFUN_1224__(szKickName, true)));
	return;
}

simulated function ProcessVoteKickRequest(R6PlayerController _playerController)
{
	// End:0x3C
	if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Client)), __NFUN_154__(int(Level.NetMode), int(NM_Standalone))))
	{
		ClientNoAuthority();
		return;
	}
	// End:0xE1
	if(__NFUN_130__(__NFUN_177__(m_fLastVoteTime, float(0)), __NFUN_176__(Level.TimeSeconds, __NFUN_174__(m_fLastVoteTime, float(300)))))
	{
		// End:0xD9
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Next possible votekick request time is ", string(__NFUN_174__(m_fLastVoteTime, float(300)))), " current time is "), string(Level.TimeSeconds)));
		}
		ClientCantRequestKickYet();
		return;
	}
	// End:0x134
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("<<KICK>> ", string(self)), ": calling StartVoteKick on "), _playerController.PlayerReplicationInfo.PlayerName));
	}
	// End:0x1D4
	if(__NFUN_119__(_playerController, none))
	{
		// End:0x160
		if(__NFUN_119__(Viewport(_playerController.Player), none))
		{
			ClientNoAuthority();
			return;
		}
		// End:0x17E
		if(__NFUN_242__(_playerController.CheckAuthority(1), true))
		{
			ClientNoKickAdmin();
			return;
		}
		// End:0x1BD
		if(__NFUN_242__(R6AbstractGameInfo(Level.Game).ProcessKickVote(_playerController, PlayerReplicationInfo.PlayerName), false))
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
	if(__NFUN_180__(R6AbstractGameInfo(Level.Game).m_fEndVoteTime, float(0)))
	{
		return;
	}
	// End:0x41
	if(__NFUN_132__(__NFUN_152__(_bVoteResult, 0), __NFUN_153__(_bVoteResult, 3)))
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
				if(__NFUN_114__(R6AbstractGameInfo(Level.Game).m_PlayerKick, none))
				{
					__NFUN_231__(__NFUN_112__(string(self), " set vote yes to change Map "));					
				}
				else
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__(string(self), " set vote yes to kick "), R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName));
				}
				// End:0x27F
				break;
			// End:0x190
			case 2:
				// End:0x13F
				if(__NFUN_114__(R6AbstractGameInfo(Level.Game).m_PlayerKick, none))
				{
					__NFUN_231__(__NFUN_112__(string(self), " set vote no to change Map "));					
				}
				else
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__(string(self), " set vote no to kick "), R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName));
				}
				// End:0x27F
				break;
			// End:0xFFFF
			default:
				// End:0x205
				if(__NFUN_114__(R6AbstractGameInfo(Level.Game).m_PlayerKick, none))
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(string(self), " how did we get here? Set invalid  vote "), string(_bVoteResult)), " to change Map "));					
				}
				else
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(string(self), " how did we get here? Set invalid  vote "), string(_bVoteResult)), " to kick "), R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName));
				}
				// End:0x27F
				break;
				break;
		}
	}
	m_iVoteResult = _bVoteResult;
	pServerInfo = Class'Engine.Actor'.static.__NFUN_1273__();
	_PlayerNameOne = PlayerReplicationInfo.PlayerName;
	_PlayerNameTwo = R6AbstractGameInfo(Level.Game).m_PlayerKick.PlayerReplicationInfo.PlayerName;
	_VoteSpamCheckOk = __NFUN_178__(__NFUN_174__(m_fLastVoteEmoteTimeStamp, pServerInfo.VoteBroadcastMaxFrequency), Level.TimeSeconds);
	_itController = Level.ControllerList;
	J0x324:

	// End:0x3BF [Loop If]
	if(__NFUN_119__(_itController, none))
	{
		_playerController = R6PlayerController(_itController);
		// End:0x3A8
		if(__NFUN_119__(_playerController, none))
		{
			__NFUN_165__(_iTotalPlayers);
			switch(_playerController.m_iVoteResult)
			{
				// End:0x36F
				case 1:
					__NFUN_165__(_iForKickVotes);
					// End:0x381
					break;
				// End:0x37E
				case 2:
					__NFUN_165__(_iAgainstKickVotes);
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
	if(__NFUN_132__(__NFUN_179__(float(_iAgainstKickVotes), __NFUN_172__(float(_iTotalPlayers), float(2))), __NFUN_177__(float(_iForKickVotes), __NFUN_172__(float(_iTotalPlayers), float(2)))))
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
	if(__NFUN_132__(__NFUN_119__(Viewport(Player), none), __NFUN_130__(Level.m_ServerSettings.UseAdminPassword, __NFUN_122__(_Password, Level.m_ServerSettings.AdminPassword))))
	{
		m_iAdmin = 1;
	}
	return;
}

exec function AdminLogin(string _Password)
{
	m_szLastAdminPassword = _Password;
	__NFUN_536__();
	ServerAdminLogin(_Password);
	return;
}

function ServerAdminLogin(string _Password)
{
	// End:0x9C
	if(__NFUN_132__(__NFUN_119__(Viewport(Player), none), __NFUN_130__(Level.m_ServerSettings.UseAdminPassword, __NFUN_122__(_Password, Level.m_ServerSettings.AdminPassword))))
	{
		m_iAdmin = 1;
		ClientAdminLogin(true);
		// End:0x99
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(PlayerReplicationInfo.PlayerName, " logged in as an Administrator"));
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
	if(__NFUN_242__(_loginRes, true))
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
	if(__NFUN_242__(Console(Player.Console).m_bStartedByGSClient, true))
	{
		Player.Console.Message(Localize("Errors", "DisabledCommand", "R6Engine"), 6.0000000);
		return;
	}
	// End:0x80
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		return;
	}
	// End:0x96
	if(__NFUN_151__(__NFUN_125__(_NewPassword), 16))
	{
		ClientPasswordTooLong();
		return;
	}
	// End:0xE1
	if(__NFUN_242__(_bFlagSetting, true))
	{
		// End:0xB9
		if(__NFUN_122__(_NewPassword, ""))
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
			__NFUN_2620__(Localize("Game", "GamePasswordMissing", "R6GameInfo"), myHUD.m_ServerMessagesColor);
			// End:0xD8
			break;
		// End:0x8F
		case 2:
			__NFUN_2620__(Localize("Game", "GamePasswordSet", "R6GameInfo"), myHUD.m_ServerMessagesColor);
			// End:0xD8
			break;
		// End:0xD5
		case 3:
			__NFUN_2620__(Localize("Game", "GamePasswordCleared", "R6GameInfo"), myHUD.m_ServerMessagesColor);
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
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		return;
	}
	// End:0x2B
	if(__NFUN_151__(__NFUN_125__(_NewPassword), 16))
	{
		ClientPasswordTooLong();
		return;
	}
	Level.m_ServerSettings.AdminPassword = _NewPassword;
	Level.m_ServerSettings.__NFUN_536__();
	_PlayerName = PlayerReplicationInfo.PlayerName;
	// End:0xA1
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(_PlayerName, " changed password to "), _NewPassword));
	}
	// End:0xC6
	foreach __NFUN_304__(Class'R6Engine.R6PlayerController', _playerController)
	{
		_playerController.ClientNewPassword(_PlayerName);		
	}	
	return;
}

function bool CheckAuthority(int _LevelNeeded)
{
	// End:0x1B
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		return false;
	}
	return __NFUN_132__(__NFUN_153__(m_iAdmin, _LevelNeeded), __NFUN_130__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)), __NFUN_119__(Viewport(Player), none)));
	return;
}

// this is executed on the server
// Admin Command
exec function Kick(string szKickName)
{
	ProcessKickRequest(R6PlayerController(__NFUN_1224__(szKickName, false)));
	return;
}

exec function KickId(string szKickName)
{
	ProcessKickRequest(R6PlayerController(__NFUN_1224__(szKickName, true)));
	return;
}

exec function Ban(string szKickName)
{
	local R6PlayerController PC;

	PC = R6PlayerController(__NFUN_1224__(szKickName, false));
	ProcessKickRequest(PC, true);
	return;
}

exec function BanId(string szKickName)
{
	local R6PlayerController PC;

	PC = R6PlayerController(__NFUN_1224__(szKickName, true));
	ProcessKickRequest(PC, true);
	return;
}

function ClientNoBanMatches()
{
	local int iPos;

	__NFUN_2620__(Localize("Game", "NoBanMatchFound", "R6GameInfo"), myHUD.m_ServerMessagesColor);
	iPos = 0;
	J0x41:

	// End:0x6A [Loop If]
	if(__NFUN_150__(iPos, 10))
	{
		m_BanPage.szBanID[iPos] = "";
		__NFUN_165__(iPos);
		// [Loop Continue]
		goto J0x41;
	}
	m_iBanPage = 0;
	m_szBanSearch = "";
	return;
}

function ClientPlayerUnbanned()
{
	__NFUN_2620__(Localize("Game", "PlayerUnBanned", "R6GameInfo"), myHUD.m_ServerMessagesColor);
	return;
}

//#ifdef R6PUNKBUSTER
function ClientPBVersionMismatch()
{
	__NFUN_2620__(Localize("Game", "PBVersionMismatch", "R6GameInfo"), myHUD.m_ServerMessagesColor);
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
	if(__NFUN_150__(iPos, 10))
	{
		// End:0x43
		if(__NFUN_122__(m_BanPage.szBanID[iPos], ""))
		{
			// [Explicit Break]
			goto J0x7D;
		}
		__NFUN_2620__(__NFUN_112__(__NFUN_112__(string(iPos), "> "), m_BanPage.szBanID[iPos]), myHUD.m_ServerMessagesColor);
		__NFUN_165__(iPos);
		// [Loop Continue]
		goto J0x1D;
	}
	J0x7D:

	__NFUN_165__(m_iBanPage);
	return;
}

exec function UnBanPos(int iPosition)
{
	local int iPos;

	// End:0x15
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		return;
	}
	// End:0x66
	if(__NFUN_122__(m_BanPage.szBanID[iPosition], ""))
	{
		__NFUN_2620__(Localize("Game", "NoBannedInPos", "R6GameInfo"), myHUD.m_ServerMessagesColor);
		return;
	}
	UnBan(m_BanPage.szBanID[iPosition]);
	iPos = 0;
	J0x83:

	// End:0xAC [Loop If]
	if(__NFUN_150__(iPos, 10))
	{
		m_BanPage.szBanID[iPos] = "";
		__NFUN_165__(iPos);
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
	if(__NFUN_242__(CheckAuthority(1), false))
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
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		return;
	}
	// End:0x5A
	if(__NFUN_154__(m_iBanPage, 0))
	{
		__NFUN_2620__(Localize("Game", "BanListFirst", "R6GameInfo"), myHUD.m_ServerMessagesColor);		
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
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		return;
	}
	i = -1;
	J0x20:

	// End:0xBA [Loop If]
	if(__NFUN_151__(_iPageNumber, 0))
	{
		iMatchesFound = 0;
		J0x32:

		__NFUN_165__(i);
		i = Level.Game.AccessControl.NextMatchingID(szPrefixBanID, i);
		// End:0x7C
		if(__NFUN_153__(i, 0))
		{
			__NFUN_165__(iMatchesFound);
		}
		// End:0x32
		if(!(__NFUN_132__(__NFUN_154__(iMatchesFound, 10), __NFUN_154__(i, -1))))
			goto J0x32;
		// End:0xB0
		if(__NFUN_154__(i, -1))
		{
			ClientNoBanMatches();
			return;
		}
		__NFUN_166__(_iPageNumber);
		// [Loop Continue]
		goto J0x20;
	}
	iMatchesFound = 0;
	J0xC1:

	__NFUN_165__(i);
	i = Level.Game.AccessControl.NextMatchingID(szPrefixBanID, i);
	// End:0x13D
	if(__NFUN_153__(i, 0))
	{
		banPage.szBanID[__NFUN_165__(iMatchesFound)] = Level.Game.AccessControl.Banned[i];
	}
	// End:0xC1
	if(!(__NFUN_132__(__NFUN_154__(iMatchesFound, 10), __NFUN_154__(i, -1))))
		goto J0xC1;
	// End:0x178
	if(__NFUN_151__(iMatchesFound, 0))
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
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		return;
	}
	_iMatchesFound = Level.Game.AccessControl.RemoveBan(szPrefixBanID);
	// End:0x55
	if(__NFUN_154__(_iMatchesFound, 0))
	{
		ClientNoBanMatches();		
	}
	else
	{
		// End:0x69
		if(__NFUN_154__(_iMatchesFound, 1))
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
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Admin command <<", CommandLine), ">> issued by:"), GetPlayerNetworkAddress()), " ignored"));
		return;
	}
	Result = ConsoleCommand(CommandLine);
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Admin command <<", CommandLine), ">> issued by:"), GetPlayerNetworkAddress()), " accepted"));
	// End:0xE8
	if(__NFUN_123__(Result, ""))
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__("Admin command returned <<", Result), ">>"));
		ClientMessage(Result);
	}
	return;
}

simulated function ProcessKickRequest(R6PlayerController _playerController, optional bool bBan)
{
	local R6PlayerController _pcIterator;
	local string _AdminName, _KickeeName;

	// End:0x15
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		return;
	}
	// End:0x28
	if(__NFUN_114__(_playerController, none))
	{
		ClientKickBadId();
		return;
	}
	// End:0x61
	if(__NFUN_132__(__NFUN_119__(Viewport(_playerController.Player), none), __NFUN_242__(_playerController.CheckAuthority(1), true)))
	{
		ClientNoKickAdmin();
		return;
	}
	// End:0xBF
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("<AdminKick> ", PlayerReplicationInfo.PlayerName), " kicked "), _playerController.PlayerReplicationInfo.PlayerName), " from server"));
	}
	_AdminName = PlayerReplicationInfo.PlayerName;
	_KickeeName = _playerController.PlayerReplicationInfo.PlayerName;
	// End:0x13F
	foreach __NFUN_304__(Class'R6Engine.R6PlayerController', _pcIterator)
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
	_playerController.__NFUN_1282__();
	return;
}

// Admin Command
exec function LoadServer(string FileName)
{
	local R6PlayerController _playerController;

	// End:0x15
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		return;
	}
	ConsoleCommand(__NFUN_112__("INGAMELOADSERVER ", FileName));
	return;
}

//=================================================================================
// INTERACTION WITH MENU FOR SERVER SETTINGS
//=================================================================================
function ServerPausePreGameRoundTime()
{
	m_bInAnOptionsPage = CheckAuthority(1);
	// End:0x37
	if(__NFUN_242__(m_bInAnOptionsPage, true))
	{
		R6AbstractGameInfo(Level.Game).PauseCountDown();
	}
	return;
}

function ServerUnPausePreGameRoundTime()
{
	// End:0x31
	if(__NFUN_242__(m_bInAnOptionsPage, true))
	{
		m_bInAnOptionsPage = false;
		R6AbstractGameInfo(Level.Game).UnPauseCountDown();
	}
	return;
}

function ServerStartChangingInfo()
{
	// End:0x1C
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		ClientServerChangingInfo(false);
		return;
	}
	// End:0x6B
	if(__NFUN_130__(__NFUN_119__(R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo, self), __NFUN_119__(R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo, none)))
	{
		ClientServerChangingInfo(false);
		return;
	}
	R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo = self;
	// End:0xF4
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__("ServerStartChangingInfo: Setting m_pCurPlayerCtrlMdfSrvInfo = ", string(R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo)));
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
	if(__NFUN_119__(R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo, self))
	{
		return;
	}
	pServerInfo = Class'Engine.Actor'.static.__NFUN_1273__();
	// End:0x102
	if(_bChangeWasMade)
	{
		pServerInfo.__NFUN_536__(Class'Engine.Actor'.static.__NFUN_1524__().GetServerIni());
		pServerInfo.m_ServerMapList.__NFUN_536__(Class'Engine.Actor'.static.__NFUN_1524__().GetServerIni());
		// End:0xA9
		if(__NFUN_129__(_bRestrictionKitChange))
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
	if(__NFUN_119__(R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo, self))
	{
		return false;
	}
	pServerInfo = Class'Engine.Actor'.static.__NFUN_1273__();
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
	if(__NFUN_119__(R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo, self))
	{
		return;
	}
	pServerInfo = Class'Engine.Actor'.static.__NFUN_1273__();
	// End:0xAF
	if(__NFUN_155__(_iLastItem, 0))
	{
		iArrayCount = 32;
		i = _iLastItem;
		J0x54:

		// End:0xAD [Loop If]
		if(__NFUN_150__(i, iArrayCount))
		{
			pServerInfo.m_ServerMapList.GameType[i] = "";
			pServerInfo.m_ServerMapList.Maps[i] = "";
			__NFUN_165__(i);
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
	if(__NFUN_119__(R6AbstractGameInfo(Level.Game).m_pCurPlayerCtrlMdfSrvInfo, self))
	{
		return;
	}
	pServerInfo = Class'Engine.Actor'.static.__NFUN_1273__();
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
		if(__NFUN_150__(i, _pARestKit.Length))
		{
			// End:0x41
			if(__NFUN_114__(_pARestKit[i], _pANewClassValue))
			{
				_pARestKit.Remove(i, 1);
			}
			__NFUN_165__(i);
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
		if(__NFUN_150__(i, _szARestKit.Length))
		{
			// End:0x41
			if(__NFUN_122__(_szARestKit[i], _szNewValue))
			{
				_szARestKit.Remove(i, 1);
			}
			__NFUN_165__(i);
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
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		return;
	}
	_AdminName = PlayerReplicationInfo.PlayerName;
	DisableFirstPersonViewEffects();
	// End:0x68
	foreach __NFUN_304__(Class'R6Engine.R6PlayerController', _playerController)
	{
		_playerController.ClientDisableFirstPersonViewEffects();
		_playerController.ClientRestartMatchMsg(_AdminName, explanation);		
	}	
	Level.Game.__NFUN_1210__();
	Level.Game.RestartGame();
	return;
}

// Admin Command
exec function RestartRound(string explanation)
{
	local R6PlayerController _playerController;
	local string _AdminName;

	// End:0x15
	if(__NFUN_242__(CheckAuthority(1), false))
	{
		ClientNoAuthority();
		return;
	}
	_AdminName = PlayerReplicationInfo.PlayerName;
	DisableFirstPersonViewEffects();
	// End:0x68
	foreach __NFUN_304__(Class'R6Engine.R6PlayerController', _playerController)
	{
		_playerController.ClientDisableFirstPersonViewEffects();
		_playerController.ClientRestartRoundMsg(_AdminName, explanation);		
	}	
	Level.Game.__NFUN_1210__();
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
	HandleServerMsg(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(_szPlayerName, " "), Localize("Game", "AdminSwitchMap", "R6GameInfo")), " "), szNewMapname));
	// End:0x5D
	if(__NFUN_123__(explanation, ""))
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
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("ClientMextMapVoteMessage displaying: ", szRequestingPlayer), ": "), Localize("Game", "LetsChangeMap", "R6GameInfo")));
	}
	m_MenuCommunication.ActiveVoteMenu(true, "");
	HandleServerMsg(__NFUN_112__(__NFUN_112__(szRequestingPlayer, ": "), Localize("Game", "LetsChangeMap", "R6GameInfo")));
	return;
}

function ClientKickVoteMessage(PlayerReplicationInfo PRIKickPlayer, string szRequestingPlayer)
{
	// End:0x73
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__(__NFUN_112__(__NFUN_112__(__NFUN_112__("ClientKickVoteMessage displaying: ", szRequestingPlayer), ": "), Localize("Game", "LetsKickOut", "R6GameInfo")), PRIKickPlayer.PlayerName));
	}
	m_MenuCommunication.ActiveVoteMenu(true, PRIKickPlayer.PlayerName);
	HandleServerMsg(__NFUN_168__(__NFUN_112__(__NFUN_112__(szRequestingPlayer, ": "), Localize("Game", "LetsKickOut", "R6GameInfo")), PRIKickPlayer.PlayerName));
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
			if(__NFUN_123__(_playerTwo, ""))
			{
				szVoteMessage = __NFUN_168__(__NFUN_168__(_playerOne, Localize("Game", "YesVoteKick", "R6GameInfo")), _playerTwo);				
			}
			else
			{
				szVoteMessage = __NFUN_168__(_playerOne, Localize("Game", "YesVoteChangeMap", "R6GameInfo"));
			}
			// End:0x117
			break;
		// End:0x112
		case 2:
			// End:0xD9
			if(__NFUN_123__(_playerTwo, ""))
			{
				szVoteMessage = __NFUN_168__(__NFUN_168__(_playerOne, Localize("Game", "NoVoteKick", "R6GameInfo")), _playerTwo);				
			}
			else
			{
				szVoteMessage = __NFUN_168__(_playerOne, Localize("Game", "NoVoteChangeMap", "R6GameInfo"));
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
	if(__NFUN_123__(_PlayerName, ""))
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
		HandleServerMsg(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(_stringOne, " "), _PlayerName), " "), _stringTwo));		
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
	HandleServerMsg(__NFUN_168__(_PlayerName, Localize("Game", "LeftTheServerVoteAborted", "R6GameInfo")));
	m_MenuCommunication.ActiveVoteMenu(false);
	return;
}

function ClientNewPassword(string _AdminName)
{
	HandleServerMsg(__NFUN_112__(__NFUN_112__(_AdminName, ": "), Localize("Game", "AdminPasswordChange", "R6GameInfo")));
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
	HandleServerMsg(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(_KickedName, " "), Localize("Game", "AdminKickOff", "R6GameInfo")), " "), _AdminName));
	return;
}

function ClientAdminBanOff(string _AdminName, string _KickedName)
{
	HandleServerMsg(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(_KickedName, " "), Localize("Game", "AdminBanOff", "R6GameInfo")), " "), _AdminName));
	return;
}

// NEW IN 1.60
function ClientVoteChangeMap(string _AdminName)
{
	HandleServerMsg(__NFUN_112__(__NFUN_112__(_AdminName, " "), Localize("Game", "VoteChangeMap", "R6GameInfo")));
	return;
}

function ClientRestartRoundMsg(string _AdminName, string explanation)
{
	HandleServerMsg(__NFUN_112__(__NFUN_112__(_AdminName, " "), Localize("Game", "RestartsTheRound", "R6GameInfo")));
	// End:0x53
	if(__NFUN_123__(explanation, ""))
	{
		HandleServerMsg(explanation);
	}
	m_MenuCommunication.SetPlayerReadyStatus(false);
	return;
}

function ClientRestartMatchMsg(string _AdminName, string explanation)
{
	HandleServerMsg(__NFUN_112__(__NFUN_112__(_AdminName, " "), Localize("Game", "RestartsTheMatch", "R6GameInfo")));
	// End:0x53
	if(__NFUN_123__(explanation, ""))
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
	if(__NFUN_150__(i, myHUD.3))
	{
		myHUD.TextServerMessages[i] = "";
		myHUD.MessageServerLife[i] = 0.0000000;
		__NFUN_165__(i);
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
	if(__NFUN_154__(PlayerReplicationInfo.TeamID, int(3)))
	{
		szObjective = Level.GetRedShortDescription(szGameTypeFlag);
		// End:0x48
		if(__NFUN_123__(szObjective, ""))
		{
			HandleServerMsg(szObjective);
		}		
	}
	else
	{
		szObjective = Level.GetGreenShortDescription(szGameTypeFlag);
		// End:0x7C
		if(__NFUN_123__(szObjective, ""))
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
	if(__NFUN_122__(szLocFile, ""))
	{
		szLocFile = Level.m_szMissionObjLocalization;
	}
	SetGameMsg(szLocFile, szPreMsg, szMsgID, sndSound, iLifeTime);
	return;
}

function ClientGameMsg(string szLocFile, string szPreMsg, string szMsgID, optional Sound sndSound, optional int iLifeTime)
{
	// End:0x1E
	if(__NFUN_122__(szLocFile, ""))
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
	if(__NFUN_130__(__NFUN_123__(szPreMsg, ""), __NFUN_123__(szMsgID, "")))
	{
		HandleServerMsg(__NFUN_112__(__NFUN_112__(szPreMsg, " "), Localize("Game", szMsgID, szLocalization)), iLifeTime);		
	}
	else
	{
		// End:0x77
		if(__NFUN_130__(__NFUN_123__(szPreMsg, ""), __NFUN_122__(szMsgID, "")))
		{
			HandleServerMsg(szPreMsg, iLifeTime);			
		}
		else
		{
			// End:0xA7
			if(__NFUN_123__(szMsgID, ""))
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
	if(__NFUN_119__(sndSound, none))
	{
		ClientPlayVoices(none, sndSound, 7, 5, true, 1.0000000);
	}
	return;
}

function ServerGhost(Pawn aPawn)
{
	// End:0x24
	if(__NFUN_119__(CheatManager, none))
	{
		R6CheatManager(CheatManager).DoGhost(aPawn);
	}
	return;
}

function ServerCompleteMission()
{
	// End:0x1F
	if(__NFUN_119__(CheatManager, none))
	{
		R6CheatManager(CheatManager).DoCompleteMission();
	}
	return;
}

function ServerAbortMission()
{
	// End:0x1F
	if(__NFUN_119__(CheatManager, none))
	{
		R6CheatManager(CheatManager).DoAbortMission();
	}
	return;
}

function ServerWalk(Pawn aPawn)
{
	// End:0x24
	if(__NFUN_119__(CheatManager, none))
	{
		R6CheatManager(CheatManager).DoWalk(aPawn);
	}
	return;
}

function ServerPlayerInvisible(bool bIsVisible)
{
	// End:0x25
	if(__NFUN_119__(CheatManager, none))
	{
		R6CheatManager(CheatManager).DoPlayerInvisible(bIsVisible);
	}
	return;
}

function ClientTeamIsDead()
{
	// End:0x1C
	if(__NFUN_119__(m_MenuCommunication, none))
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
	if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
	{
		// End:0x56
		if(__NFUN_123__(Level.GreenTeamPawnClass, "none"))
		{
			TempGreenClass = Class<R6Rainbow>(DynamicLoadObject(Level.GreenTeamPawnClass, Class'Core.Class'));
		}
		// End:0xA8
		if(__NFUN_119__(TempGreenClass, none))
		{
			R6AbstractGameInfo(Level.Game).Find2DTexture(Level.GreenTeamPawnClass, Level.GreenMenuSkin, Level.GreenMenuRegion);
		}
		// End:0xE5
		if(__NFUN_123__(Level.RedTeamPawnClass, "none"))
		{
			TempRedClass = Class<R6Rainbow>(DynamicLoadObject(Level.RedTeamPawnClass, Class'Core.Class'));
		}
		// End:0x137
		if(__NFUN_119__(TempRedClass, none))
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
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
	{
		// End:0x7E
		if(__NFUN_123__(Level.GreenTeamPawnClass, "none"))
		{
			TempGreenClass = Class<Pawn>(DynamicLoadObject(Level.GreenTeamPawnClass, Class'Core.Class'));
		}
		// End:0x1A3
		if(__NFUN_119__(TempGreenClass, none))
		{
			Level.GreenTeamSkin = TempGreenClass.default.Skins[0];
			Level.GreenHeadSkin = TempGreenClass.default.Skins[1];
			Level.GreenGogglesSkin = TempGreenClass.default.Skins[2];
			Level.GreenHandSkin = TempGreenClass.default.Skins[5];
			Level.GreenMesh = TempGreenClass.default.Mesh;
			Level.GreenHelmet = TempGreenClass.default.m_HelmetClass;
			// End:0x1A3
			if(__NFUN_119__(Level.GreenHelmet, none))
			{
				Level.GreenHelmetMesh = Level.GreenHelmet.default.StaticMesh;
				Level.GreenHelmetSkin = Level.GreenHelmet.default.Skins[0];
			}
		}
		// End:0x1E0
		if(__NFUN_123__(Level.RedTeamPawnClass, "none"))
		{
			TempRedClass = Class<Pawn>(DynamicLoadObject(Level.RedTeamPawnClass, Class'Core.Class'));
		}
		// End:0x305
		if(__NFUN_119__(TempRedClass, none))
		{
			Level.RedTeamSkin = TempRedClass.default.Skins[0];
			Level.RedHeadSkin = TempRedClass.default.Skins[1];
			Level.RedGogglesSkin = TempRedClass.default.Skins[2];
			Level.RedHandSkin = TempRedClass.default.Skins[5];
			Level.RedMesh = TempRedClass.default.Mesh;
			Level.RedHelmet = TempRedClass.default.m_HelmetClass;
			// End:0x305
			if(__NFUN_119__(TempRedClass.default.m_HelmetClass, none))
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
	if(__NFUN_130__(__NFUN_119__(myHUD, none), __NFUN_119__(Viewport(Player), none)))
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
	if(__NFUN_119__(m_MenuCommunication, none))
	{
		m_MenuCommunication.CountDownPopUpBox();
	}
	return;
}

function CountDownPopUpBoxDone()
{
	// End:0x1A
	if(__NFUN_119__(m_MenuCommunication, none))
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
	ClientMessage(__NFUN_168__(__NFUN_168__(Localize("Game", "ChatDisabledMessage1", "R6GameInfo"), string(iTimeRem)), Localize("Game", "ChatDisabledMessage2", "R6GameInfo")));
	return;
}

// NEW IN 1.60
function ClientChatAbuseMsg(int iChatLockDuration)
{
	ClientMessage(__NFUN_168__(__NFUN_168__(Localize("Game", "AbuseDetectedMessage1", "R6GameInfo"), string(iChatLockDuration)), Localize("Game", "AbuseDetectedMessage2", "R6GameInfo")));
	return;
}

	// no chit chat while surrended/arrested
exec function Say(string Msg)
{
	local R6ServerInfo pServerInfo;

	// End:0x29
	if(__NFUN_132__(__NFUN_122__(Msg, ""), __NFUN_154__(int(Level.NetMode), int(NM_Standalone))))
	{
		return;
	}
	pServerInfo = Class'Engine.Actor'.static.__NFUN_1273__();
	// End:0xE0
	if(__NFUN_178__(m_fPreviousBroadcastTimeStamp, __NFUN_175__(Level.TimeSeconds, pServerInfo.SpamThreshold)))
	{
		// End:0xC0
		if(__NFUN_179__(Level.TimeSeconds, m_fEndOfChatLockTime))
		{
			m_fPreviousBroadcastTimeStamp = m_fLastBroadcastTimeStamp;
			m_fLastBroadcastTimeStamp = Level.TimeSeconds;
			Level.Game.Broadcast(self, Msg, 'Say');			
		}
		else
		{
			ClientChatDisabledMsg(int(__NFUN_175__(m_fEndOfChatLockTime, Level.TimeSeconds)));
		}		
	}
	else
	{
		m_fEndOfChatLockTime = __NFUN_174__(Level.TimeSeconds, pServerInfo.ChatLockDuration);
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
	if(__NFUN_132__(__NFUN_122__(Msg, ""), __NFUN_154__(int(Level.NetMode), int(NM_Standalone))))
	{
		return;
	}
	pServerInfo = Class'Engine.Actor'.static.__NFUN_1273__();
	// End:0xE0
	if(__NFUN_178__(m_fPreviousBroadcastTimeStamp, __NFUN_175__(Level.TimeSeconds, pServerInfo.SpamThreshold)))
	{
		// End:0xC0
		if(__NFUN_179__(Level.TimeSeconds, m_fEndOfChatLockTime))
		{
			m_fPreviousBroadcastTimeStamp = m_fLastBroadcastTimeStamp;
			m_fLastBroadcastTimeStamp = Level.TimeSeconds;
			Level.Game.BroadcastTeam(self, Msg, 'TeamSay');			
		}
		else
		{
			ClientChatDisabledMsg(int(__NFUN_175__(m_fEndOfChatLockTime, Level.TimeSeconds)));
		}		
	}
	else
	{
		m_fEndOfChatLockTime = __NFUN_174__(Level.TimeSeconds, pServerInfo.ChatLockDuration);
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
	if(__NFUN_242__(R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon, false))
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
		if(__NFUN_119__(Pawn, none))
		{
			__NFUN_299__(__NFUN_316__(Rotation, Pawn.m_rRotationOffset));
			Pawn.m_rRotationOffset = rot(0, 0, 0);
			m_pawn.__NFUN_2214__(Pawn.m_rRotationOffset,, true);
			Pawn.__NFUN_3970__(4);
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
	if(__NFUN_119__(R6AbstractGameInfo(Level.Game), none))
	{
		// End:0x50
		if(__NFUN_154__(int(m_ePenaltyForKillingAPawn), int(3)))
		{
			ClientGameMsg("", "", "PenaltyYouKilledAHostage");			
		}
		else
		{
			ClientGameMsg("", "", "PenaltyYouKilledATeamMate");
		}
		__NFUN_256__(1.0000000);
		R6AbstractGameInfo(Level.Game).ApplyTeamKillerPenalty(Pawn);
	}
	stop;				
}

state PlayerWalking
{
	function PlayerMove(float DeltaTime)
	{
		// End:0x8A
		if(__NFUN_254__(WindowConsole(Player.Console).ConsoleState, 'UWindow'))
		{
			// End:0x60
			if(__NFUN_150__(int(Role), int(ROLE_Authority)))
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
		if(__NFUN_132__(__NFUN_114__(Pawn, none), __NFUN_114__(m_pawn, none)))
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
		if(__NFUN_155__(int(Pawn.Physics), int(2)))
		{
			// End:0xCA
			if(__NFUN_130__(m_pawn.m_bPostureTransition, __NFUN_129__(m_pawn.m_bIsLanding)))
			{
				aForward = 0.0000000;
				aStrafe = 0.0000000;
				aTurn = 0.0000000;
				Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			}
			// End:0xEE
			if(__NFUN_154__(int(DoubleClickMove), int(3)))
			{
				m_fPostFluidMovementDelay = 0.1000000;
				ResetSpecialCrouch();				
			}
			else
			{
				// End:0x114
				if(__NFUN_178__(m_fPostFluidMovementDelay, float(0)))
				{
					m_fPostFluidMovementDelay = 0.0000000;
					HandleFluidMovement(DeltaTime);					
				}
				else
				{
					__NFUN_185__(m_fPostFluidMovementDelay, DeltaTime);
				}
			}
			// End:0x140
			if(__NFUN_154__(int(bDuck), 0))
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
		if(__NFUN_130__(__NFUN_154__(int(m_bReloading), 1), __NFUN_129__(R6GameReplicationInfo(GameReplicationInfo).m_bGameOverRep)))
		{
			ReloadWeapon();
		}
		return;
	}

	function BeginState()
	{
		m_pawn = R6Rainbow(Pawn);
		// End:0x24
		if(__NFUN_114__(Pawn, none))
		{
			__NFUN_113__('BaseSpectating');
			return;
		}
		// End:0x47
		if(__NFUN_114__(Pawn.Mesh, none))
		{
			Pawn.SetMesh();
		}
		DoubleClickDir = 0;
		bPressedJump = false;
		// End:0x99
		if(__NFUN_130__(__NFUN_155__(int(Pawn.Physics), int(2)), __NFUN_155__(int(Pawn.Physics), int(14))))
		{
			Pawn.__NFUN_3970__(1);
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
		if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(Player, none), __NFUN_119__(Viewport(Player), none)), __NFUN_114__(m_GameService, none)), __NFUN_119__(Player.Console, none)))
		{
			m_GameService = R6AbstractGameService(Player.Console.SetGameServiceLinks(self));
		}
		return;
	}

	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		Acceleration = NewAccel;
		__NFUN_3969__(__NFUN_212__(Acceleration, DeltaTime));
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Rotator NewRotation, OldRotation, ViewRotation;
		local Vector X, Y, Z;

		__NFUN_229__(Rotation, X, Y, Z);
		aForward = 0.0000000;
		aStrafe = 0.0000000;
		aUp = 0.0000000;
		aTurn = 0.0000000;
		Acceleration = __NFUN_213__(0.0200000, __NFUN_215__(__NFUN_215__(__NFUN_213__(aForward, X), __NFUN_213__(aStrafe, Y)), __NFUN_213__(aUp, vect(0.0000000, 0.0000000, 1.0000000))));
		ViewRotation = Rotation;
		__NFUN_299__(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1.0000000);
		// End:0xDF
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, Acceleration, 0, __NFUN_317__(OldRotation, Rotation));			
		}
		else
		{
			ProcessMove(DeltaTime, Acceleration, 0, __NFUN_317__(OldRotation, Rotation));
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
		if(__NFUN_132__(__NFUN_114__(Pawn, none), __NFUN_242__(m_bPawnInitialized, true)))
		{
			return;
		}
		m_bPawnInitialized = true;
		Pawn.m_bIsFiringWeapon = 0;
		Pawn.__NFUN_3970__(1);
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
		if(__NFUN_119__(Pawn, none))
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
		if(__NFUN_119__(GameReplicationInfo, none))
		{
			InitializeMenuCom();
			// End:0x6C
			if(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_bReadyToEnterSpectatorMode), __NFUN_154__(int(m_TeamSelection), int(0))), __NFUN_154__(int(GameReplicationInfo.m_eCurrectServerState), GameReplicationInfo.3)))
			{
				m_bReadyToEnterSpectatorMode = true;
				__NFUN_280__(5.0000000, false);
			}
			// End:0x8C
			if(__NFUN_155__(int(m_TeamSelection), int(0)))
			{
				__NFUN_280__(0.0000000, false);
				__NFUN_113__('Dead');
			}
		}
		return;
	}

	function Timer()
	{
		__NFUN_280__(0.0000000, false);
		__NFUN_113__('Dead');
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
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			return;
		}
		// End:0x28
		if(__NFUN_129__(m_bReadyToEnterSpectatorMode))
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
		if(__NFUN_151__(__NFUN_156__(R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode, Level.1), 0))
		{
			m_bCameraFirstPerson = true;
			// End:0xC4
			if(bShowLog)
			{
				__NFUN_231__("Death Camera Mode = eDCM_FIRSTPERSON");
			}
		}
		// End:0x123
		if(__NFUN_151__(__NFUN_156__(R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode, Level.2), 0))
		{
			m_bCameraThirdPersonFixed = true;
			// End:0x123
			if(bShowLog)
			{
				__NFUN_231__("Death Camera Mode = eDCM_THIRDPERSON");
			}
		}
		// End:0x186
		if(__NFUN_151__(__NFUN_156__(R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode, Level.4), 0))
		{
			m_bCameraThirdPersonFree = true;
			// End:0x186
			if(bShowLog)
			{
				__NFUN_231__("Death Camera Mode = eDCM_FREETHIRDPERSON");
			}
		}
		// End:0x1DF
		if(__NFUN_151__(__NFUN_156__(R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode, Level.8), 0))
		{
			m_bCameraGhost = true;
			// End:0x1DF
			if(bShowLog)
			{
				__NFUN_231__("Death Camera Mode = eDCM_GHOST");
			}
		}
		// End:0x23E
		if(__NFUN_151__(__NFUN_156__(R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode, Level.16), 0))
		{
			m_bFadeToBlack = true;
			// End:0x23E
			if(bShowLog)
			{
				__NFUN_231__("Death Camera Mode = eDCM_FADETOBLACK");
			}
		}
		// End:0x2C6
		if(__NFUN_151__(__NFUN_156__(R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode, Level.32), 0))
		{
			m_bSpectatorCameraTeamOnly = true;
			// End:0x2BE
			if(bShowLog)
			{
				__NFUN_231__(__NFUN_112__("Spectator Camera is restricted to Team Only m_TeamSelection=", string(m_TeamSelection)));
			}
			m_bCameraGhost = false;
		}
		// End:0x3E8
		if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
		{
			// End:0x3E8
			if(__NFUN_132__(__NFUN_132__(IsPlayerPassiveSpectator(), __NFUN_114__(m_TeamManager, none)), __NFUN_154__(m_TeamManager.m_iMemberCount, 0)))
			{
				// End:0x326
				if(__NFUN_150__(int(Role), int(ROLE_Authority)))
				{
					ServerExecFire(f);
				}
				// End:0x36B
				if(__NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer)))
				{
					// End:0x35E
					if(__NFUN_119__(Pawn, none))
					{
						Pawn.m_fRemainingGrenadeTime = 0.0000000;
					}
					ClientFadeCommonSound(0.5000000, 100);
				}
				// End:0x39F
				if(__NFUN_132__(__NFUN_132__(__NFUN_132__(m_bCameraFirstPerson, m_bCameraThirdPersonFixed), m_bCameraThirdPersonFree), m_bCameraGhost))
				{
					__NFUN_113__('CameraPlayer');					
				}
				else
				{
					// End:0x3E8
					if(__NFUN_130__(__NFUN_119__(myHUD, none), __NFUN_119__(Viewport(Player), none)))
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
		if(__NFUN_130__(m_bSpectatorCameraTeamOnly, __NFUN_130__(__NFUN_119__(m_MenuCommunication, none), __NFUN_154__(int(m_TeamSelection), int(4)))))
		{
			BeginState();
			return;
		}
		// End:0x9F
		if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Client)), __NFUN_130__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)), __NFUN_119__(Viewport(Player), none))))
		{
			// End:0x9F
			if(__NFUN_130__(__NFUN_119__(m_MenuCommunication, none), IsPlayerPassiveSpectator()))
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
		if(__NFUN_130__(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_119__(Viewport(Player), none)), __NFUN_132__(__NFUN_114__(GameReplicationInfo, none), __NFUN_114__(m_MenuCommunication, none))))
		{
			__NFUN_113__('WaitForGameRepInfo');
			return;
		}
		bCanEnterSpectator = true;
		// End:0x82
		if(__NFUN_132__(bPendingDelete, __NFUN_130__(__NFUN_119__(Pawn, none), Pawn.bPendingDelete)))
		{
			return;
		}
		// End:0xAE
		if(__NFUN_132__(bDeleteMe, __NFUN_130__(__NFUN_119__(Pawn, none), Pawn.bDeleteMe)))
		{
			return;
		}
		m_bReadyToEnterSpectatorMode = true;
		// End:0xE7
		if(__NFUN_151__(__NFUN_156__(R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode, Level.32), 0))
		{
			m_bSpectatorCameraTeamOnly = true;			
		}
		else
		{
			m_bSpectatorCameraTeamOnly = false;
		}
		// End:0x145
		if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_130__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)), __NFUN_114__(Viewport(Player), none))))
		{
			ClientGotoState('Dead', 'None');
		}
		super.BeginState();
		ClientDisableFirstPersonViewEffects();
		Blur(75);
		// End:0x331
		if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Client)), __NFUN_130__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)), __NFUN_119__(Viewport(Player), none))))
		{
			// End:0x23B
			if(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_MenuCommunication, none), __NFUN_155__(int(m_TeamSelection), int(4))), __NFUN_132__(__NFUN_129__(GameReplicationInfo.IsInAGameState()), __NFUN_119__(Pawn, none))))
			{
				// End:0x205
				if(__NFUN_154__(int(m_TeamSelection), int(0)))
				{
					m_MenuCommunication.SetStatMenuState(0);
					return;					
				}
				else
				{
					// End:0x238
					if(__NFUN_129__(Level.IsGameTypeCooperative(GameReplicationInfo.m_szGameTypeFlagRep)))
					{
						m_MenuCommunication.SetStatMenuState(5);
					}
				}				
			}
			else
			{
				// End:0x28C
				if(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)), __NFUN_119__(Viewport(Player), none)), __NFUN_155__(int(m_TeamSelection), int(4))))
				{
					// End:0x289
					if(__NFUN_114__(m_MenuCommunication, none))
					{
						InitializeMenuCom();
					}					
				}
				else
				{
					// End:0x321
					if(__NFUN_132__(__NFUN_129__(m_bSpectatorCameraTeamOnly), __NFUN_130__(__NFUN_155__(int(m_TeamSelection), int(0)), __NFUN_155__(int(m_TeamSelection), int(4)))))
					{
						// End:0x30B
						if(__NFUN_130__(__NFUN_130__(GameReplicationInfo.IsInAGameState(), __NFUN_114__(Pawn, none)), __NFUN_155__(int(m_TeamSelection), int(0))))
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
		if(__NFUN_130__(__NFUN_119__(myHUD, none), __NFUN_119__(Viewport(Player), none)))
		{
			// End:0x382
			if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
			{
				R6AbstractHUD(myHUD).StartFadeToBlack(5, 80);				
			}
			else
			{
				// End:0x3BC
				if(__NFUN_129__(bCanEnterSpectator))
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
				__NFUN_280__(3.0000000, false);
			}
		}
		return;
	}

	function EnterSpectatorMode()
	{
		// End:0x24
		if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
		{
			Fire(0.0000000);
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		// End:0x46
		if(__NFUN_130__(__NFUN_119__(myHUD, none), __NFUN_119__(Viewport(Player), none)))
		{
			R6AbstractHUD(myHUD).StopFadeToBlack();
			R6AbstractHUD(myHUD).ActivateNoDeathCameraMsg(false);
		}
		m_bReadyToEnterSpectatorMode = false;
		ResetBlur();
		__NFUN_280__(0.0000000, false);
		return;
	}

	function Timer()
	{
		// End:0x14
		if(PlayerCanSwitchToAIBackup())
		{
			__NFUN_280__(2.0000000, false);
			return;
		}
		InitializeMenuCom();
		// End:0x44
		if(__NFUN_130__(m_bSpectatorCameraTeamOnly, __NFUN_130__(__NFUN_119__(m_MenuCommunication, none), __NFUN_154__(int(m_TeamSelection), int(4)))))
		{
			return;
		}
		m_bReadyToEnterSpectatorMode = true;
		// End:0x114
		if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
		{
			// End:0xA3
			if(__NFUN_151__(__NFUN_156__(R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode, Level.16), 0))
			{
				R6AbstractHUD(myHUD).ActivateNoDeathCameraMsg(true);				
			}
			else
			{
				Fire(0.0000000);
				// End:0x114
				if(__NFUN_130__(__NFUN_130__(__NFUN_119__(GameReplicationInfo, none), __NFUN_154__(int(GameReplicationInfo.m_eCurrectServerState), GameReplicationInfo.3)), __NFUN_155__(int(m_TeamSelection), int(0))))
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
		if(__NFUN_119__(Pawn, none))
		{
			Pawn.bOwnerNoSee = false;
		}
		Pawn = none;
		m_pawn = none;
		SetViewTarget(self);
		Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		__NFUN_3970__(4);
		m_PrevViewTarget = none;
		m_eCameraMode = 0;
		// End:0x83
		if(__NFUN_129__(CameraIsAvailable()))
		{
			SelectCameraMode(true);
		}
		// End:0x117
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			rainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetRainbowTeam(Player.Console.Master.m_StartGameInfo.m_iTeamStart));
			SetNewViewTarget(rainbowTeam.m_Team[0]);
			// End:0x114
			if(__NFUN_119__(ViewTarget, none))
			{
				SetCameraMode();
			}			
		}
		else
		{
			// End:0x148
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				SpectatorChangeTeams(true);
				// End:0x148
				if(__NFUN_119__(ViewTarget, none))
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
		if(__NFUN_119__(ViewTarget, none))
		{
			// End:0x3E
			if(__NFUN_129__(bBehindView))
			{
				__NFUN_299__(__NFUN_316__(ViewTarget.Rotation, R6Pawn(ViewTarget).__NFUN_1842__()));				
			}
			else
			{
				rViewRotation = ViewTarget.Rotation;
				rViewRotation.Pitch = -6000;
				__NFUN_299__(rViewRotation);
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
			if(__NFUN_129__(CameraIsAvailable()))
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
			if(__NFUN_129__(CameraIsAvailable()))
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
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			ServerExecFire(f);
		}
		// End:0x28
		if(__NFUN_114__(ViewTarget, none))
		{
			return;
		}
		// End:0x65
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
		{
			// End:0x58
			if(__NFUN_180__(f, float(0)))
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
		if(__NFUN_155__(int(m_eCameraMode), int(3)))
		{
			return;
		}
		// End:0x34
		if(__NFUN_151__(int(bRun), 0))
		{
			Acceleration = __NFUN_213__(1.6000000, NewAccel);			
		}
		else
		{
			Acceleration = NewAccel;
		}
		__NFUN_3969__(__NFUN_212__(Acceleration, DeltaTime));
		return;
	}

	simulated function PlayerMove(float DeltaTime)
	{
		local Vector X, Y, Z;
		local Rotator rViewRotation;

		// End:0x76
		if(__NFUN_154__(int(m_eCameraMode), int(3)))
		{
			__NFUN_229__(Rotation, X, Y, Z);
			Acceleration = __NFUN_213__(0.0500000, __NFUN_215__(__NFUN_215__(__NFUN_213__(aForward, X), __NFUN_213__(aStrafe, Y)), __NFUN_213__(aUp, vect(0.0000000, 0.0000000, 1.0000000))));
			UpdateRotation(DeltaTime, 1.0000000);			
		}
		else
		{
			m_fCurrentDeltaTime = DeltaTime;
			// End:0x1B0
			if(bBehindView)
			{
				// End:0x179
				if(__NFUN_129__(bFixedCamera))
				{
					__NFUN_229__(Rotation, X, Y, Z);
					rViewRotation = Rotation;
					__NFUN_161__(rViewRotation.Yaw, int(__NFUN_171__(__NFUN_171__(32.0000000, DeltaTime), aTurn)));
					__NFUN_161__(rViewRotation.Pitch, int(__NFUN_171__(__NFUN_171__(32.0000000, DeltaTime), aLookUp)));
					rViewRotation.Pitch = __NFUN_156__(rViewRotation.Pitch, 65535);
					// End:0x16E
					if(__NFUN_130__(__NFUN_151__(rViewRotation.Pitch, 16384), __NFUN_150__(rViewRotation.Pitch, 49152)))
					{
						// End:0x15E
						if(__NFUN_177__(aLookUp, float(0)))
						{
							rViewRotation.Pitch = 16384;							
						}
						else
						{
							rViewRotation.Pitch = 49152;
						}
					}
					__NFUN_299__(rViewRotation);					
				}
				else
				{
					// End:0x1B0
					if(__NFUN_119__(ViewTarget, none))
					{
						rViewRotation = ViewTarget.Rotation;
						rViewRotation.Pitch = -6000;
						__NFUN_299__(rViewRotation);
					}
				}
			}
			// End:0x1C7
			if(__NFUN_242__(m_bShakeActive, true))
			{
				ViewShake(DeltaTime);
			}
			ViewFlash(DeltaTime);
			Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		}
		// End:0x2F4
		if(Class'Engine.Actor'.static.__NFUN_1524__().IsMissionPack())
		{
			// End:0x2A0
			if(__NFUN_130__(__NFUN_119__(m_pawn, none), m_pawn.m_bIsSurrended))
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
				if(__NFUN_150__(int(Role), int(ROLE_Authority)))
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
			if(__NFUN_150__(int(Role), int(ROLE_Authority)))
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
		if(__NFUN_155__(int(m_eCameraMode), int(3)))
		{
			Accel = vect(0.0000000, 0.0000000, 0.0000000);			
		}
		else
		{
			// End:0x50
			if(__NFUN_217__(Accel, vect(0.0000000, 0.0000000, 0.0000000)))
			{
				Velocity = vect(0.0000000, 0.0000000, 0.0000000);
			}
			// End:0x6B
			if(NewbRun)
			{
				Accel = __NFUN_213__(1.6000000, Accel);
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
		if(__NFUN_154__(int(m_eCameraMode), int(3)))
		{
			return;
		}
		// End:0x7E
		if(__NFUN_132__(__NFUN_114__(ViewTarget, none), __NFUN_114__(ViewTarget, self)))
		{
			// End:0x7C
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				SpectatorChangeTeams(true);
				// End:0x7C
				if(__NFUN_130__(__NFUN_119__(ViewTarget, none), __NFUN_119__(ViewTarget, self)))
				{
					SetCameraMode();
				}
			}
			return;
		}
		// End:0x113
		if(__NFUN_130__(__NFUN_130__(__NFUN_130__(m_bSpectatorCameraTeamOnly, __NFUN_132__(__NFUN_154__(m_iTeamId, int(2)), __NFUN_154__(m_iTeamId, int(3)))), __NFUN_119__(ViewTarget, none)), __NFUN_155__(Pawn(ViewTarget).m_iTeam, m_iTeamId)))
		{
			// End:0x111
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				SpectatorChangeTeams(true);
				// End:0x111
				if(__NFUN_130__(__NFUN_119__(ViewTarget, none), __NFUN_119__(ViewTarget, self)))
				{
					SetCameraMode();
				}
			}
			return;
		}
		// End:0x146
		if(__NFUN_129__(bBehindView))
		{
			__NFUN_299__(__NFUN_316__(ViewTarget.Rotation, R6Pawn(ViewTarget).__NFUN_1842__()));			
		}
		else
		{
			// End:0x160
			if(bFixedCamera)
			{
				__NFUN_299__(ViewTarget.Rotation);
			}
		}
		__NFUN_267__(ViewTarget.Location);
		return;
	}

	function SetCameraMode()
	{
		local Rotator rViewRotation;
		local Actor CamSpot;

		// End:0x70
		if(__NFUN_155__(int(m_eCameraMode), int(3)))
		{
			// End:0x70
			if(__NFUN_114__(ViewTarget, self))
			{
				// End:0x28
				if(__NFUN_114__(m_PrevViewTarget, none))
				{
					return;
				}
				// End:0x65
				if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
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
				if(__NFUN_119__(ViewTarget, self))
				{
					m_PrevViewTarget = ViewTarget;
				}
				SetViewTarget(self);
				// End:0x18B
				if(__NFUN_114__(m_PrevViewTarget, none))
				{
					CamSpot = Level.GetCamSpot(GameReplicationInfo.m_szGameTypeFlagRep);
					// End:0x188
					if(__NFUN_119__(CamSpot, none))
					{
						__NFUN_299__(CamSpot.Rotation);
						__NFUN_267__(CamSpot.Location);
					}					
				}
				else
				{
					rViewRotation = m_PrevViewTarget.Rotation;
					rViewRotation.Pitch = -6000;
					__NFUN_299__(rViewRotation);
					__NFUN_267__(__NFUN_216__(m_PrevViewTarget.Location, __NFUN_213__(__NFUN_171__(CameraDist, R6Pawn(m_PrevViewTarget).default.CollisionRadius), Vector(Rotation))));
				}
				bBehindView = false;
				bFixedCamera = false;
				m_bAttachCameraToEyes = false;
				bCheatFlying = true;
				// End:0x25C
				if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
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
		if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
		{
			return;
		}
		// End:0x2D
		if(__NFUN_154__(int(m_eCameraMode), int(3)))
		{
			return;
		}
		rainbowTeam = R6RainbowTeam(R6AbstractGameInfo(Level.Game).GetNewTeam(m_TeamManager, bNextTeam));
		// End:0x6D
		if(__NFUN_114__(rainbowTeam, none))
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
		if(__NFUN_130__(__NFUN_119__(m_MenuCommunication, none), __NFUN_155__(int(m_TeamSelection), int(2))))
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
		if(__NFUN_130__(__NFUN_119__(Level.Game, none), __NFUN_129__(Level.Game.bCanViewOthers)))
		{
			return;
		}
		// End:0x51
		if(__NFUN_130__(m_bSpectatorCameraTeamOnly, __NFUN_154__(m_iTeamId, 0)))
		{
			ValidateCameraTeamId();
		}
		// End:0x10E
		if(bNextTeam)
		{
			first = none;
			// End:0xEF
			foreach __NFUN_304__(Class'R6Engine.R6Rainbow', Other)
			{
				// End:0xEE
				if(Other.IsAlive())
				{
					// End:0xAA
					if(__NFUN_130__(m_bSpectatorCameraTeamOnly, __NFUN_155__(Other.m_iTeam, m_iTeamId)))
					{
						continue;						
					}
					// End:0xD7
					if(__NFUN_132__(bFound, __NFUN_114__(first, none)))
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
					if(__NFUN_114__(Other, ViewTarget))
					{
						bFound = true;
					}
				}				
			}			
			// End:0x109
			if(__NFUN_119__(first, none))
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
			foreach __NFUN_304__(Class'R6Engine.R6Rainbow', Other)
			{
				// End:0x188
				if(Other.IsAlive())
				{
					// End:0x15E
					if(__NFUN_130__(m_bSpectatorCameraTeamOnly, __NFUN_155__(Other.m_iTeam, m_iTeamId)))
					{
						continue;						
					}
					// End:0x17D
					if(__NFUN_130__(__NFUN_114__(Other, ViewTarget), __NFUN_119__(Last, none)))
					{
						// End:0x189
						break;
					}
					Last = Other;
				}				
			}			
			// End:0x1A3
			if(__NFUN_119__(Last, none))
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
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
		{
			return;
		}
		// End:0x31
		if(__NFUN_119__(ViewTarget, self))
		{
			m_PrevViewTarget = ViewTarget;
		}
		SetNewViewTarget(ViewTarget);
		// End:0x4D
		if(__NFUN_119__(ViewTarget, none))
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
		if(__NFUN_154__(int(m_eCameraMode), int(3)))
		{
			return;
		}
		aPawn = R6Rainbow(aViewTarget);
		// End:0x2F
		if(__NFUN_114__(aPawn, none))
		{
			return;
		}
		SetViewTarget(aPawn);
		// End:0x164
		if(__NFUN_119__(aPawn.Controller, none))
		{
			aOldTeamManager = m_TeamManager;
			// End:0x92
			if(__NFUN_129__(aPawn.m_bIsPlayer))
			{
				m_TeamManager = R6RainbowAI(aPawn.Controller).m_TeamManager;				
			}
			else
			{
				m_TeamManager = R6PlayerController(aPawn.Controller).m_TeamManager;
			}
			// End:0x164
			if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(Role), int(ROLE_Authority)), __NFUN_119__(aOldTeamManager, none)), __NFUN_119__(aOldTeamManager, m_TeamManager)), __NFUN_129__(aOldTeamManager.m_bLeaderIsAPlayer)), __NFUN_129__(m_TeamManager.m_bLeaderIsAPlayer)))
			{
				aOldTeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, false, m_TeamManager.m_iIDVoicesMgr);
				m_TeamManager.SetVoicesMgr(R6AbstractGameInfo(Level.Game), false, true);
			}
		}
		SetSpectatorRotation();
		FixFOV();
		// End:0x1A1
		if(__NFUN_130__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)), __NFUN_119__(Viewport(Player), none)))
		{
			DisplayClientMessage();
		}
		return;
	}

	exec function NextMember()
	{
		local int i;

		// End:0x12
		if(__NFUN_154__(int(m_eCameraMode), int(3)))
		{
			return;
		}
		// End:0x9D
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			// End:0x9A
			if(__NFUN_151__(m_TeamManager.m_iMemberCount, 0))
			{
				i = __NFUN_146__(R6Pawn(ViewTarget).m_iID, 1);
				// End:0x7A
				if(__NFUN_153__(i, m_TeamManager.m_iMemberCount))
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
		if(__NFUN_154__(int(m_eCameraMode), int(3)))
		{
			return;
		}
		// End:0xA0
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			// End:0x9D
			if(__NFUN_151__(m_TeamManager.m_iMemberCount, 0))
			{
				i = __NFUN_147__(R6Pawn(ViewTarget).m_iID, 1);
				// End:0x7D
				if(__NFUN_150__(i, 0))
				{
					i = __NFUN_147__(m_TeamManager.m_iMemberCount, 1);
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
		if(__NFUN_114__(ViewTarget, none))
		{
			return "";
		}
		targetPawn = R6Pawn(ViewTarget);
		// End:0x2C
		if(__NFUN_114__(targetPawn, none))
		{
			return "";
		}
		// End:0x98
		if(targetPawn.m_bIsPlayer)
		{
			// End:0x69
			if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
			{
				return targetPawn.m_CharacterName;				
			}
			else
			{
				// End:0x95
				if(__NFUN_119__(targetPawn.PlayerReplicationInfo, none))
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
		if(__NFUN_114__(ViewTarget, none))
		{
			return;
		}
		// End:0x1E9
		if(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Client)), __NFUN_154__(int(Level.NetMode), int(NM_Standalone))), __NFUN_130__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)), __NFUN_119__(Viewport(Player), none))))
		{
			// End:0xA4
			if(bCheatFlying)
			{
				ClientMessage(Localize("Game", "GhostCamera", "R6GameInfo"));
				return;
			}
			targetName = GetViewTargetName();
			// End:0xBE
			if(__NFUN_122__(targetName, ""))
			{
				return;
			}
			// End:0x124
			if(__NFUN_129__(bBehindView))
			{
				ClientMessage(__NFUN_168__(__NFUN_168__(Localize("Game", "NowViewing", "R6GameInfo"), targetName), Localize("Game", "FirstCamera", "R6GameInfo")));				
			}
			else
			{
				// End:0x18D
				if(bFixedCamera)
				{
					ClientMessage(__NFUN_168__(__NFUN_168__(Localize("Game", "NowViewing", "R6GameInfo"), targetName), Localize("Game", "FixedThirdCamera", "R6GameInfo")));					
				}
				else
				{
					ClientMessage(__NFUN_168__(__NFUN_168__(Localize("Game", "NowViewing", "R6GameInfo"), targetName), Localize("Game", "FreeThirdCamera", "R6GameInfo")));
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
		if(__NFUN_155__(int(m_pawn.m_eGrenadeThrow), int(0)))
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
			Pawn.__NFUN_3970__(2);
			Pawn.OnLadder = none;
			m_pawn.m_bSlideEnd = false;
			m_pawn.m_bIsClimbingLadder = false;
			m_pawn.m_bPostureTransition = false;
			m_pawn.m_Ladder = none;
			Pawn.__NFUN_267__(__NFUN_215__(Pawn.Location, __NFUN_213__(float(25), Vector(Pawn.Rotation))));
			m_pawn.PlayFalling();			
		}
		else
		{
			// End:0x23C
			if(m_bCrawl)
			{
				m_pawn.m_bWantsToProne = false;
				// End:0x213
				if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
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
				if(__NFUN_155__(int(bDuck), 0))
				{
					// End:0x275
					if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
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
					if(__NFUN_132__(m_pawn.m_bReloadingWeapon, m_pawn.m_bChangingWeapon))
					{
						__NFUN_113__('PlayerFinishReloadingBeforeSurrender');						
					}
					else
					{
						__NFUN_113__('PlayerPreBeginSurrending');
					}					
				}
				else
				{
					// End:0x317
					if(__NFUN_132__(m_pawn.m_bReloadingWeapon, m_pawn.m_bChangingWeapon))
					{
						__NFUN_113__('PlayerFinishReloadingBeforeSurrender');						
					}
					else
					{
						// End:0x337
						if(__NFUN_155__(int(Pawn.Physics), int(2)))
						{
							__NFUN_113__('PlayerPreBeginSurrending');
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
		if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(Role), int(ROLE_Authority)), __NFUN_155__(int(Pawn.Physics), int(2))), __NFUN_129__(Pawn.m_bIsLanding)), __NFUN_129__(m_bCrawl)), __NFUN_154__(int(bDuck), 0)))
		{
			__NFUN_113__('PlayerPreBeginSurrending');
			ClientGotoState('PlayerPreBeginSurrending', 'None');
		}
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		// End:0x51
		if(__NFUN_155__(int(Pawn.Physics), int(2)))
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
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
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
		if(__NFUN_130__(__NFUN_154__(iChannel, m_pawn.1), __NFUN_155__(int(bDuck), 0)))
		{
			m_pawn.m_bPostureTransition = false;
			RaisePosture();
			// End:0x6A
			if(__NFUN_132__(m_pawn.m_bReloadingWeapon, m_pawn.m_bChangingWeapon))
			{
				__NFUN_113__('PlayerFinishReloadingBeforeSurrender');				
			}
			else
			{
				__NFUN_113__('PlayerPreBeginSurrending');
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
		if(__NFUN_119__(Pawn, none))
		{
			Floor = Pawn.Floor;
		}
		// End:0x3A
		if(__NFUN_155__(int(Pawn.Physics), int(1)))
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
		if(__NFUN_154__(iChannel, m_pawn.14))
		{
			__NFUN_113__('PlayerPreBeginSurrending');
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
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
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
		if(__NFUN_130__(__NFUN_130__(Pawn.IsLocallyControlled(), __NFUN_154__(int(m_eCameraMode), int(0))), __NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer))))
		{
			newRot.Pitch = ViewTarget.Rotation.Pitch;
			newRot.Yaw = ViewTarget.Rotation.Yaw;
			newRot.Roll = 0;
			ViewTarget.__NFUN_299__(newRot);
			DoZoom(true);
			bZooming = false;
			m_bHelmetCameraOn = false;
			DefaultFOV = default.DefaultFOV;
			DesiredFOV = default.DesiredFOV;
			FovAngle = default.DesiredFOV;
			HelmetCameraZoom(1.0000000);
			R6Pawn(Pawn).__NFUN_2004__(false, none, none);
			R6Pawn(Pawn).__NFUN_2600__(false, none, none);
			R6Pawn(Pawn).__NFUN_2605__(false, none, none);
			Level.m_bHeartBeatOn = false;
			Level.m_bInGamePlanningActive = false;
			__NFUN_2011__(false);
			m_eCameraMode = 2;
			// End:0x157
			if(__NFUN_129__(CameraIsAvailable()))
			{
				SelectCameraMode(true);
			}
			SetCameraMode();
		}
		Pawn.m_fRemainingGrenadeTime = 0.0000000;
		// End:0x289
		if(__NFUN_130__(__NFUN_119__(m_pawn.EngineWeapon, none), __NFUN_129__(__NFUN_130__(__NFUN_132__(Pawn.EngineWeapon.__NFUN_303__('R6GrenadeWeapon'), Pawn.EngineWeapon.__NFUN_303__('R6HBSSAJammerGadget')), __NFUN_129__(Pawn.EngineWeapon.HasAmmo())))))
		{
			// End:0x212
			if(__NFUN_155__(int(m_pawn.m_bIsFiringWeapon), 0))
			{
				m_pawn.EngineWeapon.ServerStopFire();
			}
			// End:0x277
			if(__NFUN_129__(m_pawn.EngineWeapon.__NFUN_281__('PutWeaponDown')))
			{
				m_pawn.EngineWeapon.__NFUN_113__('PutWeaponDown');
				// End:0x274
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(27);
				}				
			}
			else
			{
				m_bSkipBeginState = false;
				__NFUN_113__('PlayerStartSurrending');
			}			
		}
		else
		{
			m_bSkipBeginState = false;
			__NFUN_113__('PlayerStartSurrending');
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
		if(__NFUN_154__(iChannel, m_pawn.14))
		{
			m_bSkipBeginState = false;
			__NFUN_113__('PlayerStartSurrending');			
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
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_154__(iChannel, m_pawn.16))
		{
			__NFUN_113__('PlayerSurrended');			
		}
		else
		{
			// End:0x5C
			if(__NFUN_177__(__NFUN_175__(Level.TimeSeconds, m_fStartSurrenderTime), float(2)))
			{
				m_pawn.EngineWeapon.ServerStopFire();
				__NFUN_113__('PlayerSurrended');
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
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
		{
			m_pawn.SetNextPendingAction(31);
		}
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x3F
		if(__NFUN_154__(iChannel, m_pawn.16))
		{
			// End:0x3F
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(Role), int(ROLE_Authority)), __NFUN_177__(__NFUN_175__(Level.TimeSeconds, m_fStartSurrenderTime), float(10))), __NFUN_129__(m_pawn.m_bIsUnderArrest)), __NFUN_129__(m_pawn.m_bIsBeingArrestedOrFreed)))
		{
			m_bSkipBeginState = false;
			m_pawn.m_eHealth = 0;
			m_pawn.m_bIsSurrended = false;
			// End:0x9C
			if(__NFUN_154__(int(Role), int(ROLE_Authority)))
			{
				ClientEndSurrended();
			}
			__NFUN_113__('PlayerEndSurrended');			
		}
		else
		{
			// End:0xBF
			if(m_pawn.m_bIsBeingArrestedOrFreed)
			{
				__NFUN_113__('PlayerStartArrest');
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
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_130__(Pawn.IsLocallyControlled(), __NFUN_154__(int(m_eCameraMode), int(2))))
		{
			m_eCameraMode = 0;
			// End:0x44
			if(__NFUN_129__(CameraIsAvailable()))
			{
				SelectCameraMode(true);
			}
			SetCameraMode();
		}
		m_pawn.m_bPawnSpecificAnimInProgress = false;
		// End:0x153
		if(__NFUN_130__(__NFUN_119__(m_pawn.EngineWeapon, none), __NFUN_129__(__NFUN_130__(__NFUN_132__(Pawn.EngineWeapon.__NFUN_303__('R6GrenadeWeapon'), Pawn.EngineWeapon.__NFUN_303__('R6HBSSAJammerGadget')), __NFUN_129__(Pawn.EngineWeapon.HasAmmo())))))
		{
			// End:0x110
			if(__NFUN_132__(Pawn.EngineWeapon.__NFUN_303__('R6GrenadeWeapon'), Pawn.EngineWeapon.__NFUN_303__('R6HBSSAJammerGadget')))
			{
				WeaponUpState();
			}
			Pawn.EngineWeapon.__NFUN_113__('BringWeaponUp');
			// End:0x153
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(28);
			}
		}
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x46
		if(__NFUN_154__(iChannel, m_pawn.16))
		{
			// End:0x3F
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(41);
			}
			__NFUN_113__('PlayerWalking');
		}
		return;
	}

	function EndSurrenderSetUp()
	{
		m_pawn.m_bPostureTransition = false;
		// End:0x35
		if(__NFUN_154__(int(Role), int(ROLE_Authority)))
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
		if(__NFUN_119__(m_PlayerCurrentCA.aQueryTarget, none))
		{
			R6PlayerController(R6Rainbow(m_PlayerCurrentCA.aQueryTarget).Controller).m_fStartSurrenderTime = Level.TimeSeconds;
		}
		// End:0x162
		if(__NFUN_119__(m_pawn.EngineWeapon, none))
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
				R6Pawn(Pawn).__NFUN_2004__(false, none, none);
				R6Pawn(Pawn).__NFUN_2600__(false, none, none);
				R6Pawn(Pawn).__NFUN_2605__(false, none, none);
				Level.m_bHeartBeatOn = false;
				Level.m_bInGamePlanningActive = false;
				__NFUN_2011__(false);
			}
			Pawn.EngineWeapon.__NFUN_113__('PutWeaponDown');
			// End:0x162
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_150__(m_iPlayerCAProgress, 100))
		{
			m_pawn.R6ResetAnimBlendParams(m_pawn.1);
			// End:0x6D
			if(__NFUN_130__(m_bIsSecuringRainbow, R6Rainbow(m_PlayerCurrentCA.aQueryTarget).m_bIsSurrended))
			{
				R6Rainbow(m_PlayerCurrentCA.aQueryTarget).ResetArrest();
			}			
		}
		else
		{
			// End:0x37B
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
						if(__NFUN_119__(m_pawn.PlayerReplicationInfo, none))
						{
							arrestorName = m_pawn.PlayerReplicationInfo.PlayerName;							
						}
						else
						{
							arrestorName = m_pawn.m_CharacterName;
						}
						pGameInfo = R6AbstractGameInfo(Level.Game);
						// End:0x338
						if(__NFUN_119__(pGameInfo, none))
						{
							// End:0x338
							if(__NFUN_132__(__NFUN_242__(pGameInfo.m_bCompilingStats, true), __NFUN_130__(pGameInfo.m_bGameOver, pGameInfo.m_bGameOverButAllowDeath)))
							{
								// End:0x338
								if(__NFUN_119__(R6Pawn(m_PlayerCurrentCA.aQueryTarget).PlayerReplicationInfo, none))
								{
									R6Pawn(m_PlayerCurrentCA.aQueryTarget).PlayerReplicationInfo.m_szKillersName = arrestorName;
									__NFUN_184__(R6Pawn(m_PlayerCurrentCA.aQueryTarget).PlayerReplicationInfo.Deaths, 1.0000000);
									// End:0x338
									if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_129__(R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_bSuicided), __NFUN_119__(R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy, none)), __NFUN_119__(R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy.Controller, none)), __NFUN_119__(R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy.Controller.PlayerReplicationInfo, none)))
									{
										__NFUN_184__(R6Pawn(m_PlayerCurrentCA.aQueryTarget).m_KilledBy.Controller.PlayerReplicationInfo.Score, 1.0000000);
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
		if(__NFUN_129__(m_pawn.m_bIsSurrended))
		{
			m_pawn.m_ePlayerIsUsingHands = 0;
			// End:0x41E
			if(__NFUN_119__(m_pawn.EngineWeapon, none))
			{
				Pawn.EngineWeapon.__NFUN_113__('BringWeaponUp');
				// End:0x40F
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_130__(__NFUN_154__(iChannel, m_pawn.1), m_pawn.m_bPostureTransition))
		{
			// End:0x84
			if(bShowLog)
			{
				__NFUN_231__("SecureRainbow: AnimEnd, END Secure/Free rainbow animation, switch playerwalking");
			}
			m_pawn.m_bPostureTransition = false;
			m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
			m_iPlayerCAProgress = 100;
			// End:0xDF
			if(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)))
			{
				ClientActionProgressDone();
			}
			// End:0xF9
			if(__NFUN_119__(m_InteractionCA, none))
			{
				m_InteractionCA.ActionProgressDone();
			}
			// End:0x119
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				__NFUN_113__('PlayerWalking');
			}			
		}
		else
		{
			// End:0x328
			if(__NFUN_130__(__NFUN_154__(iChannel, m_pawn.14), __NFUN_154__(int(m_pawn.m_eEquipWeapon), int(m_pawn.2))))
			{
				// End:0x19D
				if(bShowLog)
				{
					__NFUN_231__("SecureRainbow: AnimEnd, start Secure/Free rainbow animation");
				}
				m_pawn.m_bWeaponTransition = false;
				m_pawn.m_bPostureTransition = false;
				m_pawn.PlaySecureTerrorist();
				m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
				m_bIsSecuringRainbow = __NFUN_154__(int(m_PlayerCurrentCA.iPlayerActionID), int(m_pawn.1));
				// End:0x29C
				if(bShowLog)
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("SecureRainbow: AnimEnd, start Secure/Free rainbow animation. CircAction=", string(m_PlayerCurrentCA.iPlayerActionID)), " m_bIsSecuringRainbow="), string(m_bIsSecuringRainbow)));
				}
				// End:0x328
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(29);
					// End:0x328
					if(__NFUN_154__(int(m_PlayerCurrentCA.iPlayerActionID), int(m_pawn.1)))
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
		if(__NFUN_130__(__NFUN_119__(m_pawn.EngineWeapon, none), __NFUN_155__(int(m_pawn.m_eEquipWeapon), int(m_pawn.2))))
		{
			return;
		}
		// End:0x50
		if(__NFUN_129__(m_pawn.m_bPostureTransition))
		{
			return;
		}
		// End:0x88
		if(__NFUN_154__(int(Role), int(ROLE_Authority)))
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
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_154__(iChannel, m_pawn.16))
		{
			Pawn.GetAnimParams(m_pawn.16, Anim, fFrame, fRate);
			// End:0x7A
			if(__NFUN_254__(Anim, 'SurrenderToKneel'))
			{
				// End:0x77
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(43);
				}				
			}
			else
			{
				__NFUN_113__('PlayerArrested');
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
		if(__NFUN_119__(m_pawn.PlayerReplicationInfo, none))
		{
			myName = m_pawn.PlayerReplicationInfo.PlayerName;			
		}
		else
		{
			myName = m_pawn.m_CharacterName;
		}
		// End:0x112
		if(__NFUN_119__(m_pInteractingRainbow, none))
		{
			// End:0x9A
			if(__NFUN_119__(m_pInteractingRainbow.PlayerReplicationInfo, none))
			{
				arrestorName = m_pInteractingRainbow.PlayerReplicationInfo.PlayerName;				
			}
			else
			{
				arrestorName = m_pInteractingRainbow.m_CharacterName;
			}
			myHUD.AddDeathTextMessage(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(arrestorName, " "), Localize("MPMiscMessages", "PlayerArrestedPlayer", "ASGameMode")), " "), myName), Class'Engine.LocalMessage');
		}
		// End:0x13C
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_154__(iChannel, m_pawn.16))
		{
			// End:0x3F
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(44);
			}
			m_pawn.__NFUN_262__(true, false, false);
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
		if(__NFUN_130__(Pawn.IsLocallyControlled(), __NFUN_154__(int(m_eCameraMode), int(2))))
		{
			m_eCameraMode = 0;
			// End:0x3E
			if(__NFUN_129__(CameraIsAvailable()))
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
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
		{
			R6AbstractGameInfo(Level.Game).PawnSecure(m_pawn);
		}
		// End:0x103
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
		{
			m_pawn.SetNextPendingAction(45);
		}
		m_pawn.__NFUN_262__(true, true, true);
		// End:0x146
		if(__NFUN_119__(m_pawn.PlayerReplicationInfo, none))
		{
			myName = m_pawn.PlayerReplicationInfo.PlayerName;			
		}
		else
		{
			myName = m_pawn.m_CharacterName;
		}
		// End:0x20A
		if(__NFUN_119__(m_pInteractingRainbow, none))
		{
			// End:0x199
			if(__NFUN_119__(m_pInteractingRainbow.PlayerReplicationInfo, none))
			{
				rescuerName = m_pInteractingRainbow.PlayerReplicationInfo.PlayerName;				
			}
			else
			{
				rescuerName = m_pInteractingRainbow.m_CharacterName;
			}
			myHUD.AddDeathTextMessage(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(myName, " "), Localize("MPMiscMessages", "PlayerRescued", "ASGameMode")), " "), rescuerName), Class'Engine.LocalMessage');
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
		if(__NFUN_130__(__NFUN_119__(m_pawn.EngineWeapon, none), __NFUN_129__(__NFUN_130__(__NFUN_132__(Pawn.EngineWeapon.__NFUN_303__('R6GrenadeWeapon'), Pawn.EngineWeapon.__NFUN_303__('R6HBSSAJammerGadget')), __NFUN_129__(Pawn.EngineWeapon.HasAmmo())))))
		{
			// End:0xB5
			if(__NFUN_132__(Pawn.EngineWeapon.__NFUN_303__('R6GrenadeWeapon'), Pawn.EngineWeapon.__NFUN_303__('R6HBSSAJammerGadget')))
			{
				WeaponUpState();
			}
			// End:0xE7
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				Pawn.EngineWeapon.__NFUN_113__('BringWeaponUp');
			}
			// End:0x111
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_154__(iChannel, m_pawn.16))
		{
			Pawn.GetAnimParams(m_pawn.16, Anim, fFrame, fRate);
			// End:0x7A
			if(__NFUN_254__(Anim, 'KneelArrest'))
			{
				// End:0x77
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(42);
				}				
			}
			else
			{
				// End:0xA4
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(41);
				}
				__NFUN_113__('PlayerWalking');
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
		if(__NFUN_130__(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_154__(int(Role), int(ROLE_Authority))), m_PlayerCurrentCA.aQueryTarget.__NFUN_303__('R6IOBomb')))
		{
			// End:0x9E
			if(__NFUN_129__(R6IOObject(m_PlayerCurrentCA.aQueryTarget).m_bIsActivated))
			{
				m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(m_pawn, 4);				
			}
			else
			{
				m_TeamManager.m_MultiCommonVoicesMgr.PlayMultiCommonVoices(m_pawn, 6);
			}
		}
		// End:0x11E
		if(__NFUN_119__(m_pawn.EngineWeapon, none))
		{
			ToggleHelmetCameraZoom(true);
			m_pawn.EngineWeapon.__NFUN_113__('PutWeaponDown');
			// End:0x11B
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(m_RequestedCircumstantialAction.aQueryTarget.__NFUN_303__('R6IOObject'))
		{
			m_pawn.m_bInteractingWithDevice = true;
			m_pawn.m_eDeviceAnim = R6IOObject(m_RequestedCircumstantialAction.aQueryTarget).m_eAnimToPlay;
			// End:0xA0
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(18);
			}			
		}
		else
		{
			// End:0xFB
			if(m_RequestedCircumstantialAction.aQueryTarget.__NFUN_303__('R6IORotatingDoor'))
			{
				m_pawn.m_bIsLockPicking = true;
				// End:0xFB
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_130__(__NFUN_154__(iChannel, m_pawn.14), __NFUN_154__(int(m_pawn.m_eEquipWeapon), int(m_pawn.2))))
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
		if(__NFUN_119__(m_pawn, none))
		{
			m_pawn.m_bPostureTransition = false;
			m_pawn.m_bIsLockPicking = false;
			m_pawn.m_bInteractingWithDevice = false;
			m_pawn.m_ePlayerIsUsingHands = 0;
			// End:0xC4
			if(__NFUN_130__(__NFUN_119__(m_pawn.EngineWeapon, none), __NFUN_129__(m_pawn.m_bIsSurrended)))
			{
				m_pawn.EngineWeapon.__NFUN_113__('BringWeaponUp');
				// End:0xC4
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(28);
				}
			}
			// End:0x110
			if(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(Role), int(ROLE_Authority)), __NFUN_129__(m_pawn.IsAlive())), __NFUN_150__(m_iPlayerCAProgress, 105)))
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
		if(__NFUN_130__(__NFUN_119__(m_pawn.EngineWeapon, none), __NFUN_155__(int(m_pawn.m_eEquipWeapon), int(m_pawn.2))))
		{
			return;
		}
		// End:0x66
		if(__NFUN_130__(__NFUN_129__(m_pawn.m_bIsLockPicking), __NFUN_129__(m_pawn.m_bInteractingWithDevice)))
		{
			return;
		}
		// End:0x13F
		if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		{
			// End:0x8B
			if(__NFUN_114__(m_PlayerCurrentCA, none))
			{
				m_iPlayerCAProgress = 0;				
			}
			else
			{
				// End:0xA9
				if(__NFUN_114__(m_PlayerCurrentCA.aQueryTarget, none))
				{
					m_iPlayerCAProgress = 0;					
				}
				else
				{
					m_iPlayerCAProgress = m_PlayerCurrentCA.aQueryTarget.R6GetCircumstantialActionProgress(m_PlayerCurrentCA, m_pawn);
				}
			}
			// End:0x13F
			if(__NFUN_153__(m_iPlayerCAProgress, 105))
			{
				m_iPlayerCAProgress = 0;
				// End:0x11E
				if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_155__(int(Level.NetMode), int(NM_Client))))
				{
					ClientActionProgressDone();
				}
				// End:0x138
				if(__NFUN_119__(m_InteractionCA, none))
				{
					m_InteractionCA.ActionProgressDone();
				}
				__NFUN_113__('PlayerWalking');
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
		if(__NFUN_119__(m_pawn.EngineWeapon, none))
		{
			ToggleHelmetCameraZoom(true);
			Pawn.EngineWeapon.__NFUN_113__('PutWeaponDown');
			// End:0x6E
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_150__(m_iPlayerCAProgress, 100))
		{
			m_pawn.R6ResetAnimBlendParams(m_pawn.1);
			// End:0x5A
			if(__NFUN_154__(int(Role), int(ROLE_Authority)))
			{
				R6Terrorist(m_PlayerCurrentCA.aQueryTarget).ResetArrest();
			}
		}
		m_pawn.m_bPostureTransition = false;
		m_iPlayerCAProgress = 0;
		m_pawn.m_ePlayerIsUsingHands = 0;
		// End:0xDA
		if(__NFUN_119__(m_pawn.EngineWeapon, none))
		{
			Pawn.EngineWeapon.__NFUN_113__('BringWeaponUp');
			// End:0xDA
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_130__(__NFUN_154__(iChannel, m_pawn.1), m_pawn.m_bPostureTransition))
		{
			m_pawn.m_bPostureTransition = false;
			m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
			m_iPlayerCAProgress = 100;
			// End:0x83
			if(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)))
			{
				ClientActionProgressDone();
			}
			// End:0x9D
			if(__NFUN_119__(m_InteractionCA, none))
			{
				m_InteractionCA.ActionProgressDone();
			}
			__NFUN_113__('PlayerWalking');			
		}
		else
		{
			// End:0x193
			if(__NFUN_130__(__NFUN_154__(iChannel, m_pawn.14), __NFUN_154__(int(m_pawn.m_eEquipWeapon), int(m_pawn.2))))
			{
				m_pawn.m_bWeaponTransition = false;
				m_pawn.m_bPostureTransition = false;
				m_pawn.PlaySecureTerrorist();
				m_PlayerCurrentCA.aQueryTarget.R6CircumstantialActionProgressStart(m_PlayerCurrentCA);
				// End:0x193
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_130__(__NFUN_119__(m_pawn.EngineWeapon, none), __NFUN_155__(int(m_pawn.m_eEquipWeapon), int(m_pawn.2))))
		{
			return;
		}
		// End:0x50
		if(__NFUN_129__(m_pawn.m_bPostureTransition))
		{
			return;
		}
		// End:0x88
		if(__NFUN_154__(int(Role), int(ROLE_Authority)))
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
		if(__NFUN_154__(iChannel, m_pawn.1))
		{
			// End:0x2D
			if(m_pawn.IsAlive())
			{
				__NFUN_113__('PlayerWalking');
			}
		}
		return;
	}

	function int GetActionProgress()
	{
		local name Anim;
		local float fFrame, fRate;

		Pawn.GetAnimParams(m_pawn.1, Anim, fFrame, fRate);
		__NFUN_251__(int(fFrame), 0, 100);
		return int(__NFUN_171__(fFrame, float(110)));
		return;
	}

	event Tick(float fDeltaTime)
	{
		m_iPlayerCAProgress = GetActionProgress();
		// End:0x20
		if(__NFUN_151__(m_iPlayerCAProgress, 75))
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
		if(__NFUN_130__(__NFUN_119__(Pawn.EngineWeapon, none), __NFUN_129__(__NFUN_130__(Pawn.EngineWeapon.__NFUN_303__('R6GrenadeWeapon'), __NFUN_129__(Pawn.EngineWeapon.HasAmmo())))))
		{
			DoZoom(true);
			Pawn.EngineWeapon.__NFUN_113__('PutWeaponDown');
			// End:0xC7
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(27);
			}
			m_pawn.RainbowSecureWeapon();			
		}
		else
		{
			m_bSkipBeginState = false;
			__NFUN_113__('PlayerBeginClimbingLadder');
			// End:0x107
			if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
			{
				ServerStartClimbingLadder();
			}
		}
		// End:0x17B
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
		{
			// End:0x150
			if(__NFUN_132__(__NFUN_114__(m_pawn.m_Ladder, none), __NFUN_114__(m_pawn.OnLadder, none)))
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
		if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_154__(iChannel, m_pawn.14)))
		{
			m_bSkipBeginState = false;
			__NFUN_113__('PlayerBeginClimbingLadder');
			// End:0x5E
			if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
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
		if(__NFUN_132__(__NFUN_114__(m_pawn.m_Ladder, none), __NFUN_114__(m_pawn.OnLadder, none)))
		{
			ExtractMissingLadderInformation();
		}
		// End:0x8A
		if(m_pawn.m_Ladder.m_bIsTopOfLadder)
		{
			Pawn.__NFUN_299__(__NFUN_316__(Pawn.OnLadder.LadderList.Rotation, rot(0, 32768, 0)));			
		}
		else
		{
			Pawn.__NFUN_299__(Pawn.OnLadder.LadderList.Rotation);
		}
		// End:0xC9
		if(m_bSkipBeginState)
		{
			m_bSkipBeginState = false;
			return;
		}
		// End:0xE3
		if(__NFUN_119__(m_TeamManager, none))
		{
			m_TeamManager.TeamLeaderIsClimbingLadder();
		}
		m_bHideReticule = true;
		m_pawn.m_bIsClimbingLadder = true;
		Pawn.LockRootMotion(1, true);
		// End:0x137
		if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
		{
			m_pawn.SetNextPendingAction(5);
		}
		m_pawn.PlayStartClimbing();
		// End:0x1A0
		if(m_pawn.m_Ladder.m_bIsTopOfLadder)
		{
			Pawn.__NFUN_299__(__NFUN_316__(Pawn.OnLadder.LadderList.Rotation, rot(0, 32768, 0)));			
		}
		else
		{
			Pawn.__NFUN_299__(Pawn.OnLadder.LadderList.Rotation);
		}
		return;
	}

    // overwritten: don't reset should crouch
	function EndState()
	{
		// End:0xB7
		if(__NFUN_119__(m_pawn.OnLadder, none))
		{
			// End:0x73
			if(__NFUN_203__(Pawn.Rotation, Pawn.OnLadder.LadderList.Rotation))
			{
				Pawn.__NFUN_299__(Pawn.OnLadder.LadderList.Rotation);
			}
			// End:0xB7
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_154__(iChannel, 0))
		{
			// End:0x35
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(6);
			}
			m_pawn.PlayPostStartLadder();
			Pawn.__NFUN_299__(Pawn.OnLadder.LadderList.Rotation);
			__NFUN_299__(Pawn.OnLadder.LadderList.Rotation);
			__NFUN_113__('PlayerClimbing');
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
		if(__NFUN_130__(__NFUN_129__(m_bLockWeaponActions), __NFUN_119__(m_pawn.EngineWeapon, none)))
		{
			m_pawn.EngineWeapon.__NFUN_113__('PutWeaponDown');
		}
		// End:0xC4
		if(__NFUN_254__(WindowConsole(Player.Console).ConsoleState, 'UWindow'))
		{
			// End:0x9A
			if(__NFUN_150__(int(Role), int(ROLE_Authority)))
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
		if(__NFUN_132__(m_pawn.m_Ladder.m_bIsTopOfLadder, __NFUN_129__(m_pawn.EndOfLadderSlide())))
		{
			Pawn.LockRootMotion(1, true);
			// End:0x7F
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
			{
				m_pawn.SetNextPendingAction(7);
			}
			m_pawn.PlayEndClimbing();			
		}
		else
		{
			// End:0xBB
			if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(Class'Engine.Actor'.static.__NFUN_1524__().IsMissionPack())
		{
			// End:0xEF
			if(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_pawn.m_bIsSurrended), __NFUN_119__(m_pawn.EngineWeapon, none)), __NFUN_129__(__NFUN_130__(Pawn.EngineWeapon.__NFUN_303__('R6GrenadeWeapon'), __NFUN_129__(Pawn.EngineWeapon.HasAmmo())))))
			{
				Pawn.EngineWeapon.__NFUN_113__('BringWeaponUp');
				// End:0xEF
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
				{
					m_pawn.SetNextPendingAction(28);
				}
			}			
		}
		else
		{
			// End:0x189
			if(__NFUN_130__(__NFUN_119__(m_pawn.EngineWeapon, none), __NFUN_129__(__NFUN_130__(Pawn.EngineWeapon.__NFUN_303__('R6GrenadeWeapon'), __NFUN_129__(Pawn.EngineWeapon.HasAmmo())))))
			{
				Pawn.EngineWeapon.__NFUN_113__('BringWeaponUp');
				// End:0x189
				if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
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
		if(__NFUN_132__(__NFUN_154__(iChannel, 0), __NFUN_154__(iChannel, m_pawn.1)))
		{
			// End:0x134
			if(__NFUN_154__(iChannel, 0))
			{
				// End:0xB5
				if(m_pawn.m_Ladder.m_bIsTopOfLadder)
				{
					// End:0x71
					if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
					{
						m_pawn.SetNextPendingAction(8);
					}
					m_pawn.PlayPostEndLadder();
					Pawn.__NFUN_267__(__NFUN_215__(Pawn.Location, __NFUN_213__(float(20), Vector(Pawn.Rotation))));					
				}
				else
				{
					// End:0x134
					if(__NFUN_129__(m_pawn.m_bSlideEnd))
					{
						// End:0xF3
						if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
						{
							m_pawn.SetNextPendingAction(8);
						}
						m_pawn.PlayPostEndLadder();
						Pawn.__NFUN_267__(__NFUN_215__(Pawn.Location, __NFUN_213__(float(25), Vector(Pawn.Rotation))));
					}
				}
			}
			EndClimbingSetUp();
			__NFUN_113__('PlayerWalking');
		}
		return;
	}

	function EndClimbingSetUp()
	{
		Pawn.__NFUN_3970__(1);
		Pawn.OnLadder = none;
		m_pawn.m_bIsClimbingLadder = false;
		m_pawn.m_bPostureTransition = false;
		// End:0x5F
		if(__NFUN_119__(m_TeamManager, none))
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
