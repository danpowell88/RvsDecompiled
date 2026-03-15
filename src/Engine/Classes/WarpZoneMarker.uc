//=============================================================================
// WarpZoneMarker - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// WarpZoneMarker.
//=============================================================================
class WarpZoneMarker extends SmallNavigationPoint
    native
    notplaceable
    hidecategories(Lighting,LightColor,Karma,Force);

var WarpZoneInfo markedWarpZone;
// AI related
var Actor TriggerActor;  // used to tell AI how to trigger me
var Actor TriggerActor2;

function PostBeginPlay()
{
	// End:0x1A
	if((markedWarpZone.numDestinations > 1))
	{
		FindTriggerActor();
	}
	super(Actor).PostBeginPlay();
	return;
}

function FindTriggerActor()
{
	local ZoneTrigger Z;

	// End:0x40
	foreach AllActors(Class'Engine.ZoneTrigger', Z)
	{
		// End:0x3F
		if((Z.Event == markedWarpZone.ZoneTag))
		{
			TriggerActor = Z;			
			return;
		}		
	}	
	return;
}

function Actor SpecialHandling(Pawn Other)
{
	// End:0x31
	if((Other.Region.Zone == markedWarpZone))
	{
		markedWarpZone.ActorEntered(Other);
	}
	return self;
	return;
}

defaultproperties
{
	bCollideWhenPlacing=false
	bHiddenEd=true
}
