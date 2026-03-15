//=============================================================================
// LineOfSightTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// LineOfSightTrigger
// triggers its event when player looks at it from close enough
// ONLY WORKS IN SINGLE PLAYER (or for the local client on a listen server)
// You could implement a multiplayer version using a tick function and PlayerCanSeeMe(),
// but that would have more performance cost
//=============================================================================
class LineOfSightTrigger extends Triggers
    native
    placeable;

var() int MaxViewAngle;  // how directly a player must be looking at SeenActor center (in degrees)
var() bool bEnabled;
var bool bTriggered;
var() float MaxViewDist;  // maximum distance player can be from this trigger to trigger it
var float OldTickTime;
var float RequiredViewDir;  // how directly player must be looking at SeenActor - 1.0 = straight on, 0.75 = barely on screen
var Actor SeenActor;
var() name SeenActorTag;  // tag of actor which triggers this trigger when seen

function PostBeginPlay()
{
	super(Actor).PostBeginPlay();
	RequiredViewDir = Cos(((float(MaxViewAngle) * 3.1415930) / float(180)));
	// End:0x5C
	if(((SeenActorTag != 'None') && (SeenActorTag != 'None')))
	{
		// End:0x5B
		foreach AllActors(Class'Engine.Actor', SeenActor, SeenActorTag)
		{
			// End:0x5B
			break;			
		}		
	}
	return;
}

event PlayerSeesMe(PlayerController P)
{
	TriggerEvent(Event, self, P.Pawn);
	bTriggered = true;
	return;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	bEnabled = true;
	return;
}

defaultproperties
{
	MaxViewAngle=15
	bEnabled=true
	MaxViewDist=3000.0000000
	bCollideActors=false
}
