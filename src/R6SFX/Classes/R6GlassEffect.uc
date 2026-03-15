//=============================================================================
// R6GlassEffect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
// Class            R6GlassEffect 
// Description      Effects spawned when a bullet hit a Glass surface
//----------------------------------------------------------------------------//
//============================================================================//
class R6GlassEffect extends R6SFXWallHit;

defaultproperties
{
	bProjectOnlyFirst=true
	m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Glass'
	m_RicochetSound=Sound'Bullet_Impacts.Play_Impact_Glass'
	m_pSparksIn=Class'R6SFX.R6GlassImpact'
	m_DecalTexture=/* Array type was not detected. */
	CullDistance=2000.0000000
}
