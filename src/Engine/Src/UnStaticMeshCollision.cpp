/*=============================================================================
	UnStaticMeshCollision.cpp: Static mesh collision and geometry data structures
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- FStaticMeshCollisionNode ---
IMPL_MATCH("Engine.dll", 0x10316570)
FStaticMeshCollisionNode::FStaticMeshCollisionNode()
{
	// Ghidra: only constructs FBox at offset 0x10 (empty default ctor)
}

IMPL_MATCH("Engine.dll", 0x103115e0)
FStaticMeshCollisionNode& FStaticMeshCollisionNode::operator=(const FStaticMeshCollisionNode& Other)
{
	// Ghidra 0x115e0: loop copies 11 DWORDs (44 bytes); shares address with FReachSpec::op=
	appMemcpy(this, &Other, 44);
	return *this;
}


// --- FStaticMeshCollisionTriangle ---
IMPL_MATCH("Engine.dll", 0x10316490)
FStaticMeshCollisionTriangle::FStaticMeshCollisionTriangle(FStaticMeshCollisionTriangle const & Other)
{
	appMemcpy(_Data, Other._Data, 84); // 21 dwords: 4 FPlanes + 5 extra dwords
}

IMPL_MATCH("Engine.dll", 0x10316490)
FStaticMeshCollisionTriangle::FStaticMeshCollisionTriangle()
{
	// Ghidra: constructs 4 FPlanes (all empty default ctors)
}

IMPL_MATCH("Engine.dll", 0x10316500)
FStaticMeshCollisionTriangle& FStaticMeshCollisionTriangle::operator=(const FStaticMeshCollisionTriangle& Other)
{
	// Ghidra 0x16500: loop copies 0x15 = 21 DWORDs (84 bytes)
	appMemcpy(_Data, Other._Data, 84); // 21 dwords
	return *this;
}


// --- FStaticMeshMaterial ---
IMPL_MATCH("Engine.dll", 0x10316580)
FStaticMeshMaterial::FStaticMeshMaterial(UMaterial * InMaterial)
{
	Material = InMaterial;
	Flags1 = 1;
	Flags2 = 1;
}

IMPL_MATCH("Engine.dll", 0x103165d0)
FStaticMeshMaterial& FStaticMeshMaterial::operator=(const FStaticMeshMaterial& Other)
{
	// Ghidra 0x165d0: copies 3 DWORDs (12 bytes); shares address with FPointRegion/FRotatorF op=
	Material = Other.Material;
	Flags1 = Other.Flags1;
	Flags2 = Other.Flags2;
	return *this;
}


// --- FStaticMeshSection ---
IMPL_MATCH("Engine.dll", 0x103162c0)
FStaticMeshSection::FStaticMeshSection()
{
	*(DWORD*)((BYTE*)this + 0x00) = 0;       // +0x00
	*(DWORD*)((BYTE*)this + 0x04) = 0;       // +0x04
	*(_WORD*)((BYTE*)this  + 0x10) = 0;      // +0x10
	*(_WORD*)((BYTE*)this  + 0x0e) = 0;      // +0x0e
	*(_WORD*)((BYTE*)this  + 0x08) = 0;      // +0x08
	*(_WORD*)((BYTE*)this  + 0x0c) = 0xffff; // +0x0c = -1
	*(_WORD*)((BYTE*)this  + 0x0a) = 0xffff; // +0x0a = -1
}

IMPL_MATCH("Engine.dll", 0x103128d0)
FStaticMeshSection& FStaticMeshSection::operator=(const FStaticMeshSection& Other)
{
	// Ghidra 0x128d0: copies 5 DWORDs (20 bytes); shares address with FHitCause::op=
	appMemcpy( this, &Other, sizeof(FStaticMeshSection) );
	return *this;
}


// --- FStaticMeshTriangle ---
IMPL_MATCH("Engine.dll", 0x103162f0)
FStaticMeshTriangle::FStaticMeshTriangle()
{
	// Ghidra: constructs 3 FVectors at offsets 0x00, 0x0C, 0x18 (all empty default ctors)
}

IMPL_MATCH("Engine.dll", 0x10316320)
FStaticMeshTriangle& FStaticMeshTriangle::operator=(const FStaticMeshTriangle& Other)
{
	// Ghidra 0x16320: loop copies 0x41 = 65 DWORDs (260 bytes); shares address with FSortedPathList::op=
	appMemcpy(_Data, Other._Data, 260); // 65 dwords
	return *this;
}


// --- FStaticMeshUV ---
IMPL_MATCH("Engine.dll", 0x10316250)
FStaticMeshUV& FStaticMeshUV::operator=(const FStaticMeshUV& Other)
{
	// Ghidra 0x16250: copies 2 DWORDs (8 bytes); shares address with FPathBuilder::op=
	*(INT*)&_Data[0] = *(INT*)&Other._Data[0];
	*(INT*)&_Data[4] = *(INT*)&Other._Data[4];
	return *this;
}


// --- FStaticMeshUVStream ---
IMPL_MATCH("Engine.dll", 0x1032c110)
FStaticMeshUVStream::FStaticMeshUVStream(FStaticMeshUVStream const &Other)
{
	// Ghidra 0x2c110: vtable set by compiler; TArray<FStaticMeshUV> at +4 (stride 8); 4 DWORDs at +10..+1c
	new ((BYTE*)this + 0x04) TArray<FStaticMeshUV>(*(const TArray<FStaticMeshUV>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x10); // 4 DWORDs
}

IMPL_MATCH("Engine.dll", 0x1032c110)
FStaticMeshUVStream::FStaticMeshUVStream()
{
	// Initialize TArray<FStaticMeshUV> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FStaticMeshUV>();
}

IMPL_MATCH("Engine.dll", 0x1032c100)
FStaticMeshUVStream::~FStaticMeshUVStream()
{
	// Ghidra 0x2c100: calls FUN_103242c0 on this = TArray<FStaticMeshUV>::~TArray at +0x04
	((TArray<FStaticMeshUV>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x1032c150)
FStaticMeshUVStream& FStaticMeshUVStream::operator=(const FStaticMeshUVStream& Other)
{
	// Ghidra 0x2c150: calls FUN_103220d0(other+4) = TArray<FStaticMeshUV>::op=, then copies 4 DWORDs at +10..+1C
	*(TArray<FStaticMeshUV>*)((BYTE*)this + 0x04) = *(const TArray<FStaticMeshUV>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x10); // 4 DWORDs
	return *this;
}


// --- FStaticMeshVertex ---
IMPL_MATCH("Engine.dll", 0x103fe100)
FStaticMeshVertex::FStaticMeshVertex()
{
	// Ghidra: constructs two FVectors at offset 0 and 0xC (same as FBspVertex)
	*(FVector*)&_Data[0] = FVector(0,0,0);
	*(FVector*)&_Data[12] = FVector(0,0,0);
}

IMPL_MATCH("Engine.dll", 0x10303890)
FStaticMeshVertex& FStaticMeshVertex::operator=(const FStaticMeshVertex& Other)
{
	// Ghidra 0x3890: copies 6 DWORDs (24 bytes); shares address with ECLipSynchData/FCanvasVertex op=
	appMemcpy( this, &Other, sizeof(FStaticMeshVertex) );
	return *this;
}


// --- FStaticMeshVertexStream ---
IMPL_MATCH("Engine.dll", 0x1032bf90)
FStaticMeshVertexStream::FStaticMeshVertexStream(FStaticMeshVertexStream const &Other)
{
	// Ghidra 0x2bf90: vtable set by compiler; TArray<FStaticMeshVertex> at +4 (stride 0x18); 3 DWORDs at +10..+18
	new ((BYTE*)this + 0x04) TArray<FStaticMeshVertex>(*(const TArray<FStaticMeshVertex>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
}

IMPL_MATCH("Engine.dll", 0x1032bf90)
FStaticMeshVertexStream::FStaticMeshVertexStream()
{
	// Initialize TArray<FStaticMeshVertex> at +4 to empty
	new ((BYTE*)this + 0x04) TArray<FStaticMeshVertex>();
}

IMPL_MATCH("Engine.dll", 0x1032bf80)
FStaticMeshVertexStream::~FStaticMeshVertexStream()
{
	// Ghidra 0x2bf80: calls FUN_10324350 on this = TArray<FStaticMeshVertex>::~TArray at +0x04
	((TArray<FStaticMeshVertex>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x1032bfd0)
FStaticMeshVertexStream& FStaticMeshVertexStream::operator=(const FStaticMeshVertexStream& Other)
{
	// Ghidra 0x2bfd0: calls FUN_10324030(other+4) = TArray<FStaticMeshVertex>::op=, then copies 3 DWORDs at +10..+18
	*(TArray<FStaticMeshVertex>*)((BYTE*)this + 0x04) = *(const TArray<FStaticMeshVertex>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 0x0C); // 3 DWORDs
	return *this;
}

