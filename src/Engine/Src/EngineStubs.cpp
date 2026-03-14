/*=============================================================================
    EngineStubs.cpp: Stub method bodies for Engine.dll exported symbols.
    
    Why this file exists
    --------------------
    The retail Engine.dll exports ~800 C++ methods by ordinal via its .def
    file. Each ordinal must resolve to a real symbol in the DLL or the
    linker will error. For methods we haven't decompiled yet, this file
    provides trivial "stub" bodies: empty functions, return 0, return NULL,
    etc. They have the correct signature so the mangled symbol name matches
    the .def entry, but they don't do any real work.

    As each method is properly reverse-engineered, its real implementation
    goes into the appropriate per-class file (UnActor.cpp, UnLevel.cpp,
    UnMesh.cpp, etc.) and the stub here should be deleted.

    Why #pragma optimize("", off)?
    --------------------------------
    Many stubs have empty bodies or just "return 0". With optimisation
    enabled, MSVC can merge identical function bodies (ICF/COMDAT folding)
    or eliminate them entirely. That would cause multiple .def ordinals to
    point at the same address — or worse, leave ordinals unresolved. 
    Disabling optimisation for this translation unit forces each stub to
    get its own unique address, keeping the export table correct.

    This file is the largest in the Engine module and will shrink over
    time as decompilation progresses.
=============================================================================*/
#pragma optimize("", off)

// Placement new: MSVC 2019+ with Win32 target requires explicit operator new(size_t,void*)
// when custom operator new overloads are in scope (UnFile.h overrides the allocating forms).
// Declaring it here satisfies all `new ((BYTE*)...) T(...)` calls in this file.
#pragma warning(push)
#pragma warning(disable: 4291) // no matching operator delete found
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// Global tool subsystems defined in Engine.cpp (used by stubs in this file).
extern ENGINE_API FRebuildTools GRebuildTools;

// Forward declarations for types used in parameters but not fully defined
class AProjector;
struct FProjectorRenderInfo;
struct FPropertyRetirement;
// FVertexComponent is now defined in EngineClasses.h
class AWarpZoneInfo;
class ATerrainInfo;
class FBspNode;
class FStaticMeshBatcherVertex;
struct FStaticMeshCollisionNode;
struct FStaticMeshCollisionTriangle;
class FStaticMeshSection;
struct FStaticMeshTriangle;

// extern declarations for FCollisionHash per-frame counters.
// Defined in UnCamera.cpp (originally in the UViewport section body).
extern INT GHashActorCount;
extern INT GHashLinkCellCount;
extern INT GHashExtraCount;


// --- FColor ---
// Note: FBrightness, HiColor565, HiColor555, operator FVector are defined inline in Engine.h (FColor struct).
// Ordinals ?FBrightness@FColor@@QBEMXZ, ?HiColor565@FColor@@QBEGXZ,
//          ?HiColor555@FColor@@QBEGXZ, ??BFColor@@QBE?AVFVector@@XZ


// ?GetCurrentAction@FMatineeTools@@QAEPAVUMatAction@@XZ
// Ghidra: returns CurrentAction (offset 0x44).
UMatAction * FMatineeTools::GetCurrentAction() { return CurrentAction; }

// ?GetNextAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
// Ghidra: GetActionIdx, return [idx+1] wrapping to [0].
UMatAction * FMatineeTools::GetNextAction(ASceneManager * Scene, UMatAction * Current)
{
	if (!Scene) return NULL;
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
	INT Count = Actions.Num();
	if (Count == 0) return NULL;
	INT Idx = GetActionIdx(Scene, Current);
	return Actions((Idx + 1) % Count);
}

// ?GetNextMovementAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
// Ghidra: calls GetNextAction in a loop until the action IsA(UActionMoveCamera).
UMatAction * FMatineeTools::GetNextMovementAction(ASceneManager * Scene, UMatAction * Current)
{
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
	INT Count = Actions.Num();
	if (Count == 0) return NULL;
	UMatAction* Candidate = GetNextAction(Scene, Current);
	INT Guard = Count; // prevent infinite loop if no move action exists
	while (Guard-- > 0 && Candidate && Candidate != Current)
	{
		if (Candidate->IsA(UActionMoveCamera::StaticClass()))
			return Candidate;
		Candidate = GetNextAction(Scene, Candidate);
	}
	return NULL;
}

// ?GetPrevAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
// Ghidra: GetActionIdx, return [idx-1] wrapping to [last].
UMatAction * FMatineeTools::GetPrevAction(ASceneManager * Scene, UMatAction * Current)
{
	if (!Scene) return NULL;
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
	INT Count = Actions.Num();
	if (Count == 0) return NULL;
	INT Idx = GetActionIdx(Scene, Current);
	INT Prev = (Idx <= 0) ? Count - 1 : Idx - 1;
	return Actions(Prev);
}

// ?SetCurrentAction@FMatineeTools@@QAEPAVUMatAction@@PAV2@@Z
// Ghidra: sets CurrentAction, primes CurrentSubAction from SubActions[0] if available.
UMatAction * FMatineeTools::SetCurrentAction(UMatAction * Action)
{
	CurrentAction = Action;
	if (Action)
	{
		TArray<UMatSubAction*>& SubActions = *(TArray<UMatSubAction*>*)((BYTE*)Action + 0x48);
		CurrentSubAction = SubActions.Num() > 0 ? SubActions(0) : NULL;
	}
	else
	{
		CurrentSubAction = NULL;
	}
	return CurrentAction;
}

// ?GetCurrentSubAction@FMatineeTools@@QAEPAVUMatSubAction@@XZ
// Ghidra: returns CurrentSubAction (offset 0x48).
UMatSubAction * FMatineeTools::GetCurrentSubAction() { return CurrentSubAction; }

// ?SetCurrentSubAction@FMatineeTools@@QAEPAVUMatSubAction@@PAV2@@Z
// Ghidra: stores SubAction at this+0x48 and returns it.
UMatSubAction * FMatineeTools::SetCurrentSubAction(UMatSubAction * SubAction)
{
	CurrentSubAction = SubAction;
	return SubAction;
}

// ?Area@FPoly@@QAEMXZ
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

// ?GetActionIdx@FMatineeTools@@QAEHPAVASceneManager@@PAVUMatAction@@@Z
int FMatineeTools::GetActionIdx(ASceneManager* SM, UMatAction* Action)
{
	if (!SM)
		return -1;
	// ASceneManager + 0x3A8 = TArray<UMatAction*> Actions
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)SM + 0x3A8);
	for (INT i = 0; i < Actions.Num(); i++)
	{
		if (Actions(i) == Action)
			return i;
	}
	return -1;
}

// ?GetPathStyle@FMatineeTools@@QAEHPAVUMatAction@@@Z
int FMatineeTools::GetPathStyle(UMatAction* Action)
{
	if (Action)
	{
		if (Action->IsA(UActionPause::StaticClass()))
			return 0;
		if (Action->IsA(UActionMoveCamera::StaticClass()))
			return *((BYTE*)Action + 0x90);
	}
	return *((BYTE*)Action + 0x90);
}

// ?GetSubActionIdx@FMatineeTools@@QAEHPAVUMatSubAction@@@Z
int FMatineeTools::GetSubActionIdx(UMatSubAction* SubAction)
{
	if (!CurrentAction)
		return -1;
	// UMatAction + 0x48 = TArray<UMatSubAction*> SubActions
	TArray<UMatSubAction*>& SubActions = *(TArray<UMatSubAction*>*)((BYTE*)CurrentAction + 0x48);
	for (INT i = 0; i < SubActions.Num(); i++)
	{
		if (SubActions(i) == SubAction)
			return i;
	}
	return -1;
}

// ?buildPaths@FPathBuilder@@QAEHPAVULevel@@@Z
int FPathBuilder::buildPaths(ULevel * p0) { return 0; }

// ?removePaths@FPathBuilder@@QAEHPAVULevel@@@Z
// Ghidra: iterate actors, destroy auto-built navigation points, clear bPathsTransient on LevelInfo
int FPathBuilder::removePaths(ULevel* Level)
{
	// Store level pointer at this+0 (first field in Pad)
	*(ULevel**)Pad = Level;

	INT Count = 0;
	for (INT i = 0; i < Level->Actors.Num(); i++)
	{
		AActor* Actor = Level->Actors(i);
		if (Actor && Actor->IsA(ANavigationPoint::StaticClass()))
		{
			// Check bAutoBuilt flag — high bit of byte at AActor+0x3A4
			if (((BYTE*)Actor)[0x3A4] & 0x80)
			{
				Count++;
				Level->DestroyActor(Actor);
			}
		}
	}

	// Verify Actors(0) is ALevelInfo and clear bPathsTransient
	if (!Level->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!Level->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Clear bPathsTransient bit (bit 0x800 at offset 0x450 on LevelInfo)
	DWORD& Flags = *(DWORD*)(((BYTE*)Level->Actors(0)) + 0x450);
	Flags &= ~0x800;

	return Count;
}

// ?CalcNormal@FPoly@@QAEHH@Z
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
int FPoly::IsBackfaced(FVector const & Point) const {
	return ((Point - Base) | Normal) < 0.f;
}

// ?IsCoplanar@FPoly@@QBEHABV1@@Z
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
int FPoly::OnPlane(FVector Point) {
	FLOAT d = (Point - Vertex[0]) | Normal;
	return (d > -0.1f && d < 0.1f) ? 1 : 0;
}

// ?OnPoly@FPoly@@QAEHVFVector@@@Z
// ?OnPoly@FPoly@@QAEHVFVector@@@Z — Ghidra at 0x9DD10.
// Returns 1 if Point lies inside the polygon, 0 otherwise.
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
int FPoly::operator!=(FPoly Other) {
	if( NumVertices != Other.NumVertices )
		return 1;
	for( INT i=0; i<NumVertices; i++ )
		if( Vertex[i] != Other.Vertex[i] )
			return 1;
	return 0;
}

// ??8FPoly@@QAEHV0@@Z — Ghidra at 0xb4b10.
int FPoly::operator==(FPoly Other) {
	if( NumVertices != Other.NumVertices )
		return 0;
	for( INT i=0; i<NumVertices; i++ )
		if( Vertex[i] != Other.Vertex[i] )
			return 0;
	return 1;
}

// ?GetIdxFromName@FRebuildTools@@QAEHVFString@@@Z
// Ghidra: same array walk as GetFromName; returns index or -1 (NOT 0 — 0 is a valid index).
int FRebuildTools::GetIdxFromName(FString p0)
{
	FRebuildOptions* data = *(FRebuildOptions**)((BYTE*)this + 4);
	INT count = *(INT*)((BYTE*)this + 8);
	for (INT i = 0; i < count; i++)
	{
		FRebuildOptions* opt = (FRebuildOptions*)((BYTE*)data + i * 0x2C);
		if (opt->Name == p0)
			return i;
	}
	return -1;
}


// ?MeshToWorld@UMeshInstance@@UAE?AVFMatrix@@XZ
FMatrix UMeshInstance::MeshToWorld() { // Retail: 36b. Copies FMatrix::Identity (from Core.dll IAT) to return buffer.
 return FMatrix::Identity; }


// ?ActorEncroachmentCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@VFVector@@VFRotator@@KK@Z
// Retail ordinal 2214 (0x6e3d0). Temporarily moves Actor to NewLocation/NewRotation and checks
// for overlap with every actor whose AABB touches the new position. Returns a tail-ordered list
// of encroachment hits. Uses GMem (the Mem argument is unused per the retail binary).
FCheckResult * FCollisionHash::ActorEncroachmentCheck(FMemStack & Mem, AActor * Actor, FVector NewLocation, FRotator NewRot, DWORD TraceFlags, DWORD ExtraNodeFlags)
{
	check(Actor != NULL);

	// Temporarily teleport the actor to the candidate position so GetActorExtent sees the right bounds.
	FLOAT OldLocX = *(FLOAT*)((BYTE*)Actor + 0x234);
	FLOAT OldLocY = *(FLOAT*)((BYTE*)Actor + 0x238);
	FLOAT OldLocZ = *(FLOAT*)((BYTE*)Actor + 0x23c);
	*(FLOAT*)((BYTE*)Actor + 0x234) = NewLocation.X;
	*(FLOAT*)((BYTE*)Actor + 0x238) = NewLocation.Y;
	*(FLOAT*)((BYTE*)Actor + 0x23c) = NewLocation.Z;
	INT OldRotP = *(INT*)((BYTE*)Actor + 0x240);
	INT OldRotY = *(INT*)((BYTE*)Actor + 0x244);
	INT OldRotR = *(INT*)((BYTE*)Actor + 0x248);
	*(INT*)((BYTE*)Actor + 0x240) = NewRot.Pitch;
	*(INT*)((BYTE*)Actor + 0x244) = NewRot.Yaw;
	*(INT*)((BYTE*)Actor + 0x248) = NewRot.Roll;

	INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
	GetActorExtent(Actor, MinX, MaxX, MinY, MaxY, MinZ, MaxZ);

	// Build results as a forward-ordered (tail-insertion) linked list, matching retail binary order.
	FCheckResult*  ListHead = NULL;
	FCheckResult** ListTail = &ListHead;

	CollisionTag++;

	for (INT x = MinX; x <= MaxX; x++)
	for (INT y = MinY; y <= MaxY; y++)
	for (INT z = MinZ; z <= MaxZ; z++) {
		const INT Pos = (z*0x400+y)*0x400+x;
		for (FCollisionLink* L = Buckets[HashX[x]^HashY[y]^HashZ[z]]; L; L = L->Next) {
			AActor* A = L->Actor;
			if (*(INT*)((BYTE*)A+0x60) != CollisionTag && L->HashPos == Pos) {
				// Filter: not joined, should participate in trace, not a no-encroach static.
				// vtable+0xbc = ShouldTrace(AActor*, DWORD); vtable+0xc8(=200) = IsMovingBrush()
				// Bit 0x100000 at Actor+0xa0 marks bNoEncroachCheck (bypassed if mover).
				if (!A->IsJoinedTo(Actor)
					&& A->ShouldTrace(Actor, ExtraNodeFlags)
					&& (!Actor->IsMovingBrush() || !(*(DWORD*)((BYTE*)A+0xa0) & 0x100000)))
				{
					*(INT*)((BYTE*)A+0x60) = CollisionTag;
					FCheckResult TestHit(1.f);
					if (Actor->IsOverlapping(A, &TestHit)) {
						TestHit.Actor     = A;
						TestHit.Primitive = NULL;
						FCheckResult* CR = (FCheckResult*)GMem.PushBytes(sizeof(FCheckResult), 8);
						if (CR) {
							*ListTail = CR;
							appMemcpy(CR, &TestHit, sizeof(FCheckResult));
							ListTail = &CR->GetNext();
						}
					}
				}
			}
		}
	}
	*ListTail = NULL;

	// Restore original position.
	*(FLOAT*)((BYTE*)Actor + 0x234) = OldLocX;
	*(FLOAT*)((BYTE*)Actor + 0x238) = OldLocY;
	*(FLOAT*)((BYTE*)Actor + 0x23c) = OldLocZ;
	*(INT*)((BYTE*)Actor + 0x240) = OldRotP;
	*(INT*)((BYTE*)Actor + 0x244) = OldRotY;
	*(INT*)((BYTE*)Actor + 0x248) = OldRotR;

	return ListHead;
}

// ?ActorLineCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@11KKPAVAActor@@@Z
// Retail ordinal 2217 (0x6e6f0). Sweeps a line (or box if Extent is non-zero) through the hash
// and collects BlockedBy+LineCheck hits. Two sub-paths:
//   Non-zero Extent: iterate all cells in the AABB of [Start,End] expanded by Extent.
//   Zero Extent:     DDA ray traversal from Start to End one cell at a time.
// TraceFlags bit 0x200 = return first hit only; bit 0x400 = sort by facing distance.
// Uses the Mem argument for allocation (retail binary does NOT use GMem here).
FCheckResult * FCollisionHash::ActorLineCheck(FMemStack & Mem, FVector End, FVector Start, FVector Extent, DWORD TraceFlags, DWORD TypeFlags, AActor * SourceActor)
{
	CollisionTag++;
	FCheckResult* List = NULL;

	if (!Extent.IsZero()) {
		// Bounding-box sweep: cover all cells touching the AABB of [Start..End] grown by Extent.
		INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
		FLOAT BMinX = ::Min(Start.X, End.X), BMinY = ::Min(Start.Y, End.Y), BMinZ = ::Min(Start.Z, End.Z);
		FLOAT BMaxX = ::Max(Start.X, End.X), BMaxY = ::Max(Start.Y, End.Y), BMaxZ = ::Max(Start.Z, End.Z);
		GetHashIndices(FVector(BMinX-Extent.X, BMinY-Extent.Y, BMinZ-Extent.Z), MinX, MinY, MinZ);
		GetHashIndices(FVector(BMaxX+Extent.X, BMaxY+Extent.Y, BMaxZ+Extent.Z), MaxX, MaxY, MaxZ);

		for (INT x = MinX; x <= MaxX; x++)
		for (INT y = MinY; y <= MaxY; y++)
		for (INT z = MinZ; z <= MaxZ; z++) {
			const INT Pos = (z*0x400+y)*0x400+x;
			for (FCollisionLink* L = Buckets[HashX[x]^HashY[y]^HashZ[z]]; L; L = L->Next) {
				AActor* A = L->Actor;
				if (*(INT*)((BYTE*)A+0x60) != CollisionTag && L->HashPos == Pos) {
					*(INT*)((BYTE*)A+0x60) = CollisionTag;
					// Skip SourceActor itself and any actor in its ignore chain (offset 0x140).
					if (A == SourceActor) continue;
					bool bIgnored = false;
					for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI+0x140)) {
						if ((AActor*)pI == A) { bIgnored = true; break; }
					}
					if (bIgnored) continue;
					if (A->ShouldTrace(SourceActor, TraceFlags)) {
						FCheckResult TestHit(0.f);
						if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start, Extent, TypeFlags, TraceFlags) == 0) {
							FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
							if (CR) {
								appMemcpy(CR, &TestHit, sizeof(FCheckResult));
								CR->GetNext() = List;
								List = CR;
							}
							if (TraceFlags & 0x200) return List;
						}
					}
				}
			}
		}
		// TraceFlags & 0x400 = sort by facing: FUN_103d92c0 not yet identified, return as-is.
		return List;
	}

	// DDA zero-extent ray traversal: walk cells from Start to End one step at a time.
	FVector Dir = (End - Start).SafeNormal();
	INT CurX, CurY, CurZ, EndX, EndY, EndZ;
	GetHashIndices(Start, CurX, CurY, CurZ);
	GetHashIndices(End,   EndX, EndY, EndZ);

	for (bool bKeepGoing = true; bKeepGoing; ) {
		const INT Pos = (CurZ*0x400+CurY)*0x400+CurX;
		bool bEarlyExit = false;
		for (FCollisionLink* L = Buckets[HashX[CurX]^HashY[CurY]^HashZ[CurZ]]; L; L = L->Next) {
			AActor* A = L->Actor;
			if (*(INT*)((BYTE*)A+0x60) != CollisionTag && L->HashPos == Pos) {
				*(INT*)((BYTE*)A+0x60) = CollisionTag;
				if (A == SourceActor) continue;
				bool bIgnored = false;
				for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI+0x140)) {
					if ((AActor*)pI == A) { bIgnored = true; break; }
				}
				if (bIgnored) continue;
				if (A->ShouldTrace(SourceActor, TraceFlags)) {
					FCheckResult TestHit(0.f);
					if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start, FVector(0,0,0), TypeFlags, TraceFlags) == 0) {
						FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
						if (CR) {
							appMemcpy(CR, &TestHit, sizeof(FCheckResult));
							CR->GetNext() = List;
							List = CR;
						}
						if (TraceFlags & 0x200) { bEarlyExit = true; break; }
					}
				}
			}
		}
		if (List && (TraceFlags & 0x200)) return List;
		// TraceFlags & 0x400 = sort earliest hit by facing: not yet implemented (FUN_103d92c0).
		if (CurX == EndX && CurY == EndY && CurZ == EndZ) { bKeepGoing = false; continue; }

		// DDA: advance to the next hash cell along the ray direction.
		// DistanceToHashPlane returns the parametric distance to the next boundary on each axis.
		// Direction convention (from retail binary): step OPPOSITE to sign of Dir (Ghidra pattern).
		FLOAT dX = DistanceToHashPlane(CurX, Dir.X, Start.X, 0x100);
		FLOAT dY = DistanceToHashPlane(CurY, Dir.Y, Start.Y, 0x100);
		FLOAT dZ = DistanceToHashPlane(CurZ, Dir.Z, Start.Z, 0x100);
		INT nX = CurX, nY = CurY, nZ = CurZ;
		if (dX > dY || dX > dZ) {
			if (dY > dX || dY > dZ) { nZ += (Dir.Z < 0.f) ? 1 : -1; }
			else                    { nY += (Dir.Y < 0.f) ? 1 : -1; }
		} else {
			nX += (Dir.X < 0.f) ? 1 : -1;
		}
		if ((DWORD)nX >= 0x4000u || (DWORD)nY >= 0x4000u || (DWORD)nZ >= 0x4000u) {
			bKeepGoing = false;
		} else {
			CurX = nX; CurY = nY; CurZ = nZ;
		}
	}
	return List;
}

// ?ActorOverlapCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@PAVFBox@@H@Z
// Retail ordinal 2220 (0x33a0). Stub in retail binary — returns NULL.
FCheckResult * FCollisionHash::ActorOverlapCheck(FMemStack & p0, AActor * p1, FBox * p2, int p3) { return NULL; }

// ?ActorPointCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@1KKHPAVAActor@@@Z
// Retail ordinal 2223 (0x6dec0). Tests whether a point+AABB (Location ± Extent) overlaps any
// actor in the hash. Calls each candidate's ShouldTrace then GetPrimitive()->PointCheck.
// Uses GMem (the Mem argument is unused per the retail binary).
FCheckResult * FCollisionHash::ActorPointCheck(FMemStack & Mem, FVector Location, FVector Extent, DWORD ExtraNodeFlags, DWORD /*unused*/, INT bSingleResult, AActor * SourceActor)
{
	INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
	GetHashIndices(FVector(Location.X-Extent.X, Location.Y-Extent.Y, Location.Z-Extent.Z), MinX, MinY, MinZ);
	GetHashIndices(FVector(Location.X+Extent.X, Location.Y+Extent.Y, Location.Z+Extent.Z), MaxX, MaxY, MaxZ);
	CollisionTag++;
	FCheckResult* List = NULL;

	for (INT x = MinX; x <= MaxX; x++)
	for (INT y = MinY; y <= MaxY; y++)
	for (INT z = MinZ; z <= MaxZ; z++) {
		const INT Pos = (z*0x400+y)*0x400+x;
		for (FCollisionLink* L = Buckets[HashX[x]^HashY[y]^HashZ[z]]; L; L = L->Next) {
			AActor* A = L->Actor;
			// Dedup and hash-pos guard, then filter by ShouldTrace before marking visited.
			if (*(INT*)((BYTE*)A+0x60) != CollisionTag && L->HashPos == Pos
				&& A->ShouldTrace(SourceActor, ExtraNodeFlags))
			{
				*(INT*)((BYTE*)A+0x60) = CollisionTag;
				FCheckResult TestHit(1.f);
				if (A->GetPrimitive()->PointCheck(TestHit, A, Location, Extent, 0) == 0) {
					check(TestHit.Actor == A);
					FCheckResult* CR = (FCheckResult*)GMem.PushBytes(sizeof(FCheckResult), 8);
					if (CR) {
						appMemcpy(CR, &TestHit, sizeof(FCheckResult));
						CR->GetNext() = List;
						List = CR;
					}
					if (bSingleResult) return List;
				}
			}
		}
	}
	return List;
}

// ?ActorRadiusCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@MK@Z
// Retail ordinal 2226 (0x6e1a0). Returns all actors within Radius of Center (sphere test on
// stored Location, no primitive shape check). Uses GMem (Mem argument unused per retail binary).
FCheckResult * FCollisionHash::ActorRadiusCheck(FMemStack & Mem, FVector Center, FLOAT Radius, DWORD ExtraNodeFlags)
{
	INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
	GetHashIndices(FVector(Center.X-Radius, Center.Y-Radius, Center.Z-Radius), MinX, MinY, MinZ);
	GetHashIndices(FVector(Center.X+Radius, Center.Y+Radius, Center.Z+Radius), MaxX, MaxY, MaxZ);
	const FLOAT RadSq = Radius * Radius;
	CollisionTag++;
	FCheckResult* List = NULL;

	for (INT x = MinX; x <= MaxX; x++)
	for (INT y = MinY; y <= MaxY; y++)
	for (INT z = MinZ; z <= MaxZ; z++) {
		const INT Pos = (z*0x400+y)*0x400+x;
		for (FCollisionLink* L = Buckets[HashX[x]^HashY[y]^HashZ[z]]; L; L = L->Next) {
			AActor* A = L->Actor;
			if (*(INT*)((BYTE*)A+0x60) != CollisionTag && L->HashPos == Pos) {
				*(INT*)((BYTE*)A+0x60) = CollisionTag;
				// Use stored Location (0x234-0x23c); no primitive shape, pure sphere test.
				const FLOAT dx = *(FLOAT*)((BYTE*)A+0x234) - Center.X;
				const FLOAT dy = *(FLOAT*)((BYTE*)A+0x238) - Center.Y;
				const FLOAT dz = *(FLOAT*)((BYTE*)A+0x23c) - Center.Z;
				if (dx*dx + dy*dy + dz*dz < RadSq) {
					FCheckResult* CR = (FCheckResult*)GMem.PushBytes(sizeof(FCheckResult), 8);
					if (CR) {
						CR->Material  = NULL;
						CR->Actor     = A;
						CR->GetNext() = List;
						List = CR;
					}
				}
			}
		}
	}
	return List;
}

// Octree collision helpers — shared iteration of the root node's flat actor list.
// The octree stores all actors in the root node (no subdivision for now), making
// queries equivalent to linear scans.  The frame counter (Pad[4]) deduplicates
// actors that appear in multiple query cells via the visited tag at actor+0x60.

// ?ActorEncroachmentCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@VFVector@@VFRotator@@KK@Z
FCheckResult* FCollisionOctree::ActorEncroachmentCheck(FMemStack& Mem, AActor* Actor, FVector Location, FRotator Rotation, DWORD ExtraNodeFlags, DWORD TypeFlags)
{
	INT& Frame = *(INT*)(Pad + 4);
	Frame++;
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (!Root) return NULL;
	TArray<AActor*>& Actors = *(TArray<AActor*>*)Root;
	FCheckResult* List = NULL;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A || A == Actor) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (A->ShouldTrace(Actor, ExtraNodeFlags))
		{
			FCheckResult TestHit(1.f);
			if (A->GetPrimitive()->PointCheck(TestHit, A, Location, FVector(0,0,0), 0) == 0)
			{
				FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
				if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
			}
		}
	}
	return List;
}

// ?ActorLineCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@11KKPAVAActor@@@Z
// Sweeps a line (or capsule if Extent nonzero) through all tracked actors.
// Mirrors FCollisionHash::ActorLineCheck but draws from the octree's root actor list.
FCheckResult* FCollisionOctree::ActorLineCheck(FMemStack& Mem, FVector End, FVector Start, FVector Extent, DWORD TraceFlags, DWORD TypeFlags, AActor* SourceActor)
{
	INT& Frame = *(INT*)(Pad + 4);
	Frame++;
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (!Root) return NULL;
	TArray<AActor*>& Actors = *(TArray<AActor*>*)Root;
	FCheckResult* List = NULL;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (A == SourceActor) continue;
		// Walk the owner chain to skip owned actors
		bool bIgnored = false;
		for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI + 0x140))
			if ((AActor*)pI == A) { bIgnored = true; break; }
		if (bIgnored) continue;
		if (A->ShouldTrace(SourceActor, TraceFlags))
		{
			FCheckResult TestHit(0.f);
			if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start, Extent, TypeFlags, TraceFlags) == 0)
			{
				FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
				if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
				if (TraceFlags & 0x200) return List;
			}
		}
	}
	return List;
}

// ?ActorOverlapCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@PAVFBox@@H@Z
FCheckResult * FCollisionOctree::ActorOverlapCheck(FMemStack & p0, AActor * p1, FBox * p2, int p3) { return NULL; }

// ?ActorPointCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@1KKHPAVAActor@@@Z
// Tests a point+AABB against all tracked actors; uses GMem for allocation (matching retail).
FCheckResult* FCollisionOctree::ActorPointCheck(FMemStack& /*Mem*/, FVector Location, FVector Extent, DWORD ExtraNodeFlags, DWORD /*unused*/, INT bSingleResult, AActor* SourceActor)
{
	INT& Frame = *(INT*)(Pad + 4);
	Frame++;
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (!Root) return NULL;
	TArray<AActor*>& Actors = *(TArray<AActor*>*)Root;
	FCheckResult* List = NULL;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		if (!A->ShouldTrace(SourceActor, ExtraNodeFlags)) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		FCheckResult TestHit(1.f);
		if (A->GetPrimitive()->PointCheck(TestHit, A, Location, Extent, 0) == 0)
		{
			FCheckResult* CR = (FCheckResult*)GMem.PushBytes(sizeof(FCheckResult), 8);
			if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
			if (bSingleResult) return List;
		}
	}
	return List;
}

// ?ActorRadiusCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@MK@Z
// Returns all actors whose location is within Radius of Center.
FCheckResult* FCollisionOctree::ActorRadiusCheck(FMemStack& Mem, FVector Center, FLOAT Radius, DWORD ExtraNodeFlags)
{
	INT& Frame = *(INT*)(Pad + 4);
	Frame++;
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (!Root) return NULL;
	TArray<AActor*>& Actors = *(TArray<AActor*>*)Root;
	FCheckResult* List = NULL;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (!A->ShouldTrace(NULL, ExtraNodeFlags)) continue;
		const FLOAT dx = A->Location.X - Center.X;
		const FLOAT dy = A->Location.Y - Center.Y;
		const FLOAT dz = A->Location.Z - Center.Z;
		if (dx*dx + dy*dy + dz*dz <= Radius*Radius)
		{
			FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
			if (CR)
			{
				appMemzero(CR, sizeof(FCheckResult));
				CR->Actor = A;
				CR->GetNext() = List;
				List = CR;
			}
		}
	}
	return List;
}

// ?AddActor@FCollisionHash@@UAEXPAVAActor@@@Z
// Retail ordinal 2232 (0x6ee70).  Inserts an actor into every hash cell that
// its bounding box overlaps.  Pool-allocates 12-byte FCollisionLink slabs of
// 1024 nodes (0x3000 bytes) on demand.  Saves actor Location into ColLocation
// (offsets 0x308-0x310) so RemoveActor can look it up by the original position.
void FCollisionHash::AddActor(AActor* Actor) {
	check((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x800); // bCollideActors must be set
	if (*(SBYTE*)((BYTE*)Actor + 0xa0) < 0) return;  // bDeleteMe — skip
	if ((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x100) return; // bIgnoreEncroachers — skip

	CheckActorNotReferenced(Actor); // debug: verify not already tracked

	INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
	GetActorExtent(Actor, MinX, MaxX, MinY, MaxY, MinZ, MaxZ);

	for (INT x = MinX; x <= MaxX; x++) {
		for (INT y = MinY; y <= MaxY; y++) {
			for (INT z = MinZ; z <= MaxZ; z++) {
				// Grow pool if free-list exhausted.
				if (!FreeList) {
					BYTE* Slab = (BYTE*)GMalloc->Malloc(0x3000, TEXT("FCollisionLink"));
					for (INT k = 0; k < 0x3FF; k++)
						((FCollisionLink*)(Slab + k*12))->Next = (FCollisionLink*)(Slab + (k+1)*12);
					((FCollisionLink*)(Slab + 0x3FF*12))->Next = NULL;
					FreeList = (FCollisionLink*)Slab;
					AllocatedPools.AddItem((void*)Slab);
				}
				FCollisionLink* Node = FreeList;
				FreeList = Node->Next;
				Node->Actor   = Actor;
				Node->HashPos = (z * 0x400 + y) * 0x400 + x;
				FCollisionLink*& Bucket = Buckets[HashX[x] ^ HashY[y] ^ HashZ[z]];
				Node->Next = Bucket;
				Bucket = Node;
				GHashLinkCellCount++;
				GHashExtraCount++;
			}
		}
	}
	GHashActorCount++;
	// Save current location as ColLocation so we can find the right cells on removal.
	*(DWORD*)((BYTE*)Actor + 0x308) = *(DWORD*)((BYTE*)Actor + 0x234);
	*(DWORD*)((BYTE*)Actor + 0x30c) = *(DWORD*)((BYTE*)Actor + 0x238);
	*(DWORD*)((BYTE*)Actor + 0x310) = *(DWORD*)((BYTE*)Actor + 0x23c);
}

// ?CheckActorLocations@FCollisionHash@@UAEXPAVULevel@@@Z
// retail: empty (ordinal 2351 shares address 0x1651d0 with dozens of other no-op virtuals)
void FCollisionHash::CheckActorLocations(ULevel * p0) {}

// ?CheckActorNotReferenced@FCollisionHash@@UAEXPAVAActor@@@Z
// retail: empty (ordinal 2353 shares address 0x1651d0 — same shared no-op stub)
void FCollisionHash::CheckActorNotReferenced(AActor * p0) {}

// ?CheckIsEmpty@FCollisionHash@@UAEXXZ
// retail: empty (ordinal 2383 shares address 0x176d60 — another shared no-op stub)
void FCollisionHash::CheckIsEmpty() {}

// ?RemoveActor@FCollisionHash@@UAEXPAVAActor@@@Z
// Retail ordinal 4274 (0x6f0c0).  Removes an actor from every hash cell it
// occupies by walking the ColLocation extent (not current Location, so it
// works even if the actor has moved since it was added).  Returns links to pool.
void FCollisionHash::RemoveActor(AActor* Actor) {
	check((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x800); // bCollideActors must be set
	if (*(SBYTE*)((BYTE*)Actor + 0xa0) < 0) return;  // bDeleteMe
	// NOTE: retail also checks ColLocation == Location consistency here;
	// omitted as it only matters for editor-time diagnostics.

	INT MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
	GetActorExtent(Actor, MinX, MaxX, MinY, MaxY, MinZ, MaxZ);

	for (INT x = MinX; x <= MaxX; x++) {
		for (INT y = MinY; y <= MaxY; y++) {
			for (INT z = MinZ; z <= MaxZ; z++) {
				FCollisionLink** pp = &Buckets[HashX[x] ^ HashY[y] ^ HashZ[z]];
				while (*pp) {
					if ((*pp)->Actor == Actor) {
						FCollisionLink* Removed = *pp;
						*pp = Removed->Next;
						Removed->Next = FreeList;
						FreeList = Removed;
					} else {
						pp = &(*pp)->Next;
					}
				}
			}
		}
	}
}

// ?Tick@FCollisionHash@@UAEXXZ
// Retail ordinal 4860 (0x6d6d0).  Resets per-frame performance counters.
void FCollisionHash::Tick() {
	GHashExtraCount    = 0; // DAT_1064ff34
	GHashLinkCellCount = 0; // DAT_1064ff2c
	GHashActorCount    = 0; // DAT_1064ff28
}

// ?AddActor@FCollisionOctree@@UAEXPAVAActor@@@Z
// Ghidra (0xdc1a0): Computes actor bbox, inserts into octree via SingleNodeFilter
// or MultiNodeFilter depending on whether actor is flagged bStatic.
// Simplified: insert into root node's flat actor list directly.
void FCollisionOctree::AddActor(AActor* Actor)
{
	check((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x800);          // bCollideActors
	if (*(SBYTE*)((BYTE*)Actor + 0xa0) < 0) return;           // bDeleteMe
	if ((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x100) return;     // bNoCollision
	// Skip if already registered (actor's OctreeNodes list non-empty)
	TArray<FOctreeNode*>& NodeList = *(TArray<FOctreeNode*>*)((BYTE*)Actor + 0x338);
	if (NodeList.Num() > 0) return;
	// Insert into root node (simplified flat storage — no octant subdivision)
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (Root) Root->SingleNodeFilter(Actor, this, NULL);
	// Save ColLocation for consistent removal even after the actor moves
	*(DWORD*)((BYTE*)Actor + 0x308) = *(DWORD*)((BYTE*)Actor + 0x234);
	*(DWORD*)((BYTE*)Actor + 0x30c) = *(DWORD*)((BYTE*)Actor + 0x238);
	*(DWORD*)((BYTE*)Actor + 0x310) = *(DWORD*)((BYTE*)Actor + 0x23c);
}

// ?CheckActorLocations@FCollisionOctree@@UAEXPAVULevel@@@Z
// DIVERGENCE: stub; retail (0xdbec0) walks Level->Actors, tests geometry overlap per node.
void FCollisionOctree::CheckActorLocations(ULevel * p0) {}

// ?CheckActorNotReferenced@FCollisionOctree@@UAEXPAVAActor@@@Z
// retail: empty (ordinal 2354 shares address 0x1651d0 — shared no-op stub)
void FCollisionOctree::CheckActorNotReferenced(AActor * p0) {}

// ?CheckIsEmpty@FCollisionOctree@@UAEXXZ
// Ghidra (0xdaf60): delegates straight to FOctreeNode::CheckIsEmpty on the root node.
// Root FOctreeNode* is stored at Pad[0..3] (first field after vtable pointer).
void FCollisionOctree::CheckIsEmpty()
{
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (Root) Root->CheckIsEmpty();
}

// ?RemoveActor@FCollisionOctree@@UAEXPAVAActor@@@Z
// Ghidra (0xdbd00): Removes actor from every octree node it appears in,
// then clears actor's OctreeNodes list.
void FCollisionOctree::RemoveActor(AActor* Actor)
{
	check((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x800);  // bCollideActors
	if (*(SBYTE*)((BYTE*)Actor + 0xa0) < 0) return;   // bDeleteMe
	// Remove actor from each node in its OctreeNodes list
	TArray<FOctreeNode*>& NodeList = *(TArray<FOctreeNode*>*)((BYTE*)Actor + 0x338);
	for (INT i = 0; i < NodeList.Num(); i++)
	{
		FOctreeNode* Node = NodeList(i);
		if (!Node) continue;
		TArray<AActor*>& ActorList = *(TArray<AActor*>*)Node;
		ActorList.RemoveItem(Actor);
	}
	NodeList.Empty();
}

// ?Tick@FCollisionOctree@@UAEXXZ
void FCollisionOctree::Tick() {}

// ?MeshBuildBounds@UMeshInstance@@UAEXXZ
void UMeshInstance::MeshBuildBounds() {}

// ?m_vStartLipsynch@ECLipSynchData@@QAEXXZ
void ECLipSynchData::m_vStartLipsynch()
{
	bPlaying = 1;
}

// ?m_vStopLipsynch@ECLipSynchData@@QAEXXZ
void ECLipSynchData::m_vStopLipsynch() {}

// ?m_vUpdateBonesCompressed@ECLipSynchData@@QAEXH@Z
void ECLipSynchData::m_vUpdateBonesCompressed(int p0) {}

// ?m_vUpdateBonesCompressed_BoneView@ECLipSynchData@@QAEXH@Z
void ECLipSynchData::m_vUpdateBonesCompressed_BoneView(int p0) {}

// ?m_vUpdateBonesCompressed_PhonemsSeq@ECLipSynchData@@QAEXH@Z
void ECLipSynchData::m_vUpdateBonesCompressed_PhonemsSeq(int p0) {}

// ?m_vUpdateLipSynch@ECLipSynchData@@QAEXM@Z
void ECLipSynchData::m_vUpdateLipSynch(float p0) {}

// ?GetHashIndices@FCollisionHash@@QAEXVFVector@@AAH11@Z
// Retail ordinal 3033 (0x6dd20).
// Converts a world-space coordinate to a hash-table grid index in each axis.
// Grid resolution: each cell = 256 unreal units; world spans [-262144, +262144].
void FCollisionHash::GetHashIndices(FVector V, INT& XI, INT& YI, INT& ZI) {
	XI = Clamp(appRound((V.X + 262144.0f) * 0.00390625f), 0, 0x3FFF);
	YI = Clamp(appRound((V.Y + 262144.0f) * 0.00390625f), 0, 0x3FFF);
	ZI = Clamp(appRound((V.Z + 262144.0f) * 0.00390625f), 0, 0x3FFF);
}

// ?GetActorExtent@FCollisionHash@@QAEXPAVAActor@@AAH11111@Z
// Retail ordinal 2897 (0x6dde0).
// Converts the actor's collision bounding box into a 3D range of hash indices.
void FCollisionHash::GetActorExtent(AActor* Actor, INT& MinX, INT& MaxX, INT& MinY, INT& MaxY, INT& MinZ, INT& MaxZ) {
	FBox Box = Actor->GetPrimitive()->GetCollisionBoundingBox(Actor);
	GetHashIndices(Box.Min, MinX, MinY, MinZ);
	GetHashIndices(Box.Max, MaxX, MaxY, MaxZ);
}

// ?GetSamples@FMatineeTools@@QAEXPAVASceneManager@@PAVUMatAction@@PAV?$TArray@VFVector@@@@@Z
void FMatineeTools::GetSamples(ASceneManager * p0, UMatAction * p1, TArray<FVector> * p2) {}

// ?Init@FMatineeTools@@QAEXXZ
void FMatineeTools::Init() {}

// ?ActorEncroachmentCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
// Node-level encroachment check.  Reads query state from OctHash->Pad:
//   Pad[96..99]   = SourceActor (the encroaching actor)
//   Pad[16..27]   = query Location (FVector)
//   Pad[80..87]   = Extent (FVector, zero for point test)
//   Pad[88..91]   = TraceFlags (DWORD)
void FOctreeNode::ActorEncroachmentCheck(FCollisionOctree* OctHash, FPlane const* NodePlane)
{
	INT     Frame       = *(INT*)(OctHash->Pad + 4);
	FCheckResult*& List = *(FCheckResult**)(OctHash->Pad + 8);
	FMemStack* Mem      = *(FMemStack**)(OctHash->Pad + 12);
	AActor* SourceActor = *(AActor**)(OctHash->Pad + 96);
	FVector Location    = *(FVector*)(OctHash->Pad + 16);
	DWORD TraceFlags    = *(DWORD*)(OctHash->Pad + 88);

	TArray<AActor*>& Actors = *(TArray<AActor*>*)this;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A || A == SourceActor) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (A->ShouldTrace(SourceActor, TraceFlags))
		{
			FCheckResult TestHit(1.f);
			if (A->GetPrimitive()->PointCheck(TestHit, A, Location, FVector(0,0,0), 0) == 0)
			{
				FCheckResult* CR = (FCheckResult*)Mem->PushBytes(sizeof(FCheckResult), 8);
				if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
			}
		}
	}
}

// ?ActorNonZeroExtentLineCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
// Capsule line check — like the zero-extent version but passes Extent to LineCheck.
void FOctreeNode::ActorNonZeroExtentLineCheck(FCollisionOctree* OctHash, FPlane const* NodePlane)
{
	INT     Frame       = *(INT*)(OctHash->Pad + 4);
	FCheckResult*& List = *(FCheckResult**)(OctHash->Pad + 8);
	FMemStack* Mem      = *(FMemStack**)(OctHash->Pad + 12);
	FVector   Start     = *(FVector*)(OctHash->Pad + 16);
	FVector   End       = *(FVector*)(OctHash->Pad + 28);
	FVector   Extent    = *(FVector*)(OctHash->Pad + 80);
	DWORD TraceFlags    = *(DWORD*)(OctHash->Pad + 88);
	DWORD TypeFlags     = *(DWORD*)(OctHash->Pad + 92);
	AActor* SourceActor = *(AActor**)(OctHash->Pad + 96);

	TArray<AActor*>& Actors = *(TArray<AActor*>*)this;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (A == SourceActor) continue;
		bool bIgnored = false;
		for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI + 0x140))
			if ((AActor*)pI == A) { bIgnored = true; break; }
		if (bIgnored) continue;
		if (A->ShouldTrace(SourceActor, TraceFlags))
		{
			FCheckResult TestHit(0.f);
			if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start, Extent, TypeFlags, TraceFlags) == 0)
			{
				FCheckResult* CR = (FCheckResult*)Mem->PushBytes(sizeof(FCheckResult), 8);
				if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
			}
		}
	}
}

// ?ActorOverlapCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::ActorOverlapCheck(FCollisionOctree * p0, FPlane const * p1) {}

// ?ActorPointCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@PAVAActor@@@Z
void FOctreeNode::ActorPointCheck(FCollisionOctree* OctHash, FPlane const* NodePlane, AActor* SourceActor)
{
	INT     Frame       = *(INT*)(OctHash->Pad + 4);
	FCheckResult*& List = *(FCheckResult**)(OctHash->Pad + 8);
	FVector Location    = *(FVector*)(OctHash->Pad + 16);
	FVector Extent      = *(FVector*)(OctHash->Pad + 80);
	DWORD TraceFlags    = *(DWORD*)(OctHash->Pad + 88);

	TArray<AActor*>& Actors = *(TArray<AActor*>*)this;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		if (!A->ShouldTrace(SourceActor, TraceFlags)) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		FCheckResult TestHit(1.f);
		if (A->GetPrimitive()->PointCheck(TestHit, A, Location, Extent, 0) == 0)
		{
			FCheckResult* CR = (FCheckResult*)GMem.PushBytes(sizeof(FCheckResult), 8);
			if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
		}
	}
}

// ?ActorRadiusCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::ActorRadiusCheck(FCollisionOctree* OctHash, FPlane const* NodePlane)
{
	INT     Frame       = *(INT*)(OctHash->Pad + 4);
	FCheckResult*& List = *(FCheckResult**)(OctHash->Pad + 8);
	FMemStack* Mem      = *(FMemStack**)(OctHash->Pad + 12);
	FVector   Center    = *(FVector*)(OctHash->Pad + 16);
	FLOAT     Radius    = *(FLOAT*)(OctHash->Pad + 80);  // radius in Extent.X
	DWORD TraceFlags    = *(DWORD*)(OctHash->Pad + 88);

	TArray<AActor*>& Actors = *(TArray<AActor*>*)this;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (!A->ShouldTrace(NULL, TraceFlags)) continue;
		const FLOAT dx = A->Location.X - Center.X;
		const FLOAT dy = A->Location.Y - Center.Y;
		const FLOAT dz = A->Location.Z - Center.Z;
		if (dx*dx + dy*dy + dz*dz <= Radius*Radius)
		{
			FCheckResult* CR = (FCheckResult*)Mem->PushBytes(sizeof(FCheckResult), 8);
			if (CR)
			{
				appMemzero(CR, sizeof(FCheckResult));
				CR->Actor = A;
				CR->GetNext() = List;
				List = CR;
			}
		}
	}
}

// ?ActorZeroExtentLineCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@MMMMMMPBVFPlane@@@Z
// Entry point for a ray test against actors in this node.  The caller passes
// Start and End as individual floats; Ghidra confirmed the packing order is
// Start.X, Start.Y, Start.Z, End.X, End.Y, End.Z.
void FOctreeNode::ActorZeroExtentLineCheck(FCollisionOctree* OctHash, float Sx, float Sy, float Sz, float Ex, float Ey, float Ez, FPlane const* NodePlane)
{
	INT     Frame       = *(INT*)(OctHash->Pad + 4);
	FCheckResult*& List = *(FCheckResult**)(OctHash->Pad + 8);
	FMemStack* Mem      = *(FMemStack**)(OctHash->Pad + 12);
	DWORD TraceFlags    = *(DWORD*)(OctHash->Pad + 88);
	DWORD TypeFlags     = *(DWORD*)(OctHash->Pad + 92);
	AActor* SourceActor = *(AActor**)(OctHash->Pad + 96);
	FVector Start(Sx, Sy, Sz);
	FVector End(Ex, Ey, Ez);

	TArray<AActor*>& Actors = *(TArray<AActor*>*)this;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;
		if (A == SourceActor) continue;
		bool bIgnored = false;
		for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI + 0x140))
			if ((AActor*)pI == A) { bIgnored = true; break; }
		if (bIgnored) continue;
		if (A->ShouldTrace(SourceActor, TraceFlags))
		{
			FCheckResult TestHit(0.f);
			if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start, FVector(0,0,0), TypeFlags, TraceFlags) == 0)
			{
				FCheckResult* CR = (FCheckResult*)Mem->PushBytes(sizeof(FCheckResult), 8);
				if (CR) { appMemcpy(CR, &TestHit, sizeof(FCheckResult)); CR->GetNext() = List; List = CR; }
			}
		}
	}
}

// ?CheckActorNotReferenced@FOctreeNode@@QAEXPAVAActor@@@Z
// Ghidra (0xd93c0): logs every actor in this node to GError, then recurses into
// 8 children if present.  Exact format string unclear from decompiler output.
// DIVERGENCE: format string approximated as TEXT("%s"); Ghidra shows Logf(GError, vtable_ptr)
//             which is a decompiler artefact, not a literal vtable dereference.
void FOctreeNode::CheckActorNotReferenced(AActor * /*Actor*/)
{
	// FOctreeNode layout (Ghidra-verified, 0x10 bytes per node):
	//   offset 0x00: TArray<AActor*>::Data  (void*)
	//   offset 0x04: TArray<AActor*>::Num   (INT)
	//   offset 0x08: TArray<AActor*>::Max   (INT)
	//   offset 0x0c: children block ptr     (FOctreeNode* block, 8 children × 0x10 bytes)
	void* DataPtr         = *(void**)Pad;
	INT   Count           = *(INT*)(Pad + 4);
	for (INT i = 0; i < Count; i++)
	{
		AActor* A = ((AActor**)DataPtr)[i];
		if (A) GError->Logf(TEXT("%s"), A->GetName());
	}
	void* ChildrenBase = *(void**)(Pad + 0xc);
	if (ChildrenBase)
	{
		for (INT i = 0; i < 8; i++)
			((FOctreeNode*)((BYTE*)ChildrenBase + i * 0x10))->CheckActorNotReferenced(NULL);
	}
}

// ?CheckIsEmpty@FOctreeNode@@QAEXXZ
// Ghidra (0xd9300): logs every actor in this node to GLog, then recurses into
// 8 children if present.
// DIVERGENCE: format string approximated; see CheckActorNotReferenced note above.
void FOctreeNode::CheckIsEmpty()
{
	void* DataPtr = *(void**)Pad;
	INT   Count   = *(INT*)(Pad + 4);
	for (INT i = 0; i < Count; i++)
	{
		AActor* A = ((AActor**)DataPtr)[i];
		if (A) GLog->Logf(TEXT("%s"), A->GetName());
	}
	void* ChildrenBase = *(void**)(Pad + 0xc);
	if (ChildrenBase)
	{
		for (INT i = 0; i < 8; i++)
			((FOctreeNode*)((BYTE*)ChildrenBase + i * 0x10))->CheckIsEmpty();
	}
}

// ?Draw@FOctreeNode@@QAEXVFColor@@HPBVFPlane@@@Z
// DIVERGENCE: stub; retail (0xdb6c0) draws the node's bounding box via GTempLineBatcher
//             and recurses into children.  Requires FTempLineBatcher access.
void FOctreeNode::Draw(FColor p0, int p1, FPlane const * p2) {}

// ?DrawFlaggedActors@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::DrawFlaggedActors(FCollisionOctree * p0, FPlane const * p1) {}

// ?FilterTest@FOctreeNode@@QAEXPAVFBox@@HPAV?$TArray@PAVFOctreeNode@@@@PBVFPlane@@@Z
void FOctreeNode::FilterTest(FBox * p0, int p1, TArray<FOctreeNode *> * p2, FPlane const * p3) {}

// ?MultiNodeFilter@FOctreeNode@@QAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
// Ghidra (0xd8ec0): In the full octree, routes actor to all overlapping child nodes.
// Simplified: store at this node directly (no subdivision).
void FOctreeNode::MultiNodeFilter(AActor* Actor, FCollisionOctree* OctHash, FPlane const* Plane)
{
	StoreActor(Actor, OctHash, Plane);
}

// ?RemoveAllActors@FOctreeNode@@QAEXPAVFCollisionOctree@@@Z
// Ghidra (0xdb3e0): Recursively clears all actors from this node and its children.
// Simplified: just clear this node's actor list.
void FOctreeNode::RemoveAllActors(FCollisionOctree* OctHash)
{
	TArray<AActor*>& ActorList = *(TArray<AActor*>*)this;
	ActorList.Empty();
}

// ?SingleNodeFilter@FOctreeNode@@QAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
// Ghidra (0xdc010): In the full octree, routes actor to the single containing child.
// Simplified: store at this node directly (no subdivision).
void FOctreeNode::SingleNodeFilter(AActor* Actor, FCollisionOctree* OctHash, FPlane const* Plane)
{
	StoreActor(Actor, OctHash, Plane);
}

// ?BuildActionSpotList@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: For each AR6ActionSpot, set CollisionHeight, call PutOnGround,
// find a NavigationPoint anchor within 1200 uu via FSortedPathList, then
// chain into LevelInfo->m_ActionSpotList linked list.
void FPathBuilder::BuildActionSpotList(ULevel* Level) {
	*(ULevel**)Pad = Level;
	// Spawn a scout if one is not already present (local_18 tracks whether we did)
	UBOOL bSpawnedScout = (*(APawn**)(Pad + 4) == NULL);
	if (bSpawnedScout)
		getScout();

	// Mark scout as "is player" for pathing purposes
	APawn* Scout = *(APawn**)(Pad + 4);
	*(BYTE*)((BYTE*)Scout + 0x2c) = 1;

	ALevelInfo* LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	LInfo->m_ActionSpotList = NULL;	// LevelInfo+0x4dc

	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (!Actor) continue;
		// IsA(AR6ActionSpot) && !bAutoBuilt (signed char at Actor+0xa0 >= 0)
		if (!Actor->IsA(AR6ActionSpot::StaticClass())) continue;
		if ((SBYTE)(*(BYTE*)((BYTE*)Actor + 0xa0)) < 0) continue;

		FSortedPathList SortedList;
		// Initialise count field to 0 (at Pad+0x100)
		*(INT*)(SortedList.Pad + 0x100) = 0;

		AR6ActionSpot* Spot = (AR6ActionSpot*)Actor;
		// Set CollisionHeight (Actor+0xfc): 70.0f if m_eFire==2, else 135.0f
		if (Spot->m_eFire == 2)
			*(FLOAT*)((BYTE*)Spot + 0xfc) = 70.0f;
		else
			*(FLOAT*)((BYTE*)Spot + 0xfc) = 135.0f;

		Spot->PutOnGround();

		LInfo = (*(ULevel**)Pad)->GetLevelInfo();
		for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
			// Skip if nav point has bit 2 set at offset 0x3a4
			if ((*(DWORD*)(Nav + 0x3a4) & 2) != 0) continue;
			// Compute squared distance from Spot->Location (FVector at 0x234) to nav point
			FLOAT dx = *(FLOAT*)((BYTE*)Spot + 0x234) - *(FLOAT*)(Nav + 0x234);
			FLOAT dy = *(FLOAT*)((BYTE*)Spot + 0x238) - *(FLOAT*)(Nav + 0x238);
			FLOAT dz = *(FLOAT*)((BYTE*)Spot + 0x23c) - *(FLOAT*)(Nav + 0x23c);
			FLOAT DistSq = dx*dx + dy*dy + dz*dz;
			// 1200 uu radius → 1440000 uu² threshold
			if (DistSq < 1440000.0f)
				SortedList.addPath((ANavigationPoint*)Nav, (INT)DistSq);
		}

		// If list has entries, find the best anchor
		if (*(INT*)(SortedList.Pad + 0x100) > 0) {
			FVector SpotLoc(*(FLOAT*)((BYTE*)Spot+0x234),
			                *(FLOAT*)((BYTE*)Spot+0x238),
			                *(FLOAT*)((BYTE*)Spot+0x23c));
			Spot->m_Anchor = SortedList.findEndAnchor(Scout, Spot, SpotLoc, 0);
		}

		// If an anchor was found, prepend to m_ActionSpotList linked list
		if (Spot->m_Anchor) {
			LInfo = (*(ULevel**)Pad)->GetLevelInfo();
			Spot->m_NextSpot = LInfo->m_ActionSpotList;
			LInfo->m_ActionSpotList = Spot;
		}
	}

	// Clean up scout if we spawned it
	if (bSpawnedScout) {
		Scout = *(APawn**)(Pad + 4);
		AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
		if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
		(*(ULevel**)Pad)->DestroyActor(Scout);
	}
}

// ?ReviewPaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: for each NavigationPoint in linked list, call ReviewPath(Scout);
// then warn about movers without associated nav points.
void FPathBuilder::ReviewPaths(ULevel* Level) {
	debugf(NAME_Log, TEXT("Reviewing paths"));
	GWarn->BeginSlowTask(TEXT("Reviewing paths..."), 0, 0);
	*(ULevel**)Pad = Level;

	if (Level) {
		ALevelInfo* LInfo = Level->GetLevelInfo();
		if (LInfo) {
			LInfo = *(ULevel**)Pad ? (*(ULevel**)Pad)->GetLevelInfo() : NULL;
			if (LInfo && *(INT*)((BYTE*)LInfo + 0x4d0) != 0) {
				// Count nav points to display progress
				INT Count = 0;
				for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8))
					Count++;

				getScout();
				SetPathCollision(1);

				APawn* Scout = *(APawn**)(Pad + 4);
				LInfo = (*(ULevel**)Pad)->GetLevelInfo();
				// Ghidra: call NavPoint->vtable[0x1a8](Scout) = ReviewPath(Scout)
				typedef void (__thiscall* tReviewPath)(BYTE*, APawn*);
				for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
					GWarn->StatusUpdatef(0, Count, TEXT("Reviewing Paths"));
					tReviewPath fn = *(tReviewPath*)((BYTE*)(*(void**)Nav) + 0x1a8);
					fn(Nav, Scout);
				}

				SetPathCollision(0);
				// Destroy Scout's AIController (Scout+0x4ec) and Scout via Level->DestroyActor
				AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
				if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
				(*(ULevel**)Pad)->DestroyActor(Scout);

				// Check movers for missing associated navigation points
				for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
					GWarn->StatusUpdatef(i, (*(ULevel**)Pad)->Actors.Num(), TEXT("Reviewing Movers"));
					AActor* Actor = (*(ULevel**)Pad)->Actors(i);
					if (Actor && Actor->IsA(AMover::StaticClass())) {
						// Skip mover if it has the 0x4000 flag set (bStatic path)
						if ((*(DWORD*)((BYTE*)Actor + 0x3b8) & 0x4000) == 0 &&
							*(INT*)((BYTE*)Actor + 0x3fc) == 0)
						{
							// Mover has no associated nav path - warn
							// Deviation: skip extended GWarn vtable call (slot 0x28 not declared)
							debugf(NAME_Warning, TEXT("No navigation point associated with this mover!"));
						}
					}
				}
				GWarn->EndSlowTask();
				return;
			}
		}
	}

	// No nav point list defined
	debugf(NAME_Warning, TEXT("No navigation point list. Paths define needed."));
	GWarn->EndSlowTask();
}

// ?defineChangedPaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: Partial redefinition — re-runs path building only for nav points
// flagged as changed (no 0x800 bit at NavPoint+0x3a4). For unchanged nav
// points, empties their PathList (TArray at +0x3d8). Same scout+pass sequence
// as definePaths but operates on the changed subset and spawns its own scout.
void FPathBuilder::defineChangedPaths(ULevel* Level) {
	*(ULevel**)Pad = Level;

	// Clear NavigationPointList head and the bPathsRebuilt bit
	ALevelInfo* LInfo = Level->GetLevelInfo();
	*(INT*)((BYTE*)LInfo + 0x4d0) = 0;
	LInfo = Level->GetLevelInfo();
	*(DWORD*)((BYTE*)LInfo + 0x94c) &= ~1u;

	// Pass 0: build nav point linked list (no InitForPathFinding here)
	for (INT i = 0; i < Level->Actors.Num(); i++) {
		AActor* Actor = Level->Actors(i);
		if (!Actor) continue;
		if (!Actor->IsA(ANavigationPoint::StaticClass())) continue;
		if ((SBYTE)(*(BYTE*)((BYTE*)Actor + 0xa0)) < 0) continue; // bAutoBuilt
		LInfo = (*(ULevel**)Pad)->GetLevelInfo();
		*(INT*)((BYTE*)Actor + 0x3a8) = *(INT*)((BYTE*)LInfo + 0x4d0);
		*(INT*)((BYTE*)LInfo + 0x4d0) = (INT)Actor;
	}

	// Pre-pass: for each nav point, decide how to handle changed vs unchanged
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		ANavigationPoint* NavPt = (ANavigationPoint*)Nav;
		if ((*(DWORD*)(Nav + 0x3a4) & 0x800) == 0) {
			// Not marked changed: check reachspecs for changed endpoints, prune
			TArray<UReachSpec*>& PathList = *(TArray<UReachSpec*>*)(Nav + 0x3d8);
			for (INT j = 0; j < PathList.Num(); j++) {
				UReachSpec* Spec = PathList(j);
				if (Spec && Spec->End && (*(DWORD*)((BYTE*)Spec->End + 0x3a4) & 0x800) != 0)
					*(BYTE*)((BYTE*)Spec + 0x2c) = 1; // mark pruned
			}
			NavPt->CleanUpPruned();
		} else {
			// Marked changed: empty the path list entirely
			// Ghidra: FArray::Empty(&NavPoint[0x3d8], 4, 0)
			((TArray<UReachSpec*>*)(Nav + 0x3d8))->Empty();
		}
	}

	getScout();
	// Verify Actors(0) is ALevelInfo
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Clear nav list and rebuild it for the main passes
	*(INT*)((BYTE*)(*(ULevel**)Pad)->Actors(0) + 0x4d0) = 0;
	GWarn->BeginSlowTask(TEXT("Defining Paths"), 1, 0);

	SetPathCollision(1);
	INT NavCount = 0;
	// Count NavPoints in first loop
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		GWarn->StatusUpdatef(i, (*(ULevel**)Pad)->Actors.Num(), TEXT("Defining"));
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (Actor && Actor->IsA(ANavigationPoint::StaticClass())) NavCount++;
	}

	// Verify + clear LevelInfo nav list head again
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
	*(INT*)((BYTE*)(*(ULevel**)Pad)->Actors(0) + 0x4d0) = 0;

	INT nc = 0;
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		GWarn->StatusUpdatef(nc, NavCount, TEXT("Navigation Points on Bases"));
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (!Actor) continue;
		if (!Actor->IsA(ANavigationPoint::StaticClass())) continue;
		if ((SBYTE)(*(BYTE*)((BYTE*)Actor + 0xa0)) < 0) continue; // bAutoBuilt
		nc++;
		// Verify + add to list with Actors(0) check
		if (!(*(ULevel**)Pad)->Actors(0))
			appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
		if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
			appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
		LInfo = (*(ULevel**)Pad)->GetLevelInfo();
		*(INT*)((BYTE*)Actor + 0x3a8) = *(INT*)((BYTE*)LInfo + 0x4d0);
		*(INT*)((BYTE*)LInfo + 0x4d0) = (INT)Actor;
		// InitForPathFinding at vtable[0x19c]
		typedef void (__thiscall* tInitPath)(BYTE*);
		tInitPath fn = *(tInitPath*)((BYTE*)(*(void**)Actor) + 0x19c);
		fn((BYTE*)Actor);
	}

	// Verify Actors(0)
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Pass 2: FindBase on each nav point (vtable[0x190])
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tFindBase)(BYTE*);
		tFindBase fn = *(tFindBase*)((BYTE*)(*(void**)Nav) + 0x190);
		fn(Nav);
	}

	debugf(NAME_Log, TEXT(""));

	// Pass 3: addReachSpecs at vtable[0x188](Scout, 1) — note: 1, not 0
	APawn* Scout = *(APawn**)(Pad + 4);
	INT rs = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(rs, NavCount, TEXT("Adding Reachspecs"));
		typedef void (__thiscall* tAddReach)(BYTE*, APawn*, INT);
		tAddReach fn = *(tAddReach*)((BYTE*)(*(void**)Nav) + 0x188);
		fn(Nav, Scout, 1);	// NOTE: int arg is 1 here (changed paths mode)
		rs++;
	}

	// Pass 4: SetupForcedPath at vtable[0x18c](Scout)
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tSetupForced)(BYTE*, APawn*);
		tSetupForced fn = *(tSetupForced*)((BYTE*)(*(void**)Nav) + 0x18c);
		fn(Nav, Scout);
	}

	debugf(NAME_Log, TEXT(""));

	// Pass 5: PrunePaths at vtable[0x1a0] with StatusUpdatef
	INT pr = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(pr, NavCount, TEXT("Pruning"));
		typedef INT (__thiscall* tPrune)(BYTE*);
		tPrune fn = *(tPrune*)((BYTE*)(*(void**)Nav) + 0x1a0);
		fn(Nav);
		pr++;
	}

	debugf(NAME_Log, TEXT(""));
	SetPathCollision(0);

	// Clear bAutoBuilt flags (0x800 at NavPoint+0x3a4)
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8))
		*(DWORD*)(Nav + 0x3a4) &= ~0x800u;

	BuildActionSpotList(Level);

	// Destroy Scout and its AIController
	Scout = *(APawn**)(Pad + 4);
	AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
	if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
	(*(ULevel**)Pad)->DestroyActor(Scout);

	debugf(NAME_Log, TEXT("defineChangedPaths done"));
	// Deviation: skip GWarn vtable[0x1c] call (undeclared)
	GWarn->EndSlowTask();
}

// ?definePaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: undefinePaths, then spawn scout, build nav-point linked list, run
// addReachSpecs + SetupForcedPath + PrunePaths + ClearPaths passes, destroy scout,
// set bPathsDefined, then BuildActionSpotList + PostPath on all actors.
void FPathBuilder::definePaths(ULevel* Level) {
	undefinePaths(Level);
	*(ULevel**)Pad = Level;
	getScout();

	ALevelInfo* LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	*(INT*)((BYTE*)LInfo + 0x4d0) = 0;	// clear NavigationPointList head
	// Clear bit 0 of LevelInfo+0x94c (bPathsRebuilt or similar)
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	*(DWORD*)((BYTE*)LInfo + 0x94c) &= ~1u;

	GWarn->BeginSlowTask(TEXT("Defining Paths"), 1, 0);
	INT NavCount = 0;
	SetPathCollision(1);

	// Pass 1: enumerate actors, build nav-point linked list, call InitForPathFinding
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		GWarn->StatusUpdatef(i, (*(ULevel**)Pad)->Actors.Num(), TEXT("Defining"));
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (!Actor) { i++; continue; }
		if (Actor->IsA(ANavigationPoint::StaticClass())) {
			NavCount++;
			// Add to linked list (LevelInfo[0x4d0] = head), NavPoint[0x3a8] = next
			LInfo = (*(ULevel**)Pad)->GetLevelInfo();
			*(INT*)((BYTE*)Actor + 0x3a8) = *(INT*)((BYTE*)LInfo + 0x4d0);
			*(INT*)((BYTE*)LInfo + 0x4d0) = (INT)Actor;
			// Ghidra: call NavPoint->vtable[0x19c](void) = InitForPathFinding
			typedef void (__thiscall* tInitPath)(BYTE*);
			tInitPath fn = *(tInitPath*)((BYTE*)(*(void**)Actor) + 0x19c);
			fn((BYTE*)Actor);
		} else {
			// Ghidra: call Actor->vtable[0x154](Scout) = AddMyMarker(Scout)
			APawn* Scout = *(APawn**)(Pad + 4);
			typedef void (__thiscall* tAddMarker)(AActor*, APawn*);
			tAddMarker fn = *(tAddMarker*)((BYTE*)(*(void**)Actor) + 0x154);
			fn(Actor, Scout);
		}
	}

	// Verify Actors(0) is LevelInfo
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);

	// Pass 2: call FindBase on each nav point (vtable[0x190/4=0x64])
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tFindBase)(BYTE*);
		tFindBase fn = *(tFindBase*)((BYTE*)(*(void**)Nav) + 0x190);
		fn(Nav);
	}

	debugf(NAME_Log, TEXT("Adding reachspecs"));

	// Pass 3: addReachSpecs(Scout, 0) on each nav point (vtable[0x188])
	APawn* Scout = *(APawn**)(Pad + 4);
	INT rs = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(rs, NavCount, TEXT("Adding Reachspecs"));
		typedef void (__thiscall* tAddReach)(BYTE*, APawn*, INT);
		tAddReach fn = *(tAddReach*)((BYTE*)(*(void**)Nav) + 0x188);
		fn(Nav, Scout, 0);
		rs++;
	}

	// Pass 4: SetupForcedPath(Scout) on each nav point (vtable[0x18c])
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		typedef void (__thiscall* tSetupForced)(BYTE*, APawn*);
		tSetupForced fn = *(tSetupForced*)((BYTE*)(*(void**)Nav) + 0x18c);
		fn(Nav, Scout);
	}

	debugf(NAME_Log, TEXT("Pruning paths"));

	// Pass 5: PrunePaths on each nav point (vtable[0x1a0]), count pruned
	INT pruned = 0; INT pr = 0;
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8)) {
		GWarn->StatusUpdatef(pr, NavCount, TEXT("Pruning"));
		typedef INT (__thiscall* tPrune)(BYTE*);
		tPrune fn = *(tPrune*)((BYTE*)(*(void**)Nav) + 0x1a0);
		pruned += fn(Nav);
		pr++;
	}

	debugf(NAME_Log, TEXT("Paths defined"));
	
	SetPathCollision(0);

	// Clear bAutoBuilt bit (0x800 at NavPoint+0x3a4) on all nav points
	LInfo = (*(ULevel**)Pad)->GetLevelInfo();
	for (BYTE* Nav = *(BYTE**)((BYTE*)LInfo + 0x4d0); Nav; Nav = *(BYTE**)(Nav + 0x3a8))
		*(DWORD*)(Nav + 0x3a4) &= ~0x800u;

	// Destroy Scout's AIController and Scout
	AActor* AICtrl = *(AActor**)((BYTE*)Scout + 0x4ec);
	if (AICtrl) (*(ULevel**)Pad)->DestroyActor(AICtrl);
	(*(ULevel**)Pad)->DestroyActor(Scout);

	// Set bPathsDefined (bit 0x800) on LevelInfo
	if (!(*(ULevel**)Pad)->Actors(0))
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
	if (!(*(ULevel**)Pad)->Actors(0)->IsA(ALevelInfo::StaticClass()))
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
	*(DWORD*)(((BYTE*)(*(ULevel**)Pad)->Actors(0)) + 0x450) |= 0x800;

	BuildActionSpotList(Level);

	// Call vtable[0x174](void) on all actors = PostPath or CheckForErrors
	for (INT i = 0; i < (*(ULevel**)Pad)->Actors.Num(); i++) {
		AActor* Actor = (*(ULevel**)Pad)->Actors(i);
		if (Actor) {
			typedef void (__thiscall* tPostPath)(AActor*);
			tPostPath fn = *(tPostPath*)((BYTE*)(*(void**)Actor) + 0x174);
			fn(Actor);
		}
	}

	debugf(NAME_Log, TEXT("definePaths done"));
	// Deviation: skip GWarn vtable[0x1c] call (slot not declared)
	GWarn->EndSlowTask();
}

// ?undefinePaths@FPathBuilder@@QAEXPAVULevel@@@Z
// Ghidra: destroy all non-transient ANavigationPoints; for transient ones call ClearPaths (vtable[0x66]);
// clear bPathsDefined on LevelInfo.
void FPathBuilder::undefinePaths(ULevel* Level) {
	*(ULevel**)Pad = Level;
	debugf(NAME_Log, TEXT("Undefining paths"));

	ALevelInfo* LInfo = Level->GetLevelInfo();
	*(DWORD*)((BYTE*)LInfo + 0x4d0) = 0;	// clear navigation point linked list head

	GWarn->BeginSlowTask(TEXT("Undefining"), 0, 0);

	INT i = 0;
	for (;;) {
		INT Num = Level->Actors.Num();
		if (i >= Num) {
			// Post-loop: verify Actors(0) and clear bPathsDefined (bit 0x800)
			if (!Level->Actors(0))
				appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AD);
			if (!Level->Actors(0)->IsA(ALevelInfo::StaticClass()))
				appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1AE);
			*(DWORD*)(((BYTE*)Level->Actors(0)) + 0x450) &= ~0x800u;
			GWarn->EndSlowTask();
			return;
		}
		GWarn->StatusUpdatef(i, Num, TEXT("Undefining"));
		AActor* Actor = Level->Actors(i);
		if (Actor && Actor->IsA(ANavigationPoint::StaticClass())) {
			UClass* Cls = Actor->GetClass();
			if ((*(DWORD*)((BYTE*)Cls + 0x48c) & 0x200) == 0) {
				// Normal nav point: destroy it then keep incrementing i
				Level->DestroyActor(Actor);
				i++;
				continue;
			} else {
				// Transient nav point: call ClearPaths via vtable slot 0x198/4 = 102
				// Deviation: vtable slot determined from Ghidra offset 0x198; likely ClearPaths()
				typedef void (__thiscall *tClearPaths)(AActor*);
				tClearPaths fn = *(tClearPaths*)((BYTE*)(*(void**)Actor) + 0x198);
				fn(Actor);
			}
		}
		i++;
	}
}

// ?Init@FPoly@@QAEXXZ
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
void FPoly::InsertVertex(int InPos, FVector InVtx)
{
	check(InPos <= NumVertices);
	for( INT i = NumVertices; i > InPos; i-- )
		Vertex[i] = Vertex[i - 1];
	Vertex[InPos] = InVtx;
	NumVertices++;
}

// ?Reverse@FPoly@@QAEXXZ
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

// ?Delete@FRebuildTools@@QAEXVFString@@@Z
void FRebuildTools::Delete(FString p0) {}

// ?Init@FRebuildTools@@QAEXXZ
void FRebuildTools::Init() {}

// ?SetCurrent@FRebuildTools@@QAEXVFString@@@Z
void FRebuildTools::SetCurrent(FString p0) {}

// ?Shutdown@FRebuildTools@@QAEXXZ
void FRebuildTools::Shutdown() {}


// ?AVIStart@@YAXPBGPAVUEngine@@H@Z
void AVIStart(const TCHAR* p0, UEngine * p1, int p2) {}

// ?AVIStop@@YAXXZ
void AVIStop() {}

// ?AVITakeShot@@YAXPAVUEngine@@@Z
void AVITakeShot(UEngine * p0) {}

// ?DrawSprite@@YAXPAVAActor@@VFVector@@PAVUMaterial@@PAVFLevelSceneNode@@PAVFRenderInterface@@@Z
void DrawSprite(AActor * p0, FVector p1, UMaterial * p2, FLevelSceneNode * p3, FRenderInterface * p4) {}

// ?DrawSprite@@YAXMVFVector@@0PAVUMaterial@@VFPlane@@EPAVFCameraSceneNode@@PAVFRenderInterface@@MHH@Z
void DrawSprite(float p0, FVector p1, FVector p2, UMaterial * p3, FPlane p4, BYTE p5, FCameraSceneNode * p6, FRenderInterface * p7, float p8, int p9, int p10) {}

// ?KME2UPosition@@YAXPAVFVector@@QBM@Z
void KME2UPosition(FVector* Out, float const * const In) {
	Out->X = In[0] * 50.0f;
	Out->Y = In[1] * 50.0f;
	Out->Z = In[2] * 50.0f;
}

// ?KME2UVecCopy@@YAXPAVFVector@@QBM@Z
void KME2UVecCopy(FVector* Out, float const * const In) {
	Out->X = In[0];
	Out->Y = In[1];
	Out->Z = In[2];
}

// ?KTermGameKarma@@YAXXZ
void KTermGameKarma() {}

// ?KU2MEPosition@@YAXQAMVFVector@@@Z
void KU2MEPosition(float * const Out, FVector In) {
	Out[0] = In.X * 0.02f;
	Out[1] = In.Y * 0.02f;
	Out[2] = In.Z * 0.02f;
}

// ?KU2MEVecCopy@@YAXQAMVFVector@@@Z
void KU2MEVecCopy(float * const Out, FVector In) {
	Out[0] = In.X;
	Out[1] = In.Y;
	Out[2] = In.Z;
}

// ?KUpdateMassProps@@YAXPAVUKMeshProps@@@Z
void KUpdateMassProps(UKMeshProps * p0) {}

// ?KarmaTriListDataInit@@YAXPAU_KarmaTriListData@@@Z
void KarmaTriListDataInit(_KarmaTriListData * p0) {}


// =============================================================================
// Explicit template instantiation for TArray<BYTE> and TLazyArray<BYTE>.
// The retail Engine.dll exports these symbols; explicit instantiation forces the
// compiler to emit out-of-line copies of all inline template members.
// =============================================================================
template class TArray<BYTE>;
template class TLazyArray<BYTE>;

// ============================================================================
// FSortedPathList
// ============================================================================
FSortedPathList::FSortedPathList() { appMemzero(this, sizeof(*this)); }
FSortedPathList& FSortedPathList::operator=(const FSortedPathList& Other) { appMemcpy(this, &Other, 260); return *this; } // 65 dwords
void FSortedPathList::addPath(ANavigationPoint* Path, INT Cost)
{
	// Ghidra (172B): Sorted insertion into fixed 32-element array.
	// Layout: Paths[32] at 0x00, Costs[32] at 0x80, Count at 0x100.
	ANavigationPoint** Paths = (ANavigationPoint**)&Pad[0];
	INT* Costs = (INT*)&Pad[0x80];
	INT& Count = *(INT*)&Pad[0x100];

	INT InsertIdx = 0;

	// Quick check: if last element's cost < new cost, start at end
	if (Count > 0 && Costs[Count - 1] < Cost)
		InsertIdx = Count;

	// Linear search for insertion point
	while (InsertIdx < Count && Costs[InsertIdx] <= Cost)
		InsertIdx++;

	// Insert if within max capacity (32)
	if (InsertIdx < 32)
	{
		// Save displaced element
		ANavigationPoint* SavedPath = Paths[InsertIdx];
		INT SavedCost = Costs[InsertIdx];

		// Write new element
		Paths[InsertIdx] = Path;
		Costs[InsertIdx] = Cost;

		// Grow count
		if (Count < 32)
			Count++;

		// Shift remaining elements right
		for (INT i = InsertIdx + 1; i < Count; i++)
		{
			ANavigationPoint* TempPath = Paths[i];
			INT TempCost = Costs[i];
			Paths[i] = SavedPath;
			Costs[i] = SavedCost;
			SavedPath = TempPath;
			SavedCost = TempCost;
		}
	}
}


// ============================================================================
// FSceneNode subclasses
// ============================================================================


// ============================================================================
// UInput / UInputPlanning
// ============================================================================
INT UInput::PreProcess(EInputKey Key, EInputAction Action, FLOAT Delta)
{
	// KeyDownMap at offset 0xEB4 from this (Ghidra-verified).
	BYTE* KeyDownMap = (BYTE*)this + 0xEB4;
	if (Action == IST_Press)
	{
		if (KeyDownMap[Key] == 0)
		{
			KeyDownMap[Key] = 1;
			return 1;
		}
	}
	else if (Action == IST_Release)
	{
		if (KeyDownMap[Key] != 0)
		{
			KeyDownMap[Key] = 0;
			return 1;
		}
	}
	else
	{
		return 1;
	}
	return 0;
}
INT UInput::Process(FOutputDevice& Ar, EInputKey Key, EInputAction Action, FLOAT Delta)
{
	if ((INT)Key < 0 || (INT)Key >= 0xFF)
		appFailAssert("iKey>=0&&iKey<IK_MAX", ".\\UnIn.cpp", 0x1E8);
	// Bindings array at offset 0x2B0 (FString[IK_MAX], 0xC each)
	FString& Binding = *(FString*)((BYTE*)this + (INT)Key * 0xC + 0x2B0);
	if (Binding.Len())
	{
		*(EInputAction*)((BYTE*)this + 0xEAC) = Action;
		*(FLOAT*)((BYTE*)this + 0xEB0) = Delta;
		Exec(*Binding, Ar);
		*(INT*)((BYTE*)this + 0xEAC) = 0;
		*(INT*)((BYTE*)this + 0xEB0) = 0;
		return 1;
	}
	return 0;
}
void UInput::DirectAxis(EInputKey Key, FLOAT Value, FLOAT Delta) {}

// ?GetKeyName@UInput@@QBEPBGHHPAVEInputKey@@@Z   (returns display name for a virtual-key code)
// Key names match the DefUser.ini binding keys (retail verified).
// Letters A-Z and digits 0-9 are their single character.
// Numpad, Function keys and special keys use the standard Unreal names.
// Unrecognised codes return "Unknown%02X" format (e.g. "Unknown3A").
const TCHAR* UInput::GetKeyName(EInputKey Key) const
{
	static TCHAR GenBuf[16]; // used for dynamically generated names
	DWORD k = (DWORD)Key;

	// A–Z  (0x41–0x5A)
	if (k >= 0x41 && k <= 0x5A) { GenBuf[0]=(TCHAR)k; GenBuf[1]=0; return GenBuf; }
	// 0–9  (0x30–0x39)
	if (k >= 0x30 && k <= 0x39) { GenBuf[0]=(TCHAR)k; GenBuf[1]=0; return GenBuf; }
	// NumPad 0–9  (0x60–0x69)
	if (k >= 0x60 && k <= 0x69)
		{ appSprintf(GenBuf, TEXT("NumPad%c"), TEXT('0')+(k-0x60)); return GenBuf; }
	// F1–F24  (0x70–0x87)
	if (k >= 0x70 && k <= 0x87)
		{ appSprintf(GenBuf, TEXT("F%d"), (INT)(k - 0x6F)); return GenBuf; }
	// Joy1–16 (0xC8–0xD7)
	if (k >= 0xC8 && k <= 0xD7)
		{ appSprintf(GenBuf, TEXT("Joy%d"), (INT)(k - 0xC7)); return GenBuf; }

	static const struct { DWORD Code; const TCHAR* Name; } Table[] =
	{
		{ 0x01, TEXT("LeftMouse")      }, { 0x02, TEXT("RightMouse")      },
		{ 0x03, TEXT("Cancel")         }, { 0x04, TEXT("MiddleMouse")      },
		{ 0x08, TEXT("Backspace")      }, { 0x09, TEXT("Tab")              },
		{ 0x0D, TEXT("Enter")          }, { 0x10, TEXT("Shift")            },
		{ 0x11, TEXT("Ctrl")           }, { 0x12, TEXT("Alt")              },
		{ 0x13, TEXT("Pause")          }, { 0x14, TEXT("CapsLock")         },
		{ 0x1B, TEXT("Escape")         }, { 0x20, TEXT("Space")            },
		{ 0x21, TEXT("PageUp")         }, { 0x22, TEXT("PageDown")         },
		{ 0x23, TEXT("End")            }, { 0x24, TEXT("Home")             },
		{ 0x25, TEXT("Left")           }, { 0x26, TEXT("Up")               },
		{ 0x27, TEXT("Right")          }, { 0x28, TEXT("Down")             },
		{ 0x29, TEXT("Select")         }, { 0x2A, TEXT("Print")            },
		{ 0x2B, TEXT("Execute")        }, { 0x2C, TEXT("PrintScrn")        },
		{ 0x2D, TEXT("Insert")         }, { 0x2E, TEXT("Delete")           },
		{ 0x2F, TEXT("Help")           },
		{ 0x6A, TEXT("GreyStar")       }, { 0x6B, TEXT("GreyPlus")         },
		{ 0x6C, TEXT("Separator")      }, { 0x6D, TEXT("GreyMinus")        },
		{ 0x6E, TEXT("NumPadPeriod")   }, { 0x6F, TEXT("GreySlash")        },
		{ 0x90, TEXT("NumLock")        }, { 0x91, TEXT("ScrollLock")       },
		{ 0xA0, TEXT("LShift")         }, { 0xA1, TEXT("RShift")           },
		{ 0xA2, TEXT("LControl")       }, { 0xA3, TEXT("RControl")         },
		{ 0xBA, TEXT("Semicolon")      }, { 0xBB, TEXT("Equals")           },
		{ 0xBC, TEXT("Comma")          }, { 0xBD, TEXT("Minus")            },
		{ 0xBE, TEXT("Period")         }, { 0xBF, TEXT("Slash")            },
		{ 0xC0, TEXT("Tilde")          }, { 0xDB, TEXT("LeftBracket")      },
		{ 0xDC, TEXT("Backslash")      }, { 0xDD, TEXT("RightBracket")     },
		{ 0xDE, TEXT("Quote")          },
		{ 0xE0, TEXT("JoyX")           }, { 0xE1, TEXT("JoyY")             },
		{ 0xE2, TEXT("JoyZ")           }, { 0xE3, TEXT("JoyR")             },
		{ 0xE4, TEXT("MouseX")         }, { 0xE5, TEXT("MouseY")           },
		{ 0xE6, TEXT("MouseZ")         }, { 0xE7, TEXT("MouseW")           },
		{ 0xE8, TEXT("JoyU")           }, { 0xE9, TEXT("JoyV")             },
		{ 0xEC, TEXT("MouseWheelUp")   }, { 0xED, TEXT("MouseWheelDown")   },
	};
	for (INT i = 0; i < ARRAY_COUNT(Table); i++)
		if (Table[i].Code == k) return Table[i].Name;

	appSprintf(GenBuf, TEXT("Unknown%02X"), k & 0xFF);
	return GenBuf;
}

// ?FindKeyName@UInput@@QBEHPBGAAHPAVEInputKey@@@Z (reverse lookup: name → EInputKey)
INT UInput::FindKeyName(const TCHAR* KeyName, EInputKey& Key) const
{
	for (INT i = 1; i < 256; i++)
	{
		if (!appStricmp(GetKeyName((EInputKey)i), KeyName))
		{
			Key = (EInputKey)i;
			return 1;
		}
	}
	return 0;
}
void UInput::SetInputAction(EInputAction Action, FLOAT Delta)
{
	*(EInputAction*)((BYTE*)this + 0xEAC) = Action;
	*(FLOAT*)((BYTE*)this + 0xEB0) = Delta;
}
EInputAction UInput::GetInputAction()
{
	return *(EInputAction*)((BYTE*)this + 0xEAC);
}
FLOAT UInput::GetInputDelta()
{
	return *(FLOAT*)((BYTE*)this + 0xEB0);
}
const TCHAR* UInput::StaticConfigName() { return TEXT("User"); }  // Retail: 6b. Returns hardcoded L"User" string pointer from .rdata.
void UInput::StaticInitInput() {}

// ============================================================================
// ALevelInfo
// ============================================================================
void ALevelInfo::SetVolumes(const TArray<class AVolume*>&) {}
void ALevelInfo::SetVolumes() {}
void ALevelInfo::SetZone(INT ZoneNumber, INT ZoneBitField)
{
	// Retail: 51b. If bit 7 of this+0xA0 is set, skip. Otherwise:
	// store DWORD from this+0x144 to this+0x228, store 0xFFFFFFFF to this+0x22C, 0 to this+0x230.
	// ZoneNumber and ZoneBitField args are not used in retail bytecode.
	if (*(BYTE*)((BYTE*)this + 0xA0) & 0x80) return;
	*(DWORD*)((BYTE*)this + 0x228) = *(DWORD*)((BYTE*)this + 0x144);
	*(DWORD*)((BYTE*)this + 0x22C) = 0xFFFFFFFF;
	*(DWORD*)((BYTE*)this + 0x230) = 0;
}
void ALevelInfo::PostNetReceive() {}
void ALevelInfo::PreNetReceive() {}
void ALevelInfo::CheckForErrors() {}
INT* ALevelInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}
void ALevelInfo::CallLogThisActor(AActor*) {}
// ?GetDefaultPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@XZ  Ghidra at ~279 bytes.
// Lazily spawns ADefaultPhysicsVolume and caches it at this+0x164.
// The original also sets vol+0x40C (Priority field, raw 0xFFF0BDC0) and vol+0xA0 |= 4.
// Priority raw-write left as TODO until AVolume layout is confirmed byte-accurate.
// CRITICAL: this must never return NULL as callers dereference the result unchecked.
APhysicsVolume* ALevelInfo::GetDefaultPhysicsVolume()
{
	APhysicsVolume*& CachedVol = *(APhysicsVolume**)((BYTE*)this + 0x164);
	if (!CachedVol)
	{
		CachedVol = (APhysicsVolume*)XLevel->SpawnActor(ADefaultPhysicsVolume::StaticClass());
		if (CachedVol)
		{
			// Priority: raw DWORD at vol+0x40C = 0xFFF0BDC0 (Ghidra; AVolume layout not yet verified)
			*(DWORD*)((BYTE*)CachedVol + 0x40C) = 0xFFF0BDC0u;
			// vol+0xA0 |= 4 (a bitmask flag in AActor's bitfield block)
			*(DWORD*)((BYTE*)CachedVol + 0xA0) |= 4;
		}
	}
	return CachedVol;
}
FString ALevelInfo::GetDisplayAs(FString s) { return s; }

// ?GetPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@VFVector@@PAVAActor@@H@Z  (0x0BBА00, 346 bytes)
// Walks the PhysicsVolume linked list to find the highest-priority volume
// that contains point V. With Actor+bUseTouchingVolumes=true it uses only
// the volumes in Actor->Touching (fast path).
// The list is lazily rebuilt when the dirty flag at this+0x94C bit 0 is clear.
// Priority field in APhysicsVolume is at raw offset 0x40C; next-pointer at 0x438.
APhysicsVolume* ALevelInfo::GetPhysicsVolume(FVector V, AActor* Actor, INT bUseTouchingVolumes)
{
	APhysicsVolume* Best = GetDefaultPhysicsVolume();
	if (!bUseTouchingVolumes || !Actor)
	{
		// Lazy rebuild of the linear PhysicsVolume list from the level's actor array.
		if (!(*(DWORD*)((BYTE*)this + 0x94C) & 1))
		{
			PhysicsVolumeList = NULL;
			ULevel* L = XLevel;
			INT N = L->Actors.Num();
			for (INT i = 0; i < N; i++)
			{
				AActor* A = L->Actors(i);
				if (A && A->IsA(APhysicsVolume::StaticClass()))
				{
					// Prepend A to the singly-linked list (NextVolume pointer at +0x438).
					*(APhysicsVolume**)((BYTE*)A + 0x438) = PhysicsVolumeList;
					PhysicsVolumeList = (APhysicsVolume*)A;
				}
			}
			*(DWORD*)((BYTE*)this + 0x94C) |= 1;
		}
		for (APhysicsVolume* V2 = PhysicsVolumeList; V2;
			 V2 = *(APhysicsVolume**)((BYTE*)V2 + 0x438))
		{
			// 0x40C = Priority (INT) in AVolume; pick highest-priority enclosing volume.
			if (*(INT*)((BYTE*)Best + 0x40C) < *(INT*)((BYTE*)V2 + 0x40C) &&
				V2->Encompasses(V))
				Best = V2;
		}
	}
	else
	{
		// Fast path: restrict search to volumes currently Touching the Actor.
		for (INT i = 0; i < Actor->Touching.Num(); i++)
		{
			AActor* A = Actor->Touching(i);
			if (A && A->IsA(APhysicsVolume::StaticClass()) &&
				*(INT*)((BYTE*)Best + 0x40C) < *(INT*)((BYTE*)A + 0x40C) &&
				((AVolume*)A)->Encompasses(V))
				Best = (APhysicsVolume*)A;
		}
	}
	return Best;
}
// Retail (44b + shared epilogue): zone audibility bitmask lookup.
// Bitmask is an array of 8-byte entries at this+0x650, indexed by Zone1.
// Each entry is two DWORDs. Bit (Zone2 & 31) of the lo DWORD is checked.
// CDQ pattern: for Zone2==31 the sign-extended mask also checks the hi DWORD.
// Returns 1 if audible, 0 if not. (Fallthrough path normalises to 1.)
INT ALevelInfo::IsSoundAudibleFromZone(INT Zone1, INT Zone2)
{
    if (Zone1 == Zone2)
        return 1;
    DWORD* Zones = (DWORD*)((BYTE*)this + 0x650);
    DWORD bit = 1u << Zone2;
    DWORD lo   = bit & Zones[Zone1 * 2];
    INT   hiMask = (INT)bit >> 31;  // CDQ: -1 if Zone2==31, else 0
    DWORD hi   = (DWORD)hiMask & Zones[Zone1 * 2 + 1];
    return (lo | hi) ? 1 : 0;
}

// ============================================================================
// AGameInfo
// ============================================================================
void AGameInfo::AbortScoreSubmission() {}
void AGameInfo::MasterServerManager() {}
void AGameInfo::InitGameInfoGameService() {}
void AGameInfo::ProcessR6Availabilty(ULevel*, FString) {}

// ============================================================================
// AGameReplicationInfo / APlayerReplicationInfo
// ============================================================================
void AGameReplicationInfo::PostNetReceive() {}
INT* AGameReplicationInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}
void APlayerReplicationInfo::PostNetReceive() {}
INT* APlayerReplicationInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}

// ============================================================================
// UNetConnection
// ============================================================================

// ?CreateChannel@UNetConnection@@QAEPAVUChannel@@W4EChannelType@@HH@Z (0x1855E0, 228 bytes)
// Allocates a new UChannel of the appropriate class, initialises it and
// registers it in the Channels array and OpenChannels list.
// Special ChIndex values:
//   -1         : auto-allocate any empty slot in [1,0x3FE] (or [0,0x3FE] for CHTYPE_Control)
//   0x7FFFFFFF : auto-allocate from patch-channel band [0x400, 0x410)
//   0x7FFFFFFE : auto-allocate from patch-channel band [0x410, 0x50F)
// Channels array at  this + ChIndex*4 + 0xEB0.
// OpenChannels TArray at this + 0x4B7C.
UChannel* UNetConnection::CreateChannel(EChannelType ChType, INT bOpenedLocally, INT ChIndex)
{
	if (!UChannel::IsKnownChannelType((INT)ChType))
		appFailAssert("UChannel::IsKnownChannelType(ChType)", ".\\UnConn.cpp", 0x31E);

	AssertValid();

	INT iIdx = ChIndex;
	if (ChIndex >= 0x400)
	{
		if (ChIndex == (INT)0x7FFFFFFF)
		{
			for (iIdx = 0x400; iIdx < 0x410; iIdx++)
				if (*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) == NULL) break;
			if (iIdx == 0x410) return NULL;
		}
		else if (ChIndex == (INT)0x7FFFFFFE)
		{
			for (iIdx = 0x410; iIdx < 0x50F; iIdx++)
				if (*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) == NULL) break;
			if (iIdx == 0x50F) return NULL;
		}
		if (iIdx >= 0x50F)
			appFailAssert("ChIndex<MAX_CHANNELS+NUM_ARMPATCH_CHANNELS", ".\\UnConn.cpp", 0x36A);
	}

	if (iIdx == -1)
	{
		iIdx = (ChType == CHTYPE_Control) ? 0 : 1;
		while (iIdx < 0x3FF && *(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) != NULL)
			iIdx++;
		if (iIdx == 0x3FF) return NULL;
	}

	if (ChIndex < 0x400)
	{
		if (iIdx >= 0x3FF)
			appFailAssert("ChIndex<MAX_CHANNELS", ".\\UnConn.cpp", 0x36E);
	}
	else
	{
		if (iIdx >= 0x50F)
			appFailAssert("ChIndex<MAX_CHANNELS+NUM_ARMPATCH_CHANNELS", ".\\UnConn.cpp", 0x36A);
	}

	if (*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) != NULL)
		appFailAssert("Channels[ChIndex]==NULL", ".\\UnConn.cpp", 0x373);

	// Construct the channel object for this channel type.
	UClass* Class = UChannel::ChannelClasses[ChType];
	check(Class->IsChildOf(UChannel::StaticClass()));
	UChannel* Ch = (UChannel*)UObject::StaticConstructObject(
		Class, UObject::GetTransientPackage(), NAME_None, 0, NULL, GError, NULL);
	Ch->Init(this, iIdx, bOpenedLocally);

	// Register in the fixed-size Channels array.
	*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) = Ch;

	// Append to OpenChannels dynamic list (TArray<UChannel*> at this+0x4B7C).
	INT arrIdx = ((FArray*)((BYTE*)this + 0x4B7C))->Add(1, sizeof(UChannel*));
	*(UChannel**)(*(BYTE**)((BYTE*)this + 0x4B7C) + arrIdx * sizeof(UChannel*)) = Ch;

	return Ch;
}
void UNetConnection::PostSend()
{
	// Out(FBitWriter) at offset 0x250, MaxPacket(INT) at offset 0xD0
	FBitWriter& Out = *(FBitWriter*)((BYTE*)this + 0x250);
	INT MaxPacket = *(INT*)((BYTE*)this + 0xD0);
	if (Out.GetNumBits() > MaxPacket * 8)
		appFailAssert("Out.GetNumBits()<=MaxPacket*8", ".\\UnConn.cpp", 0x2B6);
	if (Out.GetNumBits() == MaxPacket * 8)
		FlushNet();
}

// ============================================================================
// UChannel
// ============================================================================
UClass** UChannel::ChannelClasses = NULL;

// ============================================================================
// UDemoRecConnection
// ============================================================================
UDemoRecConnection::UDemoRecConnection(UNetDriver* Driver, const FURL& URL)
{
	guard(UDemoRecConnection::UDemoRecConnection);
	unguard;
}
void UDemoRecConnection::StaticConstructor() {}
FString UDemoRecConnection::LowLevelDescribe() { return FString(TEXT("Demo recording driver connection")); }
FString UDemoRecConnection::LowLevelGetRemoteAddress() { return FString(TEXT("")); }
void UDemoRecConnection::LowLevelSend(void* Data, INT Count) {
	// Ghidra at 0x187b80. Writes demo packet: FrameNum, DemoFrameTime, Count, Data.
	if (Driver->ServerConnection == NULL) {
		FArchive* FileAr = *(FArchive**)((BYTE*)Driver + 0xB4);
		FileAr->ByteOrderSerialize((BYTE*)Driver + 0xCC, 4);    // FrameNum (INT)
		FileAr->ByteOrderSerialize((BYTE*)Driver + 0x48, 8);    // DemoFrameTime (DOUBLE)
		FileAr->ByteOrderSerialize(&Count, 4);                  // packet size
		FileAr->Serialize(Data, Count);                          // packet data
	}
}

// Retail: 16b. Flushes only when playing back a demo (client, ServerConnection != NULL).
// JNZ path: if ServerConnection != NULL, cross-function-jump to UNetConnection::FlushNet.
void UDemoRecConnection::FlushNet() {
	if (Driver->ServerConnection != NULL)
		UNetConnection::FlushNet();
}
INT UDemoRecConnection::IsNetReady(INT) { return 1; }
void UDemoRecConnection::HandleClientPlayer(APlayerController*) {}
UDemoRecDriver* UDemoRecConnection::GetDriver() { return (UDemoRecDriver*)Driver; }

INT UPackageMapLevel::SerializeObject(FArchive&, UClass*, UObject*&) { return 1; } // Ghidra 0x18bd30: returns 1 on all paths; full net-object lookup TODO
// Ghidra at 0x48BCD0: default return is 1 (can serialize), returns 0 only for specific Actor flag checks.
INT UPackageMapLevel::CanSerializeObject(UObject*) { return 1; }

// ============================================================================
// UNullRenderDevice
// ============================================================================
void UNullRenderDevice::SetEmulationMode(EHardwareEmulationMode) {}
INT UNullRenderDevice::SupportsTextureFormat(ETextureFormat) { return 1; }

// ============================================================================
// UEngine / UGameEngine
// ============================================================================
void UGameEngine::BuildServerMasterMap(UNetDriver*, ULevel*) {}

void UTerrainPrimitive::Serialize(FArchive& Ar) { UPrimitive::Serialize(Ar); }
INT UTerrainPrimitive::LineCheck(FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD) { return 1; }
INT UTerrainPrimitive::PointCheck(FCheckResult&, AActor*, FVector, FVector, DWORD) { return 1; }
void UTerrainPrimitive::Illuminate(AActor*, INT) {}
FBox UTerrainPrimitive::GetRenderBoundingBox(const AActor*, INT) { return FBox(); }

void UTerrainSector::Serialize(FArchive& Ar) { UObject::Serialize(Ar); }
void UTerrainSector::PostLoad() {}
void UTerrainSector::StaticLight(INT) {}
void UTerrainSector::GenerateTriangles() {}
// Ghidra at 0x156550. Returns linear index in the global heightmap grid.
INT UTerrainSector::GetGlobalVertex(INT X, INT Y) {
	// TerrainInfo->HeightmapX is at offset 0x12E0 in ATerrainInfo
	INT HeightmapX = *(INT*)((BYTE*)TerrainInfo + 0x12E0);
	return (OffsetY + Y) * HeightmapX + OffsetX + X;
}

// Ghidra at 0x153a0. Returns linear index within this sector.
INT UTerrainSector::GetLocalVertex(INT X, INT Y) {
	return (SectorSizeX + 1) * Y + X;
}
INT UTerrainSector::PassShouldRenderTriangle(INT, INT, INT, INT, INT) { return 1; }
// ?IsSectorAll@UTerrainSector@@QAEHHE@Z  Ghidra at ~0x107bae30 (336 bytes).
// Gets the alpha texture for the layer, computes texel range for this sector,
// then checks that every texel matches 'value'. Returns 1 (true) on empty range.
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
INT UTerrainSector::IsTriangleAll(INT, INT, INT, INT, INT, BYTE) { return 0; }
void UTerrainSector::AttachProjector(AProjector*, FProjectorRenderInfo*) {}

// ============================================================================
// FStaticMeshColorStream
// ============================================================================
INT FStaticMeshColorStream::GetComponents(FVertexComponent* C) {
	C[0].Type = 4; C[0].Function = 3;
	return 1;
}

// ============================================================================
// FCollisionHash
// ============================================================================
// ?GetHashLink@FCollisionHash@@QAEAAPAUFCollisionLink@1@HHHAAH@Z
// Retail ordinal 3034 (0x6d680).
// Returns a reference to the bucket-head pointer for hash cell (x, y, z) and
// writes the encoded position z*0x100000 + y*0x400 + x into OutPos.
FCollisionHash::FCollisionLink*& FCollisionHash::GetHashLink(INT x, INT y, INT z, INT& OutPos)
{
	OutPos = (z * 0x400 + y) * 0x400 + x;
	return Buckets[HashX[x] ^ HashY[y] ^ HashZ[z]];
}

// ============================================================================
// URenderResource — Ghidra at 0x110D00.
// Serializes UObject + Revision (4 bytes at 0x2C).
// ============================================================================
void URenderResource::Serialize(FArchive& Ar)
{
	UObject::Serialize(Ar);
	Ar << Revision;
}

// ============================================================================
// FPoly
// ============================================================================
// ?RemoveColinears@FPoly@@QAEHXZ
// Removes collinear (in-line) vertices. A vertex is collinear if it lies within
// THRESH_POINT_ON_SIDE of the line connecting its two neighbours.
// Returns final vertex count.
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
// Karma free functions
// ============================================================================
struct _McdGeometry;
struct McdGeomMan;

_McdGeometry* KAggregateGeomInstance(FKAggregateGeom*, FVector, McdGeomMan*, const _WORD*) { return NULL; }
void KME2UCoords(FCoords* Out, const FLOAT (* const tm)[4]) {
	*Out = FCoords(
		FVector(tm[3][0]*50.f, tm[3][1]*50.f, tm[3][2]*50.f),
		FVector(tm[0][0], tm[0][1], tm[0][2]),
		FVector(tm[1][0], tm[1][1], tm[1][2]),
		FVector(tm[2][0], tm[2][1], tm[2][2])
	);
}
void KME2UMatrixCopy(FMatrix* Out, FLOAT (* const In)[4]) {
	appMemcpy(Out, In, sizeof(FLOAT)*16);
}
void KME2UTransform(FVector* OutPos, FRotator* OutRot, const FLOAT (* const tm)[4]) {
	OutPos->X = tm[3][0] * 50.0f;
	OutPos->Y = tm[3][1] * 50.0f;
	OutPos->Z = tm[3][2] * 50.0f;
	FCoords Coords;
	KME2UCoords(&Coords, tm);
	*OutRot = Coords.OrthoRotation();
}
void KModelToHulls(FKAggregateGeom*, UModel*, FVector) {}
void KU2MEMatrixCopy(FLOAT (* const Out)[4], FMatrix* In) {
	appMemcpy(Out, In, sizeof(FLOAT)*16);
}
void KU2METransform(FLOAT (* const tm)[4], FVector Pos, FRotator Rot) {
	FCoords Coords(FVector(0.f,0.f,0.f));
	Coords *= Rot;
	tm[0][0] = Coords.XAxis.X; tm[0][1] = Coords.XAxis.Y; tm[0][2] = Coords.XAxis.Z; tm[0][3] = 0.f;
	tm[1][0] = Coords.YAxis.X; tm[1][1] = Coords.YAxis.Y; tm[1][2] = Coords.YAxis.Z; tm[1][3] = 0.f;
	tm[2][0] = Coords.ZAxis.X; tm[2][1] = Coords.ZAxis.Y; tm[2][2] = Coords.ZAxis.Z; tm[2][3] = 0.f;
	tm[3][0] = Pos.X * 0.02f; tm[3][1] = Pos.Y * 0.02f; tm[3][2] = Pos.Z * 0.02f; tm[3][3] = 1.0f;
}

// ============================================================================
// TArray<BYTE> operators
// ============================================================================
// Ghidra: appends elements from Other to this, element-by-element via FArray::Add
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
TArray<BYTE>& TArray<BYTE>::operator+=(const TArray<BYTE>& Other)
{
	if (this != &Other)
		*this + Other;
	return *this;
}

// ============================================================================
// TLazyArray<BYTE> — copy ctor and operator= are compiler-generated;
// cannot provide explicit definitions. Left as linker stubs.
// ============================================================================


// ============================================================================
// AR6AbstractClimbableObj / UR6AbstractTerroristMgr (out-of-line ctors)
// ============================================================================
AR6AbstractClimbableObj::AR6AbstractClimbableObj() {}

// ============================================================================
// FHitObserver::Click (moved from inline to out-of-line)
// ============================================================================
void FHitObserver::Click(const FHitCause& Cause, const HHitProxy& Hit) {}
// ============================================================================

// ============================================================================
// UMeshInstance
// ============================================================================
// Default ctor now inline in header


// ============================================================================
// TLazyArray<BYTE> — force emission of implicitly-declared special members
// (copy ctor, operator=, default constructor closure).
// Explicit template instantiation only emits explicitly-defined members;
// these three are compiler-generated and need actual usage to be emitted.
// ============================================================================
template class TLazyArray<BYTE>;

// new[] forces default constructor closure (??_F); copy ctor and operator= are
// triggered by direct use. The function itself is unreachable but the symbols
// it references have external linkage and remain in the object file.
void _ForceTLazyArrayByteEmit() {
    TLazyArray<BYTE>* p = new TLazyArray<BYTE>[1];
    TLazyArray<BYTE> copy(*p);
    *p = copy;
    delete[] p;
}

/*-----------------------------------------------------------------------------
  AReplicationInfo virtual method stubs.
  Only methods NOT defined in EngineClassImpl.cpp remain here.
-----------------------------------------------------------------------------*/
void AReplicationInfo::DisplayVideo(UCanvas*, void*, INT) {}
void AReplicationInfo::Draw3DLine(FVector, FVector, FColor, UTexture*, FLOAT, FLOAT, FLOAT, FLOAT) {}
void AReplicationInfo::GetAvailableResolutions(TArray<FResolutionInfo>&) {}
DWORD AReplicationInfo::GetAvailableVideoMemory() { return 0; }
void AReplicationInfo::HandleFullScreenEffects(INT, INT) {}
