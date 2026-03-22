/*=============================================================================
    EngineAux.cpp: Karma free-function implementations and template
    instantiations that have no more-specific home.
    
    Moved from EngineStubs.cpp when that file was dissolved.
=============================================================================*/
#pragma optimize("", off)

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

// ?KModelToHulls@@YAXPAVFKAggregateGeom@@PAVUModel@@VFVector@@@Z  (Engine.dll 0x1036c810, 143 bytes)
// Decomposes a BSP UModel into convex hulls stored in FKAggregateGeom. Retail
// first clears AggGeom->ConvexElems (0x58 stride), then uses a local TArray<FPlane>
// scratch stack while recursing the BSP and emitting FKConvexElem hulls.
IMPL_TODO("Ghidra 0x1036c810 (143b): wrapper calls FUN_1036c5a0(AggGeom,Model,0,Model->RootNode,scratchArray,origin) which is the real BSP-to-convex recursion; FUN_1036be00/FUN_1036b6c0 are secondary convex-emission helpers. All three helpers are unexported internals not yet ported. FKConvexElem+0x4C = FPlane array layout required. KModelToHulls body is trivially: FArray scratch; FUN_1036c5a0(AggGeom,Model,0,*(Model+0x10c),scratch,origin).")
void KModelToHulls(FKAggregateGeom*, UModel*, FVector) {}

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
