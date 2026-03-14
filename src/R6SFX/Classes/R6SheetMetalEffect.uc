//=============================================================================
// R6SheetMetalEffect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6SheetMetalEffect 
// Description      Effects spawned when a bullet hit a metal wall
//----------------------------------------------------------------------------//
//============================================================================//
class R6SheetMetalEffect extends R6SFXWallHit;

defaultproperties
{
	m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_SheetMetal'
	m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_ResonMetal'
	m_pSparksIn=Class'R6SFX.R6SheetMetalImpact'
	m_DecalTexture=/* Array type was not detected. */
	CullDistance=1000.0000000
}
