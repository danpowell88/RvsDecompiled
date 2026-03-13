/*=============================================================================
	R6DemolitionsGadget.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6DemolitionsGadget)

// --- AR6DemolitionsGadget ---

void AR6DemolitionsGadget::PreNetReceive()
{
	Super::PreNetReceive();
}

void AR6DemolitionsGadget::PostNetReceive()
{
	Super::PostNetReceive();
}

void AR6DemolitionsGadget::eventNbBulletChange()
{
	ProcessEvent(FindFunctionChecked(R6WEAPONS_NbBulletChange), NULL);
}

void AR6DemolitionsGadget::eventSetGadgetStaticMesh()
{
	ProcessEvent(FindFunctionChecked(R6WEAPONS_SetGadgetStaticMesh), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
