/*=============================================================================
	UnFluidSurface.cpp: Fluid surface actors and primitives
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

// Forward declaration for the DrawSprite free function (defined in EngineStubs.cpp)
void DrawSprite(AActor* Actor, FVector Pos, UMaterial* Sprite, FLevelSceneNode* SceneNode, FRenderInterface* RI);

// FLineExtentBoxIntersection is defined in CoreStubs.cpp and exported from Core.dll but
// not declared in any project header — forward-declare it here.
extern CORE_API INT FLineExtentBoxIntersection(const FBox& Box, const FVector& Start, const FVector& End, const FVector& Extent, FVector& HitLocation, FVector& HitNormal, FLOAT& HitTime);

// FUN_103db080: removes an oscillator pointer (passed as &ptr) from the target
// fluid surface's oscillator TArray at surface+0x47c.
IMPL_APPROX("Calls retail helper at 0x103db080 to remove oscillator from fluid surface list")
static void RemoveOscillatorFromList(void* oscPtr)
{
	typedef void (*FnType)(void*);
	((FnType)0x103db080)(oscPtr);
}

// --- AFluidSurfaceInfo ---
IMPL_MATCH("Engine.dll", 0x99f30)
void AFluidSurfaceInfo::UpdateOscillatorList()
{
	// Retail: 0x99f30, 208b.Scan the level actor list at Level+0x30 for
	// AFluidSurfaceOscillator actors that reference this surface, and append
	// them to the oscillator list TArray at this+0x47c.
	INT level = *(INT*)((BYTE*)this + 0x328);
	if (!level) return;
	INT i = 0;
	while (true)
	{
		FArray* actors = (FArray*)(level + 0x30);
		INT count = actors->Num();
		if (count <= i) break;
		UObject* actor = *(UObject**)(*(INT*)actors + i * 4);
		if (actor && (*(char*)((BYTE*)actor + 0xa0) >= 0) &&
		    actor->IsA(AFluidSurfaceOscillator::StaticClass()))
		{
			actor = *(UObject**)(*(INT*)actors + i * 4);
			if (!actor || !actor->IsA(AFluidSurfaceOscillator::StaticClass()))
				actor = NULL;
			if (actor && *(AFluidSurfaceInfo**)((BYTE*)actor + 0x3a4) == this)
			{
				FArray* oscList = (FArray*)((BYTE*)this + 0x47c);
				INT idx = oscList->Add(1, 4);
				*(UObject**)(*(INT*)oscList + idx * 4) = actor;
			}
		}
		i++;
	}
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x9a030, "actor intersection loop not reconstructed")
void AFluidSurfaceInfo::RebuildClampedBitmap()
{
	// Retail: 0x9a030, 1114b.Iterate level actors and test their collision boxes
	// against the fluid surface bounds to set/clear bits in the clamped bitmap.
	// DIVERGENCE: Ghidra 0x9a030 (1114 bytes). Full implementation iterates level
	// actors testing collision boxes against fluid surface bounds to set/clear bits
	// in the clamped bitmap. Actor intersection loop not reconstructed.
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x9abf0, "vertex/index buffer management and DrawMesh call not reconstructed")
void AFluidSurfaceInfo::Render(FDynamicActor* DA, FLevelSceneNode* SceneNode, TList<FDynamicLight*>* Lights, FRenderInterface* RI)
{
	// Retail: 0x9abf0, 864b.Update vertex/index buffers then submit a DrawMesh call.
	// DIVERGENCE: Ghidra 0x9abf0 (864 bytes). Full implementation updates vertex/index
	// buffers with current wave heights and lighting, then submits a DrawMesh call.
	// Vertex buffer management and D3D draw call pattern not reconstructed.
}

IMPL_MATCH("Engine.dll", 0x1065c0)
void AFluidSurfaceInfo::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	// Retail: 0x1065c0, 127b.Draw base editor info then overlay the sprite icon.
	AActor::RenderEditorInfo(SceneNode, RI, DA);
	if (*(INT*)((BYTE*)this + 0x168) != 0)
	{
		DrawSprite(this,
		           *(FVector*)((BYTE*)this + 0x234),
		           *(UMaterial**)((BYTE*)this + 0x168),
		           SceneNode, RI);
	}
}

IMPL_MATCH("Engine.dll", 0x1cad0)
void AFluidSurfaceInfo::SetClampedBitmap(int X, int Y, int Value)
{
	// Retail: 0x1cad0, 72b.Set or clear a single bit in the clamped-bitmap for (X, Y).
	// Bitmap base pointer is at *(this+0x404); grid width at this+0x39c.
	INT bit   = *(INT*)((BYTE*)this + 0x39c) * Y + X;
	DWORD mask = 1u << (bit & 0x1f);
	DWORD* word = (DWORD*)(*(INT*)((BYTE*)this + 0x404) + (bit >> 5) * 4);
	if (Value) *word |= mask;
	else       *word &= ~mask;
}

IMPL_MATCH("Engine.dll", 0x98a50)
void AFluidSurfaceInfo::FillIndexBuffer(void* Buf)
{
	// Retail: 0x98a50, 648b.Fill the triangle index buffer for the fluid mesh.
	// FluidGridType at this+0x394: 1 = hex (offset) grid, otherwise square grid.
	// FluidXSize at this+0x39c, FluidYSize at this+0x3a0.
	short* indices = (short*)Buf;
	INT fluidType  = *(BYTE*)((BYTE*)this + 0x394);
	INT xSize      = *(INT*)((BYTE*)this + 0x39c);
	INT ySize      = *(INT*)((BYTE*)this + 0x3a0);

	if (fluidType == 1)
	{
		// Hex (offset) grid: alternate triangle winding per row
		for (INT row = 0; row < ySize - 1; row++)
		{
			short r  = (short)row;
			short r1 = r + 1;
			for (INT col = 0; col < xSize - 1; col++)
			{
				short c = (short)col;
				if ((row & 1) == 0)
				{
					*indices++ = (short)(xSize * r  + c);
					*indices++ = (short)(xSize * r1 + c);
					*indices++ = (short)(xSize * r  + 1 + c);
					*indices++ = (short)(xSize * r1 + c);
					*indices++ = (short)(xSize * r1 + 1 + c);
					*indices++ = (short)(xSize * r  + 1 + c);
				}
				else
				{
					*indices++ = (short)(xSize * r  + c);
					*indices++ = (short)(xSize * r1 + 1 + c);
					*indices++ = (short)(xSize * r  + 1 + c);
					*indices++ = (short)(xSize * r  + c);
					*indices++ = (short)(xSize * r1 + c);
					*indices++ = (short)(xSize * r1 + 1 + c);
				}
			}
		}
	}
	else
	{
		// Square grid: simple row-major winding
		for (INT row = 0; row < ySize - 1; row++)
		{
			short r  = (short)row;
			short r1 = r + 1;
			for (INT col = 0; col < xSize - 1; col++)
			{
				short c = (short)col;
				*indices++ = (short)(xSize * r  + c);
				*indices++ = (short)(xSize * r  + 1 + c);
				*indices++ = (short)(xSize * r1 + c);
				*indices++ = (short)(xSize * r  + 1 + c);
				*indices++ = (short)(xSize * r1 + 1 + c);
				*indices++ = (short)(xSize * r1 + c);
			}
		}
	}
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x991e0, "per-vertex normal convolution and hex-offset row interleaving not reconstructed")
void AFluidSurfaceInfo::FillVertexBuffer(void* Buf)
{
	// Retail: 0x991e0, 2890b.Build per-vertex position + normal data for all grid points.
	// DIVERGENCE: Ghidra 0x991e0 (2890 bytes). Builds per-vertex position + normal
	// data for all grid points. Hex-offset row interleaving and normal-from-heights
	// convolution involve complex per-row pointer arithmetic not reconstructed.
}

IMPL_MATCH("Engine.dll", 0x1ca90)
int AFluidSurfaceInfo::GetClampedBitmap(int X, int Y)
{
	// Ghidra 0x1ca90:bit-array lookup — (xSize * Y + X) into the clamp bitmap at this+0x404.
	INT idx = *(INT*)((BYTE*)this + 0x39c) * Y + X; // xSize * Y + X
	return (INT)((*(DWORD*)(*(INT*)((BYTE*)this + 0x404) + (idx >> 5) * 4) & (1u << ((BYTE)idx & 0x1f))) != 0);
}

IMPL_MATCH("Engine.dll", 0x990d0)
void AFluidSurfaceInfo::GetNearestIndex(const FVector& Pos, int& X, int& Y)
{
	// Retail: 0x990d0, 199b.Map a world-space position to the nearest grid indices.
	// Grid origin at this+0x464 (X) / this+0x468 (Y); cell size at this+0x398.
	// Hex grid (this+0x394==1) uses a Y step of cellSize * 0.866025.
	FLOAT cellSize = *(FLOAT*)((BYTE*)this + 0x398);
	FLOAT originX  = *(FLOAT*)((BYTE*)this + 0x464);
	FLOAT originY  = *(FLOAT*)((BYTE*)this + 0x468);
	INT   xSize    = *(INT*)((BYTE*)this + 0x39c);
	INT   ySize    = *(INT*)((BYTE*)this + 0x3a0);

	INT xi = appRound((Pos.X - originX) / cellSize);
	X = xi;
	if (xi < 0)           xi = 0;
	else if (xi >= xSize - 1) xi = xSize - 1;
	X = xi;

	FLOAT yCellSize = (*(BYTE*)((BYTE*)this + 0x394) == 1) ? cellSize * 0.866025f : cellSize;
	INT yi = appRound((Pos.Y - originY) / yCellSize);
	Y = yi;
	if (yi < 0)           yi = 0;
	else if (yi >= ySize - 1) yi = ySize - 1;
	Y = yi;
}

IMPL_TODO("Needs Ghidra analysis")
FVector AFluidSurfaceInfo::GetVertexPos(int,int)
{
	return FVector(0,0,0);
}


// --- AFluidSurfaceOscillator ---
IMPL_MATCH("Engine.dll", 0x9af90)
void AFluidSurfaceOscillator::UpdateOscillation(float DeltaTime)
{
	// Retail: 0x9af90, 293b. Advance the oscillator's phase and call AFluidSurfaceInfo::Pling.
	if ((*(BYTE*)((BYTE*)this + 0xa0) & 0x80) == 0)
	{
		UObject* surface = *(UObject**)((BYTE*)this + 0x3a4);
		if (surface && surface->IsA(AFluidSurfaceInfo::StaticClass()) &&
		    (*(BYTE*)((BYTE*)surface + 0xa0) & 0x80) == 0)
		{
			// Accumulate time
			*(FLOAT*)((BYTE*)this + 0x3a8) += DeltaTime;
			FLOAT accTime  = *(FLOAT*)((BYTE*)this + 0x3a8);
			FLOAT period   = *(FLOAT*)((BYTE*)this + 0x398);   // seconds per cycle
			FLOAT amplitude = *(FLOAT*)((BYTE*)this + 0x39c);  // peak strength
			FLOAT strength;
			if (period <= 0.0001f)
			{
				strength = amplitude;
			}
			else
			{
				// Phase offset encoded as BYTE 0-255 → 0..1 normalised fraction
				FLOAT phaseOff = (FLOAT)*(BYTE*)((BYTE*)this + 0x394) * (1.0f / 255.0f);
				FLOAT wrapped  = (FLOAT)appFmod((DOUBLE)accTime, (DOUBLE)period);
				strength = amplitude * (FLOAT)appSin(
				    (DOUBLE)((phaseOff + wrapped / period) * 6.283185307f));
			}
			((AFluidSurfaceInfo*)surface)->Pling(
			    *(FVector*)((BYTE*)this + 0x234),
			    strength,
			    *(FLOAT*)((BYTE*)this + 0x3a0));
		}
	}
}

IMPL_MATCH("Engine.dll", 0x9b0f0)
void AFluidSurfaceOscillator::PostEditChange()
{
	// Retail: 0x9b0f0, 215b.Re-register with the target fluid surface on property change.
	INT level = *(INT*)((BYTE*)this + 0x328);
	if (!level) return;

	// Remove this oscillator from any existing fluid surface oscillator lists
	INT i = 0;
	while (true)
	{
		FArray* actors = (FArray*)(level + 0x30);
		INT count = actors->Num();
		if (count <= i) break;
		UObject* actor = *(UObject**)(*(INT*)actors + i * 4);
		if (actor && (*(char*)((BYTE*)actor + 0xa0) >= 0) &&
		    actor->IsA(AFluidSurfaceInfo::StaticClass()))
		{
			void* selfPtr = this;
			RemoveOscillatorFromList(&selfPtr);
		}
		i++;
	}

	// Add to the target surface's oscillator list if set
	if (*(INT*)((BYTE*)this + 0x3a4) != 0)
	{
		FArray* oscList = (FArray*)(*(INT*)((BYTE*)this + 0x3a4) + 0x47c);
		INT idx = oscList->Add(1, 4);
		*(AFluidSurfaceOscillator**)(*(INT*)oscList + idx * 4) = this;
	}
}

IMPL_MATCH("Engine.dll", 0x9b200)
void AFluidSurfaceOscillator::Destroy()
{
	// Retail: 0x9b200, 92b.Remove from the target surface's list then chain to base.
	AActor::Destroy();
	if (*(INT*)((BYTE*)this + 0x3a4) != 0)
	{
		void* selfPtr = this;
		RemoveOscillatorFromList(&selfPtr);
	}
}


// --- UFluidSurfacePrimitive ---
IMPL_MATCH("Engine.dll", 0x98820)
void UFluidSurfacePrimitive::Serialize(FArchive& Ar)
{
	// Ghidra 0x98820: delegates directly to UPrimitive::Serialize.
	UPrimitive::Serialize(Ar);
}

IMPL_MATCH("Engine.dll", 0x98d90)
int UFluidSurfacePrimitive::LineCheck(FCheckResult &Result, AActor *Actor, FVector Start, FVector End, FVector Extent, DWORD ExtraNodeFlags, DWORD TraceFlags)
{
	// Ghidra 0x98d90:fluid surface line-check against AABB or flat plane.
	guard(UFluidSurfacePrimitive::LineCheck);

	AFluidSurfaceInfo* FluidInfo = (AFluidSurfaceInfo*)*(INT*)((BYTE*)this + 0x58);

	if (Extent == FVector(0,0,0))
	{
		// Thin ray vs flat Z-plane at fluid surface Z
		FLOAT SurfaceZ = *(FLOAT*)((BYTE*)FluidInfo + 0x23c); // Actor.Location.Z
		FLOAT dz = End.Z - Start.Z;
		if (dz != 0.0f)
		{
			FLOAT t = (SurfaceZ - Start.Z) / dz;
			if (t >= 0.0f && t <= 1.0f)
			{
				FVector HitLoc(Start.X + (End.X - Start.X) * t, Start.Y + (End.Y - Start.Y) * t, SurfaceZ);
				// Bounds check: FluidInfo bounding box at +0x448
				FLOAT MinX = *(FLOAT*)((BYTE*)FluidInfo + 0x448);
				FLOAT MaxX = *(FLOAT*)((BYTE*)FluidInfo + 0x454);
				FLOAT MinY = *(FLOAT*)((BYTE*)FluidInfo + 0x44c);
				FLOAT MaxY = *(FLOAT*)((BYTE*)FluidInfo + 0x458);
				if (HitLoc.X >= MinX && HitLoc.X <= MaxX && HitLoc.Y >= MinY && HitLoc.Y <= MaxY)
				{
					Result.Actor    = (AActor*)FluidInfo;
					Result.Location = HitLoc;
					Result.Normal   = FVector(0,0,1);
					Result.Time     = t;
					INT nMats = ((FArray*)((BYTE*)FluidInfo + 0x1e0))->Num();
					*(DWORD*)((BYTE*)&Result + 0x2c) = (nMats >= 1) ? **(DWORD**)(*(INT*)((BYTE*)FluidInfo + 0x1e0)) : 0;
					return 0;
				}
			}
		}
	}
	else
	{
		// Extent line check vs bounding box
		FVector HitNormal, HitLoc;
		FLOAT   HitTime;
		if (FLineExtentBoxIntersection(*(FBox*)((BYTE*)FluidInfo + 0x448), Start, End, Extent, HitLoc, HitNormal, HitTime))
		{
			Result.Actor    = (AActor*)FluidInfo;
			Result.Location = HitLoc;
			Result.Normal   = HitNormal;
			Result.Time     = HitTime;
			INT nMats = ((FArray*)((BYTE*)FluidInfo + 0x1e0))->Num();
			*(DWORD*)((BYTE*)&Result + 0x2c) = (nMats >= 1) ? **(DWORD**)(*(INT*)((BYTE*)FluidInfo + 0x1e0)) : 0;
			return 0;
		}
	}

	unguard;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x98560)
int UFluidSurfacePrimitive::PointCheck(FCheckResult &Result, AActor *Actor, FVector Point, FVector Extent, DWORD ExtraNodeFlags)
{
	// Ghidra 0x98560: point-vs-AABB overlap test using fluid surface bounding box.
	AFluidSurfaceInfo* FluidInfo = (AFluidSurfaceInfo*)*(INT*)((BYTE*)this + 0x58);

	guard(UFluidSurfacePrimitive::PointCheck);

	FBox TestBox(FVector(Point.X - Extent.X, Point.Y - Extent.Y, Point.Z - Extent.Z),
	             FVector(Point.X + Extent.X, Point.Y + Extent.Y, Point.Z + Extent.Z));
	FBox* FluidBBox = (FBox*)((BYTE*)FluidInfo + 0x448);

	if (FluidBBox->Intersect(TestBox))
	{
		Result.Actor = (AActor*)FluidInfo;
		*(FVector*)((BYTE*)&Result + 0x14) = FVector(0.f, 0.f, 1.f);  // Normal = up
		*(FVector*)((BYTE*)&Result + 0x08) = Point;
		return 0;
	}

	unguard;
	return 1;
}

IMPL_APPROX("Returns bounding box from associated FluidSurfaceInfo")
FBox UFluidSurfacePrimitive::GetCollisionBoundingBox(AActor const *) const
{
	// Retail: 29b. REP MOVSD 7 DWORDs from *(this+0x58)+0x448.
	return *(FBox*)(*(BYTE**)((BYTE*)this + 0x58) + 0x448);
}

IMPL_TODO("Needs Ghidra analysis")
FBox UFluidSurfacePrimitive::GetRenderBoundingBox(AActor const *)
{
	return FBox();
}

IMPL_TODO("Needs Ghidra analysis")
FSphere UFluidSurfacePrimitive::GetRenderBoundingSphere(AActor const *)
{
	return FSphere();
}


// =============================================================================
// AFluidSurfaceInfo (moved from EngineClassImpl.cpp)
// =============================================================================

// AFluidSurfaceInfo
// =============================================================================

IMPL_APPROX("Delegates to Super::PostLoad")
void AFluidSurfaceInfo::PostLoad() { Super::PostLoad(); }
IMPL_APPROX("Delegates to Super::Destroy")
void AFluidSurfaceInfo::Destroy() { Super::Destroy(); }
IMPL_APPROX("Delegates to Super::PostEditChange")
void AFluidSurfaceInfo::PostEditChange() { Super::PostEditChange(); }
IMPL_APPROX("Delegates to Super::Tick")
INT AFluidSurfaceInfo::Tick( FLOAT DeltaTime, ELevelTick TickType ) { return Super::Tick( DeltaTime, TickType ); }
IMPL_TODO("Needs Ghidra analysis")
void AFluidSurfaceInfo::PostEditMove() {}
IMPL_TODO("Needs Ghidra analysis")
void AFluidSurfaceInfo::Spawned() {}
IMPL_TODO("Needs Ghidra analysis")
UPrimitive* AFluidSurfaceInfo::GetPrimitive() { return NULL; }
IMPL_TODO("Needs Ghidra analysis")
void AFluidSurfaceInfo::Init() {}
IMPL_TODO("Needs Ghidra analysis")
void AFluidSurfaceInfo::Pling( const FVector& Location, FLOAT Strength, FLOAT Radius ) {}
IMPL_TODO("Needs Ghidra analysis")
void AFluidSurfaceInfo::PlingVertex( INT X, INT Y, FLOAT Strength ) {}
IMPL_TODO("Needs Ghidra analysis")
void AFluidSurfaceInfo::UpdateSimulation( FLOAT DeltaTime ) {}

// =============================================================================
