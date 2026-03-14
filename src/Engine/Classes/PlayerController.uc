//=============================================================================
// PlayerController - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// PlayerController
//
// PlayerControllers are used by human players to control pawns.
//
// This is a built-in Unreal class and it shouldn't be modified.
// for the change in Possess().
//=============================================================================
class PlayerController extends Controller
    native
    nativereplication
    config(User)
    notplaceable;

const K_GlobalID_size = 16;

enum eCameraMode
{
	CAMERA_FirstPerson,             // 0
	CAMERA_3rdPersonFixed,          // 1
	CAMERA_3rdPersonFree,           // 2
	CAMERA_Ghost                    // 3
};

struct PlayerPrefInfo
{
	var string m_CharacterName;
	var string m_ArmorName;
	var string m_WeaponName1;
	var string m_WeaponName2;
	var string m_WeaponGadgetName1;
	var string m_WeaponGadgetName2;
	var string m_BulletType1;
	var string m_BulletType2;
	var string m_GadgetName1;
	var string m_GadgetName2;
};

// NEW IN 1.60
var input byte bStrafe;
// NEW IN 1.60
var input byte bSnapLevel;
// NEW IN 1.60
var input byte bLook;
// NEW IN 1.60
var input byte bFreeLook;
// NEW IN 1.60
var input byte bTurn180;
// NEW IN 1.60
var input byte bTurnToNearest;
// NEW IN 1.60
var input byte bXAxis;
// NEW IN 1.60
var input byte bYAxis;
var Actor.EDoubleClickDir DoubleClickDir;  // direction of movement key double click (for special moves)
var Actor.EMusicTransition Transition;
var Object.ePlayerTeamSelection m_TeamSelection;
// NEW IN 1.60
var PlayerController.eCameraMode m_eCameraMode;
// Camera info.
var int ShowFlags;
var int Misc1;
// NEW IN 1.60
var int Misc2;
var int RendMap;
var int WeaponUpdate;
var config int EnemyTurnSpeed;
var int GroundPitch;
// Demo recording view rotation
var int DemoViewPitch;
var int DemoViewYaw;
var int m_iChangeNameLastTime;  // last time change name was requested
//#ifdef R6PUNKBUSTER
//__WITH_PB__
var int iPBEnabled;
// player input control
var globalconfig bool bLookUpStairs;  // look up/down stairs (player)
var globalconfig bool bSnapToLevel;  // Snap to level eyeheight when not mouselooking
var globalconfig bool bAlwaysMouseLook;
var globalconfig bool bKeyboardLook;  // no snapping when true
var bool bCenterView;
// Player control flags
var bool bBehindView;  // Outside-the-player view.
var bool bFrozen;  // set when game ends or player dies to temporarily prevent player from restarting (until cleared by timer)
var bool bPressedJump;
var bool bUpdatePosition;
var bool bIsTyping;
var bool bFixedCamera;  // used to fix camera in position (to view animations)
var bool bJumpStatus;  // used in net games
var bool bUpdating;
var bool bZooming;
var bool bOnlySpectator;  // This controller is not allowed to possess pawns
//#ifdef R6CODE
var bool m_bReadyToEnterSpectatorMode;
//#ifndef R6CODE
//var globalconfig bool bAlwaysLevel;
//#endif // #ifndef R6CODE
var bool bSetTurnRot;
var bool bCheatFlying;  // instantly stop in flying mode
var bool bFreeCamera;  // free camera when in behindview mode (for checking out player models and animations)
var bool bZeroRoll;
var bool bCameraPositionLocked;
//#ifndef R6CODE
//var globalconfig bool ngSecretSet;
//#endif // #ifndef R6CODE
var bool ReceivedSecretChecksum;
//#ifdef R6CODE
var bool m_bInitFirstTick;
var bool m_PreLogOut;  // this controller is about to be destroyed
//R6CODE
var bool m_bRadarActive;
var bool m_bHeatVisionActive;
var bool m_bLoadSoundGun;
var bool m_bInstructionTouch;  // Use in the traning to start the text.
var float AimingHelp;
var float WaitDelay;  // Delay time until can restart
// NEW IN 1.60
var input float aBaseX;
// NEW IN 1.60
var input float aBaseY;
// NEW IN 1.60
var input float aBaseZ;
// NEW IN 1.60
var input float aMouseX;
// NEW IN 1.60
var input float aMouseY;
// NEW IN 1.60
var input float aForward;
// NEW IN 1.60
var input float aTurn;
// NEW IN 1.60
var input float aStrafe;
// NEW IN 1.60
var input float aUp;
// NEW IN 1.60
var input float aLookUp;
var float OrthoZoom;  // Orthogonal/map view zoom factor.
var float CameraDist;  // multiplier for behindview camera dist
//#ifdef R6CODE
var float DesiredFOV;
var float DefaultFOV;
//#else
//var globalconfig float DesiredFOV;
//var globalconfig float DefaultFOV;
//#endif R6CODE
var float ZoomLevel;
var float DesiredFlashScale;
// NEW IN 1.60
var float ConstantGlowScale;
// NEW IN 1.60
var float InstantFlash;
var float TargetEyeHeight;
var float LastPlaySound;
var float CurrentTimeStamp;
// NEW IN 1.60
var float LastUpdateTime;
// NEW IN 1.60
var float ServerTimeStamp;
// NEW IN 1.60
var float TimeMargin;
// NEW IN 1.60
var float ClientUpdateTime;
var globalconfig float MaxTimeMargin;
var float ProgressTimeOut;
// view shaking (affects roll, and offsets camera position)
var float MaxShakeRoll;  // max magnitude to roll camera
var float ShakeRollRate;  // rate to change roll
var float ShakeRollTime;  // how long to roll.  if value is < 1.0, then MaxShakeOffset gets damped by this, else if > 1 then its the number of times to repeat undamped
var globalconfig float NetClientMaxTickRate;
var float m_fNextUpdateTime;
var float m_fLoginTime;
// Player info.
var const Player Player;
var const Actor ViewTarget;
var HUD myHUD;  // heads up display info
// Move buffering for network games.  Clients save their un-acknowledged moves in order to replay them
// when they get position updates from the server.
var SavedMove SavedMoves;  // buffered moves pending position updates
var SavedMove FreeMoves;  // freed moves, available for buffering
var SavedMove PendingMove;
// ReplicationInfo
var GameReplicationInfo GameReplicationInfo;
var Pawn TurnTarget;
// Components ( inner classes )
//R6CODE
var CheatManager CheatManager;  // Object within playercontroller that manages "cheat" commands
var R6RainbowStartInfo m_PlayerStartInfo;
var Actor m_SaveOldClientBase;
var Class<LocalMessage> LocalMessageClass;
//var private CheatManager	CheatManager;	// Object within playercontroller that manages "cheat" commands
var Class<CheatManager> CheatClass;  // class of my CheatManager
var Class<PlayerInput> InputClass;  // class of my PlayerInput
// Screen flashes
var Vector FlashScale;
// NEW IN 1.60
var Vector FlashFog;
var Vector DesiredFlashFog;
// NEW IN 1.60
var Vector ConstantGlowFog;
// NEW IN 1.60
var Vector InstantFog;
// Remote Pawn ViewTargets
var Rotator TargetViewRotation;
var Vector TargetWeaponViewOffset;
var Color ProgressColor[4];
var Vector MaxShakeOffset;  // max magnitude to offset camera position
var Vector ShakeOffsetRate;
var Vector ShakeOffset;  // current magnitude to offset camera from shake
var Vector ShakeOffsetTime;
var Rotator TurnRot180;
var Vector OldFloor;  // used by PlayerSpider mode - floor for which old rotation was based;
var PlayerVerCDKeyStatus m_stPlayerVerCDKeyStatus;
var PlayerVerCDKeyStatus m_stPlayerVerModCDKeyStatus;
var PlayerPrefInfo m_PlayerPrefs;
// Music info.
var string Song;
// Progess Indicator - used by the engine to provide status messages (HUD is responsible for displaying these).
var string ProgressMessage[4];
// Localized strings
var localized string QuickSaveString;
var localized string NoPauseMessage;
var localized string ViewingFrom;
var localized string OwnCamera;
// ngWorldStats Logging
var private globalconfig string ngWorldSecret;
var string m_szGlobalID;
var string m_szIpAddr;  // IP address withou port number used to identfy players in beacon code
var private transient PlayerInput PlayerInput;  // Object within playercontroller that manages player input.
var transient array<CameraEffect> CameraEffects;  // A stack of camera effects.

replication
{
	// Pos:0x0CB
	unreliable if(__NFUN_130__(__NFUN_154__(int(Role), int(ROLE_Authority)), __NFUN_129__(bDemoRecording)))
		ClientPlaySound, ClientStopSound;

	// Pos:0x0FF
	unreliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		ClientAdjustPosition, ClientFlash, 
		ClientInstantFlash, ClientSetFlash, 
		ClientShake, LongClientAdjustPosition, 
		SetFOVAngle, ShortClientAdjustPosition, 
		VeryShortClientAdjustPosition;

	// Pos:0x10C
	unreliable if(__NFUN_130__(__NFUN_132__(__NFUN_129__(bDemoRecording), __NFUN_130__(bClientDemoRecording, bClientDemoNetFunc)), __NFUN_154__(int(Role), int(ROLE_Authority))))
		ClientHearSound;

	// Pos:0x13C
	unreliable if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		Say, ServerMove, 
		ServerTKPopUpDone, ServerViewNextPlayer, 
		ServerViewSelf, ShortServerMove, 
		ShorterServerMove, TeamSay;

	// Pos:0x000
	reliable if(__NFUN_130__(__NFUN_130__(bNetDirty, bNetOwner), __NFUN_154__(int(Role), int(ROLE_Authority))))
		GameReplicationInfo, ViewTarget, 
		bOnlySpectator, m_TeamSelection, 
		m_eCameraMode;

	// Pos:0x023
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_130__(bNetOwner, __NFUN_154__(int(Role), int(ROLE_Authority))), __NFUN_119__(ViewTarget, Pawn)), __NFUN_119__(Pawn(ViewTarget), none)))
		TargetEyeHeight, TargetViewRotation, 
		TargetWeaponViewOffset;

	// Pos:0x05E
	reliable if(__NFUN_130__(bDemoRecording, __NFUN_154__(int(Role), int(ROLE_Authority))))
		DemoViewPitch, DemoViewYaw;

	// Pos:0x076
	reliable if(__NFUN_130__(bNetDirty, __NFUN_154__(int(Role), int(ROLE_Authority))))
		m_bRadarActive;

	// Pos:0x08E
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		ClientAdjustBase, ClientAdjustGlow, 
		ClientCantRequestChangeNameYet, ClientChangeName, 
		ClientErrorMessageLocalized, ClientGotoState, 
		ClientPBKickedOutMessage, ClientReStart, 
		ClientReliablePlaySound, ClientReplicateSkins, 
		ClientSetBehindView, ClientSetFixedCamera, 
		ClientSetHUD, ClientSetMusic, 
		EndZoom, GivePawn, 
		ResettingLevel, SetProgressTime, 
		StartZoom, StopZoom, 
		ToggleZoom;

	// Pos:0x09B
	reliable if(__NFUN_130__(__NFUN_154__(int(Role), int(ROLE_Authority)), __NFUN_132__(__NFUN_129__(bDemoRecording), __NFUN_130__(bClientDemoRecording, bClientDemoNetFunc))))
		ClientMessage, ReceiveLocalizedMessage, 
		TeamMessage;

	// Pos:0x0E5
	reliable if(__NFUN_130__(__NFUN_154__(int(Role), int(ROLE_Authority)), __NFUN_129__(bDemoRecording)))
		ClientTravel;

	// Pos:0x149
	reliable if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		AskForPawn, ChangeName, 
		Pause, ServerChangeName, 
		ServerPlayerPref, ServerReadyToLoadWeaponSound, 
		ServerRestartGame, ServerSetPlayerReadyStatus, 
		ServerTeamRequested, ServerToggleHeatVision, 
		ServerToggleRadar, SetPause, 
		Suicide, Typing;
}

//#ifdef R6CODE clauzon those functions are called to properly  initialize the 
//member variables for matinee.
function InitMatineeCamera()
{
	return;
}

function EndMatineeCamera()
{
	return;
}

// R6CODE
simulated function ResettingLevel(int iNbOfRestart)
{
	return;
}

function ServerSetPlayerReadyStatus(bool _bPlayerReady)
{
	return;
}

function ServerTKPopUpDone(bool _bApplyTeamKillerPenalty)
{
	return;
}

function ServerTeamRequested(Object.ePlayerTeamSelection eTeamSelected, optional bool bForceSelection)
{
	return;
}

// Export UPlayerController::execGetPBConnectStatus(FFrame&, void* const)
//#ifdef R6PUNKBUSTER
//__WITH_PB__
native(1317) final function string GetPBConnectStatus();

// Export UPlayerController::execIsPBEnabled(FFrame&, void* const)
native(1318) static final function int IsPBEnabled();

// Export UPlayerController::execGetPlayerNetworkAddress(FFrame&, void* const)
native final function string GetPlayerNetworkAddress();

// Export UPlayerController::execSpecialDestroy(FFrame&, void* const)
native(1282) final function SpecialDestroy();

// Export UPlayerController::execConsoleCommand(FFrame&, void* const)
native function string ConsoleCommand(string Command);

// Export UPlayerController::execGetEntryLevel(FFrame&, void* const)
native final function LevelInfo GetEntryLevel();

// Export UPlayerController::execResetKeyboard(FFrame&, void* const)
native(544) final function ResetKeyboard();

// Export UPlayerController::execSetViewTarget(FFrame&, void* const)
native final function SetViewTarget(Actor NewViewTarget);

// Export UPlayerController::execClientTravel(FFrame&, void* const)
    native event ClientTravel(string URL, Actor.ETravelType TravelType, bool bItems);

// Export UPlayerController::execUpdateURL(FFrame&, void* const)
native(546) final function UpdateURL(string NewOption, string NewValue, bool bSaveDefault);

// Export UPlayerController::execGetDefaultURL(FFrame&, void* const)
native final function string GetDefaultURL(string Option);

// Export UPlayerController::execCopyToClipboard(FFrame&, void* const)
// Execute a console command in the context of this player, then forward to Actor.ConsoleCommand.
native function CopyToClipboard(string Text);

// Export UPlayerController::execPasteFromClipboard(FFrame&, void* const)
native function string PasteFromClipboard();

simulated event bool IsPlayerPassiveSpectator()
{
	return;
}

// Export UPlayerController::execFindStairRotation(FFrame&, void* const)
native(524) final function int FindStairRotation(float DeltaTime);

//#ifdef R6CODE 
function ServerReadyToLoadWeaponSound()
{
	return;
}

function ServerPlayerPref(PlayerPrefInfo newPlayerPrefs)
{
	return;
}

event SetMatchResult(string _UserUbiID, int iField, int iValue)
{
	return;
}

event string GetLocalPlayerIp()
{
	return;
}

// Export UPlayerController::execGetKey(FFrame&, void* const)
native(2706) final function byte GetKey(string szActionKey, optional bool bPlanningInput);

// Export UPlayerController::execGetActionKey(FFrame&, void* const)
native(2707) final function string GetActionKey(byte Key, optional bool bPlanningInput);

// Export UPlayerController::execGetEnumName(FFrame&, void* const)
native(2708) final function string GetEnumName(byte Key, optional bool bPlanningInput);

// Export UPlayerController::execChangeInputSet(FFrame&, void* const)
native(2709) final function ChangeInputSet(byte iInputSet);

// Export UPlayerController::execSetKey(FFrame&, void* const)
native(2710) final function SetKey(string szKeyAndAction);

// Export UPlayerController::execSetSoundOptions(FFrame&, void* const)
native(2713) final function SetSoundOptions();

// Export UPlayerController::execChangeVolumeTypeLinear(FFrame&, void* const)
native(2714) final function ChangeVolumeTypeLinear(Actor.ESoundSlot eVolumeLine, float fVolumeLinear);

// Export UPlayerController::execPB_CanPlayerSpawn(FFrame&, void* const)
//#ifdef R6PUNKBUSTER
native(1320) final function bool PB_CanPlayerSpawn();

// Export UPlayerController::execClientHearSound(FFrame&, void* const)
    native event ClientHearSound(Actor Actor, Sound S, Actor.ESoundSlot ID);

// r6code
function bool ShouldDisplayIncomingMessages()
{
	return true;
	return;
}

// r6code: give access to the private var PlayerInput
simulated function PlayerInput getPlayerInput()
{
	return PlayerInput;
	return;
}

event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultHUD();
	// End:0x35
	if(__NFUN_123__(Level.LevelEnterText, ""))
	{
		ClientMessage(Level.LevelEnterText);
	}
	DesiredFOV = DefaultFOV;
	SetViewTarget(self);
	// End:0x66
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		AddCheats();
	}
	return;
}

function PendingStasis()
{
	bStasis = true;
	Pawn = none;
	__NFUN_113__('Scripting');
	return;
}

function AddCheats()
{
	// End:0x14
	if(Level.bKNoInit)
	{
		return;
	}
	// End:0x2E
	if(__NFUN_114__(CheatManager, none))
	{
		CheatManager = new CheatClass;
	}
	return;
}

function SpawnDefaultHUD()
{
	myHUD = __NFUN_278__(Class'Engine.HUD', self);
	return;
}

function Reset()
{
	PawnDied();
	super.Reset();
	SetViewTarget(self);
	bBehindView = false;
	WaitDelay = __NFUN_174__(Level.TimeSeconds, float(2));
	__NFUN_113__('BaseSpectating');
	return;
}

//R6CODE
event InitMultiPlayerOptions()
{
	return;
}

event InitInputSystem()
{
	PlayerInput = new InputClass;
	UpdateOptions();
	return;
}

function UpdateOptions()
{
	PlayerInput.UpdateMouseOptions();
	return;
}

function ClientGotoState(name NewState, name NewLabel)
{
	__NFUN_113__(NewState, NewLabel);
	return;
}

function AskForPawn()
{
	// End:0x19
	if(__NFUN_119__(Pawn, none))
	{
		GivePawn(Pawn);		
	}
	else
	{
		// End:0x37
		if(__NFUN_281__('GameEnded'))
		{
			ClientGotoState('GameEnded', 'Begin');			
		}
		else
		{
			// End:0x50
			if(__NFUN_281__('Dead'))
			{
				bFrozen = false;
				ServerReStartPlayer();
			}
		}
	}
	return;
}

function GivePawn(Pawn NewPawn)
{
	// End:0x0D
	if(__NFUN_114__(NewPawn, none))
	{
		return;
	}
	Pawn = NewPawn;
	NewPawn.Controller = self;
	ClientReStart();
	return;
}

function int GetFacingDirection()
{
	local Vector X, Y, Z, Dir;

	__NFUN_229__(Pawn.Rotation, X, Y, Z);
	Dir = __NFUN_226__(Pawn.Acceleration);
	// End:0x6D
	if(__NFUN_177__(__NFUN_219__(Y, Dir), float(0)))
	{
		return int(__NFUN_174__(float(49152), __NFUN_171__(float(16384), __NFUN_219__(X, Dir))));		
	}
	else
	{
		return int(__NFUN_175__(float(16384), __NFUN_171__(float(16384), __NFUN_219__(X, Dir))));
	}
	return;
}

// Possess a pawn
function Possess(Pawn aPawn)
{
	// End:0x0B
	if(bOnlySpectator)
	{
		return;
	}
	__NFUN_299__(aPawn.Rotation);
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	Pawn.bStasis = false;
	// End:0x72
	if(__NFUN_119__(PlayerReplicationInfo, none))
	{
		PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
	}
	Restart();
	return;
}

// unpossessed a pawn (not because pawn was killed)
function UnPossess()
{
	// End:0x52
	if(__NFUN_119__(Pawn, none))
	{
		__NFUN_267__(Pawn.Location);
		Pawn.RemoteRole = ROLE_SimulatedProxy;
		Pawn.UnPossessed();
		// End:0x52
		if(__NFUN_114__(ViewTarget, Pawn))
		{
			SetViewTarget(self);
		}
	}
	Pawn.Controller = none;
	Pawn = none;
	__NFUN_113__('Spectating');
	return;
}

//#ifdef R6CODE
function bool GetGender()
{
	return;
}

// unpossessed a pawn (because pawn was killed)
function PawnDied()
{
	EndZoom();
	// End:0x22
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.RemoteRole = ROLE_SimulatedProxy;
	}
	// End:0x39
	if(__NFUN_114__(ViewTarget, Pawn))
	{
		bBehindView = true;
	}
	super.PawnDied();
	return;
}

function ClientSetHUD(Class<HUD> newHUDType, Class<ScoreBoard> newScoringType)
{
	local HUD NewHUD, OldHUD;

	// End:0x14
	if(Level.bKNoInit)
	{
		return;
	}
	// End:0x8D
	if(__NFUN_132__(__NFUN_114__(myHUD, none), __NFUN_130__(__NFUN_119__(newHUDType, none), __NFUN_119__(newHUDType, myHUD.Class))))
	{
		NewHUD = __NFUN_278__(newHUDType, self);
		// End:0x8D
		if(__NFUN_119__(NewHUD, none))
		{
			OldHUD = myHUD;
			myHUD = NewHUD;
			// End:0x8D
			if(__NFUN_119__(OldHUD, none))
			{
				OldHUD.__NFUN_279__();
			}
		}
	}
	return;
}

function ViewFlash(float DeltaTime)
{
	local Vector goalFog;
	local float goalscale, Delta;

	Delta = __NFUN_244__(0.1000000, DeltaTime);
	goalscale = __NFUN_174__(__NFUN_174__(1.0000000, DesiredFlashScale), ConstantGlowScale);
	goalFog = __NFUN_215__(DesiredFlashFog, ConstantGlowFog);
	// End:0x89
	if(__NFUN_119__(Pawn, none))
	{
		__NFUN_184__(goalscale, Pawn.HeadVolume.ViewFlash.X);
		__NFUN_223__(goalFog, Pawn.HeadVolume.ViewFog);
	}
	__NFUN_185__(DesiredFlashScale, __NFUN_171__(__NFUN_171__(DesiredFlashScale, float(2)), Delta));
	__NFUN_224__(DesiredFlashFog, __NFUN_212__(__NFUN_212__(DesiredFlashFog, float(2)), Delta));
	__NFUN_184__(FlashScale.X, __NFUN_171__(__NFUN_171__(__NFUN_174__(__NFUN_175__(goalscale, FlashScale.X), InstantFlash), float(10)), Delta));
	__NFUN_223__(FlashFog, __NFUN_212__(__NFUN_212__(__NFUN_215__(__NFUN_216__(goalFog, FlashFog), InstantFog), float(10)), Delta));
	InstantFlash = 0.0000000;
	InstantFog = vect(0.0000000, 0.0000000, 0.0000000);
	// End:0x155
	if(__NFUN_177__(FlashScale.X, 0.9810000))
	{
		FlashScale.X = 1.0000000;
	}
	FlashScale = __NFUN_213__(FlashScale.X, vect(1.0000000, 1.0000000, 1.0000000));
	// End:0x198
	if(__NFUN_176__(FlashFog.X, 0.0190000))
	{
		FlashFog.X = 0.0000000;
	}
	// End:0x1BC
	if(__NFUN_176__(FlashFog.Y, 0.0190000))
	{
		FlashFog.Y = 0.0000000;
	}
	// End:0x1E0
	if(__NFUN_176__(FlashFog.Z, 0.0190000))
	{
		FlashFog.Z = 0.0000000;
	}
	return;
}

event ReceiveLocalizedMessage(Class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	Message.static.ClientReceive(self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	return;
}

//R6CODE+
function ClientErrorMessageLocalized(coerce string szKeyID)
{
	myHUD.AddTextMessage(Localize("Errors", szKeyID, "R6Engine"), Class'Engine.LocalMessage');
	return;
}

event ClientMessage(coerce string S, optional name type)
{
	// End:0x1A
	if(__NFUN_254__(type, 'None'))
	{
		type = 'Event';
	}
	TeamMessage(PlayerReplicationInfo, S, type);
	return;
}

event TeamMessage(PlayerReplicationInfo PRI, coerce string S, name type)
{
	// End:0x41
	if(__NFUN_132__(__NFUN_254__(type, 'Say'), __NFUN_254__(type, 'TeamSay')))
	{
		S = __NFUN_112__(__NFUN_112__(PRI.PlayerName, ": "), S);
	}
	Player.InteractionMaster.Process_Message(S, 6.0000000, Player.LocalInteractions);
	return;
}

simulated function PlayBeepSound()
{
	return;
}

//R6CODE
simulated function ClientPlaySound(Sound ASound, Actor.ESoundSlot eSlot)
{
	// End:0x24
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.__NFUN_264__(ASound, eSlot);		
	}
	else
	{
		ViewTarget.__NFUN_264__(ASound, eSlot);
	}
	return;
}

simulated function ClientStopSound(Sound ASound)
{
	// End:0x1F
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.__NFUN_2725__(ASound);		
	}
	else
	{
		ViewTarget.__NFUN_2725__(ASound);
	}
	return;
}

simulated function ClientReliablePlaySound(Sound ASound, optional bool bVolumeControl)
{
	ClientPlaySound(ASound, 3);
	return;
}

simulated event Destroyed()
{
	local SavedMove Next;

	// End:0x10
	if(bOnlySpectator)
	{
		Pawn = none;
	}
	// End:0x49
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.Health = 0;
		Pawn.Died(self, Pawn.Location);
	}
	// End:0x60
	if(__NFUN_119__(CheatManager, none))
	{
		CheatManager.__NFUN_1850__();
	}
	CheatManager = none;
	// End:0x7E
	if(__NFUN_119__(PlayerInput, none))
	{
		PlayerInput.__NFUN_1850__();
	}
	PlayerInput = none;
	super.Destroyed();
	myHUD.__NFUN_279__();
	myHUD = none;
	J0x9E:

	// End:0xD7 [Loop If]
	if(__NFUN_119__(FreeMoves, none))
	{
		Next = FreeMoves.NextMove;
		FreeMoves.__NFUN_279__();
		FreeMoves = Next;
		// [Loop Continue]
		goto J0x9E;
	}
	J0xD7:

	// End:0x110 [Loop If]
	if(__NFUN_119__(SavedMoves, none))
	{
		Next = SavedMoves.NextMove;
		SavedMoves.__NFUN_279__();
		SavedMoves = Next;
		// [Loop Continue]
		goto J0xD7;
	}
	return;
}

function ClientSetMusic(string NewSong, Actor.EMusicTransition NewTransition)
{
	Song = NewSong;
	Transition = NewTransition;
	return;
}

function ToggleZoom()
{
	// End:0x18
	if(__NFUN_181__(DefaultFOV, DesiredFOV))
	{
		EndZoom();		
	}
	else
	{
		StartZoom();
	}
	return;
}

function StartZoom()
{
	ZoomLevel = 0.0000000;
	bZooming = true;
	return;
}

function StopZoom()
{
	bZooming = false;
	return;
}

function EndZoom()
{
	bZooming = false;
	DesiredFOV = DefaultFOV;
	return;
}

function FixFOV()
{
	FovAngle = default.DefaultFOV;
	DesiredFOV = default.DefaultFOV;
	DefaultFOV = default.DefaultFOV;
	return;
}

function SetFOV(float NewFOV)
{
	DesiredFOV = NewFOV;
	FovAngle = NewFOV;
	return;
}

function ResetFOV()
{
	DesiredFOV = DefaultFOV;
	FovAngle = DefaultFOV;
	return;
}

exec function SetSensitivity(float f)
{
	PlayerInput.UpdateSensitivity(f);
	return;
}

// Send a message to all players.
exec function Say(string Msg)
{
	// End:0x29
	if(__NFUN_132__(__NFUN_122__(Msg, ""), __NFUN_154__(int(Level.NetMode), int(NM_Standalone))))
	{
		return;
	}
	Level.Game.Broadcast(self, Msg, 'Say');
	return;
}

exec function TeamSay(string Msg)
{
	// End:0x29
	if(__NFUN_132__(__NFUN_122__(Msg, ""), __NFUN_154__(int(Level.NetMode), int(NM_Standalone))))
	{
		return;
	}
	Level.Game.BroadcastTeam(self, Msg, 'TeamSay');
	return;
}

event PreClientTravel()
{
	return;
}

function ClientSetFixedCamera(bool B)
{
	bFixedCamera = B;
	return;
}

function ClientSetBehindView(bool B)
{
	bBehindView = B;
	return;
}

function ClientReplicateSkins(Material Skin1, optional Material Skin2, optional Material Skin3, optional Material Skin4)
{
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Getting ", string(Skin1)), ", "), string(Skin2)), ", "), string(Skin3)), ", "), string(Skin4)));
	return;
	return;
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	local VoicePack V;

	// End:0x39
	if(__NFUN_132__(__NFUN_132__(__NFUN_114__(Sender, none), __NFUN_114__(Sender.VoiceType, none)), __NFUN_114__(Player.Console, none)))
	{
		return;
	}
	V = __NFUN_278__(Sender.VoiceType, self);
	// End:0x7F
	if(__NFUN_119__(V, none))
	{
		V.ClientInitialize(Sender, Recipient, messagetype, messageID);
	}
	return;
}

function ForceDeathUpdate()
{
	LastUpdateTime = __NFUN_175__(Level.TimeSeconds, float(10));
	return;
}

// NEW IN 1.60
function ShorterServerMove(float TimeStamp, Vector ClientLoc, int View, int iNewRotOffset)
{
	ServerMove(TimeStamp, vect(0.0000000, 0.0000000, 0.0000000), ClientLoc, false, false, false, View, iNewRotOffset);
	return;
}

// NEW IN 1.60
function ShortServerMove(float TimeStamp, Vector ClientLoc, bool NewbRun, bool NewbDuck, bool NewbCrawl, int View, int iNewRotOffset)
{
	ServerMove(TimeStamp, vect(0.0000000, 0.0000000, 0.0000000), ClientLoc, NewbRun, NewbDuck, NewbCrawl, View, iNewRotOffset);
	return;
}

function ServerMove(float TimeStamp, Vector InAccel, Vector ClientLoc, bool NewbRun, bool NewbDuck, bool NewbCrawl, int View, int iNewRotOffset, optional byte OldTimeDelta, optional int OldAccel)
{
	local float DeltaTime, clientErr, OldTimeStamp;
	local Rotator DeltaRot, Rot, ViewRot;
	local Vector Accel, LocDiff, ClientVel, ClientFloor;
	local Rotator rNewRotOffset;
	local int maxPitch, ViewPitch, ViewYaw;
	local bool OldbCrawl, OldbRun, OldbDuck;
	local Actor.EDoubleClickDir OldDoubleClickMove;
	local Actor ClientBase;
	local Actor.EPhysics ClientPhysics;

	// End:0x11
	if(__NFUN_179__(CurrentTimeStamp, TimeStamp))
	{
		return;
	}
	// End:0x1DB
	if(__NFUN_155__(int(OldTimeDelta), 0))
	{
		OldTimeStamp = __NFUN_175__(__NFUN_175__(TimeStamp, __NFUN_172__(float(OldTimeDelta), float(500))), 0.0010000);
		// End:0x1DB
		if(__NFUN_176__(CurrentTimeStamp, __NFUN_175__(OldTimeStamp, 0.0010000)))
		{
			Accel.X = float(__NFUN_196__(OldAccel, 23));
			// End:0xA3
			if(__NFUN_177__(Accel.X, float(127)))
			{
				Accel.X = __NFUN_171__(-1.0000000, __NFUN_175__(Accel.X, float(128)));
			}
			Accel.Y = float(__NFUN_156__(int(float(__NFUN_196__(OldAccel, 15))), 255));
			// End:0xF6
			if(__NFUN_177__(Accel.Y, float(127)))
			{
				Accel.Y = __NFUN_171__(-1.0000000, __NFUN_175__(Accel.Y, float(128)));
			}
			Accel.Z = float(__NFUN_156__(int(float(__NFUN_196__(OldAccel, 7))), 255));
			// End:0x149
			if(__NFUN_177__(Accel.Z, float(127)))
			{
				Accel.Z = __NFUN_171__(-1.0000000, __NFUN_175__(Accel.Z, float(128)));
			}
			__NFUN_221__(Accel, float(20));
			OldbRun = __NFUN_155__(__NFUN_156__(OldAccel, 64), 0);
			OldbDuck = __NFUN_155__(__NFUN_156__(OldAccel, 32), 0);
			OldbCrawl = __NFUN_155__(__NFUN_156__(OldAccel, 16), 0);
			OldDoubleClickMove = 0;
			MoveAutonomous(__NFUN_175__(OldTimeStamp, CurrentTimeStamp), OldbRun, OldbDuck, OldbCrawl, OldDoubleClickMove, Accel, rot(0, 0, 0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}
	ViewPitch = __NFUN_145__(View, 32768);
	ViewYaw = __NFUN_144__(2, __NFUN_147__(View, __NFUN_144__(32768, ViewPitch)));
	__NFUN_159__(ViewPitch, float(2));
	Accel = __NFUN_214__(InAccel, float(10));
	DeltaTime = __NFUN_175__(TimeStamp, CurrentTimeStamp);
	// End:0x2BD
	if(__NFUN_177__(ServerTimeStamp, float(0)))
	{
		__NFUN_184__(TimeMargin, __NFUN_175__(DeltaTime, __NFUN_171__(1.0100000, __NFUN_175__(Level.TimeSeconds, ServerTimeStamp))));
		// End:0x2BD
		if(__NFUN_177__(TimeMargin, MaxTimeMargin))
		{
			__NFUN_185__(TimeMargin, DeltaTime);
			// End:0x2A7
			if(__NFUN_176__(TimeMargin, 0.5000000))
			{
				MaxTimeMargin = default.MaxTimeMargin;				
			}
			else
			{
				MaxTimeMargin = 0.5000000;
			}
			DeltaTime = 0.0000000;
		}
	}
	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	ViewRot.Pitch = ViewPitch;
	ViewRot.Yaw = ViewYaw;
	ViewRot.Roll = 0;
	__NFUN_299__(ViewRot);
	// End:0x48E
	if(__NFUN_119__(Pawn, none))
	{
		rNewRotOffset.Pitch = __NFUN_144__(2, __NFUN_145__(iNewRotOffset, 32768));
		rNewRotOffset.Yaw = __NFUN_144__(2, __NFUN_156__(32767, iNewRotOffset));
		Pawn.m_rRotationOffset = rNewRotOffset;
		Rot.Roll = 0;
		Rot.Yaw = ViewYaw;
		// End:0x3C0
		if(__NFUN_132__(__NFUN_154__(int(Pawn.Physics), int(3)), __NFUN_154__(int(Pawn.Physics), int(4))))
		{
			maxPitch = 2;			
		}
		else
		{
			maxPitch = 1;
		}
		// End:0x45A
		if(__NFUN_130__(__NFUN_151__(ViewPitch, __NFUN_144__(maxPitch, RotationRate.Pitch)), __NFUN_150__(ViewPitch, __NFUN_147__(65536, __NFUN_144__(maxPitch, RotationRate.Pitch)))))
		{
			// End:0x434
			if(__NFUN_150__(ViewPitch, 32768))
			{
				Rot.Pitch = __NFUN_144__(maxPitch, RotationRate.Pitch);				
			}
			else
			{
				Rot.Pitch = __NFUN_147__(65536, __NFUN_144__(maxPitch, RotationRate.Pitch));
			}			
		}
		else
		{
			Rot.Pitch = ViewPitch;
		}
		DeltaRot = __NFUN_317__(Rotation, Rot);
		Pawn.__NFUN_299__(Rot);
	}
	// End:0x4DA
	if(__NFUN_130__(__NFUN_114__(Level.Pauser, none), __NFUN_177__(DeltaTime, float(0))))
	{
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbCrawl, 0, Accel, DeltaRot);
	}
	// End:0x507
	if(__NFUN_177__(__NFUN_175__(Level.TimeSeconds, LastUpdateTime), 0.3000000))
	{
		clientErr = 10000.0000000;		
	}
	else
	{
		// End:0x585
		if(__NFUN_177__(__NFUN_175__(Level.TimeSeconds, LastUpdateTime), __NFUN_172__(180.0000000, float(Player.CurrentNetSpeed))))
		{
			// End:0x558
			if(__NFUN_114__(Pawn, none))
			{
				LocDiff = __NFUN_216__(Location, ClientLoc);				
			}
			else
			{
				LocDiff = __NFUN_216__(Pawn.Location, ClientLoc);
			}
			clientErr = __NFUN_219__(LocDiff, LocDiff);
		}
	}
	// End:0x84B
	if(__NFUN_177__(clientErr, float(3)))
	{
		// End:0x5C2
		if(__NFUN_114__(Pawn, none))
		{
			ClientPhysics = Physics;
			ClientLoc = Location;
			ClientVel = Velocity;			
		}
		else
		{
			ClientPhysics = Pawn.Physics;
			ClientVel = Pawn.Velocity;
			ClientBase = Pawn.Base;
			// End:0x647
			if(__NFUN_119__(Mover(Pawn.Base), none))
			{
				ClientLoc = __NFUN_216__(Pawn.Location, Pawn.Base.Location);				
			}
			else
			{
				ClientLoc = Pawn.Location;
			}
			ClientFloor = Pawn.Floor;
		}
		LastUpdateTime = Level.TimeSeconds;
		// End:0x6A8
		if(__NFUN_119__(m_SaveOldClientBase, ClientBase))
		{
			m_SaveOldClientBase = ClientBase;
			ClientAdjustBase(ClientBase);
		}
		// End:0x7D9
		if(__NFUN_132__(__NFUN_114__(Pawn, none), __NFUN_155__(int(Pawn.Physics), int(9))))
		{
			// End:0x782
			if(__NFUN_217__(ClientVel, vect(0.0000000, 0.0000000, 0.0000000)))
			{
				// End:0x749
				if(__NFUN_130__(__NFUN_130__(__NFUN_281__('PlayerWalking'), __NFUN_119__(Pawn, none)), __NFUN_154__(int(Pawn.Physics), int(1))))
				{
					VeryShortClientAdjustPosition(TimeStamp, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, ClientBase);					
				}
				else
				{
					ShortClientAdjustPosition(TimeStamp, __NFUN_284__(), ClientPhysics, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, ClientBase);
				}				
			}
			else
			{
				ClientAdjustPosition(TimeStamp, __NFUN_284__(), ClientPhysics, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, ClientVel.X, ClientVel.Y, ClientVel.Z, ClientBase);
			}			
		}
		else
		{
			LongClientAdjustPosition(TimeStamp, __NFUN_284__(), ClientPhysics, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, ClientVel.X, ClientVel.Y, ClientVel.Z, ClientBase, ClientFloor.X, ClientFloor.Y, ClientFloor.Z);
		}
	}
	return;
}

function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
{
	// End:0x1F
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.Acceleration = NewAccel;
	}
	return;
}

// NEW IN 1.60
final function MoveAutonomous(float DeltaTime, bool NewbRun, bool NewbDuck, bool NewbCrawl, Actor.EDoubleClickDir DoubleClickMove, Vector NewAccel, Rotator DeltaRot)
{
	// End:0x14
	if(NewbRun)
	{
		bRun = 1;		
	}
	else
	{
		bRun = 0;
	}
	// End:0x6D
	if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
	{
		// End:0x49
		if(NewbDuck)
		{
			bDuck = 1;			
		}
		else
		{
			bDuck = 0;
		}
		// End:0x65
		if(NewbCrawl)
		{
			m_bCrawl = true;			
		}
		else
		{
			m_bCrawl = false;
		}
	}
	HandleWalking();
	ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);
	// End:0xAC
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.__NFUN_3971__(DeltaTime);		
	}
	else
	{
		__NFUN_3971__(DeltaTime);
	}
	// End:0xE7
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.m_vEyeLocation = Pawn.GetBoneCoords('R6 PonyTail1').Origin;
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
	// End:0x62
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(Pawn, none), __NFUN_155__(int(Pawn.Physics), int(1))), __NFUN_155__(int(Pawn.Physics), int(0))))
	{
		return;
	}
	LongClientAdjustPosition(TimeStamp, 'PlayerWalking', 1, NewLocX, NewLocY, NewLocZ, 0.0000000, 0.0000000, 0.0000000, NewBase, Floor.X, Floor.Y, Floor.Z);
	return;
}

// NEW IN 1.60
function ShortClientAdjustPosition(float TimeStamp, name NewState, Actor.EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, Actor NewBase)
{
	local Vector Floor;

	// End:0x1F
	if(__NFUN_119__(Pawn, none))
	{
		Floor = Pawn.Floor;
	}
	LongClientAdjustPosition(TimeStamp, NewState, newPhysics, NewLocX, NewLocY, NewLocZ, 0.0000000, 0.0000000, 0.0000000, NewBase, Floor.X, Floor.Y, Floor.Z);
	return;
}

// NEW IN 1.60
function ClientAdjustPosition(float TimeStamp, name NewState, Actor.EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase)
{
	local Vector Floor;

	// End:0x1F
	if(__NFUN_119__(Pawn, none))
	{
		Floor = Pawn.Floor;
	}
	LongClientAdjustPosition(TimeStamp, NewState, newPhysics, NewLocX, NewLocY, NewLocZ, NewVelX, NewVelY, NewVelZ, NewBase, Floor.X, Floor.Y, Floor.Z);
	return;
}

// NEW IN 1.60
function LongClientAdjustPosition(float TimeStamp, name NewState, Actor.EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase, float NewFloorX, float NewFloorY, float NewFloorZ)
{
	local Vector NewLocation, NewFloor;
	local Actor MoveActor;

	// End:0x7B
	if(__NFUN_119__(Pawn, none))
	{
		// End:0x3E
		if(__NFUN_129__(bNetOwner))
		{
			Pawn.m_vEyeLocation = Pawn.GetBoneCoords('R6 PonyTail1').Origin;
		}
		// End:0x6D
		if(__NFUN_132__(Pawn.bTearOff, Pawn.m_bUseRagdoll))
		{
			__NFUN_113__('Dead');
			return;
		}
		MoveActor = Pawn;		
	}
	else
	{
		MoveActor = self;
	}
	// End:0x93
	if(__NFUN_177__(CurrentTimeStamp, TimeStamp))
	{
		return;
	}
	CurrentTimeStamp = TimeStamp;
	NewLocation.X = NewLocX;
	NewLocation.Y = NewLocY;
	NewLocation.Z = NewLocZ;
	MoveActor.Velocity.X = NewVelX;
	MoveActor.Velocity.Y = NewVelY;
	MoveActor.Velocity.Z = NewVelZ;
	NewFloor.X = NewFloorX;
	NewFloor.Y = NewFloorY;
	NewFloor.Z = NewFloorZ;
	MoveActor.__NFUN_298__(NewBase, NewFloor);
	// End:0x184
	if(__NFUN_119__(Mover(NewBase), none))
	{
		__NFUN_223__(NewLocation, NewBase.Location);
	}
	// End:0x1CF
	if(__NFUN_218__(NewLocation, MoveActor.Location))
	{
		MoveActor.bCanTeleport = false;
		MoveActor.__NFUN_267__(NewLocation);
		MoveActor.bCanTeleport = true;
	}
	// End:0x227
	if(__NFUN_155__(int(newPhysics), int(MoveActor.Physics)))
	{
		// End:0x227
		if(__NFUN_130__(__NFUN_155__(int(newPhysics), int(14)), __NFUN_155__(int(MoveActor.Physics), int(14))))
		{
			MoveActor.__NFUN_3970__(newPhysics);
		}
	}
	// End:0x23B
	if(__NFUN_255__(__NFUN_284__(), NewState))
	{
		__NFUN_113__(NewState);
	}
	bUpdatePosition = true;
	return;
}

function ClientAdjustBase(Actor newClientBase)
{
	local Actor MoveActor;

	// End:0x19
	if(__NFUN_119__(Pawn, none))
	{
		MoveActor = Pawn;		
	}
	else
	{
		MoveActor = self;
	}
	MoveActor.__NFUN_298__(newClientBase);
	return;
}

function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int realbRun, realbDuck;
	local bool realbCrawl;
	local float TotalTime;

	bUpdatePosition = false;
	realbRun = int(bRun);
	realbDuck = int(bDuck);
	realbCrawl = m_bCrawl;
	CurrentMove = SavedMoves;
	bUpdating = true;
	J0x42:

	// End:0x14B [Loop If]
	if(__NFUN_119__(CurrentMove, none))
	{
		// End:0xB5
		if(__NFUN_178__(CurrentMove.TimeStamp, CurrentTimeStamp))
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;			
		}
		else
		{
			__NFUN_184__(TotalTime, CurrentMove.Delta);
			MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.m_bCrawl, CurrentMove.DoubleClickMove, CurrentMove.Acceleration, rot(0, 0, 0));
			CurrentMove = CurrentMove.NextMove;
		}
		// [Loop Continue]
		goto J0x42;
	}
	bUpdating = false;
	bDuck = byte(realbDuck);
	bRun = byte(realbRun);
	m_bCrawl = realbCrawl;
	return;
}

function AdjustRadius(float MaxMove)
{
	local Pawn P;
	local Vector Dir;

	// End:0x135
	foreach __NFUN_313__(Class'Engine.Pawn', P)
	{
		// End:0x134
		if(__NFUN_130__(__NFUN_130__(__NFUN_119__(P, Pawn), __NFUN_218__(P.Velocity, vect(0.0000000, 0.0000000, 0.0000000))), P.bBlockPlayers))
		{
			Dir = __NFUN_226__(__NFUN_216__(P.Location, Pawn.Location));
			// End:0x134
			if(__NFUN_130__(__NFUN_177__(__NFUN_219__(Pawn.Velocity, Dir), float(0)), __NFUN_177__(__NFUN_219__(P.Velocity, Dir), float(0))))
			{
				// End:0x134
				if(__NFUN_176__(__NFUN_225__(__NFUN_216__(P.Location, Pawn.Location)), __NFUN_174__(__NFUN_174__(P.CollisionRadius, Pawn.CollisionRadius), MaxMove)))
				{
					P.__NFUN_3969__(__NFUN_212__(__NFUN_212__(P.Velocity, 0.5000000), float(PlayerReplicationInfo.Ping)));
				}
			}
		}		
	}	
	return;
}

final function SavedMove GetFreeMove()
{
	local SavedMove S, first;
	local int i;

	// End:0xF6
	if(__NFUN_114__(FreeMoves, none))
	{
		S = SavedMoves;
		J0x16:

		// End:0xEA [Loop If]
		if(__NFUN_119__(S, none))
		{
			__NFUN_165__(i);
			// End:0xD3
			if(__NFUN_151__(i, 30))
			{
				first = SavedMoves;
				SavedMoves = SavedMoves.NextMove;
				first.Clear();
				first.NextMove = none;
				J0x72:

				// End:0xCD [Loop If]
				if(__NFUN_119__(SavedMoves, none))
				{
					S = SavedMoves;
					SavedMoves = SavedMoves.NextMove;
					S.Clear();
					S.NextMove = FreeMoves;
					FreeMoves = S;
					// [Loop Continue]
					goto J0x72;
				}
				return first;
			}
			S = S.NextMove;
			// [Loop Continue]
			goto J0x16;
		}
		return __NFUN_278__(Class'Engine.SavedMove');		
	}
	else
	{
		S = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		S.NextMove = none;
		return S;
	}
	return;
}

function int CompressAccel(int C)
{
	// End:0x1D
	if(__NFUN_153__(C, 0))
	{
		C = __NFUN_249__(C, 127);		
	}
	else
	{
		C = __NFUN_146__(__NFUN_249__(int(__NFUN_186__(float(C))), 127), 128);
	}
	return C;
	return;
}

// NEW IN 1.60
function ReplicateMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
{
	local SavedMove NewMove, OldMove, LastMove;
	local float OldTimeDelta, NetMoveDelta;
	local int i, OldAccel;
	local Vector BuildAccel, AccelNorm, MoveLoc;
	local Rotator rSendRot;

	// End:0x2A
	if(__NFUN_119__(PendingMove, none))
	{
		PendingMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);
	}
	// End:0x16C
	if(__NFUN_119__(SavedMoves, none))
	{
		NewMove = SavedMoves;
		AccelNorm = __NFUN_226__(NewAccel);
		J0x4D:

		// End:0xF2 [Loop If]
		if(__NFUN_119__(NewMove.NextMove, none))
		{
			// End:0xDB
			if(__NFUN_132__(__NFUN_130__(__NFUN_155__(int(NewMove.DoubleClickMove), int(0)), __NFUN_150__(int(NewMove.DoubleClickMove), 5)), __NFUN_130__(__NFUN_218__(NewMove.Acceleration, NewAccel), __NFUN_176__(__NFUN_219__(__NFUN_226__(NewMove.Acceleration), AccelNorm), 0.9500000))))
			{
				OldMove = NewMove;
			}
			NewMove = NewMove.NextMove;
			// [Loop Continue]
			goto J0x4D;
		}
		// End:0x16C
		if(__NFUN_132__(__NFUN_130__(__NFUN_155__(int(NewMove.DoubleClickMove), int(0)), __NFUN_150__(int(NewMove.DoubleClickMove), 5)), __NFUN_130__(__NFUN_218__(NewMove.Acceleration, NewAccel), __NFUN_176__(__NFUN_219__(__NFUN_226__(NewMove.Acceleration), AccelNorm), 0.9500000))))
		{
			OldMove = NewMove;
		}
	}
	LastMove = NewMove;
	NewMove = GetFreeMove();
	// End:0x190
	if(__NFUN_114__(NewMove, none))
	{
		return;
	}
	NewMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DoubleClickMove, DeltaRot);
	// End:0x20C
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.__NFUN_3971__(NewMove.Delta);		
	}
	else
	{
		__NFUN_3971__(DeltaTime);
	}
	// End:0x22D
	if(__NFUN_114__(PendingMove, none))
	{
		PendingMove = NewMove;		
	}
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}
	NetMoveDelta = __NFUN_245__(__NFUN_172__(80.0000000, float(Player.CurrentNetSpeed)), 0.0150000);
	// End:0x2AE
	if(__NFUN_176__(PendingMove.Delta, __NFUN_175__(NetMoveDelta, ClientUpdateTime)))
	{
		return;		
	}
	else
	{
		// End:0x2E1
		if(__NFUN_130__(__NFUN_176__(ClientUpdateTime, float(0)), __NFUN_176__(PendingMove.Delta, __NFUN_175__(NetMoveDelta, ClientUpdateTime))))
		{
			return;			
		}
		else
		{
			ClientUpdateTime = __NFUN_175__(PendingMove.Delta, NetMoveDelta);
			// End:0x315
			if(__NFUN_114__(SavedMoves, none))
			{
				SavedMoves = PendingMove;				
			}
			else
			{
				LastMove.NextMove = PendingMove;
			}
			PendingMove = none;
		}
	}
	// End:0x44D
	if(__NFUN_119__(OldMove, none))
	{
		OldTimeDelta = __NFUN_244__(255.0000000, __NFUN_171__(__NFUN_175__(Level.TimeSeconds, OldMove.TimeStamp), float(500)));
		BuildAccel = __NFUN_215__(__NFUN_213__(0.0500000, OldMove.Acceleration), vect(0.5000000, 0.5000000, 0.5000000));
		OldAccel = __NFUN_146__(__NFUN_146__(__NFUN_148__(CompressAccel(int(BuildAccel.X)), 23), __NFUN_148__(CompressAccel(int(BuildAccel.Y)), 15)), __NFUN_148__(CompressAccel(int(BuildAccel.Z)), 7));
		// End:0x400
		if(OldMove.bRun)
		{
			__NFUN_161__(OldAccel, 64);
		}
		// End:0x41B
		if(OldMove.bDuck)
		{
			__NFUN_161__(OldAccel, 32);
		}
		// End:0x436
		if(OldMove.m_bCrawl)
		{
			__NFUN_161__(OldAccel, 16);
		}
		__NFUN_161__(OldAccel, int(OldMove.DoubleClickMove));
	}
	// End:0x466
	if(__NFUN_114__(Pawn, none))
	{
		MoveLoc = Location;		
	}
	else
	{
		rSendRot = Pawn.m_rRotationOffset;
		MoveLoc = Pawn.Location;
	}
	// End:0x4C9
	if(__NFUN_177__(Level.TimeSeconds, m_fNextUpdateTime))
	{
		m_fNextUpdateTime = __NFUN_174__(Level.TimeSeconds, __NFUN_172__(float(1), NetClientMaxTickRate));		
	}
	else
	{
		return;
	}
	// End:0x67A
	if(__NFUN_130__(__NFUN_217__(NewMove.Acceleration, vect(0.0000000, 0.0000000, 0.0000000)), __NFUN_154__(int(NewMove.DoubleClickMove), int(0))))
	{
		// End:0x5CB
		if(__NFUN_130__(__NFUN_130__(__NFUN_242__(NewMove.bDuck, false), __NFUN_242__(NewMove.bRun, false)), __NFUN_242__(NewMove.m_bCrawl, false)))
		{
			ShorterServerMove(NewMove.TimeStamp, MoveLoc, __NFUN_146__(__NFUN_144__(__NFUN_156__(32767, __NFUN_145__(Rotation.Pitch, 2)), 32768), __NFUN_156__(32767, __NFUN_145__(Rotation.Yaw, 2))), __NFUN_146__(__NFUN_144__(__NFUN_156__(32767, __NFUN_145__(rSendRot.Pitch, 2)), 32768), __NFUN_156__(32767, __NFUN_145__(rSendRot.Yaw, 2))));			
		}
		else
		{
			ShortServerMove(NewMove.TimeStamp, MoveLoc, NewMove.bRun, NewMove.bDuck, NewMove.m_bCrawl, __NFUN_146__(__NFUN_144__(__NFUN_156__(32767, __NFUN_145__(Rotation.Pitch, 2)), 32768), __NFUN_156__(32767, __NFUN_145__(Rotation.Yaw, 2))), __NFUN_146__(__NFUN_144__(__NFUN_156__(32767, __NFUN_145__(rSendRot.Pitch, 2)), 32768), __NFUN_156__(32767, __NFUN_145__(rSendRot.Yaw, 2))));
		}		
	}
	else
	{
		ServerMove(NewMove.TimeStamp, __NFUN_212__(NewMove.Acceleration, float(10)), MoveLoc, NewMove.bRun, NewMove.bDuck, NewMove.m_bCrawl, __NFUN_146__(__NFUN_144__(__NFUN_156__(32767, __NFUN_145__(Rotation.Pitch, 2)), 32768), __NFUN_156__(32767, __NFUN_145__(Rotation.Yaw, 2))), __NFUN_146__(__NFUN_144__(__NFUN_156__(32767, __NFUN_145__(rSendRot.Pitch, 2)), 32768), __NFUN_156__(32767, __NFUN_145__(rSendRot.Yaw, 2))), byte(OldTimeDelta), OldAccel);
	}
	return;
}

function HandleWalking()
{
	// End:0x50
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.SetWalking(__NFUN_130__(__NFUN_132__(__NFUN_155__(int(bRun), 0), __NFUN_155__(int(bDuck), 0)), __NFUN_129__(Region.Zone.__NFUN_303__('WarpZoneInfo'))));
	}
	return;
}

function ServerRestartGame()
{
	return;
}

function SetFOVAngle(float NewFOV)
{
	FovAngle = NewFOV;
	return;
}

function ClientFlash(float Scale, Vector fog)
{
	DesiredFlashScale = Scale;
	DesiredFlashFog = __NFUN_213__(0.0010000, fog);
	return;
}

function ClientSetFlash(Vector Scale, Vector fog)
{
	FlashScale = Scale;
	FlashFog = fog;
	return;
}

function ClientInstantFlash(float Scale, Vector fog)
{
	InstantFlash = Scale;
	InstantFog = __NFUN_213__(0.0010000, fog);
	return;
}

function ClientAdjustGlow(float Scale, Vector fog)
{
	__NFUN_184__(ConstantGlowScale, Scale);
	__NFUN_223__(ConstantGlowFog, __NFUN_213__(0.0010000, fog));
	return;
}

private function ClientShake(Vector ShakeRoll, Vector OffsetMag, Vector ShakeRate, float OffsetTime)
{
	// End:0x6F
	if(__NFUN_132__(__NFUN_176__(MaxShakeRoll, ShakeRoll.X), __NFUN_176__(ShakeRollTime, __NFUN_171__(0.0100000, ShakeRoll.Y))))
	{
		MaxShakeRoll = ShakeRoll.X;
		ShakeRollTime = __NFUN_171__(0.0100000, ShakeRoll.Y);
		ShakeRollRate = __NFUN_171__(0.0100000, ShakeRoll.Z);
	}
	// End:0xB2
	if(__NFUN_177__(__NFUN_225__(OffsetMag), __NFUN_225__(MaxShakeOffset)))
	{
		ShakeOffsetTime = __NFUN_213__(OffsetTime, vect(1.0000000, 1.0000000, 1.0000000));
		MaxShakeOffset = OffsetMag;
		ShakeOffsetRate = ShakeRate;
	}
	return;
}

function ShakeView(float shaketime, float RollMag, Vector OffsetMag, float RollRate, Vector OffsetRate, float OffsetTime)
{
	local Vector ShakeRoll;

	ShakeRoll.X = RollMag;
	ShakeRoll.Y = __NFUN_171__(100.0000000, shaketime);
	ShakeRoll.Z = __NFUN_171__(100.0000000, RollRate);
	ClientShake(ShakeRoll, OffsetMag, OffsetRate, OffsetTime);
	return;
}

function Typing(bool bTyping)
{
	bIsTyping = bTyping;
	// End:0x48
	if(__NFUN_130__(__NFUN_130__(bTyping, __NFUN_119__(Pawn, none)), __NFUN_129__(Pawn.bTearOff)))
	{
		Pawn.ChangeAnimation();
	}
	// End:0x8D
	if(__NFUN_119__(Level.Game.StatLog, none))
	{
		Level.Game.StatLog.LogTypingEvent(bTyping, self);
	}
	return;
}

//*************************************************************************************
// Normal gameplay execs
// Type the name of the exec function at the console to execute it
// R6CODE
exec function Bind(string szKeyAndCommand)
{
	local string szResult;
	local int iPos;

	// End:0x3B
	if(__NFUN_130__(__NFUN_2014__(), __NFUN_129__(Level.m_bInGamePlanningActive)))
	{
		szResult = __NFUN_168__("INPUTPLANNING", szKeyAndCommand);		
	}
	else
	{
		szResult = __NFUN_168__("INPUT", szKeyAndCommand);
	}
	__NFUN_2710__(szResult);
	iPos = __NFUN_126__(szKeyAndCommand, " ");
	szResult = __NFUN_234__(szKeyAndCommand, __NFUN_147__(__NFUN_147__(__NFUN_125__(szKeyAndCommand), iPos), 1));
	// End:0xEF
	if(__NFUN_124__(szResult, "CONSOLE"))
	{
		// End:0xCB
		if(__NFUN_130__(__NFUN_2014__(), __NFUN_129__(Level.m_bInGamePlanningActive)))
		{
			szResult = __NFUN_168__("INPUT", szKeyAndCommand);			
		}
		else
		{
			szResult = __NFUN_168__("INPUTPLANNING", szKeyAndCommand);
		}
		__NFUN_2710__(szResult);
	}
	return;
}

exec function SetOption(string szKeyAndCommand)
{
	local string szResult;

	szResult = __NFUN_168__("R6GAMEOPTIONS", szKeyAndCommand);
	__NFUN_2710__(szResult);
	return;
}

exec function Jump(optional float f)
{
	return;
}

function bool SetPause(bool bPause)
{
	return Level.Game.SetPause(bPause, self);
	return;
}

exec function Pause()
{
	return;
}

// The player wants to fire.
exec function Fire(optional float f)
{
	// End:0x21
	if(__NFUN_114__(Level.Pauser, PlayerReplicationInfo))
	{
		SetPause(false);
		return;
	}
	// End:0x75
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(Pawn, none), __NFUN_119__(Pawn.EngineWeapon, none)), __NFUN_129__(GameReplicationInfo.m_bGameOverRep)))
	{
		Pawn.EngineWeapon.Fire(f);
	}
	return;
}

// The player wants to alternate-fire.
exec function AltFire(optional float f)
{
	// End:0x21
	if(__NFUN_114__(Level.Pauser, PlayerReplicationInfo))
	{
		SetPause(false);
		return;
	}
	// End:0x52
	if(__NFUN_119__(Pawn.EngineWeapon, none))
	{
		Pawn.EngineWeapon.AltFire(f);
	}
	return;
}

exec function Suicide()
{
	return;
}

// R6CODE+
event HandleServerMsg(string _szServerMsg, optional int iLifeTime)
{
	myHUD.AddTextServerMessage(_szServerMsg, Class'Engine.LocalMessage', iLifeTime);
	return;
}

function ClientCantRequestChangeNameYet()
{
	HandleServerMsg(Localize("Game", "CantRequestChangeNameYet", "R6GameInfo"));
	return;
}

simulated function ServerChangeName(string S)
{
	local int iChangeNameTime;

	iChangeNameTime = Class'Engine.Actor'.static.__NFUN_1009__().ChangeNameTime;
	// End:0x88
	if(__NFUN_132__(__NFUN_132__(__NFUN_154__(m_iChangeNameLastTime, 0), __NFUN_177__(Level.TimeSeconds, float(__NFUN_146__(m_iChangeNameLastTime, iChangeNameTime)))), __NFUN_154__(int(Level.NetMode), int(NM_Standalone))))
	{
		m_iChangeNameLastTime = int(Level.TimeSeconds);
		ClientChangeName(S);		
	}
	else
	{
		ClientCantRequestChangeNameYet();
	}
	return;
}

simulated function ClientChangeName(string S)
{
	ChangeName(S);
	// End:0x28
	if(__NFUN_151__(__NFUN_125__(S), 15))
	{
		S = __NFUN_128__(S, 15);
	}
	ReplaceText(S, " ", "_");
	ReplaceText(S, "~", "_");
	ReplaceText(S, "?", "_");
	ReplaceText(S, ",", "_");
	ReplaceText(S, "#", "_");
	ReplaceText(S, "/", "_");
	S = __NFUN_238__(S);
	__NFUN_546__("Name", S, true);
	__NFUN_536__();
	Class'Engine.Actor'.static.__NFUN_1009__().characterName = S;
	Class'Engine.Actor'.static.__NFUN_1009__().__NFUN_536__();
	return;
}

exec function Name(coerce string S)
{
	ServerChangeName(S);
	return;
}

exec function SetName(coerce string S)
{
	ServerChangeName(S);
	return;
}

simulated function ChangeName(coerce out string S)
{
	// End:0x1D
	if(__NFUN_151__(__NFUN_125__(S), 15))
	{
		S = __NFUN_128__(S, 15);
	}
	ReplaceText(S, " ", "_");
	ReplaceText(S, "~", "_");
	ReplaceText(S, "?", "_");
	ReplaceText(S, ",", "_");
	ReplaceText(S, "#", "_");
	ReplaceText(S, "/", "_");
	S = __NFUN_238__(S);
	// End:0xC8
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		Level.Game.ChangeName(self, S, false);
	}
	return;
}

exec event SetProgressTime(float t)
{
	ProgressTimeOut = __NFUN_174__(t, Level.TimeSeconds);
	return;
}

function Restart()
{
	super.Restart();
	ServerTimeStamp = 0.0000000;
	TimeMargin = 0.0000000;
	EnterStartState();
	SetViewTarget(Pawn);
	bBehindView = Pawn.PointOfView();
	ClientReStart();
	return;
}

function EnterStartState()
{
	local name NewState;

	// End:0x6A
	if(Pawn.PhysicsVolume.bWaterVolume)
	{
		// End:0x53
		if(Pawn.HeadVolume.bWaterVolume)
		{
			Pawn.BreathTime = Pawn.UnderWaterTime;
		}
		NewState = Pawn.WaterMovementState;		
	}
	else
	{
		NewState = Pawn.LandMovementState;
	}
	// End:0x92
	if(__NFUN_281__(NewState))
	{
		BeginState();		
	}
	else
	{
		__NFUN_113__(NewState);
	}
	return;
}

function ClientReStart()
{
	// End:0x14
	if(__NFUN_114__(Pawn, none))
	{
		__NFUN_113__('WaitingForPawn');
		return;
	}
	Pawn.ClientReStart();
	SetViewTarget(Pawn);
	bBehindView = Pawn.PointOfView();
	EnterStartState();
	return;
}

exec function BehindView(bool B)
{
	// End:0x16
	if(__NFUN_129__(CheatManager.CanExec()))
	{
		return;
	}
	bBehindView = B;
	ClientSetBehindView(bBehindView);
	return;
}

event TravelPostAccept()
{
	// End:0x31
	if(__NFUN_152__(Pawn.Health, 0))
	{
		Pawn.Health = Pawn.default.Health;
	}
	return;
}

event PlayerTick(float DeltaTime)
{
	PlayerInput.PlayerInput(DeltaTime);
	// End:0x23
	if(bUpdatePosition)
	{
		ClientUpdatePosition();
	}
	PlayerMove(DeltaTime);
	return;
}

function PlayerMove(float DeltaTime)
{
	return;
}

function bool NotifyLanded(Vector HitNormal)
{
	return bUpdating;
	return;
}

function Controller.EAttitude AttitudeTo(Pawn Other)
{
	// End:0x17
	if(__NFUN_114__(Other.Controller, none))
	{
		return 4;
	}
	// End:0x2F
	if(Other.IsPlayerPawn())
	{
		return AttitudeToPlayer;
	}
	return Other.Controller.AttitudeToPlayer;
	return;
}

function AdjustView(float DeltaTime)
{
	// End:0x9F
	if(__NFUN_181__(FovAngle, DesiredFOV))
	{
		// End:0x4F
		if(__NFUN_177__(FovAngle, DesiredFOV))
		{
			FovAngle = __NFUN_175__(FovAngle, __NFUN_245__(7.0000000, __NFUN_171__(__NFUN_171__(0.9000000, DeltaTime), __NFUN_175__(FovAngle, DesiredFOV))));			
		}
		else
		{
			FovAngle = __NFUN_175__(FovAngle, __NFUN_244__(-7.0000000, __NFUN_171__(__NFUN_171__(0.9000000, DeltaTime), __NFUN_175__(FovAngle, DesiredFOV))));
		}
		// End:0x9F
		if(__NFUN_178__(__NFUN_186__(__NFUN_175__(FovAngle, DesiredFOV)), float(10)))
		{
			FovAngle = DesiredFOV;
		}
	}
	// End:0xFA
	if(bZooming)
	{
		__NFUN_184__(ZoomLevel, __NFUN_171__(DeltaTime, 1.0000000));
		// End:0xD5
		if(__NFUN_177__(ZoomLevel, 0.9000000))
		{
			ZoomLevel = 0.9000000;
		}
		DesiredFOV = __NFUN_246__(__NFUN_175__(90.0000000, __NFUN_171__(ZoomLevel, 88.0000000)), 1.0000000, 170.0000000);
	}
	return;
}

function CalcBehindView(out Vector CameraLocation, out Rotator CameraRotation, float Dist)
{
	local Vector View, HitLocation, HitNormal;
	local float ViewDist;

	CameraRotation = Rotation;
	View = __NFUN_276__(vect(1.0000000, 0.0000000, 0.0000000), CameraRotation);
	// End:0x7C
	if(__NFUN_119__(__NFUN_277__(HitLocation, HitNormal, __NFUN_216__(CameraLocation, __NFUN_213__(__NFUN_174__(Dist, float(30)), Vector(CameraRotation))), CameraLocation), none))
	{
		ViewDist = __NFUN_244__(__NFUN_219__(__NFUN_216__(CameraLocation, HitLocation), View), Dist);		
	}
	else
	{
		ViewDist = Dist;
	}
	__NFUN_224__(CameraLocation, __NFUN_213__(__NFUN_175__(ViewDist, float(30)), View));
	return;
}

function CalcFirstPersonView(out Vector CameraLocation, out Rotator CameraRotation)
{
	CameraRotation = Rotation;
	CameraLocation = __NFUN_215__(__NFUN_215__(CameraLocation, Pawn.EyePosition()), ShakeOffset);
	return;
}

event AddCameraEffect(CameraEffect NewEffect, optional bool RemoveExisting)
{
	// End:0x14
	if(RemoveExisting)
	{
		RemoveCameraEffect(NewEffect);
	}
	CameraEffects.Length = __NFUN_146__(CameraEffects.Length, 1);
	CameraEffects[__NFUN_147__(CameraEffects.Length, 1)] = NewEffect;
	return;
}

event RemoveCameraEffect(CameraEffect ExEffect)
{
	local int EffectIndex;

	EffectIndex = 0;
	J0x07:

	// End:0x44 [Loop If]
	if(__NFUN_150__(EffectIndex, CameraEffects.Length))
	{
		// End:0x3A
		if(__NFUN_114__(CameraEffects[EffectIndex], ExEffect))
		{
			CameraEffects.Remove(EffectIndex, 1);
			return;
		}
		__NFUN_165__(EffectIndex);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function Rotator GetViewRotation()
{
	// End:0x25
	if(__NFUN_130__(bBehindView, __NFUN_119__(Pawn, none)))
	{
		return Pawn.Rotation;
	}
	return Rotation;
	return;
}

event PlayerCalcView(out Actor ViewActor, out Vector CameraLocation, out Rotator CameraRotation)
{
	local Pawn PTarget;

	// End:0x78
	if(__NFUN_132__(__NFUN_114__(ViewTarget, none), ViewTarget.bDeleteMe))
	{
		__NFUN_231__("No VIEWTARGET in PlayerCalcView");
		// End:0x71
		if(__NFUN_130__(__NFUN_119__(Pawn, none), __NFUN_129__(Pawn.bDeleteMe)))
		{
			SetViewTarget(Pawn);			
		}
		else
		{
			SetViewTarget(self);
		}
	}
	ViewActor = ViewTarget;
	CameraLocation = ViewTarget.Location;
	// End:0xE9
	if(__NFUN_114__(ViewTarget, Pawn))
	{
		// End:0xD7
		if(bBehindView)
		{
			CalcBehindView(CameraLocation, CameraRotation, __NFUN_171__(CameraDist, Pawn.default.CollisionRadius));			
		}
		else
		{
			CalcFirstPersonView(CameraLocation, CameraRotation);
		}
		return;
	}
	// End:0x124
	if(__NFUN_114__(ViewTarget, self))
	{
		// End:0x114
		if(bCameraPositionLocked)
		{
			CameraRotation = CheatManager.LockedRotation;			
		}
		else
		{
			CameraRotation = Rotation;
		}
		return;		
	}
	else
	{
		// End:0x177
		if(__NFUN_119__(ViewTarget, none))
		{
			// End:0x165
			if(bBehindView)
			{
				CalcBehindView(CameraLocation, CameraRotation, __NFUN_171__(CameraDist, Pawn(ViewTarget).default.CollisionRadius));				
			}
			else
			{
				CalcFirstPersonView(CameraLocation, CameraRotation);
			}
			return;
		}
	}
	CameraRotation = ViewTarget.Rotation;
	PTarget = Pawn(ViewTarget);
	// End:0x23B
	if(__NFUN_119__(PTarget, none))
	{
		// End:0x1F3
		if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
		{
			// End:0x1F0
			if(PTarget.IsPlayerPawn())
			{
				PTarget.SetViewRotation(TargetViewRotation);
				CameraRotation = TargetViewRotation;
			}			
		}
		else
		{
			// End:0x21A
			if(PTarget.IsPlayerPawn())
			{
				CameraRotation = PTarget.GetViewRotation();
			}
		}
		// End:0x23B
		if(__NFUN_129__(bBehindView))
		{
			__NFUN_223__(CameraLocation, PTarget.EyePosition());
		}
	}
	// End:0x2A3
	if(bBehindView)
	{
		CameraLocation = __NFUN_215__(CameraLocation, __NFUN_213__(__NFUN_175__(ViewTarget.default.CollisionHeight, ViewTarget.CollisionHeight), vect(0.0000000, 0.0000000, 1.0000000)));
		CalcBehindView(CameraLocation, CameraRotation, __NFUN_171__(CameraDist, ViewTarget.default.CollisionRadius));
	}
	return;
}

function CheckShake(out float MaxOffset, out float offset, out float Rate, out float Time)
{
	// End:0x15
	if(__NFUN_176__(__NFUN_186__(offset), __NFUN_186__(MaxOffset)))
	{
		return;
	}
	offset = MaxOffset;
	// End:0x92
	if(__NFUN_177__(Time, float(1)))
	{
		// End:0x69
		if(__NFUN_178__(__NFUN_171__(Time, __NFUN_186__(__NFUN_172__(MaxOffset, Rate))), float(1)))
		{
			MaxOffset = __NFUN_171__(MaxOffset, __NFUN_175__(__NFUN_172__(float(1), Time), float(1)));			
		}
		else
		{
			__NFUN_182__(MaxOffset, float(-1));
		}
		__NFUN_185__(Time, float(1));
		__NFUN_182__(Rate, float(-1));		
	}
	else
	{
		MaxOffset = 0.0000000;
		offset = 0.0000000;
		Rate = 0.0000000;
	}
	return;
}

function ViewShake(float DeltaTime)
{
	local Rotator ViewRotation;
	local float FRoll;

	// End:0xF8
	if(__NFUN_218__(ShakeOffsetRate, vect(0.0000000, 0.0000000, 0.0000000)))
	{
		__NFUN_184__(ShakeOffset.X, __NFUN_171__(DeltaTime, ShakeOffsetRate.X));
		CheckShake(MaxShakeOffset.X, ShakeOffset.X, ShakeOffsetRate.X, ShakeOffsetTime.X);
		__NFUN_184__(ShakeOffset.Y, __NFUN_171__(DeltaTime, ShakeOffsetRate.Y));
		CheckShake(MaxShakeOffset.Y, ShakeOffset.Y, ShakeOffsetRate.Y, ShakeOffsetTime.Y);
		__NFUN_184__(ShakeOffset.Z, __NFUN_171__(DeltaTime, ShakeOffsetRate.Z));
		CheckShake(MaxShakeOffset.Z, ShakeOffset.Z, ShakeOffsetRate.Z, ShakeOffsetTime.Z);
	}
	ViewRotation = Rotation;
	// End:0x1AB
	if(__NFUN_181__(ShakeRollRate, float(0)))
	{
		ViewRotation.Roll = __NFUN_156__(int(__NFUN_174__(float(__NFUN_156__(ViewRotation.Roll, 65535)), __NFUN_171__(ShakeRollRate, DeltaTime))), 65535);
		// End:0x16A
		if(__NFUN_151__(ViewRotation.Roll, 32768))
		{
			__NFUN_162__(ViewRotation.Roll, 65536);
		}
		FRoll = float(ViewRotation.Roll);
		CheckShake(MaxShakeRoll, FRoll, ShakeRollRate, ShakeRollTime);
		ViewRotation.Roll = int(FRoll);		
	}
	else
	{
		// End:0x1C0
		if(bZeroRoll)
		{
			ViewRotation.Roll = 0;
		}
	}
	__NFUN_299__(ViewRotation);
	return;
}

function bool TurnTowardNearestEnemy()
{
	return;
}

function TurnAround()
{
	// End:0x2F
	if(__NFUN_129__(bSetTurnRot))
	{
		TurnRot180 = Rotation;
		__NFUN_161__(TurnRot180.Yaw, 32768);
		bSetTurnRot = true;
	}
	DesiredRotation = TurnRot180;
	bRotateToDesired = __NFUN_155__(DesiredRotation.Yaw, Rotation.Yaw);
	return;
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
	local Rotator NewRotation, ViewRotation;

	// End:0x37
	if(__NFUN_132__(bInterpolating, __NFUN_130__(__NFUN_119__(Pawn, none), Pawn.bInterpolating)))
	{
		ViewShake(DeltaTime);
		return;
	}
	ViewRotation = Rotation;
	DesiredRotation = ViewRotation;
	// End:0x63
	if(__NFUN_155__(int(bTurnToNearest), 0))
	{
		TurnTowardNearestEnemy();		
	}
	else
	{
		// End:0x79
		if(__NFUN_155__(int(bTurn180), 0))
		{
			TurnAround();			
		}
		else
		{
			TurnTarget = none;
			bRotateToDesired = false;
			bSetTurnRot = false;
			__NFUN_161__(ViewRotation.Yaw, int(__NFUN_171__(__NFUN_171__(32.0000000, DeltaTime), aTurn)));
			__NFUN_161__(ViewRotation.Pitch, int(__NFUN_171__(__NFUN_171__(32.0000000, DeltaTime), aLookUp)));
		}
	}
	ViewRotation.Pitch = __NFUN_156__(ViewRotation.Pitch, 65535);
	// End:0x148
	if(__NFUN_130__(__NFUN_151__(ViewRotation.Pitch, 18000), __NFUN_150__(ViewRotation.Pitch, 49152)))
	{
		// End:0x138
		if(__NFUN_177__(aLookUp, float(0)))
		{
			ViewRotation.Pitch = 18000;			
		}
		else
		{
			ViewRotation.Pitch = 49152;
		}
	}
	__NFUN_299__(ViewRotation);
	ViewShake(DeltaTime);
	ViewFlash(DeltaTime);
	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;
	// End:0x1D1
	if(__NFUN_130__(__NFUN_130__(__NFUN_129__(bRotateToDesired), __NFUN_119__(Pawn, none)), __NFUN_132__(__NFUN_129__(bFreeCamera), __NFUN_129__(bBehindView))))
	{
		Pawn.FaceRotation(NewRotation, DeltaTime);
	}
	return;
}

function ClearDoubleClick()
{
	// End:0x1F
	if(__NFUN_119__(PlayerInput, none))
	{
		PlayerInput.DoubleClickTimer = 0.0000000;
	}
	return;
}

function ServerViewNextPlayer()
{
	local Controller C;
	local Pawn Pick;
	local bool bFound, bRealSpec;

	bRealSpec = bOnlySpectator;
	bOnlySpectator = true;
	C = Level.ControllerList;
	J0x29:

	// End:0x144 [Loop If]
	if(__NFUN_119__(C, none))
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Check spectate ", string(C.Pawn)), " can "), string(Level.Game.CanSpectate(self, true, C.Pawn))));
		// End:0x12D
		if(__NFUN_130__(__NFUN_119__(C.Pawn, none), Level.Game.CanSpectate(self, true, C.Pawn)))
		{
			// End:0xEE
			if(__NFUN_114__(Pick, none))
			{
				Pick = C.Pawn;
			}
			// End:0x111
			if(bFound)
			{
				Pick = C.Pawn;
				// [Explicit Break]
				goto J0x144;				
			}
			else
			{
				bFound = __NFUN_114__(ViewTarget, C.Pawn);
			}
		}
		C = C.nextController;
		// [Loop Continue]
		goto J0x29;
	}
	J0x144:

	__NFUN_231__(__NFUN_112__("best is ", string(Pick)));
	SetViewTarget(Pick);
	__NFUN_231__(__NFUN_112__("Viewtarget is ", string(ViewTarget)));
	// End:0x195
	if(__NFUN_114__(ViewTarget, self))
	{
		bBehindView = false;		
	}
	else
	{
		bBehindView = true;
	}
	bOnlySpectator = bRealSpec;
	return;
}

event ClientSetNewViewTarget()
{
	return;
}

function ServerViewSelf()
{
	bBehindView = false;
	SetViewTarget(self);
	ClientMessage(OwnCamera, 'Event');
	return;
}

//------------------------------------------------------------------------------
// ngStats Accessors
function string GetNGSecret()
{
	return ngWorldSecret;
	return;
}

function SetNGSecret(string newSecret)
{
	ngWorldSecret = newSecret;
	return;
}

//------------------------------------------------------------------------------
// Control options	
function ChangeStairLook(bool B)
{
	bLookUpStairs = B;
	// End:0x1E
	if(bLookUpStairs)
	{
		bAlwaysMouseLook = false;
	}
	return;
}

function ChangeAlwaysMouseLook(bool B)
{
	bAlwaysMouseLook = B;
	// End:0x1E
	if(bAlwaysMouseLook)
	{
		bLookUpStairs = false;
	}
	return;
}

//R6Radar begin
event ToggleRadar(bool _bRadar)
{
	ServerToggleRadar(_bRadar);
	return;
}

function ServerToggleRadar(bool _bRadar)
{
	m_bRadarActive = _bRadar;
	return;
}

function ServerToggleHeatVision(bool bHeatVisionActive)
{
	m_bHeatVisionActive = bHeatVisionActive;
	return;
}

event ClientPBKickedOutMessage(string PBMessage)
{
	Player.Console.R6ConnectionFailed(PBMessage);
	return;
}

// 
function ClientPBKickMsg(string PBMessage)
{
	Player.Console.R6ConnectionFailed(PBMessage);
	return;
}

state PlayerWalking
{
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		// End:0x22
		if(NewVolume.bWaterVolume)
		{
			__NFUN_113__(Pawn.WaterMovementState);
		}
		return false;
		return;
	}

	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		local Vector OldAccel;
		local bool OldCrouch;

		// End:0x0D
		if(__NFUN_114__(Pawn, none))
		{
			return;
		}
		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		// End:0x53
		if(bPressedJump)
		{
			Pawn.DoJump(bUpdating);
		}
		// End:0xC4
		if(__NFUN_155__(int(Pawn.Physics), int(2)))
		{
			OldCrouch = Pawn.bWantsToCrouch;
			// End:0xA2
			if(__NFUN_154__(int(bDuck), 0))
			{
				Pawn.ShouldCrouch(false);				
			}
			else
			{
				// End:0xC4
				if(Pawn.bCanCrouch)
				{
					Pawn.ShouldCrouch(true);
				}
			}
		}
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Vector X, Y, Z, NewAccel;
		local Actor.EDoubleClickDir DoubleClickMove;
		local Rotator OldRotation, ViewRotation;
		local bool bSaveJump;

		__NFUN_229__(Pawn.Rotation, X, Y, Z);
		NewAccel = __NFUN_215__(__NFUN_213__(aForward, X), __NFUN_213__(aStrafe, Y));
		NewAccel.Z = 0.0000000;
		// End:0x73
		if(__NFUN_176__(__NFUN_225__(NewAccel), 1.0000000))
		{
			NewAccel = vect(0.0000000, 0.0000000, 0.0000000);
		}
		DoubleClickMove = PlayerInput.CheckForDoubleClickMove(DeltaTime);
		GroundPitch = 0;
		ViewRotation = Rotation;
		// End:0x176
		if(__NFUN_155__(int(Pawn.Physics), int(1)))
		{
			// End:0x176
			if(__NFUN_130__(__NFUN_130__(__NFUN_129__(bKeyboardLook), __NFUN_154__(int(bLook), 0)), bCenterView))
			{
				ViewRotation.Pitch = __NFUN_156__(ViewRotation.Pitch, 65535);
				// End:0x11E
				if(__NFUN_151__(ViewRotation.Pitch, 32768))
				{
					__NFUN_162__(ViewRotation.Pitch, 65536);
				}
				ViewRotation.Pitch = int(__NFUN_171__(float(ViewRotation.Pitch), __NFUN_175__(float(1), __NFUN_171__(float(12), __NFUN_244__(0.0833000, DeltaTime)))));
				// End:0x176
				if(__NFUN_176__(__NFUN_186__(float(ViewRotation.Pitch)), float(1000)))
				{
					ViewRotation.Pitch = 0;
				}
			}
		}
		Pawn.CheckBob(DeltaTime, Y);
		__NFUN_299__(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1.0000000);
		// End:0x1E2
		if(__NFUN_130__(bPressedJump, Pawn.CannotJumpNow()))
		{
			bSaveJump = true;
			bPressedJump = false;			
		}
		else
		{
			bSaveJump = false;
		}
		// End:0x21F
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, __NFUN_317__(OldRotation, Rotation));			
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, __NFUN_317__(OldRotation, Rotation));
		}
		bPressedJump = bSaveJump;
		return;
	}

	function BeginState()
	{
		// End:0x23
		if(__NFUN_114__(Pawn.Mesh, none))
		{
			Pawn.SetMesh();
		}
		DoubleClickDir = 0;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		// End:0x85
		if(__NFUN_130__(__NFUN_155__(int(Pawn.Physics), int(2)), __NFUN_155__(int(Pawn.Physics), int(13))))
		{
			Pawn.__NFUN_3970__(1);
		}
		GroundPitch = 0;
		return;
	}

	function EndState()
	{
		GroundPitch = 0;
		// End:0x31
		if(__NFUN_130__(__NFUN_119__(Pawn, none), __NFUN_154__(int(bDuck), 0)))
		{
			Pawn.ShouldCrouch(false);
		}
		return;
	}
	stop;
}

state PlayerClimbing
{
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		// End:0x25
		if(NewVolume.bWaterVolume)
		{
			__NFUN_113__(Pawn.WaterMovementState);			
		}
		else
		{
			__NFUN_113__(Pawn.LandMovementState);
		}
		return false;
		return;
	}

	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		local Vector OldAccel;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		// End:0x66
		if(bPressedJump)
		{
			Pawn.DoJump(bUpdating);
			// End:0x66
			if(__NFUN_154__(int(Pawn.Physics), int(2)))
			{
				__NFUN_113__('PlayerWalking');
			}
		}
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Vector X, Y, Z, NewAccel;
		local Actor.EDoubleClickDir DoubleClickMove;
		local Rotator OldRotation, ViewRotation;
		local bool bSaveJump;

		__NFUN_229__(Rotation, X, Y, Z);
		// End:0x51
		if(__NFUN_119__(Pawn.OnLadder, none))
		{
			NewAccel = __NFUN_213__(aForward, Pawn.OnLadder.ClimbDir);			
		}
		else
		{
			NewAccel = __NFUN_215__(__NFUN_213__(aForward, X), __NFUN_213__(aStrafe, Y));
		}
		// End:0x95
		if(__NFUN_176__(__NFUN_225__(NewAccel), 1.0000000))
		{
			NewAccel = vect(0.0000000, 0.0000000, 0.0000000);
		}
		ViewRotation = Pawn.Rotation;
		__NFUN_299__(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1.0000000);
		// End:0x101
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, __NFUN_317__(OldRotation, Rotation));			
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, __NFUN_317__(OldRotation, Rotation));
		}
		bPressedJump = bSaveJump;
		return;
	}

	function BeginState()
	{
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		return;
	}

	function EndState()
	{
		// End:0x1B
		if(__NFUN_119__(Pawn, none))
		{
			Pawn.ShouldCrouch(false);
		}
		return;
	}
	stop;
}

state PlayerSpidering
{
	event bool NotifyHitWall(Vector HitNormal, Actor HitActor)
	{
		Pawn.__NFUN_3970__(9);
		Pawn.__NFUN_298__(HitActor, HitNormal);
		return true;
		return;
	}

	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local Rotator TempRot, ViewRotation;
		local Vector MyFloor, CrossDir, FwdDir, OldFwdDir, OldX, RealFloor;

		// End:0x2A
		if(__NFUN_132__(bInterpolating, Pawn.bInterpolating))
		{
			ViewShake(DeltaTime);
			return;
		}
		TurnTarget = none;
		bRotateToDesired = false;
		bSetTurnRot = false;
		// End:0x8D
		if(__NFUN_132__(__NFUN_114__(Pawn.Base, none), __NFUN_217__(Pawn.Floor, vect(0.0000000, 0.0000000, 0.0000000))))
		{
			MyFloor = vect(0.0000000, 0.0000000, 1.0000000);			
		}
		else
		{
			MyFloor = Pawn.Floor;
		}
		// End:0x206
		if(__NFUN_218__(MyFloor, OldFloor))
		{
			RealFloor = MyFloor;
			MyFloor = __NFUN_226__(__NFUN_215__(__NFUN_213__(__NFUN_171__(float(6), DeltaTime), MyFloor), __NFUN_213__(__NFUN_175__(float(1), __NFUN_171__(float(6), DeltaTime)), OldFloor)));
			// End:0x10F
			if(__NFUN_177__(__NFUN_219__(RealFloor, MyFloor), 0.9990000))
			{
				MyFloor = RealFloor;
			}
			CrossDir = __NFUN_226__(__NFUN_220__(RealFloor, OldFloor));
			FwdDir = __NFUN_220__(CrossDir, MyFloor);
			OldFwdDir = __NFUN_220__(CrossDir, OldFloor);
			ViewX = __NFUN_215__(__NFUN_215__(__NFUN_212__(MyFloor, __NFUN_219__(OldFloor, ViewX)), __NFUN_212__(CrossDir, __NFUN_219__(CrossDir, ViewX))), __NFUN_212__(FwdDir, __NFUN_219__(OldFwdDir, ViewX)));
			ViewX = __NFUN_226__(ViewX);
			ViewZ = __NFUN_215__(__NFUN_215__(__NFUN_212__(MyFloor, __NFUN_219__(OldFloor, ViewZ)), __NFUN_212__(CrossDir, __NFUN_219__(CrossDir, ViewZ))), __NFUN_212__(FwdDir, __NFUN_219__(OldFwdDir, ViewZ)));
			ViewZ = __NFUN_226__(ViewZ);
			OldFloor = MyFloor;
			ViewY = __NFUN_226__(__NFUN_220__(MyFloor, ViewX));
		}
		// End:0x35C
		if(__NFUN_132__(__NFUN_181__(aTurn, float(0)), __NFUN_181__(aLookUp, float(0))))
		{
			// End:0x260
			if(__NFUN_181__(aTurn, float(0)))
			{
				ViewX = __NFUN_226__(__NFUN_215__(ViewX, __NFUN_212__(__NFUN_213__(float(2), ViewY), __NFUN_187__(__NFUN_171__(__NFUN_171__(0.0005000, DeltaTime), aTurn)))));
			}
			// End:0x348
			if(__NFUN_181__(aLookUp, float(0)))
			{
				OldX = ViewX;
				ViewX = __NFUN_226__(__NFUN_215__(ViewX, __NFUN_212__(__NFUN_213__(float(2), ViewZ), __NFUN_187__(__NFUN_171__(__NFUN_171__(0.0005000, DeltaTime), aLookUp)))));
				ViewZ = __NFUN_226__(__NFUN_220__(ViewX, ViewY));
				// End:0x348
				if(__NFUN_176__(__NFUN_219__(ViewZ, MyFloor), 0.7070000))
				{
					OldX = __NFUN_226__(__NFUN_216__(OldX, __NFUN_212__(MyFloor, __NFUN_219__(MyFloor, OldX))));
					// End:0x320
					if(__NFUN_177__(__NFUN_219__(ViewX, MyFloor), float(0)))
					{
						ViewX = __NFUN_226__(__NFUN_215__(OldX, MyFloor));						
					}
					else
					{
						ViewX = __NFUN_226__(__NFUN_216__(OldX, MyFloor));
					}
					ViewZ = __NFUN_226__(__NFUN_220__(ViewX, ViewY));
				}
			}
			ViewY = __NFUN_226__(__NFUN_220__(MyFloor, ViewX));
		}
		ViewRotation = OrthoRotation(ViewX, ViewY, ViewZ);
		__NFUN_299__(ViewRotation);
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
		Pawn.FaceRotation(ViewRotation, DeltaTime);
		return;
	}

	function bool NotifyLanded(Vector HitNormal)
	{
		Pawn.__NFUN_3970__(9);
		return bUpdating;
		return;
	}

	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		// End:0x22
		if(NewVolume.bWaterVolume)
		{
			__NFUN_113__(Pawn.WaterMovementState);
		}
		return false;
		return;
	}

	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		local Vector OldAccel;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		// End:0x46
		if(bPressedJump)
		{
			Pawn.DoJump(bUpdating);
		}
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Vector NewAccel;
		local Actor.EDoubleClickDir DoubleClickMove;
		local Rotator OldRotation, ViewRotation;
		local bool bSaveJump;

		GroundPitch = 0;
		ViewRotation = Rotation;
		// End:0x37
		if(__NFUN_130__(__NFUN_130__(__NFUN_129__(bKeyboardLook), __NFUN_154__(int(bLook), 0)), bCenterView))
		{
		}
		Pawn.CheckBob(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000));
		__NFUN_299__(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1.0000000);
		NewAccel = __NFUN_215__(__NFUN_213__(aForward, __NFUN_226__(__NFUN_216__(ViewX, __NFUN_212__(OldFloor, __NFUN_219__(OldFloor, ViewX))))), __NFUN_213__(aStrafe, ViewY));
		// End:0xD6
		if(__NFUN_176__(__NFUN_225__(NewAccel), 1.0000000))
		{
			NewAccel = vect(0.0000000, 0.0000000, 0.0000000);
		}
		// End:0x106
		if(__NFUN_130__(bPressedJump, Pawn.CannotJumpNow()))
		{
			bSaveJump = true;
			bPressedJump = false;			
		}
		else
		{
			bSaveJump = false;
		}
		// End:0x143
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, __NFUN_317__(OldRotation, Rotation));			
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, __NFUN_317__(OldRotation, Rotation));
		}
		bPressedJump = bSaveJump;
		return;
	}

	function BeginState()
	{
		local Rotator newRot;

		// End:0x23
		if(__NFUN_114__(Pawn.Mesh, none))
		{
			Pawn.SetMesh();
		}
		OldFloor = vect(0.0000000, 0.0000000, 1.0000000);
		__NFUN_229__(Rotation, ViewX, ViewY, ViewZ);
		DoubleClickDir = 0;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		// End:0x93
		if(__NFUN_155__(int(Pawn.Physics), int(2)))
		{
			Pawn.__NFUN_3970__(9);
		}
		GroundPitch = 0;
		Pawn.bCrawler = true;
		Pawn.__NFUN_283__(Pawn.default.CollisionHeight, Pawn.default.CollisionHeight);
		return;
	}

	function EndState()
	{
		GroundPitch = 0;
		// End:0x69
		if(__NFUN_119__(Pawn, none))
		{
			Pawn.__NFUN_283__(Pawn.default.CollisionRadius, Pawn.default.CollisionHeight);
			Pawn.ShouldCrouch(false);
			Pawn.bCrawler = Pawn.default.bCrawler;
		}
		return;
	}
	stop;
}

state PlayerSwimming
{
	function bool WantsSmoothedView()
	{
		return __NFUN_129__(Pawn.bJustLanded);
		return;
	}

	function bool NotifyLanded(Vector HitNormal)
	{
		// End:0x2C
		if(Pawn.PhysicsVolume.bWaterVolume)
		{
			Pawn.__NFUN_3970__(3);			
		}
		else
		{
			__NFUN_113__(Pawn.LandMovementState);
		}
		return bUpdating;
		return;
	}

	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		local Actor HitActor;
		local Vector HitLocation, HitNormal, checkpoint;

		// End:0x171
		if(__NFUN_129__(NewVolume.bWaterVolume))
		{
			Pawn.__NFUN_3970__(2);
			// End:0x9F
			if(__NFUN_130__(Pawn.bUpAndOut, Pawn.CheckWaterJump(HitNormal)))
			{
				Pawn.Velocity.Z = __NFUN_174__(__NFUN_245__(Pawn.JumpZ, 420.0000000), __NFUN_171__(float(2), Pawn.CollisionRadius));
				__NFUN_113__(Pawn.LandMovementState);				
			}
			else
			{
				// End:0xE4
				if(__NFUN_132__(__NFUN_177__(Pawn.Velocity.Z, float(160)), __NFUN_129__(Pawn.TouchingWaterVolume())))
				{
					__NFUN_113__(Pawn.LandMovementState);					
				}
				else
				{
					checkpoint = Pawn.Location;
					__NFUN_185__(checkpoint.Z, __NFUN_174__(Pawn.CollisionHeight, 6.0000000));
					HitActor = __NFUN_277__(HitLocation, HitNormal, checkpoint, Pawn.Location, false);
					// End:0x15E
					if(__NFUN_119__(HitActor, none))
					{
						__NFUN_113__(Pawn.LandMovementState);						
					}
					else
					{
						__NFUN_117__('Timer');
						__NFUN_280__(0.7000000, false);
					}
				}
			}			
		}
		else
		{
			__NFUN_118__('Timer');
			Pawn.__NFUN_3970__(3);
		}
		return false;
		return;
	}

	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		local Vector X, Y, Z, OldAccel;

		__NFUN_229__(Rotation, X, Y, Z);
		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		Pawn.bUpAndOut = __NFUN_130__(__NFUN_177__(__NFUN_219__(X, Pawn.Acceleration), float(0)), __NFUN_132__(__NFUN_177__(Pawn.Acceleration.Z, float(0)), __NFUN_151__(Rotation.Pitch, 2048)));
		// End:0xCC
		if(__NFUN_129__(Pawn.PhysicsVolume.bWaterVolume))
		{
			NotifyPhysicsVolumeChange(Pawn.PhysicsVolume);
		}
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Rotator OldRotation;
		local Vector X, Y, Z, NewAccel;

		__NFUN_229__(Rotation, X, Y, Z);
		NewAccel = __NFUN_215__(__NFUN_215__(__NFUN_213__(aForward, X), __NFUN_213__(aStrafe, Y)), __NFUN_213__(aUp, vect(0.0000000, 0.0000000, 1.0000000)));
		// End:0x70
		if(__NFUN_176__(__NFUN_225__(NewAccel), 1.0000000))
		{
			NewAccel = vect(0.0000000, 0.0000000, 0.0000000);
		}
		Pawn.CheckBob(DeltaTime, Y);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 2.0000000);
		// End:0xD6
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, NewAccel, 0, __NFUN_317__(OldRotation, Rotation));			
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, 0, __NFUN_317__(OldRotation, Rotation));
		}
		bPressedJump = false;
		return;
	}

	function Timer()
	{
		// End:0x3F
		if(__NFUN_130__(__NFUN_129__(Pawn.PhysicsVolume.bWaterVolume), __NFUN_154__(int(Role), int(ROLE_Authority))))
		{
			__NFUN_113__(Pawn.LandMovementState);
		}
		__NFUN_118__('Timer');
		return;
	}

	function BeginState()
	{
		__NFUN_118__('Timer');
		Pawn.__NFUN_3970__(3);
		return;
	}
	stop;
}

state PlayerFlying
{
	function PlayerMove(float DeltaTime)
	{
		local Vector X, Y, Z;

		__NFUN_229__(Rotation, X, Y, Z);
		Pawn.Acceleration = __NFUN_215__(__NFUN_213__(aForward, X), __NFUN_213__(aStrafe, Y));
		// End:0x75
		if(__NFUN_176__(__NFUN_225__(Pawn.Acceleration), 1.0000000))
		{
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		}
		// End:0xBC
		if(__NFUN_130__(bCheatFlying, __NFUN_217__(Pawn.Acceleration, vect(0.0000000, 0.0000000, 0.0000000))))
		{
			Pawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		}
		UpdateRotation(DeltaTime, 2.0000000);
		// End:0x107
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, Pawn.Acceleration, 0, rot(0, 0, 0));			
		}
		else
		{
			ProcessMove(DeltaTime, Pawn.Acceleration, 0, rot(0, 0, 0));
		}
		return;
	}

	function BeginState()
	{
		Pawn.__NFUN_3970__(4);
		return;
	}
	stop;
}

state PlayerHelicoptering extends PlayerFlying
{
	function PlayerMove(float DeltaTime)
	{
		local Vector X, Y, Z;

		__NFUN_229__(Rotation, X, Y, Z);
		Pawn.Acceleration = __NFUN_215__(__NFUN_215__(__NFUN_213__(aForward, X), __NFUN_213__(aStrafe, Y)), __NFUN_213__(aUp, vect(0.0000000, 0.0000000, 1.0000000)));
		// End:0x8B
		if(__NFUN_176__(__NFUN_225__(Pawn.Acceleration), 1.0000000))
		{
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		}
		// End:0xD2
		if(__NFUN_130__(bCheatFlying, __NFUN_217__(Pawn.Acceleration, vect(0.0000000, 0.0000000, 0.0000000))))
		{
			Pawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		}
		UpdateRotation(DeltaTime, 2.0000000);
		// End:0x11D
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, Pawn.Acceleration, 0, rot(0, 0, 0));			
		}
		else
		{
			ProcessMove(DeltaTime, Pawn.Acceleration, 0, rot(0, 0, 0));
		}
		return;
	}
	stop;
}

state BaseSpectating
{
	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		Acceleration = NewAccel;
		__NFUN_3969__(__NFUN_212__(Acceleration, DeltaTime));
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Rotator NewRotation;
		local Vector X, Y, Z;

		__NFUN_229__(Rotation, X, Y, Z);
		Acceleration = __NFUN_213__(0.0200000, __NFUN_215__(__NFUN_215__(__NFUN_213__(aForward, X), __NFUN_213__(aStrafe, Y)), __NFUN_213__(aUp, vect(0.0000000, 0.0000000, 1.0000000))));
		UpdateRotation(DeltaTime, 1.0000000);
		// End:0x95
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, Acceleration, 0, rot(0, 0, 0));			
		}
		else
		{
			ProcessMove(DeltaTime, Acceleration, 0, rot(0, 0, 0));
		}
		return;
	}
	stop;
}

state Scripting
{
// The player wants to fire.
	exec function Fire(optional float f)
	{
		return;
	}

// The player wants to alternate-fire.
	exec function AltFire(optional float f)
	{
		Fire(f);
		return;
	}
	stop;
}

state Spectating extends BaseSpectating
{
	ignores Suicide, ClientReStart;

// The player wants to fire.
	exec function Fire(optional float f)
	{
		bBehindView = true;
		ServerViewNextPlayer();
		return;
	}

// The player wants to alternate-fire.
	exec function AltFire(optional float f)
	{
		bBehindView = false;
		ServerViewSelf();
		return;
	}

	function BeginState()
	{
		// End:0x22
		if(__NFUN_119__(Pawn, none))
		{
			__NFUN_267__(Pawn.Location);
			UnPossess();
		}
		bCollideWorld = true;
		return;
	}

	function EndState()
	{
		// End:0x1C
		if(__NFUN_119__(PlayerReplicationInfo, none))
		{
			PlayerReplicationInfo.bIsSpectator = false;
		}
		bCollideWorld = false;
		return;
	}
	stop;
}

auto state PlayerWaiting extends BaseSpectating
{
	ignores R6TakeDamage;

	exec function Jump(optional float f)
	{
		return;
	}

	exec function Suicide()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		// End:0x1A
		if(__NFUN_176__(Level.TimeSeconds, WaitDelay))
		{
			return;
		}
		// End:0x35
		if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
		{
			return;
		}
		// End:0x64
		if(Level.Game.bWaitingToStartMatch)
		{
			PlayerReplicationInfo.bReadyToPlay = true;			
		}
		else
		{
			Level.Game.RestartPlayer(self);
		}
		return;
	}

// The player wants to fire.
	exec function Fire(optional float f)
	{
		ServerReStartPlayer();
		return;
	}

// The player wants to alternate-fire.
	exec function AltFire(optional float f)
	{
		ServerReStartPlayer();
		return;
	}

	function EndState()
	{
		// End:0x1A
		if(__NFUN_119__(Pawn, none))
		{
			Pawn.SetMesh();
		}
		// End:0x35
		if(__NFUN_119__(PlayerReplicationInfo, none))
		{
			PlayerReplicationInfo.SetWaitingPlayer(false);
		}
		bCollideWorld = false;
		return;
	}

	function BeginState()
	{
		// End:0x1B
		if(__NFUN_119__(PlayerReplicationInfo, none))
		{
			PlayerReplicationInfo.SetWaitingPlayer(true);
		}
		bCollideWorld = true;
		myHUD.bShowScores = false;
		return;
	}
	stop;
}

state WaitingForPawn extends BaseSpectating
{
	ignores KilledBy;

// The player wants to fire.
	exec function Fire(optional float f)
	{
		return;
	}

// The player wants to alternate-fire.
	exec function AltFire(optional float f)
	{
		return;
	}

// NEW IN 1.60
	function LongClientAdjustPosition(float TimeStamp, name NewState, Actor.EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase, float NewFloorX, float NewFloorY, float NewFloorZ)
	{
		return;
	}

	function PlayerTick(float DeltaTime)
	{
		global.PlayerTick(DeltaTime);
		// End:0x2C
		if(__NFUN_119__(Pawn, none))
		{
			Pawn.Controller = self;
			ClientReStart();
		}
		return;
	}

	function Timer()
	{
		AskForPawn();
		return;
	}

	function BeginState()
	{
		__NFUN_280__(0.2000000, true);
		return;
	}

	function EndState()
	{
		__NFUN_280__(0.0000000, false);
		return;
	}
	stop;
}

state GameEnded
{
	ignores Suicide, R6TakeDamage, KilledBy;

	function ServerRestartGame()
	{
		Level.Game.RestartGame();
		return;
	}

// The player wants to fire.
	exec function Fire(optional float f)
	{
		// End:0x12
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			return;
		}
		// End:0x26
		if(__NFUN_129__(bFrozen))
		{
			ServerRestartGame();			
		}
		else
		{
			// End:0x3C
			if(__NFUN_178__(TimerRate, float(0)))
			{
				__NFUN_280__(1.5000000, false);
			}
		}
		return;
	}

// The player wants to alternate-fire.
	exec function AltFire(optional float f)
	{
		Fire(f);
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Vector X, Y, Z;
		local Rotator ViewRotation;

		__NFUN_229__(Rotation, X, Y, Z);
		// End:0xEF
		if(__NFUN_129__(bFixedCamera))
		{
			ViewRotation = Rotation;
			__NFUN_161__(ViewRotation.Yaw, int(__NFUN_171__(__NFUN_171__(32.0000000, DeltaTime), aTurn)));
			__NFUN_161__(ViewRotation.Pitch, int(__NFUN_171__(__NFUN_171__(32.0000000, DeltaTime), aLookUp)));
			ViewRotation.Pitch = __NFUN_156__(ViewRotation.Pitch, 65535);
			// End:0xE4
			if(__NFUN_130__(__NFUN_151__(ViewRotation.Pitch, 18000), __NFUN_150__(ViewRotation.Pitch, 49152)))
			{
				// End:0xD4
				if(__NFUN_177__(aLookUp, float(0)))
				{
					ViewRotation.Pitch = 18000;					
				}
				else
				{
					ViewRotation.Pitch = 49152;
				}
			}
			__NFUN_299__(ViewRotation);			
		}
		else
		{
			// End:0x10B
			if(__NFUN_119__(ViewTarget, none))
			{
				__NFUN_299__(ViewTarget.Rotation);
			}
		}
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
		// End:0x15B
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));			
		}
		else
		{
			ProcessMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));
		}
		bPressedJump = false;
		return;
	}

	function ServerMove(float TimeStamp, Vector InAccel, Vector ClientLoc, bool NewbRun, bool NewbDuck, bool NewbCrawl, int View, int iNewRotOffset, optional byte OldTimeDelta, optional int OldAccel)
	{
		global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbCrawl, __NFUN_146__(__NFUN_144__(__NFUN_156__(32767, __NFUN_145__(Rotation.Pitch, 2)), 32768), __NFUN_156__(32767, __NFUN_145__(Rotation.Yaw, 2))), 0);
		return;
	}

	function FindGoodView()
	{
		local Vector cameraLoc;
		local Rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestDist, newdist;
		local int startYaw;
		local Actor ViewActor;

		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestDist = 0.0000000;
		startYaw = ViewRotation.Yaw;
		tries = 0;
		J0x4B:

		// End:0xDD [Loop If]
		if(__NFUN_150__(tries, 16))
		{
			cameraLoc = ViewTarget.Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = __NFUN_225__(__NFUN_216__(cameraLoc, ViewTarget.Location));
			// End:0xC2
			if(__NFUN_177__(newdist, bestDist))
			{
				bestDist = newdist;
				besttry = tries;
			}
			__NFUN_161__(ViewRotation.Yaw, 4096);
			__NFUN_165__(tries);
			// [Loop Continue]
			goto J0x4B;
		}
		ViewRotation.Yaw = __NFUN_146__(startYaw, __NFUN_144__(besttry, 4096));
		__NFUN_299__(ViewRotation);
		return;
	}

	function Timer()
	{
		bFrozen = false;
		return;
	}

	function BeginState()
	{
		local Pawn P;

		Level.m_bInGamePlanningActive = false;
		EndZoom();
		bFire = 0;
		bAltFire = 0;
		// End:0x77
		if(__NFUN_119__(Pawn, none))
		{
			Pawn.SimAnim.AnimRate = 0;
			Pawn.bPhysicsAnimUpdate = false;
			Pawn.StopAnimating();
			Pawn.__NFUN_262__(false, false, false);
		}
		myHUD.bShowScores = true;
		bFrozen = true;
		// End:0xA3
		if(__NFUN_129__(bFixedCamera))
		{
			bBehindView = true;
		}
		__NFUN_280__(1.5000000, false);
		__NFUN_3970__(0);
		// End:0xEC
		foreach __NFUN_313__(Class'Engine.Pawn', P)
		{
			P.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
			P.__NFUN_3970__(0);			
		}		
		return;
	}
	stop;
}

state Dead
{
	ignores KilledBy;

	function ServerReStartPlayer()
	{
		super.ServerReStartPlayer();
		return;
	}

// The player wants to fire.
	exec function Fire(optional float f)
	{
		ServerReStartPlayer();
		return;
	}

// The player wants to alternate-fire.
	exec function AltFire(optional float f)
	{
		// End:0x20
		if(myHUD.bShowScores)
		{
			Fire(f);			
		}
		else
		{
			Timer();
		}
		return;
	}

	function ServerMove(float TimeStamp, Vector Accel, Vector ClientLoc, bool NewbRun, bool NewbDuck, bool NewbCrawl, int View, int iNewRotOffset, optional byte OldTimeDelta, optional int OldAccel)
	{
		global.ServerMove(TimeStamp, Accel, ClientLoc, false, false, false, View, iNewRotOffset);
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Vector X, Y, Z;
		local Rotator ViewRotation;

		// End:0x13F
		if(__NFUN_129__(bFrozen))
		{
			// End:0x27
			if(bPressedJump)
			{
				Fire(0.0000000);
				bPressedJump = false;
			}
			__NFUN_229__(Rotation, X, Y, Z);
			ViewRotation = Rotation;
			__NFUN_161__(ViewRotation.Yaw, int(__NFUN_171__(__NFUN_171__(32.0000000, DeltaTime), aTurn)));
			__NFUN_161__(ViewRotation.Pitch, int(__NFUN_171__(__NFUN_171__(32.0000000, DeltaTime), aLookUp)));
			ViewRotation.Pitch = __NFUN_156__(ViewRotation.Pitch, 65535);
			// End:0x100
			if(__NFUN_130__(__NFUN_151__(ViewRotation.Pitch, 18000), __NFUN_150__(ViewRotation.Pitch, 49152)))
			{
				// End:0xF0
				if(__NFUN_177__(aLookUp, float(0)))
				{
					ViewRotation.Pitch = 18000;					
				}
				else
				{
					ViewRotation.Pitch = 49152;
				}
			}
			__NFUN_299__(ViewRotation);
			// End:0x13F
			if(__NFUN_150__(int(Role), int(ROLE_Authority)))
			{
				ReplicateMove(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000), 0, rot(0, 0, 0));
			}
		}
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
		return;
	}

	function FindGoodView()
	{
		local Vector cameraLoc;
		local Rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestDist, newdist;
		local int startYaw;
		local Actor ViewActor;

		// End:0x0D
		if(__NFUN_114__(ViewTarget, none))
		{
			return;
		}
		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestDist = 0.0000000;
		startYaw = ViewRotation.Yaw;
		tries = 0;
		J0x58:

		// End:0xEA [Loop If]
		if(__NFUN_150__(tries, 16))
		{
			cameraLoc = ViewTarget.Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = __NFUN_225__(__NFUN_216__(cameraLoc, ViewTarget.Location));
			// End:0xCF
			if(__NFUN_177__(newdist, bestDist))
			{
				bestDist = newdist;
				besttry = tries;
			}
			__NFUN_161__(ViewRotation.Yaw, 4096);
			__NFUN_165__(tries);
			// [Loop Continue]
			goto J0x58;
		}
		ViewRotation.Yaw = __NFUN_146__(startYaw, __NFUN_144__(besttry, 4096));
		__NFUN_299__(ViewRotation);
		return;
	}

	function Timer()
	{
		// End:0x0D
		if(__NFUN_129__(bFrozen))
		{
			return;
		}
		bFrozen = false;
		myHUD.bShowScores = true;
		bPressedJump = false;
		return;
	}

	function BeginState()
	{
		local SavedMove Next, Current;

		Enemy = none;
		bBehindView = true;
		bFrozen = true;
		bPressedJump = false;
		J0x1F:

		// End:0x63 [Loop If]
		if(__NFUN_119__(SavedMoves, none))
		{
			Next = SavedMoves.NextMove;
			Current = SavedMoves;
			SavedMoves = Next;
			Current.__NFUN_279__();
			// [Loop Continue]
			goto J0x1F;
		}
		// End:0x8C
		if(__NFUN_119__(PendingMove, none))
		{
			Current = PendingMove;
			PendingMove = none;
			Current.__NFUN_279__();
		}
		return;
	}

	function EndState()
	{
		local SavedMove Next;

		J0x00:
		// End:0x39 [Loop If]
		if(__NFUN_119__(SavedMoves, none))
		{
			Next = SavedMoves.NextMove;
			SavedMoves.__NFUN_279__();
			SavedMoves = Next;
			// [Loop Continue]
			goto J0x00;
		}
		// End:0x57
		if(__NFUN_119__(PendingMove, none))
		{
			PendingMove.__NFUN_279__();
			PendingMove = none;
		}
		Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		bBehindView = false;
		myHUD.bShowScores = false;
		bPressedJump = false;
		return;
	}
	stop;
}

defaultproperties
{
	EnemyTurnSpeed=45000
	bAlwaysMouseLook=true
	bKeyboardLook=true
	bZeroRoll=true
	OrthoZoom=40000.0000000
	CameraDist=9.0000000
	DesiredFOV=85.0000000
	DefaultFOV=85.0000000
	MaxTimeMargin=1.0000000
	NetClientMaxTickRate=15.0000000
	LocalMessageClass=Class'Engine.LocalMessage'
	CheatClass=Class'Engine.CheatManager'
	InputClass=Class'Engine.PlayerInput'
	FlashScale=(X=1.0000000,Y=1.0000000,Z=1.0000000)
	QuickSaveString="Quick Saving"
	NoPauseMessage="Game is not pauseable"
	ViewingFrom="Now viewing from"
	OwnCamera="Now viewing from own camera"
	bIsPlayer=true
	bCanOpenDoors=true
	bCanDoSpecial=true
	FovAngle=85.0000000
	Handedness=1.0000000
	bTravel=true
	NetPriority=3.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var float
// REMOVED IN 1.60: var byte
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var p
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var OldClientWeapon
// REMOVED IN 1.60: var eCameraMode
// REMOVED IN 1.60: function HandlePickup
// REMOVED IN 1.60: function FOV
// REMOVED IN 1.60: function ForceReload
// REMOVED IN 1.60: function damageAttitudeTo
// REMOVED IN 1.60: function Speech
// REMOVED IN 1.60: function RestartLevel
// REMOVED IN 1.60: function LocalTravel
// REMOVED IN 1.60: function QuickSave
// REMOVED IN 1.60: function QuickLoad
// REMOVED IN 1.60: function ActivateInventoryItem
// REMOVED IN 1.60: function ThrowWeapon
// REMOVED IN 1.60: function PrevWeapon
// REMOVED IN 1.60: function NextWeapon
// REMOVED IN 1.60: function SwitchWeapon
// REMOVED IN 1.60: function GetWeapon
// REMOVED IN 1.60: function PrevItem
// REMOVED IN 1.60: function ActivateItem
// REMOVED IN 1.60: function Use
// REMOVED IN 1.60: function ServerUse
// REMOVED IN 1.60: function SwitchTeam
// REMOVED IN 1.60: function ChangeTeam
// REMOVED IN 1.60: function SwitchLevel
// REMOVED IN 1.60: function ClearProgressMessages
// REMOVED IN 1.60: function SetProgressMessage
// REMOVED IN 1.60: function ChangedWeapon
// REMOVED IN 1.60: function AdjustAim
// REMOVED IN 1.60: function AttitudeTo
// REMOVED IN 1.60: function CreateCameraEffect
