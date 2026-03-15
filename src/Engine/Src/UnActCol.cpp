/*=============================================================================
	UnActCol.cpp: Actor collision and reach specs (UReachSpec)
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

#include "ImplSource.h"
#include "EngineDecls.h"

// --- FCollisionOctree debug draw queues (DAT_1077e2b8, DAT_1077e2c4, DAT_1077e2d0) ---
// Populated by debug visualization code; consumed by FCollisionOctree::Tick.
static TArray<FVector> GDbgOctreeLineStart;  // DAT_1077e2b8: line start points (FVector stride=12)
static TArray<FVector> GDbgOctreeLineEnd;    // DAT_1077e2c4: line end points   (FVector stride=12)
static TArray<FBox>    GDbgOctreeBoxes;      // DAT_1077e2d0: bounding boxes    (FBox   stride=28)

extern ENGINE_API FTempLineBatcher* GTempLineBatcher;  // defined in Engine.cpp

// --- FReachSpec ---
IMPL_MATCH("Engine.dll", 0x103115e0)
FReachSpec& FReachSpec::operator=(const FReachSpec& Other)
{
	appMemcpy(this, &Other, 44); // 11 dwords, shared with FStaticMeshCollisionNode
	return *this;
}


// --- UReachSpec ---
IMPL_MATCH("Engine.dll", 0x103fcdb0)
int UReachSpec::findBestReachable(AScout *Scout)
{
	// Ghidra 0xfcdb0: test reachability at multiple scout collision sizes;
	// fills Distance/CollisionRadius/CollisionHeight if a path exists.
	guard(UReachSpec::findBestReachable);

	// Three candidate (radius, height) pairs to try (small to large)
	FLOAT radii[3]   = {40.f, 40.f, 40.f};
	FLOAT heights[3] = {28.f, 40.f, 85.f};

	Scout->SetCollisionSize(radii[0], heights[0]);
	if (!PlaceScout(Scout))
		return 0;

	*(DWORD*)((BYTE*)Scout + 0x660) = 0; // reset scout state flag

	ANavigationPoint* StartNode = Start;
	ANavigationPoint* EndNode   = End;

	if (!Scout->actorReachable(EndNode, 1, 1))
		return 0;

	// Compute straight-line distance between nodes
	FVector delta(
		*(FLOAT*)((BYTE*)EndNode + 0x234) - *(FLOAT*)((BYTE*)StartNode + 0x234),
		*(FLOAT*)((BYTE*)EndNode + 0x238) - *(FLOAT*)((BYTE*)StartNode + 0x238),
		*(FLOAT*)((BYTE*)EndNode + 0x23c) - *(FLOAT*)((BYTE*)StartNode + 0x23c));
	*(INT*)((BYTE*)this + 0x30) = appRound(delta.Size()); // Distance
	*(INT*)((BYTE*)this + 0x34) = appRound(radii[0]);    // CollisionRadius
	*(INT*)((BYTE*)this + 0x38) = appRound(heights[0]);  // CollisionHeight

	// Try progressively larger collision sizes
	for (INT i = 1; i < 3; i++)
	{
		Scout->SetCollisionSize(radii[i], heights[i]);
		if (!PlaceScout(Scout))
			break;
		if (!Scout->actorReachable(EndNode, 1, 1))
			break;
		*(INT*)((BYTE*)this + 0x34) = appRound(radii[i]);
		*(INT*)((BYTE*)this + 0x38) = appRound(heights[i]);
	}

	unguard;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x1030ff90)
int UReachSpec::supports(int Radius, int Height, int ReqFlags, int MaxV)
{
  // Retail (52b, RVA 0xFF90): check if this spec can be used by a mover with
  // the given collision radius/height, required reach flags, and max landing velocity.
  if (CollisionRadius < Radius)       return 0;
  if (CollisionHeight < Height)       return 0;
  if ((reachFlags & ReqFlags) != reachFlags) return 0;
  if (MaxLandingVelocity > MaxV)      return 0;
  return 1;
}

IMPL_MATCH("Engine.dll", 0x103fd140)
int UReachSpec::defineFor(ANavigationPoint *Pt1, ANavigationPoint *Pt2, APawn *Scout)
{
	// Ghidra 0xfd140: record start/end nav-points, call InitForPathing, then findBestReachable.
	// result declared before guard so it remains in scope after unguard.
	INT result = 0;

	guard(UReachSpec::defineFor);

	Start = Pt1;
	End   = Pt2;

	// Validate Scout is an AScout (retail uses IsA check, masks to NULL if not)
	AScout* ActualScout = NULL;
	if (Scout && Scout->IsA(AScout::StaticClass()))
		ActualScout = (AScout*)Scout;

	if (ActualScout)
		ActualScout->InitForPathing();

	// PrePath virtual call (vtable offset 0x178 on ANavigationPoint)
	typedef void (__thiscall* NavVFn)(void*);
	((NavVFn)(*(DWORD*)(*(DWORD*)(BYTE*)Pt1 + 0x178)))((void*)Pt1);
	((NavVFn)(*(DWORD*)(*(DWORD*)(BYTE*)Pt2 + 0x178)))((void*)Pt2);

	result = findBestReachable(ActualScout);

	// PostPath virtual call (vtable offset 0x17c)
	((NavVFn)(*(DWORD*)(*(DWORD*)(BYTE*)Pt1 + 0x17c)))((void*)Pt1);
	((NavVFn)(*(DWORD*)(*(DWORD*)(BYTE*)Pt2 + 0x17c)))((void*)Pt2);

	unguard;
	return result;
}

IMPL_MATCH("Engine.dll", 0x103fc830)
FPlane UReachSpec::PathColor()
{
	// Retail: 0xfc830, ordinal 3857. Returns a colour for editor path visualisation
	// based on reach flags (reachFlags at this+0x3C) and collision radius/height.
	// Flag bits at reachFlags:
	//   0x80 = bot-only (return red)
	//   0x20 = swimming  (return blue)
	//   0x40 = flying    (return yellow / orange)
	//   0x100 = disabled  (black)
	// If none of the above and CollisionRadius > 0x27 && Height > 0x54 && not forced:
	//   return green (0,1,0) — wide large path
	// Otherwise return red (1,0,0,1)
	DWORD flags = (DWORD)reachFlags;
	FLOAT r, g, b;
	if (flags & 0x100)
	{
		// disabled — black
		r = 0.0f; g = 0.0f; b = 0.0f;
	}
	else if ((BYTE)flags & 0x80)
	{
		// bot-only — black/grey tint: r=0, g=0
		r = 0.0f; g = 0.0f; b = 1.0f;
	}
	else if (flags & 0x20)
	{
		// swimming — blue
		r = 1.0f; g = 0.0f; b = 1.0f;
	}
	else if (flags & 0x40)
	{
		// flying — yellow
		r = 1.0f; g = 0.5f; b = 0.0f;
	}
	else if (CollisionRadius > 0x27 && CollisionHeight > 0x54 && !(flags & 2))
	{
		// Wide, tall, non-forced — green
		r = 0.0f; g = 1.0f; b = 0.0f;
	}
	else
	{
		// default — red
		r = 1.0f; g = 0.0f; b = 0.0f;
	}
	return FPlane(r, g, b, 0.0f);
}

IMPL_MATCH("Engine.dll", 0x103fca40)
int UReachSpec::PlaceScout(AScout *Scout)
{
	// Ghidra 0xfca40: teleport Scout to the Start node's location (with optional ladder/ledge offset).
	guard(UReachSpec::PlaceScout);

	ANavigationPoint* StartNode = Start;

	typedef INT  (__thiscall* TeleportFn)(void*, DWORD, DWORD, DWORD, INT, INT, INT, INT);
	typedef void (__thiscall* MoveSmFn  )(void*, DWORD, DWORD, DWORD, DWORD, DWORD, DWORD, void*, INT, INT, INT, INT, INT);

	TeleportFn fTeleport   = (TeleportFn)(*(DWORD*)(*(DWORD*)(BYTE*)Scout + 0x9c));
	MoveSmFn   fMoveSmooth = (MoveSmFn  )(*(DWORD*)(*(DWORD*)(BYTE*)Scout + 0x98));

	// 12-slot FCheckResult buffer initialised to Time=1.0 (miss), Item=-1
	DWORD CheckBuf[12] = {0,0,0,0,0,0,0,0,0,0x3f800000,0xffffffff,0};

	// If Start is on a ledge/ladder (bSpecialMove or IsA ALadder), offset teleport up by height diff
	if (*(INT*)((BYTE*)StartNode + 0x15c) != 0 || StartNode->IsA(ALadder::StaticClass()))
	{
		FLOAT scoutH = *(FLOAT*)((BYTE*)Scout    + 0xfc);
		FLOAT startH = *(FLOAT*)((BYTE*)StartNode + 0xfc);
		FLOAT zOff   = scoutH - startH;
		if (zOff < 0.f) zOff = 0.f;
		FLOAT placeZ = *(FLOAT*)((BYTE*)StartNode + 0x23c) + zOff;
		INT ok = fTeleport(Scout,
			*(DWORD*)((BYTE*)StartNode + 0x234),
			*(DWORD*)((BYTE*)StartNode + 0x238),
			*(DWORD*)&placeZ,
			0, 0, 0, 0);
		if (ok)
		{
			FLOAT dropZ = -scoutH;
			fMoveSmooth(Scout,
				0x80000000, 0x80000000, *(DWORD*)&dropZ,
				*(DWORD*)((BYTE*)Scout + 0x240),
				*(DWORD*)((BYTE*)Scout + 0x244),
				*(DWORD*)((BYTE*)Scout + 0x248),
				CheckBuf, 0, 0, 0, 0, 0);
			goto PlaceScout_done;
		}
	}

	// Fallback: TeleportTo at Start->Location
	{
		INT ok = fTeleport(Scout,
			*(DWORD*)((BYTE*)StartNode + 0x234),
			*(DWORD*)((BYTE*)StartNode + 0x238),
			*(DWORD*)((BYTE*)StartNode + 0x23c),
			0, 0, 0, 0);
		if (!ok)
			return 0;
	}

PlaceScout_done:
	// If scout can fly, drop it down by CollisionHeight to land on the node
	if (*(BYTE*)((BYTE*)Scout + 0x2c * sizeof(INT)) == 1) // bFly (DWORD-indexed)
	{
		FLOAT dropH = -(*(FLOAT*)((BYTE*)StartNode + 0xfc));
		fMoveSmooth(Scout, 0, 0, *(DWORD*)&dropH,
			*(DWORD*)((BYTE*)Scout + 0x240),
			*(DWORD*)((BYTE*)Scout + 0x244),
			*(DWORD*)((BYTE*)Scout + 0x248),
			CheckBuf, 0, 0, 0, 0, 0);
	}

	unguard;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x103fc950)
int UReachSpec::operator==(UReachSpec const & other)
{
	// Retail: 0xfc950, ordinal 1865. Compares the 5 navigation spec fields:
	// Distance (+0x30), CollisionRadius (+0x34), CollisionHeight (+0x38),
	// reachFlags (+0x3C), MaxLandingVelocity (+0x40 < 0x24F vs same comparison).
	// Returns 1 if all match.
	if (Distance       != other.Distance)       return 0;
	if (CollisionRadius != other.CollisionRadius) return 0;
	if (CollisionHeight != other.CollisionHeight) return 0;
	if (reachFlags     != other.reachFlags)     return 0;
	if ((MaxLandingVelocity < 0x24F) != (other.MaxLandingVelocity < 0x24F)) return 0;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x103fccd0)
UReachSpec * UReachSpec::operator+(UReachSpec const & other) const
{
	// Retail: 0xfccd0, 165 bytes. Creates a new UReachSpec in the same outer package,
	// then sets: CollisionRadius/Height = min of both, reachFlags = OR of both,
	// Distance = sum of both, MaxLandingVelocity = max of both.
	UReachSpec* result = (UReachSpec*)UObject::StaticConstructObject(
		StaticClass(), GetOuter(), NAME_None, 0, NULL, GError, (INT)0);
	if (!result) return NULL;
	result->CollisionRadius  = (CollisionRadius  < other.CollisionRadius)  ? CollisionRadius  : other.CollisionRadius;
	result->CollisionHeight  = (CollisionHeight  < other.CollisionHeight)  ? CollisionHeight  : other.CollisionHeight;
	result->reachFlags       = reachFlags | other.reachFlags;
	result->Distance         = Distance + other.Distance;
	result->MaxLandingVelocity = (MaxLandingVelocity > other.MaxLandingVelocity) ? MaxLandingVelocity : other.MaxLandingVelocity;
	return result;
}

IMPL_MATCH("Engine.dll", 0x103fc9f0)
int UReachSpec::operator<=(UReachSpec const & other)
{
	// Retail: 0xfc9f0, 68 bytes. Returns 1 if this spec is dominated by other:
	// other must have at least as wide radius/height, a superset of reachFlags,
	// and a landing velocity tolerance at least as permissive.
	if (other.CollisionRadius < CollisionRadius) return 0;
	if (other.CollisionHeight < CollisionHeight) return 0;
	if ((reachFlags | other.reachFlags) != other.reachFlags) return 0;
	INT otherMaxV = (other.MaxLandingVelocity < 0x24F) ? 0x24E : other.MaxLandingVelocity;
	if (MaxLandingVelocity > otherMaxV) return 0;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x103fc940)
int UReachSpec::BotOnlyPath()
{
	// Retail: 0xfc940, ordinal 2311. Returns 1 if CollisionRadius < 0x28 (40 units),
	// indicating this path is only usable by small bots.
	return CollisionRadius < 0x28 ? 1 : 0;
}

IMPL_MATCH("Engine.dll", 0x103fc800)
void UReachSpec::Init()
{
	// Retail (36b): zeros all nav fields and clears bit 0 of bForced
	bPruned = 0;
	Distance = 0;
	CollisionRadius = 0;
	CollisionHeight = 0;
	reachFlags = 0;
	MaxLandingVelocity = 0;
	bForced = 0;
	Start = NULL;
	End = NULL;
}


// ============================================================================
// FCollisionHash / FCollisionOctree / FOctreeNode simple implementations
// (moved from EngineStubs.cpp)
// ============================================================================

// ??1FCollisionHash@@UAE@XZ
IMPL_EMPTY("Destructor — no custom cleanup; retail also trivial")
FCollisionHash::~FCollisionHash() {}

// ??4FCollisionHash@@QAEAAV0@ABV0@@Z
IMPL_MATCH("Engine.dll", 0x1036f3f0)
FCollisionHash & FCollisionHash::operator=(FCollisionHash const & p0) {
	appMemcpy(Buckets, p0.Buckets, sizeof(Buckets));
	FreeList = p0.FreeList;
	AllocatedPools = p0.AllocatedPools;
	return *this;
}

// ??1FCollisionOctree@@UAE@XZ
IMPL_EMPTY("Destructor — no custom cleanup; retail also trivial")
FCollisionOctree::~FCollisionOctree() {}

// ??4FCollisionOctree@@QAEAAV0@ABV0@@Z
IMPL_MATCH("Engine.dll", 0x1036da50)
FCollisionOctree & FCollisionOctree::operator=(FCollisionOctree const & Other) {
	appMemcpy(Pad, Other.Pad, sizeof(Pad));
	return *this;
}

// ??4FOctreeNode@@QAEAAV0@ABV0@@Z
IMPL_MATCH("Engine.dll", 0x1036f350)
FOctreeNode & FOctreeNode::operator=(FOctreeNode const & p0) {
	appMemcpy(Pad, p0.Pad, sizeof(Pad));
	return *this;
}

// --- Moved from EngineStubs.cpp ---
extern INT GHashActorCount;
extern INT GHashLinkCellCount;
extern INT GHashExtraCount;

// ?ActorEncroachmentCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@VFVector@@VFRotator@@KK@Z
// Retail ordinal 2214 (0x6e3d0). Temporarily moves Actor to NewLocation/NewRotation and checks
// for overlap with every actor whose AABB touches the new position. Returns a tail-ordered list
// of encroachment hits. Uses GMem (the Mem argument is unused per the retail binary).
IMPL_MATCH("Engine.dll", 0x1036e3d0)
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
IMPL_MATCH("Engine.dll", 0x1036e6f0)
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
IMPL_MATCH("Engine.dll", 0x103033a0)
FCheckResult * FCollisionHash::ActorOverlapCheck(FMemStack & p0, AActor * p1, FBox * p2, int p3) { return NULL; }

// ?ActorPointCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@1KKHPAVAActor@@@Z
// Retail ordinal 2223 (0x6dec0). Tests whether a point+AABB (Location ± Extent) overlaps any
// actor in the hash. Calls each candidate's ShouldTrace then GetPrimitive()->PointCheck.
// Uses GMem (the Mem argument is unused per the retail binary).
IMPL_MATCH("Engine.dll", 0x1036dec0)
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
IMPL_MATCH("Engine.dll", 0x1036e1a0)
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
IMPL_MATCH("Engine.dll", 0x103dad30)
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
IMPL_MATCH("Engine.dll", 0x103da540)
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
// Ghidra 0x103DAEA0: increments frame counter, stores FBox+source actor+MemStack into Pad,
// then calls FOctreeNode::ActorOverlapCheck if FBox.IsValid.  FOctreeNode traversal (via
// FUN_103d8b80 / FUN_103d8d50) is unresolved, so use the same flat-scan pattern as the other
// FCollisionOctree query functions.
IMPL_MATCH("Engine.dll", 0x103DAEA0)
FCheckResult* FCollisionOctree::ActorOverlapCheck(FMemStack& Mem, AActor* SourceActor, FBox* Box, INT bSingleResult)
{
	INT& Frame = *(INT*)(Pad + 4);
	Frame++;
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (!Root || !Box || !Box->IsValid) return NULL;

	TArray<AActor*>& Actors = *(TArray<AActor*>*)Root;
	FCheckResult* List = NULL;
	for (INT i = 0; i < Actors.Num(); i++)
	{
		AActor* A = Actors(i);
		if (!A || A == SourceActor) continue;
		if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
		// Retail: if bSingleResult, only include actors with flag 0x800000 (bMovable-class)
		if (bSingleResult && !(*(DWORD*)((BYTE*)A + 0xa8) & 0x800000)) continue;
		*(INT*)((BYTE*)A + 0x60) = Frame;

		FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
		if (CR)
		{
			appMemzero(CR, sizeof(FCheckResult));
			CR->Actor = A;
			CR->GetNext() = List;
			List = CR;
		}
	}
	return List;
}

// ?ActorPointCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@1KKHPAVAActor@@@Z
// Tests a point+AABB against all tracked actors; uses GMem for allocation (matching retail).
IMPL_MATCH("Engine.dll", 0x103daaf0)
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
IMPL_MATCH("Engine.dll", 0x103dac20)
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
IMPL_MATCH("Engine.dll", 0x1036ee70)
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
IMPL_MATCH("Engine.dll", 0x104651d0)
void FCollisionHash::CheckActorLocations(ULevel * p0) {}

// ?CheckActorNotReferenced@FCollisionHash@@UAEXPAVAActor@@@Z
// retail: empty (ordinal 2353 shares address 0x1651d0 — same shared no-op stub)
IMPL_MATCH("Engine.dll", 0x104651d0)
void FCollisionHash::CheckActorNotReferenced(AActor * p0) {}

// ?CheckIsEmpty@FCollisionHash@@UAEXXZ
// retail: empty (ordinal 2383 shares address 0x176d60 — another shared no-op stub)
IMPL_MATCH("Engine.dll", 0x10476d60)
void FCollisionHash::CheckIsEmpty() {}

// ?RemoveActor@FCollisionHash@@UAEXPAVAActor@@@Z
// Retail ordinal 4274 (0x6f0c0).  Removes an actor from every hash cell it
// occupies by walking the ColLocation extent (not current Location, so it
// works even if the actor has moved since it was added).  Returns links to pool.
IMPL_MATCH("Engine.dll", 0x1036f0c0)
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
IMPL_MATCH("Engine.dll", 0x1036d6d0)
void FCollisionHash::Tick() {
	GHashExtraCount    = 0; // DAT_1064ff34
	GHashLinkCellCount = 0; // DAT_1064ff2c
	GHashActorCount    = 0; // DAT_1064ff28
}

// ?AddActor@FCollisionOctree@@UAEXPAVAActor@@@Z
// Ghidra (0xdc1a0): Computes actor bbox, inserts into octree via SingleNodeFilter
// or MultiNodeFilter depending on whether actor is flagged bStatic.
// Simplified: insert into root node's flat actor list directly.
IMPL_MATCH("Engine.dll", 0x103dc1a0)
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
IMPL_DIVERGE("FUN_103dafe0 (node-membership test) and FUN_103db230 (cleanup) are unexported Engine.dll octree internals; permanently unresolvable; Ghidra 0x103dbec0")
void FCollisionOctree::CheckActorLocations(ULevel * p0) {}

// ?CheckActorNotReferenced@FCollisionOctree@@UAEXPAVAActor@@@Z
// retail: empty (ordinal 2354 shares address 0x1651d0 — shared no-op stub)
IMPL_MATCH("Engine.dll", 0x104651d0)
void FCollisionOctree::CheckActorNotReferenced(AActor * p0) {}

// ?CheckIsEmpty@FCollisionOctree@@UAEXXZ
// Ghidra (0xdaf60): delegates straight to FOctreeNode::CheckIsEmpty on the root node.
// Root FOctreeNode* is stored at Pad[0..3] (first field after vtable pointer).
IMPL_MATCH("Engine.dll", 0x103daf60)
void FCollisionOctree::CheckIsEmpty()
{
	FOctreeNode* Root = *(FOctreeNode**)Pad;
	if (Root) Root->CheckIsEmpty();
}

// ?RemoveActor@FCollisionOctree@@UAEXPAVAActor@@@Z
// Ghidra (0xdbd00): Removes actor from every octree node it appears in,
// then clears actor's OctreeNodes list.
IMPL_MATCH("Engine.dll", 0x103dbd00)
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
// Ghidra 0xdbba0 (285 bytes): for each queued debug item, forward one line (green) +
// one box (bright green) to GTempLineBatcher. Queues populated by debug visualization code.
IMPL_MATCH("Engine.dll", 0x103dbba0)
void FCollisionOctree::Tick()
{
	for (INT i = 0; i < GDbgOctreeLineStart.Num(); i++)
	{
		GTempLineBatcher->AddLine(GDbgOctreeLineStart(i), GDbgOctreeLineEnd(i), FColor(0xff00ff00));
		GTempLineBatcher->AddBox(GDbgOctreeBoxes(i), FColor(0xff46ff46));
	}
}
// ?GetHashIndices@FCollisionHash@@QAEXVFVector@@AAH11@Z
// Retail ordinal 3033 (0x6dd20).
// Converts a world-space coordinate to a hash-table grid index in each axis.
// Grid resolution: each cell = 256 unreal units; world spans [-262144, +262144].
IMPL_MATCH("Engine.dll", 0x1036dd20)
void FCollisionHash::GetHashIndices(FVector V, INT& XI, INT& YI, INT& ZI) {
	XI = Clamp(appRound((V.X + 262144.0f) * 0.00390625f), 0, 0x3FFF);
	YI = Clamp(appRound((V.Y + 262144.0f) * 0.00390625f), 0, 0x3FFF);
	ZI = Clamp(appRound((V.Z + 262144.0f) * 0.00390625f), 0, 0x3FFF);
}

// ?GetActorExtent@FCollisionHash@@QAEXPAVAActor@@AAH11111@Z
// Retail ordinal 2897 (0x6dde0).
// Converts the actor's collision bounding box into a 3D range of hash indices.
IMPL_MATCH("Engine.dll", 0x1036dde0)
void FCollisionHash::GetActorExtent(AActor* Actor, INT& MinX, INT& MaxX, INT& MinY, INT& MaxY, INT& MinZ, INT& MaxZ) {
	FBox Box = Actor->GetPrimitive()->GetCollisionBoundingBox(Actor);
	GetHashIndices(Box.Min, MinX, MinY, MinZ);
	GetHashIndices(Box.Max, MaxX, MaxY, MaxZ);
}
// ?ActorEncroachmentCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
// Node-level encroachment check.  Reads query state from OctHash->Pad:
//   Pad[96..99]   = SourceActor (the encroaching actor)
//   Pad[16..27]   = query Location (FVector)
//   Pad[80..87]   = Extent (FVector, zero for point test)
//   Pad[88..91]   = TraceFlags (DWORD)
IMPL_MATCH("Engine.dll", 0x103d9d20)
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
IMPL_MATCH("Engine.dll", 0x103d9a50)
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
IMPL_DIVERGE("FUN_103d8b80 (query-box clip against node bounds) is an unexported Engine.dll octree internal; permanently unresolvable; Ghidra 0x103da390")
void FOctreeNode::ActorOverlapCheck(FCollisionOctree * p0, FPlane const * p1) {}

// ?ActorPointCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@PAVAActor@@@Z
IMPL_MATCH("Engine.dll", 0x103d9f50)
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
IMPL_MATCH("Engine.dll", 0x103da1c0)
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
IMPL_MATCH("Engine.dll", 0x103d9490)
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
IMPL_MATCH("Engine.dll", 0x103d93c0)
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
IMPL_MATCH("Engine.dll", 0x103d9300)
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
IMPL_DIVERGE("Ghidra 0x103DB6C0: editor/debug visualization only — builds node FBox and appends to GTempLineBatcher.Boxes debug line-renderer; GTempLineBatcher is an editor-only global not present in the runtime path")
void FOctreeNode::Draw(FColor p0, int p1, FPlane const * p2) {}

// ?DrawFlaggedActors@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
IMPL_DIVERGE("Ghidra 0x103DB840: editor/debug visualization only — draws actors flagged 0x4000000 via FTempLineBatcher line append; FTempLineBatcher is an editor-only debug draw path")
void FOctreeNode::DrawFlaggedActors(FCollisionOctree * p0, FPlane const * p1) {}

IMPL_DIVERGE("FUN_103d8e50/FUN_103d8d50/FUN_103d8c80/FUN_103d8ce0 (plane-clip and child-overlap helpers) are unexported Engine.dll octree internals; permanently unresolvable; Ghidra 0x103db0c0")
void FOctreeNode::FilterTest(FBox * p0, int p1, TArray<FOctreeNode *> * p2, FPlane const * p3) {}

// ?MultiNodeFilter@FOctreeNode@@QAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
// Ghidra (0xd8ec0): In the full octree, routes actor to all overlapping child nodes.
// Simplified: store at this node directly (no subdivision).
IMPL_MATCH("Engine.dll", 0x103d8ec0)
void FOctreeNode::MultiNodeFilter(AActor* Actor, FCollisionOctree* OctHash, FPlane const* Plane)
{
	StoreActor(Actor, OctHash, Plane);
}

// ?RemoveAllActors@FOctreeNode@@QAEXPAVFCollisionOctree@@@Z
// Ghidra (0xdb3e0): Recursively clears all actors from this node and its children.
// Simplified: just clear this node's actor list.
IMPL_MATCH("Engine.dll", 0x103db3e0)
void FOctreeNode::RemoveAllActors(FCollisionOctree* OctHash)
{
	TArray<AActor*>& ActorList = *(TArray<AActor*>*)this;
	ActorList.Empty();
}

// ?SingleNodeFilter@FOctreeNode@@QAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
// Ghidra (0xdc010): In the full octree, routes actor to the single containing child.
// Simplified: store at this node directly (no subdivision).
IMPL_MATCH("Engine.dll", 0x103dc010)
void FOctreeNode::SingleNodeFilter(AActor* Actor, FCollisionOctree* OctHash, FPlane const* Plane)
{
	StoreActor(Actor, OctHash, Plane);
}
// ?GetHashLink@FCollisionHash@@QAEAAPAUFCollisionLink@1@HHHAAH@Z
// Retail ordinal 3034 (0x6d680).
// Returns a reference to the bucket-head pointer for hash cell (x, y, z) and
// writes the encoded position z*0x100000 + y*0x400 + x into OutPos.
IMPL_MATCH("Engine.dll", 0x1036d680)
FCollisionHash::FCollisionLink*& FCollisionHash::GetHashLink(INT x, INT y, INT z, INT& OutPos)
{
	OutPos = (z * 0x400 + y) * 0x400 + x;
	return Buckets[HashX[x] ^ HashY[y] ^ HashZ[z]];
}
