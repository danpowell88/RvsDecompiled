/*=============================================================================
	R6DZoneRandomPoints.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6DZoneRandomPoints)

// --- AR6DZoneRandomPoints ---

void AR6DZoneRandomPoints::CheckForErrors()
{
	guard(AR6DZoneRandomPoints::CheckForErrors);
	if (m_aNode.Num() == 0)
		GWarn->Logf(TEXT("%s don't have any node!"), GetName());
	for (INT i = 0; i < m_aNode.Num(); i++)
	{
		AR6DZoneRandomPointNode* Node = m_aNode(i);
		if (Node->m_pZone != this)
		{
			GWarn->Logf(TEXT("%s belong %s and have been removed from %s"),
				Node->GetName(),
				Node->m_pZone ? Node->m_pZone->GetName() : TEXT("None"),
				GetName());
			m_aNode.Remove(i);
			i--;
		}
	}
	AR6DeploymentZone::CheckForErrors(true);
	unguard;
}

void AR6DZoneRandomPoints::DeleteANode(AR6DZoneRandomPointNode *Node)
{
	guard(AR6DZoneRandomPoints::DeleteANode);
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

void AR6DZoneRandomPoints::DeleteANode(INT iIndex)
{
	guard(AR6DZoneRandomPoints::DeleteANode);
	check(iIndex < m_aNode.Num());
	AActor* Node = m_aNode(iIndex);
	m_aNode.Remove(iIndex);
	if (!Node->bDeleteMe)
		XLevel->DestroyActor(Node, 0);
	unguard;
}

FVector AR6DZoneRandomPoints::FindClosestPointTo(FVector const & Point)
{
	guard(AR6DZoneRandomPoints::FindClosestPointTo);

	if (m_aNode.Num() == 0)
		return FVector(0,0,0);

	AR6DZoneRandomPointNode* Best = m_aNode(0);
	FLOAT BestDist2 = (Best->Location - Point).SizeSquared();

	for (INT i = 1; i < m_aNode.Num(); i++)
	{
		FLOAT Dist2 = (m_aNode(i)->Location - Point).SizeSquared();
		if (Dist2 < BestDist2)
		{
			Best = m_aNode(i);
			BestDist2 = Dist2;
		}
	}

	return Best->Location;

	unguard;
}

FVector AR6DZoneRandomPoints::FindRandomPointInArea()
{
	guard(AR6DZoneRandomPoints::FindRandomPointInArea);
	if (m_aNode.Num() == 0)
	{
		GLog->Logf(TEXT("%s has no nodes"), GetName());
		return FVector(0,0,0);
	}
	INT Index = appRand() % m_aNode.Num();
	return m_aNode(Index)->Location;
	unguard;
}

FVector AR6DZoneRandomPoints::FindSpawningPoint(FRotator * pRotation, INT * pGroupID, enum EStance * pStance, INT * pAllowLeave)
{
	guard(AR6DZoneRandomPoints::FindSpawningPoint);
	TArray<AR6DZoneRandomPointNode*>* TempArray = &m_aTempHighPriorityNode;
	if (m_aTempHighPriorityNode.Num() == 0)
		TempArray = &m_aTempNode;

	if (m_aNode.Num() == 0)
	{
		GLog->Logf(TEXT("%s has no nodes"), GetName());
		return FVector(0,0,0);
	}

	AR6DZoneRandomPointNode* Node;
	if (!m_bInInit || TempArray->Num() == 0)
	{
		INT Index = appRand() % m_aNode.Num();
		Node = m_aNode(Index);
	}
	else
	{
		INT Index = appRand() % TempArray->Num();
		Node = (*TempArray)(Index);
		TempArray->Remove(Index);
	}

	*pRotation = Node->Rotation;
	*pGroupID = Node->m_iGroupID;
	*pStance = (enum EStance)Node->m_eStance;
	*pAllowLeave = Node->m_bAllowLeave;
	return Node->Location;
	unguard;
}

void AR6DZoneRandomPoints::FirstInit()
{
	guard(AR6DZoneRandomPoints::FirstInit);
	m_aTempHighPriorityNode.Empty();
	m_aTempNode.Empty();
	for (INT i = 0; i < m_aNode.Num(); i++)
	{
		AR6DZoneRandomPointNode* Node = m_aNode(i);
		if (Node->m_bHighPriority)
			m_aTempHighPriorityNode.AddItem(Node);
		else
			m_aTempNode.AddItem(Node);
	}
	m_bInInit = 1;
	AR6DeploymentZone::FirstInit();
	m_bInInit = 0;
	unguard;
}

INT AR6DZoneRandomPoints::GetNbOfTerroristToSpawn()
{
	return 0;
}

// Verified from Ghidra: shares function body at 0x193c0 with HurtByVolume — returns 0.
INT AR6DZoneRandomPoints::IsPointInZone(FVector const &)
{
	return 0;
}

void AR6DZoneRandomPoints::PostScriptDestroyed()
{
	guard(AR6DZoneRandomPoints::PostScriptDestroyed);
	while (m_aNode.Num() > 0)
	{
		AActor* Node = m_aNode(0);
		m_aNode.Remove(0);
		SafeDestroyActor(Node);
	}
	m_aNode.Empty();
	unguard;
}

void AR6DZoneRandomPoints::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AR6DZoneRandomPoints::SpawnANewNode(FVector)
{
	guard(AR6DZoneRandomPoints::SpawnANewNode);
	AR6DZoneRandomPointNode* Node = (AR6DZoneRandomPointNode*)XLevel->SpawnActor(AR6DZoneRandomPointNode::StaticClass());
	m_aNode.AddItem(Node);
	Node->m_pZone = this;
	unguard;
}

void AR6DZoneRandomPoints::Spawned()
{
	guard(AR6DZoneRandomPoints::Spawned);
	AR6DeploymentZone::Spawned();
	SpawnANewNode(FVector(Location.X, Location.Y + 100.0f, Location.Z));
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
