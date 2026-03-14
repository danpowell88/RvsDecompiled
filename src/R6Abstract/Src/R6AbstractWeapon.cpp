/*=============================================================================
	R6AbstractWeapon.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractWeapon)

// --- AR6AbstractWeapon ---

IMPL_MATCH("R6Abstract.dll", 0x10003360)
void AR6AbstractWeapon::PreNetReceive()
{
	Super::PreNetReceive();
}

IMPL_MATCH("R6Abstract.dll", 0x10003390)
void AR6AbstractWeapon::PostNetReceive()
{
	Super::PostNetReceive();
}

IMPL_MATCH("R6Abstract.dll", 0x10002250)
void AR6AbstractWeapon::eventSpawnSelectedGadget()
{
	ProcessEvent(FindFunctionChecked(R6ABSTRACT_SpawnSelectedGadget), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
