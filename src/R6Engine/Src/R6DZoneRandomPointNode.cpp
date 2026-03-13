/*=============================================================================
	R6DZoneRandomPointNode.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6DZoneRandomPointNode)

// --- AR6DZoneRandomPointNode ---

void AR6DZoneRandomPointNode::CheckForErrors()
{
	guard(AR6DZoneRandomPointNode::CheckForErrors);
	CopyR6Availability(m_pZone);
	PutOnGround();
	if (!Base)
		GWarn->Logf(TEXT("Random point not on valid base."));
	unguard;
}

void AR6DZoneRandomPointNode::PostScriptDestroyed()
{
	guard(AR6DZoneRandomPointNode::PostScriptDestroyed);
	if (m_pZone)
		m_pZone->DeleteANode(this);
	unguard;
}

void AR6DZoneRandomPointNode::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
