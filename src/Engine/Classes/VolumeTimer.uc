//=============================================================================
// VolumeTimer - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class VolumeTimer extends Info
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var PhysicsVolume V;

function PostBeginPlay()
{
	super(Actor).PostBeginPlay();
	SetTimer(1.0000000, true);
	V = PhysicsVolume(Owner);
	return;
}

function Timer()
{
	V.TimerPop(self);
	return;
}

defaultproperties
{
	RemoteRole=0
}
