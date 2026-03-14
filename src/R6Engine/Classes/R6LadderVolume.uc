//=============================================================================
//  R6LadderVolume.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/07/11 * Created by Rima Brek
//=============================================================================
class R6LadderVolume extends LadderVolume
    native;

#exec OBJ LOAD FILE=..\Textures\R6Engine_T.utx PACKAGE=R6Engine_T
#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons

// --- Constants ---
const C_iMaxClimbers =  6;

// --- Enums ---
enum  eLadderEndDirection   // only for getting off at top of ladder...
{
    LDR_Forward,
    LDR_Right,
    LDR_Left
} m_eLadderEndDirection;

enum eLadderCircumstantialAction
{
    CAL_None,
    CAL_Climb,
};
enum eLadderCircumstantialAction
{
    CAL_None,
    CAL_Climb,
};

// --- Variables ---
// support up to 6 pawn on a ladder at once...
var R6Pawn m_Climber[6];
var R6Ladder m_BottomLadder;
var R6Ladder m_TopLadder;
var R6LadderCollision m_BottomCollision;
var R6LadderCollision m_TopCollision;
var bool bShowLog;                // Enable verbose ladder-climbing debug logging
// ^ NEW IN 1.60
var float m_fBottomLadderActionRange;
var Sound m_FootSound;            // Footstep sound played when climbing this ladder
// ^ NEW IN 1.60
var Sound m_HandSound;            // Hand-grip sound played during ladder climbing
// ^ NEW IN 1.60
var Sound m_SlideSoundStop;       // Sound played when a pawn stops sliding down this ladder
// ^ NEW IN 1.60
var Sound m_SlideSound;           // Looping sound played while a pawn slides down this ladder
// ^ NEW IN 1.60
var eLadderEndDirection m_eLadderEndDirection;  // Which direction the pawn exits at the top of this ladder
// ^ NEW IN 1.60

// --- Functions ---
simulated function ResetOriginalData() {}
simulated function RemoveClimber(R6Pawn P) {}
function bool SpaceIsAvailableAtBottomOfLadder(optional bool bAvoidPlayerOnly) {}
// ^ NEW IN 1.60
simulated function AddClimber(R6Pawn P) {}
simulated event PawnLeavingVolume(Pawn P) {}
simulated event PawnEnteredVolume(Pawn P) {}
function bool IsAvailable(Pawn P) {}
// ^ NEW IN 1.60
function bool TopOfLadderIsAccessible() {}
// ^ NEW IN 1.60
function bool BottomOfLadderIsAccessible() {}
// ^ NEW IN 1.60
simulated function PostNetBeginPlay() {}
simulated event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController, float fDistance) {}
function EnableCollisions(R6Ladder Ladder) {}
function DisableCollisions(R6Ladder Ladder) {}
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60
simulated event PhysicsChangedFor(Actor Other) {}
function bool IsAShortLadder() {}
// ^ NEW IN 1.60
simulated event SetPotentialClimber() {}
function Destroyed() {}
// redefined PostBeginPlay() so that it is simulated
// (will be executed on the client as well during a multiplayer game)
simulated function PostBeginPlay() {}

state PotentialClimb
{
    simulated function Tick(float fDeltaTime) {}
}

defaultproperties
{
}
