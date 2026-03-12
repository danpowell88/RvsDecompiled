/*=============================================================================
	UnRenderUtil.cpp: Render buffers, lighting, and BSP geometry helpers
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// extern declarations for FCollisionHash per-frame counters.
extern INT GHashActorCount;
extern INT GHashLinkCellCount;
extern INT GHashExtraCount;

// --- FAnimMeshVertexStream ---
FAnimMeshVertexStream::FAnimMeshVertexStream(FAnimMeshVertexStream const &Other)
{
	// Ghidra 0x2b170: vtable set by compiler; DWORD at +4; TArray<FStreamVert32> at +8 (stride 0x20); 6 DWORDs at +14..+28
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	new ((BYTE*)this + 0x08) TArray<FStreamVert32>(*(const TArray<FStreamVert32>*)((const BYTE*)&Other + 0x08));
	appMemcpy((BYTE*)this + 0x14, (const BYTE*)&Other + 0x14, 0x18); // 6 DWORDs
}

FAnimMeshVertexStream::FAnimMeshVertexStream()
{
	// Initialize TArray<FStreamVert32> at +8 to empty (equivalent to TArray default ctor)
	new ((BYTE*)this + 0x08) TArray<FStreamVert32>();
}

FAnimMeshVertexStream::~FAnimMeshVertexStream()
{
	// Ghidra 0x2b160: destroy TArray<FStreamVert32> at +8 (stride 0x20, POD elements)
	((TArray<FStreamVert32>*)((BYTE*)this + 0x08))->~TArray();
}

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
unsigned __int64 FAnimMeshVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 16);
}
int FAnimMeshVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}
int FAnimMeshVertexStream::GetPartialSize()
{
	// Ghidra: if partial pointer (Pad[28]) non-zero, return min(Pad[32], Num); else Num
	INT Num = *(INT*)(Pad + 8);
	if (*(INT*)(Pad + 28))
	{
		INT PartialCount = *(INT*)(Pad + 32);
		return (PartialCount < Num) ? PartialCount : Num;
	}
	return Num;
}
void FAnimMeshVertexStream::GetRawStreamData(void ** Out, int Offset)
{
	// Ghidra: *Out = data + offset * 0x20
	*Out = *(BYTE**)(Pad + 4) + Offset * 0x20;
}
int FAnimMeshVertexStream::GetRevision()
{
	return *(INT*)(Pad + 24);
}
int FAnimMeshVertexStream::GetSize()
{
	// Ghidra: GetPartialSize() << 5 (multiply by stride 0x20)
	return GetPartialSize() << 5;
}
void FAnimMeshVertexStream::GetStreamData(void * Dest)
{
	// Ghidra: memcpy GetPartialSize()<<5 bytes from data
	INT Size = GetPartialSize() << 5;
	appMemcpy(Dest, *(void**)(Pad + 4), Size);
}
int FAnimMeshVertexStream::GetStride()
{
	return 0x20;
}


// --- FBspVertexStream ---
FBspVertexStream::FBspVertexStream(FBspVertexStream const &Other)
{
	// Ghidra 0x103278f0: vtable set by compiler; TArray<FBspVertex> at +4 (stride 0x28); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FBspVertex>(*(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

FBspVertexStream::FBspVertexStream()
{
	// Initialize TArray<FBspVertex> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FBspVertex>();
}

FBspVertexStream::~FBspVertexStream()
{
	// Ghidra 0x103278e0: shared with ~FBspSection; destroy TArray<FBspVertex> at +4
	((TArray<FBspVertex>*)((BYTE*)this + 0x04))->~TArray();
}

FBspVertexStream& FBspVertexStream::operator=(const FBspVertexStream& Other)
{
	// Ghidra 0x27930: skip vtable at +0, TArray<FBspVertex> at +4 (FUN_10324ae0=40-byte elems),
	// then 3 DWORDs at +0x10..+0x18
	*(TArray<FBspVertex>*)((BYTE*)this + 0x04) = *(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
	return *this;
}

// (merged from earlier occurrence)
unsigned __int64 FBspVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}
int FBspVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	C[3].Type = 2; C[3].Function = 5;
	return 4;
}
void FBspVertexStream::GetRawStreamData(void ** Out, int Offset)
{
	// Ghidra: *Out = data + offset * 0x28
	*Out = *(BYTE**)Pad + Offset * 0x28;
}
int FBspVertexStream::GetRevision()
{
	return *(INT*)(Pad + 20);
}
int FBspVertexStream::GetSize()
{
	// Ghidra: Num * 0x28
	return *(INT*)(Pad + 4) * 0x28;
}
void FBspVertexStream::GetStreamData(void * Dest)
{
	// Ghidra: memcpy Num()*0x28 bytes
	INT Size = *(INT*)(Pad + 4) * 0x28;
	appMemcpy(Dest, *(void**)Pad, Size);
}
int FBspVertexStream::GetStride()
{
	return 0x28;
}


// --- FLevelSceneNode ---
void FLevelSceneNode::Render(FRenderInterface *)
{
}

int FLevelSceneNode::FilterActor(AActor *)
{
	return 0;
}

FLevelSceneNode * FLevelSceneNode::GetLevelSceneNode()
{
	return this;
}


// --- FLightMap ---
FLightMap::FLightMap(FLightMap const &Other)
{
	// Ghidra 0x3c910: vtable set by compiler; 34 DWORDs at +4..+8B; TArray<FLightMapSample52> at +0x8C; TArray<FLOAT> at +0x98
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x88);
	new ((BYTE*)this + 0x8C) TArray<FLightMapSample52>(*(const TArray<FLightMapSample52>*)((const BYTE*)&Other + 0x8C));
	new ((BYTE*)this + 0x98) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x98));
}

FLightMap::FLightMap(ULevel *,int,int)
{
	// Initialize TArray members so dtor is safe regardless of which ctor was called
	new ((BYTE*)this + 0x8C) TArray<FLightMapSample52>();
	new ((BYTE*)this + 0x98) TArray<FLOAT>();
}

FLightMap::FLightMap()
{
	new ((BYTE*)this + 0x8C) TArray<FLightMapSample52>();
	new ((BYTE*)this + 0x98) TArray<FLOAT>();
}

FLightMap::~FLightMap()
{
	// Ghidra 0x3c6a0 area: destroy TArrays in reverse order
	((TArray<FLOAT>*)((BYTE*)this + 0x98))->~TArray();
	((TArray<FLightMapSample52>*)((BYTE*)this + 0x8C))->~TArray();
}

FLightMap& FLightMap::operator=(const FLightMap& Other)
{
	// Ghidra 0x3ca10: skip vtable +0; +4..+8B = 34 DWORDs (contiguous); +0x8C=TArray<FLightMapSample52>; +0x98=TArray<FLOAT>
	appMemcpy((BYTE*)this + 4, (const BYTE*)&Other + 4, 0x88);
	*(TArray<FLightMapSample52>*)((BYTE*)this + 0x8C) = *(const TArray<FLightMapSample52>*)((const BYTE*)&Other + 0x8C);
	*(TArray<FLOAT>*)((BYTE*)this + 0x98) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x98);
	return *this;
}

// (merged from earlier occurrence)
unsigned __int64 FLightMap::GetCacheId()
{
	return 0;
}
int FLightMap::GetFirstMip()
{
	return 0;
}
ETextureFormat FLightMap::GetFormat()
{
	return TEXF_BCRGB8;
}
int FLightMap::GetHeight()
{
	return *(INT*)(Pad + 28);
}
int FLightMap::GetNumMips()
{
	return 1;
}
void * FLightMap::GetRawTextureData(int)
{
	return NULL;
}
int FLightMap::GetRevision()
{
	return *(INT*)(Pad + 32);
}
void FLightMap::GetTextureData(int,void *,int,ETextureFormat,int)
{
}
ETexClampMode FLightMap::GetUClamp()
{
	return TC_Clamp;
}
UTexture * FLightMap::GetUTexture()
{
	return NULL;
}
ETexClampMode FLightMap::GetVClamp()
{
	return TC_Clamp;
}
int FLightMap::GetWidth()
{
	return *(INT*)(Pad + 24);
}


// --- FLightMapTexture ---
FLightMapTexture::FLightMapTexture(FLightMapTexture const &)
{
}

FLightMapTexture::FLightMapTexture(ULevel *)
{
}

FLightMapTexture::FLightMapTexture()
{
}

FLightMapTexture::~FLightMapTexture()
{
}

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
unsigned __int64 FLightMapTexture::GetCacheId()
{
	return *(QWORD*)(Pad + 92);
}
FTexture * FLightMapTexture::GetChild(int,int *,int *)
{
	return NULL;
}
int FLightMapTexture::GetFirstMip()
{
	return 0;
}
ETextureFormat FLightMapTexture::GetFormat()
{
	return TEXF_BCRGB8;
}
int FLightMapTexture::GetHeight()
{
	return 0x200;
}
int FLightMapTexture::GetNumChildren()
{
	// TArray at this+8; ArrayNum is 4 bytes into TArray
	return *(INT*)(Pad + 8);
}
int FLightMapTexture::GetNumMips()
{
	return 1;
}
int FLightMapTexture::GetRevision()
{
	return *(INT*)(Pad + 100);
}
ETexClampMode FLightMapTexture::GetUClamp()
{
	// Retail: 33 C0 C3 = return 0 = TC_Wrap
	return TC_Wrap;
}
ETexClampMode FLightMapTexture::GetVClamp()
{
	// Retail: 33 C0 C3 = return 0 = TC_Wrap
	return TC_Wrap;
}
int FLightMapTexture::GetWidth()
{
	return 0x200;
}


// --- FLineBatcher ---
FLineBatcher::FLineBatcher(FLineBatcher const &Other)
{
	// Ghidra 0x27320: vtable set by compiler; TArray<FLineVertex> at +4 (stride 0x10); 5 DWORDs at +10..+20
	new ((BYTE*)this + 0x04) TArray<FLineVertex>(*(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x14); // 5 DWORDs
}

FLineBatcher::FLineBatcher(FRenderInterface *,int,int)
{
	// Initialize TArray<FLineVertex> at +4 to empty so dtor is safe
	new ((BYTE*)this + 0x04) TArray<FLineVertex>();
	appMemzero((BYTE*)this + 0x10, 0x14); // zero state DWORDs
}

FLineBatcher::~FLineBatcher()
{
	// Ghidra 0x418050: reset vtable, call Flush(false), destroy TArray<FLineVertex> at +4
	// Flush() is a stub; we just destroy the TArray
	((TArray<FLineVertex>*)((BYTE*)this + 0x04))->~TArray();
}

FLineBatcher& FLineBatcher::operator=(const FLineBatcher& Other)
{
	// Ghidra 0x27360: skip vtable at +0, TArray<FLineVertex> at +4 (FUN_1031e1c0=16-byte),
	// then 5 DWORDs at +0x10..+0x20
	*(TArray<FLineVertex>*)((BYTE*)this + 0x04) = *(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x14); // 5 DWORDs
	return *this;
}

void FLineBatcher::DrawConvexVolume(FConvexVolume,FColor)
{
}

// (merged from earlier occurrence)
void FLineBatcher::DrawBox(FBox,FColor)
{
}
void FLineBatcher::DrawCircle(FVector,FVector,FVector,FColor,float,int)
{
}
void FLineBatcher::DrawCylinder(FRenderInterface *,FVector,FVector,FVector,FVector,FColor,float,float,int)
{
}
void FLineBatcher::DrawDirectionalArrow(FVector,FRotator,FColor,float)
{
}
void FLineBatcher::DrawLine(FVector,FVector,FColor)
{
}
void FLineBatcher::DrawPoint(FSceneNode *,FVector,FColor)
{
}
void FLineBatcher::DrawSphere(FVector,FColor,float,int)
{
}
void FLineBatcher::Flush(DWORD)
{
}
unsigned __int64 FLineBatcher::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}
int FLineBatcher::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 4; C[1].Function = 2;
	return 2;
}
void FLineBatcher::GetRawStreamData(void ** Out, int Offset)
{
	// Ghidra: *Out = data + offset * 0x10
	*Out = *(BYTE**)Pad + Offset * 0x10;
}
int FLineBatcher::GetRevision()
{
	return 1;
}
int FLineBatcher::GetSize()
{
	// Ghidra: FArray::Num(this+4) << 4, TArray at Pad[0]
	return *(INT*)(Pad + 4) << 4;
}
void FLineBatcher::GetStreamData(void * Dest)
{
	// Ghidra: memcpy Num<<4 bytes from TArray data
	INT Size = *(INT*)(Pad + 4) << 4;
	appMemcpy(Dest, *(void**)Pad, Size);
}
int FLineBatcher::GetStride()
{
	return 0x10;
}


// --- FRaw32BitIndexBuffer ---
FRaw32BitIndexBuffer::FRaw32BitIndexBuffer(FRaw32BitIndexBuffer const &Other)
{
	// Ghidra 0x209a0: vtable set by compiler; TArray<FLOAT> at +4 (stride 4); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

FRaw32BitIndexBuffer::FRaw32BitIndexBuffer()
{
	// Initialize TArray<FLOAT> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FLOAT>();
}

FRaw32BitIndexBuffer::~FRaw32BitIndexBuffer()
{
	// Ghidra 0x1032c020: shared with ~FRawColorStream; destroy TArray<FLOAT>(4-byte elements) at +4
	((TArray<FLOAT>*)((BYTE*)this + 0x04))->~TArray();
}

FRaw32BitIndexBuffer& FRaw32BitIndexBuffer::operator=(const FRaw32BitIndexBuffer& Other)
{
	// Ghidra 0x275b0: skip vtable +0; +4=TArray<FLOAT> (FUN_1031f660); +0x10,+0x14,+0x18=3 DWORDs
	// Shares address with FRawColorStream and FStaticMeshColorStream.
	*(TArray<FLOAT>*)((BYTE*)this + 0x04) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
unsigned __int64 FRaw32BitIndexBuffer::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}
void FRaw32BitIndexBuffer::GetContents(void * Dest)
{
	// Ghidra: memcpy Num()<<2 bytes
	INT Size = *(INT*)(Pad + 4) << 2;
	appMemcpy(Dest, *(void**)Pad, Size);
}
int FRaw32BitIndexBuffer::GetIndexSize()
{
	return 4;
}
int FRaw32BitIndexBuffer::GetRevision()
{
	return *(INT*)(Pad + 20);
}
int FRaw32BitIndexBuffer::GetSize()
{
	// Ghidra: Num << 2
	return *(INT*)(Pad + 4) << 2;
}


// --- FRawColorStream ---
FRawColorStream::FRawColorStream(FRawColorStream const &Other)
{
	// Ghidra 0x27570: vtable set by compiler; TArray<FLOAT> at +4 (stride 4); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

FRawColorStream::FRawColorStream()
{
	// Initialize TArray<FLOAT> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FLOAT>();
}

FRawColorStream::~FRawColorStream()
{
	// Ghidra 0x1032c020: shared with ~FRaw32BitIndexBuffer; destroy TArray<FLOAT>(4-byte elements) at +4
	((TArray<FLOAT>*)((BYTE*)this + 0x04))->~TArray();
}

FRawColorStream& FRawColorStream::operator=(const FRawColorStream& Other)
{
	// Ghidra 0x275b0: same body as FRaw32BitIndexBuffer::operator=
	*(TArray<FLOAT>*)((BYTE*)this + 0x04) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
unsigned __int64 FRawColorStream::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}
int FRawColorStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 4; C[0].Function = 2;
	return 1;
}
void FRawColorStream::GetRawStreamData(void ** Out, int Offset)
{
	// Ghidra: *Out = data + offset * 4
	*Out = *(BYTE**)Pad + Offset * 4;
}
int FRawColorStream::GetRevision()
{
	return *(INT*)(Pad + 20);
}
int FRawColorStream::GetSize()
{
	// Ghidra: Num << 2
	return *(INT*)(Pad + 4) << 2;
}
void FRawColorStream::GetStreamData(void * Dest)
{
	// Ghidra: memcpy Num()<<2 bytes
	INT Size = *(INT*)(Pad + 4) << 2;
	appMemcpy(Dest, *(void**)Pad, Size);
}
int FRawColorStream::GetStride()
{
	return 4;
}


// --- FRawIndexBuffer ---
int FRawIndexBuffer::Stripify()
{
	return 0;
}

FRawIndexBuffer::FRawIndexBuffer(FRawIndexBuffer const &Other)
{
	// Ghidra 0x18d80: vtable set by compiler; TArray<_WORD> at +4 (stride 2); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<_WORD>(*(const TArray<_WORD>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

FRawIndexBuffer::FRawIndexBuffer()
{
	// Initialize TArray<_WORD> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<_WORD>();
}

FRawIndexBuffer::~FRawIndexBuffer()
{
	// destroy TArray<_WORD> at +4
	((TArray<_WORD>*)((BYTE*)this + 0x04))->~TArray();
}

FRawIndexBuffer& FRawIndexBuffer::operator=(const FRawIndexBuffer& Other)
{
	// Ghidra 0x18dc0: skip vtable +0; +4=TArray<_WORD>; +0x10,+0x14,+0x18=3 DWORDs
	*(TArray<_WORD>*)((BYTE*)this + 0x04) = *(const TArray<_WORD>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C);
	return *this;
}

// (merged from earlier occurrence)
void FRawIndexBuffer::CacheOptimize()
{
}
unsigned __int64 FRawIndexBuffer::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}
void FRawIndexBuffer::GetContents(void* Dest)
{
	// Retail: 0x1141c0. TArray<WORD> at this+4 (= Pad+0). Copy Num*2 bytes.
	void*  data = *(void**)Pad;
	INT    num  = *(INT*)(Pad + 4);
	appMemcpy(Dest, data, num * 2);
}
int FRawIndexBuffer::GetIndexSize()
{
	return 2;
}
int FRawIndexBuffer::GetRevision()
{
	return *(INT*)(Pad + 20);
}
int FRawIndexBuffer::GetSize()
{
	// Retail (12b): ADD ECX,4; call Num(); SHL EAX,1 = return Data.Num() * 2
	// TArray<_WORD> at object+4; ArrayNum at +4 within TArray = Pad+4
	return *(INT*)(Pad + 4) << 1;
}


// --- FSkinVertexStream ---
FSkinVertexStream::FSkinVertexStream(FSkinVertexStream const &Other)
{
	// Ghidra 0x2b7d0: vtable set by compiler; 7 DWORDs at +4..+1c; TArray<FStreamVert32> at +20 (stride 0x20)
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x1C); // 7 DWORDs
	new ((BYTE*)this + 0x20) TArray<FStreamVert32>(*(const TArray<FStreamVert32>*)((const BYTE*)&Other + 0x20));
}

FSkinVertexStream::FSkinVertexStream()
{
	// Initialize TArray<FStreamVert32> at +0x20 to empty
	new ((BYTE*)this + 0x20) TArray<FStreamVert32>();
}

FSkinVertexStream::~FSkinVertexStream()
{
	// destroy TArray<FStreamVert32> at +0x20 (stride 0x20, POD elements)
	((TArray<FStreamVert32>*)((BYTE*)this + 0x20))->~TArray();
}

FSkinVertexStream& FSkinVertexStream::operator=(const FSkinVertexStream& Other)
{
	// Ghidra 0x2b820: skip vtable at +0, 7 DWORDs at +4..+1C,
	// TArray<FStreamVert32> at +20 (FUN_1031f7d0 = 32-byte GPU verts)
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x1C); // 7 DWORDs
	*(TArray<FStreamVert32>*)((BYTE*)this + 0x20) = *(const TArray<FStreamVert32>*)((const BYTE*)&Other + 0x20);
	return *this;
}

// (merged from earlier occurrence)
unsigned __int64 FSkinVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 8);
}
int FSkinVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}
void FSkinVertexStream::GetRawStreamData(void ** ppData, int FirstVertex)
{
	// Retail: 20b. GPU-only skin stream; no CPU-accessible raw pointer.
	// If stream data ptr at this+0x1C is non-null: set *ppData = NULL (GPU ptr, unreadable).
	// If null: cross-function-jump (stream not allocated).
	if (*(DWORD*)(Pad + 0x18))
		*ppData = NULL;
}
int FSkinVertexStream::GetRevision()
{
	return *(INT*)(Pad + 16);
}
int FSkinVertexStream::GetSize()
{
	// Retail (22b): guard on Pad+0x18 ([this+0x1C]) = skin verts pointer.
	// If null, no data allocated → return 0.
	// Otherwise: load parent object from Pad+4 ([this+8]), call vtable slot 78
	// (offset 0x138) to get vertex count, multiply by stride 32 (SHL 5).
	if (!*(DWORD*)(Pad + 0x18)) return 0;
	void* obj = *(void**)(Pad + 4);
	typedef INT (__thiscall* FnType)(void*);
	FnType fn = (FnType)(*(void***)obj)[0x138 / sizeof(void*)];
	return fn(obj) << 5; // vertex_count * 32
}
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
int FSkinVertexStream::GetStride()
{
	return 0x20;
}


// --- FStaticLightMapTexture ---
FStaticLightMapTexture::FStaticLightMapTexture(FStaticLightMapTexture const &)
{
}

FStaticLightMapTexture::FStaticLightMapTexture()
{
}

FStaticLightMapTexture::~FStaticLightMapTexture()
{
}

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
unsigned __int64 FStaticLightMapTexture::GetCacheId()
{
	return *(QWORD*)(Pad + 60);
}
int FStaticLightMapTexture::GetFirstMip()
{
	// Ghidra (25B): if UTexture::__Client and __Client+0x70 flag is set, return 1
	if (UTexture::__Client != NULL && *(INT*)((BYTE*)UTexture::__Client + 0x70) != 0)
		return 1;
	return 0;
}
ETextureFormat FStaticLightMapTexture::GetFormat()
{
	return (ETextureFormat)Pad[48];
}
int FStaticLightMapTexture::GetHeight()
{
	return *(INT*)(Pad + 56);
}
int FStaticLightMapTexture::GetNumMips()
{
	return 2;
}
void * FStaticLightMapTexture::GetRawTextureData(int)
{
	return NULL;
}
int FStaticLightMapTexture::GetRevision()
{
	return *(INT*)(Pad + 68);
}
void FStaticLightMapTexture::GetTextureData(int,void *,int,ETextureFormat,int)
{
}
ETexClampMode FStaticLightMapTexture::GetUClamp()
{
	return TC_Wrap;
}
UTexture * FStaticLightMapTexture::GetUTexture()
{
	return NULL;
}
ETexClampMode FStaticLightMapTexture::GetVClamp()
{
	return TC_Wrap;
}
int FStaticLightMapTexture::GetWidth()
{
	return *(INT*)(Pad + 52);
}
unsigned __int64 FStaticMeshUVStream::GetCacheId()
{
	return *(QWORD*)(Pad + 16);
}
int FStaticMeshUVStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 2; C[0].Function = *(INT*)(Pad + 0x0C) + 4;
	return 1;
}
void FStaticMeshUVStream::GetRawStreamData(void ** Out, int Offset)
{
	// Ghidra: *Out = data + offset * 8
	*Out = *(BYTE**)Pad + Offset * 8;
}
int FStaticMeshUVStream::GetRevision()
{
	return *(INT*)(Pad + 24);
}
int FStaticMeshUVStream::GetSize()
{
	// Ghidra: Num << 3 (stride = 8)
	return *(INT*)(Pad + 4) << 3;
}
void FStaticMeshUVStream::GetStreamData(void * Dest)
{
	// Ghidra: memcpy Num<<3 bytes from TArray data
	INT Size = *(INT*)(Pad + 4) << 3;
	appMemcpy(Dest, *(void**)Pad, Size);
}
int FStaticMeshUVStream::GetStride()
{
	return 8;
}
unsigned __int64 FStaticMeshVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}
int FStaticMeshVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	return 2;
}
void FStaticMeshVertexStream::GetRawStreamData(void ** ppData, int FirstVertex)
{
	// Retail: data = [this+4] (TArray.Data); stride = 24 (3*8); Pad[0] = this+4
	*ppData = *(BYTE**)(Pad + 0) + FirstVertex * 0x18;
}
int FStaticMeshVertexStream::GetRevision()
{
	return *(INT*)(Pad + 20);
}
int FStaticMeshVertexStream::GetSize()
{
	// Ghidra (16B): FArray::Num(this+4) * 0x18; Pad[0] = FArray at offset 4
	INT Num = *(INT*)(Pad + 4); // ArrayNum field of FArray at this+4
	return Num * 0x18;
}
void FStaticMeshVertexStream::GetStreamData(void* Dest)
{
	// Retail: 0x1c970. TArray of 24-byte verts at this+4 (= Pad+0). Copy Num*24 bytes.
	void*  data = *(void**)Pad;
	INT    num  = *(INT*)(Pad + 4);
	appMemcpy(Dest, data, num * 0x18);
}
int FStaticMeshVertexStream::GetStride()
{
	return 0x18;
}


// --- FStaticTexture ---
FStaticTexture::FStaticTexture(FStaticTexture const &Other)
{
	// Ghidra 0x20b50: vtable set by compiler; scalar copy of 4 DWORDs at +4..+10. Shares address with FStaticCubemap.
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
}

FStaticTexture::FStaticTexture(UTexture *)
{
}

FStaticTexture& FStaticTexture::operator=(const FStaticTexture& Other)
{
	// Ghidra 0x18ee0: skip vtable at +0, copy 4 DWORDs at +4..+10.
	// Shares address with FStaticCubemap.
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
	return *this;
}

// (merged from earlier occurrence)
unsigned __int64 FStaticTexture::GetCacheId()
{
	// Ghidra: return *(__uint64*)(this + 4); CacheId at Pad[0..7]
	return *(QWORD*)&Pad[0];
}
int FStaticTexture::GetFirstMip()
{
	// Ghidra: UTexture::DefaultLOD(Texture)
	UTexture* Texture = *(UTexture**)&Pad[8];
	return Texture->DefaultLOD();
}
ETextureFormat FStaticTexture::GetFormat()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return (ETextureFormat)Texture->Format;
}
int FStaticTexture::GetHeight()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return Texture->VSize;
}
int FStaticTexture::GetNumMips()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return Texture->Mips.Num();
}
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
void FStaticTexture::GetTextureData(int,void *,int,ETextureFormat,int)
{
}
ETexClampMode FStaticTexture::GetUClamp()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return (ETexClampMode)Texture->UClampMode;
}
UTexture * FStaticTexture::GetUTexture()
{
	return *(UTexture**)&Pad[8];
}
ETexClampMode FStaticTexture::GetVClamp()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return (ETexClampMode)Texture->VClampMode;
}
int FStaticTexture::GetWidth()
{
	UTexture* Texture = *(UTexture**)&Pad[8];
	return Texture->USize;
}


// --- FBspSection ---
FBspSection::FBspSection(FBspSection const &Other)
{
	// Ghidra 0x27b60: vtable set by compiler; TArray<FBspVertex> at +4 (stride 0x28); 7 DWORDs at +10..+28
	new ((BYTE*)this + 0x04) TArray<FBspVertex>(*(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x1C); // 7 DWORDs
}

FBspSection::FBspSection()
{
	// Initialize TArray<FBspVertex> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FBspVertex>();
}

FBspSection::~FBspSection()
{
	// Ghidra 0x103278e0: shared with ~FBspVertexStream; destroy TArray<FBspVertex> at +4
	((TArray<FBspVertex>*)((BYTE*)this + 0x04))->~TArray();
}

FBspSection& FBspSection::operator=(const FBspSection& Other)
{
	// Ghidra 0x27bb0: skip vtable at +0, TArray<FBspVertex> at +4 (FUN_10324ae0=40-byte elems),
	// then 7 DWORDs at +0x10..+0x28
	*(TArray<FBspVertex>*)((BYTE*)this + 0x04) = *(const TArray<FBspVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x1C); // 7 DWORDs
	return *this;
}


// --- FBspVertex ---
FBspVertex::FBspVertex()
{
	// Ghidra: constructs two FVectors at offset 0 and 0xC (Position + Normal)
	*(FVector*)&_Data[0] = FVector(0,0,0);
	*(FVector*)&_Data[12] = FVector(0,0,0);
}

FBspVertex& FBspVertex::operator=(const FBspVertex& Other)
{
	appMemcpy( this, &Other, sizeof(FBspVertex) );
	return *this;
}


// --- FConvexVolume ---
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

FConvexVolume::FConvexVolume(const FConvexVolume& Other)
{
	// Ghidra 0x3750: 32 FPlane copy ctors (FPlane is POD) + 24 DWORDs = 0x260 bytes total
	appMemcpy(this, &Other, 0x260);
}

FConvexVolume::FConvexVolume()
{
}

FConvexVolume::~FConvexVolume()
{
}

FConvexVolume& FConvexVolume::operator=(const FConvexVolume& Other)
{
	// Ghidra 0x37f0: 0x98 DWORDs from offset 0 (no vtable)
	appMemcpy(this, &Other, 0x260);
	return *this;
}

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

FPoly FConvexVolume::ClipPolygon(FPoly)
{
	return FPoly();
}

FPoly FConvexVolume::ClipPolygonPrecise(FPoly)
{
	return FPoly();
}


// --- FDynamicActor ---
void FDynamicActor::Render(FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

FDynamicActor::FDynamicActor(const FDynamicActor& Other)
{
	// Ghidra 0x135d0: no vtable; flat copy of 0x80 bytes (same as operator= at 0x13660)
	appMemcpy(this, &Other, 0x80);
}

FDynamicActor::FDynamicActor(AActor *)
{
}

FDynamicActor::~FDynamicActor()
{
}

FDynamicActor& FDynamicActor::operator=(const FDynamicActor& Other)
{
	// Ghidra 0x13660: 0x20 DWORDs from offset 0 (FDynamicActor has no vtable)
	appMemcpy(this, &Other, 0x80);
	return *this;
}


// --- FDynamicLight ---
float FDynamicLight::SampleIntensity(FVector,FVector)
{
	return 0.0f;
}

FColor FDynamicLight::SampleLight(FVector,FVector)
{
	return FColor(0,0,0,0);
}

FDynamicLight::FDynamicLight(FDynamicLight const& Other)
{
	appMemcpy( this, &Other, sizeof(FDynamicLight) );
}

FDynamicLight::FDynamicLight(AActor *)
{
}

FDynamicLight& FDynamicLight::operator=(const FDynamicLight& Other)
{
	appMemcpy( this, &Other, sizeof(FDynamicLight) );
	return *this;
}


// --- FLightMapIndex ---
FLightMapIndex::FLightMapIndex()
{
}

FLightMapIndex::~FLightMapIndex()
{
}

FLightMapIndex& FLightMapIndex::operator=(const FLightMapIndex& Other)
{
	// Ghidra 0x2c10: 0x30 DWORDs from offset 0 (no vtable)
	appMemcpy(this, &Other, 0xC0);
	return *this;
}


// --- FLineVertex ---
FLineVertex::FLineVertex(FVector InPoint, FColor InColor)
:	Point(InPoint)
,	Color(InColor)
{
}

FLineVertex::FLineVertex()
{
}

FLineVertex& FLineVertex::operator=(const FLineVertex& Other)
{
	Point = Other.Point;
	Color = Other.Color;
	return *this;
}


// --- FStaticCubemap ---
FStaticCubemap::FStaticCubemap(FStaticCubemap const &Other)
{
	// Ghidra 0x18eb0: vtable set by compiler; scalar copy of 4 DWORDs at +4..+10
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
}

FStaticCubemap::FStaticCubemap(UCubemap *)
{
}

FStaticCubemap& FStaticCubemap::operator=(const FStaticCubemap& Other)
{
	// Ghidra 0x18ee0: skip vtable at +0, copy 4 DWORDs at +4..+10.
	// Shares address with FStaticTexture.
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x10);
	return *this;
}

unsigned __int64 FStaticCubemap::GetCacheId()
{
	// Ghidra: return QWORD at this+8 = Pad+4
	return *(QWORD*)(Pad + 4);
}

FTexture * FStaticCubemap::GetFace(int)
{
	return NULL;
}

int FStaticCubemap::GetFirstMip()
{
	// UCubemap* at Pad[0] (this+4); cubemap inherits from UTexture.
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->DefaultLOD() : 0;
}

ETextureFormat FStaticCubemap::GetFormat()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? (ETextureFormat)tex->Format : TEXF_P8;
}

int FStaticCubemap::GetHeight()
{
	// Cubemap face height — UCubemap inherits VSize from UTexture.
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->VSize : 0;
}

int FStaticCubemap::GetNumMips()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->Mips.Num() : 0;
}

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

ETexClampMode FStaticCubemap::GetUClamp()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? (ETexClampMode)tex->UClampMode : TC_Wrap;
}

ETexClampMode FStaticCubemap::GetVClamp()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? (ETexClampMode)tex->VClampMode : TC_Wrap;
}

int FStaticCubemap::GetWidth()
{
	UTexture* tex = (UTexture*)(*(UCubemap**)&Pad[0]);
	return tex ? tex->USize : 0;
}


// --- FTempLineBatcher ---
void FTempLineBatcher::Render(FRenderInterface *,int)
{
}

FTempLineBatcher::FTempLineBatcher(FTempLineBatcher const &Other)
{
	// Ghidra 0x27490: no vtable; TArray<FVector>@+0, TArray<FVector>@+0xC, TArray<FLOAT>@+0x18, TArray<FBox>@+0x24, TArray<FLOAT>@+0x30
	new ((BYTE*)this + 0x00) TArray<FVector>(*(const TArray<FVector>*)((const BYTE*)&Other + 0x00));
	new ((BYTE*)this + 0x0C) TArray<FVector>(*(const TArray<FVector>*)((const BYTE*)&Other + 0x0C));
	new ((BYTE*)this + 0x18) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x18));
	new ((BYTE*)this + 0x24) TArray<FBox>(*(const TArray<FBox>*)((const BYTE*)&Other + 0x24));
	new ((BYTE*)this + 0x30) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x30));
}

FTempLineBatcher::FTempLineBatcher()
{
	// Initialize all 5 TArrays to empty
	new ((BYTE*)this + 0x00) TArray<FVector>();
	new ((BYTE*)this + 0x0C) TArray<FVector>();
	new ((BYTE*)this + 0x18) TArray<FLOAT>();
	new ((BYTE*)this + 0x24) TArray<FBox>();
	new ((BYTE*)this + 0x30) TArray<FLOAT>();
}

FTempLineBatcher::~FTempLineBatcher()
{
	// Destroy 5 TArrays in reverse order
	((TArray<FLOAT>*)((BYTE*)this + 0x30))->~TArray();
	((TArray<FBox>*)((BYTE*)this + 0x24))->~TArray();
	((TArray<FLOAT>*)((BYTE*)this + 0x18))->~TArray();
	((TArray<FVector>*)((BYTE*)this + 0x0C))->~TArray();
	((TArray<FVector>*)((BYTE*)this + 0x00))->~TArray();
}

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

void FTempLineBatcher::AddBox(FBox,FColor)
{
}

void FTempLineBatcher::AddLine(FVector,FVector,FColor)
{
}


// --- UConvexVolume ---
void UConvexVolume::Serialize(FArchive &)
{
}

FBox UConvexVolume::GetRenderBoundingBox(AActor const *)
{
	// Retail: 23b. REP MOVSD 7 DWORDs (28b = FBox) from this+0x70 to return buffer.
	return *(FBox*)((BYTE*)this + 0x70);
}

int UConvexVolume::IsPointInside(FVector,FMatrix)
{
	return 0;
}


// --- UIndexBuffer ---
void UIndexBuffer::Serialize(FArchive& Ar)
{
	// Ghidra 0x110d90: URenderResource::Serialize + index data TArray at +0x30.
	// Divergence: TArray<WORD> at +0x30 not serialized (render data reconstructed at load).
	URenderResource::Serialize(Ar);
}


// --- USkinVertexBuffer ---
void USkinVertexBuffer::Serialize(FArchive& Ar)
{
	// Ghidra 0x110f50: URenderResource::Serialize + skin vertex TArray at +0x30.
	// Divergence: skin vertex TArray at +0x30 not serialized (render data reconstructed at load).
	URenderResource::Serialize(Ar);
}

