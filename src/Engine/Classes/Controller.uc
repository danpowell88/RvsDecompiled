//=============================================================================
// Controller - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Controller, the base class of players or AI.
//
// Controllers are non-physical actors that can be attached to a pawn to control 
// its actions.  PlayerControllers are used by human players to control pawns, while 
// AIControFllers implement the artificial intelligence for the pawns they control.  
// Controllers take control of a pawn using their Possess() method, and relinquish 
// control of the pawn by calling UnPossess().
//
// Controllers receive notifications for many of the events occuring for the Pawn they 
// are controlling.  This gives the controller the opportunity to implement the behavior 
// in response to this event, intercepting the event and superceding the Pawn's default 
// behavior.  
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Controller extends Actor
	abstract
	native
	nativereplication
 notplaceable;

const LATENT_MOVETOWARD = 503;

enum EAttitude
{
	ATTITUDE_Fear,                  // 0
	ATTITUDE_Hate,                  // 1
	ATTITUDE_Frenzy,                // 2
	ATTITUDE_Threaten,              // 3
	ATTITUDE_Ignore,                // 4
	ATTITUDE_Friendly,              // 5
	ATTITUDE_Follow                 // 6
};

enum EMoveToResult
{
	eMoveTo_none,                   // 0
	eMoveTo_success,                // 1
	eMoveTo_failed                  // 2
};

enum ECDKEY_VALID_REQ
{
	ECDKEY_NONE,                    // 0
	ECDKEY_FIRSTPASS,               // 1
	ECDKEY_WAITING_FOR_RESPONSE,    // 2
	ECDKEY_NOT_VALID,               // 3
	ECDKEY_VALID,                   // 4
	ECDKEY_TIMEOUT                  // 5
};

enum ECDKEYST_STATUS
{
	ECDKEYST_PLAYER_UNKNOWN,        // 0
	ECDKEYST_PLAYER_INVALID,        // 1
	ECDKEYST_PLAYER_VALID,          // 2
	ECDKEYST_PLAYER_BANNED,         // 3
	ECDKEYST_PLAYER_PB_KICKED       // 4
};

struct PlayerVerCDKeyStatus
{
	var Controller.ECDKEY_VALID_REQ m_eCDKeyRequest;  // State of cdkey request state machine
	var string m_szAuthorizationID;  // Player authorization ID
	var int m_iCDKeyReqID;  // CD key request ID
	var bool m_bCDKeyValSecondTry;  // This is the second attempt at validating this user (only try twice)
	var Controller.ECDKEYST_STATUS m_eCDKeyStatus;  // Player status set by validation server (valid, not valid, unknown)
};

// NEW IN 1.60
var(AI) Controller.EAttitude AttitudeToPlayer;
// NEW IN 1.60
var input byte bRun;
// NEW IN 1.60
var input byte bFire;
// NEW IN 1.60
var input byte bAltFire;
// Camera movement with the keyboard for the PlaningController
var input byte m_bMoveUp;
var input byte m_bMoveDown;
var input byte m_bMoveLeft;
var input byte m_bMoveRight;
var input byte m_bRotateCW;
var input byte m_bRotateCCW;
var input byte m_bZoomIn;
var input byte m_bZoomOut;
var input byte m_bAngleUp;
var input byte m_bAngleDown;
var input byte m_bLevelUp;
var input byte m_bLevelDown;
var input byte m_bGoLevelUp;  // to change the level once.
var input byte m_bGoLevelDown;
var byte bDuck;  // 17 jan 2002 rbrek - modified the declaration of bDuck so that it is no longer mapped directly to an input button
var Controller.EMoveToResult m_eMoveToResult;
var bool bIsPlayer;  // Pawn is a player or a player-bot.
var bool bGodMode;  // cheat - when true, can't be killed or hurt
//AI flags
var const bool bLOSflag;  // used for alternating LineOfSight traces
var bool bAdvancedTactics;  // serpentine movement between pathnodes
var bool bCanOpenDoors;
var bool bCanDoSpecial;
var bool bAdjusting;  // adjusting around obstacle
var bool bPreparingMove;  // set true while pawn sets up for a latent move
var bool bControlAnimations;  // take control of animations from pawn (don't let pawn play animations based on notifications)
var bool bEnemyInfoValid;  // false when change enemy, true when LastSeenPos etc updated
// #ifdef R6PlayerMovements
var bool m_bCrawl;  // equivalent of bDuck
//Put here to save cast and checks
var bool m_bLockWeaponActions;  // Local Flag to limit the actions on weapon while doing something else.
var bool m_bHideReticule;
var float SightCounter;  // Used to keep track of when to check player visibility
var float FovAngle;  // X field of view angle in degrees, usually 90.
var float Handedness;
var float Stimulus;  // Strength of stimulus - Set when stimulus happens
// Navigation AI
var float MoveTimer;
var float MinHitWall;  // Minimum HitNormal dot Velocity.Normal to get a HitWall event from the physics
var float LastSeenTime;
var float OldMessageTime;  // to limit frequency of voice messages
var float RouteDist;  // total distance for current route
var float GroundPitchTime;
var float MonitorMaxDistSq;
var Pawn Pawn;
var const Controller nextController;  // chained Controller list
var Actor MoveTarget;  // actor being moved toward
var Actor Focus;  // actor being looked at
var Mover PendingMover;  // mover pawn is waiting for to complete its move
var Actor GoalList[4];  // used by navigation AI - list of intermediate goals
var NavigationPoint home;  // set when begin play, used for retreating and attitude checks
// Enemy information
var Pawn Enemy;
var Actor Target;
// Route Cache for Navigation
var Actor RouteCache[16];
var ReachSpec CurrentPath;
var Actor RouteGoal;  // final destination for current route
var PlayerReplicationInfo PlayerReplicationInfo;
var NavigationPoint StartSpot;  // where player started the match
var R6PawnReplicationInfo m_PawnRepInfo;
var Pawn MonitoredPawn;  // used by latent function MonitorPawn()
//#ifdef R6CODE
var name NextState;  // for queueing states
var name NextLabel;  // for queueing states
// Replication Info
var() Class<PlayerReplicationInfo> PlayerReplicationInfoClass;
var Class<Pawn> PawnClass;  // class of pawn to spawn (for players)
var Class<Pawn> PreviousPawnClass;  // Holds the player's previous class
var Vector AdjustLoc;  // location to move to while adjusting around obstacle
var Vector Destination;  // location being moved toward
var Vector FocalPoint;  // location being looked at
var Vector LastSeenPos;  // enemy position when I last saw enemy (auto updated if EnemyNotVisible() enabled)
var Vector LastSeeingPos;  // position where I last saw enemy (auto updated if EnemyNotVisible enabled)
var Vector ViewX;  // Viewrotation encoding for PHYS_Spider
// NEW IN 1.60
var Vector ViewY;
// NEW IN 1.60
var Vector ViewZ;
// for monitoring the position of a pawn
var Vector MonitorStartLoc;  // used by latent function MonitorPawn()
var string VoiceType;  // for speech

replication
{
	// Pos:0x000
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		R6DamageAttitudeTo;

	// Pos:0x00D
	reliable if(__NFUN_130__(bNetDirty, __NFUN_154__(int(Role), int(ROLE_Authority))))
		Pawn, PlayerReplicationInfo, 
		m_PawnRepInfo;

	// Pos:0x025
	reliable if(__NFUN_130__(__NFUN_130__(bNetDirty, __NFUN_154__(int(Role), int(ROLE_Authority))), bNetOwner))
		PawnClass;

	// Pos:0x048
	reliable if(__NFUN_154__(int(RemoteRole), int(ROLE_AutonomousProxy)))
		ClientDying, ClientGameEnded, 
		ClientSetLocation, ClientSetRotation;

	// Pos:0x055
	reliable if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		ServerReStartPlayer;
}

// Export UController::execMoveTo(FFrame&, void* const)
 native(500) final latent function MoveTo(Vector NewDestination, optional Actor ViewFocus, optional float speed, optional bool bShouldWalk);

// Export UController::execMoveToward(FFrame&, void* const)
 native(502) final latent function MoveToward(Actor NewTarget, optional Actor ViewFocus, optional float speed, optional float DestinationOffset, optional bool bUseStrafing, optional bool bShouldWalk);

// Export UController::execFinishRotation(FFrame&, void* const)
 native(508) final latent function FinishRotation();

// Export UController::execLineOfSightTo(FFrame&, void* const)
 native(514) final function bool LineOfSightTo(Actor Other);

// Export UController::execCanSee(FFrame&, void* const)
 native(533) final function bool CanSee(Pawn Other);

// Export UController::execFindPathTo(FFrame&, void* const)
//Navigation functions - return the next path toward the goal
 native(518) final function Actor FindPathTo(Vector aPoint, optional bool bClearPaths);

// Export UController::execFindPathToward(FFrame&, void* const)
 native(517) final function Actor FindPathToward(Actor anActor, optional bool bClearPaths);

// Export UController::execFindPathTowardNearest(FFrame&, void* const)
 native final function Actor FindPathTowardNearest(Class<NavigationPoint> GoalClass);

// Export UController::execFindRandomDest(FFrame&, void* const)
 native(525) final function NavigationPoint FindRandomDest(optional bool bClearPaths);

// Export UController::execClearPaths(FFrame&, void* const)
 native(522) final function ClearPaths();

// Export UController::execEAdjustJump(FFrame&, void* const)
 native(523) final function Vector EAdjustJump(float BaseZ, float XYSpeed);

// Export UController::execpointReachable(FFrame&, void* const)
//Reachable returns whether direct path from Actor to aPoint is traversable
//using the current locomotion method
 native(521) final function bool pointReachable(Vector aPoint);

// Export UController::execactorReachable(FFrame&, void* const)
 native(520) final function bool actorReachable(Actor anActor);

// Export UController::execPickWallAdjust(FFrame&, void* const)
 native(526) final function bool PickWallAdjust(Vector HitNormal);

// Export UController::execWaitForLanding(FFrame&, void* const)
 native(527) final latent function WaitForLanding();

// Export UController::execFindBestInventoryPath(FFrame&, void* const)
 native(540) final function Actor FindBestInventoryPath(out float MinWeight, bool bPredictRespawns);

// Export UController::execAddController(FFrame&, void* const)
 native(529) final function AddController();

// Export UController::execRemoveController(FFrame&, void* const)
 native(530) final function RemoveController();

// Export UController::execPickTarget(FFrame&, void* const)
// Pick best pawn target
 native(531) final function Pawn PickTarget(out float bestAim, out float bestDist, Vector FireDir, Vector projStart);

// Export UController::execPickAnyTarget(FFrame&, void* const)
 native(534) final function Actor PickAnyTarget(out float bestAim, out float bestDist, Vector FireDir, Vector projStart);

// Export UController::execInLatentExecution(FFrame&, void* const)
 native final function bool InLatentExecution(int LatentActionNumber);

// Export UController::execStopWaiting(FFrame&, void* const)
// Force end to sleep
 native function StopWaiting();

// Export UController::execEndClimbLadder(FFrame&, void* const)
 native function EndClimbLadder();

event MayFall()
{
	return;
}

//#ifdef R6CODE
exec function Map(int iGotoMapId, string explanation)
{
	return;
}

function PendingStasis()
{
	bStasis = true;
	Pawn = none;
	return;
}

// #ifdef R6CODE
//============================================================================
// logX - Log with more information for debugging.  Display:
//          controller, source, controller state, pawn state and a string
//============================================================================
function logX(string szText, optional int iSource)
{
	local string szSource, Time;

	Time = string(Level.TimeSeconds);
	Time = __NFUN_128__(Time, __NFUN_146__(__NFUN_126__(Time, "."), 3));
	// End:0x57
	if(__NFUN_154__(iSource, 1))
	{
		szSource = __NFUN_112__(__NFUN_112__("(", Time), ":P) ");		
	}
	else
	{
		szSource = __NFUN_112__(__NFUN_112__("(", Time), ":C) ");
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(szSource, string(Name)), " ["), string(__NFUN_284__())), "|"), string(Pawn.__NFUN_284__())), "] "), szText));
	return;
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	// End:0x22
	if(__NFUN_114__(Pawn, none))
	{
		super.DisplayDebug(Canvas, YL, YPos);
		return;
	}
	Canvas.__NFUN_2626__(byte(255), 0, 0);
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("CONTROLLER ", GetItemName(string(self))), " Pawn "), string(Pawn)));
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("     STATE: ", string(__NFUN_284__())), " Timer: "), string(TimerCounter)), " Enemy "), string(Enemy)), false);
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	// End:0x136
	if(__NFUN_114__(PlayerReplicationInfo, none))
	{
		Canvas.__NFUN_465__("     NO PLAYERREPLICATIONINFO", false);		
	}
	else
	{
		PlayerReplicationInfo.DisplayDebug(Canvas, YL, YPos);
	}
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	return;
}

function Rotator GetViewRotation()
{
	return Rotation;
	return;
}

function Reset()
{
	super.Reset();
	Enemy = none;
	LastSeenTime = 0.0000000;
	StartSpot = none;
	return;
}

function ClientSetLocation(Vector NewLocation, Rotator NewRotation)
{
	__NFUN_299__(NewRotation);
	// End:0x8B
	if(__NFUN_130__(__NFUN_151__(Rotation.Pitch, RotationRate.Pitch), __NFUN_150__(Rotation.Pitch, __NFUN_147__(65536, RotationRate.Pitch))))
	{
		// End:0x6F
		if(__NFUN_150__(Rotation.Pitch, 32768))
		{
			NewRotation.Pitch = RotationRate.Pitch;			
		}
		else
		{
			NewRotation.Pitch = __NFUN_147__(65536, RotationRate.Pitch);
		}
	}
	// End:0xC4
	if(__NFUN_119__(Pawn, none))
	{
		NewRotation.Roll = 0;
		Pawn.__NFUN_299__(NewRotation);
		Pawn.__NFUN_267__(NewLocation);
	}
	return;
}

function ClientSetRotation(Rotator NewRotation)
{
	__NFUN_299__(NewRotation);
	// End:0x3C
	if(__NFUN_119__(Pawn, none))
	{
		NewRotation.Pitch = 0;
		NewRotation.Roll = 0;
		Pawn.__NFUN_299__(NewRotation);
	}
	return;
}

function ClientDying(Vector HitLocation)
{
	// End:0x2F
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.PlayDying(HitLocation);
		Pawn.__NFUN_113__('Dying');
	}
	return;
}

event AIHearSound(Actor Actor, int ID, Sound S, Vector SoundLocation, Vector Parameters, bool Attenuate)
{
	return;
}

function Possess(Pawn aPawn)
{
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	// End:0x45
	if(__NFUN_119__(PlayerReplicationInfo, none))
	{
		PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
	}
	FocalPoint = __NFUN_215__(Pawn.Location, __NFUN_213__(float(512), Vector(Pawn.Rotation)));
	Restart();
	return;
}

function PawnDied()
{
	// End:0x2B
	if(__NFUN_119__(Pawn, none))
	{
		__NFUN_267__(Pawn.Location);
		Pawn.UnPossessed();
	}
	Pawn = none;
	PendingMover = none;
	// End:0x4C
	if(bIsPlayer)
	{
		__NFUN_113__('Dead');		
	}
	else
	{
		__NFUN_279__();
	}
	return;
}

function Restart()
{
	Enemy = none;
	return;
}

event LongFall()
{
	return;
}

// notifications of pawn events (from C++)
// if return true, then pawn won't get notified 
event bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
{
	return;
}

event bool NotifyHeadVolumeChange(PhysicsVolume NewVolume)
{
	return;
}

event bool NotifyLanded(Vector HitNormal)
{
	return;
}

event bool NotifyHitWall(Vector HitNormal, Actor Wall)
{
	return;
}

event bool NotifyBump(Actor Other)
{
	return;
}

event NotifyHitMover(Vector HitNormal, Mover Wall)
{
	return;
}

function SetFall()
{
	return;
}

event PreBeginPlay()
{
	__NFUN_529__();
	m_PawnRepInfo = __NFUN_278__(Class'Engine.R6PawnReplicationInfo');
	m_PawnRepInfo.m_ControllerOwner = self;
	super.PreBeginPlay();
	// End:0x32
	if(bDeleteMe)
	{
		return;
	}
	SightCounter = __NFUN_171__(0.2000000, __NFUN_195__());
	return;
}

event PostBeginPlay()
{
	super.PostBeginPlay();
	return;
}

function InitPlayerReplicationInfo()
{
	// End:0x32
	if(__NFUN_122__(PlayerReplicationInfo.PlayerName, ""))
	{
		PlayerReplicationInfo.SetPlayerName(Class'Engine.GameInfo'.default.DefaultPlayerName);
	}
	return;
}

simulated event Destroyed()
{
	// End:0x12
	if(__NFUN_150__(int(Role), int(ROLE_Authority)))
	{
		return;
	}
	__NFUN_530__();
	// End:0x4D
	if(__NFUN_130__(bIsPlayer, __NFUN_119__(Level.Game, none)))
	{
		Level.Game.Logout(self);
	}
	// End:0x64
	if(__NFUN_119__(PlayerReplicationInfo, none))
	{
		PlayerReplicationInfo.__NFUN_279__();
	}
	// End:0x82
	if(__NFUN_119__(m_PawnRepInfo, none))
	{
		m_PawnRepInfo.__NFUN_279__();
		m_PawnRepInfo = none;
	}
	super.Destroyed();
	return;
}

function AdjustView(float DeltaTime)
{
	local Controller C;

	C = Level.ControllerList;
	J0x14:

	// End:0x6B [Loop If]
	if(__NFUN_119__(C, none))
	{
		// End:0x54
		if(__NFUN_130__(C.__NFUN_303__('PlayerController'), __NFUN_114__(PlayerController(C).ViewTarget, Pawn)))
		{
			return;
		}
		C = C.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

function bool WantsSmoothedView()
{
	return __NFUN_130__(__NFUN_132__(__NFUN_154__(int(Pawn.Physics), int(1)), __NFUN_154__(int(Pawn.Physics), int(9))), __NFUN_129__(Pawn.bJustLanded));
	return;
}

function ClientGameEnded()
{
	__NFUN_113__('GameEnded');
	return;
}

simulated event RenderOverlays(Canvas Canvas)
{
	// End:0x31
	if(__NFUN_119__(Pawn.EngineWeapon, none))
	{
		Pawn.EngineWeapon.RenderOverlays(Canvas);
	}
	return;
}

function int GetFacingDirection()
{
	return 0;
	return;
}

function byte GetMessageIndex(name PhraseName)
{
	return 0;
	return;
}

function bool WouldReactToNoise(float Loudness, Actor NoiseMaker)
{
	return false;
	return;
}

function bool WouldReactToSeeing(Pawn seen)
{
	return false;
	return;
}

function FearThisSpot(Actor ASpot)
{
	return;
}

event PrepareForMove(NavigationPoint Goal, ReachSpec Path)
{
	return;
}

function WaitForMover(Mover M)
{
	return;
}

function MoverFinished()
{
	return;
}

function UnderLift(Mover M)
{
	return;
}

// #ifdef R6NOISE
event HearNoise(float Loudness, Actor NoiseMaker, Actor.ENoiseType eType, optional Actor.ESoundType ESoundType)
{
	return;
}

event SeePlayer(Pawn seen)
{
	return;
}

event SeeMonster(Pawn seen)
{
	return;
}

event EnemyNotVisible()
{
	return;
}

function ShakeView(float shaketime, float RollMag, Vector OffsetMag, float RollRate, Vector OffsetRate, float OffsetTime)
{
	return;
}

function Controller.EAttitude AttitudeTo(Pawn Other)
{
	// End:0x1B
	if(Other.IsPlayerPawn())
	{
		return AttitudeToPlayer;		
	}
	else
	{
		return 4;
	}
	return;
}

function bool FireWeaponAt(Actor A)
{
	return;
}

function StopFiring()
{
	bFire = 0;
	bAltFire = 0;
	return;
}

function ReceiveWarning(Pawn shooter, float projSpeed, Vector FireDir)
{
	return;
}

function bool CheckFutureSight(float DeltaTime)
{
	return true;
	return;
}

function ServerReStartPlayer()
{
	return;
}

event MonitoredPawnAlert()
{
	return;
}

function StartMonitoring(Pawn P, float MaxDist)
{
	MonitoredPawn = P;
	MonitorStartLoc = P.Location;
	MonitorMaxDistSq = __NFUN_171__(MaxDist, MaxDist);
	return;
}

//R6CODE
simulated function R6DamageAttitudeTo(Pawn Other, Actor.eKillResult eKillFromTable, Actor.eStunResult eStunFromTable, Vector vBulletMomentum)
{
	return;
}

function PlaySoundDamage(Pawn instigatedBy)
{
	return;
}

function PlaySoundInflictedDamage(Pawn DeadPawn)
{
	return;
}

function PlaySoundCurrentAction(Pawn.ERainbowTeamVoices eVoices)
{
	return;
}

function PlaySoundAffectedByGrenade(Pawn.EGrenadeType eType)
{
	return;
}

function SetWeaponSound(R6PawnReplicationInfo PawnRepInfo, string szCurrentWeaponTxt, byte u8CurrentWepon)
{
	return;
}

state Dead
{
	ignores KilledBy;

	function PawnDied()
	{
		return;
	}

	function ServerReStartPlayer()
	{
		// End:0x1B
		if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
		{
			return;
		}
		Level.Game.RestartPlayer(self);
		return;
	}
	stop;
}

state GameEnded
{
	ignores ReceiveWarning, KilledBy;

	function BeginState()
	{
		// End:0x89
		if(__NFUN_119__(Pawn, none))
		{
			Pawn.bPhysicsAnimUpdate = false;
			Pawn.StopAnimating();
			Pawn.SimAnim.AnimRate = 0;
			Pawn.__NFUN_262__(false, false, false);
			Pawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
			Pawn.__NFUN_3970__(0);
			Pawn.UnPossessed();
		}
		// End:0x97
		if(__NFUN_129__(bIsPlayer))
		{
			__NFUN_279__();
		}
		return;
	}
	stop;
}

defaultproperties
{
	AttitudeToPlayer=1
	m_bHideReticule=true
	FovAngle=90.0000000
	MinHitWall=-1.0000000
	PlayerReplicationInfoClass=Class'Engine.PlayerReplicationInfo'
	bHidden=true
	bHiddenEd=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var EAttitude
// REMOVED IN 1.60: var byte
// REMOVED IN 1.60: var Y
// REMOVED IN 1.60: var Z
// REMOVED IN 1.60: function NotifyAddInventory
// REMOVED IN 1.60: function NotifyTakeHit
// REMOVED IN 1.60: function PawnIsInPain
// REMOVED IN 1.60: function SameTeamAs
// REMOVED IN 1.60: function SendMessage
// REMOVED IN 1.60: function SendVoiceMessage
// REMOVED IN 1.60: function ClientVoiceMessage
// REMOVED IN 1.60: function BotVoiceMessage
// REMOVED IN 1.60: function NotifyKilled
// REMOVED IN 1.60: function damageAttitudeTo
// REMOVED IN 1.60: function AttitudeTo
// REMOVED IN 1.60: function AdjustDesireFor
// REMOVED IN 1.60: function WeaponPreference
// REMOVED IN 1.60: function AdjustAim
// REMOVED IN 1.60: function SwitchToBestWeapon
// REMOVED IN 1.60: function ChangedWeapon
