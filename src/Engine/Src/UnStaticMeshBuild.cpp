/*=============================================================================
	UnStaticMeshBuild.cpp: Static mesh objects (UStaticMesh, UStaticMeshInstance)
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

// Defined in UnCamera.cpp; no header declaration available.
ENGINE_API FArchive& operator<<(FArchive& Ar, FRawColorStream& V);

// --- UStaticMesh ---
IMPL_DIVERGE("Ghidra 0x10446A90: registers 3 UBoolProperty + 1 UArrayProperty<FStaticMeshMaterial> via UProperty ctor calls; UProperty reflection infrastructure not yet decompiled")
void UStaticMesh::StaticConstructor()
{
	guard(UStaticMesh::StaticConstructor);
	// Retail: registers UseSimpleLineCollision (+0x128), UseSimpleBoxCollision (+0x2BC),
	// UseVertexColor (+0x130) as UBoolProperty, and Materials as UArrayProperty<UStaticMeshMaterial>.
	// All require UBoolProperty::UBoolProperty / UObjectProperty::UObjectProperty ctors
	// which are not yet decompiled.
	unguard;
}

IMPL_EMPTY("editor-only: rebuilds mesh collision/render data on property change")
void UStaticMesh::PostEditChange()
{
	guard(UStaticMesh::PostEditChange);
	// Retail: rebuilds the static mesh collision/render data.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}

IMPL_DIVERGE("Ghidra 0x104472F0: calls UObject::PostLoad then fixes triangle normals via TArray<FStaticMeshTriangle> at +0x58 using TArray::operator()(index) vtable calls; unresolved vtable dispatch")
void UStaticMesh::PostLoad()
{
	guard(UStaticMesh::PostLoad);
	UObject::PostLoad();
	// Retail (1401b): iterates Materials TArray at +0x58 (stride 0x14) when this+0x150 == -1,
	// fixing up UMaterial references and rebuilding render/collision structures.
	// DIVERGENCE: unresolved vtable[29] and FUN_ calls block full reconstruction.
	unguard;
}

// (merged from earlier occurrence)
IMPL_DIVERGE("Ghidra 0x1044CDA0: OPCODE BVH traversal (1017b) — FUN_104487d0/FUN_10448ba0 (BVH node test/traverse) unresolved; collision tree not yet decompiled")
void UStaticMesh::TriangleSphereQuery(AActor *,FSphere &,TArray<FStaticMeshCollisionTriangle *> &)
{
	guard(UStaticMesh::TriangleSphereQuery);
	// Retail: uses Actor->WorldToLocal() to transform sphere, then traverses the OPCODE
	// collision BVH tree at this+0x124, collecting triangles that overlap the sphere.
	// DIVERGENCE: BVH traversal helpers (FUN_104487d0, FUN_10448ba0) are unresolved.
	unguard;
}
IMPL_EMPTY("editor tool: builds static mesh geometry and collision data")
void UStaticMesh::Build()
{
	guard(UStaticMesh::Build);
	// Retail: builds geometry/collision data for the static mesh.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}
IMPL_DIVERGE("Ghidra 0x1031C9F0: FUN_10317670 (UMaterial CDO lookup via USubsystem chain) unresolved; fallback default material cannot be returned")
UMaterial * UStaticMesh::GetSkin(AActor* Owner, int SkinIndex)
{
	// Ghidra 0x1c9f0 (69b): calls Owner->GetSkin(SkinIndex) via vtable[0xa0/4=40].
	// If NULL, falls back to Materials TArray at this+0xfc (stride 0x0c; UMaterial* at +0).
	// If still NULL: FUN_10317670 fetches the default UMaterial from USubsystem chain.
	typedef UMaterial* (__thiscall* GetSkinFn)(AActor*, INT);
	UMaterial* pSkin = ((GetSkinFn)(*(INT*)(*(INT*)Owner + 0xa0)))(Owner, SkinIndex);
	if (pSkin == NULL)
	{
		BYTE* materialsData = (BYTE*)*(INT*)((BYTE*)this + 0xfc);
		if (materialsData != NULL)
			pSkin = *(UMaterial**)(materialsData + SkinIndex * 0x0c);
	}
	// DIVERGENCE: FUN_10317670 (default UMaterial CDO path) is unresolved; returns NULL.
	return pSkin;
}
IMPL_MATCH("Engine.dll", 0x104478b0)
FTags * UStaticMesh::GetTag(FString Name)
{
	guard(UStaticMesh::GetTag);
	// Ghidra 0x1478b0, 85b: linear search of TArray<FTags> at this+0x17c (stride 0x3c).
	// Each FTags entry has FString TagString at +0x30. Returns pointer to entry or NULL.
	FArray* tagArr = (FArray*)((BYTE*)this + 0x17c);
	INT n = tagArr->Num();
	for (INT i = 0; i < n; i++)
	{
		BYTE* entry = (BYTE*)*(INT*)tagArr + i * 0x3c;
		if (*(FString*)(entry + 0x30) == Name)
			return (FTags*)entry;
	}
	return NULL;
	unguard;
}
IMPL_DIVERGE("Ghidra 0x10449DE0: FUN_10449c90 (triangle stream serializer), FUN_10301400 (bbox rebuild) unresolved; geometry arrays not fully serialized")
void UStaticMesh::Serialize(FArchive& Ar)
{
	// Ghidra 0x149de0 (970b): version-conditional UPrimitive::Serialize base call,
	// then serializes geometry arrays (triangle data at +0x58, render bounds at +0x2C,
	// materials at +0x1C4, FTags at +0x17c, etc.) via FUN_10449c90 and FUN_10449c50.
	// DIVERGENCE: geometry serialize helpers are unresolved; loads base-class fields only.
	if (Ar.Ver() < 0x55)
		UObject::Serialize(Ar);
	else
		UPrimitive::Serialize(Ar);
}
IMPL_DIVERGE("Ghidra 0x1044EB60: OPCODE BVH ray-triangle traversal (931b) — FUN_104487d0/FUN_10448ba0 (BVH test/traverse) unresolved; returns no-hit")
int UStaticMesh::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	guard(UStaticMesh::LineCheck);
	// Retail: transforms ray to local space, traverses OPCODE BVH collision tree at +0x124,
	// tests each leaf triangle with ray-plane intersection, fills FCheckResult on hit.
	// DIVERGENCE: BVH helpers (FUN_104487d0, FUN_10448ba0) are unresolved.
	return 1; // no hit
	unguard;
}
IMPL_DIVERGE("Ghidra 0x1044EF40: OPCODE BVH point-overlap test (403b) — same FUN_ blockers as LineCheck; returns no-overlap")
int UStaticMesh::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	guard(UStaticMesh::PointCheck);
	// Retail: transforms point+extent to local space, traverses OPCODE BVH tree at +0x124,
	// tests each leaf triangle for overlap with the swept sphere.
	// DIVERGENCE: BVH helpers (FUN_104487d0, FUN_10448ba0) are unresolved.
	return 1; // no overlap
	unguard;
}
IMPL_MATCH("Engine.dll", 0x104469d0)
void UStaticMesh::Destroy()
{
	// Retail: 0x104469d0.Calls FUN_103582d0(this) to release the static mesh collision
	// node tree and triangle arrays at this+0x164. Then calls UObject::Destroy.
	typedef void (__cdecl *FreeMeshFn)(UStaticMesh*);
	((FreeMeshFn)0x103582d0)(this);
	UObject::Destroy();
}
IMPL_DIVERGE("Ghidra 0x1044c130: vtable[29] (this+0x120) = model bbox merge — thiscall target not identified; model bbox omitted")
FBox UStaticMesh::GetCollisionBoundingBox(const AActor* Actor) const
{
	// Ghidra 0x144c130 (267b): if actor flag [this+0xA8] & 0x400000 == 0,
	// transforms mesh bbox (this+0x2c) by Actor->LocalToWorld().
	// Then if (this+0x120 != NULL), calls vtable[29](Actor) to merge in model bbox.
	// DIVERGENCE: vtable[29] target (FUN_1044c0a0 / UModel::GetCollisionBoundingBox?)
	// not yet identified — model bbox merge omitted.
	if (Actor && !(((const DWORD*)Actor)[0x2a] & 0x400000))
		return (*(const FBox*)((const BYTE*)this + 0x2c)).TransformBy(Actor->LocalToWorld());
	return UPrimitive::GetCollisionBoundingBox(Actor);
}
IMPL_MATCH("Engine.dll", 0x1046ccb0)
FVector UStaticMesh::GetEncroachCenter(AActor * Actor)
{
	// Ghidra 0x16ccb0: calls vtable[0x74/4]=GetCollisionBoundingBox(Actor), then FBox::GetCenter()
	// shares address with UModel::GetEncroachCenter and UProjectorPrimitive::GetEncroachCenter
	return GetCollisionBoundingBox(Actor).GetCenter();
}
IMPL_MATCH("Engine.dll", 0x10304990)
FVector UStaticMesh::GetEncroachExtent(AActor * Actor)
{
	// Ghidra 0x4990: calls vtable[0x74/4]=GetCollisionBoundingBox(Actor), then FBox::GetExtent()
	// shares address with UModel::GetEncroachExtent and UProjectorPrimitive::GetEncroachExtent
	return GetCollisionBoundingBox(Actor).GetExtent();
}
IMPL_MATCH("Engine.dll", 0x10146a50)
FBox UStaticMesh::GetRenderBoundingBox(const AActor*)
{
	// Ghidra 0x146a50: REP MOVSD 7 DWORDs (28 bytes = FBox) from this+0x2C
	// shares address with UModel::GetRenderBoundingBox
	return *(FBox*)((BYTE*)this + 0x2C);
}
IMPL_MATCH("Engine.dll", 0x10446a70)
FSphere UStaticMesh::GetRenderBoundingSphere(const AActor*)
{
	// Retail: 23b. Copy-constructs FSphere from this+0x48.
	return *(FSphere*)((BYTE*)this + 0x48);
}
IMPL_EMPTY("editor tool: computes per-vertex lighting bake for static mesh")
void UStaticMesh::Illuminate(AActor *,int)
{
	guard(UStaticMesh::Illuminate);
	// Retail: computes per-vertex lighting for the static mesh.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}


// --- UStaticMeshInstance ---
IMPL_DIVERGE("Ghidra 0x10449BB0: FUN_10449a90 (legacy color stream, Ver<0x70) and FUN_10448de0 (index buffer, Ver>0x6D) unresolved")
void UStaticMeshInstance::Serialize(FArchive &Ar)
{
	guard(UStaticMeshInstance::Serialize);
	UObject::Serialize(Ar);
	// Ghidra (163b): Ver < 0x70 → legacy format via FUN_10449a90 (unresolved).
	// Ver >= 0x70 → serialize FRawColorStream at this+0x38.
	if (Ar.Ver() >= 0x70)
		Ar << *(FRawColorStream*)((BYTE*)this + 0x38);
	// Ghidra: Ver > 0x6D (i.e. >= 0x6E) → index buffer at this+0x2C via FUN_10448de0 (unresolved).
	unguard;
}

IMPL_DIVERGE("Ghidra 0x10446b40: full projector triangle-clipping loop — FUN_10449ee0 (clip triangle), FUN_10448ca0 (OPCODE BVH gather) unresolved")
void UStaticMeshInstance::AttachProjectorClipped(AActor *,AProjector *)
{
	guard(UStaticMeshInstance::AttachProjectorClipped);
	// Retail: gathers triangles from the OPCODE BVH that intersect the projector frustum,
	// clips each against 6 frustum planes, builds an index buffer, and appends to per-instance
	// projector list at this+0x54. FUN_10449ee0 (clip) and FUN_10448ca0 (BVH gather) unresolved.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10448470)
void UStaticMeshInstance::DetachProjectorClipped(AProjector* param_1)
{
	guard(UStaticMeshInstance::DetachProjectorClipped);
	// Ghidra 0x148470: search per-instance projector list (FArray at this+0x54, stride 0x28)
	// for element matching param_1's render info pointer, then remove and clean up.
	FArray* projArr = (FArray*)((BYTE*)this + 0x54);
	INT count = projArr->Num();
	if (count > 0)
	{
		INT idx = 0;
		INT offset = 0;
		INT projId = *(INT*)((BYTE*)param_1 + 0x48c);
		while (*(INT*)(offset + *(INT*)projArr) != projId)
		{
			idx++;
			offset += 0x28;
			if (projArr->Num() <= idx)
				return;
		}
		FRawIndexBuffer* rib = *(FRawIndexBuffer**)(idx * 0x28 + 4 + *(INT*)projArr);
		if (rib != NULL)
		{
			rib->~FRawIndexBuffer();
			GMalloc->Free(rib);
			*(DWORD*)(idx * 0x28 + 4 + *(INT*)projArr) = 0;
		}
		INT* refCount = *(INT**)((BYTE*)param_1 + 0x48c);
		*refCount -= 1;
		if (*refCount == 0)
		{
			// FUN_103719b0: cleanup/dtor for the render info block (same as in AProjector::Detach)
			typedef void (__cdecl* CleanupFn)();
			((CleanupFn)0x103719b0)();
			GMalloc->Free(refCount);
		}
		// FUN_1031fda0: FArray::Remove(index, count, stride=0x28) — removes entry from list
		typedef void (__thiscall* RemoveFn)(FArray*, INT, INT, INT);
		((RemoveFn)0x1031fda0)(projArr, idx, 1, 0x28);
	}
	unguard;
}

// --- FOrientation ---
IMPL_MATCH("Engine.dll", 0x103019d0)
FOrientation::FOrientation()
{
	*(INT*)&_Data[0x00] = 2;
	*(INT*)&_Data[0x04] = 0;
	*(INT*)&_Data[0x08] = 0;
	*(INT*)&_Data[0x0C] = 0;
	*(INT*)&_Data[0x10] = 0;
	*(INT*)&_Data[0x14] = 0;
	*(INT*)&_Data[0x18] = 0;
	*(FRotator*)&_Data[0x28] = FRotator(0,0,0);
}

IMPL_DIVERGE("Ghidra 0x10301a00: value-type ABI (13 DWORD params) differs from our appMemcpy; VA confirmed")
FOrientation& FOrientation::operator=(FOrientation Other)
{
	// Ghidra 0x1a00: struct passed by value (13 DWORD params on stack), each copied to this+offset.
	// Our appMemcpy achieves the same result but with different byte pattern.
	appMemcpy(this, &Other, 0x34);
	return *this;
}

IMPL_MATCH("Engine.dll", 0x10301a70)
int FOrientation::operator!=(FOrientation const & Other) const
{
	// Ghidra 0x1a70: return (uint)(*(int*)(this+0x18) != *(int*)(param_1+0x18))
	return *(INT*)&_Data[0x18] != *(INT*)&Other._Data[0x18];
}


// --- FRebuildOptions ---
IMPL_MATCH("Engine.dll", 0x10301cf0)
FRebuildOptions::FRebuildOptions(FRebuildOptions const & Other)
	: Name(Other.Name)
{
	appMemcpy(Options, Other.Options, sizeof(Options));
}

IMPL_MATCH("Engine.dll", 0x10301cf0)
FRebuildOptions::FRebuildOptions()
{
	Options[0] = 2;    // 0x0C
	Options[1] = 79;   // 0x10
	Options[2] = 15;   // 0x14
	Options[3] = 70;   // 0x18
	Options[4] = 7;    // 0x1C
	Options[5] = 0;    // 0x20
	Options[6] = 0;    // 0x24
	Options[7] = 1;    // 0x28
	Name = TEXT("Default");
}

IMPL_EMPTY("FString member destructor handles cleanup automatically")
FRebuildOptions::~FRebuildOptions()
{
	// Name's implicit destructor handles FString cleanup
}

IMPL_DIVERGE("Ghidra 0x103188d0: value-type 213b with SEH frame; VA confirmed, return-by-value ABI differs")
FRebuildOptions FRebuildOptions::operator=(FRebuildOptions Other)
{
	// Ghidra 0x188d0: copies Name FString, then 8 Option DWORDs at +0xC..+0x28, returns copy.
	Name = Other.Name;
	appMemcpy(Options, Other.Options, sizeof(Options));
	return *this;
}

IMPL_MATCH("Engine.dll", 0x10301cd0)
FString FRebuildOptions::GetName()
{
	return Name;
}

IMPL_MATCH("Engine.dll", 0x103fd220)
void FRebuildOptions::Init()
{
	Options[0] = 2;
	Options[1] = 79;
	Options[2] = 15;
	Options[3] = 70;
	Options[4] = 7;
	Options[5] = 0;
	Options[6] = 0;
	Options[7] = 1;
}


// --- FTags ---
IMPL_MATCH("Engine.dll", 0x10302ed0)
FTags::FTags(FTags const &Other)
{
	// Ghidra 0x2ed0:bitwise copy of first 0x30 bytes (TArrays here are shallow/borrowed), then FString copy at +0x30
	appMemcpy(this, &Other, 0x30);
	new ((BYTE*)this + 0x30) FString(*(const FString*)((const BYTE*)&Other + 0x30));
}

IMPL_MATCH("Engine.dll", 0x10302ea0)
FTags::FTags()
{
	// Zero first 0x30 bytes;initialize owned FString at +0x30 to empty
	appMemzero(this, 0x30);
	new ((BYTE*)this + 0x30) FString();
}

IMPL_MATCH("Engine.dll", 0x10302ec0)
FTags::~FTags()
{
	// Ghidra 0x10302ec0:only ~FString at +0x30; TArrays in first 0x30 bytes are not destructed (shallow/borrowed)
	((FString*)((BYTE*)this + 0x30))->~FString();
}

IMPL_MATCH("Engine.dll", 0x10302f00)
FTags& FTags::operator=(const FTags& Other)
{
	// Ghidra 0x2f00:12 DWORDs at +0..+2F (no vtable), then FString at +0x30
	appMemcpy(this, &Other, 0x30);
	*(FString*)((BYTE*)this + 0x30) = *(const FString*)((const BYTE*)&Other + 0x30);
	return *this;
}

IMPL_MATCH("Engine.dll", 0x10302e20)
void FTags::Init()
{
	guard(FTags::Init);
	*(FString*)((BYTE*)this + 0x30) = FString(TEXT("")); // Ghidra: FString at +0x30 = empty
	unguard;
}



// ============================================================================
// FRebuildTools implementations
// (moved from EngineStubs.cpp)
// ============================================================================

// ?GetCurrent@FRebuildTools@@QAEPAVFRebuildOptions@@XZ
IMPL_MATCH("Engine.dll", 0x10301d40)
FRebuildOptions * FRebuildTools::GetCurrent() {
	// Ghidra 0x1d40: return *(ulong*)this (first DWORD = current options ptr)
	// shares address with FColor::operator unsigned long and FColor::TrueColor
	return *(FRebuildOptions**)this;
}

// ?GetFromName@FRebuildTools@@QAEPAVFRebuildOptions@@VFString@@@Z
IMPL_MATCH("Engine.dll", 0x103fd460)
FRebuildOptions * FRebuildTools::GetFromName(FString p0)
{
	FRebuildOptions* data = *(FRebuildOptions**)((BYTE*)this + 4);
	INT count = *(INT*)((BYTE*)this + 8);
	for (INT i = 0; i < count; i++)
	{
		FRebuildOptions* opt = (FRebuildOptions*)((BYTE*)data + i * 0x2C);
		if (opt->Name == p0)
			return opt;
	}
	return NULL;
}

// ?Save@FRebuildTools@@QAEPAVFRebuildOptions@@VFString@@@Z
IMPL_DIVERGE("Ghidra 0x103FD770: uses FArray::Add (realloc strategy differs) and value-copy of current options via operator=; FArray::Add address not resolved")
FRebuildOptions * FRebuildTools::Save(FString p0)
{
	guard(FRebuildTools::Save);

	FRebuildOptions* result = GetFromName(p0);
	if (!result)
	{
		// Grow the FArray at this+4 by one element
		void*& pData   = *(void**)((BYTE*)this + 4);
		INT&   count   = *(INT*)((BYTE*)this + 8);
		INT&   maxCount= *(INT*)((BYTE*)this + 12);

		INT idx = count;
		if (count >= maxCount)
		{
			INT newMax = (count * 4) / 3 + 8;
			pData = appRealloc(pData, newMax * 0x2C, TEXT("TArray"));
			maxCount = newMax;
		}
		result = (FRebuildOptions*)((BYTE*)pData + idx * 0x2C);
		new(result) FRebuildOptions();
		count++;
		// Re-read in case appRealloc moved the pointer
		result = (FRebuildOptions*)((BYTE*)pData + (count - 1) * 0x2C);
	}

	// Copy current options then override name with p0 (matches retail logic)
	FRebuildOptions* cur = GetCurrent();
	if (cur && result)
	{
		result->Name = cur->Name;
		appMemcpy(result->Options, cur->Options, sizeof(result->Options));
	}
	result->Name = p0;
	return result;
	unguard;
}

// --- Moved from EngineStubs.cpp ---
extern ENGINE_API FRebuildTools GRebuildTools;

// ?GetIdxFromName@FRebuildTools@@QAEHVFString@@@Z
// Ghidra: same array walk as GetFromName; returns index or -1 (NOT 0 — 0 is a valid index).
IMPL_MATCH("Engine.dll", 0x103fd560)
int FRebuildTools::GetIdxFromName(FString p0)
{
	FRebuildOptions* data = *(FRebuildOptions**)((BYTE*)this + 4);
	INT count = *(INT*)((BYTE*)this + 8);
	for (INT i = 0; i < count; i++)
	{
		FRebuildOptions* opt = (FRebuildOptions*)((BYTE*)data + i * 0x2C);
		if (opt->Name == p0)
			return i;
	}
	return -1;
}
// ?Delete@FRebuildTools@@QAEXVFString@@@Z
IMPL_EMPTY("editor tool: deletes named rebuild option")
void FRebuildTools::Delete(FString p0) {}

// ?Init@FRebuildTools@@QAEXXZ
IMPL_EMPTY("editor tool: initializes rebuild tools data")
void FRebuildTools::Init() {}

// ?SetCurrent@FRebuildTools@@QAEXVFString@@@Z
IMPL_EMPTY("editor tool: sets current rebuild option by name")
void FRebuildTools::SetCurrent(FString p0) {}

// ?Shutdown@FRebuildTools@@QAEXXZ
IMPL_EMPTY("editor tool: shuts down rebuild tools")
void FRebuildTools::Shutdown() {}
IMPL_MATCH("Engine.dll", 0x10316200)
INT FStaticMeshColorStream::GetComponents(FVertexComponent* C) {
	C[0].Type = 4; C[0].Function = 3;
	return 1;
}
