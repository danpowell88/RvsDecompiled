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
int UReachSpec::findBestReachable(AScout *)
{
	return 0;
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

int UReachSpec::defineFor(ANavigationPoint *,ANavigationPoint *,APawn *)
{
	return 0;
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

int UReachSpec::PlaceScout(AScout *)
{
	return 0;
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

