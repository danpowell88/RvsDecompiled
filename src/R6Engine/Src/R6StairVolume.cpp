/*=============================================================================
	R6StairVolume.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6StairVolume)

// --- AR6StairVolume ---

void AR6StairVolume::AddMyMarker(AActor *)
{
}

void AR6StairVolume::CheckForErrors()
{
}

void AR6StairVolume::PostScriptDestroyed()
{
	guard(AR6StairVolume::PostScriptDestroyed);
	SafeDestroyActor(m_pStairOrientation);
	unguard;
}

void AR6StairVolume::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6StairVolume::RenderEditorInfo);
	AActor::RenderEditorInfo(SceneNode, RI, DA);
	// Propagate bDirectional editor flag to associated stair orientation actor
	if ((*(DWORD*)((BYTE*)this + 0xAC) & 0x4000) && m_pStairOrientation)
		*(DWORD*)((BYTE*)m_pStairOrientation + 0xAC) |= 0x4000;
	unguard;
}

void AR6StairVolume::Spawned()
{
	guard(AR6StairVolume::Spawned);
	m_pStairOrientation = (AR6StairOrientation*)XLevel->SpawnActor(AR6StairOrientation::StaticClass());
	m_pStairOrientation->m_pStairVolume = this;
	m_pStairOrientation->bDirectional = 1;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
