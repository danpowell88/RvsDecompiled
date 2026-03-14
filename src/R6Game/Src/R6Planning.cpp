/*=============================================================================
	R6Planning.cpp — UR6PlanningInfo
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(UR6PlanningInfo)

IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execAddToTeam)
IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execDeletePoint)
IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execFindPathToNextPoint)
IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execInsertToTeam)

// --- UR6PlanningInfo ---

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void UR6PlanningInfo::AddPoint(AActor* param_1)
{
	// Append param_1 to the action-point array at this+0x5C
	FArray* arr = (FArray*)((BYTE*)this + 0x5c);
	INT idx = arr->Add(1, sizeof(AActor*));
	*(AActor**)((BYTE*)arr->GetData() + idx * sizeof(AActor*)) = param_1;

	// If a team leader is set, copy its reference into the new point
	INT leaderIdx = *(INT*)((BYTE*)this + 0x34);
	if (leaderIdx != -1)
	{
		*(INT*)((BYTE*)param_1 + 0x394) =
			*(INT*)((BYTE*)arr->GetData() + leaderIdx * sizeof(AActor*));
	}
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
AActor* UR6PlanningInfo::GetTeamLeader()
{
	if (*(INT*)((BYTE*)this + 0x58) != 0)
		return *(AActor**)(*(INT*)((BYTE*)this + 0x58) + 0x420);
	return NULL;
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
INT UR6PlanningInfo::NoStairsBetweenPoints(AActor* param_1)
{
	AController* pCtrl = *(AController**)((BYTE*)this + 0x58);

	// Use the path between origin and param_1; zero-vector means "from current position"
	AActor* pResult = pCtrl->FindPath(FVector(0.0f, 0.0f, 0.0f), param_1, 1);
	if (pResult)
	{
		// Walk the RouteCache (up to 16 entries) and test each node's class chain
		for (INT i = 0; i < 0x10; i++)
		{
			INT node = *(INT*)((BYTE*)pCtrl + 0x408 + i * 4);
			if (node == 0)
				break;

			// Check if the node is an AR6Stairs (or subclass)
			for (UClass* cls = *(UClass**)(node + 0x24); cls; cls = *(UClass**)(cls + 0x2c))
			{
				if (cls == AR6Stairs::StaticClass())
					return 0;
			}
			if (!AR6Stairs::StaticClass())
				return 0;
		}
	}
	return 1;
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void UR6PlanningInfo::TransferFile(FArchive& Ar)
{
	// Ghidra checks ArIsLoading at Ar+0x14; if zero this is the SAVING branch
	if (*(INT*)((BYTE*)&Ar + 0x14) == 0)
	{
		// Saving: write team info + action point locations + their data
		Ar.ByteOrderSerialize((BYTE*)this + 0x3c, 4);
		Ar.ByteOrderSerialize((BYTE*)this + 0x40, 4);
		Ar.ByteOrderSerialize((BYTE*)this + 0x34, 4);

		INT count = *(INT*)((BYTE*)this + 0x40);
		for (INT i = 0; i < count; i++)
		{
			INT pt = *(INT*)(*(INT*)((BYTE*)this + 0x5c) + i * 4);
			Ar.ByteOrderSerialize((void*)(pt + 0x234), 4);  // Location.X
			Ar.ByteOrderSerialize((void*)(pt + 0x238), 4);  // Location.Y
			Ar.ByteOrderSerialize((void*)(pt + 0x23c), 4);  // Location.Z
			AR6ActionPoint* ptSave = *(AR6ActionPoint**)(*(INT*)((BYTE*)this + 0x5c) + i * 4);
			ptSave->TransferFile(Ar);
		}
	}
	else
	{
		// Loading: reset state, rebuild array by spawning fresh action points
		*(INT*)((BYTE*)this + 0x34) = -1;
		*(INT*)((BYTE*)this + 0x38) = -1;

		FArray* arr = (FArray*)((BYTE*)this + 0x5c);
		arr->Empty(sizeof(AR6ActionPoint*));

		// Read game-mode field
		Ar.ByteOrderSerialize((BYTE*)this + 0x3c, 4);

		// Old-format compat: if ArVer < 1 read (and discard) three legacy floats
		if (*(INT*)((BYTE*)&Ar + 4) < 1)
		{
			INT dummy[3] = {0, 0, 0};
			Ar.ByteOrderSerialize(&dummy[0], 4);
			Ar.ByteOrderSerialize(&dummy[1], 4);
			Ar.ByteOrderSerialize(&dummy[2], 4);
		}

		// Read number of action points
		Ar.ByteOrderSerialize((BYTE*)this + 0x40, 4);

		// ArVer > 2: read saved leader index
		INT savedLeaderIdx = 0;
		if (*(INT*)((BYTE*)&Ar + 4) > 2)
			Ar.ByteOrderSerialize(&savedLeaderIdx, 4);

		INT count = *(INT*)((BYTE*)this + 0x40);
		if (count > 0)
		{
			AController* pCtrl = *(AController**)((BYTE*)this + 0x58);
			ULevel*       pLevel = *(ULevel**)((BYTE*)pCtrl + 0x328);

			for (INT i = 0; i < count; i++)
			{
				// Read spawn location
				FLOAT spX = 0.0f, spY = 0.0f, spZ = 0.0f;
				Ar.ByteOrderSerialize(&spX, 4);
				Ar.ByteOrderSerialize(&spY, 4);
				Ar.ByteOrderSerialize(&spZ, 4);

				// Spawn the action point actor
				AR6ActionPoint* pPt = (AR6ActionPoint*)pLevel->SpawnActor(
					AR6ActionPoint::StaticClass(), NAME_None,
					FVector(spX, spY, spZ));

				// Clear the "server-only" flag bit
				*(DWORD*)((BYTE*)pPt + 0xa0) &= ~2u;

				// Register it with the planning info
				AddPoint(pPt);
				*(INT*)((BYTE*)this + 0x34) += 1;

				// Deserialize the action point's own data
				pPt->TransferFile(Ar);

				// Copy planning ctrl reference (m_pPlanningCtrl → field at 0x168)
				*(INT*)((BYTE*)pPt + 0x168) = *(INT*)((BYTE*)pPt + 0x3c0);
			}

			*(DWORD*)((BYTE*)this + 0x4c) |= 4u;
			*(INT*)((BYTE*)this + 0x34) = savedLeaderIdx;
		}
	}
}

IMPL_TODO("Needs Ghidra analysis")
void UR6PlanningInfo::execAddToTeam(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6PlanningInfo::execDeletePoint(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6PlanningInfo::execFindPathToNextPoint(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6PlanningInfo::execInsertToTeam(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
