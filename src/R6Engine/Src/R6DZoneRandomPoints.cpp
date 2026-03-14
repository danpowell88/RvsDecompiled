/*=============================================================================
	R6DZoneRandomPoints.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6DZoneRandomPoints)

// --- AR6DZoneRandomPoints ---

IMPL_APPROX("Reconstructed validation: checks node list, removes orphaned nodes, delegates to base")
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

IMPL_APPROX("Reconstructed node deletion by pointer: searches m_aNode and delegates to index overload")
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

IMPL_APPROX("Reconstructed node deletion by index: removes from array and destroys actor")
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

IMPL_APPROX("Reconstructed nearest-node location search using squared-distance comparison")
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

IMPL_APPROX("Reconstructed random node location selection")
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

IMPL_APPROX("Reconstructed priority-queue spawning point selection with rotation, group ID, stance and leave flag")
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

IMPL_APPROX("Reconstructed init: builds priority temp node lists, delegates to base FirstInit with m_bInInit guard")
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

IMPL_APPROX("Reconstructed with raw offsets: game mode and network path to GRI terrorist count, capped by zone max")
INT AR6DZoneRandomPoints::GetNbOfTerroristToSpawn()
{
	guard(AR6DZoneRandomPoints::GetNbOfTerroristToSpawn);

	// GameInfo->GameType FString at offset 0x4b0 (TODO: no typed field name in AGameInfo)
	const FString& GameType = *(const FString*)((BYTE*)Level->Game + 0x4b0);

	DWORD bUseDynamic = Level->eventGameTypeUseNbOfTerroristToSpawn(GameType);

	INT Count;
	if (bUseDynamic == 0)
	{
		if (!(GameType == TEXT("RGM_CountDownMode")))
		{
			Count = m_iMinTerrorist;
			if (Count < m_iMaxTerrorist)
				Count += appRand() % (m_iMaxTerrorist - m_iMinTerrorist + 1);
			goto NbCap;
		}
	}

	// Get count from GRI or GameInfo depending on network mode
	if (Level->NetMode == 0) // NETMODE_Standalone
	{
		// Deep GEngine pointer chain to GRI->m_iNbOfTerroristToSpawn:
		// GEngine+0x44 -> ViewportManager -> +0x30 -> GameClient -> deref x2
		// -> +0x38 -> +0x34 -> +0x2c -> +0x39c = replicated terrorist count
		INT A  = *(INT*)((BYTE*)GEngine + 0x44);
		INT B  = *(INT*)(A + 0x30);
		INT C  = *(INT*)(*(INT*)B);   // double deref
		INT D  = *(INT*)(C + 0x38);
		INT E  = *(INT*)(D + 0x34);
		INT F  = *(INT*)(E + 0x2c);
		Count  = *(INT*)(F + 0x39c);  // GRI->m_iNbOfTerroristToSpawn or similar
	}
	else
	{
		Count = *(INT*)((BYTE*)Level->Game + 0x4d8); // AGameInfo::m_iNbOfTerrorist (raw offset)
	}

NbCap:
	{
		INT MaxCap = *(INT*)((BYTE*)this + 0x4a4); // m_iNbOfTerroristMax (raw offset)
		if (MaxCap < Count)
		{
			GLog->Logf(TEXT("%s: NbOfTerrorist capped at %d"), GetName(), MaxCap);
			Count = MaxCap;
		}
	}

	return Count;
	unguard;
}

// Ghidra 0x193c0: shared null stub — same address as HurtByVolume/R6DZonePath::IsPointInZone.
// No SEH frame in binary; returns 0 (MSVC requires a return value in non-void functions).
IMPL_MATCH("R6Engine.dll", 0x193c0)
INT AR6DZoneRandomPoints::IsPointInZone(FVector const &)
{
	return 0;
}

IMPL_APPROX("Reconstructed node list destruction loop with safe actor cleanup")
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

IMPL_APPROX("Calls parent RenderEditorInfo; additional FLineBatcher node bounding box drawing stubbed")
void AR6DZoneRandomPoints::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6DZoneRandomPoints::RenderEditorInfo);
	AR6DeploymentZone::RenderEditorInfo(SceneNode, RI, DA);
	// Ghidra at line 14815: draws bounding boxes around each random point node
	// when selected (Flags & 0x4000). Propagates selection state to child nodes
	// if bSelectNodeInEditor is set.
	// FLineBatcher drawing is a stub in this project.
	unguard;
}

IMPL_APPROX("Reconstructed random point node spawn and parent zone link setup")
void AR6DZoneRandomPoints::SpawnANewNode(FVector)
{
	guard(AR6DZoneRandomPoints::SpawnANewNode);
	AR6DZoneRandomPointNode* Node = (AR6DZoneRandomPointNode*)XLevel->SpawnActor(AR6DZoneRandomPointNode::StaticClass());
	m_aNode.AddItem(Node);
	Node->m_pZone = this;
	unguard;
}

IMPL_APPROX("Reconstructed Spawned: delegates to base and spawns one initial node offset along Y axis")
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
