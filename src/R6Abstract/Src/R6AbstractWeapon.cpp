/*=============================================================================
	R6AbstractWeapon.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractWeapon)

// --- AR6AbstractWeapon ---

IMPL_APPROX("Ravenshield-specific; reconstructed from context")
void AR6AbstractWeapon::PreNetReceive()
{
	Super::PreNetReceive();
}

IMPL_APPROX("Ravenshield-specific; reconstructed from context")
void AR6AbstractWeapon::PostNetReceive()
{
	Super::PostNetReceive();
}

IMPL_APPROX("Ravenshield-specific; reconstructed from context")
void AR6AbstractWeapon::eventSpawnSelectedGadget()
{
	ProcessEvent(FindFunctionChecked(R6ABSTRACT_SpawnSelectedGadget), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
