//=============================================================================
// PlayerController - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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

// 'input' vars are bound to key/axis bindings; the engine writes them each tick before PlayerInput runs.
// NEW IN 1.60
var input byte bStrafe;
// NEW IN 1.60
var input byte bSnapLevel;
// NEW IN 1.60
var input byte bLook;
// NEW IN 1.60
var input byte bFreeLook;   // non-zero when camera is decoupled from pawn rotation
// NEW IN 1.60
var input byte bTurn180;    // triggers a 180-degree turn
// NEW IN 1.60
var input byte bTurnToNearest; // snap-turn toward nearest enemy
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
var bool bPressedJump;      // true this frame when the jump button was pressed
var bool bUpdatePosition;   // set when server correction arrives; triggers ClientUpdatePosition next tick
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
var input float aForward;   // forward/backward movement axis (positive = forward)
// NEW IN 1.60
var input float aTurn;      // horizontal turn axis; applied to yaw each tick in UpdateRotation
// NEW IN 1.60
var input float aStrafe;    // lateral strafe axis
// NEW IN 1.60
var input float aUp;        // vertical movement axis (flying/swimming)
// NEW IN 1.60
var input float aLookUp;    // vertical look axis; applied to pitch each tick in UpdateRotation
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
var const Actor ViewTarget;         // actor the camera follows; changed via SetViewTarget
var HUD myHUD;  // heads up display info
// Move buffering for network games.  Clients save their un-acknowledged moves in order to replay them
// when they get position updates from the server.
var SavedMove SavedMoves;  // buffered moves pending position updates
var SavedMove FreeMoves;   // freed moves, available for buffering
var SavedMove PendingMove; // move being assembled this tick; held until the net send interval expires
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
var Class<PlayerInput> InputClass;  // class of PlayerInput to instantiate (set in defaultproperties)
// Screen flash/fog effect vectors: Scale controls brightness, Fog sets a screen-space color tint.
// FlashScale/FlashFog are blended; ConstantGlow/InstantFog handle persistent and one-shot variants.
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
var private transient PlayerInput PlayerInput;  // subobject that processes raw key/axis input each tick
var transient array<CameraEffect> CameraEffects;  // A stack of camera effects.

// Replication block: variables and RPCs synced between server and clients.
// 'reliable' guarantees delivery; unreliable may be dropped under load.
// Conditions are evaluated server-side each tick; Role < ROLE_Authority means client-to-server.
replication
{
	// Pos:0x0CB
	// Server -> client: sound play/stop RPCs (skipped during demo recording).
	unreliable if(((int(Role) == int(ROLE_Authority)) && (!bDemoRecording)))
		ClientPlaySound, ClientStopSound;

	// Pos:0x0FF
	// Server -> client: position corrections and screen-flash/shake effects.
	unreliable if((int(Role) == int(ROLE_Authority)))
		ClientAdjustPosition, ClientFlash, 
		ClientInstantFlash, ClientSetFlash, 
		ClientShake, LongClientAdjustPosition, 
		SetFOVAngle, ShortClientAdjustPosition, 
		VeryShortClientAdjustPosition;

	// Pos:0x10C
	// Server -> client: spatial sound events (suppressed during demo unless recording locally).
	unreliable if((((!bDemoRecording) || (bClientDemoRecording && bClientDemoNetFunc)) && (int(Role) == int(ROLE_Authority))))
		ClientHearSound;

	// Pos:0x13C
	// Client -> server: movement and chat RPCs (Role < ROLE_Authority = this is the client).
	unreliable if((int(Role) < int(ROLE_Authority)))
		Say, ServerMove, 
		ServerTKPopUpDone, ServerViewNextPlayer, 
		ServerViewSelf, ShortServerMove, 
		ShorterServerMove, TeamSay;

	// Pos:0x000
	// Server -> owning client only (bNetOwner): HUD-critical state.
	reliable if(((bNetDirty && bNetOwner) && (int(Role) == int(ROLE_Authority))))
		GameReplicationInfo, ViewTarget, 
		bOnlySpectator, m_TeamSelection, 
		m_eCameraMode;

	// Pos:0x023
	// Server -> owning client: view data for a spectated remote Pawn (not the controller's own Pawn).
	reliable if((((bNetOwner && (int(Role) == int(ROLE_Authority))) && (ViewTarget != Pawn)) && (Pawn(ViewTarget) != none)))
		TargetEyeHeight, TargetViewRotation, 
		TargetWeaponViewOffset;

	// Pos:0x05E
	// Server -> client: demo recording view angles.
	reliable if((bDemoRecording && (int(Role) == int(ROLE_Authority))))
		DemoViewPitch, DemoViewYaw;

	// Pos:0x076
	// Server -> all clients: radar active flag (dirty-checked).
	reliable if((bNetDirty && (int(Role) == int(ROLE_Authority))))
		m_bRadarActive;

	// Pos:0x08E
	// Server -> client: reliable game-state RPCs (HUD, music, respawn, zoom, etc.).
	reliable if((int(Role) == int(ROLE_Authority)))
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
	// Server -> client: chat and localized messages (suppressed in demo unless client-demo).
	reliable if(((int(Role) == int(ROLE_Authority)) && ((!bDemoRecording) || (bClientDemoRecording && bClientDemoNetFunc))))
		ClientMessage, ReceiveLocalizedMessage, 
		TeamMessage;

	// Pos:0x0E5
	// Server -> client: level travel (never replicated during demo recording).
	reliable if(((int(Role) == int(ROLE_Authority)) && (!bDemoRecording)))
		ClientTravel;

	// Pos:0x149
	// Client -> server: player management RPCs (name change, pause, suicide, etc.).
	reliable if((int(Role) < int(ROLE_Authority)))
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

// PostBeginPlay: called after the controller is fully initialized in the world.
event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultHUD();
	// End:0x35
	if((Level.LevelEnterText != ""))
	{
		ClientMessage(Level.LevelEnterText);
	}
	DesiredFOV = DefaultFOV;
	// Default view target is the controller itself until a pawn is possessed.
	SetViewTarget(self);
	// End:0x66
	// Only enable cheats in standalone (single-player) mode.
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		AddCheats();
	}
	return;
}

function PendingStasis()
{
	bStasis = true;
	Pawn = none;
	GotoState('Scripting');
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
	if((CheatManager == none))
	{
		CheatManager = new CheatClass;
	}
	return;
}

function SpawnDefaultHUD()
{
	myHUD = Spawn(Class'Engine.HUD', self);
	return;
}

function Reset()
{
	PawnDied();
	super.Reset();
	SetViewTarget(self);
	bBehindView = false;
	WaitDelay = (Level.TimeSeconds + float(2));
	GotoState('BaseSpectating');
	return;
}

//R6CODE
event InitMultiPlayerOptions()
{
	return;
}

event InitInputSystem()
{
	// Instantiate the PlayerInput subobject that processes raw key/axis events.
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
	GotoState(NewState, NewLabel);
	return;
}

function AskForPawn()
{
	// End:0x19
	if((Pawn != none))
	{
		GivePawn(Pawn);		
	}
	else
	{
		// End:0x37
		if(IsInState('GameEnded'))
		{
			ClientGotoState('GameEnded', 'Begin');			
		}
		else
		{
			// End:0x50
			if(IsInState('Dead'))
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
	if((NewPawn == none))
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

	GetAxes(Pawn.Rotation, X, Y, Z);
	Dir = Normal(Pawn.Acceleration);
	// End:0x6D
	// 16384 = 90 deg in Unreal rotator units; maps acceleration dot products to a facing quadrant.
	if((Dot(Y, Dir) > float(0)))
	{
		return int((float(49152) + (float(16384) * Dot(X, Dir))));		// 49152 = 270 deg
	}
	else
	{
		return int((float(16384) - (float(16384) * Dot(X, Dir))));       // 16384 = 90 deg
	}
	return;
}

// Possess a pawn
function Possess(Pawn aPawn)
{
	// End:0x0B
	// Pure spectators are forbidden from possessing pawns.
	if(bOnlySpectator)
	{
		return;
	}
	SetRotation(aPawn.Rotation);
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	Pawn.bStasis = false;
	// End:0x72
	if((PlayerReplicationInfo != none))
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
	if((Pawn != none))
	{
		SetLocation(Pawn.Location);
		Pawn.RemoteRole = ROLE_SimulatedProxy;
		Pawn.UnPossessed();
		// End:0x52
		if((ViewTarget == Pawn))
		{
			SetViewTarget(self);
		}
	}
	Pawn.Controller = none;
	Pawn = none;
	GotoState('Spectating');
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
	if((Pawn != none))
	{
		Pawn.RemoteRole = ROLE_SimulatedProxy;
	}
	// End:0x39
	if((ViewTarget == Pawn))
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
	if(((myHUD == none) || ((newHUDType != none) && (newHUDType != myHUD.Class))))
	{
		NewHUD = Spawn(newHUDType, self);
		// End:0x8D
		if((NewHUD != none))
		{
			OldHUD = myHUD;
			myHUD = NewHUD;
			// End:0x8D
			if((OldHUD != none))
			{
				OldHUD.Destroy();
			}
		}
	}
	return;
}

// ViewFlash: interpolates FlashScale/FlashFog toward their goal values each tick to produce screen-flash effects.
function ViewFlash(float DeltaTime)
{
	local Vector goalFog;
	local float goalscale, Delta;

	Delta = FMin(0.1000000, DeltaTime);
	goalscale = ((1.0000000 + DesiredFlashScale) + ConstantGlowScale);
	goalFog = (DesiredFlashFog + ConstantGlowFog);
	// End:0x89
	if((Pawn != none))
	{
		(goalscale += Pawn.HeadVolume.ViewFlash.X);
		(goalFog += Pawn.HeadVolume.ViewFog);
	}
	(DesiredFlashScale -= ((DesiredFlashScale * float(2)) * Delta));
	(DesiredFlashFog -= ((DesiredFlashFog * float(2)) * Delta));
	(FlashScale.X += ((((goalscale - FlashScale.X) + InstantFlash) * float(10)) * Delta));
	(FlashFog += ((((goalFog - FlashFog) + InstantFog) * float(10)) * Delta));
	InstantFlash = 0.0000000;
	InstantFog = vect(0.0000000, 0.0000000, 0.0000000);
	// End:0x155
	if((FlashScale.X > 0.9810000))
	{
		FlashScale.X = 1.0000000;
	}
	FlashScale = (FlashScale.X * vect(1.0000000, 1.0000000, 1.0000000));
	// End:0x198
	if((FlashFog.X < 0.0190000))
	{
		FlashFog.X = 0.0000000;
	}
	// End:0x1BC
	if((FlashFog.Y < 0.0190000))
	{
		FlashFog.Y = 0.0000000;
	}
	// End:0x1E0
	if((FlashFog.Z < 0.0190000))
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
	if((type == 'None'))
	{
		type = 'Event';
	}
	TeamMessage(PlayerReplicationInfo, S, type);
	return;
}

event TeamMessage(PlayerReplicationInfo PRI, coerce string S, name type)
{
	// End:0x41
	if(((type == 'Say') || (type == 'TeamSay')))
	{
		S = ((PRI.PlayerName $ ": ") $ S);
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
	if((Pawn != none))
	{
		Pawn.PlaySound(ASound, eSlot);		
	}
	else
	{
		ViewTarget.PlaySound(ASound, eSlot);
	}
	return;
}

simulated function ClientStopSound(Sound ASound)
{
	// End:0x1F
	if((Pawn != none))
	{
		Pawn.StopSound(ASound);		
	}
	else
	{
		ViewTarget.StopSound(ASound);
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
	if((Pawn != none))
	{
		Pawn.Health = 0;
		Pawn.Died(self, Pawn.Location);
	}
	// End:0x60
	if((CheatManager != none))
	{
		CheatManager.ClearOuter();
	}
	CheatManager = none;
	// End:0x7E
	if((PlayerInput != none))
	{
		PlayerInput.ClearOuter();
	}
	PlayerInput = none;
	super.Destroyed();
	myHUD.Destroy();
	myHUD = none;
	J0x9E:

	// End:0xD7 [Loop If]
	if((FreeMoves != none))
	{
		Next = FreeMoves.NextMove;
		FreeMoves.Destroy();
		FreeMoves = Next;
		// [Loop Continue]
		goto J0x9E;
	}
	J0xD7:

	// End:0x110 [Loop If]
	if((SavedMoves != none))
	{
		Next = SavedMoves.NextMove;
		SavedMoves.Destroy();
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
	if((DefaultFOV != DesiredFOV))
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
	if(((Msg == "") || (int(Level.NetMode) == int(NM_Standalone))))
	{
		return;
	}
	Level.Game.Broadcast(self, Msg, 'Say');
	return;
}

exec function TeamSay(string Msg)
{
	// End:0x29
	if(((Msg == "") || (int(Level.NetMode) == int(NM_Standalone))))
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
	Log(((((((("Getting " $ string(Skin1)) $ ") $ string(Skin2)) $ ") $ string(Skin3)) $ ") $ string(Skin4)));
	return;
	return;
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	local VoicePack V;

	// End:0x39
	if((((Sender == none) || (Sender.VoiceType == none)) || (Player.Console == none)))
	{
		return;
	}
	V = Spawn(Sender.VoiceType, self);
	// End:0x7F
	if((V != none))
	{
		V.ClientInitialize(Sender, Recipient, messagetype, messageID);
	}
	return;
}

function ForceDeathUpdate()
{
	LastUpdateTime = (Level.TimeSeconds - float(10));
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
	// Drop duplicate or out-of-order moves.
	if((CurrentTimeStamp >= TimeStamp))
	{
		return;
	}
	// End:0x1DB
	if((int(OldTimeDelta) != 0))
	{
		OldTimeStamp = ((TimeStamp - (float(OldTimeDelta) / float(500))) - 0.0010000);
		// End:0x1DB
		if((CurrentTimeStamp < (OldTimeStamp - 0.0010000)))
		{
			// Unpack OldAccel: bits 30-23 = X, bits 22-15 = Y, bits 14-7 = Z (sign in bit 7 of each byte).
			Accel.X = float((OldAccel >>> 23));
			// End:0xA3
			if((Accel.X > float(127)))
			{
				Accel.X = (-1.0000000 * (Accel.X - float(128)));
			}
			Accel.Y = float((int(float((OldAccel >>> 15))) & 255));
			// End:0xF6
			if((Accel.Y > float(127)))
			{
				Accel.Y = (-1.0000000 * (Accel.Y - float(128)));
			}
			Accel.Z = float((int(float((OldAccel >>> 7))) & 255));
			// End:0x149
			if((Accel.Z > float(127)))
			{
				Accel.Z = (-1.0000000 * (Accel.Z - float(128)));
			}
			(Accel *= float(20));
			OldbRun = ((OldAccel & 64) != 0);
			OldbDuck = ((OldAccel & 32) != 0);
			OldbCrawl = ((OldAccel & 16) != 0);
			OldDoubleClickMove = 0;
			MoveAutonomous((OldTimeStamp - CurrentTimeStamp), OldbRun, OldbDuck, OldbCrawl, OldDoubleClickMove, Accel, rot(0, 0, 0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}
	// View is a packed int: high 15 bits = pitch/2, low 15 bits = yaw/2; 32768 = 180 deg.
	ViewPitch = (View / 32768);
	ViewYaw = (2 * (View - (32768 * ViewPitch)));
	(ViewPitch *= float(2));
	Accel = (InAccel / float(10));
	DeltaTime = (TimeStamp - CurrentTimeStamp);
	// End:0x2BD
	// Detect and throttle time-margin abuse (speed hacking): client moved faster than wall-clock time.
	if((ServerTimeStamp > float(0)))
	{
		(TimeMargin += (DeltaTime - (1.0100000 * (Level.TimeSeconds - ServerTimeStamp))));
		// End:0x2BD
		// Client is exceeding the allowed time margin; discard excess delta.
		if((TimeMargin > MaxTimeMargin))
		{
			(TimeMargin -= DeltaTime);
			// End:0x2A7
			if((TimeMargin < 0.5000000))
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
	SetRotation(ViewRot);
	// End:0x48E
	if((Pawn != none))
	{
		rNewRotOffset.Pitch = (2 * (iNewRotOffset / 32768));
		rNewRotOffset.Yaw = (2 * (32767 & iNewRotOffset));
		Pawn.m_rRotationOffset = rNewRotOffset;
		Rot.Roll = 0;
		Rot.Yaw = ViewYaw;
		// End:0x3C0
		// Physics 3 = Swimming, 4 = Flying; both allow steeper pitch (double limit).
		if(((int(Pawn.Physics) == int(3)) || (int(Pawn.Physics) == int(4))))
		{
			maxPitch = 2;			
		}
		else
		{
			maxPitch = 1;
		}
		// End:0x45A
		// 65536 = 360 deg; 32768 = 180 deg. Clamp pitch to avoid degenerate up/down angles.
		if(((ViewPitch > (maxPitch * RotationRate.Pitch)) && (ViewPitch < (65536 - (maxPitch * RotationRate.Pitch)))))
		{
			// End:0x434
			if((ViewPitch < 32768))
			{
				Rot.Pitch = (maxPitch * RotationRate.Pitch);				
			}
			else
			{
				Rot.Pitch = (65536 - (maxPitch * RotationRate.Pitch));
			}			
		}
		else
		{
			Rot.Pitch = ViewPitch;
		}
		DeltaRot = (Rotation - Rot);
		Pawn.SetRotation(Rot);
	}
	// End:0x4DA
	if(((Level.Pauser == none) && (DeltaTime > float(0))))
	{
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbCrawl, 0, Accel, DeltaRot);
	}
	// End:0x507
	// Force correction if too much time has passed since last position update.
	if(((Level.TimeSeconds - LastUpdateTime) > 0.3000000))
	{
		clientErr = 10000.0000000;		
	}
	else
	{
		// End:0x585
		if(((Level.TimeSeconds - LastUpdateTime) > (180.0000000 / float(Player.CurrentNetSpeed))))
		{
			// End:0x558
			if((Pawn == none))
			{
				LocDiff = (Location - ClientLoc);				
			}
			else
			{
				LocDiff = (Pawn.Location - ClientLoc);
			}
			clientErr = Dot(LocDiff, LocDiff);
		}
	}
	// End:0x84B
	// Send position correction if squared distance error exceeds 3 UU (avoid floating-point noise).
	if((clientErr > float(3)))
	{
		// End:0x5C2
		if((Pawn == none))
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
			if((Mover(Pawn.Base) != none))
			{
				ClientLoc = (Pawn.Location - Pawn.Base.Location);				
			}
			else
			{
				ClientLoc = Pawn.Location;
			}
			ClientFloor = Pawn.Floor;
		}
		LastUpdateTime = Level.TimeSeconds;
		// End:0x6A8
		if((m_SaveOldClientBase != ClientBase))
		{
			m_SaveOldClientBase = ClientBase;
			ClientAdjustBase(ClientBase);
		}
		// End:0x7D9
		if(((Pawn == none) || (int(Pawn.Physics) != int(9))))
		{
			// End:0x782
			if((ClientVel == vect(0.0000000, 0.0000000, 0.0000000)))
			{
				// End:0x749
				if(((IsInState('PlayerWalking') && (Pawn != none)) && (int(Pawn.Physics) == int(1))))
				{
					VeryShortClientAdjustPosition(TimeStamp, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, ClientBase);					
				}
				else
				{
					ShortClientAdjustPosition(TimeStamp, GetStateName(), ClientPhysics, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, ClientBase);
				}				
			}
			else
			{
				ClientAdjustPosition(TimeStamp, GetStateName(), ClientPhysics, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, ClientVel.X, ClientVel.Y, ClientVel.Z, ClientBase);
			}			
		}
		else
		{
			LongClientAdjustPosition(TimeStamp, GetStateName(), ClientPhysics, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, ClientVel.X, ClientVel.Y, ClientVel.Z, ClientBase, ClientFloor.X, ClientFloor.Y, ClientFloor.Z);
		}
	}
	return;
}

function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
{
	// End:0x1F
	if((Pawn != none))
	{
		Pawn.Acceleration = NewAccel;
	}
	return;
}

// NEW IN 1.60
// Re-executes a single move on both client and server to keep physics in sync (client-side prediction).
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
	// Duck/crawl state is only applied on the server; clients trust their own input.
	if((int(Level.NetMode) != int(NM_Client)))
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
	if((Pawn != none))
	{
		Pawn.AutonomousPhysics(DeltaTime);		
	}
	else
	{
		AutonomousPhysics(DeltaTime);
	}
	// End:0xE7
	if((Pawn != none))
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
	if((Pawn != none))
	{
		Floor = Pawn.Floor;
	}
	// End:0x62
	if((((Pawn != none) && (int(Pawn.Physics) != int(1))) && (int(Pawn.Physics) != int(0))))
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
	if((Pawn != none))
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
	if((Pawn != none))
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
	if((Pawn != none))
	{
		// End:0x3E
		// bNetOwner is true only on the owning client; non-owners update eye location from bone data.
		if((!bNetOwner))
		{
			Pawn.m_vEyeLocation = Pawn.GetBoneCoords('R6 PonyTail1').Origin;
		}
		// End:0x6D
		if((Pawn.bTearOff || Pawn.m_bUseRagdoll))
		{
			GotoState('Dead');
			return;
		}
		MoveActor = Pawn;		
	}
	else
	{
		MoveActor = self;
	}
	// End:0x93
	// Discard corrections for moves already processed (arrived out-of-order).
	if((CurrentTimeStamp > TimeStamp))
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
	MoveActor.SetBase(NewBase, NewFloor);
	// End:0x184
	// Mover bases use relative coordinates; offset to world space.
	if((Mover(NewBase) != none))
	{
		(NewLocation += NewBase.Location);
	}
	// End:0x1CF
	if((NewLocation != MoveActor.Location))
	{
		MoveActor.bCanTeleport = false;
		MoveActor.SetLocation(NewLocation);
		MoveActor.bCanTeleport = true;
	}
	// End:0x227
	if((int(newPhysics) != int(MoveActor.Physics)))
	{
		// End:0x227
		if(((int(newPhysics) != int(14)) && (int(MoveActor.Physics) != int(14))))
		{
			MoveActor.SetPhysics(newPhysics);
		}
	}
	// End:0x23B
	if((GetStateName() != NewState))
	{
		GotoState(NewState);
	}
	bUpdatePosition = true;
	return;
}

function ClientAdjustBase(Actor newClientBase)
{
	local Actor MoveActor;

	// End:0x19
	if((Pawn != none))
	{
		MoveActor = Pawn;		
	}
	else
	{
		MoveActor = self;
	}
	MoveActor.SetBase(newClientBase);
	return;
}

// ClientUpdatePosition: client re-simulates all unacknowledged SavedMoves after receiving a server correction.
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
	if((CurrentMove != none))
	{
		// End:0xB5
		if((CurrentMove.TimeStamp <= CurrentTimeStamp))
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;			
		}
		else
		{
			(TotalTime += CurrentMove.Delta);
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
	foreach DynamicActors(Class'Engine.Pawn', P)
	{
		// End:0x134
		if((((P != Pawn) && (P.Velocity != vect(0.0000000, 0.0000000, 0.0000000))) && P.bBlockPlayers))
		{
			Dir = Normal((P.Location - Pawn.Location));
			// End:0x134
			if(((Dot(Pawn.Velocity, Dir) > float(0)) && (Dot(P.Velocity, Dir) > float(0))))
			{
				// End:0x134
				if((VSize((P.Location - Pawn.Location)) < ((P.CollisionRadius + Pawn.CollisionRadius) + MaxMove)))
				{
					P.MoveSmooth(((P.Velocity * 0.5000000) * float(PlayerReplicationInfo.Ping)));
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
	if((FreeMoves == none))
	{
		S = SavedMoves;
		J0x16:

		// End:0xEA [Loop If]
		if((S != none))
		{
			(i++);
			// End:0xD3
			// Too many saved moves (> 30); flush the buffer to prevent unbounded growth.
			if((i > 30))
			{
				first = SavedMoves;
				SavedMoves = SavedMoves.NextMove;
				first.Clear();
				first.NextMove = none;
				J0x72:

				// End:0xCD [Loop If]
				if((SavedMoves != none))
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
		return Spawn(Class'Engine.SavedMove');		
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

// CompressAccel: packs a signed acceleration component into 8 bits; sign in bit 7, magnitude in bits 0-6.
function int CompressAccel(int C)
{
	// End:0x1D
	if((C >= 0))
	{
		C = Min(C, 127);		
	}
	else
	{
		C = (Min(int(Abs(float(C))), 127) + 128);
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
	if((PendingMove != none))
	{
		PendingMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);
	}
	// End:0x16C
	if((SavedMoves != none))
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		J0x4D:

		// End:0xF2 [Loop If]
		if((NewMove.NextMove != none))
		{
			// End:0xDB
			if((((int(NewMove.DoubleClickMove) != int(0)) && (int(NewMove.DoubleClickMove) < 5)) || ((NewMove.Acceleration != NewAccel) && (Dot(Normal(NewMove.Acceleration), AccelNorm) < 0.9500000))))
			{
				OldMove = NewMove;
			}
			NewMove = NewMove.NextMove;
			// [Loop Continue]
			goto J0x4D;
		}
		// End:0x16C
		if((((int(NewMove.DoubleClickMove) != int(0)) && (int(NewMove.DoubleClickMove) < 5)) || ((NewMove.Acceleration != NewAccel) && (Dot(Normal(NewMove.Acceleration), AccelNorm) < 0.9500000))))
		{
			OldMove = NewMove;
		}
	}
	LastMove = NewMove;
	NewMove = GetFreeMove();
	// End:0x190
	if((NewMove == none))
	{
		return;
	}
	NewMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DoubleClickMove, DeltaRot);
	// End:0x20C
	if((Pawn != none))
	{
		Pawn.AutonomousPhysics(NewMove.Delta);		
	}
	else
	{
		AutonomousPhysics(DeltaTime);
	}
	// End:0x22D
	if((PendingMove == none))
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
	NetMoveDelta = FMax((80.0000000 / float(Player.CurrentNetSpeed)), 0.0150000); // minimum time between server updates, scaled by net speed
	// End:0x2AE
	if((PendingMove.Delta < (NetMoveDelta - ClientUpdateTime)))
	{
		return;		
	}
	else
	{
		// End:0x2E1
		if(((ClientUpdateTime < float(0)) && (PendingMove.Delta < (NetMoveDelta - ClientUpdateTime))))
		{
			return;			
		}
		else
		{
			ClientUpdateTime = (PendingMove.Delta - NetMoveDelta);
			// End:0x315
			if((SavedMoves == none))
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
	if((OldMove != none))
	{
		OldTimeDelta = FMin(255.0000000, ((Level.TimeSeconds - OldMove.TimeStamp) * float(500)));
		BuildAccel = ((0.0500000 * OldMove.Acceleration) + vect(0.5000000, 0.5000000, 0.5000000));
		// Pack X/Y/Z acceleration into a single int: bits 30-23 = X, 22-15 = Y, 14-7 = Z; bits 6-0 = flags.
		OldAccel = (((CompressAccel(int(BuildAccel.X)) << 23) + (CompressAccel(int(BuildAccel.Y)) << 15)) + (CompressAccel(int(BuildAccel.Z)) << 7));
		// End:0x400
		if(OldMove.bRun)
		{
			(OldAccel += 64);
		}
		// End:0x41B
		if(OldMove.bDuck)
		{
			(OldAccel += 32);
		}
		// End:0x436
		if(OldMove.m_bCrawl)
		{
			(OldAccel += 16);
		}
		(OldAccel += int(OldMove.DoubleClickMove));
	}
	// End:0x466
	if((Pawn == none))
	{
		MoveLoc = Location;		
	}
	else
	{
		rSendRot = Pawn.m_rRotationOffset;
		MoveLoc = Pawn.Location;
	}
	// End:0x4C9
	if((Level.TimeSeconds > m_fNextUpdateTime))
	{
		m_fNextUpdateTime = (Level.TimeSeconds + (float(1) / NetClientMaxTickRate));		
	}
	else
	{
		return;
	}
	// End:0x67A
	// Choose the most compact move RPC: ShorterServerMove omits acceleration, ShortServerMove omits it too.
	// View is packed as: high 15 bits = pitch/2, low 15 bits = yaw/2 (32768 = 180 deg separator).
	if(((NewMove.Acceleration == vect(0.0000000, 0.0000000, 0.0000000)) && (int(NewMove.DoubleClickMove) == int(0))))
	{
		// End:0x5CB
		if((((NewMove.bDuck == false) && (NewMove.bRun == false)) && (NewMove.m_bCrawl == false)))
		{
			ShorterServerMove(NewMove.TimeStamp, MoveLoc, (((32767 & (Rotation.Pitch / 2)) * 32768) + (32767 & (Rotation.Yaw / 2))), (((32767 & (rSendRot.Pitch / 2)) * 32768) + (32767 & (rSendRot.Yaw / 2))));			
		}
		else
		{
			ShortServerMove(NewMove.TimeStamp, MoveLoc, NewMove.bRun, NewMove.bDuck, NewMove.m_bCrawl, (((32767 & (Rotation.Pitch / 2)) * 32768) + (32767 & (Rotation.Yaw / 2))), (((32767 & (rSendRot.Pitch / 2)) * 32768) + (32767 & (rSendRot.Yaw / 2))));
		}		
	}
	else
	{
		ServerMove(NewMove.TimeStamp, (NewMove.Acceleration * float(10)), MoveLoc, NewMove.bRun, NewMove.bDuck, NewMove.m_bCrawl, (((32767 & (Rotation.Pitch / 2)) * 32768) + (32767 & (Rotation.Yaw / 2))), (((32767 & (rSendRot.Pitch / 2)) * 32768) + (32767 & (rSendRot.Yaw / 2))), byte(OldTimeDelta), OldAccel);
	}
	return;
}

function HandleWalking()
{
	// End:0x50
	if((Pawn != none))
	{
		Pawn.SetWalking((((int(bRun) != 0) || (int(bDuck) != 0)) && (!Region.Zone.IsA('WarpZoneInfo'))));
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
	DesiredFlashFog = (0.0010000 * fog);
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
	InstantFog = (0.0010000 * fog);
	return;
}

function ClientAdjustGlow(float Scale, Vector fog)
{
	(ConstantGlowScale += Scale);
	(ConstantGlowFog += (0.0010000 * fog));
	return;
}

private function ClientShake(Vector ShakeRoll, Vector OffsetMag, Vector ShakeRate, float OffsetTime)
{
	// End:0x6F
	if(((MaxShakeRoll < ShakeRoll.X) || (ShakeRollTime < (0.0100000 * ShakeRoll.Y))))
	{
		MaxShakeRoll = ShakeRoll.X;
		ShakeRollTime = (0.0100000 * ShakeRoll.Y);
		ShakeRollRate = (0.0100000 * ShakeRoll.Z);
	}
	// End:0xB2
	if((VSize(OffsetMag) > VSize(MaxShakeOffset)))
	{
		ShakeOffsetTime = (OffsetTime * vect(1.0000000, 1.0000000, 1.0000000));
		MaxShakeOffset = OffsetMag;
		ShakeOffsetRate = ShakeRate;
	}
	return;
}

function ShakeView(float shaketime, float RollMag, Vector OffsetMag, float RollRate, Vector OffsetRate, float OffsetTime)
{
	local Vector ShakeRoll;

	ShakeRoll.X = RollMag;
	ShakeRoll.Y = (100.0000000 * shaketime);
	ShakeRoll.Z = (100.0000000 * RollRate);
	ClientShake(ShakeRoll, OffsetMag, OffsetRate, OffsetTime);
	return;
}

function Typing(bool bTyping)
{
	bIsTyping = bTyping;
	// End:0x48
	if(((bTyping && (Pawn != none)) && (!Pawn.bTearOff)))
	{
		Pawn.ChangeAnimation();
	}
	// End:0x8D
	if((Level.Game.StatLog != none))
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
	if((InPlanningMode() && (!Level.m_bInGamePlanningActive)))
	{
		szResult = ("INPUTPLANNING" @ szKeyAndCommand);		
	}
	else
	{
		szResult = ("INPUT" @ szKeyAndCommand);
	}
	SetKey(szResult);
	iPos = InStr(szKeyAndCommand, " ");
	szResult = Right(szKeyAndCommand, ((Len(szKeyAndCommand) - iPos) - 1));
	// End:0xEF
	if((szResult ~= "CONSOLE"))
	{
		// End:0xCB
		if((InPlanningMode() && (!Level.m_bInGamePlanningActive)))
		{
			szResult = ("INPUT" @ szKeyAndCommand);			
		}
		else
		{
			szResult = ("INPUTPLANNING" @ szKeyAndCommand);
		}
		SetKey(szResult);
	}
	return;
}

exec function SetOption(string szKeyAndCommand)
{
	local string szResult;

	szResult = ("R6GAMEOPTIONS" @ szKeyAndCommand);
	SetKey(szResult);
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
	if((Level.Pauser == PlayerReplicationInfo))
	{
		SetPause(false);
		return;
	}
	// End:0x75
	if((((Pawn != none) && (Pawn.EngineWeapon != none)) && (!GameReplicationInfo.m_bGameOverRep)))
	{
		Pawn.EngineWeapon.Fire(f);
	}
	return;
}

// The player wants to alternate-fire.
exec function AltFire(optional float f)
{
	// End:0x21
	if((Level.Pauser == PlayerReplicationInfo))
	{
		SetPause(false);
		return;
	}
	// End:0x52
	if((Pawn.EngineWeapon != none))
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

	iChangeNameTime = Class'Engine.Actor'.static.GetGameOptions().ChangeNameTime;
	// End:0x88
	if((((m_iChangeNameLastTime == 0) || (Level.TimeSeconds > float((m_iChangeNameLastTime + iChangeNameTime)))) || (int(Level.NetMode) == int(NM_Standalone))))
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
	if((Len(S) > 15))
	{
		S = Left(S, 15);
	}
	ReplaceText(S, " ", "_");
	ReplaceText(S, "~", "_");
	ReplaceText(S, "?", "_");
	ReplaceText(S, ",", "_");
	ReplaceText(S, "#", "_");
	ReplaceText(S, "/", "_");
	S = RemoveInvalidChars(S);
	UpdateURL("Name", S, true);
	SaveConfig();
	Class'Engine.Actor'.static.GetGameOptions().characterName = S;
	Class'Engine.Actor'.static.GetGameOptions().SaveConfig();
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
	if((Len(S) > 15))
	{
		S = Left(S, 15);
	}
	ReplaceText(S, " ", "_");
	ReplaceText(S, "~", "_");
	ReplaceText(S, "?", "_");
	ReplaceText(S, ",", "_");
	ReplaceText(S, "#", "_");
	ReplaceText(S, "/", "_");
	S = RemoveInvalidChars(S);
	// End:0xC8
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		Level.Game.ChangeName(self, S, false);
	}
	return;
}

exec event SetProgressTime(float t)
{
	ProgressTimeOut = (t + Level.TimeSeconds);
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
	if(IsInState(NewState))
	{
		BeginState();		
	}
	else
	{
		GotoState(NewState);
	}
	return;
}

function ClientReStart()
{
	// End:0x14
	if((Pawn == none))
	{
		GotoState('WaitingForPawn');
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
	if((!CheatManager.CanExec()))
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
	if((Pawn.Health <= 0))
	{
		Pawn.Health = Pawn.default.Health;
	}
	return;
}

event PlayerTick(float DeltaTime)
{
	// Process raw key/axis input first, populating aForward, aTurn, etc.
	PlayerInput.PlayerInput(DeltaTime);
	// End:0x23
	// bUpdatePosition is set by LongClientAdjustPosition when the server corrects us.
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
	if((Other.Controller == none))
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

// AdjustView: smoothly tracks DesiredFOV each frame; also increments zoom level when bZooming is set.
function AdjustView(float DeltaTime)
{
	// End:0x9F
	if((FovAngle != DesiredFOV))
	{
		// End:0x4F
		if((FovAngle > DesiredFOV))
		{
			FovAngle = (FovAngle - FMax(7.0000000, ((0.9000000 * DeltaTime) * (FovAngle - DesiredFOV))));			
		}
		else
		{
			FovAngle = (FovAngle - FMin(-7.0000000, ((0.9000000 * DeltaTime) * (FovAngle - DesiredFOV))));
		}
		// End:0x9F
		if((Abs((FovAngle - DesiredFOV)) <= float(10)))
		{
			FovAngle = DesiredFOV;
		}
	}
	// End:0xFA
	if(bZooming)
	{
		(ZoomLevel += (DeltaTime * 1.0000000));
		// End:0xD5
		if((ZoomLevel > 0.9000000))
		{
			ZoomLevel = 0.9000000;
		}
		DesiredFOV = FClamp((90.0000000 - (ZoomLevel * 88.0000000)), 1.0000000, 170.0000000);
	}
	return;
}

// CalcBehindView: places camera behind the pawn at 'Dist' units, pulling closer if a wall blocks the ray.
function CalcBehindView(out Vector CameraLocation, out Rotator CameraRotation, float Dist)
{
	local Vector View, HitLocation, HitNormal;
	local float ViewDist;

	CameraRotation = Rotation;
	View = (vect(1.0000000, 0.0000000, 0.0000000) >> CameraRotation);
	// End:0x7C
	if((Trace(HitLocation, HitNormal, (CameraLocation - ((Dist + float(30)) * Vector(CameraRotation))), CameraLocation) != none))
	{
		ViewDist = FMin(Dot((CameraLocation - HitLocation), View), Dist);		
	}
	else
	{
		ViewDist = Dist;
	}
	(CameraLocation -= ((ViewDist - float(30)) * View));
	return;
}

// CalcFirstPersonView: positions the camera at the pawn eye location and applies camera shake offset.
function CalcFirstPersonView(out Vector CameraLocation, out Rotator CameraRotation)
{
	CameraRotation = Rotation;
	CameraLocation = ((CameraLocation + Pawn.EyePosition()) + ShakeOffset);
	return;
}

event AddCameraEffect(CameraEffect NewEffect, optional bool RemoveExisting)
{
	// End:0x14
	if(RemoveExisting)
	{
		RemoveCameraEffect(NewEffect);
	}
	CameraEffects.Length = (CameraEffects.Length + 1);
	CameraEffects[(CameraEffects.Length - 1)] = NewEffect;
	return;
}

event RemoveCameraEffect(CameraEffect ExEffect)
{
	local int EffectIndex;

	EffectIndex = 0;
	J0x07:

	// End:0x44 [Loop If]
	if((EffectIndex < CameraEffects.Length))
	{
		// End:0x3A
		if((CameraEffects[EffectIndex] == ExEffect))
		{
			CameraEffects.Remove(EffectIndex, 1);
			return;
		}
		(EffectIndex++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function Rotator GetViewRotation()
{
	// End:0x25
	if((bBehindView && (Pawn != none)))
	{
		return Pawn.Rotation;
	}
	return Rotation;
	return;
}

// PlayerCalcView: main camera calculation entry point; routes to CalcFirstPersonView or CalcBehindView.
event PlayerCalcView(out Actor ViewActor, out Vector CameraLocation, out Rotator CameraRotation)
{
	local Pawn PTarget;

	// End:0x78
	if(((ViewTarget == none) || ViewTarget.bDeleteMe))
	{
		Log("No VIEWTARGET in PlayerCalcView");
		// End:0x71
		if(((Pawn != none) && (!Pawn.bDeleteMe)))
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
	if((ViewTarget == Pawn))
	{
		// End:0xD7
		if(bBehindView)
		{
			CalcBehindView(CameraLocation, CameraRotation, (CameraDist * Pawn.default.CollisionRadius));			
		}
		else
		{
			CalcFirstPersonView(CameraLocation, CameraRotation);
		}
		return;
	}
	// End:0x124
	if((ViewTarget == self))
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
		if((ViewTarget != none))
		{
			// End:0x165
			if(bBehindView)
			{
				CalcBehindView(CameraLocation, CameraRotation, (CameraDist * Pawn(ViewTarget).default.CollisionRadius));				
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
	if((PTarget != none))
	{
		// End:0x1F3
		if((int(Level.NetMode) == int(NM_Client)))
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
		if((!bBehindView))
		{
			(CameraLocation += PTarget.EyePosition());
		}
	}
	// End:0x2A3
	if(bBehindView)
	{
		CameraLocation = (CameraLocation + ((ViewTarget.default.CollisionHeight - ViewTarget.CollisionHeight) * vect(0.0000000, 0.0000000, 1.0000000)));
		CalcBehindView(CameraLocation, CameraRotation, (CameraDist * ViewTarget.default.CollisionRadius));
	}
	return;
}

// CheckShake: advances one shake axis, reversing direction and decaying amplitude each bounce.
function CheckShake(out float MaxOffset, out float offset, out float Rate, out float Time)
{
	// End:0x15
	if((Abs(offset) < Abs(MaxOffset)))
	{
		return;
	}
	offset = MaxOffset;
	// End:0x92
	if((Time > float(1)))
	{
		// End:0x69
		if(((Time * Abs((MaxOffset / Rate))) <= float(1)))
		{
			MaxOffset = (MaxOffset * ((float(1) / Time) - float(1)));			
		}
		else
		{
			(MaxOffset *= float(-1));
		}
		(Time -= float(1));
		(Rate *= float(-1));		
	}
	else
	{
		MaxOffset = 0.0000000;
		offset = 0.0000000;
		Rate = 0.0000000;
	}
	return;
}

// ViewShake: applies per-axis positional shake and optional roll to the controller rotation each tick.
function ViewShake(float DeltaTime)
{
	local Rotator ViewRotation;
	local float FRoll;

	// End:0xF8
	if((ShakeOffsetRate != vect(0.0000000, 0.0000000, 0.0000000)))
	{
		(ShakeOffset.X += (DeltaTime * ShakeOffsetRate.X));
		CheckShake(MaxShakeOffset.X, ShakeOffset.X, ShakeOffsetRate.X, ShakeOffsetTime.X);
		(ShakeOffset.Y += (DeltaTime * ShakeOffsetRate.Y));
		CheckShake(MaxShakeOffset.Y, ShakeOffset.Y, ShakeOffsetRate.Y, ShakeOffsetTime.Y);
		(ShakeOffset.Z += (DeltaTime * ShakeOffsetRate.Z));
		CheckShake(MaxShakeOffset.Z, ShakeOffset.Z, ShakeOffsetRate.Z, ShakeOffsetTime.Z);
	}
	ViewRotation = Rotation;
	// End:0x1AB
	if((ShakeRollRate != float(0)))
	{
		ViewRotation.Roll = (int((float((ViewRotation.Roll & 65535)) + (ShakeRollRate * DeltaTime))) & 65535);
		// End:0x16A
		// 32768 = 180 deg; convert unsigned roll to signed range [-32768, 32767].
		if((ViewRotation.Roll > 32768))
		{
			(ViewRotation.Roll -= 65536);
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
	SetRotation(ViewRotation);
	return;
}

function bool TurnTowardNearestEnemy()
{
	return;
}

function TurnAround()
{
	// End:0x2F
	if((!bSetTurnRot))
	{
		TurnRot180 = Rotation;
		(TurnRot180.Yaw += 32768); // 32768 = 180 deg in Unreal rotator units
		bSetTurnRot = true;
	}
	DesiredRotation = TurnRot180;
	bRotateToDesired = (DesiredRotation.Yaw != Rotation.Yaw);
	return;
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
	local Rotator NewRotation, ViewRotation;

	// End:0x37
	if((bInterpolating || ((Pawn != none) && Pawn.bInterpolating)))
	{
		ViewShake(DeltaTime);
		return;
	}
	ViewRotation = Rotation;
	DesiredRotation = ViewRotation;
	// End:0x63
	if((int(bTurnToNearest) != 0))
	{
		TurnTowardNearestEnemy();		
	}
	else
	{
		// End:0x79
		if((int(bTurn180) != 0))
		{
			TurnAround();			
		}
		else
		{
			TurnTarget = none;
			bRotateToDesired = false;
			bSetTurnRot = false;
			(ViewRotation.Yaw += int(((32.0000000 * DeltaTime) * aTurn)));
			(ViewRotation.Pitch += int(((32.0000000 * DeltaTime) * aLookUp)));
		}
	}
	// Wrap pitch to [0, 65535] (65536 = 360 deg) before clamping.
	ViewRotation.Pitch = (ViewRotation.Pitch & 65535);
	// End:0x148
	// Clamp pitch to avoid gimbal wrap: 18000 (~99 deg up) and 49152 (270 deg = ~-90 deg down).
	if(((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152)))
	{
		// End:0x138
		if((aLookUp > float(0)))
		{
			ViewRotation.Pitch = 18000;			
		}
		else
		{
			ViewRotation.Pitch = 49152;
		}
	}
	SetRotation(ViewRotation);
	ViewShake(DeltaTime);
	ViewFlash(DeltaTime);
	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;
	// End:0x1D1
	if((((!bRotateToDesired) && (Pawn != none)) && ((!bFreeCamera) || (!bBehindView))))
	{
		Pawn.FaceRotation(NewRotation, DeltaTime);
	}
	return;
}

function ClearDoubleClick()
{
	// End:0x1F
	if((PlayerInput != none))
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
	if((C != none))
	{
		Log(((("Check spectate " $ string(C.Pawn)) $ " can ") $ string(Level.Game.CanSpectate(self, true, C.Pawn))));
		// End:0x12D
		if(((C.Pawn != none) && Level.Game.CanSpectate(self, true, C.Pawn)))
		{
			// End:0xEE
			if((Pick == none))
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
				bFound = (ViewTarget == C.Pawn);
			}
		}
		C = C.nextController;
		// [Loop Continue]
		goto J0x29;
	}
	J0x144:

	Log(("best is " $ string(Pick)));
	SetViewTarget(Pick);
	Log(("Viewtarget is " $ string(ViewTarget)));
	// End:0x195
	if((ViewTarget == self))
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

// PlayerWalking: normal on-foot movement state; handles walking, running, crouching, and jumping on ground.
state PlayerWalking
{
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		// End:0x22
		if(NewVolume.bWaterVolume)
		{
			GotoState(Pawn.WaterMovementState);
		}
		return false;
		return;
	}

	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		local Vector OldAccel;
		local bool OldCrouch;

		// End:0x0D
		if((Pawn == none))
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
		if((int(Pawn.Physics) != int(2)))
		{
			OldCrouch = Pawn.bWantsToCrouch;
			// End:0xA2
			if((int(bDuck) == 0))
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

		GetAxes(Pawn.Rotation, X, Y, Z);
		NewAccel = ((aForward * X) + (aStrafe * Y));
		NewAccel.Z = 0.0000000;
		// End:0x73
		if((VSize(NewAccel) < 1.0000000))
		{
			NewAccel = vect(0.0000000, 0.0000000, 0.0000000);
		}
		DoubleClickMove = PlayerInput.CheckForDoubleClickMove(DeltaTime);
		GroundPitch = 0;
		ViewRotation = Rotation;
		// End:0x176
		if((int(Pawn.Physics) != int(1)))
		{
			// End:0x176
			if((((!bKeyboardLook) && (int(bLook) == 0)) && bCenterView))
			{
				ViewRotation.Pitch = (ViewRotation.Pitch & 65535);
				// End:0x11E
				if((ViewRotation.Pitch > 32768))
				{
					(ViewRotation.Pitch -= 65536);
				}
				ViewRotation.Pitch = int((float(ViewRotation.Pitch) * (float(1) - (float(12) * FMin(0.0833000, DeltaTime)))));
				// End:0x176
				if((Abs(float(ViewRotation.Pitch)) < float(1000)))
				{
					ViewRotation.Pitch = 0;
				}
			}
		}
		Pawn.CheckBob(DeltaTime, Y);
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1.0000000);
		// End:0x1E2
		if((bPressedJump && Pawn.CannotJumpNow()))
		{
			bSaveJump = true;
			bPressedJump = false;			
		}
		else
		{
			bSaveJump = false;
		}
		// End:0x21F
		// Client: bundle move and send to server. Server: apply the move locally.
		if((int(Role) < int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, (OldRotation - Rotation));			
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, (OldRotation - Rotation));
		}
		bPressedJump = bSaveJump;
		return;
	}

	function BeginState()
	{
		// End:0x23
		if((Pawn.Mesh == none))
		{
			Pawn.SetMesh();
		}
		DoubleClickDir = 0;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		// End:0x85
		if(((int(Pawn.Physics) != int(2)) && (int(Pawn.Physics) != int(13))))
		{
			Pawn.SetPhysics(1);
		}
		GroundPitch = 0;
		return;
	}

	function EndState()
	{
		GroundPitch = 0;
		// End:0x31
		if(((Pawn != none) && (int(bDuck) == 0)))
		{
			Pawn.ShouldCrouch(false);
		}
		return;
	}
	stop;
}

// PlayerClimbing: ladder movement state; binds forward input to the ladder's ClimbDir vector.
state PlayerClimbing
{
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		// End:0x25
		if(NewVolume.bWaterVolume)
		{
			GotoState(Pawn.WaterMovementState);			
		}
		else
		{
			GotoState(Pawn.LandMovementState);
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
			if((int(Pawn.Physics) == int(2)))
			{
				GotoState('PlayerWalking');
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

		GetAxes(Rotation, X, Y, Z);
		// End:0x51
		if((Pawn.OnLadder != none))
		{
			NewAccel = (aForward * Pawn.OnLadder.ClimbDir);			
		}
		else
		{
			NewAccel = ((aForward * X) + (aStrafe * Y));
		}
		// End:0x95
		if((VSize(NewAccel) < 1.0000000))
		{
			NewAccel = vect(0.0000000, 0.0000000, 0.0000000);
		}
		ViewRotation = Pawn.Rotation;
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1.0000000);
		// End:0x101
		// Client: bundle move and send to server. Server: apply the move locally.
		if((int(Role) < int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, (OldRotation - Rotation));			
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, (OldRotation - Rotation));
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
		if((Pawn != none))
		{
			Pawn.ShouldCrouch(false);
		}
		return;
	}
	stop;
}

// PlayerSpidering: wall-crawler state (PHYS_Spider = 9); player can walk on any surface normal.
state PlayerSpidering
{
	event bool NotifyHitWall(Vector HitNormal, Actor HitActor)
	{
		Pawn.SetPhysics(9);
		Pawn.SetBase(HitActor, HitNormal);
		return true;
		return;
	}

	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local Rotator TempRot, ViewRotation;
		local Vector MyFloor, CrossDir, FwdDir, OldFwdDir, OldX, RealFloor;

		// End:0x2A
		if((bInterpolating || Pawn.bInterpolating))
		{
			ViewShake(DeltaTime);
			return;
		}
		TurnTarget = none;
		bRotateToDesired = false;
		bSetTurnRot = false;
		// End:0x8D
		if(((Pawn.Base == none) || (Pawn.Floor == vect(0.0000000, 0.0000000, 0.0000000))))
		{
			MyFloor = vect(0.0000000, 0.0000000, 1.0000000);			
		}
		else
		{
			MyFloor = Pawn.Floor;
		}
		// End:0x206
		if((MyFloor != OldFloor))
		{
			RealFloor = MyFloor;
			MyFloor = Normal((((float(6) * DeltaTime) * MyFloor) + ((float(1) - (float(6) * DeltaTime)) * OldFloor)));
			// End:0x10F
			if((Dot(RealFloor, MyFloor) > 0.9990000))
			{
				MyFloor = RealFloor;
			}
			CrossDir = Normal(Cross(RealFloor, OldFloor));
			FwdDir = Cross(CrossDir, MyFloor);
			OldFwdDir = Cross(CrossDir, OldFloor);
			ViewX = (((MyFloor * Dot(OldFloor, ViewX)) + (CrossDir * Dot(CrossDir, ViewX))) + (FwdDir * Dot(OldFwdDir, ViewX)));
			ViewX = Normal(ViewX);
			ViewZ = (((MyFloor * Dot(OldFloor, ViewZ)) + (CrossDir * Dot(CrossDir, ViewZ))) + (FwdDir * Dot(OldFwdDir, ViewZ)));
			ViewZ = Normal(ViewZ);
			OldFloor = MyFloor;
			ViewY = Normal(Cross(MyFloor, ViewX));
		}
		// End:0x35C
		if(((aTurn != float(0)) || (aLookUp != float(0))))
		{
			// End:0x260
			if((aTurn != float(0)))
			{
				ViewX = Normal((ViewX + ((float(2) * ViewY) * Sin(((0.0005000 * DeltaTime) * aTurn)))));
			}
			// End:0x348
			if((aLookUp != float(0)))
			{
				OldX = ViewX;
				ViewX = Normal((ViewX + ((float(2) * ViewZ) * Sin(((0.0005000 * DeltaTime) * aLookUp)))));
				ViewZ = Normal(Cross(ViewX, ViewY));
				// End:0x348
				if((Dot(ViewZ, MyFloor) < 0.7070000))
				{
					OldX = Normal((OldX - (MyFloor * Dot(MyFloor, OldX))));
					// End:0x320
					if((Dot(ViewX, MyFloor) > float(0)))
					{
						ViewX = Normal((OldX + MyFloor));						
					}
					else
					{
						ViewX = Normal((OldX - MyFloor));
					}
					ViewZ = Normal(Cross(ViewX, ViewY));
				}
			}
			ViewY = Normal(Cross(MyFloor, ViewX));
		}
		ViewRotation = OrthoRotation(ViewX, ViewY, ViewZ);
		SetRotation(ViewRotation);
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
		Pawn.FaceRotation(ViewRotation, DeltaTime);
		return;
	}

	function bool NotifyLanded(Vector HitNormal)
	{
		Pawn.SetPhysics(9);
		return bUpdating;
		return;
	}

	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		// End:0x22
		if(NewVolume.bWaterVolume)
		{
			GotoState(Pawn.WaterMovementState);
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
		if((((!bKeyboardLook) && (int(bLook) == 0)) && bCenterView))
		{
		}
		Pawn.CheckBob(DeltaTime, vect(0.0000000, 0.0000000, 0.0000000));
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1.0000000);
		NewAccel = ((aForward * Normal((ViewX - (OldFloor * Dot(OldFloor, ViewX))))) + (aStrafe * ViewY));
		// End:0xD6
		if((VSize(NewAccel) < 1.0000000))
		{
			NewAccel = vect(0.0000000, 0.0000000, 0.0000000);
		}
		// End:0x106
		if((bPressedJump && Pawn.CannotJumpNow()))
		{
			bSaveJump = true;
			bPressedJump = false;			
		}
		else
		{
			bSaveJump = false;
		}
		// End:0x143
		// Client: bundle move and send to server. Server: apply the move locally.
		if((int(Role) < int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, (OldRotation - Rotation));			
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, (OldRotation - Rotation));
		}
		bPressedJump = bSaveJump;
		return;
	}

	function BeginState()
	{
		local Rotator newRot;

		// End:0x23
		if((Pawn.Mesh == none))
		{
			Pawn.SetMesh();
		}
		OldFloor = vect(0.0000000, 0.0000000, 1.0000000);
		GetAxes(Rotation, ViewX, ViewY, ViewZ);
		DoubleClickDir = 0;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		// End:0x93
		if((int(Pawn.Physics) != int(2)))
		{
			Pawn.SetPhysics(9);
		}
		GroundPitch = 0;
		Pawn.bCrawler = true;
		Pawn.SetCollisionSize(Pawn.default.CollisionHeight, Pawn.default.CollisionHeight);
		return;
	}

	function EndState()
	{
		GroundPitch = 0;
		// End:0x69
		if((Pawn != none))
		{
			Pawn.SetCollisionSize(Pawn.default.CollisionRadius, Pawn.default.CollisionHeight);
			Pawn.ShouldCrouch(false);
			Pawn.bCrawler = Pawn.default.bCrawler;
		}
		return;
	}
	stop;
}

// PlayerSwimming: underwater movement state (PHYS_Swimming = 3); includes water-jump detection.
state PlayerSwimming
{
	function bool WantsSmoothedView()
	{
		return (!Pawn.bJustLanded);
		return;
	}

	function bool NotifyLanded(Vector HitNormal)
	{
		// End:0x2C
		if(Pawn.PhysicsVolume.bWaterVolume)
		{
			Pawn.SetPhysics(3);			
		}
		else
		{
			GotoState(Pawn.LandMovementState);
		}
		return bUpdating;
		return;
	}

	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		local Actor HitActor;
		local Vector HitLocation, HitNormal, checkpoint;

		// End:0x171
		if((!NewVolume.bWaterVolume))
		{
			Pawn.SetPhysics(2);
			// End:0x9F
			if((Pawn.bUpAndOut && Pawn.CheckWaterJump(HitNormal)))
			{
				Pawn.Velocity.Z = (FMax(Pawn.JumpZ, 420.0000000) + (float(2) * Pawn.CollisionRadius));
				GotoState(Pawn.LandMovementState);				
			}
			else
			{
				// End:0xE4
				if(((Pawn.Velocity.Z > float(160)) || (!Pawn.TouchingWaterVolume())))
				{
					GotoState(Pawn.LandMovementState);					
				}
				else
				{
					checkpoint = Pawn.Location;
					(checkpoint.Z -= (Pawn.CollisionHeight + 6.0000000));
					HitActor = Trace(HitLocation, HitNormal, checkpoint, Pawn.Location, false);
					// End:0x15E
					if((HitActor != none))
					{
						GotoState(Pawn.LandMovementState);						
					}
					else
					{
						Enable('Timer');
						SetTimer(0.7000000, false);
					}
				}
			}			
		}
		else
		{
			Disable('Timer');
			Pawn.SetPhysics(3);
		}
		return false;
		return;
	}

	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		local Vector X, Y, Z, OldAccel;

		GetAxes(Rotation, X, Y, Z);
		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		Pawn.bUpAndOut = ((Dot(X, Pawn.Acceleration) > float(0)) && ((Pawn.Acceleration.Z > float(0)) || (Rotation.Pitch > 2048)));
		// End:0xCC
		if((!Pawn.PhysicsVolume.bWaterVolume))
		{
			NotifyPhysicsVolumeChange(Pawn.PhysicsVolume);
		}
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Rotator OldRotation;
		local Vector X, Y, Z, NewAccel;

		GetAxes(Rotation, X, Y, Z);
		NewAccel = (((aForward * X) + (aStrafe * Y)) + (aUp * vect(0.0000000, 0.0000000, 1.0000000)));
		// End:0x70
		if((VSize(NewAccel) < 1.0000000))
		{
			NewAccel = vect(0.0000000, 0.0000000, 0.0000000);
		}
		Pawn.CheckBob(DeltaTime, Y);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 2.0000000);
		// End:0xD6
		// Client: bundle move and send to server. Server: apply the move locally.
		if((int(Role) < int(ROLE_Authority)))
		{
			ReplicateMove(DeltaTime, NewAccel, 0, (OldRotation - Rotation));			
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, 0, (OldRotation - Rotation));
		}
		bPressedJump = false;
		return;
	}

	function Timer()
	{
		// End:0x3F
		if(((!Pawn.PhysicsVolume.bWaterVolume) && (int(Role) == int(ROLE_Authority))))
		{
			GotoState(Pawn.LandMovementState);
		}
		Disable('Timer');
		return;
	}

	function BeginState()
	{
		Disable('Timer');
		Pawn.SetPhysics(3);
		return;
	}
	stop;
}

// PlayerFlying: free-fly movement state (PHYS_Flying = 4); used for the noclip cheat.
state PlayerFlying
{
	function PlayerMove(float DeltaTime)
	{
		local Vector X, Y, Z;

		GetAxes(Rotation, X, Y, Z);
		Pawn.Acceleration = ((aForward * X) + (aStrafe * Y));
		// End:0x75
		if((VSize(Pawn.Acceleration) < 1.0000000))
		{
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		}
		// End:0xBC
		if((bCheatFlying && (Pawn.Acceleration == vect(0.0000000, 0.0000000, 0.0000000))))
		{
			Pawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		}
		UpdateRotation(DeltaTime, 2.0000000);
		// End:0x107
		// Client: bundle move and send to server. Server: apply the move locally.
		if((int(Role) < int(ROLE_Authority)))
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
		Pawn.SetPhysics(4); // PHYS_Flying
		return;
	}
	stop;
}

// PlayerHelicoptering: flying variant that also accepts vertical (aUp) axis input.
state PlayerHelicoptering extends PlayerFlying
{
	function PlayerMove(float DeltaTime)
	{
		local Vector X, Y, Z;

		GetAxes(Rotation, X, Y, Z);
		Pawn.Acceleration = (((aForward * X) + (aStrafe * Y)) + (aUp * vect(0.0000000, 0.0000000, 1.0000000)));
		// End:0x8B
		if((VSize(Pawn.Acceleration) < 1.0000000))
		{
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		}
		// End:0xD2
		if((bCheatFlying && (Pawn.Acceleration == vect(0.0000000, 0.0000000, 0.0000000))))
		{
			Pawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		}
		UpdateRotation(DeltaTime, 2.0000000);
		// End:0x11D
		// Client: bundle move and send to server. Server: apply the move locally.
		if((int(Role) < int(ROLE_Authority)))
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

// BaseSpectating: minimal spectator base state; provides free-fly movement with no pawn attached.
state BaseSpectating
{
	function ProcessMove(float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		Acceleration = NewAccel;
		MoveSmooth((Acceleration * DeltaTime));
		return;
	}

	function PlayerMove(float DeltaTime)
	{
		local Rotator NewRotation;
		local Vector X, Y, Z;

		GetAxes(Rotation, X, Y, Z);
		Acceleration = (0.0200000 * (((aForward * X) + (aStrafe * Y)) + (aUp * vect(0.0000000, 0.0000000, 1.0000000))));
		UpdateRotation(DeltaTime, 1.0000000);
		// End:0x95
		// Client: bundle move and send to server. Server: apply the move locally.
		if((int(Role) < int(ROLE_Authority)))
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

// Scripting: player input is suppressed during scripted sequences (cutscenes/matinees); Fire is a no-op.
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

// Spectating: full spectator mode; Fire cycles to next player view, AltFire returns to own camera.
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
		if((Pawn != none))
		{
			SetLocation(Pawn.Location);
			UnPossess();
		}
		bCollideWorld = true;
		return;
	}

	function EndState()
	{
		// End:0x1C
		if((PlayerReplicationInfo != none))
		{
			PlayerReplicationInfo.bIsSpectator = false;
		}
		bCollideWorld = false;
		return;
	}
	stop;
}

// PlayerWaiting: auto start state; player spectates and waits for the game to assign a pawn.
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
		if((Level.TimeSeconds < WaitDelay))
		{
			return;
		}
		// End:0x35
		if((int(Level.NetMode) == int(NM_Client)))
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
		if((Pawn != none))
		{
			Pawn.SetMesh();
		}
		// End:0x35
		if((PlayerReplicationInfo != none))
		{
			PlayerReplicationInfo.SetWaitingPlayer(false);
		}
		bCollideWorld = false;
		return;
	}

	function BeginState()
	{
		// End:0x1B
		if((PlayerReplicationInfo != none))
		{
			PlayerReplicationInfo.SetWaitingPlayer(true);
		}
		bCollideWorld = true;
		myHUD.bShowScores = false;
		return;
	}
	stop;
}

// WaitingForPawn: polls every 0.2 s until a Pawn reference becomes available, then calls ClientReStart.
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
		if((Pawn != none))
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
		SetTimer(0.2000000, true);
		return;
	}

	function EndState()
	{
		SetTimer(0.0000000, false);
		return;
	}
	stop;
}

// GameEnded: post-match state; damage is ignored, scoreboard shown, Fire restarts the game server-side.
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
		if((int(Role) < int(ROLE_Authority)))
		{
			return;
		}
		// End:0x26
		if((!bFrozen))
		{
			ServerRestartGame();			
		}
		else
		{
			// End:0x3C
			if((TimerRate <= float(0)))
			{
				SetTimer(1.5000000, false);
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

		GetAxes(Rotation, X, Y, Z);
		// End:0xEF
		if((!bFixedCamera))
		{
			ViewRotation = Rotation;
			(ViewRotation.Yaw += int(((32.0000000 * DeltaTime) * aTurn)));
			(ViewRotation.Pitch += int(((32.0000000 * DeltaTime) * aLookUp)));
			ViewRotation.Pitch = (ViewRotation.Pitch & 65535);
			// End:0xE4
			if(((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152)))
			{
				// End:0xD4
				if((aLookUp > float(0)))
				{
					ViewRotation.Pitch = 18000;					
				}
				else
				{
					ViewRotation.Pitch = 49152;
				}
			}
			SetRotation(ViewRotation);			
		}
		else
		{
			// End:0x10B
			if((ViewTarget != none))
			{
				SetRotation(ViewTarget.Rotation);
			}
		}
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
		// End:0x15B
		// Client: keep sending rotation-only moves so the server stays in sync.
		if((int(Role) < int(ROLE_Authority)))
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
		// Game has ended; forward with locked rotation to prevent phantom movement.
		global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbCrawl, (((32767 & (Rotation.Pitch / 2)) * 32768) + (32767 & (Rotation.Yaw / 2))), 0);
		return;
	}

	// FindGoodView: rotates through 16 yaw angles and picks the one with the most camera clearance.
	function FindGoodView()
	{
		local Vector cameraLoc;
		local Rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestDist, newdist;
		local int startYaw;
		local Actor ViewActor;

		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000; // steep downward-looking pitch for death cam
		tries = 0;
		besttry = 0;
		bestDist = 0.0000000;
		startYaw = ViewRotation.Yaw;
		tries = 0;
		J0x4B:

		// End:0xDD [Loop If]
		if((tries < 16))
		{
			cameraLoc = ViewTarget.Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize((cameraLoc - ViewTarget.Location));
			// End:0xC2
			if((newdist > bestDist))
			{
				bestDist = newdist;
				besttry = tries;
			}
			(ViewRotation.Yaw += 4096);
			(tries++);
			// [Loop Continue]
			goto J0x4B;
		}
		ViewRotation.Yaw = (startYaw + (besttry * 4096));
		SetRotation(ViewRotation);
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
		if((Pawn != none))
		{
			Pawn.SimAnim.AnimRate = 0;
			Pawn.bPhysicsAnimUpdate = false;
			Pawn.StopAnimating();
			Pawn.SetCollision(false, false, false);
		}
		myHUD.bShowScores = true;
		bFrozen = true;
		// End:0xA3
		if((!bFixedCamera))
		{
			bBehindView = true;
		}
		SetTimer(1.5000000, false);
		SetPhysics(0);
		// End:0xEC
		foreach DynamicActors(Class'Engine.Pawn', P)
		{
			P.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
			P.SetPhysics(0);			
		}		
		return;
	}
	stop;
}

// Dead: player is dead; watches from behind view while frozen, Fire triggers respawn.
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
		if((!bFrozen))
		{
			// End:0x27
			if(bPressedJump)
			{
				Fire(0.0000000);
				bPressedJump = false;
			}
			GetAxes(Rotation, X, Y, Z);
			ViewRotation = Rotation;
			(ViewRotation.Yaw += int(((32.0000000 * DeltaTime) * aTurn)));
			(ViewRotation.Pitch += int(((32.0000000 * DeltaTime) * aLookUp)));
			ViewRotation.Pitch = (ViewRotation.Pitch & 65535);
			// End:0x100
			if(((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152)))
			{
				// End:0xF0
				if((aLookUp > float(0)))
				{
					ViewRotation.Pitch = 18000;					
				}
				else
				{
					ViewRotation.Pitch = 49152;
				}
			}
			SetRotation(ViewRotation);
			// End:0x13F
			// Client: keep sending rotation-only moves while dead so the server stays in sync.
			if((int(Role) < int(ROLE_Authority)))
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
		if((ViewTarget == none))
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
		if((tries < 16))
		{
			cameraLoc = ViewTarget.Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize((cameraLoc - ViewTarget.Location));
			// End:0xCF
			if((newdist > bestDist))
			{
				bestDist = newdist;
				besttry = tries;
			}
			(ViewRotation.Yaw += 4096);
			(tries++);
			// [Loop Continue]
			goto J0x58;
		}
		ViewRotation.Yaw = (startYaw + (besttry * 4096));
		SetRotation(ViewRotation);
		return;
	}

	function Timer()
	{
		// End:0x0D
		if((!bFrozen))
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
		if((SavedMoves != none))
		{
			Next = SavedMoves.NextMove;
			Current = SavedMoves;
			SavedMoves = Next;
			Current.Destroy();
			// [Loop Continue]
			goto J0x1F;
		}
		// End:0x8C
		if((PendingMove != none))
		{
			Current = PendingMove;
			PendingMove = none;
			Current.Destroy();
		}
		return;
	}

	function EndState()
	{
		local SavedMove Next;

		J0x00:
		// End:0x39 [Loop If]
		if((SavedMoves != none))
		{
			Next = SavedMoves.NextMove;
			SavedMoves.Destroy();
			SavedMoves = Next;
			// [Loop Continue]
			goto J0x00;
		}
		// End:0x57
		if((PendingMove != none))
		{
			PendingMove.Destroy();
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
