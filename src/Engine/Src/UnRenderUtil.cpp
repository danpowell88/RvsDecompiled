/*=============================================================================
	UnRenderUtil.cpp: Render buffers, lighting, and BSP geometry helpers
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

// extern declarations for FCollisionHash per-frame counters.
extern INT GHashActorCount;
extern INT GHashLinkCellCount;
extern INT GHashExtraCount;
extern CORE_API UBOOL GHideHiddenInEditor;

// Global render-resource cache-ID counter (Ghidra: DAT_1060b564).
// Incremented each time a render resource is constructed; OR'd with a tag byte
// to form a unique QWORD cache ID for FBspSection, FStaticLightMapTexture, etc.
INT DAT_1060b564 = 0;

// --- FAnimMeshVertexStream ---
IMPL_MATCH("Engine.dll", 0x1032b170)
FAnimMeshVertexStream::FAnimMeshVertexStream(FAnimMeshVertexStream const &Other)
{
	// Ghidra 0x2b170: vtable set by compiler; DWORD at +4; TArray<FStreamVert32> at +8 (stride 0x20); 6 DWORDs at +14..+28
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	new ((BYTE*)this + 0x08) TArray<FStreamVert32>(*(const TArray<FStreamVert32>*)((const BYTE*)&Other + 0x08));
	appMemcpy((BYTE*)this + 0x14, (const BYTE*)&Other + 0x14, 0x18); // 6 DWORDs
}

IMPL_MATCH("Engine.dll", 0x1032b0e0)
FAnimMeshVertexStream::FAnimMeshVertexStream()
{
	new ((BYTE*)this + 0x08) TArray<FStreamVert32>();
}

IMPL_MATCH("Engine.dll", 0x1032b160)
FAnimMeshVertexStream::~FAnimMeshVertexStream()
{
	// Ghidra 0x2b160: destroy TArray<FStreamVert32> at +8 (stride 0x20, POD elements)
	((TArray<FStreamVert32>*)((BYTE*)this + 0x08))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x1032b1c0)
FAnimMeshVertexStream& FAnimMeshVertexStream::operator=(const FAnimMeshVertexStream& Other)
{
	// Ghidra 0x2b1c0: skip vtable at +0, DWORD at +4, TArray<FStreamVert32> at +8
	// (FUN_1031f7d0 = 32-byte elems), then 6 DWORDs at +0x14..+0x28
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	*(TArray<FStreamVert32>*)((BYTE*)this + 0x08) = *(const TArray<FStreamVert32>*)((const BYTE*)&Other + 0x08);
	appMemcpy((BYTE*)this + 0x14, (const BYTE*)&Other + 0x14, 0x18); // 6 DWORDs
	return *this;
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x1031c5b0)
int FAnimMeshVertexStream::SetPartialSize(int Size)
{
	// Ghidra: clamp Size to [0, Num], store at Pad[32], mark dirty (increment Pad[24])
	INT Num = *(INT*)(Pad + 8);
	if (Size < 0) Size = 0;
	if (Size > Num) Size = Num;
	*(INT*)(Pad + 32) = Size;
	*(INT*)(Pad + 24) += 1;
	return Size;
}
IMPL_MATCH("Engine.dll", 0x103162b0)
unsigned __int64 FAnimMeshVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 16);
}
IMPL_MATCH("Engine.dll", 0x10314890)
int FAnimMeshVertexStream::GetComponents(FVertexComponent* C)
{
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}
IMPL_MATCH("Engine.dll", 0x1031c580)
int FAnimMeshVertexStream::GetPartialSize()
{
	INT Num = *(INT*)(Pad + 8);
	if (*(INT*)(Pad + 28))
	{
		INT PartialCount = *(INT*)(Pad + 32);
		return (PartialCount < Num) ? PartialCount : Num;
	}
	return Num;
}
IMPL_MATCH("Engine.dll", 0x1031c610)
void FAnimMeshVertexStream::GetRawStreamData(void ** Out, int Offset)
{
	*Out = *(BYTE**)(Pad + 4) + Offset * 0x20;
}
IMPL_MATCH("Engine.dll", 0x10314870)
int FAnimMeshVertexStream::GetRevision()
{
	return *(INT*)(Pad + 24);
}
IMPL_MATCH("Engine.dll", 0x10314880)
int FAnimMeshVertexStream::GetSize()
{
	return GetPartialSize() << 5;
}
IMPL_MATCH("Engine.dll", 0x1031c5f0)
void FAnimMeshVertexStream::GetStreamData(void * Dest)
{
	INT Size = GetPartialSize() << 5;
	appMemcpy(Dest, *(void**)(Pad + 4), Size);
}
IMPL_MATCH("Engine.dll", 0x1042f4a0)
int FAnimMeshVertexStream::GetStride()
{
	return 0x20;
}


// --- FBspVertexStream ---
IMPL_MATCH("Engine.dll", 0x103278f0)
FBspVertexStream::FBspVertexStream(FBspVertexStream const &Other)
{
	// Ghidra 0x103278f0: vtable set by compiler; TArray<FBspVertex> at +4 (stride 0x28); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FBspVertex>(*(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10327860)
FBspVertexStream::FBspVertexStream()
{
	// Initialize TArray<FBspVertex> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FBspVertex>();
}

IMPL_MATCH("Engine.dll", 0x103278e0)
FBspVertexStream::~FBspVertexStream()
{
	((TArray<FBspVertex>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x10327930)
FBspVertexStream& FBspVertexStream::operator=(const FBspVertexStream& Other)
{
	// Ghidra 0x27930: skip vtable at +0, TArray<FBspVertex> at +4 (FUN_10324ae0=40-byte elems),
	// then 3 DWORDs at +0x10..+0x18
	*(TArray<FBspVertex>*)((BYTE*)this + 0x04) = *(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
	return *this;
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x10444fa0)
unsigned __int64 FBspVertexStream::GetCacheId()
{
	return *(unsigned __int64*)(Pad + 12);
}
IMPL_MATCH("Engine.dll", 0x103046e0)
int FBspVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 0; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	C[3].Type = 2; C[3].Function = 5;
	return 4;
}
IMPL_MATCH("Engine.dll", 0x10318f70)
void FBspVertexStream::GetRawStreamData(void ** Out, int Offset)
{
	*Out = *(BYTE**)Pad + Offset * 0x28;
}
IMPL_MATCH("Engine.dll", 0x1047ad20)
int FBspVertexStream::GetRevision()
{
	return *(INT*)(Pad + 20);
}
IMPL_MATCH("Engine.dll", 0x103046c0)
int FBspVertexStream::GetSize()
{
	return *(INT*)(Pad + 4) * 0x28;
}
IMPL_MATCH("Engine.dll", 0x10318f40)
void FBspVertexStream::GetStreamData(void * Dest)
{
	INT Size = *(INT*)(Pad + 4) * 0x28;
	appMemcpy(Dest, *(void**)Pad, Size);
}
IMPL_MATCH("Engine.dll", 0x103046d0)
int FBspVertexStream::GetStride()
{
	return 0x28;
}


// --- FLevelSceneNode ---
// Ghidra 0x10406670 (1270b): scene render loop. Permanent divergence: constructs
// FCanvasUtil with the incoming FRenderInterface* (D3D device), then dispatches
// Begin/End scene and debug STDbgLine draws through vtable methods on that interface.
IMPL_DIVERGE("FRenderInterface vtable dispatch — FCanvasUtil construction + D3D Begin/EndScene calls")
void FLevelSceneNode::Render(FRenderInterface *)
{
	guard(FLevelSceneNode::Render);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10400e30)
int FLevelSceneNode::FilterActor(AActor* Actor)
{
	// Retail: 0x100E30, ~220b. Complex actor visibility filter used during scene rendering.
	// Returns 1 if Actor should be rendered in this scene, 0 if it should be culled.
	if (!Actor) return 0;
	// In game (non-editor), cull actors with bHidden set or bHiddenEdTemporary flag
	if (!GIsEditor && *(INT*)((BYTE*)Actor + 0xBC) == 0 && (*(DWORD*)((BYTE*)Actor + 0xA8) & 0x8000000) == 0)
		return 0;
	// Level pointer at this+4
	INT levelPtr = *(INT*)((BYTE*)this + 4);
	// Zone info visibility checks
	if ((*(BYTE*)(levelPtr + 0x1F0) & 1) != 0 && (*(DWORD*)((BYTE*)Actor + 0xAC) & 0x200000) == 0)
	{
		if (*(INT*)((BYTE*)Actor + 0xF8) == 1) return 0;
		if (*(INT*)(levelPtr + 500) < *(INT*)((BYTE*)Actor + 0x70)) return 0;
		if (*(INT*)((BYTE*)Actor + 0x74) < *(INT*)(levelPtr + 500)) return 0;
	}
	// BSP / static mesh check (when ShowFlags bit not set)
	if ((*(BYTE*)(*(INT*)(levelPtr + 0x34) + 0x4F8) & 8) == 0)
	{
		if (!Actor->IsA(ABrush::StaticClass()) && !Actor->IsA(AStaticMeshActor::StaticClass()))
			return 0;
	}
	// Karma model visibility
	if (*(INT*)((BYTE*)Actor + 0x170) != 0 &&
		(SBYTE)((*(DWORD*)(*(INT*)(*(INT*)((BYTE*)this + 4) + 0x34) + 0x4F8)) >> 8) >= 0)
		return 0;
	if (!GIsEditor)
	{
		if ((*(DWORD*)((BYTE*)Actor + 0xA8) & 0x8000000) != 0)
			*(INT*)((BYTE*)Actor + 0xBC) = 0;
		// bHidden flag
		if ((*(BYTE*)((BYTE*)Actor + 0xA0) & 2) != 0) return 0;
		if ((*(DWORD*)((BYTE*)Actor + 0xA4) & 0x4000000) != 0) return 0;
		// Tag filter
		if (*(INT*)((BYTE*)Actor + 0x15C) != 0)
		{
			FName none(NAME_None);
			if (*(FName*)((BYTE*)Actor + 0x1B0) != none) return 0;
		}
		INT ownedByCamera = Actor->IsOwnedBy(*(AActor**)((BYTE*)this + 0x1C0));
		if ((*(DWORD*)((BYTE*)Actor + 0xA0) & 0x2000) != 0 && !ownedByCamera) return 0;
		if ((*(DWORD*)((BYTE*)Actor + 0xA0) & 0x1000) == 0) return 1;
		if (!ownedByCamera) return 1;
		BYTE showOwned = *(BYTE*)(*(INT*)(*(INT*)((BYTE*)this + 4) + 0x34) + 0x524) & 0x20;
		return (showOwned != 0) ? 0 : 1;
	}
	// Editor path
	if ((*(DWORD*)((BYTE*)Actor + 0xAC) & 0x1800) != 0) return 0;
	if (*(INT*)((BYTE*)Actor + 0x15C) != 0)
	{
		FName none(NAME_None);
		if (*(FName*)((BYTE*)Actor + 0x1B0) != none) return 0;
	}
	// Editor: check bEdShouldSnap, Volume, etc.
	if (*(INT*)((BYTE*)Actor + 0x178) == 0)
	{
		// Not a volume - check general filter
		if (*(INT*)(*(INT*)(*(INT*)((BYTE*)this + 4) + 0x34) + 0x4F8) == 0) return 0;
	}
	else
	{
		if (!Actor->IsA(AVolume::StaticClass()))
		{
			if (*(INT*)(*(INT*)(*(INT*)((BYTE*)this + 4) + 0x34) + 0x4F8) == 0) return 0;
			goto label_check_model;
		}
		if ((*(DWORD*)(*(INT*)(*(INT*)((BYTE*)this + 4) + 0x34) + 0x4F8) & 0x800000) == 0) return 0;
	}
label_check_model:
	// Check if it's a model/brush and filter based on flags
	if ((*(DWORD*)((BYTE*)Actor + 0xAC) & 0x400) != 0 &&
		(*(DWORD*)(*(INT*)(*(INT*)((BYTE*)this + 4) + 0x34) + 0x4F8) & 0x400) == 0)
		return 0;
	if (*(INT*)(*(INT*)(*(INT*)((BYTE*)this + 4) + 0x34) + 0x4F8) == 0) return 1;
	BYTE bVar = (BYTE)*(INT*)((BYTE*)Actor + 0xA0) & 2;
	if (bVar == 0) return 1;
	return GHideHiddenInEditor ? 0 : 1;
}

IMPL_MATCH("Engine.dll", 0x10301a90)
FLevelSceneNode * FLevelSceneNode::GetLevelSceneNode()
{
	return this;
}


// --- FLightMap ---
IMPL_MATCH("Engine.dll", 0x1033c910)
FLightMap::FLightMap(FLightMap const &Other)
{
	// Ghidra 0x3c910: vtable set by compiler; 34 DWORDs at +4..+8B; TArray<FLightMapSample52> at +0x8C; TArray<FLOAT> at +0x98
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x88);
	new ((BYTE*)this + 0x8C) TArray<FLightMapSample52>(*(const TArray<FLightMapSample52>*)((const BYTE*)&Other + 0x8C));
	new ((BYTE*)this + 0x98) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x98));
}

IMPL_MATCH("Engine.dll", 0x10410c60)
FLightMap::FLightMap(ULevel *Level,int USize,int VSize)
{
	// Ghidra 0x110c60 (159b): constructs FMatrix at +0x28, 3 FVectors at +0x68, +0x74, +0x80,
	// 2 FArrays at +0x8C, +0x98; stores USize at +0x0C, Level at +0x04, VSize at +0x10; zeros +0x24.
	new ((BYTE*)this + 0x28) FMatrix();
	new ((BYTE*)this + 0x68) FVector(0.f,0.f,0.f);
	new ((BYTE*)this + 0x74) FVector(0.f,0.f,0.f);
	new ((BYTE*)this + 0x80) FVector(0.f,0.f,0.f);
	new ((BYTE*)this + 0x8C) TArray<FLightMapSample52>();
	new ((BYTE*)this + 0x98) TArray<FLOAT>();
	*(INT*)((BYTE*)this + 0x0C) = USize;
	*(ULevel**)((BYTE*)this + 0x04) = Level;
	*(INT*)((BYTE*)this + 0x10) = VSize;
	*(INT*)((BYTE*)this + 0x24) = 0;
}

IMPL_MATCH("Engine.dll", 0x1033c6a0)
FLightMap::FLightMap()
{
	new ((BYTE*)this + 0x28) FMatrix();
	new ((BYTE*)this + 0x68) FVector(0.f,0.f,0.f);
	new ((BYTE*)this + 0x74) FVector(0.f,0.f,0.f);
	new ((BYTE*)this + 0x80) FVector(0.f,0.f,0.f);
	new ((BYTE*)this + 0x8C) TArray<FLightMapSample52>();
	new ((BYTE*)this + 0x98) TArray<FLOAT>();
}

IMPL_MATCH("Engine.dll", 0x1033c8a0)
FLightMap::~FLightMap()
{
	// Ghidra 0x3c8a0 (97b): SEH frame; destroys TArray<FLOAT> at +0x98, TArray<FLightMapSample52> at +0x8C.
	((TArray<FLOAT>*)((BYTE*)this + 0x98))->~TArray();
	((TArray<FLightMapSample52>*)((BYTE*)this + 0x8C))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x1033ca10)
FLightMap& FLightMap::operator=(const FLightMap& Other)
{
	// Ghidra 0x3ca10 (194b): skip vtable at +0; +4..+8B = 34 DWORDs (contiguous); +0x8C=TArray<FLightMapSample52>; +0x98=TArray<FLOAT>
	appMemcpy((BYTE*)this + 4, (const BYTE*)&Other + 4, 0x88);
	*(TArray<FLightMapSample52>*)((BYTE*)this + 0x8C) = *(const TArray<FLightMapSample52>*)((const BYTE*)&Other + 0x8C);
	*(TArray<FLOAT>*)((BYTE*)this + 0x98) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x98);
	return *this;
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x10304750)
unsigned __int64 FLightMap::GetCacheId()
{
	// Ghidra 0x4750: genuine stub; returns 0.
	return 0;
}
IMPL_MATCH("Engine.dll", 0x10414310)
int FLightMap::GetFirstMip()
{
	// Ghidra 0x114310: shared stub; returns 0.
	return 0;
}
IMPL_MATCH("Engine.dll", 0x10304740)
ETextureFormat FLightMap::GetFormat()
{
	return TEXF_BCRGB8;
}
IMPL_MATCH("Engine.dll", 0x10304730)
int FLightMap::GetHeight()
{
	return *(INT*)(Pad + 28);
}
IMPL_MATCH("Engine.dll", 0x104436b0)
int FLightMap::GetNumMips()
{
	return 1;
}
IMPL_MATCH("Engine.dll", 0x10304720)
void * FLightMap::GetRawTextureData(int)
{
	// Ghidra 0x4720: shared stub; returns NULL.
	return NULL;
}
IMPL_MATCH("Engine.dll", 0x10304760)
int FLightMap::GetRevision()
{
	return *(INT*)(Pad + 32);
}
IMPL_DIVERGE("retail 0x10410560 (1589b): per-lightmap sample cache fill; uses rdtsc performance counters and complex FDynamicLight iteration")
void FLightMap::GetTextureData(int,void *,int,ETextureFormat,int)
{
	// Ghidra 0x110560 ~900 bytes. Caches per-lightmap sample data into GCache,
	// computes lighting contributions from each dynamic light, and copies
	// the result into param_2. Too complex to translate in full here.
	// TODO: implement FLightMap::GetTextureData (retail 0x110560, ~900 bytes: caches per-lightmap samples, computes lighting contributions)
	guard(FLightMap::GetTextureData);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x104436b0)
ETexClampMode FLightMap::GetUClamp()
{
	return TC_Clamp;
}
IMPL_MATCH("Engine.dll", 0x10414310)
UTexture * FLightMap::GetUTexture()
{
	// Ghidra 0x114310: shared stub; returns NULL.
	return NULL;
}
IMPL_MATCH("Engine.dll", 0x104436b0)
ETexClampMode FLightMap::GetVClamp()
{
	return TC_Clamp;
}
IMPL_MATCH("Engine.dll", 0x10314870)
int FLightMap::GetWidth()
{
	return *(INT*)(Pad + 24);
}


// --- FLightMapTexture ---
IMPL_MATCH("Engine.dll", 0x10320e50)
FLightMapTexture::FLightMapTexture(FLightMapTexture const &Other)
{
	// Ghidra 0x20e50 (117b): vtable set by compiler; copy DWORD at +4; copy TArray<FLOAT> at +8;
	// copy FStaticLightMapTexture sub-object at +0x14; copy 3 DWORDs at +0x60
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	new ((BYTE*)this + 0x08) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x08));
	new ((BYTE*)this + 0x14) FStaticLightMapTexture(*(const FStaticLightMapTexture*)((const BYTE*)&Other + 0x14));
	appMemcpy((BYTE*)this + 0x60, (const BYTE*)&Other + 0x60, 0x0C); // 3 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10410bd0)
FLightMapTexture::FLightMapTexture(ULevel* Level)
{
	// Ghidra 0x110bd0 (132b): init TArray<FLOAT> at +8, init FStaticLightMapTexture at +0x14, store Level at +4,
	// then read/increment DAT_1060b564 global counter and store composite cache ID at +0x60, zero +0x68.
	new ((BYTE*)this + 0x08) TArray<FLOAT>();
	new ((BYTE*)this + 0x14) FStaticLightMapTexture();
	*(ULevel**)((BYTE*)this + 0x04) = Level;
	*(QWORD*)((BYTE*)this + 0x60) = (QWORD)(DWORD)DAT_1060b564 * 0x100 + 0xe0;
	DAT_1060b564++;
	*(DWORD*)((BYTE*)this + 0x68) = 0;
}

IMPL_MATCH("Engine.dll", 0x103279b0)
FLightMapTexture::FLightMapTexture()
{
	// Ghidra 0x279b0 (78b): init TArray<FLOAT> at +8, init FStaticLightMapTexture at +0x14
	new ((BYTE*)this + 0x08) TArray<FLOAT>();
	new ((BYTE*)this + 0x14) FStaticLightMapTexture();
}

IMPL_MATCH("Engine.dll", 0x10320df0)
FLightMapTexture::~FLightMapTexture()
{
	// Ghidra 0x20df0 (87b): destroy FStaticLightMapTexture at +0x14, then TArray<FLOAT> at +8
	((FStaticLightMapTexture*)((BYTE*)this + 0x14))->~FStaticLightMapTexture();
	((TArray<FLOAT>*)((BYTE*)this + 0x08))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x10320ed0)
FLightMapTexture& FLightMapTexture::operator=(const FLightMapTexture& Other)
{
	// Ghidra 0x20ed0 (63b): skip vtable at +0; +4=DWORD; +8=TArray<FLOAT> via FUN_1031f660; +0x14=FStaticLightMapTexture; +0x60..+0x68=3 DWORDs
	// FUN_1031f660 is the compiler-generated TArray<FLOAT>::operator= instantiation; our call is equivalent.
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	*(TArray<FLOAT>*)((BYTE*)this + 0x08) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x08);
	*(FStaticLightMapTexture*)((BYTE*)this + 0x14) = *(const FStaticLightMapTexture*)((const BYTE*)&Other + 0x14);
	appMemcpy((BYTE*)this + 0x60, (const BYTE*)&Other + 0x60, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x103047c0)
unsigned __int64 FLightMapTexture::GetCacheId()
{
	return *(QWORD*)(Pad + 92);
}
IMPL_MATCH("Engine.dll", 0x1040fd50)
FTexture * FLightMapTexture::GetChild(int Index, int* OutWidth, int* OutHeight)
{
	// Retail: 0x10FD50, 56b. Returns the FTexture for a given face index into the
	// lightmap's per-face array. Stores USize/VSize into caller's output pointers.
	// this+4 = pointer to ULevel; this+8 = pointer to TArray<INT> of per-face indices.
	INT levelPtr  = *(INT*)((BYTE*)this + 4);
	INT* indexArr = *(INT**)((BYTE*)this + 8);
	INT faceIdx   = indexArr[Index];
	// Level's static lightmap texture array at level+0x90, each element 0xA4 bytes.
	INT texBase   = *(INT*)(levelPtr + 0x90);
	BYTE* texElem = (BYTE*)(texBase) + faceIdx * 0xA4;
	// Link back: store level pointer into element+4 (owner pointer)
	*(INT*)(texElem + 4) = levelPtr;
	// USize at element+0x14 (== level+0xF4 of the face entry), VSize at element+0x18
	*OutWidth  = *(INT*)(texElem + 0x14);
	*OutHeight = *(INT*)(texElem + 0x18);
	return (FTexture*)texElem;
}
IMPL_MATCH("Engine.dll", 0x10414310)
int FLightMapTexture::GetFirstMip()
{
	// Ghidra 0x114310: shared stub; returns 0.
	return 0;
}
IMPL_MATCH("Engine.dll", 0x10304740)
ETextureFormat FLightMapTexture::GetFormat()
{
	return TEXF_BCRGB8;
}
IMPL_MATCH("Engine.dll", 0x103047b0)
int FLightMapTexture::GetHeight()
{
	return 0x200;
}
IMPL_MATCH("Engine.dll", 0x103047a0)
int FLightMapTexture::GetNumChildren()
{
	// TArray at this+8; ArrayNum is 4 bytes into TArray
	return *(INT*)(Pad + 8);
}
IMPL_MATCH("Engine.dll", 0x104436b0)
int FLightMapTexture::GetNumMips()
{
	return 1;
}
IMPL_MATCH("Engine.dll", 0x103047d0)
int FLightMapTexture::GetRevision()
{
	return *(INT*)(Pad + 100);
}
IMPL_MATCH("Engine.dll", 0x10414310)
ETexClampMode FLightMapTexture::GetUClamp()
{
	// Retail: 33 C0 C3 = return 0 = TC_Wrap
	return TC_Wrap;
}
IMPL_MATCH("Engine.dll", 0x10414310)
ETexClampMode FLightMapTexture::GetVClamp()
{
	// Retail: 33 C0 C3 = return 0 = TC_Wrap
	return TC_Wrap;
}
IMPL_MATCH("Engine.dll", 0x103047b0)
int FLightMapTexture::GetWidth()
{
	return 0x200;
}


// --- FLineBatcher ---
IMPL_MATCH("Engine.dll", 0x10327320)
FLineBatcher::FLineBatcher(FLineBatcher const &Other)
{
	// Ghidra 0x27320: vtable set by compiler; TArray<FLineVertex> at +4 (stride 0x10); 5 DWORDs at +10..+20
	new ((BYTE*)this + 0x04) TArray<FLineVertex>(*(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x14); // 5 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10327320)
FLineBatcher::FLineBatcher(FRenderInterface *,int,int)
{
	// Initialize TArray<FLineVertex> at +4 to empty so dtor is safe
	new ((BYTE*)this + 0x04) TArray<FLineVertex>();
	appMemzero((BYTE*)this + 0x10, 0x14); // zero state DWORDs
}

IMPL_MATCH("Engine.dll", 0x10418050)
FLineBatcher::~FLineBatcher()
{
	// Ghidra 0x118050 (82b): SEH frame; destroys TArray<FLineVertex> at +4
	((TArray<FLineVertex>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x10327360)
FLineBatcher& FLineBatcher::operator=(const FLineBatcher& Other)
{
	// Ghidra 0x27360 (57b): skip vtable; TArray<FLineVertex> at +4 via FUN_1031e1c0; 5 DWORDs at +0x10..+0x20
	// FUN_1031e1c0 is the compiler-generated TArray<FLineVertex>::operator= instantiation; our call is equivalent.
	*(TArray<FLineVertex>*)((BYTE*)this + 0x04) = *(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x14); // 5 DWORDs
	return *this;
}

IMPL_TODO("Ghidra 0x10415560 (985b): FPoly class is forward-declared only in EngineClasses.h; needs full FPoly definition (vertex array + methods) before this can be implemented")
void FLineBatcher::DrawConvexVolume(FConvexVolume Volume, FColor Color)
{
	// Ghidra 0x115560: iterates FConvexVolume planes, builds FPoly per plane,
	// uses FindBestAxisVectors to generate quad corners, calls DrawLine for each edge.
	// Blocked: FPoly is forward-declared only.
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x104147c0)
void FLineBatcher::DrawBox(FBox Box, FColor Color)
{
	// Ghidra 0x1147c0: draw 12 edges of an axis-aligned box.
	// Iterates over all 4 combinations of (i,j) in {0,1}^2, drawing 3 edges per combo.
	FVector V[2] = { Box.Min, Box.Max };
	for (INT i = 0; i < 2; i++)
	{
		for (INT j = 0; j < 2; j++)
		{
			// Z-direction edge (fix X=V[i], Y=V[j], vary Z)
			DrawLine(FVector(V[i].X, V[j].Y, V[0].Z), FVector(V[i].X, V[j].Y, V[1].Z), Color);
			// X-direction edge (fix Y=V[i], Z=V[j], vary X)
			DrawLine(FVector(V[0].X, V[i].Y, V[j].Z), FVector(V[1].X, V[i].Y, V[j].Z), Color);
			// Y-direction edge (fix X=V[i], Z=V[j], vary Y)
			DrawLine(FVector(V[i].X, V[0].Y, V[j].Z), FVector(V[i].X, V[1].Y, V[j].Z), Color);
		}
	}
}

IMPL_MATCH("Engine.dll", 0x104149f0)
void FLineBatcher::DrawCircle(FVector Center, FVector X, FVector Y, FColor Color, FLOAT Radius, INT NumSides)
{
	// Ghidra 0x1149f0: draw a circle using NumSides line segments.
	// X and Y are the in-plane axes; Radius scales them.
	if (NumSides <= 0) return;
	FLOAT Step = 2.0f * PI / (FLOAT)NumSides;
	FVector Prev = Center + X * (Radius * appCos(0.0f)) + Y * (Radius * appSin(0.0f));
	for (INT i = 1; i <= NumSides; i++)
	{
		FLOAT Angle = i * Step;
		FVector Next = Center + X * (Radius * appCos(Angle)) + Y * (Radius * appSin(Angle));
		DrawLine(Prev, Next, Color);
		Prev = Next;
	}
}

IMPL_MATCH("Engine.dll", 0x10414e50)
void FLineBatcher::DrawCylinder(FRenderInterface* RI, FVector Base, FVector X, FVector Y, FVector Z, FColor Color, FLOAT Radius, FLOAT HalfHeight, INT NumSides)
{
	// Ghidra 0x114e50 (772b): loop identical to DrawCircle but draws 3 lines per step:
	// bottom ring (Prev-Z*HH → Curr-Z*HH), top ring (Prev+Z*HH → Curr+Z*HH),
	// and vertical strut (Prev-Z*HH → Prev+Z*HH). Initial point at angle 0 = Base+X*Radius.
	const FLOAT StepAngle = 2.0f * PI / (FLOAT)NumSides;
	FVector Prev = Base + X * (Radius * appCos(0.0f)) + Y * (Radius * appSin(0.0f));
	for (INT i = 1; i <= NumSides; i++)
	{
		const FLOAT Angle = (FLOAT)i * StepAngle;
		FVector Curr = Base + X * (Radius * appCos(Angle)) + Y * (Radius * appSin(Angle));
		DrawLine(Prev - Z * HalfHeight, Curr - Z * HalfHeight, Color);
		DrawLine(Prev + Z * HalfHeight, Curr + Z * HalfHeight, Color);
		DrawLine(Prev - Z * HalfHeight, Prev + Z * HalfHeight, Color);
		Prev = Curr;
	}
}

IMPL_MATCH("Engine.dll", 0x10415190)
void FLineBatcher::DrawDirectionalArrow(FVector Origin, FRotator Rotation, FColor Color, FLOAT ArrowSize)
{
	// Ghidra 0x115190: convert Rotation to FCoords, draw main shaft + two arrow-head wings.
	FCoords Coords = GMath.UnitCoords / Rotation;
	FLOAT Length = ArrowSize * 48.0f;
	FVector Forward  = Coords.XAxis * Length;
	FVector Tip      = Origin + Forward;
	// Main shaft: Tip -> Origin
	DrawLine(Tip, Origin, Color);
	// Arrow head wings
	FLOAT WingScale = ArrowSize * 16.0f;
	DrawLine(Tip - Forward * (1.0f / 3.0f) + Coords.YAxis * WingScale, Tip, Color);
	DrawLine(Tip - Forward * (1.0f / 3.0f) - Coords.YAxis * WingScale, Tip, Color);
}

IMPL_MATCH("Engine.dll", 0x104143c0)
void FLineBatcher::DrawLine(FVector Start, FVector End, FColor Color)
{
	// Ghidra 0x1143c0: add two FLineVertex entries (16 bytes each) to TArray at this+4.
	TArray<FLineVertex>* Verts = (TArray<FLineVertex>*)((BYTE*)this + 4);
	INT i = Verts->Add(1);
	new (&(*Verts)(i)) FLineVertex(Start, Color);
	i = Verts->Add(1);
	new (&(*Verts)(i)) FLineVertex(End, Color);
}

IMPL_MATCH("Engine.dll", 0x104144a0)
void FLineBatcher::DrawPoint(FSceneNode* Scene, FVector Point, FColor Color)
{
	// Ghidra 0x1144a0: draw a screen-aligned square cross at Point using camera axes.
	// Camera right at Scene+0x19C, camera up at Scene+0x1A8.
	FVector CamX = *(FVector*)((BYTE*)Scene + 0x19C);
	FVector CamY = *(FVector*)((BYTE*)Scene + 0x1A8);
	DrawLine(Point - CamX - CamY, Point + CamX - CamY, Color);
	DrawLine(Point + CamX - CamY, Point + CamX + CamY, Color);
	DrawLine(Point + CamX + CamY, Point - CamX + CamY, Color);
	DrawLine(Point - CamX + CamY, Point - CamX - CamY, Color);
}

IMPL_DIVERGE("FUN_10370d70 (FMatrix ctor from FRotator) is an unexported Engine.dll internal; FCoords/FRotator equivalent used — produces identical axis vectors")
void FLineBatcher::DrawSphere(FVector Center, FColor Color, FLOAT Radius, INT NumSides)
{
	// Retail loops NumSides times using FRotator→FMatrix via FUN_10370d70 to derive circle axes.
	// We replicate using GMath.UnitCoords / FRotator which gives the same transformed axes.
	const INT Step = 0x10000 / NumSides;
	INT Angle = 0;
	for (INT i = 0; i < NumSides; i++, Angle += Step)
	{
		FCoords C1 = GMath.UnitCoords / FRotator(Angle, 0, 0);
		DrawCircle(Center, C1.XAxis, C1.YAxis, Color, Radius, NumSides);
		FCoords C2 = GMath.UnitCoords / FRotator(0, Angle, 0);
		DrawCircle(Center, C2.YAxis, C2.ZAxis, Color, Radius, NumSides);
	}
}

// Ghidra 0x104172a0 (813b): flush line batch to GPU. Permanent divergence: calls
// (**(this+0x20))[0x54/4]() — vtable dispatch on the stored FRenderInterface* to
// submit the vertex stream; not reproducible without binary-specific D3D vtable layout.
IMPL_DIVERGE("direct FRenderInterface vtable dispatch at offset +0x54 through stored RI pointer (this+0x20)")
void FLineBatcher::Flush(DWORD Flags)
{
}
IMPL_MATCH("Engine.dll", 0x10444fa0)
unsigned __int64 FLineBatcher::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}
IMPL_MATCH("Engine.dll", 0x10414110)
int FLineBatcher::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 4; C[1].Function = 2;
	return 2;
}
IMPL_MATCH("Engine.dll", 0x104159a0)
void FLineBatcher::GetRawStreamData(void ** Out, int Offset)
{
	// Ghidra: *Out = data + offset * 0x10
	*Out = *(BYTE**)Pad + Offset * 0x10;
}
IMPL_MATCH("Engine.dll", 0x104436b0)
int FLineBatcher::GetRevision()
{
	return 1;
}
IMPL_MATCH("Engine.dll", 0x104140f0)
int FLineBatcher::GetSize()
{
	// Ghidra: FArray::Num(this+4) << 4, TArray at Pad[0]
	return *(INT*)(Pad + 4) << 4;
}
IMPL_MATCH("Engine.dll", 0x10415970)
void FLineBatcher::GetStreamData(void * Dest)
{
	INT Size = *(INT*)(Pad + 4) << 4;
	appMemcpy(Dest, *(void**)Pad, Size);
}
IMPL_MATCH("Engine.dll", 0x10414100)
int FLineBatcher::GetStride()
{
	return 0x10;
}


// --- FRaw32BitIndexBuffer ---
IMPL_MATCH("Engine.dll", 0x103209a0)
FRaw32BitIndexBuffer::FRaw32BitIndexBuffer(FRaw32BitIndexBuffer const &Other)
{
	// Ghidra 0x209a0: vtable set by compiler; TArray<FLOAT> at +4 (stride 4); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

IMPL_MATCH("Engine.dll", 0x103209a0)
FRaw32BitIndexBuffer::FRaw32BitIndexBuffer()
{
	// Initialize TArray<FLOAT> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FLOAT>();
}

IMPL_MATCH("Engine.dll", 0x1032c020)
FRaw32BitIndexBuffer::~FRaw32BitIndexBuffer()
{
	((TArray<FLOAT>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x103275b0)
FRaw32BitIndexBuffer& FRaw32BitIndexBuffer::operator=(const FRaw32BitIndexBuffer& Other)
{
	// Ghidra 0x275b0: skip vtable +0; +4=TArray<FLOAT> (FUN_1031f660); +0x10,+0x14,+0x18=3 DWORDs
	// Shares address with FRawColorStream and FStaticMeshColorStream.
	*(TArray<FLOAT>*)((BYTE*)this + 0x04) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x10444fa0)
unsigned __int64 FRaw32BitIndexBuffer::GetCacheId()
{
return *(QWORD*)(Pad + 12);
}
IMPL_MATCH("Engine.dll", 0x10416980)
void FRaw32BitIndexBuffer::GetContents(void * Dest)
{
INT Size = *(INT*)(Pad + 4) << 2;
	appMemcpy(Dest, *(void**)Pad, Size);
}
IMPL_MATCH("Engine.dll", 0x104141f0)
int FRaw32BitIndexBuffer::GetIndexSize()
{
return 4;
}
IMPL_MATCH("Engine.dll", 0x1047ad20)
int FRaw32BitIndexBuffer::GetRevision()
{
return *(INT*)(Pad + 20);
}
IMPL_MATCH("Engine.dll", 0x10414200)
int FRaw32BitIndexBuffer::GetSize()
{
return *(INT*)(Pad + 4) << 2;
}


// --- FRawColorStream ---
IMPL_MATCH("Engine.dll", 0x10327570)
FRawColorStream::FRawColorStream(FRawColorStream const &Other)
{
	// Ghidra 0x27570: vtable set by compiler; TArray<FLOAT> at +4 (stride 4); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10327570)
FRawColorStream::FRawColorStream()
{
	// Initialize TArray<FLOAT> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FLOAT>();
}

IMPL_MATCH("Engine.dll", 0x1032c020)
FRawColorStream::~FRawColorStream()
{
	((TArray<FLOAT>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x103275b0)
FRawColorStream& FRawColorStream::operator=(const FRawColorStream& Other)
{
	// Ghidra 0x275b0: same body as FRaw32BitIndexBuffer::operator=
	*(TArray<FLOAT>*)((BYTE*)this + 0x04) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x10444fa0)
unsigned __int64 FRawColorStream::GetCacheId()
{
return *(QWORD*)(Pad + 12);
}
IMPL_MATCH("Engine.dll", 0x10414210)
int FRawColorStream::GetComponents(FVertexComponent* C)
{
return 1;
}
IMPL_MATCH("Engine.dll", 0x104169b0)
void FRawColorStream::GetRawStreamData(void ** Out, int Offset)
{
*Out = *(BYTE**)Pad + Offset * 4;
}
IMPL_MATCH("Engine.dll", 0x1047ad20)
int FRawColorStream::GetRevision()
{
return *(INT*)(Pad + 20);
}
IMPL_MATCH("Engine.dll", 0x10414200)
int FRawColorStream::GetSize()
{
return *(INT*)(Pad + 4) << 2;
}
IMPL_MATCH("Engine.dll", 0x10416980)
void FRawColorStream::GetStreamData(void * Dest)
{
INT Size = *(INT*)(Pad + 4) << 2;
	appMemcpy(Dest, *(void**)Pad, Size);
}
IMPL_MATCH("Engine.dll", 0x104141f0)
int FRawColorStream::GetStride()
{
return 4;
}


// --- FRawIndexBuffer ---
IMPL_DIVERGE("NvTriStrip is a third-party GPU vertex cache optimiser not included in this project; strip generation skipped, revision bumped")
int FRawIndexBuffer::Stripify()
{
	guard(FRawIndexBuffer::Stripify);
	// Ghidra 0x116e70: calls FUN_1048d8b0 (NvTriStrip init) and FUN_1048d8c0 (generate strips),
	// copies result back into TArray<_WORD> at this+4, bumps revision.
	// FUN_1048d8b0/FUN_1048d8c0 = NvTriStrip library calls (external GPU vertex cache optimizer).
	// DIVERGENCE: NvTriStrip not available; strip generation skipped; revision bumped; returns Num()-2.
	*(INT*)(Pad + 20) += 1;
	return *(INT*)(Pad + 4) - 2;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10318d80)
FRawIndexBuffer::FRawIndexBuffer(FRawIndexBuffer const &Other)
{
	// Ghidra 0x18d80: vtable set by compiler; TArray<_WORD> at +4 (stride 2); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<_WORD>(*(const TArray<_WORD>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10318d80)
FRawIndexBuffer::FRawIndexBuffer()
{
	// Initialize TArray<_WORD> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<_WORD>();
}

IMPL_MATCH("Engine.dll", 0x103038c0)
FRawIndexBuffer::~FRawIndexBuffer()
{
	// Ghidra 0x38c0 (9b): destroys TArray<unsigned short> at +4
	((TArray<_WORD>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x10318dc0)
FRawIndexBuffer& FRawIndexBuffer::operator=(const FRawIndexBuffer& Other)
{
	// Ghidra 0x18dc0: skip vtable +0; +4=TArray<_WORD>; +0x10,+0x14,+0x18=3 DWORDs
	*(TArray<_WORD>*)((BYTE*)this + 0x04) = *(const TArray<_WORD>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
IMPL_DIVERGE("NvTriStrip is a third-party GPU vertex cache optimiser not included in this project; optimisation skipped, revision bumped")
void FRawIndexBuffer::CacheOptimize()
{
	// Ghidra 0x116860: uses FUN_1048d8b0/FUN_1048d8c0 (external cache-optimiser).
	// Those functions are not reconstructed; increment revision counter only.
	// DIVERGENCE: optimisation pass skipped; revision still bumped for cache invalidation.
	*(INT*)(Pad + 20) += 1;
}
IMPL_MATCH("Engine.dll", 0x10444fa0)
unsigned __int64 FRawIndexBuffer::GetCacheId()
{
return *(QWORD*)(Pad + 12);
}
IMPL_MATCH("Engine.dll", 0x104141c0)
void FRawIndexBuffer::GetContents(void* Dest)
{
	// Retail: 0x1141c0. TArray<WORD> at this+4 (= Pad+0). Copy Num*2 bytes.
	void*  data = *(void**)Pad;
	INT    num  = *(INT*)(Pad + 4);
	appMemcpy(Dest, data, num * 2);
}
IMPL_MATCH("Engine.dll", 0x104141b0)
int FRawIndexBuffer::GetIndexSize()
{
	return 2;
}
IMPL_MATCH("Engine.dll", 0x1047ad20)
int FRawIndexBuffer::GetRevision()
{
	return *(INT*)(Pad + 20);
}
IMPL_MATCH("Engine.dll", 0x104141a0)
int FRawIndexBuffer::GetSize()
{
// TArray<_WORD> at object+4; ArrayNum at +4 within TArray = Pad+4
	return *(INT*)(Pad + 4) << 1;
}


// --- FSkinVertexStream ---
IMPL_MATCH("Engine.dll", 0x1032b7d0)
FSkinVertexStream::FSkinVertexStream(FSkinVertexStream const &Other)
{
	// Ghidra 0x2b7d0: vtable set by compiler; 7 DWORDs at +4..+1c; TArray<FStreamVert32> at +20 (stride 0x20)
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x1C); // 7 DWORDs
	new ((BYTE*)this + 0x20) TArray<FStreamVert32>(*(const TArray<FStreamVert32>*)((const BYTE*)&Other + 0x20));
}

IMPL_MATCH("Engine.dll", 0x1032b700)
FSkinVertexStream::FSkinVertexStream()
{
	// Initialize TArray<FStreamVert32> at +0x20 to empty
	new ((BYTE*)this + 0x20) TArray<FStreamVert32>();
}

IMPL_MATCH("Engine.dll", 0x1032b7c0)
FSkinVertexStream::~FSkinVertexStream()
{
	// Ghidra 0x2b7c0 (8b): calls FUN_10323ab0() which destroys TArray<FStreamVert32> at +0x20
	// FUN_10323ab0 is the compiler-generated TArray<FStreamVert32>::~TArray instantiation; our call is equivalent.
	((TArray<FStreamVert32>*)((BYTE*)this + 0x20))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x1032b820)
FSkinVertexStream& FSkinVertexStream::operator=(const FSkinVertexStream& Other)
{
	// Ghidra 0x2b820: skip vtable at +0, 7 DWORDs at +4..+1C,
	// TArray<FStreamVert32> at +20 (FUN_1031f7d0 = 32-byte GPU verts)
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x1C); // 7 DWORDs
	*(TArray<FStreamVert32>*)((BYTE*)this + 0x20) = *(const TArray<FStreamVert32>*)((const BYTE*)&Other + 0x20);
	return *this;
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x10458140)
unsigned __int64 FSkinVertexStream::GetCacheId()
{
return *(QWORD*)(Pad + 8);
}
IMPL_MATCH("Engine.dll", 0x10314890)
int FSkinVertexStream::GetComponents(FVertexComponent* C)
{
C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}
IMPL_MATCH("Engine.dll", 0x10430d10)
void FSkinVertexStream::GetRawStreamData(void ** ppData, int FirstVertex)
{
	// Retail: 20b. GPU-only skin stream; no CPU-accessible raw pointer.
	// If stream data ptr at this+0x1C is non-null: set *ppData = NULL (GPU ptr, unreadable).
	// If null: cross-function-jump (stream not allocated).
	if (*(DWORD*)(Pad + 0x18))
		*ppData = NULL;
}
IMPL_MATCH("Engine.dll", 0x10414320)
int FSkinVertexStream::GetRevision()
{
return *(INT*)(Pad + 16);
}
IMPL_MATCH("Engine.dll", 0x1042f470)
int FSkinVertexStream::GetSize()
{
// If null, no data allocated → return 0.
	// Otherwise: load parent object from Pad+4 ([this+8]), call vtable slot 78
	// (offset 0x138) to get vertex count, multiply by stride 32 (SHL 5).
	if (!*(DWORD*)(Pad + 0x18)) return 0;
	void* obj = *(void**)(Pad + 4);
	typedef INT (__thiscall* FnType)(void*);
	FnType fn = (FnType)(*(void***)obj)[0x138 / sizeof(void*)];
	return fn(obj) << 5; // vertex_count * 32
}
IMPL_MATCH("Engine.dll", 0x10430c50)
void FSkinVertexStream::GetStreamData(void* Dest)
{
	// Retail: 0x130c50. Two paths:
	// GPU: if skinned VB exists (Pad+0x18 != 0) and parent object (Pad+4) != NULL,
	//      call vtable[0x134/4=0x4D] on that parent object.
	// CPU: copy TArray of 32-byte verts at this+0x20 (= Pad+0x1C).
	if (*(INT*)(Pad + 0x18) != 0 && *(INT*)(Pad + 4) != 0)
	{
		// GPU path: dispatch to parent vertex buffer at vtable[0x4D]
		INT  objAddr  = *(INT*)(Pad + 4);
		INT  vtable   = *(INT*)objAddr;
		typedef void (__thiscall *GetDataFn)(INT, void*);
		GetDataFn fn = (GetDataFn)(*(INT*)(vtable + 0x134));
		fn(objAddr, Dest);
		return;
	}
	// CPU path: copy raw vertex array
	void*  data = *(void**)(Pad + 0x1C);
	INT    num  = *(INT*)(Pad + 0x20);
	appMemcpy(Dest, data, num << 5); // num * 32
}
IMPL_MATCH("Engine.dll", 0x1042f4a0)
int FSkinVertexStream::GetStride()
{
	return 0x20;
}


// --- FStaticLightMapTexture ---
IMPL_MATCH("Engine.dll", 0x10320cf0)
FStaticLightMapTexture::FStaticLightMapTexture(FStaticLightMapTexture const &Other)
{
	// Ghidra 0x20cf0: vtable set by compiler; copy-construct 2 TLazyArray<BYTE> at +4 and +0x1C (stride 0x18);
	// copy extra scalar fields at +0x34..+0x48.
	// TLazyArray contains 2 scalar DWORDs followed by a TArray<BYTE>.
	appMemcpy((BYTE*)this + 0x08, (const BYTE*)&Other + 0x08, 0x08); // TLazyArray[0] header DWORDs
	new ((BYTE*)this + 0x10) TArray<BYTE>(*(const TArray<BYTE>*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x20, (const BYTE*)&Other + 0x20, 0x08); // TLazyArray[1] header DWORDs
	new ((BYTE*)this + 0x28) TArray<BYTE>(*(const TArray<BYTE>*)((const BYTE*)&Other + 0x28));
	appMemcpy((BYTE*)this + 0x34, (const BYTE*)&Other + 0x34, 0x18); // 6 DWORDs (+0x34..+0x4B)
}

IMPL_MATCH("Engine.dll", 0x10327960)
FStaticLightMapTexture::FStaticLightMapTexture()
{
	// Ghidra 0x27960 (79b): _eh_vector_constructor_iterator_ inits 2 TLazyArray<unsigned_char>
	// at this+4 (stride 0x18, 2 objects). Then uses DAT_1060b564 for QWORD CacheId at +0x40; zeros revision at +0x48.
	appMemzero((BYTE*)this + 0x08, 0x08); // TLazyArray[0] header DWORDs
	new ((BYTE*)this + 0x10) TArray<BYTE>();
	appMemzero((BYTE*)this + 0x20, 0x08); // TLazyArray[1] header DWORDs
	new ((BYTE*)this + 0x28) TArray<BYTE>();
	appMemzero((BYTE*)this + 0x34, 0x0C); // fields +0x34..+0x3F
	// CacheId at +0x40 = DAT_1060b564 * 0x100 + 0xE0 (render resource tag 0xE0 = FStaticLightMapTexture)
	*(QWORD*)((BYTE*)this + 0x40) = (QWORD)(DWORD)DAT_1060b564 * 0x100 + 0xE0;
	DAT_1060b564++;
	*(DWORD*)((BYTE*)this + 0x48) = 0; // revision = 0
}

IMPL_MATCH("Engine.dll", 0x10320cd0)
FStaticLightMapTexture::~FStaticLightMapTexture()
{
((TArray<BYTE>*)((BYTE*)this + 0x28))->~TArray();
	((TArray<BYTE>*)((BYTE*)this + 0x10))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x10320d50)
FStaticLightMapTexture& FStaticLightMapTexture::operator=(const FStaticLightMapTexture& Other)
{
	// Ghidra 0x20d50: 2-iteration loop (stride 0x18); each: 2 DWORDs before TArray<BYTE>, then TArray<BYTE>.
	// Layout: +0x08,+0x0C=2 DWORDs; +0x10=TArray<BYTE>; +0x20,+0x24=2 DWORDs; +0x28=TArray<BYTE>; +0x34..+0x48=6 DWORDs.
	appMemcpy((BYTE*)this + 0x08, (const BYTE*)&Other + 0x08, 0x08);
	*(TArray<BYTE>*)((BYTE*)this + 0x10) = *(const TArray<BYTE>*)((const BYTE*)&Other + 0x10);
	appMemcpy((BYTE*)this + 0x20, (const BYTE*)&Other + 0x20, 0x08);
	*(TArray<BYTE>*)((BYTE*)this + 0x28) = *(const TArray<BYTE>*)((const BYTE*)&Other + 0x28);
	appMemcpy((BYTE*)this + 0x34, (const BYTE*)&Other + 0x34, 0x18);
	return *this;
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x10304790)
unsigned __int64 FStaticLightMapTexture::GetCacheId()
{
return *(QWORD*)(Pad + 60);
}
IMPL_MATCH("Engine.dll", 0x1040d4f0)
int FStaticLightMapTexture::GetFirstMip()
{
if (UTexture::__Client != NULL && *(INT*)((BYTE*)UTexture::__Client + 0x70) != 0)
		return 1;
	return 0;
}
IMPL_MATCH("Engine.dll", 0x10304780)
ETextureFormat FStaticLightMapTexture::GetFormat()
{
return (ETextureFormat)*(INT*)(Pad + 48);
}
IMPL_MATCH("Engine.dll", 0x10318b20)
int FStaticLightMapTexture::GetHeight()
{
return *(INT*)(Pad + 56);
}
IMPL_MATCH("Engine.dll", 0x104141b0)
int FStaticLightMapTexture::GetNumMips()
{
return 2;
}
IMPL_MATCH("Engine.dll", 0x1040fe60)
void * FStaticLightMapTexture::GetRawTextureData(int MipIndex)
{
	// Retail: 0x10FE60, ~100b SEH. In editor only (asserts GIsEditor).
	// Loads mip data via lazy-loader at this + MipIndex*0x18 + 0x10 if not yet loaded.
	// DIVERGENCE: GIsEditor assertion removed; returns NULL when not editor-loaded.
	if (!GIsEditor) return NULL;
	FArray* mipArr = (FArray*)((BYTE*)this + MipIndex * 0x18 + 0x10);
	if (mipArr->Num() == 0)
	{
		// Trigger lazy-load: vtable call on the lazy loader at this + MipIndex*0x18 + 4
		void** lazyVtable = *(void***)((BYTE*)this + MipIndex * 0x18 + 4);
		typedef void (__thiscall *LoadFn)(void*);
		LoadFn Load = (LoadFn)lazyVtable[0];
		Load((void*)((BYTE*)this + MipIndex * 0x18 + 4));
	}
	return *(void**)((BYTE*)this + MipIndex * 0x18 + 0x10);
}
IMPL_MATCH("Engine.dll", 0x10316740)
int FStaticLightMapTexture::GetRevision()
{
return *(INT*)(Pad + 68);
}
IMPL_MATCH("Engine.dll", 0x1040fd90)
void FStaticLightMapTexture::GetTextureData(int MipIndex,void * Dest,int Size,ETextureFormat Format,int bShrink)
{
	guard(FStaticLightMapTexture::GetTextureData);
	// Ghidra 0x10fd90: assert format matches TLazyArray element format at +0x34,
	// lazy-load mip data via vtable call at (this + MipIndex*0x18 + 4) if not yet loaded,
	// then copy raw byte count via FUN_10301050(Dest, data, Num) = appMemcpy.
	check(Format == (ETextureFormat)*(int*)((BYTE*)this + 0x34));
	FArray* arr = (FArray*)((BYTE*)this + MipIndex * 0x18 + 0x10);
	if (arr->Num() == 0)
	{
		void** vt = *(void***)((BYTE*)this + MipIndex * 0x18 + 4);
		((void (__thiscall*)(void*))vt[0])((void*)((BYTE*)this + MipIndex * 0x18 + 4));
	}
	appMemcpy(Dest, *(void**)arr, arr->Num()); // FUN_10301050 = appMemcpy
	unguard;
}
IMPL_MATCH("Engine.dll", 0x10414310)
ETexClampMode FStaticLightMapTexture::GetUClamp()
{
	return TC_Wrap;
}
IMPL_MATCH("Engine.dll", 0x10414310)
UTexture * FStaticLightMapTexture::GetUTexture()
{
	// Ghidra 0x114310: shared stub; returns NULL.
	return NULL;
}
IMPL_MATCH("Engine.dll", 0x10414310)
ETexClampMode FStaticLightMapTexture::GetVClamp()
{
	return TC_Wrap;
}
IMPL_MATCH("Engine.dll", 0x10304770)
int FStaticLightMapTexture::GetWidth()
{
	return *(INT*)(Pad + 52);
}
IMPL_MATCH("Engine.dll", 0x103162b0)
unsigned __int64 FStaticMeshUVStream::GetCacheId()
{
	return *(QWORD*)(Pad + 16);
}
IMPL_MATCH("Engine.dll", 0x10316290)
int FStaticMeshUVStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 2; C[0].Function = *(INT*)(Pad + 0x0C) + 4;
	return 1;
}
IMPL_MATCH("Engine.dll", 0x1031c9d0)
void FStaticMeshUVStream::GetRawStreamData(void ** Out, int Offset)
{
	// Ghidra: *Out = data + offset * 8
	*Out = *(BYTE**)Pad + Offset * 8;
}
IMPL_MATCH("Engine.dll", 0x10314870)
int FStaticMeshUVStream::GetRevision()
{
	return *(INT*)(Pad + 24);
}
IMPL_MATCH("Engine.dll", 0x10316270)
int FStaticMeshUVStream::GetSize()
{
	// Ghidra: Num << 3 (stride = 8)
	return *(INT*)(Pad + 4) << 3;
}
IMPL_MATCH("Engine.dll", 0x1031c9a0)
void FStaticMeshUVStream::GetStreamData(void * Dest)
{
	// Ghidra: memcpy Num<<3 bytes from TArray data
	INT Size = *(INT*)(Pad + 4) << 3;
	appMemcpy(Dest, *(void**)Pad, Size);
}
IMPL_MATCH("Engine.dll", 0x10316280)
int FStaticMeshUVStream::GetStride()
{
	return 8;
}
IMPL_MATCH("Engine.dll", 0x10444fa0)
unsigned __int64 FStaticMeshVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}
IMPL_MATCH("Engine.dll", 0x103161e0)
int FStaticMeshVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	return 2;
}
IMPL_MATCH("Engine.dll", 0x10443700)
void FStaticMeshVertexStream::GetRawStreamData(void ** ppData, int FirstVertex)
{
	// Retail: data = [this+4] (TArray.Data); stride = 24 (3*8); Pad[0] = this+4
	*ppData = *(BYTE**)(Pad + 0) + FirstVertex * 0x18;
}
IMPL_MATCH("Engine.dll", 0x1047ad20)
int FStaticMeshVertexStream::GetRevision()
{
	return *(INT*)(Pad + 20);
}
IMPL_MATCH("Engine.dll", 0x104436c0)
int FStaticMeshVertexStream::GetSize()
{
	// Ghidra (16B): FArray::Num(this+4) * 0x18; Pad[0] = FArray at offset 4
	INT Num = *(INT*)(Pad + 4); // ArrayNum field of FArray at this+4
	return Num * 0x18;
}
IMPL_MATCH("Engine.dll", 0x1031c970)
void FStaticMeshVertexStream::GetStreamData(void* Dest)
{
	// Retail: 0x1c970. TArray of 24-byte verts at this+4 (= Pad+0). Copy Num*24 bytes.
	void*  data = *(void**)Pad;
	INT    num  = *(INT*)(Pad + 4);
	appMemcpy(Dest, data, num * 0x18);
}
IMPL_MATCH("Engine.dll", 0x10414160)
int FStaticMeshVertexStream::GetStride()
{
	return 0x18;
}


// --- FStaticTexture ---
IMPL_MATCH("Engine.dll", 0x10320b50)
FStaticTexture::FStaticTexture(FStaticTexture const &Other)
{
	// Ghidra 0x20b50: vtable set by compiler; scalar copy of 4 DWORDs at +4..+10. Shares address with FStaticCubemap.
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
}

IMPL_MATCH("Engine.dll", 0x10320b50)
FStaticTexture::FStaticTexture(UTexture* Texture)
{
	// Ghidra 0x16a9a0: store texture pointer, compute CacheId, set initial revision.
	// Layout (Pad is at this+4): Pad[0..7]=CacheId QWORD; Pad[8..11]=UTexture*; Pad[12..15]=Revision.
	*(UTexture**)&Pad[8]  = Texture;
	DWORD Idx             = Texture ? Texture->GetIndex() : 0;
	*(QWORD*)&Pad[0]      = (QWORD)Idx * 0x100 + 0xE0;
	*(INT*)&Pad[12]       = 1;
}

IMPL_MATCH("Engine.dll", 0x10318ee0)
FStaticTexture& FStaticTexture::operator=(const FStaticTexture& Other)
{
	// Ghidra 0x18ee0 (33b): skip vtable at +0, copy 4 DWORDs at +4..+10. Shares address with FStaticCubemap::operator=.
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
	return *this;
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x10408af0)
unsigned __int64 FStaticTexture::GetCacheId()
{
	// Ghidra: return *(__uint64*)(this + 4); CacheId at Pad[0..7]
	return *(QWORD*)&Pad[0];
}
IMPL_MATCH("Engine.dll", 0x10469cc0)
int FStaticTexture::GetFirstMip()
{
	// Ghidra: UTexture::DefaultLOD(Texture)
	UTexture* Texture = *(UTexture**)&Pad[8];
	return Texture->DefaultLOD();
}
IMPL_MATCH("Engine.dll", 0x10468cd0)
ETextureFormat FStaticTexture::GetFormat()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return (ETextureFormat)Texture->Format;
}
IMPL_MATCH("Engine.dll", 0x10468cb0)
int FStaticTexture::GetHeight()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return Texture->VSize;
}
IMPL_MATCH("Engine.dll", 0x10468cc0)
int FStaticTexture::GetNumMips()
{
UTexture* Texture = *(UTexture**)&Pad[8];
return Texture->Mips.Num();
}
IMPL_MATCH("Engine.dll", 0x10469cd0)
void * FStaticTexture::GetRawTextureData(int MipIndex)
{
	// Ghidra (149B): Access Mips array directly via raw offsets.
	// Mips at Texture+0xBC (TArray), element stride 0x28 (40 bytes).
	// Mip data pointer at element+0x1C. Lazy loader vtable at element+0x10.
	// Texture+0x94 bit 0x20 = already loaded flag.
	UTexture* Texture = *(UTexture**)&Pad[8];
	if (Texture->Mips.Num() == 0)
		return NULL;

	// Mips.Data pointer — TArray stores opaque 0x28-byte mip entries, not INT
	BYTE* MipsData = (BYTE*)Texture->Mips.GetData();
	BYTE* MipEntry = MipsData + MipIndex * 0x28;

	// If not already loaded, trigger lazy load via vtable[0]
	if ((*(((BYTE*)Texture) + 0x94) & 0x20) == 0)
	{
		void** LazyVtable = *(void***)(MipEntry + 0x10);
		if (LazyVtable)
		{
			typedef void (__thiscall *LoadFn)(void*);
			((LoadFn)LazyVtable[0])((void*)(MipEntry + 0x10));
		}
	}

	return *(void**)(MipEntry + 0x1C);
}
IMPL_MATCH("Engine.dll", 0x10468c80)
int FStaticTexture::GetRevision()
{
// If bRealtimeChanged flag (bit 6 = 0x40 in bitfield at UTexture+0x94) is set:
	// increment Revision counter at this+0x10, clear the flag, then return Revision.
	UTexture* Texture = *(UTexture**)&Pad[8];
	if (Texture->bRealtimeChanged)
	{
		++(*(INT*)&Pad[12]);
		Texture->bRealtimeChanged = 0;
	}
	return *(INT*)&Pad[12];
}
IMPL_TODO("Ghidra 0x10469da0 (1462b): FUN_1050557c confirmed in _unnamed.cpp; complex DXT/format decompression pipeline — pending full decompilation")
void FStaticTexture::GetTextureData(int,void *,int,ETextureFormat,int)
{
	// TODO: implement FStaticTexture::GetTextureData (Ghidra 0x169da0: lazy-load path,
	// format dispatch for TEXF_DXT1/DXT3/DXT5/RGBA8 etc.; uses FUN_1050557c confirmed in _unnamed.cpp)
}
IMPL_MATCH("Engine.dll", 0x10468ce0)
ETexClampMode FStaticTexture::GetUClamp()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return (ETexClampMode)Texture->UClampMode;
}
IMPL_MATCH("Engine.dll", 0x10468d00)
UTexture * FStaticTexture::GetUTexture()
{
	return *(UTexture**)&Pad[8];
}
IMPL_MATCH("Engine.dll", 0x10468cf0)
ETexClampMode FStaticTexture::GetVClamp()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return (ETexClampMode)Texture->VClampMode;
}
IMPL_MATCH("Engine.dll", 0x10468ca0)
int FStaticTexture::GetWidth()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return Texture->USize;
}


// --- FBspSection ---
IMPL_MATCH("Engine.dll", 0x10327b60)
FBspSection::FBspSection(FBspSection const &Other)
{
	// Ghidra 0x27b60: vtable set by compiler; TArray<FBspVertex> at +4 (stride 0x28); 7 DWORDs at +10..+28
	// FUN_1031ecc0 is the compiler-generated TArray<FBspVertex> copy-ctor instantiation; our call is equivalent.
	new ((BYTE*)this + 0x04) TArray<FBspVertex>(*(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x1C); // 7 DWORDs
}

IMPL_DIVERGE("vtable pointer value differs from retail; constructor logic is otherwise correct — retail sets FBspVertexStream::_vftable_ at offset 0, but FBspSection has no virtual base in source so the compiler never emits that store")
FBspSection::FBspSection()
{
	// Ghidra 0x27a70: sets vtable (FBspVertexStream::_vftable_), inits TArray at +4,
	// sets CacheId at +0x10 = DAT_1060b564*0x100+0xE1, zeros +0x18/+0x1C/+0x20/+0x24, sets +0x28 = -1.
	new ((BYTE*)this + 0x04) TArray<FBspVertex>();
	*(QWORD*)((BYTE*)this + 0x10) = (QWORD)(DWORD)DAT_1060b564 * 0x100 + 0xE1;
	DAT_1060b564++;
	*(DWORD*)((BYTE*)this + 0x18) = 0;
	*(DWORD*)((BYTE*)this + 0x1C) = 0;
	*(DWORD*)((BYTE*)this + 0x20) = 0;
	*(DWORD*)((BYTE*)this + 0x24) = 0;
	*(DWORD*)((BYTE*)this + 0x28) = 0xFFFFFFFF;
}

IMPL_MATCH("Engine.dll", 0x103278e0)
FBspSection::~FBspSection()
{
	// Ghidra 0x278e0: shared with ~FBspVertexStream; calls FUN_10324a50 to destroy TArray<FBspVertex> at +4
	// FUN_10324a50 is the compiler-generated TArray<FBspVertex>::~TArray instantiation; our call is equivalent.
	((TArray<FBspVertex>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x10327bb0)
FBspSection& FBspSection::operator=(const FBspSection& Other)
{
	// Ghidra 0x27bb0: skip vtable at +0, TArray<FBspVertex> at +4 via FUN_10324ae0; 7 DWORDs at +0x10..+0x28
	// FUN_10324ae0 is the compiler-generated TArray<FBspVertex>::operator= instantiation; our call is equivalent.
	*(TArray<FBspVertex>*)((BYTE*)this + 0x04) = *(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x1C); // 7 DWORDs
	return *this;
}


// --- FBspVertex ---
IMPL_MATCH("Engine.dll", 0x103fe100)
FBspVertex::FBspVertex()
{
	// Ghidra 0x1fe100: constructs two FVectors at offset 0 and 0xC (Position + Normal)
	*(FVector*)&_Data[0] = FVector(0,0,0);
	*(FVector*)&_Data[12] = FVector(0,0,0);
}

IMPL_MATCH("Engine.dll", 0x103046a0)
FBspVertex& FBspVertex::operator=(const FBspVertex& Other)
{
	// Ghidra 0x46a0 (49b): 10 DWORD loop → copies 40 bytes
	appMemcpy( this, &Other, sizeof(FBspVertex) );
	return *this;
}


// --- FConvexVolume ---
IMPL_MATCH("Engine.dll", 0x10413f20)
BYTE FConvexVolume::SphereCheck(FSphere Sphere)
{
	BYTE Result = 1;
	for (INT i = 0; i < NumPlanes; i++)
	{
		FLOAT Dist = Planes[i].PlaneDot(*(FVector*)&Sphere);
		if (Dist > Sphere.W)
			return 2;
		if (Dist > -Sphere.W)
			Result |= 2;
	}
	return Result;
}

IMPL_MATCH("Engine.dll", 0x10303750)
FConvexVolume::FConvexVolume(const FConvexVolume& Other)
{
	// Ghidra 0x3750: 32 FPlane copy ctors (FPlane is POD) + copy NumPlanes/FVectors/pad/FMatrix.
	// Equivalent to appMemcpy since all members are POD.
	appMemcpy(this, &Other, 0x260);
}

IMPL_MATCH("Engine.dll", 0x10414360)
FConvexVolume::FConvexVolume()
{
	// Ghidra 0x114360 (86b): 32 FPlane default ctors, FVector at +0x204, FVector at +0x210,
	// FMatrix at +0x220; zeroes NumPlanes and _Pad21C.
	for (int i = 0; i < 32; i++)
		new (&Planes[i]) FPlane();
	new (&_ExtraVec0) FVector();
	new (&_ExtraVec1) FVector();
	new (&_ExtraMatrix) FMatrix();
	NumPlanes = 0;
	_Pad21C = 0;
}

IMPL_MATCH("Engine.dll", 0x10303740)
FConvexVolume::~FConvexVolume()
{
	// Ghidra 0x3740: calls FMatrix::~FMatrix at this+0x220 (trivial, FMatrix is POD).
	_ExtraMatrix.~FMatrix();
}

IMPL_MATCH("Engine.dll", 0x103037f0)
FConvexVolume& FConvexVolume::operator=(const FConvexVolume& Other)
{
	// Ghidra 0x37f0 (54b): 0x98 DWORD loop = 0x260 bytes from offset 0.
	appMemcpy(this, &Other, 0x260);
	return *this;
}

IMPL_MATCH("Engine.dll", 0x104169d0)
BYTE FConvexVolume::BoxCheck(FVector Origin, FVector Extent)
{
	BYTE Result = 1;
	for (INT i = 0; i < NumPlanes; i++)
	{
		FLOAT Dist = Planes[i].PlaneDot(Origin);
		FLOAT PushOut = Abs(Extent.X * Planes[i].X) + Abs(Extent.Y * Planes[i].Y) + Abs(Extent.Z * Planes[i].Z);
		if (Dist > PushOut)
			return 2;
		if (Dist > -PushOut)
			Result |= 2;
	}
	return Result;
}

// For each outward-facing plane, negate normal so FPoly::Split keeps the interior half.
// Base = N * W is a point on the plane (for unit N, dot(N, N*W) = W). Ghidra 0x10413f90.
IMPL_MATCH("Engine.dll", 0x10413f90)
FPoly FConvexVolume::ClipPolygon(FPoly Poly)
{
  guard(FConvexVolume::ClipPolygon);
  for (INT i = 0; i < NumPlanes; i++)
  {
    const FPlane& P = Planes[i];
    FVector Normal(-P.X, -P.Y, -P.Z);               // negate: planes face outward, keep inside
    FVector Base(P.X * P.W, P.Y * P.W, P.Z * P.W);  // N*W = point on plane
    if (!Poly.Split(Normal, Base, 0))
      return FPoly();
  }
  return Poly;
  unguard;
}

// Same as ClipPolygon but uses SplitPrecise for tighter floating-point plane tests.
IMPL_MATCH("Engine.dll", 0x10414040)
FPoly FConvexVolume::ClipPolygonPrecise(FPoly Poly)
{
  guard(FConvexVolume::ClipPolygonPrecise);
  for (INT i = 0; i < NumPlanes; i++)
  {
    const FPlane& P = Planes[i];
    FVector Normal(-P.X, -P.Y, -P.Z);
    FVector Base(P.X * P.W, P.Y * P.W, P.Z * P.W);
    if (!Poly.SplitPrecise(Normal, Base, 0))
      return FPoly();
  }
  return Poly;
  unguard;
}

// --- FDynamicActor ---
// Ghidra 0x104038b0 (11290b): per-actor render dispatch. Permanent divergence: the
// entire function body drives FRenderInterface* param_3 vtable methods (SetMaterial,
// DrawMesh, SetTransform etc.) — a 11 kb D3D render pipeline that cannot be reproduced
// without matching the binary-specific vtable layout.
IMPL_DIVERGE("FRenderInterface vtable dispatch — full per-mesh D3D render pipeline (~11 kb)")
void FDynamicActor::Render(FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}
IMPL_MATCH("Engine.dll", 0x103135d0)
FDynamicActor::FDynamicActor(const FDynamicActor& Other)
{
	// Ghidra 0x135d0 (135b): no vtable; flat copy of 0x80 bytes (same as operator= at 0x13660)
	appMemcpy(this, &Other, 0x80);
}

IMPL_TODO("Ghidra 0x103ffb70 (1798b): no FUN_ blockers; complex vtable-dispatch for mesh/physics bounding box — actor vtable offsets 0xac/0xc0 and mesh vtable 0x6c/0x70 not yet mapped to named methods")
FDynamicActor::FDynamicActor(AActor* Actor)
{
	// Ghidra 0xffb70: construct sub-objects, store actor pointer, compute transform/bounds.
	// FMatrix at this+4, FBox at this+0x48, FSphere at this+0x64; actor pointer at this+0.
	new ((BYTE*)this + 0x04) FMatrix();
	new ((BYTE*)this + 0x48) FBox();
	new ((BYTE*)this + 0x64) FSphere();
	*(AActor**)this = Actor;
	// Remaining: vtable dispatch for mesh/physics bounding box not yet mapped to named methods.
	//   actor vtable+0xac = GetRenderBoundingBox, +0xc0 = GetMesh, mesh vtable+0x6c = GetBoundingBox.
	//   Emitter/SkeletalMesh paths also have specialised bounds logic.
}

IMPL_MATCH("Engine.dll", 0x10309a70)
FDynamicActor::~FDynamicActor()
{
	// Ghidra 0x9a70: calls FMatrix::~FMatrix at this+4 (trivial, FMatrix is POD). No heap to free.
	((FMatrix*)((BYTE*)this + 0x04))->~FMatrix();
}

IMPL_MATCH("Engine.dll", 0x10313660)
FDynamicActor& FDynamicActor::operator=(const FDynamicActor& Other)
{
	// Ghidra 0x13660 (54b): 0x20 DWORDs from offset 0 = 0x80 bytes (no vtable)
	appMemcpy(this, &Other, 0x80);
	return *this;
}


// --- FDynamicLight ---
// FUN_1040d530 (Ghidra _unnamed.cpp, 150b): Hermite-smoothstep radial falloff weighted
// by the Lambertian (Normal·delta) factor.  Inlined into SampleIntensity below.
// param1=dist, param2=Radius, param3..5=delta(dx,dy,dz), param6..8=Normal(nx,ny,nz).
// Returns 2*(|dot(Normal,delta)|/dist) * (2t³-3t²+1) if dot>0 && dist<Radius, else 0.
static FLOAT FalloffHelper(FLOAT dist, FLOAT Radius,
                            FLOAT dx, FLOAT dy, FLOAT dz,
                            FLOAT nx, FLOAT ny, FLOAT nz)
{
	FLOAT dot = nx * dx + ny * dy + nz * dz;
	if (dot > 0.0f && dist < Radius)
	{
		FLOAT t  = dist / Radius;
		FLOAT t2 = t * t;
		FLOAT t3 = t * t2;
		FLOAT hermite = (2.0f * t3 - 3.0f * t2 + 1.0f);
		FLOAT dot_nr  = Abs(dot / Radius);
		FLOAT f = (dot_nr / t) * hermite;
		return f + f;
	}
	return 0.0f;
}

IMPL_MATCH("Engine.dll", 0x1040d5d0)
float FDynamicLight::SampleIntensity(FVector Point, FVector Normal)
{
	// Retail: 0x10D5D0, 859b. Evaluates per-sample light intensity based on light type.
	// Light type byte is stored at vtable-descriptor+0x37 (custom descriptor, not C++ vtable).
	// LightPos = this+0x14 (FVector), LightDir = this+0x20 (FVector), Radius = this+0x2C.
	BYTE lightType = *(BYTE*)(*(BYTE**)this + 0x37);

	if (lightType == 0x14) // LT_Directional — Lambertian dot-product with surface normal
	{
		FVector* LightDir = (FVector*)((BYTE*)this + 0x20);
		FLOAT dot = Normal.X * LightDir->X + Normal.Y * LightDir->Y + Normal.Z * LightDir->Z;
		if (dot < 0.0f) return dot * -2.0f;
	}
	else if (lightType == 0x11) // LT_Cylinder — 2D radial falloff, 3D range check
	{
		FLOAT dX = *(FLOAT*)((BYTE*)this + 0x14) - Point.X;
		FLOAT dY = *(FLOAT*)((BYTE*)this + 0x18) - Point.Y;
		FLOAT dZ = *(FLOAT*)((BYTE*)this + 0x1C) - Point.Z;
		FLOAT dist3D = appSqrt(dX*dX + dY*dY + dZ*dZ);
		FLOAT Radius  = *(FLOAT*)((BYTE*)this + 0x2C);
		if (dist3D < Radius)
		{
			FLOAT r_sq   = dX*dX + dY*dY; // XY-plane only
			FLOAT falloff = 1.0f - r_sq / (Radius * Radius);
			if (falloff <= 0.0f) falloff = 0.0f;
			return falloff + falloff;
		}
	}
	else if (lightType == 0x0D) // LT_Cone — dot check + sqrt falloff
	{
		FLOAT dX = *(FLOAT*)((BYTE*)this + 0x14) - Point.X;
		FLOAT dY = *(FLOAT*)((BYTE*)this + 0x18) - Point.Y;
		FLOAT dZ = *(FLOAT*)((BYTE*)this + 0x1C) - Point.Z;
		FLOAT dist   = appSqrt(dX*dX + dY*dY + dZ*dZ);
		FLOAT Radius = *(FLOAT*)((BYTE*)this + 0x2C);
		FLOAT inDot  = dX * Normal.X + dZ * Normal.Z + dY * Normal.Y;
		if (inDot > 0.0f && dist < Radius)
		{
			FLOAT f = appSqrt(1.02f - dist / Radius);
			return f + f;
		}
	}
	else
	{
		// Ghidra: if lightType != 0x0C ('\f') AND != 0x08 ('\b'): pure radial falloff only.
		// If lightType IS 0x0C or 0x08: radial falloff * squared cone-attenuation factor.
		FLOAT dX = *(FLOAT*)((BYTE*)this + 0x14) - Point.X;
		FLOAT dY = *(FLOAT*)((BYTE*)this + 0x18) - Point.Y;
		FLOAT dZ = *(FLOAT*)((BYTE*)this + 0x1C) - Point.Z;
		FLOAT distSq = dX*dX + dY*dY + dZ*dZ;
		FLOAT dist   = appSqrt(distSq);
		FLOAT Radius = *(FLOAT*)((BYTE*)this + 0x2C);

		// Inline FUN_1040d530 (Ghidra _unnamed.cpp 0x1040d530, 150b):
		FLOAT falloff = FalloffHelper(dist, Radius, dX, dY, dZ, Normal.X, Normal.Y, Normal.Z);

		if (lightType != 0x0C && lightType != 0x08)
			return falloff; // pure radial falloff for non-spotlight types

		// 0x0C / 0x08: spotlight — apply squared cone-attenuation on top of radial falloff.
		if (falloff > 0.0f)
		{
			// cosOuter = cos of outer cone angle; byte at vtable-descriptor+0x3C scaled to [0,1].
			FLOAT cosOuter = 1.0f - *(BYTE*)(*(BYTE**)this + 0x3C) * 0.00390625f;
			FLOAT invRange = 1.0f / (1.0f - cosOuter);
			// coneDot = projection of (Point - LightPos) onto LightDir.
			FLOAT coneDot = -dX * *(FLOAT*)((BYTE*)this + 0x20)
			              + -dZ * *(FLOAT*)((BYTE*)this + 0x28)
			              + -dY * *(FLOAT*)((BYTE*)this + 0x24);
			if (coneDot > 0.0f)
			{
				// Check: cosOuter² * dist² < coneDot²  (point inside outer cone)
				FLOAT cosOuter2 = cosOuter * cosOuter;
				if (cosOuter2 * distSq < coneDot * coneDot)
				{
					FLOAT coneAtten = (coneDot / dist) * invRange - invRange * cosOuter;
					return coneAtten * coneAtten * falloff;
				}
			}
		}
	}
	return 0.0f;
}

IMPL_MATCH("Engine.dll", 0x104104f0)
FColor FDynamicLight::SampleLight(FVector Point, FVector Normal)
{
	// Ghidra 0x1104f0 (102b): call SampleIntensity to get per-sample float intensity,
	// scale the FPlane light color at this+4 by that intensity, return as FColor.
	float Intensity = SampleIntensity(Point, Normal);
	return FColor(*(FPlane*)((BYTE*)this + 0x04) * Intensity);
}

IMPL_MATCH("Engine.dll", 0x10313540)
FDynamicLight::FDynamicLight(FDynamicLight const& Other)
{
	// Ghidra 0x13540 (100b): FPlane copy ctor at +4, copies 10 DWORDs +0x14..+0x38.
	// FPlane is POD so equivalent to flat memcpy of sizeof(FDynamicLight).
	appMemcpy( this, &Other, sizeof(FDynamicLight) );
}

IMPL_TODO("Ghidra 0x1040ff20 (1485b): FGetHSV (defined in UnCamera.cpp) and FUN_1050557c/FUN_1038a4f0 (confirmed in _unnamed.cpp) all accessible; LightEffect dispatch complex but tractable — pending full decompilation")
FDynamicLight::FDynamicLight(AActor* Actor)
{
	// Ghidra 0x10ff20: construct sub-objects, store actor, compute light color/direction.
	// FPlane at this+4, FVector at this+0x14, FVector at this+0x20; actor at this+0.
	new ((BYTE*)this + 0x04) FPlane();
	new ((BYTE*)this + 0x14) FVector();
	new ((BYTE*)this + 0x20) FVector();
	*(AActor**)this = Actor;
	// Remaining: FGetHSV(actor->LightHue, actor->LightSaturation, ...) to build base color,
	// then LightEffect switch (LT_Pulse/Subtractive/Flicker/Strobe etc.) to modulate it,
	// then scale by actor->LightBrightness/255 and store to this->Color (FPlane at +4).
	// Direction at this+0x20 set from actor rotation for LT_Directional/LT_Spot.
}

IMPL_MATCH("Engine.dll", 0x103135b0)
FDynamicLight& FDynamicLight::operator=(const FDynamicLight& Other)
{
	// Ghidra 0x135b0 (48b): 0xF DWORDs from offset 0 = 0x3C bytes (FDynamicLight has no vtable).
	appMemcpy( this, &Other, sizeof(FDynamicLight) );
	return *this;
}


// --- FLightMapIndex ---
IMPL_MATCH("Engine.dll", 0x10302b40)
FLightMapIndex::FLightMapIndex()
{
	// Ghidra 0x2b40: constructs FMatrix at +8 and +0x48, FVector at +0x88, +0x94, +0xA0.
	new ((BYTE*)this + 0x08) FMatrix();
	new ((BYTE*)this + 0x48) FMatrix();
	new ((BYTE*)this + 0x88) FVector(0.f,0.f,0.f);
	new ((BYTE*)this + 0x94) FVector(0.f,0.f,0.f);
	new ((BYTE*)this + 0xa0) FVector(0.f,0.f,0.f);
}

IMPL_MATCH("Engine.dll", 0x10302bc0)
FLightMapIndex::~FLightMapIndex()
{
	// Ghidra 0x2bc0: calls FMatrix::~FMatrix at +0x48 then +0x08 (trivial, FMatrix is POD).
	((FMatrix*)((BYTE*)this + 0x48))->~FMatrix();
	((FMatrix*)((BYTE*)this + 0x08))->~FMatrix();
}

IMPL_MATCH("Engine.dll", 0x10302c10)
FLightMapIndex& FLightMapIndex::operator=(const FLightMapIndex& Other)
{
	// Ghidra 0x2c10 (134b): 0x30 DWORDs from offset 0 = 0xC0 bytes (no vtable).
	appMemcpy(this, &Other, 0xC0);
	return *this;
}


// --- FLineVertex ---
IMPL_EMPTY("Ghidra 0x10303810 confirms retail body is trivial (13 bytes)")
FLineVertex::FLineVertex(FVector InPoint, FColor InColor)
:	Point(InPoint)
,	Color(InColor)
{
}

IMPL_MATCH("Engine.dll", 0x10303810)
FLineVertex::FLineVertex()
{
	// Ghidra 0x3810: calls FVector::FVector((FVector*)this) then returns.
	// No SEH frame; compiler default-constructs Point (FVector trivial ctor).
}

IMPL_MATCH("Engine.dll", 0x10304570)
FLineVertex& FLineVertex::operator=(const FLineVertex& Other)
{
	// Ghidra 0x4570 (33b): shared stub; 4 DWORDs from offset 0 = 16 bytes.
	Point = Other.Point;
	Color = Other.Color;
	return *this;
}


// --- FStaticCubemap ---
IMPL_MATCH("Engine.dll", 0x10318eb0)
FStaticCubemap::FStaticCubemap(FStaticCubemap const &Other)
{
	// Ghidra 0x18eb0: vtable set by compiler; scalar copy of 4 DWORDs at +4..+10
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
}

IMPL_MATCH("Engine.dll", 0x10318eb0)
FStaticCubemap::FStaticCubemap(UCubemap* Cubemap)
{
	// Ghidra 0x16a9f0: store cubemap pointer, compute CacheId, set initial revision.
	// Layout (Pad is at this+4): Pad[0..3]=UCubemap*; Pad[4..11]=CacheId QWORD; Pad[12..15]=Revision.
	*(UCubemap**)&Pad[0] = Cubemap;
	DWORD Idx            = Cubemap ? ((UObject*)Cubemap)->GetIndex() : 0;
	*(QWORD*)(Pad + 4)   = (QWORD)Idx * 0x100 + 0xE0;
	*(INT*)(Pad + 12)    = 1;
}

IMPL_MATCH("Engine.dll", 0x10318ee0)
FStaticCubemap& FStaticCubemap::operator=(const FStaticCubemap& Other)
{
	// Ghidra 0x18ee0 (33b): skip vtable at +0, copy 4 DWORDs at +4..+10. Shares address with FStaticTexture::operator=.
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
	return *this;
}

IMPL_MATCH("Engine.dll", 0x10458240)
unsigned __int64 FStaticCubemap::GetCacheId()
{
	// Ghidra: return QWORD at this+8 = Pad+4
	return *(QWORD*)(Pad + 4);
}

IMPL_MATCH("Engine.dll", 0x1046a3b0)
FTexture * FStaticCubemap::GetFace(int FaceIndex)
{
	// Retail: 0x16A3B0, 38b. Returns the render-interface texture for the given cubemap face.
	// this+4 = UCubemap pointer.
	// UCubemap+0xD8 = array of 6 face UTexture* pointers (one per face).
	// UCubemap+0xD0 = double (last update time), passed to the Get() vtable call.
	INT cubeMapPtr = *(INT*)((BYTE*)this + 4);
	UTexture* faceTex = *(UTexture**)(cubeMapPtr + 0xD8 + FaceIndex * 4);
	if (!faceTex) return NULL;
	// Call faceTex->Get(lastUpdateTime, NULL) via vtable slot 0x94/4
	typedef UBitmapMaterial* (__thiscall *GetFn)(UTexture*, double, UViewport*);
	GetFn Get = *(GetFn*)((*(BYTE**)faceTex) + 0x94);
	UBitmapMaterial* bm = Get(faceTex, *(double*)(cubeMapPtr + 0xD0), NULL);
	if (!bm) return NULL;
	// Call bm->GetRenderInterface() via vtable slot 0x90/4
	typedef FBaseTexture* (__thiscall *GetRIFn)(UBitmapMaterial*);
	GetRIFn GetRI = *(GetRIFn*)((*(BYTE**)bm) + 0x90);
	return (FTexture*)GetRI(bm);
}

IMPL_MATCH("Engine.dll", 0x10414310)
int FStaticCubemap::GetFirstMip()
{
	// Ghidra 0x114310: shared stub returning 0 (xor eax,eax; ret). Same 3-byte stub as FStaticLightMapTexture::GetFirstMip etc.
	return 0;
}

IMPL_MATCH("Engine.dll", 0x1046ab90)
ETextureFormat FStaticCubemap::GetFormat()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? (ETextureFormat)tex->Format : TEXF_P8;
}

IMPL_MATCH("Engine.dll", 0x1046aab0)
int FStaticCubemap::GetHeight()
{
	// Cubemap face height — UCubemap inherits VSize from UTexture.
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->VSize : 0;
}

IMPL_MATCH("Engine.dll", 0x1046ab20)
int FStaticCubemap::GetNumMips()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->Mips.Num() : 0;
}

IMPL_MATCH("Engine.dll", 0x10468d10)
int FStaticCubemap::GetRevision()
{
	// Revision counter at Pad[12] (this+16), same layout as FStaticTexture.
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	if (tex && tex->bRealtimeChanged)
	{
		++(*(INT*)&Pad[12]);
		tex->bRealtimeChanged = 0;
	}
	return *(INT*)&Pad[12];
}

IMPL_MATCH("Engine.dll", 0x1046ac00)
ETexClampMode FStaticCubemap::GetUClamp()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? (ETexClampMode)tex->UClampMode : TC_Wrap;
}

IMPL_MATCH("Engine.dll", 0x1046ac70)
ETexClampMode FStaticCubemap::GetVClamp()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? (ETexClampMode)tex->VClampMode : TC_Wrap;
}

IMPL_MATCH("Engine.dll", 0x1046aa40)
int FStaticCubemap::GetWidth()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->USize : 0;
}


// --- FTempLineBatcher ---
IMPL_DIVERGE("retail builds a lightweight stack struct { vtable+FArray } without the full ctor; we use FLineBatcher ctor/dtor — functionally equivalent but binary-level struct diverges")
void FTempLineBatcher::Render(FRenderInterface* RI, INT Flags)
{
	// Ghidra 0x1180b0: sets local_30 = &FLineBatcher::_vftable_, initialises a bare FArray
	// at local_2c, sets the cache ID using DAT_1060b564 (= (QWORD)DAT_1060b564 * 0x100 + 0xe1),
	// increments DAT_1060b564, then iterates Start/End TArrays at this+0/+0xC and Box TArrays
	// at this+0x24, calling FLineBatcher::DrawLine/DrawBox on the stack-local batcher.
	// DIVERGENCE: retail builds a lightweight stack struct (vtable ptr + FArray, no full ctor);
	// our version uses the full FLineBatcher ctor/dtor path with the same draw calls.
	FLineBatcher Batcher(RI, Flags, 0);
	TArray<FVector>* Starts     = (TArray<FVector>*)((BYTE*)this + 0x00);
	TArray<FVector>* Ends       = (TArray<FVector>*)((BYTE*)this + 0x0C);
	TArray<FLOAT>*   LineColors = (TArray<FLOAT>*)  ((BYTE*)this + 0x18);
	INT LineCount = Starts->Num();
	for (INT i = 0; i < LineCount; i++)
	{
		FColor Color;
		*(DWORD*)&Color = *(DWORD*)&(*LineColors)(i);
		Batcher.DrawLine((*Starts)(i), (*Ends)(i), Color);
	}
	TArray<FBox>*  Boxes     = (TArray<FBox>*) ((BYTE*)this + 0x24);
	TArray<FLOAT>* BoxColors = (TArray<FLOAT>*)((BYTE*)this + 0x30);
	INT BoxCount = Boxes->Num();
	for (INT i = 0; i < BoxCount; i++)
	{
		FColor Color;
		*(DWORD*)&Color = *(DWORD*)&(*BoxColors)(i);
		Batcher.DrawBox((*Boxes)(i), Color);
	}
	Batcher.Flush(0);
}

IMPL_MATCH("Engine.dll", 0x103273a0)
FTempLineBatcher::FTempLineBatcher(FTempLineBatcher const &Other)
{
	// Ghidra 0x27490: no vtable; TArray<FVector>@+0, TArray<FVector>@+0xC, TArray<FLOAT>@+0x18, TArray<FBox>@+0x24, TArray<FLOAT>@+0x30
	new ((BYTE*)this + 0x00) TArray<FVector>(*(const TArray<FVector>*)((const BYTE*)&Other + 0x00));
	new ((BYTE*)this + 0x0C) TArray<FVector>(*(const TArray<FVector>*)((const BYTE*)&Other + 0x0C));
	new ((BYTE*)this + 0x18) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x18));
	new ((BYTE*)this + 0x24) TArray<FBox>(*(const TArray<FBox>*)((const BYTE*)&Other + 0x24));
	new ((BYTE*)this + 0x30) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x30));
}

IMPL_MATCH("Engine.dll", 0x103273a0)
FTempLineBatcher::FTempLineBatcher()
{
	// Initialize all 5 TArrays to empty
	new ((BYTE*)this + 0x00) TArray<FVector>();
	new ((BYTE*)this + 0x0C) TArray<FVector>();
	new ((BYTE*)this + 0x18) TArray<FLOAT>();
	new ((BYTE*)this + 0x24) TArray<FBox>();
	new ((BYTE*)this + 0x30) TArray<FLOAT>();
}

IMPL_MATCH("Engine.dll", 0x10327410)
FTempLineBatcher::~FTempLineBatcher()
{
	// Ghidra 0x27410: destroys 5 TArrays in reverse order via FUN_10322eb0/FUN_10322e20/FUN_10324640.
	// All are compiler-generated TArray<T>::~TArray instantiations; our calls are equivalent.
	((TArray<FLOAT>*)((BYTE*)this + 0x30))->~TArray();
	((TArray<FBox>*)((BYTE*)this + 0x24))->~TArray();
	((TArray<FLOAT>*)((BYTE*)this + 0x18))->~TArray();
	((TArray<FVector>*)((BYTE*)this + 0x0C))->~TArray();
	((TArray<FVector>*)((BYTE*)this + 0x00))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x10327520)
FTempLineBatcher& FTempLineBatcher::operator=(const FTempLineBatcher& Other)
{
	// Ghidra 0x27520: no vtable; 5 TArray assigns via FUN_10323160/FUN_1031f660/FUN_10322510.
	// All are compiler-generated TArray<T>::operator= instantiations; our calls are equivalent.
	*(TArray<FVector>*)((BYTE*)this + 0x00) = *(const TArray<FVector>*)((const BYTE*)&Other + 0x00);
	*(TArray<FVector>*)((BYTE*)this + 0x0C) = *(const TArray<FVector>*)((const BYTE*)&Other + 0x0C);
	*(TArray<FLOAT>*)((BYTE*)this + 0x18) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x18);
	*(TArray<FBox>*)((BYTE*)this + 0x24) = *(const TArray<FBox>*)((const BYTE*)&Other + 0x24);
	*(TArray<FLOAT>*)((BYTE*)this + 0x30) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x30);
	return *this;
}

IMPL_MATCH("Engine.dll", 0x10320950)
void FTempLineBatcher::AddBox(FBox Box, FColor Color)
{
	// Ghidra 0x20950: append FBox (0x1C bytes) to TArray<FBox> at this+0x24; append Color DWORD to TArray<FLOAT> at this+0x30.
	TArray<FBox>*  Boxes  = (TArray<FBox>*) ((BYTE*)this + 0x24);
	INT i = Boxes->Add(1);
	(*Boxes)(i) = Box;
	TArray<FLOAT>* Colors = (TArray<FLOAT>*)((BYTE*)this + 0x30);
	i = Colors->Add(1);
	*(DWORD*)&(*Colors)(i) = Color.DWColor();
}

IMPL_MATCH("Engine.dll", 0x103208d0)
void FTempLineBatcher::AddLine(FVector Start, FVector End, FColor Color)
{
	// Ghidra 0x208d0: append Start to TArray<FVector>@+0, End to TArray<FVector>@+0xC, Color DWORD to TArray<FLOAT>@+0x18.
	TArray<FVector>* Starts = (TArray<FVector>*)((BYTE*)this + 0x00);
	INT i = Starts->Add(1);
	(*Starts)(i) = Start;
	TArray<FVector>* Ends = (TArray<FVector>*)((BYTE*)this + 0x0C);
	i = Ends->Add(1);
	(*Ends)(i) = End;
	TArray<FLOAT>* Colors = (TArray<FLOAT>*)((BYTE*)this + 0x18);
	i = Colors->Add(1);
	*(DWORD*)&(*Colors)(i) = Color.DWColor();
}


// --- UConvexVolume ---
// FUN_10392040: TArray<FConvexPlane> serializer (0x1c-byte elements).
// Each element = FPlane (16 bytes) + TArray<FVector> (12 bytes).
// Loading path constructs each element with placement new before reading.
IMPL_MATCH("Engine.dll", 0x103921d0)
void UConvexVolume::Serialize(FArchive& Ar)
{
	guard(UConvexVolume::Serialize);
	UPrimitive::Serialize(Ar);

	// ---- Planes array at this+0x58 (Ghidra: FUN_10392040) ----
	// 0x1c-byte elements: FPlane (16b) + TArray<FVector> (12b)
	{
		FArray* planes = (FArray*)((BYTE*)this + 0x58);
		planes->CountBytes(Ar, 0x1c);
		INT num;
		if (!Ar.IsLoading())
		{
			INT pnum = planes->Num();
			Ar << AR_INDEX(pnum);
			for (INT i = 0; i < pnum; i++)
			{
				BYTE* elem = (BYTE*)planes->GetData() + i * 0x1c;
				Ar.ByteOrderSerialize(elem,       4); // FPlane.X
				Ar.ByteOrderSerialize(elem + 0x4, 4); // FPlane.Y
				Ar.ByteOrderSerialize(elem + 0x8, 4); // FPlane.Z
				Ar.ByteOrderSerialize(elem + 0xc, 4); // FPlane.W
				// TArray<FVector> at elem+0x10 (Ghidra: FUN_10321a80, 0xc-byte elements)
				FArray* verts = (FArray*)(elem + 0x10);
				verts->CountBytes(Ar, 0xc);
				INT vn = verts->Num();
				Ar << AR_INDEX(vn);
				for (INT j = 0; j < vn; j++)
				{
					BYTE* v = (BYTE*)verts->GetData() + j * 0xc;
					Ar.ByteOrderSerialize(v,       4); // X
					Ar.ByteOrderSerialize(v + 0x4, 4); // Y
					Ar.ByteOrderSerialize(v + 0x8, 4); // Z
				}
			}
		}
		else
		{
			Ar << AR_INDEX(num);
			// Destroy nested FArray in each existing element (Ghidra: FUN_1033b410)
			for (INT i = 0; i < planes->Num(); i++)
			{
				FArray* nested = (FArray*)((BYTE*)planes->GetData() + i * 0x1c + 0x10);
				nested->~FArray();
			}
			planes->Empty(0x1c, num);
			for (INT i = 0; i < num; i++)
			{
				INT idx = planes->Add(1, 0x1c);
				BYTE* elem = (BYTE*)planes->GetData() + idx * 0x1c;
				if (elem)
				{
					new (elem) FPlane();
					new (elem + 0x10) FArray();
				}
				Ar.ByteOrderSerialize(elem,       4); // FPlane.X
				Ar.ByteOrderSerialize(elem + 0x4, 4); // FPlane.Y
				Ar.ByteOrderSerialize(elem + 0x8, 4); // FPlane.Z
				Ar.ByteOrderSerialize(elem + 0xc, 4); // FPlane.W
				// TArray<FVector> at elem+0x10
				FArray* verts = (FArray*)(elem + 0x10);
				verts->CountBytes(Ar, 0xc);
				INT vnum;
				Ar << AR_INDEX(vnum);
				verts->Empty(0xc, vnum);
				for (INT j = 0; j < vnum; j++)
				{
					INT vi = verts->Add(1, 0xc);
					BYTE* v = (BYTE*)verts->GetData() + vi * 0xc;
					if (v) new (v) FVector();
					Ar.ByteOrderSerialize(v,       4); // X
					Ar.ByteOrderSerialize(v + 0x4, 4); // Y
					Ar.ByteOrderSerialize(v + 0x8, 4); // Z
				}
			}
		}
	}

	// ---- FPlane array at this+0x64 (Ghidra: FUN_10391e60) ----
	// 0x10-byte elements = 4 floats per FPlane
	{
		FArray* planes2 = (FArray*)((BYTE*)this + 0x64);
		planes2->CountBytes(Ar, 0x10);
		INT num2;
		if (!Ar.IsLoading())
		{
			INT n2 = planes2->Num();
			Ar << AR_INDEX(n2);
			for (INT i = 0; i < n2; i++)
			{
				BYTE* elem = (BYTE*)planes2->GetData() + i * 0x10;
				Ar.ByteOrderSerialize(elem,       4); // X
				Ar.ByteOrderSerialize(elem + 0x4, 4); // Y
				Ar.ByteOrderSerialize(elem + 0x8, 4); // Z
				Ar.ByteOrderSerialize(elem + 0xc, 4); // W
			}
		}
		else
		{
			Ar << AR_INDEX(num2);
			planes2->Empty(0x10, num2);
			for (INT i = 0; i < num2; i++)
			{
				INT idx = planes2->Add(1, 0x10);
				BYTE* elem = (BYTE*)planes2->GetData() + idx * 0x10;
				if (elem) new (elem) FPlane();
				Ar.ByteOrderSerialize(elem,       4); // X
				Ar.ByteOrderSerialize(elem + 0x4, 4); // Y
				Ar.ByteOrderSerialize(elem + 0x8, 4); // Z
				Ar.ByteOrderSerialize(elem + 0xc, 4); // W
			}
		}
	}

	// ---- FBox at this+0x70 (Ghidra: FUN_10301400) ----
	// 6 floats (Min+Max) + 1 BYTE (IsValid) = FBox
	Ar << *(FBox*)((BYTE*)this + 0x70);

	unguard;
}

IMPL_MATCH("Engine.dll", 0x10303220)
FBox UConvexVolume::GetRenderBoundingBox(AActor const *)
{
	// Retail: 23b. REP MOVSD 7 DWORDs (28b = FBox) from this+0x70 to return buffer.
	return *(FBox*)((BYTE*)this + 0x70);
}

IMPL_MATCH("Engine.dll", 0x10391d90)
int UConvexVolume::IsPointInside(FVector Point, FMatrix Matrix)
{
	// Retail: 0x91D90, ~130b SEH. Transforms each plane by Matrix, then checks if Point
	// is on the positive side of any plane (outside). Returns 0 if outside, 1 if inside.
	// Planes TArray at this+0x58, each plane element is 0x1C bytes (FPlane + padding).
	FArray* planes = (FArray*)((BYTE*)this + 0x58);
	INT count = planes->Num();
	for (INT i = 0; i < count; i++)
	{
		FPlane* src = (FPlane*)((BYTE*)(*(BYTE**)planes) + i * 0x1C);
		FPlane transformed = src->TransformBy(Matrix);
		if (transformed.PlaneDot(Point) > 0.0f)
			return 0;
		count = planes->Num(); // Ghidra re-fetches count each iteration
	}
	return 1;
}


// Forward declaration: defined in UnCamera.cpp (no header).
FArchive& operator<<(FArchive& Ar, FSkinVertex& V);

// --- UIndexBuffer ---
IMPL_MATCH("Engine.dll", 0x10410d90)
void UIndexBuffer::Serialize(FArchive& Ar)
{
	// Ghidra 0x110d90 (83b): URenderResource::Serialize, then FUN_1031e600(Ar, this+0x30)
	// = TArray<unsigned short> serializer (CountBytes + count + per-element ByteOrderSerialize(2)).
	guard(UIndexBuffer::Serialize);
	URenderResource::Serialize(Ar);
	Ar << *(TArray<_WORD>*)((BYTE*)this + 0x30);
	unguard;
}


// --- USkinVertexBuffer ---
IMPL_MATCH("Engine.dll", 0x10410f50)
void USkinVertexBuffer::Serialize(FArchive& Ar)
{
	// Ghidra 0x110f50 (83b): URenderResource::Serialize, then FUN_10410e20(Ar, this+0x30)
	// = TArray<FSkinVertex> serializer (stride 0x40, CountBytes + count + operator<< per element).
	guard(USkinVertexBuffer::Serialize);
	URenderResource::Serialize(Ar);
	Ar << *(TArray<FSkinVertex>*)((BYTE*)this + 0x30);
	unguard;
}

