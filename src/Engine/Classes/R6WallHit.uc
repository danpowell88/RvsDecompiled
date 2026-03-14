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
    native
    abstract;

// --- Enums ---
enum EHitType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
// if you want to Play Sound for the WallHit (espacially use for the shotgun).
var /* replicated */ bool m_bPlayEffectSound;
var EHitType m_eHitType;
// ^ NEW IN 1.60
var bool bProjectOnlyFirst;
// ^ NEW IN 1.60
var bool m_bGoreLevelHigh;
var ESoundType m_eSoundType;
var array<array> m_DecalTexture;
var class<R6SFX> m_pSparksIn;
var Sound m_RicochetSound;
var Sound m_ExitSound;
var Sound m_ImpactSound;
var bool m_bDoubleFace;
// ^ NEW IN 1.60

// --- Functions ---
simulated function FirstPassReset() {}

defaultproperties
{
}
