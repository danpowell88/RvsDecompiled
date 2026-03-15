//=============================================================================
// R6PlanningPawn - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PlanningPawn.uc : Pawn of the R6PlanningCtrl
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6PlanningPawn extends R6Pawn;

var float m_fSpeed;
var R6ArrowIcon m_ArrowInPlanningView;
var R6PlanningInfo m_PlanToFollow;
var Actor m_pActorToReach;
var Rotator m_rDirRot;

function ArrowReachedNavPoint()
{
	return;
}

function ArrowRotationIsOK()
{
	return;
}

event PostBeginPlay()
{
	m_ArrowInPlanningView = Spawn(Class'R6Game.R6ArrowIcon', self);
	return;
}

simulated event ChangeAnimation()
{
	return;
}

function ClientReStart()
{
	return;
}

function FollowPlanning(R6PlanningInfo m_pTeamInfo)
{
	m_PlanToFollow = m_pTeamInfo;
	m_PlanToFollow.m_iCurrentPathIndex = -1;
	GotoState('FollowPlan');
	return;
}

function StopFollowingPlanning()
{
	GotoState('None');
	return;
}

event Falling()
{
	return;
}

event Landed(Vector HitNormal)
{
	m_bIsLanding = true;
	Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	Velocity = vect(0.0000000, 0.0000000, 0.0000000);
	return;
}

simulated function PlayDuck()
{
	return;
}

state FollowPlan
{
	function bool ChangeArrowParameters(optional bool bFirstInit)
	{
		local Vector vDir;
		local R6PlanningCtrl OwnerPlanningCtrl;

		OwnerPlanningCtrl = R6PlanningCtrl(Owner);
		m_pActorToReach = m_PlanToFollow.GetNextActionPoint();
		// End:0x4DB
		if(((m_pActorToReach != none) && (m_PlanToFollow.PreviewNextActionPoint() != none)))
		{
			// End:0xA3
			if((m_pActorToReach.IsA('R6Ladder') && (R6Ladder(m_pActorToReach).m_bIsTopOfLadder == false)))
			{
				m_ArrowInPlanningView.SetLocation((m_pActorToReach.Location + vect(0.0000000, 0.0000000, 100.0000000)));				
			}
			else
			{
				m_ArrowInPlanningView.SetLocation(m_pActorToReach.Location);
			}
			m_ArrowInPlanningView.m_iPlanningFloor_0 = m_pActorToReach.m_iPlanningFloor_0;
			m_ArrowInPlanningView.m_iPlanningFloor_1 = m_pActorToReach.m_iPlanningFloor_1;
			// End:0x161
			if((m_pActorToReach.IsA('R6Stairs') && (R6Stairs(m_pActorToReach).m_bIsTopOfStairs == true)))
			{
				OwnerPlanningCtrl.SetFloorToDraw(m_ArrowInPlanningView.m_iPlanningFloor_1);
				OwnerPlanningCtrl.m_iLevelDisplay = m_ArrowInPlanningView.m_iPlanningFloor_1;				
			}
			else
			{
				OwnerPlanningCtrl.SetFloorToDraw(m_ArrowInPlanningView.m_iPlanningFloor_0);
				OwnerPlanningCtrl.m_iLevelDisplay = m_ArrowInPlanningView.m_iPlanningFloor_0;
			}
			m_ArrowInPlanningView.m_vPointToReach = m_PlanToFollow.PreviewNextActionPoint().Location;
			// End:0x25C
			if((m_PlanToFollow.PreviewNextActionPoint().IsA('R6Ladder') && (R6Ladder(m_PlanToFollow.PreviewNextActionPoint()).m_bIsTopOfLadder == false)))
			{
				(m_ArrowInPlanningView.m_vPointToReach.Z += float(100));
				vDir = ((m_PlanToFollow.PreviewNextActionPoint().Location + vect(0.0000000, 0.0000000, 100.0000000)) - m_pActorToReach.Location);				
			}
			else
			{
				vDir = (m_PlanToFollow.PreviewNextActionPoint().Location - m_pActorToReach.Location);
			}
			m_ArrowInPlanningView.m_vStartLocation = m_pActorToReach.Location;
			m_rDirRot = Rotator(vDir);
			// End:0x431
			if((bFirstInit == true))
			{
				m_ArrowInPlanningView.SetRotation(m_rDirRot);
				m_ArrowInPlanningView.SetPhysics(6);
				m_ArrowInPlanningView.m_u8SpritePlanningAngle = byte(((m_rDirRot.Yaw / 255) + 64));
				m_ArrowInPlanningView.DesiredRotation = m_rDirRot;
				// End:0x42E
				if((m_PlanToFollow.GetNextPoint() != none))
				{
					// End:0x38E
					if((int(m_PlanToFollow.GetNextPoint().m_eMovementSpeed) == int(0)))
					{
						m_ArrowInPlanningView.RotationRate.Pitch = 15000;
						m_ArrowInPlanningView.RotationRate.Yaw = 15000;
						m_fSpeed = 600.0000000;						
					}
					else
					{
						// End:0x3F1
						if((int(m_PlanToFollow.GetNextPoint().m_eMovementSpeed) == int(2)))
						{
							m_ArrowInPlanningView.RotationRate.Pitch = 7500;
							m_ArrowInPlanningView.RotationRate.Yaw = 7500;
							m_fSpeed = 250.0000000;							
						}
						else
						{
							m_ArrowInPlanningView.RotationRate.Pitch = 11000;
							m_ArrowInPlanningView.RotationRate.Yaw = 11000;
							m_fSpeed = 350.0000000;
						}
					}
				}				
			}
			else
			{
				m_ArrowInPlanningView.SetPhysics(5);
				m_ArrowInPlanningView.DesiredRotation = m_rDirRot;
				m_ArrowInPlanningView.DesiredRotation.Pitch = (m_rDirRot.Pitch & 65535);
				m_ArrowInPlanningView.DesiredRotation.Yaw = (m_rDirRot.Yaw & 65535);
				m_ArrowInPlanningView.DesiredRotation.Roll = m_rDirRot.Roll;
			}
			m_ArrowInPlanningView.Velocity = (m_fSpeed * Vector(m_rDirRot));			
		}
		else
		{
			WindowConsole(PlayerController(Controller).Player.Console).Root.StopPlayMode();
			OwnerPlanningCtrl.m_bPlayMode = false;
			OwnerPlanningCtrl.StopPlayingPlanning();
			return false;
		}
		return true;
		return;
	}

	function ArrowRotationIsOK()
	{
		m_ArrowInPlanningView.SetRotation(m_rDirRot);
		m_ArrowInPlanningView.SetPhysics(6);
		return;
	}

	function ArrowReachedNavPoint()
	{
		// End:0x16D
		if((m_PlanToFollow.m_iCurrentPathIndex == (m_PlanToFollow.GetPoint().m_PathToNextPoint.Length - 1)))
		{
			m_PlanToFollow.m_iCurrentPathIndex = -1;
			m_PlanToFollow.SetToNextNode();
			// End:0x16A
			if((m_PlanToFollow.GetNextPoint() != none))
			{
				// End:0xCA
				if((int(m_PlanToFollow.GetNextPoint().m_eMovementSpeed) == int(0)))
				{
					m_ArrowInPlanningView.RotationRate.Pitch = 15000;
					m_ArrowInPlanningView.RotationRate.Yaw = 15000;
					m_fSpeed = 600.0000000;					
				}
				else
				{
					// End:0x12D
					if((int(m_PlanToFollow.GetNextPoint().m_eMovementSpeed) == int(2)))
					{
						m_ArrowInPlanningView.RotationRate.Pitch = 7500;
						m_ArrowInPlanningView.RotationRate.Yaw = 7500;
						m_fSpeed = 250.0000000;						
					}
					else
					{
						m_ArrowInPlanningView.RotationRate.Pitch = 11000;
						m_ArrowInPlanningView.RotationRate.Yaw = 11000;
						m_fSpeed = 350.0000000;
					}
				}
			}			
		}
		else
		{
			(m_PlanToFollow.m_iCurrentPathIndex++);
		}
		// End:0x190
		if((ChangeArrowParameters() == false))
		{
			GotoState('None');
		}
		return;
	}

	function EndState()
	{
		m_ArrowInPlanningView.GotoState('None');
		return;
	}

	function BeginState()
	{
		m_ArrowInPlanningView.GotoState('FollowPath');
		ChangeArrowParameters(true);
		return;
	}
	stop;
}

defaultproperties
{
	m_fSpeed=300.0000000
	m_bCanProne=false
	bCanStrafe=true
	MenuName="Planning Assistant"
	CollisionHeight=80.0000000
	KParams=KarmaParamsSkel'R6Game.KarmaParamsSkel283'
}
