/*=============================================================================
	R6SubActionLookAt.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(UR6SubActionLookAt)

// --- UR6SubActionLookAt ---

IMPL_INFERRED("Appends LookAt label to base stat string for scene manager debugging")
FString UR6SubActionLookAt::GetStatString()
{
	FString Result = UMatSubAction::GetStatString();
	Result += TEXT("LookAt\n");
	return Result;
}

IMPL_INFERRED("Delegates to base Update; if running and pawn assigned, calls PawnTrackActor for look-at targeting")
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
