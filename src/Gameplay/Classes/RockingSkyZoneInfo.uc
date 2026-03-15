//=============================================================================
// RockingSkyZoneInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// RockingSkyZoneInfo.
//=============================================================================
class RockingSkyZoneInfo extends SkyZoneInfo
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

simulated function Tick(float DeltaTime)
{
	local Rotator newRot;

	super(Actor).Tick(DeltaTime);
	newRot.Pitch = int((float(Rotation.Pitch) + (float(1024) * DeltaTime)));
	newRot.Roll = Rotation.Roll;
	newRot.Yaw = Rotation.Yaw;
	SetRotation(newRot);
	return;
}

