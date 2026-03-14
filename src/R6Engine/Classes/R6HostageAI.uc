//=============================================================================
//  R6HostageAI.uc : This is the AI Controller class for all hostages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//=============================================================================
class R6HostageAI extends R6AIController
    native;

// --- Constants ---
const C_iKeepDistanceFromPawn =  105;

// --- Structs ---
struct OrderInfo
{
    // **** if modified, update this struct in r6engine.h ****
    var bool           m_bOrderedByRainbow;
    var R6Pawn         m_pawn1;         // the pawn involved in the order
    var eHostageOrder  m_eOrder;        // the order
    var float          m_fTime;         // the game level time
    var Actor          m_actor;
    // **** if modified, update this struct in r6engine.h ****
};

struct PlaySndInfo
{
    var INT     m_iLastTime;        // last time the sound was played
    var INT     m_iInBetweenTime;   // time to wait before playing again the sound
};

// --- Variables ---
// var ? m_actor; // REMOVED IN 1.60
// var ? m_bOrderedByRainbow; // REMOVED IN 1.60
// var ? m_eOrder; // REMOVED IN 1.60
// var ? m_fTime; // REMOVED IN 1.60
// var ? m_iInBetweenTime; // REMOVED IN 1.60
// var ? m_iLastTime; // REMOVED IN 1.60
// var ? m_pawn1; // REMOVED IN 1.60
// to get away from copyinh R6Hostage(pawn)
var R6Hostage m_pawn;
// run toward, follow this pawn
var R6Pawn m_pawnToFollow;
var R6HostageMgr m_mgr;
var R6Pawn m_lastSeenPawn;
// info on the current threat of the civilian
var ThreatInfo m_threatInfo;
// Used in patrol when waiting at a node or when freed
var int m_iWaitingTime;
// destination
var Vector m_vMoveToDest;
// number of order in the queue
var int m_iNbOrder;
// list of order queued (used by the order system
var OrderInfo m_aOrderInfo[2];
// true if running toward the group. used in FollowingPawn state
var bool m_bRunningToward;
// terroriste with who's interacting with
var R6Terrorist m_terrorist;
// time since the hostage is no longer guarded
var int m_iNotGuardedSince;
var PathNode m_pCoverNode;        // Current cover node the hostage AI is moving toward
// ^ NEW IN 1.60
// used when Enemy can't be used (ie: for grenade)
var Actor m_runAwayOfGrenade;
// true when the rainbow tell him to stay here
var bool m_bForceToStayHere;
var array<array> m_pListOfCoverNodes;  // List of cover nodes available to this hostage
// ^ NEW IN 1.60
// in follow mode, we may have to stop completly to do a transition
var bool m_bStopDoTransition;
// true when following someone walking in reverse
var bool m_bSlowedPace;
// Used in patrol when waiting at a node
var int m_iFacingTime;
// play reaction: used to desynchronis hostage reaction to threat
var int m_iPlayReaction1;
// true when in succeeded (used in Guarded_runTowardRainbow)
var bool m_bRunToRainbowSuccess;
var Actor m_pGotoToExtractionZone;
// position to go when doing a transition
var EStartingPosition m_eTransitionPosition;
// Used in following pawn
var int m_lastUpdatePaceTime;
// set to true when c_iDistanceToStartToRun is reached
var bool m_bNeedToRunToCatchUp;
// frequence to tick the AI Timer. m_fMin is used for quick AI update in the state code
var RandomTweenNum m_AITickTime;
var int m_iRandomNumber;          // Cached random value used for AI decision-making variation
// ^ NEW IN 1.60
// 3d point where the hostage looked/focused when reacted to SeePlayer in Guarded state
var Vector m_vReactionDirection;
// debug: ignore threat
var bool m_bDbgIgnoreThreat;
// pawn who escortedvar
var R6Pawn m_escort;
var R6HostageVoices m_VoicesManager;
var name m_runForCoverStateToGoOnSuccess;
var bool m_bool;
var int m_iDbgRoll;
var name m_runForCoverStateToGoOnFailure;
// used in state code: true when the we manually stop the latent function
var bool m_bLatentFnStopped;
//
var bool m_bFollowIncreaseDistance;
var bool m_bDbgRoll;
// group name used for the processing threat
var name m_threatGroupName;
var int m_iPlayReaction2;
// distance max from someone before catching up
var const int c_iDistanceMax;
// last hear noise detected
var int m_iLastHearNoiseTime;
var bool m_bFirstTimeClarkComment;
var name m_reactToGrenadeStateToReturn;
var RandomTweenNum m_stayBlindedTweenTime;
// if far from the group, start to run to catch up
var const int c_iDistanceToStartToRun;
// when catching up, the hostage will stop at this min distance
var const int c_iDistanceCatchUp;
var const int c_iRunForCoverOfGrenadeMinDist;
var bool m_bDbgIgnoreRainbow;
var RandomTweenNum m_scareToDeathTween;
// time allowed to run for cover before starting to be aware of what's going on
var RandomTweenNum m_RunForCoverMinTween;
// if no noise is hear, stay cautious for this length of time
var const int c_iCautiousLastHearNoiseTime;
// min time before stopping when running away from an enemy
var const int c_iEnemyNotVisibleTime;
// personnality modifier
var const int c_iGasModifier;
// personnality modifier
var const int c_iWoundedModifier;
// personnality modifier
var const int c_iBraveModifier;
// personnality modifier
var const int c_iNormalModifier;
// personnality modifier
var const int c_iCowardModifier;
var R6EngineWeapon DefaultWeapon;
//MissionPack1 // MPF1
var class<R6EngineWeapon> DefaultWeaponClass;
var bool bThreatShowLog;
var name m_name;
var float m_float;
var Vector m_vectorTemp;
// used in state code
var Rotator m_rotator;

// --- Functions ---
// function ? beginState(...); // REMOVED IN 1.60
// function ? endState(...); // REMOVED IN 1.60
event OpenDoorFailed() {}
//------------------------------------------------------------------
// SeePlayerMgr: called once in a while to manage the lastSeenPawn
//	This mgr allows to have some delay in the AI behavior of hostage.
//  So they don't react all at the same time on a SeePlayer
//------------------------------------------------------------------
function SeePlayerMgr() {}
//------------------------------------------------------------------
// SeePlayer:
//	- inherited
//------------------------------------------------------------------
function SeePlayer(Pawn P) {}
//------------------------------------------------------------------
// HearNoise: HearNoise used when the hostage is freed, civilian and
//  guarded by terro.
//	- inherited
//------------------------------------------------------------------
event HearNoise(ENoiseType eType, Actor NoiseMaker, optional ESoundType ESoundType, float fLoudness) {}
//------------------------------------------------------------------
// AIAffectedByGrenade()
//------------------------------------------------------------------
function AIAffectedByGrenade(EGrenadeType eType, Actor aGrenade) {}
//==============================================================
// SetStateGuarded: set the default value, his starting position
//                  (kneel, foetus) of the pawn and set to Guarded
//                  state
function SetStateGuarded(int iHstSndEvent, EStartingPosition ePos) {}
//------------------------------------------------------------------
// SetStateFollowingPawn: set values for SetStateFollowingPawn and go
//	to that state
//------------------------------------------------------------------
function SetStateFollowingPawn(int iHstSndEvent, bool bFreed, R6Pawn runTo) {}
//------------------------------------------------------------------
// Order_GotoExtraction
//
//------------------------------------------------------------------
function Order_ProcessGotoExtraction(Actor aZone) {}
//------------------------------------------------------------------
// DispatchOrder: dispatch order for a eHostageCircumstantialAction
//------------------------------------------------------------------
function DispatchOrder(int iOrder, optional R6Pawn orderFrom) {}
//------------------------------------------------------------------
// IsAwayOfGrenade: return true if away and approximatively safe of
//   the grenade.
//------------------------------------------------------------------
function bool IsAwayOfGrenade(Actor Grenade) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsRunForCoverPossible: return true if the hostage can run away and
//  generate a path to run away of this enemy
//------------------------------------------------------------------
function bool IsRunForCoverPossible(Pawn runAwayOf) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsBumpBackUpStateFinish: return true if the condition to end the
// state BumpBackUp are reached.
// - inherited
//------------------------------------------------------------------
function bool IsBumpBackUpStateFinish() {}
// ^ NEW IN 1.60
function CivGotoStateMovingTo(optional Actor aMoveTarget, eMovementPace ePace) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetStateReactToGrenade: set the default value
//
//------------------------------------------------------------------
function SetStateReactToGrenade(name stateToReturn) {}
function bool CivCheckCoverNode() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Order_ProcessFollowMe: informs the team or has received the order to follow
//  the rainbow team. The hostage is added in the escorted team
//  which will set is m_pawnToFollow.
//------------------------------------------------------------------
function Order_ProcessFollowMe(bool bOrderedByRainbow, R6Pawn follow) {}
//------------------------------------------------------------------
// CanConsiderThreat: once a threat is detected and may have
//	an exception, this is where we check if the threat can be
//  consired by the R6hostageMgr::GetThreatInfoFromThreat
//------------------------------------------------------------------
function bool CanConsiderThreat(name considerThreat, R6Pawn aPawn, Actor aThreat) {}
// ^ NEW IN 1.60
event PostBeginPlay() {}
//------------------------------------------------------------------
// GetRandomTurn90: return a random turn left or right 90'
//
//------------------------------------------------------------------
function Rotator GetRandomTurn90() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// RouteCacheWithOtherLadder
//	return true if the route cache has a the other r6ladder nav point
//------------------------------------------------------------------
function bool RouteCacheWithOtherLadder(R6Ladder Ladder) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CanClimbLadder
//
//------------------------------------------------------------------
function bool CanClimbLadders(R6Ladder Ladder) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// PlaySoundDamage()
//------------------------------------------------------------------
function PlaySoundDamage(Pawn instigatedBy) {}
//------------------------------------------------------------------
// SetPawnPosition
//
//------------------------------------------------------------------
function SetPawnPosition(EStartingPosition ePos) {}
//------------------------------------------------------------------
// SetPace: set the pace and adjust it if wounded
//
//------------------------------------------------------------------
function SetPace(eMovementPace ePace) {}
//------------------------------------------------------------------
// GetRainbowWhoEscortThisPawn: get the rainbow who will escort
//------------------------------------------------------------------
function R6Rainbow GetRainbowWhoEscortThisPawn(R6Pawn follow) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CivInit: initialization for the civilian
//------------------------------------------------------------------
function CivInit() {}
//------------------------------------------------------------------
// Order_Pop: pop the first element and shift all the rest (FIFO queue)
//
//------------------------------------------------------------------
function OrderInfo Order_Pop() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ProcessPlaySndInfo
//
//------------------------------------------------------------------
function bool ProcessPlaySndInfo(int iSndEvent) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetMovementPace: set the current pace to be when following someone
// return true if are doing a transition thats requires to stop moving
//------------------------------------------------------------------
function bool SetMovementPace(bool bStartingToMove) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Order_GetLog
//
//------------------------------------------------------------------
function string Order_GetLog(OrderInfo Info) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Order_Process: process the queued Order (FIFO)
//
//------------------------------------------------------------------
function Order_Process() {}
function ProcessThreat(Actor P, ENoiseType eType) {}
/////////////////////////////////////////////////////////////////////////
// IsGuarded: return true if the hostage is or can be guarded
//            Guarded here means that the hostage can see a terrorist.
//
//            *** costly function ***
function bool IsGuarded(optional bool bMustSeeMe, optional bool bNoTimer) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CanStopMoving: return true if I should stop moving. When moving
//	the hostage will try to catch up the group
// bCheckIfShouldMove: when true, the pawn is asking if he needs to move
//------------------------------------------------------------------
function bool CanStopMoving(bool bCheckIfShouldMove) {}
// ^ NEW IN 1.60
/////////////////////////////////////////////////////////////////////////////
// CanReturnToNormalState: return true if the hostage can return to a normal
//                         state.
function bool CanReturnToNormalState() {}
// ^ NEW IN 1.60
/////////////////////////////////////////////////////////////////////////
// Possess: once the pawn is possed, initialized the controller
// - inherited
function Possess(Pawn aPawn) {}
//------------------------------------------------------------------
// Tick
//
//------------------------------------------------------------------
function Tick(float fDeltaTime) {}
//------------------------------------------------------------------
// setFreed: freed an hostage. If he was a bait, he'll become a PERSO_Normal
//
//------------------------------------------------------------------
function SetFreed(bool bFreed) {}
//------------------------------------------------------------------
// ReturnToNormalState: when return to normal state he still could
//	be guarded or not
//------------------------------------------------------------------
function ReturnToNormalState(optional bool bNoTimer) {}
///////////////////////////////////////////////////////////////////////////
// Roll a random number adjusted by the personnality
function int Roll(int iMax) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// StopFollowingPawn: reset all info regarding following a pawn
//
//------------------------------------------------------------------
function StopFollowingPawn(bool bOrderedByRainbow) {}
//------------------------------------------------------------------
// Order_ProcessStayHere: the hostage received the order to stay
//  here, or it informs the team that he'll stay here
//------------------------------------------------------------------
function Order_ProcessStayHere(bool bOrderedByRainbow) {}
//------------------------------------------------------------------
// SetStateFollowingPaceTransition: set the default value, his starting position
//
//------------------------------------------------------------------
function SetStatePaceTransition(EStartingPosition ePos) {}
//------------------------------------------------------------------
// CanOpenDoor: check if the pawn has the ability to open the door
//	ie: in case it's locked.
//------------------------------------------------------------------
event bool CanOpenDoor(R6IORotatingDoor Door) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetStateRunForCover
//
//------------------------------------------------------------------
function SetStateRunForCover(Actor Grenade, name failureState, name successState, Pawn runAwayOfPawn) {}
//------------------------------------------------------------------
// SetThreatState:
//
//------------------------------------------------------------------
function SetThreatState(name threatState) {}
function PlaySoundAffectedByGrenade(EGrenadeType eType) {}
//------------------------------------------------------------------
// Order_Surrender: Terrorist orders to surrender
//
//------------------------------------------------------------------
function Order_Surrender(R6Pawn aPawn) {}
//------------------------------------------------------------------
// Order_FollowMe: Rainbows order to follow this pawn
//
//------------------------------------------------------------------
function Order_FollowMe(R6Pawn aPawn, bool bOrderedByRainbow) {}
//------------------------------------------------------------------
// Order_StayHere: Rainbow orders the hostage to stay here
//
//------------------------------------------------------------------
function Order_StayHere(bool bOrderedByRainbow) {}
//------------------------------------------------------------------
// Order_GotoExtraction: order hostage to go to the extraction Zone
//
//------------------------------------------------------------------
function Order_GotoExtraction(Actor aZone) {}
//------------------------------------------------------------------
// Order_Add: Add an order (FIFO).
//  If there's one only
//
//------------------------------------------------------------------
function Order_Add(eHostageOrder eOrder, R6Pawn aPawn, optional bool bOrderedByRainbow, optional Actor anActor) {}
//------------------------------------------------------------------
// SetStateEscorted
//
//------------------------------------------------------------------
function SetStateEscorted(R6Pawn escort, Vector Destination, bool bSurrender) {}
//------------------------------------------------------------------
// Order_ProcessSurrender: process the surrender order. Should not
//	be call externally of Order_Process
//------------------------------------------------------------------
function Order_ProcessSurrender(Pawn terro) {}
//------------------------------------------------------------------
// IsInTemporaryState: temporary state are states that need to be
//	over before doing anything else
//------------------------------------------------------------------
function bool IsInTemporaryState() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Order_canFollowMe: return true if the hostage can follow
//
//------------------------------------------------------------------
function bool Order_canFollowMe() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CheckNeedToClimbLadder
//
//------------------------------------------------------------------
function CheckNeedToClimbLadder() {}
//------------------------------------------------------------------
// SetStateExtracted: set the hostage in extracted state. no more or
//	- reset threat, orders
//------------------------------------------------------------------
function SetStateExtracted() {}
//------------------------------------------------------------------
// GetThreatGroupName
//
//------------------------------------------------------------------
function name GetThreatGroupName() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ResetThreatInfo
//
//------------------------------------------------------------------
function ResetThreatInfo(string sz) {}
//------------------------------------------------------------------
// BumpBackUpStateFinished: function fired if there is not a
//	return state (in m_bumpBackUpState_nextState)
// - inherited
//------------------------------------------------------------------
function BumpBackUpStateFinished() {}
//------------------------------------------------------------------
// FollowPawnFailed
//
//------------------------------------------------------------------
function FollowPawnFailed() {}
//------------------------------------------------------------------
// IsInCrouchedPosture: return truen so a crouchwalk anim will be played
//	when the pawn is bumped
//------------------------------------------------------------------
function bool IsInCrouchedPosture() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Died: called when the pawn is declared dead
//------------------------------------------------------------------
function PawnDied() {}

state Civilian
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
    /////////////////////////////////////////////////////////////////////////
    function EndState() {}
//------------------------------------------------------------------
// SeePlayerMgr: called once in a while to manage the lastSeenPawn
//	This mgr allows to have some delay in the AI behavior of hostage.
//  So they don't react all at the same time on a SeePlayer
//------------------------------------------------------------------
    function SeePlayerMgr() {}
}

state Guarded
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
    /////////////////////////////////////////////////////////////////////////
    function Timer() {}
    /////////////////////////////////////////////////////////////////////////
    function EndState() {}
}

state CivGuardPoint
{
//------------------------------------------------------------------
// SeePlayer:
//	- inherited
//------------------------------------------------------------------
    function SeePlayer(Pawn P) {}
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state RunForCover
{
    function bool IsRunForCoverSuccessfull() {}
// ^ NEW IN 1.60
    event OpenDoorFailed() {}
    function EnemyNotVisible() {}
    function StopRunForCover() {}
    /////////////////////////////////////////////////////////////////////////
    function Timer() {}
    /////////////////////////////////////////////////////////////////////////
    function EndState() {}
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state FollowingPawn
{
    /////////////////////////////////////////////////////////////////////////
    function Timer() {}
    /////////////////////////////////////////////////////////////////////////
    event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
    /////////////////////////////////////////////////////////////////////////
    function EndState() {}
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state CivPatrolPath
{
    function PickDestination() {}
    function int GetFacingTime() {}
// ^ NEW IN 1.60
    function int GetWaitingTime() {}
// ^ NEW IN 1.60
    function SetToNextNode() {}
    event OpenDoorFailed() {}
    function bool IsGoingBack() {}
// ^ NEW IN 1.60
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state EscortedByEnemy
{
    function EscortIsOver(bool bSuccess) {}
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
    /////////////////////////////////////////////////////////////////////////
    function EndState() {}
}

state CivStayHere
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state GoCivScareToDeath
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state CivScareToDeath
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state CivRunForCover
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state CivMovingTo
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state CMCivStayKneel
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state CMCivStayHere
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state CivRunTowardRainbow
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state CivSurrender
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state WaitForSomeTime
{
}

state CivPatrolArea
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state OpenDoor
{
//------------------------------------------------------------------
// SeePlayerMgr: called once in a while to manage the lastSeenPawn
//	This mgr allows to have some delay in the AI behavior of hostage.
//  So they don't react all at the same time on a SeePlayer
//------------------------------------------------------------------
    function SeePlayerMgr() {}
//------------------------------------------------------------------
// SeePlayer:
//	- inherited
//------------------------------------------------------------------
    function SeePlayer(Pawn P) {}
//------------------------------------------------------------------
// HearNoise: HearNoise used when the hostage is freed, civilian and
//  guarded by terro.
//	- inherited
//------------------------------------------------------------------
    event HearNoise(float fLoudness, Actor NoiseMaker, ENoiseType eType, optional ESoundType ESoundType) {}
}

state ReactToGrenade
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state GoHstFreedButSeeEnemy
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state GoHstRunTowardRainbow
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state GoHstRunForCover
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state DbgHostage
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state GotoExtraction
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state Extracted
{
    delegate R6DamageAttitudeTo(Pawn Other, eKillResult eKillFromTable, eStunResult eStunFromTable, Vector vBulletMomentum) {}
// ^ NEW IN 1.60
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
//------------------------------------------------------------------
// AIAffectedByGrenade()
//------------------------------------------------------------------
    function AIAffectedByGrenade(Actor aGrenade, EGrenadeType eType) {}
    /////////////////////////////////////////////////////////////////////////
    function Timer() {}
}

state FollowingPaceTransition
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state Freed
{
    /////////////////////////////////////////////////////////////////////////
    function Timer() {}
    /////////////////////////////////////////////////////////////////////////
    function EndState() {}
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state Guarded_frozen
{
    /////////////////////////////////////////////////////////////////////////
    function Timer() {}
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state GoGuarded_frozen
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state Guarded_foetus
{
    /////////////////////////////////////////////////////////////////////////
    function Timer() {}
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state GoGuarded_Foetus
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

state Configuration
{
    /////////////////////////////////////////////////////////////////////////
    function EndState() {}
    /////////////////////////////////////////////////////////////////////////
    function BeginState() {}
}

defaultproperties
{
}
