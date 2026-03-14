/*=============================================================================
	R6StairOrientation.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6StairOrientation)

// --- AR6StairOrientation ---

IMPL_APPROX("Safely destroys associated stair volume actor on script cleanup")
void AR6StairOrientation::PostScriptDestroyed()
{
	guard(AR6StairOrientation::PostScriptDestroyed);
	SafeDestroyActor(m_pStairVolume);
	unguard;
}

IMPL_APPROX("Associates this orientation marker with its parent stair volume")
void AR6StairOrientation::linkWithStair(AR6StairVolume* StairVolume)
{
	m_pStairVolume = StairVolume;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
