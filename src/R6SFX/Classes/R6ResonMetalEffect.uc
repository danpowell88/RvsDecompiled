//=============================================================================
// R6ResonMetalEffect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6MetalEffect02 
// Created By       Joel Tremblay
// Date             2001/05/08
// Description      Effects spawned when a bullet hit a metal wall
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6ResonMetalEffect extends R6SFXWallHit;

defaultproperties
{
	m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_ResonMetal'
	m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_ResonMetal'
	m_pSparksIn=Class'R6SFX.R6MetalImpact'
	m_DecalTexture=/* Array type was not detected. */
}
