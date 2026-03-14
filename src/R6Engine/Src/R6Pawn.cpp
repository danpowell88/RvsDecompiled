/*=============================================================================
	R6Pawn.cpp
	AR6Pawn — R6 pawn base class: movement, peeking, aiming, lip synch,
	collision, animation state, heartbeat sensor, ragdoll spawning.
=============================================================================*/

#include "R6EnginePrivate.h"
#include <math.h>

// External engine globals used by viewport-toggle exec functions
extern ENGINE_API UEngine* g_pEngine;

// Saved viewport overlay states for heat/night/scope toggles (GHIDRA: DAT_10074548/4c/50)
static INT GR6Pawn_SavedHeatViewport  = 0;
static INT GR6Pawn_SavedNightViewport = 0;
static INT GR6Pawn_SavedScopeViewport = 0;

IMPLEMENT_CLASS(AR6Pawn)

IMPLEMENT_FUNCTION(AR6Pawn, -1, execAdjustFluidCollisionCylinder)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execCheckCylinderTranslation)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execFootStep)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetKillResult)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetMaxRotationOffset)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetMovementDirection)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetPeekingRatioNorm)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetRotationOffset)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetStunResult)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetThroughResult)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execMoveHitBone)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPawnCanBeHurtFrom)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPawnLook)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPawnLookAbsolute)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPawnLookAt)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPawnTrackActor)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPlayVoices)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execR6GetViewRotation)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execSendPlaySound)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execSetAudioInfo)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execSetPawnScale)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execStartLipSynch)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execStopLipSynch)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execToggleHeatProperties)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execToggleNightProperties)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execToggleScopeProperties)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execUpdatePawnTrackActor)

// Statics used by PreNetReceive/PostNetReceive to detect replicated changes.
static BYTE  GR6Pawn_OldNetActionIndex;
static AR6SoundReplicationInfo* GR6Pawn_OldSoundRepInfo;

// --- AR6Pawn ---

IMPL_MATCH("R6Engine.dll", 0x10025ad0)
INT AR6Pawn::AdjustFluidCollisionCylinder(FLOAT Blend, INT bTest)
{
	if (m_bIsProne)
		return 1;

	// Read default heights from the class default object.
	APawn* Default = (APawn*)GetClass()->GetDefaultObject();
	FLOAT DefHeight  = Default->CollisionHeight;
	FLOAT DefRadius  = Default->CollisionRadius;
	FLOAT DefCrouchH = Default->CrouchHeight;

	// Lerp toward crouch height based on blend.
	FLOAT TargetH = DefHeight - (DefHeight - DefCrouchH) * Blend;
	if (TargetH == CollisionHeight)
		return 1;

	FLOAT SavedPrePivotZ = PrePivot.Z;
	FLOAT DeltaH  = TargetH - CollisionHeight;  // > 0 = growing
	FLOAT Headroom = DefHeight - TargetH;

	INT bCanGrow = 1;
	if (DeltaH > 0.0f)
	{
		// Check upward for room to grow.
		// DIVERGENCE: XLevel vtable slot 0xCC/4 — unlisted ULevel sweep/check method;
		// called via __fastcall to emulate __thiscall (ECX = XLevel).
		FCheckResult Hit(1.0f);
		FLOAT EndX = Location.X, EndY = Location.Y, EndZ = Location.Z + DeltaH;
		typedef INT (__fastcall *FSweepFn)(void*, void*, FCheckResult*, AActor*, FLOAT*, FLOAT*, INT, FLOAT, FLOAT, FLOAT);
		FSweepFn Sweep = *(FSweepFn*)((BYTE*)*(DWORD*)XLevel + 0xCC);
		Sweep(XLevel, 0, &Hit, this, &EndX, &Location.X, 0x286, CollisionRadius, CollisionRadius, CollisionHeight);
		if (Hit.Time != 1.0f)
			bCanGrow = 0;
	}

	if (bTest == 0)
	{
		if (!bCanGrow)
		{
			m_fCrouchBlendRate = ComputeCrouchBlendRate(DefHeight, DefCrouchH);
			if (Controller && Controller->IsA(AR6PlayerController::StaticClass()))
				((AR6Pawn*)Controller)->eventSetCrouchBlend(m_fCrouchBlendRate);
			return 0;
		}
	}
	else if (!bCanGrow)
	{
		return 0;
	}

	FLOAT OldHeight = CollisionHeight;
	SetCollisionSize(DefRadius, TargetH);
	SetPrePivot(FVector(0.0f, 0.0f, Headroom + m_fPrePivotPawnInitialOffset));

	// DIVERGENCE: XLevel vtable slot 0x9C/4 — unlisted ULevel move-actor method;
	// moves pawn to Location + (0, 0, DeltaH); called via __fastcall to emulate __thiscall.
	typedef INT (__fastcall *FMoveFn)(void*, void*, AActor*, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT);
	FMoveFn Move = *(FMoveFn*)((BYTE*)*(DWORD*)XLevel + 0x9C);
	INT MoveResult = Move(XLevel, 0, this, Location.X, Location.Y, Location.Z + DeltaH, 1, 0, 0, 0);

	if (MoveResult != 0 && bTest == 0)
		return MoveResult;

	SetCollisionSize(CollisionRadius, OldHeight);
	SetPrePivot(FVector(0.0f, 0.0f, SavedPrePivotZ));
	return MoveResult;
}

IMPL_MATCH("R6Engine.dll", 0x1002a150)
FLOAT AR6Pawn::AdjustMaxFluidPeeking(FLOAT InPeeking, FLOAT InLimit)
{
	if (m_bPeekingLeft)
	{
		if (InPeeking >= InLimit)
			return InPeeking;
	}
	else
	{
		if (InPeeking < InLimit)
			return InPeeking;
	}
	return InLimit;
}

IMPL_MATCH("R6Engine.dll", 0x100294f0)
void AR6Pawn::BeginTouch(AActor* Other)
{
	// If touching a door, only process if genuinely overlapping
	if (Other->IsA(AR6Door::StaticClass()))
	{
		if (!IsOverlapping(Other, NULL))
			return;
	}
	AActor::BeginTouch(Other);
}

IMPL_MATCH("R6Engine.dll", 0x100278a0)
FVector AR6Pawn::CheckForLedges(AActor *, FVector, FVector, FVector, INT &, INT &, FLOAT)
{
	return FVector(0,0,0);
}

IMPL_DIVERGE("0x1002cf40: else-branch uses FUN_100015d0 to initialize 4 test positions for multi-point sight check; FUN_100015d0 is an N-times FVector initializer")
INT AR6Pawn::CheckLineOfSight(AActor* param_1, FVector& param_2, INT param_3,
	AActor* param_4, FVector& param_5, AActor* param_6, FVector& param_7)
{
	guard(AR6Pawn::CheckLineOfSight);
	FCheckResult Hit(1.0f);
	FVector local_vec(0.f, 0.f, 0.f);

	// this+0x4ec = Controller; controller+0x400 = Enemy
	INT* pCtrl = *(INT**)((BYTE*)this + 0x4ec);
	AActor* pEnemy = (pCtrl != NULL) ? (AActor*)*(INT*)((BYTE*)pCtrl + 0x400) : NULL;

	// this+0x328 = XLevel; vtable[0xcc/4] = SingleLineCheck
	INT* pXLevel = *(INT**)((BYTE*)this + 0x328);
	typedef void (__fastcall *FSingleLineFn)(void*, void*, FCheckResult*, AActor*,
		const FVector*, const FVector*, DWORD, const FVector&, const FVector&, const FVector&);
	FSingleLineFn SingleLineCheck = *(FSingleLineFn*)((BYTE*)*pXLevel + 0xcc);

	if (param_4 == pEnemy)
	{
		// param_4 is the current enemy — try head-level sight first
		FVector puVar3 = GetHeadLocation(param_1);
		param_7 = puVar3;
		SingleLineCheck(pXLevel, 0, &Hit, this, &param_7, &param_2, 0x20286,
			FVector(0.f, 0.f, 0.f), FVector(0.f, 0.f, 0.f), FVector(0.f, 0.f, 0.f));
		if (Hit.Actor != NULL)
		{
			if ((Hit.Actor != param_4) || (Hit.Actor != param_6))
			{
				// Try mid-section
				puVar3 = GetMidSectionLocation(param_1);
				param_7 = puVar3;
				Hit = FCheckResult(1.0f);
				SingleLineCheck(pXLevel, 0, &Hit, this, &param_7, &param_2, 0x20286,
					FVector(0.f, 0.f, 0.f), FVector(0.f, 0.f, 0.f), FVector(0.f, 0.f, 0.f));
			}
			if (Hit.Actor != NULL && Hit.Actor != param_4 && Hit.Actor != param_6)
				return 0;
		}
	}
	else
	{
		// param_4 is not the current enemy — try mid-section
		FVector puVar3 = GetMidSectionLocation(param_1);
		param_7 = puVar3;
		SingleLineCheck(pXLevel, 0, &Hit, this, &param_7, &param_2, 0x20286,
			FVector(0.f, 0.f, 0.f), FVector(0.f, 0.f, 0.f), FVector(0.f, 0.f, 0.f));
		if (Hit.Actor != NULL && Hit.Actor != param_4 && Hit.Actor != param_6)
		{
			// DIVERGENCE: distance/size checks and 4-point probe grid from param_5 unresolved.
			// Retail checks dist_sq(param_5, param_1->Location) <= 6.4e7f then does multi-probe.
			return 0;
		}
	}
	return 1;
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10021e60)
DWORD AR6Pawn::CheckSeePawn(AR6Pawn* param_1, FVector& param_2, INT param_3)
{
	guard(AR6Pawn::CheckSeePawn);

	// this+0x4fc = sensor/gadget range object; this+0x6c4 flags (0x800 = extended range)
	INT pSensor = *(INT*)((BYTE*)this + 0x4fc);

	FLOAT distSq = (param_2.X - Location.X) * (param_2.X - Location.X)
	             + (param_2.Y - Location.Y) * (param_2.Y - Location.Y)
	             + (param_2.Z - Location.Z) * (param_2.Z - Location.Z);

	// Distance gating: tier depends on sensor range and extended-range flag
	if (pSensor != 0)
	{
		if (*(FLOAT*)((BYTE*)pSensor + 0x3a8) >= 10.0f)
		{
			if (distSq > 1.12896e+09f) return 0;
			goto LAB_sight;
		}
		if ((*(DWORD*)((BYTE*)this + 0x6c4) & 0x800) && *(FLOAT*)((BYTE*)pSensor + 0x3a8) >= 2.5f)
		{
			if (distSq > 5.0176e+08f) return 0;
			goto LAB_sight;
		}
	}
	if (distSq > 1.2544e+08f) return 0;

LAB_sight:
	// Direction to target (safe-normalized)
	FVector dir(param_2.X - Location.X, param_2.Y - Location.Y, param_2.Z - Location.Z);
	dir = dir.SafeNormal();

	// View forward vector from GetViewRotation
	FRotator viewRot = GetViewRotation();
	FVector forward = viewRot.Vector();

	// Dot product against peripheral vision threshold; cache in Controller+0x3b8
	AController* pCtrl = Controller;
	FLOAT sightDot = (forward | dir) - *(FLOAT*)((BYTE*)this + 0x404);
	if (pCtrl)
		*(FLOAT*)((BYTE*)pCtrl + 0x3b8) = sightDot;

	if (sightDot >= 0.0f)
	{
		// Extended-range secondary check for 0x800 flag: widen horizontal angle
		if ((*(DWORD*)((BYTE*)this + 0x6c4) & 0x800) != 0)
		{
			FVector dir2(dir.X + dir.X, dir.Y, dir.Z);
			dir2.Normalize();
			FLOAT sightDot2 = (forward | dir2) - *(FLOAT*)((BYTE*)this + 0x404);
			if (pCtrl)
				*(FLOAT*)((BYTE*)pCtrl + 0x3b8) = sightDot2;
			if (sightDot2 < 0.0f) return 0;
		}

		// Base FOV scale: SightDistanceFactor * 0.5 + 0.75
		FLOAT fov = *(FLOAT*)((BYTE*)this + 0x6e8) * 0.5f + 0.75f;

		// Observer stance/velocity: reduce fov if moving and not prone
		// 0x39e = m_bIsProne, 0x258..0x260 = Velocity, 0x3e0 bit2 = crouched
		if (*(BYTE*)((BYTE*)this + 0x39e) != 1)
		{
			if (*(FLOAT*)((BYTE*)this + 0x258) != 0.0f
				|| *(FLOAT*)((BYTE*)this + 0x25c) != 0.0f
				|| *(FLOAT*)((BYTE*)this + 0x260) != 0.0f)
			{
				fov *= (*(BYTE*)((BYTE*)this + 0x3e0) & 4) ? 0.8f : 0.6f;
			}
		}

		// Target stance/velocity: increase fov if target is moving and not prone
		if (*(BYTE*)((BYTE*)param_1 + 0x39e) != 1)
		{
			if (*(FLOAT*)((BYTE*)param_1 + 0x258) != 0.0f
				|| *(FLOAT*)((BYTE*)param_1 + 0x25c) != 0.0f
				|| *(FLOAT*)((BYTE*)param_1 + 0x260) != 0.0f)
			{
				fov *= (*(BYTE*)((BYTE*)param_1 + 0x3e0) & 4) ? 1.2f : 1.4f;
			}
		}

		// DrawScale multiplier: byte at param_1+0x395 scaled to [0..1] range (1/128)
		fov *= (FLOAT)*(BYTE*)((BYTE*)param_1 + 0x395) * 0.0078125f;

		// Lighting adjustment: param_1+0x114 = ambient light level [0..1]
		{
			FLOAT light = *(FLOAT*)((BYTE*)param_1 + 0x114);
			if (light >= 0.3f)
			{
				if (light < 0.7f)
					fov *= 0.75f;
				// else >= 0.7: full fov (no change)
			}
			else
			{
				fov *= 0.5f;  // dark: harder to spot
			}
		}

		// Final range check: distSq <= (fov * SightRadius)^2
		FLOAT range = fov * *(FLOAT*)((BYTE*)this + 0x400);
		if (distSq <= range * range)
		{
			if (!pCtrl) return 0;
			return pCtrl->LineOfSightTo(param_1, 1);
		}
	}
	return 0;
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10025a80)
FLOAT AR6Pawn::ComputeCrouchBlendRate(FLOAT TargetHeight, FLOAT OtherHeight)
{
	FLOAT Result = Abs((CollisionHeight - TargetHeight) / (TargetHeight - OtherHeight));
	if (Result < 0.0f)
		return 0.0f;
	if (Result > 1.0f)
		Result = 1.0f;
	return Result;
}

IMPL_MATCH("R6Engine.dll", 0x100246a0)
void AR6Pawn::Crawl(INT)
{
	guard(AR6Pawn::Crawl);

	// Already at crawl size: nothing to do
	if (CollisionHeight == CrouchHeight && CollisionRadius == CrouchRadius)
		return;

	AR6ColBox* ColBox = m_collisionBox;
	if (!ColBox)
		return;

	// DIVERGENCE: offset 0x140 in APawn is an unlisted attachment/owner field used to verify
	// the colbox is properly attached to its pawn before entering crawl mode.
	if (*(INT*)((BYTE*)m_collisionBox + 0x140) == 0)
		return;

	// Get colbox world location at crawl radius
	FVector ColBoxLoc;
	ColBox->GetColBoxLocationFromOwner(ColBoxLoc, CrouchRadius + CrouchRadius);

	// Adjust Z down by the standing-to-crawl height delta
	ColBoxLoc.Z -= (CollisionHeight - CrouchHeight);

	// Query maximum step clearance for the crawl colbox
	FLOAT MaxStepUp = ColBox->GetMaxStepUp(true, 0.0f);

	// Target Z centre of pawn in crawl stance
	FLOAT CrawlCentreZ = ColBoxLoc.Z + MaxStepUp + CrouchHeight;

	FLOAT SaveRadius = CollisionRadius;
	FLOAT SaveHeight = CollisionHeight;
	SetCollisionSize(CrouchRadius, CrouchHeight);

	// DIVERGENCE: XLevel vtable 0xCC = sweep/check — tests if pawn can fit at crawl destination.
	FCheckResult Hit(1.0f);
	FVector CrawlDest(Location.X, Location.Y, CrawlCentreZ);
	typedef INT (__fastcall *FSweepFn)(void*, void*, FCheckResult*, AActor*, FLOAT*, FLOAT*, INT, FLOAT, FLOAT, FLOAT);
	FSweepFn Sweep = *(FSweepFn*)((BYTE*)*(DWORD*)XLevel + 0xCC);
	Sweep(XLevel, 0, &Hit, this, &CrawlDest.X, &Location.X, 0x286, CrouchRadius, CrouchRadius, CrouchHeight);

	if (Hit.Time != 1.0f)
	{
		// Cannot fit at crawl location: revert collision size
		SetCollisionSize(SaveRadius, SaveHeight);
		return;
	}

	// Move pawn to crawl position
	typedef INT (__fastcall *FMoveFn)(void*, void*, AActor*, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT);
	FMoveFn Move = *(FMoveFn*)((BYTE*)*(DWORD*)XLevel + 0x9C);
	INT MoveResult = Move(XLevel, 0, this, CrawlDest.X, CrawlDest.Y, CrawlDest.Z, 1, 0, 0, 0);

	if (!MoveResult)
	{
		// Failed to move: revert and bail
		SetCollisionSize(SaveRadius, SaveHeight);
		initCrawlMode(false);
		return;
	}

	// Entered crawl successfully
	initCrawlMode(true);

	// Enable second collision box for crawl geometry
	if (m_collisionBox2)
		m_collisionBox2->EnableCollision(1, 0, 0);

	// DIVERGENCE: AR6ColBox::CanStepUp and AreAttached checks from Ghidra omitted;
	// these methods are not declared in the project header.

	// Set pre-pivot for crawl stance and fire script event
	APawn* DefObj = (APawn*)GetClass()->GetDefaultObject();
	SetPrePivot(FVector(0.0f, 0.0f, DefObj->CrouchHeight));
	eventStartCrawl();

	// Store current rotation to saved-rotation fields (Ghidra: this+0xa1c/a20/a24)
	*(DWORD*)((BYTE*)this + 0xa1c) = *(DWORD*)((BYTE*)this + 0x2c8);
	*(DWORD*)((BYTE*)this + 0xa20) = *(DWORD*)((BYTE*)this + 0x2cc);
	*(DWORD*)((BYTE*)this + 0xa24) = *(DWORD*)((BYTE*)this + 0x2d0);

	// Nudge pawn to settle into final crawl position (zero-velocity smear move)
	// DIVERGENCE: XLevel vtable 0x98 = moveSmear/slide actor
	typedef INT (__fastcall *FSmearFn)(void*, void*, AActor*, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT);
	FSmearFn Smear = *(FSmearFn*)((BYTE*)*(DWORD*)XLevel + 0x98);
	Smear(XLevel, 0, this, Location.X, Location.Y, Location.Z, 1, 0, 0, 0);

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10021c10)
INT AR6Pawn::DirectionHasChanged(FLOAT ForwardDot)
{
	FVector NormVel = Velocity;
	NormVel.Normalize();
	FVector Fwd = Rotation.Vector();
	FVector Cross = NormVel ^ Fwd;

	BYTE NewDir;
	if (ForwardDot <= 0.0f)
	{
		NewDir = 3;
		if (Cross.Z >= 0.0f)
			NewDir = 4;
	}
	else if (Cross.Z >= 0.0f)
	{
		NewDir = 2;
	}
	else
	{
		NewDir = 1;
	}

	if (NewDir == m_eStrafeDirection)
		return 0;
	m_eStrafeDirection = NewDir;
	return 1;
}

IMPL_MATCH("R6Engine.dll", 0x100242b0)
BYTE AR6Pawn::GetAnimState()
{
	// Dead or incapacitated
	if (m_eHealth > 1)
		return 14;

	// Posture change (crouching/standing transition)
	if (m_bSoundChangePosture)
		return (m_bWantsToProne ? 0 : 1) | 4; // 4 = going prone, 5 = standing

	// Landing
	if (m_bIsLanding)
		return 13;

	// Stationary (no velocity)
	if (Velocity.X == 0.0f && Velocity.Y == 0.0f && Velocity.Z == 0.0f)
		return 3;

	// Prone movement
	if (m_bIsProne)
		return (GetMovementDirection() == MOVEDIR_Strafe) + 6; // 6 or 7

	// Climbing stairs
	if (m_bIsClimbingStairs)
		return (Velocity.Y > 0.0f) ? 8 : 9; // ascending / descending

	// Second velocity check (effectively same as above — matches retail binary)
	if (Velocity.X == 0.0f && Velocity.Y == 0.0f && Velocity.Z == 0.0f)
		return 0;

	// Not walking → running
	if (!bIsWalking)
		return 2;

	// Walking while wounded
	if (m_eHealth == 1)
		return (m_bLeftFootDown ? (BYTE)0xFD : (BYTE)0) + (BYTE)0xF; // 12 or 15

	// Normal walking
	return 1;
}

IMPL_MATCH("R6Engine.dll", 0x1002b9a0)
BYTE AR6Pawn::GetCurrentMaterial()
{
	guard(AR6Pawn::GetCurrentMaterial);
	// this+0x520 = m_pSoundVolume zone cache
	INT* pZone = *(INT**)((BYTE*)this + 0x520);
	if (pZone == NULL)
		return 0;

	// Walk ClassPrivate hierarchy (+0x24 = ClassPrivate, +0x2c = SuperClass chain).
	// Looking for AR6SoundVolume (in R6Game.dll — cannot reference directly here).
	// DIVERGENCE: AR6SoundVolume is in R6Game.dll; referencing its StaticClass() from R6Engine
	// would create a circular link dependency. pSVClass left NULL — sound volume check skipped.
	UClass* pSVClass = NULL;

	for (UClass* C = *(UClass**)((BYTE*)pZone + 0x24); C; C = *(UClass**)((BYTE*)C + 0x2c))
	{
		if (C == pSVClass)
		{
			// Walk Outer chain (+0x58) while zone is still a sound volume
		walk_outer:
			pZone = *(INT**)((BYTE*)pZone + 0x58);
			*(INT*)((BYTE*)this + 0x520) = (INT)pZone;
			if (pZone == NULL) goto done;
			for (UClass* C2 = *(UClass**)((BYTE*)pZone + 0x24); C2; C2 = *(UClass**)((BYTE*)C2 + 0x2c))
			{
				if (C2 == pSVClass)
					goto walk_outer;
			}
			goto done;
		}
	}
done:
	pZone = *(INT**)((BYTE*)this + 0x520);
	if (pZone == NULL)
		return 0;
	// zone+0x4c = material byte
	return *(BYTE*)((BYTE*)pZone + 0x4c);
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10021b70)
void AR6Pawn::GetDefaultHeightAndRadius(FLOAT& OutHeight, FLOAT& OutCrouchHeight, FLOAT& OutRadius)
{
	AActor* Default = (AActor*)GetClass()->GetDefaultObject();
	OutHeight = Default->CollisionHeight;
	OutRadius = Default->CollisionRadius;
	OutCrouchHeight = ((APawn*)Default)->CrouchHeight;
}

IMPL_MATCH("R6Engine.dll", 0x10026780)
FVector AR6Pawn::GetFootLocation(AActor *)
{
	return FVector(0,0,0);
}

IMPL_MATCH("R6Engine.dll", 0x1002bbc0)
FVector AR6Pawn::GetHeadLocation(AActor *)
{
	return FVector(0,0,0);
}

IMPL_MATCH("R6Engine.dll", 0x10022bb0)
FLOAT AR6Pawn::GetMaxFluidPeeking(FLOAT SpeedRatio, INT bReverse)
{
	FLOAT Ratio = GetPeekingRatioNorm(1600.0f);
	FLOAT Value = ((1.0f - SpeedRatio) * (1.0f - Ratio) + Ratio) * 1000.0f;
	if (bReverse)
		return 1000.0f - Value;
	return Value + 1000.0f;
}

IMPL_MATCH("R6Engine.dll", 0x10022390)
FVector AR6Pawn::GetMidSectionLocation(AActor *)
{
	return FVector(0,0,0);
}

IMPL_MATCH("R6Engine.dll", 0x10021610)
enum eMovementDirection AR6Pawn::GetMovementDirection()
{
	guard(AR6Pawn::GetMovementDirection);
	// this+0x4ec = Controller
	INT* pCtrl = *(INT**)((BYTE*)this + 0x4ec);

	if (pCtrl != NULL)
	{
		if (((AController*)pCtrl)->IsA(AR6PlayerController::StaticClass()))
		{
			// Player path: transform velocity to local space using pawn's rotation.
			// GMath.UnitCoords is at GMath+0x18 (TODO: verify offset).
			FCoords RotCoords = GMath.UnitCoords / Rotation;
			FVector normVel = Velocity.SafeNormal();

			// normVel is ZeroVector when standing still — skip direction check
			if (normVel.X != 0.0f || normVel.Y != 0.0f || normVel.Z != 0.0f)
			{
				// forward dot: project normalized velocity onto pawn's local X axis
				FLOAT forwardDot = RotCoords.XAxis | normVel;
				if (forwardDot >= 0.25f)
					return MOVEDIR_Forward;
				if (forwardDot < -0.25f)
					return MOVEDIR_Backward;
				return MOVEDIR_Strafe;
			}
		}
		else
		{
			// AI controller path: compare direction to destination vs direction to focus
			// controller+0x3e4 = FocusActor, controller+0x488/0x48c/0x490 = FocalPoint
			INT focusActor = *(INT*)((BYTE*)pCtrl + 0x3e4);
			FLOAT focusX = focusActor ? *(FLOAT*)(focusActor + 0x234) : *(FLOAT*)((BYTE*)pCtrl + 0x488);
			FLOAT focusY = focusActor ? *(FLOAT*)(focusActor + 0x238) : *(FLOAT*)((BYTE*)pCtrl + 0x48c);
			// controller+0x480/0x484 = MoveTarget or destination
			FLOAT destX = *(FLOAT*)((BYTE*)pCtrl + 0x480);
			FLOAT destY = *(FLOAT*)((BYTE*)pCtrl + 0x484);

			FLOAT toDstX = destX - Location.X,  toDstY = destY - Location.Y;
			FLOAT toFocX = focusX - Location.X, toFocY = focusY - Location.Y;
			FLOAT dstLen = appSqrt(toDstX*toDstX + toDstY*toDstY);
			FLOAT focLen = appSqrt(toFocX*toFocX + toFocY*toFocY);
			if (dstLen > 0.0f) { toDstX /= dstLen; toDstY /= dstLen; }
			if (focLen > 0.0f) { toFocX /= focLen; toFocY /= focLen; }

			FLOAT fDot = toDstX*toFocX + toDstY*toFocY;
			if (fDot < 0.75f)
			{
				if (fDot < -0.75f)
					return MOVEDIR_Backward;
				return MOVEDIR_Strafe;
			}
		}
	}
	return MOVEDIR_Forward;
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10022ac0)
FLOAT AR6Pawn::GetPeekingRatioNorm(FLOAT PeekingValue)
{
	return (PeekingValue - 1000.0f) * 0.001f;
}

IMPL_MATCH("R6Engine.dll", 0x10024040)
INT AR6Pawn::GetRotValueCenteredAroundZero(INT Value)
{
	if (Value > 0x8000)
		return Value - 0x10000;
	if (Value < -0x8000)
		Value = Value + 0x10000;
	return Value;
}

IMPL_MATCH("R6Engine.dll", 0x10024130)
FRotator AR6Pawn::GetRotationOffset()
{
	if (m_bIsPlayer)
		return m_rRotationOffset;
	// AI pawns return previous offset (original may add jitter)
	return m_rPrevRotationOffset;
}

IMPL_MATCH("R6Engine.dll", 0x100244e0)
BYTE AR6Pawn::GetSoundGunType(INT InType)
{
	// AZoneInfo bitfield at offset 0x398: bit 4 = m_bInDoor (auto-generated field)
	BYTE ZoneBits = ((BYTE*)Region.Zone)[0x398];
	if (InType != 0)
		return (ZoneBits >> 4) & 1;	// Raw indoor flag: 0=outdoor, 1=indoor
	return ((ZoneBits & 0x10) | 0x20) >> 4;	// Gun sound type: 2=outdoor, 3=indoor
}

IMPL_MATCH("R6Engine.dll", 0x1002cf10)
BYTE AR6Pawn::GetStatusOtherTeam()
{
	if (Controller)
	{
		AR6RainbowAI* RainbowAI = Cast<AR6RainbowAI>(Controller);
		if (RainbowAI)
			return (BYTE)RainbowAI->m_TeamManager->m_iMembersLost;
	}
	return 0;
}

IMPL_MATCH("R6Engine.dll", 0x1002cec0)
BYTE AR6Pawn::GetTeamColor()
{
	if (Controller)
	{
		AR6RainbowAI* RainbowAI = Cast<AR6RainbowAI>(Controller);
		INT TeamName = 0;
		if (RainbowAI)
			TeamName = RainbowAI->m_TeamManager->m_iRainbowTeamName;
		if (TeamName == 0)
			return 2;
		if (TeamName != 1 && TeamName == 2)
			return 1;
	}
	return 0;
}

IMPL_MATCH("R6Engine.dll", 0x1002afc0)
FRotator AR6Pawn::GetViewRotation()
{
	return FRotator(0,0,0);
}

// Ghidra 0x193c0: shared null stub — same address as IsPointInZone overrides above.
// No SEH frame in binary; returns 0 (MSVC requires a return value in non-void functions).
IMPL_EMPTY("Ghidra 0x100193c0: 5-byte stub — shared address with IsPointInZone overrides; confirmed return 0")
INT AR6Pawn::HurtByVolume(AActor *)
{
	return 0;
}

IMPL_MATCH("R6Engine.dll", 0x100215d0)
INT AR6Pawn::IsCrawling()
{
	if (CollisionHeight == m_fProneHeight)
	{
		AActor* Default = (AActor*)GetClass()->GetDefaultObject();
		if (CollisionHeight < Default->CollisionHeight)
			return 1;
	}
	return 0;
}

IMPL_MATCH("R6Engine.dll", 0x100224b0)
INT AR6Pawn::IsOverLedge(AActor* param_1, FVector ledgePoint, FLOAT ledgeRadius)
{
	guard(AR6Pawn::IsOverLedge);
	// param_1 is unused in Ghidra decompilation
	// Save original velocity and a controller float
	FVector savedVelocity = Velocity;
	INT* pCtrl = *(INT**)((BYTE*)this + 0x4ec);
	FLOAT savedCtrlVal = (pCtrl != NULL) ? *(FLOAT*)((BYTE*)pCtrl + 0x3bc) : 0.0f;

	FVector normVel = Velocity.SafeNormal();

	// Gravity direction from XLevel (this+0x328 = XLevel, XLevel+0x458 = ZoneGravityAcceleration)
	INT* pXLevel = *(INT**)((BYTE*)this + 0x328);
	FLOAT gravSign = (*(FLOAT*)((BYTE*)pXLevel + 0x458) > 0.0f) ? 1.0f : -1.0f;

	// vtable[0x190/4 = 100]: unlisted ULevel ledge-check method
	FVector resultLoc(0.f, 0.f, 0.f);
	typedef void (__fastcall *FCheckLedgeFn)(void*, void*, AActor*, FLOAT, FLOAT, FLOAT,
		FLOAT, FLOAT, FLOAT, INT, INT, FLOAT, FLOAT*, FLOAT*, FLOAT);
	FCheckLedgeFn checkFn = *(FCheckLedgeFn*)((BYTE*)*pXLevel + 0x190);
	checkFn(pXLevel, 0, this,
		normVel.X, normVel.Y, normVel.Z,
		ledgePoint.X, ledgePoint.Y, ledgePoint.Z,
		0, 0, gravSign,
		&resultLoc.X, &resultLoc.Y, ledgeRadius);

	INT iVar3 = 0;
	FVector velNorm2 = Velocity.SafeNormal();
	if ((velNorm2.X != 0.0f || velNorm2.Y != 0.0f || velNorm2.Z != 0.0f) &&
		(resultLoc.X != ledgePoint.X || resultLoc.Y != ledgePoint.Y || resultLoc.Z != ledgePoint.Z) &&
		(ledgePoint.X != 0.0f || ledgePoint.Y != 0.0f || ledgePoint.Z != 0.0f))
		iVar3 = 1;

	Velocity = savedVelocity;
	if (pCtrl != NULL)
		*(FLOAT*)((BYTE*)pCtrl + 0x3bc) = savedCtrlVal;
	return iVar3;
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1002ca40)
INT AR6Pawn::IsRelevantToPawnHeartBeat(APawn *)
{
	// TODO: resolve FUN_1001bc10/FUN_1001bc70/FUN_1001bc40 (internal R6 gadget/sensor
	// accessor functions) to implement AR6Pawn::IsRelevantToPawnHeartBeat
	return 0;
}

IMPL_MATCH("R6Engine.dll", 0x1002b410)
INT AR6Pawn::IsRelevantToPawnHeatVision(APawn *)
{
	// TODO: resolve FUN_1001bc10/FUN_1001bc70/FUN_1001bc40 (same gadget/sensor
	// accessor functions) to implement AR6Pawn::IsRelevantToPawnHeatVision
	return 0;
}

IMPL_MATCH("R6Engine.dll", 0x1001bc10)
INT AR6Pawn::IsUsingHeartBeatSensor()
{
	if (m_bIsPlayer && EngineWeapon)
	{
		if (EngineWeapon->eventIsGoggles())
			return 1;
	}
	return 0;
}

IMPL_MATCH("R6Engine.dll", 0x1002c640)
void AR6Pawn::PawnLook(FRotator LookRot, INT bShouldAim, INT BlendTime)
{
	if (m_bIsClimbingLadder)
		bShouldAim = 0;

	if ((!m_bMovingDiagonally || WeaponShouldFollowHead()) &&
		(bShouldAim || IsUsingHeartBeatSensor()) &&
		!m_bWeaponTransition &&
		(!m_bIsProne || !m_bUsingBipod))
	{
		SetPawnLookAndAimDirection(LookRot, BlendTime);
		return;
	}
	SetPawnLookDirection(LookRot, BlendTime);
}

IMPL_MATCH("R6Engine.dll", 0x1002c760)
void AR6Pawn::PawnLookAbsolute(FRotator AbsoluteRot, INT bShouldAim, INT BlendTime)
{
	if (m_bIsClimbingLadder)
		bShouldAim = 0;

	FRotator RelRot(AbsoluteRot.Pitch - Rotation.Pitch,
					AbsoluteRot.Yaw - Rotation.Yaw,
					AbsoluteRot.Roll - Rotation.Roll);

	if ((!m_bMovingDiagonally || WeaponShouldFollowHead()) &&
		(bShouldAim || IsUsingHeartBeatSensor()) &&
		!m_bWeaponTransition &&
		(!m_bIsProne || !m_bUsingBipod))
	{
		SetPawnLookAndAimDirection(RelRot, BlendTime);
		return;
	}
	SetPawnLookDirection(RelRot, BlendTime);
}

IMPL_MATCH("R6Engine.dll", 0x1002c8b0)
void AR6Pawn::PawnLookAt(FVector TargetLoc, INT bShouldAim, INT BlendTime)
{
	FVector Dir = TargetLoc - Location;
	FRotator LookRot = Dir.Rotation();
	FRotator RelRot(LookRot.Pitch - Rotation.Pitch,
					LookRot.Yaw - Rotation.Yaw,
					LookRot.Roll - Rotation.Roll);

	if ((m_bIsClimbingLadder || (m_bIsProne && m_bUsingBipod) || !bShouldAim)
		&& !IsUsingHeartBeatSensor())
	{
		SetPawnLookDirection(RelRot, BlendTime);
		return;
	}
	SetPawnLookAndAimDirection(RelRot, BlendTime);
}

IMPL_MATCH("R6Engine.dll", 0x10022d90)
void AR6Pawn::PawnSetBoneRotation(FName BoneName, INT Pitch, INT Yaw, INT Roll, FLOAT Alpha)
{
	guard(AR6Pawn::PawnSetBoneRotation);
	USkeletalMeshInstance* MeshInst = (USkeletalMeshInstance*)Mesh->MeshGetInstance(this);
	MeshInst->SetBoneRotation(BoneName, FRotator(Pitch, Yaw, Roll), 0, 1.0f, Alpha);
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1002de70)
void AR6Pawn::PawnTrackActor(AActor* InActor, INT bShouldAim)
{
	*(DWORD*)((BYTE*)this + 0x6c4) ^= ((DWORD)bShouldAim << 29 ^ *(DWORD*)((BYTE*)this + 0x6c4)) & 0x20000000;
	*(AActor**)((BYTE*)this + 0x7c0) = InActor;
	UpdatePawnTrackActor(1);
}

IMPL_DIVERGE("0x10026140: FUN_10001750 initializes FCheckResult; loop uses dual line-check per direction with sizes from this+0x118; FocalPoint taken directly from Controller+0x480 not FocusActor")
INT AR6Pawn::PickActorAdjust(AActor* param_1)
{
	guard(AR6Pawn::PickActorAdjust);
	if (Physics == PHYS_Swimming || Controller == NULL)
		return 0;

	INT* pCtrl = *(INT**)((BYTE*)this + 0x4ec);
	INT* pXLevel = *(INT**)((BYTE*)this + 0x328);

	// Get direction to focal point (controller+0x3e4 = FocusActor, +0x488 = FocalPoint)
	INT focusActor = *(INT*)((BYTE*)pCtrl + 0x3e4);
	FLOAT focX = focusActor ? *(FLOAT*)(focusActor + 0x234) : *(FLOAT*)((BYTE*)pCtrl + 0x488);
	FLOAT focY = focusActor ? *(FLOAT*)(focusActor + 0x238) : *(FLOAT*)((BYTE*)pCtrl + 0x48c);

	FLOAT toDx = focX - Location.X,  toDy = focY - Location.Y;
	FLOAT len = appSqrt(toDx*toDx + toDy*toDy);
	if (len > 0.0f) { toDx /= len; toDy /= len; }

	// Left and right perpendicular directions
	FLOAT perpLX = -toDy,  perpLY =  toDx;
	FLOAT perpRX =  toDy,  perpRY = -toDx;

	// Lateral offset of param_1 from the movement axis
	FLOAT lateralDot = (*(FLOAT*)((BYTE*)param_1 + 0x234) - Location.X) * toDy +
	                   (*(FLOAT*)((BYTE*)param_1 + 0x238) - Location.Y) * (-toDx);
	// param_1+0x118 = CollisionRadius
	FLOAT adjustDist = *(FLOAT*)((BYTE*)param_1 + 0x118) + CollisionRadius;

	if (Abs(lateralDot) > adjustDist)
		return 1;

	FLOAT leftDist  = adjustDist - lateralDot;
	FLOAT rightDist = adjustDist + lateralDot;

	typedef void (__fastcall *FSingleLineFn)(void*, void*, FCheckResult*, AActor*,
		const FVector*, const FVector*, DWORD, const FVector&, const FVector&, const FVector&);
	FSingleLineFn SingleLineCheck = *(FSingleLineFn*)((BYTE*)*pXLevel + 0xcc);

	for (INT pass = 0; pass < 2; pass++)
	{
		FLOAT perpX = (pass == 0) ? perpLX : perpRX;
		FLOAT perpY = (pass == 0) ? perpLY : perpRY;
		FLOAT dist  = (pass == 0) ? leftDist : rightDist;
		FVector tryDest(Location.X + perpX * dist, Location.Y + perpY * dist, Location.Z);
		FCheckResult Hit(1.0f);
		SingleLineCheck(pXLevel, 0, &Hit, this, &tryDest, &Location, 0x20286,
			FVector(0.f, 0.f, 0.f), FVector(0.f, 0.f, 0.f), FVector(0.f, 0.f, 0.f));
		if (Hit.Time == 1.0f)
		{
			// controller+0x3a8 = flags, set bit 0x40 = has adjust destination
			*(DWORD*)((BYTE*)pCtrl + 0x3a8) |= 0x40;
			// controller+0x488/0x48c/0x490 = adjust destination
			*(FLOAT*)((BYTE*)pCtrl + 0x488) = tryDest.X;
			*(FLOAT*)((BYTE*)pCtrl + 0x48c) = tryDest.Y;
			*(FLOAT*)((BYTE*)pCtrl + 0x490) = tryDest.Z;
			return 1;
		}
	}
	return 0;
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10021db0)
void AR6Pawn::PostNetReceive()
{
	// If SoundRepInfo changed and we're ragdoll, stop weapon sound
	if (GR6Pawn_OldSoundRepInfo != m_SoundRepInfo
		&& m_bUseRagdoll
		&& m_SoundRepInfo != NULL)
	{
		m_SoundRepInfo->StopWeaponSound();
	}

	// If net action index changed from unset to valid, sync local copy
	if (GR6Pawn_OldNetActionIndex == 0xFF && m_iNetCurrentActionIndex != 0xFF)
	{
		m_iLocalCurrentActionIndex = m_iNetCurrentActionIndex;
	}

	APawn::PostNetReceive();
}

IMPL_MATCH("R6Engine.dll", 0x10021d20)
void AR6Pawn::PreNetReceive()
{
	GR6Pawn_OldNetActionIndex = m_iNetCurrentActionIndex;
	GR6Pawn_OldSoundRepInfo = m_SoundRepInfo;
	APawn::PreNetReceive();
}

IMPL_MATCH("R6Engine.dll", 0x1002d570)
DWORD AR6Pawn::R6LineOfSightTo(AActor* param_1, INT param_2)
{
	guard(AR6Pawn::R6LineOfSightTo);
	if (param_1 == NULL || Controller == NULL)
		return 0;

	INT* pCtrl = *(INT**)((BYTE*)this + 0x4ec);
	// controller+0x3d8 = Pawn
	APawn* pAVar7 = (APawn*)*(INT*)((BYTE*)pCtrl + 0x3d8);

	// this+0x5b8 = some combat/pawn-type flag
	INT iVar6 = *(INT*)((BYTE*)this + 0x5b8);
	bool bUseSelf = (iVar6 != 0) || (pAVar7 == NULL);
	APawn* viewPawn = bUseSelf ? this : pAVar7;

	FVector eyePos = viewPawn->Location;
	if (viewPawn == pAVar7 && pAVar7 != NULL)
	{
		FVector eye = pAVar7->eventEyePosition();
		eyePos += eye;
	}

	// CheckLineOfSight: (viewActor, eyeOrigin, traceFlags, targetActor, targetLoc, ignoredActor, hitLoc)
	FVector hitLoc(0.f, 0.f, 0.f);
	FVector& targetLoc = *(FVector*)((BYTE*)param_1 + 0x234);
	INT bSeen = CheckLineOfSight((AActor*)viewPawn, eyePos, param_2,
		param_1, targetLoc, NULL, hitLoc);

	if (bSeen == 0)
	{
		// IsA check: if param_1 IsA AR6Pawn, try its colbox base
		if (param_1->IsA(AR6Pawn::StaticClass()))
		{
			// param_1+0xa0 flags bit 0x200 = bHidden; param_1+0x180 = Base; Base+0xa0 bit 0x800
			AActor* pBase = *(AActor**)((BYTE*)param_1 + 0x180);
			if ((*(DWORD*)((BYTE*)param_1 + 0xa0) & 0x200) &&
				pBase != NULL &&
				(*(DWORD*)((BYTE*)pBase + 0xa0) & 0x800))
			{
				FVector& baseLoc = *(FVector*)((BYTE*)pBase + 0x234);
				bSeen = CheckLineOfSight((AActor*)viewPawn, eyePos, param_2,
					param_1, baseLoc, pBase, hitLoc);
			}
		}
		if (bSeen == 0)
		{
			// this+0x694 = m_iVisibilityTest; cycle 0..2
			*(INT*)((BYTE*)this + 0x694) = (*(INT*)((BYTE*)this + 0x694) + 1) % 3;
			return 0;
		}
	}

	// If param_1 is the current enemy, update controller's sight tracking
	// controller+0x400 = Enemy
	AActor* pEnemy = (AActor*)*(INT*)((BYTE*)pCtrl + 0x400);
	if (param_1 == pEnemy)
	{
		// controller+0x498 = LastSeenPos, +0x4a4 = LastSeeingPos, +0x3c4 = LastSeenTime
		*(FVector*)((BYTE*)pCtrl + 0x498) = hitLoc;
		*(FVector*)((BYTE*)pCtrl + 0x4a4) = viewPawn->Location;
		INT* pXLevel = *(INT**)((BYTE*)this + 0x328);
		*(FLOAT*)((BYTE*)pCtrl + 0x3c4) = *(FLOAT*)((BYTE*)pXLevel + 0x18c);  // TimeSeconds
		// controller+0x3a8 flags |= 0x200
		*(DWORD*)((BYTE*)pCtrl + 0x3a8) |= 0x200;
	}
	return 1;
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x100221b0)
DWORD AR6Pawn::R6SeePawn(APawn* param_1, INT param_2)
{
	guard(AR6Pawn::R6SeePawn);
	if (param_1 == NULL || Controller == NULL)
		return 0;

	INT* pCtrl = *(INT**)((BYTE*)this + 0x4ec);

	// Zone sphere radius check: this+0x228 = Region.Zone, zone+0x398 flags bit 0 = sphere active
	INT* zone = *(INT**)((BYTE*)this + 0x228);
	if ((*(BYTE*)((BYTE*)zone + 0x398) & 1) != 0)
	{
		FVector delta = Location - param_1->Location;
		FLOAT distSq = delta.SizeSquared();
		FLOAT zoneR = *(FLOAT*)((BYTE*)zone + 0x3a0);
		FLOAT innerR = zoneR - (zoneR - *(FLOAT*)((BYTE*)zone + 0x39c)) * 0.1f;
		if (distSq > innerR * innerR)
			return 0;
	}

	bool bIsVehicle = false;
	// param_1+0x3a2 = team index; < 2 means player team
	if (*(BYTE*)((BYTE*)param_1 + 0x3a2) < 2)
	{
		// Same team: this+0x3b0 = PlayerReplicationInfo pointer
		if (*(INT*)((BYTE*)this + 0x3b0) == *(INT*)((BYTE*)param_1 + 0x3b0))
			return 0;
	}
	else
	{
		bIsVehicle = true;
		// param_1+0x6c8 flags bit 0x200 = already marked visible this frame
		if (*(DWORD*)((BYTE*)param_1 + 0x6c8) & 0x200)
			return 0;
	}

	DWORD uVar4 = 0;
	// controller+0x400 = Enemy
	AActor* pEnemy = (AActor*)*(INT*)((BYTE*)pCtrl + 0x400);
	if (param_1 == pEnemy)
	{
		uVar4 = ((AController*)pCtrl)->LineOfSightTo(param_1, 0);
	}
	else
	{
		// Toggle TargetInfo flag bit 2 in controller+0x3a8
		DWORD ctrlFlags = *(DWORD*)((BYTE*)pCtrl + 0x3a8);
		*(DWORD*)((BYTE*)pCtrl + 0x3a8) = (~ctrlFlags ^ ctrlFlags) & 4 ^ ctrlFlags;

		FVector& loc = *(FVector*)((BYTE*)param_1 + 0x234);
		uVar4 = CheckSeePawn((AR6Pawn*)param_1, loc, param_2);
		if (!uVar4)
		{
			// If param_1 is hidden but has a visible colbox base, try that
			// param_1+0xa0 flags: bit 0x200 = bHidden; param_1+0x180 = Base; Base bit 0x800
			AActor* pBase = *(AActor**)((BYTE*)param_1 + 0x180);
			if ((*(DWORD*)((BYTE*)param_1 + 0xa0) & 0x200) &&
				pBase != NULL &&
				(*(DWORD*)((BYTE*)pBase + 0xa0) & 0x800))
			{
				FVector& baseLoc = *(FVector*)((BYTE*)pBase + 0x234);
				uVar4 = CheckSeePawn((AR6Pawn*)param_1, baseLoc, param_2);
			}
			else
				return 0;
		}
	}

	if (!uVar4)
		return 0;
	if (bIsVehicle)
		*(DWORD*)((BYTE*)param_1 + 0x6c8) |= 0x200;
	return uVar4;
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10022700)
void AR6Pawn::ResetColBox()
{
	if (!m_collisionBox)
		return;

	m_collisionBox->RelativeLocation = FVector(0.0f, 0.0f, 0.0f);

	if (m_collisionBox->Location.Z != Location.Z)
	{
		// DIVERGENCE: *(INT**)((BYTE*)XLevel + 0xF0) is an unlisted ULevel field — a
		// collision-octree (or BSP-hash) query object. We call its vtable[2] and vtable[3]
		// to remove the colbox before adjusting Location.Z, then re-add it after.
		INT* pCollTree = *(INT**)((BYTE*)XLevel + 0xF0);

		// DIVERGENCE: Actor bitfield DWORD at raw offset 0xA8, bit 0x800. This maps to
		// bBlockActors (or a nearby collision flag) in AActor's packed bitfields. Guards
		// whether the collision tree needs to be notified of the movement.
		if ((*(DWORD*)((BYTE*)m_collisionBox + 0xA8) & 0x800) != 0 && pCollTree != NULL)
		{
			// Remove colbox from collision tree before repositioning (vtable entry 3).
			typedef void (*FCollTreeFunc)(AR6ColBox*);
			((FCollTreeFunc)(*(DWORD*)( (BYTE*)(*(DWORD*)pCollTree) + 0xC )))(m_collisionBox);
		}

		m_collisionBox->Location.Z = Location.Z;
		m_collisionBox->RelativeLocation.Z = m_collisionBox->Location.Z - Location.Z;

		if ((*(DWORD*)((BYTE*)m_collisionBox + 0xA8) & 0x800) != 0 && pCollTree != NULL)
		{
			// Re-add colbox to collision tree after repositioning (vtable entry 2).
			typedef void (*FCollTreeFunc)(AR6ColBox*);
			((FCollTreeFunc)(*(DWORD*)( (BYTE*)(*(DWORD*)pCollTree) + 0x8 )))(m_collisionBox);
		}
	}

	*(DWORD*)((BYTE*)this + 0xa1c) = 0;
	*(DWORD*)((BYTE*)this + 0xa20) = 0;
	*(DWORD*)((BYTE*)this + 0xa24) = 0;
	*(DWORD*)((BYTE*)this + 0x770) = 0;
}

IMPL_MATCH("R6Engine.dll", 0x1002ccc0)
INT AR6Pawn::SetAudioInfo()
{
	guard(AR6Pawn::SetAudioInfo);
	INT iResult = 0;
	// this+0x7d8 = m_SoundRepInfo
	INT* pSRI = *(INT**)((BYTE*)this + 0x7d8);
	if (pSRI != NULL)
	{
		// Server path: this+0x2d = team byte (4 = terrorist); Level+0x425 = netmode flag
		if ((*(BYTE*)((BYTE*)this + 0x2d) == 4) && (*(BYTE*)((BYTE*)Level + 0x425) != '\0'))
		{
			// Iterate controller list from Level+0x4d4; find AR6PlayerController with a pawn
			for (INT ctrl = *(INT*)((BYTE*)Level + 0x4d4); ctrl; ctrl = *(INT*)((BYTE*)ctrl + 0x3dc))
			{
				if (!((AController*)ctrl)->IsA(AR6PlayerController::StaticClass()))
					continue;
				if (*(INT*)((BYTE*)ctrl + 0x3d8) == 0)  // no pawn
					continue;

				BYTE gunType   = GetSoundGunType(0);
				*(BYTE*)((BYTE*)pSRI + 0x396) = gunType;
				BYTE animState = GetAnimState();
				*(BYTE*)((BYTE*)pSRI + 0x396) = *(BYTE*)((BYTE*)pSRI + 0x396) * 0x10 + animState;
				BYTE material  = GetCurrentMaterial();
				*(BYTE*)((BYTE*)pSRI + 0x397) = material;
				*(DWORD*)((BYTE*)this + 0xa0) |= 0x40000000;
				iResult = 1;
				break;
			}
		}

		// Client / single-player path
		pSRI = *(INT**)((BYTE*)this + 0x7d8);
		if (pSRI != NULL && *(BYTE*)((BYTE*)Level + 0x425) != '\x01')
		{
			// GEngine->Client (GEngine+0x44) -> Viewports list
			INT iEngClient = GEngine ? *(INT*)((BYTE*)GEngine + 0x44) : 0;
			INT iVar5 = 0;
			if (iEngClient && *(INT*)((BYTE*)iEngClient + 0x34))
			{
				INT pViewport = *(INT*)(*(INT*)((BYTE*)iEngClient + 0x30) + 0x34);
				if (pViewport && *(INT*)((BYTE*)pViewport + 0x34) == (INT)this)
					iVar5 = 1;
			}
			BYTE gunType   = GetSoundGunType(iVar5);
			*(BYTE*)((BYTE*)pSRI + 0x39a) = gunType;
			BYTE material  = GetCurrentMaterial();
			*(BYTE*)((BYTE*)pSRI + 0x397) = material;
			BYTE animState = GetAnimState();
			*(BYTE*)((BYTE*)pSRI + 0x398) = animState;
			// vtable 0x1b0 = GetHeartBeatStatus, vtable 0x1b4 = GetStatusOtherSensor
			typedef BYTE (__fastcall *FGetByteStatusFn)(void*, void*);
			INT* thisVtbl = *(INT**)this;
			*(BYTE*)((BYTE*)pSRI + 0x399) = (*(FGetByteStatusFn*)((BYTE*)thisVtbl + 0x1b0))(this, 0);
			*(BYTE*)((BYTE*)pSRI + 0x39b) = (*(FGetByteStatusFn*)((BYTE*)thisVtbl + 0x1b4))(this, 0);
			iResult = 1;
		}
	}
	return iResult;
	unguard;
}

IMPL_DIVERGE("0x1002aaf0: FUN_10042934 is x87 ftol2; reads cached bone rotation from FPU ST0 register before each call - values not recoverable from Ghidra decompilation alone")
void AR6Pawn::SetPawnLookAndAimDirection(FRotator InRot, INT BlendTime)
{
	guard(AR6Pawn::SetPawnLookAndAimDirection);

	// Blend alpha: 0.6 when not prone and instant blend; 0.4 otherwise
	FLOAT Alpha;
	if (BlendTime == 0 && (*(DWORD*)((BYTE*)this + 0x6C8) & 0x20000) == 0)
		Alpha = 0.6f;
	else
		Alpha = 0.4f;

	INT CenteredYaw   = GetRotValueCenteredAroundZero(InRot.Yaw);
	INT CenteredPitch = GetRotValueCenteredAroundZero(InRot.Pitch);

	// When prone (bit 0x20000 at 0x6C8), pass zero yaw to rotation offset
	INT OffsetYaw = ((*(DWORD*)((BYTE*)this + 0x6C8) & 0x20000) == 0) ? CenteredYaw : 0;
	eventSetRotationOffset(CenteredPitch, OffsetYaw, 0);

	// Spine bone rotation
	if (!(*(DWORD*)((BYTE*)this + 0x3E0) & 0x200))
	{
		// Not crawling: use R6 Spine1
		// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
		PawnSetBoneRotation(FName(TEXT("R6 Spine1"), FNAME_Add), 0, 0, 0, Alpha);
	}
	else
	{
		// Crawling: use R6 Spine with clamped yaw
		INT ClampedYaw = CenteredYaw;
		if (ClampedYaw < -0x2000) ClampedYaw = -0x2000;
		if (ClampedYaw >  0x1FFF) ClampedYaw =  0x1FFF;
		// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
		PawnSetBoneRotation(FName(TEXT("R6 Spine"), FNAME_Add), ClampedYaw, 0, 0, Alpha);
	}

	if (Mesh)
	{
		USkeletalMeshInstance* MeshInst = (USkeletalMeshInstance*)Mesh->MeshGetInstance(this);
		if (MeshInst)
		{
			// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
			if (CenteredPitch < 1)
			{
				// Neutral/looking down: zero neck via instance, zero head via pawn method
				MeshInst->SetBoneRotation(FName(TEXT("R6 Neck"), FNAME_Add), FRotator(0, 0, 0), 0, 1.0f, Alpha);
				PawnSetBoneRotation(FName(TEXT("R6 Head"), FNAME_Add), 0, 0, 0, Alpha);
			}
			else
			{
				// Looking up: zero neck via pawn method, zero head via instance
				PawnSetBoneRotation(FName(TEXT("R6 Neck"), FNAME_Add), 0, 0, 0, Alpha);
				MeshInst->SetBoneRotation(FName(TEXT("R6 Head"), FNAME_Add), FRotator(0, 0, 0), 0, 1.0f, Alpha);
			}

			// Weapon locking when weapon should follow head and bipod is deployed
			if (WeaponShouldFollowHead() && (*(DWORD*)((BYTE*)this + 0x3E4) & 0x40000))
				WeaponLock(CenteredPitch, (FLOAT)CenteredYaw / 16384.0f, Alpha);

			// Reset clavicle rotations
			MeshInst->SetBoneRotation(FName(TEXT("R6 R Clavicle"), FNAME_Add), FRotator(0, 0, 0), 0, 1.0f, Alpha);
			MeshInst->SetBoneRotation(FName(TEXT("R6 L Clavicle"), FNAME_Add), FRotator(0, 0, 0), 0, 1.0f, Alpha);
		}
	}
	unguard;
}

IMPL_DIVERGE("0x1002a550: FUN_10042934 is x87 ftol2; reads cached bone rotation from FPU ST0 - values not recoverable from Ghidra decompilation alone")
void AR6Pawn::SetPawnLookDirection(FRotator InRot, INT BlendTime)
{
	guard(AR6Pawn::SetPawnLookDirection);

	// Blend alpha: 0.5 when not prone and instant blend; 0.4 otherwise
	FLOAT Alpha;
	if (BlendTime == 0 && (*(DWORD*)((BYTE*)this + 0x6C8) & 0x20000) == 0)
		Alpha = 0.5f;
	else
		Alpha = 0.4f;

	if (!Mesh)
		return;

	USkeletalMeshInstance* MeshInst = (USkeletalMeshInstance*)Mesh->MeshGetInstance(this);
	if (!MeshInst)
		return;

	// Zero neck rotation first
	MeshInst->SetBoneRotation(FName(TEXT("R6 Neck"), FNAME_Add), FRotator(0, 0, 0), 0, 1.0f, Alpha);

	INT CenteredPitch = GetRotValueCenteredAroundZero(InRot.Pitch);
	INT CenteredYaw   = GetRotValueCenteredAroundZero(InRot.Yaw);

	eventSetRotationOffset(CenteredYaw, 0, 0);

	// Clamp pitch to [-0x4000, 0x4000] and yaw to [-0x3000, 0x2FFF]
	INT ClampedPitch = CenteredPitch;
	if (ClampedPitch < -0x4000) ClampedPitch = -0x4000;
	if (ClampedPitch >  0x4000) ClampedPitch =  0x4000;

	INT ClampedYaw = CenteredYaw;
	if (ClampedYaw < -0x3000) ClampedYaw = -0x3000;
	if (ClampedYaw >  0x2FFF) ClampedYaw =  0x2FFF;

	if (!(*(DWORD*)((BYTE*)this + 0x3E0) & 0x200))
	{
		// Not crawling: apply yaw to head bone
		// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
		PawnSetBoneRotation(FName(TEXT("R6 Head"), FNAME_Add), 0, ClampedYaw, 0, Alpha);
	}

	// Weapon follow if weapon should follow head
	if (WeaponShouldFollowHead())
		WeaponFollow(ClampedPitch, Alpha);

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10022860)
void AR6Pawn::SetPrePivot(FVector NewPrePivot)
{
	PrePivot = NewPrePivot;
	if (PrePivot.Z == m_fPrePivotPawnInitialOffset && m_bIsClimbingStairs)
		PrePivot.Z -= 5.0f;
}

IMPL_MATCH("R6Engine.dll", 0x100229a0)
void AR6Pawn::TickSpecial(FLOAT DeltaTime)
{
	APawn::TickSpecial(DeltaTime);
}

IMPL_DIVERGE("0x10024e10: sweep flags should be 0x86 not 0x286; move destination uses this+0x2c8..0x2d0 offsets; PrePivot Z uses this+0x4e8 field after uncrawl")
void AR6Pawn::UnCrawl(INT param_1)
{
	guard(AR6Pawn::UnCrawl);

	APawn* DefObj = (APawn*)GetClass()->GetDefaultObject();
	FLOAT SaveRadius = CollisionRadius;
	FLOAT SaveHeight = CollisionHeight;

	if (!(*(DWORD*)((BYTE*)this + 0x3E0) & 0x10))
	{
		// Not crouched: try to uncrawl all the way to full standing height
		FLOAT DestRadius = DefObj->CollisionRadius;
		FLOAT DestHeight = DefObj->CollisionHeight;
		FLOAT DeltaH     = DestHeight - CollisionHeight;

		FCheckResult Hit(1.0f);
		FVector DestLoc(Location.X, Location.Y, Location.Z + DeltaH);
		typedef INT (__fastcall *FSweepFn)(void*, void*, FCheckResult*, AActor*, FLOAT*, FLOAT*, INT, FLOAT, FLOAT, FLOAT);
		FSweepFn Sweep = *(FSweepFn*)((BYTE*)*(DWORD*)XLevel + 0xCC);
		Sweep(XLevel, 0, &Hit, this, &DestLoc.X, &Location.X, 0x286, DestRadius, DestRadius, DestHeight);

		if (Hit.Time == 1.0f)
		{
			SetCollisionSize(DestRadius, DestHeight);
			typedef INT (__fastcall *FMoveFn)(void*, void*, AActor*, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT);
			FMoveFn Move = *(FMoveFn*)((BYTE*)*(DWORD*)XLevel + 0x9C);
			INT MoveResult = Move(XLevel, 0, this, DestLoc.X, DestLoc.Y, DestLoc.Z, 1, 0, 0, 0);

			if (MoveResult)
			{
				initCrawlMode(false);
				// DIVERGENCE: exact PrePivot Z after full uncrawl from Ghidra unclear; reset to zero
				SetPrePivot(FVector(0.0f, 0.0f, 0.0f));
				if (!param_1)
					eventEndCrawl();
				*(DWORD*)((BYTE*)this + 0x3E0) &= ~0x200u;
				return;
			}
			SetCollisionSize(SaveRadius, SaveHeight);
		}
	}

	// Fallback: try partial uncrawl to crouch height
	FLOAT CrouchH = DefObj->CrouchHeight;
	FLOAT CrouchR = DefObj->CrouchRadius;
	if (CrouchH > CollisionHeight)
	{
		FLOAT DeltaH2 = CrouchH - CollisionHeight;
		FCheckResult Hit2(1.0f);
		FVector DestLoc2(Location.X, Location.Y, Location.Z + DeltaH2);
		typedef INT (__fastcall *FSweepFn2)(void*, void*, FCheckResult*, AActor*, FLOAT*, FLOAT*, INT, FLOAT, FLOAT, FLOAT);
		FSweepFn2 Sweep2 = *(FSweepFn2*)((BYTE*)*(DWORD*)XLevel + 0xCC);
		Sweep2(XLevel, 0, &Hit2, this, &DestLoc2.X, &Location.X, 0x286, CrouchR, CrouchR, CrouchH);

		if (Hit2.Time == 1.0f)
		{
			SetCollisionSize(CrouchR, CrouchH);
			typedef INT (__fastcall *FMoveFn2)(void*, void*, AActor*, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT);
			FMoveFn2 Move2 = *(FMoveFn2*)((BYTE*)*(DWORD*)XLevel + 0x9C);
			INT MoveResult2 = Move2(XLevel, 0, this, DestLoc2.X, DestLoc2.Y, DestLoc2.Z, 1, 0, 0, 0);

			if (MoveResult2)
			{
				initCrawlMode(false);
				SetPrePivot(FVector(0.0f, 0.0f, 0.0f));
				if (!param_1)
					eventEndCrawl();
				*(DWORD*)((BYTE*)this + 0x3E0) &= ~0x200u;
				return;
			}
			SetCollisionSize(SaveRadius, SaveHeight);
		}
	}

	unguard;
}

IMPL_DIVERGE("0x10028920: large function using FUN_10042934 (bone angle from FPU), FUN_10016b00 (FString copy), FUN_1003e330 (hostage pick), FUN_1003e3d0 (bool pick); full implementation pending")
void AR6Pawn::UpdateColBox(FVector& NewLocation, INT p1, INT p2, INT p3)
{
	guard(AR6Pawn::UpdateColBox);
	// Approximation: sync colbox to pawn location.
	if (m_collisionBox)
		ResetColBox();
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10029b20)
FLOAT AR6Pawn::UpdateColBoxPeeking(FLOAT param_1)
{
	guard(AR6Pawn::UpdateColBoxPeeking);

	DWORD uVar1 = *(DWORD*)((BYTE*)this + 0x6c4) >> 0x1e & 1;

	if ((uVar1 != 0) && ((*(DWORD*)((BYTE*)this + 0x6c4) & 0x2000000) == 0))
		return 1000.0f;

	if ((*(DWORD*)((BYTE*)this + 0x3e0) & 0x300) != 0)
		return param_1;

	if (*(INT*)((BYTE*)this + 0x180) == 0)
		return param_1;

	if (uVar1 != 0)
		return param_1;

	// Build a rotator from offsets 0x240/0x244/0x248; add 16000 to pitch (0x244)
	DWORD local_54 = *(DWORD*)((BYTE*)this + 0x240);
	INT   local_50 = *(INT*)((BYTE*)this + 0x244) + 16000;
	DWORD local_4c = *(DWORD*)((BYTE*)this + 0x248);

	FLOAT local_18 = 0.0f;
	INT   local_20 = 1;

	FLOAT local_1c = GetPeekingRatioNorm(param_1);

	// FRotator::Vector on local_54/local_50/local_4c — layout: Pitch/Yaw/Roll
	FVector rotVec = ((FRotator*)&local_54)->Vector();
	FLOAT* pfVar2 = (FLOAT*)&rotVec;

	FLOAT local_24 = local_1c * pfVar2[2] * 56.0f;
	FLOAT local_28 = local_1c * pfVar2[1] * 56.0f;

	FLOAT local_40 = local_24 + *(FLOAT*)((BYTE*)this + 0x23c);
	FLOAT local_44 = local_28 + *(FLOAT*)((BYTE*)this + 0x238);
	FLOAT fVar6    = local_1c * pfVar2[0] * 56.0f + *(FLOAT*)((BYTE*)this + 0x234);

	FLOAT local_34 = (*(FLOAT*)((BYTE*)this + 0xfc) + *(FLOAT*)((BYTE*)this + 0x23c)) - 26.0f;

	FLOAT local_48 = fVar6;
	FLOAT local_3c = fVar6;
	FLOAT local_38 = local_44;

	// Disable upper colbox (0x184) if it exists, is enabled, and we're locally controlled or not a bot
	if ((*(INT*)((BYTE*)this + 0x184) != 0) && ((*(BYTE*)(*(INT*)((BYTE*)this + 0x184) + 0x394) & 1) != 0))
	{
		INT iVar3 = IsLocallyControlled();
		if (iVar3 != 0 || (*(char*)(*(INT*)((BYTE*)this + 0x144) + 0x425) != '\x03'))
			(*(AR6ColBox**)((BYTE*)this + 0x184))->EnableCollision(0, 0, 0);
	}

	if ((*(BYTE*)(*(INT*)((BYTE*)this + 0x180) + 0x394) & 1) == 0)
	{
		// Colbox disabled — optionally re-enable for local player
		INT iVar3 = IsLocallyControlled();
		if ((iVar3 == 0) && (*(char*)(*(INT*)((BYTE*)this + 0x144) + 0x425) == '\x03'))
			return param_1;

		if ((*(INT*)((BYTE*)this + 0x784) == 0) || ((*(BYTE*)((BYTE*)this + 0x6c4) & 4) == 0))
			(*(AR6ColBox**)((BYTE*)this + 0x180))->EnableCollision(1, 0, 0);

		if (*(INT*)(*(AActor**)((BYTE*)this + 0x180) + 0x140) == 0)
		{
			GLog->Logf(TEXT("UpdateColBoxPeeking: colbox has no primitive"));
			return param_1;
		}

		(*(AActor**)((BYTE*)this + 0x180))->SetCollisionSize(28.0f, 26.0f);
		local_20 = 0;
	}

	INT iVar3 = *(INT*)((BYTE*)this + 0x180);
	local_48 = *(FLOAT*)(iVar3 + 0x234);
	local_44 = *(FLOAT*)(iVar3 + 0x238);
	local_40 = *(FLOAT*)(iVar3 + 0x23c);

	// vtable dispatch: XLevel->MoveActor (vtable slot 0x9c/4)
	FLOAT* pfVar8 = &local_48;
	INT iVar4;
	{
		INT* pXLevel = *(INT**)((BYTE*)this + 0x328);
		typedef INT (__thiscall *TMoveActor)(void*, INT, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT, FLOAT*);
		TMoveActor MoveActor = (TMoveActor)*(DWORD*)(*(DWORD*)pXLevel + 0x9c);
		iVar4 = MoveActor(pXLevel, iVar3, fVar6, local_38, local_34, 0, 0, 1, 1, pfVar8);
	}

	iVar3 = *(INT*)((BYTE*)this + 0x180);

	// Check if colbox position changed after move, or not in peek-crawl state (0x39c != 2)
	if ((local_3c != *(FLOAT*)(iVar3 + 0x234) &&
	     local_38 != *(FLOAT*)(iVar3 + 0x238) &&
	     local_34 != *(FLOAT*)(iVar3 + 0x23c)) ||
	    (*(BYTE*)((BYTE*)this + 0x39c) != 0x2))
	{
		if ((local_20 != 0) && (iVar4 == 0))
		{
			// Fallback: try moving to height-adjusted position
			local_40 = (*(FLOAT*)((BYTE*)this + 0xfc) + *(FLOAT*)((BYTE*)this + 0x23c)) - 26.0f;
			local_18 = 1.4013e-45f; // flag: fallback attempted
			{
				INT* pXLevel2 = *(INT**)((BYTE*)this + 0x328);
				typedef INT (__thiscall *TMoveActor)(void*, INT, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT);
				TMoveActor MoveActor2 = (TMoveActor)*(DWORD*)(*(DWORD*)pXLevel2 + 0x9c);
				iVar4 = MoveActor2(pXLevel2, iVar3, local_48, local_44, local_40, 0, 0, 1, 1);
			}
		}

		iVar3 = *(INT*)((BYTE*)this + 0x180);

		// If any position component still matches requested, set fVar6 flag
		if (local_3c == *(FLOAT*)(iVar3 + 0x234) ||
		    local_38 == *(FLOAT*)(iVar3 + 0x238) ||
		    local_34 == *(FLOAT*)(iVar3 + 0x23c))
		{
			fVar6 = 1.4013e-45f;
		}

		if (iVar4 == 0)
		{
			// Try lateral offset based on peek ratio and rotator
			local_18 = *(FLOAT*)((BYTE*)this + 0xf8) - 28.0f;
			if (local_1c < 0.0f)
				local_18 = local_18 * -1.0f;

			FLOAT* pfVar8b = &local_3c;
			FVector rotVec2 = ((FRotator*)&local_54)->Vector();
			pfVar2 = (FLOAT*)&rotVec2;

			local_28 = local_18 * pfVar2[1];
			local_38 = local_28 + *(FLOAT*)((BYTE*)this + 0x238);
			local_3c = local_18 * pfVar2[0] + *(FLOAT*)((BYTE*)this + 0x234);
			local_34 = (*(FLOAT*)((BYTE*)this + 0xfc) - 26.0f) + local_18 * pfVar2[2] + *(FLOAT*)((BYTE*)this + 0x23c);

			{
				INT* pXLevel3 = *(INT**)((BYTE*)this + 0x328);
				typedef INT (__thiscall *TMoveActor)(void*, DWORD, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT, FLOAT*);
				TMoveActor MoveActor3 = (TMoveActor)*(DWORD*)(*(DWORD*)pXLevel3 + 0x9c);
				iVar3 = MoveActor3(pXLevel3, *(DWORD*)((BYTE*)this + 0x180), local_3c, local_38, local_34, 0, 0, 1, 1, pfVar8b);
			}

			if (iVar3 == 0)
			{
				// No room at all — push to standing position
				local_34 = (*(FLOAT*)((BYTE*)this + 0xfc) - 26.0f) + *(FLOAT*)((BYTE*)this + 0x23c);
				{
					INT* pXLevel4 = *(INT**)((BYTE*)this + 0x328);
					typedef void (__thiscall *TMoveActor)(void*, DWORD, DWORD, DWORD, FLOAT, INT, INT, INT, INT);
					TMoveActor MoveActor4 = (TMoveActor)*(DWORD*)(*(DWORD*)pXLevel4 + 0x9c);
					MoveActor4(pXLevel4, *(DWORD*)((BYTE*)this + 0x180),
					           *(DWORD*)((BYTE*)this + 0x234),
					           *(DWORD*)((BYTE*)this + 0x238),
					           local_34, 0, 1, 1, 1);
				}
				return 1000.0f;
			}

			fVar6 = 1.4013e-45f;
		}

		iVar3 = *(INT*)((BYTE*)this + 0x180);

		// If colbox actually moved, apply PrePivot offset via GetAxes + TransformVectorBy
		if (local_48 == *(FLOAT*)(iVar3 + 0x234) ||
		    local_44 == *(FLOAT*)(iVar3 + 0x238) ||
		    local_40 == *(FLOAT*)(iVar3 + 0x23c))
		{
			FLOAT delta_x = *(FLOAT*)(iVar3 + 0x234) - *(FLOAT*)((BYTE*)this + 0x234);
			FLOAT delta_y = *(FLOAT*)(iVar3 + 0x238) - *(FLOAT*)((BYTE*)this + 0x238);
			FLOAT delta_z = *(FLOAT*)(iVar3 + 0x23c) - *(FLOAT*)((BYTE*)this + 0x23c);

			BYTE local_84[48];
			typedef void (__thiscall *TGetAxes)(void*, BYTE*);
			((TGetAxes)*(DWORD*)(*(DWORD*)this + 0xa4))(this, local_84);

			FLOAT delta[3] = { delta_x, delta_y, delta_z };
			FVector xfResult = ((FVector*)delta)->TransformVectorBy(*(FCoords*)&local_3c);
			DWORD* puVar5 = (DWORD*)&xfResult;

			INT iVar3b = *(INT*)((BYTE*)this + 0x180);
			*(DWORD*)(iVar3b + 0x264) = puVar5[0]; // PrePivot.X
			*(DWORD*)(iVar3b + 0x268) = puVar5[1]; // PrePivot.Y
			*(DWORD*)(iVar3b + 0x26c) = puVar5[2]; // PrePivot.Z
		}

		if (fVar6 == 0.0f)
		{
			*(FLOAT*)((BYTE*)this + 0x720) = param_1;
			return param_1;
		}

		// Compute peek ratio from displacement between pawn and colbox
		FLOAT d_z = *(FLOAT*)((BYTE*)this + 0x23c) - *(FLOAT*)((BYTE*)this + 0x23c);
		FLOAT d_y = *(FLOAT*)((BYTE*)this + 0x238) - *(FLOAT*)(*(INT*)((BYTE*)this + 0x180) + 0x238);
		FLOAT d_x = *(FLOAT*)((BYTE*)this + 0x234) - *(FLOAT*)(*(INT*)((BYTE*)this + 0x180) + 0x234);
		fVar6 = ((FVector*)&d_x)->Size();

		if (local_1c < 0.0f)
			fVar6 = fVar6 * -1.0f;

		// Clamp peek displacement to [C_fPeekLeftMax, C_fPeekRightMax] = [0, 2000]
		FLOAT fVar7 = Clamp(fVar6 * 0.017857144f * 1000.0f + 1000.0f, 0.0f, 2000.0f);

		if (fabsf(*(FLOAT*)((BYTE*)this + 0x720) - fVar7) > 100.0f)
		{
			*(FLOAT*)((BYTE*)this + 0x720) = fVar7;
			return *(FLOAT*)((BYTE*)this + 0x720);
		}
	}

	return *(FLOAT*)((BYTE*)this + 0x720);

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1002be50)
void AR6Pawn::UpdateFullPeekingMode(FLOAT DeltaTime)
{
	guard(AR6Pawn::UpdateFullPeekingMode);

	DWORD bIsOver = eventIsFullPeekingOver();

	if (bIsOver != 0)
	{
		// Peeking is over
		if ((*(BYTE*)((BYTE*)this + 0x3e8) & 0x10) == 0)
			return;

		// Return if moving in ALL directions and not in follow mode
		if (Velocity.X != 0.0f &&
			Velocity.Y != 0.0f &&
			Velocity.Z != 0.0f &&
			(*(DWORD*)((BYTE*)this + 0xac) & 2) == 0)
			return;

		FLOAT fResult = UpdateColBoxPeeking(*(FLOAT*)((BYTE*)this + 0x734));
		*(FLOAT*)((BYTE*)this + 0x734) = fResult;
		return;
	}

	// Peeking still active: determine target
	DWORD bFreeAim = (*(DWORD*)((BYTE*)this + 0x3e0) >> 5) & 1;
	FLOAT TargetPeeking;
	if (bFreeAim == 0 || (*(DWORD*)((BYTE*)this + 0x6c4) & 0x2000000) != 0)
	{
		TargetPeeking = *(FLOAT*)((BYTE*)this + 0x730);
	}
	else if (*(FLOAT*)((BYTE*)this + 0x730) < 400.0f)
	{
		TargetPeeking = 400.0f;
	}
	else if (*(FLOAT*)((BYTE*)this + 0x730) < 1600.0f)
	{
		TargetPeeking = *(FLOAT*)((BYTE*)this + 0x730);
	}
	else
	{
		TargetPeeking = 1600.0f;
	}

	FLOAT fOld = *(FLOAT*)((BYTE*)this + 0x734);
	FLOAT fStep = DeltaTime * 3000.0f;
	FLOAT fDiff = *(FLOAT*)((BYTE*)this + 0x734) - TargetPeeking;
	if (fDiff < 0.0f) fDiff = -fDiff;
	if (fDiff >= 1000.0f)
		fStep += fStep;

	if (TargetPeeking <= *(FLOAT*)((BYTE*)this + 0x734))
		*(FLOAT*)((BYTE*)this + 0x734) -= fStep;
	else
		*(FLOAT*)((BYTE*)this + 0x734) += fStep;

	FLOAT fClamped;
	if ((*(DWORD*)((BYTE*)this + 0x6c4) & 0x2000000) == 0)
	{
		FLOAT fLo = TargetPeeking, fHi = TargetPeeking;
		FLOAT fVal;
		if (bFreeAim == 0)
		{
			if (*(INT*)((BYTE*)this + 0x3e4) >= 0)
			{
				fLo = 0.0f;
				fVal = *(FLOAT*)((BYTE*)this + 0x734);
			}
			else
			{
				fVal = *(FLOAT*)((BYTE*)this + 0x734);
				fHi = 2000.0f;
			}
		}
		else if (*(INT*)((BYTE*)this + 0x3e4) < 0)
		{
			fHi = 1600.0f;
			fVal = *(FLOAT*)((BYTE*)this + 0x734);
		}
		else
		{
			fVal = *(FLOAT*)((BYTE*)this + 0x734);
			fLo = 400.0f;
		}
		if (fVal < fLo) fClamped = fLo;
		else if (fVal > fHi) fClamped = fHi;
		else fClamped = fVal;
	}
	else
	{
		fClamped = *(FLOAT*)((BYTE*)this + 0x734);
		if (fOld >= 1000.0f)
		{
			if (fClamped >= 1000.0f)
				fClamped = 1000.0f;
			else if (fClamped >= 2000.0f)
				fClamped = 2000.0f;
		}
		else
		{
			if (fClamped >= 0.0f)
				fClamped = 0.0f;
			else if (fClamped < 1000.0f)
				fClamped = 1000.0f;
		}
	}
	*(FLOAT*)((BYTE*)this + 0x734) = fClamped;

	if ((*(BYTE*)((BYTE*)this + 0x3e8) & 0x10) == 0)
		return;

	if (fOld != *(FLOAT*)((BYTE*)this + 0x734))
		return;

	FLOAT fResult = UpdateColBoxPeeking(*(FLOAT*)((BYTE*)this + 0x734));
	*(FLOAT*)((BYTE*)this + 0x734) = fResult;

	unguard;
}

IMPL_DIVERGE("large animation state machine (~6245 bytes); FUN_100017a0 is Abs(float); full implementation pending - too complex for single decompilation pass")
void AR6Pawn::UpdateMovementAnimation(FLOAT DeltaTime)
{
	guard(AR6Pawn::UpdateMovementAnimation);

	// Process pending animation action queue: replay any actions queued since last sync.
	if (m_iLocalCurrentActionIndex != m_iNetCurrentActionIndex)
	{
		eventPlaySpecialPendingAction(m_iNetCurrentActionIndex, 0);
		m_iLocalCurrentActionIndex = m_iNetCurrentActionIndex;
	}

	// Dead/ragdoll flag at byte 0xA4 bit 5: skip full animation update
	if (*(BYTE*)((BYTE*)this + 0xA4) & 0x20)
		return;

	// 400+ line animation state machine not yet implemented.
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1002c520)
void AR6Pawn::UpdatePawnTrackActor(INT BlendTime)
{
	AActor* pTarget = *(AActor**)((BYTE*)this + 0x7c0);
	if (!pTarget)
		return;

	FVector Dir = pTarget->Location - Location;
	FRotator LookRot = Dir.Rotation();
	FRotator RelRot(LookRot.Pitch - Rotation.Pitch,
					LookRot.Yaw - Rotation.Yaw,
					LookRot.Roll - Rotation.Roll);

	// bit 29 of 0x6c4 = m_bAim flag
	if (*(DWORD*)((BYTE*)this + 0x6c4) & 0x20000000)
		SetPawnLookAndAimDirection(RelRot, BlendTime);
	else
		SetPawnLookDirection(RelRot, BlendTime);
}

IMPL_MATCH("R6Engine.dll", 0x1002d7a0)
void AR6Pawn::UpdatePeeking(FLOAT DeltaTime)
{
	if (*(INT*)((BYTE*)this + 0x180) == 0)
		return;

	if ((*(DWORD*)((BYTE*)this + 0x3e0) & 0x300) == 0)
	{
		BYTE ePeekingMode = *(BYTE*)((BYTE*)this + 0x39c);
		if (ePeekingMode == 0)
		{
			FLOAT fPeeking734 = *(FLOAT*)((BYTE*)this + 0x734);
			if (!(fPeeking734 == 1000.0f))
			{
				// Check AR6ColBox flag at colbox+0x394 bit 0
				if ((*(BYTE*)((BYTE*)*(INT*)((BYTE*)this + 0x180) + 0x394) & 1) == 0)
					return;

				INT bLocalCtrl = APawn::IsLocallyControlled();
				if (bLocalCtrl == 0 && *(BYTE*)((BYTE*)Level + 0x425) == '\x03')
					return;

				AR6ColBox* colBox = *(AR6ColBox**)((BYTE*)this + 0x180);
				colBox->EnableCollision(0, 0, 0);
				return;
			}
		}
		else if (ePeekingMode == 1 && (*(DWORD*)((BYTE*)this + 0x6c4) & 0x2000000) == 0)
		{
			// Full peeking mode â fall through to UpdateFullPeekingMode
		}
		else if (ePeekingMode == 2)
		{
			FLOAT fOldPeeking = *(FLOAT*)((BYTE*)this + 0x734);
			*(FLOAT*)((BYTE*)this + 0x734) = *(FLOAT*)((BYTE*)this + 0x730);
			AdjustFluidCollisionCylinder(*(FLOAT*)((BYTE*)this + 0x4b4), 0);
			FLOAT fMax = GetMaxFluidPeeking(*(FLOAT*)((BYTE*)this + 0x4b4),
											 *(DWORD*)((BYTE*)this + 0x3e4) >> 31);
			fMax = AdjustMaxFluidPeeking(*(FLOAT*)((BYTE*)this + 0x734), fMax);
			*(FLOAT*)((BYTE*)this + 0x734) = fMax;
			if (fOldPeeking == fMax)
			{
				FLOAT fResult = UpdateColBoxPeeking(fMax);
				*(FLOAT*)((BYTE*)this + 0x734) = fResult;
				return;
			}
			if ((*(BYTE*)((BYTE*)this + 0x3e8) & 0x10) == 0)
				return;
			// velocity not all zero AND not in follow mode
			if (((*(FLOAT*)((BYTE*)this + 0x24c) != 0.0f ||
				  *(FLOAT*)((BYTE*)this + 0x250) != 0.0f ||
				  *(FLOAT*)((BYTE*)this + 0x254) != 0.0f)) &&
				(*(DWORD*)((BYTE*)this + 0xac) & 2) == 0)
				return;
			FLOAT fResult = UpdateColBoxPeeking(fMax);
			*(FLOAT*)((BYTE*)this + 0x734) = fResult;
			return;
		}
		else
		{
			return;
		}
	}
	else if (*(BYTE*)((BYTE*)this + 0x39c) != 1)
	{
		return;
	}

	UpdateFullPeekingMode(DeltaTime);
}

IMPL_DIVERGE("0x10022e40: FUN_10042934 (x87 ftol2) reads cached clavicle bone rotation from FPU - 3 values per bone cannot be recovered from Ghidra decompilation")
void AR6Pawn::WeaponFollow(INT param_1, FLOAT param_2)
{
	guard(AR6Pawn::WeaponFollow);
	if (!EngineWeapon)
		return;

	if (!(*(DWORD*)((BYTE*)this + 0x3E4) & 0x40000))
	{
		// No bipod deployed: zero both clavicle rotations
		USkeletalMeshInstance* MeshInst = (USkeletalMeshInstance*)Mesh->MeshGetInstance(this);
		MeshInst->SetBoneRotation(FName(TEXT("R6 R Clavicle"), FNAME_Add), FRotator(0, 0, 0), 0, 1.0f, param_2);
		MeshInst->SetBoneRotation(FName(TEXT("R6 L Clavicle"), FNAME_Add), FRotator(0, 0, 0), 0, 1.0f, param_2);
		return;
	}

	BYTE WeapType = *(BYTE*)((BYTE*)EngineWeapon + 0x395);
	switch (WeapType)
	{
	case 1:
	case 4:
		// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
		PawnSetBoneRotation(FName(TEXT("R6 R Clavicle"), FNAME_Add), 0, 0, 0, param_2);
		PawnSetBoneRotation(FName(TEXT("R6 L Clavicle"), FNAME_Add), 0, 0, 0, param_2);
		break;
	case 2: case 3: case 5: case 6: case 7:
		// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
		PawnSetBoneRotation(FName(TEXT("R6 R Clavicle"), FNAME_Add), 0, 0, 0, 0.0f);
		PawnSetBoneRotation(FName(TEXT("R6 L Clavicle"), FNAME_Add), 0, 0, 0, 0.0f);
		break;
	default:
		// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
		PawnSetBoneRotation(FName(TEXT("R6 R Clavicle"), FNAME_Add), 0, 0, 0, param_2);
		PawnSetBoneRotation(FName(TEXT("R6 L Clavicle"), FNAME_Add), 0, 0, 0, param_2);
		break;
	}
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10042934)
INT AR6Pawn::WeaponIsAGadget()
{
	if (EngineWeapon != NULL)
	{
		BYTE WeaponType = *(BYTE*)((BYTE*)EngineWeapon + 0x394);
		if (WeaponType != 7)
			return (INT)(WeaponType == 6);
	}
	return 1;
}

IMPL_DIVERGE("0x10023580: FUN_10042934 (x87 ftol2) reads cached clavicle bone rotation from FPU - values not recoverable from Ghidra decompilation")
void AR6Pawn::WeaponLock(INT param_1, FLOAT param_2, FLOAT param_3)
{
	guard(AR6Pawn::WeaponLock);
	if (!EngineWeapon)
		return;

	if (!(*(DWORD*)((BYTE*)this + 0x3E4) & 0x40000))
	{
		// No bipod deployed
		USkeletalMeshInstance* MeshInst = (USkeletalMeshInstance*)Mesh->MeshGetInstance(this);
		MeshInst->SetBoneRotation(FName(TEXT("R6 R Clavicle"), FNAME_Add), FRotator(0, 0, 0), 0, 1.0f, param_3);
		MeshInst->SetBoneRotation(FName(TEXT("R6 L Clavicle"), FNAME_Add), FRotator(0, 0, 0), 0, 1.0f, param_3);
		return;
	}

	BYTE BVar = *(BYTE*)((BYTE*)EngineWeapon + 0x395);
	// Bail if weapon type is 0 or > 8 (BYTE subtraction wraps: 0-1 = 255 > 7)
	if ((BYTE)(BVar - 1) > 7)
		return;

	switch (BVar)
	{
	case 1:
		// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
		PawnSetBoneRotation(FName(TEXT("R6 R Clavicle"), FNAME_Add), 0, 0, 0, param_3);
		PawnSetBoneRotation(FName(TEXT("R6 L Clavicle"), FNAME_Add), 0, 0, 0, param_3);
		break;
	default:
		if (param_1 > 0)
		{
			if (!(*(DWORD*)((BYTE*)this + 0x3E0) & 0x200))
			{
				// Not crawling: R Clavicle zero, L Clavicle scaled by param_1
				// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
				PawnSetBoneRotation(FName(TEXT("R6 R Clavicle"), FNAME_Add), 0, 0, 0, param_3);
				INT Yaw = (param_1 < 0x1801) ? param_1 : (param_1 - 0x1800);
				FLOAT YawNorm = (FLOAT)Yaw * 0.00016276042f;
				PawnSetBoneRotation(FName(TEXT("R6 L Clavicle"), FNAME_Add), 0, (INT)(YawNorm * 16384.0f), 0, param_3);
			}
			else
			{
				// Crawling: zero both
				// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
				PawnSetBoneRotation(FName(TEXT("R6 R Clavicle"), FNAME_Add), 0, 0, 0, param_3);
				PawnSetBoneRotation(FName(TEXT("R6 L Clavicle"), FNAME_Add), 0, 0, 0, param_3);
			}
		}
		else
		{
			// DIVERGENCE: FUN_10042934 reads cached bone rotation state; use 0 (identity rotation) as approximation
			PawnSetBoneRotation(FName(TEXT("R6 R Clavicle"), FNAME_Add), 0, 0, 0, param_3);
			PawnSetBoneRotation(FName(TEXT("R6 L Clavicle"), FNAME_Add), 0, 0, 0, param_3);
		}
		break;
	}
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10042934)
INT AR6Pawn::WeaponShouldFollowHead()
{
	// Physics == 12 is PHYS_KarmaRagDoll
	if (Physics == 12 || m_bIsClimbingLadder)
		return 0;
	if (IsUsingHeartBeatSensor() || m_fFiringTimer > 0.0f)
		return 1;
	return m_bWeaponGadgetActivated ? 1 : 0;
}

IMPL_MATCH("R6Engine.dll", 0x1002b5c0)
INT AR6Pawn::actorReachableFromLocation(AActor* param_1, FVector loc)
{
	guard(AR6Pawn::actorReachableFromLocation);
	if (param_1 == NULL)
		return 0;

	// CollisionRadius (0xf8) < 40.0 proximity check
	// AR6SoundVolume IsA check skipped (R6Game.dll dependency; PrivateStaticClass == NULL here)
	{
		if (*(FLOAT*)((BYTE*)this + 0xf8) < 40.0f)
		{
			FLOAT r = *(FLOAT*)((BYTE*)this + 0xf8);
			if (r <= 48.0f) r = 48.0f;
			FLOAT rSq = r * r;

			INT iAnchorValid = APawn::ValidAnchor();
			if (iAnchorValid != 0)
			{
				INT iAnchor = *(INT*)((BYTE*)this + 0x4f8);
				if (iAnchor == (INT)param_1)
				{
					FLOAT dX = *(FLOAT*)(iAnchor + 0x234) - loc.X;
					FLOAT dY = *(FLOAT*)(iAnchor + 0x238) - loc.Y;
					FLOAT dist2DSq = dX*dX + dY*dY;
					if (dist2DSq < rSq)
						return 1;
				}
			}
		}
	}

	FLOAT dX = *(FLOAT*)((BYTE*)param_1 + 0x234) - loc.X;
	FLOAT dY = *(FLOAT*)((BYTE*)param_1 + 0x238) - loc.Y;
	FLOAT dZ = *(FLOAT*)((BYTE*)param_1 + 0x23c) - loc.Z;
	FLOAT distSq = dX*dX + dY*dY + dZ*dZ;

	INT* pXLevel = *(INT**)((BYTE*)this + 0x328);

	if (!GIsEditor)
	{
		if (distSq > 1440000.0f)
			return 0;

		// Check NavPoint accessibility flags
		if ((*(BYTE*)((BYTE*)*(INT*)((BYTE*)param_1 + 0x164) + 0x410) & 0x40) == 0)
		{
			INT bVar = (*(DWORD*)((BYTE*)this + 0x3e0) & 0x28000) == 0;
			if (!bVar)
				return 0;
		}
		else
		{
			INT bVar = (*(BYTE*)((BYTE*)this + 0x3e2) & 1) == 0;
			if (!bVar)
				return 0;
		}

		// Single-line-check eye-to-target visibility
		FLOAT local_74[19] = {0};
		local_74[13] = 1.0f;  // Hit.Time = 1.0
		FVector eyeOff = APawn::eventEyePosition();
		FLOAT eyeX = loc.X + eyeOff.X;
		FLOAT eyeY = loc.Y + eyeOff.Y;
		FLOAT eyeZ = loc.Z + eyeOff.Z;
		FLOAT tgtX = *(FLOAT*)((BYTE*)param_1 + 0x234) + eyeOff.X;
		FLOAT tgtY = *(FLOAT*)((BYTE*)param_1 + 0x238) + eyeOff.Y;
		FLOAT tgtZ = *(FLOAT*)((BYTE*)param_1 + 0x23c) + eyeOff.Z;
		typedef void (__fastcall *FLineFn)(void*, void*, FLOAT*, AActor*, FLOAT*, FLOAT*, DWORD, FLOAT, FLOAT, FLOAT);
		FLineFn LineCheck = *(FLineFn*)((BYTE*)*pXLevel + 0xcc);
		LineCheck(pXLevel, 0, local_74, this, &tgtX, &eyeX, 0x86, 0.0f, 0.0f, 0.0f);
		if (local_74[13] != 1.0f && (INT)local_74[4] != (INT)param_1)
		{
			return 0;
		}
	}

	// Combined collision radius proximity check
	FLOAT fJump = *(FLOAT*)((BYTE*)this + 0x410);
	FLOAT fR15  = *(FLOAT*)((BYTE*)this + 0xf8) * 1.5f;
	if (fR15 < fJump) fJump = fR15;
	FLOAT combinedR = *(FLOAT*)((BYTE*)param_1 + 0xf8) + *(FLOAT*)((BYTE*)this + 0xf8) + fJump;
	if (distSq < combinedR * combinedR)
		return 1;

	// Move pawn temporarily to param_1 location, call Reachable
	FLOAT savedX = Location.X, savedY = Location.Y, savedZ = Location.Z;
	FLOAT destX = *(FLOAT*)((BYTE*)param_1 + 0x234);
	FLOAT destY = *(FLOAT*)((BYTE*)param_1 + 0x238);
	FLOAT destZ = *(FLOAT*)((BYTE*)param_1 + 0x23c);

	typedef INT (__fastcall *FMoveFn)(void*, void*, AActor*, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT);
	FMoveFn MoveActor = *(FMoveFn*)((BYTE*)*pXLevel + 0x9c);

	INT bMoved = MoveActor(pXLevel, 0, this, destX, destY, destZ, 1, 0, 0, 0);
	if (bMoved != 0)
	{
		destX = Location.X;
		destY = Location.Y;
		destZ = Location.Z;
		MoveActor(pXLevel, 0, this, savedX, savedY, savedZ, 1, 1, 0, 0);
	}

	INT result = APawn::Reachable(FVector(destX, destY, destZ), param_1);
	return result;
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10021920)
void AR6Pawn::calcVelocity(FVector Accel, FLOAT BrakingDecel, FLOAT Friction, FLOAT MaxSpeed, INT bFluid, INT bRestricted, INT bWaterJump)
{
	FLOAT OverrideSpeed = 0.0f;
	eMovementDirection MoveDir = GetMovementDirection();

	if (Physics == PHYS_Walking)
	{
		if (m_bIsProne)
		{
			OverrideSpeed = (MoveDir == MOVEDIR_Strafe) ? m_fProneStrafeSpeed : m_fProneSpeed;
		}
		else if (bIsCrouched)
		{
			if (bIsWalking)
				OverrideSpeed = (MoveDir == MOVEDIR_Forward) ? m_fCrouchedWalkingSpeed : m_fCrouchedWalkingBackwardStrafeSpeed;
			else
				OverrideSpeed = (MoveDir == MOVEDIR_Forward) ? m_fCrouchedRunningSpeed : m_fCrouchedRunningBackwardStrafeSpeed;
		}
		else if (!bIsWalking)
		{
			if (m_fCrouchBlendRate > 0.0f)
			{
				if (MoveDir == MOVEDIR_Forward)
					OverrideSpeed = (1.0f - m_fCrouchBlendRate) * (m_fRunningSpeed - m_fCrouchedRunningSpeed) + m_fCrouchedRunningSpeed;
				else
					OverrideSpeed = (1.0f - m_fCrouchBlendRate) * (m_fRunningBackwardStrafeSpeed - m_fCrouchedRunningBackwardStrafeSpeed) + m_fCrouchedRunningBackwardStrafeSpeed;
			}
			else
			{
				OverrideSpeed = (MoveDir == MOVEDIR_Forward) ? m_fRunningSpeed : m_fRunningBackwardStrafeSpeed;
			}
		}
		else // bIsWalking, not crouched — blend walking speed toward crouched walking if transitioning
		{
			if (m_fCrouchBlendRate > 0.0f)
			{
				if (MoveDir == MOVEDIR_Forward)
					OverrideSpeed = (1.0f - m_fCrouchBlendRate) * (m_fWalkingSpeed - m_fCrouchedWalkingSpeed) + m_fCrouchedWalkingSpeed;
				else
					OverrideSpeed = (1.0f - m_fCrouchBlendRate) * (m_fWalkingBackwardStrafeSpeed - m_fCrouchedWalkingBackwardStrafeSpeed) + m_fCrouchedWalkingBackwardStrafeSpeed;
			}
			else
			{
				OverrideSpeed = (MoveDir == MOVEDIR_Forward) ? m_fWalkingSpeed : m_fWalkingBackwardStrafeSpeed;
			}
		}
	}

	// DIVERGENCE: Ghidra shows the non-walking fallback loads param_6 (the binary's 2nd FLOAT,
	// Friction in standard UE2 param order). Using MaxSpeed for semantic correctness — when no
	// R6 stance speed applies, pass the caller's MaxSpeed through unchanged.
	if (OverrideSpeed == 0.0f)
		OverrideSpeed = MaxSpeed;

	// Store override speed at this+0x428 (Ghidra: local_18 stored before base call)
	*(FLOAT*)((BYTE*)this + 0x428) = OverrideSpeed;

	// Diagonal strafe speed reduction: if bit 0 of 0x6c4 is set, reduce by factor 0.894427
	if (*(BYTE*)((BYTE*)this + 0x6c4) & 1)
		OverrideSpeed *= 0.894427f;

	APawn::calcVelocity(Accel, BrakingDecel, Friction, OverrideSpeed, bFluid, bRestricted, bWaterJump);
}

IMPL_MATCH("R6Engine.dll", 0x10002700)
void AR6Pawn::eventAdjustPawnForDiagonalStrafing()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_AdjustPawnForDiagonalStrafing), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x100027b0)
void AR6Pawn::eventEndCrawl()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_EndCrawl), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x100025b0)
void AR6Pawn::eventEndOfGrenadeEffect(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_EndOfGrenadeEffect), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10002960)
void AR6Pawn::eventEndPeekingMode(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_EndPeekingMode), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x1000db50)
FVector AR6Pawn::eventGetFiringStartPoint()
{
	struct {
		FVector ReturnValue;
	} Parms;
	Parms.ReturnValue = FVector(0,0,0);
	ProcessEvent(FindFunctionChecked(R6ENGINE_GetFiringStartPoint), &Parms);
	return Parms.ReturnValue;
}

IMPL_MATCH("R6Engine.dll", 0x100025f0)
FLOAT AR6Pawn::eventGetStanceReticuleModifier()
{
	struct {
		FLOAT ReturnValue;
	} Parms;
	Parms.ReturnValue = 0.f;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GetStanceReticuleModifier), &Parms);
	return Parms.ReturnValue;
}

IMPL_MATCH("R6Engine.dll", 0x10002500)
void AR6Pawn::eventInitBiPodPosture(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_InitBiPodPosture), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10002920)
DWORD AR6Pawn::eventIsFullPeekingOver()
{
	struct {
		DWORD ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	ProcessEvent(FindFunctionChecked(R6ENGINE_IsFullPeekingOver), &Parms);
	return Parms.ReturnValue;
}

IMPL_MATCH("R6Engine.dll", 0x10002a00)
DWORD AR6Pawn::eventIsPeekingLeft()
{
	struct {
		DWORD ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	ProcessEvent(FindFunctionChecked(R6ENGINE_IsPeekingLeft), &Parms);
	return Parms.ReturnValue;
}

IMPL_MATCH("R6Engine.dll", 0x10002850)
void AR6Pawn::eventPlayCrouchToProne(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayCrouchToProne), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10002890)
void AR6Pawn::eventPlayFluidPeekingAnim(FLOAT A, FLOAT B, FLOAT C)
{
	struct { 
		FLOAT A;
		FLOAT B;
		FLOAT C;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayFluidPeekingAnim), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x100028e0)
void AR6Pawn::eventPlayPeekingAnim(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayPeekingAnim), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10002810)
void AR6Pawn::eventPlayProneToCrouch(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayProneToCrouch), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10002570)
void AR6Pawn::eventPlaySpecialPendingAction(BYTE A, INT B)
{
	struct { 
		BYTE A;
		INT B;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlaySpecialPendingAction), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10002630)
void AR6Pawn::eventPlaySurfaceSwitch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlaySurfaceSwitch), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10002770)
void AR6Pawn::eventPotentialOpenDoor(AR6Door * A)
{
	struct { AR6Door * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PotentialOpenDoor), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10002ae0)
void AR6Pawn::eventR6MakeMovementNoise()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_R6MakeMovementNoise), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10002660)
void AR6Pawn::eventR6ResetLookDirection()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_R6ResetLookDirection), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10002730)
void AR6Pawn::eventRemovePotentialOpenDoor(AR6Door * A)
{
	struct { AR6Door * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_RemovePotentialOpenDoor), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x100024d0)
void AR6Pawn::eventResetBipodPosture()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ResetBipodPosture), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x100026d0)
void AR6Pawn::eventResetDiagonalStrafing()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ResetDiagonalStrafing), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10007c90)
void AR6Pawn::eventSetCrouchBlend(FLOAT A)
{
	struct { FLOAT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetCrouchBlend), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10002a40)
void AR6Pawn::eventSetPeekingInfo(BYTE A, FLOAT B, DWORD C)
{
	struct { 
		BYTE A;
		FLOAT B;
		DWORD C;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetPeekingInfo), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10002a90)
void AR6Pawn::eventSetRotationOffset(INT A, INT B, INT C)
{
	struct { 
		INT A;
		INT B;
		INT C;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetRotationOffset), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10002540)
void AR6Pawn::eventSpawnRagDoll()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SpawnRagDoll), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x100027e0)
void AR6Pawn::eventStartCrawl()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartCrawl), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x100029d0)
void AR6Pawn::eventStartFluidPeeking()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartFluidPeeking), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x100029a0)
void AR6Pawn::eventStartFullPeeking()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartFullPeeking), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10002690)
void AR6Pawn::eventTurnToFaceActor(AActor * A)
{
	struct { AActor * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_TurnToFaceActor), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x100024a0)
void AR6Pawn::eventUpdateBipodPosture()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_UpdateBipodPosture), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x1002bad0)
void AR6Pawn::execAdjustFluidCollisionCylinder(FFrame& Stack, RESULT_DECL)
{
	P_GET_FLOAT(fBlendRate);
	P_GET_UBOOL(bTest);
	P_FINISH;
	*(DWORD*)Result = AdjustFluidCollisionCylinder(fBlendRate, bTest);
}

IMPL_MATCH("R6Engine.dll", 0x10025860)
void AR6Pawn::execCheckCylinderTranslation(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vStart);
	P_GET_STRUCT(FVector, vDest);
	P_GET_OBJECT(AActor, ignoreActor1);
	P_GET_UBOOL(bIgnoreAllActor1Class);
	P_FINISH;
	// GHIDRA REF: 0x25860
	// Multi-hit cylinder sweep via XLevel vtable[0xd8] with GMem FMemStack allocation.
	// Iterates hits, skipping ignoreActor1 (or its class), returns 1 if any blocking actor found.
	INT* pXLevel = *(INT**)((BYTE*)this + 0x328);
	typedef void* (__fastcall *FCylinderFn)(void*, void*, FMemStack&, FVector&, FVector&, FLOAT, FLOAT, AActor*, INT, INT, INT);
	FCylinderFn CylFn = *(FCylinderFn*)((BYTE*)*pXLevel + 0xd8);

	void* pHits = CylFn(pXLevel, 0, GMem, vStart, vDest, CollisionRadius + 3.35f, CollisionHeight, this, 0, 0, 0);

	DWORD uResult = 0;
	if (pHits)
	{
		// Each entry: next_ptr at [0], actor_ptr at [4]
		for (DWORD* p = (DWORD*)pHits; *p != 0; p = (DWORD*)*p)
		{
			AActor* pAct = *(AActor**)((BYTE*)p + 4);
			if (!pAct) continue;
			if (ignoreActor1)
			{
				if (bIgnoreAllActor1Class && pAct->IsA(ignoreActor1->GetClass()))
					continue;
				else if (pAct == ignoreActor1)
					continue;
			}
			uResult = 1;
			break;
		}
	}
	*(DWORD*)Result = uResult;
}

IMPL_MATCH("R6Engine.dll", 0x1002a1a0)
void AR6Pawn::execFootStep(FFrame& Stack, RESULT_DECL)
{
	P_GET_NAME(nBoneName);
	P_GET_UBOOL(bLeftFoot);
	P_FINISH;
	// Checks Mesh, gets bone coords, traces down, spawns footstep decal, plays surface sound.
	eventPlaySurfaceSwitch();
}

IMPL_DIVERGE("0x100402e0: FUN_10042934 (x87 ftol2) computes armor-modified damage (iKillDamage * armor_factor * appFrand()); formula not recoverable from Ghidra decompilation")
void AR6Pawn::execGetKillResult(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(iKillDamage);
	P_GET_INT(ePartHit);
	P_GET_INT(eArmorType);
	P_GET_INT(iBulletToArmorModifier);
	P_GET_UBOOL(bHitBySilencedWeapon);
	P_FINISH;
	// GHIDRA REF: 0x402e0
	if (iKillDamage < 1)
	{
		*(BYTE*)Result = 0;
		return;
	}
	R6Charts Charts;
	stResultTable* pTable = Charts.GetKillTable((eBodyPart)ePartHit);
	if (!pTable)
	{
		*(BYTE*)Result = 0;
		return;
	}
	// DIVERGENCE: original code applies armor modification to iKillDamage via an x87 ftol
	// helper (FUN_10042934) that accounts for eArmorType and iBulletToArmorModifier before
	// comparing against kill thresholds. Using raw iKillDamage as approximation.
	INT iDmg = Max(1, iKillDamage);
	if (iDmg < pTable->Threshold1)
		*(BYTE*)Result = 0;
	else if (iDmg < pTable->Threshold2)
		*(BYTE*)Result = 1;
	else
		*(BYTE*)Result = (BYTE)((pTable->Threshold3 <= iDmg ? 1 : 0) + 2);
}

IMPL_MATCH("R6Engine.dll", 0x10029ac0)
void AR6Pawn::execGetMaxRotationOffset(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = getMaxRotationOffset((m_bWantsToProne || m_bIsProne) ? 1 : 0);
}

IMPL_MATCH("R6Engine.dll", 0x100257c0)
void AR6Pawn::execGetMovementDirection(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(BYTE*)Result = (BYTE)GetMovementDirection();
}

IMPL_MATCH("R6Engine.dll", 0x10022ae0)
void AR6Pawn::execGetPeekingRatioNorm(FFrame& Stack, RESULT_DECL)
{
	P_GET_FLOAT(fPeeking);
	P_FINISH;
	*(FLOAT*)Result = GetPeekingRatioNorm(fPeeking);
}

IMPL_MATCH("R6Engine.dll", 0x10024200)
void AR6Pawn::execGetRotationOffset(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FRotator*)Result = GetRotationOffset();
}

IMPL_DIVERGE("0x100406c0: FUN_10042934 (x87 ftol2) computes armor-modified stun damage; same pattern as execGetKillResult - formula not recoverable from Ghidra decompilation")
void AR6Pawn::execGetStunResult(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(iStunDamage);
	P_GET_INT(ePartHit);
	P_GET_INT(eArmorType);
	P_GET_INT(iBulletToArmorModifier);
	P_GET_UBOOL(bHitBySilencedWeapon);
	P_FINISH;
	// GHIDRA REF: 0x406c0
	if (iStunDamage < 1)
	{
		*(BYTE*)Result = 0;
		return;
	}
	R6Charts Charts;
	stResultTable* pTable = Charts.GetStunTable((eBodyPart)ePartHit);
	if (!pTable)
	{
		*(BYTE*)Result = 0;
		return;
	}
	// DIVERGENCE: same x87 armor-modification divergence as execGetKillResult;
	// using raw iStunDamage as approximation.
	INT iDmg = Max(1, iStunDamage);
	if (iDmg < pTable->Threshold1)
		*(BYTE*)Result = 0;
	else if (iDmg < pTable->Threshold2)
		*(BYTE*)Result = 1;
	else
		*(BYTE*)Result = (BYTE)((pTable->Threshold3 <= iDmg ? 1 : 0) + 2);
}

IMPL_MATCH("R6Engine.dll", 0x10040550)
void AR6Pawn::execGetThroughResult(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(iKillDamage);
	P_GET_INT(ePartHit);
	P_GET_STRUCT(FVector, vBulletDirection);
	P_FINISH;
	// GHIDRA REF: 0x40550
	// Normalise bullet direction, dot it against the pawn's facing vector to determine
	// whether the shot is head-on (front) or oblique (side). Pass to BulletGoesThroughCharacter.
	FVector vDir = vBulletDirection.SafeNormal();
	FVector vFacing = Rotation.Vector();
	FLOAT fDot = vDir | vFacing;
	if (fDot < 0.0f) fDot = -fDot;
	INT iSide = (fDot < 0.7071f) ? 1 : 0;          // <45° from normal → side shot
	BYTE iThreshold = ((BYTE*)this)[0x670];           // pawn armor-type threshold index
	R6Charts Charts;
	INT iResult = Charts.BulletGoesThroughCharacter(iKillDamage, ePartHit, (INT)iThreshold, iSide);
	*(INT*)Result = (iResult < 0) ? 0 : iResult;
}

IMPL_DIVERGE("0x1002c140: FUN_10042934 (x87 ftol2) computes cross-product-derived bone rotation pitch/yaw from hit direction; values depend on FPU state not visible in Ghidra decompilation")
void AR6Pawn::execMoveHitBone(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FRotator, rHitDirection);
	P_GET_INT(iHitBone);
	P_FINISH;
	// GHIDRA REF: 0x2c140
	// DIVERGENCE: function obtains a USkeletalMeshInstance, calls GetBoneCoords for the
	// hit bone, cross-products the hit direction with the bone axis, then calls
	// USkeletalMeshInstance::SetBoneRotation (via FUN_10042934 reads for cached state).
	// Left as no-op pending resolution of FUN_10042934.
}

IMPL_MATCH("R6Engine.dll", 0x10042934)
void AR6Pawn::execPawnCanBeHurtFrom(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vLocation);
	P_FINISH;
	// GHIDRA REF: 0x2b260
	// Shoot a line from vLocation (Start) to pawn Location (End).
	// If blocked, retry from the pawn's eye position. Return 1 if unblocked.
	INT* pXLevel = *(INT**)((BYTE*)this + 0x328);
	typedef void (__fastcall *FSingleLineFn)(void*, void*, FCheckResult*, AActor*,
		const FVector*, const FVector*, DWORD, const FVector&, const FVector&, const FVector&);
	FSingleLineFn SingleLineCheck = *(FSingleLineFn*)((BYTE*)*pXLevel + 0xcc);
	const FVector vZero(0.f, 0.f, 0.f);
	FCheckResult Hit(1.0f);
	SingleLineCheck(pXLevel, 0, &Hit, this, &Location, &vLocation, 0x40086, vZero, vZero, vZero);
	if (Hit.Actor != NULL)
	{
		// Retry from world-space eye position
		FVector vEye = eventEyePosition();
		vEye.X += Location.X;
		vEye.Y += Location.Y;
		vEye.Z += Location.Z;
		SingleLineCheck(pXLevel, 0, &Hit, this, &vEye, &vLocation, 0x40086, vZero, vZero, vZero);
	}
	*(DWORD*)Result = (Hit.Actor == NULL) ? 1 : 0;
}

IMPL_MATCH("R6Engine.dll", 0x1002daa0)
void AR6Pawn::execPawnLook(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FRotator, rLookDir);
	P_GET_UBOOL(bAim);
	P_GET_UBOOL(bNoBlend);
	P_FINISH;
	PawnLook(rLookDir, bAim, bNoBlend);
}

IMPL_MATCH("R6Engine.dll", 0x1002dbb0)
void AR6Pawn::execPawnLookAbsolute(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FRotator, rLookDir);
	P_GET_UBOOL(bAim);
	P_GET_UBOOL(bNoBlend);
	P_FINISH;
	PawnLookAbsolute(rLookDir, bAim, bNoBlend);
}

IMPL_MATCH("R6Engine.dll", 0x1002dcc0)
void AR6Pawn::execPawnLookAt(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vTarget);
	P_GET_UBOOL(bAim);
	P_GET_UBOOL(bNoBlend);
	P_FINISH;
	PawnLookAt(vTarget, bAim, bNoBlend);
}

IMPL_MATCH("R6Engine.dll", 0x1002fc00)
void AR6Pawn::execPawnTrackActor(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, Target);
	P_GET_UBOOL(bAim);
	P_FINISH;
	// Ghidra: directly sets m_bAim bit (bit 29 of 0x6c4) and m_TrackActor (0x7c0), then calls UpdatePawnTrackActor(1)
	DWORD old6c4 = *(DWORD*)((BYTE*)this + 0x6c4);
	*(DWORD*)((BYTE*)this + 0x6c4) = old6c4 ^ (((DWORD)bAim << 29) ^ old6c4) & 0x20000000;
	*(INT*)((BYTE*)this + 0x7c0) = (INT)Target;
	UpdatePawnTrackActor(1);
}

IMPL_MATCH("R6Engine.dll", 0x1002dea0)
void AR6Pawn::execPlayVoices(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(USound, sndPlayVoice);
	P_GET_BYTE(eSlotUse);
	P_GET_INT(iPriority);
	P_GET_BYTE(eSend);
	P_GET_UBOOL(bWaitToFinishSound);
	P_GET_FLOAT(fTime);
	P_FINISH;
	// GHIDRA REF: 0x2dea0
	SetAudioInfo();
	// Broadcast to every AR6PlayerController in the level (AI-driven pawns only;
	// byte at this+0x39e == 1 suppresses the broadcast for special pawn types).
	if (!IsHumanControlled() && ((BYTE*)this)[0x39e] != 1)
	{
		// Level+0x4d4 = head of the level's PlayerController linked list
		AR6PlayerController* pPC = *(AR6PlayerController**)((BYTE*)Level + 0x4d4);
		while (pPC != NULL)
		{
			if (pPC->IsA(AR6PlayerController::StaticClass()))
				pPC->eventClientPlayVoices(m_SoundRepInfo, sndPlayVoice, (BYTE)eSlotUse, iPriority, (DWORD)bWaitToFinishSound, fTime);
			pPC = *(AR6PlayerController**)((BYTE*)pPC + 0x3dc);
		}
	}
}

IMPL_MATCH("R6Engine.dll", 0x10024070)
void AR6Pawn::execR6GetViewRotation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FRotator*)Result = GetViewRotation();
}

IMPL_DIVERGE("0x1002e120: server network loop walks controller list at Level+0x4d4; proximity check uses vtable[0x100] with pawn+0x5e4..0x5ec fields; FUN_10024560 and FUN_1002ba20 unresolved")
void AR6Pawn::execSendPlaySound(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(USound, S);
	P_GET_BYTE(ID);
	P_GET_UBOOL(bDoNotPlayLocallySound);
	P_FINISH;
	// GHIDRA REF: 0x2e120
	SetAudioInfo();
	// DIVERGENCE: server-side network replication walks the PlayerController list at
	// Level+0x4d4 and performs per-controller proximity/IsA checks before calling a
	// client-play vtable method. The proximity formula uses unresolved raw offsets
	// (pawn+0x5e4..0x5ec) so the replication loop is omitted here.
}

IMPL_MATCH("R6Engine.dll", 0x1002e0e0)
void AR6Pawn::execSetAudioInfo(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	SetAudioInfo();
}

IMPL_MATCH("R6Engine.dll", 0x10021ba0)
void AR6Pawn::execSetPawnScale(FFrame& Stack, RESULT_DECL)
{
	P_GET_FLOAT(fNewScale);
	P_FINISH;
	SetDrawScale(fNewScale);
}

IMPL_MATCH("R6Engine.dll", 0x100229b0)
void AR6Pawn::execStartLipSynch(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(USound, _hSound);
	P_GET_OBJECT(USound, _hStopSound);
	P_FINISH;
	m_vInitNewLipSynch(_hSound, _hStopSound);
}

IMPL_MATCH("R6Engine.dll", 0x10022a40)
void AR6Pawn::execStopLipSynch(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	if (m_hLipSynchData)
		((ECLipSynchData*)m_hLipSynchData)->m_vStopLipsynch();
}

IMPL_MATCH("R6Engine.dll", 0x1003fd90)
void AR6Pawn::execToggleHeatProperties(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL(bTurnItOn);
	P_GET_OBJECT(UTexture, pMaskTexture);
	P_GET_OBJECT(UTexture, pAddTexture);
	P_FINISH;
	// GHIDRA REF: 0x3fd90
	// Level+0x450 = packed vision-mode bitfield; bit 0x2000000 = heat vision active.
	// Level+0x54c = mask texture ptr; Level+0x550 = additive texture ptr.
	BYTE* pLvl = (BYTE*)Level;
	if (!bTurnItOn || !pMaskTexture)
	{
		*(DWORD*)(pLvl + 0x450) &= ~0x2000000u;
		*(INT*)  (pLvl + 0x550) = 0;
		// Restore saved viewport overlay mode via g_pEngine->Client->ViewportList[0]+0x34+0x504
		INT Client = *(INT*)((BYTE*)*(INT*)g_pEngine + 0x44);
		if (Client && *(INT*)(Client + 0x34))
		{
			INT Vp = *(INT*)(**(INT**)(Client + 0x30) + 0x34);
			if (Vp) *(INT*)(Vp + 0x504) = GR6Pawn_SavedHeatViewport;
		}
	}
	else
	{
		*(DWORD*)(pLvl + 0x450) |= 0x2000000u;
		*(INT*)  (pLvl + 0x54c) = (INT)pMaskTexture;
		*(INT*)  (pLvl + 0x550) = (INT)pAddTexture;
		INT Client = *(INT*)((BYTE*)*(INT*)g_pEngine + 0x44);
		if (Client && *(INT*)(Client + 0x34))
		{
			INT Vp = *(INT*)(**(INT**)(Client + 0x30) + 0x34);
			if (Vp) { GR6Pawn_SavedHeatViewport = *(INT*)(Vp + 0x504); *(INT*)(Vp + 0x504) = 6; }
		}
	}
	GCompileMaterialsRevision++;
}

IMPL_MATCH("R6Engine.dll", 0x1003ff50)
void AR6Pawn::execToggleNightProperties(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL(bTurnItOn);
	P_GET_OBJECT(UTexture, pMaskTexture);
	P_GET_OBJECT(UTexture, pAddTexture);
	P_FINISH;
	// GHIDRA REF: 0x3ff50
	// bit 0x1000000 = night vision active; also sets Core.dll global GNightVisionActive.
	BYTE* pLvl = (BYTE*)Level;
	if (!bTurnItOn || !pMaskTexture)
	{
		GNightVisionActive = 0;
		*(DWORD*)(pLvl + 0x450) &= ~0x1000000u;
		*(INT*)  (pLvl + 0x550) = 0;
		INT Client = *(INT*)((BYTE*)*(INT*)g_pEngine + 0x44);
		if (Client && *(INT*)(Client + 0x34))
		{
			INT Vp = *(INT*)(**(INT**)(Client + 0x30) + 0x34);
			if (Vp) *(INT*)(Vp + 0x504) = GR6Pawn_SavedNightViewport;
		}
	}
	else
	{
		GNightVisionActive = 1;
		*(DWORD*)(pLvl + 0x450) |= 0x1000000u;
		*(INT*)  (pLvl + 0x54c) = (INT)pMaskTexture;
		*(INT*)  (pLvl + 0x550) = (INT)pAddTexture;
		INT Client = *(INT*)((BYTE*)*(INT*)g_pEngine + 0x44);
		if (Client && *(INT*)(Client + 0x34))
		{
			INT Vp = *(INT*)(**(INT**)(Client + 0x30) + 0x34);
			if (Vp) { GR6Pawn_SavedNightViewport = *(INT*)(Vp + 0x504); *(INT*)(Vp + 0x504) = 5; }
		}
	}
	GCompileMaterialsRevision++;
}

IMPL_MATCH("R6Engine.dll", 0x10040120)
void AR6Pawn::execToggleScopeProperties(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL(bTurnItOn);
	P_GET_OBJECT(UTexture, pMaskTexture);
	P_GET_OBJECT(UTexture, pAddTexture);
	P_FINISH;
	// GHIDRA REF: 0x40120
	// bit 0x4000000 = scope overlay active. Viewport mode 5 (shared with night vision).
	BYTE* pLvl = (BYTE*)Level;
	if (!bTurnItOn || !pMaskTexture || !pAddTexture)
	{
		*(DWORD*)(pLvl + 0x450) &= ~0x4000000u;
		*(INT*)  (pLvl + 0x54c) = 0;
		*(INT*)  (pLvl + 0x550) = 0;
		INT Client = *(INT*)((BYTE*)*(INT*)g_pEngine + 0x44);
		if (Client && *(INT*)(Client + 0x34))
		{
			INT Vp = *(INT*)(**(INT**)(Client + 0x30) + 0x34);
			if (Vp) *(INT*)(Vp + 0x504) = GR6Pawn_SavedScopeViewport;
		}
	}
	else
	{
		*(DWORD*)(pLvl + 0x450) |= 0x4000000u;
		*(INT*)  (pLvl + 0x54c) = (INT)pMaskTexture;
		*(INT*)  (pLvl + 0x550) = (INT)pAddTexture;
		INT Client = *(INT*)((BYTE*)*(INT*)g_pEngine + 0x44);
		if (Client && *(INT*)(Client + 0x34))
		{
			INT Vp = *(INT*)(**(INT**)(Client + 0x30) + 0x34);
			// DIVERGENCE: original saves previous viewport state to DAT_10074550 before
			// setting mode 5; that save step appears missing in Ghidra output for scope-on.
			if (Vp) { *(INT*)(Vp + 0x504) = 5; }
		}
	}
	GCompileMaterialsRevision++;
}

IMPL_MATCH("R6Engine.dll", 0x1002ddd0)
void AR6Pawn::execUpdatePawnTrackActor(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL(bNoBlend);
	P_FINISH;
	UpdatePawnTrackActor(bNoBlend);
}

IMPL_MATCH("R6Engine.dll", 0x10022a80)
INT AR6Pawn::getMaxRotationOffset(INT InProne)
{
	if (InProne == 0)
		return 0x1555;

	// Check weapon has bipod (byte at weapon+0x3A0, bit 1)
	if (EngineWeapon != NULL && (*(BYTE*)((BYTE*)EngineWeapon + 0x3A0) & 2) != 0)
		return 0x15E0;

	return 3000;
}

IMPL_MATCH("R6Engine.dll", 0x10024590)
void AR6Pawn::initCrawlMode(bool bEnable)
{
	guard(AR6Pawn::initCrawlMode);
	AR6ColBox* ColBox = m_collisionBox;
	if (ColBox)
	{
		// If enabling: disable colbox first if certain conditions are met
		if (bEnable &&
			(*(BYTE*)((BYTE*)this + 0x39C) != 0 ||
			 (*(DWORD*)((BYTE*)this + 0x6C4) & 0x2000000) != 0 ||
			 (*(BYTE*)((BYTE*)ColBox + 0x394) & 1) != 0))
		{
			ColBox->EnableCollision(0, 0, 0);
		}
		INT En = bEnable ? 1 : 0;
		m_collisionBox->EnableCollision(En, En, En);
	}

	// Update crawl/want-to-crawl bitfields at 0x3E0:
	//   bEnable=true  → set bit 20 (0x100000 = IsCrawling), clear bit 27 (0x8000000 = WantsToCrawl)
	//   bEnable=false → clear bit 20, set bit 27
	DWORD Old = *(DWORD*)((BYTE*)this + 0x3E0);
	DWORD NewBits = (((DWORD)(!bEnable ? 1 : 0) << 7) | (bEnable ? 1u : 0u)) << 0x14;
	*(DWORD*)((BYTE*)this + 0x3E0) = NewBits | (Old & 0xF7EFFFFF);

	if (!bEnable)
		ResetColBox();

	m_iMaxRotationOffset = getMaxRotationOffset(bEnable ? 1 : 0);
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x100228b0)
void AR6Pawn::m_vExecuteLipsSynch(FLOAT DeltaTime)
{
	if (Mesh && Mesh->IsA(USkeletalMesh::StaticClass()))
	{
		if (m_hLipSynchData)
			((ECLipSynchData*)m_hLipSynchData)->m_vUpdateLipSynch(DeltaTime);
	}
}

IMPL_MATCH("R6Engine.dll", 0x100228f0)
void AR6Pawn::m_vInitNewLipSynch(USound* pStartSound, USound* pStopSound)
{
	guard(AR6Pawn::m_vInitNewLipSynch);
	if (m_hLipSynchData)
	{
		GMalloc->Free((void*)m_hLipSynchData);
		m_hLipSynchData = 0;
	}
	UMeshInstance* MeshInst = Mesh ? (UMeshInstance*)Mesh->MeshGetInstance(this) : NULL;
	ECLipSynchData* pNew = new ECLipSynchData(MeshInst, pStartSound, pStopSound, (AActor*)this);
	m_hLipSynchData = (INT)pNew;
	pNew->m_vStartLipsynch();
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10025e20)
INT AR6Pawn::moveToPosition(FVector const& Target)
{
	if (!Controller)
		return 0;

	if (Physics != PHYS_Walking)
		return 0;

	FLOAT DX = Target.X - Location.X;
	FLOAT DY = Target.Y - Location.Y;
	FLOAT DZ = 0.0f;

	FLOAT Dist = FVector(DX, DY, DZ).Size();
	FLOAT AbsDist = (Dist < 0.0f) ? -Dist : Dist;

	if (AbsDist >= 10.0f)
	{
		if (Dist > 0.0f)
		{
			FLOAT InvDist = 1.0f / Dist;
			DX *= InvDist;
			DY *= InvDist;
		}

		FLOAT Accel = AccelRate;
		Acceleration.X = Accel * DX;
		Acceleration.Y = Accel * DY;
		Acceleration.Z = Accel * DZ;

		// DIVERGENCE: Controller float at raw offset 0x3BC — unlisted AController field
		// (likely a speed/stall penalty counter); checked against 0 to gate velocity correction.
		FLOAT CtrlField = *(FLOAT*)((BYTE*)Controller + 0x3BC);
		if (CtrlField >= 0.0f)
		{
			FLOAT VelSize = Velocity.Size();
			if (VelSize > 100.0f)
			{
				FLOAT InvVel = 1.0f / VelSize;
				FLOAT VelNX = Velocity.X * InvVel;
				FLOAT VelNY = Velocity.Y * InvVel;
				FLOAT VelNZ = Velocity.Z * InvVel;

				// Perpendicular correction: steer velocity direction toward target.
				// DIVERGENCE: FUN_100015a0 in retail binary scales a vector (out = in * scale);
				// inlined here as component multiply.
				FLOAT DiffX = VelNX - DX, DiffY = VelNY - DY, DiffZ = VelNZ - DZ;
				FLOAT Dot = VelNX * DX + VelNY * DY + VelNZ * DZ;
				FLOAT CorrScale = (1.0f - Dot) * VelSize * 0.2f;
				Acceleration.X -= DiffX * CorrScale;
				Acceleration.Y -= DiffY * CorrScale;
				Acceleration.Z -= DiffZ * CorrScale;

				if (Dist < AvgPhysicsTime * VelSize * 1.4f)
				{
					if (!bReducedSpeed)
					{
						bReducedSpeed = 1;
						DesiredSpeed *= 0.5f;
					}
					if (VelSize > 0.0f)
					{
						// DIVERGENCE: FUN_10024510 in retail binary = Min<FLOAT>(a, b); inlined here.
						FLOAT Cap = 200.0f / VelSize;
						if (DesiredSpeed > Cap)
							DesiredSpeed = Cap;
					}
				}

				if (VelSize == 0.0f)
					return 0;

				*(FLOAT*)((BYTE*)Controller + 0x3BC) -= 0.25f;
				return 0;
			}
			// DIVERGENCE: Controller byte at raw offset 0x3A7 — unlisted AController field
			// (likely an AI arrival/status byte); 2 = near-destination speed-limited.
			*(BYTE*)((BYTE*)Controller + 0x3A7) = 2;
		}
		else
		{
			// Controller penalty counter < 0: cancel acceleration and signal arrival.
			Acceleration = FVector(0.0f, 0.0f, 0.0f);
			*(BYTE*)((BYTE*)Controller + 0x3A7) = 1;
		}
		return 1;
	}
	else
	{
		// Within 10 units of target: stop and signal arrival.
		Acceleration = FVector(0.0f, 0.0f, 0.0f);
		*(BYTE*)((BYTE*)Controller + 0x3A7) = 1;
	}
	return 1;
}

IMPL_MATCH("R6Engine.dll", 0x1002bd50)
INT AR6Pawn::moveToward(FVector const& Dest, AActor* GoalActor)
{
	if (!Controller)
		return 0;
	AR6AIController* AICtrl = Cast<AR6AIController>(Controller);
	if (m_ePawnType != 1 && AICtrl && GoalActor && AICtrl->NeedToOpenDoor(GoalActor))
	{
		AICtrl->GotoOpenDoorState(((AR6Door*)GoalActor)->m_CorrespondingDoor);
		return 1;
	}
	return APawn::moveToward(Dest, GoalActor);
}

IMPL_MATCH("R6Engine.dll", 0x10025300)
void AR6Pawn::performPhysics(FLOAT DeltaTime)
{
	guard(AR6Pawn::performPhysics);

	// If dead/ragdoll (byte 0xA4 bit 5), delegate to base pawn physics
	if (*(BYTE*)((BYTE*)this + 0xA4) & 0x20)
	{
		APawn::performPhysics(DeltaTime);
		return;
	}

	// Grenade/flash effect timer
	if (*(BYTE*)((BYTE*)this + 0x39F) != 0)
	{
		*(FLOAT*)((BYTE*)this + 0x4D0) -= DeltaTime;
		if (*(FLOAT*)((BYTE*)this + 0x4D0) < 0.0f)
		{
			eventEndOfGrenadeEffect(*(BYTE*)((BYTE*)this + 0x39F));
			*(BYTE*)((BYTE*)this + 0x39F) = 0;
			*(FLOAT*)((BYTE*)this + 0x4D0) = 0.0f;
		}
	}

	// Movement noise: fire script event when velocity exceeds threshold
	if (*(FLOAT*)((BYTE*)this + 0x748) < *(FLOAT*)((BYTE*)XLevel + 0x45C))
	{
		*(FLOAT*)((BYTE*)this + 0x748) = *(FLOAT*)((BYTE*)XLevel + 0x45C) + 0.33f;
		FLOAT VelSq = Velocity.X * Velocity.X + Velocity.Y * Velocity.Y + Velocity.Z * Velocity.Z;
		if (VelSq > 1000.0f)
			eventR6MakeMovementNoise();
	}

	if (!(*(DWORD*)((BYTE*)this + 0x3E8) & 0x10) &&
		*(BYTE*)((BYTE*)this + 0x230) == 0 &&
		(*(DWORD*)((BYTE*)this + 0xA8) & 0x40000000) == 0)
	{
		eventFellOutOfWorld();
		return;
	}

	// Save velocity before physics update (used later for rotation)
	FVector PrevVelocity = Velocity;

	// Sync crouched state into flags: bit 5 (0x20) of 0x3E0
	INT bCrouching = APawn::IsCrouched();
	*(DWORD*)((BYTE*)this + 0x3E0) ^= (((DWORD)bCrouching << 5) ^ *(DWORD*)((BYTE*)this + 0x3E0)) & 0x20;

	// Sync shrunken state: bit 9 (0x200) of 0x3E0
	APawn* DefObj = (APawn*)GetClass()->GetDefaultObject();
	INT bShrunken = (CollisionHeight < DefObj->CollisionHeight) ? 1 : 0;
	*(DWORD*)((BYTE*)this + 0x3E0) ^= (((DWORD)bShrunken << 9) ^ *(DWORD*)((BYTE*)this + 0x3E0)) & 0x200;

	BYTE  CurPhysics = Physics;
	DWORD Flags3E0   = *(DWORD*)((BYTE*)this + 0x3E0);

	if (CurPhysics == 1 || CurPhysics == 12)  // PHYS_Walking or PHYS_KarmaRagDoll
	{
		if (!(Flags3E0 & 0x100))  // not want-to-uncrawl
		{
			if ((Flags3E0 & 0x10) && CurPhysics != 12)  // want-to-crouch, not ragdoll
			{
				if (!(Flags3E0 & 0x20))  // not yet crouched
				{
					APawn::Crouch(0);
				}
				else if (Flags3E0 & 0x40)  // crouch timer active
				{
					*(FLOAT*)((BYTE*)this + 0x424) -= DeltaTime;
					if (*(FLOAT*)((BYTE*)this + 0x424) < 0.0f)
						*(DWORD*)((BYTE*)this + 0x3E0) &= 0xFFFFFFAF;
				}
			}
		}
		else if (!(Flags3E0 & 0x200))  // want-to-uncrawl, not crawling
		{
			if (Flags3E0 & 0x20)
				APawn::UnCrouch(0);
			Crawl(0);
		}
		else if (Flags3E0 & 0x400)  // crawl timer active
		{
			*(FLOAT*)((BYTE*)this + 0x424) -= DeltaTime;
			if (*(FLOAT*)((BYTE*)this + 0x424) < 0.0f)
				*(DWORD*)((BYTE*)this + 0x3E0) &= 0xFFFFFAFF;
		}
	}
	else
	{
		if (Flags3E0 & 0x20)
			APawn::UnCrouch(0);
		if (*(DWORD*)((BYTE*)this + 0x3E0) & 0x200)
			UnCrawl(0);
	}

	APawn::startNewPhysics(DeltaTime, 0);
	CurPhysics = Physics;

	// Sync walking/flying flag into 0x3e0 bit 0x1000000
	{
		INT bWalkOrFly = (CurPhysics == 2 || CurPhysics == 1) ? 1 : 0;
		*(DWORD*)((BYTE*)this + 0x3E0) ^= (((DWORD)bWalkOrFly << 24) ^ *(DWORD*)((BYTE*)this + 0x3E0)) & 0x1000000;
	}
	// Post-physics uncrouch if physics changed
	{
		DWORD f3e0 = *(DWORD*)((BYTE*)this + 0x3E0);
		if ((f3e0 & 0x20) != 0 &&
			((CurPhysics != 1 && CurPhysics != 12) || (f3e0 & 0x10) == 0))
			APawn::UnCrouch(0);
		if ((*(DWORD*)((BYTE*)this + 0x3E0) & 0x200) != 0 &&
			(CurPhysics != 1 || (*(DWORD*)((BYTE*)this + 0x3E0) & 0x100) == 0))
			UnCrawl(0);
	}

	// Physics rotation update
	if (Controller)
	{
		*(FLOAT*)((BYTE*)Controller + 0x3BC) -= DeltaTime;
		if (!(*(DWORD*)((BYTE*)this + 0xAC) & 4) && CurPhysics != 13 && CurPhysics != 14)
		{
			UBOOL bRotationCurrent =
				Rotation.Pitch == *(INT*)((BYTE*)this + 0x2FC) &&
				Rotation.Yaw   == *(INT*)((BYTE*)this + 0x300) &&
				Rotation.Roll  == *(INT*)((BYTE*)this + 0x304) &&
				*(INT*)((BYTE*)this + 0x2F8) < 1;

			if (!bRotationCurrent || IsHumanControlled())
			{
				// Call physicsRotation via vtable slot 0x198
				// DIVERGENCE: vtable slot 0x198 = physicsRotation; calling directly for clarity
				physicsRotation(DeltaTime, PrevVelocity);
			}
		}
	}

	// Exponential moving average of frame physics time
	AvgPhysicsTime = AvgPhysicsTime * 0.8f + DeltaTime * 0.2f;

	// Process PostTouch deferred-touch queue
	if (PendingTouch)
	{
		AActor* TouchActor = PendingTouch;
		eventPostTouch(TouchActor);
		PendingTouch = TouchActor->PendingTouch;
		TouchActor->PendingTouch = NULL;
	}

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10027290)
void AR6Pawn::physLadder(FLOAT DeltaTime, INT)
{
	guard(AR6Pawn::physLadder);

	Velocity = FVector(0.0f, 0.0f, 0.0f);

	if (!m_Ladder)
		return;
	if (!Controller)
	{
		// Ghidra: vtable[0x11c/4] fires eventEndClimbLadder when controller is gone
		APawn::eventEndClimbLadder((ALadderVolume*)NULL);
		return;
	}

	// Compute ladder movement speed based on stance
	FLOAT Speed;
	if (!(*(DWORD*)((BYTE*)this + 0x3E0) & 4))  // not-prone-like flag
	{
		// DIVERGENCE: byte at 0x39E = m_bAutoClimbLadders (BYTE); fast-climb when == 1 and descending
		if (*(BYTE*)((BYTE*)this + 0x39E) == 1 && Acceleration.Z < 0.0f)
			Speed = GroundSpeed * 10.0f;
		else
			Speed = GroundSpeed + GroundSpeed;
	}
	else
	{
		Speed = GroundSpeed;
	}

	// Ladder direction vector stored at m_Ladder+0x4A4 (base ALadder ClimbDir field)
	FLOAT LadderX = *(FLOAT*)((BYTE*)m_Ladder + 0x4A4);
	FLOAT LadderY = *(FLOAT*)((BYTE*)m_Ladder + 0x4A8);
	FLOAT LadderZ = *(FLOAT*)((BYTE*)m_Ladder + 0x4AC);

	Velocity.X = Speed * LadderX;
	Velocity.Y = Speed * LadderY;
	Velocity.Z = Speed * LadderZ;

	// Determine movement direction: dot input acceleration against ladder direction
	FLOAT InputDot;
	// DIVERGENCE: offset check at Controller+0xC+0x28 is an unlisted input-state flag
	if (*(INT*)((BYTE*)*(INT*)((BYTE*)Controller + 0xC) + 0x28) == 0)
	{
		InputDot = LadderX * Acceleration.X + LadderY * Acceleration.Y + LadderZ * Acceleration.Z;
	}
	else
	{
		InputDot = Velocity.X + Velocity.Y + Velocity.Z;
	}

	if (InputDot < 0.0f)
	{
		Velocity.X = -Velocity.X;
		Velocity.Y = -Velocity.Y;
		Velocity.Z = -Velocity.Z;
	}

	// Move along ladder: delta = DeltaTime * Velocity
	FLOAT dX = DeltaTime * Velocity.X;
	FLOAT dY = DeltaTime * Velocity.Y;
	FLOAT dZ = DeltaTime * Velocity.Z;

	// DIVERGENCE: XLevel vtable 0x98 = moveSmear/slide for ladder movement
	typedef INT (__fastcall *FSmearFn)(void*, void*, AActor*, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT);
	FSmearFn Smear = *(FSmearFn*)((BYTE*)*(DWORD*)XLevel + 0x98);
	Smear(XLevel, 0, this, Location.X + dX, Location.Y + dY, Location.Z + dZ, 1, 0, 0, 0);

	unguard;
}

IMPL_DIVERGE("FUN_10042934 reads x87 FPU rotation cache (bone angles computed via FPU ops not visible to Ghidra decompiler)")
void AR6Pawn::physicsRotation(FLOAT DeltaTime, FVector InVelocity)
{
	guard(AR6Pawn::physicsRotation);

	INT OldPitch = Rotation.Pitch;
	INT OldYaw   = Rotation.Yaw;
	INT OldRoll  = Rotation.Roll;

	// LocalPhysFlag marks walking/ragdoll physics (non-zero = special treatment)
	FLOAT LocalPhysFlag = 0.0f;
	if (Physics == 1 || Physics == 12)
		LocalPhysFlag = 1.4013e-45f;  // near-zero but non-zero sentinel (FLT_MIN equivalent)

	// Clear rotation-following bit
	*(DWORD*)((BYTE*)this + 0xAC) &= 0xFFFFFFFE;

	INT  RotSpeed = 0;
	INT  bHuman   = IsHumanControlled();

	if (!bHuman)
	{
		// AI: set rotation-follow flag based on whether controller exists
		DWORD bHasCtrl = (Controller != NULL) ? 1u : 0u;
		*(DWORD*)((BYTE*)this + 0xAC) ^= ((bHasCtrl << 1) ^ *(DWORD*)((BYTE*)this + 0xAC)) & 2;

		if ((*(DWORD*)((BYTE*)this + 0xAC) & 2) == 0 ||
			!Controller ||
			*(INT*)((BYTE*)Controller + 0x400) == 0 ||
			*(INT*)((BYTE*)Controller + 0x3E4) != *(INT*)((BYTE*)Controller + 0x400))
		{
			RotSpeed = appRound((FLOAT)*(INT*)((BYTE*)this + 0x2F4) * DeltaTime);
		}
		else
		{
			INT PawnTR = *(INT*)((BYTE*)this + 0x2F4);
			INT CtrlTR = *(INT*)((BYTE*)Controller + 0x2F4);
			INT MaxTR  = (PawnTR > CtrlTR) ? PawnTR : CtrlTR;
			RotSpeed = appRound((FLOAT)MaxTR * DeltaTime);
		}
	}
	else if (Controller)
	{
		// Human: sync rotation-follow flag from controller
		*(DWORD*)((BYTE*)this + 0xAC) ^=
			(*(DWORD*)((BYTE*)Controller + 0xAC) ^ *(DWORD*)((BYTE*)this + 0xAC)) & 2;

		if (*(DWORD*)((BYTE*)this + 0xAC) & 2)
		{
			// FUN_1001bc10 is the IsA walk for AR6PlayerController; for human controllers it
			// always returns Controller unchanged. Read the turn-rate from Controller+0x50C.
			INT LR = *(INT*)((BYTE*)Controller + 0x50C) << 1;
			RotSpeed = appRound((FLOAT)LR * DeltaTime);
			*(DWORD*)((BYTE*)this + 0x2FC) = *(DWORD*)((BYTE*)Controller + 0x2FC);
			*(DWORD*)((BYTE*)this + 0x300) = *(DWORD*)((BYTE*)Controller + 0x300);
		}
	}

	// Apply yaw/pitch rotation when following is enabled and not on ladder
	if (Physics != 11 || !m_Ladder)
	{
		if (*(DWORD*)((BYTE*)this + 0xAC) & 2)
		{
			if (Rotation.Yaw != *(INT*)((BYTE*)this + 0x300))
				Rotation.Yaw = fixedTurn(OldYaw, *(INT*)((BYTE*)this + 0x300), RotSpeed);

			// Clear desired pitch when using walking/ragdoll physics or flying
			if (!(*(DWORD*)((BYTE*)this + 0x3E4) & 0x800) &&
				(LocalPhysFlag != 0.0f || Physics == 2))
			{
				*(INT*)((BYTE*)this + 0x2FC) = 0;
			}

			if (!(*(DWORD*)((BYTE*)this + 0x3E0) & 0x1000) || LocalPhysFlag == 0.0f)
			{
				if (Rotation.Pitch != *(INT*)((BYTE*)this + 0x2FC))
					Rotation.Pitch = fixedTurn(OldPitch, *(INT*)((BYTE*)this + 0x2FC), RotSpeed);
			}

			// Sync controller rotation
			if (Controller && (*(BYTE*)((BYTE*)Controller + 0xAC) & 2))
			{
				*(INT*)((BYTE*)Controller + 0x244) = Rotation.Yaw;
				*(INT*)((BYTE*)Controller + 0x240) = fixedTurn(
					*(INT*)((BYTE*)Controller + 0x240),
					*(INT*)((BYTE*)Controller + 0x2FC),
					RotSpeed);
			}
		}
	}

	// Roll handling
	if (!(*(DWORD*)((BYTE*)this + 0x3E4) & 0x800))
	{
		if (!(*(DWORD*)((BYTE*)this + 0x3E0) & 0x1000))
		{
			if (*(INT*)((BYTE*)this + 0x2F8) < 1)
			{
				Rotation.Roll = 0;
			}
			else if (Physics == 1)  // PHYS_Walking
			{
				FLOAT VelSq = Velocity.X * Velocity.X + Velocity.Y * Velocity.Y + Velocity.Z * Velocity.Z;
				if (VelSq < 40000.0f)
				{
					// Low speed: smoothly zero the roll
					// DIVERGENCE: FUN_10042934 for cached roll; use fixedTurn toward zero
					Rotation.Roll = fixedTurn(OldRoll, 0, RotSpeed);
				}
				else
				{
					// High speed: compute roll from velocity change
					// DIVERGENCE: complex roll-from-acceleration calculation omitted;
					// approximate with simple zero-roll tracking
					Rotation.Roll = fixedTurn(OldRoll, 0, RotSpeed);
				}
			}
			else if (LocalPhysFlag == 0.0f)
			{
				// Non-walking, non-ragdoll physics (e.g. flying): zero yaw+roll
				// DIVERGENCE: FUN_10042934 for desired orientation; approximate with zeros
				Rotation.Yaw  = fixedTurn(OldYaw,  0, RotSpeed);
				Rotation.Roll = fixedTurn(OldRoll, 0, RotSpeed);
			}
			// Other physics (ladder etc.): no roll update
		}
	}

	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
