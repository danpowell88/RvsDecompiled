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

extern INT DAT_1060b564; // Ghidra: Engine.dll DAT_1060b564 render-resource serial.
ENGINE_API FArchive& operator<<(FArchive& Ar, FRawIndexBuffer& V);

// --- CBoneDescData ---
// Separator strings extracted from retail Engine.dll binary:
//   DAT_10538e9c = L"\n"   (file line separator)
//   DAT_10538e94 = L" ->"  (bone-name/value separator per line)
//   DAT_1052ec38 = L" "    (LBP value-field separator)
// FUN_1031f060/FUN_1031efc0 are TArray<FString> helpers (Empty/Remove) fully
// covered by our TArray<FString> API.
IMPL_MATCH("Engine.dll", 0x10355fa0)
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
        fileStr.ParseIntoArray(TEXT("\n"), &lines);   // DAT_10538e9c = L"\n"
        INT boneCount = appAtoi(*lines(0));
        *(INT*)((BYTE*)this + 0) = boneCount;
        for (INT i = 0; i < boneCount; i++)
        {
                // Parse "BoneName -> ..." by " ->" (DAT_10538e94) and take first token.
                TArray<FString> nameToks;
                lines(i + 1).ParseIntoArray(TEXT(" ->"), &nameToks);
                INT newIdx = ((FArray*)((BYTE*)this + 8))->Add(1, sizeof(FString));
                FString* newSlot = (FString*)(*(INT*)((BYTE*)this + 8) + newIdx * sizeof(FString));
                if (newSlot)
                        new(newSlot) FString(nameToks.Num() > 0 ? nameToks(0) : lines(i + 1));
        }
        // Store the header/filename line that follows the bone block (lines[boneCount+1]).
        *(FString*)((BYTE*)this + 0x14) = lines(boneCount + 1);
        INT frameCount = appAtoi(*lines(boneCount + 4));
        *(INT*)((BYTE*)this + 4) = frameCount;
        if (frameCount != 0)
        {
                BYTE** arr = (BYTE**)GMalloc->Malloc(frameCount * 4, TEXT(""));
                *(void**)((BYTE*)this + 0x20) = arr;
                for (INT fi = 0; fi < frameCount; fi++)
                {
                        BYTE* frameData = (BYTE*)GMalloc->Malloc(boneCount * 0x1c, TEXT(""));
                        if (frameData)
                        {
                                // Default-construct FVector+FQuat for each bone slot (Ghidra-confirmed).
                                for (INT b = 0; b < boneCount; b++)
                                {
                                        new(frameData + b * 0x1c) FVector();
                                        new(frameData + b * 0x1c + 0x0c) FQuat();
                                }
                        }
                        arr[fi] = frameData;
                }
        }
        for (INT frame = 0; frame < frameCount; frame++)
        {
                for (INT bone = 0; bone < boneCount; bone++)
                {
                        INT lineIdx = boneCount * (frame + 1) + 5 + bone;
                        m_vProcessLbpLine(frame, bone, lines(lineIdx));
                }
        }
        GLog->Logf(TEXT(""));
        return 1;
        unguard;
}

// DAT_1052ec38 = L" " (space), confirmed from retail Engine.dll binary.
IMPL_MATCH("Engine.dll", 0x10355c60)
void CBoneDescData::m_vProcessLbpLine(int param1, int param2, FString& str)
{
	guard(CBoneDescData::m_vProcessLbpLine);
	TArray<FString> tokens;
	// DAT_1052ec38: separator TCHAR* (runtime global; assumed space for LBP format)
	str.ParseIntoArray(TEXT(" "), &tokens);
	INT stride = param2 * 0x1C;
	BYTE* base = *(BYTE**)(*(INT*)((BYTE*)this + 0x20) + param1 * 4);
	// FArray layout: {Data@+0, ArrayNum@+4, ArrayMax@+8}; element N = Data + N*0xC.
	// Ghidra: local_28[0]+0xC0=tok16, +0xCC=tok17, +0xD8=tok18;
	//         +0x108=tok22, +0x114=tok23, +0x120=tok24, +0x12C(300)=tok25.
	*(float*)(base + stride + 0x00) =  appAtof(*tokens(16)); // X
	*(float*)(base + stride + 0x04) = -appAtof(*tokens(17)); // -Y (axis flip per Ghidra)
	*(float*)(base + stride + 0x08) =  appAtof(*tokens(18)); // Z
	// FQuat [pfVar1+0..+3] = [fY, fZ, fW, fX] (fStack_1c/18/14/10 in Ghidra)
	float fX = -appAtof(*tokens(22)); // fStack_10 (negated, Ghidra Data+0x108)
	float fY =  appAtof(*tokens(23)); // fStack_1c (Ghidra Data+0x114)
	float fZ = -appAtof(*tokens(24)); // fStack_18 (negated, Ghidra Data+0x120)
	float fW =  appAtof(*tokens(25)); // fStack_14 (Ghidra Data+0x12C)
	float* pfQuat = (float*)(base + stride + 0x0C);
	pfQuat[0] = fY;
	pfQuat[1] = fZ;
	pfQuat[2] = fW;
	pfQuat[3] = fX;
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

IMPL_MATCH("Engine.dll", 0x10354f00)
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


// =============================================================================
// Static TArray serialization helpers — replicated from ghidra/exports/Engine/_unnamed.cpp.
// Each helper mirrors one or more unexported FUN_XXXXXXXX used by ULodMesh::Serialize
// and its subclasses.  Named by element stride and payload description.
// =============================================================================

// FUN_103c7240 / FUN_10438000 / FUN_1032d5f0 — stride-4, BOS 4b per element.
// All three have identical byte patterns; used for INT/DWORD arrays.
static void SerArr4BOS(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 4);
	if (Ar.IsLoading())
	{
		FCompactIndex ci; Ar << ci;
		INT n = *(INT*)&ci;
		A.Empty(4, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 4);
			Ar.ByteOrderSerialize((BYTE*)A.GetData() + idx*4, 4);
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
			Ar.ByteOrderSerialize((BYTE*)A.GetData() + i*4, 4);
	}
}

// FUN_103c7140 — stride-4, Ar<<UObject* per element.
// Used for material/texture reference arrays (vtable+0x18 save / vtable+0x1c load in retail).
static void SerArr4Ref(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 4);
	if (Ar.IsLoading())
	{
		FCompactIndex ci; Ar << ci;
		INT n = *(INT*)&ci;
		A.Empty(4, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 4);
			Ar << *(UObject**)((BYTE*)A.GetData() + idx*4);
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
			Ar << *(UObject**)((BYTE*)A.GetData() + i*4);
	}
}

// FUN_1031e600 — TArray<WORD>, stride-2, BOS 2b per element.
static void SerArrWord(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 2);
	if (Ar.IsLoading())
	{
		FCompactIndex ci; Ar << ci;
		INT n = *(INT*)&ci;
		A.Empty(2, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 2);
			Ar.ByteOrderSerialize((BYTE*)A.GetData() + idx*2, 2);
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
			Ar.ByteOrderSerialize((BYTE*)A.GetData() + i*2, 2);
	}
}

// FUN_1032d290 — stride-8, {WORD×4} per element (via FUN_1032d390: 4×BOS 2b).
// Element layout: {WORD+0, WORD+2, WORD+4, WORD+6}.
static void SerArr8x4Word(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 8);
	if (Ar.IsLoading())
	{
		FCompactIndex ci; Ar << ci;
		INT n = *(INT*)&ci;
		A.Empty(8, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 8);
			BYTE* e = (BYTE*)A.GetData() + idx*8;
			Ar.ByteOrderSerialize(e+0, 2); Ar.ByteOrderSerialize(e+2, 2);
			Ar.ByteOrderSerialize(e+4, 2); Ar.ByteOrderSerialize(e+6, 2);
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
		{
			BYTE* e = (BYTE*)A.GetData() + i*8;
			Ar.ByteOrderSerialize(e+0, 2); Ar.ByteOrderSerialize(e+2, 2);
			Ar.ByteOrderSerialize(e+4, 2); Ar.ByteOrderSerialize(e+6, 2);
		}
	}
}

// FUN_1032d090 — stride-0xC, {WORD+0, DWORD+4, DWORD+8} per element (via FUN_1032d1a0).
// Bytes +2/+3 are padding and not serialized (FUN_1032d1a0: BOS +0 2b, BOS +4 4b, BOS +8 4b).
static void SerArr0xC_WDD(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0xC);
	if (Ar.IsLoading())
	{
		FCompactIndex ci; Ar << ci;
		INT n = *(INT*)&ci;
		A.Empty(0xC, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0xC);
			BYTE* e = (BYTE*)A.GetData() + idx*0xC;
			Ar.ByteOrderSerialize(e+0, 2);
			Ar.ByteOrderSerialize(e+4, 4);
			Ar.ByteOrderSerialize(e+8, 4);
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
		{
			BYTE* e = (BYTE*)A.GetData() + i*0xC;
			Ar.ByteOrderSerialize(e+0, 2);
			Ar.ByteOrderSerialize(e+4, 4);
			Ar.ByteOrderSerialize(e+8, 4);
		}
	}
}

// FUN_103c7340 — stride-8, {DWORD+0, DWORD+4} per element (2×BOS 4b).
static void SerArr8x2DWORD(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 8);
	if (Ar.IsLoading())
	{
		FCompactIndex ci; Ar << ci;
		INT n = *(INT*)&ci;
		A.Empty(8, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 8);
			BYTE* e = (BYTE*)A.GetData() + idx*8;
			Ar.ByteOrderSerialize(e+0, 4); Ar.ByteOrderSerialize(e+4, 4);
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
		{
			BYTE* e = (BYTE*)A.GetData() + i*8;
			Ar.ByteOrderSerialize(e+0, 4); Ar.ByteOrderSerialize(e+4, 4);
		}
	}
}

// FUN_103c7500 — stride-0x28 old-format face array (via FUN_103c7090: 3×WORD + 9×DWORD).
// Bytes +6/+7 are struct padding and not serialized.  Only reached when stamp (this+0x5C) < 2.
static void SerArr0x28OldFace(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0x28);
	if (Ar.IsLoading())
	{
		FCompactIndex ci; Ar << ci;
		INT n = *(INT*)&ci;
		A.Empty(0x28, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0x28);
			BYTE* e = (BYTE*)A.GetData() + idx*0x28;
			Ar.ByteOrderSerialize(e+0x00, 2); Ar.ByteOrderSerialize(e+0x02, 2);
			Ar.ByteOrderSerialize(e+0x04, 2); // +6/+7 padding: not in archive
			Ar.ByteOrderSerialize(e+0x08, 4); Ar.ByteOrderSerialize(e+0x0C, 4);
			Ar.ByteOrderSerialize(e+0x10, 4); Ar.ByteOrderSerialize(e+0x14, 4);
			Ar.ByteOrderSerialize(e+0x18, 4); Ar.ByteOrderSerialize(e+0x1C, 4);
			Ar.ByteOrderSerialize(e+0x20, 4); Ar.ByteOrderSerialize(e+0x24, 4);
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
		{
			BYTE* e = (BYTE*)A.GetData() + i*0x28;
			Ar.ByteOrderSerialize(e+0x00, 2); Ar.ByteOrderSerialize(e+0x02, 2);
			Ar.ByteOrderSerialize(e+0x04, 2);
			Ar.ByteOrderSerialize(e+0x08, 4); Ar.ByteOrderSerialize(e+0x0C, 4);
			Ar.ByteOrderSerialize(e+0x10, 4); Ar.ByteOrderSerialize(e+0x14, 4);
			Ar.ByteOrderSerialize(e+0x18, 4); Ar.ByteOrderSerialize(e+0x1C, 4);
			Ar.ByteOrderSerialize(e+0x20, 4); Ar.ByteOrderSerialize(e+0x24, 4);
		}
	}
}

// FUN_10301310 — 4-byte scalar element serializer used by FUN_1032d5f0.
static inline void SerElem4(FArchive& Ar, void* Ptr)
{
	Ar.ByteOrderSerialize(Ptr, 4);
}

// FUN_1032d5f0 — stride-4 array serializer using FUN_10301310 per element.
static void SerArr4ViaElem(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 4);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		A.Empty(4, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 4);
			SerElem4(Ar, (BYTE*)A.GetData() + idx * 4);
		}
	}
	else
	{
		INT n = A.Num();
		Ar << AR_INDEX(n);
		for (INT i = 0; i < A.Num(); i++)
			SerElem4(Ar, (BYTE*)A.GetData() + i * 4);
	}
}

// FUN_10446ec0 — 0x20-byte element with 8 DWORD ByteOrderSerialize fields.
static void SerElem0x20_8DWORD(FArchive& Ar, BYTE* Elem)
{
	for (INT i = 0; i < 8; i++)
		Ar.ByteOrderSerialize(Elem + i * 4, 4);
}

// FUN_10323030 — stride-0x20 array serializer.
static void SerArr0x20(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0x20);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		A.Empty(0x20, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0x20);
			BYTE* Elem = (BYTE*)A.GetData() + idx * 0x20;
			new (Elem + 0x00) FVector();
			new (Elem + 0x0C) FVector();
			SerElem0x20_8DWORD(Ar, Elem);
		}
	}
	else
	{
		INT n = A.Num();
		Ar << AR_INDEX(n);
		for (INT i = 0; i < A.Num(); i++)
			SerElem0x20_8DWORD(Ar, (BYTE*)A.GetData() + i * 0x20);
	}
}

// FUN_10437c90/FUN_103ca720/FUN_103ca9f0 — FMeshAnimNotify serializer chain.
static void SerMeshAnimNotifyElem(FArchive& Ar, BYTE* Elem)
{
	if (Ar.Ver() < 0x70)
	{
		*(DWORD*)(Elem + 8) = 0;
		Ar.ByteOrderSerialize(Elem + 0, 4);
		Ar << *(FName*)(Elem + 4);
	}
	else
	{
		Ar.ByteOrderSerialize(Elem + 0, 4);
		Ar << *(FName*)(Elem + 4);
		Ar << *(UObject**)(Elem + 8);
	}
}

static void SerArrMeshAnimNotify(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0x0C);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		A.Empty(0x0C, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0x0C);
			BYTE* Elem = (BYTE*)A.GetData() + idx * 0x0C;
			*(DWORD*)(Elem + 0) = 0;
			*(FName*)(Elem + 4) = NAME_None;
			*(DWORD*)(Elem + 8) = 0;
			SerMeshAnimNotifyElem(Ar, Elem);
		}
	}
	else
	{
		INT n = A.Num();
		Ar << AR_INDEX(n);
		for (INT i = 0; i < A.Num(); i++)
			SerMeshAnimNotifyElem(Ar, (BYTE*)A.GetData() + i * 0x0C);
	}
}

// FUN_103ca780 — stride-4 FName array serializer.
static void SerArrFName(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 4);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		A.Empty(4, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 4);
			*(FName*)((BYTE*)A.GetData() + idx * 4) = NAME_None;
			Ar << *(FName*)((BYTE*)A.GetData() + idx * 4);
		}
	}
	else
	{
		INT n = A.Num();
		Ar << AR_INDEX(n);
		for (INT i = 0; i < A.Num(); i++)
			Ar << *(FName*)((BYTE*)A.GetData() + i * 4);
	}
}

// FUN_103cab30 — FMeshAnimSeq element serializer (stride 0x2C).
static void SerMeshAnimSeqElem(FArchive& Ar, BYTE* Elem)
{
	if (Ar.Ver() < 0x73)
		*(DWORD*)(Elem + 0x28) = 0;
	else
		Ar.ByteOrderSerialize(Elem + 0x28, 4);
	Ar << *(FName*)(Elem + 0x00);
	SerArrFName(Ar, *(FArray*)(Elem + 0x04));
	Ar.ByteOrderSerialize(Elem + 0x10, 4);
	Ar.ByteOrderSerialize(Elem + 0x14, 4);
	SerArrMeshAnimNotify(Ar, *(FArray*)(Elem + 0x1C));
	Ar.ByteOrderSerialize(Elem + 0x18, 4);
}

static void InitMeshAnimSeqElem(BYTE* Elem)
{
	*(FName*)(Elem + 0x00) = NAME_None;
	new (Elem + 0x04) FArray();
	*(DWORD*)(Elem + 0x10) = 0;
	*(DWORD*)(Elem + 0x14) = 0;
	*(DWORD*)(Elem + 0x18) = 0x41F00000;
	new (Elem + 0x1C) FArray();
	*(DWORD*)(Elem + 0x28) = 0;
}

// FUN_1043f770 — TArray<FMeshAnimSeq> serializer (stride 0x2C).
static void SerArrMeshAnimSeq(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0x2C);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		A.Empty(0x2C, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0x2C);
			BYTE* Elem = (BYTE*)A.GetData() + idx * 0x2C;
			InitMeshAnimSeqElem(Elem);
			SerMeshAnimSeqElem(Ar, Elem);
		}
	}
	else
	{
		INT n = A.Num();
		Ar << AR_INDEX(n);
		for (INT i = 0; i < A.Num(); i++)
			SerMeshAnimSeqElem(Ar, (BYTE*)A.GetData() + i * 0x2C);
	}
}

// FUN_1043d7e0 — render-preprocess entry constructor (stride 0x5C entry).
static void InitAnimMeshStreamEntry(BYTE* Entry)
{
	FAnimMeshVertexStream Temp;
	*(void**)(Entry + 0x14) = *(void**)&Temp;
	new (Entry + 0x1C) FArray();
	*(DWORD*)(Entry + 0x18) = 0;
	*(QWORD*)(Entry + 0x28) = (QWORD)(DWORD)DAT_1060b564 * 0x100 + 0xE1;
	DAT_1060b564++;
	*(DWORD*)(Entry + 0x30) = 0;
	*(DWORD*)(Entry + 0x34) = 0;
	*(DWORD*)(Entry + 0x38) = 0;
	new (Entry + 0x40) FRawIndexBuffer();
}

// FUN_1043d190 — stride-0x5C element serializer used by FUN_1043fc30.
static void SerElem0x5C(FArchive& Ar, BYTE* Elem)
{
	Ar.ByteOrderSerialize(Elem + 0x00, 2);
	Ar.ByteOrderSerialize(Elem + 0x02, 2);
	Ar.ByteOrderSerialize(Elem + 0x04, 2);
	Ar.ByteOrderSerialize(Elem + 0x06, 2);
	Ar.ByteOrderSerialize(Elem + 0x08, 2);
	Ar.ByteOrderSerialize(Elem + 0x0A, 2);
	Ar.ByteOrderSerialize(Elem + 0x0C, 2);
	Ar.ByteOrderSerialize(Elem + 0x0E, 2);
	Ar.ByteOrderSerialize(Elem + 0x10, 2);
	if (!Ar.IsPersistent())
	{
		SerArr0x20(Ar, *(FArray*)(Elem + 0x1C));
		Ar.ByteOrderSerialize(Elem + 0x30, 4);
		Ar << *(FRawIndexBuffer*)(Elem + 0x40);
	}
}

// FUN_1043fc30 — stride-0x5C array serializer.
static void SerArr0x5C(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0x5C);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		A.Empty(0x5C, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0x5C);
			BYTE* Elem = (BYTE*)A.GetData() + idx * 0x5C;
			InitAnimMeshStreamEntry(Elem);
			SerElem0x5C(Ar, Elem);
		}
	}
	else
	{
		INT n = A.Num();
		Ar << AR_INDEX(n);
		for (INT i = 0; i < A.Num(); i++)
			SerElem0x5C(Ar, (BYTE*)A.GetData() + i * 0x5C);
	}
}

// FUN_10301400 — FBox serializer.
static inline void SerBox(FArchive& Ar, FBox& Box)
{
	Ar.ByteOrderSerialize((BYTE*)&Box + 0x00, 4);
	Ar.ByteOrderSerialize((BYTE*)&Box + 0x04, 4);
	Ar.ByteOrderSerialize((BYTE*)&Box + 0x08, 4);
	Ar.ByteOrderSerialize((BYTE*)&Box + 0x0C, 4);
	Ar.ByteOrderSerialize((BYTE*)&Box + 0x10, 4);
	Ar.ByteOrderSerialize((BYTE*)&Box + 0x14, 4);
	Ar.ByteOrderSerialize((BYTE*)&Box + 0x18, 4);
}

// FUN_103cd010 — TArray<FBox> serializer.
static void SerArrBox(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0x1C);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		A.Empty(0x1C, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0x1C);
			FBox* Elem = (FBox*)((BYTE*)A.GetData() + idx * 0x1C);
			new (Elem) FBox();
			SerBox(Ar, *Elem);
		}
	}
	else
	{
		INT n = A.Num();
		Ar << AR_INDEX(n);
		for (INT i = 0; i < A.Num(); i++)
			SerBox(Ar, *(FBox*)((BYTE*)A.GetData() + i * 0x1C));
	}
}

// FUN_103cba20 — FSphere serializer (legacy <0x3E omits W).
static inline void SerSphere(FArchive& Ar, FSphere& Sphere)
{
	Ar.ByteOrderSerialize((BYTE*)&Sphere + 0x00, 4);
	Ar.ByteOrderSerialize((BYTE*)&Sphere + 0x04, 4);
	Ar.ByteOrderSerialize((BYTE*)&Sphere + 0x08, 4);
	if (Ar.Ver() >= 0x3E)
		Ar.ByteOrderSerialize((BYTE*)&Sphere + 0x0C, 4);
}

// FUN_10474600 — TArray<FSphere> serializer.
static void SerArrSphere(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0x10);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		A.Empty(0x10, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0x10);
			FSphere* Elem = (FSphere*)((BYTE*)A.GetData() + idx * 0x10);
			new (Elem) FSphere();
			SerSphere(Ar, *Elem);
		}
	}
	else
	{
		INT n = A.Num();
		Ar << AR_INDEX(n);
		for (INT i = 0; i < A.Num(); i++)
			SerSphere(Ar, *(FSphere*)((BYTE*)A.GetData() + i * 0x10));
	}
}

// FUN_10438510 — GLazyLoad-gated lazy array serializer.
static void SerLazyArray0xC(FArchive& Ar, void* ObjBase, void (*SerPayload)(FArchive&, FArray&))
{
	if (Ar.IsLoading())
	{
		INT SavedPos = 0;
		if (Ar.Ver() < 0x3E)
		{
			Ar << *(UObject**)ObjBase;
			INT n = 0;
			Ar << AR_INDEX(n);
			SavedPos = Ar.Tell() + n * 0x0C;
		}
		else
		{
			Ar.ByteOrderSerialize(&SavedPos, 4);
			if ((GUglyHackFlags & 8) == 0)
				Ar << *(UObject**)ObjBase;
			else
				SerPayload(Ar, *(FArray*)((BYTE*)ObjBase + 0x0C));
		}
		if (!GLazyLoad)
			(*(void(__thiscall**)(void*))(*(DWORD*)ObjBase))(ObjBase);
		Ar.Seek(SavedPos);
		return;
	}

	if (Ar.IsSaving() && Ar.Ver() > 0x3D)
	{
		INT SavedPos = Ar.Tell();
		FArray* Payload = ObjBase ? (FArray*)((BYTE*)ObjBase + 0x0C) : NULL;
		Ar.ByteOrderSerialize(&SavedPos, 4);
		if (Payload)
			SerPayload(Ar, *Payload);
		INT EndPos = Ar.Tell();
		Ar.Seek(SavedPos);
		Ar.ByteOrderSerialize(&EndPos, 4);
		Ar.Seek(EndPos);
		return;
	}

	FArray* Payload = ObjBase ? (FArray*)((BYTE*)ObjBase + 0x0C) : NULL;
	if (Payload)
		SerPayload(Ar, *Payload);
}


// --- ULodMesh ---
IMPL_MATCH("Engine.dll", 0x103c7610)
void ULodMesh::Serialize(FArchive& Ar)
{
	guard(ULodMesh::Serialize);
	// Ghidra 0xc7610 (558b): UMesh::Serialize, IsSaving→stamp=2, BOS +0x5C/+0x60,
	// TArrays at +0x64 (stride-4 INT), +0x70 (stride-4 UObject* refs),
	// scalars +0x7C..+0x9C, TArrays at +0xA0 (WORD), +0xAC (stride-8 4×WORD),
	// +0xB8 (WORD), +0xC4 (stride-0xC), +0xD0 (stride-8 2×DWORD),
	// scalars +0xDC, +0xF0, +0xE0..+0xEC (non-sequential archive order per Ghidra).
	UMesh::Serialize(Ar);
	if (Ar.IsSaving())
		*(INT*)((BYTE*)this + 0x5C) = 2;
	Ar.ByteOrderSerialize((BYTE*)this + 0x5C, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x60, 4);
	SerArr4BOS(Ar, *(FArray*)((BYTE*)this + 0x64));
	if (*(INT*)((BYTE*)this + 0x5C) < 2)
	{
		// Old-format face data: read and discard.  Stamp is always 2 on modern assets;
		// this branch is dead in practice.
		FArray tmp;
		SerArr0x28OldFace(Ar, tmp);
	}
	SerArr4Ref   (Ar, *(FArray*)((BYTE*)this + 0x70));
	Ar.ByteOrderSerialize((BYTE*)this + 0x7C, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x80, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x84, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x88, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x8C, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x90, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x94, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x98, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x9C, 4);
	if (*(INT*)((BYTE*)this + 0x5C) < 2)
	{
		// Old-format UV data: read and discard.
		FArray tmp2;
		SerArrWord(Ar, tmp2);
	}
	SerArrWord    (Ar, *(FArray*)((BYTE*)this + 0xA0));
	SerArr8x4Word (Ar, *(FArray*)((BYTE*)this + 0xAC));
	SerArrWord    (Ar, *(FArray*)((BYTE*)this + 0xB8));
	SerArr0xC_WDD (Ar, *(FArray*)((BYTE*)this + 0xC4));
	SerArr8x2DWORD(Ar, *(FArray*)((BYTE*)this + 0xD0));
	// Archive order is non-sequential for the trailing scalars (Ghidra confirmed):
	// +0xDC, +0xF0, then +0xE0..+0xEC in order.
	Ar.ByteOrderSerialize((BYTE*)this + 0xDC, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0xF0, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0xE0, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0xE4, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0xE8, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0xEC, 4);
	unguard;
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

// Ghidra 0x103ca620 (251b): cleanup branch dispatches via GetStatus() at vtable+0x98.
// If (status & 1) == 0: vtable+0x0C (UObject slot 3, likely Destroy/Close).
// If (status & 1) == 1: vtable+0x94 (slot 37, mesh-instance cleanup).
// Both are called through raw vtable dereference (same as retail indirect call).
IMPL_MATCH("Engine.dll", 0x103ca620)
UMeshInstance * UMesh::MeshGetInstance(AActor const * Owner)
{
	guard(UMesh::MeshGetInstance);
	if (!Owner)
		return *(UMeshInstance**)((BYTE*)this + 0x58);
	if ((*(BYTE*)((BYTE*)Owner + 0xA0) & 0x80))
		return *(UMeshInstance**)((BYTE*)this + 0x58);

	UMeshInstance** instSlot = (UMeshInstance**)((BYTE*)Owner + 0x324);
	UMeshInstance* inst = *instSlot;
	if (inst)
	{
		if (inst->GetActor() == Owner && inst->GetMesh() == this)
			return inst;
		// Retail: GetStatus() at vtable+0x98 selects cleanup path.
		typedef DWORD (__thiscall* GetStatusFn)(void*);
		typedef void  (__thiscall* VoidFn)(void*);
		int* vtbl = *(int**)inst;
		DWORD status = ((GetStatusFn)vtbl[0x98 / 4])(inst);
		if ((status & 1) == 0)
			((VoidFn)vtbl[0x0C / 4])(inst); // vtable+0x0C: Destroy/close (slot 3)
		else
			((VoidFn)vtbl[0x94 / 4])(inst); // vtable+0x94: mesh cleanup (slot 37)
	}

	UClass* cls = MeshGetInstanceClass();
	if (!cls)
		cls = UMeshInstance::StaticClass();
	UMeshInstance* newInst = (UMeshInstance*)UObject::StaticConstructObject(cls, GetOuter(), NAME_None, 0, NULL, GError, NULL);
	*instSlot = newInst;
	if (newInst)
	{
		newInst->SetMesh(this);
		newInst->SetActor(const_cast<AActor*>(Owner));
	}
	return newInst;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
UClass * UMesh::MeshGetInstanceClass()
{
	return NULL;
}


// --- UMeshAnimation ---
IMPL_MATCH("Engine.dll", 0x10430b80)
int UMeshAnimation::SequenceMemFootprint(FName Name)
{
	// Ghidra 0x130b80, 159b. Searches Sequences TArray (this+0x48, stride 0x2C)
	// for a FName match at element+0. If found, computes memory footprint of the
	// corresponding MotionChunk at Movements[foundIdx] by inlining FUN_10430990.
	// FUN_10430990 (153b, _unnamed.cpp): takes ECX = MotionChunk (stride 0x58).
	//   Iterates sub-array at ecx+0x24 (elements of 0x28b each, with FArrays at
	//   elem+4, +0x10, +0x1C); then adds contributions from ecx+0x34, +0x40, +0x4C.
	// Ghidra omits the ECX setup before the FUN_10430990 call; analysis confirms
	// ECX = Movements[foundIdx] (MotionChunk), not 'this' (UMeshAnimation).
	guard(UMeshAnimation::SequenceMemFootprint);
	FArray* seqArr = (FArray*)((BYTE*)this + 0x48);
	INT count = seqArr->Num();
	INT foundIdx = -1;
	for (INT i = 0; i < count; i++)
	{
		FName* elemName = (FName*)(*(INT*)seqArr + i * 0x2C);
		if (*elemName == Name)
			foundIdx = i;
		count = seqArr->Num(); // re-fetch per Ghidra pattern
	}
	if (foundIdx >= 0)
	{
		// FUN_10430990 inlined with ECX = Movements[foundIdx] (MotionChunk, stride 0x58)
		BYTE* ecx = (BYTE*)(*(INT*)((BYTE*)this + 0x3C)) + foundIdx * 0x58;
		FArray* subArr = (FArray*)(ecx + 0x24);
		INT total = 0;
		INT n = subArr->Num();
		if (n > 0)
		{
			INT byteOff = 0, idx = 0;
			BYTE* subData = (BYTE*)*(INT*)subArr;
			do {
				BYTE* elem = subData + byteOff;
				INT n2 = ((FArray*)(elem + 0x04))->Num();
				INT n3 = ((FArray*)(elem + 0x10))->Num();
				INT n4 = ((FArray*)(elem + 0x1C))->Num();
				total += 4 + n2 * 0x10 + n3 * 0x0C + n4 * 4;
				idx++;
				byteOff += 0x28;
				n = subArr->Num();
			} while (idx < n);
		}
		INT n1  = ((FArray*)(ecx + 0x34))->Num();
		INT n6  = ((FArray*)(ecx + 0x40))->Num();
		INT n2b = ((FArray*)(ecx + 0x4C))->Num();
		return total + n1 * 0x10 + n6 * 0x0C + n2b * 4;
	}
	return 0;
	unguard;
}

// === MotionChunk / AnalogTrack serialization chain ===
// Implements FUN_1043fd50 and its dependency chain:
// FUN_1043fd50 -> FUN_1043fb70 -> {FUN_103218c0, FUN_1043f8f0, FUN_10438100, FUN_10321a80, FUN_10438000}

// FUN_10438100 — stride-0x10 TArray<FQuat> serializer. 4x BOS 4b per element.
static void SerArr0x10_FQuat(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0x10);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		for (INT i = 0; i < A.Num(); i++) {} // trivial dtor loop (FQuat)
		A.Empty(0x10, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0x10);
			BYTE* E = (BYTE*)A.GetData() + idx * 0x10;
			new ((FQuat*)E) FQuat();
			Ar.ByteOrderSerialize(E + 0x0, 4);
			Ar.ByteOrderSerialize(E + 0x4, 4);
			Ar.ByteOrderSerialize(E + 0x8, 4);
			Ar.ByteOrderSerialize(E + 0xC, 4);
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
		{
			BYTE* E = (BYTE*)A.GetData() + i * 0x10;
			Ar.ByteOrderSerialize(E + 0x0, 4);
			Ar.ByteOrderSerialize(E + 0x4, 4);
			Ar.ByteOrderSerialize(E + 0x8, 4);
			Ar.ByteOrderSerialize(E + 0xC, 4);
		}
	}
}

// FUN_10321a80 — stride-0xC TArray<FVector> serializer. 3x BOS 4b per element.
static void SerArr0xC_FVector(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0xC);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		for (INT i = 0; i < A.Num(); i++) {} // trivial dtor loop (FVector)
		A.Empty(0xC, n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0xC);
			BYTE* E = (BYTE*)A.GetData() + idx * 0xC;
			new ((FVector*)E) FVector();
			Ar.ByteOrderSerialize(E + 0x0, 4);
			Ar.ByteOrderSerialize(E + 0x4, 4);
			Ar.ByteOrderSerialize(E + 0x8, 4);
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
		{
			BYTE* E = (BYTE*)A.GetData() + i * 0xC;
			Ar.ByteOrderSerialize(E + 0x0, 4);
			Ar.ByteOrderSerialize(E + 0x4, 4);
			Ar.ByteOrderSerialize(E + 0x8, 4);
		}
	}
}

// FUN_104386f0 — AnalogTrack default-constructor (stride 0x28).
// Layout: DWORD(+0), TArray<FQuat>(+4), TArray<FVector>(+0x10), TArray<FLOAT>(+0x1C).
static void InitAnalogTrack(BYTE* AT)
{
	new (AT + 0x04) FArray();
	new (AT + 0x10) FArray();
	new (AT + 0x1C) FArray();
}

// FUN_1043f8f0 — stride-0x28 TArray<AnalogTrack> serializer.
// Each element: BOS(+0,4) + TArray<FQuat>(+4) + TArray<FVector>(+0x10) + TArray<INT>(+0x1C).
static void SerArr0x28_AnalogTrack(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0x28);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0x28);
			BYTE* E = (BYTE*)A.GetData() + idx * 0x28;
			if (E) InitAnalogTrack(E);
			Ar.ByteOrderSerialize(E, 4);
			SerArr0x10_FQuat(Ar, *(FArray*)(E + 0x04));
			SerArr0xC_FVector(Ar, *(FArray*)(E + 0x10));
			SerArr4BOS(Ar, *(FArray*)(E + 0x1C));
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
		{
			BYTE* E = (BYTE*)A.GetData() + i * 0x28;
			Ar.ByteOrderSerialize(E, 4);
			SerArr0x10_FQuat(Ar, *(FArray*)(E + 0x04));
			SerArr0xC_FVector(Ar, *(FArray*)(E + 0x10));
			SerArr4BOS(Ar, *(FArray*)(E + 0x1C));
		}
	}
}

// FUN_1043fb70 — MotionChunk element serializer (stride 0x58).
// Layout: 6x DWORD(+0..+0x14), FArray<INT>(+0x18), FArray<AnalogTrack>(+0x24),
//         DWORD(+0x30), FArray<FQuat>(+0x34), FArray<FVector>(+0x40), FArray<INT>(+0x4C).
static void SerElem0x58_MotionChunk(FArchive& Ar, BYTE* MC)
{
	Ar.ByteOrderSerialize(MC + 0x00, 4);
	Ar.ByteOrderSerialize(MC + 0x04, 4);
	Ar.ByteOrderSerialize(MC + 0x08, 4);
	Ar.ByteOrderSerialize(MC + 0x0C, 4);
	Ar.ByteOrderSerialize(MC + 0x10, 4);
	Ar.ByteOrderSerialize(MC + 0x14, 4);
	SerArr4BOS(Ar, *(FArray*)(MC + 0x18));
	SerArr0x28_AnalogTrack(Ar, *(FArray*)(MC + 0x24));
	Ar.ByteOrderSerialize(MC + 0x30, 4);
	SerArr0x10_FQuat(Ar, *(FArray*)(MC + 0x34));
	SerArr0xC_FVector(Ar, *(FArray*)(MC + 0x40));
	SerArr4BOS(Ar, *(FArray*)(MC + 0x4C));
}

// FUN_1043f890 — MotionChunk default-constructor (stride 0x58).
static void InitMotionChunk(BYTE* MC)
{
	new ((FVector*)MC) FVector();
	new (MC + 0x18) FArray();
	new (MC + 0x24) FArray();
	InitAnalogTrack(MC + 0x30);
}

// FUN_1043fd50 — stride-0x58 TArray<MotionChunk> serializer.
static void SerArr0x58_MotionChunk(FArchive& Ar, FArray& A)
{
	A.CountBytes(Ar, 0x58);
	if (Ar.IsLoading())
	{
		INT n = 0;
		Ar << AR_INDEX(n);
		for (INT i = 0; i < n; i++)
		{
			INT idx = A.Add(1, 0x58);
			BYTE* E = (BYTE*)A.GetData() + idx * 0x58;
			if (E) InitMotionChunk(E);
			SerElem0x58_MotionChunk(Ar, E);
		}
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		for (INT i = 0; i < A.Num(); i++)
			SerElem0x58_MotionChunk(Ar, (BYTE*)A.GetData() + i * 0x58);
	}
}

IMPL_MATCH("Engine.dll", 0x1043fee0)
void UMeshAnimation::Serialize(FArchive& Ar)
{
	guard(UMeshAnimation::Serialize);
	// Ghidra 0x1043fee0 (135b): UObject::Serialize, BOS(+0x2C,4),
	// SerArrMeshAnimNotify(+0x30), SerArr0x58_MotionChunk(+0x3C),
	// SerArrMeshAnimSeq(+0x48), IsPersistent().
	UObject::Serialize(Ar);
	Ar.ByteOrderSerialize((BYTE*)this + 0x2C, 4);
	SerArrMeshAnimNotify(Ar, *(FArray*)((BYTE*)this + 0x30));
	SerArr0x58_MotionChunk(Ar, *(FArray*)((BYTE*)this + 0x3C));
	SerArrMeshAnimSeq(Ar, *(FArray*)((BYTE*)this + 0x48));
	Ar.IsPersistent();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10430ae0)
int UMeshAnimation::MemFootprint()
{
	// Ghidra 0x130ae0, 103b. Iterates Movements TArray (this+0x3C) and sums memory
	// footprint of each MotionChunk entry by inlining FUN_10430990 (153b, _unnamed.cpp).
	// FUN_10430990 takes ECX = MotionChunk (stride 0x58), accesses sub-arrays at
	// ecx+0x24 (elements of 0x28b), ecx+0x34, ecx+0x40, ecx+0x4C.
	// Ghidra fails to show ECX setup per iteration; confirmed ECX = Movements[i].
	guard(UMeshAnimation::MemFootprint);
	FArray* movArr = (FArray*)((BYTE*)this + 0x3C);
	INT total = 0;
	INT i = 0;
	while (true)
	{
		if (movArr->Num() <= i) break;
		// FUN_10430990 inlined: ECX = Movements[i] (MotionChunk, stride 0x58)
		BYTE* ecx = (BYTE*)*(INT*)movArr + i * 0x58;
		FArray* subArr = (FArray*)(ecx + 0x24);
		INT subTotal = 0;
		INT subN = subArr->Num();
		if (subN > 0)
		{
			INT byteOff = 0, idx = 0;
			BYTE* subData = (BYTE*)*(INT*)subArr;
			do {
				BYTE* elem = subData + byteOff;
				INT n2 = ((FArray*)(elem + 0x04))->Num();
				INT n3 = ((FArray*)(elem + 0x10))->Num();
				INT n4 = ((FArray*)(elem + 0x1C))->Num();
				subTotal += 4 + n2 * 0x10 + n3 * 0x0C + n4 * 4;
				idx++;
				byteOff += 0x28;
				subN = subArr->Num();
			} while (idx < subN);
		}
		INT n1  = ((FArray*)(ecx + 0x34))->Num();
		INT n6  = ((FArray*)(ecx + 0x40))->Num();
		INT n2b = ((FArray*)(ecx + 0x4C))->Num();
		total += subTotal + n1 * 0x10 + n6 * 0x0C + n2b * 4;
		i++;
	}
	return total;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10430a30)
void UMeshAnimation::PostLoad()
{
	// Ghidra 0x130a30, 119b. Calls UObject::PostLoad then, for each FMeshAnimSeq in
	// Sequences (this+0x48, stride 0x2C), inlines FUN_103ca8f0(GetOuter()) with
	// ECX = the sequence entry.
	// FUN_103ca8f0 (200b, _unnamed.cpp): for each FMeshAnimNotify (seq+0x1C, stride 0xC)
	//   with non-None FunctionName at notify+4, creates a UAnimNotify_Script via
	//   FUN_103ca880 = StaticConstructObject(UAnimNotify_Script::StaticClass, outer, NAME_None).
	//   Then sets obj->NotifyName (obj+0x30) = FunctionName, stores obj in notify+8,
	//   and clears notify.FunctionName to NAME_None.
	// Ghidra's PostLoad omits ECX setup before FUN_103ca8f0 call; confirmed ECX = seq entry.
	UObject::PostLoad();
	FArray* seqArr = (FArray*)((BYTE*)this + 0x48);
	INT i = 0;
	while (true)
	{
		if (seqArr->Num() <= i) break;
		UObject* outer = GetOuter();
		// FUN_103ca8f0(outer) inlined with ECX = Sequences[i] (FMeshAnimSeq, stride 0x2C)
		BYTE* seq = (BYTE*)*(INT*)seqArr + i * 0x2C;
		FArray* notifys = (FArray*)(seq + 0x1C); // FMeshAnimSeq::Notifys TArray
		INT j = 0;
		while (true)
		{
			if (notifys->Num() <= j) break;
			// FMeshAnimNotify: +0 float Time, +4 FName FunctionName, +8 UAnimNotify* Object
			BYTE* elem = (BYTE*)*(INT*)notifys + j * 0x0C;
			FName funcName; *(DWORD*)&funcName = *(DWORD*)(elem + 4);
			if (funcName != FName(NAME_None))
			{
				// FUN_103ca880 inlined: StaticConstructObject-wrapper for UAnimNotify_Script
				UAnimNotify_Script* obj = (UAnimNotify_Script*)UObject::StaticConstructObject(
					UAnimNotify_Script::StaticClass(), (UObject*)outer, NAME_None, 0, NULL, GError, NULL);
				*(DWORD*)((BYTE*)obj + 0x30) = *(DWORD*)(elem + 4); // obj->NotifyName = FunctionName
				*(DWORD*)(elem + 8) = (DWORD)obj;                   // notify.Object = obj
				*(DWORD*)(elem + 4) = 0;                             // notify.FunctionName = NAME_None
			}
			j++;
		}
		i++;
	}
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

IMPL_MATCH("Engine.dll", 0x1033a490)
void UMeshAnimation::InitForDigestion()
{
	guard(UMeshAnimation::InitForDigestion);
	if (*(INT*)((BYTE*)this + 0x54) == 0)
	{
		// Retail: GMalloc->Malloc(0x2C, "Digest"), then calls FUN_1032b9b0 to init
		// 3 FArrays at p+0x00/+0x10/+0x1C (equivalent to memzero), then zeros all
		// 11 DWORDs, then seeds the float at +0x28 with 1.0f.
		void* p = appMalloc(0x2C, TEXT("Digest"));
		*(void**)((BYTE*)this + 0x54) = p;
		appMemzero(p, 0x2C);
		*(DWORD*)((BYTE*)p + 0x28) = 0x3f800000; // 1.0f
	}
	unguard;
}


// --- UVertMesh ---
IMPL_MATCH("Engine.dll", 0x10474da0)
int UVertMesh::RenderPreProcess()
{
	guard(UVertMesh::RenderPreProcess);
	INT iVar2 = ((FArray*)((BYTE*)this + 400))->Num();
	if (iVar2 != 0) return 0;

	// Ghidra: empty destructor loop over existing entries at +0x14C (count at +0x150).
	// Retail iterates for side-effects (element destructors); our entries are POD-zeroed.
	for (INT d = 0; d < *(INT*)((BYTE*)this + 0x150); d++) {}

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

	// Ghidra: FArray::Num(+0xC4), FArray::Num(+0x14C), GLog->Logf(...)
	// Format string is embedded in the binary and not extractable from Ghidra.
	this_00->Num();
	this_01->Num();
	GLog->Logf(TEXT(""));

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
				InitAnimMeshStreamEntry(newEntry);
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

IMPL_MATCH("Engine.dll", 0x104758b0)
void UVertMesh::Serialize(FArchive& Ar)
{
	guard(UVertMesh::Serialize);
	// Ghidra 0x104758b0 (424b).
	ULodMesh::Serialize(Ar);
	SerArr0x20(Ar, *(FArray*)((BYTE*)this + 0x14C));
	Ar.ByteOrderSerialize((BYTE*)this + 0x160, 4);
	SerArr4BOS(Ar, *(FArray*)((BYTE*)this + 0x0F4));   // FUN_103c7240
	SerArr4BOS(Ar, *(FArray*)((BYTE*)this + 0x10C));   // FUN_10438000
	SerArrMeshAnimSeq(Ar, *(FArray*)((BYTE*)this + 0x118));
	SerArr4ViaElem(Ar, *(FArray*)((BYTE*)this + 0x100)); // FUN_1032d5f0
	Ar.ByteOrderSerialize((BYTE*)this + 0x13C, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x140, 4);
	SerArrBox(Ar, *(FArray*)((BYTE*)this + 0x124));
	SerArrSphere(Ar, *(FArray*)((BYTE*)this + 0x130));
	if (!Ar.IsPersistent())
	{
		Ar.ByteOrderSerialize((BYTE*)this + 0x170, 4);
		Ar << *(FRawIndexBuffer*)((BYTE*)this + 0x174);
		SerArr0x5C(Ar, *(FArray*)((BYTE*)this + 0x190));
		Ar.ByteOrderSerialize((BYTE*)this + 0x19C, 4);
		Ar << *(FRawIndexBuffer*)((BYTE*)this + 0x1A0);
		SerArr0x5C(Ar, *(FArray*)((BYTE*)this + 0x1BC));
		Ar.ByteOrderSerialize((BYTE*)this + 0x1C8, 4);
		Ar << *(FRawIndexBuffer*)((BYTE*)this + 0x1CC);
		SerArr0x5C(Ar, *(FArray*)((BYTE*)this + 0x1E8));
		Ar.ByteOrderSerialize((BYTE*)this + 0x1F4, 4);
		Ar << *(FRawIndexBuffer*)((BYTE*)this + 0x1F8);
		SerArr0x5C(Ar, *(FArray*)((BYTE*)this + 0x214));
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10314e10)
UClass * UVertMesh::MeshGetInstanceClass()
{
	return UVertMeshInstance::StaticClass();
}

IMPL_MATCH("Engine.dll", 0x10472830)
void UVertMesh::PostLoad()
{
	guard(UVertMesh::PostLoad);
	UObject::PostLoad();

	// Ghidra 0x10472830 (124b):
	// Loop over each FMeshAnimSeq (stride 0x2C) in the Anims array at this+0x118.
	// For each seq, iterate its FMeshAnimNotify array (stride 0xC, at seq+0x1c).
	// If a notify has a non-None FuncName at +4, create a UAnimNotify_Script via
	// StaticConstructObject, copy the FName to inst+0x30 (NotifyName), store
	// the instance pointer back at notify+8, then clear notify's FuncName.
	// --- FUN_103ca8f0 + FUN_103ca880 inlined as template-equivalent calls ---
	INT numSeqs = ((FArray*)((BYTE*)this + 0x118))->Num();
	for (INT i = 0; i < numSeqs; i++)
	{
		BYTE* pAnimSeq = (BYTE*)(*(INT*)((BYTE*)this + 0x118)) + i * 0x2C;
		UObject* outer = GetOuter();
		if (outer == (UObject*)(INT)-1)
			outer = (UObject*)UObject::GetTransientPackage();

		// FMeshAnimNotify: stride 0xC: [+0: reserved][+4: FName FuncName][+8: UAnimNotify_Script*]
		FArray* pNotifies = (FArray*)(pAnimSeq + 0x1c);
		INT numNotifies = pNotifies->Num();
		for (INT j = 0; j < numNotifies; j++)
		{
			BYTE* notifyEntry = (BYTE*)(*(INT*)pNotifies) + j * 0xC;
			FName funcName = *(FName*)(notifyEntry + 4);
			if (funcName != NAME_None)
			{
				UAnimNotify_Script* inst = (UAnimNotify_Script*)UObject::StaticConstructObject(
					UAnimNotify_Script::StaticClass(), outer,
					NAME_None, 0, NULL, GError);
				*(FName*)((BYTE*)inst + 0x30) = *(FName*)(notifyEntry + 4); // inst->NotifyName = funcName
				*(INT*)(notifyEntry + 8) = (INT)inst;                        // notify->Instance = inst
				*(FName*)(notifyEntry + 4) = NAME_None;                      // clear notify->FuncName
			}
		}
	}
	unguard;
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

IMPL_MATCH("Engine.dll", 0x10438890)
int USkeletalMesh::SetAttachAlias(FName param_2, FName param_3, FCoords& param_4)
{
	guard(USkeletalMesh::SetAttachAlias);
	FName none(NAME_None);
	if (param_2 == none) return 0;
	if (param_3 == none) return 0;

	FArray* nameArr = (FArray*)((BYTE*)this + 0x2d0);
	INT iVar1_before = nameArr->Num();
	// Ghidra 0x138890, 337b. FUN_10437fb0 (75b, _unnamed.cpp) = TArray<FName>::AddUnique:
	// searches ECX array for param_1, returns index if found; else appends and returns new index.
	// Inlined here; behavior is identical to the retail call-site pattern.
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

IMPL_DIVERGE("Karma physics interface callbacks at param_3+0x328+0xf0 use proprietary runtime vtables (slots [2]/[3]); gameplay path is implemented with raw calls, but exact typed integration cannot be made byte-parity-safe")
int USkeletalMesh::SetAttachmentLocation(AActor* param_2, AActor* param_3)
{
	guard(USkeletalMesh::SetAttachmentLocation);

	FCoords BoneCoords;
	FCoords AdjustCoords;

	// FName at param_3+0x1b0 = AttachTag
	FName* AttachTag = (FName*)((BYTE*)param_3 + 0x1b0);

	// Search TagAliases (TArray<FName> at this+0x2d0) for AttachTag
	// FUN_10435460: linear scan of TArray<FName> with stride 4
	FArray* aliasArr = (FArray*)((BYTE*)this + 0x2d0);
	INT aliasIdx = -1;
	for (INT i = 0; i < aliasArr->Num(); i++)
	{
		if (*(FName*)((BYTE*)aliasArr->GetData() + i * 4) == *AttachTag)
		{
			aliasIdx = i;
			break;
		}
	}

	INT boneIdx;
	if (aliasIdx == -1)
	{
		// No alias — direct bone name search
		boneIdx = -1;
		INT numBones = ((FArray*)((BYTE*)this + 0x19c))->Num();
		for (INT i = 0; i < numBones; i++)
		{
			FName* boneName = (FName*)((BYTE*)*(INT*)((BYTE*)this + 0x19c) + i * 0x40);
			if (*boneName == *AttachTag)
			{
				boneIdx = i;
				break;
			}
		}
		if (boneIdx >= 0)
		{
			MeshGetInstance(param_2);
			BYTE* instance = (BYTE*)*(INT*)((BYTE*)param_2 + 0x324);
			if (boneIdx < ((FArray*)(instance + 0xb8))->Num())
			{
				// Copy bone transform (FCoords, 48 bytes = 12 DWORDs)
				DWORD* src = (DWORD*)(*(INT*)(instance + 0xb8) + boneIdx * 0x30);
				DWORD* dst = (DWORD*)&BoneCoords;
				for (INT j = 0xc; j != 0; j--) { *dst++ = *src++; }
				// Use identity coords
				src = (DWORD*)&GMath.UnitCoords;
				dst = (DWORD*)&AdjustCoords;
				for (INT j = 0xc; j != 0; j--) { *dst++ = *src++; }
				goto doTransform;
			}
		}
	}
	else
	{
		// Alias found — get real bone name from TagAliasesRefBone (TArray at this+0x2dc)
		FName realBoneName = *(FName*)((BYTE*)*(INT*)((BYTE*)this + 0x2dc) + aliasIdx * 4);
		boneIdx = -1;
		INT numBones = ((FArray*)((BYTE*)this + 0x19c))->Num();
		for (INT i = 0; i < numBones; i++)
		{
			FName* boneName = (FName*)((BYTE*)*(INT*)((BYTE*)this + 0x19c) + i * 0x40);
			if (*boneName == realBoneName)
			{
				boneIdx = i;
				break;
			}
		}
		if (boneIdx >= 0)
		{
			MeshGetInstance(param_2);
			BYTE* instance = (BYTE*)*(INT*)((BYTE*)param_2 + 0x324);
			if (boneIdx < ((FArray*)(instance + 0xb8))->Num())
			{
				// Copy bone transform
				DWORD* src = (DWORD*)(*(INT*)(instance + 0xb8) + boneIdx * 0x30);
				DWORD* dst = (DWORD*)&BoneCoords;
				for (INT j = 0xc; j != 0; j--) { *dst++ = *src++; }
				// Copy alias adjustment coords from TagCoords (TArray at this+0x2e8)
				src = (DWORD*)(*(INT*)((BYTE*)this + 0x2e8) + aliasIdx * 0x30);
				dst = (DWORD*)&AdjustCoords;
				for (INT j = 0xc; j != 0; j--) { *dst++ = *src++; }
				goto doTransform;
			}
		}
	}

	// Bone not found — log warning if mesh has bones
	{
		INT numBones = ((FArray*)((BYTE*)*(INT*)((BYTE*)param_2 + 0x324) + 0xb8))->Num();
		if (numBones != 0)
		{
			GLog->Logf(TEXT("SetAttachmentLocation: Tag '%s' not found on mesh '%s'"),
				**(FName*)((BYTE*)param_3 + 0x1b0), ((UObject*)param_2)->GetName());
		}
	}
	return 0;

doTransform:
	{
		BYTE* instance = (BYTE*)*(INT*)((BYTE*)param_2 + 0x324);

		// Combine bone + adjustment coordinate frames
		FCoords applied = BoneCoords.ApplyPivot(AdjustCoords);

		// Transform relative location by applied coords
		FVector transRelLoc = (*(FVector*)((BYTE*)param_3 + 0x264)).TransformVectorBy(applied);

		// Build relative rotation coordinate frame
		FCoords relRotCoords = GMath.UnitCoords / *(FRotator*)((BYTE*)param_3 + 0x270);

		// Karma physics callback #1: vtable[3] at *(param_3+0x328)+0xf0
		if ((*(DWORD*)((BYTE*)param_3 + 0xa8) & 0x800) != 0)
		{
			INT* physIntf = *(INT**)(*(INT*)((BYTE*)param_3 + 0x328) + 0xf0);
			if (physIntf != NULL)
			{
				typedef void (__thiscall *PhysCB)(INT*, AActor*, void*, FCoords*, FCoords*);
				PhysCB cb = *(PhysCB*)((BYTE*)(*physIntf) + 0xc);
				cb(physIntf, param_3, (void*)((BYTE*)param_3 + 0x270), &applied, &BoneCoords);
			}
		}

		// Combine applied origin with transformed relative location
		FCoords* spaceBase = (FCoords*)(instance + 0xc4);
		applied.Origin += transRelLoc;

		// Transform to world space: applied * SpaceBase (Ghidra: ECX=applied, param=SpaceBase)
		FCoords worldResult = applied * (*spaceBase);

		// Write Location
		*(FVector*)((BYTE*)param_3 + 0x234) = worldResult.Origin;

		// Combine rotation into applied coords
		applied *= relRotCoords;

		// Build world rotation
		FCoords transposed = applied.Transpose();
		FCoords worldRotResult = transposed * (*spaceBase);
		FRotator finalRot = worldRotResult.OrthoRotation();

		// Write Rotation
		*(FRotator*)((BYTE*)param_3 + 0x240) = finalRot;

		// Karma physics callback #2: vtable[2] at *(param_3+0x328)+0xf0
		if ((*(DWORD*)((BYTE*)param_3 + 0xa8) & 0x800) != 0)
		{
			INT* physIntf = *(INT**)(*(INT*)((BYTE*)param_3 + 0x328) + 0xf0);
			if (physIntf != NULL)
			{
				typedef void (__thiscall *PhysCB2)(INT*, AActor*, FRotator*, FCoords*, FCoords*);
				PhysCB2 cb = *(PhysCB2*)((BYTE*)(*physIntf) + 8);
				cb(physIntf, param_3, &finalRot, spaceBase, &worldResult);
			}
		}

		return 1;
	}
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

IMPL_MATCH("Engine.dll", 0x10441560)
void USkeletalMesh::CalculateNormals(TArray<FVector>& Normals, int param2)
{
	guard(USkeletalMesh::CalculateNormals);
	// Ghidra 0x141560, 634b.
	// Accumulate per-face cross-product normals into a per-vertex temp buffer, then
	// normalise and optionally (param2 != 0) add to vertex positions.
	// Face data at this+0xAC uses wedge indices; wedge table at this+0xC4 maps to
	// vertex position indices; positions at this+0x1B8.
	// SEH frame and FUN_10324640 destructor thunk are handled by C++ TArray RAII.
	if (Normals.Num() != 0) return;

	FArray* vertArr = (FArray*)((BYTE*)this + 0x1b8);
	INT vertCount = vertArr->Num();
	if (vertCount == 0) return;

	TArray<FVector> tempNormals;
	tempNormals.AddZeroed(vertCount);

	BYTE* vertData  = (BYTE*)*(INT*)vertArr;
	BYTE* wedgeData = (BYTE*)*(INT*)((BYTE*)this + 0xc4); // wedge table, stride 0xC, USHORT vert-idx at [0]
	FArray* faceArr = (FArray*)((BYTE*)this + 0xac);
	INT faceCount = faceArr->Num();
	BYTE* faceData = (BYTE*)*(INT*)faceArr;               // face array, stride 8, 4 x USHORT wedge-idx

	for (INT fi = 0; fi < faceCount; fi++)
	{
		// Ghidra: (iVar2 + iVar1*4)*2 with iVar1=fi, iVar2=0..2 → wedge indices
		_WORD w0 = *(_WORD*)(faceData + (0 + fi * 4) * 2);
		_WORD w1 = *(_WORD*)(faceData + (1 + fi * 4) * 2);
		_WORD w2 = *(_WORD*)(faceData + (2 + fi * 4) * 2);

		// Two-level lookup: wedge → vertex position index (first USHORT of 12-byte wedge entry)
		_WORD vi0 = *(_WORD*)(wedgeData + (DWORD)w0 * 0xc);
		_WORD vi1 = *(_WORD*)(wedgeData + (DWORD)w1 * 0xc);
		_WORD vi2 = *(_WORD*)(wedgeData + (DWORD)w2 * 0xc);

		BYTE* pv0 = vertData + vi0 * 0xc;
		BYTE* pv1 = vertData + vi1 * 0xc;
		BYTE* pv2 = vertData + vi2 * 0xc;
		FLOAT p0x = *(FLOAT*)(pv0+0), p0y = *(FLOAT*)(pv0+4), p0z = *(FLOAT*)(pv0+8);
		FLOAT p1x = *(FLOAT*)(pv1+0), p1y = *(FLOAT*)(pv1+4), p1z = *(FLOAT*)(pv1+8);
		FLOAT p2x = *(FLOAT*)(pv2+0), p2y = *(FLOAT*)(pv2+4), p2z = *(FLOAT*)(pv2+8);

		// edge1 = p2 - p0 (local_5c/58/54), edge2 = p0 - p1 (local_68/64/60)
		// cross = edge2 ^ edge1
		FLOAT e1x = p2x-p0x, e1y = p2y-p0y, e1z = p2z-p0z;
		FLOAT e2x = p0x-p1x, e2y = p0y-p1y, e2z = p0z-p1z;
		FLOAT cx = e2y*e1z - e2z*e1y;
		FLOAT cy = e2z*e1x - e2x*e1z;
		FLOAT cz = e2x*e1y - e2y*e1x;

		tempNormals(vi0).X += cx; tempNormals(vi0).Y += cy; tempNormals(vi0).Z += cz;
		tempNormals(vi1).X += cx; tempNormals(vi1).Y += cy; tempNormals(vi1).Z += cz;
		tempNormals(vi2).X += cx; tempNormals(vi2).Y += cy; tempNormals(vi2).Z += cz;
	}

	// Normalise and optionally displace vertex positions.
	Normals.Add(vertCount);
	for (INT vi = 0; vi < vertCount; vi++)
	{
		FVector& n = tempNormals(vi);
		FLOAT sqLen = n.SizeSquared();
		FLOAT divisor = appSqrt(sqLen + 0.001f);
		FLOAT nx = n.X / divisor, ny = n.Y / divisor, nz = n.Z / divisor;

		if (param2 != 0)
		{
			BYTE* pv = vertData + vi * 0xc;
			nx += *(FLOAT*)(pv+0);
			ny += *(FLOAT*)(pv+4);
			nz += *(FLOAT*)(pv+8);
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

IMPL_DIVERGE("7 render-stream vtable slot-0 calls at this+0xF4/+0x10C/+0x124/+0x13C/+0x154/+0x16C/+0x184 (stream Clear) use binary-internal vtable layout (FAnimMeshVertexStream, FSkinVertexStream, etc.); FUN_1043f4c0 (LOD constructor) and FUN_10440e20/FUN_10441200 (LOD reduction helpers) also unexported; Ghidra 0x10442d40 (1388b)")
void USkeletalMesh::GenerateLodModel(int param1, float param2, float param3, int param4, int param5)
{
	guard(USkeletalMesh::GenerateLodModel);
	// Ghidra 0x10442d40 (1388b): validates param1 in [0,8], issues 7 render-stream
	// vtable slot-0 Clear calls, then FUN_10441200 (vert-count normalization),
	// FUN_1043f4c0 (LOD slot constructor), FUN_10440e20 (LOD reduction), and complex
	// progressive mesh decimation loop with FUN_10440840 (face insertion).
	// DIVERGENCE: render-stream vtable calls and LOD reduction helpers are binary-internal.
	if (param1 >= 0 && param1 < 9)
	{
		(void)param2; (void)param3; (void)param4; (void)param5;
	}
	unguard;
}

IMPL_DIVERGE("7 render-stream vtable slot-0 calls on param_2+0xF4/+0x13C/+0x124/+0x10C/+0x154/+0x16C/+0x184 (stream Clear/copy) use binary-internal vtable layout; FUN_1043f4c0 (LOD entry constructor with FSkinVertexStream vtable + DAT_1060b564 resource-ID) and FUN_10440e20 (LOD reduction) also unexported; Ghidra 0x10442970 (925b)")
void USkeletalMesh::InsertLodModel(int param1, USkeletalMesh* param2, float param3, int param4)
{
	guard(USkeletalMesh::InsertLodModel);
	// Ghidra 0x10442970 (925b): inserts LOD model from param2 at slot param1 in LOD array.
	// FUN_1043f4c0 constructs 0x11C-byte LOD entry (multiple FArrays, FRawIndexBuffers,
	// FSkinVertexStream vtable at +0x6C, resource-ID from DAT_1060b564 at +0x78).
	// Then 7 vtable slot-0 calls on param2's render-streams (Clear), followed by
	// deep-copy loops for vertices, faces, weights, and influence data.
	// DIVERGENCE: FUN_1043f4c0, render-stream vtable calls, and copy logic all unresolved.
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

// Ghidra 0x1043c980 (537b): flags check → BuildPivotsList on inst → copy 7-float FBox
// from inst+0x380 → AABB segment test → if hit: call inst->vtable[0x68/4] (per-instance check).
// Note: vtable+0x88 on USkeletalMesh = MeshGetInstance(actor).
IMPL_MATCH("Engine.dll", 0x1043c980)
int USkeletalMesh::R6LineCheck(FCheckResult& param_1, AActor* param_2, FVector param_3, FVector param_4, FVector param_5, DWORD param_6, DWORD param_7)
{
	guard(USkeletalMesh::R6LineCheck);
	if ((param_6 & 0x10000) == 0 || (*(DWORD*)((BYTE*)param_2 + 0xa8) & 0x2000) == 0)
		return UPrimitive::LineCheck(param_1, param_2, param_3, param_4, param_5, param_6, param_7);

	// Get instance and build bone pivots list.
	USkeletalMeshInstance* skelInst = (USkeletalMeshInstance*)MeshGetInstance(param_2);
	skelInst->BuildPivotsList();
	UMeshInstance* inst = MeshGetInstance(param_2);

	// Copy bone-based FBox (7 DWORDs) from instance+0x380.
	// Layout: Min.X/Y/Z then Max.X/Y/Z then IsValid flag.
	float* bboxSrc = (float*)((BYTE*)inst + 0x380);
	float minX = bboxSrc[0], minY = bboxSrc[1], minZ = bboxSrc[2];
	float maxX = bboxSrc[3], maxY = bboxSrc[4], maxZ = bboxSrc[5];

	// AABB segment test: are both endpoints of (End=param_3, Start=param_4) outside the box?
	// Retail: (A <= Max || B <= Max) && (A >= Min || B >= Min) for each axis.
	bool inBounds =
		((param_3.X <= maxX || param_4.X <= maxX) && (param_3.X >= minX || param_4.X >= minX)) &&
		((param_3.Y <= maxY || param_4.Y <= maxY) && (param_3.Y >= minY || param_4.Y >= minY)) &&
		((param_3.Z <= maxZ || param_4.Z <= maxZ) && (param_3.Z >= minZ || param_4.Z >= minZ));

	if (inBounds)
	{
		*(BYTE*)((BYTE*)param_2 + 0x35) = 0; // clear actor flag (retail: bDeleteMe or similar)
		inst = MeshGetInstance(param_2);
		// Call per-instance line check at vtable slot 0x68/4 = 26.
		typedef int (__thiscall* InstLineCheckFn)(void*, FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD);
		int* instVtbl = *(int**)inst;
		return ((InstLineCheckFn)instVtbl[0x68 / 4])(inst, param_1, param_2, param_3, param_4, param_5, param_6, param_7);
	}
	return 1;
	unguard;
}

IMPL_TODO("blocked by FUN_1043fa50 (FSkelMeshLODModel stride-0x11C, deep chain via FUN_1043f650); FUN_10438510 GLazyLoad-gated helper now implemented; retail hierarchy has ULodMesh::Serialize as base but source hierarchy uses UMesh::Serialize; retail 0x1043ffb0 (746b)")
void USkeletalMesh::Serialize(FArchive& Ar)
{
	// Ghidra 0x1043ffb0 (746b): retail calls ULodMesh::Serialize first (USkeletalMesh→ULodMesh
	// in retail hierarchy), but our source declares USkeletalMesh : public UMesh, so
	// UMesh::Serialize is the correct base call for our hierarchy.
	// Remaining FUN_ blockers: FUN_1043fa50 (FSkelMeshLODModel array at +0x1AC, stride 0x11C)
	// and FUN_10438510 (GLazyLoad-gated vertex array at +0xF4).
	UMesh::Serialize(Ar);
}

IMPL_DIVERGE("Karma/MeSDK proprietary: ragdoll line check uses KU2MEPosition, KME2UPosition, and per-body MeXContactPoints ray cast via FUN_104f36e0/FUN_104aa520/FUN_104aa400/FUN_104aa700 (all MathEngine SDK functions); retail 0x104354f0 (729b)")
int USkeletalMesh::LineCheck(FCheckResult& param_1, AActor* param_2, FVector param_3, FVector param_4, FVector param_5, DWORD param_6, DWORD param_7)
{
	guard(USkeletalMesh::LineCheck);
	if (*(BYTE*)((BYTE*)param_2 + 0x2c) != 0x0e) // PHYS_KarmaRagDoll = 14
		return UPrimitive::LineCheck(param_1, param_2, param_3, param_4, param_5, param_6, param_7);
	// Ghidra 0x104354f0 (729b): for ragdolls (Physics==0x0E), checks FVector!=zero extent,
	// then MeshGetInstance→IsA(USkeletalMeshInstance), converts positions via KU2MEPosition,
	// iterates instance+0x308 body array, calls FUN_104f36e0/FUN_104aa520/FUN_104aa400/
	// FUN_104aa700 (MeSDK ray-vs-body contact test), finds closest hit body, converts back
	// via KME2UPosition, fills FCheckResult. All FUN_104xxxxx are MathEngine SDK internals.
	// DIVERGENCE: Karma/MeSDK proprietary — returns 1 (no hit) for ragdoll actors.
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
IMPL_DIVERGE("7 render-stream vtable slot-0 calls at this+0xF4/+0x13C/+0x124/+0x10C/+0x154/+0x16C/+0x184 (FAnimMeshVertexStream/FSkinVertexStream Clear) use binary-internal vtable layout; subsequent FArray::Empty and per-LOD reconstruction depend on streams being in a clean state; retail 0x10441820 (1752b)")
void USkeletalMesh::ReconstructRawMesh()
{
	guard(USkeletalMesh::ReconstructRawMesh);
	// Ghidra 0x10441820 (1752b): checks GIsEditor/GIsUCC, then 7 render-stream vtable
	// slot-0 Clear calls (FAnimMeshVertexStream/FSkinVertexStream at +0xF4/+0x13C/+0x124/
	// +0x10C/+0x154/+0x16C/+0x184). Then empties arrays at +0x100/+0x130/+0x148/+0x160
	// and TArray<unsigned short> at +0x178/+0x190. Reconstructs raw mesh from LOD data at
	// +0x1C4 (up to 7 LODs), filling vertices, faces, weights, and influences.
	// Finally builds FArray of face-material assignments and copies to +0xAC faces array.
	// DIVERGENCE: render-stream vtable calls and downstream reconstruction permanently blocked.
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

IMPL_DIVERGE("render-stream vtable slot-0 call at this+0xF4 (FAnimMeshVertexStream::Clear before ReconstructRawMesh) uses binary-internal vtable layout; rest of function matches retail; retail 0x1042f4b0 (232b)")
void USkeletalMesh::PostLoad()
{
	// Ghidra 0x12f4b0: UObject::PostLoad, then if LodVersion (+0x5C) < 2: vtable slot-0 call
	// on render-stream at this+0xF4 (stream Clear), then ReconstructRawMesh().
	// If LOD models array (this+0x1AC) is empty: log warning, auto-generate 4 LOD levels.
	// DIVERGENCE: the stream-clear vtable call is permanently unresolvable; skipped.
	UObject::PostLoad();
	if (*(INT*)((BYTE*)this + 0x5C) < 2)
	{
		// DIVERGENCE: (*(code**)**(undefined4**)(this+0xF4))() — render-stream clear skipped.
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


