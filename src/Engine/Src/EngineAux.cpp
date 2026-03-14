/*=============================================================================
    EngineAux.cpp: Karma free-function implementations and template
    instantiations that have no more-specific home.
    
    Moved from EngineStubs.cpp when that file was dissolved.
=============================================================================*/
#pragma optimize("", off)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// ?KME2UPosition@@YAXPAVFVector@@QBM@Z
IMPL_APPROX("Reconstructed from Karma coordinate conversion; scale factor 50")
void KME2UPosition(FVector* Out, float const * const In) {
	Out->X = In[0] * 50.0f;
	Out->Y = In[1] * 50.0f;
	Out->Z = In[2] * 50.0f;
}

// ?KME2UVecCopy@@YAXPAVFVector@@QBM@Z
IMPL_APPROX("Reconstructed from Karma coordinate conversion; direct copy")
void KME2UVecCopy(FVector* Out, float const * const In) {
	Out->X = In[0];
	Out->Y = In[1];
	Out->Z = In[2];
}

// ?KTermGameKarma@@YAXXZ
IMPL_TODO("Needs Ghidra analysis")
void KTermGameKarma() {}

// ?KU2MEPosition@@YAXQAMVFVector@@@Z
IMPL_APPROX("Reconstructed from Karma coordinate conversion; scale factor 0.02")
void KU2MEPosition(float * const Out, FVector In) {
	Out[0] = In.X * 0.02f;
	Out[1] = In.Y * 0.02f;
	Out[2] = In.Z * 0.02f;
}

// ?KU2MEVecCopy@@YAXQAMVFVector@@@Z
IMPL_APPROX("Reconstructed from Karma coordinate conversion; direct copy")
void KU2MEVecCopy(float * const Out, FVector In) {
	Out[0] = In.X;
	Out[1] = In.Y;
	Out[2] = In.Z;
}

// ?KUpdateMassProps@@YAXPAVUKMeshProps@@@Z
IMPL_TODO("Needs Ghidra analysis")
void KUpdateMassProps(UKMeshProps * p0) {}

// ?KarmaTriListDataInit@@YAXPAU_KarmaTriListData@@@Z
IMPL_TODO("Needs Ghidra analysis")
void KarmaTriListDataInit(_KarmaTriListData * p0) {}


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

IMPL_TODO("Needs Ghidra analysis")
_McdGeometry* KAggregateGeomInstance(FKAggregateGeom*, FVector, McdGeomMan*, const _WORD*) { return NULL; }
IMPL_APPROX("Reconstructed from Karma coordinate conversion; scale factor 50")
void KME2UCoords(FCoords* Out, const FLOAT (* const tm)[4]) {
	*Out = FCoords(
		FVector(tm[3][0]*50.f, tm[3][1]*50.f, tm[3][2]*50.f),
		FVector(tm[0][0], tm[0][1], tm[0][2]),
		FVector(tm[1][0], tm[1][1], tm[1][2]),
		FVector(tm[2][0], tm[2][1], tm[2][2])
	);
}
IMPL_APPROX("Reconstructed from Karma coordinate conversion; direct memcpy")
void KME2UMatrixCopy(FMatrix* Out, FLOAT (* const In)[4]) {
	appMemcpy(Out, In, sizeof(FLOAT)*16);
}
IMPL_APPROX("Reconstructed from Karma coordinate conversion")
void KME2UTransform(FVector* OutPos, FRotator* OutRot, const FLOAT (* const tm)[4]) {
	OutPos->X = tm[3][0] * 50.0f;
	OutPos->Y = tm[3][1] * 50.0f;
	OutPos->Z = tm[3][2] * 50.0f;
	FCoords Coords;
	KME2UCoords(&Coords, tm);
	*OutRot = Coords.OrthoRotation();
}
IMPL_TODO("Needs Ghidra analysis")
void KModelToHulls(FKAggregateGeom*, UModel*, FVector) {}
IMPL_APPROX("Reconstructed from Karma coordinate conversion; direct memcpy")
void KU2MEMatrixCopy(FLOAT (* const Out)[4], FMatrix* In) {
	appMemcpy(Out, In, sizeof(FLOAT)*16);
}
IMPL_APPROX("Reconstructed from Karma coordinate conversion")
void KU2METransform(FLOAT (* const tm)[4], FVector Pos, FRotator Rot) {
	FCoords Coords(FVector(0.f,0.f,0.f));
	Coords *= Rot;
	tm[0][0] = Coords.XAxis.X; tm[0][1] = Coords.XAxis.Y; tm[0][2] = Coords.XAxis.Z; tm[0][3] = 0.f;
	tm[1][0] = Coords.YAxis.X; tm[1][1] = Coords.YAxis.Y; tm[1][2] = Coords.YAxis.Z; tm[1][3] = 0.f;
	tm[2][0] = Coords.ZAxis.X; tm[2][1] = Coords.ZAxis.Y; tm[2][2] = Coords.ZAxis.Z; tm[2][3] = 0.f;
	tm[3][0] = Pos.X * 0.02f; tm[3][1] = Pos.Y * 0.02f; tm[3][2] = Pos.Z * 0.02f; tm[3][3] = 1.0f;
}

IMPL_APPROX("Forces TLazyArray<BYTE> template instantiation for retail symbol export")
void _ForceTLazyArrayByteEmit() {
    TLazyArray<BYTE>* p = new TLazyArray<BYTE>[1];
    TLazyArray<BYTE> copy(*p);
    *p = copy;
    delete[] p;
}
