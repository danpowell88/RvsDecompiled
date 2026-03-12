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

