//=============================================================================
//  R6TerroristAI.uc : This is the AI Controller class for all terrorists
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    2001/05/08   Added a basic default waiting state that cycles through 
//                 the 3 wait animations
//=============================================================================
class R6TerroristAI extends R6AIController
    native;

// --- Constants ---
const C_MaxDistanceForActionSpot =  2000;
const C_DefaultSearchTime =  30;
const C_HostageReactionSearchTime =  15;
const C_HostageSearchTime =  15;
const C_WaitingForEnemyTime =  15;
const C_NumberOfNodeRemembered =  10;

// --- Enums ---
enum EEngageReaction
{
    EREACT_Random,
    EREACT_AimedFire,
    EREACT_SprayFire,
    EREACT_RunAway,
    EREACT_Surrender
};
enum EReactionStatus        
{
    REACTION_HearAndSeeAll,     // Lower status include all higher status (this one include all)
    REACTION_SeeHostage,        // Dropped investigate sound
    REACTION_HearBullet,        // Dropped hostage reaction
    REACTION_SeeRainbow,        // Dropped bullet sound
    REACTION_Grenade,           // Dropped rainbow
    REACTION_HearAndSeeNothing  // Dropped all
};
enum EEventState
{
    EVSTATE_DefaultState, // Use default state
    EVSTATE_RunAway,      // In state RunAway
    EVSTATE_Attack,       // In state Attack
    EVSTATE_FindHostage,  // In state FindHostage
    EVSTATE_AttackHostage // In state AttackHostage
};
enum EFollowMode
{
    FMODE_Hostage,      // Escorting an hostage
    FMODE_Path          // Following a leader on a path
};
enum EAttackMode
{
    ATTACK_NotEngaged,
    ATTACK_AimedFire,
    ATTACK_SprayFire,
    ATTACK_SprayFireNoStop,     // Don't stop when enemy is not visible
    ATTACK_SprayFireMove        // When on SprayFireNoStop and received EnemyNotVisible.  Fire while walking
};

// --- Variables ---
// var ? m_CurrentNode; // REMOVED IN 1.60
// var ? m_PawnToFollow; // REMOVED IN 1.60
var R6Terrorist m_pawn;
// Current cover spot of the terrorist
var R6ActionSpot m_pActionSpot;
var Vector m_vMovingDestination;
// Used in any place where I need a temporary random number
var int m_iRandomNumber;
                                                //   increase with each bullet detected
// Where the terrorist think a threat is coming from
var Vector m_vThreatLocation;
var string m_sDebugString;
var R6DZonePathNode m_currentNode;
// ^ NEW IN 1.60
// In wich attack mode the terrorist is currently
var EAttackMode m_eAttackMode;
// Hostage interaction
var R6Hostage m_Hostage;
var R6TerroristVoices m_VoicesManager;
// MovingTo variable
var Actor m_aMovingToDestination;
var EReactionStatus m_eReactionStatus;
var R6InteractiveObject m_TriggeredIO;
// Used in patrol when waiting at a noode
var float m_fWaitingTime;
var EEventState m_eStateForEvent;
// Time that the terrorist stay in engaged by sound
var float m_fSearchTime;
var R6TerroristMgr m_Manager;
var R6Pawn m_pawnToFollow;
// ^ NEW IN 1.60
var bool m_bWaiting;
var R6DZonePath m_path;
// Chance that the terrorist detect from where come the bullet,
var int m_iChanceToDetectShooter;
// Variables used for threat reaction (SeePlayer and HearNoise)
var EEngageReaction m_eEngageReaction;
var R6HostageAI m_HostageAI;
var bool m_bHearInvestigate;
var bool m_bHearThreat;
var int m_iCurrentGroupID;
var Rotator m_rStandRotation;
var bool m_bCanFailMovingTo;
var R6Pawn m_LastBumped;
var R6DeploymentZone m_ZoneToEscort;
// hunted pawn
var R6Pawn m_huntedPawn;
// Variable that can be used inside a state but not used between state
var int m_iStateVariable;
var bool m_bHeardGrenade;
var bool m_bSeeHostage;
var bool m_bSeeRainbow;
var bool m_bHearGrenade;
var float m_fFollowDist;
// hostage reaction direction
var Vector m_vHostageReactionDirection;
// Used in patrol when waiting at a noode
var float m_fFacingTime;
// Number of Rainbow in combat, for reaction check
var int m_iRainbowInCombat;
var byte m_wBadMoveCount;
var bool m_bFireShort;
var name m_PatrolCurrentLabel;
// Variable used for PlayVoices
var bool m_bAlreadyHeardSound;
// For interrupted IO
var bool m_bCalledForBackup;
var Vector m_vSpawningPosition;
var int m_iFollowYaw;
var float m_fPawnDistance;
var Rotator m_rSpawningRotation;
var float m_fLastBumpedTime;
var name m_labelAfterMovingTo;
var name m_stateAfterMovingTo;
var EFollowMode m_eFollowMode;
// Last ten node used by the terrorist
var NavigationPoint m_aLastNode[10];
// Variable internally used for AI
// Number of terrorist in group, for reaction check
var int m_iTerroristInGroup;
var R6TerroristAI m_TerroristLeader;
// Set to true for the pawn to walk as close as possible to destination
var bool m_bPreciseMove;
var array<array> m_listAvailableBackup;
// Patrol path variable
var bool m_bInPathMode;

// --- Functions ---
// function ? SetView(...); // REMOVED IN 1.60
//============================================================================
// SeePlayer -
//============================================================================
event SeePlayer(Pawn seen) {}
    // Ignore GotoPointToAttack in state RunAway
event GotoPointToAttack(Actor PTarget, Vector vDestination) {}
//============================================================================
// AIAffectedByGrenade -
//============================================================================
function AIAffectedByGrenade(EGrenadeType eType, Actor aGrenade) {}
//============================================================================
//  ####   ###   ####  #   #  #####    #####  #####   ###   ####   ####  ##  #
//  ##  # ##  #   ##   ##  #   ##      ##     ##     ##  #  #   # ##     ##  #
//  ####  ##  #   ##   # # #   ##      #####  ####   #####  ####  ##     #####
//  ##    ##  #   ##   #  ##   ##         ##  ##     ##  #  ## #  ##     ##  #
//  ##     ###   ####  #   #   ##      #####  #####  ##  #  ##  #  ####  ##  #
//============================================================================
event GotoPointAndSearch(optional float fSearchTime, Vector vDestination, eMovementPace ePace, optional EDefCon eNewDefCon, bool bCallBackup) {}
//============================================================================
// HearNoise -
//============================================================================
event HearNoise(Actor NoiseMaker, ENoiseType eType, float Loudness, optional ESoundType ESoundType) {}
function FollowLeader(Vector VOffset, R6Terrorist Leader) {}
//============================================================================
// HostageSurrender - Called from an hostage AI when that AI surrender
//============================================================================
function HostageSurrender(R6HostageAI hostageAI) {}
//============================================================================
//  #####   ##  #   ####    ####    #####   #   #   ####    #####   ####
//  ##      ##  #   #   #   #   #   ##      ##  #   ## ##   ##      #   #
//  #####   ##  #   ####    ####    ####    # # #   ##  #   ####    ####
//     ##   ##  #   ## #    ## #    ##      #  ##   ## ##   ##      ## #
//  #####   #####   ##  #   ##  #   #####   #   #   ####    #####   ##  #
//============================================================================
function SecureTerrorist(R6Pawn pOther) {}
function EEngageReaction GetEngageReaction(Pawn pEnemy, int iNbTerro, int iNbRainbow) {}
// ^ NEW IN 1.60
//============================================================================
//  ##### #   #   ####   ###    ####  #####    #####  ####   ####  ##  # #####
//  ##    ##  #  ##     ##  #  ##     ##       ##      ##   ##     ##  #  ##
//  ####  # # #  ## ##  #####  ## ##  ####     #####   ##   ## ##  #####  ##
//  ##    #  ##  ##  #  ##  #  ##  #  ##          ##   ##   ##  #  ##  #  ##
//  ##### #   #   ####  ##  #   ####  #####    #####  ####   ####  ##  #  ##
//============================================================================
function EngageBySight(Pawn aPawn) {}
//============================================================================
// IsAnHostage -
//============================================================================
function bool IsAnHostage(R6Pawn Other) {}
// ^ NEW IN 1.60
//============================================================================
// AssignNearHostage -
//============================================================================
function AssignNearHostage() {}
//============================================================================
// R6DamageAttitudeTo -
//============================================================================
delegate R6DamageAttitudeTo(Pawn instigatedBy, eKillResult eKillFromTable, eStunResult eStunFromTable, Vector vBulletMomentum) {}
//============================================================================
// PlaySoundDamage -
//============================================================================
function PlaySoundDamage(Pawn instigatedBy) {}
//============================================================================
// ChangeDefcon -
//============================================================================
function ChangeDefCon(EDefCon eNewDefCon) {}
//============================================================================
// LogTerroState -
//============================================================================
function LogTerroState() {}
//============================================================================
// SetGunDirection -
//============================================================================
function SetGunDirection(Actor aTarget) {}
//============================================================================
// IsAnEnemy -
//============================================================================
function bool IsAnEnemy(R6Pawn Other) {}
// ^ NEW IN 1.60
//============================================================================
// BOOL IsMyHostage -
//============================================================================
function bool IsMyHostage(R6Hostage hostage) {}
// ^ NEW IN 1.60
function bool CheckForInteraction() {}
// ^ NEW IN 1.60
//============================================================================
// GotoStateFindHostage -
//============================================================================
function GotoStateFindHostage(R6Hostage hostage) {}
//============================================================================
// SetReactionStatus -
//============================================================================
function SetReactionStatus(EReactionStatus eNewStatus, EEventState eState) {}
//============================================================================
// ReconThreatCheck -
//============================================================================
function ReconThreatCheck(Actor aThreat, ENoiseType eType) {}
//============================================================================
// GotoStateMoveToDestination -
//============================================================================
function GotoStateMovingTo(optional Vector vDestination, optional name labelAfter, optional name stateAfter, optional Actor aMoveTarget, eMovementPace ePace, string sDebugString, bool bCanFail, optional bool bDontCheckLeave, optional bool bPreciseMove) {}
//============================================================================
// AIPlayCallBackup -
//   - Return true if we must wait for the end of the animation
//============================================================================
function bool AIPlayCallBackup(Actor pEnemy) {}
// ^ NEW IN 1.60
//============================================================================
// EnemyNotVisible -
//============================================================================
event EnemyNotVisible() {}
//============================================================================
// INT GetKillingHostageChance -
//============================================================================
function int GetKillingHostageChance() {}
// ^ NEW IN 1.60
//============================================================================
// bool CanClimbLadders -
//============================================================================
function bool CanClimbLadders(R6Ladder Ladder) {}
// ^ NEW IN 1.60
function Rotator ChooseRandomDirection(int iLookBackChance) {}
// ^ NEW IN 1.60
function bool IsGoingBack() {}
// ^ NEW IN 1.60
//============================================================================
// ReactToGrenade -
//============================================================================
function ReactToGrenade(Vector vGrenadeLocation) {}
function float GetFacingTime() {}
// ^ NEW IN 1.60
// Random decision function
function float GetWaitingTime() {}
// ^ NEW IN 1.60
//============================================================================
// BOOL SetLowestSnipingStance -
//    - If aTarget != none, return true if we see the pawn from a position
//    - I have assumed that from or animation the offset on Z from the ground
//      for the start firing point is prone 15, crouch 70 and standing 135
//============================================================================
function bool SetLowestSnipingStance(optional Actor aTarget) {}
// ^ NEW IN 1.60
function WaitAtNode(float fWaitingTime, float fFacingTime, Rotator rOrientation) {}
// Callback
function GotoNode(Vector VPosition) {}
//============================================================================
//  #####   ###   ##     ##      ###   #   #
//  ##     ##  #  ##     ##     ##  #  #   #
//  ####   ##  #  ##     ##     ##  #  # # #
//  ##     ##  #  ##     ##     ##  #  #####
//  ##      ###   #####  #####   ###    # #
//
// if iYaw == 0, always approach the following pawn in straight line
//        in front : 32768
//        left : 16384 + 49151 : right
//            behind : 0
//============================================================================
function GotoStateFollowPawn(R6Pawn followedpawn, EFollowMode eMode, float fDist, optional int iYaw) {}
//============================================================================
// EscortIsOver - Called from the hostage AI when the escort is over
//============================================================================
function EscortIsOver(bool bSuccess, R6HostageAI hostageAI) {}
function GotoStateAttackHostage(R6Pawn hostage) {}
//============================================================================
//  #####    ###    ##  #   #   #   ####
//  ##      ##  #   ##  #   ##  #   ## ##
//  #####   ##  #   ##  #   # # #   ##  #
//     ##   ##  #   ##  #   #  ##   ## ##
//  #####    ###    #####   #   #   ####
//============================================================================
function GotoStateEngageBySound(Vector vInvestigateDestination, eMovementPace ePace, float fSearchTime) {}
//============================================================================
//  #####   ##  #   ####    #####    ###    #####
//   ##     ##  #   #   #   ##      ##  #    ##
//   ##     #####   ####    ####    #####    ##
//   ##     ##  #   ## #    ##      ##  #    ##
//   ##     ##  #   ##  #   #####   ##  #    ##
//============================================================================
event GotoStateEngageByThreat(Vector vThreathLocation) {}
//============================================================================
//   ####   ####    #####   #   #    ###    ####    #####
//  ##      #   #   ##      ##  #   ##  #   ## ##   ##
//  ## ##   ####    ####    # # #   #####   ##  #   ####
//  ##  #   ## #    ##      #  ##   ##  #   ## ##   ##
//   ####   ##  #   #####   #   #   ##  #   ####    #####
//============================================================================
function GotoStateThrowingGrenade(name nNextState, name nNextLabel) {}
//============================================================================
// DispatchOrder -
//============================================================================
function DispatchOrder(int iOrder, R6Pawn pSource) {}
//============================================================================
// GotoStateLostSight -
//============================================================================
function GotoStateLostSight(Vector vLastSeen) {}
//============================================================================
//  #####  #####  #####    ###    ####   #####   ###   ####
//  ##     ##     ##      ##  #   ## ##  ##     ##  #  ## ##
//  #####  ####   ####    #####   ##  #  ####   #####  ##  #
//     ##  ##     ##      ##  #   ## ##  ##     ##  #  ## ##
//  #####  #####  #####   ##  #   ####   #####  ##  #  ####
//============================================================================
function GotoSeeADead(Vector vDeadLocation) {}
function PlaySoundAffectedByGrenade(EGrenadeType eType) {}
//============================================================================
// BOOL IsAssigned -
//============================================================================
function bool IsAssigned(R6Hostage hostage) {}
// ^ NEW IN 1.60
//============================================================================
// state BumpBackUp - set the pawn engagement status at beginning of state
//============================================================================
function GotoBumpBackUpState(name returnState) {}
//============================================================================
// SetEnemy -
//============================================================================
function SetEnemy(Pawn newEnemy) {}
//============================================================================
// SetActionSpot -
//============================================================================
function SetActionSpot(R6ActionSpot pNewSpot) {}
final native function bool HaveAClearShot(Vector vStart, Pawn PTarget) {}
// ^ NEW IN 1.60
final native function Vector FindBetterShotLocation(Pawn PTarget) {}
// ^ NEW IN 1.60
final native function CallBackupForInvestigation(Vector vDestination, eMovementPace ePace) {}
// ^ NEW IN 1.60
final native function CallBackupForAttack(Vector vDestination, eMovementPace ePace) {}
// ^ NEW IN 1.60
final native function NavigationPoint GetNextRandomNode() {}
// ^ NEW IN 1.60
final native function bool MakeBackupList() {}
// ^ NEW IN 1.60
final native function bool CallVisibleTerrorist() {}
// ^ NEW IN 1.60
final native function bool IsAttackSpotStillValid() {}
// ^ NEW IN 1.60
event PostBeginPlay() {}
//============================================================================
// BOOL CanSafelyChangeState -
//          Return true if a pawn can safely change state by event.
//          - Not in ladder
//          - Not in root motion
//          - Not with an uninterruptable interactive object
//============================================================================
function bool CanSafelyChangeState() {}
// ^ NEW IN 1.60
//============================================================================
// BOOL UseRandomHostage -
//============================================================================
function bool UseRandomHostage() {}
// ^ NEW IN 1.60
//============================================================================
// StartFiring -
//============================================================================
function StartFiring() {}
//============================================================================
// StopFiring -
//============================================================================
function StopFiring() {}
//============================================================================
// ReloadWeapon -
//============================================================================
function AIReloadWeapon() {}
//============================================================================
// FLOAT GetMaxCoverDistance - Max distance that the pawn is willing to go
//                             to find a cover
//============================================================================
function float GetMaxCoverDistance() {}
// ^ NEW IN 1.60
//============================================================================
// PlayAttackVoices -
//============================================================================
function PlayAttackVoices() {}
//------------------------------------------------------------------
// PawnDied: called when the pawn is declared dead
//------------------------------------------------------------------
function PawnDied() {}
//============================================================================
//  #   #    ###      #####   ##  #   ####    #####    ###    #####
//  ##  #   ##  #      ##     ##  #   #   #   ##      ##  #    ##
//  # # #   ##  #      ##     #####   ####    ####    #####    ##
//  #  ##   ##  #      ##     ##  #   ## #    ##      ##  #    ##
//  #   #    ###       ##     ##  #   ##  #   #####   ##  #    ##
//============================================================================
function GotoStateNoThreat() {}
//============================================================================
//   ###    #####   #####    ###     ####   ##  #
//  ##  #    ##      ##     ##  #   ##      ## #
//  #####    ##      ##     #####   ##      ###
//  ##  #    ##      ##     ##  #   ##      ## #
//  ##  #    ##      ##     ##  #    ####   ##  #
//============================================================================
function GotoStateAimedFire() {}
function GotoStateSprayFire() {}
// Sent messages
function ReachedTheNode() {}
function FinishedWaiting() {}
//===================================================================================================
//   ####              #                                       #      ##
//    ##              ##                                      ##
//    ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####
//    ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##
//    ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####
//    ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##
//   ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####
//===================================================================================================
function bool CanInteractWithObjects(R6InteractiveObject o) {}
// ^ NEW IN 1.60
function PerformAction_StopInteraction() {}

state Attack
{
    function FindNextEnemy() {}
    function BeginState() {}
    function EndState() {}
    function bool NeedToReload() {}
// ^ NEW IN 1.60
    event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
}

state FindHostage
{
    event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
}

state WaitForEnemy
{
//============================================================================
// SeePlayer -
//============================================================================
    function SeePlayer(Pawn seen) {}
    function BeginState() {}
    function EndState() {}
    function Timer() {}
}

state FollowPawn
{
    function Vector GetFollowDestination() {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
}

state HuntRainbow
{
    function R6Pawn GetClosestEnemy() {}
// ^ NEW IN 1.60
    function BeginState() {}
}

state BumpBackUp
{
    function bool GetReacheablePoint(out Vector vTarget, bool bNoFail) {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
}

state ThrowingGrenade
{
    function CheckDistance() {}
    function BeginState() {}
    function EndState() {}
    event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
}

state Sniping
{
//============================================================================
// SeePlayer -
//============================================================================
    event SeePlayer(Pawn seen) {}
//============================================================================
// HearNoise -
//============================================================================
    event HearNoise(Actor NoiseMaker, ENoiseType eType, float Loudness, optional ESoundType ESoundType) {}
    function BeginState() {}
}

state MovingTo
{
    event bool NotifyBump(Actor Other) {}
// ^ NEW IN 1.60
    function bool GetReacheablePoint(out Vector vTarget) {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
    event Timer() {}
}

state test
{
}

state ApproachLadder
{
    function BeginState() {}
    function EndState() {}
}

state WaitToClimbLadder
{
    function BeginState() {}
    function EndState() {}
}

state TransientStateCode
{
    function BeginState() {}
}

state SeeADead
{
    function BeginState() {}
    function EndState() {}
}

state MovingToAttack
{
    function BeginState() {}
}

state LostSight
{
    function BeginState() {}
}

state PrecombatAction
{
    function BeginState() {}
}

state Configuration
{
}

state NoThreat
{
    function BeginState() {}
}

state EngageByThreat
{
    function BeginState() {}
    function EndState() {}
}

state EngageBySound
{
    function BeginState() {}
    function EndState() {}
    function Vector ChooseARandomPoint() {}
// ^ NEW IN 1.60
}

state Surrender
{
    function BeginState() {}
//============================================================================
//  ####   ###   ####  #   #  #####    #####  #####   ###   ####   ####  ##  #
//  ##  # ##  #   ##   ##  #   ##      ##     ##     ##  #  #   # ##     ##  #
//  ####  ##  #   ##   # # #   ##      #####  ####   #####  ####  ##     #####
//  ##    ##  #   ##   #  ##   ##         ##  ##     ##  #  ## #  ##     ##  #
//  ##     ###   ####  #   #   ##      #####  #####  ##  #  ##  #  ####  ##  #
//============================================================================
    event GotoPointAndSearch(Vector vDestination, eMovementPace ePace, bool bCallBackup, optional float fSearchTime, optional EDefCon eNewDefCon) {}
//============================================================================
// EscortIsOver - Called from the hostage AI when the escort is over
//============================================================================
    function EscortIsOver(R6HostageAI hostageAI, bool bSuccess) {}
//============================================================================
// AIAffectedByGrenade -
//============================================================================
    function AIAffectedByGrenade(Actor aGrenade, EGrenadeType eType) {}
}

state RunAway
{
    function BeginState() {}
    // Ignore GotoPointToAttack in state RunAway
    event GotoPointToAttack(Vector vDestination, Actor PTarget) {}
}

state AttackHostage
{
}

state GuardPoint
{
    function BeginState() {}
    function EndState() {}
}

state PatrolArea
{
    function BeginState() {}
    function EndState() {}
}

state PatrolPath
{
    function BeginState() {}
    function EndState() {}
}

state PA_PlayAnim
{
    function EndState() {}
}

state PA_LoopAnim
{
    function BeginState() {}
    function EndState() {}
}

defaultproperties
{
}
