/*=============================================================================
	R6ClimbableObject.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6ClimbableObject)

// --- AR6ClimbableObject ---

// DIVERGENCE from retail (0x10016310, 640b):
//   Retail calls StaticFindObjectChecked(UObject::StaticClass(), ANY_PACKAGE, "R6ClimbablePoint", false)
//   to resolve the AR6ClimbablePoint class at runtime; we use AR6ClimbablePoint::StaticClass() directly
//   (functionally identical result).
//   Retail IsA check is IsA(UObject::StaticClass()) which is trivially always true; we omit it.
//   GLog failure-path format string is an unresolved data-section literal.
IMPL_DIVERGE("GLog failure format string is a retail data-section literal with no Ghidra symbol; format permanently unknown")
void AR6ClimbableObject::AddMyMarker(AActor * param_1)
{
	guard(AR6ClimbableObject::AddMyMarker);

	// Ghidra: retail checks IsA(UObject::StaticClass()) which is always true for any non-null object.
	if (param_1 != NULL)
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

			// Ghidra: inner point is offset along world +X axis (FRotator(0,0,0).Vector() = (1,0,0)),
			// NOT along the actor's yaw direction.  Rotation for inner point has Pitch zeroed out.
			FVector innerLoc = Location + FVector(-(CollisionRadius + 30.0f), 0.0f, 0.0f);
			FRotator innerRot(0, Rotation.Yaw, Rotation.Roll);

			m_insideClimbablePoint = (AR6ClimbablePoint*)XLevel->SpawnActor(
				AR6ClimbablePoint::StaticClass(), NAME_None, innerLoc, innerRot);

			if (m_insideClimbablePoint)
			{
				m_insideClimbablePoint->m_climbableObj = this;
				return;  // success path — function-level unguard runs at end
			}
		}

		// Retail format string is an unresolved data-section literal; log a close approximation.
		GLog->Logf(TEXT("%s: failed to spawn climbable point markers"), GetName());
	}

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x100162e0)
void AR6ClimbableObject::CheckForErrors()
{
	guard(AR6ClimbableObject::CheckForErrors);
	if (!m_eClimbHeight)
		GWarn->Logf(TEXT("Collision: specify the height of m_eClimbHeight"));
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10016250)
void AR6ClimbableObject::PostScriptDestroyed()
{
	guard(AR6ClimbableObject::PostScriptDestroyed);
	SafeDestroyActor(m_climbablePoint);
	SafeDestroyActor(m_insideClimbablePoint);
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x100161b0)
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
