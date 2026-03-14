/*=============================================================================
	UnTerrain.cpp: Terrain system (ATerrainInfo, FTerrainTools)
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

#include "ImplSource.h"
#include "EngineDecls.h"

// --- ATerrainInfo ---
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::SetupSectors()
{
	guard(ATerrainInfo::SetupSectors);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::SoftDeselect()
{
	guard(ATerrainInfo::SoftDeselect);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::UpdateFromSelectedVertices()
{
	guard(ATerrainInfo::UpdateFromSelectedVertices);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::ResetMove()
{
	guard(ATerrainInfo::ResetMove);
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x164960)
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

IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::PostLoad()
{
	guard(ATerrainInfo::PostLoad);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::PrecomputeLayerWeights()
{
	guard(ATerrainInfo::PrecomputeLayerWeights);
	unguard;
}

// (merged from earlier occurrence)
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::SoftSelect(float,float)
{
	guard(ATerrainInfo::SoftSelect);
	unguard;
}
IMPL_GHIDRA("Engine.dll", 0x161140)
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
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::UpdateDecorations(int)
{
	guard(ATerrainInfo::UpdateDecorations);
	unguard;
}
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::UpdateTriangles(int,int,int,int,int)
{
	guard(ATerrainInfo::UpdateTriangles);
	unguard;
}
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::UpdateVertices(float,int,int,int,int)
{
	guard(ATerrainInfo::UpdateVertices);
	unguard;
}
IMPL_APPROX("Transforms world position to heightmap space via FCoords at +0x1330")
FVector ATerrainInfo::WorldToHeightmap(FVector In)
{
	// Retail: 29b. ECX=this+0x1330 (heightmap FCoords), call FVector::TransformPointBy.
	return In.TransformPointBy(*(FCoords*)((BYTE*)this + 0x1330));
}
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::Render(FLevelSceneNode *,FRenderInterface *,FVisibilityInterface *)
{
	guard(ATerrainInfo::Render);
	unguard;
}
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::RenderDecorations(FLevelSceneNode *,FRenderInterface *,FVisibilityInterface *)
{
	guard(ATerrainInfo::RenderDecorations);
	unguard;
}
IMPL_GHIDRA_APPROX("Engine.dll", 0x15cbf0, "Returns 0; vertex selection with symmetry mirrors deferred due to unresolved editor globals")
int ATerrainInfo::SelectVertex(FVector)
{
	guard(ATerrainInfo::SelectVertex);
	// Ghidra 0x15cbf0, 4358 bytes: find closest heightmap vertex at the given world pos,
	// then add it (and symmetry mirrors) to the selection list at this+0x1360.
	// Uses external editor globals (DAT_1061b728/b738/b7a8/b71c/b76c/b7a0) for symmetry mode.
	// DIVERGENCE: editor symmetry globals (DAT_1061b728 etc.) and FUN_1031fe20 (TArray remove)
	// are unresolved; full vertex selection with symmetry mirrors deferred.
	// Returns 0 (no selection made).
	return 0;
	unguard;
}
IMPL_GHIDRA_APPROX("Engine.dll", 0x15cac0, "FUN_1031fe20 (TArray element removal at index) unresolved; found entry not removed from selection list")
int ATerrainInfo::SelectVertexX(int X, int Y)
{
	// Ghidra 0x15cac0, 293b: search selection list at this+0x1360 (stride 0x14) for (X,Y).
	// If found: remove via FUN_1031fe20(i,1) and return 0.
	// If not found: append new entry and return 1.
	// Entry layout: [+0]=X, [+4]=Y, [+8]=heightmap_val, [+0xC]=strength(float), [+0x10]=0.
	// DIVERGENCE: FUN_1031fe20 (TArray element removal at index) is unresolved; found entry
	// is not removed from the selection list.
	FArray* list = (FArray*)((BYTE*)this + 0x1360);
	INT count = list->Num();
	INT off = 0;
	for (INT i = 0; i < count; i++, off += 0x14)
	{
		BYTE* base = (BYTE*)*(INT*)list;
		if (*(INT*)(base + off) == X && *(INT*)(base + off + 4) == Y)
		{
			// DIVERGENCE: FUN_1031fe20(i,1) = remove element at index i from TArray; unresolved.
			return 0;
		}
	}
	INT idx = list->Add(1, 0x14) * 0x14;
	BYTE* base = (BYTE*)*(INT*)list;
	*(INT*) (base + idx)          = X;
	*(INT*) (base + idx + 4)      = Y;
	*(FLOAT*)(base + idx + 0x0c)  = 0.5f; // DIVERGENCE: retail reads strength from editor global (DAT_1061b71c) / 100.0f; global unresolved, defaulting to 0.5
	*(DWORD*)(base + idx + 0x08)  = (DWORD)GetHeightmap(X, Y);
	*(INT*) (base + idx + 0x10)   = 0;
	return 1;
}
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::SelectVerticesInBox(FBox &)
{
	guard(ATerrainInfo::SelectVerticesInBox);
	unguard;
}
IMPL_APPROX("Writes packed bit into EdgeTurnBitmap at +0x137C")
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
IMPL_APPROX("Writes 16-bit height value at USize*Y+X in G16 heightmap texture")
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
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::SetLayerAlpha(float,float,int,BYTE,UTexture *)
{
	guard(ATerrainInfo::SetLayerAlpha);
	unguard;
}
IMPL_APPROX("Writes biased 4-bit nibble into packed planning floor map at +0x13C8")
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
IMPL_APPROX("Writes packed bit into QuadVisibilityBitmap at +0x1370")
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
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::SetTextureColor(int,int,UTexture *,FColor &)
{
	guard(ATerrainInfo::SetTextureColor);
	unguard;
}
IMPL_GHIDRA_APPROX("Engine.dll", 0x15c3c0, "Returns 1 (no hit); per-sector ray test FUN_1050557c unresolved")
int ATerrainInfo::LineCheck(FCheckResult &,FVector,FVector,FVector,int)
{
	guard(ATerrainInfo::LineCheck);
	// Ghidra 0x15c3c0, 1445 bytes: ray-terrain intersection test across all heightmap sectors.
	// DIVERGENCE: FUN_1050557c (per-sector ray test), rdtsc perf counters, and full sector
	// iteration tree are unresolved; returns 1 (no hit) pending full implementation.
	return 1;
	unguard;
}
IMPL_GHIDRA_APPROX("Engine.dll", 0x15a480, "Returns 1 (no hit); per-quad ray intersection structures and FUN_ calls unresolved")
int ATerrainInfo::LineCheckWithQuad(int,int,FCheckResult &,FVector,FVector,FVector,int)
{
	guard(ATerrainInfo::LineCheckWithQuad);
	// Ghidra 0x15a480, 7911 bytes: per-quad ray intersection (called from LineCheck).
	// Requires undeciphered sector/quad data structures and many unresolved FUN_ calls.
	// DIVERGENCE: returns 1 (no hit) pending full implementation.
	return 1;
	unguard;
}
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::MoveVertices(float)
{
	guard(ATerrainInfo::MoveVertices);
	unguard;
}
IMPL_GHIDRA("Engine.dll", 0x15c9a0)
int ATerrainInfo::PointCheck(FCheckResult& Result, FVector Location, FVector Extent, int ExtraNodeFlags)
{
	guard(ATerrainInfo::PointCheck);
	// Ghidra 0x15c9a0, 235b: vertical line check from Location.Z-Extent.Z to Location.Z+Extent.Z.
	// On hit, biases the float at Result+0x10 (likely Normal.X or a packed field) by +Extent.Z.
	FVector Start(Location.X, Location.Y, Location.Z - Extent.Z);
	FVector End(  Location.X, Location.Y, Location.Z + Extent.Z);
	if (LineCheck(Result, Start, End, Extent, ExtraNodeFlags) == 0)
	{
		*(FLOAT*)((BYTE*)&Result + 0x10) += Extent.Z;
		return 0;
	}
	return 1;
	unguard;
}
IMPL_GHIDRA("Engine.dll", 0x156780)
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
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::CalcLayerTexCoords()
{
	guard(ATerrainInfo::CalcLayerTexCoords);
	unguard;
}
IMPL_GHIDRA("Engine.dll", 0x1615a0)
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
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::CombineLayerWeights()
{
	guard(ATerrainInfo::CombineLayerWeights);
	unguard;
}
IMPL_TODO("Needs Ghidra analysis")
void ATerrainInfo::ConvertHeightmapFormat()
{
	guard(ATerrainInfo::ConvertHeightmapFormat);
	unguard;
}
IMPL_GHIDRA_APPROX("Engine.dll", 0x157560, "OutY parameter not assigned per Ghidra decompiler artifact")
int ATerrainInfo::GetClosestVertex(FVector& InOutPos, FVector* OutPos, int* OutX, int* OutY)
{
	// Ghidra 0x157560, 167b: transform world pos by WorldToHeightmap FCoords at this+0x1330,
	// round to integer indices, bounds-check, then snap InOutPos to the actual vertex world pos.
	// Ghidra uses unaff_EBX for one rounded coord and local_c[0] for the other.
	// param_4 (OutY): not assigned in Ghidra — possible decompiler artifact; left unchanged.
	FVector htPos = InOutPos.TransformPointBy(*(FCoords*)((BYTE*)this + 0x1330));
	INT iX = appRound(htPos.X);
	INT iY = appRound(htPos.Y);
	if (OutPos != NULL) *(INT*)OutPos = iX;
	if (OutX   != NULL) *OutX = iY;
	// OutY (param_4): not assigned in Ghidra — DIVERGENCE: left unchanged by caller.
	INT HeightmapX = *(INT*)((BYTE*)this + 0x12e0);
	INT HeightmapY = *(INT*)((BYTE*)this + 0x12e4);
	if (iX >= 0 && iY >= 0 && iX < HeightmapX && iY < HeightmapY)
	{
		// Vertex world-space position array at this+0x12d4 (3 DWORDs per vertex = FVector).
		DWORD* vertData = *(DWORD**)((BYTE*)this + 0x12d4);
		DWORD* entry    = vertData + (HeightmapX * iY + iX) * 3;
		*(DWORD*)&InOutPos.X = entry[0];
		*(DWORD*)&InOutPos.Y = entry[1];
		*(DWORD*)&InOutPos.Z = entry[2];
		return 1;
	}
	return 0;
}
IMPL_APPROX("Returns single bit from EdgeTurnBitmap at +0x137C")
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
IMPL_APPROX("Returns HeightmapX * Y + X linear heightmap index")
int ATerrainInfo::GetGlobalVertex(int X, int Y)
{
	// Retail: 8B 81 E0 12 00 00 0F AF 44 24 08 03 44 24 04 C2 08 00
	// return HeightmapX (at this+0x12E0) * Y + X.
	INT HeightmapX_val = *(INT*)((BYTE*)this + 0x12E0);
	return HeightmapX_val * Y + X;
}
IMPL_GHIDRA("Engine.dll", 0x157000)
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
IMPL_GHIDRA_APPROX("Engine.dll", 0x156de0, "Avoids FStaticTexture on stack; calls GetRawTextureData directly instead")
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
IMPL_APPROX("Reads biased 4-bit nibble from packed planning floor map at +0x13C8")
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
IMPL_APPROX("Returns single bit from QuadVisibilityBitmap at +0x1370")
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
IMPL_GHIDRA("Engine.dll", 0x15e8f0)
int ATerrainInfo::GetRenderCombinationNum(TArray<INT>& Layers, ETerrainRenderMethod Method)
{
	guard(ATerrainInfo::GetRenderCombinationNum);
	// Ghidra 0x15e8f0, 321b: search render combination cache at this+5000 (stride 0x14/entry).
	// Entry layout: TArray<INT>[+0..+8], ETerrainRenderMethod[+0xC], INT[+0x10].
	// Returns index of matching entry or appends a new one and returns its index.
	FArray* cache = (FArray*)((BYTE*)this + 5000);
	INT n = cache->Num();
	for (INT i = 0; i < n; i++)
	{
		BYTE* ep        = (BYTE*)*(INT*)cache + i * 0x14;
		TArray<INT>* eL = (TArray<INT>*)ep;
		if (*(ETerrainRenderMethod*)(ep + 0x0c) == Method && eL->Num() == Layers.Num())
		{
			UBOOL ok = 1;
			for (INT j = 0; j < Layers.Num(); j++)
				if ((*eL)(j) != Layers(j)) { ok = 0; break; }
			if (ok) return i;
		}
	}
	INT idx = cache->Add(1, 0x14);
	BYTE* ne        = (BYTE*)*(INT*)cache + idx * 0x14;
	new ((TArray<INT>*)ne) TArray<INT>();
	*(INT*)(ne + 0x10) = 0;
	TArray<INT>* nL = (TArray<INT>*)ne;
	nL->Add(Layers.Num());
	for (INT j = 0; j < Layers.Num(); j++)
		(*nL)(j) = Layers(j);
	*(ETerrainRenderMethod*)(ne + 0x0c) = Method;
	return idx;
	unguard;
}
IMPL_TODO("Needs Ghidra analysis")
FBox ATerrainInfo::GetSelectedVerticesBounds()
{
	return FBox();
}
IMPL_TODO("Needs Ghidra analysis")
FColor ATerrainInfo::GetTextureColor(int,int,UTexture *)
{
	return FColor(0,0,0,0);
}
IMPL_TODO("Needs Ghidra analysis")
FVector ATerrainInfo::GetVertexNormal(int,int)
{
	return FVector(0,0,0);
}
IMPL_APPROX("Transforms heightmap position to world space via FCoords at +0x1300")
FVector ATerrainInfo::HeightmapToWorld(FVector In)
{
	// Retail: 29b. ECX=this+0x1300 (world FCoords), call FVector::TransformPointBy.
	return In.TransformPointBy(*(FCoords*)((BYTE*)this + 0x1300));
}
IMPL_GHIDRA_APPROX("Engine.dll", 0x164cf0, "Omits legacy version-gated serialization paths prior to version 0x53")
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
IMPL_GHIDRA("Engine.dll", 0x977b0)
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
IMPL_GHIDRA("Engine.dll", 0x1566f0)
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
IMPL_GHIDRA_APPROX("Engine.dll", 0x155c0, "Lazy creation of UTerrainPrimitive via StaticAllocateObject omitted")
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
IMPL_GHIDRA("Engine.dll", 0x97f0)
FTerrainMaterialLayer::FTerrainMaterialLayer()
{
	guard(FTerrainMaterialLayer::FTerrainMaterialLayer);
	// Ghidra 0x97f0: FMatrix member at +8 is default-constructed.
	new ((BYTE*)this + 8) FMatrix();
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x9800)
FTerrainMaterialLayer::~FTerrainMaterialLayer()
{
	guard(FTerrainMaterialLayer::~FTerrainMaterialLayer);
	// Ghidra 0x9800: destroy FMatrix member at +8.
	((FMatrix*)((BYTE*)this + 8))->~FMatrix();
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x9810)
FTerrainMaterialLayer& FTerrainMaterialLayer::operator=(const FTerrainMaterialLayer& Other)
{
	// Ghidra 0x9810: shares address with FKCylinderElem::operator= (same-size flat copy, no vtable)
	appMemcpy(this, &Other, sizeof(FTerrainMaterialLayer));
	return *this;
}


// --- FTerrainTools ---
IMPL_APPROX("Writes Value to terrain brush adjust field at indirect struct+0x60")
void FTerrainTools::SetAdjust(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x60) = Value;
}

IMPL_GHIDRA("Engine.dll", 0x1665d0)
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

IMPL_APPROX("Updates current terrain info pointer and clears related brush/selection fields")
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

IMPL_APPROX("Clamps value to minimum -7 and stores in Pad[0x40]")
void FTerrainTools::SetFloorOffset(int Value)
{
	// Retail: 20b. Clamp to minimum of -7 only; no upper clamp.
	if (Value < -7) Value = -7;
	*(INT*)&Pad[0x40] = Value;
}

IMPL_APPROX("Writes Value to terrain brush inner radius field at indirect struct+0x54")
void FTerrainTools::SetInnerRadius(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x54) = Value;
}

IMPL_APPROX("Writes Value to terrain brush mirror axis field at indirect struct+0x64")
void FTerrainTools::SetMirrorAxis(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x64) = Value;
}

IMPL_APPROX("Writes Value to terrain brush outer radius field at indirect struct+0x58")
void FTerrainTools::SetOuterRadius(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x58) = Value;
}

IMPL_APPROX("Writes Value to terrain brush strength field at indirect struct+0x5C")
void FTerrainTools::SetStrength(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x5C) = Value;
}

IMPL_TODO("Needs Ghidra analysis")
FTerrainTools::FTerrainTools(FTerrainTools const &)
{
	guard(FTerrainTools::FTerrainTools);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
FTerrainTools::~FTerrainTools()
{
	guard(FTerrainTools::~FTerrainTools);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void FTerrainTools::AdjustAlignedActors()
{
	guard(FTerrainTools::AdjustAlignedActors);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void FTerrainTools::FindActorsToAlign()
{
	guard(FTerrainTools::FindActorsToAlign);
	unguard;
}

IMPL_APPROX("Returns adjust value from active brush struct or fallback at Pad[0x88]")
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

IMPL_APPROX("Returns terrain info pointer from Pad[0x78]")
ATerrainInfo * FTerrainTools::GetCurrentTerrainInfo()
{
	// Ghidra (4B): return pointer at Pad[0x78]
	return *(ATerrainInfo**)&Pad[0x78];
}

IMPL_TODO("Needs Ghidra analysis")
FString FTerrainTools::GetExecFromBrushName(FString &)
{
	return FString();
}

IMPL_APPROX("Returns floor offset stored in Pad[0x40]")
int FTerrainTools::GetFloorOffset()
{
	// Ghidra (4B): direct read from Pad[0x40]
	return *(INT*)&Pad[0x40];
}

IMPL_APPROX("Returns inner radius from active brush struct or fallback at Pad[0x7C]")
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

IMPL_APPROX("Returns mirror axis from active brush struct or fallback at Pad[0x8C]")
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

IMPL_APPROX("Returns outer radius from active brush struct or fallback at Pad[0x80]")
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

IMPL_APPROX("Returns strength from active brush struct or fallback at Pad[0x84]")
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

IMPL_TODO("Needs Ghidra analysis")
void FTerrainTools::Init()
{
	guard(FTerrainTools::Init);
	unguard;
}


// --- UTerrainMaterial ---
IMPL_APPROX("Returns this; UTerrainMaterial is its own fallback material")
UMaterial * UTerrainMaterial::CheckFallback()
{
	return this;
}

IMPL_GHIDRA("Engine.dll", 0x15d6c0)
int UTerrainMaterial::HasFallback()
{
	guard(UTerrainMaterial::HasFallback);
	// Ghidra 0x15d6c0: if bit 0 of this+0x34 is clear, check TArray<UObject*> at this+0x60;
	// if non-empty and first element IsA UShader, call HasFallback() on it via vtable[0x22].
	// Returns 0 if flag set, array empty, not a UShader, or shader reports no fallback.
	if ((*(BYTE*)((BYTE*)this + 0x34) & 1) == 0)
	{
		FArray* arr = (FArray*)((BYTE*)this + 0x60);
		if (arr->Num() != 0)
		{
			UObject* first = *(UObject**)(*(INT*)arr);  // first element (Data[0])
			if (first != NULL && first->IsA(UShader::StaticClass()))
			{
				typedef INT (__thiscall* HasFallbackFn)(UObject*);
				return ((HasFallbackFn)(*(INT*)(*(INT*)first + 0x88)))(first);
			}
		}
	}
	return 0;
	unguard;
}


// ============================================================================
// UTerrainSector / UTerrainPrimitive constructors
// (moved from EngineStubs.cpp)
// ============================================================================

// ??0UTerrainSector@@QAE@PAVATerrainInfo@@HHHH@Z
IMPL_TODO("Needs Ghidra analysis")
UTerrainSector::UTerrainSector(ATerrainInfo*, INT, INT, INT, INT) {}

// ??0UTerrainPrimitive@@QAE@PAVATerrainInfo@@@Z
IMPL_TODO("Needs Ghidra analysis")
UTerrainPrimitive::UTerrainPrimitive(ATerrainInfo*) {}

// --- Moved from EngineStubs.cpp ---
IMPL_APPROX("Delegates to UPrimitive::Serialize")
void UTerrainPrimitive::Serialize(FArchive& Ar) { UPrimitive::Serialize(Ar); }
IMPL_TODO("Needs Ghidra analysis")
INT UTerrainPrimitive::LineCheck(FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD) { return 1; }
IMPL_TODO("Needs Ghidra analysis")
INT UTerrainPrimitive::PointCheck(FCheckResult&, AActor*, FVector, FVector, DWORD) { return 1; }
IMPL_TODO("Needs Ghidra analysis")
void UTerrainPrimitive::Illuminate(AActor*, INT) {}
IMPL_TODO("Needs Ghidra analysis")
FBox UTerrainPrimitive::GetRenderBoundingBox(const AActor*, INT) { return FBox(); }

IMPL_APPROX("Delegates to UObject::Serialize")
void UTerrainSector::Serialize(FArchive& Ar) { UObject::Serialize(Ar); }
IMPL_TODO("Needs Ghidra analysis")
void UTerrainSector::PostLoad() {}
IMPL_TODO("Needs Ghidra analysis")
void UTerrainSector::StaticLight(INT) {}
IMPL_TODO("Needs Ghidra analysis")
void UTerrainSector::GenerateTriangles() {}
// Ghidra at 0x156550. Returns linear index in the global heightmap grid.
IMPL_GHIDRA("Engine.dll", 0x156550)
INT UTerrainSector::GetGlobalVertex(INT X, INT Y) {
	// TerrainInfo->HeightmapX is at offset 0x12E0 in ATerrainInfo
	INT HeightmapX = *(INT*)((BYTE*)TerrainInfo + 0x12E0);
	return (OffsetY + Y) * HeightmapX + OffsetX + X;
}

// Ghidra at 0x153a0. Returns linear index within this sector.
IMPL_GHIDRA("Engine.dll", 0x153a0)
INT UTerrainSector::GetLocalVertex(INT X, INT Y) {
	return (SectorSizeX + 1) * Y + X;
}
IMPL_TODO("Needs Ghidra analysis")
INT UTerrainSector::PassShouldRenderTriangle(INT, INT, INT, INT, INT) { return 1; }
// ?IsSectorAll@UTerrainSector@@QAEHHE@Z  Ghidra at ~0x107bae30 (336 bytes).
// Gets the alpha texture for the layer, computes texel range for this sector,
// then checks that every texel matches 'value'. Returns 1 (true) on empty range.
IMPL_GHIDRA("Engine.dll", 0x107bae30)
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
IMPL_TODO("Needs Ghidra analysis")
INT UTerrainSector::IsTriangleAll(INT, INT, INT, INT, INT, BYTE) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void UTerrainSector::AttachProjector(AProjector*, FProjectorRenderInfo*) {}
