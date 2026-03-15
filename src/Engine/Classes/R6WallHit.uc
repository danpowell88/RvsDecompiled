//=============================================================================
// R6WallHit - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
// Class            R6WallHit.uc 
// Created By       
// Date             
// Description      R6 base class for Wall effects. Includes: Decals, sparks
//    	 		    and smoke.
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/07	    Cyrille Lauzon: Added the new R6Decals, out effects are not
//									taken in account.
//============================================================================//
class R6WallHit extends R6DecalsBase
    abstract
    native
    notplaceable;

enum EHitType
{
	HIT_Impact,                     // 0
	HIT_Ricochet,                   // 1
	HIT_Exit                        // 2
};

var(Rainbow) Actor.ESoundType m_eSoundType;
// NEW IN 1.60
var R6WallHit.EHitType m_eHitType;
// NEW IN 1.60
var bool m_bDoubleFace;
var(Rainbow) bool m_bGoreLevelHigh;
// NEW IN 1.60
var() bool bProjectOnlyFirst;
var bool m_bPlayEffectSound;  // if you want to Play Sound for the WallHit (espacially use for the shotgun).
var(Rainbow) Sound m_ImpactSound;
var(Rainbow) Sound m_ExitSound;
var(Rainbow) Sound m_RicochetSound;
var(Rainbow) Class<R6SFX> m_pSparksIn;
var(Rainbow) array<Texture> m_DecalTexture;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bPlayEffectSound;
}

simulated function FirstPassReset()
{
	Destroy();
	return;
}

defaultproperties
{
	m_eSoundType=2
	m_bPlayEffectSound=true
	bHidden=true
	bNetOptional=true
	m_bDeleteOnReset=true
	LifeSpan=5.0000000
	CullDistance=1700.0000000
	Texture=none
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var EHitType
