/*=============================================================================
	R6DZonePath.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6DZonePath)

// --- AR6DZonePath ---

IMPL_APPROX("Reconstructed path validation: checks node list is non-empty and delegates to base CheckForErrors")
void AR6DZonePath::CheckForErrors()
{
	guard(AR6DZonePath::CheckForErrors);
	if (m_aNode.Num() == 0)
		GWarn->Logf(TEXT("%s don't have any node!"), GetName());
	AR6DeploymentZone::CheckForErrors(true);
	unguard;
}

IMPL_APPROX("Reconstructed node deletion by pointer: searches m_aNode and delegates to index overload")
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

IMPL_APPROX("Reconstructed node deletion by index: removes from array and destroys actor")
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

IMPL_APPROX("Reconstructed closest-point-on-circle search across all path nodes")
FVector AR6DZonePath::FindClosestPointTo(FVector const & Point)
{
	guard(AR6DZonePath::FindClosestPointTo);

	if (m_aNode.Num() == 0)
		return FVector(0,0,0);

	// Retail: for each node, project Point onto the circle of radius m_fRadius
	// centred on the node (XY plane only — retail zeroes the Z contribution).
	// Return the candidate with minimum distance to Point.
	AR6DZonePathNode* Node = m_aNode(0);
	FVector Dir = (Point - Node->Location).SafeNormal();
	FVector BestCandidate;
	BestCandidate.X = Dir.X * Node->m_fRadius + Node->Location.X;
	BestCandidate.Y = Dir.Y * Node->m_fRadius + Node->Location.Y;
	BestCandidate.Z = Node->Location.Z;
	FLOAT BestDist2 = (BestCandidate - Point).SizeSquared();

	for (INT i = 1; i < m_aNode.Num(); i++)
	{
		Node = m_aNode(i);
		Dir = (Point - Node->Location).SafeNormal();
		FVector Candidate;
		Candidate.X = Dir.X * Node->m_fRadius + Node->Location.X;
		Candidate.Y = Dir.Y * Node->m_fRadius + Node->Location.Y;
		Candidate.Z = Node->Location.Z;
		FLOAT Dist2 = (Candidate - Point).SizeSquared();
		if (Dist2 < BestDist2)
		{
			BestCandidate = Candidate;
			BestDist2 = Dist2;
		}
	}

	return BestCandidate;

	unguard;
}

IMPL_APPROX("Reconstructed random point within a randomly chosen node's radius")
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

IMPL_APPROX("Reconstructed spawning point with rotation from randomly chosen node")
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

// Ghidra 0x193c0: shared null stub — same address as HurtByVolume/R6DZoneRandomPoints::IsPointInZone.
// No SEH frame in binary; returns 0 (MSVC requires a return value in non-void functions).
IMPL_MATCH("R6Engine.dll", 0x193c0)
INT AR6DZonePath::IsPointInZone(FVector const &)
{
	return 0;
}

IMPL_APPROX("Reconstructed node list destruction loop with safe actor cleanup")
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

IMPL_APPROX("Calls parent RenderEditorInfo; additional FLineBatcher path node drawing stubbed")
void AR6DZonePath::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6DZonePath::RenderEditorInfo);
	AR6DeploymentZone::RenderEditorInfo(SceneNode, RI, DA);
	// Ghidra at line 14047: draws lines connecting path nodes and circles around each node
	// when selected (Flags & 0x4000). Propagates selection to child nodes.
	// FLineBatcher drawing is a stub in this project.
	unguard;
}

IMPL_APPROX("Reconstructed path node spawn and parent-link setup")
void AR6DZonePath::SpawnANewNode(FVector)
{
	guard(AR6DZonePath::SpawnANewNode);
	AR6DZonePathNode* Node = (AR6DZonePathNode*)XLevel->SpawnActor(AR6DZonePathNode::StaticClass());
	m_aNode.AddItem(Node);
	Node->m_pPath = this;
	unguard;
}

IMPL_APPROX("Reconstructed initial node spawning with two offset nodes along Y axis")
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
