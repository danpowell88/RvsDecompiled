/*=============================================================================
	R6AbstractWeapon.cpp
	AR6AbstractWeapon, AR6AbstractFirstPersonWeapon, AR6AbstractGadget,
	AR6AbstractBullet — abstract weapon hierarchy base classes.
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractBullet)
IMPLEMENT_CLASS(AR6AbstractFirstPersonWeapon)
IMPLEMENT_CLASS(AR6AbstractGadget)
IMPLEMENT_CLASS(AR6AbstractWeapon)

/*-----------------------------------------------------------------------------
	AR6AbstractGadget
-----------------------------------------------------------------------------*/

INT* AR6AbstractGadget::GetOptimizedRepList(BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel)
{
	return Super::GetOptimizedRepList(Recent, Retire, Ptr, Map, Channel);
}

/*-----------------------------------------------------------------------------
	AR6AbstractWeapon
-----------------------------------------------------------------------------*/

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
