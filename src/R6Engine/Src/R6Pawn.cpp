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

INT AR6Pawn::AdjustFluidCollisionCylinder(FLOAT, INT)
{
	return 0;
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
	return 0;
}

INT AR6Pawn::IsRelevantToPawnHeatVision(APawn *)
{
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
}

INT AR6Pawn::SetAudioInfo()
{
	return 0;
}

void AR6Pawn::SetPawnLookAndAimDirection(FRotator, INT)
{
}

void AR6Pawn::SetPawnLookDirection(FRotator, INT)
{
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

void AR6Pawn::UnCrawl(INT)
{
}

void AR6Pawn::UpdateColBox(FVector &, INT, INT, INT)
{
}

FLOAT AR6Pawn::UpdateColBoxPeeking(FLOAT)
{
	return 0.f;
}

void AR6Pawn::UpdateFullPeekingMode(FLOAT)
{
}

void AR6Pawn::UpdateMovementAnimation(FLOAT)
{
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

void AR6Pawn::UpdatePeeking(FLOAT)
{
}

void AR6Pawn::WeaponFollow(INT, FLOAT)
{
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

void AR6Pawn::WeaponLock(INT, FLOAT, FLOAT)
{
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

void AR6Pawn::calcVelocity(FVector, FLOAT, FLOAT, FLOAT, INT, INT, INT)
{
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

void AR6Pawn::initCrawlMode(bool)
{
}

void AR6Pawn::m_vExecuteLipsSynch(FLOAT DeltaTime)
{
	if (Mesh && Mesh->IsA(USkeletalMesh::StaticClass()))
	{
		if (m_hLipSynchData)
			((ECLipSynchData*)m_hLipSynchData)->m_vUpdateLipSynch(DeltaTime);
	}
}

void AR6Pawn::m_vInitNewLipSynch(USound *, USound *)
{
}

INT AR6Pawn::moveToPosition(FVector const &)
{
	return 0;
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

void AR6Pawn::performPhysics(FLOAT)
{
}

void AR6Pawn::physLadder(FLOAT, INT)
{
}

void AR6Pawn::physicsRotation(FLOAT, FVector)
{
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
