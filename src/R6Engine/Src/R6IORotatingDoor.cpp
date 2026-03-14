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

void AR6IORotatingDoor::AddMyMarker(AActor * param_1)
{
	guard(AR6IORotatingDoor::AddMyMarker);

	// DIVERGENCE: Ghidra 0x1f330 (~5061 bytes). Spawns R6Door navigation markers at
	// the door's pivot; calculates door normal via cross product; spawns door actor(s)
	// for m_DoorActorA / m_DoorActorB with clockwise/sliding variations.
	// Multiple unresolved FUN_ helpers and raw SpawnActor vtable dispatch make this
	// impractical to reconstruct without further Ghidra analysis. AI door pathfinding
	// markers will be absent — doors are still physically present and functional.

	unguard;
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

void AR6IORotatingDoor::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6IORotatingDoor::RenderEditorInfo);

	if ((*(DWORD*)((BYTE*)this + 0xAC) & 0x4000) != 0)
	{
		// Ghidra at 0x1d550: computes a rotated direction vector from the door's rotation,
		// adjusting Yaw by (m_iOpenAngle * 0xFFFF / 360) with sign based on m_bIsOpeningClockWise.
		// Draws a line from Location to Location + Dir * 128 using FLineBatcher::DrawLine
		// with color 0xff0000ff (blue).

		FLineBatcher Batcher(*(FRenderInterface**)(*(INT*)((BYTE*)SceneNode + 4) + 0x164), 1, 0);

		FRotator DrawRot;
		DrawRot.Pitch = *(INT*)((BYTE*)this + 0x240);
		DrawRot.Roll  = *(INT*)((BYTE*)this + 0x248);

		INT angleUnreal = (*(INT*)((BYTE*)this + 0x46c) * 0xFFFF) / 0x168;
		if ((((BYTE*)this)[0x488] & 0x40) == 0)
			angleUnreal = -angleUnreal;
		DrawRot.Yaw = *(INT*)((BYTE*)this + 0x244) - 0x8000 + angleUnreal;

		FVector Dir = DrawRot.Vector();
		FVector Start;
		Start.X = *(FLOAT*)((BYTE*)this + 0x234);
		Start.Y = *(FLOAT*)((BYTE*)this + 0x238);
		Start.Z = *(FLOAT*)((BYTE*)this + 0x23c);

		FVector End;
		End.X = Dir.X * 128.0f + Start.X;
		End.Y = Dir.Y * 128.0f + Start.Y;
		End.Z = Dir.Z * 128.0f + Start.Z;

		Batcher.DrawLine(Start, End, FColor((DWORD)0xff0000ff));
	}

	unguard;
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
