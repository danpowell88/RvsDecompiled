//=============================================================================
// R6BloodSplat - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6BloodSplat.uc 
// Created By       
// Date             
// Description      R6 base class for blood splat effects.
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/24    Jean-Francois Dube: Creation
//============================================================================//
class R6BloodSplat extends R6DecalsBase;

var Texture m_BloodSplatTexture;

simulated function PostBeginPlay()
{
	local Rotator DecalRot;

	// End:0x6C
	if(__NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer)))
	{
		DecalRot = Rotation;
		DecalRot.Roll = __NFUN_167__(65535);
		Level.m_DecalManager.__NFUN_2900__(Location, DecalRot, m_BloodSplatTexture, 2, 1, 0.0000000, 0.0000000, 300.0000000);
	}
	super.PostBeginPlay();
	return;
}

defaultproperties
{
	m_BloodSplatTexture=Texture'Inventory_t.BloodSplats.BloodSplat'
	bHidden=true
	bNetOptional=true
	LifeSpan=0.1000000
	Texture=none
}
