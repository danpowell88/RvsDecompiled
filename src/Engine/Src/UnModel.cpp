/*=============================================================================
UnModel.cpp: UModel and UPolys implementation.
Reconstructed from Ghidra analysis of Engine.dll (Ravenshield 1.60).

BSP tree geometry class used for level architecture: brushes, collision,
lighting, BSP queries, and render data management.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(UModel);
IMPLEMENT_CLASS(UPolys);

#pragma optimize("", off)

#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// Forward-declare FPoly serializer used in UPolys::Serialize.
extern FArchive& operator<<(FArchive& Ar, FPoly& V);

// Raw-offset accessors for UModel internals (no named members in EngineClasses.h).
// All offsets verified from Ghidra constructor at 0x103d06d0.
#define MODEL_NODES(m)       ((FArray*)((BYTE*)(m) + 0x5c))  // TArray<FBspNode>, elem=0x90
#define MODEL_VERTS(m)       ((FArray*)((BYTE*)(m) + 0x6c))  // TArray<FVert>, elem=8
// NOTE: In UE2 the class declaration order is Vectors (normals/tex dirs) then Points
// (vertex positions). Ghidra ConvexVolumeMultiCheck 0x10470aa0 and BuildRenderData
// 0x103cf020 both confirm +0x8c = Points (positions) and +0x7c = Vectors (directions).
#define MODEL_VECTORS(m)     ((FArray*)((BYTE*)(m) + 0x7c))  // TArray<FVector>, elem=0xc (normals, texture U/V)
#define MODEL_POINTS(m)      ((FArray*)((BYTE*)(m) + 0x8c))  // TArray<FVector>, elem=0xc (vertex positions)
#define MODEL_SURFS(m)       ((FArray*)((BYTE*)(m) + 0x9c))  // TArray<FBspSurf>, elem=0x5c
#define MODEL_LIGHTMAP(m)    ((FArray*)((BYTE*)(m) + 0xac))  // lightmap array, elem=0x1c
#define MODEL_VERTIDX(m)     ((FArray*)((BYTE*)(m) + 0xb8))  // TArray<INT>, elem=4
#define MODEL_SECTIONS(m)    ((FArray*)((BYTE*)(m) + 0xdc))  // render sections, elem=0x2c
#define MODEL_POLYS(m)       (*(BYTE**)((BYTE*)(m) + 0x58))  // UPolys*
#define MODEL_ROOTOUTSIDE(m) (*(INT*)((BYTE*)(m) + 0x10c))   // RootOutside flag

// Strides for raw array element access (from Ghidra constructor analysis)
#define NODE_STRIDE  0x90   // sizeof(FBspNode)
#define SURF_STRIDE  0x5c   // sizeof(FBspSurf)
#define FPOLY_STRIDE 0x15c  // sizeof(FPoly)
#define PROJ_STRIDE  0x10   // projector entry stride (Destroy loop at 0x103ce9a0)


// =============================================================================
// BSP helper function stubs -- implementations pending decompilation of
// UnBsp.cpp / unnamed Ghidra code segments.
// =============================================================================

// DAT_1079bfe4 -- Nodes.Data pointer cached for BSP traversal helpers.
static INT GBspNodes = 0;

// Ghidra 0x1046cd40 (350b): fast BSP line check.
// Iteratively traverses BSP tree, classifying whether the line from A(sx,sy,sz)
// to B(ex,ey,ez) is inside (returns 1) or outside (returns 0) the BSP solid.
// GBspNodes = DAT_1079bfe4: Nodes.Data pointer set by FastLineCheck before calling.
// NodeFlags byte at node+0x6f: bit 0 modulates the "outside" propagation.
// DIVERGENCE: In retail, this is a standalone non-method function that reads
// DAT_1079bfe4 directly from a fixed BSS address. Our implementation reads
// from the same GBspNodes static, which is set identically by FastLineCheck.
IMPL_MATCH("Engine.dll", 0x1046cd40)
static BYTE bspFastLineCheck( INT iNode, FLOAT sx, FLOAT sy, FLOAT sz,
                               FLOAT ex, FLOAT ey, FLOAT ez, BYTE rootOutside )
{
    if (iNode != -1) {
        do {
            BYTE*   nb     = (BYTE*)GBspNodes + iNode * NODE_STRIDE;
            FPlane* plane  = (FPlane*)nb;
            FLOAT   dotB   = plane->PlaneDot(*(const FVector*)&ex);  // dot of B endpoint
            FLOAT   dotA   = plane->PlaneDot(*(const FVector*)&sx);  // dot of A endpoint
            BYTE    flags  = *(BYTE*)(nb + 0x6f);                    // NodeFlags
            BYTE    bBPos  = (INT)dotB >= 0 ? 1 : 0;
            BYTE    bAPos  = (INT)dotA >= 0 ? 1 : 0;
            if ((DWORD)bBPos != (DWORD)bAPos) {
                // Line crosses plane: clip to intersection, recurse on A-half
                FLOAT t  = dotB / (dotB - dotA);
                FLOAT ix = (sx - ex) * t + ex;
                FLOAT iy = (sy - ey) * t + ey;
                FLOAT iz = (sz - ez) * t + ez;
                INT   childA   = *(INT*)(nb + bAPos * 4 + 0x38);
                BYTE  outA     = (BYTE)(((bAPos ^ rootOutside) & flags & 1) ^ bAPos);
                BYTE  cVar2    = bspFastLineCheck(childA, ix, iy, iz, sx, sy, sz, outA);
                if (cVar2 == 0)
                    return 0;
                sz = iz;  sx = ix;  sy = iy;   // truncate A to intersection point
            }
            iNode       = *(INT*)(nb + bBPos * 4 + 0x38);  // advance to B's child
            rootOutside = (BYTE)(((bBPos ^ rootOutside) & flags & 1) ^ bBPos);
        } while (iNode != -1);
    }
    return rootOutside;
}

// Ghidra 0x104704f0 (626b): BSP nearest-vertex search.
// Walks the BSP tree (via back child 0x38) and at each node whose plane is
// within MinRadius of Src, checks the surface base vertex (Surfs[iSurf].field+8
// indexes Model+0x8c) and all vertices in the node's vertex pool (Verts at +0x30,
// NumVertices at +0x6e, each FVert = 8 bytes, first field = vertex index into +0x8c).
// Also recurses into the front child (0x3c) when needed.
// Returns the distance to the nearest vertex found, or -1 if none.
// NOTE: Model+0x8c is the vertex-position array (Ghidra accesses it via FVert.pVertex
// and FBspSurf field+8; may correspond to either Points or Vectors in our macro map).
IMPL_MATCH("Engine.dll", 0x104704f0)
static FLOAT bspFindNearestVertexHelper( UModel* Model, const FVector* Src, FVector* Dst,
                                          FLOAT MinRadius, INT P5, INT* iVertex )
{
    FLOAT local_18 = -1.0f;
    if (P5 == -1)
        return -1.0f;

    BYTE*  nodesData = (BYTE*)*(INT*)((BYTE*)Model + 0x5c);  // Nodes.Data
    BYTE*  vertsData = (BYTE*)*(INT*)((BYTE*)Model + 0x6c);  // Verts.Data
    FLOAT* ptData    = (FLOAT*)*(INT*)((BYTE*)Model + 0x8c); // vertex-position array
    BYTE*  surfsData = (BYTE*)*(INT*)((BYTE*)Model + 0x9c);  // Surfs.Data

    FLOAT curRadius = MinRadius;
    FLOAT fVar6 = (FLOAT)local_18;

    while (1) {
        INT   backChild = *(INT*)(nodesData + P5 * NODE_STRIDE + 0x38);
        BYTE* nb        = nodesData + P5 * NODE_STRIDE;
        FPlane* plane   = (FPlane*)nb;
        FLOAT dotPt     = plane->PlaneDot(*Src);

        // Recurse into front child if point is close enough to positive side
        INT frontChild = *(INT*)(nb + 0x3c);
        if (dotPt > -curRadius && frontChild != -1) {
            FLOAT r = bspFindNearestVertexHelper(Model, Src, Dst, curRadius, frontChild, iVertex);
            if (r >= 0.0f) {
                curRadius = r;
                local_18  = r;
            }
        }

        fVar6 = (FLOAT)local_18;
        if (dotPt > -curRadius) {
            if (dotPt > curRadius)
                return fVar6;   // point is far on positive side, stop here

            // Walk the plane chain to check all coincident-plane vertices
            INT planeNode = P5;
            if (planeNode != -1) {
                do {
                    BYTE* pnb     = nodesData + planeNode * NODE_STRIDE;
                    // Check surface base vertex
                    INT iSurf     = *(INT*)(pnb + 0x34);
                    INT iVtx      = *(INT*)(surfsData + iSurf * SURF_STRIDE + 8);
                    FLOAT* vp     = ptData + iVtx * 3;
                    FLOAT dx = vp[0] - Src->X, dy = vp[1] - Src->Y, dz = vp[2] - Src->Z;
                    FLOAT dist2 = dx*dx + dy*dy + dz*dz;
                    if (dist2 < curRadius * curRadius) {
                        *iVertex  = iVtx;
                        FLOAT r   = (FLOAT)appSqrt((DOUBLE)dist2);
                        fVar6 = r;  curRadius = r;
                        Dst->X = vp[0];  Dst->Y = vp[1];  Dst->Z = vp[2];
                    }
                    // Walk vertex pool entries for this node
                    INT   poolBase = *(INT*)(pnb + 0x30);
                    INT*  vpool    = (INT*)(vertsData + poolBase * 8);
                    BYTE  numV     = *(BYTE*)(pnb + 0x6e);
                    for (BYTE v = 0; v < numV; v++, vpool += 2) {
                        INT    vi   = *vpool;
                        FLOAT* vpos = ptData + vi * 3;
                        dx = vpos[0] - Src->X;  dy = vpos[1] - Src->Y;  dz = vpos[2] - Src->Z;
                        dist2 = dx*dx + dy*dy + dz*dz;
                        if (dist2 < curRadius * curRadius) {
                            *iVertex  = vi;
                            FLOAT r   = (FLOAT)appSqrt((DOUBLE)dist2);
                            fVar6 = r;  curRadius = r;
                            Dst->X = vpos[0];  Dst->Y = vpos[1];  Dst->Z = vpos[2];
                        }
                    }
                    planeNode = *(INT*)(pnb + 0x40);   // advance along plane chain
                } while (planeNode != -1);
            }
            local_18 = fVar6;
        }
        if (dotPt > curRadius) break;  // far positive, descend back child
        P5 = backChild;
        if (backChild == -1)
            return (FLOAT)local_18;
    }
    return (FLOAT)local_18;
}

// Ghidra 0x103ccc70 (640b): BSP box-leaf collector.
// Iteratively traverses the BSP tree finding all leaf zones that a box overlaps.
// Two modes: AABB mode (elongated box) uses per-axis half-extent projection;
// sphere mode (compact box) uses the box's bounding-sphere radius.
// DIVERGENCE: retail uses a pre-allocated global FArray (DAT_1067dd6c) as work
// stack; we use a local INT[512] array which avoids the global write but produces
// identical leaf results for any practical BSP depth.
IMPL_DIVERGE("Ghidra 0x103ccc70: local INT[512] work-stack used instead of retail global FArray DAT_1067dd6c; produces identical leaf results but global state differs — not byte-parity")
static void bspBoxLeavesHelper( UModel* Model, INT iNode,
                                 FLOAT cx, FLOAT cy, FLOAT cz,
                                 FLOAT ex, FLOAT ey, FLOAT ez,
                                 FArray* Result )
{
    BYTE* nodesData = (BYTE*)*(INT*)((BYTE*)Model + 0x5c);

    // Select traversal mode based on box aspect ratio
    FLOAT minExt = ey;
    if (ex < ey)   minExt = ex;
    if (minExt >= ez) minExt = ez;
    FLOAT maxExt = ey;
    if (ey <= ex)  maxExt = ex;
    if (maxExt < ez) maxExt = ez;
    INT   useSphere = (minExt + minExt > maxExt);
    FLOAT sphereRad = 0.0f;
    if (useSphere)
        sphereRad = FVector(ex, ey, ez).Size();

    INT work[512];
    work[0] = iNode;
    INT top = 0;

    do {
        BYTE*   nb    = nodesData + work[top] * NODE_STRIDE;
        FPlane* pl    = (FPlane*)nb;
        INT     after = top - 1;   // default: pop current entry

        FLOAT projExt = useSphere
            ? sphereRad
            : Abs(ex * pl->X) + Abs(ey * pl->Y) + Abs(ez * pl->Z);

        const FVector center(cx, cy, cz);
        FLOAT dist = pl->PlaneDot(center);

        // Check back/negative side (child at +0x38)
        if (dist < projExt) {
            INT backChild = *(INT*)(nb + 0x38);
            if (backChild == -1) {
                INT iZone0 = *(INT*)(nb + 0x70);
                if (iZone0 != -1) {
                    INT idx = Result->Add(1, 4);
                    *(INT*)((BYTE*)Result->GetData() + idx * 4) = iZone0;
                }
            } else {
                work[top] = backChild;  // replace current with back child
                after = top;            // don't pop
            }
        }
        top = after;

        // Check front/positive side (child at +0x3c)
        if (-dist < projExt) {
            INT frontChild = *(INT*)(nb + 0x3c);
            if (frontChild == -1) {
                INT iZone1 = *(INT*)(nb + 0x74);
                if (iZone1 != -1) {
                    INT idx = Result->Add(1, 4);
                    *(INT*)((BYTE*)Result->GetData() + idx * 4) = iZone1;
                }
            } else {
                if (top + 1 < 512)
                    work[++top] = frontChild;
            }
        }
    } while (top >= 0);
}

// Ghidra 0x1046de10 (124b): BSP sphere-filter precomputation.
// For each node, clears NodeFlags bits 6-7 and sets them based on sphere position:
//   bit 0x40 — sphere fully in front of this plane (dist > radius)
//   bit 0x80 — sphere fully behind this plane     (dist < -radius)
// When the sphere straddles the plane, recurses into the back child (0x38)
// then iterates into the front child (0x3c).
IMPL_MATCH("Engine.dll", 0x1046de10)
static void bspPrecomputeSphereFilterHelper( UModel* Model, INT iNode, const FPlane* Sphere )
{
    BYTE*  nodesData = (BYTE*)*(INT*)((BYTE*)Model + 0x5c);
    FLOAT  radius    = Sphere->W;
    do {
        BYTE*   nb    = nodesData + iNode * NODE_STRIDE;
        *(BYTE*)(nb + 0x6f) &= 0x3f;               // clear bits 6 and 7
        FPlane* plane = (FPlane*)nb;
        FLOAT   dist  = plane->PlaneDot(*(const FVector*)Sphere);
        if (dist >= -radius) {
            if (dist <= radius) {
                INT backChild = *(INT*)(nb + 0x38); // straddles: recurse back
                if (backChild != -1)
                    bspPrecomputeSphereFilterHelper(Model, backChild, Sphere);
            } else {
                *(BYTE*)(nb + 0x6f) |= 0x40;        // fully in front
            }
            iNode = *(INT*)(nb + 0x3c);              // iterate front child
        } else {
            *(BYTE*)(nb + 0x6f) |= 0x80;            // fully behind
            iNode = *(INT*)(nb + 0x38);              // iterate back child
        }
    } while (iNode != -1);
}


// =============================================================================
// UPolys
// =============================================================================

// Ghidra: Engine.dll 0x1032f9c0, 229 bytes.
// Non-trans path: CountBytes, ByteOrderSerialize Num+Max, stream each FPoly.
// Trans path: retail calls FUN_1032c490 which immediately returns when IsTrans()
// is true — the undo system does not record raw poly data. We match that no-op.
IMPL_DIVERGE("permanent: FUN_103222e0/FUN_10322330 are unexported FArray helpers that allocate all N slots at once then iterate; our implementation adds one at a time — equivalent result, different bytecode")
void UPolys::Serialize( FArchive& Ar )
{
guard(UPolys::Serialize);
UObject::Serialize(Ar);
FArray& Polys = *(FArray*)((BYTE*)this + 0x2c);
if (Ar.IsTrans())
{
    // Retail FUN_1032c490 is a no-op when IsTrans() — undo system skips raw poly data.
}
else
{
    Polys.CountBytes(Ar, FPOLY_STRIDE);
    INT Num = Polys.Num();
    INT Max = Num;
    Ar.ByteOrderSerialize(&Num, 4);
    Ar.ByteOrderSerialize(&Max, 4);
    if (Ar.IsLoading())
    {
        Polys.Empty(FPOLY_STRIDE, Num);
        for (INT i = 0; i < Num; i++)
        {
            INT idx = Polys.Add(1, FPOLY_STRIDE);
            Ar << *(FPoly*)((BYTE*)Polys.GetData() + idx * FPOLY_STRIDE);
        }
    }
    else
    {
        for (INT i = 0; i < Polys.Num(); i++)
            Ar << *(FPoly*)((BYTE*)Polys.GetData() + i * FPOLY_STRIDE);
    }
}
unguard;
}


// =============================================================================
// UModel
// =============================================================================

// Ghidra: Engine.dll 0x103d06d0, 446 bytes.
// Initialises 13 FArray members via raw offsets, stores UModel* back-references
// for the first 5 arrays (Nodes/Verts/Points/Vectors/Surfs), zeroes 256 zone
// property entries (0x40 bytes zeroed per 0x48-byte slot starting at this+0x128),
// sets RF_Transactional, calls EmptyModel(1,1), and -- if Owner is non-NULL --
// stores this as Owner->Brush (at Owner+0x178) and calls Owner::InitPosRotScale
// via vtable slot 0x188.
// Ghidra 0x103d06d0, 446 bytes.
// FArray(ptr,0,stride) in Ghidra is the TTransArray ctor which, with count=0,
// produces Data=null/Num=0/Max=0 — identical to our default-constructed FArray().
// The zone-property zeroing loop matches exactly (16 DWORDs * 256 entries * +0x48 stride).
IMPL_MATCH("Engine.dll", 0x103d06d0)
UModel::UModel( ABrush* Owner, INT InRootOutside )
{
guard(UModel::UModel);
new((FArray*)((BYTE*)this + 0x5c)) FArray();  *(UModel**)((BYTE*)this + 0x68) = this;
new((FArray*)((BYTE*)this + 0x6c)) FArray();  *(UModel**)((BYTE*)this + 0x78) = this;
new((FArray*)((BYTE*)this + 0x7c)) FArray();  *(UModel**)((BYTE*)this + 0x88) = this;
new((FArray*)((BYTE*)this + 0x8c)) FArray();  *(UModel**)((BYTE*)this + 0x98) = this;
new((FArray*)((BYTE*)this + 0x9c)) FArray();  *(UModel**)((BYTE*)this + 0xa8) = this;
new((FArray*)((BYTE*)this + 0xac)) FArray();
new((FArray*)((BYTE*)this + 0xb8)) FArray();
new((FArray*)((BYTE*)this + 0xc4)) FArray();
new((FArray*)((BYTE*)this + 0xd0)) FArray();
new((FArray*)((BYTE*)this + 0xdc)) FArray();
new((FArray*)((BYTE*)this + 0xe8)) FArray();
new((FArray*)((BYTE*)this + 0xf4)) FArray();
new((FArray*)((BYTE*)this + 0x100)) FArray();
MODEL_ROOTOUTSIDE(this) = InRootOutside;
// Zero the first 0x40 bytes of each 0x48-byte zone-property slot.
// 256 entries -- Ravenshield BSP_MAX_ZONES == 256 (Ghidra-confirmed).
DWORD* p = (DWORD*)((BYTE*)this + 0x128);
for (INT i = 0; i < 0x100; i++)
{
    for (INT j = 0; j < 16; j++)
        p[j] = 0;
    p = (DWORD*)((BYTE*)p + 0x48);
}
SetFlags(RF_Transactional);
EmptyModel(1, 1);
if (Owner != NULL)
{
    *(UModel**)((BYTE*)Owner + 0x178) = this;
    // InitPosRotScale -- vtable slot 0x188 on ABrush.
    (*(void(__thiscall**)(ABrush*))(*((INT*)Owner) + 0x188))(Owner);
}
unguard;
}

// Ghidra: Engine.dll 0x103ccbb0, 133 bytes.
// For each BSP node i: reads iSurf at FBspNode+0x34, then appends i
// to that surface's LeafArray (FArray at FBspSurf+0x20, elem=INT).
IMPL_MATCH("Engine.dll", 0x103ccbb0)
void UModel::PostLoad()
{
guard(UModel::PostLoad);
FArray* nodes = MODEL_NODES(this);
FArray* surfs = MODEL_SURFS(this);
for (INT i = 0; i < nodes->Num(); i++)
{
    INT iSurf    = *(INT*)(*(INT*)nodes + i * NODE_STRIDE + 0x34);
    FArray* leaf = (FArray*)(*(INT*)surfs + iSurf * SURF_STRIDE + 0x20);
    INT idx = leaf->Add(1, 4);
    *(INT*)(*(INT*)leaf + idx * 4) = i;
}
Super::PostLoad();
unguard;
}

// Ghidra: Engine.dll 0x103ce9a0, 184 bytes.
// Decrements ref-counts on projector entries attached to each BSP node;
// frees objects whose count reaches zero (FUN_103719b0 = projector dtor, unnamed).
// FUN_103719b0 body (0x103719b0, 110 bytes): asserts refcount==0, then explicitly
// destructs two FMatrix objects embedded in the projector allocation at offsets
// +0x24 (in_ECX+9) and +0x64 (in_ECX+0x19) before the allocator frees the block.
// DIVERGENCE: retail calls FUN_103719b0 as a subroutine (CALL 0x103719b0); we inline
// the ~FMatrix calls here, producing identical runtime behaviour but a different
// instruction layout.
IMPL_DIVERGE("Ghidra 0x103ce9a0: FUN_103719b0 body inlined (FMatrix::~FMatrix at +0x24 and +0x64); retail emits a CALL to unnamed 0x103719b0 — behaviour matches, bytecode differs")
void UModel::Destroy()
{
guard(UModel::Destroy);
FArray* nodes = MODEL_NODES(this);
BYTE* nodeData = (BYTE*)nodes->GetData();
INT numNodes = nodes->Num();
for (INT i = 0; i < numNodes; i++)
{
	FArray* projectors = (FArray*)(nodeData + i * NODE_STRIDE + 0x84);
	while (projectors->Num() >= 1)
	{
		INT num = projectors->Num();
		BYTE* lastEntry = (BYTE*)projectors->GetData() + (num - 1) * PROJ_STRIDE;
		INT* refCount = *(INT**)lastEntry;
		(*refCount)--;
		if (*refCount == 0)
		{
			// FUN_103719b0 inline: destruct the two FMatrix objects embedded in the
			// projector-info allocation (at byte offsets +0x64 and +0x24 from base),
			// then free the allocation.  FMatrix::~FMatrix is trivially empty so
			// these calls produce no visible side-effects at runtime.
			((FMatrix*)((BYTE*)refCount + 0x64))->~FMatrix();
			((FMatrix*)((BYTE*)refCount + 0x24))->~FMatrix();
			appFree(refCount);
		}
		projectors->Remove(num - 1, 1, PROJ_STRIDE);
	}
}
Super::Destroy();
unguard;
}

// Ghidra: Engine.dll 0x103d02e0, 948 bytes.
// All FUN_ helpers are in _unnamed.cpp (confirmed). Each takes (FArchive*, FArray*)
// and returns FArchive* — the returned pointer chains to the next call.
// Legacy paths (ver < 0x5c / < 0x69) create scratch TArrays to skip over old data.
IMPL_MATCH("Engine.dll", 0x103d02e0)
void UModel::Serialize( FArchive& Ar )
{
guard(UModel::Serialize);
Super::Serialize(Ar);

typedef FArchive* (__cdecl* TArrSer)(FArchive*, void*);

// Phase 1: BSP geometry arrays (IsTrans-gated inside each helper)
FArchive* pAr = ((TArrSer)0x103ce2a0)(&Ar, (BYTE*)this + 0x7c); // TTransArray<FVector> Points
pAr = ((TArrSer)0x103ce2a0)(pAr, (BYTE*)this + 0x8c);           // TTransArray<FVector> Vectors
pAr = ((TArrSer)0x103d0250)(pAr, (BYTE*)this + 0x5c);           // TArray<FBspNode> Nodes
pAr = ((TArrSer)0x103ce7f0)(pAr, (BYTE*)this + 0x9c);           // TArray<FBspSurf> Surfs
pAr = ((TArrSer)0x103cd140)(pAr, (BYTE*)this + 0x6c);           // TArray<FVert> Verts

// Phase 2: shared sides and zone count
pAr->ByteOrderSerialize((BYTE*)this + 0x118, 4);   // NumSharedSides
pAr->ByteOrderSerialize((BYTE*)this + 0x11c, 4);   // NumZones

// Phase 3: zone entries at (i*9+0x24)*8 from model base (72 bytes per entry)
INT NumZones = *(INT*)((BYTE*)this + 0x11c);
for (INT i = 0; i < NumZones; i++)
	((TArrSer)0x103cca60)(&Ar, (BYTE*)this + (i * 9 + 0x24) * 8);

// Phase 4: Polys UObject ref + optional Preload (vtable[4] at +0x10)
Ar << *(UObject**)((BYTE*)this + 0x58);
if (*(UObject**)((BYTE*)this + 0x58) && !Ar.IsTrans())
	(*(void(__thiscall**)(FArchive*, UObject*))(*((INT*)&Ar) + 0x10))(&Ar, *(UObject**)((BYTE*)this + 0x58));

// Phase 5: version-gated legacy array paths
// Scratch TArrays absorb the serialized old-format data then go out of scope.
if (Ar.Ver() < 0x5c)
{
	TArray<BYTE> arr1, arr2;
	FArchive* t = ((TArrSer)0x103ce380)(&Ar, &arr1);
	((TArrSer)0x1031cce0)(t, &arr2);
}
else if (Ar.Ver() < 0x69)
{
	TArray<BYTE> arr1, arr2;
	FArchive* t = ((TArrSer)0x103ce380)(&Ar, &arr1);
	((TArrSer)0x1033a9a0)(t, &arr2);
}

// Phase 6: post-legacy arrays
pAr = ((TArrSer)0x103cd010)(&Ar, (BYTE*)this + 0xac); // FLightMapIndex array
pAr = ((TArrSer)0x103218c0)(pAr, (BYTE*)this + 0xb8); // INT index array
pAr = ((TArrSer)0x103cd1d0)(pAr, (BYTE*)this + 0xc4); // portal nodes
((TArrSer)0x103c09b0)(pAr, (BYTE*)this + 0xd0);        // zone visibility data

// Phase 7: scalar flags
Ar.ByteOrderSerialize((BYTE*)this + 0x10c, 4);   // RootOutside
Ar.ByteOrderSerialize((BYTE*)this + 0x110, 4);   // Linked

// Phase 8: render sections or old vertex stream (ver-gated)
if (Ar.Ver() > 0x5b)
{
	if (Ar.Ver() < 0x5d)
	{
		TArray<BYTE> arr;
		DWORD tag = 0;
		pAr = ((TArrSer)0x10322590)(&Ar, &arr);
		pAr->ByteOrderSerialize(&tag, 4);
	}
	else if (Ar.Ver() < 0x69)
	{
		TArray<BYTE> arr;
		((TArrSer)0x103cf9c0)(&Ar, &arr);
	}
	else
	{
		((TArrSer)0x103cf4f0)(&Ar, (BYTE*)this + 0xdc); // FBspSection array
	}
}

// Phase 9: FLightMap array (ver > 0x68)
if (Ar.Ver() > 0x68)
{
	if (Ar.Ver() < 0x6b)
	{
		TArray<BYTE> arr;
		((TArrSer)0x103cc860)(&Ar, &arr);
	}
	((TArrSer)0x103cfb40)(&Ar, (BYTE*)this + 0xf4);
	if (Ar.Ver() < 0x6b && Ar.IsLoading())
		((void(__thiscall*)(void*, int))0x10351e60)((BYTE*)this + 0xf4, 0);
}

// Phase 10: misc version-gated trailing fields
if (Ar.Ver() > 0x6a && Ar.Ver() < 0x6e)
{
	INT unused = 0;
	Ar.ByteOrderSerialize(&unused, 4);
}
if (Ar.Ver() > 0x6d)
	((TArrSer)0x103ce880)(&Ar, (BYTE*)this + 0xe8); // FLightMapTexture LeafHulls

unguard;
}

// Ghidra: Engine.dll 0x1046ed90, 651 bytes -- complex BSP point collision.
// Uses rdtsc() for per-call profiling counters that accumulate into a binary
// global stats table: iVar4 = *(int*)(DAT_10799554 + DAT_10799694*4) += elapsed cycles.
// DAT_10799554 and DAT_10799694 are BSP stats-array base and index — binary globals
// with no source declarations.  Neither the rdtsc nor the globals are replicable.
// Also calls unnamed BSP traversal helpers from UnBsp.cpp.
IMPL_DIVERGE("Ghidra 0x1046ed90: directly uses rdtsc() and binary globals DAT_10799554/DAT_10799694 (BSP profiling stats table) — permanent divergence; unnamed BSP traversal helpers also unresolved")
INT UModel::PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags )
{
guard(UModel::PointCheck);
return 1;
unguard;
}

// Ghidra: Engine.dll 0x1046feb0, 1542 bytes -- complex BSP line collision.
// Like PointCheck, uses rdtsc() around the BSP traversal and accumulates
// timing into DAT_10799554/DAT_10799694 (same binary-global stats table).
// Also calls unnamed BSP traversal helpers FUN_1046d860 and FUN_1046f1d0.
// Binary globals make byte parity permanently impossible.
IMPL_DIVERGE("Ghidra 0x1046feb0: directly uses rdtsc() and binary globals DAT_10799554/DAT_10799694 (BSP profiling stats table) — permanent divergence; FUN_1046d860/FUN_1046f1d0 unnamed BSP helpers also unresolved")
INT UModel::LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD TraceFlags, DWORD ExtraNodeFlags )
{
guard(UModel::LineCheck);
return 1;
unguard;
}

// Ghidra: Engine.dll 0x10446a50, 23 bytes.
// Copies 7 DWORDs from this+0x2c (the Bound FBox) into the return value.
// Also shared by UStaticMesh::GetRenderBoundingBox at the same address.
IMPL_MATCH("Engine.dll", 0x10446a50)
FBox UModel::GetRenderBoundingBox( const AActor* Owner )
{
guard(UModel::GetRenderBoundingBox);
FBox result(0);
const DWORD* src = (const DWORD*)((const BYTE*)this + 0x2c);
DWORD* dst = (DWORD*)&result;
for (INT i = 0; i < 7; i++)
    dst[i] = src[i];
return result;
unguard;
}

// Ghidra: Engine.dll 0x1046cbe0, 148 bytes.
// Owner==NULL: copies Bound (7 DWORDs at this+0x2c) straight into return value.
// Owner!=NULL: calls Owner vtable[0xac/4] to get transform matrix, returns
//              FBox::TransformBy(Bound, matrix).
IMPL_MATCH("Engine.dll", 0x1046cbe0)
FBox UModel::GetCollisionBoundingBox( const AActor* Owner ) const
{
guard(UModel::GetCollisionBoundingBox);
FBox bound(0);
const DWORD* src = (const DWORD*)((const BYTE*)this + 0x2c);
DWORD* dst = (DWORD*)&bound;
for (INT i = 0; i < 7; i++)
    dst[i] = src[i];
if (!Owner)
    return bound;
FMatrix mat;
(*(void(__thiscall**)(const AActor*, FMatrix*))(*((const INT*)Owner) + 0xac))(Owner, &mat);
return bound.TransformBy(mat);
unguard;
}

// Ghidra: Engine.dll 0x103d46f0, 2027 bytes -- complex BSP lighting pass.
// Full body requires unnamed lighting helpers from UnBsp.cpp.
IMPL_DIVERGE("Ghidra 0x103d46f0: BSP lightmap build pass is editor-only; not needed for gameplay")
void UModel::Illuminate( AActor* Owner, INT bExtra )
{
guard(UModel::Illuminate);
unguard;
}

// Ghidra: Engine.dll 0x10304990, 41 bytes.
// Calls vtable[0x74/4] (GetCollisionBoundingBox) then FBox::GetExtent.
// Shared stub -- also used by UProjectorPrimitive and UStaticMesh at the same address.
IMPL_MATCH("Engine.dll", 0x10304990)
FVector UModel::GetEncroachExtent( AActor* Owner )
{
guard(UModel::GetEncroachExtent);
FBox box(0);
(*(FBox*(__thiscall**)(UModel*, AActor*, FBox*))(*((INT*)this) + 0x74))(this, Owner, &box);
return box.GetExtent();
unguard;
}

// Ghidra: Engine.dll 0x1046ccb0, 41 bytes.
// Calls vtable[0x74/4] (GetCollisionBoundingBox) then FBox::GetCenter.
// Shared stub -- also used by UProjectorPrimitive and UStaticMesh at the same address.
IMPL_MATCH("Engine.dll", 0x1046ccb0)
FVector UModel::GetEncroachCenter( AActor* Owner )
{
guard(UModel::GetEncroachCenter);
FBox box(0);
(*(FBox*(__thiscall**)(UModel*, AActor*, FBox*))(*((INT*)this) + 0x74))(this, Owner, &box);
return box.GetCenter();
unguard;
}

// Ghidra: Engine.dll 0x103cba10, 8 bytes -- always returns 1 (always visible).
IMPL_MATCH("Engine.dll", 0x103cba10)
INT UModel::PotentiallyVisible( INT iLeaf0, INT iLeaf1 )
{
return 1;
}

// Ghidra: Engine.dll 0x10466269 (shared stub), 5 bytes -- always returns 0.
IMPL_MATCH("Engine.dll", 0x10466269)
INT UModel::UseCylinderCollision( const AActor* Owner )
{
return 0;
}

// Ghidra: Engine.dll 0x103ccf00, 219 bytes.
// Decomposes Box into centre+extent, then calls FUN_103ccc70 (BSP leaf collector)
// if the model has nodes.
IMPL_MATCH("Engine.dll", 0x103ccf00)
TArray<INT> UModel::BoxLeaves( FBox Box )
{
guard(UModel::BoxLeaves);
TArray<INT> result;
if (MODEL_NODES(this)->Num() != 0)
{
    FVector center, extent;
    Box.GetCenterAndExtents(center, extent);
    bspBoxLeavesHelper(this, 0,
                       center.X, center.Y, center.Z,
                       extent.X, extent.Y, extent.Z,
                       (FArray*)&result);
}
return result;
unguard;
}

// Ghidra: Engine.dll 0x103cd490, 351 bytes.
// Iterates all polys, collects vertices into a temporary FVector array (FArray of
// 0xc-byte elements), then builds FBox (this+0x2c) and FSphere (this+0x48) from
// those points.  Falls back to an invalid FBox when no polys exist.
// Vertex layout within FPoly: header is 0x30 bytes (4 x FVector), then numVerts
// vertices at stride 0xc; numVerts is stored at FPoly+0x100.
IMPL_MATCH("Engine.dll", 0x103cd490)
void UModel::BuildBound()
{
guard(UModel::BuildBound);
BYTE* polysPtr = MODEL_POLYS(this);
if (polysPtr != NULL)
{
    FArray* polysArr = (FArray*)(polysPtr + 0x2c);
    INT numPolys = polysArr->Num();
    if (numPolys != 0)
    {
        {
            FArray verts;
            BYTE* polyData = (BYTE*)polysArr->GetData();
            for (INT j = 0; j < numPolys; j++)
            {
                BYTE* poly   = polyData + j * FPOLY_STRIDE;
                INT numVerts = *(INT*)(poly + 0x100);
                for (INT i = 0; i < numVerts; i++)
                {
                    FVector* vtx = (FVector*)(poly + 0x30 + i * 0x0c);
                    INT idx      = verts.Add(1, 0x0c);
                    *(FVector*)((BYTE*)verts.GetData() + idx * 0x0c) = *vtx;
                }
            }
            INT      count  = verts.Num();
            FVector* points = (FVector*)verts.GetData();
            FBox box(points, count);
            DWORD* bsrc = (DWORD*)&box;
            DWORD* bdst = (DWORD*)((BYTE*)this + 0x2c);
            for (INT k = 7; k != 0; k--) *bdst++ = *bsrc++;
            FSphere sphere(points, count);
            *(FSphere*)((BYTE*)this + 0x48) = sphere;
        }
        return;
    }
}
// No polys: store an invalid (empty) bounding box.
FBox empty(0);
DWORD* esrc = (DWORD*)&empty;
DWORD* edst = (DWORD*)((BYTE*)this + 0x2c);
for (INT k = 7; k != 0; k--) *edst++ = *esrc++;
unguard;
}

// Ghidra: Engine.dll 0x103cf020, 880 bytes -- builds BSP render sections from nodes/surfs.
// Iterates all nodes, maps each to a surf material (defaulting to UMaterial CDO's
// DefaultMaterial at +0x30), then builds or grows FBspSection entries via the
// sections array. Vertex positions, texture UVs, lightmap UVs, and normals are
// computed per-vertex using FCoords/FMatrix transforms.
IMPL_MATCH("Engine.dll", 0x103cf020)
void UModel::BuildRenderData()
{
guard(UModel::BuildRenderData);

ClearRenderData( NULL );

FArray* nodes    = MODEL_NODES(this);
FArray* surfs    = MODEL_SURFS(this);
FArray* sections = MODEL_SECTIONS(this);

for (INT i = 0; i < nodes->Num(); i++)
{
    BYTE* node = (BYTE*)nodes->GetData() + i * NODE_STRIDE;
    INT iSurf  = *(INT*)(node + 0x34);
    BYTE* surf = (BYTE*)surfs->GetData() + iSurf * SURF_STRIDE;

    // Lightmap data pointer (stride 0xa4 in array at +0xf4)
    BYTE* lmData = NULL;
    INT lmIndex = *(INT*)(node + 0x80);
    if (lmIndex != -1)
        lmData = (BYTE*)(*(INT*)((BYTE*)this + 0xf4)) + lmIndex * 0xa4;

    // Material from surf.Texture (+0x00); fall back to UMaterial CDO's DefaultMaterial (+0x30)
    UMaterial* material = *(UMaterial**)surf;
    if (!material)
    {
        UObject* defObj = UMaterial::StaticClass()->GetDefaultObject();
        // FUN_10317670 = CastChecked<UMaterial>; CDO is UMaterial-typed in retail path.
        UMaterial* materialCDO = CastChecked<UMaterial>(defObj);
        material = *(UMaterial**)(((BYTE*)materialCDO) + 0x30);
    }

    // PolyFlags mask & lightmap ref for section matching
    DWORD polyFlags = *(DWORD*)(surf + 0x04) & 0x2400100;
    INT lmRef = lmData ? *(INT*)(lmData + 8) : -1;

    // Skip nodes with no vertices
    BYTE numVerts = *(BYTE*)(node + 0x6E);
    if (numVerts == 0)
        continue;

    // Search existing sections for a compatible match
    BYTE* sectionPtr = NULL;
    for (INT j = 0; j < sections->Num(); j++)
    {
        BYTE* sec = (BYTE*)sections->GetData() + j * 0x2c;
        if (*(UMaterial**)(sec + 0x20) == material &&
            *(DWORD*)(sec + 0x24) == polyFlags &&
            *(INT*)(sec + 0x28) == lmRef)
        {
            FArray* va = (FArray*)(sec + 0x04);
            if ((INT)((DWORD)numVerts + va->Num()) < 0xFFFF)
            {
                sectionPtr = sec;
                break;
            }
        }
    }

    // Create new section if no match found
    if (!sectionPtr)
    {
        INT idx = sections->Add(1, 0x2c);
        sectionPtr = (BYTE*)sections->GetData() + idx * 0x2c;
        if (sectionPtr)
            new (sectionPtr) FBspSection();
        else
            sectionPtr = NULL;
        *(UMaterial**)(sectionPtr + 0x20) = material;
        *(DWORD*)(sectionPtr + 0x24) = polyFlags;
        *(INT*)(sectionPtr + 0x28) = lmRef;
    }

    // Store section index in node (+0x78 = FirstRenderSection)
    *(INT*)(node + 0x78) = (INT)(sectionPtr - (BYTE*)sections->GetData()) / 0x2c;

    // Add vertices to the section's vertex array (+0x04)
    FArray* vertArr = (FArray*)(sectionPtr + 0x04);
    INT firstVert = vertArr->Add((INT)numVerts, 0x28);
    *(INT*)(node + 0x7C) = firstVert;

    // Build texture coordinate system from surf vectors
    // +0x8c = Points (positions), +0x7c = Vectors (normals/texture dirs)
    BYTE* points  = (BYTE*)(*(INT*)((BYTE*)this + 0x8c));
    BYTE* vectors = (BYTE*)(*(INT*)((BYTE*)this + 0x7c));
    INT pBase     = *(INT*)(surf + 0x08);
    INT vTextureU = *(INT*)(surf + 0x10);
    INT vTextureV = *(INT*)(surf + 0x14);
    INT vNormal   = *(INT*)(surf + 0x0C);

    FCoords texCoords(
        *(FVector*)(points + pBase * 0x0c),
        *(FVector*)(vectors + vTextureU * 0x0c),
        *(FVector*)(vectors + vTextureV * 0x0c),
        *(FVector*)(vectors + vNormal * 0x0c)
    );
    FMatrix texMatrix = texCoords.Matrix();

    // Get material USize/VSize (vtable +0x70 / +0x74)
    FLOAT uSize = (FLOAT)material->MaterialUSize();
    FLOAT vSize = (FLOAT)material->MaterialVSize();

    // Fill vertex data (stride 0x28 per vertex)
    BYTE* vertBase = (BYTE*)vertArr->GetData() + firstVert * 0x28;
    BYTE* vertsData = (BYTE*)(*(INT*)((BYTE*)this + 0x6c));  // Verts array data

    for (INT v = 0; v < (INT)numVerts; v++)
    {
        // Get vertex position: Points[ Verts[iVertPool + v].iVertex ]
        INT iVertPool = *(INT*)(node + 0x30);
        INT iVertex = *(INT*)(vertsData + (iVertPool + v) * 8);
        FVector pos = *(FVector*)(points + iVertex * 0x0c);

        BYTE* vout = vertBase + v * 0x28;

        // Position (+0x00)
        *(FVector*)vout = pos;

        // Texture UV (+0x18, +0x1C): transform position through texture matrix
        FVector texUV = texMatrix.TransformFVector(pos);
        *(FLOAT*)(vout + 0x18) = texUV.X / uSize;
        *(FLOAT*)(vout + 0x1C) = texUV.Y / vSize;

        // Lightmap UV (+0x20, +0x24)
        if (lmData)
        {
            FVector lmUV = ((FMatrix*)(lmData + 0x28))->TransformFVector(pos);
            *(FLOAT*)(vout + 0x20) = ((FLOAT)*(INT*)(lmData + 0x14) + lmUV.X) * (1.0f / 512.0f);
            *(FLOAT*)(vout + 0x24) = ((FLOAT)*(INT*)(lmData + 0x18) + lmUV.Y) * (1.0f / 512.0f);
        }

        // Normal (+0x0C): from node splitting plane
        *(FLOAT*)(vout + 0x0C) = *(FLOAT*)(node + 0x00);
        *(FLOAT*)(vout + 0x10) = *(FLOAT*)(node + 0x04);
        *(FLOAT*)(vout + 0x14) = *(FLOAT*)(node + 0x08);
    }

    // Increment section counters
    *(INT*)(sectionPtr + 0x18) = *(INT*)(sectionPtr + 0x18) + 1;
    *(INT*)(sectionPtr + 0x1C) = *(INT*)(sectionPtr + 0x1C) + 1;
}

unguard;
}

// Ghidra: Engine.dll 0x103cef10, 220 bytes.
// If sections non-empty: optionally releases GPU resources via RenDev vtable[0x78/4],
// clears FirstRenderSection (+0x78) and NumRenderSections (+0x7c) on all nodes to -1,
// calls FUN_10324a50 (unnamed) per section, then empties the sections array.
IMPL_DIVERGE("FUN_10324a50 inlined at call site in retail; calling separately produces same result but different codegen")
void UModel::ClearRenderData( URenderDevice* RenDev )
{
guard(UModel::ClearRenderData);
FArray* sections = MODEL_SECTIONS(this);
if (sections->Num() == 0)
    return;
if (RenDev)
{
    for (INT i = 0; i < sections->Num(); i++)
    {
        (*(void(__thiscall**)(URenderDevice*, INT, INT))(*((INT*)RenDev) + 0x78))(
            RenDev,
            *(INT*)(*(INT*)sections + i * 0x2c + 0x10),
            *(INT*)(*(INT*)sections + i * 0x2c + 0x14));
    }
}
FArray* nodes = MODEL_NODES(this);
for (INT i = 0; i < nodes->Num(); i++)
{
    *(INT*)(*(INT*)nodes + i * NODE_STRIDE + 0x78) = INDEX_NONE;
    *(INT*)(*(INT*)nodes + i * NODE_STRIDE + 0x7c) = INDEX_NONE;
}
// Per-section destructor: FUN_10324a50 destroys TArray<FBspVertex> at section+0x04.
// Retail: Read ArrayNum, Remove(0, Num, 0x28), then ~FArray.
// FUN_10324a50 ECX = FArray* at section+0x04 (NOT the section base).
{
    INT numSec = sections->Num();
    BYTE* secData = (BYTE*)sections->GetData();
    for (INT i = 0; i < numSec; i++)
    {
        FArray* vertArr = (FArray*)(secData + i * 0x2c + 4);
        INT cnt = vertArr->Num();
        if (cnt > 0)
            vertArr->Remove(0, cnt, 0x28);
        vertArr->~FArray();
    }
}
sections->Empty(0x2c, 0);
unguard;
}

// Ghidra: Engine.dll 0x103d2f10, 801 bytes -- compresses lightmap data in-place.
// Full body requires unnamed lightmap-compression helpers.
IMPL_DIVERGE("Ghidra 0x103d2f10: lightmap compression called only by the editor lightmap build pipeline; editor out of scope")
void UModel::CompressLightmaps()
{
guard(UModel::CompressLightmaps);
unguard;
}

// ============================================================================
// BSP convex-volume traversal helpers.
// These are unnamed static helpers (FUN_103fa310 and FUN_10470830 in Ghidra)
// extracted from Engine's _unnamed code segment.
// ============================================================================

// FUN_103fa310 (76 bytes, 0x103fa310):
// Computes the projection of a box half-extent onto a plane normal as
//   |normal.X * extent.X| + |normal.Y * extent.Y| + |normal.Z * extent.Z|
// This is the "box radius along plane direction" used in AABB vs FPlane tests.
static float BSPHalfExtentProject( const float* PlaneNormal, const float* Extent )
{
    float ax = PlaneNormal[0] * Extent[0]; if (ax < 0.f) ax = -ax;
    float ay = PlaneNormal[1] * Extent[1]; if (ay < 0.f) ay = -ay;
    float az = PlaneNormal[2] * Extent[2]; if (az < 0.f) az = -az;
    return ax + ay + az;
}

// FUN_10470830 (621 bytes, 0x10470830):
// Recursive BSP convex-volume traversal.  Starting at NodeIdx, compares
// the AABB (Center ± ScaledExtent) against the node's splitting plane:
//   - Entirely in front: recurse front child.
//   - Entirely behind: recurse back child.
//   - Straddling: add this node and all coplanar siblings (iCoplanar chain)
//     to Result (if the dot(Extent, plane_normal) < VisRadius), then
//     recurse both children.
//
// Parameters:
//   Model       - UModel*
//   NodeIdx     - current BSP node index (-1 terminates recursion)
//   Cx/Cy/Cz   - AABB centre (from FBox::GetCenter)
//   Ex/Ey/Ez    - scaled extent (Extent * 1.1f)
//   Px/Py/Pz    - original, un-scaled extent (used for the VisRadius dot test)
//   Result      - FArray* to collect hit node indices
//   VisRadius   - dot-product threshold against the original extent
static void BSPConvexVolumeTraverse( UModel* Model, INT NodeIdx,
    float Cx, float Cy, float Cz,
    float Ex, float Ey, float Ez,
    float Px, float Py, float Pz,
    FArray* Result, float VisRadius )
{
    if (NodeIdx == -1)
        return;

    BYTE* nodeBase = (BYTE*)MODEL_NODES(Model)->GetData();
    FPlane* Plane  = (FPlane*)(nodeBase + NodeIdx * NODE_STRIDE);

    float halfExtent  = BSPHalfExtentProject( (float*)Plane, &Ex );
    FVector Center_( Cx, Cy, Cz );
    float centerDot   = Plane->PlaneDot( Center_ );

    if (halfExtent < centerDot)
    {
        // AABB is entirely in front of the plane → recurse front child only.
        BSPConvexVolumeTraverse( Model, *(INT*)((BYTE*)Plane + 0x3c),
            Cx, Cy, Cz, Ex, Ey, Ez, Px, Py, Pz, Result, VisRadius );
        return;
    }

    if (centerDot < -halfExtent)
    {
        // AABB is entirely behind the plane → recurse back child only.
        BSPConvexVolumeTraverse( Model, *(INT*)((BYTE*)Plane + 0x38),
            Cx, Cy, Cz, Ex, Ey, Ez, Px, Py, Pz, Result, VisRadius );
        return;
    }

    // AABB straddles the plane: walk the coplanar-node chain starting at
    // NodeIdx, adding each node to Result when the vis-radius test passes,
    // then recurse both children.
    INT cur = NodeIdx;
    do
    {
        BYTE* nd = nodeBase + cur * NODE_STRIDE;
        float dot = Px * *(float*)nd + Py * *(float*)(nd + 4) + Pz * *(float*)(nd + 8);
        if (dot < VisRadius)
        {
            INT slot = Result->Add( 1, 4 );
            *(INT*)(*(INT*)Result + slot * 4) = cur;
        }
        cur = *(INT*)((BYTE*)MODEL_NODES(Model)->GetData() + 0x40 + cur * NODE_STRIDE);
    } while (cur != -1);

    BSPConvexVolumeTraverse( Model, *(INT*)((BYTE*)Plane + 0x3c),
        Cx, Cy, Cz, Ex, Ey, Ez, Px, Py, Pz, Result, VisRadius );
    BSPConvexVolumeTraverse( Model, *(INT*)((BYTE*)Plane + 0x38),
        Cx, Cy, Cz, Ex, Ey, Ez, Px, Py, Pz, Result, VisRadius );
}

// Ghidra: Engine.dll 0x10470aa0, 419 bytes.
// Checks which BSP nodes of this model are inside the convex volume defined by
// Planes[0..NumPlanes-1].  Box is the AABB of the volume, Extent is used for
// the VisRadius dot-product test, Result receives the matching node indices,
// and VisRadius is a maximum visibility distance threshold.
//
// Returns non-zero if at least one node is inside the volume.
//
// Implementation:
//   1. Empty Result.
//   2. Traverse BSP tree starting at node 0 using the scaled AABB (1.1x).
//   3. Post-filter: remove any node whose surface has the hidden flag (bit 0 of
//      FBspSurf.PolyFlags), and remove nodes that have at least one plane for
//      which all vertices are in front (i.e. the node is outside the frustum).
IMPL_MATCH("Engine.dll", 0x10470aa0)
INT UModel::ConvexVolumeMultiCheck( FBox& Box, FPlane* Planes, INT NumPlanes, FVector Extent, TArray<INT>& Result, FLOAT VisRadius )
{
guard(UModel::ConvexVolumeMultiCheck);

    Result.Empty();
    if (MODEL_NODES(this)->Num() == 0)
        return 0;

    // Scale the AABB extent by 1.1 to add a small fudge factor.
    FVector ScaledExtent = Box.GetExtent() * 1.1f;
    FVector Center       = Box.GetCenter();

    BSPConvexVolumeTraverse( this, 0,
        Center.X,       Center.Y,       Center.Z,
        ScaledExtent.X, ScaledExtent.Y, ScaledExtent.Z,
        Extent.X,       Extent.Y,       Extent.Z,
        (FArray*)&Result, VisRadius );

    // Filter out nodes whose surface is hidden (PolyFlags bit 0 set) and
    // nodes that lie entirely outside any of the bounding planes.
    // Ghidra: (*(byte*)(*(int*)(iVar1 + 0x34 + *(int*)(this+0x5c))) * 0x5c + 4 + *(int*)(this+0x9c)) & 1) == 0
    BYTE* surfBase = (BYTE*)MODEL_SURFS(this)->GetData();
    BYTE* nodeBase = (BYTE*)MODEL_NODES(this)->GetData();

    for (INT i = 0; i < Result.Num(); )
    {
        INT nodeIdx = Result(i);
        BYTE* nd    = nodeBase + nodeIdx * NODE_STRIDE;

        // Check hidden flag (FBspSurf.PolyFlags & 1).
        INT surfIdx = *(INT*)(nd + 0x34);
        if (surfBase[surfIdx * SURF_STRIDE + 4] & 1)
        {
            // Hidden surface — remove from result.
            Result.Remove( i, 1 );
            continue;
        }

        // Check each frustum plane: if all vertices of this node are in
        // front of plane j, the node is outside the frustum.
        BYTE* vptr = (BYTE*)MODEL_VERTS(this)->GetData();
        BYTE* ptBase = (BYTE*)MODEL_POINTS(this)->GetData();
        INT numVerts = (INT)(BYTE)*(nd + 0x6e);
        INT firstVert = *(INT*)(nd + 0x30);
        INT bRemove = 0;
        for (INT j = 0; j < NumPlanes && !bRemove; j++)
        {
            for (INT v = 0; v < numVerts; v++)
            {
                // vptr entry is 8 bytes: first 4 = point index.
                INT ptIdx = *(INT*)(vptr + (firstVert + v) * 8);
                FVector* pt = (FVector*)(ptBase + ptIdx * 0xc);
                FLOAT d = (Planes + j)->PlaneDot( *pt );
                if (d > 0.f)
                {
                    // At least one vertex is in front → node could be inside.
                    bRemove = 0;
                    break;
                }
                bRemove = 1; // tentatively: all verts so far are behind this plane
            }
        }

        if (bRemove)
        {
            Result.Remove( i, 1 );
        }
        else
        {
            i++;
        }
    }

    return Result.Num() > 0 ? 1 : 0;

unguard;
}

// Ghidra: Engine.dll 0x103cfd80, 1176 bytes.
// Phase 1: projector ref-count cleanup (same pattern as Destroy).
// Phase 2: GUndo->SaveArray for Nodes (LAB_ callbacks skipped — editor machinery).
// Phase 3: per-node projector FArray::~FArray + FArray::Empty for Nodes.
// Phase 4: Empty LightMap, VertIdx, and several other BSP arrays.
// Phase 5: element-destructor loops for +0xf4 and +0xe8 implemented.
// Phase 6: sections array — per-section FUN_10324a50 destructor implemented.
// Phase 7 (EmptySurfs): GUndo skipped; empties Points, Vectors, Surfs with per-surf cleanup.
// Phase 8 (EmptyPolys): creates new UPolys via StaticAllocateObject + zone table reset.
// DIVERGENCE: GUndo callbacks omitted (editor-only, NULL at runtime).
IMPL_DIVERGE("GUndo LAB_ callbacks omitted (editor-only, always NULL at runtime; Ghidra 0x103cfd80)")
void UModel::EmptyModel( INT EmptySurfs, INT EmptyPolys )
{
guard(UModel::EmptyModel);
// Phase 1: projector ref-count cleanup (see Destroy for full annotation).
FArray* nodes = MODEL_NODES(this);
INT numNodes = nodes->Num();
BYTE* nodeData = (BYTE*)nodes->GetData();
for (INT i = 0; i < numNodes; i++)
{
	FArray* projectors = (FArray*)(nodeData + i * NODE_STRIDE + 0x84);
	while (projectors->Num() >= 1)
	{
		INT num = projectors->Num();
		BYTE* lastEntry = (BYTE*)projectors->GetData() + (num - 1) * PROJ_STRIDE;
		INT* refCount = *(INT**)lastEntry;
		(*refCount)--;
		if (*refCount == 0)
		{
			// FUN_103719b0 inline: same as Destroy.
			((FMatrix*)((BYTE*)refCount + 0x64))->~FMatrix();
			((FMatrix*)((BYTE*)refCount + 0x24))->~FMatrix();
			appFree(refCount);
		}
		projectors->Remove(num - 1, 1, PROJ_STRIDE);
	}
}
// GUndo->SaveArray for Nodes omitted (LAB_ callbacks are editor undo machinery;
// GUndo==NULL during gameplay).
// Phase 3: separate loop to destruct each node's projector sub-FArray.
// Ghidra: FUN_1033bbc0(0, count) + FArray::~FArray per node.
for (INT i = 0; i < numNodes; i++)
{
	FArray* projectors = (FArray*)(nodeData + i * NODE_STRIDE + 0x84);
	INT cnt = projectors->Num();
	if (cnt > 0)
		projectors->Remove(0, cnt, PROJ_STRIDE);
	projectors->~FArray();
}
// GUndo->SaveArray for Nodes omitted (LAB_ callbacks are editor undo machinery;
// GUndo==NULL during gameplay).
MODEL_NODES(this)->Empty(NODE_STRIDE, 0);

// Phase 4: additional BSP array empties.
// +0xac = LightMap, +0xb8 = VertIdx (matches current), +0xc4 elem=0x14,
// +0x6c = Verts, +0xd0 elem=4.
MODEL_LIGHTMAP(this)->Empty(0x1c, 0);
MODEL_VERTIDX(this)->Empty(4, 0);
((FArray*)((BYTE*)this + 0xc4))->Empty(0x14, 0);
// GUndo->SaveArray for Verts omitted (editor machinery).
MODEL_VERTS(this)->Empty(8, 0);
((FArray*)((BYTE*)this + 0xd0))->Empty(4, 0);

// Phase 5: arrays at +0xf4 (elem=0xa4) and +0x100 (elem=4) and +0xe8 (elem=0x6c).
// Per-element destructors for +0xf4: each element has TArray at base, FMatrix at +0x28,
// FArray at +0x8c. Ghidra: FUN_10322eb0 (TArray dtor), FUN_1032e660 (sub-array clear),
// FArray::~FArray, FMatrix::~FMatrix per element.
{
	FArray* arr0xf4 = (FArray*)((BYTE*)this + 0xf4);
	INT num0xf4 = arr0xf4->Num();
	BYTE* data0xf4 = (BYTE*)arr0xf4->GetData();
	for (INT j = 0; j < num0xf4; j++)
	{
		BYTE* elem = data0xf4 + j * 0xa4;
		((FArray*)elem)->~FArray();                // TArray at element base (FUN_10322eb0)
		((FArray*)(elem + 0x8c))->Empty(0, *(INT*)(elem + 0x90)); // FUN_1032e660(0, Num)
		((FArray*)(elem + 0x8c))->~FArray();       // FArray::~FArray at +0x8c
		((FMatrix*)(elem + 0x28))->~FMatrix();     // FMatrix::~FMatrix at +0x28
	}
}
((FArray*)((BYTE*)this + 0xf4))->Empty(0xa4, 0);
((FArray*)((BYTE*)this + 0x100))->Empty(4, 0);
// Per-element destructors for +0xe8 (stride 0x6c): Ghidra shows
// _eh_vector_destructor_iterator_ for 2 TLazyArray<BYTE> at +0x18, then TArray dtor.
// TLazyArray<BYTE> layout: +0x00=FArray(12b), +0x0C=FLazyLoader vtable(4b),
// +0x10=SavedAr(4b), +0x14=SavedPos(4b) = 0x18 per element.
// ~TLazyArray: if(SavedAr) SavedAr->DetachLazyLoader(this); then ~FArray.
{
	FArray* arr0xe8 = (FArray*)((BYTE*)this + 0xe8);
	INT num0xe8 = arr0xe8->Num();
	BYTE* data0xe8 = (BYTE*)arr0xe8->GetData();
	for (INT j = 0; j < num0xe8; j++)
	{
		BYTE* elem = data0xe8 + j * 0x6c;
		// Retail: _eh_vector_destructor_iterator_(elem+0x18, 0x18, 2, TLazyArray<BYTE>::~TLazyArray)
		// Destruct two TLazyArray<BYTE> at +0x30 and +0x18 (reverse order)
		for (INT k = 1; k >= 0; k--)
		{
			BYTE* tla = elem + 0x18 + k * 0x18;
			FArchive* savedAr = *(FArchive**)(tla + 0x10);
			if (savedAr)
				savedAr->DetachLazyLoader((FLazyLoader*)(tla + 0x0C));
			((FArray*)tla)->~FArray();
		}
		((FArray*)elem)->~FArray();                // TArray dtor at base (FUN_10322eb0)
	}
}
((FArray*)((BYTE*)this + 0xe8))->Empty(0x6c, 0);

// Phase 6: render sections — FUN_10324a50 per section destructs sub-FArray (stride 0x28).
// Ghidra: iterates *(this+0xe0) sections, each element starts with an FArray that owns
// stride-0x28 entries (index buffer data). FUN_10324a50 = Remove(0,Num,0x28) + ~FArray.
// ECX for FUN_10324a50 = FArray at section+0x04 (after vtable/pad slot at +0x00).
{
	INT numSections = *(INT*)((BYTE*)this + 0xe0);
	BYTE* secData = (BYTE*)MODEL_SECTIONS(this)->GetData();
	for (INT j = 0; j < numSections; j++)
	{
		FArray* subArr = (FArray*)(secData + j * 0x2c + 4);
		INT cnt = subArr->Num();
		if (cnt > 0)
			subArr->Remove(0, cnt, 0x28);
		subArr->~FArray();
	}
}
MODEL_SECTIONS(this)->Empty(0x2c, 0);

if (EmptySurfs)
{
	// GUndo->SaveArray calls omitted (editor machinery; GUndo==NULL at runtime).
	MODEL_POINTS(this)->Empty(0xc, 0);
	MODEL_VECTORS(this)->Empty(0xc, 0);
	// Per-surf TArray cleanup: Ghidra calls FUN_10322eb0 per surf element.
	{
		FArray* surfs = MODEL_SURFS(this);
		INT numSurfs = surfs->Num();
		BYTE* surfData = (BYTE*)surfs->GetData();
		for (INT j = 0; j < numSurfs; j++)
		{
			BYTE* surf = surfData + j * SURF_STRIDE;
			((FArray*)surf)->~FArray();            // TArray dtor per surf (FUN_10322eb0)
		}
	}
	MODEL_SURFS(this)->Empty(SURF_STRIDE, 0);
}

if (EmptyPolys)
{
	// Create new UPolys: StaticAllocateObject + placement-new constructor.
	FName PolyName(NAME_None);
	UObject* Outer = GetOuter();
	UObject* NewPolys = UObject::StaticAllocateObject(
		UPolys::StaticClass(), Outer, PolyName, 1, NULL, GError, NULL);
	if (NewPolys)
		NewPolys = (UObject*)new(NewPolys) UPolys();
	*(UObject**)((BYTE*)this + 0x58) = NewPolys;
}

// Zone table reset: NumSharedSides=4, NumZones=0, clear zone visibility/connectivity.
*(INT*)((BYTE*)this + 0x118) = 4;
*(INT*)((BYTE*)this + 0x11c) = 0;
for (INT z = 0; z < 256; z++)
{
	// Each zone entry is at offset (z*9 + 0x24) * 8 = z*0x48 + 0x120
	// ZoneActors pointer: *(this + (z*9+0x24)*8) = 0
	*(INT*)((BYTE*)this + (z * 9 + 0x24) * 8) = 0;

	// Zone visibility bitmask: 8 DWORDs starting at this + z*0x48 + 0x128
	INT visBase = z * 0x48 + 0x128;
	for (INT k = 0; k < 8; k++)
		*(INT*)((BYTE*)this + visBase + k * 4) = 0;

	// Self-visibility: set own bit in the visibility mask
	*(DWORD*)((BYTE*)this + (z >> 5) * 4 + visBase) |= (1u << (z & 0x1f));

	// Zone rejection bitmask: 8 DWORDs at this + (z*0x12)*4 + 0x148
	for (INT k = 0; k < 8; k++)
		*(INT*)((BYTE*)this + (k + z * 0x12) * 4 + 0x148) = (INT)0xffffffff;
}
unguard;
}

// Ghidra: Engine.dll 0x1046d250, 173 bytes.
// Caches Nodes.Data into DAT_1079bfe4 (GBspNodes), then if nodes exist calls
// FUN_1046cd40 (fast BSP line traversal); otherwise returns (BYTE)RootOutside.
IMPL_MATCH("Engine.dll", 0x1046d250)
BYTE UModel::FastLineCheck( FVector Start, FVector End )
{
guard(UModel::FastLineCheck);
FArray* nodes = MODEL_NODES(this);
GBspNodes = *(INT*)nodes;
if (nodes->Num() == 0)
    return (BYTE)MODEL_ROOTOUTSIDE(this);
return bspFastLineCheck(0,
                        Start.X, Start.Y, Start.Z,
                        End.X,   End.Y,   End.Z,
                        (BYTE)MODEL_ROOTOUTSIDE(this));
unguard;
}

// Ghidra: Engine.dll 0x10470770, 129 bytes.
// Returns -1 if no nodes; otherwise calls FUN_104704f0 (BSP nearest-vertex finder).
IMPL_MATCH("Engine.dll", 0x10470770)
FLOAT UModel::FindNearestVertex( const FVector& SourcePoint, FVector& DestPoint, FLOAT MinRadius, INT& iVertex ) const
{
guard(UModel::FindNearestVertex);
if (MODEL_NODES(this)->Num() == 0)
    return -1.f;
return bspFindNearestVertexHelper(const_cast<UModel*>(this),
                                   &SourcePoint, &DestPoint,
                                   MinRadius, 0, &iVertex);
unguard;
}

// Ghidra: Engine.dll 0x103cb990, 73 bytes.
// Calls UObject::Modify via vtable slot 0x20/4 on Polys if Polys is non-null.
IMPL_MATCH("Engine.dll", 0x103cb990)
void UModel::Modify( INT DoTransArrays )
{
guard(UModel::Modify);
BYTE* polys = MODEL_POLYS(this);
if (polys)
    (*(void(__thiscall**)(BYTE*))(*((INT*)polys) + 0x20))(polys);
unguard;
}

// Ghidra: Engine.dll 0x103ce6b0, 95 bytes -- calls ModifySurf for every surface.
IMPL_MATCH("Engine.dll", 0x103ce6b0)
void UModel::ModifyAllSurfs( INT SetBits )
{
guard(UModel::ModifyAllSurfs);
for (INT i = 0; i < MODEL_SURFS(this)->Num(); i++)
    ModifySurf(i, SetBits);
unguard;
}

// Ghidra: Engine.dll 0x103ce740, 117 bytes.
// Only calls ModifySurf for surfaces with PF_Selected (0x2000000) in PolyFlags (surf+0x04).
IMPL_MATCH("Engine.dll", 0x103ce740)
void UModel::ModifySelectedSurfs( INT SetBits )
{
guard(UModel::ModifySelectedSurfs);
FArray* surfs = MODEL_SURFS(this);
for (INT i = 0; i < surfs->Num(); i++)
{
    if (*(DWORD*)(*(INT*)surfs + i * SURF_STRIDE + 0x04) & 0x2000000)
        ModifySurf(i, SetBits);
}
unguard;
}

// Ghidra: Engine.dll 0x103ce5c0, 184 bytes.
// Records undo for Surfs[iSurf] via GUndo->SaveArray (vtable+4).
// If SetBits is set and the surf has an actor back-ref (surf+0x1c), also records
// the undo entry for that actor's brush poly (surf+0x18 gives poly index).
IMPL_DIVERGE("Ghidra 0x103ce5c0: GUndo->SaveArray callbacks LAB_10317600/LAB_10326190 are editor undo machinery; GUndo==NULL during gameplay — behaviour complete")
void UModel::ModifySurf( INT iSurf, INT SetBits )
{
guard(UModel::ModifySurf);
if (GUndo)
    GUndo->SaveArray(*(UObject**)((BYTE*)this + 0xa8),
                     (FArray*)((BYTE*)this + 0x9c),
                     iSurf, 1, 0, SURF_STRIDE, NULL, NULL);
if (SetBits)
{
    INT surfBase = *(INT*)((BYTE*)this + 0x9c) + iSurf * SURF_STRIDE;
    INT actor    = *(INT*)(surfBase + 0x1c);
    if (actor != 0)
    {
        INT polysPtr = *(INT*)(*(INT*)(actor + 0x178) + 0x58);
        if (GUndo)
            GUndo->SaveArray(*(UObject**)(polysPtr + 0x38),
                             (FArray*)(polysPtr + 0x2c),
                             *(INT*)(surfBase + 0x18), 1, 0, FPOLY_STRIDE, NULL, NULL);
    }
}
unguard;
}

// Ghidra: Engine.dll 0x1046dc70, 353 bytes.
// Traverses the BSP tree from root to find which zone contains Location.
// Each node splits space with its FPlane; negative dot → back child, non-negative → front child.
// iOutside (init = RootOutside) tracks the current zone-boundary state.
// After traversal the zone leaf and zone number are read from the last node visited,
// and the AZoneInfo actor is fetched from the per-zone slot at this+0x120+N*0x48.
IMPL_MATCH("Engine.dll", 0x1046dc70)
FPointRegion UModel::PointRegion( AZoneInfo* Zone, FVector Location ) const
{
guard(UModel::PointRegion);
check(Zone != NULL);
FPointRegion result;
result.Zone       = Zone;
result.iLeaf      = INDEX_NONE;
result.ZoneNumber = 0;

FArray* nodes = MODEL_NODES(this);
if (nodes->Num() == 0)
    return result;

INT  iOutside = MODEL_ROOTOUTSIDE(this);
INT  iSide    = 0;
INT  iLast    = 0;
INT  iNode    = 0;   // start at root

while (iNode != INDEX_NONE)
{
    BYTE*   nodeBase = (BYTE*)nodes->GetData() + iNode * NODE_STRIDE;
    FPlane* plane    = (FPlane*)nodeBase;
    FLOAT   dot      = plane->PlaneDot(Location);
    iLast = iNode;

    if (dot < 0.0f)
    {
        // Back side
        iSide = 0;
        BYTE leaf  = *(BYTE*)(nodeBase + 0x6e);
        BYTE flags = *(BYTE*)(nodeBase + 0x6f);
        if ((iOutside == 0) || (leaf != 0 && (flags & 0x21) == 0))
            iOutside = 0;
        else
            iOutside = 1;
        iNode = *(INT*)(nodeBase + 0x38);   // back child
    }
    else
    {
        // Front side
        iSide = 1;
        BYTE leaf  = *(BYTE*)(nodeBase + 0x6e);
        BYTE flags = *(BYTE*)(nodeBase + 0x6f);
        if ((iOutside == 0) && (leaf == 0 || (flags & 0x21) != 0))
            iOutside = 0;
        else
            iOutside = 1;
        iNode = *(INT*)(nodeBase + 0x3c);   // front child
    }
}

// Read iLeaf: node[iLast].iLeaf[iSide] lives at nodes.Data + iLast*0x90 + 0x70 + iSide*4.
// Ghidra: (iSide + iLast*0x24)*4 = iSide*4 + iLast*0x90
result.iLeaf = *(INT*)((BYTE*)nodes->GetData() + 0x70 + (iSide + iLast * 0x24) * 4);

// ZoneNumber byte at node[iLast]+0x6c+iSide (only when NumZones != 0)
BYTE zoneNum = 0;
if (*(INT*)((BYTE*)this + 0x11c) != 0)   // NumZones
    zoneNum = *(BYTE*)((BYTE*)nodes->GetData() + iLast * NODE_STRIDE + 0x6c + iSide);
result.ZoneNumber = zoneNum;

// Zone actor slot: this + (zoneNum+4)*0x48  (zone 0 entry is at this+0x120 = this+4*0x48)
AZoneInfo* zoneActor = *(AZoneInfo**)((BYTE*)this + (zoneNum + 4) * 0x48);
if (zoneActor != NULL)
    result.Zone = zoneActor;

return result;
unguard;
}

// Ghidra: Engine.dll 0x1046de90, 89 bytes.
// Calls FUN_1046de10 (BSP sphere filter precomputation) if nodes exist.
IMPL_MATCH("Engine.dll", 0x1046de90)
void UModel::PrecomputeSphereFilter( const FPlane& Sphere )
{
guard(UModel::PrecomputeSphereFilter);
if (MODEL_NODES(this)->Num() != 0)
    bspPrecomputeSphereFilterHelper(this, 0, &Sphere);
unguard;
}

// Ghidra: Engine.dll 0x1046db50, 288 bytes.
// Loads FPlane from Nodes[iNode] (stride NODE_STRIDE=0x90, first 16 bytes = FPlane).
// Computes PlaneDot for End (fVar2) then Start (fVar3).
// Straddle check: (fVar2<=-0.001 || fVar3<=-0.001) && (fVar2>=0.001 || fVar3>=0.001).
// On straddle: t = DotStart/(DotStart-DotEnd), Result.Location = Start + Dir*t, return 1.
// On no-straddle: log (Ghidra output garbled) and return 0.
// NOTE: Ghidra uses unaff_retaddr to hold &Result, and param numbering for FVector
//       components is ambiguous — logic reconstructed from plane-intersection pattern.
IMPL_DIVERGE("Ghidra 0x1046db50: unaff_retaddr artifact makes FCheckResult* parameter untrackable by Ghidra; logic reconstructed from plane-intersection pattern — byte parity unachievable")
INT UModel::R6LineCheck( FCheckResult& Result, INT iNode, FVector Start, FVector End )
{
guard(UModel::R6LineCheck);
FPlane* Plane = (FPlane*)(*(INT*)((BYTE*)this + 0x5c) + iNode * (INT)NODE_STRIDE);
FLOAT DotEnd   = Plane->PlaneDot(End);
FLOAT DotStart = Plane->PlaneDot(Start);
if ((DotEnd <= -0.001f || DotStart <= -0.001f) &&
    (DotEnd >= 0.001f  || DotStart >= 0.001f))
{
    FVector Dir = End - Start;
    FLOAT t = DotStart / (DotStart - DotEnd);
    Result.Location = Start + Dir * t;
    return 1;
}
return 0;
unguard;
}

// Ghidra: Engine.dll 0x103cc780, 172 bytes.
// Shrinks Points(0xc), Vectors(0xc), Verts(8), Nodes(0x90), Surfs(0x5c),
// conditionally Polys->Elems(0x15c), LightMap(0x1c), VertIndices(4).
IMPL_MATCH("Engine.dll", 0x103cc780)
void UModel::ShrinkModel()
{
guard(UModel::ShrinkModel);
MODEL_POINTS(this)->Shrink(0x0c);
MODEL_VECTORS(this)->Shrink(0x0c);
MODEL_VERTS(this)->Shrink(8);
MODEL_NODES(this)->Shrink(NODE_STRIDE);
MODEL_SURFS(this)->Shrink(SURF_STRIDE);
BYTE* polys = MODEL_POLYS(this);
if (polys)
    ((FArray*)(polys + 0x2c))->Shrink(FPOLY_STRIDE);
MODEL_LIGHTMAP(this)->Shrink(0x1c);
MODEL_VERTIDX(this)->Shrink(4);
unguard;
}

// Ghidra: Engine.dll 0x103cd620, 255 bytes.
// Asserts Brush != NULL, records undo for Polys via GUndo (if set),
// calls ABrush::BuildCoords to get FModelCoords, then transforms each FPoly.
IMPL_DIVERGE("Ghidra 0x103cd620: GUndo undo-recording callback LAB_103171d0 is editor undo machinery; GUndo==NULL during gameplay — poly transform implemented")
void UModel::Transform( ABrush* Brush )
{
guard(UModel::Transform);
check(Brush != NULL);
BYTE*   polys   = MODEL_POLYS(this);
FArray* polyArr = (FArray*)(polys + 0x2c);
// GUndo undo recording omitted -- GUndo is NULL during normal gameplay.
FModelCoords coords;
FLOAT orient = Brush->BuildCoords(&coords, NULL);
INT numPolys = polyArr->Num();
for (INT i = 0; i < numPolys; i++)
{
    FPoly* poly = (FPoly*)((BYTE*)polyArr->GetData() + i * FPOLY_STRIDE);
    poly->Transform(coords, *(FVector*)((BYTE*)Brush + 0x2c8),
                            *(FVector*)((BYTE*)Brush + 0x234), orient);
}
unguard;
}

// Ghidra: Engine.dll 0x103cd750, 2842 bytes -- full BSP render pass.
// Dispatches to unnamed BSP render helpers for zone visibility, surface batching,
// decals, dynamic actors, fog zones, sky zones, and post-processing.
// Involves FCanvasUtil, FLineBatcher, and many vtable-dispatched RenderInterface calls.
// No binary-global or rdtsc blockers; all FUN_ helpers are in _unnamed.cpp and
// theoretically tractable, but volume and complexity are high.
IMPL_TODO("Ghidra 0x103cd750 (2842b): Render body still pending; dispatcher relies on many unresolved BSP helpers (zone visibility, section batching, decals, fog/sky paths, post effects) from _unnamed.cpp. No permanent blocker identified.")
void UModel::Render( FDynamicActor*, FLevelSceneNode*, FRenderInterface* )
{
guard(UModel::Render);
unguard;
}

// Ghidra: Engine.dll 0x103cea90, 1081 bytes -- attaches projector to BSP nodes/surfs.
// Phase 1: prunes expired projector entries by calling FUN_103ccb10 per entry.
//   FUN_103ccb10 (0x103ccb10, 151 bytes): uses rdtsc() + GSecondsPerCycle to compute
//   elapsed time since projector was created; returns 0 if expired and decrements
//   refcount (calling FUN_103719b0 + appFree if it reaches 0).
// Phase 2: AddZeroed a new projector entry, stores FProjectorRenderInfo* in first field.
// Phase 3: if clip planes given, projects them into node space via FVector/FPlane math.
// Blocked by FUN_103ccb10 (unnamed expiry helper; uses rdtsc+GSecondsPerCycle timing;
// rdtsc-based timing helpers are a confirmed permanent IMPL_DIVERGE category per AGENTS.md).
IMPL_DIVERGE("Ghidra 0x103cea90 (1025b): FUN_103ccb10 is called to check/expire stale projector render-info entries using rdtsc+GSecondsPerCycle timing. rdtsc-based timing is a permanent binary-only divergence; remaining projection/clipping logic in _unnamed.cpp also pending.")
void UModel::AttachProjector( int iNode, FProjectorRenderInfo* ProjInfo, FPlane* Planes )
{
guard(UModel::AttachProjector);
unguard;
}

// =============================================================================
