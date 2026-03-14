/*=============================================================================
	R6DZonePathNode.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6DZonePathNode)

// --- AR6DZonePathNode ---

IMPL_INFERRED("Reconstructed orphan-check: validates node belongs to its path and puts on ground")
void AR6DZonePathNode::CheckForErrors()
{
	guard(AR6DZonePathNode::CheckForErrors);
	if (m_pPath)
	{
		for (INT i = 0; i < m_pPath->m_aNode.Num(); i++)
		{
			if (m_pPath->m_aNode(i) == this)
			{
				CopyR6Availability(m_pPath);
				goto Done;
			}
		}
	}
	GWarn->Logf(TEXT("%s is not part of a path."), GetName());
Done:
	PutOnGround();
	if (!Base)
		GWarn->Logf(TEXT("Path node not on valid base."));
	unguard;
}

IMPL_INFERRED("Reconstructed node self-removal from parent path on destruction")
void AR6DZonePathNode::PostScriptDestroyed()
{
	guard(AR6DZonePathNode::PostScriptDestroyed);
	if (m_pPath)
		m_pPath->DeleteANode(this);
	unguard;
}

IMPL_INFERRED("Reconstructed editor rendering delegation to parent path")
void AR6DZonePathNode::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6DZonePathNode::RenderEditorInfo);
	if (m_pPath)
		m_pPath->RenderEditorInfo(SceneNode, RI, DA);
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
