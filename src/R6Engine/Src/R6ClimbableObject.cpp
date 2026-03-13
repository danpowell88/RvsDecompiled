/*=============================================================================
	R6ClimbableObject.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6ClimbableObject)

// --- AR6ClimbableObject ---

void AR6ClimbableObject::AddMyMarker(AActor *)
{
}

void AR6ClimbableObject::CheckForErrors()
{
	guard(AR6ClimbableObject::CheckForErrors);
	if (!m_eClimbHeight)
		GWarn->Logf(TEXT("Collision: specify the height of m_eClimbHeight"));
	unguard;
}

void AR6ClimbableObject::PostScriptDestroyed()
{
	guard(AR6ClimbableObject::PostScriptDestroyed);
	SafeDestroyActor(m_climbablePoint);
	SafeDestroyActor(m_insideClimbablePoint);
	unguard;
}

INT AR6ClimbableObject::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	guard(AR6ClimbableObject::ShouldTrace);

	// If not tracing for level geometry, delegate to AActor base
	if (!(TraceFlags & TRACE_LevelGeometry))
	{
		if (!AActor::ShouldTrace(Other, TraceFlags))
			return 0;
	}

	return 1;

	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
