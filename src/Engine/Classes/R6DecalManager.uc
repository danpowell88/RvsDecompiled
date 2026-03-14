//=============================================================================
// R6DecalManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
    native
    notplaceable;

enum eDecalType
{
	DECAL_Footstep,                 // 0
	DECAL_Bullet,                   // 1
	DECAL_BloodSplats,              // 2
	DECAL_BloodBaths,               // 3
	DECAL_GrenadeDecals             // 4
};

var() bool m_bActive;
var() R6DecalGroup m_FootSteps;
var() R6DecalGroup m_WallHit;
var() R6DecalGroup m_BloodSplats;
var() R6DecalGroup m_BloodBaths;
var() R6DecalGroup m_GrenadeDecals;

// Export UR6DecalManager::execAddDecal(FFrame&, void* const)
native(2900) final function AddDecal(Vector Position, Rotator Rotation, Texture decalTexture, R6DecalManager.eDecalType type, int iFov, float fDuration, float fStartTime, float fMaxTraceDistance, optional float CullDistance);

// Export UR6DecalManager::execKillDecal(FFrame&, void* const)
native(2901) final function KillDecal();

simulated event Destroyed()
{
	// End:0x1E
	if(__NFUN_119__(m_FootSteps, none))
	{
		m_FootSteps.__NFUN_279__();
		m_FootSteps = none;
	}
	// End:0x3C
	if(__NFUN_119__(m_WallHit, none))
	{
		m_WallHit.__NFUN_279__();
		m_WallHit = none;
	}
	// End:0x5A
	if(__NFUN_119__(m_BloodSplats, none))
	{
		m_BloodSplats.__NFUN_279__();
		m_BloodSplats = none;
	}
	// End:0x78
	if(__NFUN_119__(m_BloodBaths, none))
	{
		m_BloodBaths.__NFUN_279__();
		m_BloodBaths = none;
	}
	// End:0x96
	if(__NFUN_119__(m_GrenadeDecals, none))
	{
		m_GrenadeDecals.__NFUN_279__();
		m_GrenadeDecals = none;
	}
	super.Destroyed();
	return;
}

defaultproperties
{
	m_bActive=true
	bHidden=true
}
