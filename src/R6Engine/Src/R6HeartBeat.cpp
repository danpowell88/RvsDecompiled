/*=============================================================================
	R6HeartBeat.cpp — AR6FalseHeartBeat
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6FalseHeartBeat)

// --- AR6FalseHeartBeat ---

INT AR6FalseHeartBeat::IsBlockedBy(AActor const* Other) const
{
	guard(AR6FalseHeartBeat::IsBlockedBy);

	// Don't block actors owned by the heartbeat puck's owner
	if (Other && Other->Owner == m_HeartBeatPuckOwner)
		return 0;

	ALevelInfo* LevelInfo = XLevel->GetLevelInfo();
	if (Other == LevelInfo)
	{
		// If level info doesn't block actors, defer to base
		if (!Other->bBlockActors)
			return AActor::IsBlockedBy(Other);
	}
	else
	{
		// Non-level actors: not blocked unless bBlockActors
		if (!Other->bBlockActors)
			return 0;
	}

	return 1;

	unguard;
}

INT AR6FalseHeartBeat::IsRelevantToPawn(APawn* Other)
{
	guard(AR6FalseHeartBeat::IsRelevantToPawn);
	if (!m_bBroken && Other->EngineWeapon)
	{
		if (Other->EngineWeapon->eventIsGoggles())
		{
			FVector Diff = Location - Other->Location;
			FLOAT DistSq = Diff.X * Diff.X + Diff.Y * Diff.Y + Diff.Z * Diff.Z;
			if (DistSq < 2250000.0f)
				return 1;
		}
	}
	return 0;
	unguard;
}

INT AR6FalseHeartBeat::IsRelevantToPawnHeartBeat(APawn *)
{
	return 0;
}

INT AR6FalseHeartBeat::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	guard(AR6FalseHeartBeat::ShouldTrace);

	// Don't trace against actors owned by the heartbeat puck's owner
	if (Other && Other->Owner == m_HeartBeatPuckOwner)
		return 0;

	return AR6InteractiveObject::ShouldTrace(Other, TraceFlags);

	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
