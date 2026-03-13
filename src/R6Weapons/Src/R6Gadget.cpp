/*=============================================================================
	R6Gadget.cpp: Gadget classes — demolitions, heartbeat sensor, smoke, reticule.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6Gadget)
IMPLEMENT_CLASS(AR6DemolitionsGadget)
IMPLEMENT_CLASS(AR6HBSGadget)
IMPLEMENT_CLASS(AR6Reticule)
IMPLEMENT_CLASS(AR6SmokeCloud)

IMPLEMENT_FUNCTION(AR6HBSGadget, -1, execToggleHeartBeatProperties)

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

// --- AR6SmokeCloud ---

INT AR6SmokeCloud::IsBlockedBy(AActor const* Other) const
{
	return 0;
}

INT AR6SmokeCloud::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	return 0;
}

// --- AR6HBSGadget ---

INT AR6HBSGadget::GetHeartBeatStatus()
{
	return m_bHeartBeatOn ? 1 : 0;
}

void AR6HBSGadget::execToggleHeartBeatProperties(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- AR6Reticule ---

void AR6Reticule::UpdateReticule(AR6PlayerController* PC, FLOAT DeltaTime)
{
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
