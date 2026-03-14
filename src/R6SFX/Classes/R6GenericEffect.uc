//=============================================================================
// R6GenericEffect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6GenericEffect 
// Created By       Carl Lavoie
// Date             05/05/2002
// Description      Effects spawned when a bullet hit a generic stuff
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6GenericEffect extends R6SFXWallHit;

defaultproperties
{
	m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Concrete'
	m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_Concrete'
	m_pSparksIn=Class'R6SFX.R6GenericImpact'
	m_DecalTexture=/* Array type was not detected. */
}
