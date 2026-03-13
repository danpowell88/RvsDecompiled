/*=============================================================================
	R6IORotatingDoor.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6IORotatingDoor)

IMPLEMENT_FUNCTION(AR6IORotatingDoor, -1, execAddBreach)
IMPLEMENT_FUNCTION(AR6IORotatingDoor, -1, execRemoveBreach)
IMPLEMENT_FUNCTION(AR6IORotatingDoor, -1, execWillOpenOnTouch)

// Statics used by AR6IORotatingDoor PreNetReceive/PostNetReceive.
static FVector GRotatingDoor_OldLocation;

// --- AR6IORotatingDoor ---

void AR6IORotatingDoor::AddMyMarker(AActor *)
{
}

INT AR6IORotatingDoor::DoorOpenTowards(FVector Point)
{
	FVector Dir = Rotation.Vector();
	m_vCenterOfDoor = Location - Dir * 64.0f;
	FVector Up(0, 0, 1);
	m_vNormal = Rotation.Vector() ^ Up;

	FLOAT Dot = (m_vCenterOfDoor.X - Point.X) * m_vNormal.X +
	            (m_vCenterOfDoor.Y - Point.Y) * m_vNormal.Y +
	            (m_vCenterOfDoor.Z - Point.Z) * m_vNormal.Z;

	if (Dot > 0.0f)
		return !m_bIsOpeningClockWise;
	return m_bIsOpeningClockWise;
}

INT AR6IORotatingDoor::IsMovingBrush() const
{
	return StaticMesh != NULL;
}

void AR6IORotatingDoor::PostNetReceive()
{
	guard(AR6IORotatingDoor::PostNetReceive);
	AR6InteractiveObject::PostNetReceive();

	// Doors don't replicate position — restore if it changed
	if (GRotatingDoor_OldLocation.X != Location.X ||
		GRotatingDoor_OldLocation.Y != Location.Y ||
		GRotatingDoor_OldLocation.Z != Location.Z)
	{
		Location = GRotatingDoor_OldLocation;
	}

	unguard;
}

void AR6IORotatingDoor::PostScriptDestroyed()
{
	guard(AR6IORotatingDoor::PostScriptDestroyed);
	SafeDestroyActor(m_DoorActorA);
	SafeDestroyActor(m_DoorActorB);
	AR6InteractiveObject::PostScriptDestroyed();
	unguard;
}

void AR6IORotatingDoor::PreNetReceive()
{
	guard(AR6IORotatingDoor::PreNetReceive);
	AR6InteractiveObject::PreNetReceive();
	GRotatingDoor_OldLocation = Location;
	unguard;
}

void AR6IORotatingDoor::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

INT AR6IORotatingDoor::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	guard(AR6IORotatingDoor::ShouldTrace);

	if (!(TraceFlags & 0x80000))
	{
		// See-through or bullet-goes-through → skip this door
		if ((TraceFlags & 0x20000) && m_bSeeThrough)
			return 0;
		if ((TraceFlags & 0x40000) && m_bBulletGoThrough)
			return 0;

		// If not tracing for movers, defer to parent
		if (!(TraceFlags & TRACE_Movers) &&
			!AR6InteractiveObject::ShouldTrace(Other, TraceFlags))
			return 0;
	}

	return 1;

	unguard;
}

INT AR6IORotatingDoor::WillOpenOnTouch(AR6Pawn* Pawn)
{
	if (!Pawn->m_bIsPlayer && m_bIsDoorClosed && Rotation.Yaw != m_iYawInit)
		return 1;
	return 0;
}

void AR6IORotatingDoor::execAddBreach(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, BreachAttached);
	P_FINISH;
	m_BreachAttached.AddItem((AR6AbstractBullet*)BreachAttached);
}

void AR6IORotatingDoor::execRemoveBreach(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, BreachAttached);
	P_FINISH;
	m_BreachAttached.RemoveItem((AR6AbstractBullet*)BreachAttached);
}

void AR6IORotatingDoor::execWillOpenOnTouch(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AR6Pawn, R6Pawn);
	P_FINISH;
	*(DWORD*)Result = WillOpenOnTouch(R6Pawn);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
