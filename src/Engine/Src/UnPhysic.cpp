/*=============================================================================
	UnPhysic.cpp: Physics volumes and zone system
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- APhysicsVolume ---
IMPL_GHIDRA("Engine.dll", 0xb77a0)
void APhysicsVolume::SetZone(INT bTest, INT bJustTeleported)
{
	guard(APhysicsVolume::SetZone);
	// Ghidra 0xb77a0 (263 bytes): query BSP for new zone/leaf, fire zone-change
	// events, then register self as own PhysicsVolume (physics volumes live in
	// themselves, unlike regular actors which look up the enclosing volume).
	if (!bDeleteMe)
	{
		if (bJustTeleported)
		{
			Region.Zone      = Level;
			Region.iLeaf     = -1;
			Region.ZoneNumber = 0;
		}
		FPointRegion NewRegion;
		UModel* pModel = *(UModel**)((BYTE*)XLevel + 0x90);
		NewRegion = pModel ? pModel->PointRegion(Level, Location)
		                   : FPointRegion(Level);
		if (NewRegion.Zone == Region.Zone)
		{
			Region = NewRegion;
		}
		else
		{
			if (!bTest)
			{
				Region.Zone->eventActorLeaving(this);
				eventZoneChange(NewRegion.Zone);
			}
			Region = NewRegion;
			if (!bTest)
				Region.Zone->eventActorEntered(this);
		}
		PhysicsVolume = this;
	}
	unguard;
}

IMPL_INFERRED("Delegates to AActor::GetOptimizedRepList")
INT* APhysicsVolume::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}


// --- AVolume ---
IMPL_TODO("Needs Ghidra analysis")
void AVolume::SetVolumes(TArray<AVolume *> const &)
{
}

IMPL_TODO("Needs Ghidra analysis")
void AVolume::SetVolumes()
{
}

IMPL_GHIDRA("Engine.dll", 0x71530)
int AVolume::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	guard(AVolume::ShouldTrace);
	// Ghidra 0x71530: collision trace permission check for volumes.
	if ((TraceFlags & 0x2000) == 0)
	{
		if (TraceFlags & 0x20000)
		{
			// TRACE_Volumes: return !bHidden (inverted bit 0 of ushort at 0xaa)
			return ~(DWORD)*(_WORD*)((BYTE*)this + 0xaa) & 1;
		}
		if ( (!(TraceFlags & 0x40000) || !(*(DWORD*)((BYTE*)this + 0xa8) & 0x40000)) &&
		     (!Other || !(*(DWORD*)((BYTE*)Other + 0xa0) & 0x2000000)) )
		{
			if ((*(DWORD*)((BYTE*)this + 0xa0) & 0x2000000) && Other)
			{
				// vtable[26] on Other — IsStaticActor or similar
				typedef int (__thiscall* VFn26)(AActor*);
				int r = ((VFn26)(*(INT*)(*(INT*)Other + 0x68)))(Other);
				if (!r)
					return 0;
			}
			if ((*(DWORD*)((BYTE*)this + 0xa0) & 0x100000) && (SBYTE)TraceFlags < 0)
				return 1;
			if (TraceFlags & 8)
			{
				if (!(TraceFlags & 0x20))
				{
					if (TraceFlags & 0x40)
					{
						if (!Other) return 0;
						// vtable[28] on Other with this as parameter
						typedef int (__thiscall* VFn28)(AActor*, AActor*);
						int r2 = ((VFn28)(*(INT*)(*(INT*)Other + 0x70)))(Other, (AActor*)this);
						if (!r2) return 0;
						return 1;
					}
				}
				else
				{
					DWORD uVar1 = *(DWORD*)((BYTE*)this + 0xa8);
					if ((SBYTE)(uVar1 >> 8) >= 0)
					{
						if (!(uVar1 & 0x2000)) return 0;
						if (!(uVar1 & 0x4000)) return 0;
					}
				}
				return 1;
			}
		}
	}
	return 0;
	unguard;
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x175ab0, "R6 decoration-volume spawning deferred: undocumented struct layout at +0x3f8 not yet reconstructed")
void AVolume::PostBeginPlay()
{
	guard(AVolume::PostBeginPlay);
	Super::PostBeginPlay();
	// Ghidra 0x175ab0 (886 bytes): R6-specific decoration volume spawning.
	// When a decoration-spec array is attached at +0x3f8, iterates the specs,
	// randomly places ADecoVolumeObject actors within the brush bounds using
	// ULevel::ToFloor, and optionally randomises rotation/scale per spec entry.
	// Deferred: requires the undocumented R6 struct layout at offset +0x3f8.
	unguard;
}

IMPL_INFERRED("No Ghidra RVA; Brush PointCheck pattern inferred from Ghidra notes")
int AVolume::Encompasses(FVector Location)
{
	// Ghidra: Check if Brush is NULL (offset 0x178), return 0 if so.
	// Then call Brush->PointCheck with the location and zero extent.
	// Return 1 if PointCheck returns 0 (point is inside the volume).
	UPrimitive* Brush = *(UPrimitive**)((BYTE*)this + 0x178);
	if (!Brush)
		return 0;

	FCheckResult Result(1.0f);
	INT Check = Brush->PointCheck(Result, this, Location, FVector(0, 0, 0), 0);
	return (Check == 0) ? 1 : 0;
}


// --- AWarpZoneInfo ---
IMPL_GHIDRA_APPROX("Engine.dll", 0xe12c0, "scout zone-resize fallback path deferred: unknown Level vtable slot 0x9c")
void AWarpZoneInfo::AddMyMarker(AActor* param_1)
{
	guard(AWarpZoneInfo::AddMyMarker);
	// Ghidra 0xe12c0 (453 bytes): when a Scout is placed at this WarpZone, verify
	// it can fit (findStart), then spawn an AWarpZoneMarker at the scout's location
	// and link it back to this WarpZoneInfo.
	if (!param_1)
		return;

	if (param_1->IsA(AScout::StaticClass()))
	{
		AScout* Scout = (AScout*)param_1;
		if (!Scout->findStart(Scout->Location) || Scout->Region.Zone != Region.Zone)
		{
			Scout->SetCollisionSize(40.0f, Scout->CollisionHeight);
			if (!Scout->findStart(Scout->Location) || Scout->Region.Zone != Region.Zone)
			{
				// Ghidra: calls Level->vtable[0x27] (slot 0x9c) when scout still
				// cannot reach the zone after resize; deferred (unknown method).
			}
			Scout->SetCollisionSize(40.0f, Scout->CollisionHeight);
		}

		// Find the WarpZoneMarker class and spawn one at the scout's position.
		UClass* WZMClass = (UClass*)UObject::StaticFindObjectChecked(
			UClass::StaticClass(), (UObject*)-1, TEXT("WarpZoneMarker"), 0);
		AActor* Marker = XLevel->SpawnActor(WZMClass, NAME_None, Scout->Location);
		if (Marker && !Marker->IsA(AWarpZoneMarker::StaticClass()))
			Marker = NULL;

		// Link marker back to this WarpZoneInfo (offset 0x3E8 in AWarpZoneMarker).
		*(AWarpZoneInfo**)((BYTE*)Marker + 0x3E8) = this;
	}
	unguard;
}


// --- AWarpZoneMarker ---
IMPL_TODO("Needs Ghidra analysis")
void AWarpZoneMarker::addReachSpecs(APawn*,int)
{
	guardSlow(AWarpZoneMarker::addReachSpecs);
	unguardSlow;
}

IMPL_GHIDRA("Engine.dll", 0xd5f00)
int AWarpZoneMarker::IsIdentifiedAs(FName Name)
{
	guard(AWarpZoneMarker::IsIdentifiedAs);
	// Ghidra 0xd5f00: compare Name against own name, then against linked actor (this+0x3e8) name.
	if (Name == GetFName())
		return 1;
	UObject* linked = *(UObject**)((BYTE*)this + 0x3e8); // unknown linked actor field
	if (linked != NULL && Name == linked->GetFName())
		return 1;
	return 0;
	unguard;
}


// --- AZoneInfo ---
IMPL_TODO("Needs Ghidra analysis")
void AZoneInfo::PostEditChange()
{
	guard(AZoneInfo::PostEditChange);
	unguard;
}


// --- FZoneProperties ---
IMPL_GHIDRA("Engine.dll", 0x2ac0)
FZoneProperties::FZoneProperties(const FZoneProperties& Other)
{
	// Ghidra 0x2ac0: shares address with operator=; 18 DWORDs flat copy (no vtable)
	appMemcpy(this, &Other, 0x48);
}

IMPL_GHIDRA("Engine.dll", 0x18b40)
FZoneProperties::FZoneProperties()
{
	// Ghidra 0x18b40: 53 bytes. Zeroes offsets 0x08-0x44 (16 DWORDs).
	// First 8 bytes are left untouched (written only by the copy ctor / operator=).
	appMemzero((BYTE*)this + 8, 0x40);
}

IMPL_GHIDRA("Engine.dll", 0x2ac0)
FZoneProperties& FZoneProperties::operator=(const FZoneProperties& Other)
{
	// Ghidra 0x2ac0: 18 DWORDs from +0x00 (no vtable; also used as copy ctor body)
	appMemcpy(this, &Other, 0x48);
	return *this;
}

