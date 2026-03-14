/*=============================================================================
	UnRenderUtil.cpp: Render buffers, lighting, and BSP geometry helpers
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
IMPL_INFERRED("Reconstructed from context")
inline void* operator new(size_t, void* p) noexcept { return p; }
IMPL_INFERRED("Reconstructed from context")
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// extern declarations for FCollisionHash per-frame counters.
extern INT GHashActorCount;
extern INT GHashLinkCellCount;
extern INT GHashExtraCount;
extern CORE_API UBOOL GHideHiddenInEditor;

// --- FAnimMeshVertexStream ---
IMPL_GHIDRA("Engine.dll", 0x2b170)
FAnimMeshVertexStream::FAnimMeshVertexStream(FAnimMeshVertexStream const &Other)
{
	// Ghidra 0x2b170: vtable set by compiler; DWORD at +4; TArray<FStreamVert32> at +8 (stride 0x20); 6 DWORDs at +14..+28
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	new ((BYTE*)this + 0x08) TArray<FStreamVert32>(*(const TArray<FStreamVert32>*)((const BYTE*)&Other + 0x08));
	appMemcpy((BYTE*)this + 0x14, (const BYTE*)&Other + 0x14, 0x18); // 6 DWORDs
}

IMPL_INFERRED("Default constructor; initializes TArray<FStreamVert32> at +8 to empty")
FAnimMeshVertexStream::FAnimMeshVertexStream()
	new ((BYTE*)this + 0x08) TArray<FStreamVert32>();
}

IMPL_GHIDRA("Engine.dll", 0x2b160)
FAnimMeshVertexStream::~FAnimMeshVertexStream()
{
	// Ghidra 0x2b160: destroy TArray<FStreamVert32> at +8 (stride 0x20, POD elements)
	((TArray<FStreamVert32>*)((BYTE*)this + 0x08))->~TArray();
}

IMPL_GHIDRA("Engine.dll", 0x2b1c0)
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
IMPL_INFERRED("Ghidra describes logic; no standalone address extracted")
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
IMPL_INFERRED("Returns QWORD cache ID from Pad+16; no Ghidra address")
unsigned __int64 FAnimMeshVertexStream::GetCacheId()
}
IMPL_INFERRED("Vertex component layout inferred from stream type; no Ghidra address")
int FAnimMeshVertexStream::GetComponents(FVertexComponent* C)
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}
IMPL_INFERRED("Ghidra describes logic; no standalone address extracted")
int FAnimMeshVertexStream::GetPartialSize()
	INT Num = *(INT*)(Pad + 8);
	if (*(INT*)(Pad + 28))
	{
		INT PartialCount = *(INT*)(Pad + 32);
		return (PartialCount < Num) ? PartialCount : Num;
	}
	return Num;
}
IMPL_INFERRED("Ghidra describes logic; no standalone address extracted")
void FAnimMeshVertexStream::GetRawStreamData(void ** Out, int Offset)
	*Out = *(BYTE**)(Pad + 4) + Offset * 0x20;
}
IMPL_INFERRED("Returns revision counter from Pad+24; no Ghidra address")
int FAnimMeshVertexStream::GetRevision()
}
IMPL_INFERRED("Ghidra describes GetPartialSize() << 5; no standalone address")
int FAnimMeshVertexStream::GetSize()
	return GetPartialSize() << 5;
}
IMPL_INFERRED("Ghidra describes memcpy logic; no standalone address")
void FAnimMeshVertexStream::GetStreamData(void * Dest)
	INT Size = GetPartialSize() << 5;
	appMemcpy(Dest, *(void**)(Pad + 4), Size);
}
IMPL_INFERRED("Returns fixed stride 0x20; no Ghidra address")
int FAnimMeshVertexStream::GetStride()


// --- FBspVertexStream ---
IMPL_GHIDRA("Engine.dll", 0x103278f0)
FBspVertexStream::FBspVertexStream(FBspVertexStream const &Other)
{
	// Ghidra 0x103278f0: vtable set by compiler; TArray<FBspVertex> at +4 (stride 0x28); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FBspVertex>(*(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

IMPL_INFERRED("Default constructor; initializes TArray<FBspVertex> at +4 to empty")
FBspVertexStream::FBspVertexStream()
{
	// Initialize TArray<FBspVertex> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FBspVertex>();
}

IMPL_GHIDRA("Engine.dll", 0x103278e0)
FBspVertexStream::~FBspVertexStream()
	((TArray<FBspVertex>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_GHIDRA("Engine.dll", 0x27930)
FBspVertexStream& FBspVertexStream::operator=(const FBspVertexStream& Other)
{
	// Ghidra 0x27930: skip vtable at +0, TArray<FBspVertex> at +4 (FUN_10324ae0=40-byte elems),
	// then 3 DWORDs at +0x10..+0x18
	*(TArray<FBspVertex>*)((BYTE*)this + 0x04) = *(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
	return *this;
}

// (merged from earlier occurrence)
IMPL_INFERRED("Returns QWORD cache ID from Pad+12; no Ghidra address")
unsigned __int64 FBspVertexStream::GetCacheId()
}
IMPL_INFERRED("Vertex component layout inferred from BSP stream type; no Ghidra address")
int FBspVertexStream::GetComponents(FVertexComponent* C)
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	C[3].Type = 2; C[3].Function = 5;
	return 4;
}
IMPL_INFERRED("Ghidra describes logic; no standalone address extracted")
void FBspVertexStream::GetRawStreamData(void ** Out, int Offset)
	*Out = *(BYTE**)Pad + Offset * 0x28;
}
IMPL_INFERRED("Returns revision counter from Pad+20; no Ghidra address")
int FBspVertexStream::GetRevision()
}
IMPL_INFERRED("Ghidra describes Num * 0x28; no standalone address")
int FBspVertexStream::GetSize()
	return *(INT*)(Pad + 4) * 0x28;
}
IMPL_INFERRED("Ghidra describes memcpy Num*0x28; no standalone address")
void FBspVertexStream::GetStreamData(void * Dest)
	INT Size = *(INT*)(Pad + 4) * 0x28;
	appMemcpy(Dest, *(void**)Pad, Size);
}
IMPL_INFERRED("Returns fixed stride 0x28; no Ghidra address")
int FBspVertexStream::GetStride()


// --- FLevelSceneNode ---
IMPL_GHIDRA_APPROX("Engine.dll", 0x106670, "Ghidra reference only; body approximated")
void FLevelSceneNode::Render(FRenderInterface *)
{
	// Ghidra 0x106670, ~720 bytes. Full scene render — too complex for a single stub.
	// TODO: implement FLevelSceneNode::Render (retail 0x106670, ~720 bytes: full scene render — BSP, actors, decals, post-process)
	guard(FLevelSceneNode::Render);
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x100E30)
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

IMPL_INFERRED("Trivially returns this; no Ghidra address")
FLevelSceneNode * FLevelSceneNode::GetLevelSceneNode()
{
	return this;
}


// --- FLightMap ---
IMPL_GHIDRA("Engine.dll", 0x3c910)
FLightMap::FLightMap(FLightMap const &Other)
{
	// Ghidra 0x3c910: vtable set by compiler; 34 DWORDs at +4..+8B; TArray<FLightMapSample52> at +0x8C; TArray<FLOAT> at +0x98
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x88);
	new ((BYTE*)this + 0x8C) TArray<FLightMapSample52>(*(const TArray<FLightMapSample52>*)((const BYTE*)&Other + 0x8C));
	new ((BYTE*)this + 0x98) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x98));
}

IMPL_INFERRED("Initializes TArray members so dtor is safe; no Ghidra address")
FLightMap::FLightMap(ULevel *,int,int)
{
	// Initialize TArray members so dtor is safe regardless of which ctor was called
	new ((BYTE*)this + 0x8C) TArray<FLightMapSample52>();
	new ((BYTE*)this + 0x98) TArray<FLOAT>();
}

IMPL_INFERRED("Reconstructed from context")
FLightMap::FLightMap()
{
	new ((BYTE*)this + 0x8C) TArray<FLightMapSample52>();
	new ((BYTE*)this + 0x98) TArray<FLOAT>();
}

IMPL_INFERRED("Reconstructed from context")
FLightMap::~FLightMap()
{
	// Ghidra 0x3c6a0 area: destroy TArrays in reverse order
	((TArray<FLOAT>*)((BYTE*)this + 0x98))->~TArray();
	((TArray<FLightMapSample52>*)((BYTE*)this + 0x8C))->~TArray();
}

IMPL_INFERRED("Reconstructed from context")
FLightMap& FLightMap::operator=(const FLightMap& Other)
{
	// Ghidra 0x3ca10: skip vtable +0; +4..+8B = 34 DWORDs (contiguous); +0x8C=TArray<FLightMapSample52>; +0x98=TArray<FLOAT>
	appMemcpy((BYTE*)this + 4, (const BYTE*)&Other + 4, 0x88);
	*(TArray<FLightMapSample52>*)((BYTE*)this + 0x8C) = *(const TArray<FLightMapSample52>*)((const BYTE*)&Other + 0x8C);
	*(TArray<FLOAT>*)((BYTE*)this + 0x98) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x98);
	return *this;
}

// (merged from earlier occurrence)
IMPL_TODO("Needs Ghidra analysis")
unsigned __int64 FLightMap::GetCacheId()
{
	// Ghidra 0x4750: genuine stub; returns 0.
	return 0;
}
IMPL_TODO("Needs Ghidra analysis")
int FLightMap::GetFirstMip()
{
	// Ghidra 0x114310: shared stub; returns 0.
	return 0;
}
IMPL_INFERRED("Reconstructed from context")
ETextureFormat FLightMap::GetFormat()
{
	return TEXF_BCRGB8;
}
IMPL_INFERRED("Reconstructed from context")
int FLightMap::GetHeight()
{
	return *(INT*)(Pad + 28);
}
IMPL_INFERRED("Reconstructed from context")
int FLightMap::GetNumMips()
{
	return 1;
}
IMPL_TODO("Needs Ghidra analysis")
void * FLightMap::GetRawTextureData(int)
{
	// Ghidra 0x4720: shared stub; returns NULL.
	return NULL;
}
IMPL_INFERRED("Reconstructed from context")
int FLightMap::GetRevision()
{
	return *(INT*)(Pad + 32);
}
IMPL_TODO("Needs Ghidra analysis")
void FLightMap::GetTextureData(int,void *,int,ETextureFormat,int)
{
	// Ghidra 0x110560 ~900 bytes. Caches per-lightmap sample data into GCache,
	// computes lighting contributions from each dynamic light, and copies
	// the result into param_2. Too complex to translate in full here.
	// TODO: implement FLightMap::GetTextureData (retail 0x110560, ~900 bytes: caches per-lightmap samples, computes lighting contributions)
	guard(FLightMap::GetTextureData);
	unguard;
}
IMPL_INFERRED("Reconstructed from context")
ETexClampMode FLightMap::GetUClamp()
{
	return TC_Clamp;
}
IMPL_TODO("Needs Ghidra analysis")
UTexture * FLightMap::GetUTexture()
{
	// Ghidra 0x114310: shared stub; returns NULL.
	return NULL;
}
IMPL_INFERRED("Reconstructed from context")
ETexClampMode FLightMap::GetVClamp()
{
	return TC_Clamp;
}
IMPL_INFERRED("Reconstructed from context")
int FLightMap::GetWidth()
{
	return *(INT*)(Pad + 24);
}


// --- FLightMapTexture ---
IMPL_INFERRED("Reconstructed from context")
FLightMapTexture::FLightMapTexture(FLightMapTexture const &Other)
{
	// Ghidra 0x20e50: vtable set by compiler; copy DWORD at +4; copy TArray<FLOAT> at +8;
	// copy FStaticLightMapTexture sub-object at +0x14
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	new ((BYTE*)this + 0x08) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x08));
	new ((BYTE*)this + 0x14) FStaticLightMapTexture(*(const FStaticLightMapTexture*)((const BYTE*)&Other + 0x14));
	appMemcpy((BYTE*)this + 0x60, (const BYTE*)&Other + 0x60, 0x0C); // 3 DWORDs
}

IMPL_INFERRED("Reconstructed from context")
FLightMapTexture::FLightMapTexture(ULevel* Level)
{
	// Ghidra 0x110bd0: init TArray<FLOAT> at +8, init FStaticLightMapTexture at +0x14, store Level at +4
	new ((BYTE*)this + 0x08) TArray<FLOAT>();
	new ((BYTE*)this + 0x14) FStaticLightMapTexture();
	*(ULevel**)((BYTE*)this + 0x04) = Level;
}

IMPL_INFERRED("Reconstructed from context")
FLightMapTexture::FLightMapTexture()
{
	// Ghidra 0x279b0: init TArray<FLOAT> at +8, init FStaticLightMapTexture at +0x14
	new ((BYTE*)this + 0x08) TArray<FLOAT>();
	new ((BYTE*)this + 0x14) FStaticLightMapTexture();
}

IMPL_INFERRED("Reconstructed from context")
FLightMapTexture::~FLightMapTexture()
{
	// Ghidra 0x20df0: destroy FStaticLightMapTexture at +0x14, then TArray<FLOAT> at +8
	((FStaticLightMapTexture*)((BYTE*)this + 0x14))->~FStaticLightMapTexture();
	((TArray<FLOAT>*)((BYTE*)this + 0x08))->~TArray();
}

IMPL_INFERRED("Reconstructed from context")
FLightMapTexture& FLightMapTexture::operator=(const FLightMapTexture& Other)
{
	// Ghidra 0x20ed0: skip vtable +0; +4=DWORD; +8=TArray<FLOAT>; +0x14=FStaticLightMapTexture subobj; +0x60,+0x64,+0x68=3 DWORDs
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	*(TArray<FLOAT>*)((BYTE*)this + 0x08) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x08);
	*(FStaticLightMapTexture*)((BYTE*)this + 0x14) = *(const FStaticLightMapTexture*)((const BYTE*)&Other + 0x14);
	appMemcpy((BYTE*)this + 0x60, (const BYTE*)&Other + 0x60, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
IMPL_INFERRED("Reconstructed from context")
unsigned __int64 FLightMapTexture::GetCacheId()
{
	return *(QWORD*)(Pad + 92);
}
IMPL_INFERRED("Reconstructed from context")
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
IMPL_TODO("Needs Ghidra analysis")
int FLightMapTexture::GetFirstMip()
{
	// Ghidra 0x114310: shared stub; returns 0.
	return 0;
}
IMPL_INFERRED("Reconstructed from context")
ETextureFormat FLightMapTexture::GetFormat()
{
	return TEXF_BCRGB8;
}
IMPL_INFERRED("Reconstructed from context")
int FLightMapTexture::GetHeight()
{
	return 0x200;
}
IMPL_INFERRED("Reconstructed from context")
int FLightMapTexture::GetNumChildren()
{
	// TArray at this+8; ArrayNum is 4 bytes into TArray
	return *(INT*)(Pad + 8);
}
IMPL_INFERRED("Reconstructed from context")
int FLightMapTexture::GetNumMips()
{
	return 1;
}
IMPL_INFERRED("Reconstructed from context")
int FLightMapTexture::GetRevision()
{
	return *(INT*)(Pad + 100);
}
IMPL_INFERRED("Reconstructed from context")
ETexClampMode FLightMapTexture::GetUClamp()
{
	// Retail: 33 C0 C3 = return 0 = TC_Wrap
	return TC_Wrap;
}
IMPL_INFERRED("Reconstructed from context")
ETexClampMode FLightMapTexture::GetVClamp()
{
	// Retail: 33 C0 C3 = return 0 = TC_Wrap
	return TC_Wrap;
}
IMPL_INFERRED("Reconstructed from context")
int FLightMapTexture::GetWidth()
{
	return 0x200;
}


// --- FLineBatcher ---
IMPL_INFERRED("Reconstructed from context")
FLineBatcher::FLineBatcher(FLineBatcher const &Other)
{
	// Ghidra 0x27320: vtable set by compiler; TArray<FLineVertex> at +4 (stride 0x10); 5 DWORDs at +10..+20
	new ((BYTE*)this + 0x04) TArray<FLineVertex>(*(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x14); // 5 DWORDs
}

IMPL_INFERRED("Reconstructed from context")
FLineBatcher::FLineBatcher(FRenderInterface *,int,int)
{
	// Initialize TArray<FLineVertex> at +4 to empty so dtor is safe
	new ((BYTE*)this + 0x04) TArray<FLineVertex>();
	appMemzero((BYTE*)this + 0x10, 0x14); // zero state DWORDs
}

IMPL_INFERRED("Reconstructed from context")
FLineBatcher::~FLineBatcher()
{
	// Ghidra 0x418050: reset vtable, call Flush(false), destroy TArray<FLineVertex> at +4
	// Flush() is a stub; we just destroy the TArray
	((TArray<FLineVertex>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_INFERRED("Reconstructed from context")
FLineBatcher& FLineBatcher::operator=(const FLineBatcher& Other)
{
	// Ghidra 0x27360: skip vtable at +0, TArray<FLineVertex> at +4 (FUN_1031e1c0=16-byte),
	// then 5 DWORDs at +0x10..+0x20
	*(TArray<FLineVertex>*)((BYTE*)this + 0x04) = *(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x14); // 5 DWORDs
	return *this;
}

IMPL_TODO("Needs Ghidra analysis")
void FLineBatcher::DrawConvexVolume(FConvexVolume Volume, FColor Color)
{
	// Ghidra 0x115560: too complex to fully decompile (FPoly + plane iteration); left empty.
	// TODO: implement FLineBatcher::DrawConvexVolume (Ghidra 0x115560: FPoly + plane iteration)
}

// (merged from earlier occurrence)
IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
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

IMPL_TODO("Needs Ghidra analysis")
void FLineBatcher::DrawCylinder(FRenderInterface* RI, FVector Base, FVector X, FVector Y, FVector Z, FColor Color, FLOAT Radius, FLOAT HalfHeight, INT NumSides)
{
	// Ghidra 0x114e50: too complex to fully decompile; left empty.
	// TODO: implement FLineBatcher::DrawCylinder (Ghidra 0x114e50)
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
void FLineBatcher::DrawLine(FVector Start, FVector End, FColor Color)
{
	// Ghidra 0x1143c0: add two FLineVertex entries (16 bytes each) to TArray at this+4.
	TArray<FLineVertex>* Verts = (TArray<FLineVertex>*)((BYTE*)this + 4);
	INT i = Verts->Add(1);
	new (&(*Verts)(i)) FLineVertex(Start, Color);
	i = Verts->Add(1);
	new (&(*Verts)(i)) FLineVertex(End, Color);
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_TODO("Needs Ghidra analysis")
void FLineBatcher::DrawSphere(FVector Center, FColor Color, FLOAT Radius, INT NumSides)
{
	// Ghidra 0x114b90: too complex to fully decompile (FMatrix rotation per ring); left empty.
	// TODO: implement FLineBatcher::DrawSphere (Ghidra 0x114b90: complex FMatrix rotation per ring)
}

IMPL_TODO("Needs Ghidra analysis")
void FLineBatcher::Flush(DWORD Flags)
{
	// Ghidra 0x1172a0: too complex to fully decompile (GCache + UProxyBitmapMaterial + vertex stream).
	// TODO: implement FLineBatcher::Flush (Ghidra 0x1172a0: GCache + UProxyBitmapMaterial + vertex stream)
}
IMPL_INFERRED("Reconstructed from context")
unsigned __int64 FLineBatcher::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}
IMPL_INFERRED("Reconstructed from context")
int FLineBatcher::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 4; C[1].Function = 2;
	return 2;
}
IMPL_TODO("Needs Ghidra analysis")
void FLineBatcher::GetRawStreamData(void ** Out, int Offset)
{
	// Ghidra: *Out = data + offset * 0x10
	*Out = *(BYTE**)Pad + Offset * 0x10;
}
IMPL_INFERRED("Reconstructed from context")
int FLineBatcher::GetRevision()
{
	return 1;
}
IMPL_INFERRED("Reconstructed from context")
int FLineBatcher::GetSize()
{
	// Ghidra: FArray::Num(this+4) << 4, TArray at Pad[0]
	return *(INT*)(Pad + 4) << 4;
}
IMPL_INFERRED("Ghidra describes memcpy Num<<4; no standalone address")
void FLineBatcher::GetStreamData(void * Dest)
	INT Size = *(INT*)(Pad + 4) << 4;
	appMemcpy(Dest, *(void**)Pad, Size);
}
IMPL_INFERRED("Returns fixed stride 0x10; no Ghidra address")
int FLineBatcher::GetStride()


// --- FRaw32BitIndexBuffer ---
IMPL_GHIDRA("Engine.dll", 0x209a0)
FRaw32BitIndexBuffer::FRaw32BitIndexBuffer(FRaw32BitIndexBuffer const &Other)
{
	// Ghidra 0x209a0: vtable set by compiler; TArray<FLOAT> at +4 (stride 4); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

IMPL_INFERRED("Default constructor; initializes TArray<FLOAT> at +4 to empty")
FRaw32BitIndexBuffer::FRaw32BitIndexBuffer()
{
	// Initialize TArray<FLOAT> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FLOAT>();
}

IMPL_GHIDRA("Engine.dll", 0x1032c020)
FRaw32BitIndexBuffer::~FRaw32BitIndexBuffer()
	((TArray<FLOAT>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_GHIDRA("Engine.dll", 0x275b0)
FRaw32BitIndexBuffer& FRaw32BitIndexBuffer::operator=(const FRaw32BitIndexBuffer& Other)
{
	// Ghidra 0x275b0: skip vtable +0; +4=TArray<FLOAT> (FUN_1031f660); +0x10,+0x14,+0x18=3 DWORDs
	// Shares address with FRawColorStream and FStaticMeshColorStream.
	*(TArray<FLOAT>*)((BYTE*)this + 0x04) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
IMPL_INFERRED("Returns QWORD cache ID from Pad+12; no Ghidra address")
unsigned __int64 FRaw32BitIndexBuffer::GetCacheId()
}
IMPL_INFERRED("Ghidra describes memcpy Num<<2; no standalone address")
void FRaw32BitIndexBuffer::GetContents(void * Dest)
	INT Size = *(INT*)(Pad + 4) << 2;
	appMemcpy(Dest, *(void**)Pad, Size);
}
IMPL_INFERRED("Returns fixed index size 4; no Ghidra address")
int FRaw32BitIndexBuffer::GetIndexSize()
}
IMPL_INFERRED("Returns revision from Pad+20; no Ghidra address")
int FRaw32BitIndexBuffer::GetRevision()
}
IMPL_INFERRED("Ghidra describes Num << 2; no standalone address")
int FRaw32BitIndexBuffer::GetSize()
	return *(INT*)(Pad + 4) << 2;
}


// --- FRawColorStream ---
IMPL_GHIDRA("Engine.dll", 0x27570)
FRawColorStream::FRawColorStream(FRawColorStream const &Other)
{
	// Ghidra 0x27570: vtable set by compiler; TArray<FLOAT> at +4 (stride 4); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

IMPL_INFERRED("Default constructor; initializes TArray<FLOAT> at +4 to empty")
FRawColorStream::FRawColorStream()
{
	// Initialize TArray<FLOAT> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FLOAT>();
}

IMPL_GHIDRA("Engine.dll", 0x1032c020)
FRawColorStream::~FRawColorStream()
	((TArray<FLOAT>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_GHIDRA("Engine.dll", 0x275b0)
FRawColorStream& FRawColorStream::operator=(const FRawColorStream& Other)
{
	// Ghidra 0x275b0: same body as FRaw32BitIndexBuffer::operator=
	*(TArray<FLOAT>*)((BYTE*)this + 0x04) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
IMPL_INFERRED("Returns QWORD cache ID from Pad+12; no Ghidra address")
unsigned __int64 FRawColorStream::GetCacheId()
}
IMPL_INFERRED("Vertex component layout inferred from colour stream type; no Ghidra address")
int FRawColorStream::GetComponents(FVertexComponent* C)
	return 1;
}
IMPL_INFERRED("Ghidra describes logic; no standalone address extracted")
void FRawColorStream::GetRawStreamData(void ** Out, int Offset)
	*Out = *(BYTE**)Pad + Offset * 4;
}
IMPL_INFERRED("Returns revision from Pad+20; no Ghidra address")
int FRawColorStream::GetRevision()
}
IMPL_INFERRED("Ghidra describes Num << 2; no standalone address")
int FRawColorStream::GetSize()
	return *(INT*)(Pad + 4) << 2;
}
IMPL_INFERRED("Ghidra describes memcpy Num<<2; no standalone address")
void FRawColorStream::GetStreamData(void * Dest)
	INT Size = *(INT*)(Pad + 4) << 2;
	appMemcpy(Dest, *(void**)Pad, Size);
}
IMPL_INFERRED("Returns fixed stride 4; no Ghidra address")
int FRawColorStream::GetStride()


// --- FRawIndexBuffer ---
IMPL_GHIDRA_APPROX("Engine.dll", 0x116e70, "NvTriStrip not available; strip generation skipped; revision still bumped")
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

IMPL_GHIDRA("Engine.dll", 0x18d80)
FRawIndexBuffer::FRawIndexBuffer(FRawIndexBuffer const &Other)
{
	// Ghidra 0x18d80: vtable set by compiler; TArray<_WORD> at +4 (stride 2); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<_WORD>(*(const TArray<_WORD>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

IMPL_INFERRED("Default constructor; initializes TArray<_WORD> at +4 to empty")
FRawIndexBuffer::FRawIndexBuffer()
{
	// Initialize TArray<_WORD> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<_WORD>();
}

IMPL_INFERRED("Destroys TArray<_WORD> at +4; no Ghidra address")
FRawIndexBuffer::~FRawIndexBuffer()
	((TArray<_WORD>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_GHIDRA("Engine.dll", 0x18dc0)
FRawIndexBuffer& FRawIndexBuffer::operator=(const FRawIndexBuffer& Other)
{
	// Ghidra 0x18dc0: skip vtable +0; +4=TArray<_WORD>; +0x10,+0x14,+0x18=3 DWORDs
	*(TArray<_WORD>*)((BYTE*)this + 0x04) = *(const TArray<_WORD>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
IMPL_GHIDRA_APPROX("Engine.dll", 0x116860, "NvTriStrip cache-optimiser not available; optimisation pass skipped")
void FRawIndexBuffer::CacheOptimize()
{
	// Ghidra 0x116860: uses FUN_1048d8b0/FUN_1048d8c0 (external cache-optimiser).
	// Those functions are not reconstructed; increment revision counter only.
	// DIVERGENCE: optimisation pass skipped; revision still bumped for cache invalidation.
	*(INT*)(Pad + 20) += 1;
}
IMPL_INFERRED("Returns QWORD cache ID from Pad+12; no Ghidra address")
unsigned __int64 FRawIndexBuffer::GetCacheId()
}
IMPL_INFERRED("Reconstructed from context")
void FRawIndexBuffer::GetContents(void* Dest)
{
	// Retail: 0x1141c0. TArray<WORD> at this+4 (= Pad+0). Copy Num*2 bytes.
	void*  data = *(void**)Pad;
	INT    num  = *(INT*)(Pad + 4);
	appMemcpy(Dest, data, num * 2);
}
IMPL_INFERRED("Reconstructed from context")
int FRawIndexBuffer::GetIndexSize()
{
	return 2;
}
IMPL_INFERRED("Reconstructed from context")
int FRawIndexBuffer::GetRevision()
{
	return *(INT*)(Pad + 20);
}
IMPL_INFERRED("Retail byte sequence confirms Num << 1; no standalone Ghidra address")
int FRawIndexBuffer::GetSize()
	// TArray<_WORD> at object+4; ArrayNum at +4 within TArray = Pad+4
	return *(INT*)(Pad + 4) << 1;
}


// --- FSkinVertexStream ---
IMPL_GHIDRA("Engine.dll", 0x2b7d0)
FSkinVertexStream::FSkinVertexStream(FSkinVertexStream const &Other)
{
	// Ghidra 0x2b7d0: vtable set by compiler; 7 DWORDs at +4..+1c; TArray<FStreamVert32> at +20 (stride 0x20)
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x1C); // 7 DWORDs
	new ((BYTE*)this + 0x20) TArray<FStreamVert32>(*(const TArray<FStreamVert32>*)((const BYTE*)&Other + 0x20));
}

IMPL_INFERRED("Default constructor; initializes TArray<FStreamVert32> at +0x20 to empty")
FSkinVertexStream::FSkinVertexStream()
{
	// Initialize TArray<FStreamVert32> at +0x20 to empty
	new ((BYTE*)this + 0x20) TArray<FStreamVert32>();
}

IMPL_INFERRED("Destroys TArray<FStreamVert32> at +0x20; no Ghidra address")
FSkinVertexStream::~FSkinVertexStream()
	((TArray<FStreamVert32>*)((BYTE*)this + 0x20))->~TArray();
}

IMPL_GHIDRA("Engine.dll", 0x2b820)
FSkinVertexStream& FSkinVertexStream::operator=(const FSkinVertexStream& Other)
{
	// Ghidra 0x2b820: skip vtable at +0, 7 DWORDs at +4..+1C,
	// TArray<FStreamVert32> at +20 (FUN_1031f7d0 = 32-byte GPU verts)
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x1C); // 7 DWORDs
	*(TArray<FStreamVert32>*)((BYTE*)this + 0x20) = *(const TArray<FStreamVert32>*)((const BYTE*)&Other + 0x20);
	return *this;
}

// (merged from earlier occurrence)
IMPL_INFERRED("Returns QWORD cache ID from Pad+8; no Ghidra address")
unsigned __int64 FSkinVertexStream::GetCacheId()
}
IMPL_INFERRED("Vertex component layout inferred from skin stream type; no Ghidra address")
int FSkinVertexStream::GetComponents(FVertexComponent* C)
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}
IMPL_INFERRED("Retail describes GPU-only path; no standalone Ghidra address")
void FSkinVertexStream::GetRawStreamData(void ** ppData, int FirstVertex)
{
	// Retail: 20b. GPU-only skin stream; no CPU-accessible raw pointer.
	// If stream data ptr at this+0x1C is non-null: set *ppData = NULL (GPU ptr, unreadable).
	// If null: cross-function-jump (stream not allocated).
	if (*(DWORD*)(Pad + 0x18))
		*ppData = NULL;
}
IMPL_INFERRED("Returns revision from Pad+16; no Ghidra address")
int FSkinVertexStream::GetRevision()
}
IMPL_INFERRED("Retail describes GPU/CPU size logic; no standalone Ghidra address")
int FSkinVertexStream::GetSize()
	// If null, no data allocated → return 0.
	// Otherwise: load parent object from Pad+4 ([this+8]), call vtable slot 78
	// (offset 0x138) to get vertex count, multiply by stride 32 (SHL 5).
	if (!*(DWORD*)(Pad + 0x18)) return 0;
	void* obj = *(void**)(Pad + 4);
	typedef INT (__thiscall* FnType)(void*);
	FnType fn = (FnType)(*(void***)obj)[0x138 / sizeof(void*)];
	return fn(obj) << 5; // vertex_count * 32
}
IMPL_GHIDRA("Engine.dll", 0x130c50)
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
IMPL_INFERRED("Returns fixed stride 0x20; no Ghidra address")
int FSkinVertexStream::GetStride()
{
	return 0x20;
}


// --- FStaticLightMapTexture ---
IMPL_GHIDRA("Engine.dll", 0x20cf0)
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

IMPL_GHIDRA_APPROX("Engine.dll", 0x27960, "CacheId left 0; retail uses global per-resource counter DAT_1060b564")
FStaticLightMapTexture::FStaticLightMapTexture()
	// cache ID at +0x40 uses a global render-resource counter (DAT_1060b564, not reconstructed);
	// revision at +0x48 = 0.
	appMemzero((BYTE*)this + 0x08, 0x08); // TLazyArray[0] header DWORDs
	new ((BYTE*)this + 0x10) TArray<BYTE>();
	appMemzero((BYTE*)this + 0x20, 0x08); // TLazyArray[1] header DWORDs
	new ((BYTE*)this + 0x28) TArray<BYTE>();
	appMemzero((BYTE*)this + 0x34, 0x18); // extra fields (includes CacheId, Revision = 0)
	// DIVERGENCE: CacheId left 0; retail uses a global per-resource counter (DAT_1060b564).
}

IMPL_GHIDRA("Engine.dll", 0x20cd0)
FStaticLightMapTexture::~FStaticLightMapTexture()
	((TArray<BYTE>*)((BYTE*)this + 0x28))->~TArray();
	((TArray<BYTE>*)((BYTE*)this + 0x10))->~TArray();
}

IMPL_GHIDRA("Engine.dll", 0x20d50)
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
IMPL_INFERRED("Returns QWORD cache ID from Pad+60; no Ghidra address")
unsigned __int64 FStaticLightMapTexture::GetCacheId()
}
IMPL_INFERRED("Ghidra describes UTexture::__Client check; no standalone address")
int FStaticLightMapTexture::GetFirstMip()
	if (UTexture::__Client != NULL && *(INT*)((BYTE*)UTexture::__Client + 0x70) != 0)
		return 1;
	return 0;
}
IMPL_INFERRED("Returns format from Pad+48; no Ghidra address")
ETextureFormat FStaticLightMapTexture::GetFormat()
}
IMPL_INFERRED("Returns height from Pad+56; no Ghidra address")
int FStaticLightMapTexture::GetHeight()
}
IMPL_INFERRED("Returns fixed mip count 2; no Ghidra address")
int FStaticLightMapTexture::GetNumMips()
}
IMPL_GHIDRA_APPROX("Engine.dll", 0x10FE60, "GIsEditor assertion removed; returns NULL when not editor-loaded")
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
IMPL_INFERRED("Returns revision from Pad+68; no Ghidra address")
int FStaticLightMapTexture::GetRevision()
}
IMPL_TODO("Needs Ghidra analysis")
void FStaticLightMapTexture::GetTextureData(int,void *,int,ETextureFormat,int)
{
	// TODO: implement FStaticLightMapTexture::GetTextureData (Ghidra: complex lazy-load + DXT decode pipeline)
}
IMPL_INFERRED("Reconstructed from context")
ETexClampMode FStaticLightMapTexture::GetUClamp()
{
	return TC_Wrap;
}
IMPL_TODO("Needs Ghidra analysis")
UTexture * FStaticLightMapTexture::GetUTexture()
{
	// Ghidra 0x114310: shared stub; returns NULL.
	return NULL;
}
IMPL_INFERRED("Reconstructed from context")
ETexClampMode FStaticLightMapTexture::GetVClamp()
{
	return TC_Wrap;
}
IMPL_INFERRED("Reconstructed from context")
int FStaticLightMapTexture::GetWidth()
{
	return *(INT*)(Pad + 52);
}
IMPL_INFERRED("Reconstructed from context")
unsigned __int64 FStaticMeshUVStream::GetCacheId()
{
	return *(QWORD*)(Pad + 16);
}
IMPL_INFERRED("Reconstructed from context")
int FStaticMeshUVStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 2; C[0].Function = *(INT*)(Pad + 0x0C) + 4;
	return 1;
}
IMPL_TODO("Needs Ghidra analysis")
void FStaticMeshUVStream::GetRawStreamData(void ** Out, int Offset)
{
	// Ghidra: *Out = data + offset * 8
	*Out = *(BYTE**)Pad + Offset * 8;
}
IMPL_INFERRED("Reconstructed from context")
int FStaticMeshUVStream::GetRevision()
{
	return *(INT*)(Pad + 24);
}
IMPL_INFERRED("Reconstructed from context")
int FStaticMeshUVStream::GetSize()
{
	// Ghidra: Num << 3 (stride = 8)
	return *(INT*)(Pad + 4) << 3;
}
IMPL_INFERRED("Reconstructed from context")
void FStaticMeshUVStream::GetStreamData(void * Dest)
{
	// Ghidra: memcpy Num<<3 bytes from TArray data
	INT Size = *(INT*)(Pad + 4) << 3;
	appMemcpy(Dest, *(void**)Pad, Size);
}
IMPL_INFERRED("Reconstructed from context")
int FStaticMeshUVStream::GetStride()
{
	return 8;
}
IMPL_INFERRED("Reconstructed from context")
unsigned __int64 FStaticMeshVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}
IMPL_INFERRED("Reconstructed from context")
int FStaticMeshVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	return 2;
}
IMPL_TODO("Needs Ghidra analysis")
void FStaticMeshVertexStream::GetRawStreamData(void ** ppData, int FirstVertex)
{
	// Retail: data = [this+4] (TArray.Data); stride = 24 (3*8); Pad[0] = this+4
	*ppData = *(BYTE**)(Pad + 0) + FirstVertex * 0x18;
}
IMPL_INFERRED("Reconstructed from context")
int FStaticMeshVertexStream::GetRevision()
{
	return *(INT*)(Pad + 20);
}
IMPL_INFERRED("Reconstructed from context")
int FStaticMeshVertexStream::GetSize()
{
	// Ghidra (16B): FArray::Num(this+4) * 0x18; Pad[0] = FArray at offset 4
	INT Num = *(INT*)(Pad + 4); // ArrayNum field of FArray at this+4
	return Num * 0x18;
}
IMPL_INFERRED("Reconstructed from context")
void FStaticMeshVertexStream::GetStreamData(void* Dest)
{
	// Retail: 0x1c970. TArray of 24-byte verts at this+4 (= Pad+0). Copy Num*24 bytes.
	void*  data = *(void**)Pad;
	INT    num  = *(INT*)(Pad + 4);
	appMemcpy(Dest, data, num * 0x18);
}
IMPL_INFERRED("Reconstructed from context")
int FStaticMeshVertexStream::GetStride()
{
	return 0x18;
}


// --- FStaticTexture ---
IMPL_INFERRED("Reconstructed from context")
FStaticTexture::FStaticTexture(FStaticTexture const &Other)
{
	// Ghidra 0x20b50: vtable set by compiler; scalar copy of 4 DWORDs at +4..+10. Shares address with FStaticCubemap.
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
}

IMPL_INFERRED("Reconstructed from context")
FStaticTexture::FStaticTexture(UTexture* Texture)
{
	// Ghidra 0x16a9a0: store texture pointer, compute CacheId, set initial revision.
	// Layout (Pad is at this+4): Pad[0..7]=CacheId QWORD; Pad[8..11]=UTexture*; Pad[12..15]=Revision.
	*(UTexture**)&Pad[8]  = Texture;
	DWORD Idx             = Texture ? Texture->GetIndex() : 0;
	*(QWORD*)&Pad[0]      = (QWORD)Idx * 0x100 + 0xE0;
	*(INT*)&Pad[12]       = 1;
}

IMPL_INFERRED("Reconstructed from context")
FStaticTexture& FStaticTexture::operator=(const FStaticTexture& Other)
{
	// Ghidra 0x18ee0: skip vtable at +0, copy 4 DWORDs at +4..+10.
	// Shares address with FStaticCubemap.
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
	return *this;
}

// (merged from earlier occurrence)
IMPL_INFERRED("Reconstructed from context")
unsigned __int64 FStaticTexture::GetCacheId()
{
	// Ghidra: return *(__uint64*)(this + 4); CacheId at Pad[0..7]
	return *(QWORD*)&Pad[0];
}
IMPL_INFERRED("Reconstructed from context")
int FStaticTexture::GetFirstMip()
{
	// Ghidra: UTexture::DefaultLOD(Texture)
	UTexture* Texture = *(UTexture**)&Pad[8];
	return Texture->DefaultLOD();
}
IMPL_INFERRED("Reconstructed from context")
ETextureFormat FStaticTexture::GetFormat()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return (ETextureFormat)Texture->Format;
}
IMPL_INFERRED("Reconstructed from context")
int FStaticTexture::GetHeight()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return Texture->VSize;
}
IMPL_INFERRED("Reconstructed from context")
IMPL_INFERRED("Returns Texture->Mips.Num(); no Ghidra address")
int FStaticTexture::GetNumMips()
}
IMPL_INFERRED("Reconstructed from context")
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
IMPL_INFERRED("Reconstructed from context")
int FStaticTexture::GetRevision()
{
	// Retail: 8B 41 0C F6 80 94 00 00 00 40 74 0A FF 41 10 83 A0 94 00 00 00 BF 8B 41 10 C3
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
IMPL_TODO("Needs Ghidra analysis")
void FStaticTexture::GetTextureData(int,void *,int,ETextureFormat,int)
{
	// TODO: implement FStaticTexture::GetTextureData (Ghidra: complex lazy-load path)
}
IMPL_INFERRED("Reconstructed from context")
ETexClampMode FStaticTexture::GetUClamp()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return (ETexClampMode)Texture->UClampMode;
}
IMPL_INFERRED("Reconstructed from context")
UTexture * FStaticTexture::GetUTexture()
{
	return *(UTexture**)&Pad[8];
}
IMPL_INFERRED("Reconstructed from context")
ETexClampMode FStaticTexture::GetVClamp()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return (ETexClampMode)Texture->VClampMode;
}
IMPL_INFERRED("Reconstructed from context")
int FStaticTexture::GetWidth()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return Texture->USize;
}


// --- FBspSection ---
IMPL_INFERRED("Reconstructed from context")
FBspSection::FBspSection(FBspSection const &Other)
{
	// Ghidra 0x27b60: vtable set by compiler; TArray<FBspVertex> at +4 (stride 0x28); 7 DWORDs at +10..+28
	new ((BYTE*)this + 0x04) TArray<FBspVertex>(*(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x1C); // 7 DWORDs
}

IMPL_INFERRED("Reconstructed from context")
FBspSection::FBspSection()
{
	// Initialize TArray<FBspVertex> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FBspVertex>();
}

IMPL_INFERRED("Reconstructed from context")
FBspSection::~FBspSection()
{
	// Ghidra 0x103278e0: shared with ~FBspVertexStream; destroy TArray<FBspVertex> at +4
	((TArray<FBspVertex>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_INFERRED("Reconstructed from context")
FBspSection& FBspSection::operator=(const FBspSection& Other)
{
	// Ghidra 0x27bb0: skip vtable at +0, TArray<FBspVertex> at +4 (FUN_10324ae0=40-byte elems),
	// then 7 DWORDs at +0x10..+0x28
	*(TArray<FBspVertex>*)((BYTE*)this + 0x04) = *(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x1C); // 7 DWORDs
	return *this;
}


// --- FBspVertex ---
IMPL_TODO("Needs Ghidra analysis")
FBspVertex::FBspVertex()
{
	// Ghidra: constructs two FVectors at offset 0 and 0xC (Position + Normal)
	*(FVector*)&_Data[0] = FVector(0,0,0);
	*(FVector*)&_Data[12] = FVector(0,0,0);
}

IMPL_INFERRED("Reconstructed from context")
FBspVertex& FBspVertex::operator=(const FBspVertex& Other)
{
	appMemcpy( this, &Other, sizeof(FBspVertex) );
	return *this;
}


// --- FConvexVolume ---
IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
FConvexVolume::FConvexVolume(const FConvexVolume& Other)
{
	// Ghidra 0x3750: 32 FPlane copy ctors (FPlane is POD) + 24 DWORDs = 0x260 bytes total
	appMemcpy(this, &Other, 0x260);
}

IMPL_INFERRED("Reconstructed from context")
FConvexVolume::FConvexVolume()
{
	// Ghidra: default ctor; no heap allocation; stack/member data left to caller init.
	NumPlanes = 0;
}

IMPL_TODO("Needs Ghidra analysis")
FConvexVolume::~FConvexVolume()
{
	// Ghidra: trivial dtor; no heap to free.
}

IMPL_INFERRED("Reconstructed from context")
FConvexVolume& FConvexVolume::operator=(const FConvexVolume& Other)
{
	// Ghidra 0x37f0: 0x98 DWORDs from offset 0 (no vtable)
	appMemcpy(this, &Other, 0x260);
	return *this;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
FPoly FConvexVolume::ClipPolygon(FPoly)
{
	return FPoly();
}

IMPL_INFERRED("Reconstructed from context")
FPoly FConvexVolume::ClipPolygonPrecise(FPoly)
{
	return FPoly();
}


// --- FDynamicActor ---
IMPL_TODO("Needs Ghidra analysis")
void FDynamicActor::Render(FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	// Ghidra: deferred to mesh renderer via vtable; actual dispatch is in UMeshInstance::Render.
	// INTENTIONALLY EMPTY: rendering dispatched via UMeshInstance::Render vtable; FDynamicActor::Render has no per-type render logic
}

IMPL_INFERRED("Reconstructed from context")
FDynamicActor::FDynamicActor(const FDynamicActor& Other)
{
	// Ghidra 0x135d0: no vtable; flat copy of 0x80 bytes (same as operator= at 0x13660)
	appMemcpy(this, &Other, 0x80);
}

IMPL_INFERRED("Reconstructed from context")
FDynamicActor::FDynamicActor(AActor* Actor)
{
	// Ghidra 0xffb70: construct sub-objects, store actor pointer, compute transform/bounds.
	// FMatrix at this+4, FBox at this+0x48, FSphere at this+0x64; actor pointer at this+0.
	new ((BYTE*)this + 0x04) FMatrix();
	new ((BYTE*)this + 0x48) FBox();
	new ((BYTE*)this + 0x64) FSphere();
	*(AActor**)this = Actor;
	// TODO: complete FDynamicActor constructor mesh/physics transform setup (requires unresolved FUN_* helpers)
}

IMPL_TODO("Needs Ghidra analysis")
FDynamicActor::~FDynamicActor()
{
	// Ghidra: trivial dtor; no heap to free.
}

IMPL_INFERRED("Reconstructed from context")
FDynamicActor& FDynamicActor::operator=(const FDynamicActor& Other)
{
	// Ghidra 0x13660: 0x20 DWORDs from offset 0 (FDynamicActor has no vtable)
	appMemcpy(this, &Other, 0x80);
	return *this;
}


// --- FDynamicLight ---
IMPL_INFERRED("Reconstructed from context")
float FDynamicLight::SampleIntensity(FVector Point, FVector Normal)
{
	// Retail: 0x10D5D0, ~200b. Evaluates per-sample light intensity based on light type.
	// Light type byte is stored at vtable+0x37 (custom descriptor, not C++ vtable).
	// LightPos = this+0x14 (FVector), LightDir = this+0x20 (FVector), Radius = this+0x2C.
	BYTE lightType = *(BYTE*)(*(BYTE**)this + 0x37);

	if (lightType == 0x14) // LT_Directional — dot-product with surface normal
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
			FLOAT r_sq = dX*dX + dY*dY; // XY plane only
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
		FLOAT dist = appSqrt(dX*dX + dY*dY + dZ*dZ);
		FLOAT Radius = *(FLOAT*)((BYTE*)this + 0x2C);
		FLOAT inDot = dX * Normal.X + dZ * Normal.Z + dY * Normal.Y;
		if (inDot > 0.0f && dist < Radius)
		{
			FLOAT f = appSqrt(1.02f - dist / Radius);
			return f + f;
		}
	}
	else
	{
		// Types 0x0C, 0x08 and others: distance falloff + optional cone attenuation.
		// DIVERGENCE: FUN_1040d530 (radius-based falloff via x87 FPU stack) not implemented;
		// approximated as linear falloff. Cases 0x0C/0x08 use same formula, cone attenuation
		// applied for non-0x0C/0x08 types when falloff > 0.
		FLOAT dX = *(FLOAT*)((BYTE*)this + 0x14) - Point.X;
		FLOAT dY = *(FLOAT*)((BYTE*)this + 0x18) - Point.Y;
		FLOAT dZ = *(FLOAT*)((BYTE*)this + 0x1C) - Point.Z;
		FLOAT dist   = appSqrt(dX*dX + dY*dY + dZ*dZ);
		FLOAT Radius = *(FLOAT*)((BYTE*)this + 0x2C);
		// Approximate FUN_1040d530: linear falloff
		FLOAT baseFalloff = (Radius > 0.0f) ? (1.0f - dist / Radius) : 0.0f;
		if (baseFalloff <= 0.0f) return 0.0f;

		if (lightType == 0x0C || lightType == 0x08)
			return baseFalloff; // No cone attenuation for these types

		// Apply cone attenuation (spot light style)
		FLOAT cosOuter = 1.0f - *(BYTE*)(*(BYTE**)this + 0x3C) * (1.0f/256.0f);
		if (cosOuter >= 1.0f) return 0.0f;
		FLOAT invRange  = 1.0f / (1.0f - cosOuter);
		FVector* LightDir = (FVector*)((BYTE*)this + 0x20);
		FLOAT coneDot = -dX * LightDir->X - dY * LightDir->Y - dZ * LightDir->Z;
		if (coneDot <= 0.0f) return 0.0f;
		FLOAT distSq = dX*dX + dY*dY + dZ*dZ;
		if (distSq < coneDot * coneDot)
		{
			FLOAT coneAtten = (coneDot / dist) * invRange - invRange * cosOuter;
			return coneAtten * coneAtten * baseFalloff;
		}
	}
	return 0.0f;
}

IMPL_INFERRED("Reconstructed from context")
FColor FDynamicLight::SampleLight(FVector,FVector)
{
	return FColor(0,0,0,0);
}

IMPL_INFERRED("Reconstructed from context")
FDynamicLight::FDynamicLight(FDynamicLight const& Other)
{
	appMemcpy( this, &Other, sizeof(FDynamicLight) );
}

IMPL_INFERRED("Reconstructed from context")
FDynamicLight::FDynamicLight(AActor* Actor)
{
	// Ghidra 0x10ff20: construct sub-objects, store actor, compute light color/direction.
	// FPlane at this+4, FVector at this+0x14, FVector at this+0x20; actor at this+0.
	new ((BYTE*)this + 0x04) FPlane();
	new ((BYTE*)this + 0x14) FVector();
	new ((BYTE*)this + 0x20) FVector();
	*(AActor**)this = Actor;
	// DIVERGENCE: complex light-effect and color setup omitted (requires FGetHSV + LightEffect dispatch).
}

IMPL_INFERRED("Reconstructed from context")
FDynamicLight& FDynamicLight::operator=(const FDynamicLight& Other)
{
	appMemcpy( this, &Other, sizeof(FDynamicLight) );
	return *this;
}


// --- FLightMapIndex ---
IMPL_TODO("Needs Ghidra analysis")
FLightMapIndex::FLightMapIndex()
{
	// Ghidra 0x2b40: constructs FMatrix at +8 and +0x48, FVector at +0x88, +0x94, +0xA0.
	// Header omits member fields; sub-object construction handled by compiler via member decls.
	guard(FLightMapIndex::FLightMapIndex);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
FLightMapIndex::~FLightMapIndex()
{
	// Ghidra 0x2bc0: destructs FMatrix at +0x48 then +8.
	guard(FLightMapIndex::~FLightMapIndex);
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
FLightMapIndex& FLightMapIndex::operator=(const FLightMapIndex& Other)
{
	// Ghidra 0x2c10: 0x30 DWORDs from offset 0 (no vtable)
	appMemcpy(this, &Other, 0xC0);
	return *this;
}


// --- FLineVertex ---
IMPL_TODO("Needs Ghidra analysis")
FLineVertex::FLineVertex(FVector InPoint, FColor InColor)
:	Point(InPoint)
,	Color(InColor)
{
}

IMPL_TODO("Needs Ghidra analysis")
FLineVertex::FLineVertex()
{
	// Ghidra 0x3810: calls FVector::FVector((FVector*)this) then returns.
	// No SEH frame; compiler default-constructs Point (FVector trivial ctor).
}

IMPL_INFERRED("Reconstructed from context")
FLineVertex& FLineVertex::operator=(const FLineVertex& Other)
{
	Point = Other.Point;
	Color = Other.Color;
	return *this;
}


// --- FStaticCubemap ---
IMPL_INFERRED("Reconstructed from context")
FStaticCubemap::FStaticCubemap(FStaticCubemap const &Other)
{
	// Ghidra 0x18eb0: vtable set by compiler; scalar copy of 4 DWORDs at +4..+10
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
}

IMPL_INFERRED("Reconstructed from context")
FStaticCubemap::FStaticCubemap(UCubemap* Cubemap)
{
	// Ghidra 0x16a9f0: store cubemap pointer, compute CacheId, set initial revision.
	// Layout (Pad is at this+4): Pad[0..3]=UCubemap*; Pad[4..11]=CacheId QWORD; Pad[12..15]=Revision.
	*(UCubemap**)&Pad[0] = Cubemap;
	DWORD Idx            = Cubemap ? ((UObject*)Cubemap)->GetIndex() : 0;
	*(QWORD*)(Pad + 4)   = (QWORD)Idx * 0x100 + 0xE0;
	*(INT*)(Pad + 12)    = 1;
}

IMPL_INFERRED("Reconstructed from context")
FStaticCubemap& FStaticCubemap::operator=(const FStaticCubemap& Other)
{
	// Ghidra 0x18ee0: skip vtable at +0, copy 4 DWORDs at +4..+10.
	// Shares address with FStaticTexture.
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
	return *this;
}

IMPL_INFERRED("Reconstructed from context")
unsigned __int64 FStaticCubemap::GetCacheId()
{
	// Ghidra: return QWORD at this+8 = Pad+4
	return *(QWORD*)(Pad + 4);
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
int FStaticCubemap::GetFirstMip()
{
	// UCubemap* at Pad[0] (this+4); cubemap inherits from UTexture.
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->DefaultLOD() : 0;
}

IMPL_INFERRED("Reconstructed from context")
ETextureFormat FStaticCubemap::GetFormat()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? (ETextureFormat)tex->Format : TEXF_P8;
}

IMPL_INFERRED("Reconstructed from context")
int FStaticCubemap::GetHeight()
{
	// Cubemap face height — UCubemap inherits VSize from UTexture.
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->VSize : 0;
}

IMPL_INFERRED("Reconstructed from context")
int FStaticCubemap::GetNumMips()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->Mips.Num() : 0;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
ETexClampMode FStaticCubemap::GetUClamp()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? (ETexClampMode)tex->UClampMode : TC_Wrap;
}

IMPL_INFERRED("Reconstructed from context")
ETexClampMode FStaticCubemap::GetVClamp()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? (ETexClampMode)tex->VClampMode : TC_Wrap;
}

IMPL_INFERRED("Reconstructed from context")
int FStaticCubemap::GetWidth()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->USize : 0;
}


// --- FTempLineBatcher ---
IMPL_INFERRED("Reconstructed from context")
void FTempLineBatcher::Render(FRenderInterface* RI, INT Flags)
{
	// Ghidra 0x1180b0: create a temporary FLineBatcher, draw all stored lines and boxes, flush.
	// Line starts at this+0, ends at this+0xC, line colors at this+0x18 (DWORD in FLOAT slot).
	// Boxes at this+0x24, box colors at this+0x30.
	// DIVERGENCE: FLineBatcher ctor args (cache-key counter DAT_1060b564) not reconstructed;
	// using FLineBatcher(RI, Flags, 0) and relying on existing ctor stub.
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

IMPL_INFERRED("Reconstructed from context")
FTempLineBatcher::FTempLineBatcher(FTempLineBatcher const &Other)
{
	// Ghidra 0x27490: no vtable; TArray<FVector>@+0, TArray<FVector>@+0xC, TArray<FLOAT>@+0x18, TArray<FBox>@+0x24, TArray<FLOAT>@+0x30
	new ((BYTE*)this + 0x00) TArray<FVector>(*(const TArray<FVector>*)((const BYTE*)&Other + 0x00));
	new ((BYTE*)this + 0x0C) TArray<FVector>(*(const TArray<FVector>*)((const BYTE*)&Other + 0x0C));
	new ((BYTE*)this + 0x18) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x18));
	new ((BYTE*)this + 0x24) TArray<FBox>(*(const TArray<FBox>*)((const BYTE*)&Other + 0x24));
	new ((BYTE*)this + 0x30) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x30));
}

IMPL_INFERRED("Reconstructed from context")
FTempLineBatcher::FTempLineBatcher()
{
	// Initialize all 5 TArrays to empty
	new ((BYTE*)this + 0x00) TArray<FVector>();
	new ((BYTE*)this + 0x0C) TArray<FVector>();
	new ((BYTE*)this + 0x18) TArray<FLOAT>();
	new ((BYTE*)this + 0x24) TArray<FBox>();
	new ((BYTE*)this + 0x30) TArray<FLOAT>();
}

IMPL_INFERRED("Reconstructed from context")
FTempLineBatcher::~FTempLineBatcher()
{
	// Destroy 5 TArrays in reverse order
	((TArray<FLOAT>*)((BYTE*)this + 0x30))->~TArray();
	((TArray<FBox>*)((BYTE*)this + 0x24))->~TArray();
	((TArray<FLOAT>*)((BYTE*)this + 0x18))->~TArray();
	((TArray<FVector>*)((BYTE*)this + 0x0C))->~TArray();
	((TArray<FVector>*)((BYTE*)this + 0x00))->~TArray();
}

IMPL_INFERRED("Reconstructed from context")
FTempLineBatcher& FTempLineBatcher::operator=(const FTempLineBatcher& Other)
{
	// Ghidra 0x27520: no vtable; line start/end FVectors at +0/+0C, line colors at +18,
	// box data (FBox) at +24, box colors at +30
	*(TArray<FVector>*)((BYTE*)this + 0x00) = *(const TArray<FVector>*)((const BYTE*)&Other + 0x00);
	*(TArray<FVector>*)((BYTE*)this + 0x0C) = *(const TArray<FVector>*)((const BYTE*)&Other + 0x0C);
	*(TArray<FLOAT>*)((BYTE*)this + 0x18) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x18);
	*(TArray<FBox>*)((BYTE*)this + 0x24) = *(const TArray<FBox>*)((const BYTE*)&Other + 0x24);
	*(TArray<FLOAT>*)((BYTE*)this + 0x30) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x30);
	return *this;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
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
IMPL_TODO("Needs Ghidra analysis")
void UConvexVolume::Serialize(FArchive& Ar)
{
	// Ghidra: trivial serialize stub; no persistent data beyond UObject base.
	// INTENTIONALLY EMPTY: retail trivial serialize stub; no persistent data beyond UObject base
}

IMPL_INFERRED("Reconstructed from context")
FBox UConvexVolume::GetRenderBoundingBox(AActor const *)
{
	// Retail: 23b. REP MOVSD 7 DWORDs (28b = FBox) from this+0x70 to return buffer.
	return *(FBox*)((BYTE*)this + 0x70);
}

IMPL_INFERRED("Reconstructed from context")
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


// --- UIndexBuffer ---
IMPL_INFERRED("Reconstructed from context")
void UIndexBuffer::Serialize(FArchive& Ar)
{
	// Ghidra 0x110d90: URenderResource::Serialize + index data TArray at +0x30.
	// Divergence: TArray<WORD> at +0x30 not serialized (render data reconstructed at load).
	URenderResource::Serialize(Ar);
}


// --- USkinVertexBuffer ---
IMPL_INFERRED("Reconstructed from context")
void USkinVertexBuffer::Serialize(FArchive& Ar)
{
	// Ghidra 0x110f50: URenderResource::Serialize + skin vertex TArray at +0x30.
	// Divergence: skin vertex TArray at +0x30 not serialized (render data reconstructed at load).
	URenderResource::Serialize(Ar);
}

