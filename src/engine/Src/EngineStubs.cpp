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

// Raw 32-byte vertex element for FSkinVertexStream / FAnimMeshVertexStream.
// Both streams use TArray<FStreamVert32> where element size = 32 bytes
// (confirmed by GetStreamData: FArray::Num * 32 bytes).
struct FStreamVert32 { BYTE d[32]; };

// 52-byte element type for TArray in FLightMap (Ghidra FUN_1033aac0).
// Confirmed by FUN_1031eda0 copy constructor: DWORD + TArray<BYTE> + 9 DWORDs.
struct FLightMapSample52 {
	DWORD        d0;
	TArray<BYTE> bytes;
	DWORD        d4, d5, d6, d7, d8, d9, d10, d11, d12;
};

// --- ACamera ---
void ACamera::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void ACamera::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

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

// --- ATerrainInfo ---
void ATerrainInfo::SoftSelect(float,float)
{
}

void ATerrainInfo::Update(float,int,int,int,int,int)
{
}

void ATerrainInfo::UpdateDecorations(int)
{
}

void ATerrainInfo::UpdateTriangles(int,int,int,int,int)
{
}

void ATerrainInfo::UpdateVertices(float,int,int,int,int)
{
}

FVector ATerrainInfo::WorldToHeightmap(FVector In)
{
	// Retail: 29b. ECX=this+0x1330 (heightmap FCoords), call FVector::TransformPointBy.
	return In.TransformPointBy(*(FCoords*)((BYTE*)this + 0x1330));
}

void ATerrainInfo::Render(FLevelSceneNode *,FRenderInterface *,FVisibilityInterface *)
{
}

void ATerrainInfo::RenderDecorations(FLevelSceneNode *,FRenderInterface *,FVisibilityInterface *)
{
}

int ATerrainInfo::SelectVertex(FVector)
{
	return 0;
}

int ATerrainInfo::SelectVertexX(int,int)
{
	return 0;
}

void ATerrainInfo::SelectVerticesInBox(FBox &)
{
}

void ATerrainInfo::SetEdgeTurnBitmap(int X, int Y, int Value)
{
	// Retail: packed-bit write into EdgeTurnBitmap.Data (Data* at this+0x137C).
	// idx = HeightmapX (this+0x12E0) * Y + X.
	INT HeightmapX_val = *(INT*)((BYTE*)this + 0x12E0);
	INT idx = HeightmapX_val * Y + X;
	INT bit_mask = 1 << (idx & 31);
	INT* data = *(INT**)((BYTE*)this + 0x137C);
	if (!data) return;
	if (Value) data[idx >> 5] |=  bit_mask;
	else       data[idx >> 5] &= ~bit_mask;
}

void ATerrainInfo::SetHeightmap(int X, int Y, _WORD Value)
{
	// Retail: 45b. Writes 16-bit height value at USize*Y+X in the G16 heightmap.
	// Checks format at terrain texture+0x58 must be 10 (G16). First mip data
	// pointer is at Mips.Data[0x1C]. Stored as WORD array.
	UTexture* HeightTex = *(UTexture**)((BYTE*)this + 0x398);
	if (*(BYTE*)((BYTE*)HeightTex + 0x58) != 10) return; // must be G16/format-10
	INT idx = *(INT*)((BYTE*)HeightTex + 0x60) * Y + X;  // USize * Y + X
	BYTE* mipsData = *(BYTE**)((BYTE*)HeightTex + 0xBC); // Mips.Data ptr (first field of TArray)
	WORD* heightData = (WORD*)*(BYTE**)(mipsData + 0x1C); // FMipmapBase[0].DataPtr
	heightData[idx] = Value;
}

void ATerrainInfo::SetLayerAlpha(float,float,int,BYTE,UTexture *)
{
}

void ATerrainInfo::SetPlanningFloorMap(int X, int Y, int Value)
{
	// Retail: writes biased 4-bit nibble (Value+8) into packed INT array at
	// this+0x13C8. 8 nibbles per INT, nibble_pos = (X&7)*4 bits.
	// Inverse of GetPlanningFloorMap (adds bias 8 back, stores in 4-bit nibble).
	UTexture* HeightTex = *(UTexture**)((BYTE*)this + 0x398);
	INT USize = *(INT*)((BYTE*)HeightTex + 0x60);
	INT idx = USize * Y + X;
	INT* planData = *(INT**)((BYTE*)this + 0x13C8);
	INT bit_pos = (X & 7) << 2;
	INT mask = 0x0F << bit_pos;
	INT* word_ptr = &planData[idx >> 3];
	*word_ptr = (*word_ptr & ~mask) | (((Value + 8) & 0x0F) << bit_pos);
	// TODO: flag at this+0x12B4 also ORed in retail (terrain-dirty marking).
}

void ATerrainInfo::SetQuadVisibilityBitmap(int X, int Y, int Value)
{
	// Same as SetEdgeTurnBitmap but for QuadVisibilityBitmap.Data (Data* at this+0x1370).
	INT HeightmapX_val = *(INT*)((BYTE*)this + 0x12E0);
	INT idx = HeightmapX_val * Y + X;
	INT bit_mask = 1 << (idx & 31);
	INT* data = *(INT**)((BYTE*)this + 0x1370);
	if (!data) return;
	if (Value) data[idx >> 5] |=  bit_mask;
	else       data[idx >> 5] &= ~bit_mask;
}

void ATerrainInfo::SetTextureColor(int,int,UTexture *,FColor &)
{
}

int ATerrainInfo::LineCheck(FCheckResult &,FVector,FVector,FVector,int)
{
	return 0;
}

int ATerrainInfo::LineCheckWithQuad(int,int,FCheckResult &,FVector,FVector,FVector,int)
{
	return 0;
}

void ATerrainInfo::MoveVertices(float)
{
}

int ATerrainInfo::PointCheck(FCheckResult &,FVector,FVector,int)
{
	return 0;
}

void ATerrainInfo::CalcCoords()
{
}

void ATerrainInfo::CalcLayerTexCoords()
{
}

void ATerrainInfo::CheckComputeDataOnLoad()
{
}

void ATerrainInfo::CombineLayerWeights()
{
}

void ATerrainInfo::ConvertHeightmapFormat()
{
}

int ATerrainInfo::GetClosestVertex(FVector &,FVector *,int *,int *)
{
	return 0;
}

int ATerrainInfo::GetEdgeTurnBitmap(int X, int Y)
{
	// Retail: return single bit from EdgeTurnBitmap (Data* at this+0x137C).
	// idx = HeightmapX * Y + X; return bit (idx&31) of Data[idx>>5].
	INT HeightmapX_val = *(INT*)((BYTE*)this + 0x12E0);
	INT idx = HeightmapX_val * Y + X;
	INT* data = *(INT**)((BYTE*)this + 0x137C);
	if (!data) return 0;
	INT word = data[idx >> 5];
	INT bit_mask = 1 << (idx & 31);
	return (word & bit_mask) ? 1 : 0;
}

int ATerrainInfo::GetGlobalVertex(int X, int Y)
{
	// Retail: 8B 81 E0 12 00 00 0F AF 44 24 08 03 44 24 04 C2 08 00
	// return HeightmapX (at this+0x12E0) * Y + X.
	INT HeightmapX_val = *(INT*)((BYTE*)this + 0x12E0);
	return HeightmapX_val * Y + X;
}

_WORD ATerrainInfo::GetHeightmap(int X, int Y)
{
	// Retail: 23b format-check wrapper + tail-call to 34b impl.
	// If format is not 10 (G16), returns 0. Otherwise reads WORD at USize*Y+X
	// from the first mip data of the terrain heightmap texture at this+0x398.
	UTexture* HeightTex = *(UTexture**)((BYTE*)this + 0x398);
	if (*(BYTE*)((BYTE*)HeightTex + 0x58) != 10) return 0; // not G16: return 0
	INT idx = *(INT*)((BYTE*)HeightTex + 0x60) * Y + X;    // USize * Y + X
	BYTE* mipsData = *(BYTE**)((BYTE*)HeightTex + 0xBC);
	WORD* heightData = (WORD*)*(BYTE**)(mipsData + 0x1C);
	return heightData[idx];
}

BYTE ATerrainInfo::GetLayerAlpha(int,int,int,UTexture *)
{
	return 0;
}

int ATerrainInfo::GetPlanningFloorMap(int X, int Y)
{
	// Retail: 57b. Planning floor map stored as packed 4-bit nibbles in INT array
	// at this+0x13C8. 8 nibbles per INT (DWORD), bias of -8 on read (stored + 8).
	// Index = USize*Y+X; DWORD_idx = idx>>3; nibble_pos = (X&7)*4.
	UTexture* HeightTex = *(UTexture**)((BYTE*)this + 0x398);
	INT USize = *(INT*)((BYTE*)HeightTex + 0x60);
	INT idx = USize * Y + X;
	INT* planData = *(INT**)((BYTE*)this + 0x13C8);
	INT bit_pos = (X & 7) << 2;  // nibble position within DWORD
	INT nibble = (planData[idx >> 3] >> bit_pos) & 0x0F;
	return nibble - 8;            // unbias: stored range 0..15, returned -8..7
}

int ATerrainInfo::GetQuadVisibilityBitmap(int X, int Y)
{
	// Same pattern as GetEdgeTurnBitmap but reads QuadVisibilityBitmap (Data* at this+0x1370).
	INT HeightmapX_val = *(INT*)((BYTE*)this + 0x12E0);
	INT idx = HeightmapX_val * Y + X;
	INT* data = *(INT**)((BYTE*)this + 0x1370);
	if (!data) return 0;
	INT word = data[idx >> 5];
	INT bit_mask = 1 << (idx & 31);
	return (word & bit_mask) ? 1 : 0;
}

int ATerrainInfo::GetRenderCombinationNum(TArray<int> &,ETerrainRenderMethod)
{
	return 0;
}

FBox ATerrainInfo::GetSelectedVerticesBounds()
{
	return FBox();
}

FColor ATerrainInfo::GetTextureColor(int,int,UTexture *)
{
	return FColor(0,0,0,0);
}

FVector ATerrainInfo::GetVertexNormal(int,int)
{
	return FVector(0,0,0);
}

FVector ATerrainInfo::HeightmapToWorld(FVector In)
{
	// Retail: 29b. ECX=this+0x1300 (world FCoords), call FVector::TransformPointBy.
	return In.TransformPointBy(*(FCoords*)((BYTE*)this + 0x1300));
}

void ATerrainInfo::Serialize(FArchive &)
{
}

void ATerrainInfo::CheckForErrors()
{
}

void ATerrainInfo::Destroy()
{
}

UPrimitive * ATerrainInfo::GetPrimitive()
{
	return NULL;
}

// --- FAnimMeshVertexStream ---
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

// --- FCanvasUtil ---
void FCanvasUtil::BeginPrimitive(EPrimitiveType,UMaterial *)
{
}

void FCanvasUtil::DrawLine(float,float,float,float,FColor)
{
}

void FCanvasUtil::DrawPoint(float,float,float,float,float,FColor)
{
}

void FCanvasUtil::DrawTile(float,float,float,float,float,float,float,float,float,UMaterial *,FColor)
{
}

void FCanvasUtil::DrawTileRotated(float,float,float,float,float,float,float,float,float,UMaterial *,FColor,float)
{
}

void FCanvasUtil::Flush()
{
}

unsigned __int64 FCanvasUtil::GetCacheId()
{
	// Ghidra: CacheId QWORD at this+0xc9c = Pad+0xc98
	return *(QWORD*)(Pad + 0xc98);
}

int FCanvasUtil::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 4; C[1].Function = 2;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}

void FCanvasUtil::GetRawStreamData(void * *,int)
{
}

int FCanvasUtil::GetRevision()
{
	return 1;
}

int FCanvasUtil::GetSize()
{
	// Ghidra: count at this+0x98 = Pad+0x94, times stride 0x18
	return *(INT*)(Pad + 0x94) * 0x18;
}

void FCanvasUtil::GetStreamData(void * Dest)
{
	// Ghidra: memcpy from inline vertex buffer at this+0x9c = Pad+0x98
	INT Size = *(INT*)(Pad + 0x94) * 0x18;
	appMemcpy(Dest, Pad + 0x98, Size);
}

int FCanvasUtil::GetStride()
{
	return 0x18;
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
void FRawIndexBuffer::CacheOptimize()
{
}

unsigned __int64 FRawIndexBuffer::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}

void FRawIndexBuffer::GetContents(void *)
{
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
	return 0;
}

// --- FSkinVertexStream ---
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
	return 0;
}

void FSkinVertexStream::GetStreamData(void *)
{
}

int FSkinVertexStream::GetStride()
{
	return 0x20;
}

// --- FStaticLightMapTexture ---
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

void FStaticMeshVertexStream::GetStreamData(void *)
{
}

int FStaticMeshVertexStream::GetStride()
{
	return 0x18;
}

// --- FStaticTexture ---
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

// --- UBinaryFileDownload ---
void UBinaryFileDownload::ReceiveData(BYTE*,int)
{
}

void UBinaryFileDownload::ReceiveFile(UNetConnection *,int,const TCHAR*,int)
{
}

void UBinaryFileDownload::Serialize(FArchive &)
{
}

void UBinaryFileDownload::Destroy()
{
}

void UBinaryFileDownload::DownloadDone()
{
}

void UBinaryFileDownload::DownloadError(const TCHAR*)
{
}

// --- UCanvas ---
void UCanvas::SetVirtualSize(float,float)
{
}

void UCanvas::StartFade(FColor,FColor,float,int)
{
}

void UCanvas::UseVirtualSize(int,float,float)
{
}

void UCanvas::SetStretch(float stretchX, float stretchY)
{
	// Retail (23b): stores both params directly into m_fStretchX (0x94) and m_fStretchY (0x98)
	m_fStretchX = stretchX;
	m_fStretchY = stretchY;
}

void UCanvas::DrawTileClipped(UMaterial *,float,float,float,float,float,float)
{
}

int UCanvas::_DrawString(UFont *,int,int,const TCHAR*,FPlane,int,int,int)
{
	return 0;
}

void UCanvas::WrappedDrawString(ERenderStyle,int &,int &,UFont *,int,const TCHAR*)
{
}

void UCanvas::SetClip(int,int,int,int)
{
}

void UCanvas::DrawIcon(UMaterial *,float,float,float,float,float,FPlane,FPlane)
{
}

void UCanvas::DrawPattern(UMaterial *,float,float,float,float,float,float,float,float,FPlane,FPlane)
{
}

void UCanvas::DrawTile(UMaterial *,float,float,float,float,float,float,float,float,float,FPlane,FPlane,float)
{
}

// --- UChannel ---
int UChannel::SendBunch(FOutBunch *,int)
{
	return 0;
}

// --- UFileChannel ---
void UFileChannel::ReceivedBunch(FInBunch &)
{
}

FString UFileChannel::Describe()
{
	return FString();
}

void UFileChannel::Destroy()
{
}

void UFileChannel::Init(UNetConnection *,int,int)
{
}

// --- UGameEngine ---
// --- UInput ---
// --- ULodMeshInstance ---
FMeshAnimSeq * ULodMeshInstance::GetAnimSeq(FName)
{
	return NULL;
}

void ULodMeshInstance::Serialize(FArchive &)
{
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

// --- UMaterial ---
UMaterial * UMaterial::ConvertPolyFlagsToMaterial(UMaterial *,DWORD)
{
	return NULL;
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
}

void UMeshInstance::SetAnimFrame(int,float)
{
}

void UMeshInstance::SetMesh(UMesh *)
{
}

void UMeshInstance::SetScale(FVector)
{
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

FBox UMeshInstance::GetCollisionBoundingBox(const AActor*)
{
	return FBox();
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

FBox UMeshInstance::GetRenderBoundingBox(const AActor*)
{
	return FBox();
}

FSphere UMeshInstance::GetRenderBoundingSphere(const AActor*)
{
	return FSphere();
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

// --- UNetConnection ---
// --- UNetDriver ---
void UNetDriver::TickDispatch(float)
{
}

void UNetDriver::Serialize(FArchive &Ar)
{
	guard(UNetDriver::Serialize);
	// Ghidra 0x1048C210: UObject::Serialize, then a conditional-transact helper (RVA 0x18BFA0)
	// that returns a filtered archive, then serializes fields at +0x3C,+0x44,+0x7C,+0x80.
	UObject::Serialize(Ar);
	// NOTE: Divergence — object-ref fields (+0x3C ServerConnection, +0x44, +0x7C, +0x80) not serialized;
	// full implementation requires transactor helper identification.
	unguard;
}

void UNetDriver::NotifyActorDestroyed(AActor *)
{
}

void UNetDriver::AssertValid()
{
}

void UNetDriver::Destroy()
{
}

int UNetDriver::InitConnect(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

int UNetDriver::InitListen(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

// --- UNullRenderDevice ---
// --- USkeletalMesh ---
void USkeletalMesh::m_bLoadLbpFile(FString)
{
}

int USkeletalMesh::SetAttachAlias(FName,FName,FCoords &)
{
	return 0;
}

int USkeletalMesh::SetAttachmentLocation(AActor *,AActor *)
{
	return 0;
}

int USkeletalMesh::LODFootprint(int,int)
{
	return 0;
}

void USkeletalMesh::NormalizeInfluences(int)
{
}

void USkeletalMesh::CalculateNormals(TArray<FVector> &,int)
{
}

void USkeletalMesh::ClearAttachAliases()
{
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

int USkeletalMesh::UseCylinderCollision(const AActor*)
{
	return 0;
}

int USkeletalMesh::R6LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

void USkeletalMesh::Serialize(FArchive &)
{
}

int USkeletalMesh::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int USkeletalMesh::MemFootprint(int)
{
	return 0;
}

void USkeletalMesh::Destroy()
{
}

FBox USkeletalMesh::GetCollisionBoundingBox(const AActor*) const
{
	return FBox();
}

FBox USkeletalMesh::GetRenderBoundingBox(const AActor*)
{
	return FBox();
}

FSphere USkeletalMesh::GetRenderBoundingSphere(const AActor*)
{
	return FSphere();
}

// --- USkeletalMeshInstance ---
int USkeletalMeshInstance::TraceHeadHit(FCheckResult &,FVector const &,FVector const &,FVector const &,float const &)
{
	return 0;
}

void USkeletalMeshInstance::UpdateBlendAlpha(int,float,float)
{
}

int USkeletalMeshInstance::ValidateAnimChannel(int)
{
	return 0;
}

void USkeletalMeshInstance::SetAnimRate(int,float)
{
}

void USkeletalMeshInstance::SetAnimSequence(int,FName)
{
}

void USkeletalMeshInstance::SetBlendAlpha(int,float)
{
}

int USkeletalMeshInstance::SetBlendParams(int,float,float,float,FName,int)
{
	return 0;
}

int USkeletalMeshInstance::SetBoneDirection(FName,FRotator,FVector,float)
{
	return 0;
}

int USkeletalMeshInstance::SetBoneLocation(FName,FVector,float)
{
	return 0;
}

int USkeletalMeshInstance::SetBonePosition(FName,FRotator,FVector,float)
{
	return 0;
}

int USkeletalMeshInstance::SetBoneRotation(FName,FRotator,int,float,float)
{
	return 0;
}

int USkeletalMeshInstance::SetBoneScale(int,float,FName)
{
	return 0;
}

int USkeletalMeshInstance::SetSkelAnim(UMeshAnimation *,USkeletalMesh *)
{
	return 0;
}

int USkeletalMeshInstance::LockRootMotion(int,int)
{
	return 0;
}

int USkeletalMeshInstance::MatchRefBone(FName)
{
	return 0;
}

void USkeletalMeshInstance::BlendToAlpha(int,float,float)
{
}

void USkeletalMeshInstance::BuildPivotsList()
{
}

void USkeletalMeshInstance::ClearSkelAnims()
{
}

void USkeletalMeshInstance::CopyAnimation(int,int)
{
}

void USkeletalMeshInstance::DrawCollisionCylinders(FSceneNode *)
{
}

int USkeletalMeshInstance::EnableChannelNotify(int,int)
{
	return 0;
}

void USkeletalMeshInstance::ForceAnimRate(int,float)
{
}

int USkeletalMeshInstance::GetAnimChannelCount()
{
	return 0;
}

float USkeletalMeshInstance::GetAnimFrame(int)
{
	return 0.0f;
}

float USkeletalMeshInstance::GetAnimRateOnChannel(int)
{
	return 0.0f;
}

FName USkeletalMeshInstance::GetAnimSequence(int)
{
	return FName(NAME_None);
}

float USkeletalMeshInstance::GetBlendAlpha(int)
{
	return 0.0f;
}

FCoords USkeletalMeshInstance::GetBoneCoords(DWORD,int)
{
	return FCoords();
}

int USkeletalMeshInstance::GetBoneCylinder(int,FCylinder &)
{
	return 0;
}

FName USkeletalMeshInstance::GetBoneName(FName)
{
	return FName(NAME_None);
}

FRotator USkeletalMeshInstance::GetBoneRotation(DWORD,int)
{
	return FRotator(0,0,0);
}

FRotator USkeletalMeshInstance::GetBoneRotation(FName,int)
{
	return FRotator(0,0,0);
}

FVector USkeletalMeshInstance::GetRootLocation()
{
	return FVector(0,0,0);
}

FVector USkeletalMeshInstance::GetRootLocationDelta()
{
	return FVector(0,0,0);
}

FRotator USkeletalMeshInstance::GetRootRotation()
{
	return FRotator(0,0,0);
}

FRotator USkeletalMeshInstance::GetRootRotationDelta()
{
	return FRotator(0,0,0);
}

FCoords USkeletalMeshInstance::GetTagCoords(FName)
{
	return FCoords();
}

FCoords USkeletalMeshInstance::GetTagPosition(FName)
{
	return FCoords();
}

int USkeletalMeshInstance::StopAnimating(int)
{
	return 0;
}

int USkeletalMeshInstance::UpdateAnimation(float)
{
	return 0;
}

void USkeletalMeshInstance::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void USkeletalMeshInstance::Serialize(FArchive &)
{
}

void USkeletalMeshInstance::SetAnimFrame(int,float)
{
}

void USkeletalMeshInstance::SetMesh(UMesh *)
{
}

void USkeletalMeshInstance::SetScale(FVector)
{
}

int USkeletalMeshInstance::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

void USkeletalMeshInstance::MeshSkinVertsCallback(void *)
{
}

int USkeletalMeshInstance::PlayAnim(int,FName,float,float,int,int,int)
{
	return 0;
}

int USkeletalMeshInstance::ActiveVertStreamSize()
{
	return 0;
}

void USkeletalMeshInstance::ActualizeAnimLinkups()
{
}

int USkeletalMeshInstance::AnimForcePose(FName,float,float,int)
{
	return 0;
}

float USkeletalMeshInstance::AnimGetFrameCount(void *)
{
	return 0.0f;
}

FName USkeletalMeshInstance::AnimGetGroup(void *)
{
	return FName(NAME_None);
}

FName USkeletalMeshInstance::AnimGetName(void* Channel)
{
	// Retail: 19b. Same as VertMesh but with null check on Channel.
	FName result;
	if (Channel)
		*(INT*)&result = *(INT*)Channel;
	return result;
}

int USkeletalMeshInstance::AnimGetNotifyCount(void *)
{
	return 0;
}

UAnimNotify * USkeletalMeshInstance::AnimGetNotifyObject(void* Channel, int notifyIndex)
{
	// Retail: 25b. Same as VertMesh but with null check on Channel.
	// Notify array pointer at Channel+0x1C, 12 bytes/entry, ptr at entry+8.
	if (!Channel) return NULL;
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	return *(UAnimNotify**)(notifyArray + notifyIndex * 12 + 8);
}

const TCHAR* USkeletalMeshInstance::AnimGetNotifyText(void *,int)
{
	return NULL;
}

float USkeletalMeshInstance::AnimGetNotifyTime(void *,int)
{
	return 0.0f;
}

float USkeletalMeshInstance::AnimGetRate(void *)
{
	return 0.0f;
}

int USkeletalMeshInstance::AnimIsInGroup(void *,FName)
{
	return 0;
}

int USkeletalMeshInstance::AnimStopLooping(int)
{
	return 0;
}

void USkeletalMeshInstance::ClearChannel(int)
{
}

UMeshAnimation * USkeletalMeshInstance::CurrentSkelAnim(int)
{
	return NULL;
}

void USkeletalMeshInstance::Destroy()
{
}

UMeshAnimation * USkeletalMeshInstance::FindAnimObjectForSequence(FName)
{
	return NULL;
}

int USkeletalMeshInstance::FreezeAnimAt(float,int)
{
	return 0;
}

float USkeletalMeshInstance::GetActiveAnimFrame(int)
{
	return 0.0f;
}

float USkeletalMeshInstance::GetActiveAnimRate(int)
{
	return 0.0f;
}

FName USkeletalMeshInstance::GetActiveAnimSequence(int)
{
	return FName(NAME_None);
}

int USkeletalMeshInstance::GetAnimCount()
{
	return 0;
}

void * USkeletalMeshInstance::GetAnimIndexed(int)
{
	return NULL;
}

void * USkeletalMeshInstance::GetAnimNamed(FName)
{
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
	return FBox();
}

FSphere USkeletalMeshInstance::GetRenderBoundingSphere(const AActor*)
{
	return FSphere();
}

int USkeletalMeshInstance::IsAnimating(int)
{
	return 0;
}

int USkeletalMeshInstance::IsAnimLooping(int)
{
	return 0;
}

int USkeletalMeshInstance::IsAnimPastLastFrame(int)
{
	return 0;
}

int USkeletalMeshInstance::IsAnimTweening(int)
{
	return 0;
}

// --- USound ---
void USound::Serialize(FArchive &)
{
}

void USound::Destroy()
{
}

float USound::GetDuration()
{
	// Ghidra: Duration at offset 0x5C, FSoundData at offset 0x2C.
	// Lazy-init: if Duration < 0, compute via FSoundData::GetPeriod.
	FLOAT& Duration = *(FLOAT*)((BYTE*)this + 0x5C);
	if (Duration < 0.0f)
	{
		FSoundData* SoundData = (FSoundData*)((BYTE*)this + 0x2C);
		Duration = SoundData->GetPeriod();
	}
	return Duration;
}

// --- UStaticMesh ---
void UStaticMesh::TriangleSphereQuery(AActor *,FSphere &,TArray<FStaticMeshCollisionTriangle *> &)
{
}

void UStaticMesh::Build()
{
}

UMaterial * UStaticMesh::GetSkin(AActor *,int)
{
	return NULL;
}

FTags * UStaticMesh::GetTag(FString)
{
	return NULL;
}

void UStaticMesh::Serialize(FArchive &)
{
}

int UStaticMesh::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int UStaticMesh::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}

void UStaticMesh::Destroy()
{
}

FBox UStaticMesh::GetCollisionBoundingBox(const AActor*) const
{
	return FBox();
}

FVector UStaticMesh::GetEncroachCenter(AActor *)
{
	return FVector(0,0,0);
}

FVector UStaticMesh::GetEncroachExtent(AActor *)
{
	return FVector(0,0,0);
}

FBox UStaticMesh::GetRenderBoundingBox(const AActor*)
{
	// Retail: 23b. REP MOVSD 7 DWORDs (28b = FBox) from this+0x2C to return buffer.
	return *(FBox*)((BYTE*)this + 0x2C);
}

FSphere UStaticMesh::GetRenderBoundingSphere(const AActor*)
{
	// Retail: 23b. Copy-constructs FSphere from this+0x48.
	return *(FSphere*)((BYTE*)this + 0x48);
}

void UStaticMesh::Illuminate(AActor *,int)
{
}

// --- UTexture ---
void UTexture::SetLastUpdateTime(double Time)
{
	// Ghidra (13B): __LastUpdateTime at offset 0xD0 as double
	*(double*)((BYTE*)this + 0xD0) = Time;
}

int UTexture::Compress(ETextureFormat,int,FDXTCompressionOptions *)
{
	return 0;
}

ETextureFormat UTexture::ConvertDXT(int,int,int,void * *)
{
	return TEXF_P8;
}

ETextureFormat UTexture::ConvertDXT()
{
	return TEXF_P8;
}

void UTexture::CreateColorRange()
{
}

void UTexture::CreateMips(int,int)
{
}

int UTexture::Decompress(ETextureFormat)
{
	return 0;
}

int UTexture::DefaultLOD()
{
	return 0;
}

FColor * UTexture::GetColors()
{
	// Ghidra (14B): if Palette (0x70) non-null, return Colors data at Palette+0x2C
	void* Pal = *(void**)((BYTE*)this + 0x70);
	if (Pal)
		return *(FColor**)((BYTE*)Pal + 0x2C);
	return NULL;
}

DWORD UTexture::GetColorsIndex()
{
	// Ghidra (9B): return Palette->GetIndex()
	UObject* Pal = *(UObject**)((BYTE*)this + 0x70);
	return Pal->GetIndex();
}

FString UTexture::GetFormatDesc()
{
	return FString();
}

double UTexture::GetLastUpdateTime()
{
	// Ghidra (7B): return double at offset 0xD0
	return *(double*)((BYTE*)this + 0xD0);
}

FMipmapBase * UTexture::GetMip(int MipIndex)
{
	// Ghidra (19B): Mips at 0xBC, element stride 0x28
	BYTE* MipsData = *(BYTE**)((BYTE*)this + 0xBC);
	return (FMipmapBase*)(MipsData + MipIndex * 0x28);
}

int UTexture::GetNumMips()
{
	return Mips.Num();
}

FColor UTexture::GetTexel(float,float,float,float)
{
	return FColor(0,0,0,0);
}

void UTexture::Tick(float)
{
}


void UTexture::ArithOp(UTexture *,ETextureArithOp)
{
}

void UTexture::Clear(DWORD)
{
}

void UTexture::Clear(FColor)
{
}

void UTexture::ConstantTimeTick()
{
	// Retail: 45b. Advances the circular linked-list for realtime texture ticking.
	// this+0xA8 = "current" pointer; object+0xA4 = "next" pointer in each node.
	// If current is null, initializes to self. Then advances current to next.
	void* cur = *(void**)((BYTE*)this + 0xA8);
	if (!cur)
		cur = this;
	void* nxt = *(void**)((BYTE*)cur + 0xA4);
	*(void**)((BYTE*)this + 0xA8) = nxt ? nxt : this; // advance or wrap to self
}


UBitmapMaterial * UTexture::Get(double,UViewport *)
{
	return NULL;
}

FBaseTexture * UTexture::GetRenderInterface()
{
	return reinterpret_cast<FBaseTexture*>(RenderInterface);
}

void UTexture::Init(int,int)
{
}


// --- UVertMeshInstance ---
FMeshAnimSeq * UVertMeshInstance::GetAnimSeq(FName)
{
	return NULL;
}

int UVertMeshInstance::StopAnimating(int)
{
	return 0;
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

float UVertMeshInstance::AnimGetFrameCount(void *)
{
	return 0.0f;
}

FName UVertMeshInstance::AnimGetGroup(void *)
{
	return FName(NAME_None);
}

FName UVertMeshInstance::AnimGetName(void* Channel)
{
	// Retail: 15b. Copies the FName index (first DWORD) from *Channel to output.
	// Animation name is stored at the start of the animation channel struct.
	FName result;
	*(INT*)&result = *(INT*)Channel;
	return result;
}

int UVertMeshInstance::AnimGetNotifyCount(void *)
{
	return 0;
}

UAnimNotify * UVertMeshInstance::AnimGetNotifyObject(void* Channel, int notifyIndex)
{
	// Retail: 21b. Returns UAnimNotify* from packed notify array.
	// Channel+0x1C = pointer to notify array (12 bytes/entry).
	// Notify pointer is at byte offset 8 within each entry.
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	return *(UAnimNotify**)(notifyArray + notifyIndex * 12 + 8);
}

const TCHAR* UVertMeshInstance::AnimGetNotifyText(void *,int)
{
	return NULL;
}

float UVertMeshInstance::AnimGetNotifyTime(void *,int)
{
	return 0.0f;
}

float UVertMeshInstance::AnimGetRate(void *)
{
	return 0.0f;
}

int UVertMeshInstance::AnimIsInGroup(void *,FName)
{
	return 0;
}

int UVertMeshInstance::AnimStopLooping(int)
{
	return 0;
}

float UVertMeshInstance::GetActiveAnimFrame(int)
{
	return 0.0f;
}

float UVertMeshInstance::GetActiveAnimRate(int)
{
	return 0.0f;
}

FName UVertMeshInstance::GetActiveAnimSequence(int)
{
	return FName(NAME_None);
}

int UVertMeshInstance::GetAnimCount()
{
	return 0;
}

void * UVertMeshInstance::GetAnimIndexed(int)
{
	return NULL;
}

void * UVertMeshInstance::GetAnimNamed(FName)
{
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

FBox UVertMeshInstance::GetRenderBoundingBox(const AActor*)
{
	return FBox();
}

FSphere UVertMeshInstance::GetRenderBoundingSphere(const AActor*)
{
	return FSphere();
}

int UVertMeshInstance::IsAnimating(int)
{
	return 0;
}

int UVertMeshInstance::IsAnimLooping(int)
{
	return 0;
}

int UVertMeshInstance::IsAnimPastLastFrame(int)
{
	return 0;
}

int UVertMeshInstance::IsAnimTweening(int)
{
	return 0;
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

// --- AEmitter ---
void AEmitter::Spawned()
{
	// Ghidra 0xdf2e0, 18B: set flag 4 at offset 0x3c8 when not in editor
	if (!GIsEditor)
		*(DWORD*)((BYTE*)this + 0x3c8) |= 4;
}

int AEmitter::Tick(float,ELevelTick)
{
	return 0;
}

void AEmitter::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void AEmitter::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AEmitter::Kill()
{
}

void AEmitter::PostScriptDestroyed()
{
}

int AEmitter::CheckForProjectors()
{
	return 0;
}

void AEmitter::Initialize()
{
}

// --- AFluidSurfaceInfo ---
void AFluidSurfaceInfo::UpdateOscillatorList()
{
}

void AFluidSurfaceInfo::RebuildClampedBitmap()
{
}

void AFluidSurfaceInfo::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void AFluidSurfaceInfo::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AFluidSurfaceInfo::SetClampedBitmap(int,int,int)
{
}

void AFluidSurfaceInfo::FillIndexBuffer(void *)
{
}

void AFluidSurfaceInfo::FillVertexBuffer(void *)
{
}

int AFluidSurfaceInfo::GetClampedBitmap(int,int)
{
	return 0;
}

void AFluidSurfaceInfo::GetNearestIndex(FVector const &,int &,int &)
{
}

FVector AFluidSurfaceInfo::GetVertexPos(int,int)
{
	return FVector(0,0,0);
}

// --- AFluidSurfaceOscillator ---
void AFluidSurfaceOscillator::UpdateOscillation(float)
{
}

void AFluidSurfaceOscillator::PostEditChange()
{
}

void AFluidSurfaceOscillator::Destroy()
{
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

// --- AKActor ---
void AKActor::Spawned()
{
}

// --- AKConeLimit ---
void AKConeLimit::KUpdateConstraintParams()
{
}

// --- AKConstraint ---
MdtBaseConstraint * AKConstraint::getKConstraint() const
{
	// Retail: 7b. MOV EAX, [ECX+0x418]; RET — returns the Karma constraint pointer.
	return *(MdtBaseConstraint**)((BYTE*)this + 0x418);
}

_McdModel * AKConstraint::getKModel() const
{
	return NULL;
}

void AKConstraint::physKarma(float)
{
}

void AKConstraint::postKarmaStep()
{
}

void AKConstraint::preKarmaStep(float)
{
}

void AKConstraint::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AKConstraint::KUpdateConstraintParams()
{
}

void AKConstraint::PostEditChange()
{
}

void AKConstraint::PostEditMove()
{
}

void AKConstraint::CheckForErrors()
{
}

int AKConstraint::CheckOwnerUpdated()
{
	return 0;
}

// --- AKHinge ---
void AKHinge::preKarmaStep(float)
{
}

void AKHinge::KUpdateConstraintParams()
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

// --- AMover ---
void AMover::SetWorldRaytraceKey()
{
}

void AMover::Spawned()
{
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
}

void AMover::PostNetReceive()
{
}

void AMover::PostRaytrace()
{
}

void AMover::PreNetReceive()
{
}

void AMover::PreRaytrace()
{
}

// --- ANote ---
void ANote::CheckForErrors()
{
}

// --- APathNode ---
int APathNode::ReviewPath(APawn *)
{
	return 0;
}

void APathNode::CheckSymmetry(ANavigationPoint *)
{
}

// --- APhysicsVolume ---
void APhysicsVolume::SetZone(int,int)
{
}

INT* APhysicsVolume::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
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

void APlayerController::SetPlayer(UPlayer *)
{
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

// --- AProjector ---
int AProjector::ShouldTrace(AActor * Other, DWORD TraceFlags)
{
	if (TraceFlags & 0x4000)
		return 1;
	return AActor::ShouldTrace(Other, TraceFlags);
}

void AProjector::TickSpecial(float DeltaTime)
{
	// Retail: 17b. If lifecycle state byte at this+0x2C == 5, call vtable[100] (offset 0x190).
	if (*(BYTE*)((BYTE*)this + 0x2C) == 5)
	{
		void** vtbl = *(void***)this;
		typedef void (__thiscall *FnType)(AProjector*);
		((FnType)vtbl[100])(this);
	}
}

void AProjector::UpdateParticleMaterial(UParticleMaterial *,int)
{
}

void AProjector::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AProjector::RenderWireframe(FRenderInterface *)
{
}

void AProjector::PostEditChange()
{
}

void AProjector::PostEditLoad()
{
}

void AProjector::PostEditMove()
{
}

void AProjector::Abandon()
{
}

void AProjector::Attach()
{
}

void AProjector::CalcMatrix()
{
}

void AProjector::Destroy()
{
}

void AProjector::Detach(int)
{
}

UPrimitive * AProjector::GetPrimitive()
{
	return NULL;
}

// --- AR6AbstractCircumstantialActionQuery ---
INT* AR6AbstractCircumstantialActionQuery::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}

// --- AR6ActionSpot ---
void AR6ActionSpot::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AR6ActionSpot::CheckForErrors()
{
}

// --- AR6ColBox ---
int AR6ColBox::ShouldTrace(AActor *,DWORD)
{
	return 0;
}

void AR6ColBox::SetBase(AActor* NewBase, FVector FloorNormal, int bNotifyActor)
{
	// Retail: 21b. If NewBase is NULL, calls error handler (3x null push + call).
	// If non-NULL, cross-function-jumps to AActor::SetBase.
	if (!NewBase) return;
	AActor::SetBase(NewBase, FloorNormal, bNotifyActor);
}

int AR6ColBox::CanStepUp(FVector)
{
	return 0;
}

void AR6ColBox::EnableCollision(int,int,int)
{
}

void AR6ColBox::GetColBoxLocationFromOwner(FVector &,float)
{
}

void AR6ColBox::GetDestination(FVector &,FRotator &)
{
}

float AR6ColBox::GetMaxStepUp(bool,float)
{
	return 0.0f;
}

APawn * AR6ColBox::GetPawnOrColBoxOwner() const
{
	return NULL;
}

int AR6ColBox::IsBlockedBy(AActor const *) const
{
	return 0;
}

// --- AR6DecalGroup ---
void AR6DecalGroup::Spawned()
{
}

void AR6DecalGroup::KillDecal(AR6Decal *)
{
}

void AR6DecalGroup::PostScriptDestroyed()
{
}

void AR6DecalGroup::ActivateGroup()
{
}

int AR6DecalGroup::AddDecal(FVector *,FRotator *,UTexture *,int,float,float,float,float,int)
{
	return 0;
}

// --- AR6DecalManager ---
void AR6DecalManager::Spawned()
{
}

int AR6DecalManager::AddDecal(FVector *,FRotator *,UTexture *,eDecalType,int,float,float,float,float,int)
{
	return 0;
}

AR6DecalGroup * AR6DecalManager::FindGroup(eDecalType)
{
	return NULL;
}

// --- AR6DecalsBase ---
int AR6DecalsBase::IsNetRelevantFor(APlayerController *,AActor *,FVector)
{
	return 0;
}

// --- AR6EngineWeapon ---
int AR6EngineWeapon::GetHeartBeatStatus()
{
	return 0;
}

// --- AR6RainbowStartInfo ---
void AR6RainbowStartInfo::TransferFile(FArchive &)
{
}

// --- AR6TeamStartInfo ---
void AR6TeamStartInfo::TransferFile(FArchive &,int)
{
}

// --- AR6WallHit ---
void AR6WallHit::SpawnEffects()
{
}

void AR6WallHit::SpawnSound()
{
}

void AR6WallHit::PostBeginPlay()
{
}

// --- AR6eviLTesting ---
void AR6eviLTesting::eviLTestATS()
{
}

void AR6eviLTesting::evilTestUpdateSystem()
{
}

// --- ASceneManager ---
void ASceneManager::UpdateViewerFromPct(float)
{
}

int ASceneManager::VerifyIntPoints()
{
	return 0;
}

void ASceneManager::RefreshSubActions(float)
{
}

void ASceneManager::SceneEnded()
{
}

void ASceneManager::SceneStarted()
{
}

void ASceneManager::PreparePath()
{
}

void ASceneManager::ChangeOrientation(FOrientation)
{
}

void ASceneManager::DeletePathSamples()
{
	// Retail: 17b. Empties the PathSamples TArray at this+0x3E4 (12-byte elements).
	// Calls an indirect TArray resize function with count=0, elementSize=12.
	INT* arr = (INT*)((BYTE*)this + 0x3E4);  // TArray: [0]=Data*, [4]=ArrayNum, [8]=ArrayMax
	arr[1] = 0;  // ArrayNum = 0 (retail may also free/realloc the buffer)
}

UMatAction * ASceneManager::GetActionFromPct(float)
{
	return NULL;
}

float ASceneManager::GetActionPctFromScenePct(float)
{
	return 0.0f;
}

FVector ASceneManager::GetLocation(TArray<FVector> *,float)
{
	return FVector(0,0,0);
}

FRotator ASceneManager::GetRotation(TArray<FVector> *,float,FVector,FRotator,UMatAction *,int)
{
	return FRotator(0,0,0);
}

void ASceneManager::InitializeActions()
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

// --- ATerrainInfo ---
void ATerrainInfo::SetupSectors()
{
}

void ATerrainInfo::SoftDeselect()
{
}

void ATerrainInfo::UpdateFromSelectedVertices()
{
}

void ATerrainInfo::ResetMove()
{
}

void ATerrainInfo::PostEditChange()
{
}

void ATerrainInfo::PostLoad()
{
}

void ATerrainInfo::PrecomputeLayerWeights()
{
}

// --- AVolume ---
void AVolume::SetVolumes(TArray<AVolume *> const &)
{
}

void AVolume::SetVolumes()
{
}

int AVolume::ShouldTrace(AActor *,DWORD)
{
	return 0;
}

void AVolume::PostBeginPlay()
{
}

int AVolume::Encompasses(FVector Location)
{
	// Ghidra: Check if Brush is NULL (offset 0x178), return 0 if so.
	// Then call Brush->PointCheck with the location and zero extent.
	// Return 1 if PointCheck returns 0 (point is inside the volume).
	UPrimitive* Brush = *(UPrimitive**)((BYTE*)this + 0x178);
	if (!Brush)
		return 0;

	FCheckResult Result(1.0f);
	INT Check = Brush->PointCheck(Result, this, Location, FVector(0, 0, 0), 0);
	return (Check == 0) ? 1 : 0;
}

// --- AWarpZoneInfo ---
void AWarpZoneInfo::AddMyMarker(AActor *)
{
}

// --- AWarpZoneMarker ---
void AWarpZoneMarker::addReachSpecs(APawn *,int)
{
}

int AWarpZoneMarker::IsIdentifiedAs(FName)
{
	return 0;
}

// --- AZoneInfo ---
void AZoneInfo::PostEditChange()
{
}

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

// --- FBezier ---
FBezier::FBezier(FBezier const &)
{
}

FBezier::FBezier()
{
}

FBezier::~FBezier()
{
}

FBezier& FBezier::operator=(const FBezier&)
{
	return *this;
}

float FBezier::Evaluate(FVector *,int,TArray<FVector> *)
{
	return 0.0f;
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

// --- FCanvasUtil ---
FCanvasUtil::FCanvasUtil(FCanvasUtil const &Other)
{
	// Ghidra 0x18c10: vtable set by compiler; same copy regions as operator= (0x18cb0):
	// scalar state +4..+53, skip transient +54..+93, big vertex batch +94..+CA7
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x50);
	appMemcpy((BYTE*)this + 0x94, (const BYTE*)&Other + 0x94, 0xC14);
}

FCanvasUtil::FCanvasUtil(UViewport *,FRenderInterface *,int,int)
{
}

FCanvasUtil::~FCanvasUtil()
{
}

FCanvasUtil& FCanvasUtil::operator=(const FCanvasUtil& Other)
{
	// Ghidra 0x18cb0: vtable at +0 skipped. Copy +4..+53, skip +54..+93 (transient state),
	// then copy +94..+CA7 (includes big vertex batch + 3 trailing DWORDs)
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x50);
	appMemcpy((BYTE*)this + 0x94, (const BYTE*)&Other + 0x94, 0xC14);
	return *this;
}

// --- FCanvasVertex ---
FCanvasVertex::FCanvasVertex(FVector InPoint, FColor InColor, float InU, float InV)
:	Point(InPoint)
,	Color(InColor)
,	U(InU)
,	V(InV)
{
}

FCanvasVertex::FCanvasVertex()
{
}

FCanvasVertex& FCanvasVertex::operator=(const FCanvasVertex& Other)
{
	Point = Other.Point;
	Color = Other.Color;
	U     = Other.U;
	V     = Other.V;
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

// --- FDXTCompressionOptions ---
FDXTCompressionOptions::FDXTCompressionOptions()
{
}

FDXTCompressionOptions& FDXTCompressionOptions::operator=(const FDXTCompressionOptions& Other)
{
	// Ghidra 0x14390: 9 DWORDs, no vtable. Shares address with CCompressedLipDescData.
	appMemcpy(this, &Other, 36);
	return *this;
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

// --- FFontCharacter ---
FFontCharacter& FFontCharacter::operator=(const FFontCharacter& Other)
{
	appMemcpy( this, &Other, sizeof(FFontCharacter) );
	return *this;
}

// --- FFontPage ---
FFontPage::FFontPage(FFontPage const &Other)
{
	// Ghidra 0x27800: no vtable; 2 DWORDs at +0,+4; TArray<FLineVertex> at +8 (stride 0x10)
	appMemcpy(this, &Other, 8);
	new ((BYTE*)this + 0x08) TArray<FLineVertex>(*(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x08));
}

FFontPage::FFontPage()
{
	// Initialize TArray<FLineVertex> at +8 to empty
	new ((BYTE*)this + 0x08) TArray<FLineVertex>();
}

FFontPage::~FFontPage()
{
	// Ghidra 0x103277f0: destroy TArray<FLineVertex> at +8 (stride 0x10, POD elements)
	((TArray<FLineVertex>*)((BYTE*)this + 0x08))->~TArray();
}

FFontPage& FFontPage::operator=(const FFontPage& Other)
{
	// Ghidra 0x27830: 2 DWORDs at +0,+4, then TArray<FLineVertex> at +8
	// (FUN_1031e1c0 = 16-byte elems, same function as FLineBatcher::op=)
	appMemcpy(this, &Other, 8);
	*(TArray<FLineVertex>*)((BYTE*)this + 0x08) = *(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x08);
	return *this;
}

// --- FKAggregateGeom ---
FKAggregateGeom::FKAggregateGeom(FKAggregateGeom const &Other)
{
	// Ghidra 0x3cc00: no vtable; 4 TArrays at +0, +0xC, +0x18, +0x24
	new ((BYTE*)this + 0x00) TArray<FKSphereElem>(*(const TArray<FKSphereElem>*)((const BYTE*)&Other + 0x00));
	new ((BYTE*)this + 0x0C) TArray<FKBoxElem>(*(const TArray<FKBoxElem>*)((const BYTE*)&Other + 0x0C));
	new ((BYTE*)this + 0x18) TArray<FKCylinderElem>(*(const TArray<FKCylinderElem>*)((const BYTE*)&Other + 0x18));
	new ((BYTE*)this + 0x24) TArray<FKConvexElem>(*(const TArray<FKConvexElem>*)((const BYTE*)&Other + 0x24));
}

FKAggregateGeom::FKAggregateGeom()
{
	// Initialize all 4 TArrays to empty
	new ((BYTE*)this + 0x00) TArray<FKSphereElem>();
	new ((BYTE*)this + 0x0C) TArray<FKBoxElem>();
	new ((BYTE*)this + 0x18) TArray<FKCylinderElem>();
	new ((BYTE*)this + 0x24) TArray<FKConvexElem>();
}

FKAggregateGeom::~FKAggregateGeom()
{
	// Destroy 4 TArrays in reverse order
	((TArray<FKConvexElem>*)((BYTE*)this + 0x24))->~TArray();
	((TArray<FKCylinderElem>*)((BYTE*)this + 0x18))->~TArray();
	((TArray<FKBoxElem>*)((BYTE*)this + 0x0C))->~TArray();
	((TArray<FKSphereElem>*)((BYTE*)this + 0x00))->~TArray();
}

FKAggregateGeom& FKAggregateGeom::operator=(const FKAggregateGeom& Other)
{
	// Ghidra 0x3cc80: 4 TArrays at +0,+0xC,+0x18,+0x24
	*(TArray<FKSphereElem>*)((BYTE*)this + 0x00) = *(const TArray<FKSphereElem>*)((const BYTE*)&Other + 0x00);
	*(TArray<FKBoxElem>*)((BYTE*)this + 0x0C) = *(const TArray<FKBoxElem>*)((const BYTE*)&Other + 0x0C);
	*(TArray<FKCylinderElem>*)((BYTE*)this + 0x18) = *(const TArray<FKCylinderElem>*)((const BYTE*)&Other + 0x18);
	*(TArray<FKConvexElem>*)((BYTE*)this + 0x24) = *(const TArray<FKConvexElem>*)((const BYTE*)&Other + 0x24);
	return *this;
}

void FKAggregateGeom::EmptyElements()
{
	// Retail: 44b. Calls TArray::Empty(0) on each sub-array.
	// Retail order: boxes (0x0C), convex (0x24), cylinders (0x18), spheres (0x00).
	((TArray<FKBoxElem>*)     ((BYTE*)this + 0x0C))->Empty();
	((TArray<FKConvexElem>*)  ((BYTE*)this + 0x24))->Empty();
	((TArray<FKCylinderElem>*)((BYTE*)this + 0x18))->Empty();
	((TArray<FKSphereElem>*)  ((BYTE*)this + 0x00))->Empty();
}

// Ghidra: sum of 4 TArray Num() at offsets 0x00, 0x0C, 0x18, 0x24
int FKAggregateGeom::GetElementCount()
{
	INT* Counts = (INT*)this;
	// TArray layout: Data(4), ArrayNum(4), ArrayMax(4) = 12 bytes each
	// ArrayNum offsets: 0x04, 0x10, 0x1C, 0x28
	return Counts[1] + Counts[4] + Counts[7] + Counts[10];
}

// --- FKBoxElem ---
FKBoxElem::FKBoxElem(float InSize)
{
	// Ghidra: FMatrix::FMatrix() + set all 3 dims to same value
	X = InSize;
	Y = InSize;
	Z = InSize;
}

FKBoxElem::FKBoxElem(float InX, float InY, float InZ)
{
	X = InX;
	Y = InY;
	Z = InZ;
}

FKBoxElem::FKBoxElem()
{
	// Ghidra: just calls FMatrix::FMatrix() (default FMatrix ctor is empty)
}

FKBoxElem::~FKBoxElem()
{
}

FKBoxElem& FKBoxElem::operator=(const FKBoxElem& Other)
{
	appMemcpy( this, &Other, sizeof(FKBoxElem) );
	return *this;
}

// --- FKConvexElem ---
FKConvexElem::FKConvexElem(FKConvexElem const &Other)
{
	// Ghidra 0x27ce0: no vtable; 16 DWORDs at +0..+3F; TArray<FVector> at +40 (stride 12); TArray<INT> at +4C (stride 4)
	appMemcpy(this, &Other, 0x40); // 16 DWORDs
	new ((BYTE*)this + 0x40) TArray<FVector>(*(const TArray<FVector>*)((const BYTE*)&Other + 0x40));
	new ((BYTE*)this + 0x4C) TArray<INT>(*(const TArray<INT>*)((const BYTE*)&Other + 0x4C));
}

FKConvexElem::FKConvexElem()
{
	// Initialize TArray<FVector> at +0x40 and TArray<INT> at +0x4C to empty
	new ((BYTE*)this + 0x40) TArray<FVector>();
	new ((BYTE*)this + 0x4C) TArray<INT>();
}

FKConvexElem::~FKConvexElem()
{
	// Destroy TArray<INT> at +0x4C then TArray<FVector> at +0x40 (reverse order)
	((TArray<INT>*)((BYTE*)this + 0x4C))->~TArray();
	((TArray<FVector>*)((BYTE*)this + 0x40))->~TArray();
}

FKConvexElem& FKConvexElem::operator=(const FKConvexElem& Other)
{
	// Ghidra 0x27d50: 16 DWORDs (64 bytes) at +0..+3F (no vtable),
	// TArray<FVector> at +40 (FUN_10323160=12-byte), TArray<INT> at +4C (FUN_10322870=4-byte)
	appMemcpy(this, &Other, 0x40);
	*(TArray<FVector>*)((BYTE*)this + 0x40) = *(const TArray<FVector>*)((const BYTE*)&Other + 0x40);
	*(TArray<INT>*)((BYTE*)this + 0x4C) = *(const TArray<INT>*)((const BYTE*)&Other + 0x4C);
	return *this;
}

// --- FKCylinderElem ---
FKCylinderElem::FKCylinderElem(float InRadius, float InLength)
{
	Radius = InRadius;
	Length = InLength;
}

FKCylinderElem::FKCylinderElem()
{
}

FKCylinderElem::~FKCylinderElem()
{
}

FKCylinderElem& FKCylinderElem::operator=(const FKCylinderElem& Other)
{
	appMemcpy( this, &Other, sizeof(FKCylinderElem) );
	return *this;
}

// --- FKSphereElem ---
FKSphereElem::FKSphereElem(float InRadius)
{
	Radius = InRadius;
}

FKSphereElem::FKSphereElem()
{
}

FKSphereElem::~FKSphereElem()
{
}

FKSphereElem& FKSphereElem::operator=(const FKSphereElem& Other)
{
	appMemcpy( this, &Other, sizeof(FKSphereElem) );
	return *this;
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

// --- FMipmap ---
FMipmap::FMipmap(FMipmap const &)
{
}

FMipmap::FMipmap(BYTE,BYTE)
{
}

FMipmap::FMipmap(BYTE,BYTE,int)
{
}

FMipmap::FMipmap()
{
}

FMipmap::~FMipmap()
{
}

FMipmap& FMipmap::operator=(const FMipmap& Other)
{
	// Ghidra 0x27790: FMipmapBase 4 DWORDs at +0..+0C, skip FLazyLoader vtable at +10,
	// deep-copy TArray<BYTE> at +1C, then SavedAr at +14 and SavedPos at +18
	appMemcpy(this, &Other, 0x10); // FMipmapBase data
	*(TArray<BYTE>*)((BYTE*)this + 0x1C) = *(const TArray<BYTE>*)((const BYTE*)&Other + 0x1C);
	*(DWORD*)((BYTE*)this + 0x14) = *(const DWORD*)((const BYTE*)&Other + 0x14);
	*(DWORD*)((BYTE*)this + 0x18) = *(const DWORD*)((const BYTE*)&Other + 0x18);
	return *this;
}

void FMipmap::Clear()
{
}

// --- FMipmapBase ---
FMipmapBase::FMipmapBase(BYTE,BYTE)
{
}

FMipmapBase::FMipmapBase()
{
}

FMipmapBase& FMipmapBase::operator=(const FMipmapBase& Other)
{
	appMemcpy( this, &Other, sizeof(FMipmapBase) );
	return *this;
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

// --- FR6MatineePreviewProxy ---
void FR6MatineePreviewProxy::OnEndSequenceNotify(ASceneManager *)
{
}

void FR6MatineePreviewProxy::OnScrollBarUpdate()
{
}

FR6MatineePreviewProxy::FR6MatineePreviewProxy(FR6MatineePreviewProxy const &)
{
}

FR6MatineePreviewProxy::FR6MatineePreviewProxy()
{
}

FR6MatineePreviewProxy::~FR6MatineePreviewProxy()
{
}

FR6MatineePreviewProxy& FR6MatineePreviewProxy::operator=(const FR6MatineePreviewProxy&)
{
	return *this;
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

// --- FRawIndexBuffer ---
int FRawIndexBuffer::Stripify()
{
	return 0;
}

FRawIndexBuffer::FRawIndexBuffer(FRawIndexBuffer const &Other)
{
	// Ghidra 0x18d80: vtable set by compiler; TArray<WORD> at +4 (stride 2); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<WORD>(*(const TArray<WORD>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

FRawIndexBuffer::FRawIndexBuffer()
{
	// Initialize TArray<WORD> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<WORD>();
}

FRawIndexBuffer::~FRawIndexBuffer()
{
	// destroy TArray<WORD> at +4
	((TArray<WORD>*)((BYTE*)this + 0x04))->~TArray();
}

FRawIndexBuffer& FRawIndexBuffer::operator=(const FRawIndexBuffer& Other)
{
	// Ghidra 0x18dc0: skip vtable +0; +4=TArray<WORD>; +0x10,+0x14,+0x18=3 DWORDs
	*(TArray<WORD>*)((BYTE*)this + 0x04) = *(const TArray<WORD>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C);
	return *this;
}

// --- FReachSpec ---
FReachSpec& FReachSpec::operator=(const FReachSpec& Other)
{
	appMemcpy(this, &Other, 44); // 11 dwords, shared with FStaticMeshCollisionNode
	return *this;
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

// --- FStatGraphLine ---
FStatGraphLine::FStatGraphLine(FStatGraphLine const &Other)
{
	// Ghidra 0x2c410: no vtable; DWORD at +0; TArray<FLOAT> at +4; 2 DWORDs at +10; FString at +18; 4 DWORDs at +24..+30
	*(DWORD*)this = *(const DWORD*)&Other;
	new ((BYTE*)this + 0x04) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 8); // 2 DWORDs
	new ((BYTE*)this + 0x18) FString(*(const FString*)((const BYTE*)&Other + 0x18));
	appMemcpy((BYTE*)this + 0x24, (const BYTE*)&Other + 0x24, 0x10); // 4 DWORDs
}

FStatGraphLine::FStatGraphLine()
{
	// Initialize TArray<FLOAT> at +4 and FString at +18 to empty
	new ((BYTE*)this + 0x04) TArray<FLOAT>();
	new ((BYTE*)this + 0x18) FString();
}

FStatGraphLine::~FStatGraphLine()
{
	// Destroy FString at +18 then TArray<FLOAT> at +4 (reverse order)
	((FString*)((BYTE*)this + 0x18))->~FString();
	((TArray<FLOAT>*)((BYTE*)this + 0x04))->~TArray();
}

FStatGraphLine& FStatGraphLine::operator=(const FStatGraphLine& Other)
{
	// Ghidra 0x21790: DWORD at +0, TArray<FLOAT> at +4 (FUN_1031f660=4-byte data points),
	// 2 DWORDs at +10,+14, FString at +18, 4 DWORDs at +24..+30
	*(DWORD*)((BYTE*)this + 0x00) = *(const DWORD*)((const BYTE*)&Other + 0x00);
	*(TArray<FLOAT>*)((BYTE*)this + 0x04) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 8); // 2 DWORDs
	*(FString*)((BYTE*)this + 0x18) = *(const FString*)((const BYTE*)&Other + 0x18);
	appMemcpy((BYTE*)this + 0x24, (const BYTE*)&Other + 0x24, 0x10); // 4 DWORDs
	return *this;
}

int FStatGraphLine::operator==(FStatGraphLine const &) const
{
	return 0;
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
	return 0;
}

ETextureFormat FStaticCubemap::GetFormat()
{
	return TEXF_P8;
}

int FStaticCubemap::GetHeight()
{
	return 0;
}

int FStaticCubemap::GetNumMips()
{
	return 0;
}

int FStaticCubemap::GetRevision()
{
	return 0;
}

ETexClampMode FStaticCubemap::GetUClamp()
{
	return TC_Wrap;
}

ETexClampMode FStaticCubemap::GetVClamp()
{
	return TC_Wrap;
}

int FStaticCubemap::GetWidth()
{
	return 0;
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

// --- FStaticMeshCollisionNode ---
FStaticMeshCollisionNode::FStaticMeshCollisionNode()
{
	// Ghidra: only constructs FBox at offset 0x10 (empty default ctor)
}

FStaticMeshCollisionNode& FStaticMeshCollisionNode::operator=(const FStaticMeshCollisionNode& Other)
{
	appMemcpy(this, &Other, 44); // 11 dwords, shared with FReachSpec
	return *this;
}

// --- FStaticMeshCollisionTriangle ---
FStaticMeshCollisionTriangle::FStaticMeshCollisionTriangle(FStaticMeshCollisionTriangle const & Other)
{
	appMemcpy(_Data, Other._Data, 84); // 21 dwords: 4 FPlanes + 5 extra dwords
}

FStaticMeshCollisionTriangle::FStaticMeshCollisionTriangle()
{
	// Ghidra: constructs 4 FPlanes (all empty default ctors)
}

FStaticMeshCollisionTriangle& FStaticMeshCollisionTriangle::operator=(const FStaticMeshCollisionTriangle& Other)
{
	appMemcpy(_Data, Other._Data, 84); // 21 dwords
	return *this;
}

// --- FStaticMeshMaterial ---
FStaticMeshMaterial::FStaticMeshMaterial(UMaterial * InMaterial)
{
	Material = InMaterial;
	Flags1 = 1;
	Flags2 = 1;
}

FStaticMeshMaterial& FStaticMeshMaterial::operator=(const FStaticMeshMaterial& Other)
{
	Material = Other.Material;
	Flags1 = Other.Flags1;
	Flags2 = Other.Flags2;
	return *this;
}

// --- FStaticMeshSection ---
FStaticMeshSection::FStaticMeshSection()
{
}

FStaticMeshSection& FStaticMeshSection::operator=(const FStaticMeshSection& Other)
{
	appMemcpy( this, &Other, sizeof(FStaticMeshSection) );
	return *this;
}

// --- FStaticMeshTriangle ---
FStaticMeshTriangle::FStaticMeshTriangle()
{
	// Ghidra: constructs 3 FVectors at offsets 0x00, 0x0C, 0x18 (all empty default ctors)
}

FStaticMeshTriangle& FStaticMeshTriangle::operator=(const FStaticMeshTriangle& Other)
{
	appMemcpy(_Data, Other._Data, 260); // 65 dwords, shared with FSortedPathList
	return *this;
}

// --- FStaticMeshUV ---
FStaticMeshUV& FStaticMeshUV::operator=(const FStaticMeshUV& Other)
{
	*(INT*)&_Data[0] = *(INT*)&Other._Data[0];
	*(INT*)&_Data[4] = *(INT*)&Other._Data[4];
	return *this;
}

// --- FStaticMeshUVStream ---
FStaticMeshUVStream::FStaticMeshUVStream(FStaticMeshUVStream const &Other)
{
	// Ghidra 0x2c110: vtable set by compiler; TArray<FStaticMeshUV> at +4 (stride 8); 4 DWORDs at +10..+1c
	new ((BYTE*)this + 0x04) TArray<FStaticMeshUV>(*(const TArray<FStaticMeshUV>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x10); // 4 DWORDs
}

FStaticMeshUVStream::FStaticMeshUVStream()
{
	// Initialize TArray<FStaticMeshUV> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FStaticMeshUV>();
}

FStaticMeshUVStream::~FStaticMeshUVStream()
{
	// destroy TArray<FStaticMeshUV> at +4 (stride 8, POD elements)
	((TArray<FStaticMeshUV>*)((BYTE*)this + 0x04))->~TArray();
}

FStaticMeshUVStream& FStaticMeshUVStream::operator=(const FStaticMeshUVStream& Other)
{
	// Ghidra 0x2c150: skip vtable at +0, TArray<FStaticMeshUV> at +4 (FUN_103220d0=8-byte),
	// then 4 DWORDs at +10..+1C
	*(TArray<FStaticMeshUV>*)((BYTE*)this + 0x04) = *(const TArray<FStaticMeshUV>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x10); // 4 DWORDs
	return *this;
}

// --- FStaticMeshVertex ---
FStaticMeshVertex::FStaticMeshVertex()
{
	// Ghidra: constructs two FVectors at offset 0 and 0xC (same as FBspVertex)
	*(FVector*)&_Data[0] = FVector(0,0,0);
	*(FVector*)&_Data[12] = FVector(0,0,0);
}

FStaticMeshVertex& FStaticMeshVertex::operator=(const FStaticMeshVertex& Other)
{
	appMemcpy( this, &Other, sizeof(FStaticMeshVertex) );
	return *this;
}

// --- FStaticMeshVertexStream ---
FStaticMeshVertexStream::FStaticMeshVertexStream(FStaticMeshVertexStream const &Other)
{
	// Ghidra 0x2bf90: vtable set by compiler; TArray<FStaticMeshVertex> at +4 (stride 0x18); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FStaticMeshVertex>(*(const TArray<FStaticMeshVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

FStaticMeshVertexStream::FStaticMeshVertexStream()
{
	// Initialize TArray<FStaticMeshVertex> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FStaticMeshVertex>();
}

FStaticMeshVertexStream::~FStaticMeshVertexStream()
{
	// destroy TArray<FStaticMeshVertex> at +4 (stride 0x18, POD elements)
	((TArray<FStaticMeshVertex>*)((BYTE*)this + 0x04))->~TArray();
}

FStaticMeshVertexStream& FStaticMeshVertexStream::operator=(const FStaticMeshVertexStream& Other)
{
	// Ghidra 0x2bfd0: skip vtable at +0, TArray<FStaticMeshVertex> at +4 (FUN_10324030=24-byte),
	// then 3 DWORDs at +10..+18
	*(TArray<FStaticMeshVertex>*)((BYTE*)this + 0x04) = *(const TArray<FStaticMeshVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
	return *this;
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

// --- FTerrainMaterialLayer ---
FTerrainMaterialLayer::FTerrainMaterialLayer()
{
}

FTerrainMaterialLayer::~FTerrainMaterialLayer()
{
}

FTerrainMaterialLayer& FTerrainMaterialLayer::operator=(const FTerrainMaterialLayer& Other)
{
	// Ghidra 0x9810: shares address with FKCylinderElem::operator= (same-size flat copy, no vtable)
	appMemcpy(this, &Other, sizeof(FTerrainMaterialLayer));
	return *this;
}

// --- FTerrainTools ---
void FTerrainTools::SetAdjust(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x60) = Value;
}

void FTerrainTools::SetCurrentBrush(int)
{
}

void FTerrainTools::SetCurrentTerrainInfo(ATerrainInfo* Info)
{
	// Ghidra (29B): if changed, set ptr and zero related fields
	ATerrainInfo** Cur = (ATerrainInfo**)&Pad[0x78];
	if (*Cur != Info)
	{
		*Cur = Info;
		*(INT*)&Pad[0x70] = 0;
		*(INT*)&Pad[0x74] = 0;
		*(INT*)&Pad[0x54] = 0;
		*(INT*)&Pad[0x5C] = 0;
	}
}

void FTerrainTools::SetFloorOffset(int Value)
{
	// Retail: 20b. Clamp to minimum of -7 only; no upper clamp.
	if (Value < -7) Value = -7;
	*(INT*)&Pad[0x40] = Value;
}

void FTerrainTools::SetInnerRadius(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x54) = Value;
}

void FTerrainTools::SetMirrorAxis(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x64) = Value;
}

void FTerrainTools::SetOuterRadius(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x58) = Value;
}

void FTerrainTools::SetStrength(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x5C) = Value;
}

FTerrainTools::FTerrainTools(FTerrainTools const &)
{
}

FTerrainTools::~FTerrainTools()
{
}

void FTerrainTools::AdjustAlignedActors()
{
}

void FTerrainTools::FindActorsToAlign()
{
}

int FTerrainTools::GetAdjust()
{
	// Ghidra (21B): if brush ptr (Pad[0]) non-null, read from indirect struct;
	// otherwise return fallback at Pad[0x88].
	INT* BrushPtr = *(INT**)&Pad[0];
	if (BrushPtr)
	{
		INT* DataPtr = *(INT**)&Pad[0x50];
		return *(INT*)((BYTE*)DataPtr + 0x60);
	}
	return *(INT*)&Pad[0x88];
}

ATerrainInfo * FTerrainTools::GetCurrentTerrainInfo()
{
	// Ghidra (4B): return pointer at Pad[0x78]
	return *(ATerrainInfo**)&Pad[0x78];
}

FString FTerrainTools::GetExecFromBrushName(FString &)
{
	return FString();
}

int FTerrainTools::GetFloorOffset()
{
	// Ghidra (4B): direct read from Pad[0x40]
	return *(INT*)&Pad[0x40];
}

int FTerrainTools::GetInnerRadius()
{
	INT* BrushPtr = *(INT**)&Pad[0];
	if (BrushPtr)
	{
		INT* DataPtr = *(INT**)&Pad[0x50];
		return *(INT*)((BYTE*)DataPtr + 0x54);
	}
	return *(INT*)&Pad[0x7C];
}

int FTerrainTools::GetMirrorAxis()
{
	INT* BrushPtr = *(INT**)&Pad[0];
	if (BrushPtr)
	{
		INT* DataPtr = *(INT**)&Pad[0x50];
		return *(INT*)((BYTE*)DataPtr + 0x64);
	}
	return *(INT*)&Pad[0x8C];
}

int FTerrainTools::GetOuterRadius()
{
	INT* BrushPtr = *(INT**)&Pad[0];
	if (BrushPtr)
	{
		INT* DataPtr = *(INT**)&Pad[0x50];
		return *(INT*)((BYTE*)DataPtr + 0x58);
	}
	return *(INT*)&Pad[0x80];
}

int FTerrainTools::GetStrength()
{
	INT* BrushPtr = *(INT**)&Pad[0];
	if (BrushPtr)
	{
		INT* DataPtr = *(INT**)&Pad[0x50];
		return *(INT*)((BYTE*)DataPtr + 0x5C);
	}
	return *(INT*)&Pad[0x84];
}

void FTerrainTools::Init()
{
}

// --- FZoneProperties ---
FZoneProperties::FZoneProperties(const FZoneProperties& Other)
{
	// Ghidra 0x2ac0: shares address with operator=; 18 DWORDs flat copy (no vtable)
	appMemcpy(this, &Other, 0x48);
}

FZoneProperties::FZoneProperties()
{
}

FZoneProperties& FZoneProperties::operator=(const FZoneProperties& Other)
{
	// Ghidra 0x2ac0: 18 DWORDs from +0x00 (no vtable; also used as copy ctor body)
	appMemcpy(this, &Other, 0x48);
	return *this;
}

// --- UActorChannel ---
void UActorChannel::StaticConstructor()
{
}

void UActorChannel::Tick()
{
}

void UActorChannel::ReceivedBunch(FInBunch &)
{
}

void UActorChannel::ReceivedNak(int)
{
}

void UActorChannel::ReplicateActor()
{
}

void UActorChannel::SetChannelActor(AActor *)
{
}

void UActorChannel::SetClosingFlag()
{
}

void UActorChannel::Close()
{
}

FString UActorChannel::Describe()
{
	return FString();
}

void UActorChannel::Destroy()
{
}

AActor * UActorChannel::GetActor()
{
	// Ghidra (4B): Actor at offset 0x6C
	return *(AActor**)((BYTE*)this + 0x6C);
}

void UActorChannel::Init(UNetConnection *,int,int)
{
}

// --- UAnimNotify ---
void UAnimNotify::Notify(UMeshInstance *,AActor *)
{
}

void UAnimNotify::PostEditChange()
{
	// Retail: FF 41 2C C3 = INC [ECX+0x2C]; RET — increments Revision counter
	Revision++;
}

// --- UAnimNotify_DestroyEffect ---
void UAnimNotify_DestroyEffect::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimNotify_Effect ---
void UAnimNotify_Effect::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimNotify_MatSubAction ---
void UAnimNotify_MatSubAction::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimNotify_Script ---
void UAnimNotify_Script::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimNotify_Scripted ---
void UAnimNotify_Scripted::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimNotify_Sound ---
void UAnimNotify_Sound::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimation ---
void UAnimation::Serialize(FArchive &)
{
}

// --- UBeamEmitter ---
void UBeamEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
}

void UBeamEmitter::UpdateActorHitList()
{
}

int UBeamEmitter::UpdateParticles(float)
{
	return 0;
}

int UBeamEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
}

void UBeamEmitter::Scale(float)
{
}

void UBeamEmitter::PostEditChange()
{
}

void UBeamEmitter::CleanUp()
{
}

void UBeamEmitter::Initialize(int)
{
}

// --- UBinaryFileDownload ---
void UBinaryFileDownload::StaticConstructor()
{
}

void UBinaryFileDownload::Tick()
{
}

int UBinaryFileDownload::TrySkipFile()
{
	return 0;
}

// --- UBitmapMaterial ---


UBitmapMaterial * UBitmapMaterial::Get(double,UViewport *)
{
	return this;
}

// --- UCameraEffect ---
void UCameraEffect::PostRender(UViewport *,FRenderInterface *)
{
}

void UCameraEffect::PreRender(UViewport *,FRenderInterface *)
{
}

// --- UCameraOverlay ---
void UCameraOverlay::PostRender(UViewport *,FRenderInterface *)
{
}

// --- UCanvas ---
void __cdecl UCanvas::WrappedPrint(ERenderStyle,int &,int &,UFont *,int,const TCHAR*)
{
}

void UCanvas::WrappedPrintf(UFont *,int,const TCHAR*,...)
{
}

void UCanvas::WrappedStrLenf(UFont *,int &,int &,const TCHAR*,...)
{
}

// --- UChannel ---
// --- UChannelDownload ---
void UChannelDownload::StaticConstructor()
{
}

int UChannelDownload::TrySkipFile()
{
	return 0;
}

void UChannelDownload::ReceiveFile(UNetConnection *,int,const TCHAR*,int)
{
}

void UChannelDownload::Serialize(FArchive &)
{
}

void UChannelDownload::Destroy()
{
}

// --- UClient ---
void UClient::StaticConstructor()
{
}

void UClient::UpdateGamma()
{
}

void UClient::UpdateGraphicOptions()
{
}

void UClient::RestoreGamma()
{
}

void UClient::Serialize(FArchive &)
{
}

void UClient::PostEditChange()
{
}

void UClient::Destroy()
{
}

int UClient::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

void UClient::Flush(int)
{
}

void UClient::Init(UEngine *)
{
}

// --- UCombiner ---







// --- UConstantColor ---
FColor UConstantColor::GetColor(float)
{
	return Color;
}

// --- UConstantMaterial ---
FColor UConstantMaterial::GetColor(float)
{
	return FColor(0,0,0,0);
}

// --- UControlChannel ---
void UControlChannel::StaticConstructor()
{
}

void UControlChannel::ReceivedBunch(FInBunch &)
{
}

void UControlChannel::Serialize(const TCHAR*,EName)
{
}

FString UControlChannel::Describe()
{
	return FString();
}

void UControlChannel::Destroy()
{
}

void UControlChannel::Init(UNetConnection *,int,int)
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

// --- UCubemap ---
void UCubemap::Destroy()
{
}

FBaseTexture * UCubemap::GetRenderInterface()
{
	// Retail: 8B 81 F0 00 00 00 C3 = return *(this+0xF0) — UCubemap's own render interface
	return *(FBaseTexture**)((BYTE*)this + 0xF0);
}

// --- UDemoRecDriver ---
void UDemoRecDriver::SpawnDemoRecSpectator(UNetConnection *)
{
}

void UDemoRecDriver::StaticConstructor()
{
}

void UDemoRecDriver::TickDispatch(float)
{
}

void UDemoRecDriver::LowLevelDestroy()
{
}

FString UDemoRecDriver::LowLevelGetNetworkNumber()
{
	return FString();
}

int UDemoRecDriver::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

ULevel * UDemoRecDriver::GetLevel()
{
	return NULL;
}

int UDemoRecDriver::InitBase(int,FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

int UDemoRecDriver::InitConnect(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

int UDemoRecDriver::InitListen(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

// --- UDownload ---
void UDownload::StaticConstructor()
{
}

void UDownload::Tick()
{
}

int UDownload::TrySkipFile()
{
	return 0;
}

void UDownload::ReceiveData(BYTE*,int)
{
}

void UDownload::ReceiveFile(UNetConnection *,int,const TCHAR*,int)
{
}

void UDownload::Serialize(FArchive &)
{
}

void UDownload::Destroy()
{
}

void UDownload::DownloadDone()
{
}

void UDownload::DownloadError(const TCHAR*)
{
}

// --- UEngine ---
void UEngine::StaticConstructor()
{
}

int UEngine::ReplaceTexture(FString,UTexture *)
{
	return 0;
}

void UEngine::Serialize(FArchive &Ar)
{
	guard(UEngine::Serialize);
	// Ghidra 0x10393120: UObject::Serialize, then Ar << fields at +0x40,+0x44(Client),+0x48(Audio),+0x4C,
	// then 5 global static UObject* pointers (BSS, always NULL on first run).
	UObject::Serialize(Ar);
	Ar << *(UObject**)((BYTE*)this + 0x40);	// unknown UObject* field before Client
	Ar << (UObject*&)Client;
	Ar << (UAudioSubsystem*&)Audio;
	Ar << *(UObject**)((BYTE*)this + 0x4C);	// unknown UObject* field after Audio
	// NOTE: Divergence — 5 global static UObject* refs (0x1066bcd0-bc) skipped; BSS/NULL at startup.
	unguard;
}

int UEngine::Key(UViewport *,EInputKey)
{
	return 0;
}

int UEngine::LoadBackgroundImage(FString,UTexture *,UTexture *)
{
	return 0;
}

void UEngine::LoadRandomMenuBackgroundImage(FString)
{
}

int UEngine::CacheArmPatch(FGuid *,DWORD *)
{
	return 0;
}

void UEngine::Destroy()
{
}

int UEngine::ExecServerProf(const TCHAR*,int,FOutputDevice &)
{
	return 0;
}

void UEngine::InitAudio()
{
}

int UEngine::InputEvent(UViewport *,EInputKey,EInputAction,float)
{
	return 0;
}

// --- UFadeColor ---
FColor UFadeColor::GetColor(float)
{
	return FColor(0,0,0,0);
}

// --- UFileChannel ---
void UFileChannel::StaticConstructor()
{
}

void UFileChannel::Tick()
{
}

// --- UFinalBlend ---





// --- UFluidSurfacePrimitive ---
void UFluidSurfacePrimitive::Serialize(FArchive &)
{
}

int UFluidSurfacePrimitive::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int UFluidSurfacePrimitive::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}

FBox UFluidSurfacePrimitive::GetCollisionBoundingBox(AActor const *) const
{
	return FBox();
}

FBox UFluidSurfacePrimitive::GetRenderBoundingBox(AActor const *)
{
	return FBox();
}

FSphere UFluidSurfacePrimitive::GetRenderBoundingSphere(AActor const *)
{
	return FSphere();
}

// --- UFont ---
_WORD UFont::RemapChar(_WORD)
{
	return 0;
}

void UFont::Serialize(FArchive &)
{
}

// --- UGameEngine ---
int UGameEngine::ReplaceTexture(FString,UTexture *)
{
	return 0;
}

int UGameEngine::LoadBackgroundImage(FString,UTexture *,UTexture *)
{
	return 0;
}

void UGameEngine::LoadRandomMenuBackgroundImage(FString)
{
}

void UGameEngine::PostRenderFullScreenEffects(FLevelSceneNode *,UViewport *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,APawn *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,UMaterial *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,UMesh *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,UStaticMesh *)
{
}

void UGameEngine::DisplayGameVideo(eGameVideoType)
{
}

void UGameEngine::InitializeMissionDescription(FString &)
{
}

// --- UI3DL2Listener ---
void UI3DL2Listener::PostEditChange()
{
	// Retail: 30b. Call UObject::PostEditChange via import, then mark dirty flag at this+0x64.
	UObject::PostEditChange();
	*(INT*)((BYTE*)this + 0x64) = 1;
}

// --- UIndexBuffer ---
void UIndexBuffer::Serialize(FArchive &)
{
}

// --- UInputPlanning ---
const TCHAR* UInputPlanning::StaticConfigName()
{
	return NULL;
}

void UInputPlanning::StaticInitInput()
{
}

// --- UInteractionMaster ---
int UInteractionMaster::MasterProcessKeyEvent(EInputKey,EInputAction,float)
{
	return 0;
}

int UInteractionMaster::MasterProcessKeyType(EInputKey)
{
	return 0;
}

void UInteractionMaster::MasterProcessMessage(FString const &,float)
{
}

void UInteractionMaster::MasterProcessPostRender(UCanvas *)
{
}

void UInteractionMaster::MasterProcessPreRender(UCanvas *)
{
}

void UInteractionMaster::MasterProcessTick(float)
{
}

void UInteractionMaster::DisplayCopyright()
{
}

int UInteractionMaster::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

// --- UKMeshProps ---
void UKMeshProps::Serialize(FArchive &)
{
}

void UKMeshProps::Draw(FRenderInterface *,int)
{
}

// --- UKarmaParams ---
void UKarmaParams::PostEditChange()
{
}

// --- ULevelSummary ---
void ULevelSummary::PostLoad()
{
}

// --- ULodMesh ---
void ULodMesh::Serialize(FArchive &)
{
}

int ULodMesh::MemFootprint(int)
{
	return 0;
}

UClass * ULodMesh::MeshGetInstanceClass()
{
	return ULodMeshInstance::StaticClass();
}

// --- UMatAction ---
void UMatAction::PostEditChange()
{
}

void UMatAction::PostLoad()
{
}

void UMatAction::Initialize()
{
}

// --- UMatSubAction ---
int UMatSubAction::Update(float,ASceneManager *)
{
	return 0;
}

void UMatSubAction::PostEditChange()
{
}

void UMatSubAction::PreBeginPreview()
{
}

FString UMatSubAction::GetStatString()
{
	return FString();
}

FString UMatSubAction::GetStatusDesc()
{
	return FString();
}

void UMatSubAction::Initialize()
{
}

int UMatSubAction::IsEnding()
{
	return 0;
}

int UMatSubAction::IsRunning()
{
	return 0;
}

// --- UMaterial ---




void UMaterial::ClearFallbacks()
{
}

// --- UMaterialSwitch ---
void UMaterialSwitch::PostEditChange()
{
}

int UMaterialSwitch::CheckCircularReferences(TArray<UMaterial *> &)
{
	return 0;
}

// --- UMesh ---
void UMesh::Serialize(FArchive &)
{
}

UMeshInstance * UMesh::MeshGetInstance(AActor const *)
{
	return NULL;
}

UClass * UMesh::MeshGetInstanceClass()
{
	return NULL;
}

// --- UMeshAnimation ---
int UMeshAnimation::SequenceMemFootprint(FName)
{
	return 0;
}

void UMeshAnimation::Serialize(FArchive &)
{
}

int UMeshAnimation::MemFootprint()
{
	return 0;
}

void UMeshAnimation::PostLoad()
{
}

void UMeshAnimation::ClearAnimNotifys()
{
}

FMeshAnimSeq * UMeshAnimation::GetAnimSeq(FName)
{
	return NULL;
}

MotionChunk * UMeshAnimation::GetMovement(FName)
{
	return NULL;
}

void UMeshAnimation::InitForDigestion()
{
}

// --- UMeshEmitter ---
int UMeshEmitter::UpdateParticles(float)
{
	return 0;
}

int UMeshEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
}

void UMeshEmitter::PostEditChange()
{
}

void UMeshEmitter::Initialize(int)
{
}

// --- UModel ---
void UModel::Render(FDynamicActor *,FLevelSceneNode *,FRenderInterface *)
{
}

void UModel::AttachProjector(int,FProjectorRenderInfo *,FPlane *)
{
}

// --- UModifier ---







// --- UMotionBlur ---
void UMotionBlur::PostRender(UViewport *,FRenderInterface *)
{
}

void UMotionBlur::PreRender(UViewport *,FRenderInterface *)
{
}

void UMotionBlur::Destroy()
{
}

// --- UNetDriver ---
void UNetDriver::StaticConstructor()
{
}

void UNetDriver::TickFlush()
{
}

// --- UPalette ---
UPalette * UPalette::ReplaceWithExisting()
{
	return NULL;
}


BYTE UPalette::BestMatch(FColor,int)
{
	return 0;
}

void UPalette::FixPalette()
{
}

// --- UParticleEmitter ---
void UParticleEmitter::SpawnIndividualParticles(int)
{
}

void UParticleEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
}

float UParticleEmitter::SpawnParticles(float,float,float)
{
	return 0.0f;
}

int UParticleEmitter::UpdateParticles(float)
{
	return 0;
}

int UParticleEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
}

void UParticleEmitter::Reset()
{
}

void UParticleEmitter::Scale(float)
{
}

void UParticleEmitter::PostEditChange()
{
}

void UParticleEmitter::PostLoad()
{
}

void UParticleEmitter::CleanUp()
{
}

void UParticleEmitter::Destroy()
{
}

void UParticleEmitter::HandleActorForce(AActor *,float)
{
}

void UParticleEmitter::Initialize(int)
{
}

// --- UPlayer ---
void UPlayer::Serialize(FArchive &Ar)
{
	guard(UPlayer::Serialize);
	// Ghidra 0x103F7120 (41 bytes): only calls UObject::Serialize then returns.
	UObject::Serialize(Ar);
	unguard;
}

void UPlayer::Destroy()
{
}

int UPlayer::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

// --- UPolys ---
void UPolys::Serialize(FArchive &)
{
}

// --- UProjectorPrimitive ---
int UProjectorPrimitive::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int UProjectorPrimitive::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}

void UProjectorPrimitive::Destroy()
{
}

FBox UProjectorPrimitive::GetCollisionBoundingBox(AActor const *) const
{
	// Retail: 30b. REP MOVSD 7 DWORDs (28b = FBox) from this+0x470.
	return *(FBox*)((BYTE*)this + 0x470);
}

FVector UProjectorPrimitive::GetEncroachCenter(AActor *)
{
	return FVector(0,0,0);
}

FVector UProjectorPrimitive::GetEncroachExtent(AActor *)
{
	return FVector(0,0,0);
}

// --- UProxyBitmapMaterial ---
void UProxyBitmapMaterial::SetTextureInterface(FBaseTexture * Interface)
{
	TextureInterface = Interface;
}

UBitmapMaterial * UProxyBitmapMaterial::Get(double,UViewport *)
{
	return this;
}

FBaseTexture * UProxyBitmapMaterial::GetRenderInterface()
{
	return TextureInterface;
}

// --- UR6AbstractGameManager ---
void UR6AbstractGameManager::StartJoinServer(FString,FString,int)
{
}

int UR6AbstractGameManager::StartLogInProcedure()
{
	return 0;
}

void UR6AbstractGameManager::StartPreJoinProcedure(int)
{
}

void UR6AbstractGameManager::UnInitialize()
{
}

void UR6AbstractGameManager::SetGSCreateUbiServer(int)
{
}

void UR6AbstractGameManager::LaunchListenSrv(FString,FString)
{
}

void UR6AbstractGameManager::ClientLeaveServer()
{
}

void UR6AbstractGameManager::ConnectionInterrupted(int)
{
}

void UR6AbstractGameManager::GameServiceTick(UConsole *)
{
}

int UR6AbstractGameManager::GetGSCreateUbiServer()
{
	return 0;
}

void UR6AbstractGameManager::InitializeGameService(UConsole *)
{
}

// --- UR6AbstractPlanningInfo ---
void UR6AbstractPlanningInfo::TransferFile(FArchive &)
{
}

void UR6AbstractPlanningInfo::AddPoint(AActor *)
{
}

AActor * UR6AbstractPlanningInfo::GetTeamLeader()
{
	return NULL;
}

// --- UR6FileManager ---
int UR6FileManager::FindFile(FString *)
{
	return 0;
}

void UR6FileManager::GetFileName(int,FString *)
{
}

int UR6FileManager::GetNbFile(FString *,FString *)
{
	return 0;
}

// --- UReachSpec ---
int UReachSpec::findBestReachable(AScout *)
{
	return 0;
}

int UReachSpec::supports(int,int,int,int)
{
	return 0;
}

int UReachSpec::defineFor(ANavigationPoint *,ANavigationPoint *,APawn *)
{
	return 0;
}

FPlane UReachSpec::PathColor()
{
	return FPlane();
}

int UReachSpec::PlaceScout(AScout *)
{
	return 0;
}

int UReachSpec::operator==(UReachSpec const &)
{
	return 0;
}

UReachSpec * UReachSpec::operator+(UReachSpec const &) const
{
	return NULL;
}

int UReachSpec::operator<=(UReachSpec const &)
{
	return 0;
}

int UReachSpec::BotOnlyPath()
{
	return 0;
}

void UReachSpec::Init()
{
	// Retail (36b): zeros all nav fields and clears bit 0 of bForced
	bPruned = 0;
	Distance = 0;
	CollisionRadius = 0;
	CollisionHeight = 0;
	reachFlags = 0;
	MaxLandingVelocity = 0;
	bForced = FALSE;
	Start = NULL;
	End = NULL;
}

// --- URenderDevice ---
void URenderDevice::StartVideo(UCanvas *,int,int,int)
{
}

void URenderDevice::StaticConstructor()
{
}

void URenderDevice::StopVideo(UCanvas *)
{
}

int URenderDevice::OpenVideo(UCanvas *,char *,char *,int)
{
	return 0;
}

void URenderDevice::ChangeDrawingSurface(ER6SwitchSurface,int)
{
}

void URenderDevice::CloseVideo(UCanvas *)
{
}

void URenderDevice::DisplayVideo(UCanvas *,void *,int)
{
}

void URenderDevice::Draw3DLine(FVector,FVector,FColor,UTexture *,float,float,float,float)
{
}

void URenderDevice::GetAvailableResolutions(TArray<FResolutionInfo> &)
{
}

DWORD URenderDevice::GetAvailableVideoMemory()
{
	return 0;
}

void URenderDevice::HandleFullScreenEffects(int,int)
{
}

// --- UShader ---



// --- UShadowBitmapMaterial ---
void UShadowBitmapMaterial::Destroy()
{
}

UBitmapMaterial * UShadowBitmapMaterial::Get(double,UViewport *)
{
	return NULL;
}

FBaseTexture * UShadowBitmapMaterial::GetRenderInterface()
{
	// Retail: 8B 81 9C 00 00 00 C3 = return *(this+0x9C) — render interface pointer in shadow bitmap
	return *(FBaseTexture**)((BYTE*)this + 0x9C);
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
}

// --- USkeletalMeshInstance ---
int USkeletalMeshInstance::WasSkeletonUpdated()
{
	return 0;
}

void USkeletalMeshInstance::MeshBuildBounds()
{
}

FMatrix USkeletalMeshInstance::MeshToWorld()
{
	return FMatrix();
}

// --- USkinVertexBuffer ---
void USkinVertexBuffer::Serialize(FArchive &)
{
}

// --- USound ---
void USound::PostLoad()
{
}

void USound::PS2Convert()
{
}

USound::USound(const TCHAR*,int)
{
}

// --- USoundGen ---
void USoundGen::Serialize(FArchive &)
{
}

// --- USparkEmitter ---
void USparkEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
}

int USparkEmitter::UpdateParticles(float)
{
	return 0;
}

int USparkEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
}

void USparkEmitter::PostEditChange()
{
	// Retail: 28b. Call parent, then call vtable[26]() and vtable[25](this+0x3C).
	// vtable[26]=Reset, vtable[25]=Initialize(MaxParticles).
	UParticleEmitter::PostEditChange();
	void** vtbl = *(void***)this;
	typedef void(__thiscall* NoArgFn)(USparkEmitter*);
	typedef void(__thiscall* IntFn)(USparkEmitter*, INT);
	((NoArgFn)vtbl[26])(this);
	((IntFn)vtbl[25])(this, *(INT*)((BYTE*)this + 0x3C));
}

void USparkEmitter::CleanUp()
{
}

void USparkEmitter::Initialize(int)
{
}

// --- USpriteEmitter ---
int USpriteEmitter::UpdateParticles(float)
{
	return 0;
}

int USpriteEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
}

void USpriteEmitter::PostEditChange()
{
	// Retail: 28b. Same as USparkEmitter::PostEditChange — call parent,
	// then vtable[26]() (Reset) and vtable[25](this+0x3C) (Initialize).
	UParticleEmitter::PostEditChange();
	void** vtbl = *(void***)this;
	typedef void(__thiscall* NoArgFn)(USpriteEmitter*);
	typedef void(__thiscall* IntFn)(USpriteEmitter*, INT);
	((NoArgFn)vtbl[26])(this);
	((IntFn)vtbl[25])(this, *(INT*)((BYTE*)this + 0x3C));
}

void USpriteEmitter::CleanUp()
{
}

int USpriteEmitter::FillVertexBuffer(FSpriteParticleVertex *,FLevelSceneNode *)
{
	return 0;
}

void USpriteEmitter::Initialize(int)
{
}

// --- UStaticMesh ---
void UStaticMesh::StaticConstructor()
{
}

void UStaticMesh::PostEditChange()
{
}

void UStaticMesh::PostLoad()
{
}

// --- UStaticMeshInstance ---
void UStaticMeshInstance::Serialize(FArchive &)
{
}

void UStaticMeshInstance::AttachProjectorClipped(AActor *,AProjector *)
{
}

void UStaticMeshInstance::DetachProjectorClipped(AProjector *)
{
}

// --- USubActionCameraEffect ---
int USubActionCameraEffect::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionCameraEffect::GetStatString()
{
	return FString();
}

// --- USubActionCameraShake ---
int USubActionCameraShake::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionCameraShake::GetStatString()
{
	return FString();
}

// --- USubActionFOV ---
int USubActionFOV::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionFOV::GetStatString()
{
	return FString();
}

// --- USubActionFade ---
int USubActionFade::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionFade::GetStatString()
{
	return FString();
}

// --- USubActionGameSpeed ---
int USubActionGameSpeed::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionGameSpeed::GetStatString()
{
	return FString();
}

// --- USubActionOrientation ---
int USubActionOrientation::Update(float,ASceneManager *)
{
	return 0;
}

void USubActionOrientation::PostLoad()
{
}

FString USubActionOrientation::GetStatString()
{
	return FString();
}

int USubActionOrientation::IsRunning()
{
	return 0;
}

// --- USubActionSceneSpeed ---
int USubActionSceneSpeed::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionSceneSpeed::GetStatString()
{
	return FString();
}

// --- USubActionTrigger ---
int USubActionTrigger::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionTrigger::GetStatString()
{
	return FString();
}

// --- UTerrainBrush ---
void UTerrainBrush::MouseButtonDown(UViewport *)
{
}

void UTerrainBrush::MouseButtonUp(UViewport *)
{
}

void UTerrainBrush::MouseMove(float,float)
{
}

UTerrainBrush::UTerrainBrush(UTerrainBrush const &Other)
{
	// Ghidra 0x15690: vtable set by compiler; FString placement new at +4 and +10; 19 DWORDs at +1C..+64
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrush::UTerrainBrush()
{
	// Initialize 2 FStrings to empty
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrush::~UTerrainBrush()
{
	// Ghidra 0x165170: ~FString at +10 then +4 (reverse order)
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrush& UTerrainBrush::operator=(const UTerrainBrush& Other)
{
	// Ghidra 0x15770: skip vtable +0; FString@+4, FString@+0x10, 19 DWORDs@+0x1C..+0x64
	*(FString*)((BYTE*)this + 0x04) = *(const FString*)((const BYTE*)&Other + 0x04);
	*(FString*)((BYTE*)this + 0x10) = *(const FString*)((const BYTE*)&Other + 0x10);
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C);
	return *this;
}

int UTerrainBrush::BeginPainting(UTexture * *,ATerrainInfo * *)
{
	return 0;
}

void UTerrainBrush::EndPainting(UTexture *,ATerrainInfo *)
{
}

void UTerrainBrush::Execute(int)
{
}

FBox UTerrainBrush::GetRect()
{
	return FBox();
}

// --- UTerrainBrushColor ---
UTerrainBrushColor::UTerrainBrushColor(UTerrainBrushColor const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushColor::UTerrainBrushColor()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushColor::~UTerrainBrushColor()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushColor& UTerrainBrushColor::operator=(const UTerrainBrushColor& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator= (shared by all 13 subclasses)
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushColor::Execute(int)
{
}

// --- UTerrainBrushEdgeTurn ---
UTerrainBrushEdgeTurn::UTerrainBrushEdgeTurn(UTerrainBrushEdgeTurn const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushEdgeTurn::UTerrainBrushEdgeTurn()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushEdgeTurn::~UTerrainBrushEdgeTurn()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushEdgeTurn& UTerrainBrushEdgeTurn::operator=(const UTerrainBrushEdgeTurn& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushEdgeTurn::Execute(int)
{
}

FBox UTerrainBrushEdgeTurn::GetRect()
{
	return FBox();
}

// --- UTerrainBrushFlatten ---
UTerrainBrushFlatten::UTerrainBrushFlatten(UTerrainBrushFlatten const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushFlatten::UTerrainBrushFlatten()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushFlatten::~UTerrainBrushFlatten()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushFlatten& UTerrainBrushFlatten::operator=(const UTerrainBrushFlatten& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushFlatten::Execute(int)
{
}

// --- UTerrainBrushNoise ---
UTerrainBrushNoise::UTerrainBrushNoise(UTerrainBrushNoise const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushNoise::UTerrainBrushNoise()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushNoise::~UTerrainBrushNoise()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushNoise& UTerrainBrushNoise::operator=(const UTerrainBrushNoise& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushNoise::Execute(int)
{
}

// --- UTerrainBrushPaint ---
UTerrainBrushPaint::UTerrainBrushPaint(UTerrainBrushPaint const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushPaint::UTerrainBrushPaint()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushPaint::~UTerrainBrushPaint()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushPaint& UTerrainBrushPaint::operator=(const UTerrainBrushPaint& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushPaint::Execute(int)
{
}

// --- UTerrainBrushPlanningPaint ---
void UTerrainBrushPlanningPaint::MouseButtonDown(UViewport *)
{
}

UTerrainBrushPlanningPaint::UTerrainBrushPlanningPaint(UTerrainBrushPlanningPaint const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushPlanningPaint::UTerrainBrushPlanningPaint()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushPlanningPaint::~UTerrainBrushPlanningPaint()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushPlanningPaint& UTerrainBrushPlanningPaint::operator=(const UTerrainBrushPlanningPaint& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushPlanningPaint::Execute(int)
{
}

// --- UTerrainBrushSelect ---
void UTerrainBrushSelect::MouseButtonDown(UViewport *)
{
}

void UTerrainBrushSelect::MouseMove(float,float)
{
}

UTerrainBrushSelect::UTerrainBrushSelect(UTerrainBrushSelect const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushSelect::UTerrainBrushSelect()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushSelect::~UTerrainBrushSelect()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushSelect& UTerrainBrushSelect::operator=(const UTerrainBrushSelect& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushSelect::Execute(int)
{
}

FBox UTerrainBrushSelect::GetRect()
{
	return FBox();
}

// --- UTerrainBrushSmooth ---
UTerrainBrushSmooth::UTerrainBrushSmooth(UTerrainBrushSmooth const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushSmooth::UTerrainBrushSmooth()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushSmooth::~UTerrainBrushSmooth()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushSmooth& UTerrainBrushSmooth::operator=(const UTerrainBrushSmooth& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushSmooth::Execute(int)
{
}

// --- UTerrainBrushTexPan ---
void UTerrainBrushTexPan::MouseMove(float,float)
{
}

UTerrainBrushTexPan::UTerrainBrushTexPan(UTerrainBrushTexPan const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushTexPan::UTerrainBrushTexPan()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushTexPan::~UTerrainBrushTexPan()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushTexPan& UTerrainBrushTexPan::operator=(const UTerrainBrushTexPan& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

// --- UTerrainBrushTexRotate ---
void UTerrainBrushTexRotate::MouseMove(float,float)
{
}

UTerrainBrushTexRotate::UTerrainBrushTexRotate(UTerrainBrushTexRotate const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushTexRotate::UTerrainBrushTexRotate()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushTexRotate::~UTerrainBrushTexRotate()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushTexRotate& UTerrainBrushTexRotate::operator=(const UTerrainBrushTexRotate& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

// --- UTerrainBrushTexScale ---
void UTerrainBrushTexScale::MouseMove(float,float)
{
}

UTerrainBrushTexScale::UTerrainBrushTexScale(UTerrainBrushTexScale const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushTexScale::UTerrainBrushTexScale()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushTexScale::~UTerrainBrushTexScale()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushTexScale& UTerrainBrushTexScale::operator=(const UTerrainBrushTexScale& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

// --- UTerrainBrushVertexEdit ---
UTerrainBrushVertexEdit::UTerrainBrushVertexEdit(UTerrainBrushVertexEdit const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushVertexEdit::UTerrainBrushVertexEdit()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushVertexEdit::~UTerrainBrushVertexEdit()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushVertexEdit& UTerrainBrushVertexEdit::operator=(const UTerrainBrushVertexEdit& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

// --- UTerrainBrushVisibility ---
UTerrainBrushVisibility::UTerrainBrushVisibility(UTerrainBrushVisibility const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushVisibility::UTerrainBrushVisibility()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushVisibility::~UTerrainBrushVisibility()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushVisibility& UTerrainBrushVisibility::operator=(const UTerrainBrushVisibility& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushVisibility::Execute(int)
{
}

FBox UTerrainBrushVisibility::GetRect()
{
	return FBox();
}

// --- UTerrainMaterial ---
UMaterial * UTerrainMaterial::CheckFallback()
{
	return this;
}

int UTerrainMaterial::HasFallback()
{
	return 0;
}

// --- UTexCoordMaterial ---
INT UTexCoordMaterial::MaterialUSize()
{
	return Material ? Material->MaterialUSize() : 0;
}

INT UTexCoordMaterial::MaterialVSize()
{
	return Material ? Material->MaterialVSize() : 0;
}

// --- UTexCoordSource ---
void UTexCoordSource::PostEditChange()
{
	// Retail: 25b. Call parent, then clamp TexCoordCount at this+0x64 to 0 if negative.
	// Also zeroes mode byte at this+0x5C when clamping.
	UModifier::PostEditChange();
	INT& coordCount = *(INT*)((BYTE*)this + 0x64);
	if (coordCount < 0)
	{
		coordCount = 0;
		*(BYTE*)((BYTE*)this + 0x5C) = 0;
	}
}

// --- UTexEnvMap ---
FMatrix * UTexEnvMap::GetMatrix(float)
{
	// Retail: 21b. When env mapping mode (this+0x64) == 1: set coord-generation
	// mode byte at this+0x5C = 0x0B (GL_REFLECTION_MAP). Returns NULL always.
	BYTE envMode = *(BYTE*)((BYTE*)this + 0x64);
	if (envMode == 1)
		*(BYTE*)((BYTE*)this + 0x5C) = 0x0B;
	return NULL;
}

// --- UTexMatrix ---
FMatrix * UTexMatrix::GetMatrix(float)
{
	return &Matrix;
}

// --- UTexModifier ---
void UTexModifier::SetValidated(int x)
{
	// Delegate to Material via virtual call if present.
	// Retail: 8B 41 58 85 C0 74 07 8B C8 8B 01 FF 60 6C C2 04 00
	if (Material)
		Material->SetValidated(x);
}

BYTE UTexModifier::RequiredUVStreams()
{
	// Retail: when TexCoordSource <= 7 and Material present: (1<<src)|Material->RequiredUVStreams()
	// When TexCoordSource <= 7 and no Material: (1<<src)|1
	if (TexCoordSource <= 7)
	{
		if (Material)
		{
			BYTE matResult = Material->RequiredUVStreams();
			return (BYTE)((1 << TexCoordSource) | matResult);
		}
		return 0; // Retail: JZ to RET with EAX=0 when Material is NULL
	}
	// TexCoordSource > 7 (world/camera coords etc.): retail cross-function-jump (divergence)
	if (Material)
		return Material->RequiredUVStreams();
	return 1;
}

int UTexModifier::MaterialUSize()
{
	// Retail: 17b. Delegates to Material->MaterialUSize(); returns 0 if null.
	if (!Material) return 0;
	return Material->MaterialUSize();
}

int UTexModifier::MaterialVSize()
{
	// Retail: 17b. Delegates to Material->MaterialVSize(); returns 0 if null.
	if (!Material) return 0;
	return Material->MaterialVSize();
}

FMatrix * UTexModifier::GetMatrix(float)
{
	return NULL;
}

int UTexModifier::GetValidated()
{
	// Retail: if Material -> tail-call Material->GetValidated(); else return 1
	// 8B 41 58 85 C0 74 07 8B C8 8B 01 FF 60 68 B8 01 00 00 00 C3
	if (Material)
		return Material->GetValidated();
	return 1;
}

// --- UTexOscillator ---
FMatrix * UTexOscillator::GetMatrix(float)
{
	return NULL;
}

// --- UTexPanner ---
FMatrix * UTexPanner::GetMatrix(float)
{
	return NULL;
}

// --- UTexRotator ---
void UTexRotator::PostLoad()
{
	// Retail: 28b. Call parent PostLoad (imports UObject::PostLoad from Core.dll),
	// then convert legacy bit 0 of this+0x68: if set, clear it and set this+0x64=1.
	Super::PostLoad();
	DWORD& flags = *(DWORD*)((BYTE*)this + 0x68);
	if (flags & 1)
	{
		flags &= ~1u;
		*(BYTE*)((BYTE*)this + 0x64) = 1;
	}
}

FMatrix * UTexRotator::GetMatrix(float)
{
	return NULL;
}

// --- UTexScaler ---
FMatrix * UTexScaler::GetMatrix(float)
{
	return NULL;
}

// --- UTexture ---


void UTexture::Prime()
{
	// Retail: 49b. Loops while PrimeCurrent < PrimeCount, calling vtable[42]
	// (prime-one-mip callback) each iteration.
	// PrimeCount BYTE at this+0xAC, PrimeCurrent BYTE at this+0xAD.
	while (PrimeCurrent < PrimeCount)
	{
		++PrimeCurrent;
		void** vtbl = *(void***)this;
		typedef void (__thiscall *PrimeFn)(UTexture*);
		((PrimeFn)vtbl[42])(this);
	}
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
}

FBox UVertMesh::GetRenderBoundingBox(AActor const *)
{
	return FBox();
}

FSphere UVertMesh::GetRenderBoundingSphere(AActor const *)
{
	return FSphere();
}

// --- UVertMeshInstance ---
void UVertMeshInstance::MeshBuildBounds()
{
}

FMatrix UVertMeshInstance::MeshToWorld()
{
	return FMatrix();
}

// --- UViewport ---
void UViewport::PushHit(HHitProxy const &,int)
{
}

void UViewport::RefreshAll()
{
}

void UViewport::LockOnActor(AActor *)
{
}

int UViewport::MultiShot()
{
	return 0;
}

void UViewport::PopHit(int)
{
}

void UViewport::ChangeInputSet(BYTE bReset)
{
	// Retail: 23b. If bReset==0, restores input set ptr: copy this+0x84 to this+0x80.
	if (!bReset)
		*(DWORD*)((BYTE*)this + 0x80) = *(DWORD*)((BYTE*)this + 0x84);
}

void UViewport::ExecProfile(const TCHAR*,int,FOutputDevice &)
{
}

void UViewport::ExecuteHits(FHitCause const &,BYTE*,int,TCHAR*,FColor *,AActor * *)
{
}

int UViewport::IsDepthComplexity()
{
	return 0;
}

int UViewport::IsEditing()
{
	return 0;
}

int UViewport::IsLit()
{
	return 0;
}

int UViewport::IsTopView()
{
	return 0;
}


struct FUV2Data;
struct FProjectorRelativeRenderInfo;
struct HHitProxy;
struct _KarmaGlobals;
struct _McdGeometry;
struct McdGeomMan;
struct _KarmaTriListData;


/*-----------------------------------------------------------------------------
  Data definitions
-----------------------------------------------------------------------------*/

UEngine * g_pEngine = NULL;

int AVIRecording = 0;

FString FURL::DefaultHost;

FString FURL::DefaultLocalMap;

FString FURL::DefaultMap;

FString FURL::DefaultMapExt;

FString FURL::DefaultName;

FString FURL::DefaultPortal;

FString FURL::DefaultProtocol;

FString FURL::DefaultProtocolDescription;

FString FURL::DefaultSaveExt;

UAudioSubsystem * USound::Audio = NULL;

UClient * UTexture::__Client = NULL;

float * USkeletalMeshInstance::m_fCylindersRadius = NULL;

// Hash-mixing permutation tables — 0x4000 entries each.
// Must be declared as arrays (not pointers) to match the retail layout
// where &HashX[i] is meaningful without heap allocation.
INT FCollisionHash::HashX[0x4000];
INT FCollisionHash::HashY[0x4000];
INT FCollisionHash::HashZ[0x4000];
INT FCollisionHash::CollisionTag = 0;
INT FCollisionHash::Inited = 0;

// Per-frame performance counters reset by FCollisionHash::Tick.
// Retail addresses: GHashActorCount @0x1064ff28, GHashLinkCellCount @0x1064ff2c, GHashExtraCount @0x1064ff34
INT GHashActorCount  = 0;   // DAT_1064ff28 — incremented once per AddActor call
INT GHashLinkCellCount = 0; // DAT_1064ff2c — incremented per hash-cell link inserted
INT GHashExtraCount  = 0;   // DAT_1064ff34 — additional insertion counter

int FURL::DefaultPort = 0;

_KarmaGlobals * KGData = NULL;

static INT bGameShutDown = 0;


/*-----------------------------------------------------------------------------
  Implementations
-----------------------------------------------------------------------------*/

// Forward declarations for element serializers needed by TArray<T> template
// instantiation in stream/buffer serializers below.
FArchive & operator<<(FArchive & Ar, FBspVertex & V);
FArchive & operator<<(FArchive & Ar, FStaticMeshVertex & V);
FArchive & operator<<(FArchive & Ar, FStaticMeshUV & V);
FArchive & operator<<(FArchive & Ar, FTerrainVertex & V);

// ??6@YAAAVFArchive@@AAV0@AAVFAnimMeshVertexStream@@@Z
// FUN_10323030 = TArray<0x20-element>::Serialize. Each element via FUN_10446ec0 = 8×ByteOrderSerialize(4).
// Layout (after vtable): Pad[4] TArray<elem>  Pad[0x18] Revision
FArchive & operator<<(FArchive & Ar, FAnimMeshVertexStream & V) {
	// TArray at Pad[4] (obj+8), element size 0x20. Manual serialization.
	FArray& Arr = *(FArray*)&V.Pad[4];
	if (Ar.IsLoading()) {
		FCompactIndex count;
		Ar << count;
		INT n = *(INT*)&count;
		Arr.Empty(0x20, n);
		for (INT i = 0; i < n; i++) {
			INT idx = Arr.Add(1, 0x20);
			BYTE* elem = (BYTE*)Arr.GetData() + idx * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	} else {
		Ar << *(FCompactIndex*)&V.Pad[8];  // ArrayNum as FCompactIndex
		for (INT i = 0; i < Arr.Num(); i++) {
			BYTE* elem = (BYTE*)Arr.GetData() + i * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	}
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);  // Revision at Pad[0x18] = obj+0x1C
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspNode@@@Z
// Decoded from Ghidra Engine @ 0xcf6f0. Complex with ZoneMask (FUN_103cc610),
// sub-struct pairs (FUN_103cba20), version-gated multi-branch INT serialization.
// All internal functions fully decoded from _unnamed.cpp.
FArchive & operator<<(FArchive & Ar, FBspNode & V) {
	BYTE* P = (BYTE*)&V;

	// FPlane at offset 0x00 (X, Y, Z, W)
	Ar.ByteOrderSerialize(P + 0x00, 4);
	Ar.ByteOrderSerialize(P + 0x04, 4);
	Ar.ByteOrderSerialize(P + 0x08, 4);
	Ar.ByteOrderSerialize(P + 0x0C, 4);

	// ZoneMask at offset 0x10: 256-bit bitmask (8 DWORDs = 32 bytes)
	// FUN_103cc610: Ravenshield format (LicenseeVer >= 9)
	if (Ar.LicenseeVer() < 9) {
		// Legacy: 8-byte QWORD (pre-Ravenshield). Read and discard.
		BYTE temp[8];
		Ar.ByteOrderSerialize(temp, 8);
	} else {
		if (Ar.IsLoading()) {
			appMemzero(P + 0x10, 32);
		}
		INT NumBytes = 0x20;  // 32
		Ar.ByteOrderSerialize((BYTE*)&NumBytes, 4);
		for (INT i = 0; i < NumBytes; i++) {
			if (!Ar.IsLoading()) {
				// Saving: pack 8 bits from DWORD array into 1 byte
				BYTE packed = 0;
				for (INT bit = 0; bit < 8; bit++) {
					INT bitIndex = bit + i * 8;
					INT dwordIndex = bitIndex >> 5;
					INT bitOffset = bitIndex & 0x1F;
					if (((DWORD*)(P + 0x10))[dwordIndex] & (1 << bitOffset))
						packed |= (BYTE)(1 << (bit & 0x1F));
				}
				Ar.Serialize(&packed, 1);
			} else {
				// Loading: read 1 byte, unpack to DWORD bits
				BYTE packed;
				Ar.Serialize(&packed, 1);
				if ((DWORD)i < 0x20) {
					for (INT bit = 0; bit < 8; bit++) {
						if (packed & (1 << (bit & 0x1F))) {
							INT bitIndex = bit + i * 8;
							INT dwordIndex = bitIndex >> 5;
							INT bitOffset = bitIndex & 0x1F;
							((DWORD*)(P + 0x10))[dwordIndex] |= (1 << bitOffset);
						}
					}
				}
			}
		}
	}

	// 1 byte at offset 0x6F (flags byte)
	Ar.Serialize(P + 0x6F, 1);

	// FCompactIndex fields
	Ar << *(FCompactIndex*)(P + 0x30);
	Ar << *(FCompactIndex*)(P + 0x34);
	Ar << *(FCompactIndex*)(P + 0x38);
	Ar << *(FCompactIndex*)(P + 0x3C);
	Ar << *(FCompactIndex*)(P + 0x40);
	Ar << *(FCompactIndex*)(P + 0x64);
	Ar << *(FCompactIndex*)(P + 0x68);

	// Sub-structures at +0x44 and +0x54 (FUN_103cba20: version-gated 3 or 4 DWORDs)
	if (Ar.Ver() > 0x45) {
		// Sub-struct at 0x44
		Ar.ByteOrderSerialize(P + 0x44, 4);
		Ar.ByteOrderSerialize(P + 0x48, 4);
		Ar.ByteOrderSerialize(P + 0x4C, 4);
		if (Ar.Ver() >= 0x3E)
			Ar.ByteOrderSerialize(P + 0x50, 4);
		// Sub-struct at 0x54
		Ar.ByteOrderSerialize(P + 0x54, 4);
		Ar.ByteOrderSerialize(P + 0x58, 4);
		Ar.ByteOrderSerialize(P + 0x5C, 4);
		if (Ar.Ver() >= 0x3E)
			Ar.ByteOrderSerialize(P + 0x60, 4);
	}

	// 3 single bytes at 0x6C, 0x6D, 0x6E
	Ar.Serialize(P + 0x6C, 1);
	Ar.Serialize(P + 0x6D, 1);
	Ar.Serialize(P + 0x6E, 1);

	// 2 INTs at 0x70 and 0x74
	Ar.ByteOrderSerialize(P + 0x70, 4);
	Ar.ByteOrderSerialize(P + 0x74, 4);

	// Version-gated block for offsets 0x78, 0x7C, 0x80 (3 INTs)
	if (Ar.Ver() < 0x5C) {
		*(INT*)(P + 0x78) = -1;
		*(INT*)(P + 0x7C) = -1;
		*(INT*)(P + 0x80) = -1;
	} else if (Ar.Ver() > 100) {
		// Ver > 0x64: real serialization
		Ar.ByteOrderSerialize(P + 0x78, 4);
		Ar.ByteOrderSerialize(P + 0x7C, 4);
		Ar.ByteOrderSerialize(P + 0x80, 4);
		if (Ar.IsLoading() && Ar.Ver() < 0x6C)
			*(INT*)(P + 0x80) = -1;
	} else {
		// 0x5C <= Ver <= 100: read temp values into locals, discard
		INT temp1 = -1, temp2 = -1;
		if (Ar.Ver() < 0x5D) {
			Ar.ByteOrderSerialize((BYTE*)&temp1, 4);
		} else {
			Ar.ByteOrderSerialize((BYTE*)&temp1, 4);
			Ar.ByteOrderSerialize((BYTE*)&temp2, 4);
		}
		*(INT*)(P + 0x78) = -1;
		*(INT*)(P + 0x7C) = -1;
		*(INT*)(P + 0x80) = -1;
	}

	// Loading: mask top bits of flags byte at 0x6F
	if (Ar.IsLoading())
		P[0x6F] &= 0x1F;

	// FUN_103cf3d0 at offset 0x84 only in counting mode (neither loading nor saving)
	// — skipped as it has no effect on actual serialization.

	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspSection@@@Z
// Decoded from Ghidra Engine @ 0x27ad0. Uses TArray<FBspVertex> (FUN_10322590),
// UObject* at +0x20, and version-gated INT override.
// Layout: [0x00] vtable  [0x04] TArray<FBspVertex>  [0x18] INT  [0x1C] INT
//         [0x20] UObject*  [0x24] INT  [0x28] INT (ver-gated default -1)
FArchive & operator<<(FArchive & Ar, FBspSection & V) {
	Ar << *(TArray<FBspVertex>*)&V.Pad[4];       // TArray<FBspVertex> at obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);      // INT at obj+0x18
	Ar << *(UObject**)&V.Pad[0x20];               // UObject* at obj+0x20
	Ar.ByteOrderSerialize(&V.Pad[0x1C], 4);      // INT at obj+0x1C
	Ar.ByteOrderSerialize(&V.Pad[0x24], 4);      // INT at obj+0x24
	Ar.ByteOrderSerialize(&V.Pad[0x28], 4);      // INT at obj+0x28
	if (Ar.Ver() < 0x6B) {
		if (Ar.IsLoading()) {
			*(INT*)&V.Pad[0x28] = -1;
		}
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspSurf@@@Z
// Decoded from Ghidra Engine @ 0xcbf50. Uses vtable+0x18 (UObject*), FCompactIndex,
// ByteOrderSerialize, and Serialize. No FUN_xxx dependencies.
FArchive & operator<<(FArchive & Ar, FBspSurf & V) {
	Ar << V.Texture;
	Ar.ByteOrderSerialize((BYTE*)&V.PolyFlags, 4);
	Ar << *(FCompactIndex*)&V.pBase;
	Ar << *(FCompactIndex*)&V.vNormal;
	Ar << *(FCompactIndex*)&V.vTextureU;
	Ar << *(FCompactIndex*)&V.vTextureV;
	if (Ar.Ver() < 0x65) {
		FCompactIndex temp;
		*(INT*)&temp = -1;
		Ar << temp;
	}
	Ar << *(FCompactIndex*)&V.iLightMap;
	if (Ar.Ver() < 0x4e) {
		_WORD temp1 = 0, temp2 = 0;
		Ar.ByteOrderSerialize((BYTE*)&temp1, 2);
		Ar.ByteOrderSerialize((BYTE*)&temp2, 2);
	}
	Ar << V.Actor;
	if (Ar.Ver() > 0x56) {
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.X, 4);
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.Y, 4);
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.Z, 4);
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.W, 4);
	}
	if (Ar.LicenseeVer() > 3) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x00], 4);       // offset 0x48
		Ar.Serialize(&V._RvsExtra[0x08], 1);                 // offset 0x50
		Ar.Serialize(&V._RvsExtra[0x0E], 1);                 // offset 0x56
		Ar.Serialize(&V._RvsExtra[0x0D], 1);                 // offset 0x55
		Ar.Serialize(&V._RvsExtra[0x0C], 1);                 // offset 0x54
		Ar.Serialize(&V._RvsExtra[0x0F], 1);                 // offset 0x57
	}
	if (Ar.LicenseeVer() > 4) {
		Ar.Serialize(&V._RvsExtra[0x10], 1);                 // offset 0x58
	}
	if (Ar.LicenseeVer() > 6) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x04], 4);       // offset 0x4C
	}
	if (Ar.Ver() > 0x69) {
		Ar.ByteOrderSerialize((BYTE*)&V.LightMapScale, 4);
	} else if (Ar.IsLoading()) {
		V.LightMapScale = 32.0f;
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspVertexStream@@@Z
// FUN_10322590 = TArray<FBspVertex>::Serialize (elem_size 0x28)
// Layout (after vtable): Pad[0] TArray<FBspVertex>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FBspVertexStream & V) {
	Ar << *(TArray<FBspVertex>*)V.Pad;            // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFLightMap@@@Z
// Ghidra @ 0x3c730: 7x FCompactIndex at Pad[8..0x20]; 9x DWORD at Pad[0x68..0x88];
// FUN_10301470 (FName?), FUN_1033a9a0, version checks 0x6a/0x6b/0x6d/0x6e.
// Needs FTexture base size to correctly interpret Pad offsets.
FArchive & operator<<(FArchive & Ar, FLightMap & p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@AAVFLightMapTexture@@@Z
// Ghidra @ 0x27a00: vtable[6] on Pad[4..8], FUN_103218c0, BOS at Pad[0x60]+8, Pad[0x68]+4;
// if Ver()>0x73: recurse into FStaticLightMapTexture at Pad[0x14].
FArchive & operator<<(FArchive & Ar, FLightMapTexture & p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@AAVFPoly@@@Z
FArchive & operator<<(FArchive & Ar, FPoly & V) {
	// NumVertices first (compact index)
	Ar << *(FCompactIndex*)&V.NumVertices;
	// Base(3) + Normal(3) + TextureU(3) + TextureV(3) = 12 floats
	for (INT i = 0; i < 12; i++)
		Ar.ByteOrderSerialize((BYTE*)&V.Base + i * 4, 4);
	// Variable-length vertex array
	for (INT i = 0; i < V.NumVertices; i++) {
		Ar.ByteOrderSerialize(&V.Vertex[i].X, 4);
		Ar.ByteOrderSerialize(&V.Vertex[i].Y, 4);
		Ar.ByteOrderSerialize(&V.Vertex[i].Z, 4);
	}
	// PolyFlags
	Ar.ByteOrderSerialize(&V.PolyFlags, 4);
	// Object references and name
	Ar << *(UObject**)&V.Actor;
	Ar << *(UObject**)&V.Material;
	Ar << V.ItemName;
	// Link indices
	Ar << *(FCompactIndex*)&V.iLink;
	Ar << *(FCompactIndex*)&V.iBrushPoly;
	// Legacy Ver < 0x4E path omitted (pre-Ravenshield format)
	// Ravenshield extensions (LicenseeVer > 5)
	if (Ar.LicenseeVer() > 5) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x38], 4);
		Ar.Serialize(&V._RvsExtra[0x40], 1);
		Ar.Serialize(&V._RvsExtra[0x46], 1);
		Ar.Serialize(&V._RvsExtra[0x45], 1);
		Ar.Serialize(&V._RvsExtra[0x44], 1);
		Ar.Serialize(&V._RvsExtra[0x47], 1);
		Ar.Serialize(&V._RvsExtra[0x48], 1);
	}
	if (Ar.LicenseeVer() > 6) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x3C], 4);
	}
	if (Ar.Ver() > 0x69) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x34], 4);
	} else if (Ar.IsLoading()) {
		*(FLOAT*)&V._RvsExtra[0x34] = 32.0f; // Default LightMapScale
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFRaw32BitIndexBuffer@@@Z
// FUN_1037fbd0 = TArray<DWORD>::Serialize (elem_size 4, ByteOrderSerialize per element)
// Layout (after vtable): Pad[0] TArray<DWORD>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FRaw32BitIndexBuffer & V) {
	Ar << *(TArray<DWORD>*)V.Pad;                 // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFRawColorStream@@@Z
// FUN_104170d0 = Custom TArray<FColor>::Serialize with BGRA byte order.
// Original serializes per-element bytes in order: [2]=B, [1]=G, [0]=R, [3]=A.
// Layout (after vtable): Pad[0] TArray<FColor>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FRawColorStream & V) {
	TArray<FColor>& Colors = *(TArray<FColor>*)V.Pad;
	Colors.CountBytes(Ar);
	if (Ar.IsLoading()) {
		FCompactIndex count;
		Ar << count;
		INT n = *(INT*)&count;
		Colors.Empty(n);
		for (INT i = 0; i < n; i++) {
			INT idx = Colors.Add();
			BYTE* elem = (BYTE*)&Colors(idx);
			Ar.Serialize(elem + 2, 1);  // B
			Ar.Serialize(elem + 1, 1);  // G
			Ar.Serialize(elem + 0, 1);  // R
			Ar.Serialize(elem + 3, 1);  // A
		}
	} else {
		Ar << *(FCompactIndex*)&V.Pad[4];  // ArrayNum as FCompactIndex
		for (INT i = 0; i < Colors.Num(); i++) {
			BYTE* elem = (BYTE*)&Colors(i);
			Ar.Serialize(elem + 2, 1);  // B
			Ar.Serialize(elem + 1, 1);  // G
			Ar.Serialize(elem + 0, 1);  // R
			Ar.Serialize(elem + 3, 1);  // A
		}
	}
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);  // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFRawIndexBuffer@@@Z
// FUN_1031e600 = TArray<_WORD>::Serialize (elem_size 2, ByteOrderSerialize per element)
// Layout (after vtable): Pad[0] TArray<_WORD>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FRawIndexBuffer & V) {
	Ar << *(TArray<_WORD>*)V.Pad;                 // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFSkinVertexStream@@@Z
// Decoded from Ghidra Engine @ 0x2b750. Conditionally serializes two UObject* refs
// (only when !IsPersistent), then 3 INTs, then TArray<0x20-elem> via FUN_10323030.
// Layout (after vtable): Pad[0] UObject*  Pad[4] UObject*  Pad[0x10] INT
//   Pad[0x14] INT  Pad[0x18] INT  Pad[0x1C] TArray<0x20-elem>
FArchive & operator<<(FArchive & Ar, FSkinVertexStream & V) {
	if (!Ar.IsPersistent()) {
		Ar << *(UObject**)&V.Pad[0x00];   // UObject* at Pad[0] = obj+0x04
		Ar << *(UObject**)&V.Pad[0x04];   // UObject* at Pad[4] = obj+0x08
	}
	Ar.ByteOrderSerialize(&V.Pad[0x10], 4);  // INT at Pad[0x10] = obj+0x14
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);  // INT at Pad[0x14] = obj+0x18
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);  // INT at Pad[0x18] = obj+0x1C
	// TArray<0x20-elem> at Pad[0x1C] (obj+0x20), serialized same as FAnimMeshVertexStream
	FArray& Arr = *(FArray*)&V.Pad[0x1C];
	Arr.CountBytes(Ar, 0x20);
	if (Ar.IsLoading()) {
		FCompactIndex count;
		Ar << count;
		INT n = *(INT*)&count;
		Arr.Empty(0x20, n);
		for (INT i = 0; i < n; i++) {
			INT idx = Arr.Add(1, 0x20);
			BYTE* elem = (BYTE*)Arr.GetData() + idx * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	} else {
		Ar << *(FCompactIndex*)&V.Pad[0x20]; // TArray.ArrayNum at Pad[0x1C]+4
		for (INT i = 0; i < Arr.Num(); i++) {
			BYTE* elem = (BYTE*)Arr.GetData() + i * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticLightMapTexture@@@Z
// Ghidra @ 0x20c60: FUN_1031d450 on Pad[4..0x1c]; vtable[0] at Pad[0x34]+1;
// BOS at Pad[0x38]+4, Pad[0x3c]+4, Pad[0x48]+4. Needs FTexture base size.
FArchive & operator<<(FArchive & Ar, FStaticLightMapTexture & p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshBatcherVertex@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshBatcherVertex & p1) { return Ar; } // empty in original

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshLightInfo@@@Z
// Decoded from Ghidra Engine @ 0x21750. UObject* at +0, TArray<BYTE> at +4
// (FUN_1031cce0 = bulk byte array), INT at +0x10.
FArchive & operator<<(FArchive & Ar, FStaticMeshLightInfo & V) {
	Ar << V.LightObject;
	Ar << V.LightData;
	Ar.ByteOrderSerialize((BYTE*)&V.Field10, 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshMaterial@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshMaterial & V) {
	Ar << *(UObject**)&V.Material;
	Ar << *(FCompactIndex*)&V.Flags1;
	Ar << *(FCompactIndex*)&V.Flags2;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshSection@@@Z
// Ghidra @ 0x50f10: complex version-branched (pre-0x5c / 0x5c-0x70 / 0x70+) with SEH;
// creates temp FStaticMeshVertexStream + FRawIndexBuffer locals. Needs deep decode.
FArchive & operator<<(FArchive & Ar, FStaticMeshSection & p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshUVStream@@@Z
// FUN_10324510 = TArray<FStaticMeshUV>::Serialize (elem_size 8, two floats per elem)
// Layout (after vtable): Pad[0] TArray<FStaticMeshUV>  Pad[0x0C] INT  Pad[0x18] Revision
FArchive & operator<<(FArchive & Ar, FStaticMeshUVStream & V) {
	Ar << *(TArray<FStaticMeshUV>*)V.Pad;         // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x0C], 4);      // INT at Pad[0x0C] = obj+0x10
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);      // Revision at Pad[0x18] = obj+0x1C
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshVertexStream@@@Z
// FUN_103243e0 = TArray<FStaticMeshVertex>::Serialize (elem_size 0x18)
// Layout (after vtable): Pad[0] TArray<FStaticMeshVertex>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FStaticMeshVertexStream & V) {
	Ar << *(TArray<FStaticMeshVertex>*)V.Pad;     // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFTags@@@Z
// Decoded from Ghidra Engine @ 0xcc180. Inlines FUN_103cbaa0 (12×4-byte flat serialize)
// then serializes FString at offset 0x30.
FArchive & operator<<(FArchive & Ar, FTags & V) {
	for (INT i = 0; i < 12; i++)
		Ar.ByteOrderSerialize(V._Data + i * 4, 4);
	Ar << V.TagString;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFTerrainVertexStream@@@Z
// FUN_10323cd0 = TArray<FTerrainVertex>::Serialize (elem_size 0x24)
FArchive & operator<<(FArchive & Ar, FTerrainVertexStream & V) {
	Ar << V.Vertices;
	Ar.ByteOrderSerialize((BYTE*)&V.Revision, 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFURL@@@Z
FArchive & operator<<(FArchive& Ar, FURL& U) {
	Ar << U.Protocol << U.Host << U.Map << U.Portal << U.Op;
	Ar << U.Port << U.Valid;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFBspVertex@@@Z
FArchive & operator<<(FArchive & Ar, FBspVertex & V) {
	// Always serialize: offsets 0x00-0x08 (3 floats), 0x18-0x24 (4 floats)
	Ar.ByteOrderSerialize(&V._Data[0x00], 4);
	Ar.ByteOrderSerialize(&V._Data[0x04], 4);
	Ar.ByteOrderSerialize(&V._Data[0x08], 4);
	Ar.ByteOrderSerialize(&V._Data[0x18], 4);
	Ar.ByteOrderSerialize(&V._Data[0x1C], 4);
	Ar.ByteOrderSerialize(&V._Data[0x20], 4);
	Ar.ByteOrderSerialize(&V._Data[0x24], 4);
	// Version > 108: serialize 3 more floats at 0x0C-0x14
	if (Ar.Ver() > 0x6C) {
		Ar.ByteOrderSerialize(&V._Data[0x0C], 4);
		Ar.ByteOrderSerialize(&V._Data[0x10], 4);
		Ar.ByteOrderSerialize(&V._Data[0x14], 4);
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFPosNormTexData@@@Z
FArchive & operator<<(FArchive & Ar, FPosNormTexData & V) {
	// 10 floats: offsets 0x00-0x24
	for (INT i = 0; i < 10; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFProjectorRelativeRenderInfo@@@Z
// Ghidra @ 0x48c0: reads p1.m_RenderInfoPtr.Ptr as FProjectorRenderInfo*;
// calls FUN_10304820 version check, then vtable[6] for two fields at +0x18 and +0x1c.
FArchive & operator<<(FArchive & Ar, FProjectorRelativeRenderInfo & p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@PAUFProjectorRenderInfo@@@Z
// Ghidra @ 0x4890: calls FUN_10304820 version check; if 0 returns Ar;
// otherwise vtable[6] on p1+0x18 and p1+0x1c. FProjectorRenderInfo is forward-decl only.
FArchive & operator<<(FArchive & Ar, FProjectorRenderInfo * p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@AAUFSkinVertex@@@Z
FArchive & operator<<(FArchive & Ar, FSkinVertex & V) {
	// 16 floats: offsets 0x00-0x3C
	for (INT i = 0; i < 16; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshCollisionNode@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshCollisionNode & V) {
	// 4 FCompactIndex values at offsets 0x00, 0x04, 0x08, 0x0C
	Ar << *(FCompactIndex*)&V._Data[0x00];
	Ar << *(FCompactIndex*)&V._Data[0x04];
	Ar << *(FCompactIndex*)&V._Data[0x08];
	Ar << *(FCompactIndex*)&V._Data[0x0C];
	// FBox at offset 0x10
	Ar << V.Box;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshCollisionTriangle@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshCollisionTriangle & V) {
	// 16 floats (4 FPlanes) via ByteOrderSerialize
	for (INT i = 0; i < 16; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	// 4 FCompactIndex values at offsets 0x40, 0x44, 0x48, 0x4C
	Ar << *(FCompactIndex*)&V._Data[0x40];
	Ar << *(FCompactIndex*)&V._Data[0x44];
	Ar << *(FCompactIndex*)&V._Data[0x48];
	Ar << *(FCompactIndex*)&V._Data[0x4C];
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshUV@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshUV & V) {
	Ar.ByteOrderSerialize(&V._Data[0], 4);
	Ar.ByteOrderSerialize(&V._Data[4], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshVertex@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshVertex & V) {
	// 6 floats: Position (3) + Normal (3)
	for (INT i = 0; i < 6; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	// Legacy version paths for Ver < 0x70 and Ver == 0x6F omitted
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFTerrainVertex@@@Z
FArchive & operator<<(FArchive & Ar, FTerrainVertex & V) {
	// 6 floats at 0x00-0x14
	for (INT i = 0; i < 6; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	// 4 individual bytes at 0x18-0x1B (serialized in reverse order per Ghidra)
	Ar.Serialize(&V._Data[0x1A], 1);
	Ar.Serialize(&V._Data[0x19], 1);
	Ar.Serialize(&V._Data[0x18], 1);
	Ar.Serialize(&V._Data[0x1B], 1);
	// 2 floats at 0x1C-0x20
	Ar.ByteOrderSerialize(&V._Data[0x1C], 4);
	Ar.ByteOrderSerialize(&V._Data[0x20], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFUV2Data@@@Z
FArchive & operator<<(FArchive & Ar, FUV2Data & D) {
	Ar.ByteOrderSerialize(&D, 4);
	Ar.ByteOrderSerialize((BYTE*)&D + 4, 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFUntransformedVertex@@@Z
FArchive & operator<<(FArchive & Ar, FUntransformedVertex & V) {
	// 11 floats: offsets 0x00-0x28
	for (INT i = 0; i < 11; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	return Ar;
}

// ?GNewCollisionHash@@YAPAVFCollisionHashBase@@XZ
FCollisionHashBase * GNewCollisionHash() {
	if( !GIsEditor )
		return new FCollisionOctree();
	else
		return new FCollisionHash();
}

// ?FGetHSV@@YA?AVFPlane@@EEE@Z
// Converts Hue/Saturation/Value (each 0-255) to a normalised FPlane colour.
// Ghidra: param_2 (S/Hue) selects one of three sectors; param_3 (V) scales
// brightness; result has W=1.0f.
FPlane FGetHSV(BYTE H, BYTE S, BYTE V) {
	FLOAT fR, fG, fB;
	if (S < 0x56) {
		fR = (FLOAT)(0x55 - (DWORD)S) * 0.011764706f;
		fG = (FLOAT)(DWORD)S            * 0.011764706f;
		fB = 0.0f;
	} else if (S < 0xAB) {
		fR = 0.0f;
		fG = (FLOAT)(0xAA - (DWORD)S)   * 0.011764706f;
		fB = (FLOAT)((DWORD)S - 0x55)   * 0.011764706f;
	} else {
		fR = (FLOAT)((DWORD)S - 0xAA)   * 0.011764706f;
		fG = 0.0f;
		fB = (FLOAT)(0xFF - (DWORD)S)   * 0.011904762f;
	}
	FLOAT fV     = (FLOAT)V * 0.003921569f; // V / 255
	FLOAT fScale = (1.0f - fR) * fV;        // desaturation weight (Ghidra: afStack_c[0])
	fR = fScale + fR;
	fG = (1.0f - fG) * fV + fG;
	fB = (1.0f - fB) * fV + fB;
	// Ghidra: FVector{fR,fG,fB} * fScale, then FPlane(x,y,z,1.0f)
	FVector RGB = FVector(fR, fG, fB) * fScale;
	return FPlane(RGB.X, RGB.Y, RGB.Z, 1.0f);
}

// Forward declaration for overloaded variants below
int GetSUBSTRING(const TCHAR* Stream, const TCHAR* Match, TCHAR* Value, int MaxLen);

// ?GetFROTATOR@@YAHPBGAAVFRotator@@H@Z
int GetFROTATOR(const TCHAR* Stream, FRotator& Rotation, int ScaleFactor)
{
	FLOAT Temp = 0.f;
	int Count = 0;
	if( Parse( Stream, TEXT("PITCH="), Temp ) ) { Rotation.Pitch = (INT)(Temp * ScaleFactor); Count++; }
	if( Parse( Stream, TEXT("YAW="), Temp ) )   { Rotation.Yaw   = (INT)(Temp * ScaleFactor); Count++; }
	if( Parse( Stream, TEXT("ROLL="), Temp ) )  { Rotation.Roll  = (INT)(Temp * ScaleFactor); Count++; }
	if( Count > 0 )
		return 1;
	Rotation.Pitch = (INT)(appAtof( Stream ) * ScaleFactor);
	TCHAR* S = appStrchr( Stream, ',' );
	if( S )
	{
		Rotation.Yaw = (INT)(appAtof( S + 1 ) * ScaleFactor);
		S = appStrchr( S + 1, ',' );
		if( S )
		{
			Rotation.Roll = (INT)(appAtof( S + 1 ) * ScaleFactor);
			return 1;
		}
	}
	return 0;
}

// ?GetFROTATOR@@YAHPBG0AAVFRotator@@H@Z
int GetFROTATOR(const TCHAR* Stream, const TCHAR* Match, FRotator& Rotation, int ScaleFactor)
{
	TCHAR Temp[80];
	if( !GetSUBSTRING( Stream, Match, Temp, 80 ) )
		return 0;
	return GetFROTATOR( Temp, Rotation, ScaleFactor );
}

// ?GetFVECTOR@@YAHPBGAAVFVector@@@Z
int GetFVECTOR(const TCHAR* Stream, FVector& Value)
{
	int NumParsed = 0;
	NumParsed += Parse( Stream, TEXT("X="), Value.X );
	NumParsed += Parse( Stream, TEXT("Y="), Value.Y );
	NumParsed += Parse( Stream, TEXT("Z="), Value.Z );
	if( NumParsed > 0 )
		return NumParsed == 3;
	Value.X = appAtof( Stream );
	TCHAR* S = appStrchr( Stream, ',' );
	if( S )
	{
		Value.Y = appAtof( S + 1 );
		S = appStrchr( S + 1, ',' );
		if( S )
		{
			Value.Z = appAtof( S + 1 );
			return 1;
		}
	}
	return 0;
}

// ?GetFVECTOR@@YAHPBG0AAVFVector@@@Z
int GetFVECTOR(const TCHAR* Stream, const TCHAR* Match, FVector& Value)
{
	TCHAR Temp[80];
	if( !GetSUBSTRING( Stream, Match, Temp, 80 ) )
		return 0;
	return GetFVECTOR( Temp, Value );
}

// ?GetSUBSTRING@@YAHPBG0PAGH@Z
int GetSUBSTRING(const TCHAR* Stream, const TCHAR* Match, TCHAR* Value, int MaxLen)
{
	const TCHAR* Found = appStrfind( Stream, Match );
	if( !Found )
		return 0;
	Found += appStrlen( Match );
	int i = 0;
	while( *Found && *Found != ' ' && *Found != '\t' && i < MaxLen - 1 )
		Value[i++] = *Found++;
	Value[i] = 0;
	return 1;
}

// ?getGameShutDown@@YAHXZ
int getGameShutDown() { return bGameShutDown; }

// ?newPath@FPathBuilder@@AAEPAVANavigationPoint@@VFVector@@@Z
// Retail ordinal 5641 (0xe07b0).
// Spawns a PathNode at Location (adjusting Z upward if Scout's half-height < 85)
// and sets the machine-placed flag bit 0x80 at NavigationPoint+0x3a4.
// FPathBuilder layout: Pad[0..3]=ULevel*, Pad[4..7]=APawn* Scout.
ANavigationPoint* FPathBuilder::newPath(FVector Location) {
	ULevel* Level = *(ULevel**)((BYTE*)this);
	APawn* Scout  = *(APawn**)((BYTE*)this + 4);

	// Adjust Z so the node clears the Scout's collision cylinder height.
	FLOAT HalfHeight = *(FLOAT*)((BYTE*)Scout + 0xfc);
	if (HalfHeight < 85.0f)
		Location.Z = (Location.Z + 85.0f) - HalfHeight;

	// Find the PathNode class object.
	UClass* MetaClass  = UClass::StaticClass();
	UObject* PathNodeClass = UObject::StaticFindObjectChecked(MetaClass, (UObject*)~0, TEXT("PathNode"), 0);

	// Spawn a PathNode at Location with default rotation/name.
	ANavigationPoint* NavPt = (ANavigationPoint*)Level->SpawnActor(
		(UClass*)PathNodeClass, NAME_None, Location);

	if (!NavPt) {
		debugf(NAME_Warning, TEXT("FPathBuilder::newPath — failed to spawn PathNode"));
		return NULL;
	}

	// Mark as machine-placed (bit 0x80 of the NavigationPoint flags at +0x3a4).
	*(DWORD*)((BYTE*)NavPt + 0x3a4) |= 0x80;

	return NavPt;
}

// ?DistanceToHashPlane@FCollisionHash@@AAEMHMMH@Z
// Retail ordinal 2514 (0x6d6f0).  Returns the signed distance along axis p1
// to the far or near face of hash cell p0 (cell size = p3 unreal units,
// world offset = 262144).  Returns 256000 when p1 is zero (no movement along axis).
float FCollisionHash::DistanceToHashPlane(INT CellIdx, FLOAT Dir, FLOAT Pos, INT CellSize) {
	if (Dir == 0.0f) return 256000.0f;
	if (Dir > 0.0f)
		return ((((float)CellIdx + 0.5f) * (float)CellSize - 262144.0f) - Pos) / Dir;
	return ((((float)CellIdx - 0.5f) * (float)CellSize - 262144.0f) - Pos) / Dir;
}


// ?TestReach@FPathBuilder@@AAEHVFVector@@0@Z
// Retail ordinal 4852 (0xe0060).
// Teleports the Scout pawn to Start, tests whether it can reach End via
// APawn::pointReachable, then teleports Scout back to its original position.
// FPathBuilder layout: Pad[0..3] = ULevel*, Pad[4..7] = APawn* Scout.
int FPathBuilder::TestReach(FVector Start, FVector End) {
	ULevel* Level = *(ULevel**)((BYTE*)this);
	APawn* Scout = *(APawn**)((BYTE*)this + 4);

	// Save Scout's current location.
	FVector OldLoc;
	OldLoc.X = *(FLOAT*)((BYTE*)Scout + 0x234);
	OldLoc.Y = *(FLOAT*)((BYTE*)Scout + 0x238);
	OldLoc.Z = *(FLOAT*)((BYTE*)Scout + 0x23c);

	// Teleport Scout to Start (bNoCheck=0, bIgnorePawns=0).
	Level->FarMoveActor(Scout, Start, 0, 0, 0, 0);

	// Enable navigation-mode flag (bCanFly or similar path-test flag at +0x2c).
	*(BYTE*)((BYTE*)Scout + 0x2c) = 1;

	// Test whether End is reachable from Start.
	INT bReachable = Scout->pointReachable(End, 0);

	// Teleport Scout back to its original location (bIgnorePawns=1 to avoid
	// blocking the return move against other pawns).
	Level->FarMoveActor(Scout, OldLoc, 0, 1, 0, 0);

	return bReachable;
}

// ?TestWalk@FPathBuilder@@AAEHVFVector@@UFCheckResult@@M@Z
int FPathBuilder::TestWalk(FVector p0, FCheckResult p1, float p2) { return 0; }

// ?ValidNode@FPathBuilder@@AAEHPAVANavigationPoint@@PAVAActor@@@Z
// Retail ordinal 4962 (0xe0c90).
// Returns 1 when p1 is a valid adjacent navigation point for p0:
//   - p1 is non-null and different from p0
//   - p1 is not flagged as deleted (sign byte at 0xa0 >= 0)
//   - p1 is a NavigationPoint but NOT a LiftCenter
int FPathBuilder::ValidNode(ANavigationPoint* NavPoint, AActor* Candidate) {
	if (Candidate && Candidate != (AActor*)NavPoint && *(SBYTE*)((BYTE*)Candidate + 0xa0) >= 0) {
		if (((UObject*)Candidate)->IsA(ANavigationPoint::StaticClass())) {
			if (!((UObject*)Candidate)->IsA(ALiftCenter::StaticClass()))
				return 1;
		}
	}
	return 0;
}

// ?createPaths@FPathBuilder@@AAEHXZ
int FPathBuilder::createPaths() { return 0; }

// ?StoreActor@FOctreeNode@@AAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
// Ghidra (0xdb4e0): Leaf storage — adds the actor to this node's TArray and records
// this node in the actor's OctreeNodes list (actor+0x338) for fast removal.
// If the node already has >2 actors and is large enough to subdivide it does so;
// for simplicity we always use leaf storage (no subdivision).
void FOctreeNode::StoreActor(AActor* Actor, FCollisionOctree* OctHash, FPlane const* Plane)
{
	// Add actor to this node's actor list (TArray<AActor*> at FOctreeNode offset 0)
	TArray<AActor*>& ActorList = *(TArray<AActor*>*)this;
	ActorList.AddItem(Actor);
	// Record this node in the actor's OctreeNodes list (TArray<FOctreeNode*> at actor+0x338)
	TArray<FOctreeNode*>& NodeList = *(TArray<FOctreeNode*>*)((BYTE*)Actor + 0x338);
	NodeList.AddItem(this);
}

// ?FindBlockingNormal@FPathBuilder@@AAEXAAVFVector@@@Z
// Finds the surface normal at the point that blocks a path check.
// Runs up to three line checks (via Level->SingleLineCheck at vtable+0xcc):
//   Pass 1: Trace from (Scout.Loc - Direction*16) toward Scout.Loc.
//           If nothing blocked -> return unchanged.
//   Pass 2: If pass 1 blocked, trace downward 33 units at the end point.
//           If blocked -> give up, return unchanged.
//   Pass 3: If pass 2 not blocked, trace horizontally at Z-33 from End back toward Scout.
//           If blocked -> write Hit.Normal to p0.
//
// NOTE: The retail SingleLineCheck has a 7th undeclared FLOAT parameter (ExtraParam = 16.0).
// Passes 1 and 2 supply 16.0f for it via raw vtable call; pass 3 omits it (= 0).
void FPathBuilder::FindBlockingNormal(FVector& p0)
{
	ULevel* Level = *(ULevel**)((BYTE*)this);
	AActor* Scout = *(AActor**)((BYTE*)this + 4);

	FCheckResult Hit;
	Hit.Time = 1.0f;
	Hit.Item = INDEX_NONE;

	FLOAT HalfHeight = *(FLOAT*)((BYTE*)Scout + 0xfc);
	FLOAT Radius     = *(FLOAT*)((BYTE*)Scout + 0xf8);

	// Raw vtable call for SingleLineCheck with 7 explicit params (the extra 16.0f ExtraParam).
	typedef INT (__thiscall *tSLC7)(ULevel*,
	    FCheckResult*, AActor*, const FVector*, const FVector*, DWORD,
	    FLOAT, FLOAT, FLOAT,  // FVector Extent (3 floats by value)
	    FLOAT);               // ExtraParam
	void** VTable = *(void***)Level;
	tSLC7 SLC = (tSLC7)VTable[0xcc / 4];

	// Pass 1: trace from (Scout.Location - p0*16) toward Scout.Location.
	FVector Scaled = p0 * 16.0f;
	FVector End1(
		Scout->Location.X - Scaled.X,
		Scout->Location.Y - Scaled.Y,
		Scout->Location.Z - Scaled.Z);

	SLC(Level, &Hit, Scout, &End1, &Scout->Location, 0x86, Radius, Radius, HalfHeight, 16.0f);

	if (Hit.Time < 1.0f)
	{
		// Pass 2: vertical trace 33 units downward at the end point.
		Scaled = p0 * 16.0f;
		FLOAT EndZ = Scout->Location.Z - Scaled.Z;
		FVector End2(
			Scout->Location.X - Scaled.X,
			Scout->Location.Y - Scaled.Y,
			EndZ - 33.0f);
		FVector Start2(End2.X, End2.Y, EndZ);

		SLC(Level, &Hit, Scout, &End2, &Start2, 0x86, Radius, Radius, HalfHeight, 16.0f);

		if (Hit.Time < 1.0f)
			return;  // Pass 2 blocked—give up

		// Pass 3: horizontal trace at Z-33 from End back toward Scout.Location.
		FVector Start3(Scout->Location.X, Scout->Location.Y, Scout->Location.Z - 33.0f);
		FVector End3(End2.X, End2.Y, EndZ - 33.0f);

		Level->SingleLineCheck(Hit, Scout, Start3, End3, 0x86,
		                       FVector(Radius, Radius, HalfHeight));

		if (Hit.Time >= 1.0f)
			return;  // Pass 3 found nothing—give up

		// Pass 3 found a hit: set output to its surface normal.
		p0 = Hit.Normal;
	}
}

// ?Pass2From@FPathBuilder@@AAEXVFVector@@0M@Z
void FPathBuilder::Pass2From(FVector p0, FVector p1, float p2) {}

// ?SetPathCollision@FPathBuilder@@AAEXH@Z
// Retail ordinal 4485 (0xe0300).
// Toggles collision for actors that block path-building.
// When disabling (param_1 != 0): for each live actor that has bBlockPlayers &&
//   bCollideActors && !bPathTemp && !(JointDetails & 0x20000), save the old
//   collision state by setting a temporary flag (bit 3) at actor+0x320, then
//   call SetCollision(0, ...) to take the actor "out of the way".
// When re-enabling (param_1 == 0): restore collision for every actor that had
//   the temp flag set.
// Field actor+0x320 (800 decimal): custom scratch field used only during path
//   building; bit 3 (0x8) = "collision was disabled for path test; restore it".
void FPathBuilder::SetPathCollision(int bDisable) {
	ULevel* Level = *(ULevel**)((BYTE*)this);
	INT Count = Level->Actors.Num();

	if (bDisable == 0) {
		// Re-enable collision for actors we disabled.
		for (INT i = 0; i < Count; i++) {
			AActor* A = Level->Actors(i);
			if (!A) continue;
			if (*(DWORD*)((BYTE*)A + 0x320) & 0x8) {
				// Clear the temp flag.
				*(DWORD*)((BYTE*)A + 0x320) &= ~0x8u;
				// Restore bBlockActors=1, bBlockPlayers and bBlocksSelf from saved flags.
				DWORD Flags = *(DWORD*)((BYTE*)A + 0xa8);
				A->SetCollision(1, (Flags >> 13) & 1, (Flags >> 14) & 1);
			}
		}
	} else {
		// Disable collision of actors that block path search.
		for (INT i = 0; i < Count; i++) {
			AActor* A = Level->Actors(i);
			if (!A) continue;
			if (*(SBYTE*)((BYTE*)A + 0xa0) < 0) continue; // bDeleteMe
			DWORD Flags = *(DWORD*)((BYTE*)A + 0xa8);
			DWORD bBlockPlayers = (Flags >> 13) & 1;
			if (!bBlockPlayers) {
				*(DWORD*)((BYTE*)A + 0x320) &= ~0x8u;
				continue;
			}
			// Skip if not bCollideActors, or bPathTemp set, or joint-no-encroach flag.
			if (!(Flags & 0x800) || (*(DWORD*)((BYTE*)A + 0xa0) & 1) ||
			    (*(DWORD*)((BYTE*)A + 0xac) & 0x20000)) {
				*(DWORD*)((BYTE*)A + 0x320) &= ~0x8u;
				continue;
			}
			// Save and disable.
			*(DWORD*)((BYTE*)A + 0x320) |= 0x8;
			A->SetCollision(0, bBlockPlayers, (Flags >> 14) & 1);
		}
	}
}

// ?getScout@FPathBuilder@@AAEXXZ
// Finds or spawns the Scout pawn used for path-building reachability tests.
// FPathBuilder layout: [0..3]=ULevel*, [4..7]=APawn* Scout
// Post-spawn Scout setup:
//   SetCollision(1,1,1)
//   Scout+0xa8 |= 0x1000  (bPathBuilding flag)
//   vtable[0x10c] and vtable[0x114] on Scout (SetPhysics-related calls)
//   Scout->PhysicsVolume = Level->GetDefaultPhysicsVolume()
void FPathBuilder::getScout()
{
	ULevel* Level = *(ULevel**)((BYTE*)this);
	*(AActor**)((BYTE*)this + 4) = NULL;

	// Find Scout UClass for IsA checks.
	// Deviation from original: StaticFindObjectChecked called before loop
	// instead of using AScout::PrivateStaticClass directly (AScout is forward-declared only).
	UClass* ScoutClass = (UClass*)UObject::StaticFindObjectChecked(
		UClass::StaticClass(), (UObject*)-1, TEXT("Scout"), 0);

	// Search existing actors for a Scout pawn.
	INT Count = Level->Actors.Num();
	for (INT i = 0; i < Count; i++)
	{
		AActor* A = Level->Actors(i);
		if (!A || !A->IsA(ScoutClass)) continue;
		*(AActor**)((BYTE*)this + 4) = A;
		break;
	}

	if (*(INT*)((BYTE*)this + 4) == 0)
	{
		// Spawn a new Scout pawn.
		AActor* S = Level->SpawnActor(ScoutClass, NAME_None, FVector(0,0,0));
		*(AActor**)((BYTE*)this + 4) = (S && S->IsA(ScoutClass)) ? S : NULL;

		// Spawn an AIController for the Scout.
		UClass* AIClass = (UClass*)UObject::StaticFindObjectChecked(
			UClass::StaticClass(), (UObject*)-1, TEXT("AIController"), 0);
		AActor* AICtrl = Level->SpawnActor(AIClass, NAME_None, FVector(0,0,0));
		AActor* Scout = *(AActor**)((BYTE*)this + 4);
		if (Scout) *(void**)((BYTE*)Scout + 0x4ec) = AICtrl;
	}

	AActor* Scout = *(AActor**)((BYTE*)this + 4);
	if (!Scout) return;

	Scout->SetCollision(1, 1, 1);
	*(DWORD*)((BYTE*)Scout + 0xa8) |= 0x1000;  // bPathBuilding

	// vtable[0x10c] on Scout — physics/state init call (no visible args)
	typedef void (__thiscall *tVoidFn)(AActor*);
	tVoidFn fn1 = *(tVoidFn*)((BYTE*)(*(void**)Scout) + 0x10c);
	fn1(Scout);

	// Store default physics volume
	ALevelInfo* LevelInfo = *(ALevelInfo**)((BYTE*)Scout + 0x144);
	APhysicsVolume* Vol = LevelInfo->GetDefaultPhysicsVolume();
	*(APhysicsVolume**)((BYTE*)Scout + 0x164) = Vol;

	// vtable[0x114] on Scout — second physics/state init call (no visible args)
	tVoidFn fn2 = *(tVoidFn*)((BYTE*)(*(void**)Scout) + 0x114);
	fn2(Scout);
}

// ?testPathsFrom@FPathBuilder@@AAEXVFVector@@@Z
// Ghidra: call findStart on Scout; if Z matches within MaxStepHeight -> testPathwithRadius;
// else retry findStart with Start.Z+20. If neither works, return.
void FPathBuilder::testPathsFrom(FVector Start) {
	AScout* Scout = *(AScout**)(Pad + 4);
	if (Scout->findStart(Start)) {
		// Check if scout landed close enough in Z (within MaxStepHeight at Scout+0xfc)
		FLOAT ScoutZ  = *(FLOAT*)((BYTE*)Scout + 0x23c);	// Z component after placement
		FLOAT MaxStep = *(FLOAT*)((BYTE*)Scout + 0xfc);	// MaxStepHeight
		FLOAT DiffZ   = ScoutZ - Start.Z;
		if (DiffZ < 0.0f) DiffZ = -DiffZ;
		if (DiffZ <= MaxStep) {
			testPathwithRadius(Start, 40.0f);
			return;
		}
	}
	// Retry 20 units higher
	if (Scout->findStart(FVector(Start.X, Start.Y, Start.Z + 20.0f)))
		testPathwithRadius(Start, 40.0f);
}

// ?testPathwithRadius@FPathBuilder@@AAEXVFVector@@M@Z
// Ghidra: resize Scout to Radius x 85, then probe 8 horizontal directions (±X, ±Y) at ±1 walk.
void FPathBuilder::testPathwithRadius(FVector Start, float Radius) {
	AActor* Scout = *(AActor**)(Pad + 4);
	Scout->SetCollisionSize(Radius, 85.0f);
	Pass2From(Start, FVector( 1.0f, 0.0f, 0.0f),  1.0f);
	Pass2From(Start, FVector( 1.0f, 0.0f, 0.0f), -1.0f);
	Pass2From(Start, FVector( 0.0f, 1.0f, 0.0f),  1.0f);
	Pass2From(Start, FVector( 0.0f, 1.0f, 0.0f), -1.0f);
	Pass2From(Start, FVector(-1.0f, 0.0f, 0.0f),  1.0f);
	Pass2From(Start, FVector(-1.0f, 0.0f, 0.0f), -1.0f);
	Pass2From(Start, FVector( 0.0f,-1.0f, 0.0f),  1.0f);
	Pass2From(Start, FVector( 0.0f,-1.0f, 0.0f), -1.0f);
}

// ??0ECLipSynchData@@QAE@PAVUMeshInstance@@PAVUSound@@1PAVAActor@@@Z
ECLipSynchData::ECLipSynchData(UMeshInstance * p0, USound * p1, USound * p2, AActor * p3) {}

// ??0ECLipSynchData@@QAE@XZ
ECLipSynchData::ECLipSynchData() {}

// ??0FActorSceneNode@@QAE@PAVUViewport@@PAVAActor@@1VFVector@@VFRotator@@M@Z
FActorSceneNode::FActorSceneNode(UViewport * p0, AActor * p1, AActor * p2, FVector p3, FRotator p4, float p5) : FSceneNode((UViewport*)NULL) {}

// ??0FCameraSceneNode@@QAE@PAVUViewport@@PAVAActor@@VFVector@@VFRotator@@M@Z
FCameraSceneNode::FCameraSceneNode(UViewport * p0, AActor * p1, FVector p2, FRotator p3, float p4) : FSceneNode((UViewport*)NULL) {}

// ??0FCollisionHash@@QAE@ABV0@@Z
// Copy constructor — rarely called; just default-init and leave buckets empty.
// A proper implementation would clone the hash table from p0, but that involves
// re-inserting all actors which requires level context we don't have here.
FCollisionHash::FCollisionHash(FCollisionHash const & /*p0*/) {
	FreeList = NULL;
	// AllocatedPools default-constructed to empty
	if (!Inited) {
		Inited = 1;
		for (INT i = 0; i < 0x4000; i++) HashX[i] = HashY[i] = HashZ[i] = i;
		for (INT i = 0; i < 0x4000; i++) {
			INT jx = (DWORD)appRand() & 0x3FFF; Exchange(HashX[i], HashX[jx]);
			INT jy = (DWORD)appRand() & 0x3FFF; Exchange(HashY[i], HashY[jy]);
			INT jz = (DWORD)appRand() & 0x3FFF; Exchange(HashZ[i], HashZ[jz]);
		}
	}
	for (INT i = 0; i < 0x4000; i++) Buckets[i] = NULL;
}

// ??0FCollisionHash@@QAE@XZ
// Retail: ordinal 211 (0x6f440).  Size: ~700 bytes.
// Sets up vftable, zeros pool/FArray, initialises permutation tables once via
// Fisher-Yates shuffle (seeded by appRand), then NULLs all 0x4000 bucket heads.
FCollisionHash::FCollisionHash() {
	FreeList = NULL;
	// AllocatedPools is default-constructed (TArray ctor zeroes it)
	if (!Inited) {
		Inited = 1;
		for (INT i = 0; i < 0x4000; i++) HashX[i] = HashY[i] = HashZ[i] = i;
		for (INT i = 0; i < 0x4000; i++) {
			INT jx = (DWORD)appRand() & 0x3FFF; Exchange(HashX[i], HashX[jx]);
			INT jy = (DWORD)appRand() & 0x3FFF; Exchange(HashY[i], HashY[jy]);
			INT jz = (DWORD)appRand() & 0x3FFF; Exchange(HashZ[i], HashZ[jz]);
		}
	}
	for (INT i = 0; i < 0x4000; i++) Buckets[i] = NULL;
}

// ??0FCollisionOctree@@QAE@ABV0@@Z
FCollisionOctree::FCollisionOctree(FCollisionOctree const& p0) {
	appMemcpy(Pad, p0.Pad, sizeof(Pad));
}

// ??0FCollisionOctree@@QAE@XZ
// Ghidra: allocates a root FOctreeNode, zeroes counters, sets world bitmask.
FCollisionOctree::FCollisionOctree() {
	appMemzero(Pad, sizeof(Pad));
	// Pad[0..3] = root FOctreeNode* (object offset +4, ref from Ghidra)
	FOctreeNode* root = new FOctreeNode();
	*(FOctreeNode**)Pad = root;
	// Pad[4..7] = world size bitmask 0x1fffffff (object offset +8)
	*(INT*)(Pad + 4) = 0x1fffffff;
	// FVector/FRotator fields at Pad+0x10..0x4c already zeroed by appMemzero
}

// ??0FDirectionalLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@AAVFBspSurf@@PAVFLightMap@@@Z
FDirectionalLightMapSceneNode::FDirectionalLightMapSceneNode(UViewport * p0, AActor * p1, FBspSurf & p2, FLightMap * p3) : FSceneNode((UViewport*)NULL) {}

// ??0FHitCause@@QAE@PAVFHitObserver@@PAVUViewport@@KMM@Z
FHitCause::FHitCause(FHitObserver* InObserver, UViewport* InViewport, DWORD InButtons, float InMouseX, float InMouseY)
:	Observer(InObserver)
,	Viewport(InViewport)
,	Buttons(InButtons)
,	MouseX(InMouseX)
,	MouseY(InMouseY)
{}

// ??4FHitCause@@QAEAAU0@ABU0@@Z
FHitCause& FHitCause::operator=(const FHitCause& Other)
{
	Observer = Other.Observer;
	Viewport = Other.Viewport;
	Buttons  = Other.Buttons;
	MouseX   = Other.MouseX;
	MouseY   = Other.MouseY;
	return *this;
}

// ??0FLevelSceneNode@@QAE@PAV0@HVFMatrix@@@Z
FLevelSceneNode::FLevelSceneNode(FLevelSceneNode * p0, int p1, FMatrix p2) : FSceneNode((UViewport*)NULL) {}

// ??0FLevelSceneNode@@QAE@ABV0@@Z
// Ghidra: calls FSceneNode copy ctor, then copies 6 DWORDs at 0x1B8-0x1CC
FLevelSceneNode::FLevelSceneNode(FLevelSceneNode const & Other) : FSceneNode((const FSceneNode&)Other)
{
	appMemcpy(((BYTE*)this) + 0x1B8, ((const BYTE*)&Other) + 0x1B8, 24);
}

// ??0FLevelSceneNode@@QAE@PAVUViewport@@@Z
FLevelSceneNode::FLevelSceneNode(UViewport * p0) : FSceneNode((UViewport*)NULL) {}

// ??0FLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@PAVFLightMap@@@Z
FLightMapSceneNode::FLightMapSceneNode(UViewport * p0, AActor * p1, FLightMap * p2) : FSceneNode((UViewport*)NULL) {}

// ??0FMatineeTools@@QAE@ABV0@@Z
FMatineeTools::FMatineeTools(FMatineeTools const & p0) {}

// ??0FOctreeNode@@QAE@ABV0@@Z
// Copy constructor — copy TArray (actors list at Pad[0..11]) and flag at Pad[12]
FOctreeNode::FOctreeNode(FOctreeNode const& p0) {
	appMemcpy(Pad, p0.Pad, 16);
}

// ??0FOctreeNode@@QAE@XZ
// Ghidra: FArray::FArray((FArray*)this) zeros first 12 bytes; *(this+0xc) = 0
FOctreeNode::FOctreeNode() {
	appMemzero(Pad, 16); // TArray<> at 0..11, flag at 12
}

// ??1FOctreeNode@@QAE@XZ
FOctreeNode::~FOctreeNode() {}

// ??0FPointLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@AAVFBspSurf@@PAVFLightMap@@HHHH@Z
FPointLightMapSceneNode::FPointLightMapSceneNode(UViewport * p0, AActor * p1, FBspSurf & p2, FLightMap * p3, int p4, int p5, int p6, int p7) : FSceneNode((UViewport*)NULL) {}

// ??0FPoly@@QAE@XZ
FPoly::FPoly() {
	Init();
}

// ??0FRebuildTools@@QAE@ABV0@@Z
FRebuildTools::FRebuildTools(FRebuildTools const & p0) {}

// ??1FRebuildTools@@QAE@XZ
FRebuildTools::~FRebuildTools() {}

// ??0FRotatorF@@QAE@VFRotator@@@Z
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
FMatrix UMeshInstance::MeshToWorld() { return FMatrix(); }

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
void UVertexStreamBase::Serialize(FArchive& Ar) { URenderResource::Serialize(Ar); }
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
const TCHAR* UInput::StaticConfigName() { return TEXT("Input"); }
void UInput::StaticInitInput() {}

// ============================================================================
// ALevelInfo
// ============================================================================
void ALevelInfo::SetVolumes(const TArray<class AVolume*>&) {}
void ALevelInfo::SetVolumes() {}
void ALevelInfo::SetZone(INT, INT) {}
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
INT ALevelInfo::IsSoundAudibleFromZone(INT, INT) { return 1; }

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
FPointRegion::FPointRegion(AZoneInfo* InZone) : Zone(InZone), iLeaf(0), ZoneNumber(0) {}
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
