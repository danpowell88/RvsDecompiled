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
#if _MSC_VER > 1310
#include <intrin.h>
#endif

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

IMPL_TODO("Ghidra 0x103FB160 (1291b): Attach logic implemented; render-info ctor is internal helper FUN_103f82f0 (0x103f82f0) with unresolved concrete C++ type/layout, currently invoked by address.")
void AProjector::Attach()
{
	guard(AProjector::Attach);

	// Recalculate projection matrix
	CalcMatrix();

	// In editor: snapshot this frame's Location for preview display
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
		INT iVar4 = (INT)GMalloc->Malloc(200, TEXT("FProjectorRenderInfo"));
		INT* piVar5;
		if (iVar4 == 0)
		{
			piVar5 = NULL;
		}
		else
		{
			// FUN_103f82f0 is __thiscall: ECX = allocated mem, stack: (AProjector*, float)
			typedef INT* (*InitFn)(AProjector*, INT);
			piVar5 = ((InitFn)0x103f82f0)(this, 0);
		}
		*(INT**)((BYTE*)this + 0x48c) = piVar5;
		*piVar5 += 1;

		// Copy Rotation and Location vectors into RenderInfo
		INT ri = *(INT*)((BYTE*)this + 0x48c);
		*(DWORD*)(ri + 0xb0) = *(DWORD*)((BYTE*)this + 0x240);
		*(DWORD*)(ri + 0xb4) = *(DWORD*)((BYTE*)this + 0x244);
		*(DWORD*)(ri + 0xb8) = *(DWORD*)((BYTE*)this + 0x248);
		ri = *(INT*)((BYTE*)this + 0x48c);
		*(DWORD*)(ri + 0xbc) = *(DWORD*)((BYTE*)this + 0x234);
		*(DWORD*)(ri + 0xc0) = *(DWORD*)((BYTE*)this + 0x238);
		*(DWORD*)(ri + 0xc4) = *(DWORD*)((BYTE*)this + 0x23c);
	}

	// --- Terrain attachment loop (bit 1 = bProjectTerrain) ---
	if (*(BYTE*)((BYTE*)this + 0x3A0) & 2)
	{
		INT XLevel = *(INT*)((BYTE*)*(INT*)((BYTE*)this + 0x144) + 0x328);
		// TerrainArray at XLevel+0x101d8
		INT terrainData = *(INT*)(XLevel + 0x101d8);
		INT terrainNum  = *(INT*)(XLevel + 0x101d8 + 4);
		for (INT i = 0; i < terrainNum; i++)
		{
			INT terrain = *(INT*)(terrainData + i * 4);
			// Sector groups at terrain+0x3c0
			INT sectorData = *(INT*)(terrain + 0x3c0);
			INT sectorNum  = *(INT*)(terrain + 0x3c0 + 4);
			for (INT j = 0; j < sectorNum; j++)
			{
				INT sectorGroup = *(INT*)(sectorData + j * 4);
				// Sub-sectors at sectorGroup+0x12c8
				INT subData = *(INT*)(sectorGroup + 0x12c8);
				INT subNum  = *(INT*)(sectorGroup + 0x12c8 + 4);
				for (INT k = 0; k < subNum; k++)
				{
					INT subSector = *(INT*)(subData + k * 4);
					if (((FBox*)(subSector + 0x48))->Intersect(*(FBox*)((BYTE*)this + 0x470)))
					{
						INT* pRI = *(INT**)((BYTE*)this + 0x48c);
						*pRI += 1;
						((UTerrainSector*)subSector)->AttachProjector(
							this, (FProjectorRenderInfo*)pRI);
					}
				}
			}
		}
	}

	// --- BSP attachment loop (bit 0 = bProjectBSP) ---
	if (*(BYTE*)((BYTE*)this + 0x3A0) & 1)
	{
		TArray<INT> OverlapSurfs;
		// VisRadius = sin(FOV * 0.5 * PI/180)
		FLOAT VisRadius = appSin((FLOAT)(*(INT*)((BYTE*)this + 0x398)) * 0.5f * 0.017453292f);
		FVector Dir = (*(FRotator*)((BYTE*)this + 0x240)).Vector();
		UModel* Model = *(UModel**)((BYTE*)*(INT*)((BYTE*)*(INT*)((BYTE*)this + 0x144) + 0x328) + 0x90);
		Model->ConvexVolumeMultiCheck(
			*(FBox*)((BYTE*)this + 0x470),
			(FPlane*)((BYTE*)this + 0x3b0),
			6, Dir, OverlapSurfs, VisRadius);

		for (INT i = 0; i < OverlapSurfs.Num(); i++)
		{
			// Check surface material for transparency skip (flag 0x800 = m_bProjectTransparent)
			UBOOL bSkipTransparent = 0;
			if ((*(DWORD*)((BYTE*)this + 0x3A0) & 0x800) == 0)
			{
				// Look up the surface's material via BSP node chain:
				// surfIdx * 0x90 + Model->Surfs.Data + 0x34 = material/texture index
				// that * 0x5c + Model->TextureInfo.Data = material pointer
				INT surfIdx = OverlapSurfs(i);
				INT matIdx = *(INT*)(surfIdx * 0x90 + *(INT*)((BYTE*)Model + 0x5c) + 0x34);
				INT* pMat = *(INT**)(matIdx * 0x5c + *(INT*)((BYTE*)Model + 0x9c));
				if (pMat != NULL)
				{
					// vtable[0x7c/4] = IsTransparent() or similar virtual on UMaterial
					typedef INT (__thiscall* IsTransFn)(INT*);
					if (((IsTransFn)(*(void***)pMat)[0x7c/4])(pMat))
						bSkipTransparent = 1;
				}
			}

			// Check floor-only projection (flag 0x1000 = m_bProjectOnlyOnFloor)
			UBOOL bPassFloorCheck = 1;
			if (*(DWORD*)((BYTE*)this + 0x3A0) & 0x1000)
			{
				// Surface normal Z component at surfIdx * 0x90 + Surfs.Data + 0x08
				FLOAT NormalZ = *(FLOAT*)(OverlapSurfs(i) * 0x90 +
					*(INT*)((BYTE*)*(UModel**)((BYTE*)*(INT*)((BYTE*)*(INT*)((BYTE*)this + 0x144) + 0x328) + 0x90) + 0x5c) + 8);
				if (NormalZ < 0.5f)
					bPassFloorCheck = 0;
			}

			if (bPassFloorCheck && !bSkipTransparent)
			{
				// Clip planes: if bClipBSP (bit 7 = 0x80), pass FrustumPlanes; else NULL
				FPlane* ClipPlanes = NULL;
				if ((BYTE)*(DWORD*)((BYTE*)this + 0x3A0) & 0x80)
					ClipPlanes = (FPlane*)((BYTE*)this + 0x3b0);

				INT* pRI = *(INT**)((BYTE*)this + 0x48c);
				*pRI += 1;
				Model->AttachProjector(OverlapSurfs(i), (FProjectorRenderInfo*)pRI, (FPlane*)ClipPlanes);
			}
		}
		// TArray<INT> destructor runs automatically (replaces FUN_10322eb0 cleanup)
	}

	// --- Actor attachment loop (bit 2 = bProjectStaticMesh) ---
	if (*(BYTE*)((BYTE*)this + 0x3A0) & 4)
	{
		FCollisionHashBase* Hash = *(FCollisionHashBase**)((BYTE*)*(INT*)((BYTE*)*(INT*)((BYTE*)this + 0x144) + 0x328) + 0xf0);
		if (Hash)
		{
			FMemMark Mark(GMem);
			FCheckResult* Results = Hash->ActorEncroachmentCheck(
				GMem, this,
				*(FVector*)((BYTE*)this + 0x234),
				*(FRotator*)((BYTE*)this + 0x240),
				0x8002, 0);

			if ((*(DWORD*)((BYTE*)this + 0x3A0) & 0x20000) == 0)
			{
				// All-matching mode: attach every qualifying actor
				for (FCheckResult* Link = Results; Link; Link = Link->GetNext())
				{
					if ((*(DWORD*)((BYTE*)Link->Actor + 0xa0) & 0x200000) == 0)
						continue;

					// Check tag: ProjectTag == NAME_None OR Actor->Tag == ProjectTag
					FName None(NAME_None);
					FName ProjectTag = *(FName*)((BYTE*)this + 0x3ac);
					if (ProjectTag != None)
					{
						FName ActorTag = *(FName*)((BYTE*)Link->Actor + 0x19c);
						if (ActorTag != ProjectTag)
							continue;
					}

					// Must have bProjectStaticMesh set and actor has a StaticMesh
					if ((*(BYTE*)((BYTE*)this + 0x3A0) & 4) == 0)
						continue;
					if (*(INT*)((BYTE*)Link->Actor + 0x170) == 0)
						continue;

					Link->Actor->AttachProjector(this);
				}
			}
			else
			{
				// Closest-only mode (bProjectOnlyFirst): find nearest qualifying actor
				FVector BoxCenter = ((FBox*)((BYTE*)this + 0x470))->GetCenter();
				FLOAT ClosestDist = 1e+06f;
				FCheckResult* Closest = NULL;

				for (FCheckResult* Link = Results; Link; Link = Link->GetNext())
				{
					if ((*(DWORD*)((BYTE*)Link->Actor + 0xa0) & 0x200000) == 0)
						continue;

					FName None(NAME_None);
					FName ProjectTag = *(FName*)((BYTE*)this + 0x3ac);
					if (ProjectTag != None)
					{
						FName ActorTag = *(FName*)((BYTE*)Link->Actor + 0x19c);
						if (ActorTag != ProjectTag)
							continue;
					}

					if ((*(BYTE*)((BYTE*)this + 0x3A0) & 4) == 0)
						continue;
					if (*(INT*)((BYTE*)Link->Actor + 0x170) == 0)
						continue;

					FLOAT Dist = appSqrt(Square(BoxCenter.X - Link->Location.X) + Square(BoxCenter.Y - Link->Location.Y) + Square(BoxCenter.Z - Link->Location.Z));
					if (Dist < ClosestDist)
					{
						ClosestDist = Dist;
						Closest = Link;
					}
				}

				if (Closest)
					Closest->Actor->AttachProjector(this);
			}

			Mark.Pop();
		}
	}

	unguard;
}

// Local 4x4 matrix multiply helper (FUN_103f86b0, 169b, internal to Engine.dll).
// Computes dest = A * B for 4x4 row-major float matrices.
// Called via __thiscall(ECX=dest, stack=A, B) in retail; inlined here for simplicity.
static void CalcMatrixMul4x4(FLOAT* dest, const FLOAT* A, const FLOAT* B)
{
	for (INT r = 0; r < 4; r++)
		for (INT c = 0; c < 4; c++)
		{
			FLOAT s = 0.f;
			for (INT k = 0; k < 4; k++)
				s += A[r*4+k] * B[k*4+c];
			dest[r*4+c] = s;
		}
}

IMPL_TODO("Ghidra 0x103F8F90 (4699b): functional path implemented; orthographic scale divisors still approximated as Width/Height and animated-texture branch is only partially reconstructed, so parity status remains TODO.")
void AProjector::CalcMatrix()
{
	guard(AProjector::CalcMatrix);

	if (!*(BYTE**)(this+0x3a4))
		return;  // no texture → nothing to compute

	// 1. Decompose rotation into projection axes.
	//    FCoords.XAxis = Forward, -YAxis = Right (projector convention), ZAxis = Up.
	FCoords Coords = GMath.UnitCoords / *(FRotator*)(this+0x240);
	FVector Forward  =  Coords.XAxis;
	FVector RightNeg = FVector(-Coords.YAxis.X, -Coords.YAxis.Y, -Coords.YAxis.Z);
	FVector Up       =  Coords.ZAxis;
	FVector Pos      = *(FVector*)(this+0x234);

	// 2. Get texture dimensions via vtable calls.
	//    vtable[0x70/4] = USize (pixel width), vtable[0x74/4] = VSize (pixel height).
	typedef INT (__thiscall *GetTexDimFn)(BYTE*);
	BYTE** texPtr = (BYTE**)(this+0x3a4);
	void** vtbl   = *(void***)*texPtr;
	INT uSize = ((GetTexDimFn)vtbl[0x70/4])(*texPtr);
	INT vSize = ((GetTexDimFn)vtbl[0x74/4])(*texPtr);

	FLOAT DrawScale = *(FLOAT*)(this+0xe0);
	FLOAT Width     = (FLOAT)uSize * *(FLOAT*)(this+0x2bc) * DrawScale;
	FLOAT Height    = (FLOAT)vSize * *(FLOAT*)(this+0x2c0) * DrawScale;
	FLOAT HalfDiag  = appSqrt(Width*Width*0.25f + Height*Height*0.25f);

	// 3. Compute the 4 near corners of the frustum.
	//    Directions: D0 = Up + RightNeg, D1 = Up - RightNeg,
	//                D2 = -(Up + RightNeg) = -D0, D3 = -Up + RightNeg.
	//    PHYS_Rotating (5): unnormalized projection; else: SafeNormal.
	FVector D0 = Up + RightNeg;
	FVector D1 = Up - RightNeg;

	FVector* Corners = (FVector*)(this+0x410);  // 4 × FVector (stride 12)
	if (Physics == PHYS_Rotating)
	{
		// Unnormalized: just multiply direction by HalfDiag.
		Corners[0] = Pos + D0 * HalfDiag;
		Corners[1] = Pos + D1 * HalfDiag;
		Corners[2] = Pos + (- D0) * HalfDiag;   // -D0
		Corners[3] = Pos + (- D1) * HalfDiag;   // -D1 = -Up - RightNeg
	}
	else
	{
		// SafeNormal each direction, then scale.
		Corners[0] = Pos + D0.SafeNormal() * HalfDiag;
		Corners[1] = Pos + D1.SafeNormal() * HalfDiag;
		Corners[2] = Pos + (-D0).SafeNormal() * HalfDiag;
		Corners[3] = Pos + (-D1).SafeNormal() * HalfDiag;
	}

	// 4. Near frustum plane (this+0x3b0): normal = Forward, base = Pos.
	*(FPlane*)(this+0x3b0) = FPlane(Pos, Forward);

	// 5. Four side frustum planes (this+0x3c0..0x3fc).
	//    Stored in order: plane through corner[0], corner[1], corner[2], corner[3].
	INT FOV = *(INT*)(this+0x398);  // 0 = ortho, else perspective angle in degrees

	if (FOV == 0)
	{
		// Ortho: plane is the corner point + negated SafeNormal of the corner direction.
		*(FPlane*)(this+0x3c0) = FPlane(Corners[0], -D0.SafeNormal());
		*(FPlane*)(this+0x3d0) = FPlane(Corners[1], -D1.SafeNormal());
		*(FPlane*)(this+0x3e0) = FPlane(Corners[2], D0.SafeNormal());
		*(FPlane*)(this+0x3f0) = FPlane(Corners[3], D1.SafeNormal());
	}
	else
	{
		// Perspective: 3-point constructor (apex + two adjacent corners).
		// apex = Pos - Forward * cos(FOV/2)   (in front of Pos by half the angle cosine)
		FLOAT cosHalfFOV = appCos((FLOAT)FOV * 0.5f * 0.017453292f);
		FVector Apex = Pos - Forward * cosHalfFOV;

		*(FPlane*)(this+0x3c0) = FPlane(Apex, Corners[1], Corners[0]);
		*(FPlane*)(this+0x3d0) = FPlane(Apex, Corners[2], Corners[1]);
		*(FPlane*)(this+0x3e0) = FPlane(Apex, Corners[3], Corners[2]);
		*(FPlane*)(this+0x3f0) = FPlane(Apex, Corners[0], Corners[3]);
	}

	// 6. Far frustum plane (this+0x400): normal = -Forward, base = corner[3] (or [4] far point).
	//    For ortho the far-extent corners haven't been computed yet — use corner[3].
	*(FPlane*)(this+0x400) = FPlane(Corners[3], -Forward);

	// 7. Projection matrix (this+0x4d0).
	{
		FMatrix& ProjMat = *(FMatrix*)(this+0x4d0);
		if (FOV == 0)
		{
			// Orthographic: FCoords(center, Right/Width, Up/Height, Forward).Matrix()
			// DIVERGENCE: retail scale divisors extracted from intermediate stack buffers
			// (local_e0/local_c0/local_220/local_214) — approximated as Width and Height.
			FVector halfR = (Coords.YAxis) * (1.0f / Width);   // Right direction normalized to UV width
			FVector halfU = Up * (1.0f / Height);              // Up direction normalized to UV height
			// Center = Pos - halfR*(Width/2) - halfU*(Height/2)  (bottom-left corner mapped to UV 0,0)
			FVector Center = Pos - halfR * (Width * 0.5f) - halfU * (Height * 0.5f);
			FCoords projCoords(Center, halfR, halfU, Forward);
			ProjMat = projCoords.Matrix();
		}
		else
		{
			// Perspective:
			//   1. FCoords(apex, Right_positive, Up_positive, Forward).Matrix() → local_1c8
			//   2. ScaleMatrix = diag(0.5/tanFOV, 0.5/tanFOV, 1, 1) with [2][0..3] = 0.5,0.5,1,1
			//   3. ProjMat = local_1c8 * ScaleMatrix   via FUN_103f86b0
			FLOAT tanHalfFOV = appTan((FLOAT)FOV * 0.5f * 0.017453292f);
			FLOAT cosHalfFOV = appCos((FLOAT)FOV * 0.5f * 0.017453292f);
			FVector Apex = Pos - Forward * cosHalfFOV;
			// Positive Right direction = -RightNeg = Coords.YAxis
			FVector RightPos = Coords.YAxis;

			FCoords coordsForMat(Apex, RightPos, Up, Forward);
			FMatrix coordsMat = coordsForMat.Matrix();

			// Scale matrix matching Ghidra's local_188:
			//   M[0][0] = M[1][1] = 0.5/tanFOV
			//   M[2][0] = M[2][1] = 0.5,  M[2][2] = M[2][3] = 1.0
			FLOAT scaleArr[16];
			appMemzero(scaleArr, sizeof(scaleArr));
			FLOAT sc = 0.5f / tanHalfFOV;
			scaleArr[0]  = sc;    // [0][0]
			scaleArr[5]  = sc;    // [1][1]
			scaleArr[8]  = 0.5f;  // [2][0]
			scaleArr[9]  = 0.5f;  // [2][1]
			scaleArr[10] = 1.0f;  // [2][2]
			scaleArr[11] = 1.0f;  // [2][3]

			CalcMatrixMul4x4((FLOAT*)&ProjMat, (FLOAT*)&coordsMat, scaleArr);
		}
	}

	// 8. Four far-extent corners (this+0x440..0x46c).
	FLOAT FarRange = (FLOAT)*(INT*)(this+0x39c);
	FVector* FarCorners = (FVector*)(this+0x440);  // 4 × FVector
	if (FOV == 0)
	{
		// Ortho: shift each near corner forward by the range distance.
		for (INT i = 0; i < 4; i++)
			FarCorners[i] = Corners[i] + Forward * FarRange;
	}
	else
	{
		// Perspective: each far corner = apex + SafeNormal(nearCorner - apex) * FarRange.
		FLOAT cosHalfFOV = appCos((FLOAT)FOV * 0.5f * 0.017453292f);
		FVector Apex = Pos - Forward * cosHalfFOV;
		for (INT i = 0; i < 4; i++)
		{
			FVector dir = (Corners[i] - Apex).SafeNormal();
			FarCorners[i] = Corners[i] + dir * FarRange;
		}
	}

	// 9. Animated-texture offset section (flags & 0x4000).
	//    Updates the animated projection matrix at this+0x490 and copies to renderInfo+0x64 if present.
	DWORD Flags3a0 = *(DWORD*)(this+0x3a0);
	if ((Flags3a0 & 0x4000) && *(INT*)(this+0x3a8))
	{
		INT animTex = *(INT*)(this+0x3a8);
		FLOAT numFrames = (FLOAT)(*(INT*)(animTex + 100) - 2);  // animTex+0x64 = NumFrames-like
		FLOAT frameRatioOrLen;
		FVector localOrg;
		if (!(Flags3a0 & 0x400))
		{
			frameRatioOrLen = FarRange / (FLOAT)*(INT*)(animTex + 100);  // = Range / frames
			// near starting point along -Forward from far-extent corner[3]
			localOrg = Corners[3] - Forward / 1.0f;
		}
		else
		{
			frameRatioOrLen = (FLOAT)*(INT*)(this+0x39c) * 0.9f / (FLOAT)*(INT*)(animTex + 100);  // ~0.9*Range/numFrames
			localOrg = Corners[3] - Forward / 1.0f;
		}
		// Build animated FCoords: origin = localOrg, xAxis = zero, yAxis = Forward/divisor, zAxis = zero
		// FCoords(localOrg, FVector(0,0,0), Forward/divisor, FVector(0,0,0)).Matrix()
		FCoords animCoords(localOrg, FVector(0,0,0), Forward / (FarRange * numFrames), FVector(0,0,0));
		*(FMatrix*)(this+0x490) = animCoords.Matrix();
		if (*(INT*)(this+0x48c))
		{
			FLOAT* dst = (FLOAT*)(*(INT*)(this+0x48c) + 100);  // renderInfo + 0x64
			FLOAT* src = (FLOAT*)(this+0x490);
			for (INT i = 0; i < 16; i++) dst[i] = src[i];
		}
	}

	// 10. Compute the bounding box from all 8 corners.
	FBox& Box = *(FBox*)(this+0x470);
	Box.Init();
	for (INT i = 0; i < 4; i++)
	{
		Box += Corners[i];
		Box += FarCorners[i];
	}

	// 11. If renderInfo is present, copy the projection matrix to renderInfo+0x24.
	if (*(INT*)(this+0x48c))
	{
		FLOAT* dst = (FLOAT*)(*(INT*)(this+0x48c) + 0x24);
		FLOAT* src = (FLOAT*)(this+0x4d0);
		for (INT i = 0; i < 16; i++) dst[i] = src[i];
	}

	unguard;
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

