//=============================================================================
// R6ClimbableObject - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//------------------------------------------------------------------
// R6ClimbableObject: an object that can be climbed by pawn.
//	An R6ClimbableObject as an orientation that shows the
//  direction of the climbing. They are meant to be used to climb
//  and then go on another box/level/new edge. I have not tested
//  the code when the R6ClimbableObject is placed alone. To use
//  those kind
//------------------------------------------------------------------
class R6ClimbableObject extends R6
    AbstractClimbableObj
    native;

enum EClimbHeight
{
	EClimbNone,                     // 0
	EClimb64,                       // 1
	EClimb96                        // 2
};

enum eClimbableObjectCircumstantialAction
{
	COBJ_None,                      // 0
	COBJ_Climb                      // 1
};

var(Collision) R6ClimbableObject.EClimbHeight m_eClimbHeight;
var R6ClimbablePoint m_climbablePoint;
var R6ClimbablePoint m_insideClimbablePoint;
var Vector m_vClimbDir;

replication
{
	// Pos:0x000
	reliable if((bNetInitial && (int(Role) == int(ROLE_Authority))))
		m_climbablePoint, m_eClimbHeight, 
		m_vClimbDir;
}

function PostBeginPlay()
{
	super(Actor).PostBeginPlay();
	m_vClimbDir = Vector(Rotation);
	m_vClimbDir = Normal(m_vClimbDir);
	return;
}

simulated function bool IsClimbableBy(R6Pawn P, bool bCheckCylinderTranslation, bool bCheckRotation)
{
	local Rotator rPawnRot;
	local float fFootZ, fDistance2d;
	local Vector vStart, vDest, vPawnLocation;

	// End:0x2A
	if((P.m_bIsProne || (P.m_climbObject != none)))
	{
		return false;
	}
	fFootZ = (P.Location.Z - P.CollisionHeight);
	// End:0x88
	if((!((fFootZ <= Location.Z) && ((Location.Z - CollisionHeight) <= fFootZ))))
	{
		return false;
	}
	rPawnRot = P.Rotation;
	rPawnRot.Pitch = 0;
	// End:0xCE
	if((bCheckRotation && (Dot(Vector(rPawnRot), m_vClimbDir) < float(0))))
	{
		return false;		
	}
	else
	{
		vPawnLocation = P.Location;
		vPawnLocation.Z = Location.Z;
		fDistance2d = ((VSize((vPawnLocation - Location)) - CollisionRadius) - P.CollisionRadius);
		// End:0x136
		if((fDistance2d > m_fCircumstantialActionRange))
		{
			return false;			
		}
		else
		{
			// End:0x1D1
			if(bCheckCylinderTranslation)
			{
				vDest = (P.Location + ((Vector(rPawnRot) * P.CollisionRadius) * 1.9000000));
				(vDest.Z += (CollisionHeight * float(2)));
				vStart = P.Location;
				vStart.Z = vDest.Z;
				// End:0x1D1
				if((!P.CheckCylinderTranslation(vStart, vDest, self)))
				{
					return false;
				}
			}
		}
	}
	return true;
	return;
}

event Bump(Actor Other)
{
	local R6Pawn P;

	P = R6Pawn(Other);
	// End:0x1D
	if((P == none))
	{
		return;
	}
	// End:0x31
	if(P.m_bIsPlayer)
	{
		return;
	}
	// End:0xAA
	if(((((P.Controller != none) && R6AIController(P.Controller).CanClimbObject()) && IsClimbableBy(P, false, false)) && (!P.Controller.IsInState('ClimbObject'))))
	{
		P.StartClimbObject(self);
	}
	return;
}

simulated event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	local R6Pawn P;

	P = R6Pawn(PlayerController.Pawn);
	Query.iHasAction = 1;
	// End:0x5E
	if(IsClimbableBy(P, true, true))
	{
		Query.iInRange = 1;
		P.PotentialClimbableObject(self);		
	}
	else
	{
		Query.iInRange = 0;
		P.RemovePotentialClimbableObject(self);
	}
	Query.textureIcon = Texture'R6ActionIcons.ClimbObject';
	Query.iPlayerActionID = 1;
	Query.iTeamActionID = 0;
	Query.iTeamActionIDList[0] = 0;
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

event Attach(Actor pActor)
{
	local R6Pawn pPawn;

	pPawn = R6Pawn(pActor);
	// End:0x2B
	if((pPawn != none))
	{
		pPawn.AttachToClimbableObject(self);
	}
	return;
}

event Detach(Actor pActor)
{
	local R6Pawn pPawn;

	pPawn = R6Pawn(pActor);
	// End:0x2B
	if((pPawn != none))
	{
		pPawn.DetachFromClimbableObject(self);
	}
	return;
}

defaultproperties
{
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bDirectional=true
	bObsolete=true
	CollisionRadius=40.0000000
	CollisionHeight=32.0000000
	m_fCircumstantialActionRange=30.0000000
}
