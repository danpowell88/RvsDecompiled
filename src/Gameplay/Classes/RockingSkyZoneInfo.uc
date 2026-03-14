//=============================================================================
// RockingSkyZoneInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// RockingSkyZoneInfo.
//=============================================================================
class RockingSkyZoneInfo extends SkyZoneInfo
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

simulated function Tick(float DeltaTime)
{
	local Rotator newRot;

	super(Actor).Tick(DeltaTime);
	newRot.Pitch = int(__NFUN_174__(float(Rotation.Pitch), __NFUN_171__(float(1024), DeltaTime)));
	newRot.Roll = Rotation.Roll;
	newRot.Yaw = Rotation.Yaw;
	__NFUN_299__(newRot);
	return;
}

