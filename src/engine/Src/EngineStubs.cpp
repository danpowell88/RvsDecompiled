/*=============================================================================
    EngineStubs.cpp: Stub method bodies for Engine.dll exported symbols.
    
    Why this file exists
    --------------------
    The retail Engine.dll exports ~800 C++ methods by ordinal via its .def
    file. Each ordinal must resolve to a real symbol in the DLL or the
    linker will error. For methods we haven't decompiled yet, this file
    provides trivial "stub" bodies: empty functions, return 0, return NULL,
    etc. They have the correct signature so the mangled symbol name matches
    the .def entry, but they don't do any real work.

    As each method is properly reverse-engineered, its real implementation
    goes into the appropriate per-class file (UnActor.cpp, UnLevel.cpp,
    UnMesh.cpp, etc.) and the stub here should be deleted.

    Why #pragma optimize("", off)?
    --------------------------------
    Many stubs have empty bodies or just "return 0". With optimisation
    enabled, MSVC can merge identical function bodies (ICF/COMDAT folding)
    or eliminate them entirely. That would cause multiple .def ordinals to
    point at the same address — or worse, leave ordinals unresolved. 
    Disabling optimisation for this translation unit forces each stub to
    get its own unique address, keeping the export table correct.

    This file is the largest in the Engine module and will shrink over
    time as decompilation progresses.
=============================================================================*/
#pragma optimize("", off)

// Placement new: MSVC 2019+ with Win32 target requires explicit operator new(size_t,void*)
// when custom operator new overloads are in scope (UnFile.h overrides the allocating forms).
// Declaring it here satisfies all `new ((BYTE*)...) T(...)` calls in this file.
#pragma warning(push)
#pragma warning(disable: 4291) // no matching operator delete found
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// Global tool subsystems defined in Engine.cpp (used by stubs in this file).
extern ENGINE_API FRebuildTools GRebuildTools;

// Forward declarations for types used in parameters but not fully defined
class AProjector;
struct FProjectorRenderInfo;
struct FPropertyRetirement;
// FVertexComponent is now defined in EngineClasses.h
class AWarpZoneInfo;
class ATerrainInfo;
class FBspNode;
class FStaticMeshBatcherVertex;
struct FStaticMeshCollisionNode;
struct FStaticMeshCollisionTriangle;
class FStaticMeshSection;
struct FStaticMeshTriangle;

// extern declarations for FCollisionHash per-frame counters.
// Defined in UnCamera.cpp (originally in the UViewport section body).
extern INT GHashActorCount;
extern INT GHashLinkCellCount;
extern INT GHashExtraCount;

// --- AMover ---
void AMover::physMovingBrush(float)
{
}

void AMover::performPhysics(float)
{
}

int AMover::ShouldTrace(AActor*,DWORD TraceFlags)
{
	return TraceFlags & 2;
}

void AMover::AddMyMarker(AActor *)
{
}

INT* AMover::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}


// --- AMover ---
void AMover::SetWorldRaytraceKey()
{
}

void AMover::Spawned()
{
	// Ghidra 0xd4f30: copy BasePos/BaseRot from this+0x234..0x24B to KeyPos0/KeyRot0 at +0x670..0x6A8.
	appMemcpy((BYTE*)this + 0x670, (BYTE*)this + 0x234, 12); // BasePos -> KeyPos0
	appMemcpy((BYTE*)this + 0x6A0, (BYTE*)this + 0x240, 12); // BaseRot -> KeyRot0
}

void AMover::SetBrushRaytraceKey()
{
}

void AMover::PostEditChange()
{
}

void AMover::PostEditMove()
{
}

void AMover::PostLoad()
{
	// Ghidra 0xd4f70: AActor::PostLoad, init position sentinel (-12345.678f = 0xC640E400)
	// at DeltaPosition fields, and store a default rotation at this+0x6B8..0x6C0.
	AActor::PostLoad();
	const DWORD kSentinel = 0xC640E400u; // -12345.678f
	*(DWORD*)((BYTE*)this + 0x694) = kSentinel;
	*(DWORD*)((BYTE*)this + 0x698) = kSentinel;
	*(DWORD*)((BYTE*)this + 0x69C) = kSentinel;
	// Store default rotation {0x7B, 0x1C8, 0x315} = Pitch/Yaw/Roll at +0x6B8
	*(INT*)((BYTE*)this + 0x6B8) = 0x7B;
	*(INT*)((BYTE*)this + 0x6BC) = 0x1C8;
	*(INT*)((BYTE*)this + 0x6C0) = 0x315;
}

void AMover::PostNetReceive()
{
	// Ghidra 0x7da40: AActor::PostNetReceive, then apply interpolated position
	// if location changed since PreNetReceive snapshot. Complex - simplified to super call.
	// Divergence: mover position interpolation state at +0x67C..0x6CC not updated.
	AActor::PostNetReceive();
}

void AMover::PostRaytrace()
{
}

void AMover::PreNetReceive()
{
	// Ghidra 0x78100: snapshot current position this+0x6D0 to a static global,
	// then call AActor::PreNetReceive. Divergence: snapshot not stored (not needed
	// without the full PostNetReceive interpolation).
	AActor::PreNetReceive();
}

void AMover::PreRaytrace()
{
	// Ghidra 0xd5460: copy FVector(0,0,0) from FVector0_exref into this+0x694..0x69C
	// (resets DeltaPosition sentinel before raytrace pass). Divergence: skip external ref;
	// zero the sentinel directly (same effect).
	appMemzero((BYTE*)this + 0x694, 12);
}


// --- UInput ---

// --- ULodMeshInstance ---
FMeshAnimSeq * ULodMeshInstance::GetAnimSeq(FName)
{
	return NULL;
}

void ULodMeshInstance::Serialize(FArchive& Ar)
{
	// Retail: 0x103c6ff0. Calls UPrimitive::Serialize (chain: UObject::Serialize + render bounds).
	// Divergence: simplified to UObject::Serialize; render bounds regenerated on load.
	UObject::Serialize(Ar);
}

void ULodMeshInstance::SetActor(AActor * a)
{
	Actor = a;
}

void ULodMeshInstance::SetMesh(UMesh * m)
{
	Mesh = m;
}

void ULodMeshInstance::SetStatus(int s)
{
	Status = s;
}

AActor * ULodMeshInstance::GetActor()
{
	return Actor;
}

void ULodMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
}

UMaterial * ULodMeshInstance::GetMaterial(int,AActor *)
{
	return NULL;
}

UMesh * ULodMeshInstance::GetMesh()
{
	return Mesh;
}

void ULodMeshInstance::GetMeshVerts(AActor *,FVector *,int,int &)
{
}

INT ULodMeshInstance::GetStatus()
{
	return Status;
}


// --- UMeshInstance ---
int UMeshInstance::StopAnimating(int)
{
	return 0;
}

int UMeshInstance::UpdateAnimation(float)
{
	return 0;
}

void UMeshInstance::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void UMeshInstance::SetActor(AActor *)
{
	// Retail (3b): base no-op, subclasses override.
}

void UMeshInstance::SetAnimFrame(int,float)
{
	// Retail (3b): base no-op, subclasses override.
}

void UMeshInstance::SetMesh(UMesh *)
{
	// Retail (3b): base no-op, subclasses override.
}

void UMeshInstance::SetScale(FVector)
{
	// Retail (3b): base no-op, subclasses override.
}

void UMeshInstance::SetStatus(int)
{
}

int UMeshInstance::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int UMeshInstance::PlayAnim(int,FName,float,float,int,int,int)
{
	return 0;
}

int UMeshInstance::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}

int UMeshInstance::AnimForcePose(FName,float,float,int)
{
	return 0;
}

float UMeshInstance::AnimGetFrameCount(void *)
{
	return 0.0f;
}

FName UMeshInstance::AnimGetGroup(void *)
{
	return FName(NAME_None);
}

FName UMeshInstance::AnimGetName(void *)
{
	return FName(NAME_None);
}

int UMeshInstance::AnimGetNotifyCount(void *)
{
	return 0;
}

UAnimNotify * UMeshInstance::AnimGetNotifyObject(void *,int)
{
	return NULL;
}

const TCHAR* UMeshInstance::AnimGetNotifyText(void *,int)
{
	// Ghidra: returns L""
	return TEXT("");
}

float UMeshInstance::AnimGetNotifyTime(void *,int)
{
	return 0.0f;
}

float UMeshInstance::AnimGetRate(void *)
{
	// Ghidra: default rate is 15.0
	return 15.0f;
}

int UMeshInstance::AnimIsInGroup(void *,FName)
{
	return 0;
}

int UMeshInstance::AnimStopLooping(int)
{
	return 0;
}

void UMeshInstance::ClearChannel(int)
{
	// Retail (3b): base no-op, subclasses override.
}

int UMeshInstance::FreezeAnimAt(float,int)
{
	return 0;
}

float UMeshInstance::GetActiveAnimFrame(int)
{
	return 0.0f;
}

float UMeshInstance::GetActiveAnimRate(int)
{
	return 0.0f;
}

FName UMeshInstance::GetActiveAnimSequence(int)
{
	return FName(NAME_None);
}

AActor * UMeshInstance::GetActor()
{
	return NULL;
}

int UMeshInstance::GetAnimCount()
{
	return 0;
}

void * UMeshInstance::GetAnimIndexed(int)
{
	return NULL;
}

void * UMeshInstance::GetAnimNamed(FName)
{
	return NULL;
}

FBox UMeshInstance::GetCollisionBoundingBox(const AActor* Owner)
{
	// Retail: 32b. Get mesh via vtable[35] (GetMesh), call GetCollisionBoundingBox on mesh.
	return GetMesh()->GetCollisionBoundingBox(Owner);
}

void UMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
}

UMaterial * UMeshInstance::GetMaterial(int,AActor *)
{
	return NULL;
}

UMesh * UMeshInstance::GetMesh()
{
	return NULL;
}

FBox UMeshInstance::GetRenderBoundingBox(const AActor* Owner)
{
	// Retail: 32b. Get mesh via vtable[35] (GetMesh), call GetRenderBoundingBox on mesh.
	return GetMesh()->GetRenderBoundingBox(Owner);
}

FSphere UMeshInstance::GetRenderBoundingSphere(const AActor* Owner)
{
	// Retail: 32b. Get mesh via vtable[35] (GetMesh), call GetRenderBoundingSphere on mesh.
	return GetMesh()->GetRenderBoundingSphere(Owner);
}

int UMeshInstance::GetStatus()
{
	return 0;
}

int UMeshInstance::IsAnimating(int)
{
	return 0;
}

int UMeshInstance::IsAnimLooping(int)
{
	return 0;
}

int UMeshInstance::IsAnimPastLastFrame(int)
{
	return 0;
}

int UMeshInstance::IsAnimTweening(int)
{
	return 0;
}


// --- UNullRenderDevice ---

// --- USkeletalMesh ---
void USkeletalMesh::m_bLoadLbpFile(FString FileName)
{
	// Retail: 0x12f410. Extracts raw TCHAR* from FString and initialises
	// the CBoneDescData bone descriptor at this+0x294 from the LBP file.
	CBoneDescData* boneDesc = (CBoneDescData*)((BYTE*)this + 0x294);
	boneDesc->fn_bInitFromLbpFile(*FileName);
}

int USkeletalMesh::SetAttachAlias(FName,FName,FCoords &)
{
	return 0;
}

int USkeletalMesh::SetAttachmentLocation(AActor *,AActor *)
{
	return 0;
}

int USkeletalMesh::LODFootprint(int param_1, int param_2)
{
	// Retail: 0x140640. Returns memory footprint in bytes for the given LOD model.
	// param_2 == 0: include render-stream sizes. LOD models TArray at this+0x1AC, stride 0x11C.
	if (param_1 < 0)
		return 0;
	INT numLods = ((FArray*)((BYTE*)this + 0x1AC))->Num();
	if (param_1 >= numLods)
		return 0;
	BYTE* lod = (BYTE*)(*(INT*)((BYTE*)this + 0x1AC)) + param_1 * 0x11C;
	INT total = 0;
	if (param_2 == 0) {
		INT s0 = ((FArray*)(lod + 0xB0))->Num();
		INT s1 = ((FArray*)(lod + 0xC8))->Num();
		INT s2 = ((FArray*)(lod + 0xE0))->Num();
		INT s3 = ((FArray*)(lod + 0xF8))->Num();
		total = s0 * 8 + s1 * 0xC + s2 * 8 + (s3 + 8) * 0xC;
	}
	INT n0 = ((FArray*)(lod))->Num();
	INT n1 = ((FArray*)(lod + 0xC))->Num();
	INT n2 = ((FArray*)(lod + 0x1C))->Num();
	INT n3 = ((FArray*)(lod + 0x28))->Num();
	INT n4 = ((FArray*)(lod + 0x98))->Num();
	INT n5 = ((FArray*)(lod + 0x38))->Num();
	INT n6 = ((FArray*)(lod + 0x54))->Num();
	INT n7 = ((FArray*)(lod + 0x8C))->Num();
	return n7 * 0x20 + total + n0 * 4 + n1 * 0x10 + n2 * 0x14 + n3 * 0x14 + 0xBC + n4 * 2 + n5 * 2 + n6 * 2;
}

void USkeletalMesh::NormalizeInfluences(int)
{
}

void USkeletalMesh::CalculateNormals(TArray<FVector> &,int)
{
}

void USkeletalMesh::ClearAttachAliases()
{
	// Retail: 0x135bb0. Empties the three attach alias arrays.
	// Alias names at this+0x2D0 (stride 4), alias targets at this+0x2DC (stride 4),
	// alias coord data at this+0x2E8 (stride 0x30).
	((TArray<INT>*)((BYTE*)this + 0x2D0))->Empty();
	((TArray<INT>*)((BYTE*)this + 0x2DC))->Empty();
	((TArray<INT>*)((BYTE*)this + 0x2E8))->Empty();
}

void USkeletalMesh::FlipFaces()
{
}

void USkeletalMesh::GenerateLodModel(int,float,float,int,int)
{
}

void USkeletalMesh::InsertLodModel(int,USkeletalMesh *,float,int)
{
}

int USkeletalMesh::UseCylinderCollision(const AActor* Actor)
{
	// Retail (18b, RVA 0x12F6C0): returns 0 only for ragdoll actors (Physics byte at Actor+0x2C == 0x0E = PHYS_KarmaRagDoll).
	// PHYS_KarmaRagDoll = 14/0x0E. All other physics modes use cylinder collision.
	return Actor->Physics != PHYS_KarmaRagDoll;
}

int USkeletalMesh::R6LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

void USkeletalMesh::Serialize(FArchive& Ar)
{
	// Retail: 0x1043ffb0. Calls ULodMesh::Serialize, then serializes bone ref pose (+0x1B8),
	// bone array (+0x19C), default anim ref (+0x1DC), vertex inflations, LOD arrays etc.
	// Divergence: simplified to UObject::Serialize; mesh data is loaded from .u package.
	UObject::Serialize(Ar);
}

int USkeletalMesh::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int USkeletalMesh::MemFootprint(int param_1)
{
	// Retail: 0x140350. Sum memory of all mesh data arrays.
	// param_1 == 0: also count render streams. LOD array at this+0x1AC, stride 0x11C.
	INT total = 0;
	INT lodRender = 0;
	if (param_1 == 0) {
		// Count base mesh arrays (bones, weights, verts, faces, etc.)
		INT n0  = ((FArray*)((BYTE*)this + 0x100))->Num();
		INT n1  = ((FArray*)((BYTE*)this + 0x118))->Num();
		INT n2  = ((FArray*)((BYTE*)this + 0x130))->Num();
		INT n3  = ((FArray*)((BYTE*)this + 0x148))->Num();
		INT n4  = ((FArray*)((BYTE*)this + 0x160))->Num();
		INT n5  = ((FArray*)((BYTE*)this + 0x178))->Num();
		INT n6  = ((FArray*)((BYTE*)this + 0x190))->Num();
		total = n0 * 0xC + n1 * 4 + n2 * 0xC + n3 * 0xC + n4 * 8 + n5 * 2 + 0xA8 + n6 * 2;
		// Sum per-LOD render stream sizes
		FArray* lodArr = (FArray*)((BYTE*)this + 0x1AC);
		INT numLods = lodArr->Num();
		for (INT i = 0; i < numLods; i++) {
			BYTE* lod = (BYTE*)(*(INT*)lodArr) + i * 0x11C;
			INT s0 = ((FArray*)(lod + 0xB0))->Num();
			INT s1 = ((FArray*)(lod + 0xC8))->Num();
			INT s2 = ((FArray*)(lod + 0xE0))->Num();
			INT s3 = ((FArray*)(lod + 0xF8))->Num();
			total += s0 * 8 + s1 * 0xC + s2 * 8 + (s3 + 8) * 0xC;
		}
	}
	// Sum per-LOD index/vertex arrays
	FArray* lodArr2 = (FArray*)((BYTE*)this + 0x1AC);
	INT numLods2 = lodArr2->Num();
	for (INT j = 0; j < numLods2; j++) {
		BYTE* lod = (BYTE*)(*(INT*)lodArr2) + j * 0x11C;
		INT n0 = ((FArray*)(lod))->Num();
		INT n1 = ((FArray*)(lod + 0xC))->Num();
		INT n2 = ((FArray*)(lod + 0x1C))->Num();
		INT n3 = ((FArray*)(lod + 0x28))->Num();
		INT n4 = ((FArray*)(lod + 0x98))->Num();
		INT n5 = ((FArray*)(lod + 0x38))->Num();
		INT n6 = ((FArray*)(lod + 0x54))->Num();
		INT n7 = ((FArray*)(lod + 0x8C))->Num();
		total += n7 * 0x20 + n0 * 4 + n1 * 0x10 + n2 * 0x14 + n3 * 0x14 + 0xBC + n4 * 2 + n5 * 2 + n6 * 2;
	}
	// Animation and extra arrays
	INT a0 = ((FArray*)((BYTE*)this + 0x2B8))->Num();
	INT a1 = ((FArray*)((BYTE*)this + 0x2D0))->Num();
	INT a2 = ((FArray*)((BYTE*)this + 0x2DC))->Num();
	INT a3 = ((FArray*)((BYTE*)this + 0x2E8))->Num();
	return total + (a3 + 3) * 0x30 + a0 * 0x30 + a1 * 4 + a2 * 4;
}

void USkeletalMesh::Destroy()
{
	// Retail: 0x1042f5d0. Just calls UObject::Destroy (no custom cleanup beyond base class).
	UObject::Destroy();
}

FBox USkeletalMesh::GetCollisionBoundingBox(const AActor* Owner) const
{
	// Retail: 0x12f6e0. Delegates to UPrimitive::GetCollisionBoundingBox.
	return UPrimitive::GetCollisionBoundingBox(Owner);
}

FBox USkeletalMesh::GetRenderBoundingBox(const AActor* Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingBox on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingBox(Owner);
}

FSphere USkeletalMesh::GetRenderBoundingSphere(const AActor* Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingSphere on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingSphere(Owner);
}


// --- USkeletalMesh ---
void USkeletalMesh::ReconstructRawMesh()
{
}

int USkeletalMesh::RenderPreProcess()
{
	return 0;
}

UClass * USkeletalMesh::MeshGetInstanceClass()
{
	return USkeletalMeshInstance::StaticClass();
}

void USkeletalMesh::PostLoad()
{
	// Ghidra 0x12f4b0: UObject::PostLoad, then if LOD version at +0x5C < 2,
	// call ReconstructRawMesh(). If LOD models array (this+0x1AC) is empty,
	// auto-generate 4 LOD levels.
	// Divergence: LOD version check and auto-generation skipped;
	// LOD data is expected to already be in the package file.
	UObject::PostLoad();
}


// --- USkeletalMeshInstance ---
int USkeletalMeshInstance::TraceHeadHit(FCheckResult& Hit, FVector const& Start, FVector const& End, FVector const& DirNorm, float const& Extent)
{
	// Retail: 0x12FF20, 96b. Casts a line from Start toward End with the given half-extent
	// to detect a head-bone collision. Uses FVector arithmetic (delta, normalization) on
	// stack locals then calls vtbl-based line check. Returns non-zero if head hit.
	// The function uses SEH (push -1/SEH frame), computes:
	//   delta = End - Start, dir2 = Head - Start
	//   dotProduct = dot(dir2, DirNorm) * each component + ...
	// Returning 0 is safe for a stub that doesn't affect gameplay critically.
	return 0;
}

void USkeletalMeshInstance::UpdateBlendAlpha(INT Channel, float Alpha, float DeltaTime)
{
	// Retail: 0x134EF0, 160b.
	// Bounds-check Channel vs this+0x10C TArray Num().
	// Channel element blend alpha stored at elem+0x50.
	// Lerp: if |current - target| <= DeltaTime: snap to target.
	// Otherwise: current += sign(target - current) * DeltaTime.
	if (Channel < 0) return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num()) return;
	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	FLOAT current = *(FLOAT*)(elem + 0x50);
	FLOAT diff = current - Alpha;
	if (diff < 0.0f) diff = -diff;
	if (diff <= DeltaTime)
	{
		*(FLOAT*)(elem + 0x50) = Alpha;
	}
	else
	{
		if (current > Alpha)
			*(FLOAT*)(elem + 0x50) = current - DeltaTime;
		else
			*(FLOAT*)(elem + 0x50) = current + DeltaTime;
	}
}

int USkeletalMeshInstance::ValidateAnimChannel(INT Channel)
{
	// Retail: 0x130F40, 92b. Bounds-check channel [0..255]. If TArray at this+0x10C
	// has fewer than Channel+1 slots, grow it by adding zero-initialised elements
	// (stride 0x74). Returns 1 always (indicates channel is or has become valid).
	if (Channel > 255 || Channel < 0)
		return 1;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	while (arr->Num() <= Channel)
		arr->Add(1, 0x74);
	return 1;
}

void USkeletalMeshInstance::SetAnimRate(INT Channel, FLOAT Rate)
{
	// Disasm: 0x134A90, 240b.
	// Multiplies Rate by the per-channel rate scale (elem+0x20) and stores to elem+0x0C.
	// With a zero rate, sets elem+0x40 = 0 (paused); non-zero sets elem+0x40 = 1 (playing).
	if (Channel < 0) return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num()) return;
	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	FLOAT Scale = *(FLOAT*)(elem + 0x20);
	FLOAT Stored = Rate * Scale;
	*(FLOAT*)(elem + 0x0C) = Stored;
	*(INT*)(elem + 0x40) = (Rate > 0.0f) ? 1 : 0;
}

void USkeletalMeshInstance::SetAnimSequence(INT Channel, FName SeqName)
{
	// Disasm: 0x134FC0, 304b.
	// Looks up the anim object for SeqName, then sets channel slot+seq fields and
	// computes the rate scale (elem+0x20) via vtable calls on the anim object.
	if (Channel < 0) return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num()) return;

	// Find the anim object that contains this sequence
	typedef void* (__thiscall *FindAnimObjFn)(USkeletalMeshInstance*, FName);
	FindAnimObjFn FindAnimObj = *(FindAnimObjFn*)((*(BYTE**)this) + 0x12C);
	void* AnimObj = FindAnimObj(this, SeqName);

	INT SlotIdx = -1;
	if (AnimObj)
	{
		// Find slot index of this anim in AnimObjects array
		typedef INT (*FindSlotFn)(FArray*, void*);
		FindSlotFn FindSlot = (FindSlotFn)0x10431D00;
		FArray* AnimArr = (FArray*)((BYTE*)this + 0xAC);
		SlotIdx = FindSlot(AnimArr, AnimObj);
	}

	// Get the sequence object (vtbl[0xB0/4] = GetAnimIndexed or equivalent)
	typedef void* (__thiscall *GetAnimNamedFn)(USkeletalMeshInstance*, FName);
	GetAnimNamedFn GetAnimNamed_fn = *(GetAnimNamedFn*)((*(BYTE**)this) + 0xB0);
	void* SeqObj = GetAnimNamed_fn(this, SeqName);

	if (SlotIdx < 0 || !SeqObj) return;

	// Compute channel element offset
	BYTE* ChannelData = *(BYTE**)arr;
	BYTE* elem = ChannelData + Channel * 0x74;

	// Store slot index and sequence name
	*(INT*)(elem + 4) = SlotIdx;
	*(FName*)(elem + 8) = SeqName;

	// Compute rate scale = vtbl[0xC4](seqObj) / vtbl[0xC0](seqObj)
	// vtbl[0xC4/4] = GetActiveAnimRate, vtbl[0xC0/4] = GetAnimFrameCount (returns anim native rate)
	typedef FLOAT (__thiscall *GetRateFn)(USkeletalMeshInstance*, void*);
	typedef FLOAT (__thiscall *GetFrameCountFn)(USkeletalMeshInstance*, void*);
	GetRateFn GetRate     = *(GetRateFn*)((*(BYTE**)this) + 0xC4);
	GetFrameCountFn GetFC = *(GetFrameCountFn*)((*(BYTE**)this) + 0xC0);
	FLOAT NativeRate = GetRate(this, SeqObj);
	FLOAT FrameCount = GetFC(this, SeqObj);
	if (FrameCount != 0.0f)
		*(FLOAT*)(elem + 0x20) = NativeRate / FrameCount;

	// vtbl[0xC8/4] = AnimStopLooping (or IsLooping check) — store as bool in elem+0x34
	typedef INT (__thiscall *IsLoopingFn)(USkeletalMeshInstance*, void*);
	IsLoopingFn IsLooping = *(IsLoopingFn*)((*(BYTE**)this) + 0xC8);
	*(INT*)(elem + 0x34) = (IsLooping(this, SeqObj) != 0) ? 1 : 0;
}

void USkeletalMeshInstance::SetBlendAlpha(INT Channel, FLOAT Alpha)
{
	// Retail: 145b SEH. Clamps Alpha to [0.0, 1.0] and stores at element+0x50 in TArray at this+0x10C.
	if (Channel < 0) return;
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return;
	FLOAT clamped = Alpha;
	if (clamped < 0.0f) clamped = 0.0f;
	if (clamped > 1.0f) clamped = 1.0f;
	*(FLOAT*)(*(BYTE**)(seqBase) + Channel * 0x74 + 0x50) = clamped;
}

int USkeletalMeshInstance::SetBlendParams(int,float,float,float,FName,int)
{
	return 0;
}

int USkeletalMeshInstance::SetBoneDirection(FName,FRotator,FVector,float)
{
	// Retail: 0x131A90, 32b. Returns 0 if bone override array (this+0x130) is at
	// capacity (>= 256 entries); actual bone direction logic unimplemented.
	FArray* arr = (FArray*)((BYTE*)this + 0x130);
	if (arr->Num() >= 0x100)
		return 0;
	return 0;
}

int USkeletalMeshInstance::SetBoneLocation(FName BoneName, FVector Location, FLOAT Scale)
{
	// Retail: 0x1317A0. Faithfully decompiled from Ghidra.
	// this+0x124: bone location override TArray, stride 0x40, max 256.
	// entry+0x00=boneIdx, +0x04=BoneName, +0x20=Location(FVector), +0x30=0, +0x3C=Scale.
	FArray* arr = (FArray*)((BYTE*)this + 0x124);
	if (arr->Num() > 0xFF)
		return 0;

	INT boneIdx = MatchRefBone(BoneName);
	if (boneIdx < 0)
		return 0;

	// Search for existing entry with matching BoneName
	INT foundIdx = -1;
	INT count = arr->Num();
	for (INT i = 0, off = 0; i < count; i++, off += 0x40)
	{
		if (*(FName*)((BYTE*)(*(BYTE**)arr) + off + 4) == BoneName)
		{
			foundIdx = i;
			break;
		}
	}

	if (foundIdx < 0)
	{
		// Add new entry (uninitialized, we set what we need)
		foundIdx = arr->Num();
		arr->Add(1, 0x40);
		BYTE* e = (BYTE*)(*(BYTE**)arr) + foundIdx * 0x40;
		*(FName*)(e + 4)  = BoneName;
		*(INT*)  (e + 0x30) = 0;
		*(INT*)  (e)        = boneIdx;
	}

	BYTE* elem = (BYTE*)(*(BYTE**)arr) + foundIdx * 0x40;
	*(FLOAT*)  (elem + 0x3C) = Scale;
	*(FVector*)(elem + 0x20) = Location;
	return 1;
}

int USkeletalMeshInstance::SetBonePosition(FName BoneName, FRotator Rot, FVector Loc, FLOAT Scale)
{
	// Retail: 0x131BA0. Faithfully decompiled from Ghidra.
	// this+0x13C: bone position override TArray, stride 0x40, max 256.
	// entry+0x00=boneIdx, +0x04=BoneName, +0x08=Rotation(FRotator), +0x20=Location(FVector),
	// +0x30=Scale, +0x3C=Scale (duplicate).
	FArray* arr = (FArray*)((BYTE*)this + 0x13C);
	if (arr->Num() >= 0x100)
		return 0;

	INT boneIdx = MatchRefBone(BoneName);
	if (boneIdx < 0)
		return 0;

	// Search for existing entry
	INT foundIdx = -1;
	for (INT i = 0; i < arr->Num(); i++)
	{
		if (*(FName*)((BYTE*)(*(BYTE**)arr) + i * 0x40 + 4) == BoneName)
		{
			foundIdx = i;
			break;
		}
	}

	if (foundIdx < 0)
	{
		foundIdx = arr->Num();
		arr->Add(1, 0x40);
		BYTE* e = (BYTE*)(*(BYTE**)arr) + foundIdx * 0x40;
		*(FName*)(e + 4)   = BoneName;
		*(INT*)  (e + 0x3C) = 0;
		*(INT*)  (e)         = boneIdx;
	}

	BYTE* elem = (BYTE*)(*(BYTE**)arr) + foundIdx * 0x40;
	*(FLOAT*)  (elem + 0x30) = Scale;
	*(FLOAT*)  (elem + 0x3C) = Scale;
	*(FRotator*)(elem + 0x08) = Rot;
	*(FVector*) (elem + 0x20) = Loc;
	return 1;
}

int USkeletalMeshInstance::SetBoneRotation(FName BoneName, FRotator NewRot, INT bNotifyOwner, FLOAT BlendTarget, FLOAT BlendSpeed)
{
	// Retail: 0x131890. Faithfully decompiled from Ghidra.
	// this+0x124: bone rotation override TArray, stride 0x40, max 256.
	// entry+0x00=boneIdx, +0x04=BoneName, +0x08=Rotation(FRotator),
	// +0x14=OldRotation(FRotator), +0x2C=bNotifyOwner, +0x30=BlendTarget,
	// +0x34=BlendSpeed, +0x38=CurrentBlend(FLOAT).
	FArray* arr = (FArray*)((BYTE*)this + 0x124);
	if (arr->Num() > 0xFF)
		return 0;

	INT boneIdx = MatchRefBone(BoneName);
	if (boneIdx < 0)
		return 0;

	// Search for existing entry
	INT foundIdx = -1;
	for (INT i = 0, off = 0; i < arr->Num(); i++, off += 0x40)
	{
		if (*(FName*)((BYTE*)(*(BYTE**)arr) + off + 4) == BoneName)
		{
			foundIdx = i;
			break;
		}
	}

	if (foundIdx < 0)
	{
		// Add new entry and zero-initialize rotation fields
		foundIdx = arr->Num();
		arr->Add(1, 0x40);
		BYTE* e = (BYTE*)(*(BYTE**)arr) + foundIdx * 0x40;
		*(FName*)(e + 4)   = BoneName;
		*(INT*)  (e + 0x3C) = 0;
		*(INT*)  (e)         = boneIdx;
		*(FRotator*)(e + 0x14) = FRotator(0,0,0); // old rotation backup
		*(FRotator*)(e + 0x08) = FRotator(0,0,0); // current rotation
		*(INT*)  (e + 0x34)  = 0;                  // blend speed
		*(INT*)  (e + 0x38)  = 0;                  // current blend
	}

	INT off = foundIdx * 0x40;
	BYTE* base = (BYTE*)(*(BYTE**)arr);
	BYTE* elem = base + off;

	*(INT*)  (elem + 0x2C) = bNotifyOwner;
	*(FLOAT*)(elem + 0x30) = BlendTarget;

	FLOAT existing = *(FLOAT*)(elem + 0x34);
	if (BlendSpeed == 0.0f || existing != 0.0f)
	{
		*(FLOAT*)(elem + 0x34) = BlendSpeed;
		if (BlendSpeed == 0.0f)
		{
			// Check if rotation changed
			FRotator curRot = *(FRotator*)(elem + 0x08);
			if (!(curRot == NewRot))
			{
				*(INT*)(elem + 0x38) = 0; // reset blend
				// Notify owner about blend state
				typedef BYTE* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
				GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
				BYTE* owner = GetOwner(this);
				if (owner) *(INT*)(owner + 0x118) = *(INT*)(elem + 0x38);
			}
			else
			{
				*(FLOAT*)(elem + 0x38) = 1.0f; // 0x3f800000
			}
		}
		else
		{
			*(FLOAT*)(elem + 0x38) = 1.0f;
		}
		// Copy current rotation to backup
		*(FRotator*)(elem + 0x14) = *(FRotator*)(elem + 0x08);
	}

	*(FRotator*)(elem + 0x08) = NewRot;
	return 1;
}

int USkeletalMeshInstance::SetBoneScale(INT BoneChannel, FLOAT Scale, FName BoneName)
{
	// Retail: 0x131620. Faithfully decompiled from Ghidra.
	// this+0x118: per-channel bone scale TArray, stride 0x3C, indexed by BoneChannel (0-256).
	// entry+0x00=boneIdx(-1 if inactive), +0x04=BoneName, +0x08=Scale.
	// Scale==1.0 with valid BoneName sets the scale; Scale==1.0 with NAME_None resets.
	if (BoneChannel < 0 || BoneChannel > 0x100)
		return 0;

	FArray* arr = (FArray*)((BYTE*)this + 0x118);

	// Grow array until it covers BoneChannel index
	while (arr->Num() <= BoneChannel)
	{
		arr->AddZeroed(0x3C, 1);
		// Mark new entry as invalid
		INT n = arr->Num();
		*(INT*)((BYTE*)(*(BYTE**)arr) + (n - 1) * 0x3C) = 0xFFFFFFFF;
	}
	arr->Shrink(0x3C);

	if (Scale != 1.0f)
	{
		// Set bone scale if BoneName is valid
		if (BoneName != FName(NAME_None))
		{
			INT boneIdx = MatchRefBone(BoneName);
			if (boneIdx < 0)
				return 1;
			BYTE* slot = (BYTE*)(*(BYTE**)arr) + BoneChannel * 0x3C;
			*(INT*)   slot        = boneIdx;
			*(FName*) (slot + 4)  = BoneName;
			*(FLOAT*) (slot + 8)  = Scale;
			return 1;
		}
		// BoneName == NAME_None → fall through to reset
	}

	// Reset: mark entry inactive
	BYTE* slot = (BYTE*)(*(BYTE**)arr) + BoneChannel * 0x3C;
	*(INT*)  slot       = 0xFFFFFFFF; // boneIdx = -1
	*(FLOAT*)(slot + 4) = 0.0f;       // scale = 0
	return 1;
}

int USkeletalMeshInstance::SetSkelAnim(UMeshAnimation* Anim, USkeletalMesh* Mesh)
{
	// Disasm: if Anim==NULL return 0
	if (!Anim) return 0;

	// Search this->AnimObjects (this+0xAC, stride 0x18) for existing slot
	FArray* AnimArr = (FArray*)((BYTE*)this + 0xAC);
	INT Count = AnimArr->Num();
	INT Found = -1;
	for (INT i = 0; i < Count; i++)
	{
		BYTE* Slot = (BYTE*)(*(BYTE**)AnimArr) + i * 0x18;
		if (*(UMeshAnimation**)Slot == Anim)
		{
			Found = i;
			break;
		}
	}

	if (Found == -1)
	{
		// Add a new slot and store Anim* and Mesh* in it
		INT Idx = AnimArr->Add(1, 0x18);
		BYTE* Slot = (BYTE*)(*(BYTE**)AnimArr) + Idx * 0x18;
		*(UMeshAnimation**)Slot = Anim;
		*(USkeletalMesh**)(Slot + 4) = Mesh;
	}

	// vtbl[0x128/4] — notification callback (AnimObjectsChanged)
	typedef void (__thiscall *NotifyFn)(USkeletalMeshInstance*);
	NotifyFn Notify = *(NotifyFn*)((*(BYTE**)this) + 0x128);
	Notify(this);
	return 1;
}

int USkeletalMeshInstance::LockRootMotion(INT Mode, INT /*Unused*/)
{
	// Disasm: store Mode at this+0x1C4, set lock flag at this+0x228=1, clear this+0x188=0
	*(INT*)((BYTE*)this + 0x1C4) = Mode;
	*(INT*)((BYTE*)this + 0x228) = 1;
	*(INT*)((BYTE*)this + 0x188) = 0;

	// vtbl[0x8C/4] — GetMesh
	typedef void* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	(void)GetMesh(this);

	// vtbl[0x84/4] — GetOwner/GetActor  (result unused in our simplified form)
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
	void* Owner = GetOwner(this);

	// Retail: if owner is NULL, just clean up and return 0 (exception-frame teardown path)
	// if owner is non-NULL more work is done but is safe to defer
	if (!Owner) return 0;
	return 1;
}

int USkeletalMeshInstance::MatchRefBone(FName BoneName)
{
	// Disasm: 0x130D40, 256b.
	// Phase 0: get mesh via vtbl[0x8C/4], reject NAME_None
	typedef BYTE* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh(this);
	if (!Mesh) return -1;

	if (BoneName == FName(NAME_None)) return -1;

	// Phase 1: search mesh->RefBoneNames TArray at mesh+0x2D0 (stride 4 = FName array)
	FArray* BoneNameArr = (FArray*)(Mesh + 0x2D0);
	INT BoneCount = BoneNameArr->Num();
	if (BoneCount <= 0) return -1;

	BYTE* BoneNameData = *(BYTE**)BoneNameArr;
	INT FoundIdx = -1;
	for (INT i = 0; i < BoneCount; i++)
	{
		FName* Entry = (FName*)(BoneNameData + i * 4);
		if (*Entry == BoneName) { FoundIdx = i; break; }
	}
	if (FoundIdx < 0) return -1;

	// Phase 2: get bone index from mesh->RefBoneIndices TArray at mesh+0x2DC
	BYTE* BoneIdxData = *(BYTE**)(Mesh + 0x2DC);
	INT BoneIdx = *(INT*)(BoneIdxData + FoundIdx * 4);

	// Phase 3: search mesh->RefBones TArray at mesh+0x19C (stride 0x40)
	// for a slot whose first DWORD matches BoneIdx
	Mesh = GetMesh(this);
	FArray* SkelArr = (FArray*)(Mesh + 0x19C);
	INT SkelCount = SkelArr->Num();
	if (SkelCount <= 0) return -1;

	BYTE* SkelData = *(BYTE**)SkelArr;
	for (INT j = 0; j < SkelCount; j++)
	{
		BYTE* Slot = SkelData + j * 0x40;
		if (*(INT*)Slot == BoneIdx) return j;
	}
	return -1;
}

void USkeletalMeshInstance::BlendToAlpha(INT Channel, FLOAT BlendAlpha, FLOAT DeltaTime)
{
	// Retail: 0x1351B0, ~130b.
	// Sets up a timed blend on channel elem+0x38/0x5C/0x60.
	// If DeltaTime == 0.0f: do nothing (no-op guard at retail).
	// Otherwise: store BlendAlpha at elem+0x60, DeltaTime at elem+0x5C, set elem+0x38=1.
	if (DeltaTime == 0.0f) return;
	if (Channel < 0) return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num()) return;
	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	*(INT*)(elem + 0x60)  = *(INT*)&BlendAlpha; // store as int-aliased float
	*(FLOAT*)(elem + 0x5C) = DeltaTime;
	*(INT*)(elem + 0x38)   = 1;
}

void USkeletalMeshInstance::BuildPivotsList()
{
}

void USkeletalMeshInstance::ClearSkelAnims()
{
	// Disasm: 0x13D860, 128b.
	// For each slot in AnimObjects (this+0xAC, stride 0x18), empty the inner FArray at slot+0x0C.
	// Then destroy each slot object, then empty the whole AnimObjects array.
	FArray* AnimArr = (FArray*)((BYTE*)this + 0xAC);
	INT Count = AnimArr->Num();
	BYTE* Data = *(BYTE**)AnimArr;
	for (INT i = 0; i < Count; i++)
	{
		FArray* Inner = (FArray*)(Data + i * 0x18 + 0x0C);
		Inner->Empty(4);
	}
	AnimArr->Empty(0x18);
}

void USkeletalMeshInstance::CopyAnimation(INT Src, INT Dst)
{
	// Retail: 0x134980, ~200b.
	// Both Src and Dst must be valid channels (>= 0 and < Num). Dst is ValidateAnimChannel'd.
	// Copies channel fields from Src to Dst: +8(FName), +4(slotIdx), +0C(rate), +20(rateScale),
	// +10(frame), +50(blendAlpha), +14(frameCount), +34(isLooping), +2C(loopFlag1).
	if (Src < 0 || Dst < 0) return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Src >= arr->Num()) return;
	ValidateAnimChannel(Dst);
	if (Dst >= arr->Num()) return;
	BYTE* base = (BYTE*)(*(BYTE**)arr);
	BYTE* src  = base + Src * 0x74;
	BYTE* dst  = base + Dst * 0x74;
	*(INT*)(dst + 0x08) = *(INT*)(src + 0x08); // FName sequence
	*(INT*)(dst + 0x04) = *(INT*)(src + 0x04); // anim slot index
	*(INT*)(dst + 0x0C) = *(INT*)(src + 0x0C); // rate
	*(INT*)(dst + 0x20) = *(INT*)(src + 0x20); // rate scale
	*(INT*)(dst + 0x10) = *(INT*)(src + 0x10); // frame
	*(INT*)(dst + 0x50) = *(INT*)(src + 0x50); // blend alpha
	*(INT*)(dst + 0x14) = *(INT*)(src + 0x14); // frame count
	*(INT*)(dst + 0x34) = *(INT*)(src + 0x34); // isLooping
	*(INT*)(dst + 0x2C) = *(INT*)(src + 0x2C); // loop flag 1
}

void USkeletalMeshInstance::DrawCollisionCylinders(FSceneNode *)
{
}

int USkeletalMeshInstance::EnableChannelNotify(INT Channel, INT bEnable)
{
	// Retail: 0x1338B0, ~130b.
	// ValidateAnimChannel(Channel). Then elem+0x48 = !bEnable (i.e. 0 when enabling, 1 when disabling).
	// Returns 1 on success, 0 if ValidateAnimChannel fails.
	if (!ValidateAnimChannel(Channel)) return 0;
	BYTE* base = (BYTE*)(*(BYTE**)((BYTE*)this + 0x10C));
	BYTE* elem = base + Channel * 0x74;
	*(INT*)(elem + 0x48) = (bEnable == 0) ? 1 : 0;
	return 1;
}

void USkeletalMeshInstance::ForceAnimRate(INT Channel, FLOAT Rate)
{
	// Retail: 0x134B80, 96b. Stores Rate at channel element+0x0C in TArray at this+0x10C
	// (stride 0x74). Bounds-checks channel first; ignores negative channel.
	if (Channel < 0)
		return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num())
		return;
	BYTE* elem = (BYTE*)(*(INT*)arr) + Channel * 0x74;
	*(FLOAT*)(elem + 0x0C) = Rate;
}

int USkeletalMeshInstance::GetAnimChannelCount()
{
	// Retail: 12b. Adjusts this to TArray at this+0x10C, then jumps to TArray::Num via IAT.
	// Equivalent to reading the TArray ArrayNum field directly.
	return *(INT*)((BYTE*)this + 0x110); // this+0x10C is TArray start; +0x04 = ArrayNum
}

float USkeletalMeshInstance::GetAnimFrame(INT Channel)
{
	// Retail: 93b SEH. Same TArray at this+0x10C (stride 0x74), frame float at element+0x10.
	if (Channel < 0) return 0.0f;
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return 0.0f;
	return *(FLOAT*)(*(BYTE**)(seqBase) + Channel * 0x74 + 0x10);
}

float USkeletalMeshInstance::GetAnimRateOnChannel(INT Channel)
{
	// Disasm: 0x135B20, 96b.
	// Validates channel, then returns GetActiveAnimRate(GetAnimNamed(channel_seqname)).
	// Returns 0.0f if channel is invalid or anim not found.
	typedef INT (__thiscall *ValidateFn)(USkeletalMeshInstance*, INT);
	ValidateFn Validate = (ValidateFn)0x10430F40;
	if (!Validate(this, Channel)) return 0.0f;

	// Get sequence FName from channel elem+8
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	FName SeqName = *(FName*)(elem + 8);

	// GetAnimNamed(SeqName) → anim object pointer
	typedef void* (__thiscall *GetAnimNamedFn)(USkeletalMeshInstance*, FName);
	GetAnimNamedFn GetAnimNamed_fn = *(GetAnimNamedFn*)((*(BYTE**)this) + 0xB0);
	void* SeqObj = GetAnimNamed_fn(this, SeqName);
	if (!SeqObj) return 0.0f;

	// GetActiveAnimRate(SeqObj) → current channel rate
	typedef FLOAT (__thiscall *GetActiveRateFn)(USkeletalMeshInstance*, void*);
	GetActiveRateFn GetActiveRate = *(GetActiveRateFn*)((*(BYTE**)this) + 0xC4);
	return GetActiveRate(this, SeqObj);
}

FName USkeletalMeshInstance::GetAnimSequence(INT Channel)
{
	// Retail: 98b SEH. Reads FName.Index from channel element+0x08 in TArray at this+0x10C.
	// Same layout as GetActiveAnimSequence; [ebp+0xC] used as arg due to hidden return ptr.
	if (Channel < 0) return FName(NAME_None);
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return FName(NAME_None);
	BYTE* data = *(BYTE**)(seqBase);
	return *(FName*)(data + Channel * 0x74 + 0x08);
}

float USkeletalMeshInstance::GetBlendAlpha(INT Channel)
{
	// Retail: 93b SEH. Same TArray at this+0x10C (stride 0x74), blend alpha float at element+0x50.
	if (Channel < 0) return 0.0f;
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return 0.0f;
	return *(FLOAT*)(*(BYTE**)(seqBase) + Channel * 0x74 + 0x50);
}

FCoords USkeletalMeshInstance::GetBoneCoords(DWORD,int)
{
	return FCoords();
}

int USkeletalMeshInstance::GetBoneCylinder(int,FCylinder &)
{
	return 0;
}

FName USkeletalMeshInstance::GetBoneName(FName BoneName)
{
	// Disasm: 0x133680, 128b.
	// Gets mesh, searches mesh->RefBoneNames (mesh+0x2D0, stride 4) for BoneName.
	// On success returns the corresponding entry from mesh->RefBoneIndices (mesh+0x2DC).
	typedef BYTE* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh(this);
	if (!Mesh) return FName(NAME_None);

	FArray* BoneNameArr = (FArray*)(Mesh + 0x2D0);
	INT Count = BoneNameArr->Num();
	BYTE* NameData = *(BYTE**)BoneNameArr;
	for (INT i = 0; i < Count; i++)
	{
		FName* Entry = (FName*)(NameData + i * 4);
		if (*Entry == BoneName)
		{
			// Return the mapped bone index from RefBoneIndices (mesh+0x2DC) as a FName
			BYTE* IndexData = *(BYTE**)(Mesh + 0x2DC);
			FName Result;
			*(INT*)&Result = *(INT*)(IndexData + i * 4);
			return Result;
		}
	}
	return FName(NAME_None);
}

FRotator USkeletalMeshInstance::GetBoneRotation(DWORD boneIndex, INT Space)
{
	// Retail: 0x133520, 320b. Same skeleton update guard as GetBoneCoords.
	// Checks WasSkeletonUpdated (bone array at 0xB8, SQWORD stamp at 0x64/0x68 vs GTicks).
	// If stale and owner is valid: call vtbl[0x110/4] to refresh skeleton.
	// Then validates boneIndex < Num(). Reads bone transform from this+0xB8[boneIndex*0x30],
	// converts to FRotator via transform at this+0xC4 (inverse world transform).
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	typedef void  (__thiscall *UpdateAnimFn)(USkeletalMeshInstance*, void*, void*, INT, INT, INT, INT);
	typedef FRotator* (__cdecl *GetTransformRotFn)(FRotator*, void*, void*);
	typedef FRotator* (__cdecl *FRotatorCtorFn)(FRotator*, INT, INT, INT);

	FArray* boneArr = (FArray*)((BYTE*)this + 0xB8);
	if (boneArr->Num() > 0)
	{
		SQWORD stamp = *(SQWORD*)((BYTE*)this + 0x64);
		if (stamp < GTicks)
		{
			GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
			void* Owner = GetOwner(this);
			if (Owner)
			{
				UpdateAnimFn UpdateAnim = *(UpdateAnimFn*)((*(BYTE**)this) + 0x110);
				FRotator scratch(0,0,0);
				UpdateAnim(this, &scratch, Owner, 0, 0, 0, 2);
			}
		}
	}
	if (boneArr->Num() == 0 || boneIndex >= (DWORD)boneArr->Num())
	{
		// IAT 0x10529064: FRotator(0,0,0)
		return FRotator(0, 0, 0);
	}
	// boneTransform = this->BoneTransforms[boneIndex] (stride 0x30)
	// result = FCoords(boneTransform) * this->WorldTransform (at this+0xC4)
	// then extract rotation from that combined FCoords
	// IAT 0x1052919c: load FCoords from bone array element (bone elem is at offset 0x30 apart)
	// IAT 0x10529384: FCoords multiply: combined = boneCoords * worldTransform
	// IAT 0x10529388: FCoords.Rotation() -> FRotator
	typedef void  (__cdecl *LoadBoneFn)(void*, void*);
	typedef void  (__cdecl *MulCoordsFn)(void*, void*, void*);
	typedef void  (__cdecl *ExtractRotFn)(void*, void*);
	LoadBoneFn    LoadBone   = *(LoadBoneFn*)   0x1052919c;
	MulCoordsFn   MulCoords  = *(MulCoordsFn*)  0x10529384;
	ExtractRotFn  ExtractRot = *(ExtractRotFn*) 0x10529388;
	BYTE* elem = (BYTE*)(*(BYTE**)boneArr) + boneIndex * 0x30;
	BYTE boneCoords[0x30]; // FCoords is 0x30 bytes (4 FVectors)
	LoadBone(boneCoords, elem);
	BYTE combined[0x30];
	MulCoords(combined, boneCoords, (BYTE*)this + 0xC4);
	FRotator result(0,0,0);
	ExtractRot(&result, combined);
	return result;
}

FRotator USkeletalMeshInstance::GetBoneRotation(FName BoneName, INT Space)
{
	// Retail: 0x133610, 64b. Call MatchRefBone to get index then forward to GetBoneRotation(DWORD,int).
	INT boneIndex = MatchRefBone(BoneName);
	if (boneIndex < 0)
		return FRotator(0, 0, 0);
	return GetBoneRotation((DWORD)boneIndex, Space);
}

FVector USkeletalMeshInstance::GetRootLocation()
{
	// Disasm: 0x12F8F0, 96b.
	// If root motion lock (this+0x228) is set AND owner (vtbl[0x84/4]) is non-null:
	//   call vtbl[0x110/4](this, outVec, owner, 0,0,0, 3) to fill root motion data,
	//   then copy this+0x1C8 (root location cache) to output.
	// Else return zero vector.
	if (!*(INT*)((BYTE*)this + 0x228)) return FVector(0,0,0);
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
	if (!GetOwner(this)) return FVector(0,0,0);
	// Return cached root location at this+0x1C8
	return *(FVector*)((BYTE*)this + 0x1C8);
}

FVector USkeletalMeshInstance::GetRootLocationDelta()
{
	// Disasm: 0x133790, 288b.
	// 1. Guard: root motion lock (this+0x228) set AND GetOwner vtable non-null.
	// 2. Call vtbl[0x110/4] to refresh root motion caches.
	// 3. delta = current location (this+0x1C8) - prev location (this+0x1E0).
	// 4. Update prev cache to current.
	// 5. If this+0x22C != 0, call LockRootMotion(this+0x100, 1).
	if (!*(INT*)((BYTE*)this + 0x228)) return FVector(0,0,0);
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
	if (!GetOwner(this)) return FVector(0,0,0);
	// Trigger root motion update (vtbl slot 0x110/4 = UpdateAnimation-like)
	typedef void (__thiscall *UpdateRootFn)(USkeletalMeshInstance*);
	UpdateRootFn UpdateRoot = *(UpdateRootFn*)((*(BYTE**)this) + 0x110);
	UpdateRoot(this);
	// Compute per-axis deltas
	FLOAT dX = *(FLOAT*)((BYTE*)this + 0x1C8) - *(FLOAT*)((BYTE*)this + 0x1E0);
	FLOAT dY = *(FLOAT*)((BYTE*)this + 0x1CC) - *(FLOAT*)((BYTE*)this + 0x1E4);
	FLOAT dZ = *(FLOAT*)((BYTE*)this + 0x1D0) - *(FLOAT*)((BYTE*)this + 0x1E8);
	// Update previous position cache
	*(FLOAT*)((BYTE*)this + 0x1E0) = *(FLOAT*)((BYTE*)this + 0x1C8);
	*(FLOAT*)((BYTE*)this + 0x1E4) = *(FLOAT*)((BYTE*)this + 0x1CC);
	*(FLOAT*)((BYTE*)this + 0x1E8) = *(FLOAT*)((BYTE*)this + 0x1D0);
	// If additional autolock flag set, re-lock root motion
	if (*(INT*)((BYTE*)this + 0x22C))
		LockRootMotion(*(INT*)((BYTE*)this + 0x100), 1);
	return FVector(dX, dY, dZ);
}

FRotator USkeletalMeshInstance::GetRootRotation()
{
	// Disasm: 0x12F950, 96b. Same pattern as GetRootLocation but reads this+0x1D4.
	if (!*(INT*)((BYTE*)this + 0x228)) return FRotator(0,0,0);
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
	if (!GetOwner(this)) return FRotator(0,0,0);
	// Return cached root rotation at this+0x1D4
	return *(FRotator*)((BYTE*)this + 0x1D4);
}

FRotator USkeletalMeshInstance::GetRootRotationDelta()
{
	// Disasm: 0x12F9B0, 224b.
	// 1. Guard: root motion lock (this+0x228) set AND GetOwner vtable non-null.
	// 2. Call vtbl[0x110/4] to refresh root motion caches.
	// 3. Compute Yaw delta = current yaw (this+0x1D4+4) - previous yaw (this+0x1EC+4).
	// 4. Update prev rotation cache (this+0x1EC) = current (this+0x1D4).
	// 5. Return {0, deltaYaw, 0} — retail only extracts Yaw component.
	if (!*(INT*)((BYTE*)this + 0x228)) return FRotator(0,0,0);
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
	if (!GetOwner(this)) return FRotator(0,0,0);
	// Trigger root motion update
	typedef void (__thiscall *UpdateRootFn)(USkeletalMeshInstance*);
	UpdateRootFn UpdateRoot = *(UpdateRootFn*)((*(BYTE**)this) + 0x110);
	UpdateRoot(this);
	// Read current and previous rotations
	FRotator Current = *(FRotator*)((BYTE*)this + 0x1D4);
	FRotator Prev    = *(FRotator*)((BYTE*)this + 0x1EC);
	// Update previous rotation cache
	*(FRotator*)((BYTE*)this + 0x1EC) = Current;
	// Return yaw-only delta (retail zeroes Pitch and Roll)
	return FRotator(0, Current.Yaw - Prev.Yaw, 0);
}

FCoords USkeletalMeshInstance::GetTagCoords(FName TagName)
{
	// Retail: 0x135BF0, 120b.
	// 1) Search mesh's tag name array (mesh+0x2D0) for TagName → tag found flag.
	//    (Internal helper FUN_10433680 does GetMesh + search + returns found FName)
	// 2) Call MatchRefBone(TagName) → boneIndex.
	// 3) If boneIndex >= 0 AND bone array (this+0xB8) has entries AND boneIndex in range:
	//    multiply bone transform[boneIndex] by world transform (this+0xC4) via IAT 0x10529384.
	//    Return that FCoords.
	// 4) Else: return identity FCoords from global constant.
	INT boneIndex = MatchRefBone(TagName);
	FArray* boneArr = (FArray*)((BYTE*)this + 0xB8);
	if (boneIndex >= 0 && boneArr->Num() > 0 && boneIndex < boneArr->Num())
	{
		typedef void (__cdecl *MulCoordsFn)(void*, void*, void*);
		MulCoordsFn MulCoords = *(MulCoordsFn*)0x10529384;
		BYTE* elem = (BYTE*)(*(BYTE**)boneArr) + boneIndex * 0x30;
		FCoords result;
		MulCoords(&result, elem, (BYTE*)this + 0xC4);
		return result;
	}
	return FCoords();
}

FCoords USkeletalMeshInstance::GetTagPosition(FName TagName)
{
	// Retail: 0x133700, ~140b.
	// GetMesh(), search mesh's tag name array (mesh+0x2D0) for matching FName.
	// Each tag FName stored as 4-byte entries; positions at mesh+0x2E8 stride 12 (FVector, 0x30/idx).
	// If tag found: copy that entry's position (mesh+0x2E8 + idx*0x30) as FVector.
	// Else: return zero FVector as FCoords origin.
	typedef BYTE* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh(this);
	FCoords result;
	if (Mesh)
	{
		FArray* TagNames = (FArray*)(Mesh + 0x2D0);
		INT Count = TagNames->Num();
		FName* NameData = *(FName**)TagNames;
		for (INT i = 0; i < Count; i++)
		{
			if (NameData[i] == TagName)
			{
				// Tag position is at mesh+0x2E8, stride 0x30 per entry, FVector at start
				BYTE* TagPos = *(BYTE**)(Mesh + 0x2E8) + i * 0x30;
				result.Origin = *(FVector*)TagPos;
				return result;
			}
		}
	}
	return result;
}

int USkeletalMeshInstance::StopAnimating(int bClearAll)
{
	// Retail: 0x135800. Clear animation play state for all channels.
	// Sets rate (elem+0x0C), tween (elem+0x18), and notifier (elem+0x50) to 0.
	// If bClearAll: also empty blend shape arrays, clear channels 1+ names to None.
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	INT count = arr->Num();
	for (INT i = 0; i < count; i++) {
		BYTE* elem = (BYTE*)(*(INT*)arr) + i * 0x74;
		*(INT*)(elem + 0x0C) = 0;
		*(INT*)(elem + 0x18) = 0;
		*(INT*)(elem + 0x50) = 0;
	}
	if (bClearAll) {
		((FArray*)((BYTE*)this + 0x124))->Empty(0x40);
		((FArray*)((BYTE*)this + 0x130))->Empty(0x40);
		UObject* owner = (*(UObject* (__thiscall**)(USkeletalMeshInstance*))((*(void***)this)[0x84 / sizeof(void*)]))(this);
		INT keepShape = owner && owner->IsA(APawn::StaticClass()) && *(INT*)((BYTE*)owner + 0x3A4) == 0xB14E;
		if (!keepShape)
			((FArray*)((BYTE*)this + 0x118))->Empty(0x3C);
		FName none(NAME_None);
		count = arr->Num();
		for (INT i = 1; i < count; i++) {
			BYTE* elem = (BYTE*)(*(INT*)arr) + i * 0x74;
			*(INT*)(elem + 0x50) = 0;
			*(FName*)(elem + 0x08) = none;
		}
	}
	return 1;
}

int USkeletalMeshInstance::UpdateAnimation(float)
{
	return 0;
}

void USkeletalMeshInstance::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void USkeletalMeshInstance::Serialize(FArchive& Ar)
{
	// Retail: 0x10438750. Calls ULodMeshInstance::Serialize, then serializes animation-
	// channel TArray (+0x10C), bone scale/pos/rot TArrays (+0x118, +0x124), scalar fields
	// at +0x104 and +0x108, bone coordinate caches (+0x150, +0x15C, +0x168, +0x190, +0x19C),
	// and AnimObjects TArray (+0xB8). Helpers for TArray types are internal addresses.
	// Divergence: simplified to calling base class; per-field data regenerated at runtime.
	ULodMeshInstance::Serialize(Ar);
	if (!Ar.IsLoading())
	{
		// Serialize two scalar cache fields (+0x104: active vert stream size, +0x108: flags)
		Ar.Serialize((BYTE*)this + 0x104, 4);
		Ar.Serialize((BYTE*)this + 0x108, 4);
	}
}

void USkeletalMeshInstance::SetAnimFrame(INT Channel, FLOAT Frame)
{
	// Retail: 96b SEH. Bounds-checks Channel against TArray count at this+0x10C,
	// then stores Frame (float) into channel element at Data + Channel*0x74 + 0x10.
	if (Channel < 0) return;
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return;
	BYTE* data = *(BYTE**)(seqBase);
	*(FLOAT*)(data + Channel * 0x74 + 0x10) = Frame;
}

void USkeletalMeshInstance::SetMesh(UMesh* NewMesh)
{
	// Disasm: 0x135AA0, ~60b.
	// Store mesh pointer at this+0x58, empty animation/bone caches, notify.
	*(UMesh**)((BYTE*)this + 0x58) = NewMesh;
	// Empty bone transform and blend arrays
	((FArray*)((BYTE*)this + 0x150))->Empty(0x10);
	((FArray*)((BYTE*)this + 0x15C))->Empty(0x0C);
	((FArray*)((BYTE*)this + 0xB8))->Empty(0x30);
	((FArray*)((BYTE*)this + 0x118))->Empty(0x3C);
	((FArray*)((BYTE*)this + 0x124))->Empty(0x40);
	((FArray*)((BYTE*)this + 0x130))->Empty(0x40);
	// If mesh is non-null, trigger ActualizeAnimLinkups notification
	if (NewMesh)
	{
		typedef void (__thiscall *NotifyFn)(USkeletalMeshInstance*);
		NotifyFn Notify = *(NotifyFn*)((*(BYTE**)this) + 0x128);
		Notify(this);
	}
}

void USkeletalMeshInstance::SetScale(FVector Scale)
{
	// Disasm: 0x130E40, 96b.
	// Get mesh via vtbl[0x8C/4], write Scale to mesh+0x7C,
	// then ensure mesh+0x84 (some float, likely DrawScale) is non-negative.
	typedef BYTE* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh_fn = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh_fn(this);
	if (!Mesh) return;
	*(FVector*)(Mesh + 0x7C) = Scale;
	// Abs-value the draw scale at mesh+0x84
	FLOAT* DrawScale = (FLOAT*)(Mesh + 0x84);
	if (*DrawScale < 0.0f) *DrawScale = -*DrawScale;
}

int USkeletalMeshInstance::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

void USkeletalMeshInstance::MeshSkinVertsCallback(void *)
{
}

int USkeletalMeshInstance::PlayAnim(INT Channel, FName SeqName, FLOAT Rate, FLOAT TweenTime, INT bLooping, INT bLoopLast, INT bIdle)
{
	// Retail: 0x131D50, ~700b. Faithfully decompiled from Ghidra.
	// bLooping: loop the animation. bLoopLast: stored at elem+0x40 (bIdle field).
	// bIdle: if non-zero, use Rate directly; otherwise scale Rate by rateScale.
	typedef void*  (__thiscall *GetAnimNamedFn)(USkeletalMeshInstance*, FName);
	typedef BYTE*  (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	typedef void*  (__thiscall *FindAnimObjFn)(USkeletalMeshInstance*, FName);
	typedef FLOAT  (__thiscall *GetFrameCountFn)(USkeletalMeshInstance*, void*);
	typedef FLOAT  (__thiscall *GetActiveRateFn)(USkeletalMeshInstance*, void*);
	typedef INT    (__thiscall *IsLoopingFn)(USkeletalMeshInstance*, void*);
	typedef INT    (__cdecl   *FindAnimSlotFn)(FArray*, void*);
	typedef FLOAT  (__cdecl   *TweenRateFn)(FLOAT, FLOAT);

	if (Channel < 0 || !ValidateAnimChannel(Channel))
		return 0;

	BYTE* vtbl = *(BYTE**)this;
	GetAnimNamedFn GetAnimNamed    = *(GetAnimNamedFn*) (vtbl + 0xB0);
	GetOwnerFn     GetOwner        = *(GetOwnerFn*)     (vtbl + 0x84);
	FindAnimObjFn  FindAnimObjForSeq = *(FindAnimObjFn*)(vtbl + 0x12C);
	GetFrameCountFn GetFrameCount  = *(GetFrameCountFn*)(vtbl + 0xC0);
	GetActiveRateFn GetActiveRate  = *(GetActiveRateFn*)(vtbl + 0xC4);
	IsLoopingFn    IsLooping       = *(IsLoopingFn*)    (vtbl + 0xC8);

	void* seqObj = GetAnimNamed(this, SeqName);
	if (!seqObj) return 0;

	BYTE* owner = GetOwner(this);
	if (!owner) return 0;

	void* seqObj2 = FindAnimObjForSeq(this, SeqName);
	if (!seqObj2) return 0;

	FindAnimSlotFn FindAnimSlot = (FindAnimSlotFn)0x10431D00;
	INT slotIdx = FindAnimSlot((FArray*)((BYTE*)this + 0xAC), seqObj2);

	BYTE* elem = (BYTE*)(*(BYTE**)((BYTE*)this + 0x10C)) + Channel * 0x74;
	*(INT*)(elem + 0x04) = slotIdx;

	if (bLooping)
	{
		// Looping path
		FLOAT frameCount = GetFrameCount(this, seqObj);
		if (frameCount <= 0.0f) return 0;
		FLOAT nativeRate = GetActiveRate(this, seqObj);

		// Continuation: same anim, already playing, still animating
		if (*(FName*)(elem + 0x08) == SeqName && *(INT*)(elem + 0x30) && IsAnimating(Channel))
		{
			FLOAT rateScale = nativeRate / frameCount;
			*(FLOAT*)(elem + 0x20) = rateScale;
			*(FLOAT*)(elem + 0x0C) = bIdle ? Rate : rateScale * Rate;
			*(INT*)(elem + 0x2C) = 0;
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			return 1;
		}

		// New looping animation
		FLOAT invFC = 1.0f / frameCount;
		*(FName*)(elem + 0x08) = SeqName;
		FLOAT rateScale = invFC * nativeRate;
		*(FLOAT*)(elem + 0x20) = rateScale;
		*(FLOAT*)(elem + 0x0C) = bIdle ? Rate : rateScale * Rate;
		*(FLOAT*)(elem + 0x14) = 1.0f - invFC;
		INT looping = IsLooping(this, seqObj);
		*(INT*)(elem + 0x40) = bLoopLast;
		*(INT*)(elem + 0x2C) = 0;
		*(INT*)(elem + 0x30) = 1;
		*(INT*)(elem + 0x34) = looping ? 1 : 0;

		FLOAT endFrame = *(FLOAT*)(elem + 0x14);
		if (endFrame != 0.0f)
		{
			// Has end frame: single-shot tween
			*(INT*)(elem + 0x34) = 0;
			*(INT*)(elem + 0x1C) = 0;
			if (TweenTime <= 0.0f)
			{
				*(FLOAT*)(elem + 0x18) = 10.0f;
				*(INT*)(elem + 0x0C)   = 0;
				*(INT*)(elem + 0x1C)   = 0;
				*(FLOAT*)(elem + 0x10) = -invFC;
				return 1;
			}
			*(INT*)(elem + 0x0C)   = 0;
			*(INT*)(elem + 0x1C)   = 0;
			*(FLOAT*)(elem + 0x18) = 1.0f / TweenTime;
			*(FLOAT*)(elem + 0x10) = -invFC;
			return 1;
		}

		// endFrame == 0: continuous loop with tween
		if (TweenTime > 0.0f)
		{
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			*(FLOAT*)(elem + 0x18) = 1.0f / (frameCount * TweenTime);
			*(FLOAT*)(elem + 0x10) = -invFC;
			return 1;
		}
		if (TweenTime == -1.0f)
		{
			*(DWORD*)(elem + 0x10) = 0x38d1b717u; // tiny positive float (~1e-4)
			*(INT*)(elem + 0x18)   = 0;
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			return 1;
		}
		*(FLOAT*)(elem + 0x10) = -invFC;
		FLOAT curTween = *(FLOAT*)(elem + 0x1C);
		if (curTween > 0.0f)
		{
			*(FLOAT*)(elem + 0x18) = curTween;
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			return 1;
		}
		if (curTween >= 0.0f) // == 0.0f
		{
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			*(FLOAT*)(elem + 0x18) = 1.0f / (frameCount * 0.025f);
			return 1;
		}
		// curTween < 0: speed-based tween
		FLOAT ownerSpeed = ((FVector*)(owner + 0x24C))->Size();
		TweenRateFn CalcTwRate = (TweenRateFn)0x103808E0;
		*(FLOAT*)(elem + 0x18) = CalcTwRate(*(FLOAT*)(elem + 0x0C) * 0.5f, ownerSpeed * curTween * -1.0f);
		*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
		return 1;
	}
	else
	{
		// Non-looping path
		if (Rate <= 0.0f)
		{
			if (Rate < 0.0f) return 0; // negative rate: fail
			// Rate == 0.0: play at native rate, freeze at end
			FLOAT frameCount = GetFrameCount(this, seqObj);
			FLOAT nativeRate = GetActiveRate(this, seqObj);
			if (frameCount <= 0.0f) return 0;
			*(FName*)(elem + 0x08) = SeqName;
			*(INT*)(elem + 0x14)   = 0;
			*(INT*)(elem + 0x34)   = 0;
			*(INT*)(elem + 0x2C)   = 0;
			*(INT*)(elem + 0x30)   = 0;
			*(INT*)(elem + 0x0C)   = 0;
			*(INT*)(elem + 0x1C)   = 0;
			*(FLOAT*)(elem + 0x20) = nativeRate / frameCount;
			if (TweenTime <= 0.0f)
			{
				*(INT*)(elem + 0x18) = 0;
				*(INT*)(elem + 0x10) = 0;
			}
			else
			{
				*(FLOAT*)(elem + 0x18) = 1.0f / (frameCount * TweenTime);
				*(FLOAT*)(elem + 0x10) = -(1.0f / frameCount);
			}
			return 1;
		}

		// Rate > 0: normal non-looping play
		FLOAT frameCount = GetFrameCount(this, seqObj);
		if (frameCount <= 0.0f) return 0;
		*(FName*)(elem + 0x08) = SeqName;
		FLOAT nativeRate = GetActiveRate(this, seqObj);
		FLOAT invFC = 1.0f / frameCount;
		*(FLOAT*)(elem + 0x20) = invFC * nativeRate;
		*(FLOAT*)(elem + 0x0C) = bIdle ? Rate : invFC * nativeRate * Rate;
		*(FLOAT*)(elem + 0x14) = 1.0f - invFC;
		INT looping = IsLooping(this, seqObj);
		*(INT*)(elem + 0x40) = bLoopLast;
		*(INT*)(elem + 0x2C) = 0;
		*(INT*)(elem + 0x30) = 0;
		*(INT*)(elem + 0x34) = looping ? 1 : 0;

		FLOAT endFrame = *(FLOAT*)(elem + 0x14);
		if (endFrame == 0.0f)
		{
			// Single frame
			if (TweenTime > 0.0f)
			{
				*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
				*(FLOAT*)(elem + 0x18) = 1.0f / (frameCount * TweenTime);
				*(FLOAT*)(elem + 0x10) = -invFC;
				return 1;
			}
			if (TweenTime == -1.0f)
			{
				*(DWORD*)(elem + 0x10) = 0x3a83126fu; // ~0.001f
				*(INT*)(elem + 0x18)   = 0;
				*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
				return 1;
			}
			*(FLOAT*)(elem + 0x10) = -invFC;
			FLOAT curTween = *(FLOAT*)(elem + 0x1C);
			if (curTween > 0.0f)
			{
				*(FLOAT*)(elem + 0x18) = curTween;
				*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
				return 1;
			}
			if (curTween >= 0.0f) // == 0.0f
			{
				*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
				*(FLOAT*)(elem + 0x18) = 1.0f / (frameCount * 0.025f);
				return 1;
			}
			// curTween < 0
			FLOAT ownerSpeed = ((FVector*)(owner + 0x24C))->Size();
			TweenRateFn CalcTwRate = (TweenRateFn)0x103808E0;
			*(FLOAT*)(elem + 0x18) = CalcTwRate(*(FLOAT*)(elem + 0x0C) * 0.5f, ownerSpeed * curTween * -1.0f);
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			return 1;
		}

		// endFrame != 0: multi-frame non-looping
		*(INT*)(elem + 0x34) = 0;
		*(INT*)(elem + 0x1C) = 0;
		if (TweenTime <= 0.0f)
		{
			*(FLOAT*)(elem + 0x18) = 10.0f;
			*(INT*)(elem + 0x0C)   = 0;
			*(INT*)(elem + 0x1C)   = 0;
			*(FLOAT*)(elem + 0x10) = -invFC;
			return 1;
		}
		*(INT*)(elem + 0x0C)   = 0;
		*(INT*)(elem + 0x1C)   = 0;
		*(FLOAT*)(elem + 0x18) = 1.0f / TweenTime;
		*(FLOAT*)(elem + 0x10) = -invFC;
		return 1;
	}
}

int USkeletalMeshInstance::ActiveVertStreamSize()
{
	// Disasm: 0x133960, 48b.
	// Gets LODIndex from this+0x104, then gets mesh via vtbl[0x8C/4].
	// Returns *(INT*)(mesh->LODMeshes.Data + LODIndex * 0x11C + 0x18).
	INT LODIdx = *(INT*)((BYTE*)this + 0x104);
	typedef BYTE* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh(this);
	if (!Mesh) return 0;
	BYTE* LODData = *(BYTE**)(Mesh + 0x1AC);  // mesh.LODMeshes TArray data ptr
	return *(INT*)(LODData + LODIdx * 0x11C + 0x18);
}

void USkeletalMeshInstance::ActualizeAnimLinkups()
{
	// Retail: 0x135A30. Iterates AnimObjects TArray at this+0xAC (stride 0x18).
	// For each slot where anim ptr (slot+0) is non-null and slot+4 differs from
	// this->mesh (+0x58), calls FUN_10435900(mesh, anim, slot+0x0C) to rebuild
	// the bone channel linkup table, then stamps slot+4 = mesh.
	typedef void (__cdecl *LinkupFn)(INT mesh, INT anim, void* out);
	LinkupFn Linkup = (LinkupFn)0x10435900;
	FArray* arr = (FArray*)((BYTE*)this + 0xAC);
	INT count = arr->Num();
	for (INT i = 0; i < count; i++)
	{
		BYTE* slot = (BYTE*)(*(INT*)arr) + i * 0x18;
		INT anim = *(INT*)slot;
		INT mesh = *(INT*)((BYTE*)this + 0x58);
		if (anim != 0 && *(INT*)(slot + 4) != mesh)
		{
			Linkup(mesh, anim, slot + 0x0C);
			*(INT*)(slot + 4) = mesh;
		}
	}
}

int USkeletalMeshInstance::AnimForcePose(FName,float,float,int)
{
	return 0;
}

float USkeletalMeshInstance::AnimGetFrameCount(void* Channel)
{
	// Retail: 14b. Returns float of int frame count at Channel+0x14. Checks Channel != NULL.
	if (!Channel) return 0.0f;
	return (FLOAT)(*(INT*)((BYTE*)Channel + 0x14));
}

FName USkeletalMeshInstance::AnimGetGroup(void* Channel)
{
	// Retail: 34b. Check *(Channel+4) is non-null via IAT guard, then double-deref to get FName.Index.
	// Same bytecode as UVertMeshInstance::AnimGetGroup.
	FName result;
	if (*(void**)((BYTE*)Channel + 4))
		*(INT*)&result = *(INT*)*(void**)((BYTE*)Channel + 4);
	return result;
}

FName USkeletalMeshInstance::AnimGetName(void* Channel)
{
	// Retail: 19b. Null-check Channel, then double-deref: FName.Index = *(*(Channel+0)).
	// Channel[0] is a pointer to an animation state struct; its first DWORD is FName.Index.
	FName result;
	if (Channel)
		*(INT*)&result = *(INT*)*(void**)Channel;
	return result;
}

int USkeletalMeshInstance::AnimGetNotifyCount(void* Channel)
{
	// Retail: 20b. Null-checks Channel (returns 0 via fallthrough into next func), then
	// reads Num of TArray<FMeshAnimNotify> at Channel+0x1C (Num is at Channel+0x20).
	if (!Channel) return 0;
	return *(INT*)((BYTE*)Channel + 0x20);
}

UAnimNotify * USkeletalMeshInstance::AnimGetNotifyObject(void* Channel, int notifyIndex)
{
	// Retail: 25b. Same as VertMesh but with null check on Channel.
	// Notify array pointer at Channel+0x1C, 12 bytes/entry, ptr at entry+8.
	if (!Channel) return NULL;
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	return *(UAnimNotify**)(notifyArray + notifyIndex * 12 + 8);
}

const TCHAR* USkeletalMeshInstance::AnimGetNotifyText(void* Channel, INT notifyIndex)
{
	// Retail: 31b. Null-checks Channel (null->returns NULL via fallthrough), then reads FName at
	// notify entry+4 and returns FName string via operator*. Same layout as UVertMeshInstance.
	if (!Channel) return NULL;
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	FName name = *(FName*)(notifyArray + notifyIndex * 12 + 4);
	return *name;
}

float USkeletalMeshInstance::AnimGetNotifyTime(void* Channel, INT notifyIndex)
{
	// Retail: 24b. Null-check Channel; returns time float at notify_array[notifyIndex*12] (entry+0).
	if (!Channel) return 0.0f;
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	return *(FLOAT*)(notifyArray + notifyIndex * 12);
}

float USkeletalMeshInstance::AnimGetRate(void* Channel)
{
	// Retail: 14b. Returns float rate from Channel+0x18, or 0.0f if Channel NULL.
	if (!Channel) return 0.0f;
	return *(FLOAT*)((BYTE*)Channel + 0x18);
}

int USkeletalMeshInstance::AnimIsInGroup(void* Channel, FName GroupName)
{
	// Retail: 37b. Has direct call — not fully implemented (complex relative call).
	return 0;
}

int USkeletalMeshInstance::AnimStopLooping(INT channel)
{
	// Retail: 104b (SEH). TArray at this+0x10C, stride 0x74=116b.
	// Clears loop flag at element+0x30 and element+0x2C, returns 1.
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (count <= channel || channel < 0) return 0;
	BYTE* data = *(BYTE**)(seqBase);
	BYTE* elem = data + channel * 0x74;
	*(INT*)(elem + 0x30) = 0;
	*(INT*)(elem + 0x2C) = 0;
	return 1;
}

void USkeletalMeshInstance::ClearChannel(INT Channel)
{
	// Retail: 0x132500, 141b. If Channel is within the channel TArray (this+0x10C,
	// stride 0x74), reset the slot: sequence name→NAME_None, frame/rate/tween/etc→0.
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel < 0 || Channel >= arr->Num())
		return;
	BYTE* elem = (BYTE*)(*(INT*)arr) + Channel * 0x74;
	*(FName*)(elem + 0x08) = FName(NAME_None);
	*(INT*)(elem + 0x10) = 0;  // frame
	*(INT*)(elem + 0x0C) = 0;  // rate
	*(INT*)(elem + 0x18) = 0;  // tween
	*(INT*)(elem + 0x50) = 0;  // notifier
	*(INT*)(elem + 0x60) = 0;
	*(INT*)(elem + 0x5C) = 0;
	*(INT*)(elem + 0x38) = 0;  // loop
}

UMeshAnimation* USkeletalMeshInstance::CurrentSkelAnim(INT Channel)
{
	// Bounds check channel
	if (Channel < 0) return NULL;

	// Channels TArray at this+0x10C, stride 0x74
	FArray* ChanArr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= ChanArr->Num()) return NULL;

	// Read anim slot index from channel elem+4
	BYTE* ChanElem = (BYTE*)(*(BYTE**)ChanArr) + Channel * 0x74;
	INT AnimSlotIdx = *(INT*)(ChanElem + 4);
	if (AnimSlotIdx < 0) return NULL;

	// Look up anim pointer in this->AnimObjects (this+0xAC, stride 0x18)
	FArray* AnimArr = (FArray*)((BYTE*)this + 0xAC);
	if (AnimSlotIdx >= AnimArr->Num()) return NULL;

	UMeshAnimation* Anim = *(UMeshAnimation**)((BYTE*)(*(BYTE**)AnimArr) + AnimSlotIdx * 0x18);
	if (Anim) return Anim;

	// Fallback: vtbl[0x8C/4] to get mesh, return mesh's default anim at mesh+0x1DC
	typedef void* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	void* MeshPtr = GetMesh(this);
	if (!MeshPtr) return NULL;
	return *(UMeshAnimation**)((BYTE*)MeshPtr + 0x1DC);
}

void USkeletalMeshInstance::Destroy()
{
	// Retail: 0x12f640. Calls FUN_10367df0(this) to release bone geometry arrays
	// (TArrays at this+0x308 and this+0x314 — cached transform/ref lists), then
	// calls UObject::Destroy for the UObject cleanup chain.
	typedef void (__thiscall *CleanupFn)(USkeletalMeshInstance*);
	((CleanupFn)0x10367df0)(this);
	UObject::Destroy();
}

UMeshAnimation* USkeletalMeshInstance::FindAnimObjectForSequence(FName SeqName)
{
	// Disasm: 0x132A50, 112b.
	// 1. Call FUN_10432640 (RefreshAnimObjects) to ensure this->AnimObjects is populated
	// 2. Iterate AnimObjects TArray at this+0xAC (stride 0x18), for each non-null anim:
	//    call vtbl[0x64/4=25](anim, SeqName) — UMeshAnimation::FindAnimSeq(FName)
	//    if non-null result return anim
	// 3. Ensure populated first
	typedef void (__thiscall *RefreshFn)(USkeletalMeshInstance*);
	// RefreshAnimObjects is internal (not exported), call it only if array is empty
	// We cannot call it by address portably, so we check manually and skip if non-empty
	FArray* AnimArr = (FArray*)((BYTE*)this + 0xAC);
	INT Count = AnimArr->Num();
	if (Count <= 0) return NULL;  // Can't refresh without calling internal fn

	BYTE* Data = *(BYTE**)AnimArr;
	for (INT i = 0; i < Count; i++)
	{
		BYTE* Slot = Data + i * 0x18;
		UMeshAnimation* Anim = *(UMeshAnimation**)Slot;
		if (!Anim) continue;

		// vtbl[0x64/4=25](Anim, SeqName) — FindAnimSeq on UMeshAnimation
		typedef void* (__thiscall *FindSeqFn)(UMeshAnimation*, FName);
		FindSeqFn FindSeq = *(FindSeqFn*)((*(BYTE**)Anim) + 0x64);
		if (FindSeq(Anim, SeqName)) return Anim;
	}
	return NULL;
}

int USkeletalMeshInstance::FreezeAnimAt(FLOAT Frame, INT Channel)
{
	// Disasm: 0x131040, 200b.
	// Freezes a channel at a normalised frame position.
	// 1. Bounds-check Channel.
	// 2. Get sequence name from channel+8, call GetAnimNamed to get seq object.
	// 3. GetAnimFrameCount(seqObj) to get natural frame count.
	// 4. Normalise Frame by frameCount; clamp to [0, frameCount].
	// 5. Store at elem+0x10 (current frame), zero rate and tween.
	if (Channel < 0) return 0;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num()) return 0;
	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	FName SeqName = *(FName*)(elem + 8);

	typedef void* (__thiscall *GetAnimNamedFn)(USkeletalMeshInstance*, FName);
	GetAnimNamedFn GetAnimNamed_fn = *(GetAnimNamedFn*)((*(BYTE**)this) + 0xB0);
	void* SeqObj = GetAnimNamed_fn(this, SeqName);

	// Get frame count; normalise Frame if frameCount > 0
	typedef FLOAT (__thiscall *GetFrameCountFn)(USkeletalMeshInstance*, void*);
	GetFrameCountFn GetFrameCount = *(GetFrameCountFn*)((*(BYTE**)this) + 0xC0);
	FLOAT FrameCount = GetFrameCount(this, SeqObj);
	FLOAT NormFrame = Frame;
	if (FrameCount != 0.0f)
		NormFrame = Frame / FrameCount;
	// Clamp to [0, frameCount]
	if (NormFrame < 0.0f) NormFrame = 0.0f;
	if (NormFrame > FrameCount && FrameCount > 0.0f) NormFrame = FrameCount;
	// Freeze: set frame, zero rate and tween
	*(FLOAT*)(elem + 0x10) = NormFrame;
	*(INT*)(elem + 0x0C) = 0;
	*(INT*)(elem + 0x18) = 0;
	return 1;
}

float USkeletalMeshInstance::GetActiveAnimFrame(INT Channel)
{
	// Retail: 93b (SEH). TArray at this+0x10C, stride 0x74=116b, frame float at element+0x10.
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (count <= Channel || Channel < 0) return 0.0f;
	BYTE* data = *(BYTE**)(seqBase);
	return *(FLOAT*)(data + Channel * 0x74 + 0x10);
}

float USkeletalMeshInstance::GetActiveAnimRate(INT Channel)
{
	// Retail: 93b (SEH). Same TArray at this+0x10C (stride 0x74=116b), rate float at element+0x0C.
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (count <= Channel || Channel < 0) return 0.0f;
	BYTE* data = *(BYTE**)(seqBase);
	return *(FLOAT*)(data + Channel * 0x74 + 0x0C);
}

FName USkeletalMeshInstance::GetActiveAnimSequence(INT Channel)
{
	// Retail: 98b SEH. Reads FName from channel element+0x08 in TArray at this+0x10C.
	// Returns NAME_None if Channel < 0 or Channel >= count.
	if (Channel < 0) return FName(NAME_None);
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return FName(NAME_None);
	BYTE* data = *(BYTE**)(seqBase);
	return *(FName*)(data + Channel * 0x74 + 0x08);
}

int USkeletalMeshInstance::GetAnimCount()
{
	// Retail: 0x132810. Iterate anim object slots in TArray at this+0xAC (stride 0x18).
	// Each slot has a UMeshAnimation* at slot+0 and a sequence TArray at anim+0x48.
	// Sum the count of sequences across all valid (non-null) animation objects.
	FArray* arr = (FArray*)((BYTE*)this + 0xAC);
	INT total = 0;
	INT count = arr->Num();
	for (INT i = 0; i < count; i++) {
		BYTE* slot = (BYTE*)(*(INT*)arr) + i * 0x18;
		UMeshAnimation* anim = *(UMeshAnimation**)slot;
		if (anim) {
			INT seqs = ((FArray*)((BYTE*)anim + 0x48))->Num();
			total += seqs;
		}
	}
	return total;
}

void * USkeletalMeshInstance::GetAnimIndexed(INT Index)
{
	// Retail: 88b. Calls vtbl[0x130/4=76] with arg 0 to get anim channel array object.
	// Checks count at obj+0x48 TArray; returns Data + Index*0x2C, or NULL if out of range.
	typedef BYTE* (__thiscall *GetChannelFn)(USkeletalMeshInstance*, INT);
	GetChannelFn fn = (GetChannelFn)((*(void***)this)[0x130 / sizeof(void*)]);
	BYTE* obj = fn(this, 0);
	if (!obj) return NULL;
	INT count = *(INT*)(obj + 0x48 + 4);
	if (count <= Index) return NULL;
	obj = fn(this, 0);
	BYTE* data = *(BYTE**)(obj + 0x48);
	return data + Index * 0x2C;
}

void* USkeletalMeshInstance::GetAnimNamed(FName SeqName)
{
	// Retail: 0x1328D0. Calls FUN_10432640 (RefreshAnimObjects) to populate AnimObjects
	// TArray at this+0xAC with the mesh's anim objects. Then iterates each non-null
	// UMeshAnimation* at slot+0 (stride 0x18), searching its sequence TArray at anim+0x48
	// (stride 0x2C, FName at seq+0). Returns the matching sequence pointer, or NULL.
	typedef void (__thiscall *RefreshFn)(USkeletalMeshInstance*);
	((RefreshFn)0x10432640)(this);
	FArray* animArr = (FArray*)((BYTE*)this + 0xAC);
	INT animCount = animArr->Num();
	for (INT ai = 0; ai < animCount; ai++)
	{
		BYTE* slot = (BYTE*)(*(INT*)animArr) + ai * 0x18;
		BYTE* anim = *(BYTE**)slot;
		if (!anim) continue;
		FArray* seqArr = (FArray*)(anim + 0x48);
		INT seqCount = seqArr->Num();
		for (INT si = 0; si < seqCount; si++)
		{
			BYTE* seq = (BYTE*)(*(INT*)seqArr) + si * 0x2C;
			if (*(FName*)seq == SeqName)
				return seq;
		}
	}
	return NULL;
}

void USkeletalMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
}

UMaterial * USkeletalMeshInstance::GetMaterial(int materialIndex, AActor* Actor)
{
	// Retail: 49b. Identical implementation to UVertMeshInstance::GetMaterial.
	// Calls Actor vtable slot 40 twice; returns NULL if Actor null or first call null.
	if (!Actor) return NULL;
	typedef UMaterial* (__thiscall *GetSkinFn)(AActor*, int);
	void** vtbl = *(void***)Actor;
	UMaterial* m = ((GetSkinFn)vtbl[40])(Actor, materialIndex);
	if (!m) return NULL;
	vtbl = *(void***)Actor;
	return ((GetSkinFn)vtbl[40])(Actor, materialIndex);
}

void USkeletalMeshInstance::GetMeshVerts(AActor *,FVector *,int,int &)
{
}

FBox USkeletalMeshInstance::GetRenderBoundingBox(const AActor*)
{
	// Retail: 33b. GetMesh() + copy FBox from mesh+0x2C (cached render bounds).
	return *(FBox*)((BYTE*)GetMesh() + 0x2C);
}

FSphere USkeletalMeshInstance::GetRenderBoundingSphere(const AActor*)
{
	// Retail: 31b. GetMesh() + copy FSphere from mesh+0x48 via ctor.
	return *(FSphere*)((BYTE*)GetMesh() + 0x48);
}

int USkeletalMeshInstance::IsAnimating(int Channel)
{
	// Retail: 0x130FB0, 133 bytes. Returns 1 if the animation channel has a non-None
	// sequence name AND a non-zero rate (either forward elem+0x0C or backward via elem+0x18).
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	INT count = arr->Num();
	if (Channel < 0 || Channel >= count)
		return 0;
	BYTE* elem = (BYTE*)(*(INT*)arr) + Channel * 0x74;
	FName seqName = *(FName*)(elem + 0x08);
	if (seqName == FName(NAME_None))
		return 0;
	if (*(FLOAT*)(elem + 0x10) < 0.0f) {
		// negative frame = tween backward: check elem+0x18 (tween rate)
		if (*(FLOAT*)(elem + 0x18) != 0.0f)
			return 1;
	} else {
		if (*(FLOAT*)(elem + 0x0C) != 0.0f)
			return 1;
	}
	return 0;
}

int USkeletalMeshInstance::IsAnimLooping(INT Channel)
{
	// Retail: 93b (SEH). TArray at this+0x10C, stride 0x74=116b, loop flag (INT) at element+0x30.
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (count <= Channel || Channel < 0) return 0;
	BYTE* data = *(BYTE**)(seqBase);
	return *(INT*)(data + Channel * 0x74 + 0x30);
}

int USkeletalMeshInstance::IsAnimPastLastFrame(INT Channel)
{
	// Retail: 111b (SEH). Compares current frame (element+0x10) with end frame (element+0x14).
	// Returns 1 if current >= end (animation has reached or passed last frame).
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (count <= Channel || Channel < 0) return 0;
	BYTE* data = *(BYTE**)(seqBase);
	BYTE* elem = data + Channel * 0x74;
	return (*(FLOAT*)(elem + 0x10) >= *(FLOAT*)(elem + 0x14)) ? 1 : 0;
}

int USkeletalMeshInstance::IsAnimTweening(int Channel)
{
	// Retail: 0x131110, 117 bytes. Returns 1 if channel's current frame < 0 and vtbl
	// IsAnimating check (vtbl[0xD8/4]) also returns non-zero.
	// TArray at this+0x10C, stride 0x74, frame at elem+0x10.
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	INT count = arr->Num();
	if (Channel < 0 || Channel >= count)
		return 0;
	BYTE* elem = (BYTE*)(*(INT*)arr) + Channel * 0x74;
	if (*(FLOAT*)(elem + 0x10) >= 0.0f)
		return 0;
	typedef INT (__thiscall *AnimCheckFn)(USkeletalMeshInstance*, INT);
	AnimCheckFn fn = (AnimCheckFn)((*(void***)this)[0xD8 / sizeof(void*)]);
	return fn(this, Channel) ? 1 : 0;
}


// --- USkeletalMeshInstance ---
int USkeletalMeshInstance::WasSkeletonUpdated()
{
	// Disasm: 0x12F8B0, 64b.
	// 1. If TArray at this+0xB8 is empty (Num()==0), bone data invalid → return 0.
	// 2. Compare update stamp QWORD at this+0x64 with GTicks-1.
	// 3. Return 1 if updated this tick or last tick.
	if (((FArray*)((BYTE*)this + 0xB8))->Num() == 0) return 0;
	SQWORD UpdateStamp = *(SQWORD*)((BYTE*)this + 0x64);
	return (UpdateStamp >= GTicks - 1) ? 1 : 0;
}

void USkeletalMeshInstance::MeshBuildBounds()
{
}

FMatrix USkeletalMeshInstance::MeshToWorld()
{
	return FMatrix();
}


// --- UVertMeshInstance ---
FMeshAnimSeq * UVertMeshInstance::GetAnimSeq(FName Name)
{
	// Retail: ~90b. Calls vtbl[0x8C/4=35] on this to get the underlying mesh object,
	// then searches TArray at mesh+0x118 (stride 0x2C=44b, FName at element+0).
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	GetMeshFn fn = (GetMeshFn)((*(void***)this)[0x8C / sizeof(void*)]);
	BYTE* mesh = fn(this);
	BYTE* seqBase = mesh + 0x118;
	INT count = *(INT*)(seqBase + 4);
	if (count <= 0) return NULL;
	BYTE* data = *(BYTE**)(seqBase);
	INT i = 0, byteOff = 0;
	while (i < count)
	{
		BYTE* elem = data + byteOff;
		if (*(FName*)elem == Name) return (FMeshAnimSeq*)elem;
		i++;
		byteOff += 0x2C;
		count = *(INT*)(seqBase + 4);
	}
	return NULL;
}

int UVertMeshInstance::StopAnimating(INT Channel)
{
	// Retail: 15b. Clears the animation sequence name (FName) at this+0xB8 and returns 1.
	// Channel argument is ignored (single-channel vertex mesh).
	*(FName*)((BYTE*)this + 0xB8) = FName(NAME_None);
	return 1;
}

int UVertMeshInstance::UpdateAnimation(float)
{
	return 0;
}

void UVertMeshInstance::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void UVertMeshInstance::Serialize(FArchive &)
{
}

void UVertMeshInstance::SetAnimFrame(int, float Frame)
{
	// Retail: 13b. Stores Frame float value at this+0xC0 (ignores channel index).
	*(FLOAT*)((BYTE*)this + 0xC0) = Frame;
}

void UVertMeshInstance::SetScale(FVector)
{
}

int UVertMeshInstance::PlayAnim(int,FName,float,float,int,int,int)
{
	return 0;
}

int UVertMeshInstance::AnimForcePose(FName,float,float,int)
{
	return 0;
}

float UVertMeshInstance::AnimGetFrameCount(void* Channel)
{
	// Retail: 10b. Returns float of int frame count at Channel+0x14 (no null check per retail).
	return (FLOAT)(*(INT*)((BYTE*)Channel + 0x14));
}

FName UVertMeshInstance::AnimGetGroup(void* Channel)
{
	// Retail: 34b. Identical bytecode to USkeletalMeshInstance::AnimGetGroup.
	// Check *(Channel+4) non-null, then double-deref for FName.Index.
	FName result;
	if (*(void**)((BYTE*)Channel + 4))
		*(INT*)&result = *(INT*)*(void**)((BYTE*)Channel + 4);
	return result;
}

FName UVertMeshInstance::AnimGetName(void* Channel)
{
	// Retail: 15b. Copies the FName index (first DWORD) from *Channel to output.
	// Animation name is stored at the start of the animation channel struct.
	FName result;
	*(INT*)&result = *(INT*)Channel;
	return result;
}

int UVertMeshInstance::AnimGetNotifyCount(void* Channel)
{
	// Retail: 16b. Reads Num field of TArray<FMeshAnimNotify> embedded at Channel+0x1C.
	// TArray layout: {Data* at +0, Num at +4}; so count is at Channel+0x20.
	return *(INT*)((BYTE*)Channel + 0x20);
}

UAnimNotify * UVertMeshInstance::AnimGetNotifyObject(void* Channel, int notifyIndex)
{
	// Retail: 21b. Returns UAnimNotify* from packed notify array.
	// Channel+0x1C = pointer to notify array (12 bytes/entry).
	// Notify pointer is at byte offset 8 within each entry.
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	return *(UAnimNotify**)(notifyArray + notifyIndex * 12 + 8);
}

const TCHAR* UVertMeshInstance::AnimGetNotifyText(void* Channel, INT notifyIndex)
{
	// Retail: 27b. Reads FName at notify entry+4, returns FName string via operator*.
	// Entry layout: +0 time (float), +4 FName, +8 UAnimNotify* (stride 12b).
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	FName name = *(FName*)(notifyArray + notifyIndex * 12 + 4);
	return *name;
}

float UVertMeshInstance::AnimGetNotifyTime(void* Channel, INT notifyIndex)
{
	// Retail: 20b. Returns time float from Channel's notify array (stride 12b, float at entry+0).
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	return *(FLOAT*)(notifyArray + notifyIndex * 12);
}

float UVertMeshInstance::AnimGetRate(void* Channel)
{
	// Retail: 10b. Returns float rate from Channel+0x18 (no null check per retail).
	return *(FLOAT*)((BYTE*)Channel + 0x18);
}

int UVertMeshInstance::AnimIsInGroup(void*, FName)
{
	// Retail: 48b. Has complex sub-call — stub returns 0.
	return 0;
}

int UVertMeshInstance::AnimStopLooping(int)
{
	// Retail: 22b. Clears loop flag at this+0xE0 and this+0xDC, returns 1.
	*(INT*)((BYTE*)this + 0xE0) = 0;
	*(INT*)((BYTE*)this + 0xDC) = 0;
	return 1;
}

float UVertMeshInstance::GetActiveAnimFrame(INT Channel)
{
	// Retail: 17b. Returns current frame float from this+0xC0 for channel 0 only.
	// For Channel != 0, retail falls into next function; approximated as return 0.0f.
	if (Channel != 0) return 0.0f;
	return *(FLOAT*)((BYTE*)this + 0xC0);
}

float UVertMeshInstance::GetActiveAnimRate(INT Channel)
{
	// Retail: 17b. Returns animation rate float from this+0xBC for channel 0 only.
	// For Channel != 0, retail falls into next function; approximated as return 0.0f.
	if (Channel != 0) return 0.0f;
	return *(FLOAT*)((BYTE*)this + 0xBC);
}

FName UVertMeshInstance::GetActiveAnimSequence(int sequenceChannelIndex)
{
	// Retail: 23b. Only returns a value for channel index 0 (reads FName.Index from this+0xB8).
	// For index != 0, retail returns uninitialized — we return NAME_None for safety (divergence).
	if (sequenceChannelIndex != 0) return FName(NAME_None);
	FName result;
	*(INT*)&result = *(INT*)((BYTE*)this + 0xB8);
	return result;
}

int UVertMeshInstance::GetAnimCount()
{
	// Retail: 18b. Gets mesh via vtbl[35], returns TArray.Num from TArray at mesh+0x118.
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	GetMeshFn fn = (GetMeshFn)((*(void***)this)[0x8C / sizeof(void*)]);
	BYTE* obj = fn(this);
	return *(INT*)(obj + 0x118 + 4);
}

void * UVertMeshInstance::GetAnimIndexed(INT Index)
{
	// Retail: 34b. Gets mesh via vtbl[35], returns TArray.Data[Index] (stride 0x2C=44b).
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	GetMeshFn fn = (GetMeshFn)((*(void***)this)[0x8C / sizeof(void*)]);
	BYTE* obj = fn(this);
	BYTE* data = *(BYTE**)(obj + 0x118);
	return data + Index * 0x2C;
}

void * UVertMeshInstance::GetAnimNamed(FName Name)
{
	// Retail: ~144b. Gets mesh via vtbl[35], searches TArray at mesh+0x118 (stride 0x2C=44b,
	// FName at element+0). Retail re-calls vtbl[35] per iteration; divergence: we call once.
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	GetMeshFn fn = (GetMeshFn)((*(void***)this)[0x8C / sizeof(void*)]);
	BYTE* obj = fn(this);
	BYTE* tarray = obj + 0x118;
	INT count = *(INT*)(tarray + 4);
	if (count <= 0) return NULL;
	BYTE* data = *(BYTE**)(tarray);
	INT i = 0, byteOff = 0;
	while (i < count)
	{
		BYTE* elem = data + byteOff;
		if (*(FName*)elem == Name) return data + i * 0x2C;
		i++;
		byteOff += 0x2C;
		count = *(INT*)(tarray + 4);
	}
	return NULL;
}

void UVertMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
}

UMaterial * UVertMeshInstance::GetMaterial(int materialIndex, AActor* Actor)
{
	// Retail: 49b. Calls Actor->vtable[40] (GetSkin, vtable offset 0xA0) twice:
	// once to check if skin exists, once to retrieve it. Returns NULL if Actor is
	// null or first call returns NULL.
	if (!Actor) return NULL;
	typedef UMaterial* (__thiscall *GetSkinFn)(AActor*, int);
	void** vtbl = *(void***)Actor;
	UMaterial* m = ((GetSkinFn)vtbl[40])(Actor, materialIndex);
	if (!m) return NULL;
	vtbl = *(void***)Actor;
	return ((GetSkinFn)vtbl[40])(Actor, materialIndex);
}

void UVertMeshInstance::GetMeshVerts(AActor *,FVector *,int,int &)
{
}

FBox UVertMeshInstance::GetRenderBoundingBox(const AActor* Owner)
{
	// Retail: 33b. Same pattern as GetRenderBoundingSphere: get mesh, call mesh's method.
	return GetMesh()->GetRenderBoundingBox(Owner);
}

FSphere UVertMeshInstance::GetRenderBoundingSphere(const AActor*)
{
	// Retail: 84b (SEH). Calls vtbl[35] to get mesh, copies FSphere from mesh+0x48.
	return *(FSphere*)((BYTE*)GetMesh() + 0x48);
}

int UVertMeshInstance::IsAnimating(int Channel)
{
	// Retail: 0x1725d0, 74b. Only channel 0 supported on vertex meshes.
	// If actor (this+0x5C) is set AND channel is 0 AND anim name (this+0xB8) is not NAME_None:
	//   if frame (this+0xC0) < 0 (tweening): return whether tween-rate (this+0xC8) != 0
	//   else: return whether anim-rate (this+0xBC) != 0
	if (!*(INT*)((BYTE*)this + 0x5C) || Channel != 0)
		return 0;
	FName none(NAME_None);
	if (*(FName*)((BYTE*)this + 0xB8) == none)
		return 0;
	if (*(FLOAT*)((BYTE*)this + 0xC0) < 0.0f)
		return (*(FLOAT*)((BYTE*)this + 0xC8) != 0.0f) ? 1 : 0;
	return (*(FLOAT*)((BYTE*)this + 0xBC) != 0.0f) ? 1 : 0;
}

int UVertMeshInstance::IsAnimLooping(int)
{
	// Retail: 9b. Returns loop flag/counter at this+0xE0 (ignores Channel argument).
	return *(INT*)((BYTE*)this + 0xE0);
}

int UVertMeshInstance::IsAnimPastLastFrame(int)
{
	// Retail: 31b (scanner shows 27b, stops at first RETN). Compares frame position
	// (this+0xC0) vs end-frame sentinel (this+0xC4). Returns 1 if frame < end sentinel.
	return (*(FLOAT*)((BYTE*)this + 0xC0) < *(FLOAT*)((BYTE*)this + 0xC4)) ? 1 : 0;
}

int UVertMeshInstance::IsAnimTweening(int)
{
	// Retail: 9b. Returns the tween flag/counter at this+0xE4 (ignores Channel argument).
	// Analogous to IsAnimLooping which reads this+0xE0.
	return *(INT*)((BYTE*)this + 0xE4);
}




// --- UVertMeshInstance ---
void UVertMeshInstance::MeshBuildBounds()
{
}

FMatrix UVertMeshInstance::MeshToWorld()
{
	return FMatrix();
}


// --- AAIController ---
void AAIController::SetAdjustLocation(FVector NewLoc)
{
	bAdjusting = 1;
	AdjustLoc = NewLoc;
}

int AAIController::AcceptNearbyPath(AActor* Goal)
{
	if( Goal && Goal->IsA(ANavigationPoint::StaticClass()) )
		return 1;
	return 0;
}

void AAIController::AdjustFromWall(FVector,AActor *)
{
}


// --- AAIMarker ---
int AAIMarker::IsIdentifiedAs(FName)
{
	return 0;
}


// --- AAIScript ---
void AAIScript::AddMyMarker(AActor *)
{
}


// --- ADoor ---
void ADoor::PostaddReachSpecs(APawn *)
{
}

void ADoor::PostPath()
{
}

void ADoor::PrePath()
{
}

AActor * ADoor::AssociatedLevelGeometry()
{
	// Ghidra 0xd5af0, 7B: return pointer at offset 0x3ec
	return *(AActor**)((BYTE*)this + 0x3ec);
}

void ADoor::FindBase()
{
}

int ADoor::HasAssociatedLevelGeometry(AActor * Other)
{
	// Ghidra 0xd5b20, 45B: walk linked list at 0x3ec, next ptr at 0x3e0
	if (Other)
	{
		for (AActor* Node = *(AActor**)((BYTE*)this + 0x3ec); Node; Node = *(AActor**)((BYTE*)Node + 0x3e0))
		{
			if (Node == Other)
				return 1;
		}
	}
	return 0;
}

void ADoor::InitForPathFinding()
{
}

int ADoor::IsIdentifiedAs(FName)
{
	return 0;
}


// --- AHUD ---
void AHUD::DrawInGameMap(FCameraSceneNode *,UViewport *)
{
}

void AHUD::DrawRadar(FCameraSceneNode *,UViewport *)
{
}

void AHUD::DrawSpecificModeInfo(FCameraSceneNode *,UViewport *)
{
}


// --- AInterpolationPoint ---
void AInterpolationPoint::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AInterpolationPoint::PostEditChange()
{
}

void AInterpolationPoint::PostEditMove()
{
}


// --- AJumpDest ---
void AJumpDest::SetupForcedPath(APawn *,UReachSpec *)
{
}

void AJumpDest::ClearPaths()
{
}


// --- AJumpPad ---
void AJumpPad::addReachSpecs(APawn *,int)
{
}


// --- ALadder ---
void ALadder::addReachSpecs(APawn *,int)
{
}

int ALadder::ProscribedPathTo(ANavigationPoint * Nav)
{
	// Ghidra 0xd7130, 131B: if Nav is ALadder with same MyLadder ptr, proscribed
	if (Nav)
	{
		if (Nav->IsA(ALadder::StaticClass()))
		{
			if (*(INT*)((BYTE*)this + 0x3E8) == *(INT*)((BYTE*)Nav + 0x3E8))
				return 1;
		}
	}
	return ANavigationPoint::ProscribedPathTo(Nav);
}

void ALadder::ClearPaths()
{
	// Ghidra 0xd6a60, 90B: call base, clear ladder reference, zero pointers
	ANavigationPoint::ClearPaths();
	INT* MyLadder = (INT*)((BYTE*)this + 0x3E8);
	if (*MyLadder != 0)
		*(INT*)(*MyLadder + 0x47c) = 0;
	*(INT*)((BYTE*)this + 0x3ec) = 0;
	*MyLadder = 0;
}

void ALadder::InitForPathFinding()
{
}


// --- ALadderVolume ---
void ALadderVolume::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void ALadderVolume::AddMyMarker(AActor *)
{
}

FVector ALadderVolume::FindCenter()
{
	return FVector(0,0,0);
}

FVector ALadderVolume::FindTop(FVector)
{
	return FVector(0,0,0);
}


// --- ALiftCenter ---
void ALiftCenter::addReachSpecs(APawn *,int)
{
}

void ALiftCenter::FindBase()
{
}


// --- ALineOfSightTrigger ---
void ALineOfSightTrigger::TickAuthoritative(float)
{
}


// --- ANote ---
void ANote::CheckForErrors()
{
	// Ghidra 0x980f0: log the Note text via GWarn, then call super.
	FString& noteStr = *(FString*)((BYTE*)this + 0x394);
	GWarn->Logf(TEXT("%s"), *noteStr);
	AActor::CheckForErrors();
}


// --- APathNode ---
int APathNode::ReviewPath(APawn *)
{
	return 0;
}

void APathNode::CheckSymmetry(ANavigationPoint *)
{
}


// --- APlayerController ---
void APlayerController::SpecialDestroy()
{
	// Ghidra (49B): If Player (offset 0x5B4) is a UNetConnection with a Driver,
	// set bPendingDestroy on the Driver's connection info.
	UObject* Player = *(UObject**)((BYTE*)this + 0x5B4);
	if (Player && Player->IsA(UNetConnection::StaticClass()))
	{
		UNetConnection* Conn = (UNetConnection*)Player;
		// Driver at Conn+0x7C
		INT* DriverPtr = (INT*)((BYTE*)Conn + 0x7C);
		if (*DriverPtr != 0)
		{
			// bPendingDestroy at Conn+0x80
			*(INT*)((BYTE*)Conn + 0x80) = 1;
		}
	}
}

int APlayerController::Tick(float,ELevelTick)
{
	return 0;
}

void APlayerController::R6PBKickPlayer(FString)
{
}

void APlayerController::SetPlayer(UPlayer* InPlayer)
{
	// Ghidra 0x7a5c0: bi-directional controller<->player link, init input if viewport.
	if (!InPlayer)
		appFailAssert("InPlayer!=NULL", ".\\UnActor.cpp", 0x760);

	// Clear old player's back-pointer to this controller
	APlayerController* oldActor = *(APlayerController**)((BYTE*)InPlayer + 0x34);
	if (oldActor)
		*(UPlayer**)((BYTE*)oldActor + 0x5B4) = NULL;

	// Establish bidirectional link
	*(UPlayer**)((BYTE*)this + 0x5B4) = InPlayer;
	*(APlayerController**)((BYTE*)InPlayer + 0x34) = this;

	// If InPlayer is a viewport, initialise input system
	if (InPlayer->IsA(UViewport::StaticClass()))
		eventInitInputSystem();

	// Log
	debugf(TEXT("%s"), GetFullName());
}

int APlayerController::LocalPlayerController()
{
	UPlayer* Player = (UPlayer*)_NativeData[50]; // offset 0x5B4
	return Player && Player->IsA(UViewport::StaticClass());
}

void APlayerController::PostNetReceive()
{
}

void APlayerController::PreNetReceive()
{
}

void APlayerController::CheckHearSound(AActor *,int,USound *,FVector,float,int)
{
}

INT* APlayerController::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}

FString APlayerController::GetPlayerNetworkAddress()
{
	// Ghidra shows vtable dispatch to LowLevelGetRemoteAddress on the Player connection.
	UNetConnection* Conn = Cast<UNetConnection>( *(UPlayer**)(&_NativeData[50]) ); // offset 0x5B4
	if( Conn )
		return Conn->LowLevelGetRemoteAddress();
	return FString(TEXT(""));
}

AActor * APlayerController::GetViewTarget()
{
	AActor*& ViewTarget = *(AActor**)(&_NativeData[51]); // offset 0x5B8
	if( !ViewTarget )
	{
		if( Pawn && !Pawn->bDeleteMe && !Pawn->bPendingDelete )
		{
			ViewTarget = Pawn;
			return Pawn;
		}
		ViewTarget = this;
	}
	return ViewTarget;
}

int APlayerController::IsNetRelevantFor(APlayerController* RealViewer,AActor* Viewer,FVector SrcLocation)
{
	if( this == RealViewer )
		return 1;
	return AActor::IsNetRelevantFor( RealViewer, Viewer, SrcLocation );
}


// --- APlayerStart ---
void APlayerStart::addReachSpecs(APawn *,int)
{
}


// --- AScout ---
int AScout::findStart(FVector)
{
	return 0;
}

int AScout::HurtByVolume(AActor *)
{
	return 0;
}

void AScout::InitForPathing()
{
	// Retail: 0xfc9b0, ordinal 3354. Initialises the scout's pathfinding state:
	// - Sets BYTE at this+0x2C to 1 (bPathfinding flag)
	// - Sets this+0x43C = 0x43D20000 (FLOAT 424.0f — max step height)
	// - Sets this+0x3E0 = (existing value & ~0x00020000) | 0x0005C000 (reach flags)
	// - Sets this+0x428 = 0x44160000 (FLOAT 600.0f — jump Z velocity)
	// - Sets this+0x44C = 0x44138000 (FLOAT 590.0f — ground speed)
	*(BYTE*)((BYTE*)this + 0x2C) = 1;
	*(DWORD*)((BYTE*)this + 0x43C) = 0x43D20000;  // 424.0f
	*(DWORD*)((BYTE*)this + 0x3E0) = (*(DWORD*)((BYTE*)this + 0x3E0) & ~0x00020000u) | 0x0005C000u;
	*(DWORD*)((BYTE*)this + 0x428) = 0x44160000;  // 600.0f
	*(DWORD*)((BYTE*)this + 0x44C) = 0x44138000;  // 590.0f
}


// --- AStaticMeshActor ---
int AStaticMeshActor::ShouldTrace(AActor * Other, DWORD TraceFlags)
{
	// Ghidra 0x718b0, 32B: check bCollideActors (bit 1 of flags at 0x398)
	if (TraceFlags & 0x2000)
		return (*(DWORD*)((BYTE*)this + 0x398) >> 1) & 1;
	return AActor::ShouldTrace(Other, TraceFlags);
}


// --- ATeleporter ---
void ATeleporter::addReachSpecs(APawn *,int)
{
}


// --- FOrientation ---
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

FOrientation& FOrientation::operator=(FOrientation Other)
{
	appMemcpy(this, &Other, 0x34);
	return *this;
}

int FOrientation::operator!=(FOrientation const & Other) const
{
	return *(INT*)&_Data[0x18] != *(INT*)&Other._Data[0x18];
}


// --- FRebuildOptions ---
FRebuildOptions::FRebuildOptions(FRebuildOptions const & Other)
	: Name(Other.Name)
{
	appMemcpy(Options, Other.Options, sizeof(Options));
}

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

FRebuildOptions::~FRebuildOptions()
{
	// Name's implicit destructor handles FString cleanup
}

FRebuildOptions FRebuildOptions::operator=(FRebuildOptions Other)
{
	Name = Other.Name;
	appMemcpy(Options, Other.Options, sizeof(Options));
	return *this;
}

FString FRebuildOptions::GetName()
{
	return Name;
}

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
FTags::FTags(FTags const &Other)
{
	// Ghidra 0x2ed0: bitwise copy of first 0x30 bytes (TArrays here are shallow/borrowed), then FString copy at +0x30
	appMemcpy(this, &Other, 0x30);
	new ((BYTE*)this + 0x30) FString(*(const FString*)((const BYTE*)&Other + 0x30));
}

FTags::FTags()
{
	// Zero first 0x30 bytes; initialize owned FString at +0x30 to empty
	appMemzero(this, 0x30);
	new ((BYTE*)this + 0x30) FString();
}

FTags::~FTags()
{
	// Ghidra 0x10302ec0: only ~FString at +0x30; TArrays in first 0x30 bytes are not destructed (shallow/borrowed)
	((FString*)((BYTE*)this + 0x30))->~FString();
}

FTags& FTags::operator=(const FTags& Other)
{
	// Ghidra 0x2f00: 12 DWORDs at +0..+2F (no vtable), then FString at +0x30
	appMemcpy(this, &Other, 0x30);
	*(FString*)((BYTE*)this + 0x30) = *(const FString*)((const BYTE*)&Other + 0x30);
	return *this;
}

void FTags::Init()
{
}


// --- FColor ---
// Note: FBrightness, HiColor565, HiColor555, operator FVector are defined inline in Engine.h (FColor struct).
// Ordinals ?FBrightness@FColor@@QBEMXZ, ?HiColor565@FColor@@QBEGXZ,
//          ?HiColor555@FColor@@QBEGXZ, ??BFColor@@QBE?AVFVector@@XZ


FRotatorF::FRotatorF(FRotator R) : Pitch((FLOAT)R.Pitch), Yaw((FLOAT)R.Yaw), Roll((FLOAT)R.Roll) {}

// ??0FRotatorF@@QAE@MMM@Z
FRotatorF::FRotatorF(float InPitch, float InYaw, float InRoll) : Pitch(InPitch), Yaw(InYaw), Roll(InRoll) {}

// ??0FRotatorF@@QAE@XZ
FRotatorF::FRotatorF() {}

// ??0FSceneNode@@QAE@PAV0@@Z
// Ghidra: copies viewport/matrices/vectors from parent, recalculates determinant
FSceneNode::FSceneNode(FSceneNode * p0)
{
	appMemcpy(((BYTE*)this) + 4, ((BYTE*)p0) + 4, 0x1B4);
}

// ??0FSceneNode@@QAE@ABV0@@Z
// Ghidra: bitwise copy of all fields from 0x04 through 0x1B4
FSceneNode::FSceneNode(FSceneNode const & p0)
{
	appMemcpy(((BYTE*)this) + 4, ((const BYTE*)&p0) + 4, 0x1B4);
}

// ??0FSceneNode@@QAE@PAVUViewport@@@Z
// Ghidra: init 6 FMatrix + 3 FVector, set Viewport, clear Parent/Level
FSceneNode::FSceneNode(UViewport * Viewport)
{
	// Zero-init the data region (0x04 through 0x1B7)
	appMemzero(((BYTE*)this) + 4, 0x1B4);
	// Set viewport at offset 0x04, Parent(0x08)=NULL, Level(0x0C)=0
	*(UViewport**)(((BYTE*)this) + 0x04) = Viewport;
}

// ??0FStatGraph@@QAE@ABV0@@Z
FStatGraph::FStatGraph(FStatGraph const & p0) {}

// ??1FStatGraph@@QAE@XZ
FStatGraph::~FStatGraph() {}

// ??0FURL@@QAE@PAV0@PBGW4ETravelType@@@Z
// Ghidra at 0x171a30. Full URL parser: handles travel types, options, protocol/host/port/map/portal.
FURL::FURL(FURL* Base, const TCHAR* TextURL, ETravelType Type) {
	// Initialize with defaults
	Protocol = DefaultProtocol;
	Host     = DefaultHost;
	Port     = DefaultPort;
	Map      = DefaultMap;
	Portal   = DefaultPortal;
	Valid    = 1;

	check(TextURL);

	// Copy to mutable local buffer
	TCHAR Temp[1024];
	appStrncpy(Temp, TextURL, ARRAY_COUNT(Temp));
	TCHAR* Str = Temp;

	// TRAVEL_Relative: copy URL fields from Base
	if (Type == TRAVEL_Relative) {
		check(Base);
		Protocol = Base->Protocol;
		Host     = Base->Host;
		Map      = Base->Map;
		Portal   = Base->Portal;
		Port     = Base->Port;
	}

	// TRAVEL_Relative and TRAVEL_Partial: copy non-transient options from Base
	if (Type == TRAVEL_Relative || Type == TRAVEL_Partial) {
		check(Base);
		for (INT i = 0; i < Base->Op.Num(); i++) {
			if (appStricmp(*Base->Op(i), TEXT("PUSH"))  != 0
			 && appStricmp(*Base->Op(i), TEXT("POP"))   != 0
			 && appStricmp(*Base->Op(i), TEXT("PEER"))  != 0
			 && appStricmp(*Base->Op(i), TEXT("LOAD"))  != 0
			 && appStricmp(*Base->Op(i), TEXT("QUIET")) != 0)
			{
				new(Op) FString(Base->Op(i));
			}
		}
	}

	// Skip leading spaces
	while (*Str == ' ')
		Str++;

	// Split off options (?) and portal (#)
	TCHAR* OptionStart = appStrchr(Str, '?');
	TCHAR* HashStart   = appStrchr(Str, '#');
	if (OptionStart == NULL || (HashStart != NULL && HashStart <= OptionStart))
		OptionStart = HashStart;

	if (OptionStart != NULL) {
		TCHAR Delim = *OptionStart;
		*OptionStart = 0;
		TCHAR* Token = OptionStart + 1;
		TCHAR  NextDelim = 0;

		do {
			TCHAR* NextQ = appStrchr(Token, '?');
			TCHAR* NextH = appStrchr(Token, '#');
			TCHAR* Next  = NextQ;
			if (Next == NULL || (NextH != NULL && NextH <= Next))
				Next = NextH;

			NextDelim = 0;
			if (Next != NULL) {
				NextDelim = *Next;
				*Next++ = 0;
			}

			// Space in option/portal token invalidates the URL
			if (appStrchr(Token, ' ') != NULL) {
				*this = FURL(NULL);
				Valid = 0;
				return;
			}

			if (Delim == '?')
				AddOption(Token);
			else
				Portal = Token;

			Delim = NextDelim;
			Token = Next;
		} while (Token != NULL);
	}

	// Parse URL structure
	UBOOL bMapChange = 0;
	UBOOL bHasMap    = 0;

	INT StrLen = appStrlen(Str);
	if (StrLen >= 3 && Str[1] == ':') {
		// Drive letter path (e.g., "C:\Maps\MyMap.rsm")
		Protocol = DefaultProtocol;
		Host     = DefaultHost;
		Map      = Str;
		Portal   = DefaultPortal;
		Str      = NULL;
		bMapChange = 1;
		bHasMap    = 1;
		Host       = TEXT("");
	} else {
		// Check for protocol (colon with >1 char before it, no dot before colon)
		if (appStrchr(Str, ':') != NULL) {
			TCHAR* Colon = appStrchr(Str, ':');
			if (Str + 1 < Colon) {
				TCHAR* Dot = appStrchr(Str, '.');
				if (Dot == NULL || Dot > Colon) {
					*Colon = 0;
					Protocol = Str;
					Str = Colon + 1;
				}
			}
		}

		// Check for authority (//)
		if (*Str == '/') {
			if (Str[1] != '/') {
				// Single / without // is invalid
				*this = FURL(NULL);
				Valid = 0;
				return;
			}
			Str += 2;
			bMapChange = 1;
			Host = TEXT("");
		}

		// Check for host (dot in remaining, not a map/save extension)
		TCHAR* Dot = appStrchr(Str, '.');
		if (Dot != NULL && Dot > Str) {
			UBOOL bIsMapExt = 0;
			if (appStrnicmp(Dot + 1, *DefaultMapExt, DefaultMapExt.Len()) == 0) {
				TCHAR After = Dot[DefaultMapExt.Len() + 1];
				if (!((After >= 'a' && After <= 'z') || (After >= 'A' && After <= 'Z') || (After >= '0' && After <= '9')))
					bIsMapExt = 1;
			}
			if (!bIsMapExt && appStrnicmp(Dot + 1, *DefaultSaveExt, DefaultSaveExt.Len()) == 0) {
				TCHAR After = Dot[DefaultSaveExt.Len() + 1];
				if (!((After >= 'a' && After <= 'z') || (After >= 'A' && After <= 'Z') || (After >= '0' && After <= '9')))
					bIsMapExt = 1;
			}

			if (!bIsMapExt) {
				// It's a host — extract host:port/path
				TCHAR* HostStr = Str;
				TCHAR* Slash = appStrchr(Str, '/');
				if (Slash != NULL) {
					*Slash = 0;
					Str = Slash + 1;
				} else {
					Str = NULL;
				}

				TCHAR* PortSep = appStrchr(HostStr, ':');
				if (PortSep != NULL) {
					*PortSep = 0;
					Port = appAtoi(PortSep + 1);
				}

				Host = HostStr;
				if (appStricmp(*Protocol, *DefaultProtocol) == 0)
					Map = DefaultMap;
				else
					Map = TEXT("");
				bMapChange = 1;
			}
		}
	}

	// TRAVEL_Absolute: forward persistent options from Base
	if (Type == TRAVEL_Absolute && Base != NULL && IsInternal()) {
		for (INT i = 0; i < Base->Op.Num(); i++) {
			if (appStrnicmp(*Base->Op(i), TEXT("Name="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Team="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Class="), 6) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Skin="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Face="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Voice="), 6) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("OverrideClass="), 14) == 0)
			{
				TCHAR Match[256];
				const TCHAR* Eq = appStrchr(*Base->Op(i), '=');
				if (Eq == NULL)
					appStrcpy(Match, *Base->Op(i));
				else
					appStrncpy(Match, *Base->Op(i), (INT)(Eq - *Base->Op(i)) + 1);

				if (appStrcmp(GetOption(Match, TEXT("")), TEXT("")) == 0) {
					debugf(TEXT("URL: Carrying over <%s>"), *Base->Op(i));
					new(Op) FString(Base->Op(i));
				}
			}
		}
	}

	// Parse map from remaining string
	if (Str != NULL && *Str != 0) {
		if (IsInternal()) {
			bHasMap = 1;
			TCHAR* Slash = appStrchr(Str, '/');
			if (Slash != NULL) {
				*Slash = 0;
				TCHAR* Slash2 = appStrchr(Slash + 1, '/');
				if (Slash2 != NULL) {
					*Slash2 = 0;
					if (Slash2[1] != 0) {
						*this = FURL(NULL);
						Valid = 0;
						return;
					}
				}
				Portal = Slash + 1;
			}
		}
		Map = Str;
	}

	// Validate: no spaces in Protocol/Host/Portal, and something meaningful was parsed
	if (appStrchr(*Protocol, ' ') || appStrchr(*Host, ' ') || appStrchr(*Portal, ' ')
	 || (!bMapChange && !bHasMap && Op.Num() == 0))
	{
		*this = FURL(NULL);
		Valid = 0;
	}
}

// ??0FURL@@QAE@PBG@Z
// ??0FURL@@QAE@PBG@Z — Ghidra at 0x171950.
// Constructs a URL with defaults, optionally using the provided string as Map.
FURL::FURL(const TCHAR* Filename) {
	Protocol = DefaultProtocol;
	Host     = DefaultHost;
	Port     = DefaultPort;
	Map      = Filename ? FString(Filename) : DefaultMap;
	Portal   = DefaultPortal;
	Valid    = 1;
}

// ??0FWaveModInfo@@QAE@XZ
FWaveModInfo::FWaveModInfo() : SampleLoopsNum(0), NoiseGate(0) {}

// ?findEndAnchor@FSortedPathList@@QAEPAVANavigationPoint@@PAVAPawn@@PAVAActor@@VFVector@@H@Z
// Ghidra (0x11c590): Finds the best nav point in the sorted list that the Scout can
// walk to AND from which the End actor/point is reachable.  Returns the first
// qualifying candidate, or a fallback (first reachable nav point) if bAllowFallback.
ANavigationPoint* FSortedPathList::findEndAnchor(APawn* Scout, AActor* End, FVector EndVec, INT bAllowFallback)
{
	ANavigationPoint** Paths = (ANavigationPoint**)Pad;
	INT Count = *(INT*)(Pad + 0x100);
	ANavigationPoint* Best = NULL;
	for (INT i = 0; i < Count; i++)
	{
		ANavigationPoint* Nav = Paths[i];
		if (!Nav) continue;
		if ((*(DWORD*)((BYTE*)Nav + 0x3a4)) & 0x200) continue;  // NavPoint flagged as blocked
		if (!Scout->actorReachable(Nav, 1, 1)) continue;
		INT EndReachable = End ? Scout->actorReachable(End, 1, 1) : Scout->pointReachable(EndVec, 1);
		if (EndReachable) return Nav;
		if (bAllowFallback && !Best) Best = Nav;
	}
	return Best;
}

// ?findStartAnchor@FSortedPathList@@QAEPAVANavigationPoint@@PAVAPawn@@@Z
// Ghidra (0x11c3b0): Finds the first nav point in the sorted list that the Scout
// can reach (not flagged as blocked, passes actorReachable test).
ANavigationPoint* FSortedPathList::findStartAnchor(APawn* Scout)
{
	ANavigationPoint** Paths = (ANavigationPoint**)Pad;
	INT Count = *(INT*)(Pad + 0x100);
	for (INT i = 0; i < Count; i++)
	{
		ANavigationPoint* Nav = Paths[i];
		if (!Nav) continue;
		if ((*(DWORD*)((BYTE*)Nav + 0x3a4)) & 0x200) continue;  // NavPoint flagged as blocked
		if (Scout->actorReachable(Nav, 1, 1)) return Nav;
	}
	return NULL;
}

// ?GetCurrent@FMatineeTools@@QAEPAVASceneManager@@XZ
// Ghidra at 0x...: simply returns CurrentScene (offset 0x28).
ASceneManager * FMatineeTools::GetCurrent() { return CurrentScene; }

// ?SetCurrent@FMatineeTools@@QAEPAVASceneManager@@PAVUEngine@@PAVULevel@@PAV2@@Z
// Ghidra: sets CurrentScene, primes CurrentAction/CurrentSubAction from Actions[0].
ASceneManager * FMatineeTools::SetCurrent(UEngine * Engine, ULevel * Level, ASceneManager * Scene)
{
	CurrentScene = Scene;
	if (Scene)
	{
		TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
		if (Actions.Num() > 0)
			SetCurrentAction(Actions(0));
		else
		{
			CurrentAction = NULL;
			CurrentSubAction = NULL;
		}
	}
	else
	{
		CurrentAction = NULL;
		CurrentSubAction = NULL;
	}
	return Scene;
}

// ?SetCurrent@FMatineeTools@@QAEPAVASceneManager@@PAVUEngine@@PAVULevel@@VFString@@@Z
// Ghidra: searches Level->Actors for ASceneManager whose GetName() matches Name, then
// delegates to the ASceneManager* overload.
ASceneManager * FMatineeTools::SetCurrent(UEngine * Engine, ULevel * Level, FString Name)
{
	for (INT i = 0; i < Level->Actors.Num(); i++)
	{
		AActor* Actor = Level->Actors(i);
		if (Actor && Actor->IsA(ASceneManager::StaticClass()))
		{
			if (FString(Actor->GetName()) == Name)
				return SetCurrent(Engine, Level, (ASceneManager*)Actor);
		}
	}
	return SetCurrent(Engine, Level, (ASceneManager*)NULL);
}

// ??4ECLipSynchData@@QAEAAV0@ABV0@@Z
ECLipSynchData & ECLipSynchData::operator=(ECLipSynchData const & Other) {
	appMemcpy(this, &Other, 24); // 6 dwords, shared with FCanvasVertex and FStaticMeshVertex
	return *this;
}

// ??4FCollisionHash@@QAEAAV0@ABV0@@Z
// Ghidra @ 0x6f3f0: copies Buckets[0x4000] (offsets 4..0x10003), then FreeList at
// 0x10004, then TArray<void*> AllocatedPools at 0x10008.
FCollisionHash & FCollisionHash::operator=(FCollisionHash const & p0) {
	appMemcpy(Buckets, p0.Buckets, sizeof(Buckets));
	FreeList = p0.FreeList;
	AllocatedPools = p0.AllocatedPools;
	return *this;
}

// ??4FCollisionOctree@@QAEAAV0@ABV0@@Z
FCollisionOctree & FCollisionOctree::operator=(FCollisionOctree const & Other) {
	appMemcpy(Pad, Other.Pad, sizeof(Pad)); // 272 bytes, skip vtable at offset 0
	return *this;
}

// ??4FOctreeNode@@QAEAAV0@ABV0@@Z
// Ghidra @ 0x6f350: TArray<AActor*> copy at Pad[0] (FUN_1031f660 = TArray::operator=),
// then DWORD copy at Pad[0xc]. Pad copy is shallow but TArray<AActor*> stores raw ptrs.
FOctreeNode & FOctreeNode::operator=(FOctreeNode const & p0) {
	appMemcpy(Pad, p0.Pad, sizeof(Pad));
	return *this;
}

// ??4FPathBuilder@@QAEAAV0@ABV0@@Z
FPathBuilder & FPathBuilder::operator=(FPathBuilder const & Other) { appMemcpy(this, &Other, 8); return *this; } // 2 dwords, shared with FStaticMeshUV

// ?Project@FSceneNode@@QAE?AVFPlane@@VFVector@@@Z
FPlane FSceneNode::Project(FVector p0) { return FPlane(); }

// ??4FPoly@@QAEAAV0@ABV0@@Z
FPoly & FPoly::operator=(FPoly const & Other) {
	appMemcpy(this, &Other, sizeof(FPoly));
	return *this;
}

// ?GetCurrent@FRebuildTools@@QAEPAVFRebuildOptions@@XZ
// Ghidra: loads first pointer in layout (Current field at Pad[0x00]).
FRebuildOptions * FRebuildTools::GetCurrent() { return *(FRebuildOptions**)this; }

// ?GetFromName@FRebuildTools@@QAEPAVFRebuildOptions@@VFString@@@Z
// Ghidra: walks TArray of FRebuildOptions (data at Pad[0x04], count at Pad[0x08], stride 0x2C=44).
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
FRebuildOptions * FRebuildTools::Save(FString p0) { return NULL; }

// ?Rotator@FRotatorF@@QAE?AVFRotator@@XZ
FRotator FRotatorF::Rotator() { return FRotator((INT)Pitch, (INT)Yaw, (INT)Roll); }

// ??4FRotatorF@@QAEAAV0@ABV0@@Z
FRotatorF & FRotatorF::operator=(FRotatorF const & p0) { Pitch=p0.Pitch; Yaw=p0.Yaw; Roll=p0.Roll; return *this; }

// ??DFRotatorF@@QBE?AV0@M@Z
FRotatorF FRotatorF::operator*(float p0) const { return FRotatorF(Pitch*p0, Yaw*p0, Roll*p0); }

// ??XFRotatorF@@QAE?AV0@M@Z
FRotatorF FRotatorF::operator*=(float p0) { Pitch*=p0; Yaw*=p0; Roll*=p0; return *this; }

// ??HFRotatorF@@QBE?AV0@V0@@Z
FRotatorF FRotatorF::operator+(FRotatorF p0) const { return FRotatorF(Pitch+p0.Pitch, Yaw+p0.Yaw, Roll+p0.Roll); }

// ??YFRotatorF@@QAE?AV0@V0@@Z
FRotatorF FRotatorF::operator+=(FRotatorF p0) { Pitch+=p0.Pitch; Yaw+=p0.Yaw; Roll+=p0.Roll; return *this; }

// ??GFRotatorF@@QBE?AV0@V0@@Z
FRotatorF FRotatorF::operator-(FRotatorF p0) const { return FRotatorF(Pitch-p0.Pitch, Yaw-p0.Yaw, Roll-p0.Roll); }

// ??ZFRotatorF@@QAE?AV0@V0@@Z
FRotatorF FRotatorF::operator-=(FRotatorF p0) { Pitch-=p0.Pitch; Yaw-=p0.Yaw; Roll-=p0.Roll; return *this; }

// ??4FStatGraph@@QAEAAV0@ABV0@@Z
// Ghidra @ 0x519b0: copies individual DWORDs/TArrays across Pad[0..0x64] plus
// FString at Pad[0x54]. Uses appMemcpy equivalent - divergence: no deep TArray copy.
FStatGraph & FStatGraph::operator=(FStatGraph const & p0) {
	appMemcpy(Pad, p0.Pad, sizeof(Pad));
	return *this;
}

// ?GetOrientationDesc@FMatineeTools@@QAE?AVFString@@H@Z
FString FMatineeTools::GetOrientationDesc(int p0) { return FString(); }

// ?String@FURL@@QBE?AVFString@@H@Z
// Ghidra at 0x1710c0. Serializes URL to string form.
FString FURL::String(int FullyQualified) const {
	FString Result;
	if (Protocol != DefaultProtocol || FullyQualified) {
		Result += Protocol;
		Result += TEXT(":");
		if (Host != DefaultHost)
			Result += TEXT("//");
	}
	if (Host != DefaultHost || Port != DefaultPort) {
		Result += Host;
		if (Port != DefaultPort) {
			Result += TEXT(":");
			Result += FString::Printf(TEXT("%i"), Port);
		}
		Result += TEXT("/");
	}
	if (Map.Len())
		Result += Map;
	for (INT i = 0; i < Op.Num(); i++) {
		Result += TEXT("?");
		Result += Op(i);
	}
	if (Portal.Len()) {
		Result += TEXT("#");
		Result += Portal;
	}
	return Result;
}

// ?GetTextureSize@FPoly@@QAE?AVFVector@@XZ
FVector FPoly::GetTextureSize()
{
	if( !Material )
		return FVector( 256.f, 256.f, 0.f );
	return FVector( (FLOAT)Material->MaterialVSize(), (FLOAT)Material->MaterialUSize(), 0.f );
}

// ?Vector@FRotatorF@@QAE?AVFVector@@XZ
FVector FRotatorF::Vector()
{
	return FRotator(appRound(Pitch), appRound(Yaw), appRound(Roll)).Vector();
}

// ?Deproject@FSceneNode@@QAE?AVFVector@@VFPlane@@@Z
FVector FSceneNode::Deproject(FPlane p0) { return FVector(); }

// ??4FWaveModInfo@@QAEAAV0@ABV0@@Z
FWaveModInfo & FWaveModInfo::operator=(FWaveModInfo const & Other) { appMemcpy(this, &Other, 64); return *this; } // 16 dwords

// ?GetCurrentAction@FMatineeTools@@QAEPAVUMatAction@@XZ
// Ghidra: returns CurrentAction (offset 0x44).
UMatAction * FMatineeTools::GetCurrentAction() { return CurrentAction; }

// ?GetNextAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
// Ghidra: GetActionIdx, return [idx+1] wrapping to [0].
UMatAction * FMatineeTools::GetNextAction(ASceneManager * Scene, UMatAction * Current)
{
	if (!Scene) return NULL;
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
	INT Count = Actions.Num();
	if (Count == 0) return NULL;
	INT Idx = GetActionIdx(Scene, Current);
	return Actions((Idx + 1) % Count);
}

// ?GetNextMovementAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
// Ghidra: calls GetNextAction in a loop until the action IsA(UActionMoveCamera).
UMatAction * FMatineeTools::GetNextMovementAction(ASceneManager * Scene, UMatAction * Current)
{
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
	INT Count = Actions.Num();
	if (Count == 0) return NULL;
	UMatAction* Candidate = GetNextAction(Scene, Current);
	INT Guard = Count; // prevent infinite loop if no move action exists
	while (Guard-- > 0 && Candidate && Candidate != Current)
	{
		if (Candidate->IsA(UActionMoveCamera::StaticClass()))
			return Candidate;
		Candidate = GetNextAction(Scene, Candidate);
	}
	return NULL;
}

// ?GetPrevAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
// Ghidra: GetActionIdx, return [idx-1] wrapping to [last].
UMatAction * FMatineeTools::GetPrevAction(ASceneManager * Scene, UMatAction * Current)
{
	if (!Scene) return NULL;
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
	INT Count = Actions.Num();
	if (Count == 0) return NULL;
	INT Idx = GetActionIdx(Scene, Current);
	INT Prev = (Idx <= 0) ? Count - 1 : Idx - 1;
	return Actions(Prev);
}

// ?SetCurrentAction@FMatineeTools@@QAEPAVUMatAction@@PAV2@@Z
// Ghidra: sets CurrentAction, primes CurrentSubAction from SubActions[0] if available.
UMatAction * FMatineeTools::SetCurrentAction(UMatAction * Action)
{
	CurrentAction = Action;
	if (Action)
	{
		TArray<UMatSubAction*>& SubActions = *(TArray<UMatSubAction*>*)((BYTE*)Action + 0x48);
		CurrentSubAction = SubActions.Num() > 0 ? SubActions(0) : NULL;
	}
	else
	{
		CurrentSubAction = NULL;
	}
	return CurrentAction;
}

// ?GetCurrentSubAction@FMatineeTools@@QAEPAVUMatSubAction@@XZ
// Ghidra: returns CurrentSubAction (offset 0x48).
UMatSubAction * FMatineeTools::GetCurrentSubAction() { return CurrentSubAction; }

// ?SetCurrentSubAction@FMatineeTools@@QAEPAVUMatSubAction@@PAV2@@Z
// Ghidra: stores SubAction at this+0x48 and returns it.
UMatSubAction * FMatineeTools::SetCurrentSubAction(UMatSubAction * SubAction)
{
	CurrentSubAction = SubAction;
	return SubAction;
}

// ?Area@FPoly@@QAEMXZ
float FPoly::Area() {
	FLOAT TotalArea = 0.f;
	FVector Side1 = Vertex[1] - Vertex[0];
	for( INT i=2; i<NumVertices; i++ ) {
		FVector Side2 = Vertex[i] - Vertex[0];
		FLOAT TriArea = (Side1 ^ Side2).Size();
		TotalArea += TriArea;
		Side1 = Side2;
	}
	return TotalArea;
}

// ?GetActionIdx@FMatineeTools@@QAEHPAVASceneManager@@PAVUMatAction@@@Z
int FMatineeTools::GetActionIdx(ASceneManager* SM, UMatAction* Action)
{
	if (!SM)
		return -1;
	// ASceneManager + 0x3A8 = TArray<UMatAction*> Actions
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)SM + 0x3A8);
	for (INT i = 0; i < Actions.Num(); i++)
	{
		if (Actions(i) == Action)
			return i;
	}
	return -1;
}

// ?GetPathStyle@FMatineeTools@@QAEHPAVUMatAction@@@Z
int FMatineeTools::GetPathStyle(UMatAction* Action)
{
	if (Action)
	{
		if (Action->IsA(UActionPause::StaticClass()))
			return 0;
		if (Action->IsA(UActionMoveCamera::StaticClass()))
			return *((BYTE*)Action + 0x90);
	}
	return *((BYTE*)Action + 0x90);
}

// ?GetSubActionIdx@FMatineeTools@@QAEHPAVUMatSubAction@@@Z
int FMatineeTools::GetSubActionIdx(UMatSubAction* SubAction)
{
	if (!CurrentAction)
		return -1;
	// UMatAction + 0x48 = TArray<UMatSubAction*> SubActions
	TArray<UMatSubAction*>& SubActions = *(TArray<UMatSubAction*>*)((BYTE*)CurrentAction + 0x48);
	for (INT i = 0; i < SubActions.Num(); i++)
	{
		if (SubActions(i) == SubAction)
			return i;
	}
	return -1;
}

// ?buildPaths@FPathBuilder@@QAEHPAVULevel@@@Z
int FPathBuilder::buildPaths(ULevel * p0) { return 0; }

// ?removePaths@FPathBuilder@@QAEHPAVULevel@@@Z
// Ghidra: iterate actors, destroy auto-built navigation points, clear bPathsTransient on LevelInfo
int FPathBuilder::removePaths(ULevel* Level)
{
	// Store level pointer at this+0 (first field in Pad)
	*(ULevel**)Pad = Level;

	INT Count = 0;
	for (INT i = 0; i < Level->Actors.Num(); i++)
	{
		AActor* Actor = Level->Actors(i);
		if (Actor && Actor->IsA(ANavigationPoint::StaticClass()))
		{
			// Check bAutoBuilt flag — high bit of byte at AActor+0x3A4
			if (((BYTE*)Actor)[0x3A4] & 0x80)
			{
				Count++;
				Level->DestroyActor(Actor);
			}
		}
	}

	// Verify Actors(0) is ALevelInfo and clear bPathsTransient
	if (!Level->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!Level->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Clear bPathsTransient bit (bit 0x800 at offset 0x450 on LevelInfo)
	DWORD& Flags = *(DWORD*)(((BYTE*)Level->Actors(0)) + 0x450);
	Flags &= ~0x800;

	return Count;
}

// ?CalcNormal@FPoly@@QAEHH@Z
int FPoly::CalcNormal(int bSilent) {
	Normal = FVector(0,0,0);
	for( INT i=2; i<NumVertices; i++ )
		Normal += (Vertex[i-1] - Vertex[0]) ^ (Vertex[i] - Vertex[0]);
	if( Normal.SizeSquared() < 0.0001f ) {
		return 1;
	}
	Normal.Normalize();
	return 0;
}

// ?DoesLineIntersect@FPoly@@QAEHVFVector@@0PAV2@@Z
// ?DoesLineIntersect@FPoly@@QAEHVFVector@@0PAV2@@Z — Ghidra at 0x9E760.
// Tests if a line segment intersects this polygon. Optionally returns the hit point.
int FPoly::DoesLineIntersect(FVector Start, FVector End, FVector * Intersection) {
	FLOAT d1 = (Start - Vertex[0]) | Normal;
	FLOAT d2 = (End   - Vertex[0]) | Normal;

	// Check that the line straddles the polygon's plane.
	if( (d1 >= 0.f || d2 >= 0.f) && (d1 <= 0.f || d2 <= 0.f) )
	{
		FVector Hit = FLinePlaneIntersection( Start, End, Vertex[0], Normal );
		if( Intersection )
			*Intersection = Hit;

		// Only count as intersection if hit point is not at an endpoint.
		if( !(Hit == Start) && !(Hit == End) )
			return OnPoly( Hit );
	}
	return 0;
}

// ?Faces@FPoly@@QBEHABV1@@Z
int FPoly::Faces(FPoly const & Other) const {
	if( IsCoplanar(Other) )
		return 0;
	for( INT i=0; i<Other.NumVertices; i++ ) {
		FLOAT d = (Other.Vertex[i] - Base) | Normal;
		if( d < 0.f ) {
			for( INT j=0; j<NumVertices; j++ ) {
				FLOAT d2 = (Vertex[j] - Other.Base) | Other.Normal;
				if( d2 > 0.f )
					return 1;
			}
			return 0;
		}
	}
	return 0;
}

// ?Finalize@FPoly@@QAEHH@Z — Ghidra at 0x9e190.
// Cleans up polygon: removes duplicate verts, validates, computes normal & texture vectors.
int FPoly::Finalize(int bSilent) {
	Fix();
	if( NumVertices < 3 )
	{
		debugf( NAME_Warning, TEXT("FPoly::Finalize: Not enough vertices (%i)"), NumVertices );
		if( bSilent )
			return -1;
		appErrorf( TEXT("FPoly::Finalize: Not enough vertices (%i)"), NumVertices );
	}
	if( Normal.IsZero() && NumVertices >= 3 )
	{
		if( CalcNormal(0) )
		{
			debugf( NAME_Warning, TEXT("FPoly::Finalize: Normalization failed, IsZero=%i, Size=%f"), Normal.IsZero(), Normal.Size() );
			if( bSilent )
				return -1;
			appErrorf( TEXT("FPoly::Finalize: Normalization failed, IsZero=%i, Size=%f"), Normal.IsZero(), Normal.Size() );
		}
	}
	if( TextureU.IsZero() && TextureV.IsZero() )
	{
		for( INT i=1; i<NumVertices; i++ )
		{
			TextureU = ((Vertex[0] - Vertex[i]) ^ Normal).SafeNormal();
			TextureV = (Normal ^ TextureU).SafeNormal();
			if( TextureU.SizeSquared() != 0.f && TextureV.SizeSquared() != 0.f )
				return 0;
		}
	}
	return 0;
}

// ?Fix@FPoly@@QAEHXZ
int FPoly::Fix()
{
	INT j = 0;
	INT prev = NumVertices - 1;
	for( INT i = 0; i < NumVertices; i++ )
	{
		if( !FPointsAreSame( Vertex[i], Vertex[prev] ) )
		{
			if( j != i )
				Vertex[j] = Vertex[i];
			prev = j;
			j++;
		}
		else
		{
			debugf( NAME_Warning, TEXT("FPoly::Fix: Deleted a duplicate vertex") );
		}
	}
	if( j < 3 )
		j = 0;
	NumVertices = j;
	return j;
}

// ?IsBackfaced@FPoly@@QBEHABVFVector@@@Z
int FPoly::IsBackfaced(FVector const & Point) const {
	return ((Point - Base) | Normal) < 0.f;
}

// ?IsCoplanar@FPoly@@QBEHABV1@@Z
int FPoly::IsCoplanar(FPoly const & Other) const {
	FLOAT d = (Base - Other.Base) | Normal;
	if( d < 0.f ) d = -d;
	if( d < 0.01f ) {
		FLOAT dot = Other.Normal | Normal;
		if( dot < 0.f ) dot = -dot;
		if( dot > 0.9999f )
			return 1;
	}
	return 0;
}

// ?OnPlane@FPoly@@QAEHVFVector@@@Z
int FPoly::OnPlane(FVector Point) {
	FLOAT d = (Point - Vertex[0]) | Normal;
	return (d > -0.1f && d < 0.1f) ? 1 : 0;
}

// ?OnPoly@FPoly@@QAEHVFVector@@@Z
// ?OnPoly@FPoly@@QAEHVFVector@@@Z — Ghidra at 0x9DD10.
// Returns 1 if Point lies inside the polygon, 0 otherwise.
int FPoly::OnPoly(FVector Point) {
	for( INT i=0; i<NumVertices; i++ )
	{
		INT j = i - 1;
		if( j < 0 ) j = NumVertices - 1;
		FVector Side = Vertex[i] - Vertex[j];
		FVector SideNormal = Side ^ Normal;
		SideNormal.Normalize();
		if( ((Point - Vertex[i]) | SideNormal) > 0.1f )
			return 0;
	}
	return 1;
}

// ?Split@FPoly@@QAEHABVFVector@@0H@Z
int FPoly::Split(const FVector& Base, const FVector& Normal, INT NoOverflow)
{
	if (NoOverflow && NumVertices >= 14)
	{
		// Too many vertices — just classify without allocating output polys.
		FPlane Plane(Normal.X, Normal.Y, Normal.Z, Normal | Base);
		INT Result = SplitWithPlaneFast(Plane, NULL, NULL);
		if (Result == SP_Back)
			return 0;
		return NumVertices;
	}

	FPoly Front, Back;
	FPlane Plane(Normal.X, Normal.Y, Normal.Z, Normal | Base);
	INT Result = SplitWithPlaneFast(Plane, &Front, &Back);
	if (Result == SP_Back)
		return 0;
	if (Result == SP_Split)
		*this = Front;
	return NumVertices;
}

// ?SplitPrecise@FPoly@@QAEHABVFVector@@0H@Z
int FPoly::SplitPrecise(const FVector& Base, const FVector& Normal, INT NoOverflow)
{
	if (NoOverflow && NumVertices >= 14)
	{
		FPlane Plane(Normal.X, Normal.Y, Normal.Z, Normal | Base);
		INT Result = SplitWithPlaneFastPrecise(Plane, NULL, NULL);
		if (Result == SP_Back)
			return 0;
		return NumVertices;
	}

	FPoly Front, Back;
	FPlane Plane(Normal.X, Normal.Y, Normal.Z, Normal | Base);
	INT Result = SplitWithPlaneFastPrecise(Plane, &Front, &Back);
	if (Result == SP_Back)
		return 0;
	if (Result == SP_Split)
		*this = Front;
	return NumVertices;
}

// ?SplitWithNode@FPoly@@QBEHPBVUModel@@HPAV1@1H@Z
// Calls SplitWithPlane using the geometric plane defined by BSP node p1 in p0.
// Plane base  = Points[ Verts[ Nodes[p1].iVertPool ].iVertex ]    (first vertex of the node)
// Plane normal = Vectors[ Surfs[ Nodes[p1].iSurf ].vNormal ]      (surface normal vector)
//
// UModel layout (Ghidra-verified offsets, all are TTransArray<T>.Data pointers):
//   Model+0x5c = Nodes.Data  (FBspNode array, stride 0x90)
//   Model+0x6c = Verts.Data  (FVert array,    stride 0x08; first INT = iVertex)
//   Model+0x7c = Vectors.Data(FVector array,  stride 0x0c)
//   Model+0x8c = Points.Data (FVector array,  stride 0x0c)
//   Model+0x9c = Surfs.Data  (FBspSurf array, stride 0x5c; vNormal INT at +0x0c)
// FBspNode field offsets: iVertPool at +0x30, iSurf at +0x34
int FPoly::SplitWithNode(UModel const * p0, int p1, FPoly * p2, FPoly * p3, int p4) const
{
	const BYTE* NodesData  = (const BYTE*)*(const INT*)((const BYTE*)p0 + 0x5c);
	const BYTE* VertsData  = (const BYTE*)*(const INT*)((const BYTE*)p0 + 0x6c);
	const BYTE* VectorsData= (const BYTE*)*(const INT*)((const BYTE*)p0 + 0x7c);
	const BYTE* PointsData = (const BYTE*)*(const INT*)((const BYTE*)p0 + 0x8c);
	const BYTE* SurfsData  = (const BYTE*)*(const INT*)((const BYTE*)p0 + 0x9c);

	const BYTE* Node  = NodesData + p1 * 0x90;
	INT iVertPool     = *(const INT*)(Node + 0x30);
	INT iSurf         = *(const INT*)(Node + 0x34);

	INT iVertex       = *(const INT*)(VertsData + iVertPool * 8);  // FVert.iVertex at +0
	const FVector* PointBase   = (const FVector*)(PointsData  + iVertex * 0xc);

	INT vNormal       = *(const INT*)(SurfsData + iSurf * 0x5c + 0x0c);  // FBspSurf.vNormal at +0x0c
	const FVector* PlaneNormal = (const FVector*)(VectorsData + vNormal * 0xc);

	return SplitWithPlane(*PointBase, *PlaneNormal, p2, p3, p4);
}

// ?SplitWithPlane@FPoly@@QBEHABVFVector@@0PAV1@1H@Z
// Same split logic as SplitWithPlaneFast but takes Base+Normal instead of FPlane.
// bNormal flag (p4): if non-zero, calls CalcNormal on each output polygon.
int FPoly::SplitWithPlane(FVector const & p0, FVector const & p1, FPoly * p2, FPoly * p3, int p4) const
{
	FPlane Plane(p1.X, p1.Y, p1.Z, p1 | p0);
	INT Result = SplitWithPlaneFast(Plane, p2, p3);
	if (p4 && Result == SP_Split)
	{
		if (p2) p2->CalcNormal(1);
		if (p3) p3->CalcNormal(1);
	}
	return Result;
}

// ?SplitWithPlaneFast@FPoly@@QBEHVFPlane@@PAV1@1@Z
// Splits this polygon against a plane using THRESH_SPLIT_POLY_WITH_PLANE (0.25).
// Returns SP_Front, SP_Back, SP_Coplanar, or SP_Split.
// Out-polys (FrontPoly/BackPoly) may be NULL when the result is one-sided.
int FPoly::SplitWithPlaneFast(FPlane p0, FPoly * p1, FPoly * p2) const
{
	const FLOAT Thresh = THRESH_SPLIT_POLY_WITH_PLANE;

	// Classify every vertex against the plane
	FLOAT Dist[16];
	INT FrontN = 0, BackN = 0;
	for (INT i = 0; i < NumVertices; i++)
	{
		Dist[i] = p0.PlaneDot(Vertex[i]);
		if      (Dist[i] >  Thresh) FrontN++;
		else if (Dist[i] < -Thresh) BackN++;
	}

	if (!FrontN && !BackN)
		return SP_Coplanar;
	if (!BackN)
	{
		if (p1) *p1 = *this;
		return SP_Front;
	}
	if (!FrontN)
	{
		if (p2) *p2 = *this;
		return SP_Back;
	}

	// Build split halves
	if (p1) { *p1 = *this; p1->NumVertices = 0; }
	if (p2) { *p2 = *this; p2->NumVertices = 0; }

	INT   j        = NumVertices - 1;
	FLOAT PrevDist = Dist[j];
	for (INT i = 0; i < NumVertices; i++)
	{
		FLOAT CurDist = Dist[i];

		// If edge crosses the plane, emit an intersection vertex in both halves
		if ((PrevDist < -Thresh && CurDist > Thresh) ||
		    (PrevDist >  Thresh && CurDist < -Thresh))
		{
			FLOAT t   = PrevDist / (PrevDist - CurDist);
			FVector I = Vertex[j] + (Vertex[i] - Vertex[j]) * t;
			if (p1 && p1->NumVertices < 16) p1->Vertex[p1->NumVertices++] = I;
			if (p2 && p2->NumVertices < 16) p2->Vertex[p2->NumVertices++] = I;
		}

		// Emit current vertex to front and/or back half
		if (CurDist >= -Thresh)
			if (p1 && p1->NumVertices < 16) p1->Vertex[p1->NumVertices++] = Vertex[i];
		if (CurDist <=  Thresh)
			if (p2 && p2->NumVertices < 16) p2->Vertex[p2->NumVertices++] = Vertex[i];

		j        = i;
		PrevDist = CurDist;
	}
	return SP_Split;
}

// ?SplitWithPlaneFastPrecise@FPoly@@QBEHVFPlane@@PAV1@1@Z
// Same as SplitWithPlaneFast but uses THRESH_SPLIT_POLY_PRECISELY (0.01).
int FPoly::SplitWithPlaneFastPrecise(FPlane p0, FPoly * p1, FPoly * p2) const
{
	const FLOAT Thresh = THRESH_SPLIT_POLY_PRECISELY;

	FLOAT Dist[16];
	INT FrontN = 0, BackN = 0;
	for (INT i = 0; i < NumVertices; i++)
	{
		Dist[i] = p0.PlaneDot(Vertex[i]);
		if      (Dist[i] >  Thresh) FrontN++;
		else if (Dist[i] < -Thresh) BackN++;
	}

	if (!FrontN && !BackN)
		return SP_Coplanar;
	if (!BackN)
	{
		if (p1) *p1 = *this;
		return SP_Front;
	}
	if (!FrontN)
	{
		if (p2) *p2 = *this;
		return SP_Back;
	}

	if (p1) { *p1 = *this; p1->NumVertices = 0; }
	if (p2) { *p2 = *this; p2->NumVertices = 0; }

	INT   j        = NumVertices - 1;
	FLOAT PrevDist = Dist[j];
	for (INT i = 0; i < NumVertices; i++)
	{
		FLOAT CurDist = Dist[i];

		if ((PrevDist < -Thresh && CurDist > Thresh) ||
		    (PrevDist >  Thresh && CurDist < -Thresh))
		{
			FLOAT t   = PrevDist / (PrevDist - CurDist);
			FVector I = Vertex[j] + (Vertex[i] - Vertex[j]) * t;
			if (p1 && p1->NumVertices < 16) p1->Vertex[p1->NumVertices++] = I;
			if (p2 && p2->NumVertices < 16) p2->Vertex[p2->NumVertices++] = I;
		}

		if (CurDist >= -Thresh)
			if (p1 && p1->NumVertices < 16) p1->Vertex[p1->NumVertices++] = Vertex[i];
		if (CurDist <=  Thresh)
			if (p2 && p2->NumVertices < 16) p2->Vertex[p2->NumVertices++] = Vertex[i];

		j        = i;
		PrevDist = CurDist;
	}
	return SP_Split;
}

// ??9FPoly@@QAEHV0@@Z — Ghidra at 0x8bce0.
int FPoly::operator!=(FPoly Other) {
	if( NumVertices != Other.NumVertices )
		return 1;
	for( INT i=0; i<NumVertices; i++ )
		if( Vertex[i] != Other.Vertex[i] )
			return 1;
	return 0;
}

// ??8FPoly@@QAEHV0@@Z — Ghidra at 0xb4b10.
int FPoly::operator==(FPoly Other) {
	if( NumVertices != Other.NumVertices )
		return 0;
	for( INT i=0; i<NumVertices; i++ )
		if( Vertex[i] != Other.Vertex[i] )
			return 0;
	return 1;
}

// ?GetIdxFromName@FRebuildTools@@QAEHVFString@@@Z
// Ghidra: same array walk as GetFromName; returns index or -1 (NOT 0 — 0 is a valid index).
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

// ?Exec@FStatGraph@@QAEHPBGAAVFOutputDevice@@@Z
int FStatGraph::Exec(const TCHAR* p0, FOutputDevice & p1) { return 0; }

// ?HasOption@FURL@@QBEHPBG@Z
int FURL::HasOption(const TCHAR* Test) const {
	for( INT i=0; i<Op.Num(); i++ )
		if( appStricmp(*Op(i),Test)==0 )
			return 1;
	return 0;
}

// ?IsInternal@FURL@@QBEHXZ
int FURL::IsInternal() const {
	return Protocol == DefaultProtocol;
}

// ?IsLocalInternal@FURL@@QBEHXZ
int FURL::IsLocalInternal() const {
	return IsInternal() && Host.Len()==0;
}

// ??8FURL@@QBEHABV0@@Z
int FURL::operator==(FURL const & Other) const {
	if( Protocol!=Other.Protocol )
		return 0;
	if( Host!=Other.Host )
		return 0;
	if( Map!=Other.Map )
		return 0;
	if( Port!=Other.Port )
		return 0;
	if( Op.Num()!=Other.Op.Num() )
		return 0;
	for( INT i=0; i<Op.Num(); i++ )
		if( Op(i)!=Other.Op(i) )
			return 0;
	return 1;
}

// ?ReadWaveInfo@FWaveModInfo@@QAEHAAV?$TArray@E@@@Z
INT FWaveModInfo::ReadWaveInfo(TArray<BYTE>& WavData) {
	guard(FWaveModInfo::ReadWaveInfo);

	BYTE* Start = &WavData(0);
	INT Len = WavData.Num();
	WaveDataEnd = Start + Len;

	// Check RIFF/WAVE header
	if( *(DWORD*)(Start + 8) != 0x45564157 ) // 'WAVE'
		return 0;
	pMasterSize = (DWORD*)(Start + 4);

	BYTE* Ptr;
	DWORD ChunkSize;

	// Scan for "fmt " chunk
	for( Ptr = Start + 12; Ptr + 8 < WaveDataEnd && *(DWORD*)Ptr != 0x20746d66; Ptr += Pad16Bit(*(DWORD*)(Ptr+4)) + 8 ) {}
	if( *(DWORD*)Ptr != 0x20746d66 ) // 'fmt '
		return 0;

	BYTE* FmtData = Ptr + 8; // actual format data past chunk header
	pBitsPerSample  = (_WORD*)(Ptr + 0x16);
	pSamplesPerSec  = (DWORD*)(Ptr + 12);
	pAvgBytesPerSec = (DWORD*)(Ptr + 16);
	pBlockAlign     = (_WORD*)(Ptr + 20);
	pChannels       = (_WORD*)(Ptr + 10);

	// Scan for "data" chunk
	for( Ptr = Start + 12; Ptr + 8 < WaveDataEnd && *(DWORD*)Ptr != 0x61746164; Ptr += Pad16Bit(*(DWORD*)(Ptr+4)) + 8 ) {}
	if( *(DWORD*)Ptr != 0x61746164 ) // 'data'
		return 0;

	SampleDataStart = Ptr + 8;
	pWaveDataSize   = (DWORD*)(Ptr + 4);
	SampleDataSize  = *(DWORD*)(Ptr + 4);
	OldBitsPerSample = (DWORD)*(_WORD*)(FmtData + 0x0E);
	SampleDataEnd   = SampleDataStart + SampleDataSize;
	NewDataSize     = SampleDataSize;

	// Scan for optional "smpl" chunk
	for( Ptr = Start + 12; Ptr + 8 < WaveDataEnd && *(DWORD*)Ptr != 0x6C706D73; Ptr += Pad16Bit(*(DWORD*)(Ptr+4)) + 8 ) {}
	if( Ptr + 4 < WaveDataEnd && *(DWORD*)Ptr == 0x6C706D73 ) // 'smpl'
	{
		BYTE SmplHeader[36];
		appMemcpy(SmplHeader, Ptr + 8, 36);
		SampleLoopsNum = *(INT*)(SmplHeader + 28);
		pSampleLoop    = (FSampleLoop*)(Ptr + 8 + 36);
	}

	return 1;
	unguard;
}

// ?UpdateWaveData@FWaveModInfo@@QAEHAAV?$TArray@E@@@Z
// Retail ordinal unknown. Applies a sample-rate change to in-memory WAV data:
//   - Shrinks the data chunk header, block-align and bytes-per-sec fields,
//   - Re-scales any "smpl" loop-point positions to the new sample count,
//   - Compacts the array (shifts post-sample chunks left, trims the tail).
// Only executes if NewDataSize < SampleDataSize; always returns 1.
INT FWaveModInfo::UpdateWaveData(TArray<BYTE>& WavData)
{
	if (NewDataSize < SampleDataSize) {
		// Amount by which the sample data shrinks (RIFF chunks must be WORD-aligned).
		DWORD delta = Pad16Bit(SampleDataSize) - Pad16Bit(NewDataSize);

		// Update the WAV header fields that reflect sample-data size.
		*pWaveDataSize     = NewDataSize;
		*pMasterSize      -= delta;
		*pBlockAlign       = (_WORD)(*pChannels * (*pBitsPerSample >> 3));
		*pAvgBytesPerSec   = (DWORD)(*pBlockAlign) * *pSamplesPerSec;

		// Re-scale all "smpl" loop point positions proportionally.
		if (SampleLoopsNum > 0) {
			FSampleLoop* pLoop = pSampleLoop;
			DWORD scaleNum = (DWORD)*pBitsPerSample * SampleDataSize / NewDataSize;
			for (INT i = 0; i < SampleLoopsNum; i++, pLoop++) {
				pLoop->dwStart = (DWORD)((DWORD)pLoop->dwStart * OldBitsPerSample) / scaleNum;
				pLoop->dwEnd   = (DWORD)((DWORD)pLoop->dwEnd   * OldBitsPerSample) / scaleNum;
			}
		}

		// Shift data that follows the (now-smaller) sample block left by delta bytes.
		INT afterSize = (INT)(WaveDataEnd - SampleDataEnd);
		for (INT i = 0; i < afterSize; i++)
			*(SampleDataEnd - delta + i) = *(SampleDataEnd + i);

		// Trim the now-redundant tail of the array.
		WavData.Remove(WavData.Num() - delta, delta);
	}
	return 1;
}

// ?StaticExit@FURL@@SAXXZ
void FURL::StaticExit() {
	DefaultProtocol          = TEXT("");
	DefaultProtocolDescription = TEXT("");
	DefaultName              = TEXT("");
	DefaultMap               = TEXT("");
	DefaultLocalMap          = TEXT("");
	DefaultHost              = TEXT("");
	DefaultPortal            = TEXT("");
	DefaultMapExt            = TEXT("");
	DefaultSaveExt           = TEXT("");
}

// ?StaticInit@FURL@@SAXXZ
void FURL::StaticInit() {
	DefaultProtocol            = GConfig->GetStr( TEXT("URL"), TEXT("Protocol"), NULL );
	DefaultProtocolDescription = GConfig->GetStr( TEXT("URL"), TEXT("ProtocolDescription"), NULL );
	DefaultName                = GConfig->GetStr( TEXT("URL"), TEXT("Name"), NULL );
	if( DefaultName == TEXT("UbiPlayer") )
		DefaultName = appUserName();
	DefaultMap = TEXT("Entry.");
	DefaultMap += GConfig->GetStr( TEXT("URL"), TEXT("MapExt"), NULL );
	DefaultLocalMap = TEXT("Entry.");
	DefaultLocalMap += GConfig->GetStr( TEXT("URL"), TEXT("MapExt"), NULL );
	DefaultHost     = GConfig->GetStr( TEXT("URL"), TEXT("Host"), NULL );
	DefaultPortal   = GConfig->GetStr( TEXT("URL"), TEXT("Portal"), NULL );
	DefaultMapExt   = GConfig->GetStr( TEXT("URL"), TEXT("MapExt"), NULL );
	DefaultSaveExt  = GConfig->GetStr( TEXT("URL"), TEXT("SaveExt"), NULL );
	DefaultPort     = appAtoi( GConfig->GetStr( TEXT("URL"), TEXT("Port"), NULL ) );
}

// ?Pad16Bit@FWaveModInfo@@QAEKK@Z
DWORD FWaveModInfo::Pad16Bit(DWORD InVal) { return (InVal + 1) & ~1; }

// ?GetOption@FURL@@QBEPBGPBG0@Z
const TCHAR* FURL::GetOption(const TCHAR* Match, const TCHAR* Default) const {
	for( INT i=0; i<Op.Num(); i++ )
		if( appStrnicmp(*Op(i),Match,appStrlen(Match))==0 )
			return *Op(i) + appStrlen(Match);
	return Default;
}

// ??1FCollisionHash@@UAE@XZ
FCollisionHash::~FCollisionHash() {}

// ??1FCollisionOctree@@UAE@XZ
FCollisionOctree::~FCollisionOctree() {}

// ??1FLevelSceneNode@@UAE@XZ
FLevelSceneNode::~FLevelSceneNode() {}

// ??1FMatineeTools@@UAE@XZ
FMatineeTools::~FMatineeTools() {}

// ??1FSceneNode@@UAE@XZ
FSceneNode::~FSceneNode() {}

// ?GetActorSceneNode@FSceneNode@@UAEPAVFActorSceneNode@@XZ
FActorSceneNode * FSceneNode::GetActorSceneNode() { return NULL; }

// ?GetCameraSceneNode@FSceneNode@@UAEPAVFCameraSceneNode@@XZ
FCameraSceneNode * FSceneNode::GetCameraSceneNode() { return NULL; }

// ?GetLevelSceneNode@FSceneNode@@UAEPAVFLevelSceneNode@@XZ
FLevelSceneNode * FSceneNode::GetLevelSceneNode() { return NULL; }

// ?MeshToWorld@UMeshInstance@@UAE?AVFMatrix@@XZ
FMatrix UMeshInstance::MeshToWorld() { // Retail: 36b. Copies FMatrix::Identity (from Core.dll IAT) to return buffer.
 return FMatrix::Identity; }

// ?GetMirrorSceneNode@FSceneNode@@UAEPAVFMirrorSceneNode@@XZ
FMirrorSceneNode * FSceneNode::GetMirrorSceneNode() { return NULL; }

// ?GetSkySceneNode@FSceneNode@@UAEPAVFSkySceneNode@@XZ
FSkySceneNode * FSceneNode::GetSkySceneNode() { return NULL; }

// ?GetWarpZoneSceneNode@FSceneNode@@UAEPAVFWarpZoneSceneNode@@XZ
FWarpZoneSceneNode * FSceneNode::GetWarpZoneSceneNode() { return NULL; }

// ?ActorEncroachmentCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@VFVector@@VFRotator@@KK@Z
// Retail ordinal 2214 (0x6e3d0). Temporarily moves Actor to NewLocation/NewRotation and checks
// for overlap with every actor whose AABB touches the new position. Returns a tail-ordered list
// of encroachment hits. Uses GMem (the Mem argument is unused per the retail binary).
FCheckResult * FCollisionHash::ActorEncroachmentCheck(FMemStack & Mem, AActor * Actor, FVector NewLocation, FRotator NewRot, DWORD TraceFlags, DWORD ExtraNodeFlags)
{
	check(Actor != NULL);

	// Temporarily teleport the actor to the candidate position so GetActorExtent sees the right bounds.
	FLOAT OldLocX = *(FLOAT*)((BYTE*)Actor + 0x234);
	FLOAT OldLocY = *(FLOAT*)((BYTE*)Actor + 0x238);
	FLOAT OldLocZ = *(FLOAT*)((BYTE*)Actor + 0x23c);
	*(FLOAT*)((BYTE*)Actor + 0x234) = NewLocation.X;
	*(FLOAT*)((BYTE*)Actor + 0x238) = NewLocation.Y;
	*(FLOAT*)((BYTE*)Actor + 0x23c) = NewLocation.Z;
	INT OldRotP = *(INT*)((BYTE*)Actor + 0x240);
	INT OldRotY = *(INT*)((BYTE*)Actor + 0x244);
	INT OldRotR = *(INT*)((BYTE*)Actor + 0x248);
	*(INT*)((BYTE*)Actor + 0x240) = NewRot.Pitch;
	*(INT*)((BYTE*)Actor + 0x244) = NewRot.Yaw;
	*(INT*)((BYTE*)Actor + 0x248) = NewRot.Roll;

	INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
	GetActorExtent(Actor, MinX, MaxX, MinY, MaxY, MinZ, MaxZ);

	// Build results as a forward-ordered (tail-insertion) linked list, matching retail binary order.
	FCheckResult*  ListHead = NULL;
	FCheckResult** ListTail = &ListHead;

	CollisionTag++;

	for (INT x = MinX; x <= MaxX; x++)
	for (INT y = MinY; y <= MaxY; y++)
	for (INT z = MinZ; z <= MaxZ; z++) {
		const INT Pos = (z*0x400+y)*0x400+x;
		for (FCollisionLink* L = Buckets[HashX[x]^HashY[y]^HashZ[z]]; L; L = L->Next) {
			AActor* A = L->Actor;
			if (*(INT*)((BYTE*)A+0x60) != CollisionTag && L->HashPos == Pos) {
				// Filter: not joined, should participate in trace, not a no-encroach static.
				// vtable+0xbc = ShouldTrace(AActor*, DWORD); vtable+0xc8(=200) = IsMovingBrush()
				// Bit 0x100000 at Actor+0xa0 marks bNoEncroachCheck (bypassed if mover).
				if (!A->IsJoinedTo(Actor)
					&& A->ShouldTrace(Actor, ExtraNodeFlags)
					&& (!Actor->IsMovingBrush() || !(*(DWORD*)((BYTE*)A+0xa0) & 0x100000)))
				{
					*(INT*)((BYTE*)A+0x60) = CollisionTag;
					FCheckResult TestHit(1.f);
					if (Actor->IsOverlapping(A, &TestHit)) {
						TestHit.Actor     = A;
						TestHit.Primitive = NULL;
						FCheckResult* CR = (FCheckResult*)GMem.PushBytes(sizeof(FCheckResult), 8);
						if (CR) {
							*ListTail = CR;
							appMemcpy(CR, &TestHit, sizeof(FCheckResult));
							ListTail = &CR->GetNext();
						}
					}
				}
			}
		}
	}
	*ListTail = NULL;

	// Restore original position.
	*(FLOAT*)((BYTE*)Actor + 0x234) = OldLocX;
	*(FLOAT*)((BYTE*)Actor + 0x238) = OldLocY;
	*(FLOAT*)((BYTE*)Actor + 0x23c) = OldLocZ;
	*(INT*)((BYTE*)Actor + 0x240) = OldRotP;
	*(INT*)((BYTE*)Actor + 0x244) = OldRotY;
	*(INT*)((BYTE*)Actor + 0x248) = OldRotR;

	return ListHead;
}

// ?ActorLineCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@11KKPAVAActor@@@Z
// Retail ordinal 2217 (0x6e6f0). Sweeps a line (or box if Extent is non-zero) through the hash
// and collects BlockedBy+LineCheck hits. Two sub-paths:
//   Non-zero Extent: iterate all cells in the AABB of [Start,End] expanded by Extent.
//   Zero Extent:     DDA ray traversal from Start to End one cell at a time.
// TraceFlags bit 0x200 = return first hit only; bit 0x400 = sort by facing distance.
// Uses the Mem argument for allocation (retail binary does NOT use GMem here).
FCheckResult * FCollisionHash::ActorLineCheck(FMemStack & Mem, FVector End, FVector Start, FVector Extent, DWORD TraceFlags, DWORD TypeFlags, AActor * SourceActor)
{
	CollisionTag++;
	FCheckResult* List = NULL;

	if (!Extent.IsZero()) {
		// Bounding-box sweep: cover all cells touching the AABB of [Start..End] grown by Extent.
		INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
		FLOAT BMinX = ::Min(Start.X, End.X), BMinY = ::Min(Start.Y, End.Y), BMinZ = ::Min(Start.Z, End.Z);
		FLOAT BMaxX = ::Max(Start.X, End.X), BMaxY = ::Max(Start.Y, End.Y), BMaxZ = ::Max(Start.Z, End.Z);
		GetHashIndices(FVector(BMinX-Extent.X, BMinY-Extent.Y, BMinZ-Extent.Z), MinX, MinY, MinZ);
		GetHashIndices(FVector(BMaxX+Extent.X, BMaxY+Extent.Y, BMaxZ+Extent.Z), MaxX, MaxY, MaxZ);

		for (INT x = MinX; x <= MaxX; x++)
		for (INT y = MinY; y <= MaxY; y++)
		for (INT z = MinZ; z <= MaxZ; z++) {
			const INT Pos = (z*0x400+y)*0x400+x;
			for (FCollisionLink* L = Buckets[HashX[x]^HashY[y]^HashZ[z]]; L; L = L->Next) {
				AActor* A = L->Actor;
				if (*(INT*)((BYTE*)A+0x60) != CollisionTag && L->HashPos == Pos) {
					*(INT*)((BYTE*)A+0x60) = CollisionTag;
					// Skip SourceActor itself and any actor in its ignore chain (offset 0x140).
					if (A == SourceActor) continue;
					bool bIgnored = false;
					for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI+0x140)) {
						if ((AActor*)pI == A) { bIgnored = true; break; }
					}
					if (bIgnored) continue;
					if (A->ShouldTrace(SourceActor, TraceFlags)) {
						FCheckResult TestHit(0.f);
						if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start, Extent, TypeFlags, TraceFlags) == 0) {
							FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
							if (CR) {
								appMemcpy(CR, &TestHit, sizeof(FCheckResult));
								CR->GetNext() = List;
								List = CR;
							}
							if (TraceFlags & 0x200) return List;
						}
					}
				}
			}
		}
		// TraceFlags & 0x400 = sort by facing: FUN_103d92c0 not yet identified, return as-is.
		return List;
	}

	// DDA zero-extent ray traversal: walk cells from Start to End one step at a time.
	FVector Dir = (End - Start).SafeNormal();
	INT CurX, CurY, CurZ, EndX, EndY, EndZ;
	GetHashIndices(Start, CurX, CurY, CurZ);
	GetHashIndices(End,   EndX, EndY, EndZ);

	for (bool bKeepGoing = true; bKeepGoing; ) {
		const INT Pos = (CurZ*0x400+CurY)*0x400+CurX;
		bool bEarlyExit = false;
		for (FCollisionLink* L = Buckets[HashX[CurX]^HashY[CurY]^HashZ[CurZ]]; L; L = L->Next) {
			AActor* A = L->Actor;
			if (*(INT*)((BYTE*)A+0x60) != CollisionTag && L->HashPos == Pos) {
				*(INT*)((BYTE*)A+0x60) = CollisionTag;
				if (A == SourceActor) continue;
				bool bIgnored = false;
				for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI+0x140)) {
					if ((AActor*)pI == A) { bIgnored = true; break; }
				}
				if (bIgnored) continue;
				if (A->ShouldTrace(SourceActor, TraceFlags)) {
					FCheckResult TestHit(0.f);
					if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start, FVector(0,0,0), TypeFlags, TraceFlags) == 0) {
						FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
						if (CR) {
							appMemcpy(CR, &TestHit, sizeof(FCheckResult));
							CR->GetNext() = List;
							List = CR;
						}
						if (TraceFlags & 0x200) { bEarlyExit = true; break; }
					}
				}
			}
		}
		if (List && (TraceFlags & 0x200)) return List;
		// TraceFlags & 0x400 = sort earliest hit by facing: not yet implemented (FUN_103d92c0).
		if (CurX == EndX && CurY == EndY && CurZ == EndZ) { bKeepGoing = false; continue; }

		// DDA: advance to the next hash cell along the ray direction.
		// DistanceToHashPlane returns the parametric distance to the next boundary on each axis.
		// Direction convention (from retail binary): step OPPOSITE to sign of Dir (Ghidra pattern).
		FLOAT dX = DistanceToHashPlane(CurX, Dir.X, Start.X, 0x100);
		FLOAT dY = DistanceToHashPlane(CurY, Dir.Y, Start.Y, 0x100);
		FLOAT dZ = DistanceToHashPlane(CurZ, Dir.Z, Start.Z, 0x100);
		INT nX = CurX, nY = CurY, nZ = CurZ;
		if (dX > dY || dX > dZ) {
			if (dY > dX || dY > dZ) { nZ += (Dir.Z < 0.f) ? 1 : -1; }
			else                    { nY += (Dir.Y < 0.f) ? 1 : -1; }
		} else {
			nX += (Dir.X < 0.f) ? 1 : -1;
		}
		if ((DWORD)nX >= 0x4000u || (DWORD)nY >= 0x4000u || (DWORD)nZ >= 0x4000u) {
			bKeepGoing = false;
		} else {
			CurX = nX; CurY = nY; CurZ = nZ;
		}
	}
	return List;
}

// ?ActorOverlapCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@PAVFBox@@H@Z
// Retail ordinal 2220 (0x33a0). Stub in retail binary — returns NULL.
FCheckResult * FCollisionHash::ActorOverlapCheck(FMemStack & p0, AActor * p1, FBox * p2, int p3) { return NULL; }

// ?ActorPointCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@1KKHPAVAActor@@@Z
// Retail ordinal 2223 (0x6dec0). Tests whether a point+AABB (Location ± Extent) overlaps any
// actor in the hash. Calls each candidate's ShouldTrace then GetPrimitive()->PointCheck.
// Uses GMem (the Mem argument is unused per the retail binary).
FCheckResult * FCollisionHash::ActorPointCheck(FMemStack & Mem, FVector Location, FVector Extent, DWORD ExtraNodeFlags, DWORD /*unused*/, INT bSingleResult, AActor * SourceActor)
{
	INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
	GetHashIndices(FVector(Location.X-Extent.X, Location.Y-Extent.Y, Location.Z-Extent.Z), MinX, MinY, MinZ);
	GetHashIndices(FVector(Location.X+Extent.X, Location.Y+Extent.Y, Location.Z+Extent.Z), MaxX, MaxY, MaxZ);
	CollisionTag++;
	FCheckResult* List = NULL;

	for (INT x = MinX; x <= MaxX; x++)
	for (INT y = MinY; y <= MaxY; y++)
	for (INT z = MinZ; z <= MaxZ; z++) {
		const INT Pos = (z*0x400+y)*0x400+x;
		for (FCollisionLink* L = Buckets[HashX[x]^HashY[y]^HashZ[z]]; L; L = L->Next) {
			AActor* A = L->Actor;
			// Dedup and hash-pos guard, then filter by ShouldTrace before marking visited.
			if (*(INT*)((BYTE*)A+0x60) != CollisionTag && L->HashPos == Pos
				&& A->ShouldTrace(SourceActor, ExtraNodeFlags))
			{
				*(INT*)((BYTE*)A+0x60) = CollisionTag;
				FCheckResult TestHit(1.f);
				if (A->GetPrimitive()->PointCheck(TestHit, A, Location, Extent, 0) == 0) {
					check(TestHit.Actor == A);
					FCheckResult* CR = (FCheckResult*)GMem.PushBytes(sizeof(FCheckResult), 8);
					if (CR) {
						appMemcpy(CR, &TestHit, sizeof(FCheckResult));
						CR->GetNext() = List;
						List = CR;
					}
					if (bSingleResult) return List;
				}
			}
		}
	}
	return List;
}

// ?ActorRadiusCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@MK@Z
// Retail ordinal 2226 (0x6e1a0). Returns all actors within Radius of Center (sphere test on
// stored Location, no primitive shape check). Uses GMem (Mem argument unused per retail binary).
FCheckResult * FCollisionHash::ActorRadiusCheck(FMemStack & Mem, FVector Center, FLOAT Radius, DWORD ExtraNodeFlags)
{
	INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
	GetHashIndices(FVector(Center.X-Radius, Center.Y-Radius, Center.Z-Radius), MinX, MinY, MinZ);
	GetHashIndices(FVector(Center.X+Radius, Center.Y+Radius, Center.Z+Radius), MaxX, MaxY, MaxZ);
	const FLOAT RadSq = Radius * Radius;
	CollisionTag++;
	FCheckResult* List = NULL;

	for (INT x = MinX; x <= MaxX; x++)
	for (INT y = MinY; y <= MaxY; y++)
	for (INT z = MinZ; z <= MaxZ; z++) {
		const INT Pos = (z*0x400+y)*0x400+x;
		for (FCollisionLink* L = Buckets[HashX[x]^HashY[y]^HashZ[z]]; L; L = L->Next) {
			AActor* A = L->Actor;
			if (*(INT*)((BYTE*)A+0x60) != CollisionTag && L->HashPos == Pos) {
				*(INT*)((BYTE*)A+0x60) = CollisionTag;
				// Use stored Location (0x234-0x23c); no primitive shape, pure sphere test.
				const FLOAT dx = *(FLOAT*)((BYTE*)A+0x234) - Center.X;
				const FLOAT dy = *(FLOAT*)((BYTE*)A+0x238) - Center.Y;
				const FLOAT dz = *(FLOAT*)((BYTE*)A+0x23c) - Center.Z;
				if (dx*dx + dy*dy + dz*dz < RadSq) {
					FCheckResult* CR = (FCheckResult*)GMem.PushBytes(sizeof(FCheckResult), 8);
					if (CR) {
						CR->Material  = NULL;
						CR->Actor     = A;
						CR->GetNext() = List;
						List = CR;
					}
				}
			}
		}
	}
	return List;
}

// Octree collision helpers — shared iteration of the root node's flat actor list.
// The octree stores all actors in the root node (no subdivision for now), making
// queries equivalent to linear scans.  The frame counter (Pad[4]) deduplicates
// actors that appear in multiple query cells via the visited tag at actor+0x60.

// ?ActorEncroachmentCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@VFVector@@VFRotator@@KK@Z
FCheckResult* FCollisionOctree::ActorEncroachmentCheck(FMemStack& Mem, AActor* Actor, FVector Location, FRotator Rotation, DWORD ExtraNodeFlags, DWORD TypeFlags)
{
	INT& Frame = *(INT*)(Pad + 4);
	Frame++;
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (!Root) return NULL;
	TArray<AActor*>& Actors = *(TArray<AActor*>*)Root;
	FCheckResult* List = NULL;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A || A == Actor) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (A->ShouldTrace(Actor, ExtraNodeFlags))
		{
			FCheckResult TestHit(1.f);
			if (A->GetPrimitive()->PointCheck(TestHit, A, Location, FVector(0,0,0), 0) == 0)
			{
				FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
				if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
			}
		}
	}
	return List;
}

// ?ActorLineCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@11KKPAVAActor@@@Z
// Sweeps a line (or capsule if Extent nonzero) through all tracked actors.
// Mirrors FCollisionHash::ActorLineCheck but draws from the octree's root actor list.
FCheckResult* FCollisionOctree::ActorLineCheck(FMemStack& Mem, FVector End, FVector Start, FVector Extent, DWORD TraceFlags, DWORD TypeFlags, AActor* SourceActor)
{
	INT& Frame = *(INT*)(Pad + 4);
	Frame++;
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (!Root) return NULL;
	TArray<AActor*>& Actors = *(TArray<AActor*>*)Root;
	FCheckResult* List = NULL;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (A == SourceActor) continue;
		// Walk the owner chain to skip owned actors
		bool bIgnored = false;
		for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI + 0x140))
			if ((AActor*)pI == A) { bIgnored = true; break; }
		if (bIgnored) continue;
		if (A->ShouldTrace(SourceActor, TraceFlags))
		{
			FCheckResult TestHit(0.f);
			if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start, Extent, TypeFlags, TraceFlags) == 0)
			{
				FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
				if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
				if (TraceFlags & 0x200) return List;
			}
		}
	}
	return List;
}

// ?ActorOverlapCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@PAVFBox@@H@Z
FCheckResult * FCollisionOctree::ActorOverlapCheck(FMemStack & p0, AActor * p1, FBox * p2, int p3) { return NULL; }

// ?ActorPointCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@1KKHPAVAActor@@@Z
// Tests a point+AABB against all tracked actors; uses GMem for allocation (matching retail).
FCheckResult* FCollisionOctree::ActorPointCheck(FMemStack& /*Mem*/, FVector Location, FVector Extent, DWORD ExtraNodeFlags, DWORD /*unused*/, INT bSingleResult, AActor* SourceActor)
{
	INT& Frame = *(INT*)(Pad + 4);
	Frame++;
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (!Root) return NULL;
	TArray<AActor*>& Actors = *(TArray<AActor*>*)Root;
	FCheckResult* List = NULL;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		if (!A->ShouldTrace(SourceActor, ExtraNodeFlags)) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		FCheckResult TestHit(1.f);
		if (A->GetPrimitive()->PointCheck(TestHit, A, Location, Extent, 0) == 0)
		{
			FCheckResult* CR = (FCheckResult*)GMem.PushBytes(sizeof(FCheckResult), 8);
			if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
			if (bSingleResult) return List;
		}
	}
	return List;
}

// ?ActorRadiusCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@MK@Z
// Returns all actors whose location is within Radius of Center.
FCheckResult* FCollisionOctree::ActorRadiusCheck(FMemStack& Mem, FVector Center, FLOAT Radius, DWORD ExtraNodeFlags)
{
	INT& Frame = *(INT*)(Pad + 4);
	Frame++;
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (!Root) return NULL;
	TArray<AActor*>& Actors = *(TArray<AActor*>*)Root;
	FCheckResult* List = NULL;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (!A->ShouldTrace(NULL, ExtraNodeFlags)) continue;
		const FLOAT dx = A->Location.X - Center.X;
		const FLOAT dy = A->Location.Y - Center.Y;
		const FLOAT dz = A->Location.Z - Center.Z;
		if (dx*dx + dy*dy + dz*dz <= Radius*Radius)
		{
			FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
			if (CR)
			{
				appMemzero(CR, sizeof(FCheckResult));
				CR->Actor = A;
				CR->GetNext() = List;
				List = CR;
			}
		}
	}
	return List;
}

// ?AddActor@FCollisionHash@@UAEXPAVAActor@@@Z
// Retail ordinal 2232 (0x6ee70).  Inserts an actor into every hash cell that
// its bounding box overlaps.  Pool-allocates 12-byte FCollisionLink slabs of
// 1024 nodes (0x3000 bytes) on demand.  Saves actor Location into ColLocation
// (offsets 0x308-0x310) so RemoveActor can look it up by the original position.
void FCollisionHash::AddActor(AActor* Actor) {
	check((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x800); // bCollideActors must be set
	if (*(SBYTE*)((BYTE*)Actor + 0xa0) < 0) return;  // bDeleteMe — skip
	if ((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x100) return; // bIgnoreEncroachers — skip

	CheckActorNotReferenced(Actor); // debug: verify not already tracked

	INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
	GetActorExtent(Actor, MinX, MaxX, MinY, MaxY, MinZ, MaxZ);

	for (INT x = MinX; x <= MaxX; x++) {
		for (INT y = MinY; y <= MaxY; y++) {
			for (INT z = MinZ; z <= MaxZ; z++) {
				// Grow pool if free-list exhausted.
				if (!FreeList) {
					BYTE* Slab = (BYTE*)GMalloc->Malloc(0x3000, TEXT("FCollisionLink"));
					for (INT k = 0; k < 0x3FF; k++)
						((FCollisionLink*)(Slab + k*12))->Next = (FCollisionLink*)(Slab + (k+1)*12);
					((FCollisionLink*)(Slab + 0x3FF*12))->Next = NULL;
					FreeList = (FCollisionLink*)Slab;
					AllocatedPools.AddItem((void*)Slab);
				}
				FCollisionLink* Node = FreeList;
				FreeList = Node->Next;
				Node->Actor   = Actor;
				Node->HashPos = (z * 0x400 + y) * 0x400 + x;
				FCollisionLink*& Bucket = Buckets[HashX[x] ^ HashY[y] ^ HashZ[z]];
				Node->Next = Bucket;
				Bucket = Node;
				GHashLinkCellCount++;
				GHashExtraCount++;
			}
		}
	}
	GHashActorCount++;
	// Save current location as ColLocation so we can find the right cells on removal.
	*(DWORD*)((BYTE*)Actor + 0x308) = *(DWORD*)((BYTE*)Actor + 0x234);
	*(DWORD*)((BYTE*)Actor + 0x30c) = *(DWORD*)((BYTE*)Actor + 0x238);
	*(DWORD*)((BYTE*)Actor + 0x310) = *(DWORD*)((BYTE*)Actor + 0x23c);
}

// ?CheckActorLocations@FCollisionHash@@UAEXPAVULevel@@@Z
void FCollisionHash::CheckActorLocations(ULevel * p0) {}

// ?CheckActorNotReferenced@FCollisionHash@@UAEXPAVAActor@@@Z
void FCollisionHash::CheckActorNotReferenced(AActor * p0) {}

// ?CheckIsEmpty@FCollisionHash@@UAEXXZ
void FCollisionHash::CheckIsEmpty() {}

// ?RemoveActor@FCollisionHash@@UAEXPAVAActor@@@Z
// Retail ordinal 4274 (0x6f0c0).  Removes an actor from every hash cell it
// occupies by walking the ColLocation extent (not current Location, so it
// works even if the actor has moved since it was added).  Returns links to pool.
void FCollisionHash::RemoveActor(AActor* Actor) {
	check((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x800); // bCollideActors must be set
	if (*(SBYTE*)((BYTE*)Actor + 0xa0) < 0) return;  // bDeleteMe
	// NOTE: retail also checks ColLocation == Location consistency here;
	// omitted as it only matters for editor-time diagnostics.

	INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
	GetActorExtent(Actor, MinX, MaxX, MinY, MaxY, MinZ, MaxZ);

	for (INT x = MinX; x <= MaxX; x++) {
		for (INT y = MinY; y <= MaxY; y++) {
			for (INT z = MinZ; z <= MaxZ; z++) {
				FCollisionLink** pp = &Buckets[HashX[x] ^ HashY[y] ^ HashZ[z]];
				while (*pp) {
					if ((*pp)->Actor == Actor) {
						FCollisionLink* Removed = *pp;
						*pp = Removed->Next;
						Removed->Next = FreeList;
						FreeList = Removed;
					} else {
						pp = &(*pp)->Next;
					}
				}
			}
		}
	}
}

// ?Tick@FCollisionHash@@UAEXXZ
// Retail ordinal 4860 (0x6d6d0).  Resets per-frame performance counters.
void FCollisionHash::Tick() {
	GHashExtraCount    = 0; // DAT_1064ff34
	GHashLinkCellCount = 0; // DAT_1064ff2c
	GHashActorCount    = 0; // DAT_1064ff28
}

// ?AddActor@FCollisionOctree@@UAEXPAVAActor@@@Z
// Ghidra (0xdc1a0): Computes actor bbox, inserts into octree via SingleNodeFilter
// or MultiNodeFilter depending on whether actor is flagged bStatic.
// Simplified: insert into root node's flat actor list directly.
void FCollisionOctree::AddActor(AActor* Actor)
{
	check((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x800);          // bCollideActors
	if (*(SBYTE*)((BYTE*)Actor + 0xa0) < 0) return;           // bDeleteMe
	if ((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x100) return;     // bNoCollision
	// Skip if already registered (actor's OctreeNodes list non-empty)
	TArray<FOctreeNode*>& NodeList = *(TArray<FOctreeNode*>*)((BYTE*)Actor + 0x338);
	if (NodeList.Num() > 0) return;
	// Insert into root node (simplified flat storage — no octant subdivision)
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (Root) Root->SingleNodeFilter(Actor, this, NULL);
	// Save ColLocation for consistent removal even after the actor moves
	*(DWORD*)((BYTE*)Actor + 0x308) = *(DWORD*)((BYTE*)Actor + 0x234);
	*(DWORD*)((BYTE*)Actor + 0x30c) = *(DWORD*)((BYTE*)Actor + 0x238);
	*(DWORD*)((BYTE*)Actor + 0x310) = *(DWORD*)((BYTE*)Actor + 0x23c);
}

// ?CheckActorLocations@FCollisionOctree@@UAEXPAVULevel@@@Z
void FCollisionOctree::CheckActorLocations(ULevel * p0) {}

// ?CheckActorNotReferenced@FCollisionOctree@@UAEXPAVAActor@@@Z
void FCollisionOctree::CheckActorNotReferenced(AActor * p0) {}

// ?CheckIsEmpty@FCollisionOctree@@UAEXXZ
void FCollisionOctree::CheckIsEmpty() {}

// ?RemoveActor@FCollisionOctree@@UAEXPAVAActor@@@Z
// Ghidra (0xdbd00): Removes actor from every octree node it appears in,
// then clears actor's OctreeNodes list.
void FCollisionOctree::RemoveActor(AActor* Actor)
{
	check((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x800);  // bCollideActors
	if (*(SBYTE*)((BYTE*)Actor + 0xa0) < 0) return;   // bDeleteMe
	// Remove actor from each node in its OctreeNodes list
	TArray<FOctreeNode*>& NodeList = *(TArray<FOctreeNode*>*)((BYTE*)Actor + 0x338);
	for (INT i = 0; i < NodeList.Num(); i++)
	{
		FOctreeNode* Node = NodeList(i);
		if (!Node) continue;
		TArray<AActor*>& ActorList = *(TArray<AActor*>*)Node;
		ActorList.RemoveItem(Actor);
	}
	NodeList.Empty();
}

// ?Tick@FCollisionOctree@@UAEXXZ
void FCollisionOctree::Tick() {}

// ?MeshBuildBounds@UMeshInstance@@UAEXXZ
void UMeshInstance::MeshBuildBounds() {}

// ?m_vStartLipsynch@ECLipSynchData@@QAEXXZ
void ECLipSynchData::m_vStartLipsynch()
{
	bPlaying = 1;
}

// ?m_vStopLipsynch@ECLipSynchData@@QAEXXZ
void ECLipSynchData::m_vStopLipsynch() {}

// ?m_vUpdateBonesCompressed@ECLipSynchData@@QAEXH@Z
void ECLipSynchData::m_vUpdateBonesCompressed(int p0) {}

// ?m_vUpdateBonesCompressed_BoneView@ECLipSynchData@@QAEXH@Z
void ECLipSynchData::m_vUpdateBonesCompressed_BoneView(int p0) {}

// ?m_vUpdateBonesCompressed_PhonemsSeq@ECLipSynchData@@QAEXH@Z
void ECLipSynchData::m_vUpdateBonesCompressed_PhonemsSeq(int p0) {}

// ?m_vUpdateLipSynch@ECLipSynchData@@QAEXM@Z
void ECLipSynchData::m_vUpdateLipSynch(float p0) {}

// ?GetHashIndices@FCollisionHash@@QAEXVFVector@@AAH11@Z
// Retail ordinal 3033 (0x6dd20).
// Converts a world-space coordinate to a hash-table grid index in each axis.
// Grid resolution: each cell = 256 unreal units; world spans [-262144, +262144].
void FCollisionHash::GetHashIndices(FVector V, INT& XI, INT& YI, INT& ZI) {
	XI = Clamp(appRound((V.X + 262144.0f) * 0.00390625f), 0, 0x3FFF);
	YI = Clamp(appRound((V.Y + 262144.0f) * 0.00390625f), 0, 0x3FFF);
	ZI = Clamp(appRound((V.Z + 262144.0f) * 0.00390625f), 0, 0x3FFF);
}

// ?GetActorExtent@FCollisionHash@@QAEXPAVAActor@@AAH11111@Z
// Retail ordinal 2897 (0x6dde0).
// Converts the actor's collision bounding box into a 3D range of hash indices.
void FCollisionHash::GetActorExtent(AActor* Actor, INT& MinX, INT& MaxX, INT& MinY, INT& MaxY, INT& MinZ, INT& MaxZ) {
	FBox Box = Actor->GetPrimitive()->GetCollisionBoundingBox(Actor);
	GetHashIndices(Box.Min, MinX, MinY, MinZ);
	GetHashIndices(Box.Max, MaxX, MaxY, MaxZ);
}

// ?GetSamples@FMatineeTools@@QAEXPAVASceneManager@@PAVUMatAction@@PAV?$TArray@VFVector@@@@@Z
void FMatineeTools::GetSamples(ASceneManager * p0, UMatAction * p1, TArray<FVector> * p2) {}

// ?Init@FMatineeTools@@QAEXXZ
void FMatineeTools::Init() {}

// ?ActorEncroachmentCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
// Node-level encroachment check.  Reads query state from OctHash->Pad:
//   Pad[96..99]   = SourceActor (the encroaching actor)
//   Pad[16..27]   = query Location (FVector)
//   Pad[80..87]   = Extent (FVector, zero for point test)
//   Pad[88..91]   = TraceFlags (DWORD)
void FOctreeNode::ActorEncroachmentCheck(FCollisionOctree* OctHash, FPlane const* NodePlane)
{
	INT     Frame       = *(INT*)(OctHash->Pad + 4);
	FCheckResult*& List = *(FCheckResult**)(OctHash->Pad + 8);
	FMemStack* Mem      = *(FMemStack**)(OctHash->Pad + 12);
	AActor* SourceActor = *(AActor**)(OctHash->Pad + 96);
	FVector Location    = *(FVector*)(OctHash->Pad + 16);
	DWORD TraceFlags    = *(DWORD*)(OctHash->Pad + 88);

	TArray<AActor*>& Actors = *(TArray<AActor*>*)this;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A || A == SourceActor) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (A->ShouldTrace(SourceActor, TraceFlags))
		{
			FCheckResult TestHit(1.f);
			if (A->GetPrimitive()->PointCheck(TestHit, A, Location, FVector(0,0,0), 0) == 0)
			{
				FCheckResult* CR = (FCheckResult*)Mem->PushBytes(sizeof(FCheckResult), 8);
				if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
			}
		}
	}
}

// ?ActorNonZeroExtentLineCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
// Capsule line check — like the zero-extent version but passes Extent to LineCheck.
void FOctreeNode::ActorNonZeroExtentLineCheck(FCollisionOctree* OctHash, FPlane const* NodePlane)
{
	INT     Frame       = *(INT*)(OctHash->Pad + 4);
	FCheckResult*& List = *(FCheckResult**)(OctHash->Pad + 8);
	FMemStack* Mem      = *(FMemStack**)(OctHash->Pad + 12);
	FVector   Start     = *(FVector*)(OctHash->Pad + 16);
	FVector   End       = *(FVector*)(OctHash->Pad + 28);
	FVector   Extent    = *(FVector*)(OctHash->Pad + 80);
	DWORD TraceFlags    = *(DWORD*)(OctHash->Pad + 88);
	DWORD TypeFlags     = *(DWORD*)(OctHash->Pad + 92);
	AActor* SourceActor = *(AActor**)(OctHash->Pad + 96);

	TArray<AActor*>& Actors = *(TArray<AActor*>*)this;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (A == SourceActor) continue;
		bool bIgnored = false;
		for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI + 0x140))
			if ((AActor*)pI == A) { bIgnored = true; break; }
		if (bIgnored) continue;
		if (A->ShouldTrace(SourceActor, TraceFlags))
		{
			FCheckResult TestHit(0.f);
			if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start, Extent, TypeFlags, TraceFlags) == 0)
			{
				FCheckResult* CR = (FCheckResult*)Mem->PushBytes(sizeof(FCheckResult), 8);
				if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
			}
		}
	}
}

// ?ActorOverlapCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::ActorOverlapCheck(FCollisionOctree * p0, FPlane const * p1) {}

// ?ActorPointCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@PAVAActor@@@Z
void FOctreeNode::ActorPointCheck(FCollisionOctree* OctHash, FPlane const* NodePlane, AActor* SourceActor)
{
	INT     Frame       = *(INT*)(OctHash->Pad + 4);
	FCheckResult*& List = *(FCheckResult**)(OctHash->Pad + 8);
	FVector Location    = *(FVector*)(OctHash->Pad + 16);
	FVector Extent      = *(FVector*)(OctHash->Pad + 80);
	DWORD TraceFlags    = *(DWORD*)(OctHash->Pad + 88);

	TArray<AActor*>& Actors = *(TArray<AActor*>*)this;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		if (!A->ShouldTrace(SourceActor, TraceFlags)) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		FCheckResult TestHit(1.f);
		if (A->GetPrimitive()->PointCheck(TestHit, A, Location, Extent, 0) == 0)
		{
			FCheckResult* CR = (FCheckResult*)GMem.PushBytes(sizeof(FCheckResult), 8);
			if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
		}
	}
}

// ?ActorRadiusCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::ActorRadiusCheck(FCollisionOctree* OctHash, FPlane const* NodePlane)
{
	INT     Frame       = *(INT*)(OctHash->Pad + 4);
	FCheckResult*& List = *(FCheckResult**)(OctHash->Pad + 8);
	FMemStack* Mem      = *(FMemStack**)(OctHash->Pad + 12);
	FVector   Center    = *(FVector*)(OctHash->Pad + 16);
	FLOAT     Radius    = *(FLOAT*)(OctHash->Pad + 80);  // radius in Extent.X
	DWORD TraceFlags    = *(DWORD*)(OctHash->Pad + 88);

	TArray<AActor*>& Actors = *(TArray<AActor*>*)this;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (!A->ShouldTrace(NULL, TraceFlags)) continue;
		const FLOAT dx = A->Location.X - Center.X;
		const FLOAT dy = A->Location.Y - Center.Y;
		const FLOAT dz = A->Location.Z - Center.Z;
		if (dx*dx + dy*dy + dz*dz <= Radius*Radius)
		{
			FCheckResult* CR = (FCheckResult*)Mem->PushBytes(sizeof(FCheckResult), 8);
			if (CR)
			{
				appMemzero(CR, sizeof(FCheckResult));
				CR->Actor = A;
				CR->GetNext() = List;
				List = CR;
			}
		}
	}
}

// ?ActorZeroExtentLineCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@MMMMMMPBVFPlane@@@Z
// Entry point for a ray test against actors in this node.  The caller passes
// Start and End as individual floats; Ghidra confirmed the packing order is
// Start.X, Start.Y, Start.Z, End.X, End.Y, End.Z.
void FOctreeNode::ActorZeroExtentLineCheck(FCollisionOctree* OctHash, float Sx, float Sy, float Sz, float Ex, float Ey, float Ez, FPlane const* NodePlane)
{
	INT     Frame       = *(INT*)(OctHash->Pad + 4);
	FCheckResult*& List = *(FCheckResult**)(OctHash->Pad + 8);
	FMemStack* Mem      = *(FMemStack**)(OctHash->Pad + 12);
	DWORD TraceFlags    = *(DWORD*)(OctHash->Pad + 88);
	DWORD TypeFlags     = *(DWORD*)(OctHash->Pad + 92);
	AActor* SourceActor = *(AActor**)(OctHash->Pad + 96);
	FVector Start(Sx, Sy, Sz);
	FVector End(Ex, Ey, Ez);

	TArray<AActor*>& Actors = *(TArray<AActor*>*)this;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (A == SourceActor) continue;
		bool bIgnored = false;
		for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI + 0x140))
			if ((AActor*)pI == A) { bIgnored = true; break; }
		if (bIgnored) continue;
		if (A->ShouldTrace(SourceActor, TraceFlags))
		{
			FCheckResult TestHit(0.f);
			if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start, FVector(0,0,0), TypeFlags, TraceFlags) == 0)
			{
				FCheckResult* CR = (FCheckResult*)Mem->PushBytes(sizeof(FCheckResult), 8);
				if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
			}
		}
	}
}

// ?CheckActorNotReferenced@FOctreeNode@@QAEXPAVAActor@@@Z
void FOctreeNode::CheckActorNotReferenced(AActor * p0) {}

// ?CheckIsEmpty@FOctreeNode@@QAEXXZ
void FOctreeNode::CheckIsEmpty() {}

// ?Draw@FOctreeNode@@QAEXVFColor@@HPBVFPlane@@@Z
void FOctreeNode::Draw(FColor p0, int p1, FPlane const * p2) {}

// ?DrawFlaggedActors@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::DrawFlaggedActors(FCollisionOctree * p0, FPlane const * p1) {}

// ?FilterTest@FOctreeNode@@QAEXPAVFBox@@HPAV?$TArray@PAVFOctreeNode@@@@PBVFPlane@@@Z
void FOctreeNode::FilterTest(FBox * p0, int p1, TArray<FOctreeNode *> * p2, FPlane const * p3) {}

// ?MultiNodeFilter@FOctreeNode@@QAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
// Ghidra (0xd8ec0): In the full octree, routes actor to all overlapping child nodes.
// Simplified: store at this node directly (no subdivision).
void FOctreeNode::MultiNodeFilter(AActor* Actor, FCollisionOctree* OctHash, FPlane const* Plane)
{
	StoreActor(Actor, OctHash, Plane);
}

// ?RemoveAllActors@FOctreeNode@@QAEXPAVFCollisionOctree@@@Z
// Ghidra (0xdb3e0): Recursively clears all actors from this node and its children.
// Simplified: just clear this node's actor list.
void FOctreeNode::RemoveAllActors(FCollisionOctree* OctHash)
{
	TArray<AActor*>& ActorList = *(TArray<AActor*>*)this;
	ActorList.Empty();
}

// ?SingleNodeFilter@FOctreeNode@@QAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
// Ghidra (0xdc010): In the full octree, routes actor to the single containing child.
// Simplified: store at this node directly (no subdivision).
void FOctreeNode::SingleNodeFilter(AActor* Actor, FCollisionOctree* OctHash, FPlane const* Plane)
{
	StoreActor(Actor, OctHash, Plane);
}

// ?BuildActionSpotList@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: For each AR6ActionSpot, set CollisionHeight, call PutOnGround,
// find a NavigationPoint anchor within 1200 uu via FSortedPathList, then
// chain into LevelInfo->m_ActionSpotList linked list.
void FPathBuilder::BuildActionSpotList(ULevel* Level) {
	*(ULevel**)Pad = Level;
	// Spawn a scout if one is not already present (local_18 tracks whether we did)
	UBOOL bSpawnedScout = (*(APawn**)(Pad + 4) == NULL);
	if (bSpawnedScout)
		getScout();

	// Mark scout as "is player" for pathing purposes
	APawn* Scout = *(APawn**)(Pad + 4);
	*(BYTE*)((BYTE*)Scout + 0x2c) = 1;

	ALevelInfo* LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	LInfo->m_ActionSpotList = NULL;	// LevelInfo+0x4dc

	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (!Actor) continue;
		// IsA(AR6ActionSpot) && !bAutoBuilt (signed char at Actor+0xa0 >= 0)
		if (!Actor->IsA(AR6ActionSpot::StaticClass())) continue;
		if ((SBYTE)(*(BYTE*)((BYTE*)Actor + 0xa0)) < 0) continue;

		FSortedPathList SortedList;
		// Initialise count field to 0 (at Pad+0x100)
		*(INT*)(SortedList.Pad + 0x100) = 0;

		AR6ActionSpot* Spot = (AR6ActionSpot*)Actor;
		// Set CollisionHeight (Actor+0xfc): 70.0f if m_eFire==2, else 135.0f
		if (Spot->m_eFire == 2)
			*(FLOAT*)((BYTE*)Spot + 0xfc) = 70.0f;
		else
			*(FLOAT*)((BYTE*)Spot + 0xfc) = 135.0f;

		Spot->PutOnGround();

		LInfo = (*(ULevel**)Pad)->GetLevelInfo();
		for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
			// Skip if nav point has bit 2 set at offset 0x3a4
			if ((*(DWORD*)(Nav + 0x3a4) & 2) != 0) continue;
			// Compute squared distance from Spot->Location (FVector at 0x234) to nav point
			FLOAT dx = *(FLOAT*)((BYTE*)Spot + 0x234) - *(FLOAT*)(Nav + 0x234);
			FLOAT dy = *(FLOAT*)((BYTE*)Spot + 0x238) - *(FLOAT*)(Nav + 0x238);
			FLOAT dz = *(FLOAT*)((BYTE*)Spot + 0x23c) - *(FLOAT*)(Nav + 0x23c);
			FLOAT DistSq = dx*dx + dy*dy + dz*dz;
			// 1200 uu radius → 1440000 uu² threshold
			if (DistSq < 1440000.0f)
				SortedList.addPath((ANavigationPoint*)Nav, (INT)DistSq);
		}

		// If list has entries, find the best anchor
		if (*(INT*)(SortedList.Pad + 0x100) > 0) {
			FVector SpotLoc(*(FLOAT*)((BYTE*)Spot+0x234),
			                *(FLOAT*)((BYTE*)Spot+0x238),
			                *(FLOAT*)((BYTE*)Spot+0x23c));
			Spot->m_Anchor = SortedList.findEndAnchor(Scout, Spot, SpotLoc, 0);
		}

		// If an anchor was found, prepend to m_ActionSpotList linked list
		if (Spot->m_Anchor) {
			LInfo = (*(ULevel**)Pad)->GetLevelInfo();
			Spot->m_NextSpot = LInfo->m_ActionSpotList;
			LInfo->m_ActionSpotList = Spot;
		}
	}

	// Clean up scout if we spawned it
	if (bSpawnedScout) {
		Scout = *(APawn**)(Pad + 4);
		AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
		if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
		(*(ULevel**)Pad)->DestroyActor(Scout);
	}
}

// ?ReviewPaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: for each NavigationPoint in linked list, call ReviewPath(Scout);
// then warn about movers without associated nav points.
void FPathBuilder::ReviewPaths(ULevel* Level) {
	debugf(NAME_Log, TEXT("Reviewing paths"));
	GWarn->BeginSlowTask(TEXT("Reviewing paths..."), 0, 0);
	*(ULevel**)Pad = Level;

	if (Level) {
		ALevelInfo* LInfo = Level->GetLevelInfo();
		if (LInfo) {
			LInfo = *(ULevel**)Pad ? (*(ULevel**)Pad)->GetLevelInfo() : NULL;
			if (LInfo && *(INT*)((BYTE*)LInfo + 0x4d0) != 0) {
				// Count nav points to display progress
				INT Count = 0;
				for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8))
					Count++;

				getScout();
				SetPathCollision(1);

				APawn* Scout = *(APawn**)(Pad + 4);
				LInfo = (*(ULevel**)Pad)->GetLevelInfo();
				// Ghidra: call NavPoint->vtable[0x1a8](Scout) = ReviewPath(Scout)
				typedef void (__thiscall* tReviewPath)(BYTE*, APawn*);
				for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
					GWarn->StatusUpdatef(0, Count, TEXT("Reviewing Paths"));
					tReviewPath fn = *(tReviewPath*)((BYTE*)(*(void**)Nav) + 0x1a8);
					fn(Nav, Scout);
				}

				SetPathCollision(0);
				// Destroy Scout's AIController (Scout+0x4ec) and Scout via Level->DestroyActor
				AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
				if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
				(*(ULevel**)Pad)->DestroyActor(Scout);

				// Check movers for missing associated navigation points
				for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
					GWarn->StatusUpdatef(i, (*(ULevel**)Pad)->Actors.Num(), TEXT("Reviewing Movers"));
					AActor* Actor = (*(ULevel**)Pad)->Actors(i);
					if (Actor && Actor->IsA(AMover::StaticClass())) {
						// Skip mover if it has the 0x4000 flag set (bStatic path)
						if ((*(DWORD*)((BYTE*)Actor + 0x3b8) & 0x4000) == 0 &&
							*(INT*)((BYTE*)Actor + 0x3fc) == 0)
						{
							// Mover has no associated nav path - warn
							// Deviation: skip extended GWarn vtable call (slot 0x28 not declared)
							debugf(NAME_Warning, TEXT("No navigation point associated with this mover!"));
						}
					}
				}
				GWarn->EndSlowTask();
				return;
			}
		}
	}

	// No nav point list defined
	debugf(NAME_Warning, TEXT("No navigation point list. Paths define needed."));
	GWarn->EndSlowTask();
}

// ?defineChangedPaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: Partial redefinition — re-runs path building only for nav points
// flagged as changed (no 0x800 bit at NavPoint+0x3a4). For unchanged nav
// points, empties their PathList (TArray at +0x3d8). Same scout+pass sequence
// as definePaths but operates on the changed subset and spawns its own scout.
void FPathBuilder::defineChangedPaths(ULevel* Level) {
	*(ULevel**)Pad = Level;

	// Clear NavigationPointList head and the bPathsRebuilt bit
	ALevelInfo* LInfo = Level->GetLevelInfo();
	*(INT*)((BYTE*)LInfo + 0x4d0) = 0;
	LInfo = Level->GetLevelInfo();
	*(DWORD*)((BYTE*)LInfo + 0x94c) &= ~1u;

	// Pass 0: build nav point linked list (no InitForPathFinding here)
	for (INT i = 0; i < Level->Actors.Num(); i++) {
		AActor* Actor = Level->Actors(i);
		if (!Actor) continue;
		if (!Actor->IsA(ANavigationPoint::StaticClass())) continue;
		if ((SBYTE)(*(BYTE*)((BYTE*)Actor + 0xa0)) < 0) continue; // bAutoBuilt
		LInfo = (*(ULevel**)Pad)->GetLevelInfo();
		*(INT*)((BYTE*)Actor + 0x3a8) = *(INT*)((BYTE*)LInfo + 0x4d0);
		*(INT*)((BYTE*)LInfo + 0x4d0) = (INT)Actor;
	}

	// Pre-pass: for each nav point, decide how to handle changed vs unchanged
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		ANavigationPoint* NavPt = (ANavigationPoint*)Nav;
		if ((*(DWORD*)(Nav + 0x3a4) & 0x800) == 0) {
			// Not marked changed: check reachspecs for changed endpoints, prune
			TArray<UReachSpec*>& PathList = *(TArray<UReachSpec*>*)(Nav + 0x3d8);
			for (INT j = 0; j < PathList.Num(); j++) {
				UReachSpec* Spec = PathList(j);
				if (Spec && Spec->End && (*(DWORD*)((BYTE*)Spec->End + 0x3a4) & 0x800) != 0)
					*(BYTE*)((BYTE*)Spec + 0x2c) = 1; // mark pruned
			}
			NavPt->CleanUpPruned();
		} else {
			// Marked changed: empty the path list entirely
			// Ghidra: FArray::Empty(&NavPoint[0x3d8], 4, 0)
			((TArray<UReachSpec*>*)(Nav + 0x3d8))->Empty();
		}
	}

	getScout();
	// Verify Actors(0) is ALevelInfo
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Clear nav list and rebuild it for the main passes
	*(INT*)((BYTE*)(*(ULevel**)Pad)->Actors(0) + 0x4d0) = 0;
	GWarn->BeginSlowTask(TEXT("Defining Paths"), 1, 0);

	SetPathCollision(1);
	INT NavCount = 0;
	// Count NavPoints in first loop
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		GWarn->StatusUpdatef(i, (*(ULevel**)Pad)->Actors.Num(), TEXT("Defining"));
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (Actor && Actor->IsA(ANavigationPoint::StaticClass())) NavCount++;
	}

	// Verify + clear LevelInfo nav list head again
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
	*(INT*)((BYTE*)(*(ULevel**)Pad)->Actors(0) + 0x4d0) = 0;

	INT nc = 0;
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		GWarn->StatusUpdatef(nc, NavCount, TEXT("Navigation Points on Bases"));
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (!Actor) continue;
		if (!Actor->IsA(ANavigationPoint::StaticClass())) continue;
		if ((SBYTE)(*(BYTE*)((BYTE*)Actor + 0xa0)) < 0) continue; // bAutoBuilt
		nc++;
		// Verify + add to list with Actors(0) check
		if (!(*(ULevel**)Pad)->Actors(0))
			appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
		if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
			appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
		LInfo = (*(ULevel**)Pad)->GetLevelInfo();
		*(INT*)((BYTE*)Actor + 0x3a8) = *(INT*)((BYTE*)LInfo + 0x4d0);
		*(INT*)((BYTE*)LInfo + 0x4d0) = (INT)Actor;
		// InitForPathFinding at vtable[0x19c]
		typedef void (__thiscall* tInitPath)(BYTE*);
		tInitPath fn = *(tInitPath*)((BYTE*)(*(void**)Actor) + 0x19c);
		fn((BYTE*)Actor);
	}

	// Verify Actors(0)
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Pass 2: FindBase on each nav point (vtable[0x190])
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tFindBase)(BYTE*);
		tFindBase fn = *(tFindBase*)((BYTE*)(*(void**)Nav) + 0x190);
		fn(Nav);
	}

	debugf(NAME_Log, TEXT(""));

	// Pass 3: addReachSpecs at vtable[0x188](Scout, 1) — note: 1, not 0
	APawn* Scout = *(APawn**)(Pad + 4);
	INT rs = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(rs, NavCount, TEXT("Adding Reachspecs"));
		typedef void (__thiscall* tAddReach)(BYTE*, APawn*, INT);
		tAddReach fn = *(tAddReach*)((BYTE*)(*(void**)Nav) + 0x188);
		fn(Nav, Scout, 1);	// NOTE: int arg is 1 here (changed paths mode)
		rs++;
	}

	// Pass 4: SetupForcedPath at vtable[0x18c](Scout)
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tSetupForced)(BYTE*, APawn*);
		tSetupForced fn = *(tSetupForced*)((BYTE*)(*(void**)Nav) + 0x18c);
		fn(Nav, Scout);
	}

	debugf(NAME_Log, TEXT(""));

	// Pass 5: PrunePaths at vtable[0x1a0] with StatusUpdatef
	INT pr = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(pr, NavCount, TEXT("Pruning"));
		typedef INT (__thiscall* tPrune)(BYTE*);
		tPrune fn = *(tPrune*)((BYTE*)(*(void**)Nav) + 0x1a0);
		fn(Nav);
		pr++;
	}

	debugf(NAME_Log, TEXT(""));
	SetPathCollision(0);

	// Clear bAutoBuilt flags (0x800 at NavPoint+0x3a4)
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8))
		*(DWORD*)(Nav + 0x3a4) &= ~0x800u;

	BuildActionSpotList(Level);

	// Destroy Scout and its AIController
	Scout = *(APawn**)(Pad + 4);
	AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
	if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
	(*(ULevel**)Pad)->DestroyActor(Scout);

	debugf(NAME_Log, TEXT("defineChangedPaths done"));
	// Deviation: skip GWarn vtable[0x1c] call (undeclared)
	GWarn->EndSlowTask();
}

// ?definePaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: undefinePaths, then spawn scout, build nav-point linked list, run
// addReachSpecs + SetupForcedPath + PrunePaths + ClearPaths passes, destroy scout,
// set bPathsDefined, then BuildActionSpotList + PostPath on all actors.
void FPathBuilder::definePaths(ULevel* Level) {
	undefinePaths(Level);
	*(ULevel**)Pad = Level;
	getScout();

	ALevelInfo* LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	*(INT*)((BYTE*)LInfo + 0x4d0) = 0;	// clear NavigationPointList head
	// Clear bit 0 of LevelInfo+0x94c (bPathsRebuilt or similar)
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	*(DWORD*)((BYTE*)LInfo + 0x94c) &= ~1u;

	GWarn->BeginSlowTask(TEXT("Defining Paths"), 1, 0);
	INT NavCount = 0;
	SetPathCollision(1);

	// Pass 1: enumerate actors, build nav-point linked list, call InitForPathFinding
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		GWarn->StatusUpdatef(i, (*(ULevel**)Pad)->Actors.Num(), TEXT("Defining"));
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (!Actor) { i++; continue; }
		if (Actor->IsA(ANavigationPoint::StaticClass())) {
			NavCount++;
			// Add to linked list (LevelInfo[0x4d0] = head), NavPoint[0x3a8] = next
			LInfo = (*(ULevel**)Pad)->GetLevelInfo();
			*(INT*)((BYTE*)Actor + 0x3a8) = *(INT*)((BYTE*)LInfo + 0x4d0);
			*(INT*)((BYTE*)LInfo + 0x4d0) = (INT)Actor;
			// Ghidra: call NavPoint->vtable[0x19c](void) = InitForPathFinding
			typedef void (__thiscall* tInitPath)(BYTE*);
			tInitPath fn = *(tInitPath*)((BYTE*)(*(void**)Actor) + 0x19c);
			fn((BYTE*)Actor);
		} else {
			// Ghidra: call Actor->vtable[0x154](Scout) = AddMyMarker(Scout)
			APawn* Scout = *(APawn**)(Pad + 4);
			typedef void (__thiscall* tAddMarker)(AActor*, APawn*);
			tAddMarker fn = *(tAddMarker*)((BYTE*)(*(void**)Actor) + 0x154);
			fn(Actor, Scout);
		}
	}

	// Verify Actors(0) is LevelInfo
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Pass 2: call FindBase on each nav point (vtable[0x190/4=0x64])
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tFindBase)(BYTE*);
		tFindBase fn = *(tFindBase*)((BYTE*)(*(void**)Nav) + 0x190);
		fn(Nav);
	}

	debugf(NAME_Log, TEXT("Adding reachspecs"));

	// Pass 3: addReachSpecs(Scout, 0) on each nav point (vtable[0x188])
	APawn* Scout = *(APawn**)(Pad + 4);
	INT rs = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(rs, NavCount, TEXT("Adding Reachspecs"));
		typedef void (__thiscall* tAddReach)(BYTE*, APawn*, INT);
		tAddReach fn = *(tAddReach*)((BYTE*)(*(void**)Nav) + 0x188);
		fn(Nav, Scout, 0);
		rs++;
	}

	// Pass 4: SetupForcedPath(Scout) on each nav point (vtable[0x18c])
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tSetupForced)(BYTE*, APawn*);
		tSetupForced fn = *(tSetupForced*)((BYTE*)(*(void**)Nav) + 0x18c);
		fn(Nav, Scout);
	}

	debugf(NAME_Log, TEXT("Pruning paths"));

	// Pass 5: PrunePaths on each nav point (vtable[0x1a0]), count pruned
	INT pruned = 0; INT pr = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(pr, NavCount, TEXT("Pruning"));
		typedef INT (__thiscall* tPrune)(BYTE*);
		tPrune fn = *(tPrune*)((BYTE*)(*(void**)Nav) + 0x1a0);
		pruned += fn(Nav);
		pr++;
	}

	debugf(NAME_Log, TEXT("Paths defined"));
	
	SetPathCollision(0);

	// Clear bAutoBuilt bit (0x800 at NavPoint+0x3a4) on all nav points
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8))
		*(DWORD*)(Nav + 0x3a4) &= ~0x800u;

	// Destroy Scout's AIController and Scout
	AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
	if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
	(*(ULevel**)Pad)->DestroyActor(Scout);

	// Set bPathsDefined (bit 0x800) on LevelInfo
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
	*(DWORD*)(((BYTE*)(*(ULevel**)Pad)->Actors(0)) + 0x450) |= 0x800;

	BuildActionSpotList(Level);

	// Call vtable[0x174](void) on all actors = PostPath or CheckForErrors
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (Actor) {
			typedef void (__thiscall* tPostPath)(AActor*);
			tPostPath fn = *(tPostPath*)((BYTE*)(*(void**)Actor) + 0x174);
			fn(Actor);
		}
	}

	debugf(NAME_Log, TEXT("definePaths done"));
	// Deviation: skip GWarn vtable[0x1c] call (slot not declared)
	GWarn->EndSlowTask();
}

// ?undefinePaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: destroy all non-transient ANavigationPoints; for transient ones call ClearPaths (vtable[0x66]);
// clear bPathsDefined on LevelInfo.
void FPathBuilder::undefinePaths(ULevel* Level) {
	*(ULevel**)Pad = Level;
	debugf(NAME_Log, TEXT("Undefining paths"));

	ALevelInfo* LInfo = Level->GetLevelInfo();
	*(DWORD*)((BYTE*)LInfo + 0x4d0) = 0;	// clear navigation point linked list head

	GWarn->BeginSlowTask(TEXT("Undefining"), 0, 0);

	INT i = 0;
	for (;;) {
		INT Num = Level->Actors.Num();
		if (i >= Num) {
			// Post-loop: verify Actors(0) and clear bPathsDefined (bit 0x800)
			if (!Level->Actors(0))
				appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
			if (!Level->Actors(0)->IsA(ALevelInfo::StaticClass()))
				appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
			*(DWORD*)(((BYTE*)Level->Actors(0)) + 0x450) &= ~0x800u;
			GWarn->EndSlowTask();
			return;
		}
		GWarn->StatusUpdatef(i, Num, TEXT("Undefining"));
		AActor* Actor = Level->Actors(i);
		if (Actor && Actor->IsA(ANavigationPoint::StaticClass())) {
			UClass* Cls = Actor->GetClass();
			if ((*(DWORD*)((BYTE*)Cls + 0x48c) & 0x200) == 0) {
				// Normal nav point: destroy it then keep incrementing i
				Level->DestroyActor(Actor);
				i++;
				continue;
			} else {
				// Transient nav point: call ClearPaths via vtable slot 0x198/4 = 102
				// Deviation: vtable slot determined from Ghidra offset 0x198; likely ClearPaths()
				typedef void (__thiscall *tClearPaths)(AActor*);
				tClearPaths fn = *(tClearPaths*)((BYTE*)(*(void**)Actor) + 0x198);
				fn(Actor);
			}
		}
		i++;
	}
}

// ?Init@FPoly@@QAEXXZ
void FPoly::Init() {
	Base     = FVector(0,0,0);
	Normal   = FVector(0,0,0);
	TextureU = FVector(0,0,0);
	TextureV = FVector(0,0,0);
	PolyFlags   = 0;
	Actor       = NULL;
	Material    = NULL;
	ItemName    = FName(NAME_None);
	NumVertices = 0;
	iLink       = INDEX_NONE;
	iBrushPoly  = INDEX_NONE;
	SavePolyIndex = INDEX_NONE;
	appMemzero(_RvsExtra, sizeof(_RvsExtra));
	// LightMapScale at _RvsExtra offset 52 (0x144 - 0x110) = 32.0f
	*(FLOAT*)&_RvsExtra[52] = 32.0f;
	// Sentinel values at known offsets within _RvsExtra
	*(INT*)&_RvsExtra[56] = INDEX_NONE;  // 0x148
	*(INT*)&_RvsExtra[60] = INDEX_NONE;  // 0x14C
	*(DWORD*)&_RvsExtra[68] = 0xFF808080; // 0x154
}

// ?InsertVertex@FPoly@@QAEXHVFVector@@@Z
// NOTE: Original uses temp TArray copy+insert+copyback. Simplified to in-place shift.
void FPoly::InsertVertex(int InPos, FVector InVtx)
{
	check(InPos <= NumVertices);
	for( INT i = NumVertices; i > InPos; i-- )
		Vertex[i] = Vertex[i - 1];
	Vertex[InPos] = InVtx;
	NumVertices++;
}

// ?Reverse@FPoly@@QAEXXZ
void FPoly::Reverse() {
	Normal *= -1.f;
	for( INT i=0; i<NumVertices/2; i++ ) {
		FVector Temp = Vertex[i];
		Vertex[i] = Vertex[NumVertices-1-i];
		Vertex[NumVertices-1-i] = Temp;
	}
}

// ?SplitInHalf@FPoly@@QAEXPAV1@@Z
// ?SplitInHalf@FPoly@@QAEXPAV1@@Z — Ghidra at 0x9C640.
// Splits a polygon in two halves along the vertex midpoint.
void FPoly::SplitInHalf(FPoly * OtherHalf) {
	INT Half = NumVertices / 2;
	if( NumVertices < 4 || NumVertices > 16 )
		appErrorf( TEXT("FPoly::SplitInHalf: Vertex count = %i"), NumVertices );

	// Copy full polygon structure to the other half.
	*OtherHalf = *this;

	// Adjust vertex counts: first half gets [0..Half], second half gets [Half..N-1, 0].
	OtherHalf->NumVertices = NumVertices - Half + 1;
	NumVertices = Half + 1;

	// Copy the right-side vertices into OtherHalf.
	for( INT i=0; i<OtherHalf->NumVertices-1; i++ )
		OtherHalf->Vertex[i] = Vertex[i + Half];

	// Close the second polygon by copying back the first vertex of the original.
	OtherHalf->Vertex[OtherHalf->NumVertices - 1] = Vertex[0];

	// Mark both halves as cut (PF_EdCut = 0x80000000).
	PolyFlags |= 0x80000000;
	OtherHalf->PolyFlags |= 0x80000000;
}

// ?Transform@FPoly@@QAEXABVFModelCoords@@ABVFVector@@1M@Z
// ?Transform@FPoly@@QAEXABVFModelCoords@@ABVFVector@@1M@Z — Ghidra at 0x9C8F0.
// Transforms all polygon data by the given coordinate system.
void FPoly::Transform(FModelCoords const & Coords, FVector const & PreSubtract, FVector const & PostAdd, float Orientation) {
	// Transform texture mapping vectors by the contravariant (vector) transform.
	TextureU = TextureU.TransformVectorBy( Coords.VectorXform );
	TextureV = TextureV.TransformVectorBy( Coords.VectorXform );

	// Transform base: subtract pivot, apply covariant transform, add destination.
	Base = (Base - PreSubtract).TransformVectorBy( Coords.PointXform ) + PostAdd;

	// Transform each vertex the same way.
	for( INT i=0; i<NumVertices; i++ )
		Vertex[i] = (Vertex[i] - PreSubtract).TransformVectorBy( Coords.PointXform ) + PostAdd;

	// If orientation is negative (mirroring), reverse the winding order.
	if( Orientation < 0.f )
	{
		for( INT i=0; i<NumVertices/2; i++ )
		{
			FVector Temp = Vertex[i];
			Vertex[i] = Vertex[(NumVertices-1) - i];
			Vertex[(NumVertices-1) - i] = Temp;
		}
	}

	// Re-compute the normal after transformation.
	Normal = Normal.TransformVectorBy( Coords.VectorXform ).SafeNormal();
}

// ?Delete@FRebuildTools@@QAEXVFString@@@Z
void FRebuildTools::Delete(FString p0) {}

// ?Init@FRebuildTools@@QAEXXZ
void FRebuildTools::Init() {}

// ?SetCurrent@FRebuildTools@@QAEXVFString@@@Z
void FRebuildTools::SetCurrent(FString p0) {}

// ?Shutdown@FRebuildTools@@QAEXXZ
void FRebuildTools::Shutdown() {}

// ?AddDataPoint@FStatGraph@@QAEXVFString@@MH@Z
void FStatGraph::AddDataPoint(FString p0, float p1, int p2) {}

// ?AddLine@FStatGraph@@QAEXVFString@@VFColor@@MM@Z
void FStatGraph::AddLine(FString p0, FColor p1, float p2, float p3) {}

// ?AddLineAutoRange@FStatGraph@@QAEXVFString@@VFColor@@@Z
void FStatGraph::AddLineAutoRange(FString p0, FColor p1) {}

// ?Render@FStatGraph@@QAEXPAVUViewport@@PAVFRenderInterface@@@Z
void FStatGraph::Render(UViewport * p0, FRenderInterface * p1) {}

// ?Reset@FStatGraph@@QAEXXZ
void FStatGraph::Reset() {}

// ?AddOption@FURL@@QAEXPBG@Z
void FURL::AddOption(const TCHAR* Str) {
	const TCHAR* Eq = appStrchr(Str,'=');
	INT PrefixLen = Eq ? (INT)(Eq - Str) + 1 : appStrlen(Str) + 1;
	INT i;
	for( i=0; i<Op.Num(); i++ )
		if( appStrnicmp(*Op(i),Str,PrefixLen)==0 )
			break;
	if( i==Op.Num() )
		new(Op)FString(Str);
	else
		Op(i) = Str;
}

// ?LoadURLConfig@FURL@@QAEXPBG0@Z
void FURL::LoadURLConfig(const TCHAR* Section, const TCHAR* Filename) {
	TCHAR Buffer[32000];
	GConfig->GetSection( Section, Buffer, ARRAY_COUNT(Buffer), Filename );
	const TCHAR* Ptr = Buffer;
	while( *Ptr ) {
		AddOption( Ptr );
		Ptr += appStrlen(Ptr) + 1;
	}
}

// ?SaveURLConfig@FURL@@QBEXPBG00@Z
void FURL::SaveURLConfig(const TCHAR* Section, const TCHAR* Key, const TCHAR* Filename) const {
	for( INT i=0; i<Op.Num(); i++ ) {
		TCHAR Temp[1024];
		appStrcpy( Temp, *Op(i) );
		TCHAR* Value = appStrchr( Temp, '=' );
		if( Value ) {
			*Value++ = 0;
			if( appStricmp(Temp, Key)==0 )
				GConfig->SetString( Section, Temp, Value, Filename );
		}
	}
}

// ?HalveData@FWaveModInfo@@QAEXXZ
// Ghidra: halve sample rate with error-diffusion filter, both 16-bit and 8-bit paths
void FWaveModInfo::HalveData()
{
	if (*pBitsPerSample == 16)
	{
		DWORD DataSize = SampleDataSize;
		short* Data = (short*)SampleDataStart;
		INT Accum = 0;
		INT Prev = Data[0];
		for (DWORD i = 0; i < DataSize >> 2; i++)
		{
			INT Cur = Data[i * 2 + 1];
			Accum = Accum + Prev + 0x20000 + Data[i * 2] * 2 + Cur;
			DWORD Val = (Accum + 2) & 0x3FFFC;
			if (Val > 0x3FFFC) Val = 0x3FFFC;
			Data[i] = (short)((INT)Val >> 2) - 0x8000;
			Accum = Accum - Val;
			Prev = Cur;
		}
		NewDataSize = (DataSize >> 2) << 1;
		*pSamplesPerSec >>= 1;
	}
	else if (*pBitsPerSample == 8)
	{
		DWORD DataSize = SampleDataSize;
		BYTE* Data = SampleDataStart;
		INT Accum = 0;
		DWORD Prev = Data[0];
		for (DWORD i = 0; i < DataSize >> 1; i++)
		{
			BYTE Next = Data[i * 2 + 1];
			Accum = Accum + Prev + Data[i * 2] * 2 + Next;
			DWORD Val = (Accum + 2) & 0x3FC;
			if (Val > 0x3FC) Val = 0x3FC;
			Data[i] = (BYTE)(Val >> 2);
			Accum = Accum - Val;
			Prev = Next;
		}
		NewDataSize = DataSize >> 1;
		*pSamplesPerSec >>= 1;
	}
}

// ?HalveReduce16to8@FWaveModInfo@@QAEXXZ
// Ghidra: halve + reduce 16-bit to 8-bit in one pass with error diffusion
void FWaveModInfo::HalveReduce16to8()
{
	DWORD DataSize = SampleDataSize;
	short* Data16 = (short*)SampleDataStart;
	BYTE* Data8 = SampleDataStart;
	INT Accum = 0;
	INT Prev = Data16[0];
	for (DWORD i = 0; i < DataSize >> 2; i++)
	{
		INT Cur = Data16[i * 2 + 1];
		Accum = Accum + Prev + 0x20000 + Data16[i * 2] * 2 + Cur;
		DWORD Val = (Accum + 0x200) & 0xFFFFFC00;
		if ((INT)Val > 0x3FC00) Val = 0x3FC00;
		Data8[i] = (BYTE)(Val >> 10);
		Accum = Accum - Val;
		Prev = Cur;
	}
	NewDataSize = DataSize >> 2;
	*pBitsPerSample = 8;
	*pSamplesPerSec >>= 1;
	NoiseGate = 1;
}

// ?NoiseGateFilter@FWaveModInfo@@QAEXXZ
// Ghidra: gates silent sections in 8-bit audio data
void FWaveModInfo::NoiseGateFilter()
{
	BYTE* Data = SampleDataStart;
	INT TotalSamples = *pWaveDataSize;
	DWORD Rate = *pSamplesPerSec;
	INT SilenceStart = 0;

	for (INT i = 0; i < TotalSamples; i++)
	{
		// Compute amplitude (distance from 0x80 midpoint)
		INT Amp = (INT)Data[i] - 0x80;
		if (Amp < 0) Amp = -Amp;

		UBOOL IsLoud = (Amp >= 0x12);
		// Debounce: if loud and close to previous loud section, treat as loud
		if (IsLoud && SilenceStart > 0 && (i - SilenceStart) < (INT)((Rate / 0x2B11) << 5))
			IsLoud = 0;

		if (SilenceStart == 0)
		{
			if (!IsLoud)
				SilenceStart = i;
		}
		else if (IsLoud || i == TotalSamples - 1)
		{
			// If silence duration exceeds threshold, gate it
			if ((i - SilenceStart) >= (INT)((Rate / 0x2B11) * 0x35C))
			{
				for (INT j = SilenceStart; j < i; j++)
					Data[j] = 0x80;
			}
			SilenceStart = 0;
		}
	}
}

// ?Reduce16to8@FWaveModInfo@@QAEXXZ
void FWaveModInfo::Reduce16to8()
{
	// Convert 16-bit signed PCM to 8-bit unsigned with error diffusion dithering.
	DWORD DataSize = SampleDataSize;
	short* Data16 = (short*)SampleDataStart;
	BYTE* Data8 = SampleDataStart;
	INT Error = 0;
	for (DWORD i = 0; i < DataSize >> 1; i++)
	{
		Error = Error + 0x8000 + (INT)Data16[i];
		INT Quantized = (Error + 0x7F) & 0xFFFFFF00;
		if (Quantized > 0xFF00)
			Quantized = 0xFF00;
		Data8[i] = (BYTE)(Quantized >> 8);
		Error = Error - Quantized;
	}
	NewDataSize = DataSize >> 1;
	*pBitsPerSample = 8;
	NoiseGate = 1;
}

// ?AVIStart@@YAXPBGPAVUEngine@@H@Z
void AVIStart(const TCHAR* p0, UEngine * p1, int p2) {}

// ?AVIStop@@YAXXZ
void AVIStop() {}

// ?AVITakeShot@@YAXPAVUEngine@@@Z
void AVITakeShot(UEngine * p0) {}

// ?DrawSprite@@YAXPAVAActor@@VFVector@@PAVUMaterial@@PAVFLevelSceneNode@@PAVFRenderInterface@@@Z
void DrawSprite(AActor * p0, FVector p1, UMaterial * p2, FLevelSceneNode * p3, FRenderInterface * p4) {}

// ?DrawSprite@@YAXMVFVector@@0PAVUMaterial@@VFPlane@@EPAVFCameraSceneNode@@PAVFRenderInterface@@MHH@Z
void DrawSprite(float p0, FVector p1, FVector p2, UMaterial * p3, FPlane p4, BYTE p5, FCameraSceneNode * p6, FRenderInterface * p7, float p8, int p9, int p10) {}

// ?KME2UPosition@@YAXPAVFVector@@QBM@Z
void KME2UPosition(FVector* Out, float const * const In) {
	Out->X = In[0] * 50.0f;
	Out->Y = In[1] * 50.0f;
	Out->Z = In[2] * 50.0f;
}

// ?KME2UVecCopy@@YAXPAVFVector@@QBM@Z
void KME2UVecCopy(FVector* Out, float const * const In) {
	Out->X = In[0];
	Out->Y = In[1];
	Out->Z = In[2];
}

// ?KTermGameKarma@@YAXXZ
void KTermGameKarma() {}

// ?KU2MEPosition@@YAXQAMVFVector@@@Z
void KU2MEPosition(float * const Out, FVector In) {
	Out[0] = In.X * 0.02f;
	Out[1] = In.Y * 0.02f;
	Out[2] = In.Z * 0.02f;
}

// ?KU2MEVecCopy@@YAXQAMVFVector@@@Z
void KU2MEVecCopy(float * const Out, FVector In) {
	Out[0] = In.X;
	Out[1] = In.Y;
	Out[2] = In.Z;
}

// ?KUpdateMassProps@@YAXPAVUKMeshProps@@@Z
void KUpdateMassProps(UKMeshProps * p0) {}

// ?KarmaTriListDataInit@@YAXPAU_KarmaTriListData@@@Z
void KarmaTriListDataInit(_KarmaTriListData * p0) {}

// =============================================================================
// UVertexStream class implementations.
// Ghidra: constructors at 0x2210 (base), 0x26280+ (derived).
// GetData/GetDataSize at 0x18b20/0x18b30+.
// =============================================================================
UVertexStreamBase::UVertexStreamBase(INT InElementSize, DWORD InFlags, DWORD InType)
: ElementSize(InElementSize), StreamFlags(InFlags), StreamType(InType) {}
void UVertexStreamBase::Serialize(FArchive& Ar)
{
	// Retail: 80b. After parent serialize, if Ar.Ver() >= 75 (0x4B),
	// serialize ElementSize, StreamFlags, StreamType (3x 4 bytes via Ar.Serialize).
	Super::Serialize(Ar);
	if (Ar.Ver() >= 75)
	{
		Ar << ElementSize;
		Ar << StreamFlags;
		Ar << StreamType;
	}
}
void UVertexStreamBase::SetPolyFlags(DWORD Flags) {
	DWORD OldFlags = StreamFlags;
	StreamFlags = Flags;
	if( OldFlags != Flags )
		Revision++;
}

// UVertexBuffer: ElementSize=0x2C (44 = sizeof FBspVertex), StreamType=4.
UVertexBuffer::UVertexBuffer()
: UVertexStreamBase(0x2C, 0, 4) {}
UVertexBuffer::UVertexBuffer(DWORD InFlags)
: UVertexStreamBase(0x2C, InFlags, 0) {}
void UVertexBuffer::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
void* UVertexBuffer::GetData() { return Data.GetData(); }
INT UVertexBuffer::GetDataSize() { return Data.Num() * 0x2C; }

// UVertexStreamCOLOR: ElementSize=4 (sizeof FColor), StreamType=2.
UVertexStreamCOLOR::UVertexStreamCOLOR()
: UVertexStreamBase(4, 0, 2) {}
UVertexStreamCOLOR::UVertexStreamCOLOR(DWORD InFlags)
: UVertexStreamBase(4, InFlags, 2) {}
void UVertexStreamCOLOR::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
void* UVertexStreamCOLOR::GetData() { return Data.GetData(); }
INT UVertexStreamCOLOR::GetDataSize() { return Data.Num() * 4; }

// UVertexStreamPosNormTex: ElementSize=0x28 (40), StreamType=5.
UVertexStreamPosNormTex::UVertexStreamPosNormTex()
: UVertexStreamBase(0x28, 0, 5) {}
UVertexStreamPosNormTex::UVertexStreamPosNormTex(DWORD InFlags)
: UVertexStreamBase(0x28, InFlags, 5) {}
void UVertexStreamPosNormTex::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
void* UVertexStreamPosNormTex::GetData() { return Data.GetData(); }
INT UVertexStreamPosNormTex::GetDataSize() { return Data.Num() * 0x28; }

// UVertexStreamUV: ElementSize=8 (2 floats), StreamType=3.
UVertexStreamUV::UVertexStreamUV()
: UVertexStreamBase(8, 0, 3) {}
UVertexStreamUV::UVertexStreamUV(DWORD InFlags)
: UVertexStreamBase(8, InFlags, 3) {}
void UVertexStreamUV::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
void* UVertexStreamUV::GetData() { return Data.GetData(); }
INT UVertexStreamUV::GetDataSize() { return Data.Num() * 8; }

// UVertexStreamVECTOR: ElementSize=0xC (12 = sizeof FVector), StreamType=1.
UVertexStreamVECTOR::UVertexStreamVECTOR()
: UVertexStreamBase(0xC, 0, 1) {}
UVertexStreamVECTOR::UVertexStreamVECTOR(DWORD InFlags)
: UVertexStreamBase(0xC, InFlags, 1) {}
void UVertexStreamVECTOR::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
void* UVertexStreamVECTOR::GetData() { return Data.GetData(); }
INT UVertexStreamVECTOR::GetDataSize() { return Data.Num() * 0xC; }

// =============================================================================
// FColor constructor from FPlane (out-of-line to avoid circular header deps).
// =============================================================================
FColor::FColor(const FPlane& P)
:	R((BYTE)Clamp(appFloor(P.X*255.f),0,255))
,	G((BYTE)Clamp(appFloor(P.Y*255.f),0,255))
,	B((BYTE)Clamp(appFloor(P.Z*255.f),0,255))
,	A((BYTE)Clamp(appFloor(P.W*255.f),0,255))
{}

// =============================================================================
// Explicit template instantiation for TArray<BYTE> and TLazyArray<BYTE>.
// The retail Engine.dll exports these symbols; explicit instantiation forces the
// compiler to emit out-of-line copies of all inline template members.
// =============================================================================
template class TArray<BYTE>;
template class TLazyArray<BYTE>;

// ============================================================================
// FSortedPathList
// ============================================================================
FSortedPathList::FSortedPathList() { appMemzero(this, sizeof(*this)); }
FSortedPathList& FSortedPathList::operator=(const FSortedPathList& Other) { appMemcpy(this, &Other, 260); return *this; } // 65 dwords
void FSortedPathList::addPath(ANavigationPoint* Path, INT Cost)
{
	// Ghidra (172B): Sorted insertion into fixed 32-element array.
	// Layout: Paths[32] at 0x00, Costs[32] at 0x80, Count at 0x100.
	ANavigationPoint** Paths = (ANavigationPoint**)&Pad[0];
	INT* Costs = (INT*)&Pad[0x80];
	INT& Count = *(INT*)&Pad[0x100];

	INT InsertIdx = 0;

	// Quick check: if last element's cost < new cost, start at end
	if (Count > 0 && Costs[Count - 1] < Cost)
		InsertIdx = Count;

	// Linear search for insertion point
	while (InsertIdx < Count && Costs[InsertIdx] <= Cost)
		InsertIdx++;

	// Insert if within max capacity (32)
	if (InsertIdx < 32)
	{
		// Save displaced element
		ANavigationPoint* SavedPath = Paths[InsertIdx];
		INT SavedCost = Costs[InsertIdx];

		// Write new element
		Paths[InsertIdx] = Path;
		Costs[InsertIdx] = Cost;

		// Grow count
		if (Count < 32)
			Count++;

		// Shift remaining elements right
		for (INT i = InsertIdx + 1; i < Count; i++)
		{
			ANavigationPoint* TempPath = Paths[i];
			INT TempCost = Costs[i];
			Paths[i] = SavedPath;
			Costs[i] = SavedCost;
			SavedPath = TempPath;
			SavedCost = TempCost;
		}
	}
}

// ============================================================================
// FPointRegion
// ============================================================================
FPointRegion& FPointRegion::operator=(const FPointRegion& Other)
{
	Zone = Other.Zone;
	iLeaf = Other.iLeaf;
	ZoneNumber = Other.ZoneNumber;
	return *this;
}

// ============================================================================
// FDbgVectorInfo
// ============================================================================
FDbgVectorInfo::FDbgVectorInfo() { appMemzero(this, sizeof(*this)); }
FDbgVectorInfo::FDbgVectorInfo(const FDbgVectorInfo& Other) { appMemcpy(this, &Other, sizeof(*this)); }
FDbgVectorInfo::~FDbgVectorInfo() {}
FDbgVectorInfo& FDbgVectorInfo::operator=(const FDbgVectorInfo& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// ============================================================================
// FStats
// ============================================================================
FStats::FStats(const FStats& Other) { appMemcpy(this, &Other, sizeof(*this)); }
FStats::~FStats() {}
void FStats::UpdateString(FString&, INT) {}
void FStats::Render(UViewport*, UEngine*) {}
// ?RegisterStats@FStats@@QAEHW4EStatsType@@W4EStatsDataType@@VFString@@2W4EStatsUnit@@@Z  (0x154670)
// Registers a new stat slot and returns its index in the type-specific value array.
// FStats layout (from Ghidra / Clear() analysis):
//   INT values/retirements  at 0x1C/0x28  (stride 4)
//   FLOAT values/retirements at 0x4C/0x58  (stride 4)
//   FString values/retirements at 0x7C/0x88 (stride 12)
//   Name/DisplayName arrays per data type:
//     INT:    0x34/0x40   FLOAT: 0x64/0x70   STRING: 0x94/0xA0  (stride 12)
//   Descriptor TArray[3] at 0xAC (indexed by EStatsType, stride 12):
//     each descriptor = {INT valueIdx, INT dataType, INT unit}
INT FStats::RegisterStats(EStatsType StatType, EStatsDataType DataType,
	FString StatName, FString DisplayName, EStatsUnit Unit)
{
	INT SlotIdx = -1;

	if (DataType == (EStatsDataType)0)       // INT
	{
		SlotIdx = ((FArray*)((BYTE*)this + 0x1C))->AddZeroed(4);
		((FArray*)((BYTE*)this + 0x28))->AddZeroed(4);

		INT ni = ((FArray*)((BYTE*)this + 0x34))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0x34) + ni * sizeof(FString)) = StatName;

		INT di = ((FArray*)((BYTE*)this + 0x40))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0x40) + di * sizeof(FString)) = DisplayName + StatName;
	}
	else if (DataType == (EStatsDataType)1)  // FLOAT
	{
		SlotIdx = ((FArray*)((BYTE*)this + 0x4C))->AddZeroed(4);
		((FArray*)((BYTE*)this + 0x58))->AddZeroed(4);

		INT ni = ((FArray*)((BYTE*)this + 0x64))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0x64) + ni * sizeof(FString)) = StatName;

		INT di = ((FArray*)((BYTE*)this + 0x70))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0x70) + di * sizeof(FString)) = DisplayName + StatName;
	}
	else if (DataType == (EStatsDataType)2)  // STRING
	{
		SlotIdx = ((FArray*)((BYTE*)this + 0x7C))->AddZeroed(sizeof(FString));
		((FArray*)((BYTE*)this + 0x88))->AddZeroed(sizeof(FString));

		INT ni = ((FArray*)((BYTE*)this + 0x94))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0x94) + ni * sizeof(FString)) = StatName;

		INT di = ((FArray*)((BYTE*)this + 0xA0))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0xA0) + di * sizeof(FString)) = DisplayName + StatName;
	}
	else
	{
		return -1;
	}

	// Append descriptor {valueIdx, dataType, unit} to the per-StatsType table.
	// Each TArray in the descriptor table is 12 bytes; descriptor element = 12 bytes.
	INT ri = ((FArray*)((BYTE*)this + (INT)StatType * 12 + 0xAC))->Add(1, 12);
	INT* pRec = (INT*)(*(BYTE**)((BYTE*)this + (INT)StatType * 12 + 0xAC) + ri * 12);
	pRec[0] = SlotIdx;
	pRec[1] = (INT)DataType;
	pRec[2] = (INT)Unit;

	return SlotIdx;
}
void FStats::CalcMovingAverage(INT, DWORD) {}
void FStats::Clear()
{
	// Ghidra (363B): Save current stats to previous, then zero current.
	// FStats layout: IntStats(0x1C), PrevIntStats(0x28), FloatStats(0x4C),
	// PrevFloatStats(0x58), StringStats(0x7C), PrevStringStats(0x88).
	// TArray = {Data*, Num, Max} = 12 bytes. FString element size = 0xC.

	BYTE* Base = (BYTE*)this;

	// Access TArrays via raw offsets (Data ptr at +0, Num at +4)
	INT*   IntData     = *(INT**)(Base + 0x1C);
	INT    IntNum      = *(INT*)(Base + 0x20);
	INT*   PrevIntData = *(INT**)(Base + 0x28);

	INT*   FloatData     = *(INT**)(Base + 0x4C);
	INT    FloatNum      = *(INT*)(Base + 0x50);
	INT*   PrevFloatData = *(INT**)(Base + 0x58);

	BYTE*  StrData      = *(BYTE**)(Base + 0x7C);
	INT    StrNum       = *(INT*)(Base + 0x80);
	BYTE*  PrevStrData  = *(BYTE**)(Base + 0x88);

	// Step 1: Copy IntStats → PrevIntStats
	if (IntNum > 0)
		appMemcpy(PrevIntData, IntData, IntNum * 4);

	// Step 2: Copy FloatStats → PrevFloatStats
	if (FloatNum > 0)
		appMemcpy(PrevFloatData, FloatData, FloatNum * 4);

	// Step 3: Copy StringStats → PrevStringStats (FString assignment)
	for (INT i = 0; i < StrNum; i++)
	{
		FString* Dst = (FString*)(PrevStrData + i * 0xC);
		FString* Src = (FString*)(StrData + i * 0xC);
		*Dst = *Src;
	}

	// Step 4: Zero IntStats
	if (IntNum > 0)
		appMemzero(IntData, IntNum * 4);

	// Step 5: Zero FloatStats
	if (FloatNum > 0)
		appMemzero(FloatData, FloatNum * 4);

	// Step 6: Clear StringStats to empty
	for (INT i = 0; i < StrNum; i++)
	{
		FString* Str = (FString*)(StrData + i * 0xC);
		*Str = TEXT("");
	}
}

// ============================================================================
// FEngineStats
// ============================================================================
// ??4FEngineStats@@QAEAAV0@ABV0@@Z
// Ghidra: rep movsd loop copying 99 dwords (396 bytes)
FEngineStats& FEngineStats::operator=(const FEngineStats& Other)
{
	appMemcpy(this, &Other, 99 * 4);
	return *this;
}

void FEngineStats::Init() {}

// ============================================================================
// FSoundData
// ============================================================================
FSoundData::FSoundData(USound*) { appMemzero(this, sizeof(*this)); }
FSoundData::~FSoundData() {}
void FSoundData::Load() {}
FLOAT FSoundData::GetPeriod() { return 0.0f; }

// ============================================================================
// FRenderInterface
// ============================================================================
FRenderInterface::FRenderInterface() { appMemzero(RIPad, sizeof(RIPad)); }
FRenderInterface::FRenderInterface(const FRenderInterface& Other) { appMemcpy(this, &Other, sizeof(*this)); }
FRenderInterface& FRenderInterface::operator=(const FRenderInterface& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// ============================================================================
// FSceneNode subclasses
// ============================================================================

// FActorSceneNode
void FActorSceneNode::Render(FRenderInterface*) {}
FActorSceneNode* FActorSceneNode::GetActorSceneNode() { return this; }

// FCameraSceneNode
void FCameraSceneNode::Render(FRenderInterface*) {}
FCameraSceneNode* FCameraSceneNode::GetCameraSceneNode() { return this; }
void FCameraSceneNode::UpdateMatrices() {}

// FMirrorSceneNode
FMirrorSceneNode::FMirrorSceneNode(FLevelSceneNode* Parent, FPlane Mirror, INT a, INT b)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
FMirrorSceneNode* FMirrorSceneNode::GetMirrorSceneNode() { return this; }

// FSkySceneNode
FSkySceneNode::FSkySceneNode(FLevelSceneNode* Parent, INT Zone)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
FSkySceneNode* FSkySceneNode::GetSkySceneNode() { return this; }

// FWarpZoneSceneNode
FWarpZoneSceneNode::FWarpZoneSceneNode(FLevelSceneNode* Parent, AWarpZoneInfo*)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
FWarpZoneSceneNode* FWarpZoneSceneNode::GetWarpZoneSceneNode() { return this; }

// FLevelSceneNode
FConvexVolume FLevelSceneNode::GetViewFrustum() { return FConvexVolume(); }

// FLightMapSceneNode
void FLightMapSceneNode::Render(FRenderInterface*) {}
// Ghidra: if GRebuildTools has lightmap mode flag (Pad[0x10] & 0x10) and actor's
// collision flags (offset 0xAC) indicate a shadow-casting group, skip it (return 0).
// Otherwise return the actor's bLightChanged bit (offset 0xA4 >> 30).
INT FLightMapSceneNode::FilterActor(AActor* Actor)
{
	if ((GRebuildTools.Pad[0x10] & 0x10) && (*(DWORD*)((BYTE*)Actor + 0xAC) & 0x1800))
		return 0;
	return (*(DWORD*)((BYTE*)Actor + 0xA4) >> 30) & 1;
}

// FDirectionalLightMapSceneNode
FConvexVolume FDirectionalLightMapSceneNode::GetViewFrustum() { return FConvexVolume(); }

// FPointLightMapSceneNode
FConvexVolume FPointLightMapSceneNode::GetViewFrustum() { return FConvexVolume(); }

// ============================================================================
// FHitObserver / HCoords
// ============================================================================
HCoords::HCoords(FCameraSceneNode*) {}

// ============================================================================
// FInBunch
// ============================================================================
FInBunch::FInBunch(const FInBunch& Other) : FBitReader() { appMemcpy(this, &Other, sizeof(*this)); }
FInBunch::FInBunch(UNetConnection*) : FBitReader() { appMemzero(Pad, sizeof(Pad)); }
FInBunch& FInBunch::operator=(const FInBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }
FArchive& FInBunch::operator<<(UObject*& Obj) { return *this; }
FArchive& FInBunch::operator<<(FName& N) { return *this; }

// ============================================================================
// FOutBunch
// ============================================================================
FOutBunch::FOutBunch() { appMemzero(this, sizeof(*this)); }
FOutBunch::FOutBunch(const FOutBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); }
FOutBunch::FOutBunch(UChannel*, INT) { appMemzero(this, sizeof(*this)); }
FOutBunch::~FOutBunch() {}
FArchive& FOutBunch::operator<<(UObject*& Obj) { return *(FArchive*)this; }
FArchive& FOutBunch::operator<<(FName& N) { return *(FArchive*)this; }

// ============================================================================
// UInput / UInputPlanning
// ============================================================================
INT UInput::PreProcess(EInputKey Key, EInputAction Action, FLOAT Delta)
{
	// KeyDownMap at offset 0xEB4 from this (Ghidra-verified).
	BYTE* KeyDownMap = (BYTE*)this + 0xEB4;
	if (Action == IST_Press)
	{
		if (KeyDownMap[Key] == 0)
		{
			KeyDownMap[Key] = 1;
			return 1;
		}
	}
	else if (Action == IST_Release)
	{
		if (KeyDownMap[Key] != 0)
		{
			KeyDownMap[Key] = 0;
			return 1;
		}
	}
	else
	{
		return 1;
	}
	return 0;
}
INT UInput::Process(FOutputDevice& Ar, EInputKey Key, EInputAction Action, FLOAT Delta)
{
	if ((INT)Key < 0 || (INT)Key >= 0xFF)
		appFailAssert("iKey>=0&&iKey<IK_MAX", ".\\UnIn.cpp", 0x1E8);
	// Bindings array at offset 0x2B0 (FString[IK_MAX], 0xC each)
	FString& Binding = *(FString*)((BYTE*)this + (INT)Key * 0xC + 0x2B0);
	if (Binding.Len())
	{
		*(EInputAction*)((BYTE*)this + 0xEAC) = Action;
		*(FLOAT*)((BYTE*)this + 0xEB0) = Delta;
		Exec(*Binding, Ar);
		*(INT*)((BYTE*)this + 0xEAC) = 0;
		*(INT*)((BYTE*)this + 0xEB0) = 0;
		return 1;
	}
	return 0;
}
void UInput::DirectAxis(EInputKey Key, FLOAT Value, FLOAT Delta) {}

// ?GetKeyName@UInput@@QBEPBGHHPAVEInputKey@@@Z   (returns display name for a virtual-key code)
// Key names match the DefUser.ini binding keys (retail verified).
// Letters A-Z and digits 0-9 are their single character.
// Numpad, Function keys and special keys use the standard Unreal names.
// Unrecognised codes return "Unknown%02X" format (e.g. "Unknown3A").
const TCHAR* UInput::GetKeyName(EInputKey Key) const
{
	static TCHAR GenBuf[16]; // used for dynamically generated names
	DWORD k = (DWORD)Key;

	// A–Z  (0x41–0x5A)
	if (k >= 0x41 && k <= 0x5A) { GenBuf[0]=(TCHAR)k; GenBuf[1]=0; return GenBuf; }
	// 0–9  (0x30–0x39)
	if (k >= 0x30 && k <= 0x39) { GenBuf[0]=(TCHAR)k; GenBuf[1]=0; return GenBuf; }
	// NumPad 0–9  (0x60–0x69)
	if (k >= 0x60 && k <= 0x69)
		{ appSprintf(GenBuf, TEXT("NumPad%c"), TEXT('0')+(k-0x60)); return GenBuf; }
	// F1–F24  (0x70–0x87)
	if (k >= 0x70 && k <= 0x87)
		{ appSprintf(GenBuf, TEXT("F%d"), (INT)(k - 0x6F)); return GenBuf; }
	// Joy1–16 (0xC8–0xD7)
	if (k >= 0xC8 && k <= 0xD7)
		{ appSprintf(GenBuf, TEXT("Joy%d"), (INT)(k - 0xC7)); return GenBuf; }

	static const struct { DWORD Code; const TCHAR* Name; } Table[] =
	{
		{ 0x01, TEXT("LeftMouse")      }, { 0x02, TEXT("RightMouse")      },
		{ 0x03, TEXT("Cancel")         }, { 0x04, TEXT("MiddleMouse")      },
		{ 0x08, TEXT("Backspace")      }, { 0x09, TEXT("Tab")              },
		{ 0x0D, TEXT("Enter")          }, { 0x10, TEXT("Shift")            },
		{ 0x11, TEXT("Ctrl")           }, { 0x12, TEXT("Alt")              },
		{ 0x13, TEXT("Pause")          }, { 0x14, TEXT("CapsLock")         },
		{ 0x1B, TEXT("Escape")         }, { 0x20, TEXT("Space")            },
		{ 0x21, TEXT("PageUp")         }, { 0x22, TEXT("PageDown")         },
		{ 0x23, TEXT("End")            }, { 0x24, TEXT("Home")             },
		{ 0x25, TEXT("Left")           }, { 0x26, TEXT("Up")               },
		{ 0x27, TEXT("Right")          }, { 0x28, TEXT("Down")             },
		{ 0x29, TEXT("Select")         }, { 0x2A, TEXT("Print")            },
		{ 0x2B, TEXT("Execute")        }, { 0x2C, TEXT("PrintScrn")        },
		{ 0x2D, TEXT("Insert")         }, { 0x2E, TEXT("Delete")           },
		{ 0x2F, TEXT("Help")           },
		{ 0x6A, TEXT("GreyStar")       }, { 0x6B, TEXT("GreyPlus")         },
		{ 0x6C, TEXT("Separator")      }, { 0x6D, TEXT("GreyMinus")        },
		{ 0x6E, TEXT("NumPadPeriod")   }, { 0x6F, TEXT("GreySlash")        },
		{ 0x90, TEXT("NumLock")        }, { 0x91, TEXT("ScrollLock")       },
		{ 0xA0, TEXT("LShift")         }, { 0xA1, TEXT("RShift")           },
		{ 0xA2, TEXT("LControl")       }, { 0xA3, TEXT("RControl")         },
		{ 0xBA, TEXT("Semicolon")      }, { 0xBB, TEXT("Equals")           },
		{ 0xBC, TEXT("Comma")          }, { 0xBD, TEXT("Minus")            },
		{ 0xBE, TEXT("Period")         }, { 0xBF, TEXT("Slash")            },
		{ 0xC0, TEXT("Tilde")          }, { 0xDB, TEXT("LeftBracket")      },
		{ 0xDC, TEXT("Backslash")      }, { 0xDD, TEXT("RightBracket")     },
		{ 0xDE, TEXT("Quote")          },
		{ 0xE0, TEXT("JoyX")           }, { 0xE1, TEXT("JoyY")             },
		{ 0xE2, TEXT("JoyZ")           }, { 0xE3, TEXT("JoyR")             },
		{ 0xE4, TEXT("MouseX")         }, { 0xE5, TEXT("MouseY")           },
		{ 0xE6, TEXT("MouseZ")         }, { 0xE7, TEXT("MouseW")           },
		{ 0xE8, TEXT("JoyU")           }, { 0xE9, TEXT("JoyV")             },
		{ 0xEC, TEXT("MouseWheelUp")   }, { 0xED, TEXT("MouseWheelDown")   },
	};
	for (INT i = 0; i < ARRAY_COUNT(Table); i++)
		if (Table[i].Code == k) return Table[i].Name;

	appSprintf(GenBuf, TEXT("Unknown%02X"), k & 0xFF);
	return GenBuf;
}

// ?FindKeyName@UInput@@QBEHPBGAAHPAVEInputKey@@@Z (reverse lookup: name → EInputKey)
INT UInput::FindKeyName(const TCHAR* KeyName, EInputKey& Key) const
{
	for (INT i = 1; i < 256; i++)
	{
		if (!appStricmp(GetKeyName((EInputKey)i), KeyName))
		{
			Key = (EInputKey)i;
			return 1;
		}
	}
	return 0;
}
void UInput::SetInputAction(EInputAction Action, FLOAT Delta)
{
	*(EInputAction*)((BYTE*)this + 0xEAC) = Action;
	*(FLOAT*)((BYTE*)this + 0xEB0) = Delta;
}
EInputAction UInput::GetInputAction()
{
	return *(EInputAction*)((BYTE*)this + 0xEAC);
}
FLOAT UInput::GetInputDelta()
{
	return *(FLOAT*)((BYTE*)this + 0xEB0);
}
const TCHAR* UInput::StaticConfigName() { return TEXT("User"); }  // Retail: 6b. Returns hardcoded L"User" string pointer from .rdata.
void UInput::StaticInitInput() {}

// ============================================================================
// ALevelInfo
// ============================================================================
void ALevelInfo::SetVolumes(const TArray<class AVolume*>&) {}
void ALevelInfo::SetVolumes() {}
void ALevelInfo::SetZone(INT ZoneNumber, INT ZoneBitField)
{
	// Retail: 51b. If bit 7 of this+0xA0 is set, skip. Otherwise:
	// store DWORD from this+0x144 to this+0x228, store 0xFFFFFFFF to this+0x22C, 0 to this+0x230.
	// ZoneNumber and ZoneBitField args are not used in retail bytecode.
	if (*(BYTE*)((BYTE*)this + 0xA0) & 0x80) return;
	*(DWORD*)((BYTE*)this + 0x228) = *(DWORD*)((BYTE*)this + 0x144);
	*(DWORD*)((BYTE*)this + 0x22C) = 0xFFFFFFFF;
	*(DWORD*)((BYTE*)this + 0x230) = 0;
}
void ALevelInfo::PostNetReceive() {}
void ALevelInfo::PreNetReceive() {}
void ALevelInfo::CheckForErrors() {}
INT* ALevelInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}
void ALevelInfo::CallLogThisActor(AActor*) {}
// ?GetDefaultPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@XZ  Ghidra at ~279 bytes.
// Lazily spawns ADefaultPhysicsVolume and caches it at this+0x164.
// The original also sets vol+0x40C (Priority field, raw 0xFFF0BDC0) and vol+0xA0 |= 4.
// Priority raw-write left as TODO until AVolume layout is confirmed byte-accurate.
// CRITICAL: this must never return NULL as callers dereference the result unchecked.
APhysicsVolume* ALevelInfo::GetDefaultPhysicsVolume()
{
	APhysicsVolume*& CachedVol = *(APhysicsVolume**)((BYTE*)this + 0x164);
	if (!CachedVol)
	{
		CachedVol = (APhysicsVolume*)XLevel->SpawnActor(ADefaultPhysicsVolume::StaticClass());
		if (CachedVol)
		{
			// Priority: raw DWORD at vol+0x40C = 0xFFF0BDC0 (Ghidra; AVolume layout not yet verified)
			*(DWORD*)((BYTE*)CachedVol + 0x40C) = 0xFFF0BDC0u;
			// vol+0xA0 |= 4 (a bitmask flag in AActor's bitfield block)
			*(DWORD*)((BYTE*)CachedVol + 0xA0) |= 4;
		}
	}
	return CachedVol;
}
FString ALevelInfo::GetDisplayAs(FString s) { return s; }

// ?GetPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@VFVector@@PAVAActor@@H@Z  (0x0BBА00, 346 bytes)
// Walks the PhysicsVolume linked list to find the highest-priority volume
// that contains point V. With Actor+bUseTouchingVolumes=true it uses only
// the volumes in Actor->Touching (fast path).
// The list is lazily rebuilt when the dirty flag at this+0x94C bit 0 is clear.
// Priority field in APhysicsVolume is at raw offset 0x40C; next-pointer at 0x438.
APhysicsVolume* ALevelInfo::GetPhysicsVolume(FVector V, AActor* Actor, INT bUseTouchingVolumes)
{
	APhysicsVolume* Best = GetDefaultPhysicsVolume();
	if (!bUseTouchingVolumes || !Actor)
	{
		// Lazy rebuild of the linear PhysicsVolume list from the level's actor array.
		if (!(*(DWORD*)((BYTE*)this + 0x94C) & 1))
		{
			PhysicsVolumeList = NULL;
			ULevel* L = XLevel;
			INT N = L->Actors.Num();
			for (INT i = 0; i < N; i++)
			{
				AActor* A = L->Actors(i);
				if (A && A->IsA(APhysicsVolume::StaticClass()))
				{
					// Prepend A to the singly-linked list (NextVolume pointer at +0x438).
					*(APhysicsVolume**)((BYTE*)A + 0x438) = PhysicsVolumeList;
					PhysicsVolumeList = (APhysicsVolume*)A;
				}
			}
			*(DWORD*)((BYTE*)this + 0x94C) |= 1;
		}
		for (APhysicsVolume* V2 = PhysicsVolumeList; V2;
			 V2 = *(APhysicsVolume**)((BYTE*)V2 + 0x438))
		{
			// 0x40C = Priority (INT) in AVolume; pick highest-priority enclosing volume.
			if (*(INT*)((BYTE*)Best + 0x40C) < *(INT*)((BYTE*)V2 + 0x40C) &&
				V2->Encompasses(V))
				Best = V2;
		}
	}
	else
	{
		// Fast path: restrict search to volumes currently Touching the Actor.
		for (INT i = 0; i < Actor->Touching.Num(); i++)
		{
			AActor* A = Actor->Touching(i);
			if (A && A->IsA(APhysicsVolume::StaticClass()) &&
				*(INT*)((BYTE*)Best + 0x40C) < *(INT*)((BYTE*)A + 0x40C) &&
				((AVolume*)A)->Encompasses(V))
				Best = (APhysicsVolume*)A;
		}
	}
	return Best;
}
// Retail (44b + shared epilogue): zone audibility bitmask lookup.
// Bitmask is an array of 8-byte entries at this+0x650, indexed by Zone1.
// Each entry is two DWORDs. Bit (Zone2 & 31) of the lo DWORD is checked.
// CDQ pattern: for Zone2==31 the sign-extended mask also checks the hi DWORD.
// Returns 1 if audible, 0 if not. (Fallthrough path normalises to 1.)
INT ALevelInfo::IsSoundAudibleFromZone(INT Zone1, INT Zone2)
{
    if (Zone1 == Zone2)
        return 1;
    DWORD* Zones = (DWORD*)((BYTE*)this + 0x650);
    DWORD bit = 1u << Zone2;
    DWORD lo   = bit & Zones[Zone1 * 2];
    INT   hiMask = (INT)bit >> 31;  // CDQ: -1 if Zone2==31, else 0
    DWORD hi   = (DWORD)hiMask & Zones[Zone1 * 2 + 1];
    return (lo | hi) ? 1 : 0;
}

// ============================================================================
// AGameInfo
// ============================================================================
void AGameInfo::AbortScoreSubmission() {}
void AGameInfo::MasterServerManager() {}
void AGameInfo::InitGameInfoGameService() {}
void AGameInfo::ProcessR6Availabilty(ULevel*, FString) {}

// ============================================================================
// AGameReplicationInfo / APlayerReplicationInfo
// ============================================================================
void AGameReplicationInfo::PostNetReceive() {}
INT* AGameReplicationInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}
void APlayerReplicationInfo::PostNetReceive() {}
INT* APlayerReplicationInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}

// ============================================================================
// UNetConnection
// ============================================================================

// ?CreateChannel@UNetConnection@@QAEPAVUChannel@@W4EChannelType@@HH@Z (0x1855E0, 228 bytes)
// Allocates a new UChannel of the appropriate class, initialises it and
// registers it in the Channels array and OpenChannels list.
// Special ChIndex values:
//   -1         : auto-allocate any empty slot in [1,0x3FE] (or [0,0x3FE] for CHTYPE_Control)
//   0x7FFFFFFF : auto-allocate from patch-channel band [0x400, 0x410)
//   0x7FFFFFFE : auto-allocate from patch-channel band [0x410, 0x50F)
// Channels array at  this + ChIndex*4 + 0xEB0.
// OpenChannels TArray at this + 0x4B7C.
UChannel* UNetConnection::CreateChannel(EChannelType ChType, INT bOpenedLocally, INT ChIndex)
{
	if (!UChannel::IsKnownChannelType((INT)ChType))
		appFailAssert("UChannel::IsKnownChannelType(ChType)", ".\\UnConn.cpp", 0x31E);

	AssertValid();

	INT iIdx = ChIndex;
	if (ChIndex >= 0x400)
	{
		if (ChIndex == (INT)0x7FFFFFFF)
		{
			for (iIdx = 0x400; iIdx < 0x410; iIdx++)
				if (*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) == NULL) break;
			if (iIdx == 0x410) return NULL;
		}
		else if (ChIndex == (INT)0x7FFFFFFE)
		{
			for (iIdx = 0x410; iIdx < 0x50F; iIdx++)
				if (*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) == NULL) break;
			if (iIdx == 0x50F) return NULL;
		}
		if (iIdx >= 0x50F)
			appFailAssert("ChIndex<MAX_CHANNELS+NUM_ARMPATCH_CHANNELS", ".\\UnConn.cpp", 0x36A);
	}

	if (iIdx == -1)
	{
		iIdx = (ChType == CHTYPE_Control) ? 0 : 1;
		while (iIdx < 0x3FF && *(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) != NULL)
			iIdx++;
		if (iIdx == 0x3FF) return NULL;
	}

	if (ChIndex < 0x400)
	{
		if (iIdx >= 0x3FF)
			appFailAssert("ChIndex<MAX_CHANNELS", ".\\UnConn.cpp", 0x36E);
	}
	else
	{
		if (iIdx >= 0x50F)
			appFailAssert("ChIndex<MAX_CHANNELS+NUM_ARMPATCH_CHANNELS", ".\\UnConn.cpp", 0x36A);
	}

	if (*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) != NULL)
		appFailAssert("Channels[ChIndex]==NULL", ".\\UnConn.cpp", 0x373);

	// Construct the channel object for this channel type.
	UClass* Class = UChannel::ChannelClasses[ChType];
	check(Class->IsChildOf(UChannel::StaticClass()));
	UChannel* Ch = (UChannel*)UObject::StaticConstructObject(
		Class, UObject::GetTransientPackage(), NAME_None, 0, NULL, GError, NULL);
	Ch->Init(this, iIdx, bOpenedLocally);

	// Register in the fixed-size Channels array.
	*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) = Ch;

	// Append to OpenChannels dynamic list (TArray<UChannel*> at this+0x4B7C).
	INT arrIdx = ((FArray*)((BYTE*)this + 0x4B7C))->Add(1, sizeof(UChannel*));
	*(UChannel**)(*(BYTE**)((BYTE*)this + 0x4B7C) + arrIdx * sizeof(UChannel*)) = Ch;

	return Ch;
}
void UNetConnection::PostSend()
{
	// Out(FBitWriter) at offset 0x250, MaxPacket(INT) at offset 0xD0
	FBitWriter& Out = *(FBitWriter*)((BYTE*)this + 0x250);
	INT MaxPacket = *(INT*)((BYTE*)this + 0xD0);
	if (Out.GetNumBits() > MaxPacket * 8)
		appFailAssert("Out.GetNumBits()<=MaxPacket*8", ".\\UnConn.cpp", 0x2B6);
	if (Out.GetNumBits() == MaxPacket * 8)
		FlushNet();
}

// ============================================================================
// UChannel
// ============================================================================
UClass** UChannel::ChannelClasses = NULL;

// ============================================================================
// UDemoRecConnection
// ============================================================================
UDemoRecConnection::UDemoRecConnection(UNetDriver* Driver, const FURL& URL)
{
}
void UDemoRecConnection::StaticConstructor() {}
FString UDemoRecConnection::LowLevelDescribe() { return FString(TEXT("Demo recording driver connection")); }
FString UDemoRecConnection::LowLevelGetRemoteAddress() { return FString(TEXT("")); }
void UDemoRecConnection::LowLevelSend(void* Data, INT Count) {
	// Ghidra at 0x187b80. Writes demo packet: FrameNum, DemoFrameTime, Count, Data.
	if (Driver->ServerConnection == NULL) {
		FArchive* FileAr = *(FArchive**)((BYTE*)Driver + 0xB4);
		FileAr->ByteOrderSerialize((BYTE*)Driver + 0xCC, 4);    // FrameNum (INT)
		FileAr->ByteOrderSerialize((BYTE*)Driver + 0x48, 8);    // DemoFrameTime (DOUBLE)
		FileAr->ByteOrderSerialize(&Count, 4);                  // packet size
		FileAr->Serialize(Data, Count);                          // packet data
	}
}

// Retail: 16b. Flushes only when playing back a demo (client, ServerConnection != NULL).
// JNZ path: if ServerConnection != NULL, cross-function-jump to UNetConnection::FlushNet.
void UDemoRecConnection::FlushNet() {
	if (Driver->ServerConnection != NULL)
		UNetConnection::FlushNet();
}
INT UDemoRecConnection::IsNetReady(INT) { return 1; }
void UDemoRecConnection::HandleClientPlayer(APlayerController*) {}
UDemoRecDriver* UDemoRecConnection::GetDriver() { return (UDemoRecDriver*)Driver; }

// ============================================================================
// UPackageMapLevel
// ============================================================================
UPackageMapLevel::UPackageMapLevel(UNetConnection*) {}
INT UPackageMapLevel::SerializeObject(FArchive&, UClass*, UObject*&) { return 1; } // Ghidra 0x18bd30: returns 1 on all paths; full net-object lookup TODO
// Ghidra at 0x48BCD0: default return is 1 (can serialize), returns 0 only for specific Actor flag checks.
INT UPackageMapLevel::CanSerializeObject(UObject*) { return 1; }

// ============================================================================
// UNullRenderDevice
// ============================================================================
void UNullRenderDevice::SetEmulationMode(EHardwareEmulationMode) {}
INT UNullRenderDevice::SupportsTextureFormat(ETextureFormat) { return 1; }

// ============================================================================
// UEngine / UGameEngine
// ============================================================================
void UGameEngine::BuildServerMasterMap(UNetDriver*, ULevel*) {}

// ============================================================================
// UTerrainPrimitive
// ============================================================================
UTerrainPrimitive::UTerrainPrimitive(ATerrainInfo*) {}
void UTerrainPrimitive::Serialize(FArchive& Ar) { UPrimitive::Serialize(Ar); }
INT UTerrainPrimitive::LineCheck(FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD) { return 1; }
INT UTerrainPrimitive::PointCheck(FCheckResult&, AActor*, FVector, FVector, DWORD) { return 1; }
void UTerrainPrimitive::Illuminate(AActor*, INT) {}
FBox UTerrainPrimitive::GetRenderBoundingBox(const AActor*, INT) { return FBox(); }

// ============================================================================
// UTerrainSector
// ============================================================================
UTerrainSector::UTerrainSector(ATerrainInfo*, INT, INT, INT, INT) {}
void UTerrainSector::Serialize(FArchive& Ar) { UObject::Serialize(Ar); }
void UTerrainSector::PostLoad() {}
void UTerrainSector::StaticLight(INT) {}
void UTerrainSector::GenerateTriangles() {}
// Ghidra at 0x156550. Returns linear index in the global heightmap grid.
INT UTerrainSector::GetGlobalVertex(INT X, INT Y) {
	// TerrainInfo->HeightmapX is at offset 0x12E0 in ATerrainInfo
	INT HeightmapX = *(INT*)((BYTE*)TerrainInfo + 0x12E0);
	return (OffsetY + Y) * HeightmapX + OffsetX + X;
}

// Ghidra at 0x153a0. Returns linear index within this sector.
INT UTerrainSector::GetLocalVertex(INT X, INT Y) {
	return (SectorSizeX + 1) * Y + X;
}
INT UTerrainSector::PassShouldRenderTriangle(INT, INT, INT, INT, INT) { return 1; }
// ?IsSectorAll@UTerrainSector@@QAEHHE@Z  Ghidra at ~0x107bae30 (336 bytes).
// Gets the alpha texture for the layer, computes texel range for this sector,
// then checks that every texel matches 'value'. Returns 1 (true) on empty range.
INT UTerrainSector::IsSectorAll(INT layerIdx, BYTE value)
{
	// Alpha map pointer: TerrainInfo + 0x3AC + layerIdx * 0x78
	UTexture* alphaMap = *(UTexture**)((BYTE*)TerrainInfo + 0x3AC + layerIdx * 0x78);
	INT QuadsX = *(INT*)((BYTE*)TerrainInfo + 0x12E0);
	INT QuadsY = *(INT*)((BYTE*)TerrainInfo + 0x12E4);

	// Scale factors: texels per quad in each axis
	INT scaleX = alphaMap->USize / QuadsX;
	INT scaleY = alphaMap->VSize / QuadsY;

	// Inclusive texel range for this sector
	INT x0 = OffsetX * scaleX;
	INT x1 = (OffsetX + SectorSizeX) * scaleX - 1;
	INT y0 = OffsetY * scaleY;
	INT y1 = (OffsetY + SectorSizeY) * scaleY - 1;

	// Empty sector (SectorSizeX/Y == 0) → trivially all match
	if (x0 > x1 || y0 > y1)
		return 1;

	for (INT y = y0; y <= y1; y++)
		for (INT x = x0; x <= x1; x++)
			if (TerrainInfo->GetLayerAlpha(x, y, layerIdx, alphaMap) != value)
				return 0;

	return 1;
}
INT UTerrainSector::IsTriangleAll(INT, INT, INT, INT, INT, BYTE) { return 0; }
void UTerrainSector::AttachProjector(AProjector*, FProjectorRenderInfo*) {}

// ============================================================================
// FStaticMeshColorStream
// ============================================================================
INT FStaticMeshColorStream::GetComponents(FVertexComponent* C) {
	C[0].Type = 4; C[0].Function = 3;
	return 1;
}

// ============================================================================
// FCollisionHash
// ============================================================================
// ?GetHashLink@FCollisionHash@@QAEAAPAUFCollisionLink@1@HHHAAH@Z
// Retail ordinal 3034 (0x6d680).
// Returns a reference to the bucket-head pointer for hash cell (x, y, z) and
// writes the encoded position z*0x100000 + y*0x400 + x into OutPos.
FCollisionHash::FCollisionLink*& FCollisionHash::GetHashLink(INT x, INT y, INT z, INT& OutPos)
{
	OutPos = (z * 0x400 + y) * 0x400 + x;
	return Buckets[HashX[x] ^ HashY[y] ^ HashZ[z]];
}

// ============================================================================
// URenderResource — Ghidra at 0x110D00.
// Serializes UObject + Revision (4 bytes at 0x2C).
// ============================================================================
void URenderResource::Serialize(FArchive& Ar)
{
	UObject::Serialize(Ar);
	Ar << Revision;
}

// ============================================================================
// FPoly
// ============================================================================
// ?RemoveColinears@FPoly@@QAEHXZ
// Removes collinear (in-line) vertices. A vertex is collinear if it lies within
// THRESH_POINT_ON_SIDE of the line connecting its two neighbours.
// Returns final vertex count.
INT FPoly::RemoveColinears()
{
	BYTE Colinear[16];
	for (INT i = 0; i < NumVertices; i++)
	{
		INT Prev = (i + NumVertices - 1) % NumVertices;
		INT Next = (i + 1) % NumVertices;
		// Direction along the prev→next edge
		FVector Side  = (Vertex[Next] - Vertex[Prev]);
		// In-plane perpendicular to that edge
		FVector Cross = Side ^ Normal;
		FLOAT   Len   = Cross.Size();
		// Signed distance from Vertex[i] to the line (prev → next), measured in the polygon plane
		FLOAT   Dist  = (Len > 0.f) ? Abs((Vertex[i] - Vertex[Prev]) | (Cross / Len)) : 0.f;
		Colinear[i] = (Dist < THRESH_POINT_ON_SIDE) ? 1 : 0;
	}

	INT j = 0;
	for (INT i = 0; i < NumVertices; i++)
		if (!Colinear[i])
			Vertex[j++] = Vertex[i];
	NumVertices = j;
	return NumVertices;
}

// ============================================================================
// Karma free functions
// ============================================================================
struct _McdGeometry;
struct McdGeomMan;

_McdGeometry* KAggregateGeomInstance(FKAggregateGeom*, FVector, McdGeomMan*, const _WORD*) { return NULL; }
void KME2UCoords(FCoords* Out, const FLOAT (* const tm)[4]) {
	*Out = FCoords(
		FVector(tm[3][0]*50.f, tm[3][1]*50.f, tm[3][2]*50.f),
		FVector(tm[0][0], tm[0][1], tm[0][2]),
		FVector(tm[1][0], tm[1][1], tm[1][2]),
		FVector(tm[2][0], tm[2][1], tm[2][2])
	);
}
void KME2UMatrixCopy(FMatrix* Out, FLOAT (* const In)[4]) {
	appMemcpy(Out, In, sizeof(FLOAT)*16);
}
void KME2UTransform(FVector* OutPos, FRotator* OutRot, const FLOAT (* const tm)[4]) {
	OutPos->X = tm[3][0] * 50.0f;
	OutPos->Y = tm[3][1] * 50.0f;
	OutPos->Z = tm[3][2] * 50.0f;
	FCoords Coords;
	KME2UCoords(&Coords, tm);
	*OutRot = Coords.OrthoRotation();
}
void KModelToHulls(FKAggregateGeom*, UModel*, FVector) {}
void KU2MEMatrixCopy(FLOAT (* const Out)[4], FMatrix* In) {
	appMemcpy(Out, In, sizeof(FLOAT)*16);
}
void KU2METransform(FLOAT (* const tm)[4], FVector Pos, FRotator Rot) {
	FCoords Coords(FVector(0.f,0.f,0.f));
	Coords *= Rot;
	tm[0][0] = Coords.XAxis.X; tm[0][1] = Coords.XAxis.Y; tm[0][2] = Coords.XAxis.Z; tm[0][3] = 0.f;
	tm[1][0] = Coords.YAxis.X; tm[1][1] = Coords.YAxis.Y; tm[1][2] = Coords.YAxis.Z; tm[1][3] = 0.f;
	tm[2][0] = Coords.ZAxis.X; tm[2][1] = Coords.ZAxis.Y; tm[2][2] = Coords.ZAxis.Z; tm[2][3] = 0.f;
	tm[3][0] = Pos.X * 0.02f; tm[3][1] = Pos.Y * 0.02f; tm[3][2] = Pos.Z * 0.02f; tm[3][3] = 1.0f;
}

// ============================================================================
// TArray<BYTE> operators
// ============================================================================
// Ghidra: appends elements from Other to this, element-by-element via FArray::Add
TArray<BYTE>& TArray<BYTE>::operator+(const TArray<BYTE>& Other)
{
	if (this != &Other)
	{
		for (INT i = 0; i < Other.Num(); i++)
		{
			INT Index = Add(1);
			(*this)(Index) = Other(i);
		}
	}
	return *this;
}

// Ghidra: delegates to operator+ then operator= (self)
TArray<BYTE>& TArray<BYTE>::operator+=(const TArray<BYTE>& Other)
{
	if (this != &Other)
		*this + Other;
	return *this;
}

// ============================================================================
// TLazyArray<BYTE> — copy ctor and operator= are compiler-generated;
// cannot provide explicit definitions. Left as linker stubs.
// ============================================================================


// ============================================================================
// FPointRegion constructors (moved from inline to out-of-line)
// ============================================================================
FPointRegion::FPointRegion() : Zone(NULL), iLeaf(0), ZoneNumber(0) {}
// Retail (RVA=0x2980): 1-arg ctor sets iLeaf = -1 (INDEX_NONE = no BSP leaf), not 0.
FPointRegion::FPointRegion(AZoneInfo* InZone) : Zone(InZone), iLeaf(INDEX_NONE), ZoneNumber(0) {}
FPointRegion::FPointRegion(AZoneInfo* InZone, INT InLeaf, BYTE InZoneNumber) : Zone(InZone), iLeaf(InLeaf), ZoneNumber(InZoneNumber) {}

// ============================================================================
// AR6AbstractClimbableObj / UR6AbstractTerroristMgr (out-of-line ctors)
// ============================================================================
AR6AbstractClimbableObj::AR6AbstractClimbableObj() {}
UR6AbstractTerroristMgr::UR6AbstractTerroristMgr() {}

// ============================================================================
// FHitObserver::Click (moved from inline to out-of-line)
// ============================================================================
void FHitObserver::Click(const FHitCause& Cause, const HHitProxy& Hit) {}
// ============================================================================

// ============================================================================
// UMeshInstance
// ============================================================================
// Default ctor now inline in header

// ============================================================================
// FLevelSceneNode
// ============================================================================
FLevelSceneNode& FLevelSceneNode::operator=(const FLevelSceneNode& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// ============================================================================
// FSceneNode
// ============================================================================
FSceneNode& FSceneNode::operator=(const FSceneNode& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }



// ============================================================================
// TLazyArray<BYTE> — force emission of implicitly-declared special members
// (copy ctor, operator=, default constructor closure).
// Explicit template instantiation only emits explicitly-defined members;
// these three are compiler-generated and need actual usage to be emitted.
// ============================================================================
template class TLazyArray<BYTE>;

// new[] forces default constructor closure (??_F); copy ctor and operator= are
// triggered by direct use. The function itself is unreachable but the symbols
// it references have external linkage and remain in the object file.
void _ForceTLazyArrayByteEmit() {
    TLazyArray<BYTE>* p = new TLazyArray<BYTE>[1];
    TLazyArray<BYTE> copy(*p);
    *p = copy;
    delete[] p;
}

/*-----------------------------------------------------------------------------
  AReplicationInfo virtual method stubs.
  Only methods NOT defined in EngineClassImpl.cpp remain here.
-----------------------------------------------------------------------------*/
void AReplicationInfo::DisplayVideo(UCanvas*, void*, INT) {}
void AReplicationInfo::Draw3DLine(FVector, FVector, FColor, UTexture*, FLOAT, FLOAT, FLOAT, FLOAT) {}
void AReplicationInfo::GetAvailableResolutions(TArray<FResolutionInfo>&) {}
DWORD AReplicationInfo::GetAvailableVideoMemory() { return 0; }
void AReplicationInfo::HandleFullScreenEffects(INT, INT) {}
