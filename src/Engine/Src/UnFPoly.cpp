/*=============================================================================
	UnFPoly.cpp: Face polygon helpers (FBezier)
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

#include "EngineDecls.h"

// --- FBezier ---
IMPL_EMPTY("Copy constructor — compiler-synthesized, no managed resources; Ghidra shows no body")
FBezier::FBezier(FBezier const &)
{
}

IMPL_EMPTY("Default constructor — no fields to initialize; Ghidra shows no body")
FBezier::FBezier()
{
}

IMPL_EMPTY("Destructor — no resources to release; Ghidra shows no body")
FBezier::~FBezier()
{
}

IMPL_EMPTY("Ghidra VA 0x10311630 (RVA 0x11630) confirms retail body is trivial (5 bytes)")
FBezier& FBezier::operator=(const FBezier&)
{
	return *this;
}

IMPL_MATCH("Engine.dll", 0x203F0)
float FBezier::Evaluate(FVector *,int,TArray<FVector> *)
{
	return 0.0f;
}


// ============================================================================
// FPoly::operator= and GetTextureSize
// (moved from EngineStubs.cpp)
// ============================================================================

// ??4FPoly@@QAEAAV0@ABV0@@Z
IMPL_MATCH("Engine.dll", 0x2E00)
FPoly & FPoly::operator=(FPoly const & Other) {
	appMemcpy(this, &Other, sizeof(FPoly));
	return *this;
}

// ?GetTextureSize@FPoly@@QAE?AVFVector@@XZ
IMPL_MATCH("Engine.dll", 0x9CB40)
FVector FPoly::GetTextureSize()
{
	if( !Material )
		return FVector( 256.f, 256.f, 0.f );
	return FVector( (FLOAT)Material->MaterialVSize(), (FLOAT)Material->MaterialUSize(), 0.f );
}

// --- Moved from EngineStubs.cpp ---
// ?Area@FPoly@@QAEMXZ
IMPL_MATCH("Engine.dll", 0x9C510)
float FPoly::Area() {
	FLOAT TotalArea = 0.f;
	FVector Side1 = Vertex[1] - Vertex[0];
	for( INT i=2; i<NumVertices; i++ ) {
		FVector Side2 = Vertex[i] - Vertex[0];
		FLOAT TriArea = (Side1 ^ Side2).Size();
		TotalArea += TriArea;
		Side1 = Side2;
	}
	return TotalArea;
}
// ?CalcNormal@FPoly@@QAEHH@Z
IMPL_MATCH("Engine.dll", 0x9C780)
int FPoly::CalcNormal(int bSilent) {
	Normal = FVector(0,0,0);
	for( INT i=2; i<NumVertices; i++ )
		Normal += (Vertex[i-1] - Vertex[0]) ^ (Vertex[i] - Vertex[0]);
	if( Normal.SizeSquared() < 0.0001f ) {
		return 1;
	}
	Normal.Normalize();
	return 0;
}

// ?DoesLineIntersect@FPoly@@QAEHVFVector@@0PAV2@@Z
// ?DoesLineIntersect@FPoly@@QAEHVFVector@@0PAV2@@Z — Ghidra at 0x9E760.
// Tests if a line segment intersects this polygon. Optionally returns the hit point.
IMPL_MATCH("Engine.dll", 0x9E760)
int FPoly::DoesLineIntersect(FVector Start, FVector End, FVector * Intersection) {
	FLOAT d1 = (Start - Vertex[0]) | Normal;
	FLOAT d2 = (End   - Vertex[0]) | Normal;

	// Check that the line straddles the polygon's plane.
	if( (d1 >= 0.f || d2 >= 0.f) && (d1 <= 0.f || d2 <= 0.f) )
	{
		FVector Hit = FLinePlaneIntersection( Start, End, Vertex[0], Normal );
		if( Intersection )
			*Intersection = Hit;

		// Only count as intersection if hit point is not at an endpoint.
		if( !(Hit == Start) && !(Hit == End) )
			return OnPoly( Hit );
	}
	return 0;
}

// ?Faces@FPoly@@QBEHABV1@@Z
IMPL_MATCH("Engine.dll", 0x9E8E0)
int FPoly::Faces(FPoly const & Other) const {
	if( IsCoplanar(Other) )
		return 0;
	for( INT i=0; i<Other.NumVertices; i++ ) {
		FLOAT d = (Other.Vertex[i] - Base) | Normal;
		if( d < 0.f ) {
			for( INT j=0; j<NumVertices; j++ ) {
				FLOAT d2 = (Vertex[j] - Other.Base) | Other.Normal;
				if( d2 > 0.f )
					return 1;
			}
			return 0;
		}
	}
	return 0;
}

// ?Finalize@FPoly@@QAEHH@Z — Ghidra at 0x9e190.
// Cleans up polygon: removes duplicate verts, validates, computes normal & texture vectors.
IMPL_MATCH("Engine.dll", 0x9e190)
int FPoly::Finalize(int bSilent) {
	Fix();
	if( NumVertices < 3 )
	{
		debugf( NAME_Warning, TEXT("FPoly::Finalize: Not enough vertices (%i)"), NumVertices );
		if( bSilent )
			return -1;
		appErrorf( TEXT("FPoly::Finalize: Not enough vertices (%i)"), NumVertices );
	}
	if( Normal.IsZero() && NumVertices >= 3 )
	{
		if( CalcNormal(0) )
		{
			debugf( NAME_Warning, TEXT("FPoly::Finalize: Normalization failed, IsZero=%i, Size=%f"), Normal.IsZero(), Normal.Size() );
			if( bSilent )
				return -1;
			appErrorf( TEXT("FPoly::Finalize: Normalization failed, IsZero=%i, Size=%f"), Normal.IsZero(), Normal.Size() );
		}
	}
	if( TextureU.IsZero() && TextureV.IsZero() )
	{
		for( INT i=1; i<NumVertices; i++ )
		{
			TextureU = ((Vertex[0] - Vertex[i]) ^ Normal).SafeNormal();
			TextureV = (Normal ^ TextureU).SafeNormal();
			if( TextureU.SizeSquared() != 0.f && TextureV.SizeSquared() != 0.f )
				return 0;
		}
	}
	return 0;
}

// ?Fix@FPoly@@QAEHXZ
IMPL_MATCH("Engine.dll", 0x9CEC0)
int FPoly::Fix()
{
	INT j = 0;
	INT prev = NumVertices - 1;
	for( INT i = 0; i < NumVertices; i++ )
	{
		if( !FPointsAreSame( Vertex[i], Vertex[prev] ) )
		{
			if( j != i )
				Vertex[j] = Vertex[i];
			prev = j;
			j++;
		}
		else
		{
			debugf( NAME_Warning, TEXT("FPoly::Fix: Deleted a duplicate vertex") );
		}
	}
	if( j < 3 )
		j = 0;
	NumVertices = j;
	return j;
}

// ?IsBackfaced@FPoly@@QBEHABVFVector@@@Z
IMPL_MATCH("Engine.dll", 0x2CE0)
int FPoly::IsBackfaced(FVector const & Point) const {
	return ((Point - Base) | Normal) < 0.f;
}

// ?IsCoplanar@FPoly@@QBEHABV1@@Z
IMPL_MATCH("Engine.dll", 0x18B80)
int FPoly::IsCoplanar(FPoly const & Other) const {
	FLOAT d = (Base - Other.Base) | Normal;
	if( d < 0.f ) d = -d;
	if( d < 0.01f ) {
		FLOAT dot = Other.Normal | Normal;
		if( dot < 0.f ) dot = -dot;
		if( dot > 0.9999f )
			return 1;
	}
	return 0;
}

// ?OnPlane@FPoly@@QAEHVFVector@@@Z
IMPL_MATCH("Engine.dll", 0x9DE70)
int FPoly::OnPlane(FVector Point) {
	FLOAT d = (Point - Vertex[0]) | Normal;
	return (d > -0.1f && d < 0.1f) ? 1 : 0;
}

// ?OnPoly@FPoly@@QAEHVFVector@@@Z
// ?OnPoly@FPoly@@QAEHVFVector@@@Z — Ghidra at 0x9DD10.
// Returns 1 if Point lies inside the polygon, 0 otherwise.
IMPL_MATCH("Engine.dll", 0x9DD10)
int FPoly::OnPoly(FVector Point) {
	for( INT i=0; i<NumVertices; i++ )
	{
		INT j = i - 1;
		if( j < 0 ) j = NumVertices - 1;
		FVector Side = Vertex[i] - Vertex[j];
		FVector SideNormal = Side ^ Normal;
		SideNormal.Normalize();
		if( ((Point - Vertex[i]) | SideNormal) > 0.1f )
			return 0;
	}
	return 1;
}

// ?Split@FPoly@@QAEHABVFVector@@0H@Z
IMPL_MATCH("Engine.dll", 0x9DEF0)
int FPoly::Split(const FVector& Base, const FVector& Normal, INT NoOverflow)
{
	if (NoOverflow && NumVertices >= 14)
	{
		// Too many vertices — just classify without allocating output polys.
		FPlane Plane(Normal.X, Normal.Y, Normal.Z, Normal | Base);
		INT Result = SplitWithPlaneFast(Plane, NULL, NULL);
		if (Result == SP_Back)
			return 0;
		return NumVertices;
	}

	FPoly Front, Back;
	FPlane Plane(Normal.X, Normal.Y, Normal.Z, Normal | Base);
	INT Result = SplitWithPlaneFast(Plane, &Front, &Back);
	if (Result == SP_Back)
		return 0;
	if (Result == SP_Split)
		*this = Front;
	return NumVertices;
}

// ?SplitPrecise@FPoly@@QAEHABVFVector@@0H@Z
IMPL_MATCH("Engine.dll", 0x9E040)
int FPoly::SplitPrecise(const FVector& Base, const FVector& Normal, INT NoOverflow)
{
	if (NoOverflow && NumVertices >= 14)
	{
		FPlane Plane(Normal.X, Normal.Y, Normal.Z, Normal | Base);
		INT Result = SplitWithPlaneFastPrecise(Plane, NULL, NULL);
		if (Result == SP_Back)
			return 0;
		return NumVertices;
	}

	FPoly Front, Back;
	FPlane Plane(Normal.X, Normal.Y, Normal.Z, Normal | Base);
	INT Result = SplitWithPlaneFastPrecise(Plane, &Front, &Back);
	if (Result == SP_Back)
		return 0;
	if (Result == SP_Split)
		*this = Front;
	return NumVertices;
}

// ?SplitWithNode@FPoly@@QBEHPBVUModel@@HPAV1@1H@Z
// Calls SplitWithPlane using the geometric plane defined by BSP node p1 in p0.
// Plane base  = Points[ Verts[ Nodes[p1].iVertPool ].iVertex ]    (first vertex of the node)
// Plane normal = Vectors[ Surfs[ Nodes[p1].iSurf ].vNormal ]      (surface normal vector)
//
// UModel layout (Ghidra-verified offsets, all are TTransArray<T>.Data pointers):
//   Model+0x5c = Nodes.Data  (FBspNode array, stride 0x90)
//   Model+0x6c = Verts.Data  (FVert array,    stride 0x08; first INT = iVertex)
//   Model+0x7c = Vectors.Data(FVector array,  stride 0x0c)
//   Model+0x8c = Points.Data (FVector array,  stride 0x0c)
//   Model+0x9c = Surfs.Data  (FBspSurf array, stride 0x5c; vNormal INT at +0x0c)
// FBspNode field offsets: iVertPool at +0x30, iSurf at +0x34
IMPL_MATCH("Engine.dll", 0x9D610)
int FPoly::SplitWithNode(UModel const * p0, int p1, FPoly * p2, FPoly * p3, int p4) const
{
	const BYTE* NodesData  = (const BYTE*)*(const INT*)((const BYTE*)p0 + 0x5c);
	const BYTE* VertsData  = (const BYTE*)*(const INT*)((const BYTE*)p0 + 0x6c);
	const BYTE* VectorsData= (const BYTE*)*(const INT*)((const BYTE*)p0 + 0x7c);
	const BYTE* PointsData = (const BYTE*)*(const INT*)((const BYTE*)p0 + 0x8c);
	const BYTE* SurfsData  = (const BYTE*)*(const INT*)((const BYTE*)p0 + 0x9c);

	const BYTE* Node  = NodesData + p1 * 0x90;
	INT iVertPool     = *(const INT*)(Node + 0x30);
	INT iSurf         = *(const INT*)(Node + 0x34);

	INT iVertex       = *(const INT*)(VertsData + iVertPool * 8);  // FVert.iVertex at +0
	const FVector* PointBase   = (const FVector*)(PointsData  + iVertex * 0xc);

	INT vNormal       = *(const INT*)(SurfsData + iSurf * 0x5c + 0x0c);  // FBspSurf.vNormal at +0x0c
	const FVector* PlaneNormal = (const FVector*)(VectorsData + vNormal * 0xc);

	return SplitWithPlane(*PointBase, *PlaneNormal, p2, p3, p4);
}

// ?SplitWithPlane@FPoly@@QBEHABVFVector@@0PAV1@1H@Z
// Same split logic as SplitWithPlaneFast but takes Base+Normal instead of FPlane.
// bNormal flag (p4): if non-zero, calls CalcNormal on each output polygon.
IMPL_MATCH("Engine.dll", 0x9CFE0)
int FPoly::SplitWithPlane(FVector const & p0, FVector const & p1, FPoly * p2, FPoly * p3, int p4) const
{
	FPlane Plane(p1.X, p1.Y, p1.Z, p1 | p0);
	INT Result = SplitWithPlaneFast(Plane, p2, p3);
	if (p4 && Result == SP_Split)
	{
		if (p2) p2->CalcNormal(1);
		if (p3) p3->CalcNormal(1);
	}
	return Result;
}

// ?SplitWithPlaneFast@FPoly@@QBEHVFPlane@@PAV1@1@Z
// Splits this polygon against a plane using THRESH_SPLIT_POLY_WITH_PLANE (0.25).
// Returns SP_Front, SP_Back, SP_Coplanar, or SP_Split.
// Out-polys (FrontPoly/BackPoly) may be NULL when the result is one-sided.
IMPL_MATCH("Engine.dll", 0x9D6D0)
int FPoly::SplitWithPlaneFast(FPlane p0, FPoly * p1, FPoly * p2) const
{
	const FLOAT Thresh = THRESH_SPLIT_POLY_WITH_PLANE;

	// Classify every vertex against the plane
	FLOAT Dist[16];
	INT FrontN = 0, BackN = 0;
	for (INT i = 0; i < NumVertices; i++)
	{
		Dist[i] = p0.PlaneDot(Vertex[i]);
		if      (Dist[i] >  Thresh) FrontN++;
		else if (Dist[i] < -Thresh) BackN++;
	}

	if (!FrontN && !BackN)
		return SP_Coplanar;
	if (!BackN)
	{
		if (p1) *p1 = *this;
		return SP_Front;
	}
	if (!FrontN)
	{
		if (p2) *p2 = *this;
		return SP_Back;
	}

	// Build split halves
	if (p1) { *p1 = *this; p1->NumVertices = 0; }
	if (p2) { *p2 = *this; p2->NumVertices = 0; }

	INT   j        = NumVertices - 1;
	FLOAT PrevDist = Dist[j];
	for (INT i = 0; i < NumVertices; i++)
	{
		FLOAT CurDist = Dist[i];

		// If edge crosses the plane, emit an intersection vertex in both halves
		if ((PrevDist < -Thresh && CurDist > Thresh) ||
		    (PrevDist >  Thresh && CurDist < -Thresh))
		{
			FLOAT t   = PrevDist / (PrevDist - CurDist);
			FVector I = Vertex[j] + (Vertex[i] - Vertex[j]) * t;
			if (p1 && p1->NumVertices < 16) p1->Vertex[p1->NumVertices++] = I;
			if (p2 && p2->NumVertices < 16) p2->Vertex[p2->NumVertices++] = I;
		}

		// Emit current vertex to front and/or back half
		if (CurDist >= -Thresh)
			if (p1 && p1->NumVertices < 16) p1->Vertex[p1->NumVertices++] = Vertex[i];
		if (CurDist <=  Thresh)
			if (p2 && p2->NumVertices < 16) p2->Vertex[p2->NumVertices++] = Vertex[i];

		j        = i;
		PrevDist = CurDist;
	}
	return SP_Split;
}

// ?SplitWithPlaneFastPrecise@FPoly@@QBEHVFPlane@@PAV1@1@Z
// Same as SplitWithPlaneFast but uses THRESH_SPLIT_POLY_PRECISELY (0.01).
IMPL_MATCH("Engine.dll", 0x9D9F0)
int FPoly::SplitWithPlaneFastPrecise(FPlane p0, FPoly * p1, FPoly * p2) const
{
	const FLOAT Thresh = THRESH_SPLIT_POLY_PRECISELY;

	FLOAT Dist[16];
	INT FrontN = 0, BackN = 0;
	for (INT i = 0; i < NumVertices; i++)
	{
		Dist[i] = p0.PlaneDot(Vertex[i]);
		if      (Dist[i] >  Thresh) FrontN++;
		else if (Dist[i] < -Thresh) BackN++;
	}

	if (!FrontN && !BackN)
		return SP_Coplanar;
	if (!BackN)
	{
		if (p1) *p1 = *this;
		return SP_Front;
	}
	if (!FrontN)
	{
		if (p2) *p2 = *this;
		return SP_Back;
	}

	if (p1) { *p1 = *this; p1->NumVertices = 0; }
	if (p2) { *p2 = *this; p2->NumVertices = 0; }

	INT   j        = NumVertices - 1;
	FLOAT PrevDist = Dist[j];
	for (INT i = 0; i < NumVertices; i++)
	{
		FLOAT CurDist = Dist[i];

		if ((PrevDist < -Thresh && CurDist > Thresh) ||
		    (PrevDist >  Thresh && CurDist < -Thresh))
		{
			FLOAT t   = PrevDist / (PrevDist - CurDist);
			FVector I = Vertex[j] + (Vertex[i] - Vertex[j]) * t;
			if (p1 && p1->NumVertices < 16) p1->Vertex[p1->NumVertices++] = I;
			if (p2 && p2->NumVertices < 16) p2->Vertex[p2->NumVertices++] = I;
		}

		if (CurDist >= -Thresh)
			if (p1 && p1->NumVertices < 16) p1->Vertex[p1->NumVertices++] = Vertex[i];
		if (CurDist <=  Thresh)
			if (p2 && p2->NumVertices < 16) p2->Vertex[p2->NumVertices++] = Vertex[i];

		j        = i;
		PrevDist = CurDist;
	}
	return SP_Split;
}

// ??9FPoly@@QAEHV0@@Z — Ghidra at 0x8bce0.
IMPL_MATCH("Engine.dll", 0x8bce0)
int FPoly::operator!=(FPoly Other) {
	if( NumVertices != Other.NumVertices )
		return 1;
	for( INT i=0; i<NumVertices; i++ )
		if( Vertex[i] != Other.Vertex[i] )
			return 1;
	return 0;
}

// ??8FPoly@@QAEHV0@@Z — Ghidra at 0xb4b10.
IMPL_MATCH("Engine.dll", 0xb4b10)
int FPoly::operator==(FPoly Other) {
	if( NumVertices != Other.NumVertices )
		return 0;
	for( INT i=0; i<NumVertices; i++ )
		if( Vertex[i] != Other.Vertex[i] )
			return 0;
	return 1;
}
// ?Init@FPoly@@QAEXXZ
IMPL_MATCH("Engine.dll", 0x9CD40)
void FPoly::Init() {
	Base     = FVector(0,0,0);
	Normal   = FVector(0,0,0);
	TextureU = FVector(0,0,0);
	TextureV = FVector(0,0,0);
	PolyFlags   = 0;
	Actor       = NULL;
	Material    = NULL;
	ItemName    = FName(NAME_None);
	NumVertices = 0;
	iLink       = INDEX_NONE;
	iBrushPoly  = INDEX_NONE;
	SavePolyIndex = INDEX_NONE;
	appMemzero(_RvsExtra, sizeof(_RvsExtra));
	// LightMapScale at _RvsExtra offset 52 (0x144 - 0x110) = 32.0f
	*(FLOAT*)&_RvsExtra[52] = 32.0f;
	// Sentinel values at known offsets within _RvsExtra
	*(INT*)&_RvsExtra[56] = INDEX_NONE;  // 0x148
	*(INT*)&_RvsExtra[60] = INDEX_NONE;  // 0x14C
	*(DWORD*)&_RvsExtra[68] = 0xFF808080; // 0x154
}

// ?InsertVertex@FPoly@@QAEXHVFVector@@@Z
// NOTE: Original uses temp TArray copy+insert+copyback. Simplified to in-place shift.
IMPL_MATCH("Engine.dll", 0x9E9B0)
void FPoly::InsertVertex(int InPos, FVector InVtx)
{
	check(InPos <= NumVertices);
	for( INT i = NumVertices; i > InPos; i-- )
		Vertex[i] = Vertex[i - 1];
	Vertex[InPos] = InVtx;
	NumVertices++;
}

// ?Reverse@FPoly@@QAEXXZ
IMPL_MATCH("Engine.dll", 0x9C400)
void FPoly::Reverse() {
	Normal *= -1.f;
	for( INT i=0; i<NumVertices/2; i++ ) {
		FVector Temp = Vertex[i];
		Vertex[i] = Vertex[NumVertices-1-i];
		Vertex[NumVertices-1-i] = Temp;
	}
}

// ?SplitInHalf@FPoly@@QAEXPAV1@@Z
// ?SplitInHalf@FPoly@@QAEXPAV1@@Z — Ghidra at 0x9C640.
// Splits a polygon in two halves along the vertex midpoint.
IMPL_MATCH("Engine.dll", 0x9C640)
void FPoly::SplitInHalf(FPoly * OtherHalf) {
	INT Half = NumVertices / 2;
	if( NumVertices < 4 || NumVertices > 16 )
		appErrorf( TEXT("FPoly::SplitInHalf: Vertex count = %i"), NumVertices );

	// Copy full polygon structure to the other half.
	*OtherHalf = *this;

	// Adjust vertex counts: first half gets [0..Half], second half gets [Half..N-1, 0].
	OtherHalf->NumVertices = NumVertices - Half + 1;
	NumVertices = Half + 1;

	// Copy the right-side vertices into OtherHalf.
	for( INT i=0; i<OtherHalf->NumVertices-1; i++ )
		OtherHalf->Vertex[i] = Vertex[i + Half];

	// Close the second polygon by copying back the first vertex of the original.
	OtherHalf->Vertex[OtherHalf->NumVertices - 1] = Vertex[0];

	// Mark both halves as cut (PF_EdCut = 0x80000000).
	PolyFlags |= 0x80000000;
	OtherHalf->PolyFlags |= 0x80000000;
}

// ?Transform@FPoly@@QAEXABVFModelCoords@@ABVFVector@@1M@Z
// ?Transform@FPoly@@QAEXABVFModelCoords@@ABVFVector@@1M@Z — Ghidra at 0x9C8F0.
// Transforms all polygon data by the given coordinate system.
IMPL_MATCH("Engine.dll", 0x9C8F0)
void FPoly::Transform(FModelCoords const & Coords, FVector const & PreSubtract, FVector const & PostAdd, float Orientation) {
	// Transform texture mapping vectors by the contravariant (vector) transform.
	TextureU = TextureU.TransformVectorBy( Coords.VectorXform );
	TextureV = TextureV.TransformVectorBy( Coords.VectorXform );

	// Transform base: subtract pivot, apply covariant transform, add destination.
	Base = (Base - PreSubtract).TransformVectorBy( Coords.PointXform ) + PostAdd;

	// Transform each vertex the same way.
	for( INT i=0; i<NumVertices; i++ )
		Vertex[i] = (Vertex[i] - PreSubtract).TransformVectorBy( Coords.PointXform ) + PostAdd;

	// If orientation is negative (mirroring), reverse the winding order.
	if( Orientation < 0.f )
	{
		for( INT i=0; i<NumVertices/2; i++ )
		{
			FVector Temp = Vertex[i];
			Vertex[i] = Vertex[(NumVertices-1) - i];
			Vertex[(NumVertices-1) - i] = Temp;
		}
	}

	// Re-compute the normal after transformation.
	Normal = Normal.TransformVectorBy( Coords.VectorXform ).SafeNormal();
}
// ?RemoveColinears@FPoly@@QAEHXZ
// Removes collinear (in-line) vertices. A vertex is collinear if it lies within
// THRESH_POINT_ON_SIDE of the line connecting its two neighbours.
// Returns final vertex count.
IMPL_MATCH("Engine.dll", 0x9E470)
INT FPoly::RemoveColinears()
{
	BYTE Colinear[16];
	for (INT i = 0; i < NumVertices; i++)
	{
		INT Prev = (i + NumVertices - 1) % NumVertices;
		INT Next = (i + 1) % NumVertices;
		// Direction along the prev→next edge
		FVector Side  = (Vertex[Next] - Vertex[Prev]);
		// In-plane perpendicular to that edge
		FVector Cross = Side ^ Normal;
		FLOAT   Len   = Cross.Size();
		// Signed distance from Vertex[i] to the line (prev → next), measured in the polygon plane
		FLOAT   Dist  = (Len > 0.f) ? Abs((Vertex[i] - Vertex[Prev]) | (Cross / Len)) : 0.f;
		Colinear[i] = (Dist < THRESH_POINT_ON_SIDE) ? 1 : 0;
	}

	INT j = 0;
	for (INT i = 0; i < NumVertices; i++)
		if (!Colinear[i])
			Vertex[j++] = Vertex[i];
	NumVertices = j;
	return NumVertices;
}
// ============================================================================
// TArray<BYTE> operators
// ============================================================================
// Ghidra: appends elements from Other to this, element-by-element via FArray::Add
IMPL_APPROX("element-by-element append via FArray::Add; Ghidra-verified")
TArray<BYTE>& TArray<BYTE>::operator+(const TArray<BYTE>& Other)
{
	if (this != &Other)
	{
		for (INT i = 0; i < Other.Num(); i++)
		{
			INT Index = Add(1);
			(*this)(Index) = Other(i);
		}
	}
	return *this;
}

// Ghidra: delegates to operator+ then operator= (self)
IMPL_APPROX("delegates to operator+ then returns self; Ghidra-verified")
TArray<BYTE>& TArray<BYTE>::operator+=(const TArray<BYTE>& Other)
{
	if (this != &Other)
		*this + Other;
	return *this;
}
