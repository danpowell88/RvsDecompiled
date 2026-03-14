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
IMPL_DIVERGE("reconstructed from Ghidra 0x10355fa0; LBP parsing SEH frame and error paths diverge")
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

IMPL_DIVERGE("reconstructed from Ghidra 0x10355c60; separator is runtime global DAT_1052ec38")
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

IMPL_MATCH("Engine.dll", 0x1032b030)
CBoneDescData::CBoneDescData(CBoneDescData const & Other)
{
	// Ghidra 0x2b030, 93B. Copy 2 DWORDs, deep-copy TArray<FString>, copy FString, copy DWORD.
	*(DWORD*)((BYTE*)this + 0x00) = *(const DWORD*)((const BYTE*)&Other + 0x00);
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	new((BYTE*)this + 0x08) TArray<FString>(*(const TArray<FString>*)((const BYTE*)&Other + 0x08));
	new((BYTE*)this + 0x14) FString(*(const FString*)((const BYTE*)&Other + 0x14));
	*(DWORD*)((BYTE*)this + 0x20) = *(const DWORD*)((const BYTE*)&Other + 0x20);
}

IMPL_MATCH("Engine.dll", 0x10355b30)
CBoneDescData::CBoneDescData()
{
	// Ghidra 0x55b30, 93B. Init TArray<FString> at +0x08, FString at +0x14, zero the rest.
	*(DWORD*)((BYTE*)this + 0x00) = 0;
	*(DWORD*)((BYTE*)this + 0x04) = 0;
	new((BYTE*)this + 0x08) TArray<FString>();
	new((BYTE*)this + 0x14) FString();
	*(DWORD*)((BYTE*)this + 0x20) = 0;
}

IMPL_MATCH("Engine.dll", 0x10355b90)
CBoneDescData::~CBoneDescData()
{
	// Ghidra 0x55b90: if +0x20 non-null, free each frame buffer (count=this+4),
	// free the pointer array, zero +0x20/+4/+0. Then ~FString(+0x14), ~TArray(+0x08).
	if (*(void**)((BYTE*)this + 0x20) != NULL)
	{
		INT frameCount = *(INT*)((BYTE*)this + 0x04);
		BYTE** frames = *(BYTE***)((BYTE*)this + 0x20);
		for (INT i = 0; i < frameCount; i++)
			GMalloc->Free(frames[i]);
		GMalloc->Free(frames);
		*(void**)((BYTE*)this + 0x20) = NULL;
		*(INT*)((BYTE*)this + 0x04) = 0;
		*(INT*)((BYTE*)this + 0x00) = 0;
	}
	((FString*)((BYTE*)this + 0x14))->~FString();
	typedef TArray<FString> TFStringArray;
	((TFStringArray*)((BYTE*)this + 0x08))->~TFStringArray();
}

IMPL_MATCH("Engine.dll", 0x1032b0a0)
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
IMPL_MATCH("Engine.dll", 0x10355070)
int CCompressedLipDescData::fn_bInitFromMemory(BYTE* param_1)
{
	// Ghidra 0x55070 (209b): NULL guard → rdtsc (perf timing, no side-effects) →
	// m_bReadCompressedFileFromMemory → rdtsc → GLog->Logf.
	// rdtsc calls are pure instrumentation with no behavioral effect; body is faithful.
	if (param_1 == NULL) return 0;
	INT iVar1 = m_bReadCompressedFileFromMemory(param_1);
	GLog->Logf(TEXT(""));
	return iVar1;
}

IMPL_DIVERGE("reconstructed from Ghidra 0x10354f00; sub-array allocation offsets approximated")
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
		INT sValRaw; appMemcpy(&sValRaw, puVar6, 4); puVar6 += 4; // retail reads 4 bytes; lower 2 used as count
		*(SWORD*)((BYTE*)arr + iVar4 + 4) = (SWORD)sValRaw;
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

IMPL_MATCH("Engine.dll", 0x10314390)
CCompressedLipDescData& CCompressedLipDescData::operator=(const CCompressedLipDescData& Other)
{
	// Ghidra 0x14390: 9 DWORDs, no vtable. Shares address with FDXTCompressionOptions.
	appMemcpy(this, &Other, 36);
	return *this;
}


// --- ULodMesh ---
IMPL_DIVERGE("calls FUN_103c7240/FUN_103c7140/FUN_1031e600/FUN_1032d290/FUN_1032d090/FUN_103c7340 (unresolved LOD TArray serializers); retail 0x103c7610 (558b)")
void ULodMesh::Serialize(FArchive& Ar)
{
	// Retail: calls UMesh::Serialize, then serializes LOD version (+0x5C), LOD section arrays,
	// poly data, and face arrays via FUN_103c7240/FUN_103c7140/FUN_1031e600/FUN_1032d290 etc.
	// DIVERGENCE: LOD TArray serializers unresolved; base-class data is preserved correctly.
	UMesh::Serialize(Ar);
}

IMPL_MATCH("Engine.dll", 0x10304720)
int ULodMesh::MemFootprint(int param_1)
{
	guard(ULodMesh::MemFootprint);
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10314b40)
UClass * ULodMesh::MeshGetInstanceClass()
{
	return ULodMeshInstance::StaticClass();
}


// --- UMesh ---
IMPL_MATCH("Engine.dll", 0x103ca570)
void UMesh::Serialize(FArchive& Ar)
{
	// Retail: 0xca570, 60b. Calls UPrimitive::Serialize, then if archive is not
	// persistent (in-memory), serializes the mesh instance pointer at this+0x58.
	UPrimitive::Serialize(Ar);
	if (!Ar.IsPersistent())
		Ar << *(UObject**)((BYTE*)this + 0x58);
}

IMPL_DIVERGE("simplified; retail 0x103ca620 (251b) creates instances via StaticConstructObject")
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

IMPL_MATCH("Engine.dll", 0x10414310)
UClass * UMesh::MeshGetInstanceClass()
{
	return NULL;
}


// --- UMeshAnimation ---
IMPL_DIVERGE("calls FUN_10430990 (unresolved per-sequence memory footprint helper); fixed stride returned instead; retail 0x10430b80 (159b)")
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

IMPL_DIVERGE("calls FUN_10437c90/FUN_1043fd50/FUN_1043f770 (unresolved TArray serializers at +0x30/+0x3C/+0x48); retail 0x1043fee0 (135b)")
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

IMPL_DIVERGE("calls FUN_10430990 (unresolved per-sequence footprint helper) per Movements entry; accumulation omitted; retail 0x10430ae0 (103b)")
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

IMPL_DIVERGE("calls FUN_103ca8f0 (unresolved lazy package preload helper) per Sequences entry; retail 0x10430a30 (119b)")
void UMeshAnimation::PostLoad()
{
	// Ghidra 0x130a30: UObject::PostLoad, then iterate Sequences (this+0x48) once per
	// entry calling FUN_103ca8f0(GetOuter()) to preload linked animation packages.
	// FUN_103ca8f0 = lazy package preload helper — forces load of the outer package
	// so any cross-referenced animation data is available before first use.
	// DIVERGENCE: FUN_103ca8f0 not called; the UE2 linker handles cross-ref loading.
	UObject::PostLoad();
}

IMPL_MATCH("Engine.dll", 0x10320f50)
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

IMPL_MATCH("Engine.dll", 0x1031c650)
FMeshAnimSeq * UMeshAnimation::GetAnimSeq(FName Name)
{
	// Ghidra 0x1c650 (80b): linear search through Sequences TArray (this+0x48, stride 0x2C).
	// Compares FName at element+0, re-fetches count each iteration. Returns element ptr or NULL.
	FArray* seqArr = (FArray*)((BYTE*)this + 0x48);
	INT count = seqArr->Num();
	if (count > 0)
	{
		INT byteOff = 0, idx = 0;
		do
		{
			if (Name == *(FName*)(*(INT*)seqArr + byteOff))
				return (FMeshAnimSeq*)(idx * 0x2C + *(INT*)seqArr);
			idx++;
			byteOff += 0x2C;
			count = seqArr->Num();
		} while (idx < count);
	}
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x1031c6a0)
MotionChunk * UMeshAnimation::GetMovement(FName Name)
{
	// Ghidra 0x1c6a0 (93b): searches Sequences (this+0x48, stride 0x2C) for FName match.
	// Returns MotionChunk at Movements.Data (*(this+0x3C)) + index*0x58 (stride confirmed 88b).
	FArray* seqArr = (FArray*)((BYTE*)this + 0x48);
	INT count = seqArr->Num();
	if (count > 0)
	{
		INT byteOff = 0, idx = 0;
		do
		{
			if (Name == *(FName*)(*(INT*)seqArr + byteOff))
				return (MotionChunk*)(idx * 0x58 + *(INT*)((BYTE*)this + 0x3C));
			idx++;
			byteOff += 0x2C;
			count = seqArr->Num();
		} while (idx < count);
	}
	return NULL;
}

IMPL_DIVERGE("calls FUN_1032b9b0 (unresolved digest struct initializer) after GMalloc alloc; replaced with appMalloc; retail 0x1033a490 (139b)")
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
IMPL_DIVERGE("reconstructed from Ghidra 0x10474da0 (409b); section-building logic approximated")
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

IMPL_DIVERGE("calls FUN_103c7240/FUN_10438000/FUN_1043f770/FUN_1032d5f0 (unresolved TArray serializers at +0xF4/+0x10C/+0x118/+0x100); retail 0x104758b0 (424b)")
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

IMPL_MATCH("Engine.dll", 0x10314e10)
UClass * UVertMesh::MeshGetInstanceClass()
{
	return UVertMeshInstance::StaticClass();
}

IMPL_DIVERGE("calls FUN_103ca8f0 (unresolved lazy package preload helper) per AnimSets entry; retail 0x10472830 (124b)")
void UVertMesh::PostLoad()
{
	// Ghidra 0x172830: UObject::PostLoad, then iterate AnimSets (this+0x118) once per
	// entry calling FUN_103ca8f0(GetOuter()) to preload linked animation packages.
	// FUN_103ca8f0 = lazy package preload helper (same as UMeshAnimation::PostLoad).
	// DIVERGENCE: FUN_103ca8f0 not called; the UE2 linker handles cross-ref loading.
	UObject::PostLoad();
}

IMPL_MATCH("Engine.dll", 0x1042f800)
FBox UVertMesh::GetRenderBoundingBox(AActor const * Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingBox on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingBox(Owner);
}

IMPL_MATCH("Engine.dll", 0x1042f830)
FSphere UVertMesh::GetRenderBoundingSphere(AActor const * Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingSphere on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingSphere(Owner);
}


// --- USkeletalMesh ---
IMPL_MATCH("Engine.dll", 0x1042f410)
void USkeletalMesh::m_bLoadLbpFile(FString FileName)
{
	// Retail: 0x12f410. Extracts raw TCHAR* from FString and initialises
	// the CBoneDescData bone descriptor at this+0x294 from the LBP file.
	CBoneDescData* boneDesc = (CBoneDescData*)((BYTE*)this + 0x294);
	boneDesc->fn_bInitFromLbpFile(*FileName);
}

IMPL_DIVERGE("reconstructed from Ghidra 0x10438890 (337b); AddUnique loop approximated")
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

IMPL_DIVERGE("retail 0x10436770 (865b) applies bone-to-world transform; requires GetTagCoords")
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

IMPL_MATCH("Engine.dll", 0x10440640)
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

IMPL_EMPTY("Ghidra 0x1651d0 confirms function body is empty")
void USkeletalMesh::NormalizeInfluences(int)
{
	guard(USkeletalMesh::NormalizeInfluences);
	// Ghidra 0x1651d0: shared empty-stub address — function body is empty.
	unguard;
}

IMPL_DIVERGE("SEH frame and FUN_10324640 destructor differ; Ghidra 0x10441560 (634b): body implemented")
void USkeletalMesh::CalculateNormals(TArray<FVector>& Normals, int param2)
{
	guard(USkeletalMesh::CalculateNormals);
	// Ghidra 0x141560: if Normals array is non-empty, return immediately.
	// Otherwise accumulate per-face cross-product normals into a temp array, then
	// normalize each vertex normal and optionally (param2 != 0) add it to the vertex
	// position as a displacement.
	// DIVERGENCE: SEH frame differs; FUN_10324640 (temp-array destructor thunk) differs.
	if (Normals.Num() != 0) return;

	FArray* vertArr = (FArray*)((BYTE*)this + 0x1b8);
	INT vertCount = vertArr->Num();
	if (vertCount == 0) return;

	// Allocate temp per-vertex normal accumulation buffer (zeroed FVectors).
	// Ghidra: FArray::AddZeroed(local_44, 0xc, iVar1) where iVar1 = vertCount.
	TArray<FVector> tempNormals;
	tempNormals.AddZeroed(vertCount);

	BYTE* vertData = (BYTE*)*(INT*)vertArr;          // position array, stride 0xC
	FArray* faceArr = (FArray*)((BYTE*)this + 0xac);
	INT faceCount = faceArr->Num();
	BYTE* faceData = (BYTE*)*(INT*)faceArr;          // face array, stride 8

	// Face loop: accumulate face-normal contributions per vertex.
	// Each face entry is 8 bytes: 3 x uint16 vertex indices at byte offsets 0, 2, 4.
	// Ghidra: (iVar2 + iVar1*4)*2 where iVar2=0,1,2 gives byte offsets 0,2,4 within face iVar1.
	for (INT fi = 0; fi < faceCount; fi++)
	{
		WORD vi0 = *(WORD*)(faceData + fi * 8 + 0);
		WORD vi1 = *(WORD*)(faceData + fi * 8 + 2);
		WORD vi2 = *(WORD*)(faceData + fi * 8 + 4);

		// Vertex positions: stride 0xC = sizeof(FVector)
		BYTE* pv0 = vertData + vi0 * 0xC;
		BYTE* pv1 = vertData + vi1 * 0xC;
		BYTE* pv2 = vertData + vi2 * 0xC;
		FLOAT p0x = *(FLOAT*)(pv0 + 0); FLOAT p0y = *(FLOAT*)(pv0 + 4); FLOAT p0z = *(FLOAT*)(pv0 + 8);
		FLOAT p1x = *(FLOAT*)(pv1 + 0); FLOAT p1y = *(FLOAT*)(pv1 + 4); FLOAT p1z = *(FLOAT*)(pv1 + 8);
		FLOAT p2x = *(FLOAT*)(pv2 + 0); FLOAT p2y = *(FLOAT*)(pv2 + 4); FLOAT p2z = *(FLOAT*)(pv2 + 8);

		// edge1 = p2 - p0 (local_5c/58/54 in Ghidra)
		// edge2 = p0 - p1 (local_68/64/60 in Ghidra)
		// cross = edge2 ^ edge1  (Ghidra: FVector::operator^(this=&local_68, ...) with this=edge2)
		FLOAT e1x = p2x - p0x, e1y = p2y - p0y, e1z = p2z - p0z;
		FLOAT e2x = p0x - p1x, e2y = p0y - p1y, e2z = p0z - p1z;
		FLOAT cx = e2y * e1z - e2z * e1y;
		FLOAT cy = e2z * e1x - e2x * e1z;
		FLOAT cz = e2x * e1y - e2y * e1x;

		tempNormals(vi0).X += cx; tempNormals(vi0).Y += cy; tempNormals(vi0).Z += cz;
		tempNormals(vi1).X += cx; tempNormals(vi1).Y += cy; tempNormals(vi1).Z += cz;
		tempNormals(vi2).X += cx; tempNormals(vi2).Y += cy; tempNormals(vi2).Z += cz;
	}

	// Resize output array and write normalised results.
	// Ghidra: FArray::Add(param_1, vertCount, 0xC) then per-vertex normalize + optional blend.
	Normals.Add(vertCount);
	for (INT vi = 0; vi < vertCount; vi++)
	{
		FVector& n = tempNormals(vi);
		FLOAT sqLen = n.SizeSquared();
		// Ghidra: appSqrt(sqLen + 0.001) used as divisor; avoids zero-length normals.
		FLOAT invLen = (FLOAT)(1.0 / appSqrt((DOUBLE)(sqLen + 0.001f)));
		FLOAT nx = n.X * invLen, ny = n.Y * invLen, nz = n.Z * invLen;

		if (param2 != 0)
		{
			// Ghidra: when param2 != 0, the normalised vector is added to the vertex
			// position (this+0x1b8) as a displacement, then stored to Normals.
			BYTE* pv = vertData + vi * 0xC;
			nx += *(FLOAT*)(pv + 0);
			ny += *(FLOAT*)(pv + 4);
			nz += *(FLOAT*)(pv + 8);
		}

		Normals(vi).X = nx;
		Normals(vi).Y = ny;
		Normals(vi).Z = nz;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10435bb0)
void USkeletalMesh::ClearAttachAliases()
{
	// Retail: 0x135bb0. Empties the three attach alias arrays.
	// Alias names at this+0x2D0 (stride 4), alias targets at this+0x2DC (stride 4),
	// alias coord data at this+0x2E8 (stride 0x30).
	((TArray<INT>*)((BYTE*)this + 0x2D0))->Empty();
	((TArray<INT>*)((BYTE*)this + 0x2DC))->Empty();
	((TArray<INT>*)((BYTE*)this + 0x2E8))->Empty();
}

IMPL_MATCH("Engine.dll", 0x10440780)
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

IMPL_DIVERGE("progressive mesh reduction helpers unresolved; retail 0x10442d40 (1388b)")
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

IMPL_DIVERGE("LOD entry constructor FUN_1043f4c0 and stream-copy helpers unresolved; retail 0x10442970 (925b)")
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

IMPL_MATCH("Engine.dll", 0x1042f6c0)
int USkeletalMesh::UseCylinderCollision(const AActor* Actor)
{
	// Retail (18b, RVA 0x12F6C0): returns 0 only for ragdoll actors (Physics byte at Actor+0x2C == 0x0E = PHYS_KarmaRagDoll).
	// PHYS_KarmaRagDoll = 14/0x0E. All other physics modes use cylinder collision.
	return Actor->Physics != PHYS_KarmaRagDoll;
}

IMPL_DIVERGE("skeletal hit-cylinder path unresolved; retail 0x1043c980 (537b)")
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

IMPL_DIVERGE("calls FUN_10321a80/FUN_104378f0/FUN_10415600/FUN_10321870 (unresolved bone/LOD TArray serializers); retail 0x1043ffb0 (746b)")
void USkeletalMesh::Serialize(FArchive& Ar)
{
	// Retail: calls ULodMesh::Serialize (which calls UMesh::Serialize) then serializes bone ref pose (+0x1B8),
	// bone array (+0x19C), default anim ref (+0x1DC), vertex inflations, LOD arrays etc.
	// NOTE: USkeletalMesh inherits from UMesh (not ULodMesh) so we call UMesh::Serialize directly.
	// DIVERGENCE: bone/LOD TArray serializers unresolved; base-class data is preserved correctly.
	UMesh::Serialize(Ar);
}

IMPL_DIVERGE("Karma ragdoll line check pending MeSDK decompilation; retail 0x104354f0 (729b)")
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

IMPL_MATCH("Engine.dll", 0x10440350)
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

IMPL_MATCH("Engine.dll", 0x1042f5d0)
void USkeletalMesh::Destroy()
{
	// Retail: 0x1042f5d0. Just calls UObject::Destroy (no custom cleanup beyond base class).
	UObject::Destroy();
}

IMPL_MATCH("Engine.dll", 0x1042f6e0)
FBox USkeletalMesh::GetCollisionBoundingBox(const AActor* Owner) const
{
	// Retail: 0x12f6e0. Delegates to UPrimitive::GetCollisionBoundingBox.
	return UPrimitive::GetCollisionBoundingBox(Owner);
}

IMPL_MATCH("Engine.dll", 0x1042f800)
FBox USkeletalMesh::GetRenderBoundingBox(const AActor* Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingBox on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingBox(Owner);
}

IMPL_MATCH("Engine.dll", 0x1042f830)
FSphere USkeletalMesh::GetRenderBoundingSphere(const AActor* Owner)
{
	// Retail: 33b. MeshGetInstance(Owner) then call GetRenderBoundingSphere on the instance.
	return MeshGetInstance(Owner)->GetRenderBoundingSphere(Owner);
}


// --- USkeletalMesh ---
IMPL_DIVERGE("stream-clear vtable calls and per-LOD copy loops unresolved; retail 0x10441820 (1752b)")
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

IMPL_MATCH("Engine.dll", 0x104436b0)
int USkeletalMesh::RenderPreProcess()
{
	guard(USkeletalMesh::RenderPreProcess);
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10314c00)
UClass * USkeletalMesh::MeshGetInstanceClass()
{
	return USkeletalMeshInstance::StaticClass();
}

IMPL_DIVERGE("vtable stream-clear at this+0xF4 unresolved; retail 0x1042f4b0 (232b): LOD check and auto-generation added")
void USkeletalMesh::PostLoad()
{
	// Ghidra 0x12f4b0: UObject::PostLoad, then if LOD version (+0x5C) < 2 call the first
	// vtable slot of the stream object at this+0xF4 (a Clear/Reset operation), then call
	// ReconstructRawMesh(). If the LOD models array (this+0x1AC) is empty, log a warning
	// and auto-generate 4 LOD levels at ratios 1.0, 0.7, 0.35, 0.1.
	// DIVERGENCE: vtable call on stream at this+0xF4 (stream clear before reconstruction)
	// is unresolved and skipped — the vtable layout for the render-stream objects is not
	// yet determined. ReconstructRawMesh() itself is also IMPL_DIVERGE (empty stub).
	UObject::PostLoad();
	if (*(INT*)((BYTE*)this + 0x5C) < 2)
	{
		// Retail: (*(code**)**(undefined4**)(this+0xF4))() — unresolved stream clear.
		// DIVERGENCE: stream clear call skipped; vtable layout unknown.
		ReconstructRawMesh();
	}
	if (((FArray*)((BYTE*)this + 0x1AC))->Num() == 0)
	{
		// Ghidra: logs warning then calls GenerateLodModel 4 times.
		GLog->Logf(TEXT(""));
		GenerateLodModel(0, 1.0f, 1.0f, 4, 0);
		GenerateLodModel(1, 0.7f, 0.5f, 1, 0);
		GenerateLodModel(2, 0.35f, 0.4f, 1, 0);
		GenerateLodModel(3, 0.1f, 0.17f, 1, 0);
	}
}


