//=============================================================================
// R6Ladder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  Ladder.uc : invisible actor used to mark the top and bottom of a ladder
//              (navigation point)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/06/05 * Created by Rima Brek
//=============================================================================
class R6Ladder extends Ladder
    native
    hidecategories(Lighting,LightColor,Karma,Force);

var() bool m_bIsTopOfLadder;  // set to true when this ladder actor is at the top of a ladderVolume
var() bool m_bSingleFileFormationOnly;
var bool bShowLog;
var R6Ladder m_pOtherFloor;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bIsTopOfLadder;
}

//used for initial detection for exiting a ladder - for animation playing purposes...
simulated function Touch(Actor Other)
{
	local R6Pawn Pawn;

	Pawn = R6Pawn(Other);
	// End:0x49
	if((((Pawn == none) || (!Pawn.bCanClimbLadders)) || (Pawn.Controller == none)))
	{
		return;
	}
	// End:0x80
	if(bShowLog)
	{
		Log(((string(Pawn) $ " has touched ladder actor : ") $ string(self)));
	}
	Pawn.m_Ladder = self;
	// End:0x269
	if((int(Pawn.Physics) == int(11)))
	{
		// End:0xCC
		if(((!Pawn.bIsWalking) && (!m_bIsTopOfLadder)))
		{
			return;
		}
		// End:0x179
		if(Pawn.m_bIsPlayer)
		{
			// End:0x176
			if(Pawn.m_bIsClimbingLadder)
			{
				// End:0x176
				if((((Dot(Normal(Pawn.Acceleration), Normal(MyLadder.ClimbDir)) < -0.9000000) && (!m_bIsTopOfLadder)) || ((Dot(Normal(Pawn.Acceleration), Normal(MyLadder.ClimbDir)) > 0.9000000) && m_bIsTopOfLadder)))
				{
					Pawn.EndClimbLadder(MyLadder);
				}
			}			
		}
		else
		{
			// End:0x1B4
			if(bShowLog)
			{
				Log((" pawn.m_bIsClimbingLadder =" $ string(Pawn.m_bIsClimbingLadder)));
			}
			// End:0x264
			if((Pawn.m_bIsClimbingLadder && (!Pawn.Controller.IsInState('EndClimbingLadder'))))
			{
				// End:0x226
				if(((Pawn.Acceleration.Z > 30.0000000) && m_bIsTopOfLadder))
				{
					Pawn.EndClimbLadder(MyLadder);					
				}
				else
				{
					// End:0x264
					if(((Pawn.Acceleration.Z < 30.0000000) && (!m_bIsTopOfLadder)))
					{
						Pawn.EndClimbLadder(MyLadder);
					}
				}
			}
		}
		return;		
	}
	else
	{
		// End:0x2A9
		if(bShowLog)
		{
			Log(((string(Pawn) $ " is not in PHYSICS_Ladder yet... for ") $ string(self)));
		}
		// End:0x2BD
		if(Pawn.m_bIsClimbingLadder)
		{
			return;
		}
		// End:0x2DA
		if(m_bIsTopOfLadder)
		{
			Pawn.PotentialClimbLadder(MyLadder);
		}
		// End:0x2F9
		if(Pawn.Controller.IsInState('ApproachLadder'))
		{
			return;
		}
		// End:0x451
		if(((int(Pawn.m_ePawnType) != int(1)) && R6AIController(Pawn.Controller).CanClimbLadders(self)))
		{
			// End:0x451
			if(((m_bIsTopOfLadder && (Dot(Vector(Pawn.Rotation), MyLadder.LookDir) < float(0))) || ((!m_bIsTopOfLadder) && (Dot(Vector(Pawn.Rotation), MyLadder.LookDir) > float(0)))))
			{
				// End:0x3ED
				if(bShowLog)
				{
					Log((string(Pawn) $ " was detected by R6Ladder));
				}
				Pawn.Controller.NextState = Pawn.Controller.GetStateName();
				Pawn.Controller.MoveTarget = self;
				R6AIController(Pawn.Controller).GotoState('ApproachLadder');
			}
		}
	}
	return;
}

event bool SuggestMovePreparation(Pawn Other)
{
	return false;
	return;
}

defaultproperties
{
	m_eDisplayFlag=0
	bHidden=false
	bCollideActors=true
	m_bBulletGoThrough=true
	m_bSpriteShowFlatInPlanning=true
	DrawScale=2.0000000
	CollisionRadius=35.0000000
	CollisionHeight=14.0000000
	Texture=Texture'R6Planning.Icons.PlanIcon_Ladder'
}
