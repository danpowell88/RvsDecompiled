/*=============================================================================
	R6ClimbablePoint.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6ClimbablePoint)

// --- AR6ClimbablePoint ---

IMPL_INFERRED("Reconstructed path clearing with back-reference nulling on the owning climbable object")
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

IMPL_INFERRED("Reconstructed path finding init connecting climbable point pairs via their shared object")
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

IMPL_INFERRED("Reconstructed path preclusion: blocks same-object climbable point pairing")
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

IMPL_INFERRED("Reconstructed reach spec delegation to base navigation point")
void AR6ClimbablePoint::addReachSpecs(APawn* Other, INT bOnlyChanged)
{
	guard(AR6ClimbablePoint::addReachSpecs);
	ANavigationPoint::addReachSpecs(Other, bOnlyChanged);
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
