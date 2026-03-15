//=============================================================================
// R6HardMetalEffect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
// Class            R6HardMetalEffect 
// Description      Effects spawned when a bullet hit a metal wall
//----------------------------------------------------------------------------//
//============================================================================//
class R6HardMetalEffect extends R6SFXWallHit;

defaultproperties
{
	m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_HardMetal'
	m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_HardMetal'
	m_pSparksIn=Class'R6SFX.R6MetalImpact'
	m_DecalTexture=/* Array type was not detected. */
	CullDistance=1000.0000000
}
