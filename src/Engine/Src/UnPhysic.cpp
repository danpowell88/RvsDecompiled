/*=============================================================================
	UnPhysic.cpp: Physics volumes and zone system
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- APhysicsVolume ---
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

INT* APhysicsVolume::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}


// --- AVolume ---
void AVolume::SetVolumes(TArray<AVolume *> const &)
{
}

void AVolume::SetVolumes()
{
}

int AVolume::ShouldTrace(AActor *,DWORD)
{
	return 0;
}

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
void AWarpZoneMarker::addReachSpecs(APawn*,int)
{
	guardSlow(AWarpZoneMarker::addReachSpecs);
	unguardSlow;
}

int AWarpZoneMarker::IsIdentifiedAs(FName)
{
	return 0;
}


// --- AZoneInfo ---
void AZoneInfo::PostEditChange()
{
	guard(AZoneInfo::PostEditChange);
	unguard;
}


// --- FZoneProperties ---
FZoneProperties::FZoneProperties(const FZoneProperties& Other)
{
	// Ghidra 0x2ac0: shares address with operator=; 18 DWORDs flat copy (no vtable)
	appMemcpy(this, &Other, 0x48);
}

FZoneProperties::FZoneProperties()
{
	// Ghidra 0x18b40 (53 bytes): zeroes offsets 0x08–0x44 (16 DWORDs).
	// First 8 bytes are left untouched (written only by the copy ctor / operator=).
	appMemzero((BYTE*)this + 8, 0x40);
}

FZoneProperties& FZoneProperties::operator=(const FZoneProperties& Other)
{
	// Ghidra 0x2ac0: 18 DWORDs from +0x00 (no vtable; also used as copy ctor body)
	appMemcpy(this, &Other, 0x48);
	return *this;
}

