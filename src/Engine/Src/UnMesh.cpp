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
IMPL_INFERRED("Reconstructed from context")
inline void* operator new(size_t, void* p) noexcept { return p; }
IMPL_INFERRED("Reconstructed from context")
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- CBoneDescData ---
IMPL_INFERRED("reconstructed from Ghidra; loads bone names and frame data from LBP text file")
int CBoneDescData::fn_bInitFromLbpFile(const TCHAR* param_1)
{
	guard(CBoneDescData::fn_bInitFromLbpFile);
	FString fileStr;
	if (!appLoadFileToString(fileStr, param_1, GFileManager))
	{
		GError->Logf(TEXT(""));
		return 0;
	}
	TArray<FString> lines;
	fileStr.ParseIntoArray(TEXT("\n"), &lines);
	*(INT*)((BYTE*)this + 0) = appAtoi(*lines(0));
	for (INT i = 0; i < *(INT*)((BYTE*)this + 0); i++)
	{
		// Retail: FArray::Add(1, 0xc) then FString copy-ctor via placement-new.
		// FUN_1031efc0 is an SEH element-destructor helper (destroys n FString objects
		// before FArray::~FArray releases the buffer) — not a copy routine.
		// We emulate the add+copy via the TArray<FString> API directly.
		INT newIdx = ((FArray*)((BYTE*)this + 8))->Add(1, sizeof(FString));
		FString* newSlot = (FString*)(*(INT*)((BYTE*)this + 8) + newIdx * sizeof(FString));
		if (newSlot) new(newSlot) FString(lines(i + 1)); // copy bone-name line into slot
	}
	*(INT*)((BYTE*)this + 4) = appAtoi(*lines(*(INT*)((BYTE*)this + 0) + 4));
	INT frameCount = *(INT*)((BYTE*)this + 4);
	if (frameCount != 0)
	{
		BYTE** arr = (BYTE**)GMalloc->Malloc(frameCount * 4, TEXT("BoneDesc"));
		*(void**)((BYTE*)this + 0x20) = arr;
		INT boneCount = *(INT*)((BYTE*)this + 0);
		for (INT fi = 0; fi < frameCount; fi++)
		{
			BYTE* pFVar5 = (BYTE*)GMalloc->Malloc(boneCount * 0x1c, TEXT("BoneFrame"));
			arr[fi] = pFVar5;
		}
	}
	for (INT frame = 0; frame < *(INT*)((BYTE*)this + 4); frame++)
	{
		for (INT bone = 0; bone < *(INT*)((BYTE*)this + 0); bone++)
		{
			INT lineIdx = *(INT*)((BYTE*)this + 0) * (frame + 1) + 5 + bone;
			m_vProcessLbpLine(frame, bone, lines(lineIdx));
		}
	}
	GLog->Logf(TEXT(""));
	return 1;
	unguard;
}

IMPL_INFERRED("parses one LBP token line into bone position/quaternion; axis conventions from Ghidra")
void CBoneDescData::m_vProcessLbpLine(int param1, int param2, FString& str)
{
	guard(CBoneDescData::m_vProcessLbpLine);
	TArray<FString> tokens;
	// DAT_1052ec38: separator TCHAR* (TODO: unknown at compile time; assumed space for LBP format)
	str.ParseIntoArray(TEXT(" "), &tokens);
	INT stride = param2 * 0x1C;
	BYTE* base = *(BYTE**)(*(INT*)((BYTE*)this + 0x20) + param1 * 4);
	*(float*)(base + stride + 0x00) =  appAtof(*tokens(16)); // X
	*(float*)(base + stride + 0x04) = -appAtof(*tokens(17)); // -Y (axis flip per Ghidra)
	*(float*)(base + stride + 0x08) =  appAtof(*tokens(18)); // Z
	// FQuat stored as [Y, Z, W, X] = [fStack_1c, fStack_18, fStack_14, fStack_10]
	float fX = -appAtof(*tokens(34)); // fStack_10 (negated)
	float fY =  appAtof(*tokens(35)); // fStack_1c
	float fZ = -appAtof(*tokens(36)); // fStack_18 (negated)
	float fW =  appAtof(*tokens(39)); // fStack_14
	float* pfQuat = (float*)(base + stride + 0x0C);
	pfQuat[0] = fY; // *pfVar1
	pfQuat[1] = fZ; // pfVar1[1]
	pfQuat[2] = fW; // pfVar1[2]
	pfQuat[3] = fX; // pfVar1[3]
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x2b030)
CBoneDescData::CBoneDescData(CBoneDescData const & Other)
{
	// Ghidra 0x2b030, 93B. Copy 2 DWORDs, deep-copy TArray<FString>, copy FString, copy DWORD.
	*(DWORD*)((BYTE*)this + 0x00) = *(const DWORD*)((const BYTE*)&Other + 0x00);
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	new((BYTE*)this + 0x08) TArray<FString>(*(const TArray<FString>*)((const BYTE*)&Other + 0x08));
	new((BYTE*)this + 0x14) FString(*(const FString*)((const BYTE*)&Other + 0x14));
	*(DWORD*)((BYTE*)this + 0x20) = *(const DWORD*)((const BYTE*)&Other + 0x20);
}

IMPL_GHIDRA("Engine.dll", 0x55b30)
CBoneDescData::CBoneDescData()
{
	// Ghidra 0x55b30, 93B. Init TArray<FString> at +0x08, FString at +0x14, zero the rest.
	*(DWORD*)((BYTE*)this + 0x00) = 0;
	*(DWORD*)((BYTE*)this + 0x04) = 0;
	new((BYTE*)this + 0x08) TArray<FString>();
	new((BYTE*)this + 0x14) FString();
	*(DWORD*)((BYTE*)this + 0x20) = 0;
}

IMPL_INFERRED("destroys TArray<FString> and FString members in correct order")
CBoneDescData::~CBoneDescData()
{
	// Destroy TArray<FString> at +0x08 and FString at +0x14.
	typedef TArray<FString> TFStringArray;
	((TFStringArray*)((BYTE*)this + 0x08))->~TFStringArray();
	((FString*)((BYTE*)this + 0x14))->~FString();
}

IMPL_GHIDRA("Engine.dll", 0x2b0a0)
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
IMPL_INFERRED("null-check then delegates to m_bReadCompressedFileFromMemory")
int CCompressedLipDescData::fn_bInitFromMemory(BYTE* param_1)
{
	if (param_1 == NULL) return 0;
	INT iVar1 = m_bReadCompressedFileFromMemory(param_1);
	GLog->Logf(TEXT(""));
	return iVar1;
}

IMPL_INFERRED("reads compressed lip-sync header and allocates per-frame morph-key arrays")
int CCompressedLipDescData::m_bReadCompressedFileFromMemory(BYTE* param_1)
{
	guard(CCompressedLipDescData::m_bReadCompressedFileFromMemory);
	appMemcpy((BYTE*)this + 8,    param_1,        4);
	appMemcpy((BYTE*)this + 0,    param_1 + 4,    4);
	appMemcpy((BYTE*)this + 4,    param_1 + 8,    4);
	appMemcpy((BYTE*)this + 0xc,  param_1 + 0xc,  4);
	appMemcpy((BYTE*)this + 0x10, param_1 + 0x10, 4);
	appMemcpy((BYTE*)this + 0x1c, param_1 + 0x14, 4);
	appMemcpy((BYTE*)this + 0x18, param_1 + 0x18, 4);
	BYTE* puVar6 = param_1 + 0x1c;
	INT count = *(INT*)((BYTE*)this + 0x18);
	void* arr = GMalloc->Malloc(count << 4, TEXT("CompressedLip"));
	*(void**)((BYTE*)this + 0x20) = arr;
	INT iVar4 = 0;
	for (INT iVar7 = 0; iVar7 < count; iVar7++)
	{
		FLOAT fVal; appMemcpy(&fVal, puVar6, 4); puVar6 += 4;
		*(FLOAT*)((BYTE*)arr + iVar4) = fVal;
		SWORD sVal; appMemcpy(&sVal, puVar6, 4); puVar6 += 4;
		*(SWORD*)((BYTE*)arr + iVar4 + 4) = sVal;
		_WORD count2 = *(_WORD*)((BYTE*)arr + iVar4 + 4);
		if (count2 != 0)
		{
			void* subArr = GMalloc->Malloc((DWORD)count2 << 1, TEXT("CompressedLip"));
			*(void**)((BYTE*)arr + iVar4 + 0xc) = subArr;
			for (INT iVar5 = 0; iVar5 < (INT)(DWORD)count2; iVar5++)
			{
				_WORD wVal; appMemcpy(&wVal, puVar6, 2); puVar6 += 2;
				*(_WORD*)((BYTE*)subArr + iVar5 * 2) = wVal;
			}
		}
		iVar4 += 0x10;
	}
	return 1;
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x14390)
CCompressedLipDescData& CCompressedLipDescData::operator=(const CCompressedLipDescData& Other)
{
	// Ghidra 0x14390: 9 DWORDs, no vtable. Shares address with FDXTCompressionOptions.
	appMemcpy(this, &Other, 36);
	return *this;
}


// --- ULodMesh ---
IMPL_INFERRED("simplified to UObject::Serialize; LOD array serializers unresolved")
void ULodMesh::Serialize(FArchive& Ar)
{
	// Retail: calls UMesh::Serialize (which calls UObject::Serialize) then serializes
	// LOD section arrays at +0x58, +0x6C, poly data at +0x80, +0x94 etc.
	// Divergence: simplified to UObject::Serialize. LOD data loaded from package.
	UObject::Serialize(Ar);
}

IMPL_TODO("Needs Ghidra analysis")
int ULodMesh::MemFootprint(int param_1)
{
	guard(ULodMesh::MemFootprint);
	return 0;
	unguard;
}

IMPL_INFERRED("returns ULodMeshInstance::StaticClass()")
UClass * ULodMesh::MeshGetInstanceClass()
{
	return ULodMeshInstance::StaticClass();
}


// --- UMesh ---
IMPL_GHIDRA_APPROX("Engine.dll", 0xca570, "non-persistent path serializes mesh instance pointer; persistent path omits it")
void UMesh::Serialize(FArchive& Ar)
{
	// Retail: 0xca570, 60b. Calls UPrimitive::Serialize, then if archive is not
	// persistent (in-memory), serializes the mesh instance pointer at this+0x58.
	UPrimitive::Serialize(Ar);
	if (!Ar.IsPersistent())
		Ar << *(UObject**)((BYTE*)this + 0x58);
}

IMPL_GHIDRA_APPROX("Engine.dll", 0xca620, "no on-demand instance creation; simplified path only")
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

IMPL_INFERRED("returns UMeshInstance::StaticClass() for base UMesh")
UClass * UMesh::MeshGetInstanceClass()
{
	// Retail: base UMesh uses UMeshInstance; subclasses override this.
	return UMeshInstance::StaticClass();
}


// --- UMeshAnimation ---
IMPL_GHIDRA_APPROX("Engine.dll", 0x130b80, "FUN_10430990 not called — returns fixed stride 0x2C instead of true per-item footprint")
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
		// Retail calls FUN_10430990(0) to obtain the per-sequence memory footprint.
		// FUN_10430990 appears to be a virtual/static "sizeof this item" helper;
		// its true identity is unresolved. We return the known FMeshAnimSeq stride.
		// DIVERGENCE: FUN_10430990(0) not called — returns fixed stride 0x2C instead.
		return 0x2C;
	}
	return 0;
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x13fee0, "TArray helper calls unresolved; mesh animation data loaded from packages")
void UMeshAnimation::Serialize(FArchive& Ar)
{
	// Ghidra 0x13fee0: UObject::Serialize, ByteOrderSerialize at +0x2C (4b flags/version),
	// then 3 TArray serializations at +0x30 (Notifys), +0x3C (Movements), +0x48 (Sequences)
	// via helpers FUN_10437c90, FUN_1043fd50, FUN_1043f770 (complex TArray<UObject> serializers).
	// DIVERGENCE: those TArray helpers are unresolved external calls; mesh animation data
	// is loaded directly from packages by the UE2 serialization system.
	UObject::Serialize(Ar);
	Ar.ByteOrderSerialize((BYTE*)this + 0x2C, 4);
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x130ae0, "FUN_10430990 not called — per-item footprint not accumulated; returns 0")
int UMeshAnimation::MemFootprint()
{
	// Retail: 0x130ae0, ordinal 3775. Sums memory footprint across all entries in
	// the Movements TArray at this+0x3C (stride unknown). Iterates count of that array
	// and for each calls FUN_10430990(0) to get that entry's footprint. Returns total.
	// FUN_10430990 is a virtual "sizeof this item" helper whose identity is unresolved.
	// DIVERGENCE: FUN_10430990(0) not called — total is 0 (no per-item footprint known).
	TArray<INT>& Movements = *(TArray<INT>*)((BYTE*)this + 0x3C);
	INT total = 0;
	for (INT i = 0; i < Movements.Num(); i++)
	{
		// FUN_10430990(0) = virtual "size of one MotionChunk item" helper; unresolved.
		// DIVERGENCE: item footprint not accumulated (FUN_10430990 identity unknown).
		(void)i; // avoid unused warning
	}
	return total;
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x130a30, "FUN_103ca8f0 (lazy preload helper) not called; UE2 linker handles cross-ref loading")
void UMeshAnimation::PostLoad()
{
	// Ghidra 0x130a30: UObject::PostLoad, then iterate Sequences (this+0x48) once per
	// entry calling FUN_103ca8f0(GetOuter()) to preload linked animation packages.
	// FUN_103ca8f0 = lazy package preload helper — forces load of the outer package
	// so any cross-referenced animation data is available before first use.
	// DIVERGENCE: FUN_103ca8f0 not called; the UE2 linker handles cross-ref loading.
	UObject::PostLoad();
}

IMPL_GHIDRA("Engine.dll", 0x20f50)
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

IMPL_INFERRED("linear search through Sequences TArray at +0x48 by FName; re-fetches count each iteration")
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

IMPL_INFERRED("searches Sequences TArray for FName then returns MotionChunk at stride 0x58")
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

IMPL_INFERRED("allocates 0x2C-byte digest struct if not already present; seeds 1.0f sentinel")
void UMeshAnimation::InitForDigestion()
{
	guard(UMeshAnimation::InitForDigestion);
	if (*(INT*)((BYTE*)this + 0x54) == 0)
	{
		// FUN_1032b9b0 = raw memory allocator for animation digest struct (0x2C bytes).
		// Ghidra shows it returns appMalloc(0x2C, ...) equivalent; the 11-DWORD zero loop
		// and the 1.0f seed follow in the caller, so our appMalloc+memzero is faithful.
		void* p = appMalloc(0x2C, TEXT("Digest"));
		*(void**)((BYTE*)this + 0x54) = p;
		appMemzero(p, 0x2C); // loop: 11 DWORDs zeroed = 0x2C bytes
		*(DWORD*)((BYTE*)p + 0x28) = 0x3f800000; // 1.0f
	}
	unguard;
}


// --- UVertMesh ---
IMPL_INFERRED("builds render-section list from raw verts and tex-index array")
int UVertMesh::RenderPreProcess()
{
	guard(UVertMesh::RenderPreProcess);
	INT iVar2 = ((FArray*)((BYTE*)this + 400))->Num();
	if (iVar2 != 0) return 0;

	((FArray*)((BYTE*)this + 0x14c))->Empty(0x20, 0);
	FArray* this_00 = (FArray*)((BYTE*)this + 0xc4);
	iVar2 = this_00->Num();
	FArray* this_01 = (FArray*)((BYTE*)this + 0x14c);
	this_01->Add(iVar2, 0x20);
	*(INT*)((BYTE*)this + 0x160) += 1;

	iVar2 = 0;
	while (true)
	{
		INT iVar3 = this_00->Num();
		if (iVar3 <= iVar2) break;
		BYTE* dst = (BYTE*)((BYTE*)*(INT*)this_01 + iVar2 * 0x20);
		BYTE* src = (BYTE*)((BYTE*)*(INT*)this_00 + iVar2 * 0xc);
		*(DWORD*)(dst + 0x18) = *(DWORD*)(src + 4);
		*(DWORD*)(dst + 0x1c) = *(DWORD*)(src + 8);
		iVar2++;
	}

	_WORD* puVar4 = NULL;
	iVar2 = 0;
	while (true)
	{
		INT iVar3 = ((FArray*)((BYTE*)this + 0xac))->Num();
		if (iVar3 <= iVar2) break;
		DWORD uVar1 = *(DWORD*)((BYTE*)*(INT*)((BYTE*)this + 0xac) + 4 + iVar2 * 8);
		if ((puVar4 == NULL) || ((uVar1 >> 0x10) != (DWORD)*puVar4))
		{
			INT newIdx = ((FArray*)((BYTE*)this + 400))->Add(1, 0x5c);
			BYTE* newEntry = (BYTE*)((BYTE*)*(INT*)((BYTE*)this + 400) + newIdx * 0x5c);
			if (newEntry == NULL)
				puVar4 = NULL;
			else
			{
				puVar4 = (_WORD*)newEntry;
				_WORD uStack_22 = (_WORD)(uVar1 >> 0x10);
				puVar4[7] = (_WORD)iVar2;
				*puVar4 = uStack_22;
				puVar4[2] = 0;
				iVar3 = ((FArray*)((BYTE*)this + 0xc4))->Num();
				puVar4[3] = (SWORD)(iVar3 - 1);
				puVar4[8] = 0;
			}
		}
		if (puVar4) puVar4[8]++;
		iVar2++;
	}
	return 1;
	unguard;
}

IMPL_INFERRED("calls ULodMesh::Serialize; complex TArray serializers diverged — data loaded from package")
void UVertMesh::Serialize(FArchive& Ar)
{
	guard(UVertMesh::Serialize);
	ULodMesh::Serialize(Ar);
	// FUN_10323030 = TArray<0x20-element>::Serialize (lazy-loader sub-archive for +0x14C)
	// followed by ByteOrderSerialize(+0x160). FUN_103c7240/FUN_10438000/FUN_1043f770/
	// FUN_1032d5f0 are TArray serializers for +0xF4, +0x10C, +0x118, +0x100 respectively;
	// FUN_103cd010 and FUN_10474600 handle +0x124 and +0x130.
	// DIVERGENCE: all TArray serializers omitted; vert mesh data loaded from package.
	Ar.ByteOrderSerialize((BYTE*)this + 0x13C, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x140, 4);
	if (!Ar.IsPersistent())
	{
		// FUN_1043fc30 = FAnimMeshVertexStream TArray serializer; called between each of the
		// four index-buffer ByteOrderSerialize calls below. Unresolved — omitted.
		// DIVERGENCE: FAnimMeshVertexStream TArray streams not serialized here.
		Ar.ByteOrderSerialize((BYTE*)this + 0x170, 4);
		Ar.ByteOrderSerialize((BYTE*)this + 0x19C, 4);
		Ar.ByteOrderSerialize((BYTE*)this + 0x1C8, 4);
		Ar.ByteOrderSerialize((BYTE*)this + 0x1F4, 4); // 500 = 0x1F4
	}
	unguard;
}

IMPL_INFERRED("returns UVertMeshInstance::StaticClass()")
UClass * UVertMesh::MeshGetInstanceClass()
{
	return UVertMeshInstance::StaticClass();
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x172830, "FUN_103ca8f0 not called; UE2 linker handles cross-ref loading")
void UVertMesh::PostLoad()
{
	// Ghidra 0x172830: UObject::PostLoad, then iterate AnimSets (this+0x118) once per
	// entry calling FUN_103ca8f0(GetOuter()) to preload linked animation packages.
	// FUN_103ca8f0 = lazy package preload helper (same as UMeshAnimation::PostLoad).
	// DIVERGENCE: FUN_103ca8f0 not called; the UE2 linker handles cross-ref loading.
	UObject::PostLoad();
}

IMPL_INFERRED("delegates to mesh instance GetRenderBoundingBox")
FBox UVertMesh::GetRenderBoundingBox(AActor const * Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingBox on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingBox(Owner);
}

IMPL_INFERRED("delegates to mesh instance GetRenderBoundingSphere")
FSphere UVertMesh::GetRenderBoundingSphere(AActor const * Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingSphere on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingSphere(Owner);
}


// --- USkeletalMesh ---
IMPL_GHIDRA("Engine.dll", 0x12f410)
void USkeletalMesh::m_bLoadLbpFile(FString FileName)
{
	// Retail: 0x12f410. Extracts raw TCHAR* from FString and initialises
	// the CBoneDescData bone descriptor at this+0x294 from the LBP file.
	CBoneDescData* boneDesc = (CBoneDescData*)((BYTE*)this + 0x294);
	boneDesc->fn_bInitFromLbpFile(*FileName);
}

IMPL_INFERRED("AddUnique on alias name array then inserts or updates target FName and FCoords")
int USkeletalMesh::SetAttachAlias(FName param_2, FName param_3, FCoords& param_4)
{
	guard(USkeletalMesh::SetAttachAlias);
	FName none(NAME_None);
	if (param_2 == none) return 0;
	if (param_3 == none) return 0;

	FArray* nameArr = (FArray*)((BYTE*)this + 0x2d0);
	INT iVar1_before = nameArr->Num();
	// FUN_10437fb0(&param_2) = TArray<FName>::AddUnique(param_2):
	// searches the array for param_2, returns its index if found (no insertion),
	// otherwise appends and returns the new index. Ghidra 0x37fb0 confirms this pattern:
	// local_18=Num() before, iVar2=FUN_10437fb0(&name), iVar1=Num() after; if equal=found.
	INT iVar2 = -1;
	for (INT k = 0; k < iVar1_before; k++)
	{
		if (*(FName*)(*(INT*)nameArr + k * 4) == param_2) { iVar2 = k; break; }
	}
	if (iVar2 < 0)
	{
		iVar2 = nameArr->Add(1, 4);
		*(FName*)(*(INT*)nameArr + iVar2 * 4) = param_2;
	}
	INT iVar1_after = nameArr->Num();

	if (iVar1_before == iVar1_after)
	{
		if (((FArray*)((BYTE*)this + 0x2e8))->Num() != nameArr->Num()) return 1;
		if (((FArray*)((BYTE*)this + 0x2dc))->Num() != nameArr->Num()) return 1;
		*(DWORD*)((BYTE*)*(INT*)((BYTE*)this + 0x2dc) + iVar2 * 4) = *(DWORD*)&param_3;
		DWORD* src = (DWORD*)&param_4;
		DWORD* dst = (DWORD*)((BYTE*)*(INT*)((BYTE*)this + 0x2e8) + iVar2 * 0x30);
		for (INT iVar3 = 0xc; iVar3 != 0; iVar3--) { *dst = *src; src++; dst++; }
	}
	else
	{
		INT iVar1 = ((FArray*)((BYTE*)this + 0x2dc))->Add(1, 4);
		*(DWORD*)((BYTE*)*(INT*)((BYTE*)this + 0x2dc) + iVar1 * 4) = *(DWORD*)&param_3;
		iVar2 = ((FArray*)((BYTE*)this + 0x2e8))->Add(1, 0x30);
		DWORD* src = (DWORD*)&param_4;
		DWORD* dst = (DWORD*)((BYTE*)*(INT*)((BYTE*)this + 0x2e8) + iVar2 * 0x30);
		for (INT iVar3 = 0xc; iVar3 != 0; iVar3--) { *dst = *src; src++; dst++; }
	}
	return 1;
	unguard;
}

IMPL_TODO("requires USkeletalMeshInstance::GetTagCoords and bone-transform-to-world conversion")
int USkeletalMesh::SetAttachmentLocation(AActor* param_2, AActor* param_3)
{
	guard(USkeletalMesh::SetAttachmentLocation);
	// Retail: reads bone transforms from SkeletalMeshInstance (via GetMeshInstance on param_2)
	// and applies the world-space bone transform to param_3's Location/Rotation.
	// TODO: implement USkeletalMesh::SetAttachmentLocation — requires USkeletalMeshInstance::GetTagCoords
	// and bone-transform-to-world conversion
	return 0;
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x140640)
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

IMPL_INTENTIONALLY_EMPTY("Ghidra 0x1651d0 confirms function body is empty")
void USkeletalMesh::NormalizeInfluences(int)
{
	guard(USkeletalMesh::NormalizeInfluences);
	// Ghidra 0x1651d0: shared empty-stub address — function body is empty.
	unguard;
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x1441e0, "full implementation deferred — requires stride constants from unidentified TArray serializers")
void USkeletalMesh::CalculateNormals(TArray<FVector>& Normals, int param2)
{
	guard(USkeletalMesh::CalculateNormals);
	// Ghidra 0x1441e0: complex per-triangle normal accumulation.
	// Reads faces (this+0xAC, stride 8), verts (this+0x1B8), bone weights.
	// DIVERGENCE: full implementation deferred — requires stride constants and inline
	// arithmetic from multiple unidentified TArray serializers to be accurate.
	(void)Normals; (void)param2;
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x135bb0)
void USkeletalMesh::ClearAttachAliases()
{
	// Retail: 0x135bb0. Empties the three attach alias arrays.
	// Alias names at this+0x2D0 (stride 4), alias targets at this+0x2DC (stride 4),
	// alias coord data at this+0x2E8 (stride 0x30).
	((TArray<INT>*)((BYTE*)this + 0x2D0))->Empty();
	((TArray<INT>*)((BYTE*)this + 0x2DC))->Empty();
	((TArray<INT>*)((BYTE*)this + 0x2E8))->Empty();
}

IMPL_GHIDRA("Engine.dll", 0x140780)
void USkeletalMesh::FlipFaces()
{
	guard(USkeletalMesh::FlipFaces);
	// Ghidra 0x140780: swap first two uint16 vertex indices in each face entry.
	// Faces TArray at this+0xAC; each face is 8 bytes (3 x uint16 + padding).
	FArray* facesArr = (FArray*)((BYTE*)this + 0xAC);
	INT i = 0;
	while (true)
	{
		if (facesArr->Num() <= i) break;
		BYTE* face = (BYTE*)(*(INT*)facesArr) + i * 8;
		_WORD tmp          = *(_WORD*)(face + 0);
		*(_WORD*)(face + 0) = *(_WORD*)(face + 2);
		*(_WORD*)(face + 2) = tmp;
		i++;
	}
	unguard;
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x142d40, "progressive mesh reduction helpers unresolved; LOD generation not implementable")
void USkeletalMesh::GenerateLodModel(int param1, float param2, float param3, int param4, int param5)
{
	guard(USkeletalMesh::GenerateLodModel);
	// Ghidra 0x142d40: validates param1 in [0,8], then calls many FUN_ helpers
	// to compute LOD vertex/face streams from the full-resolution mesh.
	// DIVERGENCE: progressive mesh reduction helpers (FUN_10437c20 and related) are
	// unresolved external calls in Engine.dll; LOD generation is not implementable here.
	if (param1 >= 0 && param1 < 9)
	{
		(void)param2; (void)param3; (void)param4; (void)param5;
	}
	unguard;
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x142970, "LOD entry constructor and stream-copy helpers unresolved; no data copy")
void USkeletalMesh::InsertLodModel(int param1, USkeletalMesh* param2, float param3, int param4)
{
	guard(USkeletalMesh::InsertLodModel);
	// Ghidra 0x142970: inserts LOD model from param2 at slot param1 in LOD array.
	// FUN_1043f4c0 = LOD entry constructor (initialises the 0x11C-byte slot);
	// following vtable stream-copy calls deep-copy param2's vertex/index streams.
	// DIVERGENCE: FUN_1043f4c0 and stream-copy helpers are unresolved — no data copy.
	if (param1 >= 0 && param1 < 9)
	{
		FArray* lodArr = (FArray*)((BYTE*)this + 0x1AC);
		// Extend LOD array until it has at least param1+1 entries (stride 0x11C)
		while (lodArr->Num() <= param1)
		{
			INT idx = lodArr->Add(1, 0x11C);
			if (idx * 0x11C + *(INT*)lodArr != 0)
			{
				// FUN_1043f4c0 = LOD entry constructor; unresolved — slot left zeroed.
			}
		}
		(void)param2; (void)param3; (void)param4;
		// DIVERGENCE: stream data not copied from param2 (stream-copy helpers unresolved)
	}
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x12F6C0)
int USkeletalMesh::UseCylinderCollision(const AActor* Actor)
{
	// Retail (18b, RVA 0x12F6C0): returns 0 only for ragdoll actors (Physics byte at Actor+0x2C == 0x0E = PHYS_KarmaRagDoll).
	// PHYS_KarmaRagDoll = 14/0x0E. All other physics modes use cylinder collision.
	return Actor->Physics != PHYS_KarmaRagDoll;
}

IMPL_INFERRED("delegates to UPrimitive::LineCheck except for skeletal hit-cylinder path which is unresolved")
int USkeletalMesh::R6LineCheck(FCheckResult& param_1, AActor* param_2, FVector param_3, FVector param_4, FVector param_5, DWORD param_6, DWORD param_7)
{
	guard(USkeletalMesh::R6LineCheck);
	if ((param_6 & 0x10000) == 0 || (*(DWORD*)((BYTE*)param_2 + 0xa8) & 0x2000) == 0)
		return UPrimitive::LineCheck(param_1, param_2, param_3, param_4, param_5, param_6, param_7);
	// DIVERGENCE: skeletal hit detection via bone pivots unresolved.
	// Retail reads bone world positions from the mesh instance (GetMeshInstance) and tests
	// the ray against per-bone cylinders (GetBoneCylinder). GetBoneCylinder and the bone
	// radius table (m_fCylindersRadius) are not yet populated from binary data.
	return 1;
	unguard;
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x1043ffb0, "simplified to UObject::Serialize; skeletal mesh data loaded from .u package")
void USkeletalMesh::Serialize(FArchive& Ar)
{
	// Retail: 0x1043ffb0. Calls ULodMesh::Serialize, then serializes bone ref pose (+0x1B8),
	// bone array (+0x19C), default anim ref (+0x1DC), vertex inflations, LOD arrays etc.
	// Divergence: simplified to UObject::Serialize; mesh data is loaded from .u package.
	UObject::Serialize(Ar);
}

IMPL_PERMANENT_DIVERGENCE("Karma physics — MathEngine SDK proprietary; source unavailable")
int USkeletalMesh::LineCheck(FCheckResult& param_1, AActor* param_2, FVector param_3, FVector param_4, FVector param_5, DWORD param_6, DWORD param_7)
{
	guard(USkeletalMesh::LineCheck);
	if (*(BYTE*)((BYTE*)param_2 + 0x2c) != 0x0e) // PHYS_KarmaRagDoll = 14
		return UPrimitive::LineCheck(param_1, param_2, param_3, param_4, param_5, param_6, param_7);
	// DIVERGENCE: Karma ragdoll line check delegates to MeXContactPoints for per-body ray cast.
	// Karma physics integration not implemented; returns 1 (no hit).
	return 1;
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x140350)
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

IMPL_GHIDRA("Engine.dll", 0x1042f5d0)
void USkeletalMesh::Destroy()
{
	// Retail: 0x1042f5d0. Just calls UObject::Destroy (no custom cleanup beyond base class).
	UObject::Destroy();
}

IMPL_GHIDRA("Engine.dll", 0x12f6e0)
FBox USkeletalMesh::GetCollisionBoundingBox(const AActor* Owner) const
{
	// Retail: 0x12f6e0. Delegates to UPrimitive::GetCollisionBoundingBox.
	return UPrimitive::GetCollisionBoundingBox(Owner);
}

IMPL_INFERRED("delegates to mesh instance GetRenderBoundingBox")
FBox USkeletalMesh::GetRenderBoundingBox(const AActor* Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingBox on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingBox(Owner);
}

IMPL_INFERRED("delegates to mesh instance GetRenderBoundingSphere")
FSphere USkeletalMesh::GetRenderBoundingSphere(const AActor* Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingSphere on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingSphere(Owner);
}


// --- USkeletalMesh ---
IMPL_GHIDRA_APPROX("Engine.dll", 0x141820, "stream-clear vtable calls and per-LOD copy loops reference unresolved helpers; body left empty")
void USkeletalMesh::ReconstructRawMesh()
{
	guard(USkeletalMesh::ReconstructRawMesh);
	// Ghidra 0x141820: empties render streams via vtable calls, then reconstructs
	// raw vertex/face arrays from LOD data.  All stream-clear vtable calls (+0xF4,
	// +0x13C, +0x124, +0x10C, +0x154, +0x16C, +0x184) and the per-LOD copy loops
	// require unidentified helpers — TODO.
	// The two export loops (for iVar4 iterating 0..*(this+0x104) and ..*(this+0x134))
	// are no-ops in Ghidra (empty bodies), so they are omitted here.
	// FArray::Empty calls on +0x100 and +0x118 are skipped (also in the TODO block).
	unguard;
}

IMPL_INFERRED("returns 1; skeletal mesh render pre-process is a no-op at this level")
int USkeletalMesh::RenderPreProcess()
{
	guard(USkeletalMesh::RenderPreProcess);
	return 1;
	unguard;
}

IMPL_INFERRED("returns USkeletalMeshInstance::StaticClass()")
UClass * USkeletalMesh::MeshGetInstanceClass()
{
	return USkeletalMeshInstance::StaticClass();
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x12f4b0, "LOD version check and auto-generation skipped; LOD data expected from package")
void USkeletalMesh::PostLoad()
{
	// Ghidra 0x12f4b0: UObject::PostLoad, then if LOD version at +0x5C < 2,
	// call ReconstructRawMesh(). If LOD models array (this+0x1AC) is empty,
	// auto-generate 4 LOD levels.
	// Divergence: LOD version check and auto-generation skipped;
	// LOD data is expected to already be in the package file.
	UObject::PostLoad();
}


