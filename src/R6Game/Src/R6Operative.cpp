/*=============================================================================
	R6Operative.cpp
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(UR6Operative)

// --- UR6Operative ---

IMPL_MATCH("R6Game.dll", 0x10007e00)
void UR6Operative::TransferFile(FArchive& Ar)
{
	// Skill stats (floats at 0x68-0x84)
	Ar.ByteOrderSerialize(&m_fAssault,       sizeof(m_fAssault));
	Ar.ByteOrderSerialize(&m_fDemolitions,   sizeof(m_fDemolitions));
	Ar.ByteOrderSerialize(&m_fElectronics,   sizeof(m_fElectronics));
	Ar.ByteOrderSerialize(&m_fSniper,        sizeof(m_fSniper));
	Ar.ByteOrderSerialize(&m_fStealth,       sizeof(m_fStealth));
	Ar.ByteOrderSerialize(&m_fSelfControl,   sizeof(m_fSelfControl));
	Ar.ByteOrderSerialize(&m_fLeadership,    sizeof(m_fLeadership));
	Ar.ByteOrderSerialize(&m_fObservation,   sizeof(m_fObservation));

	// Combat statistics (ints at 0x54-0x64)
	Ar.ByteOrderSerialize(&m_iHealth,          sizeof(m_iHealth));
	Ar.ByteOrderSerialize(&m_iNbMissionPlayed, sizeof(m_iNbMissionPlayed));
	Ar.ByteOrderSerialize(&m_iTerrokilled,     sizeof(m_iTerrokilled));
	Ar.ByteOrderSerialize(&m_iRoundsfired,     sizeof(m_iRoundsfired));
	Ar.ByteOrderSerialize(&m_iRoundsOntarget,  sizeof(m_iRoundsOntarget));

	// Identity
	Ar.ByteOrderSerialize(&m_iRookieID, sizeof(m_iRookieID));

	// Loadout strings
	Ar << m_szPrimaryWeapon;
	Ar << m_szPrimaryWeaponGadget;
	Ar << m_szPrimaryWeaponBullet;
	Ar << m_szPrimaryGadget;
	Ar << m_szSecondaryWeapon;
	Ar << m_szSecondaryWeaponGadget;
	Ar << m_szSecondaryWeaponBullet;
	Ar << m_szSecondaryGadget;
	Ar << m_szArmor;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
