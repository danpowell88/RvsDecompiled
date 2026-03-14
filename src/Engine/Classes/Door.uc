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
	if(__NFUN_255__(DoorTrigger, 'None'))
	{
		// End:0x28
		foreach __NFUN_304__(Class'Engine.Actor', RecommendedTrigger, DoorTrigger)
		{
			// End:0x28
			break;			
		}		
		// End:0x9F
		if(__NFUN_119__(RecommendedTrigger, none))
		{
			Dist = __NFUN_216__(Location, RecommendedTrigger.Location);
			// End:0x9F
			if(__NFUN_176__(__NFUN_186__(Dist.Z), RecommendedTrigger.CollisionHeight))
			{
				Dist.Z = 0.0000000;
				// End:0x9F
				if(__NFUN_176__(__NFUN_225__(Dist), RecommendedTrigger.CollisionRadius))
				{
					RecommendedTrigger = none;
				}
			}
		}
	}
	bBlocked = __NFUN_130__(bInitiallyClosed, bBlockedWhenClosed);
	bDoorOpen = __NFUN_129__(bInitiallyClosed);
	super(Actor).PostBeginPlay();
	return;
}

function MoverOpened()
{
	bBlocked = __NFUN_130__(__NFUN_129__(bInitiallyClosed), bBlockedWhenClosed);
	bDoorOpen = bInitiallyClosed;
	return;
}

function MoverClosed()
{
	bBlocked = __NFUN_130__(bInitiallyClosed, bBlockedWhenClosed);
	bDoorOpen = __NFUN_129__(bInitiallyClosed);
	return;
}

function Actor SpecialHandling(Pawn Other)
{
	// End:0x0D
	if(__NFUN_114__(MyDoor, none))
	{
		return self;
	}
	// End:0x3E
	if(__NFUN_130__(__NFUN_154__(int(MyDoor.BumpType), int(0)), __NFUN_129__(Other.IsPlayerPawn())))
	{
		return none;
	}
	// End:0x79
	if(__NFUN_242__(bInitiallyClosed, __NFUN_132__(__NFUN_132__(bDoorOpen, MyDoor.bOpening), MyDoor.bDelaying)))
	{
		return self;
	}
	// End:0x8A
	if(__NFUN_119__(RecommendedTrigger, none))
	{
		return RecommendedTrigger;
	}
	return self;
	return;
}

function bool ProceedWithMove(Pawn Other)
{
	// End:0x21
	if(__NFUN_132__(bDoorOpen, __NFUN_129__(MyDoor.bDamageTriggered)))
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
	if(__NFUN_132__(MyDoor.bOpening, MyDoor.bDelaying))
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
