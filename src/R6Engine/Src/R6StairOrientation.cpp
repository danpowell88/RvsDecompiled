/*=============================================================================
	R6StairOrientation.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6StairOrientation)

// --- AR6StairOrientation ---

IMPL_MATCH("R6Engine.dll", 0x1003b000)
void AR6StairOrientation::PostScriptDestroyed()
{
	guard(AR6StairOrientation::PostScriptDestroyed);
	SafeDestroyActor(m_pStairVolume);
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1003aff0)
void AR6StairOrientation::linkWithStair(AR6StairVolume* StairVolume)
{
	m_pStairVolume = StairVolume;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
