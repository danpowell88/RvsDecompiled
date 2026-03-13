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
		// Set CollisionHeight: 32.0f for low climb (m_eClimbHeight == 1), 48.0f otherwise
		CollisionHeight = (m_eClimbHeight == 1) ? 32.0f : 48.0f;

		// Get the R6ClimbablePoint class default actor to read its CollisionHeight
		AActor* DefaultActor = AR6ClimbablePoint::StaticClass()->GetDefaultActor();

		// Spawn the outer climbable point elevated above this object
		FVector outerLoc(Location.X, Location.Y,
			Location.Z + CollisionHeight + DefaultActor->CollisionHeight);
		m_climbablePoint = (AR6ClimbablePoint*)XLevel->SpawnActor(
			AR6ClimbablePoint::StaticClass(), NAME_None, outerLoc, Rotation);

		if (m_climbablePoint)
		{
			m_climbablePoint->m_climbableObj = this;

			// Spawn the inner climbable point offset backwards along the flat rotation direction
			FRotator flatRot(0, Rotation.Yaw, Rotation.Roll);
			FVector dir = flatRot.Vector();
			FLOAT offset = -(CollisionRadius + 30.0f);
			FVector innerLoc = Location + dir * offset;

			m_insideClimbablePoint = (AR6ClimbablePoint*)XLevel->SpawnActor(
				AR6ClimbablePoint::StaticClass(), NAME_None, innerLoc, Rotation);

			if (m_insideClimbablePoint)
			{
				m_insideClimbablePoint->m_climbableObj = this;
				return;  // success path — function-level unguard runs at end
			}
		}

		// DIVERGENCE: retail error log args are in data sections; log a generic message
		GLog->Logf(TEXT("%s: failed to spawn climbable point markers"), GetName());
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
