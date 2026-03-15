//=============================================================================
// Door - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
/*=============================================================================
 Door.
 Used to mark a door on the Navigation network (a door is a mover that may act
 as an obstruction).
=============================================================================
*/
class Door extends NavigationPoint
    native
    placeable
    hidecategories(Lighting,LightColor,Karma,Force);

var() bool bInitiallyClosed;  // if true, means that the initial position of the mover blocks navigation
var() bool bBlockedWhenClosed;  // don't even try to go through this path if door is closed
var bool bDoorOpen;
var bool bTempNoCollide;  // used during path building
var Mover MyDoor;
var Actor RecommendedTrigger;
var() name DoorTag;  // tag of mover associated with this node
var() name DoorTrigger;  // recommended trigger to use (if door is triggerable)

function PostBeginPlay()
{
	local Vector Dist;

	// End:0x9F
	if((DoorTrigger != 'None'))
	{
		// End:0x28
		foreach AllActors(Class'Engine.Actor', RecommendedTrigger, DoorTrigger)
		{
			// End:0x28
			break;			
		}		
		// End:0x9F
		if((RecommendedTrigger != none))
		{
			Dist = (Location - RecommendedTrigger.Location);
			// End:0x9F
			if((Abs(Dist.Z) < RecommendedTrigger.CollisionHeight))
			{
				Dist.Z = 0.0000000;
				// End:0x9F
				if((VSize(Dist) < RecommendedTrigger.CollisionRadius))
				{
					RecommendedTrigger = none;
				}
			}
		}
	}
	bBlocked = (bInitiallyClosed && bBlockedWhenClosed);
	bDoorOpen = (!bInitiallyClosed);
	super(Actor).PostBeginPlay();
	return;
}

function MoverOpened()
{
	bBlocked = ((!bInitiallyClosed) && bBlockedWhenClosed);
	bDoorOpen = bInitiallyClosed;
	return;
}

function MoverClosed()
{
	bBlocked = (bInitiallyClosed && bBlockedWhenClosed);
	bDoorOpen = (!bInitiallyClosed);
	return;
}

function Actor SpecialHandling(Pawn Other)
{
	// End:0x0D
	if((MyDoor == none))
	{
		return self;
	}
	// End:0x3E
	if(((int(MyDoor.BumpType) == int(0)) && (!Other.IsPlayerPawn())))
	{
		return none;
	}
	// End:0x79
	if((bInitiallyClosed == ((bDoorOpen || MyDoor.bOpening) || MyDoor.bDelaying)))
	{
		return self;
	}
	// End:0x8A
	if((RecommendedTrigger != none))
	{
		return RecommendedTrigger;
	}
	return self;
	return;
}

function bool ProceedWithMove(Pawn Other)
{
	// End:0x21
	if((bDoorOpen || (!MyDoor.bDamageTriggered)))
	{
		return true;
	}
	MyDoor.Trigger(Other, Other);
	Other.Controller.WaitForMover(MyDoor);
	return false;
	return;
}

event bool SuggestMovePreparation(Pawn Other)
{
	// End:0x0B
	if(bDoorOpen)
	{
		return false;
	}
	// End:0x50
	if((MyDoor.bOpening || MyDoor.bDelaying))
	{
		Other.Controller.WaitForMover(MyDoor);
		return true;
	}
	// End:0x9A
	if(MyDoor.bDamageTriggered)
	{
		MyDoor.Trigger(Other, Other);
		Other.Controller.WaitForMover(MyDoor);
		return true;
	}
	return false;
	return;
}

defaultproperties
{
	bInitiallyClosed=true
	ExtraCost=100
	bSpecialMove=true
	RemoteRole=0
	Texture=Texture'Engine.S_Door'
}
