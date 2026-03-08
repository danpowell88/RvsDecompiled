/*=============================================================================
	FD3DResource.h: D3D8 resource cache entry.
	Reconstructed for Ravenshield decompilation project — Phase 9A.

	FD3DResource is the base type for cached GPU resources (textures,
	vertex buffers, index buffers). Each cached resource is indexed by a
	QWORD CacheID and stored in a hash table on UD3DRenderDevice.

	Layout derived from Ghidra offset analysis of retail D3DDrv.dll:
	  - 0x29a28 on UD3DRenderDevice = resource hash table base
	  - CacheID-indexed lookups in GetCachedResource (0x10008fc0)
	  - FlushResource (0x10009060) walks chains and releases D3D refs

	The UT99 D3D7 driver uses a similar FTexInfo struct with CacheID,
	FrameCounter, linked-list pointers, and IDirectDrawSurface7 refs.
	The D3D8 version replaces DDraw surfaces with IDirect3DTexture8*.
=============================================================================*/

#ifndef _INC_FD3DRESOURCE
#define _INC_FD3DRESOURCE

#pragma pack(push, 4)

// Resource hash table size — same as UT99's 4096-slot CachedTextures array.
#define D3D_RESOURCE_HASH_SIZE 4096
#define D3D_RESOURCE_HASH_MASK (D3D_RESOURCE_HASH_SIZE - 1)

/*-----------------------------------------------------------------------------
	FD3DResource — cached GPU resource.
-----------------------------------------------------------------------------*/
class FD3DResource
{
public:
	// Cache identification.
	QWORD                   CacheID;        // Unreal resource cache identifier
	INT                     FrameCounter;   // Last frame this resource was used
	INT                     SubCounter;     // Sub-frame usage counter

	// Hash chain.
	FD3DResource*           HashNext;       // Next in hash bucket chain
	FD3DResource**          HashPrevLink;   // Address of pointer to this entry

	// D3D8 resource reference.
	IDirect3DBaseTexture8*  D3DTexture;     // The actual D3D8 texture (may be NULL for non-texture resources)
	IDirect3DSurface8*      D3DSurface;     // Optional surface reference (render targets, depth stencil)

	// Texture metadata.
	INT                     USize;          // Width
	INT                     VSize;          // Height
	INT                     NumMips;        // Mipmap count
	D3DFORMAT               Format;         // Pixel format

	FD3DResource()
		: CacheID(0)
		, FrameCounter(0)
		, SubCounter(0)
		, HashNext(NULL)
		, HashPrevLink(NULL)
		, D3DTexture(NULL)
		, D3DSurface(NULL)
		, USize(0)
		, VSize(0)
		, NumMips(0)
		, Format(D3DFMT_UNKNOWN)
	{}

	~FD3DResource()
	{
		Unlink();
		if( D3DTexture )
		{
			D3DTexture->Release();
			D3DTexture = NULL;
		}
		if( D3DSurface )
		{
			D3DSurface->Release();
			D3DSurface = NULL;
		}
	}

	void Unlink()
	{
		if( HashPrevLink )
			*HashPrevLink = HashNext;
		if( HashNext )
			HashNext->HashPrevLink = HashPrevLink;
		HashPrevLink = NULL;
		HashNext = NULL;
	}
};

#pragma pack(pop)

#endif // _INC_FD3DRESOURCE
