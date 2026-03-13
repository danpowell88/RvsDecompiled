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

void AR6DZoneRandomPointNode::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6DZoneRandomPointNode::RenderEditorInfo);

	if (m_pZone != NULL)
	{
		// Propagate selection state: if the parent zone is selected and bSelectNodeInEditor is set,
		// mark this node as selected too (Flags |= 0x4000).
		if ((*(DWORD*)((BYTE*)m_pZone + 0xAC) & 0x4000) &&
		    (*(BYTE*)((BYTE*)m_pZone + 0x49C) & 1))
		{
			*(DWORD*)((BYTE*)this + 0xAC) |= 0x4000;
		}

		// Ghidra: draws a bounding box (green=unselected, yellow=selected) when this or any
		// sibling node in the zone is selected. FLineBatcher drawing is a stub in this project.
	}

	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
