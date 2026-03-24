/*=============================================================================
	R6AbstractWeapon.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractWeapon)

// --- AR6AbstractWeapon ---

static INT SavedWeaponOwner;    // DAT_1000d10c — Owner at net receive start
static INT SavedSelectedGadget; // DAT_1000d108 — m_WeaponGadgetClass at net receive start

IMPL_MATCH("R6Abstract.dll", 0x10003360)
void AR6AbstractWeapon::PreNetReceive()
{
	AActor::PreNetReceive();
	SavedWeaponOwner = (INT)Owner;                // this + 0x140
	SavedSelectedGadget = (INT)m_WeaponGadgetClass; // this + 0x500
}

IMPL_MATCH("R6Abstract.dll", 0x10003390)
void AR6AbstractWeapon::PostNetReceive()
{
	AActor::PostNetReceive();
	if (Owner != NULL)
	{
		if (Owner->GetPlayerPawn() && (INT)Owner != SavedWeaponOwner)
		{
			eventUpdateWeaponAttachment();
		}
	}
	if (SavedSelectedGadget != (INT)m_WeaponGadgetClass)
	{
		ProcessEvent(FindFunctionChecked(R6ABSTRACT_SpawnSelectedGadget), NULL);
	}
}

IMPL_MATCH("R6Abstract.dll", 0x10002250)
void AR6AbstractWeapon::eventSpawnSelectedGadget()
{
	ProcessEvent(FindFunctionChecked(R6ABSTRACT_SpawnSelectedGadget), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
