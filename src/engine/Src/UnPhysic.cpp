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
void APhysicsVolume::SetZone(int,int)
{
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
void AWarpZoneInfo::AddMyMarker(AActor *)
{
}


// --- AWarpZoneMarker ---
void AWarpZoneMarker::addReachSpecs(APawn *,int)
{
}

int AWarpZoneMarker::IsIdentifiedAs(FName)
{
	return 0;
}


// --- AZoneInfo ---
void AZoneInfo::PostEditChange()
{
}


// --- FZoneProperties ---
FZoneProperties::FZoneProperties(const FZoneProperties& Other)
{
	// Ghidra 0x2ac0: shares address with operator=; 18 DWORDs flat copy (no vtable)
	appMemcpy(this, &Other, 0x48);
}

FZoneProperties::FZoneProperties()
{
}

FZoneProperties& FZoneProperties::operator=(const FZoneProperties& Other)
{
	// Ghidra 0x2ac0: 18 DWORDs from +0x00 (no vtable; also used as copy ctor body)
	appMemcpy(this, &Other, 0x48);
	return *this;
}

