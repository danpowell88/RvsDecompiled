/*=============================================================================
	R6SubActionLookAt.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(UR6SubActionLookAt)

// --- UR6SubActionLookAt ---

IMPL_MATCH("R6Engine.dll", 0x10040bb0)
FString UR6SubActionLookAt::GetStatString()
{
	FString Result = UMatSubAction::GetStatString();
	Result += TEXT("LookAt\n");
	return Result;
}

IMPL_MATCH("R6Engine.dll", 0x10040b60)
INT UR6SubActionLookAt::Update(FLOAT DeltaTime, ASceneManager* SceneManager)
{
	if (!UMatSubAction::Update(DeltaTime, SceneManager))
		return 0;
	if (IsRunning() && m_AffectedPawn)
	{
		m_AffectedPawn->PawnTrackActor(m_TargetActor, m_bAim);
	}
	return 1;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
