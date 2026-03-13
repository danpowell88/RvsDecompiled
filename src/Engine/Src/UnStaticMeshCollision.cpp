/*=============================================================================
	UnStaticMeshCollision.cpp: Static mesh collision and geometry data structures
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
	*(DWORD*)((BYTE*)this + 0x00) = 0;       // +0x00
	*(DWORD*)((BYTE*)this + 0x04) = 0;       // +0x04
	*(_WORD*)((BYTE*)this  + 0x10) = 0;      // +0x10
	*(_WORD*)((BYTE*)this  + 0x0e) = 0;      // +0x0e
	*(_WORD*)((BYTE*)this  + 0x08) = 0;      // +0x08
	*(_WORD*)((BYTE*)this  + 0x0c) = 0xffff; // +0x0c = -1
	*(_WORD*)((BYTE*)this  + 0x0a) = 0xffff; // +0x0a = -1
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

