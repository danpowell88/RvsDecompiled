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
	P_GET_STRUCT(FVector, vDestination);
	P_GET_BYTE(ePace);
	P_FINISH;
	// TODO: iterates nearby terrorists, calls path finding and eventGotoPointAndAttack (see Ghidra)
}

void AR6TerroristAI::execCallBackupForInvestigation(FFrame& Stack, RESULT_DECL)
{
	P_GET_STRUCT(FVector, vDestination);
	P_GET_BYTE(ePace);
	P_FINISH;
	// TODO: iterates terrorist list, calls eventGotoPointAndSearch on each (see Ghidra)
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
