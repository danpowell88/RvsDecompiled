/*=============================================================================
	R6AbstractWeapon.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractWeapon)

// --- AR6AbstractWeapon ---

void AR6AbstractWeapon::PreNetReceive()
{
	Super::PreNetReceive();
}

void AR6AbstractWeapon::PostNetReceive()
{
	Super::PostNetReceive();
}

void AR6AbstractWeapon::eventSpawnSelectedGadget()
{
	ProcessEvent(FindFunctionChecked(R6ABSTRACT_SpawnSelectedGadget), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
