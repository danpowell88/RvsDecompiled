/*=============================================================================
	R6DZonePoint.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6DZonePoint)

// --- AR6DZonePoint ---

IMPL_APPROX("Reconstructed closest point in reaction zone or fixed location")
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

IMPL_APPROX("Reconstructed fixed-location random point (returns actor Location)")
FVector AR6DZonePoint::FindRandomPointInArea()
{
	return Location;
}

IMPL_APPROX("Reconstructed spawning point with rotation and stance from actor properties")
FVector AR6DZonePoint::FindSpawningPoint(FRotator * pRotation, INT *, enum EStance * pStance, INT *)
{
	*pRotation = Rotation;
	*pStance = (enum EStance)m_eStance;
	return FindRandomPointInArea();
}

IMPL_APPROX("Reconstructed point-in-zone test supporting circular radius and rectangular reaction zone")
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

IMPL_APPROX("Calls parent RenderEditorInfo; additional FLineBatcher bounding box drawing stubbed")
void AR6DZonePoint::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6DZonePoint::RenderEditorInfo);
	AR6DeploymentZone::RenderEditorInfo(SceneNode, RI, DA);
	// Ghidra: additionally draws a bounding box and (if m_bUseReactionZone) a reaction-zone box
	// when selected (Flags & 0x4000). FLineBatcher drawing is a stub in this project.
	unguard;
}

IMPL_APPROX("Reconstructed Spawned: delegates to base and caches initial reaction zone centre")
void AR6DZonePoint::Spawned()
{
	guard(AR6DZonePoint::Spawned);
	AR6DeploymentZone::Spawned();
	m_vReactionZoneCenter = Location;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
