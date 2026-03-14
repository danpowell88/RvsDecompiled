//============================================================================//
// Class            R6DecalManager.uc 
// Created By       Cyrille Lauzon
// Date             2001/01/18
// Description      Manages multiple lists of Decals
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6DecalManager extends Actor
    native;

// --- Enums ---
enum eDecalType
{
	DECAL_Footstep,
	DECAL_Bullet,
    DECAL_BloodSplats,
    DECAL_BloodBaths,
    DECAL_GrenadeDecals
};

// --- Variables ---
var R6DecalGroup m_GrenadeDecals;
var R6DecalGroup m_BloodBaths;
var R6DecalGroup m_BloodSplats;
var R6DecalGroup m_WallHit;
var R6DecalGroup m_FootSteps;
var bool m_bActive;

// --- Functions ---
final native function AddDecal(Vector Position, Rotator Rotation, Texture decalTexture, eDecalType type, int iFov, float fDuration, float fStartTime, float fMaxTraceDistance, optional float CullDistance) {}
// ^ NEW IN 1.60
simulated event Destroyed() {}
final native function KillDecal() {}
// ^ NEW IN 1.60

defaultproperties
{
}
