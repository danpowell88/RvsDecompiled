//=============================================================================
//  R6PlanningPawn.uc : Pawn of the R6PlanningCtrl
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6PlanningPawn extends R6Pawn;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

// --- Variables ---
var R6ArrowIcon m_ArrowInPlanningView;
var R6PlanningInfo m_PlanToFollow;
var Actor m_pActorToReach;
var Rotator m_rDirRot;
var float m_fSpeed;

// --- Functions ---
function ArrowRotationIsOK() {}
function ArrowReachedNavPoint() {}
function FollowPlanning(R6PlanningInfo m_pTeamInfo) {}
simulated function PlayDuck() {}
event Landed(Vector HitNormal) {}
event Falling() {}
function StopFollowingPlanning() {}
function ClientReStart() {}
simulated event ChangeAnimation() {}
event PostBeginPlay() {}

state FollowPlan
{
    function bool ChangeArrowParameters(optional bool bFirstInit) {}
// ^ NEW IN 1.60
    function BeginState() {}
    function EndState() {}
    function ArrowReachedNavPoint() {}
    function ArrowRotationIsOK() {}
}

defaultproperties
{
}
