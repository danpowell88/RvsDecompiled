/*=============================================================================
	R6Pawn.cpp
	AR6Pawn — R6 pawn base class: movement, peeking, aiming, lip synch,
	collision, animation state, heartbeat sensor, ragdoll spawning.
=============================================================================*/

#include "R6EnginePrivate.h"

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

FVector AR6Pawn::CheckForLedges(AActor *, FVector, FVector, FVector, INT &, INT &, FLOAT)
{
	return FVector(0,0,0);
}

INT AR6Pawn::CheckLineOfSight(AActor *, FVector &, INT, AActor *, FVector &, AActor *, FVector &)
{
	return 0;
}

DWORD AR6Pawn::CheckSeePawn(AR6Pawn *, FVector &, INT)
{
	return 0;
}

FLOAT AR6Pawn::ComputeCrouchBlendRate(FLOAT TargetHeight, FLOAT OtherHeight)
{
	FLOAT Result = Abs((CollisionHeight - TargetHeight) / (TargetHeight - OtherHeight));
	if (Result < 0.0f)
		return 0.0f;
	if (Result > 1.0f)
		Result = 1.0f;
	return Result;
}

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
	if (*(INT*)((BYTE*)this + 0x140) == 0)
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

	// Nudge pawn to settle into final crawl position (zero-velocity smear move)
	// DIVERGENCE: XLevel vtable 0x98 = moveSmear/slide actor
	typedef INT (__fastcall *FSmearFn)(void*, void*, AActor*, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT);
	FSmearFn Smear = *(FSmearFn*)((BYTE*)*(DWORD*)XLevel + 0x98);
	Smear(XLevel, 0, this, Location.X, Location.Y, Location.Z, 1, 0, 0, 0);

	unguard;
}

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

BYTE AR6Pawn::GetCurrentMaterial()
{
	return 0;
}

void AR6Pawn::GetDefaultHeightAndRadius(FLOAT& OutHeight, FLOAT& OutCrouchHeight, FLOAT& OutRadius)
{
	AActor* Default = (AActor*)GetClass()->GetDefaultObject();
	OutHeight = Default->CollisionHeight;
	OutRadius = Default->CollisionRadius;
	OutCrouchHeight = ((APawn*)Default)->CrouchHeight;
}

FVector AR6Pawn::GetFootLocation(AActor *)
{
	return FVector(0,0,0);
}

FVector AR6Pawn::GetHeadLocation(AActor *)
{
	return FVector(0,0,0);
}

FLOAT AR6Pawn::GetMaxFluidPeeking(FLOAT SpeedRatio, INT bReverse)
{
	FLOAT Ratio = GetPeekingRatioNorm(1600.0f);
	FLOAT Value = ((1.0f - SpeedRatio) * (1.0f - Ratio) + Ratio) * 1000.0f;
	if (bReverse)
		return 1000.0f - Value;
	return Value + 1000.0f;
}

FVector AR6Pawn::GetMidSectionLocation(AActor *)
{
	return FVector(0,0,0);
}

enum eMovementDirection AR6Pawn::GetMovementDirection()
{
	return (enum eMovementDirection)0;
}

FLOAT AR6Pawn::GetPeekingRatioNorm(FLOAT PeekingValue)
{
	return (PeekingValue - 1000.0f) * 0.001f;
}

INT AR6Pawn::GetRotValueCenteredAroundZero(INT Value)
{
	if (Value > 0x8000)
		return Value - 0x10000;
	if (Value < -0x8000)
		Value = Value + 0x10000;
	return Value;
}

FRotator AR6Pawn::GetRotationOffset()
{
	if (m_bIsPlayer)
		return m_rRotationOffset;
	// AI pawns return previous offset (original may add jitter)
	return m_rPrevRotationOffset;
}

BYTE AR6Pawn::GetSoundGunType(INT InType)
{
	// AZoneInfo bitfield at offset 0x398: bit 4 = m_bInDoor (auto-generated field)
	BYTE ZoneBits = ((BYTE*)Region.Zone)[0x398];
	if (InType != 0)
		return (ZoneBits >> 4) & 1;	// Raw indoor flag: 0=outdoor, 1=indoor
	return ((ZoneBits & 0x10) | 0x20) >> 4;	// Gun sound type: 2=outdoor, 3=indoor
}

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

FRotator AR6Pawn::GetViewRotation()
{
	return FRotator(0,0,0);
}

// Verified from Ghidra: function at 0x193c0 just returns 0.
INT AR6Pawn::HurtByVolume(AActor *)
{
	return 0;
}

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

INT AR6Pawn::IsOverLedge(AActor *, FVector, FLOAT)
{
	return 0;
}

INT AR6Pawn::IsRelevantToPawnHeartBeat(APawn *)
{
	// DIVERGENCE: remains stub — depends on FUN_1001bc10/FUN_1001bc70/FUN_1001bc40,
	// which are internal R6 gadget/sensor accessor functions not yet decompiled.
	return 0;
}

INT AR6Pawn::IsRelevantToPawnHeatVision(APawn *)
{
	// DIVERGENCE: remains stub — depends on same unresolved gadget accessor functions
	// (FUN_1001bc10, FUN_1001bc70, FUN_1001bc40) as IsRelevantToPawnHeartBeat.
	return 0;
}

INT AR6Pawn::IsUsingHeartBeatSensor()
{
	if (m_bIsPlayer && EngineWeapon)
	{
		if (EngineWeapon->eventIsGoggles())
			return 1;
	}
	return 0;
}

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

void AR6Pawn::PawnSetBoneRotation(FName BoneName, INT Pitch, INT Yaw, INT Roll, FLOAT Alpha)
{
	guard(AR6Pawn::PawnSetBoneRotation);
	USkeletalMeshInstance* MeshInst = (USkeletalMeshInstance*)Mesh->MeshGetInstance(this);
	MeshInst->SetBoneRotation(BoneName, FRotator(Pitch, Yaw, Roll), 0, 1.0f, Alpha);
	unguard;
}

void AR6Pawn::PawnTrackActor(AActor* InActor, INT bShouldAim)
{
	m_bAim = bShouldAim;
	m_TrackActor = InActor;
	UpdatePawnTrackActor(1);
}

INT AR6Pawn::PickActorAdjust(AActor *)
{
	return 0;
}

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

void AR6Pawn::PreNetReceive()
{
	GR6Pawn_OldNetActionIndex = m_iNetCurrentActionIndex;
	GR6Pawn_OldSoundRepInfo = m_SoundRepInfo;
	APawn::PreNetReceive();
}

DWORD AR6Pawn::R6LineOfSightTo(AActor *, INT)
{
	return 0;
}

DWORD AR6Pawn::R6SeePawn(APawn *, INT)
{
	return 0;
}

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

	m_rLFinger0          = FRotator(0, 0, 0);
	m_fPrePivotLastUpdate = 0.0f;
}

INT AR6Pawn::SetAudioInfo()
{
	return 0;
}

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

void AR6Pawn::SetPrePivot(FVector NewPrePivot)
{
	PrePivot = NewPrePivot;
	if (PrePivot.Z == m_fPrePivotPawnInitialOffset && m_bIsClimbingStairs)
		PrePivot.Z -= 5.0f;
}

void AR6Pawn::TickSpecial(FLOAT DeltaTime)
{
	APawn::TickSpecial(DeltaTime);
}

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

void AR6Pawn::UpdateColBox(FVector& NewLocation, INT p1, INT p2, INT p3)
{
	guard(AR6Pawn::UpdateColBox);
	// DIVERGENCE: UpdateColBox is a 200+ line function managing collision box repositioning,
	// skeletal bone attachment updates, and PrePivot corrections. Full implementation
	// requires complete Ghidra pseudocode not available here. Approximate: sync colbox
	// to pawn location via ResetColBox.
	if (m_collisionBox)
		ResetColBox();
	unguard;
}

FLOAT AR6Pawn::UpdateColBoxPeeking(FLOAT)
{
	return 0.f;
}

void AR6Pawn::UpdateFullPeekingMode(FLOAT DeltaTime)
{
	guard(AR6Pawn::UpdateFullPeekingMode);

	DWORD bIsOver = eventIsFullPeekingOver();

	if (bIsOver != 0)
	{
		// Full peeking has ended
		// DIVERGENCE: raw bit check at this+0x3E8 bit 4; approximated with m_bWantsToProne
		if (!m_bWantsToProne)
			return;

		// If still moving (and not in special follow mode), don't transition yet
		if ((Velocity.X != 0.0f || Velocity.Y != 0.0f || Velocity.Z != 0.0f) &&
			(*(DWORD*)((BYTE*)this + 0xAC) & 2) == 0)
			return;

		// Use current peeking as target (return-to-centre)
		*(FLOAT*)((BYTE*)this + 0x734) = UpdateColBoxPeeking(*(FLOAT*)((BYTE*)this + 0x734));
		return;
	}

	// Peeking still active: determine target peeking value
	FLOAT TargetPeeking;
	DWORD bFreeAim = (*(DWORD*)((BYTE*)this + 0x3E0) >> 5) & 1;
	if (bFreeAim == 0 || (*(DWORD*)((BYTE*)this + 0x6C4) & 0x2000000) != 0)
	{
		TargetPeeking = *(FLOAT*)((BYTE*)this + 0x730);
	}
	else
	{
		// Free-aim: clamp peek goal to [400, 1600]
		FLOAT Goal = *(FLOAT*)((BYTE*)this + 0x730);
		if (Goal < 400.0f)
			TargetPeeking = 400.0f;
		else if (Goal < 1600.0f)
			TargetPeeking = Goal;
		else
			TargetPeeking = 1600.0f;
	}

	*(FLOAT*)((BYTE*)this + 0x734) = UpdateColBoxPeeking(TargetPeeking);
	unguard;
}

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

	// DIVERGENCE: 400+ line animation state machine (movement direction, physics stance,
	// bone modification) not implemented; requires full Ghidra pseudocode.
	unguard;
}

void AR6Pawn::UpdatePawnTrackActor(INT BlendTime)
{
	FVector Dir = m_TrackActor->Location - Location;
	FRotator LookRot = Dir.Rotation();
	FRotator RelRot(LookRot.Pitch - Rotation.Pitch,
					LookRot.Yaw - Rotation.Yaw,
					LookRot.Roll - Rotation.Roll);

	if (m_bAim)
		SetPawnLookAndAimDirection(RelRot, BlendTime);
	else
		SetPawnLookDirection(RelRot, BlendTime);
}

void AR6Pawn::UpdatePeeking(FLOAT DeltaTime)
{
	if (!m_collisionBox)
		return;

	if (!m_bWantsToProne && !m_bIsProne)
	{
		BYTE PeekingMode = m_ePeekingMode;

		// Mode 0: no active peeking. If peeking has returned to centre (sentinel 1000.0f),
		// disable the colbox collision so it no longer blocks actors.
		if (PeekingMode == 0 && m_fPeeking == 1000.0f)
		{
			// DIVERGENCE: AR6ColBox flag at raw offset 0x394 — an unlisted field inside
			// AR6ColBox that gates whether the colbox reset should proceed.
			if ((*(BYTE*)((BYTE*)m_collisionBox + 0x394) & 1) == 0)
				return;

			// Skip on pure clients when not the owning client.
			// NM_Client == 3 (ENetMode enum is not defined in project headers).
			if (!APawn::IsLocallyControlled() && Level->NetMode == 3)
				return;

			m_collisionBox->EnableCollision(0, 0, 0);
			return;
		}

		if (PeekingMode == 1 && !m_bPeekingReturnToCenter)
		{
			// Full peeking active with no pending return-to-centre: fall through to
			// UpdateFullPeekingMode below.
		}
		else
		{
			if (PeekingMode != 2)
				return;

			// Fluid (analogue) peeking mode.
			FLOAT OldPeeking  = m_fPeeking;
			m_fPeeking        = m_fPeekingGoal;

			AdjustFluidCollisionCylinder(m_fCrouchBlendRate, 0);

			FLOAT Limit = GetMaxFluidPeeking(m_fCrouchBlendRate, (INT)m_bHBJammerOn);
			Limit       = AdjustMaxFluidPeeking(m_fPeeking, Limit);
			m_fPeeking  = Limit;

			if (OldPeeking != Limit)
			{
				// Peeking value changed — update the colbox immediately.
				m_fPeeking = UpdateColBoxPeeking(Limit);
				return;
			}

			// Peeking value unchanged. Only continue (and update the colbox) when a
			// flashbang visual effect is in progress; that can shift the apparent lean.
			if (!m_bFlashBangVisualEffectRequested)
				return;

			// DIVERGENCE: Ghidra has an additional guard here — a velocity-against-zero
			// check (Velocity.X vs 0) combined with an actor bitfield at raw offset 0xAC
			// bit 1. The full condition was truncated in the Ghidra decompilation and is
			// omitted; we proceed to UpdateColBoxPeeking unconditionally.
			m_fPeeking = UpdateColBoxPeeking(Limit);
			return;
		}
	}
	else
	{
		// Prone or transitioning to prone. Only call UpdateFullPeekingMode in full-peek mode.
		if (m_ePeekingMode != 1)
			return;
	}

	UpdateFullPeekingMode(DeltaTime);
}

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

INT AR6Pawn::WeaponShouldFollowHead()
{
	// Physics == 12 is PHYS_KarmaRagDoll
	if (Physics == 12 || m_bIsClimbingLadder)
		return 0;
	if (IsUsingHeartBeatSensor() || m_fFiringTimer > 0.0f)
		return 1;
	return m_bWeaponGadgetActivated ? 1 : 0;
}

INT AR6Pawn::actorReachableFromLocation(AActor *, FVector)
{
	return 0;
}

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

	APawn::calcVelocity(Accel, BrakingDecel, Friction, OverrideSpeed, bFluid, bRestricted, bWaterJump);
}

void AR6Pawn::eventAdjustPawnForDiagonalStrafing()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_AdjustPawnForDiagonalStrafing), NULL);
}

void AR6Pawn::eventEndCrawl()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_EndCrawl), NULL);
}

void AR6Pawn::eventEndOfGrenadeEffect(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_EndOfGrenadeEffect), &Parms);
}

void AR6Pawn::eventEndPeekingMode(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_EndPeekingMode), &Parms);
}

FVector AR6Pawn::eventGetFiringStartPoint()
{
	struct {
		FVector ReturnValue;
	} Parms;
	Parms.ReturnValue = FVector(0,0,0);
	ProcessEvent(FindFunctionChecked(R6ENGINE_GetFiringStartPoint), &Parms);
	return Parms.ReturnValue;
}

FLOAT AR6Pawn::eventGetStanceReticuleModifier()
{
	struct {
		FLOAT ReturnValue;
	} Parms;
	Parms.ReturnValue = 0.f;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GetStanceReticuleModifier), &Parms);
	return Parms.ReturnValue;
}

void AR6Pawn::eventInitBiPodPosture(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_InitBiPodPosture), &Parms);
}

DWORD AR6Pawn::eventIsFullPeekingOver()
{
	struct {
		DWORD ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	ProcessEvent(FindFunctionChecked(R6ENGINE_IsFullPeekingOver), &Parms);
	return Parms.ReturnValue;
}

DWORD AR6Pawn::eventIsPeekingLeft()
{
	struct {
		DWORD ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	ProcessEvent(FindFunctionChecked(R6ENGINE_IsPeekingLeft), &Parms);
	return Parms.ReturnValue;
}

void AR6Pawn::eventPlayCrouchToProne(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayCrouchToProne), &Parms);
}

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

void AR6Pawn::eventPlayPeekingAnim(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayPeekingAnim), &Parms);
}

void AR6Pawn::eventPlayProneToCrouch(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayProneToCrouch), &Parms);
}

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

void AR6Pawn::eventPlaySurfaceSwitch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlaySurfaceSwitch), NULL);
}

void AR6Pawn::eventPotentialOpenDoor(AR6Door * A)
{
	struct { AR6Door * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PotentialOpenDoor), &Parms);
}

void AR6Pawn::eventR6MakeMovementNoise()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_R6MakeMovementNoise), NULL);
}

void AR6Pawn::eventR6ResetLookDirection()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_R6ResetLookDirection), NULL);
}

void AR6Pawn::eventRemovePotentialOpenDoor(AR6Door * A)
{
	struct { AR6Door * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_RemovePotentialOpenDoor), &Parms);
}

void AR6Pawn::eventResetBipodPosture()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ResetBipodPosture), NULL);
}

void AR6Pawn::eventResetDiagonalStrafing()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ResetDiagonalStrafing), NULL);
}

void AR6Pawn::eventSetCrouchBlend(FLOAT A)
{
	struct { FLOAT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetCrouchBlend), &Parms);
}

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

void AR6Pawn::eventSpawnRagDoll()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SpawnRagDoll), NULL);
}

void AR6Pawn::eventStartCrawl()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartCrawl), NULL);
}

void AR6Pawn::eventStartFluidPeeking()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartFluidPeeking), NULL);
}

void AR6Pawn::eventStartFullPeeking()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartFullPeeking), NULL);
}

void AR6Pawn::eventTurnToFaceActor(AActor * A)
{
	struct { AActor * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_TurnToFaceActor), &Parms);
}

void AR6Pawn::eventUpdateBipodPosture()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_UpdateBipodPosture), NULL);
}

void AR6Pawn::execAdjustFluidCollisionCylinder(FFrame& Stack, RESULT_DECL)
{
	P_GET_FLOAT(fBlendRate);
	P_GET_UBOOL(bTest);
	P_FINISH;
	*(DWORD*)Result = AdjustFluidCollisionCylinder(fBlendRate, bTest);
}

void AR6Pawn::execCheckCylinderTranslation(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vStart);
	P_GET_STRUCT(FVector, vDest);
	P_GET_OBJECT(AActor, ignoreActor1);
	P_GET_UBOOL(bIgnoreAllActor1Class);
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AR6Pawn::execFootStep(FFrame& Stack, RESULT_DECL)
{
	P_GET_NAME(nBoneName);
	P_GET_UBOOL(bLeftFoot);
	P_FINISH;
	// TODO: decal/trace footstep effect — complex inline sound/decal logic (see Ghidra)
}

void AR6Pawn::execGetKillResult(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(iKillDamage);
	P_GET_INT(ePartHit);
	P_GET_INT(eArmorType);
	P_GET_INT(iBulletToArmorModifier);
	P_GET_UBOOL(bHitBySilencedWeapon);
	P_FINISH;
	*(BYTE*)Result = 0;
}

void AR6Pawn::execGetMaxRotationOffset(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(INT*)Result = getMaxRotationOffset((m_bWantsToProne || m_bIsProne) ? 1 : 0);
}

void AR6Pawn::execGetMovementDirection(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(BYTE*)Result = (BYTE)GetMovementDirection();
}

void AR6Pawn::execGetPeekingRatioNorm(FFrame& Stack, RESULT_DECL)
{
	P_GET_FLOAT(fPeeking);
	P_FINISH;
	*(FLOAT*)Result = GetPeekingRatioNorm(fPeeking);
}

void AR6Pawn::execGetRotationOffset(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FRotator*)Result = GetRotationOffset();
}

void AR6Pawn::execGetStunResult(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(iStunDamage);
	P_GET_INT(ePartHit);
	P_GET_INT(eArmorType);
	P_GET_INT(iBulletToArmorModifier);
	P_GET_UBOOL(bHitBySilencedWeapon);
	P_FINISH;
	*(BYTE*)Result = 0;
}

void AR6Pawn::execGetThroughResult(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(iKillDamage);
	P_GET_INT(ePartHit);
	P_GET_STRUCT(FVector, vBulletDirection);
	P_FINISH;
	*(INT*)Result = 0;
}

void AR6Pawn::execMoveHitBone(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FRotator, rHitDirection);
	P_GET_INT(iHitBone);
	P_FINISH;
	// TODO: drives hit-reaction bone rotation via USkeletalMeshInstance::SetBoneRotation (see Ghidra)
}

void AR6Pawn::execPawnCanBeHurtFrom(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vLocation);
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AR6Pawn::execPawnLook(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FRotator, rLookDir);
	P_GET_UBOOL(bAim);
	P_GET_UBOOL(bNoBlend);
	P_FINISH;
	PawnLook(rLookDir, bAim, bNoBlend);
}

void AR6Pawn::execPawnLookAbsolute(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FRotator, rLookDir);
	P_GET_UBOOL(bAim);
	P_GET_UBOOL(bNoBlend);
	P_FINISH;
	PawnLookAbsolute(rLookDir, bAim, bNoBlend);
}

void AR6Pawn::execPawnLookAt(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vTarget);
	P_GET_UBOOL(bAim);
	P_GET_UBOOL(bNoBlend);
	P_FINISH;
	PawnLookAt(vTarget, bAim, bNoBlend);
}

void AR6Pawn::execPawnTrackActor(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, Target);
	P_GET_UBOOL(bAim);
	P_FINISH;
	PawnTrackActor(Target, bAim);
}

void AR6Pawn::execPlayVoices(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(USound, sndPlayVoice);
	P_GET_BYTE(eSlotUse);
	P_GET_INT(iPriority);
	P_GET_BYTE(eSend);
	P_GET_UBOOL(bWaitToFinishSound);
	P_GET_FLOAT(fTime);
	P_FINISH;
	// TODO: routes voice through player controller sound priority system (see Ghidra)
}

void AR6Pawn::execR6GetViewRotation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FRotator*)Result = GetViewRotation();
}

void AR6Pawn::execSendPlaySound(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(USound, S);
	P_GET_BYTE(ID);
	P_GET_UBOOL(bDoNotPlayLocallySound);
	P_FINISH;
	// TODO: calls SetAudioInfo then replicates sound to all player controllers (see Ghidra)
}

void AR6Pawn::execSetAudioInfo(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	SetAudioInfo();
}

void AR6Pawn::execSetPawnScale(FFrame& Stack, RESULT_DECL)
{
	P_GET_FLOAT(fNewScale);
	P_FINISH;
	SetDrawScale(fNewScale);
}

void AR6Pawn::execStartLipSynch(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(USound, _hSound);
	P_GET_OBJECT(USound, _hStopSound);
	P_FINISH;
	m_vInitNewLipSynch(_hSound, _hStopSound);
}

void AR6Pawn::execStopLipSynch(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	if (m_hLipSynchData)
		((ECLipSynchData*)m_hLipSynchData)->m_vStopLipsynch();
}

void AR6Pawn::execToggleHeatProperties(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL(bTurnItOn);
	P_GET_OBJECT(UTexture, pMaskTexture);
	P_GET_OBJECT(UTexture, pAddTexture);
	P_FINISH;
	// TODO: applies/removes thermal-vision viewport texture properties (see Ghidra)
}

void AR6Pawn::execToggleNightProperties(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL(bTurnItOn);
	P_GET_OBJECT(UTexture, pMaskTexture);
	P_GET_OBJECT(UTexture, pAddTexture);
	P_FINISH;
	// TODO: sets GNightVisionActive and applies night-vision viewport textures (see Ghidra)
}

void AR6Pawn::execToggleScopeProperties(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL(bTurnItOn);
	P_GET_OBJECT(UTexture, pMaskTexture);
	P_GET_OBJECT(UTexture, pAddTexture);
	P_FINISH;
	// TODO: applies/removes weapon-scope viewport overlay textures (see Ghidra)
}

void AR6Pawn::execUpdatePawnTrackActor(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL(bNoBlend);
	P_FINISH;
	UpdatePawnTrackActor(bNoBlend);
}

INT AR6Pawn::getMaxRotationOffset(INT InProne)
{
	if (InProne == 0)
		return 0x1555;

	// Check weapon has bipod (byte at weapon+0x3A0, bit 1)
	if (EngineWeapon != NULL && (*(BYTE*)((BYTE*)EngineWeapon + 0x3A0) & 2) != 0)
		return 0x15E0;

	return 3000;
}

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

void AR6Pawn::m_vExecuteLipsSynch(FLOAT DeltaTime)
{
	if (Mesh && Mesh->IsA(USkeletalMesh::StaticClass()))
	{
		if (m_hLipSynchData)
			((ECLipSynchData*)m_hLipSynchData)->m_vUpdateLipSynch(DeltaTime);
	}
}

void AR6Pawn::m_vInitNewLipSynch(USound* pStartSound, USound* pStopSound)
{
	guard(AR6Pawn::m_vInitNewLipSynch);
	if (m_hLipSynchData)
	{
		GMalloc->Free((void*)m_hLipSynchData);
		m_hLipSynchData = 0;
	}
	// Allocate ECLipSynchData (size 0x18 = 24 bytes) via global new
	UMeshInstance* MeshInst = Mesh ? (UMeshInstance*)Mesh->MeshGetInstance(this) : NULL;
	// DIVERGENCE: ECLipSynchData constructor param order uncertain from Ghidra;
	// using (MeshInst, pStartSound, pStopSound, this) based on execStartLipSynch call site.
	ECLipSynchData* pNew = new ECLipSynchData(MeshInst, pStartSound, pStopSound, (AActor*)this);
	m_hLipSynchData = (INT)pNew;
	if (pNew)
		pNew->m_vStartLipsynch();
	unguard;
}

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

	// DIVERGENCE: out-of-world Z check uses raw offset 0x230 in Ghidra (uncertain field);
	// using Location.Z as approximation.
	if (!(*(DWORD*)((BYTE*)this + 0x3E8) & 0x10) &&
		Location.Z == 0.0f &&
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

void AR6Pawn::physLadder(FLOAT DeltaTime, INT)
{
	guard(AR6Pawn::physLadder);

	Velocity = FVector(0.0f, 0.0f, 0.0f);

	if (!m_Ladder || !Controller)
		return;

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

	// Move along ladder: delta = DeltaTime * Velocity (Ghidra shows X/Z swap)
	FLOAT dX = DeltaTime * Velocity.Z;
	FLOAT dY = DeltaTime * Velocity.Y;
	FLOAT dZ = DeltaTime * Velocity.X;

	// DIVERGENCE: XLevel vtable 0x98 = moveSmear/slide for ladder movement
	typedef INT (__fastcall *FSmearFn)(void*, void*, AActor*, FLOAT, FLOAT, FLOAT, INT, INT, INT, INT);
	FSmearFn Smear = *(FSmearFn*)((BYTE*)*(DWORD*)XLevel + 0x98);
	Smear(XLevel, 0, this, Location.X + dX, Location.Y + dY, Location.Z + dZ, 1, 0, 0, 0);

	unguard;
}

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
			// DIVERGENCE: FUN_1001bc10 on Controller is an unknown accessor; approximate
			// TurnRate from offset 0x50C (RotationRate or similar stored field).
			INT LR = *(INT*)((BYTE*)this + 0x50C);
			RotSpeed = appRound((FLOAT)(LR << 1) * DeltaTime);
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
