/*=============================================================================
	R6Ladder.cpp
	AR6ClimbableObject, AR6ClimbablePoint, AR6LadderVolume — climbing system.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6ClimbableObject)
IMPLEMENT_CLASS(AR6ClimbablePoint)
IMPLEMENT_CLASS(AR6Ladder)
IMPLEMENT_CLASS(AR6LadderVolume)

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

// --- AR6ClimbablePoint ---

void AR6ClimbablePoint::ClearPaths()
{
	guard(AR6ClimbablePoint::ClearPaths);
	ANavigationPoint::ClearPaths();
	if (m_climbableObj)
	{
		if (this == m_climbableObj->m_insideClimbablePoint)
			m_climbableObj->m_insideClimbablePoint = NULL;
		else if (this == m_climbableObj->m_climbablePoint)
			m_climbableObj->m_climbablePoint = NULL;
	}
	m_climbableObj = NULL;
	unguard;
}

void AR6ClimbablePoint::InitForPathFinding()
{
	guard(AR6ClimbablePoint::InitForPathFinding);
	if (!m_climbableObj)
	{
		GWarn->Logf(TEXT("R6ClimbablePoint doesn't have R6ClimbableObject"));
		return;
	}
	if (this == m_climbableObj->m_insideClimbablePoint)
		m_connectedClimbablePoint = m_climbableObj->m_climbablePoint;
	else if (this == m_climbableObj->m_climbablePoint)
		m_connectedClimbablePoint = m_climbableObj->m_insideClimbablePoint;
	unguard;
}

INT AR6ClimbablePoint::ProscribedPathTo(ANavigationPoint* Nav)
{
	guard(AR6ClimbablePoint::ProscribedPathTo);
	if (Nav && Nav->IsA(AR6ClimbablePoint::StaticClass()))
	{
		if (m_climbableObj == ((AR6ClimbablePoint*)Nav)->m_climbableObj)
			return 1;
	}
	return ANavigationPoint::ProscribedPathTo(Nav);
	unguard;
}

void AR6ClimbablePoint::addReachSpecs(APawn* Other, INT bOnlyChanged)
{
	guard(AR6ClimbablePoint::addReachSpecs);
	ANavigationPoint::addReachSpecs(Other, bOnlyChanged);
	unguard;
}

// --- AR6LadderVolume ---

void AR6LadderVolume::AddMyMarker(AActor *)
{
}

INT AR6LadderVolume::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	guard(AR6LadderVolume::ShouldTrace);

	if (!(TraceFlags & 0x80000))
	{
		if (!AVolume::ShouldTrace(Other, TraceFlags))
			return 0;
	}

	return 1;

	unguard;
}

void AR6LadderVolume::eventSetPotentialClimber()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetPotentialClimber), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
