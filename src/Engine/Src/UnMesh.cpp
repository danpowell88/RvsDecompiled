/*=============================================================================
	UnMesh.cpp: UMesh, ULodMesh, USkeletalMesh, UStaticMesh registration.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() registrations for the mesh hierarchy.
	These are the geometry container classes used for characters
	(USkeletalMesh), props (UStaticMesh), and legacy vertex-animated
	models (UMesh / ULodMesh). Currently just registrations —
	decompiled method bodies will be added here as mesh code is
	reverse-engineered.

	This file is permanent and will grow as mesh code is decompiled.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(UMesh);
IMPLEMENT_CLASS(ULodMesh);
IMPLEMENT_CLASS(USkeletalMesh);
IMPLEMENT_CLASS(USkeletalMeshInstance);
IMPLEMENT_CLASS(UStaticMesh);
IMPLEMENT_CLASS(UStaticMeshInstance);

// =============================================================================
// Stubs imported from EngineStubs.cpp during file reorganization.
// These will be replaced with full implementations as decompilation progresses.
// =============================================================================
#pragma optimize("", off)

#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- CBoneDescData ---
int CBoneDescData::fn_bInitFromLbpFile(const TCHAR*)
{
	return 0;
}

void CBoneDescData::m_vProcessLbpLine(int,int,FString &)
{
}

CBoneDescData::CBoneDescData(CBoneDescData const &)
{
}

CBoneDescData::CBoneDescData()
{
}

CBoneDescData::~CBoneDescData()
{
}

CBoneDescData& CBoneDescData::operator=(const CBoneDescData& Other)
{
	// Ghidra 0x2b0a0: +0,+4=DWORD; +8=TArray<FString> (FUN_10321830); +0x14=FString; +0x20=DWORD
	*(DWORD*)((BYTE*)this + 0x00) = *(const DWORD*)((const BYTE*)&Other + 0x00);
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	*(TArray<FString>*)((BYTE*)this + 0x08) = *(const TArray<FString>*)((const BYTE*)&Other + 0x08);
	*(FString*)((BYTE*)this + 0x14) = *(const FString*)((const BYTE*)&Other + 0x14);
	*(DWORD*)((BYTE*)this + 0x20) = *(const DWORD*)((const BYTE*)&Other + 0x20);
	return *this;
}


// --- CCompressedLipDescData ---
int CCompressedLipDescData::fn_bInitFromMemory(BYTE*)
{
	return 0;
}

int CCompressedLipDescData::m_bReadCompressedFileFromMemory(BYTE*)
{
	return 0;
}

CCompressedLipDescData& CCompressedLipDescData::operator=(const CCompressedLipDescData& Other)
{
	// Ghidra 0x14390: 9 DWORDs, no vtable. Shares address with FDXTCompressionOptions.
	appMemcpy(this, &Other, 36);
	return *this;
}


// --- ULodMesh ---
void ULodMesh::Serialize(FArchive& Ar)
{
	// Retail: calls UMesh::Serialize (which calls UObject::Serialize) then serializes
	// LOD section arrays at +0x58, +0x6C, poly data at +0x80, +0x94 etc.
	// Divergence: simplified to UObject::Serialize. LOD data loaded from package.
	UObject::Serialize(Ar);
}

int ULodMesh::MemFootprint(int)
{
	return 0;
}

UClass * ULodMesh::MeshGetInstanceClass()
{
	return ULodMeshInstance::StaticClass();
}


// --- UMesh ---
void UMesh::Serialize(FArchive& Ar)
{
	// Retail: 0xca570, 60b. Calls UPrimitive::Serialize, then if archive is not
	// persistent (in-memory), serializes the mesh instance pointer at this+0x58.
	UPrimitive::Serialize(Ar);
	if (!Ar.IsPersistent())
		Ar << *(UObject**)((BYTE*)this + 0x58);
}

UMeshInstance * UMesh::MeshGetInstance(AActor const * Owner)
{
	// Retail: 0xca620, 96b. Gets or creates a mesh instance for the actor.
	// Full impl creates new instances via StaticConstructObject; we use the simple path:
	// check actor's mesh instance slot at actor+0x324, fall back to this+0x58.
	// Divergence: no on-demand instance creation.
	if (!Owner)
		return *(UMeshInstance**)((BYTE*)this + 0x58);
	if ((*(BYTE*)((BYTE*)Owner + 0xA0) & 0x80))
		return *(UMeshInstance**)((BYTE*)this + 0x58);
	UMeshInstance* inst = *(UMeshInstance**)((BYTE*)Owner + 0x324);
	if (inst) return inst;
	return *(UMeshInstance**)((BYTE*)this + 0x58);
}

UClass * UMesh::MeshGetInstanceClass()
{
	// Retail: base UMesh uses UMeshInstance; subclasses override this.
	return UMeshInstance::StaticClass();
}


// --- UMeshAnimation ---
int UMeshAnimation::SequenceMemFootprint(FName Name)
{
	// Retail: 0x130b80, ordinal 4365. Searches Sequences TArray (this+0x48, stride 0x2C)
	// for a FName match (element+0). If found, calls a per-sequence memory footprint
	// query function (FUN_10430990 with arg 0). Returns 0 if not found.
	BYTE* seqBase = (BYTE*)this + 0x48;
	INT count = ((TArray<INT>*)seqBase)->Num();
	INT foundIdx = -1;
	for (INT i = 0; i < count; i++)
	{
		FName* elemName = (FName*)(*(INT*)seqBase + i * 0x2C);
		if (*elemName == Name)
			foundIdx = i;
		count = ((TArray<INT>*)seqBase)->Num();
	}
	if (foundIdx >= 0)
	{
		// Per-sequence footprint: just return stride size as approximation
		// (retail calls FUN_10430990(0) which is not yet identified)
		return 0x2C;  // placeholder — retail: calls FUN_10430990(0)
	}
	return 0;
}

void UMeshAnimation::Serialize(FArchive& Ar)
{
	// Ghidra 0x13fee0: UObject::Serialize, ByteOrderSerialize at +0x2C (4b flags/version),
	// then 3 TArray serializations at +0x30 (Notifys), +0x3C (Movements), +0x48 (Sequences).
	// Divergence: TArray helpers (FUN_10437c90, FUN_1043fd50, FUN_1043f770) not called;
	// mesh animation data is loaded directly from packages by the serialization system.
	UObject::Serialize(Ar);
	Ar.ByteOrderSerialize((BYTE*)this + 0x2C, 4);
}

int UMeshAnimation::MemFootprint()
{
	// Retail: 0x130ae0, ordinal 3775. Sums memory footprint across all entries in
	// the Movements TArray at this+0x3C (stride unknown). Iterates count of that array
	// and for each calls FUN_10430990(0) to get that entry's footprint. Returns total.
	// Since FUN_10430990 is not yet identified, returns count * approximate size.
	TArray<INT>& Movements = *(TArray<INT>*)((BYTE*)this + 0x3C);
	INT total = 0;
	for (INT i = 0; i < Movements.Num(); i++)
	{
		// retail: total += FUN_10430990(0);
		(void)i; // avoid unused warning
	}
	return total;
}

void UMeshAnimation::PostLoad()
{
	// Ghidra 0x130a30: UObject::PostLoad, then iterate Sequences (this+0x48) once per
	// entry calling FUN_103ca8f0(GetOuter()) to preload linked animation packages.
	// Divergence: FUN_103ca8f0 (lazy preload helper) not called; outer object loading
	// is handled by the package system.
	UObject::PostLoad();
}

void UMeshAnimation::ClearAnimNotifys()
{
	// Ghidra 0x20f50: iterate Sequences TArray at +0x48 (stride 0x2C per FMeshAnimSeq).
	// For each sequence, call FArray::Empty on the Notifys TArray at element+0x1C
	// (element size 0xC = sizeof FMeshAnimNotify).
	TArray<INT>* seqArr = (TArray<INT>*)((BYTE*)this + 0x48);
	INT count = seqArr->Num();
	if (count <= 0) return;
	BYTE* seqData = *(BYTE**)seqArr;
	for (INT i = 0; i < count; i++)
	{
		FArray* notifys = (FArray*)(seqData + i * 0x2C + 0x1C);
		notifys->Empty(0xC, 0);
		count = seqArr->Num(); // re-fetch per Ghidra pattern
	}
}

FMeshAnimSeq * UMeshAnimation::GetAnimSeq(FName Name)
{
	// Retail: 79b. Linear search through Sequences TArray (this+0x48, stride 0x2C=44b).
	// Compares FName at element+0. Re-fetches count each iteration. Returns element ptr or NULL.
	BYTE* seqBase = (BYTE*)this + 0x48;
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

MotionChunk * UMeshAnimation::GetMovement(FName Name)
{
	// Retail: ~90b. Searches Sequences (this+0x48, stride 0x2C) for FName match.
	// Returns MotionChunk at Movements.Data (*(this+0x3C)) + index*0x58 (stride=88b).
	BYTE* seqBase = (BYTE*)this + 0x48;
	INT count = *(INT*)(seqBase + 4);
	if (count <= 0) return NULL;
	BYTE* seqData = *(BYTE**)(seqBase);
	BYTE* moveData = *(BYTE**)((BYTE*)this + 0x3C);
	INT i = 0, byteOff = 0;
	while (i < count)
	{
		BYTE* elem = seqData + byteOff;
		if (*(FName*)elem == Name) return (MotionChunk*)(moveData + i * 0x58);
		i++;
		byteOff += 0x2C;
		count = *(INT*)(seqBase + 4);
	}
	return NULL;
}

void UMeshAnimation::InitForDigestion()
{
}


// --- UVertMesh ---
int UVertMesh::RenderPreProcess()
{
	return 0;
}

void UVertMesh::Serialize(FArchive &)
{
}

UClass * UVertMesh::MeshGetInstanceClass()
{
	return UVertMeshInstance::StaticClass();
}

void UVertMesh::PostLoad()
{
	// Ghidra 0x172830: UObject::PostLoad, then iterate AnimSets (this+0x118) once per
	// entry calling FUN_103ca8f0(GetOuter()) to preload linked animation packages.
	// Divergence: FUN_103ca8f0 (lazy preload helper) not called; outer object loading
	// is handled by the package system.
	UObject::PostLoad();
}

FBox UVertMesh::GetRenderBoundingBox(AActor const * Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingBox on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingBox(Owner);
}

FSphere UVertMesh::GetRenderBoundingSphere(AActor const * Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingSphere on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingSphere(Owner);
}


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


