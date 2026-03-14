/*=============================================================================
	R6CoverSpot.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6CoverSpot)

// --- AR6CoverSpot ---

IMPL_EMPTY("FLineBatcher drawing stub; Ghidra confirms drawing-only body")
void AR6CoverSpot::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6CoverSpot::RenderEditorInfo);
	// Ghidra: draws an arrow cylinder at Location when selected (Flags & 0x4000).
	// FLineBatcher drawing is a stub in this project.
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
