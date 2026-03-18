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

static UBOOL RepTripleChanged(const void* NewValue, const void* OldValue)
{
	const DWORD* A = (const DWORD*)NewValue;
	const DWORD* B = (const DWORD*)OldValue;
	return A[0] != B[0] || A[1] != B[1] || A[2] != B[2];
}

static UBOOL RepObjectChanged(INT NewObj, UPackageMap* Map, UActorChannel* Chan)
{
	typedef INT (__thiscall* MapObjectFn)(UPackageMap*, INT);
	DWORD* Vtbl = *(DWORD**)Map;
	if (((MapObjectFn)Vtbl[25])(Map, NewObj) != 0)
		return 0;
	*(INT*)((BYTE*)Chan + 0x8c) = 1;
	return (NewObj != 0);
}

static UObject* FindRepProperty(UObject* Outer, const TCHAR* PropName)
{
	return UObject::StaticFindObjectChecked(UProperty::StaticClass(), Outer, PropName, 0);
}

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

IMPL_MATCH("Engine.dll", 0x10375370)
INT* APhysicsVolume::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	guard(APhysicsVolume::GetOptimizedRepList);
	static DWORD    s_RepFlags            = 0;
	static UObject* s_LocationProp        = NULL;
	static UObject* s_RotationProp        = NULL;
	static UObject* s_BaseProp            = NULL;
	static UObject* s_RelativeLocationProp = NULL;
	static UObject* s_RelativeRotationProp = NULL;
	static UObject* s_AttachmentBoneProp  = NULL;

	Ptr = AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);

	// Retail also checks APhysicsVolume::PrivateStaticClass.ClassFlags & CLASS_NativeReplication.
	// EngineClasses.h now carries that flag, so this branch reflects the retail gate.
	if (Role == ROLE_Authority &&
		((*(DWORD*)((BYTE*)this + 0xa4) & 4) != 0) &&
		((*(DWORD*)((BYTE*)this + 0xac) & 0x20) == 0))
	{
		if (RepTripleChanged((BYTE*)this + 0x234, Mem + 0x234))
		{
			if (!(s_RepFlags & 1))
			{
				s_RepFlags |= 1;
				s_LocationProp = FindRepProperty(AActor::StaticClass(), TEXT("Location"));
			}
			*Ptr++ = *(unsigned short*)((BYTE*)s_LocationProp + 0x4a);
		}

		if (RepTripleChanged((BYTE*)this + 0x240, Mem + 0x240))
		{
			if (!(s_RepFlags & 2))
			{
				s_RepFlags |= 2;
				s_RotationProp = FindRepProperty(AActor::StaticClass(), TEXT("Rotation"));
			}
			*Ptr++ = *(unsigned short*)((BYTE*)s_RotationProp + 0x4a);
		}

		if (RepObjectChanged(*(INT*)((BYTE*)this + 0x15c), Map, Chan))
		{
			if (!(s_RepFlags & 4))
			{
				s_RepFlags |= 4;
				s_BaseProp = FindRepProperty(AActor::StaticClass(), TEXT("Base"));
			}
			*Ptr++ = *(unsigned short*)((BYTE*)s_BaseProp + 0x4a);
		}

		if (*(INT*)((BYTE*)this + 0x15c) != 0 &&
			((*(DWORD*)(*(INT*)((BYTE*)this + 0x15c) + 0xa0) & 0x100000) == 0))
		{
			if (RepTripleChanged((BYTE*)this + 0x264, Mem + 0x264))
			{
				if (!(s_RepFlags & 8))
				{
					s_RepFlags |= 8;
					s_RelativeLocationProp = FindRepProperty(AActor::StaticClass(), TEXT("RelativeLocation"));
				}
				*Ptr++ = *(unsigned short*)((BYTE*)s_RelativeLocationProp + 0x4a);
			}

			if (RepTripleChanged((BYTE*)this + 0x270, Mem + 0x270))
			{
				if (!(s_RepFlags & 0x10))
				{
					s_RepFlags |= 0x10;
					s_RelativeRotationProp = FindRepProperty(AActor::StaticClass(), TEXT("RelativeRotation"));
				}
				*Ptr++ = *(unsigned short*)((BYTE*)s_RelativeRotationProp + 0x4a);
			}

			if (*(INT*)((BYTE*)this + 0x1b0) != *(INT*)(Mem + 0x1b0))
			{
				if (!(s_RepFlags & 0x20))
				{
					s_RepFlags |= 0x20;
					s_AttachmentBoneProp = FindRepProperty(AActor::StaticClass(), TEXT("AttachmentBone"));
				}
				*Ptr++ = *(unsigned short*)((BYTE*)s_AttachmentBoneProp + 0x4a);
			}
		}
	}

	return Ptr;
	unguard;
}


// --- AVolume ---
IMPL_EMPTY("Retail shares the 0x104651d0 no-op stub with AActor::AddMyMarker and other empty helpers")
void AVolume::SetVolumes(TArray<AVolume *> const &)
{
}

IMPL_EMPTY("Retail shares the 0x10476d60 no-op stub with AActor::PostBeginPlay and AKConstraint::postKarmaStep")
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

IMPL_MATCH("Engine.dll", 0x10475ab0)
void AVolume::PostBeginPlay()
{
	guard(AVolume::PostBeginPlay);
	// Retail 0x10475ab0 (886b): spawns ADecoVolumeObject instances inside the
	// volume brush's world-space bounds, using per-entry FRanges for count and
	// draw scale, then calls ToFloor to ground each actor.
	// vtable[0x6c] on Brush == GetRenderBoundingBox  (UPrimitive slot 27)
	// vtable[0xac] on this  == LocalToWorld (AActor; actual slot may differ from
	//                           SDK header but named virtual is equivalent here)
	// vtable[0xa0] on XLevel == DestroyActor (ULevel slot 40)
	// vtable[0xa8] on XLevel == SpawnActor   (ULevel slot 42)
	// FUN_1050557c == appRound (x87 float->int conversion helper)

	postKarmaStep();

	if (*(INT*)((BYTE*)this + 0x3f8) != 0)
	{
		// Get brush local bounds and transform both corners to world space.
		UPrimitive* brush = *(UPrimitive**)((BYTE*)this + 0x178);
		FBox   localBox   = brush->GetRenderBoundingBox(this);
		FMatrix ltw1      = LocalToWorld();
		FVector worldMin  = ltw1.TransformFVector(localBox.Min);
		FMatrix ltw2      = LocalToWorld();
		FVector worldMax  = ltw2.TransformFVector(localBox.Max);
		FBox    worldBox(worldMin, worldMax);
		FVector half = worldBox.GetExtent(); // half-extents

		// Iterate deco-spec entries at pDecoObj+0x394.
		// Each entry is 0x24 bytes:
		//   [+0x00] = reserved 4 bytes  (actor field init at actor+0x170)
		//   [+0x04] = FRange  count     (spawn count range)
		//   [+0x0c] = FRange  scale     (draw scale range)
		//   [+0x14] = INT     bToFloor  (bTest arg for ToFloor)
		//   [+0x18] = INT     bRandYaw
		//   [+0x1c] = INT     bRandPitch
		//   [+0x20] = INT     bRandRoll
		FArray* specArr   = (FArray*)((BYTE*)*(INT*)((BYTE*)this + 0x3f8) + 0x394);
		INT     numSpecs  = specArr->Num();
		for (INT i = 0; i < numSpecs; i++)
		{
			INT* entry        = (INT*)((BYTE*)specArr->GetData() + i * 0x24);
			FRange countRange = *(FRange*)(entry + 1);
			INT    count      = appRound(countRange.GetRand());

			for (INT j = 0; j < count; j++)
			{
				// Random local-space offset clamped to brush half-extents.
				FLOAT dx = FRange(-half.X, half.X).GetRand();
				FLOAT dy = FRange(-half.Y, half.Y).GetRand();
				FLOAT dz = FRange(-half.Z, half.Z).GetRand();

				// Transform random offset to world space.
				// Ghidra ordering: local_2c=dz, local_28=dx, local_24=dy
				FMatrix ltw3     = LocalToWorld();
				FVector spawnPos = ltw3.TransformFVector(FVector(dz, dx, dy));

				// Spawn via XLevel->SpawnActor.
				AActor* actor = XLevel->SpawnActor(
					ADecoVolumeObject::StaticClass(),
					NAME_None, spawnPos, FRotator(0,0,0));

				if ((actor == NULL) ||
					(actor->IsA(ADecoVolumeObject::StaticClass()) == 0))
				{
					continue;
				}

				// Copy first dword of entry into actor+0x170.
				*(INT*)((BYTE*)actor + 0x170) = *entry;

				// Drop to floor; on failure destroy and continue.
				if (XLevel->ToFloor(actor, entry[5], this))
				{
					if (entry[6] != 0)
					{
						DWORD uVar7 = (DWORD)appRand() & 0x8000ffff;
						if ((INT)uVar7 < 0)
							uVar7 = (uVar7 - 1 | 0xffff0000) + 1;
						*(DWORD*)((BYTE*)actor + 0x240) += uVar7;
					}
					if (entry[7] != 0)
					{
						DWORD uVar7 = (DWORD)appRand() & 0x8000ffff;
						if ((INT)uVar7 < 0)
							uVar7 = (uVar7 - 1 | 0xffff0000) + 1;
						*(DWORD*)((BYTE*)actor + 0x244) += uVar7;
					}
					if (entry[8] != 0)
					{
						DWORD uVar7 = (DWORD)appRand() & 0x8000ffff;
						if ((INT)uVar7 < 0)
							uVar7 = (uVar7 - 1 | 0xffff0000) + 1;
						*(DWORD*)((BYTE*)actor + 0x248) += uVar7;
					}
					FRange* scaleRange = (FRange*)(entry + 3);
					if (!scaleRange->IsZero())
						actor->SetDrawScale(scaleRange->GetRand());
				}
				else
				{
					XLevel->DestroyActor(actor, 0); // vtable[0xa0]
				}
			}
		}
	}
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
IMPL_MATCH("Engine.dll", 0x103e12c0)
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
				// Ghidra: XLevel->vtable[0x9c/4] unnamed no-arg error-path dispatch.
				// Matching retail via the raw slot call until the virtual is named.
				void* XLev = *(void**)((BYTE*)this + 0x328);
				((void(__thiscall*)(void*))(*(void***)XLev)[0x9c/4])(XLev);
			}
			Scout->SetCollisionSize(40.0f, Scout->CollisionHeight);
		}

		// Find the WarpZoneMarker class and spawn one at the scout's position.
		UClass* WZMClass = (UClass*)UObject::StaticFindObjectChecked(
			UClass::StaticClass(), (UObject*)-1, TEXT("WarpZoneMarker"), 0);
		// Ghidra: Level->vtable[0xa8/4] = SpawnActor(WZMClass, NAME_None, Scout->Location, FRotator(0,0,0)).
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

