/*=============================================================================
	UnProjector.cpp: Projector actors (AProjector, UProjectorPrimitive)
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
#include <intrin.h>

// DAT_10780140 in retail: the singleton UProjectorPrimitive instance.
static UPrimitive* GProjectorPrimitive = NULL;

// --- AProjector ---
IMPL_MATCH("Engine.dll", 0x103f8690)
int AProjector::ShouldTrace(AActor * Other, DWORD TraceFlags)
{
	if (TraceFlags & 0x4000)
		return 1;
	return AActor::ShouldTrace(Other, TraceFlags);
}

IMPL_MATCH("Engine.dll", 0x103060c0)
void AProjector::TickSpecial(float DeltaTime)
{
	// When the projector uses rotating physics, recalculate its projection matrix.
	// Retail: cmp [this+0x2c(Physics)], 5; jne skip; call vtable[0x190/4=100]=CalcMatrix
	if (Physics == PHYS_Rotating)
		CalcMatrix();
}

IMPL_MATCH("Engine.dll", 0x103fad80)
void AProjector::UpdateParticleMaterial(UParticleMaterial* PM, int Index)
{
	// Retail: 0xfad80, 162b. Copy projector texture + matrix rows + flags into a
	// per-particle-material slot at Index * 0x4c within the UParticleMaterial.
	UObject* tex = *(UObject**)((BYTE*)this + 0x3a4);
	if (!tex || !tex->IsA(UBitmapMaterial::StaticClass()))
		tex = NULL;
	*(UObject**)((BYTE*)PM + Index * 0x4c + 0x88) = tex;
	// Copy 16 DWORDs (0x40 bytes) of matrix data from this+0x4d0
	appMemcpy((BYTE*)PM + Index * 0x4c + 0x8c, (BYTE*)this + 0x4d0, 0x40);
	*(DWORD*)((BYTE*)PM + Index * 0x4c + 0xcc) = (*(INT*)((BYTE*)this + 0x398) != 0) ? 1u : 0u;
	*(DWORD*)((BYTE*)PM + Index * 0x4c + 0xd0) = (DWORD)*(BYTE*)((BYTE*)this + 0x395);
}

IMPL_MATCH("Engine.dll", 0x1040b970)
void AProjector::RenderEditorSelected(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	RenderWireframe(RI);
	AActor::RenderEditorSelected(SceneNode, RI, DA);
}

IMPL_MATCH("Engine.dll", 0x103f8ae0)
void AProjector::RenderWireframe(FRenderInterface* RI)
{
	// Retail: 0xf8ae0, 1200b. Draws the projector volume as a wireframe box.
	// Push identity transform onto the render interface, then use FLineBatcher
	// to draw the 12 edges of the projection box from the 8 corner points
	// precomputed by CalcMatrix and stored at this+0x410 (4 far corners) and
	// this+0x434 (4 near corners), each an FVector (12 bytes).

	// Set identity matrix on the RI (vtable[0x34/4=13])
	static DWORD identity[16] = {
		0x3F800000,0,0,0,
		0,0x3F800000,0,0,
		0,0,0x3F800000,0,
		0,0,0,0x3F800000
	};
	typedef void (__thiscall* SetMatFn)(FRenderInterface*, void*);
	((SetMatFn)(*(void***)RI)[0x34/4])(RI, identity);

	// Create a line batcher and draw the 12 edges
	FLineBatcher lb(RI, 1, 0);
	FColor col(255, 0, 0);

	// Corner points at this+0x410 (far) and this+0x434 (near), 4 each (12 bytes = FVector)
	FVector* farPts  = (FVector*)((BYTE*)this + 0x410);
	FVector* nearPts = (FVector*)((BYTE*)this + 0x434);

	// Far-plane edges (rectangle)
	lb.DrawLine(farPts[0], farPts[1], col);
	lb.DrawLine(farPts[1], farPts[2], col);
	lb.DrawLine(farPts[2], farPts[3], col);
	lb.DrawLine(farPts[3], farPts[0], col);

	// Near-plane edges (rectangle)
	lb.DrawLine(nearPts[0], nearPts[1], col);
	lb.DrawLine(nearPts[1], nearPts[2], col);
	lb.DrawLine(nearPts[2], nearPts[3], col);
	lb.DrawLine(nearPts[3], nearPts[0], col);

	// Connecting edges between near and far planes
	lb.DrawLine(farPts[0], nearPts[0], col);
	lb.DrawLine(farPts[1], nearPts[1], col);
	lb.DrawLine(farPts[2], nearPts[2], col);
	lb.DrawLine(farPts[3], nearPts[3], col);
}

IMPL_MATCH("Engine.dll", 0x10306020)
void AProjector::PostEditChange()
{
	// Retail: 0x6020, 31b. Reattach on property change.
	AActor::PostEditChange();
	Detach(1);
	Attach();
}

IMPL_EMPTY("PostEditLoad — Ghidra shows retail body is empty (shared stub at 0x176d60)")
void AProjector::PostEditLoad()
{
	// Retail: 0x176d60 (shared empty stub)
}

IMPL_EMPTY("PostEditMove — Ghidra shows retail body is empty (shared stub at 0x176d60)")
void AProjector::PostEditMove()
{
	// Retail: 0x176d60 (shared empty stub)
}

IMPL_MATCH("Engine.dll", 0x103fb7f0)
void AProjector::Abandon()
{
	// Retail: 0xfb7f0, 103b. Decrement the render-info refcount and free when zero.
	INT* renderInfo = *(INT**)((BYTE*)this + 0x48c);
	if (renderInfo)
	{
		*renderInfo -= 1;
		if (*renderInfo == 0)
		{
			typedef void (*FunType)();
			((FunType)0x103719b0)();
			GMalloc->Free((void*)renderInfo);
		}
		*(DWORD*)((BYTE*)this + 0x48c) = 0;
	}
}

IMPL_DIVERGE("body incomplete — Ghidra 0x103FB160 not yet fully reconstructed")
void AProjector::Attach()
{
	// Retail: 0xfb160, 1291b. Build the projection matrix then allocate and populate
	// a FProjectorRenderInfo, and attach to terrain/BSP as appropriate.
	// DIVERGENCE: terrain sector iteration and BSP ConvexVolumeMultiCheck loop not
	// reconstructed — projector attaches without terrain/BSP surface info.

	// Recalculate projection matrix
	CalcMatrix();

	// In editor: snapshot this frame's direction vectors for preview display
	if (GIsEditor)
	{
		*(DWORD*)((BYTE*)this + 0x510) = *(DWORD*)((BYTE*)this + 0x234);
		*(DWORD*)((BYTE*)this + 0x514) = *(DWORD*)((BYTE*)this + 0x238);
		*(DWORD*)((BYTE*)this + 0x518) = *(DWORD*)((BYTE*)this + 0x23c);
		typedef void (__thiscall* Fn)(AProjector*, INT, INT);
		((Fn)(*(void***)this)[0x10c/4])(this, 0, 0);
	}

	if (*(INT*)((BYTE*)this + 0x48c) == 0)
	{
		// Allocate and initialise a FProjectorRenderInfo (200 bytes)
		void* mem = GMalloc->Malloc(200, TEXT("FProjectorRenderInfo"));
		INT* piVar5;
		if (!mem)
		{
			piVar5 = NULL;
		}
		else
		{
			typedef INT* (*InitFn)(AProjector*, INT);
			piVar5 = ((InitFn)0x103f82f0)(this, 0);
		}
		*(INT**)((BYTE*)this + 0x48c) = piVar5;
		if (piVar5)
			*piVar5 += 1;

		// Copy base colour tint vectors
		INT ri = *(INT*)((BYTE*)this + 0x48c);
		if (ri)
		{
			*(DWORD*)(ri + 0xb0) = *(DWORD*)((BYTE*)this + 0x240);
			*(DWORD*)(ri + 0xb4) = *(DWORD*)((BYTE*)this + 0x244);
			*(DWORD*)(ri + 0xb8) = *(DWORD*)((BYTE*)this + 0x248);
			*(DWORD*)(ri + 0xbc) = *(DWORD*)((BYTE*)this + 0x234);
			*(DWORD*)(ri + 0xc0) = *(DWORD*)((BYTE*)this + 0x238);
			*(DWORD*)(ri + 0xc4) = *(DWORD*)((BYTE*)this + 0x23c);
		}
	}

	// DIVERGENCE: terrain attachment (bit 1 of this+0x3a0) and
	// BSP attachment (bit 0 of this+0x3a0) — loops not reconstructed (see above).
}

IMPL_DIVERGE("body incomplete — Ghidra 0x103F8F90 not yet fully reconstructed")
void AProjector::CalcMatrix()
{
	// Retail: 0xf8f90, 4699b. Builds projection matrix and 8 frustum corner points
	// from position, rotation, FOV, and draw-distance properties.
	// DIVERGENCE: FCoords construction and matrix-multiply helpers not reconstructed.
}

IMPL_MATCH("Engine.dll", 0x103060a0)
void AProjector::Destroy()
{
	// Retail: 0x60a0, 21b.
	Detach(1);
	AActor::Destroy();
}

IMPL_MATCH("Engine.dll", 0x103fb6e0)
void AProjector::Detach(int Flush)
{
	// Retail: 0xfb6e0, 209b. Timestamp the render info with the current TSC-based
	// time, optionally zero the geometry data, then decrement the refcount and free.
	INT* renderInfo = *(INT**)((BYTE*)this + 0x48c);
	if (!renderInfo)
		return;

	// Convert rdtsc to seconds and store as a "last used" timestamp at renderInfo+0xc
	// __rdtsc() expands to _RVS_RDTSC() inline asm wrapper on MSVC 7.1 (via ImplSource.h).
	unsigned __int64 tsc = __rdtsc();
	double hi = (double)(int)(tsc >> 32);
	if ((signed __int64)tsc < 0) hi += 4294967296.0;
	double lo = (double)(int)(tsc & 0xFFFFFFFF);
	if ((int)(tsc & 0xFFFFFFFF) < 0) lo += 4294967296.0;
	*(double*)((BYTE*)renderInfo + 0xc) = (lo + hi * 4294967296.0) * GSecondsPerCycle + 16777216.0;

	if (Flush)
		*(unsigned __int64*)((BYTE*)renderInfo + 4) = 0;

	*renderInfo -= 1;
	if (*renderInfo == 0)
	{
		typedef void (*FunType)();
		((FunType)0x103719b0)();
		GMalloc->Free((void*)renderInfo);
	}
	*(DWORD*)((BYTE*)this + 0x48c) = 0;
}

IMPL_MATCH("Engine.dll", 0x103faca0)
UPrimitive * AProjector::GetPrimitive()
{
	if (!GProjectorPrimitive)
		GProjectorPrimitive = ConstructObject<UProjectorPrimitive>(UProjectorPrimitive::StaticClass());
	return GProjectorPrimitive;
}


// --- UProjectorPrimitive ---
IMPL_MATCH("Engine.dll", 0x103fa470)
int UProjectorPrimitive::LineCheck(FCheckResult &Result, AActor *Actor, FVector Start, FVector End, FVector Extent, DWORD ExtraNodeFlags, DWORD TraceFlags)
{
	// Ghidra 0xfa470: projector frustum line-check against 6 clip planes.
	if (!Actor)
		return 1;

	guard(UProjectorPrimitive::LineCheck);

	// If Actor isn't an AProjector, treat it as null (retail code masks it to 0)
	BYTE* Proj = Actor->IsA(AProjector::StaticClass()) ? (BYTE*)Actor : NULL;

	// 6 clip planes stored at Projector+0x3b0..+0x408 (FPlane[6], 16 bytes each).
	// Check each plane: if Start and End are both on negative side, line misses frustum.
	for (INT i = 0; i < 6; i++)
	{
		FPlane& Plane = *(FPlane*)(Proj + 0x3b0 + i * 0x10);
		if (Plane.PlaneDot(Start) < 0.0f && Plane.PlaneDot(End) < 0.0f)
			return 1;
	}

	// Line intersects all planes — fill result
	Result.Actor    = Actor;
	Result.Location = Start;
	Result.Normal   = (End - Start).SafeNormal();
	Result.Time     = 0.0f;

	unguard;
	return 0;
}

IMPL_MATCH("Engine.dll", 0x103fa360)
int UProjectorPrimitive::PointCheck(FCheckResult &Result, AActor *Actor, FVector Point, FVector Extent, DWORD ExtraNodeFlags)
{
	// Ghidra 0xfa360: projector frustum point-check (no SEH frame).
	BYTE* Proj = (Actor && Actor->IsA(AProjector::StaticClass())) ? (BYTE*)Actor : NULL;

	FPlane* Plane = (FPlane*)(Proj + 0x3b0); // 6 frustum planes at Projector+0x3b0
	for (INT i = 0; i < 6; i++, Plane = (FPlane*)((BYTE*)Plane + 0x10))
	{
		FLOAT extX = Plane->X * Extent.X; if (extX < 0.f) extX = -extX;
		FLOAT extY = Plane->Y * Extent.Y; if (extY < 0.f) extY = -extY;
		FLOAT extZ = Plane->Z * Extent.Z; if (extZ < 0.f) extZ = -extZ;
		if (Plane->PlaneDot(Point) < -(extX + extY + extZ))
			return 1; // outside this plane — miss
	}

	// All 6 planes passed — point is inside frustum
	Result.Actor = Actor;
	// Normal = projector forward direction (FRotator at Actor+0x240)
	*(FVector*)((BYTE*)&Result + 0x14) = ((FRotator*)(Proj + 0x240))->Vector();
	*(FVector*)((BYTE*)&Result + 0x08) = Point;
	return 0;
}

IMPL_MATCH("Engine.dll", 0x103f8270)
void UProjectorPrimitive::Destroy()
{
	// Retail: 0xf8270, 73b. Clear the singleton primitive global then chain to base.
	GProjectorPrimitive = NULL;
	UObject::Destroy();
}

IMPL_MATCH("Engine.dll", 0x103f8250)
FBox UProjectorPrimitive::GetCollisionBoundingBox(AActor const *) const
{
	// Retail: 30b. REP MOVSD 7 DWORDs (28b = FBox) from this+0x470.
	return *(FBox*)((BYTE*)this + 0x470);
}

IMPL_MATCH("Engine.dll", 0x1046ccb0)
FVector UProjectorPrimitive::GetEncroachCenter(AActor* Actor)
{
	// Ghidra 0x16ccb0: calls vtable[0x74/4]=GetCollisionBoundingBox(Actor), then FBox::GetCenter()
	// shares address with UModel::GetEncroachCenter and UStaticMesh::GetEncroachCenter
	return GetCollisionBoundingBox(Actor).GetCenter();
}

IMPL_MATCH("Engine.dll", 0x10304990)
FVector UProjectorPrimitive::GetEncroachExtent(AActor* Actor)
{
	// Ghidra 0x4990: calls vtable[0x74/4]=GetCollisionBoundingBox(Actor), then FBox::GetExtent()
	// shares address with UModel::GetEncroachExtent and UStaticMesh::GetEncroachExtent
	return GetCollisionBoundingBox(Actor).GetExtent();
}

