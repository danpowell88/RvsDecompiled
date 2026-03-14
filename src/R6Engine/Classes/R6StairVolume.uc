//=============================================================================
//  R6StairVolume.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//=============================================================================
class R6StairVolume extends PhysicsVolume
    native;

// --- Variables ---
var R6StairOrientation m_pStairOrientation;  // Actor defining the up-direction and bounds of this staircase
// ^ NEW IN 1.60
var Vector m_vOrientationNorm;
var bool m_bShowLog;
var bool m_bRestrictedSpaceAtStairLimits;  // Narrow landings at stair ends; disables sideways movement there
// ^ NEW IN 1.60
var bool m_bCreateIcon;           // Spawn a stair icon actor visible in the editor for this volume
// ^ NEW IN 1.60

// --- Functions ---
simulated event PawnEnteredVolume(Pawn P) {}
simulated event PawnLeavingVolume(Pawn P) {}
simulated function PostBeginPlay() {}

defaultproperties
{
}
