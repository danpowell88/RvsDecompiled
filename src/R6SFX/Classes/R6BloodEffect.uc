//=============================================================================
// R6BloodEffect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            r6BloodEffect 
// Created By       Joel Tremblay
// Date             2001/05/08
// Description      Effects spawned when a bullet hit a Human Flesh
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6BloodEffect extends R6SFXWallHit;

defaultproperties
{
	m_bGoreLevelHigh=true
	m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Rainbow'
	m_pSparksIn=Class'R6SFX.R6BloodImpact'
}
