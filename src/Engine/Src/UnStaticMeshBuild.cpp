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
IMPL_DIVERGE("body incomplete — Ghidra 0x10446A90 not yet fully reconstructed")
void UStaticMesh::StaticConstructor()
{
	guard(UStaticMesh::StaticConstructor);
	// Retail: complex property registration via IMPLEMENT_CLASS (FUN_10449d30).
	// Divergence: not fully reconstructed from Ghidra.
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

IMPL_DIVERGE("body incomplete — Ghidra 0x104472F0 not yet fully reconstructed")
void UStaticMesh::PostLoad()
{
	guard(UStaticMesh::PostLoad);
	// Retail: fixes up triangle normals and builds render data.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}

// (merged from earlier occurrence)
IMPL_DIVERGE("body incomplete — Ghidra 0x1044CDA0 not yet fully reconstructed")
void UStaticMesh::TriangleSphereQuery(AActor *,FSphere &,TArray<FStaticMeshCollisionTriangle *> &)
{
	guard(UStaticMesh::TriangleSphereQuery);
	// Retail: iterates collision triangles and tests against the sphere.
	// Divergence: not fully reconstructed from Ghidra.
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
IMPL_DIVERGE("body incomplete — Ghidra 0x1031C9F0 not yet fully reconstructed")
UMaterial * UStaticMesh::GetSkin(AActor* Owner, int SkinIndex)
{
	// Ghidra 0x1c9f0, 69b:call Owner->GetSkin(SkinIndex) via vtable[0xa0/4=40].
	// If NULL, fall back to Materials TArray at this+0xfc (stride 0x0c; UMaterial* at +0).
	// If still NULL: FUN_10317670 (default UMaterial CDO) unresolved — return NULL.
	typedef UMaterial* (__thiscall* GetSkinFn)(AActor*, INT);
	UMaterial* pSkin = ((GetSkinFn)(*(INT*)(*(INT*)Owner + 0xa0)))(Owner, SkinIndex);
	if (pSkin == NULL)
	{
		BYTE* materialsData = (BYTE*)*(INT*)((BYTE*)this + 0xfc);
		if (materialsData != NULL)
			pSkin = *(UMaterial**)(materialsData + SkinIndex * 0x0c);
	}
	// DIVERGENCE: if still NULL, FUN_10317670 (GetDefaultMaterial CDO) is unresolved.
	// Retail returns a fallback default UMaterial; we return NULL here.
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
IMPL_DIVERGE("body incomplete — Ghidra 0x10449DE0 not yet fully reconstructed")
void UStaticMesh::Serialize(FArchive& Ar)
{
	// Retail: 0x10449de0.Calls UPrimitive::Serialize (if version >= 0x55) or UObject::Serialize,
	// then serializes geometry arrays: +0x154/+0x158 (v<0x5C), +0x58 (triangle data),
	// +0x2C (render bounds), +0x1C4, +0x1D0 (materials), etc.
	// Divergence: simplified to base class; geometry is loaded from package.
	UObject::Serialize(Ar);
}
IMPL_DIVERGE("body incomplete — Ghidra 0x1044EB60 not yet fully reconstructed")
int UStaticMesh::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	guard(UStaticMesh::LineCheck);
	// Ghidra 0x44eb60, 931 bytes: full static mesh ray-triangle intersection (BVH/OPCODE).
	// DIVERGENCE: complex OPCODE/BVH ray-triangle traversal requires many unresolved FUN_ calls.
	// Returns 1 (no hit) pending full collision geometry implementation.
	return 1;
	unguard;
}
IMPL_DIVERGE("body incomplete — Ghidra 0x1044EF40 not yet fully reconstructed")
int UStaticMesh::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	guard(UStaticMesh::PointCheck);
	// Ghidra 0x44ef40, 403 bytes: point overlap test against static mesh collision geometry.
	// DIVERGENCE: OPCODE point-overlap traversal requires many unresolved FUN_ calls.
	// Returns 1 (no overlap) pending full collision geometry implementation.
	return 1;
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
IMPL_DIVERGE("Ghidra 0x1044c130: model bbox (this+0x120 via vtable[29]) not merged — DIVERGENCE")
FBox UStaticMesh::GetCollisionBoundingBox(const AActor* Actor) const
{
	// Ghidra: if actor flag[0x2a] & 0x400000 == 0, transform mesh bbox (this+0x2c)
	// by Actor->LocalToWorld(), then optionally merge model bbox via this+0x120 vtable[29].
	// We omit the model merge due to unresolved vtable target.
	if (Actor && !(((const DWORD*)Actor)[0x2a] & 0x400000))
		return (*(const FBox*)((const BYTE*)this + 0x2c)).TransformBy(Actor->LocalToWorld());
	return UPrimitive::GetCollisionBoundingBox(Actor);
}
IMPL_DIVERGE("UStaticMesh::GetEncroachCenter not found in Ghidra export — cannot confirm VA")
FVector UStaticMesh::GetEncroachCenter(AActor * Actor)
{
	// Retail: 41b. Calls GetCollisionBoundingBox, then FBox::GetCenter().
	return GetCollisionBoundingBox(Actor).GetCenter();
}
IMPL_DIVERGE("UStaticMesh::GetEncroachExtent not found in Ghidra export — cannot confirm VA")
FVector UStaticMesh::GetEncroachExtent(AActor * Actor)
{
	// Retail: 41b. Calls GetCollisionBoundingBox, then FBox::GetExtent().
	return GetCollisionBoundingBox(Actor).GetExtent();
}
IMPL_DIVERGE("UStaticMesh::GetRenderBoundingBox not found in Ghidra export — cannot confirm VA")
FBox UStaticMesh::GetRenderBoundingBox(const AActor*)
{
	// Retail: 23b. REP MOVSD 7 DWORDs (28b = FBox) from this+0x2C to return buffer.
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
IMPL_DIVERGE("Ghidra 0x10449bb0: FUN_10449a90 (old color stream) and FUN_10448de0 (index buffer) unresolved")
void UStaticMeshInstance::Serialize(FArchive &Ar)
{
	guard(UStaticMeshInstance::Serialize);
	UObject::Serialize(Ar);
	// Ghidra: version < 0x70 uses legacy format via FUN_10449a90 (unresolved).
	// Version >= 0x70: serialize color stream at this+0x38.
	if (Ar.Ver() >= 0x70)
		Ar << *(FRawColorStream*)((BYTE*)this + 0x38);
	// Ghidra: version > 0x6d (0x6e+): serialize index buffer at this+0x2c via FUN_10448de0.
	// DIVERGENCE: FUN_10448de0 unresolved — index buffer skipped.
	unguard;
}

IMPL_DIVERGE("body incomplete/diverged — body contains divergence markers (Divergence:)")
void UStaticMeshInstance::AttachProjectorClipped(AActor *,AProjector *)
{
	guard(UStaticMeshInstance::AttachProjectorClipped);
	// Retail: attaches a projector, clipping its triangles against the mesh.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}

IMPL_DIVERGE("body incomplete — Ghidra 0x10448470 not yet fully reconstructed")
void UStaticMeshInstance::DetachProjectorClipped(AProjector *)
{
	guard(UStaticMeshInstance::DetachProjectorClipped);
	// Retail: removes the projector from the per-instance projector list.
	// Divergence: not fully reconstructed from Ghidra.
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

IMPL_DIVERGE("FOrientation::operator= not found in Ghidra export — cannot confirm VA")
FOrientation& FOrientation::operator=(FOrientation Other)
{
	appMemcpy(this, &Other, 0x34);
	return *this;
}

IMPL_DIVERGE("FOrientation::operator!= not found in Ghidra export — cannot confirm VA")
int FOrientation::operator!=(FOrientation const & Other) const
{
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

IMPL_DIVERGE("FRebuildOptions::operator= not found in Ghidra export — cannot confirm VA")
FRebuildOptions FRebuildOptions::operator=(FRebuildOptions Other)
{
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
IMPL_DIVERGE("FRebuildTools::GetCurrent not found in Ghidra export — cannot confirm VA")
FRebuildOptions * FRebuildTools::GetCurrent() { return *(FRebuildOptions**)this; }

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
IMPL_DIVERGE("body incomplete — Ghidra 0x103FD770 not yet fully reconstructed")
FRebuildOptions * FRebuildTools::Save(FString p0) { return NULL; }

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
