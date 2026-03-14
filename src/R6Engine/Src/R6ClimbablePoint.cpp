/*=============================================================================
	R6ClimbablePoint.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6ClimbablePoint)

// --- AR6ClimbablePoint ---

IMPL_MATCH("R6Engine.dll", 0x10016730)
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

IMPL_MATCH("R6Engine.dll", 0x10016650)
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

IMPL_MATCH("R6Engine.dll", 0x100167d0)
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

IMPL_MATCH("R6Engine.dll", 0x100165d0)
void AR6ClimbablePoint::addReachSpecs(APawn* Other, INT bOnlyChanged)
{
	guard(AR6ClimbablePoint::addReachSpecs);
	ANavigationPoint::addReachSpecs(Other, bOnlyChanged);
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
