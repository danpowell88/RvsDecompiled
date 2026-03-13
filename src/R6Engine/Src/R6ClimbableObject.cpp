/*=============================================================================
	R6ClimbableObject.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6ClimbableObject)

// --- AR6ClimbableObject ---

void AR6ClimbableObject::AddMyMarker(AActor * param_1)
{
	guard(AR6ClimbableObject::AddMyMarker);

	if (param_1 != NULL && param_1->IsA(AR6ClimbableObject::StaticClass()))
	{
		// Set collision height based on climb height type
		if (((BYTE*)this)[0x394] == 0x1)
			*(FLOAT*)((BYTE*)this + 0xfc) = 32.0f;   // 0x42000000
		else
			*(FLOAT*)((BYTE*)this + 0xfc) = 48.0f;   // 0x42400000

		// TODO: Full implementation spawns two R6ClimbablePoint actors:
		// 1. m_climbablePoint above the object at Location + (0,0,CollisionHeight+DefaultCH)
		// 2. m_insideClimbablePoint offset backwards along flat rotation direction
		// Uses SpawnActor via vtable dispatch at (*(code**)(*(int*)(this+0x328)+0xa8))().
		// Both spawned points have m_climbableObj set to this.
	}

	unguard;
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
