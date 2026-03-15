//=============================================================================
// R6MarbleEffect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
// Class            R6MarbleEffect 
// Created By       Joel Tremblay
// Date             2001/05/08
// Description      Effects spawned when a bullet hit a marble wall
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6MarbleEffect extends R6SFXWallHit;

defaultproperties
{
	m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Concrete'
	m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_Concrete'
	m_pSparksIn=Class'R6SFX.R6MarbleImpact'
	m_DecalTexture=/* Array type was not detected. */
}
