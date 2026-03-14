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
    native
    nativereplication
    abstract;

// --- Constants ---
const LATENT_MOVETOWARD =  503;

// --- Enums ---
enum EAttitude  // order in decreasing importance
{
	ATTITUDE_Fear,		// will try to run away
	ATTITUDE_Hate,		// will attack enemy
	ATTITUDE_Frenzy,	// will attack anything, indiscriminately
	ATTITUDE_Threaten,	// animations, but no attack
	ATTITUDE_Ignore,
	ATTITUDE_Friendly,
	ATTITUDE_Follow 	// accepts player as leader
} AttitudeToPlayer;		// determines how creature will react on seeing player (if in human form)


// #ifdef R6PlayerMovements
var                 BOOL            m_bCrawl;               // equivalent of bDuck
// #endif R6PlayerMovements

// Input buttons.
var input byte
	bRun, /* r6code bDuck,*/ bFire, bAltFire;

// r6code

// Camera movement with the keyboard for the PlaningController
var input BYTE		m_bMoveUp;
var input BYTE		m_bMoveDown;
var input BYTE		m_bMoveLeft;
var input BYTE		m_bMoveRight;
var input BYTE		m_bRotateCW;
var input BYTE		m_bRotateCCW;
var input BYTE		m_bZoomIn;
var input BYTE		m_bZoomOut;
var input BYTE      m_bAngleUp;
var input BYTE      m_bAngleDown;
var input BYTE    	m_bLevelUp;
var input BYTE      m_bLevelDown;
var input BYTE      m_bGoLevelUp; //to change the level once.
var input BYTE      m_bGoLevelDown;

// end

var		byte		bDuck;			// 17 jan 2002 rbrek - modified the declaration of bDuck so that it is no longer mapped directly to an input button
                 					// especially since we use it as a regular variable.  Input variables are all reset when the game loses focus (switch tasks).

var		vector		AdjustLoc;			// location to move to while adjusting around obstacle

var const	Controller		nextController; // chained Controller list

var		float 		Stimulus;			// Strength of stimulus - Set when stimulus happens

// Navigation AI
var 	float		MoveTimer;
var 	Actor		MoveTarget;		// actor being moved toward
var		vector	 	Destination;	// location being moved toward
var	 	vector		FocalPoint;		// location being looked at
var		Actor		Focus;			// actor being looked at
var		Mover		PendingMover;	// mover pawn is waiting for to complete its move
var		Actor		GoalList[4];	// used by navigation AI - list of intermediate goals
var NavigationPoint home;			// set when begin play, used for retreating and attitude checks
var	 	float		MinHitWall;		// Minimum HitNormal dot Velocity.Normal to get a HitWall event from the physics

// Enemy information
var	 	Pawn    	Enemy;
var		Actor		Target;
var		vector		LastSeenPos; 	// enemy position when I last saw enemy (auto updated if EnemyNotVisible() enabled)
var		vector		LastSeeingPos;	// position where I last saw enemy (auto updated if EnemyNotVisible enabled)
var		float		LastSeenTime;
 
var string VoiceType; //for speech
var float OldMessageTime; //to limit frequency of voice messages

// Route Cache for Navigation
var Actor RouteCache[16];
var ReachSpec	CurrentPath;
var Actor	RouteGoal; //final destination for current route
var float	RouteDist;	// total distance for current route

// Replication Info
var() class<PlayerReplicationInfo> PlayerReplicationInfoClass;
var PlayerReplicationInfo PlayerReplicationInfo;

var class<Pawn> PawnClass;	// class of pawn to spawn (for players)
var class<Pawn> PreviousPawnClass;	// Holds the player's previous class

var float GroundPitchTime;
var vector ViewX, ViewY, ViewZ;	// Viewrotation encoding for PHYS_Spider

var NavigationPoint StartSpot;  // where player started the match

//#ifdef R6CODE
var         name                NextState; //for queueing states
var         name                NextLabel; //for queueing states
var R6PawnReplicationInfo m_PawnRepInfo;

//Put here to save cast and checks
var         BOOL                m_bLockWeaponActions;      //Local Flag to limit the actions on weapon while doing something else.
var         BOOL                m_bHideReticule;

//#endif // #ifdef R6CODE

// R6MOVETO
enum EMoveToResult {
    eMoveTo_none,
    eMoveTo_success,
    eMoveTo_failed
};
enum EMoveToResult {
    eMoveTo_none,
    eMoveTo_success,
    eMoveTo_failed
};
enum ECDKEY_VALID_REQ
{
    ECDKEY_NONE,
    ECDKEY_FIRSTPASS,
    ECDKEY_WAITING_FOR_RESPONSE,
    ECDKEY_NOT_VALID,
    ECDKEY_VALID,
    ECDKEY_TIMEOUT
};
enum ECDKEYST_STATUS
{
    ECDKEYST_PLAYER_UNKNOWN,
    ECDKEYST_PLAYER_INVALID,
    ECDKEYST_PLAYER_VALID,
    ECDKEYST_PLAYER_BANNED,
    ECDKEYST_PLAYER_PB_KICKED
};

// --- Structs ---
struct PlayerVerCDKeyStatus
{
    var ECDKEY_VALID_REQ m_eCDKeyRequest;       // State of cdkey request state machine
    var string           m_szAuthorizationID;   // Player authorization ID
    var INT              m_iCDKeyReqID;         // CD key request ID
    var BOOL             m_bCDKeyValSecondTry;  // This is the second attempt at validating this user (only try twice)
    var ECDKEYST_STATUS  m_eCDKeyStatus;        // Player status set by validation server (valid, not valid, unknown)
};

// --- Variables ---
// var ? m_bCDKeyValSecondTry; // REMOVED IN 1.60
// var ? m_eCDKeyRequest; // REMOVED IN 1.60
// var ? m_eCDKeyStatus; // REMOVED IN 1.60
// var ? m_iCDKeyReqID; // REMOVED IN 1.60
// var ? m_szAuthorizationID; // REMOVED IN 1.60
var /* replicated */ Pawn Pawn;
// Replication Info
var /* replicated */ PlayerReplicationInfo PlayerReplicationInfo;
var Vector ViewX;
// ^ NEW IN 1.60
// actor being moved toward
var Actor MoveTarget;
// X field of view angle in degrees, usually 90.
var float FovAngle;
// chained Controller list
var const Controller nextController;
// Viewrotation encoding for PHYS_Spider
var Vector ViewZ;
// Pawn is a player or a player-bot.
var bool bIsPlayer;
// Route Cache for Navigation
var Actor RouteCache[16];
// location being moved toward
var Vector Destination;
var Vector ViewY;
// ^ NEW IN 1.60
// mover pawn is waiting for to complete its move
var Mover PendingMover;
// 17 jan 2002 rbrek - modified the declaration of bDuck so that it is no longer mapped directly to an input button
var byte bDuck;
// Enemy information
var Pawn Enemy;
// set true while pawn sets up for a latent move
var bool bPreparingMove;
var byte bRun;
// ^ NEW IN 1.60
// actor being looked at
var Actor Focus;
var /* replicated */ R6PawnReplicationInfo m_PawnRepInfo;
// #ifdef R6PlayerMovements
// equivalent of bDuck
var bool m_bCrawl;
// Navigation AI
var float MoveTimer;
// where player started the match
var NavigationPoint StartSpot;
var EAttitude AttitudeToPlayer;
// ^ NEW IN 1.60
var byte bFire;
// ^ NEW IN 1.60
var byte bAltFire;
// ^ NEW IN 1.60
// location being looked at
var Vector FocalPoint;
var ReachSpec CurrentPath;
// location to move to while adjusting around obstacle
var Vector AdjustLoc;
// used by navigation AI - list of intermediate goals
var Actor GoalList[4];
// Used to keep track of when to check player visibility
var float SightCounter;
// cheat - when true, can't be killed or hurt
var bool bGodMode;
// adjusting around obstacle
var bool bAdjusting;
// take control of animations from pawn (don't let pawn play animations based on notifications)
var bool bControlAnimations;
var float LastSeenTime;
//final destination for current route
var Actor RouteGoal;
// total distance for current route
var float RouteDist;
// class of pawn to spawn (for players)
var /* replicated */ class<Pawn> PawnClass;
// for monitoring the position of a pawn
// used by latent function MonitorPawn()
var Vector MonitorStartLoc;
// used by latent function MonitorPawn()
var Pawn MonitoredPawn;
var float MonitorMaxDistSq;
var float Handedness;
//AI flags
// used for alternating LineOfSight traces
var const bool bLOSflag;
// serpentine movement between pathnodes
var bool bAdvancedTactics;
var bool bCanOpenDoors;
var bool bCanDoSpecial;
// false when change enemy, true when LastSeenPos etc updated
var bool bEnemyInfoValid;
// Camera movement with the keyboard for the PlaningController
var byte m_bMoveUp;
var byte m_bMoveDown;
var byte m_bMoveLeft;
var byte m_bMoveRight;
var byte m_bRotateCW;
var byte m_bRotateCCW;
var byte m_bZoomIn;
var byte m_bZoomOut;
var byte m_bAngleUp;
var byte m_bAngleDown;
var byte m_bLevelUp;
var byte m_bLevelDown;
//to change the level once.
var byte m_bGoLevelUp;
var byte m_bGoLevelDown;
// Strength of stimulus - Set when stimulus happens
var float Stimulus;
// set when begin play, used for retreating and attitude checks
var NavigationPoint home;
// Minimum HitNormal dot Velocity.Normal to get a HitWall event from the physics
var float MinHitWall;
var Actor Target;
// enemy position when I last saw enemy (auto updated if EnemyNotVisible() enabled)
var Vector LastSeenPos;
// position where I last saw enemy (auto updated if EnemyNotVisible enabled)
var Vector LastSeeingPos;
//for speech
var string VoiceType;
//to limit frequency of voice messages
var float OldMessageTime;
var class<PlayerReplicationInfo> PlayerReplicationInfoClass;
// ^ NEW IN 1.60
// Holds the player's previous class
var class<Pawn> PreviousPawnClass;
var float GroundPitchTime;
//#ifdef R6CODE
//for queueing states
var name NextState;
//for queueing states
var name NextLabel;
//Put here to save cast and checks
//Local Flag to limit the actions on weapon while doing something else.
var bool m_bLockWeaponActions;
var bool m_bHideReticule;
var EMoveToResult m_eMoveToResult;

// --- Functions ---
// function ? BotVoiceMessage(...); // REMOVED IN 1.60
// function ? ChangedWeapon(...); // REMOVED IN 1.60
// function ? ClientVoiceMessage(...); // REMOVED IN 1.60
// function ? NotifyAddInventory(...); // REMOVED IN 1.60
// function ? NotifyKilled(...); // REMOVED IN 1.60
// function ? NotifyTakeHit(...); // REMOVED IN 1.60
// function ? PawnIsInPain(...); // REMOVED IN 1.60
// function ? SendMessage(...); // REMOVED IN 1.60
// function ? SendVoiceMessage(...); // REMOVED IN 1.60
// function ? SwitchToBestWeapon(...); // REMOVED IN 1.60
// function ? damageAttitudeTo(...); // REMOVED IN 1.60
function Reset() {}
// notifications of pawn events (from C++)
// if return true, then pawn won't get notified
event bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume) {}
// ^ NEW IN 1.60
function AdjustView(float DeltaTime) {}
function PawnDied() {}
simulated event Destroyed() {}
function Restart() {}
event PreBeginPlay() {}
event PostBeginPlay() {}
delegate ServerReStartPlayer() {}
function DisplayDebug(Canvas Canvas, out float YPos, out float YL) {}
function int GetFacingDirection() {}
// ^ NEW IN 1.60
function EAttitude AttitudeTo(Pawn Other) {}
// ^ NEW IN 1.60
function Possess(Pawn aPawn) {}
function ShakeView(float shaketime, float RollMag, Vector OffsetMag, float RollRate, Vector OffsetRate, float OffsetTime) {}
event bool NotifyLanded(Vector HitNormal) {}
// ^ NEW IN 1.60
function UnderLift(Mover M) {}
function WaitForMover(Mover M) {}
event bool NotifyHitWall(Vector HitNormal, Actor Wall) {}
// ^ NEW IN 1.60
function PendingStasis() {}
function Rotator GetViewRotation() {}
// ^ NEW IN 1.60
function bool WantsSmoothedView() {}
// ^ NEW IN 1.60
event PrepareForMove(NavigationPoint Goal, ReachSpec Path) {}
function MoverFinished() {}
function ReceiveWarning(Pawn shooter, float projSpeed, Vector FireDir) {}
simulated event RenderOverlays(Canvas Canvas) {}
function ClientDying(Vector HitLocation) {}
final native function bool InLatentExecution(int LatentActionNumber) {}
// ^ NEW IN 1.60
final native function Actor PickAnyTarget(out float bestAim, out float bestDist, Vector FireDir, Vector projStart) {}
// ^ NEW IN 1.60
final native function Pawn PickTarget(out float bestAim, out float bestDist, Vector FireDir, Vector projStart) {}
// ^ NEW IN 1.60
final native function Actor FindBestInventoryPath(out float MinWeight, bool bPredictRespawns) {}
// ^ NEW IN 1.60
final native function bool PickWallAdjust(Vector HitNormal) {}
// ^ NEW IN 1.60
final native function bool actorReachable(Actor anActor) {}
// ^ NEW IN 1.60
final native function bool pointReachable(Vector aPoint) {}
// ^ NEW IN 1.60
final native function Vector EAdjustJump(float BaseZ, float XYSpeed) {}
// ^ NEW IN 1.60
final native function NavigationPoint FindRandomDest(optional bool bClearPaths) {}
// ^ NEW IN 1.60
final native function Actor FindPathTowardNearest(class<NavigationPoint> GoalClass) {}
// ^ NEW IN 1.60
final native function Actor FindPathToward(Actor anActor, optional bool bClearPaths) {}
// ^ NEW IN 1.60
final native function Actor FindPathTo(Vector aPoint, optional bool bClearPaths) {}
// ^ NEW IN 1.60
final native function bool CanSee(Pawn Other) {}
// ^ NEW IN 1.60
final native function bool LineOfSightTo(Actor Other) {}
// ^ NEW IN 1.60
final native latent function MoveToward(Actor NewTarget, optional Actor ViewFocus, optional float speed, optional float DestinationOffset, optional bool bUseStrafing, optional bool bShouldWalk) {}
// ^ NEW IN 1.60
final native latent function MoveTo(Vector NewDestination, optional Actor ViewFocus, optional float speed, optional bool bShouldWalk) {}
// ^ NEW IN 1.60
function StartMonitoring(Pawn P, float MaxDist) {}
function ClientSetRotation(Rotator NewRotation) {}
function ClientSetLocation(Rotator NewRotation, Vector NewLocation) {}
// #ifdef R6CODE
//============================================================================
// logX - Log with more information for debugging.  Display:
//          controller, source, controller state, pawn state and a string
//============================================================================
function logX(string szText, optional int iSource) {}
final native latent function FinishRotation() {}
// ^ NEW IN 1.60
final native function ClearPaths() {}
// ^ NEW IN 1.60
final native latent function WaitForLanding() {}
// ^ NEW IN 1.60
final native function AddController() {}
// ^ NEW IN 1.60
final native function RemoveController() {}
// ^ NEW IN 1.60
// Force end to sleep
native function StopWaiting() {}
native function EndClimbLadder() {}
event MayFall() {}
//#ifdef R6CODE
exec function Map(int iGotoMapId, string explanation) {}
event AIHearSound(Actor Actor, int ID, Sound S, Vector SoundLocation, Vector Parameters, bool Attenuate) {}
event LongFall() {}
event bool NotifyHeadVolumeChange(PhysicsVolume NewVolume) {}
// ^ NEW IN 1.60
event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
event NotifyHitMover(Vector HitNormal, Mover Wall) {}
function SetFall() {}
function InitPlayerReplicationInfo() {}
function ClientGameEnded() {}
function byte GetMessageIndex(name PhraseName) {}
// ^ NEW IN 1.60
function bool WouldReactToNoise(float Loudness, Actor NoiseMaker) {}
// ^ NEW IN 1.60
function bool WouldReactToSeeing(Pawn seen) {}
// ^ NEW IN 1.60
function FearThisSpot(Actor ASpot) {}
// #ifdef R6NOISE
event HearNoise(float Loudness, Actor NoiseMaker, ENoiseType eType, optional ESoundType ESoundType) {}
event SeePlayer(Pawn seen) {}
event SeeMonster(Pawn seen) {}
event EnemyNotVisible() {}
function bool FireWeaponAt(Actor A) {}
// ^ NEW IN 1.60
function StopFiring() {}
function bool CheckFutureSight(float DeltaTime) {}
// ^ NEW IN 1.60
event MonitoredPawnAlert() {}
//R6CODE
function R6DamageAttitudeTo(Pawn Other, eKillResult eKillFromTable, eStunResult eStunFromTable, Vector vBulletMomentum) {}
function PlaySoundDamage(Pawn instigatedBy) {}
function PlaySoundInflictedDamage(Pawn DeadPawn) {}
function PlaySoundCurrentAction(ERainbowTeamVoices eVoices) {}
function PlaySoundAffectedByGrenade(EGrenadeType eType) {}
function SetWeaponSound(R6PawnReplicationInfo PawnRepInfo, string szCurrentWeaponTxt, byte u8CurrentWepon) {}

state Dead
{
    delegate ServerReStartPlayer() {}
    function KilledBy(Pawn EventInstigator) {}
// ^ NEW IN 1.60
    function PawnDied() {}
}

state GameEnded
{
    function BeginState() {}
    function KilledBy(Pawn EventInstigator) {}
// ^ NEW IN 1.60
    function ReceiveWarning(Pawn shooter, float projSpeed, Vector FireDir) {}
}

defaultproperties
{
}
