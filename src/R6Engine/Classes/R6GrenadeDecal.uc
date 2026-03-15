//=============================================================================
// R6GrenadeDecal - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6GrenadeDecal.uc 
// Created By       
// Date             
// Description      R6 base class for grenade splatch effects.
//----------------------------------------------------------------------------//
// Revision history:
// 2002/05/11       Jean-Francois Dube: Creation
//============================================================================//
class R6GrenadeDecal extends R6DecalsBase;

var Texture m_GrenadeDecalTexture;

simulated function PostBeginPlay()
{
	local Rotator DecalRot;

	// End:0x7D
	if((int(Level.NetMode) != int(NM_DedicatedServer)))
	{
		DecalRot.Pitch = 49152;
		DecalRot.Yaw = 0;
		DecalRot.Roll = Rand(65535);
		Level.m_DecalManager.AddDecal(Location, DecalRot, m_GrenadeDecalTexture, 4, 1, 0.0000000, 0.0000000, 50.0000000);
	}
	super.PostBeginPlay();
	return;
}

defaultproperties
{
	m_GrenadeDecalTexture=Texture'R6SFX_T.Grenade.GrenadeImpact'
	bHidden=true
	bNetOptional=true
	bNetInitialRotation=false
	LifeSpan=0.1000000
	Texture=none
}
