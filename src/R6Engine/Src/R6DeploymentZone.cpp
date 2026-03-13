/*=============================================================================
	R6DeploymentZone.cpp
	AR6DeploymentZone and all zone shape/node subclasses.
	AR6CoverSpot, AR6DZonePath, AR6DZonePathNode, AR6DZonePoint,
	AR6DZoneRandomPointNode, AR6DZoneRandomPoints, AR6DZoneCircle,
	AR6DZoneRectangle.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6CoverSpot)
IMPLEMENT_CLASS(AR6DZoneCircle)
IMPLEMENT_CLASS(AR6DZonePath)
IMPLEMENT_CLASS(AR6DZonePathNode)
IMPLEMENT_CLASS(AR6DZonePoint)
IMPLEMENT_CLASS(AR6DZoneRandomPointNode)
IMPLEMENT_CLASS(AR6DZoneRandomPoints)
IMPLEMENT_CLASS(AR6DZoneRectangle)
IMPLEMENT_CLASS(AR6DeploymentZone)

IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execAddHostage)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execFindClosestPointTo)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execFindRandomPointInArea)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execFirstInit)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execGetClosestHostage)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execHaveHostage)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execHaveTerrorist)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execIsPointInZone)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execOrderTerroListFromDistanceTo)

// --- AR6CoverSpot ---

void AR6CoverSpot::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

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

// --- AR6DZonePathNode ---

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

void AR6DZonePathNode::PostScriptDestroyed()
{
	guard(AR6DZonePathNode::PostScriptDestroyed);
	if (m_pPath)
		m_pPath->DeleteANode(this);
	unguard;
}

void AR6DZonePathNode::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6DZonePathNode::RenderEditorInfo);
	if (m_pPath)
		m_pPath->RenderEditorInfo(SceneNode, RI, DA);
	unguard;
}

// --- AR6DZonePoint ---

FVector AR6DZonePoint::FindClosestPointTo(FVector const & Point)
{
	FVector Result = Location;
	if (m_bUseReactionZone)
	{
		FLOAT HalfX = m_fReactionZoneX * 0.5f;
		FLOAT HalfY = m_fReactionZoneY * 0.5f;
		Result.X = Clamp(Point.X, m_vReactionZoneCenter.X - HalfX, m_vReactionZoneCenter.X + HalfX);
		Result.Y = Clamp(Point.Y, m_vReactionZoneCenter.Y - HalfY, m_vReactionZoneCenter.Y + HalfY);
		Result.Z = Point.Z;
	}
	return Result;
}

FVector AR6DZonePoint::FindRandomPointInArea()
{
	return Location;
}

FVector AR6DZonePoint::FindSpawningPoint(FRotator * pRotation, INT *, enum EStance * pStance, INT *)
{
	*pRotation = Rotation;
	*pStance = (enum EStance)m_eStance;
	return FindRandomPointInArea();
}

INT AR6DZonePoint::IsPointInZone(FVector const & Point)
{
	FLOAT RefX, DeltaY, DeltaZ;
	if (!m_bUseReactionZone)
	{
		RefX = Location.X;
		DeltaY = Point.Y - Location.Y;
		DeltaZ = Point.Z - Location.Z;
	}
	else
	{
		RefX = m_vReactionZoneCenter.X;
		DeltaY = Point.Y - m_vReactionZoneCenter.Y;
		DeltaZ = Point.Z - m_vReactionZoneCenter.Z;
	}
	FLOAT DeltaX = Point.X - RefX;
	if (DeltaZ < 0.0f) DeltaZ = -DeltaZ;
	if (DeltaZ < 100.0f)
	{
		if (!m_bUseReactionZone)
		{
			if (DeltaX * DeltaX + DeltaY * DeltaY <= 2500.0f)
				return 1;
		}
		else
		{
			if (DeltaX < 0.0f) DeltaX = -DeltaX;
			if (DeltaX > m_fReactionZoneX * 0.5f)
				return 0;
			if (DeltaY < 0.0f) DeltaY = -DeltaY;
			if (DeltaY <= m_fReactionZoneY * 0.5f)
				return 1;
		}
	}
	return 0;
}

void AR6DZonePoint::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AR6DZonePoint::Spawned()
{
	guard(AR6DZonePoint::Spawned);
	AR6DeploymentZone::Spawned();
	m_vReactionZoneCenter = Location;
	unguard;
}

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

FVector AR6DZoneRandomPoints::FindClosestPointTo(FVector const &)
{
	return FVector(0,0,0);
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

// --- AR6DeploymentZone ---

void AR6DeploymentZone::CheckForErrors()
{
	guard(AR6DeploymentZone::CheckForErrors);
	if (!IsA(AR6DZoneRandomPoints::StaticClass()) && !IsA(AR6DZonePath::StaticClass()))
	{
		PutOnGround();
		if (!Base)
			GWarn->Logf(TEXT("Deployment zone not on valid base."));
	}
	CheckForErrors(true);
	unguard;
}

void AR6DeploymentZone::CheckForErrors(bool bSilent)
{
	guard(AR6DeploymentZone::CheckForErrors);

	// Validate terrorist template chances sum to 100 (or 0 if unused)
	INT TerroTotal = m_Template[0].m_iChance + m_Template[1].m_iChance + m_Template[2].m_iChance
	               + m_Template[3].m_iChance + m_Template[4].m_iChance;
	if (TerroTotal != 100 && TerroTotal != 0)
	{
		if (bSilent)
			GWarn->Logf(TEXT("Total template chance of TERRORIST is %d%% in %s"), TerroTotal, GetName());
		else
			appMsgf(0, TEXT("Total template chance of TERRORIST is %d%% in %s"), TerroTotal, GetName());
	}

	// Validate hostage template chances sum to 100 (or 0 if unused)
	INT HostTotal = m_HostageTemplates[0].m_iChance + m_HostageTemplates[1].m_iChance + m_HostageTemplates[2].m_iChance
	              + m_HostageTemplates[3].m_iChance + m_HostageTemplates[4].m_iChance;
	if (HostTotal != 100 && HostTotal != 0)
	{
		if (bSilent)
			GWarn->Logf(TEXT("Total template chance of HOSTAGE is %d%% in %s"), HostTotal, GetName());
		else
			appMsgf(0, TEXT("Total template chance of HOSTAGE is %d%% in %s"), HostTotal, GetName());
	}

	// Validate terrorist min/max range
	// NOTE: Original binary uses "HOSTAGE" string in bSilent path — likely a copy-paste bug in retail code.
	if (m_iMinTerrorist < 0 || m_iMaxTerrorist < m_iMinTerrorist)
	{
		if (bSilent)
			GWarn->Logf(TEXT("Template min max of HOSTAGE is wrong (min=%d%% max=%d%%) in %s"), m_iMinTerrorist, m_iMaxTerrorist, GetName());
		else
			appMsgf(0, TEXT("Template min max of TERRORIST is wrong (min=%d%% max=%d%%) in %s"), m_iMinTerrorist, m_iMaxTerrorist, GetName());
	}

	// Validate hostage min/max range
	if (m_iMinHostage < 0 || m_iMaxHostage < m_iMinHostage)
	{
		if (bSilent)
			GWarn->Logf(TEXT("Template min max of HOSTAGE is wrong (min=%d%% max=%d%%) in %s"), m_iMinHostage, m_iMaxHostage, GetName());
		else
			appMsgf(0, TEXT("Template min max of HOSTAGE is wrong (min=%d%% max=%d%%) in %s"), m_iMinHostage, m_iMaxHostage, GetName());
	}

	unguard;
}

FVector AR6DeploymentZone::FindClosestPointTo(FVector const & Point)
{
	guard(AR6DeploymentZone::FindClosestPointTo);

	FLOAT ResultX = Point.X;
	FLOAT ResultY = Point.Y;
	FLOAT ResultZ = Location.Z;

	if (IsA(AR6DZoneRectangle::StaticClass()))
	{
		FLOAT HalfX = ((AR6DZoneRectangle*)this)->m_fX * 0.5f;
		FLOAT MaxX = Location.X + HalfX;
		FLOAT MinX = Location.X - HalfX;
		if (ResultX < MinX)
			ResultX = MinX;
		else if (ResultX > MaxX)
			ResultX = MaxX;

		FLOAT HalfY = ((AR6DZoneRectangle*)this)->m_fY * 0.5f;
		FLOAT MaxY = Location.Y + HalfY;
		FLOAT MinY = Location.Y - HalfY;
		if (ResultY < MinY)
			ResultY = MinY;
		else if (ResultY > MaxY)
			ResultY = MaxY;

		return FVector(ResultX, ResultY, ResultZ);
	}

	if (IsA(AR6DZoneCircle::StaticClass()))
	{
		FVector Delta(ResultX - Location.X, ResultY - Location.Y, ResultZ - Location.Z);
		FVector Dir = Delta.GetNormalized();
		FLOAT Radius = ((AR6DZoneCircle*)this)->m_fRadius;
		ResultX = Dir.X * Radius + Location.X;
		ResultY = Dir.Y * Radius + Location.Y;
		ResultZ = Dir.Z * Radius + Location.Z;
	}

	return FVector(ResultX, ResultY, ResultZ);

	unguard;
}

FVector AR6DeploymentZone::FindRandomPointInArea()
{
	return FVector(0,0,0);
}

FVector AR6DeploymentZone::FindSpawningPoint(FRotator *, INT *, enum EStance *, INT *)
{
	return FindRandomPointInArea();
}

void AR6DeploymentZone::FirstInit()
{
	guard(AR6DeploymentZone::FirstInit);

	// Get the game type string from Level->Game->m_szGameTypeFlag (offset 0x4B0)
	FString GameType = *(FString*)((BYTE*)Level->Game + 0x4B0);

	if (IsAvailableInGameType(GameType))
	{
		if (!m_bAlreadyInitialized)
		{
			CheckForErrors(false);

			if (!m_bAlreadyInitialized)
			{
				// Convert individual chances to cumulative sums
				INT TerrorCumulative = 0;
				INT HostageCumulative = 0;
				for (INT i = 0; i < 5; i++)
				{
					TerrorCumulative += m_Template[i].m_iChance;
					m_Template[i].m_iChance = TerrorCumulative;

					HostageCumulative += m_HostageTemplates[i].m_iChance;
					m_HostageTemplates[i].m_iChance = HostageCumulative;
				}
			}
		}

		// Spawn terrorists
		INT NumTerrorists = GetNbOfTerroristToSpawn();
		for (INT i = 0; i < NumTerrorists; i++)
		{
			SpawnATerrorist();
		}

		// Spawn hostages: random count in [m_iMinHostage, m_iMaxHostage]
		INT NumHostages = m_iMinHostage;
		if (m_iMinHostage < m_iMaxHostage)
		{
			NumHostages = m_iMinHostage + appRand() % ((m_iMaxHostage - m_iMinHostage) + 1);
		}
		for (INT i = 0; i < NumHostages; i++)
		{
			SpawnAHostage();
		}

		m_bAlreadyInitialized = 1;
	}

	unguard;
}

INT AR6DeploymentZone::GetNbOfTerroristToSpawn()
{
	// Check if game type overrides terrorist count
	FString& GameType = *(FString*)((BYTE*)Level->Game + 0x4B0);
	if (Level->eventGameTypeUseNbOfTerroristToSpawn(GameType))
		return 0;

	// Random number in [m_iMinTerrorist, m_iMaxTerrorist]
	INT Result = m_iMinTerrorist;
	if (m_iMinTerrorist < m_iMaxTerrorist)
		Result = m_iMinTerrorist + appRand() % ((m_iMaxTerrorist - m_iMinTerrorist) + 1);

	return Result;
}

INT AR6DeploymentZone::HaveHostage()
{
	INT i = -1;
	do
	{
		if (m_HostageZoneToCheck.Num() <= i)
			return 0;

		AR6DeploymentZone* Zone = this;
		if (i != -1)
			Zone = m_HostageZoneToCheck(i);

		while (Zone->m_aHostage.Num() > 0)
		{
			AR6Hostage* Hostage = Zone->m_aHostage(0);
			if (Hostage == NULL || (Hostage->m_eHealth < 2 && !Hostage->m_bExtracted))
				return 1;
			Zone->m_aHostage.Remove(0, 1);
		}
		i++;
	} while (true);
}

INT AR6DeploymentZone::HavePlaceForPawnAt(FVector& Position)
{
	guard(AR6DeploymentZone::HavePlaceForPawnAt);
	AActor* Default = AR6Terrorist::StaticClass()->GetDefaultActor();
	FVector Extent(Default->CollisionRadius, Default->CollisionRadius, Default->CollisionHeight);
	return XLevel->FindSpot(Extent, Position, 0, NULL);
	unguard;
}

INT AR6DeploymentZone::HaveTerrorist()
{
	for (INT i = 0; i < m_aTerrorist.Num(); i++)
	{
		AR6Terrorist* Terrorist = m_aTerrorist(i);
		if (Terrorist->m_eHealth < 2)
		{
			if (IsPointInZone(Terrorist->Location))
				return 1;
		}
		else
		{
			m_aTerrorist.Remove(i, 1);
			i--;
		}
	}
	return 0;
}

void AR6DeploymentZone::InitHostageAI(FR6CharTemplate *, AR6Hostage *)
{
}

void AR6DeploymentZone::InitTerroristAI(FR6CharTemplate *, AR6Terrorist *)
{
}

INT AR6DeploymentZone::IsPointInZone(FVector const & Point)
{
	guard(AR6DeploymentZone::IsPointInZone);

	FLOAT DeltaX = Point.X - Location.X;
	FLOAT DeltaY = Point.Y - Location.Y;
	FLOAT DeltaZ = Point.Z - Location.Z;

	if (DeltaZ < 0.0f)
		DeltaZ = -DeltaZ;

	if (DeltaZ < 100.0f)
	{
		if (IsA(AR6DZoneRectangle::StaticClass()))
		{
			if (DeltaX < 0.0f)
				DeltaX = -DeltaX;
			if (DeltaX > ((AR6DZoneRectangle*)this)->m_fX * 0.5f)
				return 0;
			if (DeltaY < 0.0f)
				DeltaY = -DeltaY;
			if (DeltaY > ((AR6DZoneRectangle*)this)->m_fY * 0.5f)
				return 0;
			return 1;
		}
		if (IsA(AR6DZoneCircle::StaticClass()))
		{
			FLOAT Radius = ((AR6DZoneCircle*)this)->m_fRadius;
			if (DeltaX * DeltaX + DeltaY * DeltaY <= Radius * Radius)
				return 1;
		}
	}

	return 0;

	unguard;
}

void AR6DeploymentZone::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AR6DeploymentZone::SpawnAHostage()
{
}

void AR6DeploymentZone::SpawnATerrorist()
{
}

void AR6DeploymentZone::Spawned()
{
	guard(AR6DeploymentZone::Spawned);
	m_Template[0].m_szName = TEXT("Normal");
	m_Template[0].m_iChance = 100;
	m_HostageTemplates[0].m_szName = TEXT("NormalHostage");
	m_HostageTemplates[0].m_iChance = 100;
	m_HostageTemplates[1].m_szName = TEXT("NormalCivilian");
	m_HostageTemplates[1].m_iChance = 0;
	unguard;
}

void AR6DeploymentZone::execAddHostage(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AR6Hostage, hostage);
	P_FINISH;
	m_aHostage.AddItem(hostage);
}

void AR6DeploymentZone::execFindClosestPointTo(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vPoint);
	P_FINISH;
	*(FVector*)Result = FindClosestPointTo(vPoint);
}

void AR6DeploymentZone::execFindRandomPointInArea(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FVector*)Result = FindRandomPointInArea();
}

void AR6DeploymentZone::execFirstInit(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	FirstInit();
}

void AR6DeploymentZone::execGetClosestHostage(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vPoint);
	P_FINISH;
	*(UObject**)Result = NULL;
}

void AR6DeploymentZone::execHaveHostage(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = HaveHostage();
}

void AR6DeploymentZone::execHaveTerrorist(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = HaveTerrorist();
}

void AR6DeploymentZone::execIsPointInZone(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vPoint);
	P_FINISH;
	*(DWORD*)Result = IsPointInZone(vPoint);
}

void AR6DeploymentZone::execOrderTerroListFromDistanceTo(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vPoint);
	P_FINISH;
}

INT AR6DeploymentZone::getChanceFromArrayTemplates(struct FSTTemplate *Templates, INT sizeOfArray)
{
	check(sizeOfArray <= 5); // UCONST_C_NB_Template
	INT Total = 0;
	for (INT i = 0; i < sizeOfArray; i++)
		Total += Templates[i].m_iChance;
	return Total;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
