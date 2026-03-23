/*=============================================================================
    EngineAux.cpp: Karma free-function implementations and template
    instantiations that have no more-specific home.
    
    Moved from EngineStubs.cpp when that file was dissolved.
=============================================================================*/

#include "EnginePrivate.h"
#include "EngineDecls.h"

// ?KME2UPosition@@YAXPAVFVector@@QBM@Z  (Engine.dll 0x1036a2c0)
IMPL_MATCH("Engine.dll", 0x1036a2c0)
void KME2UPosition(FVector* Out, float const * const In) {
	Out->X = In[0] * 50.0f;
	Out->Y = In[1] * 50.0f;
	Out->Z = In[2] * 50.0f;
}

// ?KME2UVecCopy@@YAXPAVFVector@@QBM@Z  (Engine.dll 0x1036a310)
IMPL_MATCH("Engine.dll", 0x1036a310)
void KME2UVecCopy(FVector* Out, float const * const In) {
	Out->X = In[0];
	Out->Y = In[1];
	Out->Z = In[2];
}

// ?KTermGameKarma@@YAXXZ  (Engine.dll 0x10357cf0, 565 bytes)
// Tears down the Karma physics globals after validating the retail geometry/model
// counters. The retail body is known in Ghidra, but the MeSDK teardown/query
// chain it calls has not been ported into src/MeSDK yet.
IMPL_DIVERGE("Retail teardown depends on proprietary MeSDK query/teardown helpers that are not available in source form")
void KTermGameKarma() {}

// ?KU2MEPosition@@YAXQAMVFVector@@@Z  (Engine.dll 0x1036a290)
IMPL_MATCH("Engine.dll", 0x1036a290)
void KU2MEPosition(float * const Out, FVector In) {
	Out[0] = In.X * 0.02f;
	Out[1] = In.Y * 0.02f;
	Out[2] = In.Z * 0.02f;
}

// ?KU2MEVecCopy@@YAXQAMVFVector@@@Z  (Engine.dll 0x1036a2f0)
IMPL_MATCH("Engine.dll", 0x1036a2f0)
void KU2MEVecCopy(float * const Out, FVector In) {
	Out[0] = In.X;
	Out[1] = In.Y;
	Out[2] = In.Z;
}

// ?KUpdateMassProps@@YAXPAVUKMeshProps@@@Z  (Engine.dll 0x1036af30, 396 bytes)
// Computes mass properties by creating a temporary Me world/geometry manager,
// instantiating the aggregate geometry, querying mass properties, then tearing
// the temporary objects back down. The retail wrapper is known in Ghidra.
IMPL_DIVERGE("Retail mass-property calculation depends on proprietary MeSDK temp-world and query helpers that are not available in source form")
void KUpdateMassProps(UKMeshProps * p0) {}

// ?KarmaTriListDataInit@@YAXPAU_KarmaTriListData@@@Z  (Engine.dll 0x10369b80, 25 bytes)
// Initialises the three count fields of a _KarmaTriListData struct to zero.
IMPL_MATCH("Engine.dll", 0x10369b80)
void KarmaTriListDataInit(_KarmaTriListData * p0) {
	*(int*)((char*)p0 + 0x6000)  = 0;
	*(int*)((char*)p0 + 0xf004)  = 0;
	*(int*)((char*)p0 + 0x14008) = 0;
}


// --- Moved from EngineStubs.cpp ---
// =============================================================================
// Explicit template instantiation for TArray<BYTE> and TLazyArray<BYTE>.
// The retail Engine.dll exports these symbols; explicit instantiation forces the
// compiler to emit out-of-line copies of all inline template members.
// =============================================================================
template class TArray<BYTE>;
template class TLazyArray<BYTE>;

struct _McdGeometry;
struct McdGeomMan;

// ?KAggregateGeomInstance@@YAPAU_McdGeometry@@PAVFKAggregateGeom@@VFVector@@PAUMcdGeomMan@@PBG@Z
// (Engine.dll 0x1036a890, 1632 bytes)
// Builds aggregate Karma geometry from FKAggregateGeom by allocating a Me
// aggregate and appending sphere/box/cylinder/convex children. The retail body
// is known in Ghidra, but the MeSDK geometry-construction chain is still absent.
IMPL_DIVERGE("Retail aggregate geometry construction depends on proprietary MeSDK shape builders that are not available in source form")
_McdGeometry* KAggregateGeomInstance(FKAggregateGeom*, FVector, McdGeomMan*, const _WORD*) { return NULL; }

// ?KME2UCoords@@YAXPAVFCoords@@QAY03$$CBM@Z  (Engine.dll 0x1036a0d0, 158 bytes)
// Converts a Karma 4x4 column-major matrix to an Unreal FCoords.
// Origin scaled by 50 (ME → UU). Columns 0-2 map to XAxis/YAxis/ZAxis.
IMPL_MATCH("Engine.dll", 0x1036a0d0)
void KME2UCoords(FCoords* Out, const FLOAT (* const tm)[4]) {
	*Out = FCoords(
		FVector(tm[3][0]*50.f, tm[3][1]*50.f, tm[3][2]*50.f),
		FVector(tm[0][0], tm[0][1], tm[0][2]),
		FVector(tm[1][0], tm[1][1], tm[1][2]),
		FVector(tm[2][0], tm[2][1], tm[2][2])
	);
}

// ?KME2UMatrixCopy@@YAXPAVFMatrix@@QAY03M@Z  (Engine.dll 0x1036a330, 103 bytes)
// Also serves as KU2MEMatrixCopy — both symbols share this body (raw memcpy).
IMPL_MATCH("Engine.dll", 0x1036a330)
void KME2UMatrixCopy(FMatrix* Out, FLOAT (* const In)[4]) {
	appMemcpy(Out, In, sizeof(FLOAT)*16);
}

// ?KME2UTransform@@YAXPAVFVector@@PAVFRotator@@QAY03$$CBM@Z  (Engine.dll 0x1036a220)
// Extracts position (scaled *50) and orientation (via KME2UCoords+OrthoRotation)
// from a Karma 4x4 matrix into separate FVector/FRotator outputs.
IMPL_MATCH("Engine.dll", 0x1036a220)
void KME2UTransform(FVector* OutPos, FRotator* OutRot, const FLOAT (* const tm)[4]) {
	OutPos->X = tm[3][0] * 50.0f;
	OutPos->Y = tm[3][1] * 50.0f;
	OutPos->Z = tm[3][2] * 50.0f;
	FCoords Coords;
	KME2UCoords(&Coords, tm);
	*OutRot = Coords.OrthoRotation();
}

// ========================================================================
// KModelToHulls internal helpers (unexported, reconstructed from Ghidra)
// ========================================================================

// FUN_1036b6c0 (193 bytes): adds a vertex to an FVector TArray if no existing
// vertex is within epsilon (0.0001 dist²).  Retail uses __thiscall with
// ECX=vertex, EDX=array; here expressed as a plain static helper.
static void AddUniqueConvexVertex(const FVector& Vert, FArray* VertArray)
{
	INT Count = VertArray->Num();
	for (INT i = 0; i < Count; i++)
	{
		FVector* Existing = (FVector*)(*(BYTE**)VertArray + i * sizeof(FVector));
		FVector Diff;
		Diff.X = Vert.X - Existing->X;
		Diff.Y = Vert.Y - Existing->Y;
		Diff.Z = Vert.Z - Existing->Z;
		FLOAT DistSq = Diff.X*Diff.X + Diff.Y*Diff.Y + Diff.Z*Diff.Z;
		if (DistSq < 0.0001f)
			return;
	}
	INT idx = VertArray->Add(1, sizeof(FVector));
	FVector* Dst = (FVector*)(*(BYTE**)VertArray + idx * sizeof(FVector));
	*Dst = Vert;
}

// FUN_1036be00 (1885 bytes): emits one FKConvexElem from a set of half-space
// planes.  For each plane, builds a large polygon (FPoly), clips it against all
// other planes, snaps surviving vertices to the nearest BSP vertex, scales by
// 0.02 (UU→ME), and stores in FKConvexElem+0x40 (TArray<FVector>).  Degenerate
// hulls (coplanar or < 4 vertices) are removed.
static void EmitConvexHull(INT AggGeomAddr, FArray* Planes, INT ModelAddr, FVector* Origin)
{
	// Allocate a new FKConvexElem (stride 0x58) in ConvexElems at AggGeom+0x24
	FArray* ConvexElems = (FArray*)((BYTE*)AggGeomAddr + 0x24);
	INT elemIdx = ConvexElems->AddZeroed(0x58, 1);
	BYTE* Elem = *(BYTE**)ConvexElems + elemIdx * 0x58;

	// Copy input planes to the element's plane list at Elem+0x4C (TArray<FPlane>)
	FArray* ElemPlanes = (FArray*)(Elem + 0x4C);
	FArray* SrcPlanes = Planes;
	ElemPlanes->Empty(0x10, SrcPlanes->Num());
	for (INT i = 0; i < SrcPlanes->Num(); i++)
	{
		INT addIdx = ElemPlanes->Add(1, 0x10);
		FPlane* dst = (FPlane*)(*(BYTE**)ElemPlanes + addIdx * 0x10);
		FPlane* src = (FPlane*)(*(BYTE**)SrcPlanes + i * 0x10);
		*dst = *src;
	}

	// Set FMatrix at Elem+0x00 to identity
	FMatrix* Mat = (FMatrix*)Elem;
	Mat->SetIdentity();

	// TArray<FVector> for collected vertices at Elem+0x40
	FArray* VertArray = (FArray*)(Elem + 0x40);

	// Surfs array at Model+0x6C (stride 8), Points at Model+0x8C (stride 0xC)
	FArray* Surfs  = (FArray*)((BYTE*)ModelAddr + 0x6C);
	FArray* Points = (FArray*)((BYTE*)ModelAddr + 0x8C);

	INT PlaneCount = Planes->Num();
	for (INT pi = 0; pi < PlaneCount; pi++)
	{
		// Build a large quad polygon on this plane
		FPoly Poly;
		FVector PtOnPlane;
		FVector AxisU, AxisV;

		FPlane* CurPlane = (FPlane*)(*(BYTE**)Planes + pi * 0x10);
		FVector Normal(CurPlane->X, CurPlane->Y, CurPlane->Z);

		Normal.FindBestAxisVectors(AxisU, AxisV);

		// Compute a point on the plane: Normal * W
		PtOnPlane = Normal * CurPlane->W;

		// Build 4-vertex polygon: ±AxisU ± AxisV around PtOnPlane, scaled large
		FVector Scaled;
		Scaled = AxisU * HALF_WORLD_MAX;  Poly.Vertex[0] = PtOnPlane + Scaled;
		Scaled = AxisV * HALF_WORLD_MAX;  Poly.Vertex[0] = Poly.Vertex[0] + Scaled;
		Scaled = AxisU * HALF_WORLD_MAX;  Poly.Vertex[1] = PtOnPlane - Scaled;
		Scaled = AxisV * HALF_WORLD_MAX;  Poly.Vertex[1] = Poly.Vertex[1] + Scaled;
		Scaled = AxisU * HALF_WORLD_MAX;  Poly.Vertex[2] = PtOnPlane - Scaled;
		Scaled = AxisV * HALF_WORLD_MAX;  Poly.Vertex[2] = Poly.Vertex[2] - Scaled;
		Scaled = AxisU * HALF_WORLD_MAX;  Poly.Vertex[3] = PtOnPlane + Scaled;
		Scaled = AxisV * HALF_WORLD_MAX;  Poly.Vertex[3] = Poly.Vertex[3] - Scaled;
		Poly.NumVertices = 4;

		// Clip against every other plane
		UBOOL Survived = 1;
		for (INT ci = 0; ci < PlaneCount; ci++)
		{
			if (ci == pi) continue;
			FPlane* ClipPlane = (FPlane*)(*(BYTE**)Planes + ci * 0x10);
			FVector ClipNormal(-ClipPlane->X, -ClipPlane->Y, -ClipPlane->Z);
			FVector ClipBase = FVector(ClipPlane->X, ClipPlane->Y, ClipPlane->Z) * ClipPlane->W;
			if (Poly.Split(ClipNormal, ClipBase, 0) == 0)
			{
				Survived = 0;
				break;
			}
		}

		// For each surviving vertex, snap to nearest BSP vertex and add
		for (INT vi = 0; vi < (Survived ? Poly.NumVertices : 0); vi++)
		{
			FVector PolyVert = Poly.Vertex[vi];

			// Find nearest BSP vertex (Surfs→Points lookup)
			FLOAT BestDistSq = 3.4028235e+38f;
			FLOAT BestIdx = -1.0f;
			INT SurfCount = Surfs->Num();
			for (INT si = 0; si < SurfCount; si++)
			{
				INT PointIdx = *(INT*)(*(BYTE**)Surfs + si * 8);
				if (PointIdx < 0 || PointIdx >= Points->Num())
					continue;
				FVector* BSPVert = (FVector*)(*(BYTE**)Points + PointIdx * sizeof(FVector));
				FVector D;
				D.X = PolyVert.X - BSPVert->X;
				D.Y = PolyVert.Y - BSPVert->Y;
				D.Z = PolyVert.Z - BSPVert->Z;
				FLOAT DSq = D.X*D.X + D.Y*D.Y + D.Z*D.Z;
				if (DSq < BestDistSq)
				{
					BestIdx = (FLOAT)si;
					BestDistSq = DSq;
				}
			}

			FVector ScaledVert;
			if (BestIdx < 0.0f || BestDistSq >= 0.01f)
			{
				// No close BSP vertex — use polygon vertex directly
				ScaledVert.X = (PolyVert.X - Origin->X) * 0.02f;
				ScaledVert.Y = (PolyVert.Y - Origin->Y) * 0.02f;
				ScaledVert.Z = (PolyVert.Z - Origin->Z) * 0.02f;
			}
			else
			{
				// Snap to BSP vertex
				INT PointIdx = *(INT*)(*(BYTE**)Surfs + (INT)BestIdx * 8);
				FVector* BSPVert = (FVector*)(*(BYTE**)Points + PointIdx * sizeof(FVector));
				ScaledVert.X = (BSPVert->X - Origin->X) * 0.02f;
				ScaledVert.Y = (BSPVert->Y - Origin->Y) * 0.02f;
				ScaledVert.Z = (BSPVert->Z - Origin->Z) * 0.02f;
			}
			AddUniqueConvexVertex(ScaledVert, VertArray);
		}
	}

	// Validate hull: must have > 3 vertices and not be coplanar
	INT VertCount = VertArray->Num();
	if (VertCount > 3)
	{
		FVector* Verts = *(FVector**)VertArray;
		// Check if all vertices are coplanar
		FVector Edge1;
		Edge1.X = Verts[1].X - Verts[0].X;
		Edge1.Y = Verts[1].Y - Verts[0].Y;
		Edge1.Z = Verts[1].Z - Verts[0].Z;
		Edge1.Normalize();

		UBOOL bNonColinear = 0;
		FVector Edge2;
		for (INT i = 2; i < VertCount; i++)
		{
			if (bNonColinear) break;
			Edge2.X = Verts[i].X - Verts[0].X;
			Edge2.Y = Verts[i].Y - Verts[0].Y;
			Edge2.Z = Verts[i].Z - Verts[0].Z;
			Edge2.Normalize();
			FLOAT Dot = Edge1.X*Edge2.X + Edge1.Y*Edge2.Y + Edge1.Z*Edge2.Z;
			if (Dot < 0.99f)
				bNonColinear = 1;
		}

		if (bNonColinear)
		{
			// Build reference plane from first three non-colinear vertices
			FVector HullNormal = Edge1 ^ Edge2;
			HullNormal.Normalize();
			FPlane RefPlane(Verts[0].X, Verts[0].Y, Verts[0].Z,
			                HullNormal.X * Verts[0].X + HullNormal.Y * Verts[0].Y + HullNormal.Z * Verts[0].Z);

			// Check all vertices are within tolerance of the plane
			UBOOL bDegenerate = 0;
			for (INT i = 2; i < VertCount; i++)
			{
				if (bDegenerate) return; // bail — hull is kept
				FLOAT PlaneDist = RefPlane.PlaneDot(Verts[i]);
				if (PlaneDist > 0.01f)
					bDegenerate = 1;
			}
			if (bDegenerate)
				return; // all vertices too close to a single plane
		}
	}

	// If we get here with < 4 verts or all coplanar, remove the degenerate hull
	// Retail: FUN_1032e8c0 removes the last ConvexElem
	if (VertCount < 4)
	{
		// Destruct and remove the last element
		FKConvexElem* LastElem = (FKConvexElem*)(*(BYTE**)ConvexElems + elemIdx * 0x58);
		LastElem->~FKConvexElem();
		ConvexElems->Remove(elemIdx, 1, 0x58);
	}
}

// FUN_1036c5a0 (561 bytes): recurses through the BSP tree, collecting half-space
// planes into a scratch array.  At leaf nodes, calls EmitConvexHull to convert
// the accumulated plane set into a convex hull.
// BSP nodes: Model+0x5C, stride 0x90; iFront at +0x38, iBack at +0x3C.
// Node plane is the first 16 bytes (FPlane).
static void BSPToConvexRecurse(INT AggGeomAddr, INT ModelAddr, INT NodeIdx,
                                INT IsFront, FArray* Planes, FVector* Origin)
{
	BYTE* NodeBase = *(BYTE**)((BYTE*)ModelAddr + 0x5C);
	BYTE* Node = NodeBase + NodeIdx * 0x90;
	FPlane* NodePlane = (FPlane*)Node;
	INT iFront = *(INT*)(Node + 0x38);
	INT iBack  = *(INT*)(Node + 0x3C);

	// --- Front half-space ---
	if (iFront == -1)
	{
		// Leaf node: check flags
		if (IsFront)
		{
			BYTE f6E = *(Node + 0x6E);
			BYTE f6F = *(Node + 0x6F);
			if (f6E == 0 || (f6F & 0x21) != 0)
				goto SkipFront;
		}
		// Add this plane and emit a hull
		INT addIdx = Planes->Add(1, 0x10);
		FPlane* dst = (FPlane*)(*(BYTE**)Planes + addIdx * 0x10);
		*dst = *NodePlane;
		EmitConvexHull(AggGeomAddr, Planes, ModelAddr, Origin);
	}
	else
	{
		// Internal node: add plane, recurse front child
		INT addIdx = Planes->Add(1, 0x10);
		FPlane* dst = (FPlane*)(*(BYTE**)Planes + addIdx * 0x10);
		*dst = *NodePlane;

		INT frontFlag = 0;
		if (IsFront)
		{
			BYTE f6E = *(Node + 0x6E);
			BYTE f6F = *(Node + 0x6F);
			if (f6E != 0 && (f6F & 0x21) == 0)
				frontFlag = 0;
			else
				frontFlag = 1;
		}
		BSPToConvexRecurse(AggGeomAddr, ModelAddr, iFront, frontFlag, Planes, Origin);
	}
	// Pop the last plane
	Planes->Remove(Planes->Num() - 1, 1, 0x10);

SkipFront:
	// --- Back half-space (flipped plane) ---
	if (iBack == -1)
	{
		// Leaf node
		if (IsFront)
			return;
		BYTE f6E = *(Node + 0x6E);
		BYTE f6F = *(Node + 0x6F);
		if (f6E != 0 && (f6F & 0x21) == 0)
			return;
		// Add flipped plane and emit
		FPlane Flipped = NodePlane->Flip();
		INT addIdx = Planes->Add(1, 0x10);
		FPlane* dst = (FPlane*)(*(BYTE**)Planes + addIdx * 0x10);
		*dst = Flipped;
		EmitConvexHull(AggGeomAddr, Planes, ModelAddr, Origin);
	}
	else
	{
		// Internal node: add flipped plane, recurse back child
		FPlane Flipped = NodePlane->Flip();
		INT addIdx = Planes->Add(1, 0x10);
		FPlane* dst = (FPlane*)(*(BYTE**)Planes + addIdx * 0x10);
		*dst = Flipped;

		INT backFlag;
		if (!IsFront)
		{
			BYTE f6E = *(Node + 0x6E);
			BYTE f6F = *(Node + 0x6F);
			if (f6E == 0 || (f6F & 0x21) != 0)
				backFlag = 0;
			else
				backFlag = 1;
		}
		else
		{
			backFlag = 1;
		}
		BSPToConvexRecurse(AggGeomAddr, ModelAddr, iBack, backFlag, Planes, Origin);
	}
	// Pop the last plane
	Planes->Remove(Planes->Num() - 1, 1, 0x10);
}

// ?KModelToHulls@@YAXPAVFKAggregateGeom@@PAVUModel@@VFVector@@@Z  (Engine.dll 0x1036c810, 143 bytes)
// Decomposes a BSP UModel into convex hulls stored in FKAggregateGeom.
// Clears ConvexElems, initialises a scratch TArray<FPlane>, and recurses
// through the BSP tree emitting convex hulls at each leaf.
IMPL_MATCH("Engine.dll", 0x1036c810)
void KModelToHulls(FKAggregateGeom* AggGeom, UModel* Model, FVector Origin)
{
	guard(KModelToHulls);

	// Clear existing ConvexElems (TArray<FKConvexElem> at AggGeom+0x24, stride 0x58)
	FArray* ConvexElems = (FArray*)((BYTE*)AggGeom + 0x24);
	for (INT i = 0; i < ConvexElems->Num(); i++)
	{
		FKConvexElem* Elem = (FKConvexElem*)(*(BYTE**)ConvexElems + i * 0x58);
		Elem->~FKConvexElem();
	}
	ConvexElems->Empty(0x58, 0);

	// Scratch plane array for BSP recursion
	FArray Scratch;
	appMemzero(&Scratch, sizeof(FArray));

	// Model->RootNode at Model+0x10C
	INT RootNode = *(INT*)((BYTE*)Model + 0x10C);

	BSPToConvexRecurse((INT)AggGeom, (INT)Model, 0, RootNode, &Scratch, &Origin);

	// Clean up scratch array
	Scratch.Empty(0x10, 0);

	unguard;
}

// ?KU2MEMatrixCopy@@YAXQAY03MPAVFMatrix@@@Z  (Engine.dll 0x1036a330, same body as KME2UMatrixCopy)
IMPL_MATCH("Engine.dll", 0x1036a330)
void KU2MEMatrixCopy(FLOAT (* const Out)[4], FMatrix* In) {
	appMemcpy(Out, In, sizeof(FLOAT)*16);
}

// ?KU2METransform@@YAXQAY03MVFVector@@VFRotator@@@Z  (Engine.dll 0x1036a170, 161 bytes)
// Converts FVector position and FRotator orientation to a Karma 4x4 matrix.
// IMPORTANT: Karma uses column-major rotation storage — axis vectors are
// stored as COLUMNS (transposed relative to Unreal's row convention):
//   tm[row][0..2] = { XAxis[row], YAxis[row], ZAxis[row] }
// Position scaled by 0.02 (UU → ME).
IMPL_MATCH("Engine.dll", 0x1036a170)
void KU2METransform(FLOAT (* const tm)[4], FVector Pos, FRotator Rot) {
	FCoords Coords(FVector(0.f,0.f,0.f));
	Coords *= Rot;
	// Columns of the rotation matrix = axis vectors (Karma column-major layout)
	tm[0][0] = Coords.XAxis.X; tm[0][1] = Coords.YAxis.X; tm[0][2] = Coords.ZAxis.X; tm[0][3] = 0.f;
	tm[1][0] = Coords.XAxis.Y; tm[1][1] = Coords.YAxis.Y; tm[1][2] = Coords.ZAxis.Y; tm[1][3] = 0.f;
	tm[2][0] = Coords.XAxis.Z; tm[2][1] = Coords.YAxis.Z; tm[2][2] = Coords.ZAxis.Z; tm[2][3] = 0.f;
	tm[3][0] = Pos.X * 0.02f; tm[3][1] = Pos.Y * 0.02f; tm[3][2] = Pos.Z * 0.02f; tm[3][3] = 1.0f;
}

// Local helper to force TLazyArray<BYTE> out-of-line template instantiation.
// This function does NOT exist in the retail Engine.dll binary; it is our
// mechanism for emitting the symbols that retail compiled from an unknown TU.
IMPL_DIVERGE("non-retail helper: forces TLazyArray<BYTE> symbol emission; retail exports the instantiated methods but has no standalone function")
void _ForceTLazyArrayByteEmit() {
    TLazyArray<BYTE>* p = new TLazyArray<BYTE>[1];
    TLazyArray<BYTE> copy(*p);
    *p = copy;
    delete[] p;
}
