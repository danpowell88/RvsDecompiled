/*=============================================================================
	UnActCol.cpp: Actor collision and reach specs (UReachSpec)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- FReachSpec ---
FReachSpec& FReachSpec::operator=(const FReachSpec& Other)
{
	appMemcpy(this, &Other, 44); // 11 dwords, shared with FStaticMeshCollisionNode
	return *this;
}


// --- UReachSpec ---
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

int UReachSpec::BotOnlyPath()
{
	// Retail: 0xfc940, ordinal 2311. Returns 1 if CollisionRadius < 0x28 (40 units),
	// indicating this path is only usable by small bots.
	return CollisionRadius < 0x28 ? 1 : 0;
}

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
FCollisionHash::~FCollisionHash() {}

// ??4FCollisionHash@@QAEAAV0@ABV0@@Z
FCollisionHash & FCollisionHash::operator=(FCollisionHash const & p0) {
	appMemcpy(Buckets, p0.Buckets, sizeof(Buckets));
	FreeList = p0.FreeList;
	AllocatedPools = p0.AllocatedPools;
	return *this;
}

// ??1FCollisionOctree@@UAE@XZ
FCollisionOctree::~FCollisionOctree() {}

// ??4FCollisionOctree@@QAEAAV0@ABV0@@Z
FCollisionOctree & FCollisionOctree::operator=(FCollisionOctree const & Other) {
	appMemcpy(Pad, Other.Pad, sizeof(Pad));
	return *this;
}

// ??4FOctreeNode@@QAEAAV0@ABV0@@Z
FOctreeNode & FOctreeNode::operator=(FOctreeNode const & p0) {
	appMemcpy(Pad, p0.Pad, sizeof(Pad));
	return *this;
}
