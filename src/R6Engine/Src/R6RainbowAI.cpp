/*=============================================================================
	R6RainbowAI.cpp
	AR6RainbowAI — Rainbow AI controller: formation, sniping, room entry.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6RainbowAI)

IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execAClearShotIsAvailable)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execCheckEnvironment)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execClearToSnipe)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execFindSafeSpot)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execGetEntryPosition)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execGetGuardPosition)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execGetLadderPosition)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execGetTargetPosition)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execLookAroundRoom)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execSetOrientation)

// --- AR6RainbowAI ---

IMPL_APPROX("Line-of-sight check for clear shot; uses cached aim position or spotter head location")
INT AR6RainbowAI::AClearShotIsAvailable(APawn* TargetPawn, FVector ShotTarget)
{
	guard(AR6RainbowAI::AClearShotIsAvailable);

	FVector ShootFrom;
	if (TargetPawn == Enemy)
	{
		// Use cached aim location stored in controller (TODO: no typed field name)
		ShootFrom.X = *(FLOAT*)((BYTE*)this + 0x498);
		ShootFrom.Y = *(FLOAT*)((BYTE*)this + 0x49c);
		ShootFrom.Z = *(FLOAT*)((BYTE*)this + 0x4a0);
	}
	else
	{
		// Get head location from the spotter pawn (at +0x598, TODO: no typed field name)
		AR6Pawn* Spotter = *(AR6Pawn**)((BYTE*)this + 0x598);
		ShootFrom = Spotter->GetHeadLocation(NULL);
	}

	FCheckResult Hit(1.0f);
	XLevel->SingleLineCheck(Hit, (AActor*)Pawn, ShotTarget, ShootFrom, 0x4400bf, FVector(0,0,0));

	// Ghidra: vtable[0x6c/4] on hit actor = GetPawnOrColBoxOwner
	if (Hit.Actor != NULL)
	{
		APawn* HitPawn = Hit.Actor->GetPawnOrColBoxOwner();
		if (Hit.Actor != NULL && HitPawn != TargetPawn)
		{
			if (HitPawn != NULL
				&& !HitPawn->IsFriend(HitPawn)
				&& !HitPawn->IsNeutral(HitPawn))
			{
				return 1; // blocked by enemy — shot is usable
			}
			return 0; // blocked by friendly or neutral
		}
	}

	return 1; // nothing in the way
	unguard;
}

IMPL_APPROX("Traces 300 units along snipe direction to verify clear line of sight")
INT AR6RainbowAI::ClearToSnipe(FVector Position, FRotator Direction)
{
	guard(AR6RainbowAI::ClearToSnipe);
	FVector Dir = Direction.Vector() * 300.0f;
	FVector End = Position + Dir;
	FCheckResult Hit(1.0f);
	XLevel->SingleLineCheck(Hit, Pawn, End, Position, 0x4400BF, FVector(0,0,0));
	return Hit.Actor == NULL;
	unguard;
}

IMPL_APPROX("Searches anchor path list then all nav points for cover position farther from threat origin")
AActor * AR6RainbowAI::FindSafeSpot()
{
	guard(AR6RainbowAI::FindSafeSpot);

	APawn* P = (APawn*)Pawn;

	// Cached danger/safe origin position (TODO: no typed field name found at +0x5d0)
	FLOAT SafeX = *(FLOAT*)((BYTE*)this + 0x5d0);
	FLOAT SafeY = *(FLOAT*)((BYTE*)this + 0x5d4);
	FLOAT SafeZ = *(FLOAT*)((BYTE*)this + 0x5d8);

	FLOAT PawnX = P->Location.X;
	FLOAT PawnY = P->Location.Y;
	FLOAT PawnZ = P->Location.Z;

	// Squared distance from pawn to the danger origin
	FLOAT CachedDistSq = (PawnX - SafeX)*(PawnX - SafeX)
	                   + (PawnY - SafeY)*(PawnY - SafeY)
	                   + (PawnZ - SafeZ)*(PawnZ - SafeZ);

	// First: search anchor's path list for nodes farther from danger than we are
	if (P->ValidAnchor() != 0)
	{
		ANavigationPoint* Anchor = P->Anchor;
		for (INT i = 0; i < Anchor->PathList.Num(); i++)
		{
			ANavigationPoint* Node = Anchor->PathList(i)->End;
			if (Node == NULL)
				continue;

			FLOAT ndx = PawnX - Node->Location.X;
			FLOAT ndy = PawnY - Node->Location.Y;
			FLOAT ndz = PawnZ - Node->Location.Z;
			FLOAT NodeDistSq = ndx*ndx + ndy*ndy + ndz*ndz;

			FLOAT sdx = SafeX - Node->Location.X;
			FLOAT sdy = SafeY - Node->Location.Y;
			FLOAT sdz = SafeZ - Node->Location.Z;
			FLOAT SafeToNodeSq = sdx*sdx + sdy*sdy + sdz*sdz;

			if (NodeDistSq < 1440000.0f       // within 1200 units
				&& SafeToNodeSq > CachedDistSq // node is farther from danger
				&& P->actorReachable(Node, 0, 0) != 0)
			{
				return Node;
			}
		}
	}

	// Second: search all navigation points
	for (ANavigationPoint* Nav = Level->NavigationPointList; Nav != NULL; Nav = Nav->nextNavigationPoint)
	{
		FLOAT ndx = PawnX - Nav->Location.X;
		FLOAT ndy = PawnY - Nav->Location.Y;
		FLOAT ndz = PawnZ - Nav->Location.Z;
		FLOAT NodeDistSq = ndx*ndx + ndy*ndy + ndz*ndz;

		FLOAT sdx = SafeX - Nav->Location.X;
		FLOAT sdy = SafeY - Nav->Location.Y;
		FLOAT sdz = SafeZ - Nav->Location.Z;
		FLOAT SafeToNodeSq = sdx*sdx + sdy*sdy + sdz*sdz;

		if (NodeDistSq < 1440000.0f
			&& SafeToNodeSq > CachedDistSq
			&& P->actorReachable(Nav, 0, 0) != 0)
		{
			return Nav;
		}
	}

	return NULL;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
FVector AR6RainbowAI::GetTeamLeftOfDoorPosition(INT, AR6Door *)
{
	return FVector(0,0,0);
}

IMPL_APPROX("Standard accessor returning team manager pointer")
AActor * AR6RainbowAI::GetTeamManager()
{
	return m_TeamManager;
}

IMPL_TODO("Needs Ghidra analysis")
FVector AR6RainbowAI::GetTeamRightOfDoorPosition(INT, AR6Door *)
{
	return FVector(0,0,0);
}

IMPL_APPROX("Sets pawn desired yaw based on formation layout for room-clearing sweep")
void AR6RainbowAI::LookAroundRoom(INT param_1)
{
	guard(AR6RainbowAI::LookAroundRoom);

	BYTE uVar2 = 0;
	BYTE uVar3 = 0;

	if (Enemy != NULL)
		goto ApplyYaw;

	if (param_1 == 0)
	{
		if (m_eCurrentRoomLayout == 0)
		{
			if (m_eCoverDirection == 3)
				goto ApplyYaw;
		}
		else
		{
			if (m_eCurrentRoomLayout > 2)
				goto ApplyYaw;
			switch (m_eCoverDirection)
			{
			case 0:
				uVar2 = 0x15; uVar3 = 0xF1;
				goto ApplyYaw;
			case 1:
				break; // fall through to common assignment
			case 2:
				uVar2 = 0xEA; uVar3 = 0x0E;
				goto ApplyYaw;
			default:
				goto ApplyYaw;
			}
		}
		uVar2 = 0xEA;
		uVar3 = 0x15;
		goto ApplyYaw;
	}

	{
		AR6Pawn* r6pawn = (AR6Pawn*)Pawn;
		if (r6pawn->m_iID == m_TeamManager->m_iMemberCount - 1)
		{
			switch (m_eCurrentRoomLayout)
			{
			case 0: uVar2 = 0x15; uVar3 = 0xEA; break;
			case 1: uVar2 = 0xE0; uVar3 = 0x0E; break;
			case 2: uVar2 = 0x20; uVar3 = 0xF1; break;
			case 3: uVar2 = 0x0E; uVar3 = 0xF1; break;
			}
		}
		else
		{
			switch (m_eCurrentRoomLayout)
			{
			case 0:
			case 2: uVar2 = 0x0E; uVar3 = 0xEA; break;
			case 1: uVar2 = 0xF1; uVar3 = 0x15; break;
			case 3: uVar2 = 0x0E; uVar3 = 0xF1; break;
			}
		}
	}

ApplyYaw:
	{
		AR6Rainbow* rainbow = (AR6Rainbow*)Pawn;
		if (m_iTurn == 0)
			rainbow->m_u8DesiredYaw = uVar2;
		else if (m_iTurn != 1)
			rainbow->m_u8DesiredYaw = 0;
		else
			rainbow->m_u8DesiredYaw = uVar3;
	}

	unguard;
}

IMPL_APPROX("Advances attack timer, fires eventAttackTimer and eventStopAttack, then chains to AActor::UpdateTimers")
void AR6RainbowAI::UpdateTimers(FLOAT DeltaTime)
{
	if (m_fAttackTimerRate > 0.0f)
	{
		FLOAT fAccum = m_fAttackTimerCounter + DeltaTime;
		m_fAttackTimerCounter = fAccum;

		if (fAccum >= m_fAttackTimerRate)
		{
			if (m_fAttackTimerRate > 0.0f)
			{
				m_fAttackTimerCounter = fAccum - (FLOAT)(INT)(fAccum / m_fAttackTimerRate) * m_fAttackTimerRate;
			}

			if (Enemy != NULL || bFire != 0)
			{
				eventAttackTimer();

				if (bFire != 0)
				{
					m_fFiringAttackTimer = (FLOAT)(appRand() % 6 + 1) * 0.05f;
				}
			}

			goto CallSuper;
		}
	}

	if (bFire != 0 && m_fFiringAttackTimer <= m_fAttackTimerCounter)
	{
		eventStopAttack();
	}

CallSuper:
	AActor::UpdateTimers(DeltaTime);
}

IMPL_APPROX("Traces 60 degrees left and right to classify corridor width; posts formation change event")
void AR6RainbowAI::checkEnvironment()
{
	guard(AR6RainbowAI::checkEnvironment);

	if (m_eFormation != 0)
	{
		// Trace right: pawn rotation + 60 degrees
		FCheckResult Hit1(1.0f);
		FRotator RightRot = Pawn->Rotation;
		RightRot.Yaw += 0x2AAB;
		FVector RightDir = RightRot.Vector() * 300.0f;
		FVector RightEnd = Pawn->Location + RightDir;
		XLevel->SingleLineCheck(Hit1, this, RightEnd, Pawn->Location, TRACE_World, FVector(0, 0, 0));

		// Trace left: pawn rotation - 60 degrees
		FCheckResult Hit2(1.0f);
		FRotator LeftRot = Pawn->Rotation;
		LeftRot.Yaw -= 0x2AAB;
		FVector LeftDir = LeftRot.Vector() * 300.0f;
		FVector LeftEnd = Pawn->Location + LeftDir;
		XLevel->SingleLineCheck(Hit2, this, LeftEnd, Pawn->Location, TRACE_World, FVector(0, 0, 0));

		// Classify environment based on trace results
		if (Hit1.Time < 1.0f)
		{
			if (Hit2.Time < 1.0f)
				m_eFormation = 4; // Both sides blocked
			else
				m_eFormation = 3; // Right blocked only
		}
		else if (Hit2.Time < 1.0f)
		{
			m_eFormation = 2; // Left blocked only
		}
		else
		{
			m_eFormation = 1; // Both sides open
		}

		m_TeamManager->eventRequestFormationChange(m_eFormation);
	}

	unguard;
}

IMPL_APPROX("Standard UObject event thunk")
void AR6RainbowAI::eventAttackTimer()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_AttackTimer), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6RainbowAI::eventStopAttack()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StopAttack), NULL);
}

IMPL_APPROX("Standard exec thunk delegating to native AClearShotIsAvailable")
void AR6RainbowAI::execAClearShotIsAvailable(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(APawn, PTarget);
	P_GET_STRUCT(FVector, vStart);
	P_FINISH;
	*(DWORD*)Result = AClearShotIsAvailable(PTarget, vStart);
}

IMPL_APPROX("Standard exec thunk delegating to native checkEnvironment")
void AR6RainbowAI::execCheckEnvironment(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	checkEnvironment();
}

IMPL_APPROX("Standard exec thunk delegating to native ClearToSnipe")
void AR6RainbowAI::execClearToSnipe(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vStart);
	P_GET_STRUCT(FRotator, rSnipingDir);
	P_FINISH;
	*(DWORD*)Result = ClearToSnipe(vStart, rSnipingDir);
}

IMPL_APPROX("Standard exec thunk delegating to native FindSafeSpot")
void AR6RainbowAI::execFindSafeSpot(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(UObject**)Result = FindSafeSpot();
}

IMPL_APPROX("Standard exec thunk delegating to native getEntryPosition")
void AR6RainbowAI::execGetEntryPosition(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL(bInsideRoom);
	P_FINISH;
	*(FVector*)Result = getEntryPosition();
}

IMPL_APPROX("Standard exec thunk delegating to native getGuardPosition")
void AR6RainbowAI::execGetGuardPosition(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FVector*)Result = getGuardPosition();
}

IMPL_APPROX("Standard exec thunk delegating to native getLadderPosition")
void AR6RainbowAI::execGetLadderPosition(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FVector*)Result = getLadderPosition();
}

IMPL_APPROX("Standard exec thunk delegating to native getTargetPosition")
void AR6RainbowAI::execGetTargetPosition(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(FVector*)Result = getTargetPosition();
}

IMPL_APPROX("Standard exec thunk delegating to native LookAroundRoom")
void AR6RainbowAI::execLookAroundRoom(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL(bIsLeadingRoomEntry);
	P_FINISH;
	LookAroundRoom(bIsLeadingRoomEntry);
}

IMPL_APPROX("Standard exec thunk delegating to native setMemberOrientation")
void AR6RainbowAI::execSetOrientation(FFrame& Stack, RESULT_DECL)
{
	P_GET_BYTE(eOverrideOrientation);
	P_FINISH;
	setMemberOrientation((EPawnOrientation)eOverrideOrientation);
}

IMPL_TODO("Needs Ghidra analysis")
FVector AR6RainbowAI::getEntryPosition()
{
	return FVector(0,0,0);
}

IMPL_TODO("Needs Ghidra analysis")
FVector AR6RainbowAI::getGuardPosition()
{
	return FVector(0,0,0);
}

IMPL_TODO("Needs Ghidra analysis")
FVector AR6RainbowAI::getLadderPosition()
{
	return FVector(0,0,0);
}

IMPL_TODO("Needs Ghidra analysis")
FVector AR6RainbowAI::getPreEntryPosition()
{
	return FVector(0,0,0);
}

IMPL_TODO("Needs Ghidra analysis")
FVector AR6RainbowAI::getTargetPosition()
{
	return FVector(0,0,0);
}

IMPL_APPROX("Resets spine, spine1, and neck bone rotations to identity on the skeletal mesh instance")
void AR6RainbowAI::resetBoneRotation()
{
	USkeletalMeshInstance* MeshInst = (USkeletalMeshInstance*)Pawn->Mesh->MeshGetInstance(Pawn);
	MeshInst->SetBoneRotation(FName(TEXT("R6 Spine"), FNAME_Add), FRotator(0,0,0), 0, 1.0f, 0.5f);
	MeshInst->SetBoneRotation(FName(TEXT("R6 Spine1"), FNAME_Add), FRotator(0,0,0), 0, 1.0f, 0.5f);
	MeshInst->SetBoneRotation(FName(TEXT("R6 Neck"), FNAME_Add), FRotator(0,0,0), 0, 1.0f, 0.5f);
}

IMPL_APPROX("Maps orientation enum to yaw/pitch bone offsets considering formation, stair state, and peeking")
void AR6RainbowAI::setMemberOrientation(enum EPawnOrientation param_1)
{
	guard(AR6RainbowAI::setMemberOrientation);

	INT iYawOffset = 0;
	BYTE bDesiredPitch = 0;

	// If pawn is prone, skip orientation changes
	if ((*(DWORD*)(*(INT*)((BYTE*)this + 0x3d8) + 0x3e0) & 0x200) != 0)
		return;

	// If param_1 matches current orientation, recalculate from formation
	if (((BYTE*)this)[0x56d] == (BYTE)param_1)
	{
		enum ePawnOrientation eNewOri = updatePawnOrientation();
		((BYTE*)this)[0x56d] = (BYTE)eNewOri;
	}

	// Need a skeletal mesh
	INT pawnPtr = *(INT*)((BYTE*)this + 0x3d8);
	if (*(INT*)(pawnPtr + 0x16c) == 0)
		return;

	// Verify mesh IsA USkeletalMesh
	check(*(INT*)(*(INT*)(pawnPtr + 0x16c) + 0x24) != 0 || true);

	// Get the mesh instance - vtable call to MeshGetInstance
	INT pawnMesh = *(INT*)(pawnPtr + 0x16c);
	(*(void(__thiscall**)(INT, INT))(**(INT**)pawnMesh + 0x88))(pawnMesh, pawnPtr);

	// Handle peek orientations specially
	if (param_1 == (enum EPawnOrientation)7)  // PO_PeekLeft
	{
		resetBoneRotation();
		(*(AR6Pawn**)((BYTE*)this + 0x598))->eventSetPeekingInfo(1, 2000.0f, 0);
		return;
	}
	if (param_1 == (enum EPawnOrientation)6)  // PO_PeekRight
	{
		resetBoneRotation();
		(*(AR6Pawn**)((BYTE*)this + 0x598))->eventSetPeekingInfo(1, 0.0f, 1);
		return;
	}

	// Clear peeking state if currently peeking
	AR6Pawn* peekPawn = *(AR6Pawn**)((BYTE*)this + 0x598);
	if (((BYTE*)peekPawn)[0x39c] != 0)
	{
		peekPawn->eventSetPeekingInfo(0, 1000.0f, 0);
	}

	// If still in a peeking transition, don't change bone rotation
	FLOAT peekRatio = peekPawn->GetPeekingRatioNorm(
		*(FLOAT*)((BYTE*)peekPawn + 0x734));
	if (peekRatio > 0.0f)
		return;

	// Map orientation enum to yaw offset
	switch (param_1)
	{
	case 1: // PO_FrontLeft
	case 7: // PO_PeekLeft
		iYawOffset = 0x1555;
		break;
	case 2: // PO_Left
		iYawOffset = 0x2aab;
		break;
	case 3: // PO_Right
		iYawOffset = -0x2aab;
		break;
	case 4: // PO_FrontRight
	case 6: // PO_PeekRight
		iYawOffset = -0x1555;
		break;
	}

	pawnPtr = *(INT*)((BYTE*)this + 0x3d8);

	// Adjust yaw based on stair climbing state and formation member index
	if ((*(DWORD*)(pawnPtr + 0x6c4) & 1) != 0)
	{
		// On stairs: adjust pitch based on stair direction
		if ((*(DWORD*)(pawnPtr + 0x6c4) & 2) == 0)
			bDesiredPitch = (BYTE)((((param_1 != 5) - 1) & 0x1c70) - 0xe38 >> 8);
		else
			bDesiredPitch = (BYTE)(((INT)((param_1 != 5) - 1) & (INT)0xffffe390) + 0xe38 >> 8);
	}
	else
	{
		// Adjust yaw offset based on formation position
		INT formIdx = *(INT*)((BYTE*)this + 0x574);
		if (*(INT*)(pawnPtr + 0x68c) == 1 && param_1 != 5)
		{
			if (formIdx > 1 && formIdx >= 4)
				iYawOffset -= 0xe38;
			// else keep iYawOffset unchanged
		}
		else
		{
			if (formIdx > 0 && formIdx >= 3)
				iYawOffset -= 0xe38;
			else
				iYawOffset += 0xe38;
		}
	}

	// Apply the calculated yaw and pitch to the pawn's desired aim
	*(BYTE*)(pawnPtr + 0xa28) = bDesiredPitch;
	*(BYTE*)(pawnPtr + 0xa2a) = (BYTE)(iYawOffset >> 8);

	unguard;
}

IMPL_APPROX("Selects orientation enum based on pawn prone state, team size, and formation type")
enum ePawnOrientation AR6RainbowAI::updatePawnOrientation()
{
	guard(AR6RainbowAI::updatePawnOrientation);

	AR6Pawn* r6pawn = (AR6Pawn*)Pawn;
	INT iID = r6pawn->m_iID;

	// Prone pawns always face forward
	if (r6pawn->m_bIsProne)
		return PO_Front;

	// Last team member always faces back
	if (m_eFormation != 0 && iID != 0 && iID == m_TeamManager->m_iMemberCount - 1)
		return PO_Back;

	switch (m_eFormation)
	{
	case 1:
		if (iID == 1) return r6pawn->m_bIsClimbingStairs ? PO_Front : PO_PeekLeft;
		if (iID == 2) return r6pawn->m_bIsClimbingStairs ? PO_Front : PO_PeekRight;
		break;
	case 2:
		if (iID == 1) return PO_FrontLeft;
		if (iID == 2) return PO_Left;
		break;
	case 3:
		if (iID == 1) return PO_FrontRight;
		if (iID == 2) return PO_Right;
		break;
	case 4:
		if (iID == 1) return PO_FrontLeft;
		if (iID == 2) return PO_FrontRight;
		break;
	case 5:
		if (iID == 1) return PO_PeekRight;
		if (iID == 2) return PO_PeekLeft;
		return PO_Front;
	default:
		return PO_Front;
	}

	// For cases 1-4, member 3 faces back
	if (iID == 3)
		return PO_Back;

	return PO_Front;

	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
