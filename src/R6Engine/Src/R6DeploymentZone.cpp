/*=============================================================================
	R6DeploymentZone.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

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
