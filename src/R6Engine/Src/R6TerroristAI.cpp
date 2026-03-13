/*=============================================================================
	R6TerroristAI.cpp
	AR6TerroristAI — terrorist AI controller with hearing, backup calls,
	and attack spot validation.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6TerroristAI)

IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execCallBackupForAttack)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execCallBackupForInvestigation)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execCallVisibleTerrorist)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execFindBetterShotLocation)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execGetNextRandomNode)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execHaveAClearShot)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execIsAttackSpotStillValid)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execMakeBackupList)

// --- AR6TerroristAI ---

INT AR6TerroristAI::CanHear(FVector Location, FLOAT Loudness, AActor* Source, enum ENoiseType NoiseType, enum EPawnType PawnType)
{
	// Filter by noise type against terrorist hearing capabilities
	switch ((INT)NoiseType)
	{
	case 1: // NOISE_Footstep
	case 4: // R6-specific noise type
		if (!m_bHearInvestigate)
			return 0;
		break;
	case 2: // NOISE_Weapon
		if (!m_bHearThreat)
			return 0;
		break;
	case 3: // NOISE_Explosion
		if (!m_bHearGrenade)
			return 0;
		break;
	}
	return AR6AIController::CanHear(Location, Loudness, Source, NoiseType, PawnType);
}

INT AR6TerroristAI::HaveAClearShot(FVector, APawn *)
{
	return 0;
}

void AR6TerroristAI::eventGotoPointAndSearch(FVector A, BYTE B, DWORD C, FLOAT D, BYTE E)
{
	struct { 
		FVector A;
		BYTE B;
		DWORD C;
		FLOAT D;
		BYTE E;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	Parms.D = D;
	Parms.E = E;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoPointAndSearch), &Parms);
}

void AR6TerroristAI::eventGotoPointToAttack(FVector A, AActor * B)
{
	struct { 
		FVector A;
		AActor * B;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoPointToAttack), &Parms);
}

void AR6TerroristAI::eventGotoStateEngageByThreat(FVector A)
{
	struct { FVector A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoStateEngageByThreat), &Parms);
}

void AR6TerroristAI::execCallBackupForAttack(FFrame& Stack, RESULT_DECL)
{
	guard(AR6TerroristAI::execCallBackupForAttack);
	P_GET_STRUCT(FVector, vDestination);
	P_GET_BYTE(ePace);
	P_FINISH;

	if (m_iTerroristInGroup == 0)
		return;

	// Direction components from the possessed pawn to the destination.
	FLOAT dY = vDestination.Y - Pawn->Location.Y;
	FLOAT dX = vDestination.X - Pawn->Location.X;

	// Two perpendicular flanking positions around the destination.
	// NOTE: Z = vDestination.Z * 401.0f faithfully reproduces the original arithmetic
	// (vDestination.Z * 400.0f + vDestination.Z) from the Ghidra decompilation.
	FLOAT zComp = vDestination.Z * 400.0f + vDestination.Z;
	FVector pos1(vDestination.X + dY * 400.0f, vDestination.Y - dX * 400.0f, zComp);
	FVector pos2(vDestination.X - dY * 400.0f, vDestination.Y + dX * 400.0f, zComp);

	// Trace from destination toward each flanking position.
	// A clear trace (Time == 1.0f, no obstacle) means the attacker will have LOS to the target.
	// Additionally, the terrorist's deployment zone must have space for a pawn there.
	FCheckResult Hit1(1.0f);
	XLevel->SingleLineCheck(Hit1, Enemy, pos1, vDestination, 0x286, FVector(0,0,0));
	UBOOL bPos1Valid = (Hit1.Time == 1.0f) && m_pawn->m_DZone != NULL && m_pawn->m_DZone->HavePlaceForPawnAt(pos1);

	FCheckResult Hit2(1.0f);
	XLevel->SingleLineCheck(Hit2, Enemy, pos2, vDestination, 0x286, FVector(0,0,0));
	UBOOL bPos2Valid = (Hit2.Time == 1.0f) && m_pawn->m_DZone != NULL && m_pawn->m_DZone->HavePlaceForPawnAt(pos2);

	// Probability thresholds: rand in [0,threshDest) → destination,
	// [threshDest,threshPos1) → pos1, [threshPos1,100) → pos2.
	INT threshDest = 0;
	INT threshPos1 = 0;
	if (!bPos1Valid && !bPos2Valid)
	{
		threshDest = 100;
	}
	else if (!bPos1Valid)
	{
		threshDest = 66;                 // 66% destination, 34% pos2
	}
	else if (bPos2Valid)
	{
		threshDest = 50; threshPos1 = 75; // 50% dest, 25% pos1, 25% pos2
	}
	else
	{
		threshDest = 66; threshPos1 = 100; // 66% dest, 34% pos1
	}

	for (INT i = 0; i < m_iTerroristInGroup; i++)
	{
		AR6TerroristAI* pTerrorist = m_listAvailableBackup(i);
		if (!pTerrorist->m_bCantInterruptIO)
		{
			pTerrorist->m_iCurrentGroupID = m_iCurrentGroupID;
			pTerrorist->m_TerroristLeader = this;

			INT r = appRand() % 100;
			FVector attackPos;
			if (r < threshDest)
				attackPos = vDestination;
			else if (r < threshPos1)
				attackPos = pos1;
			else
				attackPos = pos2;

			pTerrorist->eventGotoPointToAttack(attackPos, Enemy);
		}
	}

	unguard;
}

void AR6TerroristAI::execCallBackupForInvestigation(FFrame& Stack, RESULT_DECL)
{
	guard(AR6TerroristAI::execCallBackupForInvestigation);
	P_GET_STRUCT(FVector, vDestination);
	P_GET_BYTE(ePace);
	P_FINISH;

	for (INT i = 0; i < m_iTerroristInGroup; i++)
	{
		AR6TerroristAI* pTerrorist = m_listAvailableBackup(i);
		if (!pTerrorist->m_bCantInterruptIO)
		{
			pTerrorist->m_iCurrentGroupID = m_iCurrentGroupID;
			pTerrorist->m_TerroristLeader = this;
			pTerrorist->eventGotoPointAndSearch(vDestination, ePace, 0, 30.0f, 2);
		}
	}

	unguard;
}

void AR6TerroristAI::execCallVisibleTerrorist(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AR6TerroristAI::execFindBetterShotLocation(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(APawn, PTarget);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
}

void AR6TerroristAI::execGetNextRandomNode(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(UObject**)Result = NULL;
}

void AR6TerroristAI::execHaveAClearShot(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vStart);
	P_GET_OBJECT(APawn, PTarget);
	P_FINISH;
	*(DWORD*)Result = HaveAClearShot(vStart, PTarget);
}

void AR6TerroristAI::execIsAttackSpotStillValid(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

void AR6TerroristAI::execMakeBackupList(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	*(DWORD*)Result = 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
