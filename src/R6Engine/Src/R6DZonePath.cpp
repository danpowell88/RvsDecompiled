/*=============================================================================
	R6DZonePath.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6DZonePath)

// --- AR6DZonePath ---

void AR6DZonePath::CheckForErrors()
{
	guard(AR6DZonePath::CheckForErrors);
	if (m_aNode.Num() == 0)
		GWarn->Logf(TEXT("%s don't have any node!"), GetName());
	AR6DeploymentZone::CheckForErrors(true);
	unguard;
}

void AR6DZonePath::DeleteANode(AR6DZonePathNode *Node)
{
	guard(AR6DZonePath::DeleteANode);
	for (INT i = 0; i < m_aNode.Num(); i++)
	{
		if (m_aNode(i) == Node)
		{
			DeleteANode(i);
			return;
		}
	}
	unguard;
}

void AR6DZonePath::DeleteANode(INT iIndex)
{
	guard(AR6DZonePath::DeleteANode);
	check(iIndex < m_aNode.Num());
	AActor* Node = m_aNode(iIndex);
	m_aNode.Remove(iIndex);
	if (!Node->bDeleteMe)
		XLevel->DestroyActor(Node, 0);
	unguard;
}

FVector AR6DZonePath::FindClosestPointTo(FVector const &)
{
	return FVector(0,0,0);
}

FVector AR6DZonePath::FindRandomPointInArea()
{
	guard(AR6DZonePath::FindRandomPointInArea);
	if (m_aNode.Num() == 0)
	{
		GLog->Logf(TEXT("%s has no nodes"), GetName());
		return FVector(0,0,0);
	}
	INT Index = appRand() % m_aNode.Num();
	AR6DZonePathNode* Node = m_aNode(Index);
	FRotator RandRot(0, (appRand() % 0x7FFF) << 1, 0);
	FLOAT Dist = appFrand() * Node->m_fRadius;
	FVector Dir = RandRot.Vector();
	return Node->Location + Dist * Dir;
	unguard;
}

FVector AR6DZonePath::FindSpawningPoint(FRotator * pRotation, INT *, enum EStance *, INT *)
{
	guard(AR6DZonePath::FindSpawningPoint);
	if (m_aNode.Num() == 0)
	{
		GLog->Logf(TEXT("%s has no nodes"), GetName());
		return FVector(0,0,0);
	}
	INT Index = appRand() % m_aNode.Num();
	AR6DZonePathNode* Node = m_aNode(Index);
	*pRotation = Node->Rotation;
	FRotator RandRot(0, (appRand() % 0x7FFF) << 1, 0);
	FLOAT Dist = appFrand() * Node->m_fRadius;
	FVector Dir = RandRot.Vector();
	return Node->Location + Dist * Dir;
	unguard;
}

// Verified from Ghidra: shares function body at 0x193c0 with HurtByVolume — returns 0.
INT AR6DZonePath::IsPointInZone(FVector const &)
{
	return 0;
}

void AR6DZonePath::PostScriptDestroyed()
{
	guard(AR6DZonePath::PostScriptDestroyed);
	while (m_aNode.Num() > 0)
	{
		AActor* Node = m_aNode(0);
		m_aNode.Remove(0);
		SafeDestroyActor(Node);
	}
	m_aNode.Empty();
	unguard;
}

void AR6DZonePath::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AR6DZonePath::SpawnANewNode(FVector)
{
	guard(AR6DZonePath::SpawnANewNode);
	AR6DZonePathNode* Node = (AR6DZonePathNode*)XLevel->SpawnActor(AR6DZonePathNode::StaticClass());
	m_aNode.AddItem(Node);
	Node->m_pPath = this;
	unguard;
}

void AR6DZonePath::Spawned()
{
	guard(AR6DZonePath::Spawned);
	AR6DeploymentZone::Spawned();
	SpawnANewNode(FVector(Location.X, Location.Y + 20.0f, Location.Z));
	SpawnANewNode(FVector(Location.X, Location.Y + 100.0f, Location.Z));
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
