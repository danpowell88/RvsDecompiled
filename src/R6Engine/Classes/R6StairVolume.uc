//=============================================================================
// R6StairVolume - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6StairVolume.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//=============================================================================
class R6StairVolume extends PhysicsVolume
    native;

var() bool m_bCreateIcon;
var() bool m_bRestrictedSpaceAtStairLimits;
var bool m_bShowLog;
var() R6StairOrientation m_pStairOrientation;
var Vector m_vOrientationNorm;

simulated function PostBeginPlay()
{
	// End:0x43
	if((m_pStairOrientation == none))
	{
		Log((("WARNING: " $ string(self)) $ " is missing m_pStairOrientation"));		
	}
	else
	{
		m_vOrientationNorm = Vector(m_pStairOrientation.Rotation);
	}
	return;
}

simulated event PawnEnteredVolume(Pawn P)
{
	local R6Pawn thisPawn;

	thisPawn = R6Pawn(P);
	// End:0x1D
	if((thisPawn == none))
	{
		return;
	}
	super.PawnEnteredVolume(P);
	// End:0x7A
	if((!thisPawn.m_bIsClimbingStairs))
	{
		// End:0x55
		if(m_bShowLog)
		{
			Log("STAIR: enter");
		}
		thisPawn.m_bIsClimbingStairs = true;
		thisPawn.ClimbStairs(m_vOrientationNorm);
	}
	return;
}

simulated event PawnLeavingVolume(Pawn P)
{
	local R6Pawn thisPawn;
	local Vector vDirection;

	thisPawn = R6Pawn(P);
	// End:0x1D
	if((thisPawn == none))
	{
		return;
	}
	super.PawnLeavingVolume(P);
	// End:0x41
	if(m_bShowLog)
	{
		Log("STAIR: leave");
	}
	// End:0x73
	if(thisPawn.m_bIsClimbingStairs)
	{
		thisPawn.m_bIsClimbingStairs = false;
		thisPawn.EndClimbStairs();
	}
	return;
}

defaultproperties
{
	m_bCreateIcon=true
}
