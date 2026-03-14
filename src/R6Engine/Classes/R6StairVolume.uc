//=============================================================================
//  R6StairVolume.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//=============================================================================
class R6StairVolume extends PhysicsVolume
    native;

// --- Variables ---
var R6StairOrientation m_pStairOrientation;
// ^ NEW IN 1.60
var Vector m_vOrientationNorm;
var bool m_bShowLog;
var bool m_bRestrictedSpaceAtStairLimits;
// ^ NEW IN 1.60
var bool m_bCreateIcon;
// ^ NEW IN 1.60

// --- Functions ---
simulated event PawnEnteredVolume(Pawn P) {}
simulated event PawnLeavingVolume(Pawn P) {}
simulated function PostBeginPlay() {}

defaultproperties
{
}
