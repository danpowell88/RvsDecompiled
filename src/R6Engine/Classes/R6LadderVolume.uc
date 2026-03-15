//=============================================================================
// R6LadderVolume - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6LadderVolume.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/07/11 * Created by Rima Brek
//=============================================================================
class R6LadderVolume extends LadderVolume
    native;

const C_iMaxClimbers = 6;

enum eLadderEndDirection
{
	LDR_Forward,                    // 0
	LDR_Right,                      // 1
	LDR_Left                        // 2
};

enum eLadderCircumstantialAction
{
	CAL_None,                       // 0
	CAL_Climb                       // 1
};

// NEW IN 1.60
var() R6LadderVolume.eLadderEndDirection m_eLadderEndDirection;
var(Debug) bool bShowLog;
var float m_fBottomLadderActionRange;
var R6Ladder m_TopLadder;
var R6Ladder m_BottomLadder;
var R6LadderCollision m_TopCollision;
var R6LadderCollision m_BottomCollision;
// NEW IN 1.60
var R6Pawn m_Climber[6];
var(R6Sound) Sound m_SlideSound;
var(R6Sound) Sound m_SlideSoundStop;
var(R6Sound) Sound m_HandSound;
var(R6Sound) Sound m_FootSound;

// redefined PostBeginPlay() so that it is simulated 
// (will be executed on the client as well during a multiplayer game)
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	PostNetBeginPlay();
	return;
}

simulated function PostNetBeginPlay()
{
	local Ladder L, M;
	local Vector vDir;

	// End:0x41
	if((LadderList == none))
	{
		Log(("WARNING - no Ladder actors in LadderVolume " $ string(self)));
		return;
	}
	LookDir = Vector(LadderList.Rotation);
	WallDir = Rotator(LookDir);
	// End:0x1E4
	if((!bAutoPath))
	{
		ClimbDir = vect(0.0000000, 0.0000000, 0.0000000);
		L = LadderList;
		J0x8D:

		// End:0x1AD [Loop If]
		if((L != none))
		{
			M = LadderList;
			J0xA3:

			// End:0x196 [Loop If]
			if((M != none))
			{
				// End:0x17F
				if((M != L))
				{
					vDir = Normal((M.Location - L.Location));
					// End:0x105
					if((Dot(vDir, ClimbDir) < float(0)))
					{
						(vDir *= float(-1));
					}
					(ClimbDir += vDir);
					// End:0x15F
					if((M.Location.Z > L.Location.Z))
					{
						m_TopLadder = R6Ladder(M);
						m_BottomLadder = R6Ladder(L);						
					}
					else
					{
						m_TopLadder = R6Ladder(L);
						m_BottomLadder = R6Ladder(M);
					}
				}
				M = M.LadderList;
				// [Loop Continue]
				goto J0xA3;
			}
			L = L.LadderList;
			// [Loop Continue]
			goto J0x8D;
		}
		ClimbDir = Normal(ClimbDir);
		// End:0x1E4
		if((Dot(ClimbDir, vect(0.0000000, 0.0000000, 1.0000000)) < float(0)))
		{
			(ClimbDir *= float(-1));
		}
	}
	ClimbDir.X = 0.0000000;
	ClimbDir.Y = 0.0000000;
	// End:0x2C5
	if((int(Level.NetMode) != int(NM_Client)))
	{
		// End:0x271
		if((m_TopCollision == none))
		{
			m_TopCollision = Spawn(Class'R6Engine.R6LadderCollision', self,, (m_TopLadder.Location - vect(0.0000000, 0.0000000, 239.0000000)), rot(0, 0, 0));
			m_TopCollision.SetCollision(false, false, false);
		}
		// End:0x2C5
		if((m_BottomCollision == none))
		{
			m_BottomCollision = Spawn(Class'R6Engine.R6LadderCollision', self,, (m_BottomLadder.Location + vect(0.0000000, 0.0000000, 199.0000000)), rot(0, 0, 0));
			m_BottomCollision.SetCollision(false, false, false);
		}
	}
	return;
}

function Destroyed()
{
	// End:0x1E
	if((m_TopCollision != none))
	{
		m_TopCollision.Destroy();
		m_TopCollision = none;
	}
	// End:0x3C
	if((m_BottomCollision != none))
	{
		m_BottomCollision.Destroy();
		m_BottomCollision = none;
	}
	return;
}

simulated function ResetOriginalData()
{
	local int i;

	// End:0x1A
	if((m_TopCollision != none))
	{
		m_TopCollision.SetCollision(false, false, false);
	}
	// End:0x34
	if((m_BottomCollision != none))
	{
		m_BottomCollision.SetCollision(false, false, false);
	}
	i = 0;
	J0x3B:

	// End:0x5E [Loop If]
	if((i < 6))
	{
		m_Climber[i] = none;
		(i++);
		// [Loop Continue]
		goto J0x3B;
	}
	return;
}

function EnableCollisions(R6Ladder Ladder)
{
	// End:0x21
	if((Ladder == m_TopLadder))
	{
		m_TopCollision.SetCollision(true, true, true);		
	}
	else
	{
		m_BottomCollision.SetCollision(true, true, true);
	}
	return;
}

function DisableCollisions(R6Ladder Ladder)
{
	// End:0x21
	if((Ladder == m_TopLadder))
	{
		m_TopCollision.SetCollision(false, false, false);		
	}
	else
	{
		m_BottomCollision.SetCollision(false, false, false);
	}
	return;
}

simulated event PawnEnteredVolume(Pawn P)
{
	local R6Pawn Pawn;
	local Rotator rPawnRot;

	Pawn = R6Pawn(P);
	// End:0x49
	if((((Pawn == none) || (!Pawn.bCanClimbLadders)) || (Pawn.Controller == none)))
	{
		return;
	}
	// End:0x70
	if(P.IsPlayerPawn())
	{
		TriggerEvent(Event, P, P);
	}
	rPawnRot = Pawn.Rotation;
	rPawnRot.Pitch = 0;
	// End:0xCF
	if((Dot(Vector(rPawnRot), LookDir) > 0.9000000))
	{
		// End:0xBC
		if(Pawn.m_bIsClimbingLadder)
		{
			return;
		}
		Pawn.PotentialClimbLadder(self);		
	}
	else
	{
		SetPotentialClimber();
	}
	return;
}

simulated event PawnLeavingVolume(Pawn P)
{
	// End:0x27
	if(P.IsPlayerPawn())
	{
		UntriggerEvent(Event, P, P);
	}
	// End:0x53
	if((int(P.Physics) == int(11)))
	{
		P.EndClimbLadder(self);		
	}
	else
	{
		R6Pawn(P).RemovePotentialClimbLadder(self);
	}
	return;
}

simulated event SetPotentialClimber()
{
	GotoState('PotentialClimb');
	return;
}

simulated function AddClimber(R6Pawn P)
{
	local int i;

	// End:0x29
	if(bShowLog)
	{
		Log(((string(self) $ " AddClimber : ") $ string(P)));
	}
	i = 0;
	J0x30:

	// End:0x83 [Loop If]
	if((i < 6))
	{
		// End:0x54
		if((m_Climber[i] == P))
		{
			// [Explicit Break]
			goto J0x83;
		}
		// End:0x79
		if((m_Climber[i] == none))
		{
			m_Climber[i] = P;
			// [Explicit Break]
			goto J0x83;
		}
		(i++);
		// [Loop Continue]
		goto J0x30;
	}
	J0x83:

	return;
}

simulated function RemoveClimber(R6Pawn P)
{
	local int i;

	// End:0x2D
	if(bShowLog)
	{
		Log(((string(self) $ " Remove Climber : ") $ string(P)));
	}
	i = 0;
	J0x34:

	// End:0x6F [Loop If]
	if((i < 6))
	{
		// End:0x65
		if((m_Climber[i] == P))
		{
			m_Climber[i] = none;
			// [Explicit Break]
			goto J0x6F;
		}
		(i++);
		// [Loop Continue]
		goto J0x34;
	}
	J0x6F:

	return;
}

function bool IsAvailable(Pawn P)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x6F [Loop If]
	if((i < 6))
	{
		// End:0x65
		if((m_Climber[i] != none))
		{
			// End:0x4E
			if((!m_Climber[i].IsValidClimber()))
			{
				m_Climber[i] = none;
				// [Explicit Continue]
				goto J0x65;
			}
			// End:0x65
			if((m_Climber[i] != P))
			{
				return false;
			}
		}
		J0x65:

		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return true;
	return;
}

function bool TopOfLadderIsAccessible()
{
	local float fTopZLimit;
	local int i;

	fTopZLimit = (m_TopLadder.Location.Z - 240.0000000);
	i = 0;
	J0x27:

	// End:0xB6 [Loop If]
	if((i < 6))
	{
		// End:0x47
		if((m_Climber[i] == none))
		{
			// [Explicit Continue]
			goto J0xAC;
		}
		// End:0x71
		if((!m_Climber[i].IsValidClimber()))
		{
			m_Climber[i] = none;
			// [Explicit Continue]
			goto J0xAC;
		}
		// End:0xAC
		if(((m_Climber[i].Location.Z + m_Climber[i].CollisionHeight) > fTopZLimit))
		{
			return false;
		}
		J0xAC:

		(i++);
		// [Loop Continue]
		goto J0x27;
	}
	return true;
	return;
}

function bool BottomOfLadderIsAccessible()
{
	local float fBottomZLimit;
	local int i;

	fBottomZLimit = (m_BottomLadder.Location.Z + 200.0000000);
	i = 0;
	J0x27:

	// End:0xB6 [Loop If]
	if((i < 6))
	{
		// End:0x47
		if((m_Climber[i] == none))
		{
			// [Explicit Continue]
			goto J0xAC;
		}
		// End:0x71
		if((!m_Climber[i].IsValidClimber()))
		{
			m_Climber[i] = none;
			// [Explicit Continue]
			goto J0xAC;
		}
		// End:0xAC
		if(((m_Climber[i].Location.Z - m_Climber[i].CollisionHeight) < fBottomZLimit))
		{
			return false;
		}
		J0xAC:

		(i++);
		// [Loop Continue]
		goto J0x27;
	}
	return true;
	return;
}

function bool SpaceIsAvailableAtBottomOfLadder(optional bool bAvoidPlayerOnly)
{
	local R6Pawn Pawn;
	local Vector vDist;

	// End:0xCA
	foreach TouchingActors(Class'R6Engine.R6Pawn', Pawn)
	{
		// End:0x28
		if((!Pawn.IsAlive()))
		{
			continue;			
		}
		// End:0x4B
		if((bAvoidPlayerOnly && (!Pawn.m_bIsPlayer)))
		{
			continue;			
		}
		// End:0x82
		if((Abs((Pawn.Location.Z - m_BottomLadder.Location.Z)) > float(100)))
		{
			continue;			
		}
		vDist = (Pawn.Location - m_BottomLadder.Location);
		vDist.Z = 0.0000000;
		// End:0xC9
		if((VSize(vDist) < float(90)))
		{			
			return false;
		}		
	}	
	return true;
	return;
}

function bool IsAShortLadder()
{
	// End:0x36
	if(((m_TopLadder.Location.Z - m_BottomLadder.Location.Z) < float(340)))
	{
		return true;
	}
	return false;
	return;
}

simulated event PhysicsChangedFor(Actor Other)
{
	return;
}

simulated event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	local float fXYDistance;
	local Vector vLocation, vPawnLocation;
	local float fResult, fPawnFootZ;

	// End:0x59
	if((R6Pawn(PlayerController.Pawn).m_bIsClimbingLadder || (IsAShortLadder() && (!IsAvailable(PlayerController.Pawn)))))
	{
		Query.iHasAction = 0;
		return;
	}
	vLocation = Location;
	vLocation.Z = 0.0000000;
	vPawnLocation = PlayerController.Pawn.Location;
	vPawnLocation.Z = 0.0000000;
	fXYDistance = VSize((vLocation - vPawnLocation));
	Query.iHasAction = 1;
	fPawnFootZ = (PlayerController.Pawn.Location.Z - PlayerController.Pawn.CollisionHeight);
	// End:0x206
	if((PlayerController.Pawn.Location.Z < Location.Z))
	{
		// End:0x15D
		if((fPawnFootZ > m_BottomLadder.Location.Z))
		{
			Query.iInRange = 0;			
		}
		else
		{
			fResult = Dot(Vector(PlayerController.Pawn.Rotation), Vector(m_BottomLadder.Rotation));
			// End:0x1B1
			if((fResult < 0.8000000))
			{
				Query.iInRange = 0;				
			}
			else
			{
				// End:0x1F2
				if((fXYDistance < m_fBottomLadderActionRange))
				{
					Query.iInRange = 1;
					// End:0x1EF
					if((!BottomOfLadderIsAccessible()))
					{
						Query.iHasAction = 0;
						return;
					}					
				}
				else
				{
					Query.iInRange = 0;
				}
			}
		}		
	}
	else
	{
		// End:0x237
		if((fPawnFootZ > m_TopLadder.Location.Z))
		{
			Query.iInRange = 0;			
		}
		else
		{
			fResult = Dot(Vector(PlayerController.Pawn.Rotation), (-Vector(m_TopLadder.Rotation)));
			// End:0x28D
			if((fResult < 0.9000000))
			{
				Query.iInRange = 0;				
			}
			else
			{
				// End:0x2F5
				if((fXYDistance < m_fCircumstantialActionRange))
				{
					Query.iInRange = 1;
					// End:0x2CB
					if((!TopOfLadderIsAccessible()))
					{
						Query.iHasAction = 0;
						return;
					}
					// End:0x2F2
					if(IsAShortLadder())
					{
						// End:0x2F2
						if((!SpaceIsAvailableAtBottomOfLadder()))
						{
							Query.iHasAction = 0;
							return;
						}
					}					
				}
				else
				{
					Query.iInRange = 0;
				}
			}
		}
	}
	Query.textureIcon = Texture'R6ActionIcons.Climb';
	Query.iPlayerActionID = 1;
	Query.iTeamActionID = 1;
	Query.iTeamActionIDList[0] = 1;
	Query.iTeamActionIDList[1] = 0;
	Query.iTeamActionIDList[2] = 0;
	Query.iTeamActionIDList[3] = 0;
	return;
}

simulated function string R6GetCircumstantialActionString(int iAction)
{
	switch(iAction)
	{
		// End:0x34
		case int(1):
			return Localize("RDVOrder", "Order_Climb", "R6Menu");
		// End:0xFFFF
		default:
			return "";
			break;
	}
	return;
}

state PotentialClimb
{
	simulated function Tick(float fDeltaTime)
	{
		local Rotator rPawnRot;
		local R6Pawn Pawn;
		local bool bFound;

		// End:0xB5
		foreach TouchingActors(Class'R6Engine.R6Pawn', Pawn)
		{
			// End:0xB4
			if(((Pawn.Controller != none) && (int(Pawn.Physics) != int(11))))
			{
				// End:0xB4
				if(Encompasses(Pawn))
				{
					rPawnRot = Pawn.Rotation;
					rPawnRot.Pitch = 0;
					// End:0xAC
					if((Dot(Vector(rPawnRot), LookDir) > 0.9000000))
					{
						// End:0xA9
						if((!Pawn.m_bIsClimbingLadder))
						{
							Pawn.PotentialClimbLadder(self);
						}
						// End:0xB4
						continue;
					}
					bFound = true;
				}
			}			
		}		
		// End:0xC8
		if((!bFound))
		{
			GotoState('None');
		}
		return;
	}
	stop;
}

defaultproperties
{
	m_fBottomLadderActionRange=30.0000000
	bStatic=false
	m_fCircumstantialActionRange=110.0000000
	NetPriority=2.7000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_ClimberC_iMaxClimbers
// REMOVED IN 1.60: var eLadderEndDirection
