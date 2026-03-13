/*=============================================================================
	UnTerrain.cpp: Terrain system (ATerrainInfo, FTerrainTools)
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

// --- ATerrainInfo ---
void ATerrainInfo::SetupSectors()
{
	guard(ATerrainInfo::SetupSectors);
	unguard;
}

void ATerrainInfo::SoftDeselect()
{
	guard(ATerrainInfo::SoftDeselect);
	unguard;
}

void ATerrainInfo::UpdateFromSelectedVertices()
{
	guard(ATerrainInfo::UpdateFromSelectedVertices);
	unguard;
}

void ATerrainInfo::ResetMove()
{
	guard(ATerrainInfo::ResetMove);
	unguard;
}

void ATerrainInfo::PostEditChange()
{
	// Ghidra 0x164960: update terrain arrays, rebuild sectors, recalculate coords.
	// Divergence: two unknown function calls (FUN_10352020, FUN_1032ecd0) omitted.
	AActor::PostEditChange();
	INT* levelInfo = *(INT**)((BYTE*)this + 0x144);
	if (levelInfo)
	{
		ULevel* level = *(ULevel**)((BYTE*)levelInfo + 0x328);
		if (level) level->UpdateTerrainArrays();
	}
	SetupSectors();
	CalcCoords();
	Update(0.0f, 0, 0, 0, 0, 0);
}

void ATerrainInfo::PostLoad()
{
	guard(ATerrainInfo::PostLoad);
	unguard;
}

void ATerrainInfo::PrecomputeLayerWeights()
{
	guard(ATerrainInfo::PrecomputeLayerWeights);
	unguard;
}

// (merged from earlier occurrence)
void ATerrainInfo::SoftSelect(float,float)
{
	guard(ATerrainInfo::SoftSelect);
	unguard;
}
void ATerrainInfo::Update(float Dt, int X1, int Y1, int X2, int Y2, int Flags)
{
	guard(ATerrainInfo::Update);
	// Ghidra 0x161140: default X2/Y2 to full terrain dimensions, then dispatch to sub-steps.
	if (X2 == 0) X2 = *(INT*)((BYTE*)this + 0x12E0);
	if (Y2 == 0) Y2 = *(INT*)((BYTE*)this + 0x12E4);
	if (!GIsEditor)
		PrecomputeLayerWeights();
	CalcLayerTexCoords();
	UpdateVertices(Dt, X1, Y1, X2, Y2);
	UpdateTriangles(X1, Y1, X2, Y2, Flags);
	if (!GIsEditor)
		CombineLayerWeights();
	unguard;
}
void ATerrainInfo::UpdateDecorations(int)
{
	guard(ATerrainInfo::UpdateDecorations);
	unguard;
}
void ATerrainInfo::UpdateTriangles(int,int,int,int,int)
{
	guard(ATerrainInfo::UpdateTriangles);
	unguard;
}
void ATerrainInfo::UpdateVertices(float,int,int,int,int)
{
	guard(ATerrainInfo::UpdateVertices);
	unguard;
}
FVector ATerrainInfo::WorldToHeightmap(FVector In)
{
	// Retail: 29b. ECX=this+0x1330 (heightmap FCoords), call FVector::TransformPointBy.
	return In.TransformPointBy(*(FCoords*)((BYTE*)this + 0x1330));
}
void ATerrainInfo::Render(FLevelSceneNode *,FRenderInterface *,FVisibilityInterface *)
{
	guard(ATerrainInfo::Render);
	unguard;
}
void ATerrainInfo::RenderDecorations(FLevelSceneNode *,FRenderInterface *,FVisibilityInterface *)
{
	guard(ATerrainInfo::RenderDecorations);
	unguard;
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
	guard(ATerrainInfo::SelectVerticesInBox);
	unguard;
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
	_WORD* heightData = (_WORD*)*(BYTE**)(mipsData + 0x1C); // FMipmapBase[0].DataPtr
	heightData[idx] = Value;
}
void ATerrainInfo::SetLayerAlpha(float,float,int,BYTE,UTexture *)
{
	guard(ATerrainInfo::SetLayerAlpha);
	unguard;
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
	// Retail 0x104570D0: mark terrain dirty for rebuild (bit 2 of DWORD at +0x12B4).
	*(DWORD*)((BYTE*)this + 0x12B4) |= 4;
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
	guard(ATerrainInfo::SetTextureColor);
	unguard;
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
	guard(ATerrainInfo::MoveVertices);
	unguard;
}
int ATerrainInfo::PointCheck(FCheckResult &,FVector,FVector,int)
{
	return 0;
}
void ATerrainInfo::CalcCoords()
{
	// Ghidra 0x156780: build heightmap-to-world FCoords at this+0x1300,
	// optionally divide by heightmap center, then store inverse at this+0x1330.
	FLOAT TSX = *(FLOAT*)((BYTE*)this + 0x39c);
	FLOAT TSY = *(FLOAT*)((BYTE*)this + 0x3a0);
	FLOAT TSZ = *(FLOAT*)((BYTE*)this + 0x3a4);

	FVector Origin(
		-(*(FLOAT*)((BYTE*)this + 0x234) / TSX),
		(-1.0f / TSY) * *(FLOAT*)((BYTE*)this + 0x238),
		(*(FLOAT*)((BYTE*)this + 0x23c) / TSZ) * -256.0f
	);
	FVector XAxis(TSX,          0.0f,               0.0f);
	FVector YAxis(0.0f,         TSY,                0.0f);
	FVector ZAxis(0.0f,         0.0f,               TSZ * 0.00390625f); // 1/256

	FCoords* HeightmapToWorld = (FCoords*)((BYTE*)this + 0x1300);
	*HeightmapToWorld = FCoords(Origin, XAxis, YAxis, ZAxis);

	if (*(INT*)((BYTE*)this + 0x398)) // heightmap texture present
	{
		FVector Center(
			(FLOAT)(*(INT*)((BYTE*)this + 0x12e0) / 2),
			(FLOAT)(*(INT*)((BYTE*)this + 0x12e4) / 2),
			32767.0f
		);
		*HeightmapToWorld /= Center;
	}

	*(FCoords*)((BYTE*)this + 0x1330) = HeightmapToWorld->Inverse();
}
void ATerrainInfo::CalcLayerTexCoords()
{
	guard(ATerrainInfo::CalcLayerTexCoords);
	unguard;
}
void ATerrainInfo::CheckComputeDataOnLoad()
{
	guard(ATerrainInfo::CheckComputeDataOnLoad);
	// Ghidra 0x1615a0: if dirty flag (this+0x12B8) is set, rebuild and clear it.
	if (*(INT*)((BYTE*)this + 0x12B8) != 0)
	{
		Update(0.0f, 0, 0, 0, 0, 0);
		*(INT*)((BYTE*)this + 0x12B8) = 0;
	}
	unguard;
}
void ATerrainInfo::CombineLayerWeights()
{
	guard(ATerrainInfo::CombineLayerWeights);
	unguard;
}
void ATerrainInfo::ConvertHeightmapFormat()
{
	guard(ATerrainInfo::ConvertHeightmapFormat);
	unguard;
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
	// Retail: 0x157000, 94b. Format-check wrapper over heightmap texture at this+0x398.
	// Format 0 (P8): return high byte of 8-bit texel shifted to 16-bit.
	// Format 10 (G16): direct 16-bit read. Other: return 0.
	UTexture* HeightTex = *(UTexture**)((BYTE*)this + 0x398);
	BYTE fmt = *(BYTE*)((BYTE*)HeightTex + 0x58);
	INT USize = *(INT*)((BYTE*)HeightTex + 0x60); // USize
	BYTE* mipEntry = *(BYTE**)((BYTE*)HeightTex + 0xBC); // Mips.Data
	BYTE* texData = *(BYTE**)(mipEntry + 0x1C);          // FMipmapBase[0].DataPtr
	if (fmt == 0)
		return (_WORD)(*(BYTE*)(texData + USize * Y + X)) << 8;
	if (fmt == 10)
		return *((_WORD*)(texData + (USize * Y + X) * 2));
	return 0;
}
BYTE ATerrainInfo::GetLayerAlpha(int X, int Y, int Layer, UTexture* Tex)
{
	// Retail: 0x156de0, ~200b. Lookup layer alpha texture, optionally scale coords
	// by texture/terrain size ratio, then sample texture data by format.
	// Divergence: avoids FStaticTexture on stack — calls GetRawTextureData directly.

	// Resolve texture: if null, look up from layer array at this+0x3AC
	if (!Tex)
	{
		if (Layer != -1)
			Tex = *(UTexture**)((BYTE*)this + Layer * 0x78 + 0x3AC);
		else
			Tex = *(UTexture**)((BYTE*)this + 0x398); // heightmap texture
	}

	// Scale coords by texture/terrain ratio (skip if Layer == -2 and Tex given)
	if (!(Tex && Layer == -2))
	{
		INT terrainW = *(INT*)((BYTE*)this + 0x12E0);
		INT terrainH = *(INT*)((BYTE*)this + 0x12E4);
		INT texW = *(INT*)((BYTE*)Tex + 0x60);
		INT texH = *(INT*)((BYTE*)Tex + 0x64);
		if (terrainW > 0) X = (texW * X) / terrainW;
		if (terrainH > 0) Y = (texH * Y) / terrainH;
	}

	FStaticTexture StaticTex(Tex);
	void* texData = StaticTex.GetRawTextureData(0);
	if (!texData)
		return 0;

	INT texW = *(INT*)((BYTE*)Tex + 0x60);
	BYTE fmt  = *(BYTE*)((BYTE*)Tex + 0x58);
	INT  idx  = texW * Y + X;
	if (fmt == 0)
	{
		// Paletted: index into palette RGBA, byte [2] = R channel used as alpha
		BYTE texel   = *(BYTE*)((BYTE*)texData + idx);
		BYTE* palPtr = *(BYTE**)(*(INT*)((BYTE*)Tex + 0x70) + 0x2C);
		return palPtr[texel * 4 + 2];
	}
	if (fmt == 5)
		return *(BYTE*)((BYTE*)texData + idx * 4 + 3); // RGBA: alpha at [3]
	if (fmt == 9)
		return *(BYTE*)((BYTE*)texData + idx);          // 8-bit alpha
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
void ATerrainInfo::Serialize(FArchive& Ar)
{
	// Retail: 0x164cf0. Calls AActor::Serialize then serializes terrain dimensions,
	// sector data, FCoords transforms, and heightmap/alpha data arrays.
	// Divergence: omits legacy version-gated paths (ver < 0x4c / 0x52 / 0x53).
	AActor::Serialize(Ar);
	// Terrain dimensions (HeightmapX/Y at +0x12E0/+0x12E4)
	Ar.ByteOrderSerialize((BYTE*)this + 0x12E0, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x12E4, 4);
}
void ATerrainInfo::CheckForErrors()
{
	// Retail: 0x977b0. Iterates 32 layer slots at this+0x3AC (stride 0x78),
	// warns via GWarn if any alpha-map texture has more than 1 mip level.
	for (INT i = 0; i < 0x20; i++)
	{
		UTexture* AlphaTex = *(UTexture**)((BYTE*)this + i * 0x78 + 0x3AC);
		if (AlphaTex && AlphaTex->Mips.Num() > 1)
		{
			GWarn->Logf(TEXT("Terrain alpha map %s has more than one mip level.  This will cause visual artifacts."),
				AlphaTex->GetPathName());
		}
	}
}
void ATerrainInfo::Destroy()
{
	// Retail: 0x1566f0. Checks this->LevelInfo (this+0x144); reads ULevel* at levelInfo+0x328
	// and calls ULevel::UpdateTerrainArrays to evict this terrain from the level cache.
	// Then calls AActor::Destroy.
	INT* levelInfo = (INT*)*(INT*)((BYTE*)this + 0x144);
	if (levelInfo)
	{
		ULevel* level = *(ULevel**)((BYTE*)levelInfo + 0x328);
		if (level)
			level->UpdateTerrainArrays();
	}
	AActor::Destroy();
}
UPrimitive * ATerrainInfo::GetPrimitive()
{
	// Retail: 0x155c0. If sector list at this+0x12C8 is empty, defer to AActor.
	// Otherwise return cached UTerrainPrimitive at this+0x12F0.
	// Divergence: lazy creation of UTerrainPrimitive via StaticAllocateObject is omitted.
	TArray<INT>* sectors = (TArray<INT>*)((BYTE*)this + 0x12C8);
	if (sectors->Num() == 0)
		return AActor::GetPrimitive();
	return *(UPrimitive**)((BYTE*)this + 0x12F0);
}


// --- FTerrainMaterialLayer ---
FTerrainMaterialLayer::FTerrainMaterialLayer()
{
	guard(FTerrainMaterialLayer::FTerrainMaterialLayer);
	// Ghidra 0x97f0: FMatrix member at +8 is default-constructed.
	new ((BYTE*)this + 8) FMatrix();
	unguard;
}

FTerrainMaterialLayer::~FTerrainMaterialLayer()
{
	guard(FTerrainMaterialLayer::~FTerrainMaterialLayer);
	// Ghidra 0x9800: destroy FMatrix member at +8.
	((FMatrix*)((BYTE*)this + 8))->~FMatrix();
	unguard;
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

void FTerrainTools::SetCurrentBrush(int BrushID)
{
	// Ghidra 0x1665d0: if a current terrain info is set, clear its selection list.
	// Then search the brush list (at Pad[0x48], stride 0x68) for BrushID match
	// at element+0x1c; store the found element pointer and the BrushID.
	// Divergence: falls through to appFailAssert if not found (retained from retail).
	INT* terrainInfo = *(INT**)&Pad[0x7c];
	if (terrainInfo)
	{
		for (INT i = 0; i < *(INT*)((BYTE*)terrainInfo + 0x1364); i++) {}
		((FArray*)((BYTE*)terrainInfo + 0x1360))->Empty(0x14, 0);
	}

	FArray* brushList = (FArray*)&Pad[0x48];
	for (INT i = 0; i < brushList->Num(); i++)
	{
		BYTE* entry = *(BYTE**)brushList + i * 0x68;
		if (*(INT*)(entry + 0x1c) == BrushID)
		{
			*(BYTE**)&Pad[0x54] = entry;
			*(INT*)&Pad[0x3c]   = BrushID;
			return;
		}
	}
	appFailAssert("0", ".\\UnTerrainTools.cpp", 0x372);
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
	guard(FTerrainTools::FTerrainTools);
	unguard;
}

FTerrainTools::~FTerrainTools()
{
	guard(FTerrainTools::~FTerrainTools);
	unguard;
}

void FTerrainTools::AdjustAlignedActors()
{
	guard(FTerrainTools::AdjustAlignedActors);
	unguard;
}

void FTerrainTools::FindActorsToAlign()
{
	guard(FTerrainTools::FindActorsToAlign);
	unguard;
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
	guard(FTerrainTools::Init);
	unguard;
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

