/*=============================================================================
	UnTerrain.cpp: Terrain system (ATerrainInfo, FTerrainTools)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

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
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 802B at 0x10460de0")
void ATerrainInfo::SetupSectors()
{
	guard(ATerrainInfo::SetupSectors);
	unguard;
}

IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 121B at 0x1045cea0")
void ATerrainInfo::SoftDeselect()
{
	guard(ATerrainInfo::SoftDeselect);
	unguard;
}

IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 252B at 0x10461220")
void ATerrainInfo::UpdateFromSelectedVertices()
{
	guard(ATerrainInfo::UpdateFromSelectedVertices);
	unguard;
}

IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 163B at 0x10461760")
void ATerrainInfo::ResetMove()
{
	guard(ATerrainInfo::ResetMove);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10464960)
void ATerrainInfo::PostEditChange()
{
	guard(ATerrainInfo::PostEditChange);
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
	unguard;
}

IMPL_TODO("virtual base no-op — subclass overrides - retail has 810B at 0x10459b10")
void ATerrainInfo::PostLoad()
{
	guard(ATerrainInfo::PostLoad);
	unguard;
}

IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 416B at 0x10459710")
void ATerrainInfo::PrecomputeLayerWeights()
{
	guard(ATerrainInfo::PrecomputeLayerWeights);
	unguard;
}

// (merged from earlier occurrence)
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 1286B at 0x10457610")
void ATerrainInfo::SoftSelect(float,float)
{
	guard(ATerrainInfo::SoftSelect);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x10461140)
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
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 2268B at 0x1045d780")
void ATerrainInfo::UpdateDecorations(int)
{
	guard(ATerrainInfo::UpdateDecorations);
	unguard;
}
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 163B at 0x10460710")
void ATerrainInfo::UpdateTriangles(int,int,int,int,int)
{
	guard(ATerrainInfo::UpdateTriangles);
	unguard;
}
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 1465B at 0x10459e90")
void ATerrainInfo::UpdateVertices(float,int,int,int,int)
{
	guard(ATerrainInfo::UpdateVertices);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x10315660)
FVector ATerrainInfo::WorldToHeightmap(FVector In)
{
	// Retail: 29b. ECX=this+0x1330 (heightmap FCoords), call FVector::TransformPointBy.
	return In.TransformPointBy(*(FCoords*)((BYTE*)this + 0x1330));
}
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 8875B at 0x10461840")
void ATerrainInfo::Render(FLevelSceneNode *,FRenderInterface *,FVisibilityInterface *)
{
	guard(ATerrainInfo::Render);
	unguard;
}
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 2971B at 0x1045ea70")
void ATerrainInfo::RenderDecorations(FLevelSceneNode *,FRenderInterface *,FVisibilityInterface *)
{
	guard(ATerrainInfo::RenderDecorations);
	unguard;
}
IMPL_DIVERGE("permanent: editor-only terrain vertex selection with symmetry mirrors; requires DAT editor globals (DAT_1061bXXX) and TArray remove helpers — editor terrain tools are out of scope")
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
IMPL_DIVERGE("permanent: editor-only terrain vertex selection helper; requires DAT editor globals (DAT_1061b71c/b7a0/b76c) for selection strength — editor terrain tools are out of scope")
int ATerrainInfo::SelectVertexX(int X, int Y)
{
	// Ghidra 0x15cac0, 293b: search selection list at this+0x1360 (stride 0x14) for (X,Y).
	// If found: remove via FArray::Remove(i,1,0x14) and return 0.
	// If not found: append new entry and return 1.
	// Entry layout: [+0]=X, [+4]=Y, [+8]=heightmap_val, [+0xC]=strength(float), [+0x10]=0.
	// DIVERGENCE: retail reads selection strength from editor globals (DAT_1061b71c/b7a0/b76c);
	// globals unresolved, strength defaulted to 0.5f.
	FArray* list = (FArray*)((BYTE*)this + 0x1360);
	INT count = list->Num();
	INT off = 0;
	for (INT i = 0; i < count; i++, off += 0x14)
	{
		BYTE* base = (BYTE*)*(INT*)list;
		if (*(INT*)(base + off) == X && *(INT*)(base + off + 4) == Y)
		{
			list->Remove(i, 1, 0x14);
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
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 421B at 0x1045cf50")
void ATerrainInfo::SelectVerticesInBox(FBox &)
{
	guard(ATerrainInfo::SelectVerticesInBox);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1031c8f0)
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
IMPL_MATCH("Engine.dll", 0x10457060)
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
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 174B at 0x104568c0")
void ATerrainInfo::SetLayerAlpha(float,float,int,BYTE,UTexture *)
{
	guard(ATerrainInfo::SetLayerAlpha);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x104570d0)
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
IMPL_MATCH("Engine.dll", 0x1031c860)
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
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 124B at 0x10456f80")
void ATerrainInfo::SetTextureColor(int,int,UTexture *,FColor &)
{
	guard(ATerrainInfo::SetTextureColor);
	unguard;
}
IMPL_DIVERGE("Ghidra 0x1045C3C0 (1445b): MSVC x87 FPU register allocation confuses Ghidra's coord-transform decompilation — exact float variable mapping cannot be recovered without full x87 stack disassembly trace. Algorithm understood but not reproducible from Ghidra output alone.")
int ATerrainInfo::LineCheck(FCheckResult &,FVector,FVector,FVector,int)
{
	guard(ATerrainInfo::LineCheck);
	// Ghidra 0x15c3c0, 1445 bytes: transform ray to heightmap space, iterate quads, call
	// LineCheckWithQuad. FUN_1050557c = __ftol2_sse = (INT)(float). All FUN_ in _unnamed.cpp.
	// Blocked: MSVC x87 FPU register allocation confuses Ghidra's coord-transform decompilation.
	// Algorithm is understood; floating-point variable mapping cannot be verified without disasm.
	return 1;
	unguard;
}
IMPL_DIVERGE("Ghidra 0x1045A480 (7911b): 7911 bytes of heavily-optimised MSVC FPU/SSE code with register aliasing — per-quad triangle intersection math not recoverable from Ghidra decompilation alone. Not tractable without full x87/SSE register trace.")
int ATerrainInfo::LineCheckWithQuad(int,int,FCheckResult &,FVector,FVector,FVector,int)
{
	guard(ATerrainInfo::LineCheckWithQuad);
	// Ghidra 0x15a480, 7911 bytes: per-quad ray-triangle intersection (called from LineCheck).
	// All FUN_ helpers in _unnamed.cpp (no permanent blockers). Blocked by 7911 bytes of
	// heavily-optimised FPU/SSE code with register aliasing; not tractable from Ghidra alone.
	return 1;
	unguard;
}
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 227B at 0x10461640")
void ATerrainInfo::MoveVertices(float)
{
	guard(ATerrainInfo::MoveVertices);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1045c9a0)
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
IMPL_MATCH("Engine.dll", 0x10456780)
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
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 573B at 0x104572f0")
void ATerrainInfo::CalcLayerTexCoords()
{
	guard(ATerrainInfo::CalcLayerTexCoords);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x104615a0)
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
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 479B at 0x104598e0")
void ATerrainInfo::CombineLayerWeights()
{
	guard(ATerrainInfo::CombineLayerWeights);
	unguard;
}
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 250B at 0x1045cd70")
void ATerrainInfo::ConvertHeightmapFormat()
{
	guard(ATerrainInfo::ConvertHeightmapFormat);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x10457560)
int ATerrainInfo::GetClosestVertex(FVector& InOutPos, FVector* OutPos, int* OutX, int* OutY)
{
	// Ghidra 0x157560, 167b: transform world pos by WorldToHeightmap FCoords at this+0x1330,
	// round to integer indices, bounds-check, then snap InOutPos to the actual vertex world pos.
	// param_4 (OutY): not assigned in Ghidra (confirmed decompiler artifact — retail also skips it).
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
IMPL_MATCH("Engine.dll", 0x1031c8b0)
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
IMPL_MATCH("Engine.dll", 0x104566b0)
int ATerrainInfo::GetGlobalVertex(int X, int Y)
{
	// Retail: 8B 81 E0 12 00 00 0F AF 44 24 08 03 44 24 04 C2 08 00
	// return HeightmapX (at this+0x12E0) * Y + X.
	INT HeightmapX_val = *(INT*)((BYTE*)this + 0x12E0);
	return HeightmapX_val * Y + X;
}
IMPL_MATCH("Engine.dll", 0x10457000)
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
IMPL_MATCH("Engine.dll", 0x10456de0)
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
IMPL_MATCH("Engine.dll", 0x10457090)
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
IMPL_MATCH("Engine.dll", 0x1031c820)
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
IMPL_MATCH("Engine.dll", 0x1045e8f0)
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
IMPL_MATCH("Engine.dll", 0x10457b60)
FBox ATerrainInfo::GetSelectedVerticesBounds()
{
	guard(ATerrainInfo::GetSelectedVerticesBounds);
	INT HeightmapX = *(INT*)((BYTE*)this + 0x12E0);
	INT HeightmapY = *(INT*)((BYTE*)this + 0x12E4);
	// Retail initialises FBox with inverted extremes so the first vertex sets the real bounds.
	FBox bounds(FVector((FLOAT)HeightmapX, (FLOAT)HeightmapY, 0.0f),
	            FVector(-(FLOAT)HeightmapX, -(FLOAT)HeightmapY, 0.0f));
	FArray* list = (FArray*)((BYTE*)this + 0x1360);
	for (INT i = 0; i < list->Num(); i++)
	{
		BYTE* data = *(BYTE**)list;
		FLOAT vX = (FLOAT)*(INT*)(data + i * 0x14);
		FLOAT vY = (FLOAT)*(INT*)(data + i * 0x14 + 4);
		bounds += FVector(vX, vY, 0.0f);
	}
	return bounds;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x10456F00)
FColor ATerrainInfo::GetTextureColor(int X, int Y, UTexture* Tex)
{
	guardSlow(ATerrainInfo::GetTextureColor);
	// Ghidra 0x156f00: scale (X,Y) to texture coordinates, read RGBA8888 texel.
	if (!Tex) return FColor(0,0,0,0);
	INT terrainW = *(INT*)((BYTE*)this + 0x12e0);
	INT terrainH = *(INT*)((BYTE*)this + 0x12e4);
	INT uSize = *(INT*)((BYTE*)Tex + 0x60);
	INT vSize = *(INT*)((BYTE*)Tex + 0x64);
	FStaticTexture StaticTex(Tex);
	void* texData = StaticTex.GetRawTextureData(0);
	if (texData && *(BYTE*)((BYTE*)Tex + 0x58) == 5) // format 5 = RGBA8888
	{
		INT texelRow = (vSize * Y) / terrainH;
		INT texelCol = (uSize * X) / terrainW;
		INT idx = uSize * texelRow + texelCol;
		FColor result;
		appMemcpy(&result, (BYTE*)texData + idx * 4, 4);
		return result;
	}
	return FColor(0,0,0,0);
	unguardSlow;
}
IMPL_MATCH("Engine.dll", 0x10457140)
FVector ATerrainInfo::GetVertexNormal(int X, int Y)
{
	guardSlow(ATerrainInfo::GetVertexNormal);
	// Ghidra 0x10457140, 428 bytes: accumulate pre-computed normal pairs from vertex
	// data array at this+0x12F4 (entry = 6 floats = 2 FVector3 half-normals).
	// Sums contributions from up to 4 adjacent vertices (current, left, upper, diagonal).
	// Normalises result; negates if flip-normal flag (bit 0 of this+0x12b4) is set.
	INT HeightmapX = *(INT*)((BYTE*)this + 0x12e0);
	BYTE* vtxBase  = *(BYTE**)((BYTE*)this + 0x12f4);

	FLOAT nx = 0.f, ny = 0.f, nz = 0.f;

	// accumulate both half-normals from a vertex entry — lambda rewritten for MSVC 7.1
	// auto accumEntry = [&](INT ex, INT ey) { ... }
#define accumEntry(ex, ey) do { \
	FLOAT* _e = (FLOAT*)(vtxBase + (HeightmapX * (ey) + (ex)) * 0x18); \
	nx += _e[0] + _e[3]; ny += _e[1] + _e[4]; nz += _e[2] + _e[5]; \
} while(0)

	accumEntry(X,     Y);
	if (X > 0)             accumEntry(X - 1, Y);
	if (Y > 0)             accumEntry(X,     Y - 1);
	if (X > 0 && Y > 0)   accumEntry(X - 1, Y - 1);
#undef accumEntry

	FVector N(nx, ny, nz);
	FVector Safe = N.SafeNormal();

	// Retail: if bit 0 of this+0x12b4 is set, return negated normal.
	if (*(BYTE*)((BYTE*)this + 0x12b4) & 1)
		Safe = FVector(-Safe.X, -Safe.Y, -Safe.Z);

	return Safe;
	unguardSlow;
}
IMPL_MATCH("Engine.dll", 0x10315640)
FVector ATerrainInfo::HeightmapToWorld(FVector In)
{
	// Retail: 29b. ECX=this+0x1300 (world FCoords), call FVector::TransformPointBy.
	return In.TransformPointBy(*(FCoords*)((BYTE*)this + 0x1300));
}
// Helper: serialize a TArray with FCompactIndex count + bulk POD data.
// Matches the pattern used by all FUN_104xxxxx TArray helpers (stride = element size).
static void SerializeFixedTArray(FArchive& Ar, FArray& A, INT Stride)
{
	if (Ar.IsLoading())
	{
		FCompactIndex ci;
		Ar << ci;
		INT n = *(INT*)&ci;
		A.Empty(Stride, 0);
		if (n > 0) A.Add(n, Stride);
		if (n > 0) Ar.Serialize(A.GetData(), n * Stride);
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);  // FArray.ArrayNum as compact index
		INT n = A.Num();
		if (n > 0) Ar.Serialize(A.GetData(), n * Stride);
	}
}

// Helper: serialize a TArray<UObject*> (stride 4, each element via Ar << UObject*&).
// Matches FUN_1045e240.
static void SerializeUObjTArray(FArchive& Ar, FArray& A)
{
	if (Ar.IsLoading())
	{
		FCompactIndex ci;
		Ar << ci;
		INT n = *(INT*)&ci;
		A.Empty(4, 0);
		if (n > 0) A.Add(n, 4);
		for (INT i = 0; i < n; i++)
			Ar << *(UObject**)((BYTE*)A.GetData() + i * 4);
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		INT n = A.Num();
		for (INT i = 0; i < n; i++)
			Ar << *(UObject**)((BYTE*)A.GetData() + i * 4);
	}
}

// Helper: serialize a TArray<WORD> (stride 2).  Matches FUN_1031e600.
static void SerializeWordTArray(FArchive& Ar, FArray& A)
{
	if (Ar.IsLoading())
	{
		FCompactIndex ci;
		Ar << ci;
		INT n = *(INT*)&ci;
		A.Empty(2, 0);
		if (n > 0) A.Add(n, 2);
		for (INT i = 0; i < n; i++)
			Ar.ByteOrderSerialize((BYTE*)A.GetData() + i * 2, 2);
	}
	else
	{
		Ar << *(FCompactIndex*)((BYTE*)&A + 4);
		INT n = A.Num();
		for (INT i = 0; i < n; i++)
			Ar.ByteOrderSerialize((BYTE*)A.GetData() + i * 2, 2);
	}
}

IMPL_DIVERGE("Counting-path render buffers omitted; legacy ver<0x4c/0x52/0x53 paths omitted (Ravenshield always ver>=0x73). Ghidra 0x10464CF0")
void ATerrainInfo::Serialize(FArchive& Ar)
{
	guard(ATerrainInfo::Serialize);
	// Ghidra 0x164cf0 (891b).
	// DIVERGENCE: legacy version-gated paths (ver < 0x4c / 0x52 / 0x53) omitted.
	// The "neither loading nor saving" (counting) path is omitted; it serializes
	// render data structures (this+0x1360, 0x12bc, 0x136c, 0x344, 0x12f0, 0x1394, 0x13ac, 5000)
	// that are runtime-only and not needed for load/save correctness.

	AActor::Serialize(Ar);

	// Sectors: TArray<UTerrainSector*> at +0x12C8 (stride 4, UObject* each).
	// FUN_1045e240
	SerializeUObjTArray(Ar, *(FArray*)((BYTE*)this + 0x12C8));

	// Vertices: TArray<FVector> at +0x12D4 (stride 12).
	// FUN_10321a80
	SerializeFixedTArray(Ar, *(FArray*)((BYTE*)this + 0x12D4), 12);

	// HeightmapX-related INT fields at +0x12E8/+0x12EC.
	Ar.ByteOrderSerialize((BYTE*)this + 0x12E8, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x12EC, 4);

	// Vertex normals: TArray<{FVector,FVector}> at +0x12F4 (stride 24 = 2×FVector).
	// FUN_1045e340
	SerializeFixedTArray(Ar, *(FArray*)((BYTE*)this + 0x12F4), 0x18);

	// Legacy < ver 0x53: temp TArray<FPlane> (stride 0x10); read and discard.
	if (Ar.Ver() < 0x53)
	{
		FArray tmp;
		appMemzero(&tmp, sizeof(tmp));
		SerializeFixedTArray(Ar, tmp, 0x10);
		tmp.Empty(0x10, 0);
	}

	// FCoords HeightmapToWorld at +0x1300 and WorldToHeightmap at +0x1330 (48 bytes each).
	// FUN_103cbaa0: serializes all 12 floats of FCoords via ByteOrderSerialize.
	Ar.ByteOrderSerialize((BYTE*)this + 0x1300, 48);
	Ar.ByteOrderSerialize((BYTE*)this + 0x1330, 48);

	// Legacy < ver 0x4C: TArray<WORD> at +0x13BC.
	// FUN_1031e600
	if (Ar.Ver() < 0x4C)
		SerializeWordTArray(Ar, *(FArray*)((BYTE*)this + 0x13BC));

	// HeightmapX/Y dimensions at +0x12E0/+0x12E4.
	Ar.ByteOrderSerialize((BYTE*)this + 0x12E0, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x12E4, 4);

	// Legacy 0x4A < ver < 0x52: 16 temporary layer entries with 7 floats + FString each.
	// DIVERGENCE: omitted (ancient format; Ravenshield ships ver >= 0x73).

	// On load: propagate heightmap ref to +0x13B8.
	if (Ar.IsLoading())
		*(DWORD*)((BYTE*)this + 0x13B8) = *(DWORD*)((BYTE*)this + 0x398);

	// Ver 0x56 / 0x57 only: QuadVisibilityBitmap at +0x1370 (stride 4).
	// FUN_1037fbd0
	if (Ar.Ver() == 0x56 || Ar.Ver() == 0x57)
		SerializeFixedTArray(Ar, *(FArray*)((BYTE*)this + 0x1370), 4);

	// Legacy < ver 0x73: zero render-cache entries in sectors array at +0x12A8.
	if (Ar.Ver() < 0x73)
	{
		FArray* sectors2 = (FArray*)((BYTE*)this + 0x12A8);
		for (INT i = 0; i < sectors2->Num(); i++)
		{
			BYTE* e = (BYTE*)sectors2->GetData() + i * 0x58;
			*(DWORD*)(e + 0x50) = 0;
			*(DWORD*)(e + 0x54) = 0;
		}
	}

	// Ver > 0x74: TArray at +0x13A0 (stride 4).
	// FUN_104170d0
	if (Ar.Ver() > 0x74)
		SerializeFixedTArray(Ar, *(FArray*)((BYTE*)this + 0x13A0), 4);

	// PlanningFloorMap: TArray<INT> at +0x13C8 (stride 4); empty on old licensee ver.
	// FUN_1037fbd0
	if (Ar.LicenseeVer() < 10)
		((FArray*)((BYTE*)this + 0x13C8))->Empty(4, 0);
	else
		SerializeFixedTArray(Ar, *(FArray*)((BYTE*)this + 0x13C8), 4);

	// Mark terrain dirty for rebuild.
	*(DWORD*)((BYTE*)this + 0x12B4) |= 4;

	unguard;
}
IMPL_MATCH("Engine.dll", 0x103977b0)
void ATerrainInfo::CheckForErrors()
{
	guard(ATerrainInfo::CheckForErrors);
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
	unguard;
}
IMPL_MATCH("Engine.dll", 0x104566f0)
void ATerrainInfo::Destroy()
{
	guard(ATerrainInfo::Destroy);
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
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103155c0)
UPrimitive* ATerrainInfo::GetPrimitive()
{
	// Ghidra 0x155c0 (119b): if sector list empty defer to AActor; otherwise return/lazy-create
	// UTerrainPrimitive at this+0x12f0 via StaticAllocateObject + placement-new constructor.
	TArray<INT>* sectors = (TArray<INT>*)((BYTE*)this + 0x12C8);
	if (sectors->Num() == 0)
		return AActor::GetPrimitive();
	UPrimitive*& cached = *(UPrimitive**)((BYTE*)this + 0x12F0);
	if (!cached)
	{
		UObject* obj = UObject::StaticAllocateObject(
			UTerrainPrimitive::StaticClass(), this, NAME_None, 0, NULL, GError);
		if (obj)
		{
			cached = new(obj) UTerrainPrimitive(this);
			return cached;
		}
		cached = NULL;
		return NULL;
	}
	return cached;
}


// --- FTerrainMaterialLayer ---
IMPL_MATCH("Engine.dll", 0x103097f0)
FTerrainMaterialLayer::FTerrainMaterialLayer()
{
	guardSlow(FTerrainMaterialLayer::FTerrainMaterialLayer);
	// Ghidra 0x97f0: FMatrix member at +8 is default-constructed.
	new ((BYTE*)this + 8) FMatrix();
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10309800)
FTerrainMaterialLayer::~FTerrainMaterialLayer()
{
	guardSlow(FTerrainMaterialLayer::~FTerrainMaterialLayer);
	// Ghidra 0x9800: destroy FMatrix member at +8.
	((FMatrix*)((BYTE*)this + 8))->~FMatrix();
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10309810)
FTerrainMaterialLayer& FTerrainMaterialLayer::operator=(const FTerrainMaterialLayer& Other)
{
	// Ghidra 0x9810: shares address with FKCylinderElem::operator= (same-size flat copy, no vtable)
	appMemcpy(this, &Other, sizeof(FTerrainMaterialLayer));
	return *this;
}


// --- FTerrainTools ---
IMPL_MATCH("Engine.dll", 0x10316050)
void FTerrainTools::SetAdjust(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x60) = Value;
}

IMPL_MATCH("Engine.dll", 0x104665d0)
void FTerrainTools::SetCurrentBrush(int BrushID)
{
	guard(FTerrainTools::SetCurrentBrush);
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
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10465a10)
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

IMPL_MATCH("Engine.dll", 0x1031c940)
void FTerrainTools::SetFloorOffset(int Value)
{
	// Retail: 20b. Clamp to minimum of -7 only; no upper clamp.
	if (Value < -7) Value = -7;
	*(INT*)&Pad[0x40] = Value;
}

IMPL_MATCH("Engine.dll", 0x10315fc0)
void FTerrainTools::SetInnerRadius(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x54) = Value;
}

IMPL_MATCH("Engine.dll", 0x10316080)
void FTerrainTools::SetMirrorAxis(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x64) = Value;
}

IMPL_MATCH("Engine.dll", 0x10315ff0)
void FTerrainTools::SetOuterRadius(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x58) = Value;
}

IMPL_MATCH("Engine.dll", 0x10316020)
void FTerrainTools::SetStrength(int Value)
{
	// Retail: 20b. No-op if Pad[0] (this+0x04) is null (cross-function-jump).
	if (*(INT**)&Pad[0])
		*(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x5C) = Value;
}

IMPL_EMPTY("terrain editor tool — not needed for runtime gameplay")
FTerrainTools::FTerrainTools(FTerrainTools const &)
{
	guard(FTerrainTools::FTerrainTools);
	unguard;
}

IMPL_EMPTY("terrain editor tool — not needed for runtime gameplay")
FTerrainTools::~FTerrainTools()
{
	guard(FTerrainTools::~FTerrainTools);
	unguard;
}

IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 456B at 0x104669f0")
void FTerrainTools::AdjustAlignedActors()
{
	guard(FTerrainTools::AdjustAlignedActors);
	unguard;
}

IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 746B at 0x104666d0")
void FTerrainTools::FindActorsToAlign()
{
	guard(FTerrainTools::FindActorsToAlign);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10315f80)
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

IMPL_MATCH("Engine.dll", 0x103701c0)
ATerrainInfo * FTerrainTools::GetCurrentTerrainInfo()
{
	// Ghidra (4B): return pointer at Pad[0x78]
	return *(ATerrainInfo**)&Pad[0x78];
}

IMPL_MATCH("Engine.dll", 0x104662c0)
FString FTerrainTools::GetExecFromBrushName(FString& Name)
{
	guard(FTerrainTools::GetExecFromBrushName);
	// Brush list at this+0x48 (stride 0x68): entry+0x04 = name FString, entry+0x10 = exec FString.
	FArray* list = (FArray*)((BYTE*)this + 0x48);
	for (INT i = 0; i < list->Num(); i++)
	{
		BYTE* elem = *(BYTE**)list + i * 0x68;
		if (*(FString*)(elem + 0x04) == Name)
			return FString(*(FString*)(elem + 0x10));
	}
	return FString(TEXT("NONE"));
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10316720)
int FTerrainTools::GetFloorOffset()
{
	// Ghidra (4B): direct read from Pad[0x40]
	return *(INT*)&Pad[0x40];
}

IMPL_MATCH("Engine.dll", 0x10315f20)
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

IMPL_MATCH("Engine.dll", 0x10315fa0)
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

IMPL_MATCH("Engine.dll", 0x10315f40)
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

IMPL_MATCH("Engine.dll", 0x10315f60)
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

IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 738B at 0x10467240")
void FTerrainTools::Init()
{
	guard(FTerrainTools::Init);
	unguard;
}


// --- UTerrainMaterial ---
IMPL_MATCH("Engine.dll", 0x10301a90)
UMaterial * UTerrainMaterial::CheckFallback()
{
	return this;
}

IMPL_MATCH("Engine.dll", 0x1045d6c0)
int UTerrainMaterial::HasFallback()
{
	guard(UTerrainMaterial::HasFallback);
	// Ghidra 0x15d6c0: if bit 0 of this+0x34 is set, return 0 immediately;
	// otherwise check TArray<UObject*> at this+0x60;
	// if non-empty and first element IsA UShader, call HasFallback() on it via vtable[0x22].
	// Returns 0 if flag set, array empty, not a UShader, or shader reports no fallback.
	if (*(BYTE*)((BYTE*)this + 0x34) & 1)
		return 0;
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
IMPL_EMPTY("terrain editor tool — not needed for runtime gameplay")
UTerrainSector::UTerrainSector(ATerrainInfo*, INT, INT, INT, INT) {}

// ??0UTerrainPrimitive@@QAE@PAVATerrainInfo@@@Z
IMPL_EMPTY("terrain editor tool — not needed for runtime gameplay")
UTerrainPrimitive::UTerrainPrimitive(ATerrainInfo*) {}

// --- Moved from EngineStubs.cpp ---
IMPL_MATCH("Engine.dll", 0x10456d50)
void UTerrainPrimitive::Serialize(FArchive& Ar)
{
	guard(UTerrainPrimitive::Serialize);
	UPrimitive::Serialize(Ar);
	Ar << *(UObject**)((BYTE*)this + 0x58); // Info (ATerrainInfo*)
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1045e740)
INT UTerrainPrimitive::LineCheck(FCheckResult& Result, AActor* Owner, FVector Start, FVector End, FVector Extent, DWORD TraceFlags, DWORD /*ExtraNodeFlags*/)
{
	guard(UTerrainPrimitive::LineCheck);
	ATerrainInfo* Info = *(ATerrainInfo**)((BYTE*)this + 0x58);
	if (Info != (ATerrainInfo*)Owner)
		appFailAssert("Info==Owner", ".\\UnTerrain.cpp", 0x347);
	return Info->LineCheck(Result, Start, End, Extent, (INT)TraceFlags);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1045e820)
INT UTerrainPrimitive::PointCheck(FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD /*ExtraNodeFlags*/)
{
	guard(UTerrainPrimitive::PointCheck);
	ATerrainInfo* Info = *(ATerrainInfo**)((BYTE*)this + 0x58);
	if (Info != (ATerrainInfo*)Owner)
		appFailAssert("Info==Owner", ".\\UnTerrain.cpp", 0x34f);
	return Info->PointCheck(Result, Location, Extent, 0);
	unguard;
}
IMPL_TODO("virtual base no-op — subclass overrides - retail has 2241B at 0x10464050")
void UTerrainPrimitive::Illuminate(AActor*, INT) {}
IMPL_MATCH("Engine.dll", 0x10456620)
FBox UTerrainPrimitive::GetRenderBoundingBox(const AActor* Owner, INT /*bDetailed*/)
{
	guard(UTerrainPrimitive::GetRenderBoundingBox);
	// Retail: 82b. Returns a degenerate (point) FBox at the actor's world Location (actor+0x234).
	return FBox(*(FVector*)((BYTE*)Owner + 0x234), *(FVector*)((BYTE*)Owner + 0x234));
	unguard;
}

IMPL_DIVERGE("Counting-path (neither loading nor saving) serializes runtime render buffers; FRawColorStream has no FArchive op<<; Ravenshield packages are always ver>=0x75 so legacy branch is unreachable. Ghidra 0x10460b60")
void UTerrainSector::Serialize(FArchive& Ar)
{
	guard(UTerrainSector::Serialize);
	// Ghidra 0x160b60 (583b).
	// DIVERGENCE: The "neither loading nor saving" (counting) path serializes render
	// buffers (FRawIndexBuffer at +0x98, TArrays at +0x84/+0x2c) and is omitted here;
	// these are runtime-only GPU resources and not loaded from disk.

	UObject::Serialize(Ar);

	// Legacy < ver 0x5E: read/discard stale bounding-box + sphere not stored in struct.
	if (Ar.Ver() < 0x5E)
	{
		FBox   tmpBox;
		FSphere tmpSphere;
		Ar << tmpBox << tmpSphere;
	}

	// Serialize TerrainInfo reference (UObject* at +0x44).
	Ar << *(UObject**)((BYTE*)this + 0x44);

	// Sector geometry: +0x64 = SectorSizeX, +0x68 = SectorSizeY, +0x6C = OffsetX, +0x70 = OffsetY.
	Ar.ByteOrderSerialize((BYTE*)this + 0x64, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x68, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x6C, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x70, 4);

	// Bounding box at +0x48.
	FBox& bbox = *(FBox*)((BYTE*)this + 0x48);
	if (Ar.Ver() < 0x75)
	{
		// Legacy: bbox was not stored directly; reconstruct from 8 corner vectors.
		// FUN_10301400 was used in modern path; here we accumulate from serialized corners.
		bbox.Init();
		FVector corner;
		for (INT i = 0; i < 8; i++)
		{
			Ar.ByteOrderSerialize(&corner.X, 4);
			Ar.ByteOrderSerialize(&corner.Y, 4);
			Ar.ByteOrderSerialize(&corner.Z, 4);
			bbox += corner;
		}
	}
	else
	{
		// Modern: bbox serialized directly (6 floats + 1-byte valid flag).
		// Matches FUN_10301400: 6×ByteOrderSerialize(4) + ByteOrderSerialize(1).
		Ar.ByteOrderSerialize(&bbox.Min.X, 4);
		Ar.ByteOrderSerialize(&bbox.Min.Y, 4);
		Ar.ByteOrderSerialize(&bbox.Min.Z, 4);
		Ar.ByteOrderSerialize(&bbox.Max.X, 4);
		Ar.ByteOrderSerialize(&bbox.Max.Y, 4);
		Ar.ByteOrderSerialize(&bbox.Max.Z, 4);
		Ar.ByteOrderSerialize(&bbox.IsValid, 1);
	}

	// TArray at +0x38 (stride 0x10: UObject* + TArray<float>).
	// FUN_104607f0.
	{
		FArray& A = *(FArray*)((BYTE*)this + 0x38);
		if (Ar.IsLoading())
		{
			FCompactIndex ci;
			Ar << ci;
			INT n = *(INT*)&ci;
			A.Empty(0x10, 0);
			if (n > 0) { A.Add(n, 0x10); appMemzero(A.GetData(), n * 0x10); }
			for (INT i = 0; i < n; i++)
			{
				BYTE* elem = (BYTE*)A.GetData() + i * 0x10;
				Ar << *(UObject**)(elem + 0);
				// Inner TArray<float> at elem+4 (already zero-init from appMemzero above).
				FArray& inner = *(FArray*)(elem + 4);
				FCompactIndex ci2;
				Ar << ci2;
				INT m = *(INT*)&ci2;
				inner.Empty(4, 0);
				if (m > 0) { inner.Add(m, 4); Ar.Serialize(inner.GetData(), m * 4); }
			}
		}
		else
		{
			Ar << *(FCompactIndex*)((BYTE*)&A + 4);
			INT n = A.Num();
			for (INT i = 0; i < n; i++)
			{
				BYTE* elem = (BYTE*)A.GetData() + i * 0x10;
				Ar << *(UObject**)(elem + 0);
				FArray& inner = *(FArray*)(elem + 4);
				Ar << *(FCompactIndex*)((BYTE*)&inner + 4);
				INT m = inner.Num();
				if (m > 0) Ar.Serialize(inner.GetData(), m * 4);
			}
		}
	}

	// Legacy < ver 0x59: read/discard a stale UObject* ref.
	if (Ar.Ver() < 0x59)
	{
		UObject* discard = NULL;
		Ar << discard;
	}

	// Legacy < ver 0x75: read/discard a FRawColorStream (not stored in struct).
	// DIVERGENCE: FRawColorStream has no FArchive operator<<; Ravenshield packages
	// are always ver >= 0x75 so this branch is never executed in practice.
	if (Ar.Ver() < 0x75 && !Ar.IsLoading())
	{
		// nothing to write for the old stream (unreachable for Ravenshield content)
	}

	// On load: mark render cache dirty (+0x90 = 0xFFFFFFFF).
	if (Ar.IsLoading())
		*(DWORD*)((BYTE*)this + 0x90) = 0xFFFFFFFF;

	unguard;
}
IMPL_MATCH("Engine.dll", 0x104564e0)
void UTerrainSector::PostLoad()
{
	guard(UTerrainSector::PostLoad);
	UObject::PostLoad();
	unguard;
}
IMPL_TODO("virtual base no-op — subclass overrides - retail has 870B at 0x10459390")
void UTerrainSector::StaticLight(INT) {}
IMPL_TODO("terrain editor tool — not needed for runtime gameplay - retail has 3351B at 0x1045f9b0")
void UTerrainSector::GenerateTriangles() {}
// Ghidra at 0x156550. Returns linear index in the global heightmap grid.
IMPL_MATCH("Engine.dll", 0x10456550)
INT UTerrainSector::GetGlobalVertex(INT X, INT Y) {
	// TerrainInfo->HeightmapX is at offset 0x12E0 in ATerrainInfo
	INT HeightmapX = *(INT*)((BYTE*)TerrainInfo + 0x12E0);
	return (OffsetY + Y) * HeightmapX + OffsetX + X;
}

// Ghidra at 0x153a0. Returns linear index within this sector.
IMPL_MATCH("Engine.dll", 0x103153a0)
INT UTerrainSector::GetLocalVertex(INT X, INT Y) {
	return (SectorSizeX + 1) * Y + X;
}
IMPL_TODO("Ghidra 0x104590F0: per-triangle LOD/culling test blocked by terrain sector struct layout not yet reconstructed")
INT UTerrainSector::PassShouldRenderTriangle(INT, INT, INT, INT, INT) { return 1; }
// ?IsSectorAll@UTerrainSector@@QAEHHE@Z  Ghidra at ~0x107bae30 (336 bytes).
// Gets the alpha texture for the layer, computes texel range for this sector,
// then checks that every texel matches 'value'. Returns 1 (true) on empty range.
IMPL_MATCH("Engine.dll", 0x10458c30)
INT UTerrainSector::IsSectorAll(INT layerIdx, BYTE value)
{
	guard(UTerrainSector::IsSectorAll);
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
	unguard;
}
IMPL_TODO("Ghidra 0x10458D70: terrain texel alpha triangle check blocked by terrain sector texel/alpha buffer layout not yet reconstructed")
INT UTerrainSector::IsTriangleAll(INT, INT, INT, INT, INT, BYTE) { return 0; }
IMPL_TODO("virtual base no-op — subclass overrides - retail has 1235B at 0x10463b40")
void UTerrainSector::AttachProjector(AProjector*, FProjectorRenderInfo*) {}
