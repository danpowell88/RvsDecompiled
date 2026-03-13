/*=============================================================================
	R6StairOrientation.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6StairOrientation)

// --- AR6StairOrientation ---

void AR6StairOrientation::PostScriptDestroyed()
{
	guard(AR6StairOrientation::PostScriptDestroyed);
	SafeDestroyActor(m_pStairVolume);
	unguard;
}

void AR6StairOrientation::linkWithStair(AR6StairVolume* StairVolume)
{
	m_pStairVolume = StairVolume;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
