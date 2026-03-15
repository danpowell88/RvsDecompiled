//=============================================================================
// R6HardWoodEffect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
// Class            R6HardWoodEffect 
// Description      Effects spawned when a bullet hit a Wood wall
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6HardWoodEffect extends R6SFXWallHit;

defaultproperties
{
	m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_HardWood'
	m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_HardWood'
	m_pSparksIn=Class'R6SFX.R6WoodImpact'
	m_DecalTexture=/* Array type was not detected. */
	CullDistance=1000.0000000
}
