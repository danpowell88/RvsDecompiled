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
IMPL_MATCH("Engine.dll", 0x103b77a0)
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

IMPL_DIVERGE("Ghidra 0x10375370: FUN_10370800 (FVector-compare helper) and FUN_10371990 (property handle cache) unresolved")
INT* APhysicsVolume::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}


// --- AVolume ---
IMPL_EMPTY("SetVolumes(array) — no volume tracking required for minimal playback; Ghidra analysis pending")
void AVolume::SetVolumes(TArray<AVolume *> const &)
{
}

IMPL_EMPTY("SetVolumes() — no-arg override; Ghidra analysis pending")
void AVolume::SetVolumes()
{
}

IMPL_MATCH("Engine.dll", 0x10371530)
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

IMPL_DIVERGE("Ghidra 0x10475AB0: FUN_1050557c (PRNG, unresolved) and R6 decoration struct layout at +0x3f8 not reproduced")
void AVolume::PostBeginPlay()
{
	guard(AVolume::PostBeginPlay);
	// Ghidra 0x175ab0 (886 bytes): calls AKConstraint::postKarmaStep, then when a
	// decoration-spec array is attached at +0x3f8, iterates specs and randomly places
	// ADecoVolumeObject actors within the brush bounds using ULevel::ToFloor.
	// FUN_1050557c() is an unresolved PRNG call that determines spawn count per spec.
	Super::PostBeginPlay();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103f05c0)
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
IMPL_DIVERGE("Ghidra 0x103E12C0: Level vtable slot 0x9c (void, no-args) when Scout.findStart fails after resize — method unidentified")
void AWarpZoneInfo::AddMyMarker(AActor* param_1)
{
	guard(AWarpZoneInfo::AddMyMarker);
	// Ghidra 0xe12c0: if param_1 is an AScout, verify it can fit (findStart), then
	// spawn an AWarpZoneMarker at the scout's location and link it back to this.
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
				// Ghidra: (**(code **)(**(int **)(this + 0x328) + 0x9c))()
				// = XLevel->vtable[0x9c/4]() -- unidentified ULevel virtual, called with
				// XLevel as implicit __thiscall receiver (no stack args).
				void* XLev = *(void**)((BYTE*)this + 0x328);
				((void(__thiscall*)(void*))(*(void***)XLev)[0x9c/4])(XLev);
			}
			Scout->SetCollisionSize(40.0f, Scout->CollisionHeight);
		}

		// Find the WarpZoneMarker class and spawn one at the scout's position.
		UClass* WZMClass = (UClass*)UObject::StaticFindObjectChecked(
			UClass::StaticClass(), (UObject*)-1, TEXT("WarpZoneMarker"), 0);
		// Ghidra: Level->vtable[0xa8/4] = SpawnActor (WZMClass, NAME_None, Scout->Location, FRotator(0,0,0))
		// Divergence: using XLevel->SpawnActor() which maps to the same vtable slot.
		AActor* Marker = XLevel->SpawnActor(WZMClass, NAME_None, Scout->Location);
		if (Marker && !Marker->IsA(AWarpZoneMarker::StaticClass()))
			Marker = NULL;

		// Link marker back to this WarpZoneInfo (offset 1000 = 0x3E8 in AWarpZoneMarker).
		*(AWarpZoneInfo**)((BYTE*)Marker + 1000) = this;
	}
	unguard;
}


// --- AWarpZoneMarker ---
IMPL_MATCH("Engine.dll", 0x103D8360)
void AWarpZoneMarker::addReachSpecs(APawn* Scout, int bOnlyWeightedPaths)
{
	guardSlow(AWarpZoneMarker::addReachSpecs);
	// Ghidra 0xd8360 (393 bytes): iterate Level's actor list; for each other
	// AWarpZoneMarker that shares the same WarpZone name (and at least one has bTwoWay set),
	// create a UReachSpec linking this to that marker, add to PathList. Then call base.
	// FUN_103d7010 = StaticConstructObject wrapper: constructs UReachSpec in the package
	// that owns XLevel.
	UObject* lvlOuter = (*(UObject**)((BYTE*)this + 0x328))->GetOuter();
	UReachSpec* spec = (UReachSpec*)UObject::StaticConstructObject(
		UReachSpec::StaticClass(), lvlOuter, NAME_None, 0, NULL, GError, NULL);

	for (INT i = 0;;)
	{
		INT count = *(INT*)(*(INT*)((BYTE*)this + 0x328) + 0x34); // Level.Actors.Num()
		if (count <= i)
		{
			// LAB_103d84b9:
			ANavigationPoint::addReachSpecs(Scout, bOnlyWeightedPaths);
			return;
		}
		UObject* actor = *(UObject**)(*(INT*)(*(INT*)((BYTE*)this + 0x328) + 0x30) + i * 4);
		if (actor != NULL && actor->IsA(AWarpZoneMarker::StaticClass()) && actor != (UObject*)this)
		{
			// FName of target WarpZone at warpzoneinfo + 0x430.
			FName* otherFN = (FName*)(*(INT*)((BYTE*)actor + 1000) + 0x430);
			const TCHAR* otherZoneName = *(*otherFN);
			// FString of this WarpZone at warpzoneinfo + 0x464.
			FString* thisFStr = (FString*)(*(INT*)((BYTE*)this + 1000) + 0x464);
			INT match = (*thisFStr == otherZoneName) ? 1 : 0;
			if (match != 0 &&
				((*(DWORD*)((BYTE*)this  + 0x3a4) & 0x800) != 0 ||
				 (*(DWORD*)((BYTE*)actor + 0x3a4) & 0x800) != 0))
			{
				spec->Init();
				spec->End            = (ANavigationPoint*)actor;  // +0x4c
				spec->CollisionRadius = 0x28;                      // +0x34
				spec->CollisionHeight = 0x28;                      // +0x38
				spec->reachFlags      = 0x20;                      // +0x3c
				spec->Start           = this;                      // +0x48
				spec->Distance        = 100;                       // +0x30
				INT idx = PathList.Add();
				PathList(idx) = spec;
				// Ghidra: allocates another spec (discarded/leaked) before base call.
				UObject::StaticConstructObject(UReachSpec::StaticClass(),
					(*(UObject**)((BYTE*)this + 0x328))->GetOuter(),
					NAME_None, 0, NULL, GError, NULL);
				// goto LAB_103d84b9:
				ANavigationPoint::addReachSpecs(Scout, bOnlyWeightedPaths);
				return;
			}
		}
		i++;
	}
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x103d5f00)
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
IMPL_MATCH("Engine.dll", 0x1037CC60)
void AZoneInfo::PostEditChange()
{
	guard(AZoneInfo::PostEditChange);
	AActor::PostEditChange();
	if (*(INT*)GIsEditor)
	{
		// Ghidra: (**(code **)(**(int **)(*(int *)(this + 0x328) + 0x44) + 0x78))(0)
		// XLevel->field_0x44 (UModel* / engine object) vtable[0x78/4] called with arg 0.
		INT* model = *(INT**)(*(INT*)((BYTE*)this + 0x328) + 0x44);
		((void(__thiscall*)(void*,INT))(*(void***)model)[0x78/4])(model, 0);
		INT levelPtr = *(INT*)((BYTE*)this + 0x328);
		INT i = 0;
		while (true)
		{
			INT count = *(INT*)(levelPtr + 0x34); // Actors.Num()
			if (count <= i) break;
			AActor* A = *(AActor**)(*(INT*)(levelPtr + 0x30) + i * 4);
			if (A)
				A->UpdateRenderData();
			i++;
		}
	}
	unguard;
}


// --- FZoneProperties ---
IMPL_MATCH("Engine.dll", 0x10302ac0)
FZoneProperties::FZoneProperties(const FZoneProperties& Other)
{
	// Ghidra 0x2ac0: shares address with operator=; 18 DWORDs flat copy (no vtable)
	appMemcpy(this, &Other, 0x48);
}

IMPL_MATCH("Engine.dll", 0x10318b40)
FZoneProperties::FZoneProperties()
{
	// Ghidra 0x18b40: 53 bytes. Zeroes offsets 0x08-0x44 (16 DWORDs).
	// First 8 bytes are left untouched (written only by the copy ctor / operator=).
	appMemzero((BYTE*)this + 8, 0x40);
}

IMPL_MATCH("Engine.dll", 0x10302ac0)
FZoneProperties& FZoneProperties::operator=(const FZoneProperties& Other)
{
	// Ghidra 0x2ac0: 18 DWORDs from +0x00 (no vtable; also used as copy ctor body)
	appMemcpy(this, &Other, 0x48);
	return *this;
}

