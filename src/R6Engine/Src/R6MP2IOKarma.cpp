/*=============================================================================
	R6MP2IOKarma.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AMP2IOKarma)

IMPLEMENT_FUNCTION(AMP2IOKarma, -1, execMP2IOKarmaAllNativeFct)

// --- AMP2IOKarma ---

void AMP2IOKarma::CheckForErrors()
{
	guard(AMP2IOKarma::CheckForErrors);
	// Verified from Ghidra: shares function body at 0x1c220 (no-op, just returns).
	unguard;
}

INT AMP2IOKarma::KMP2DynKarmaInterface(INT Cmd, FVector P, FRotator R, AActor* A)
{
	guard(AMP2IOKarma::KMP2DynKarmaInterface);

	// Flags DWORD at +0x45c (packs bCollideRagDoll, bUseSafeTimeWithLevel, bUseSafeTimeWithSM, bSimulationActive, etc.)

	if (Cmd == 10) // query bUseSafeTimeWithLevel
		return (*(DWORD*)((BYTE*)this + 0x45c) >> 1) & 1;

	if (Cmd == 11) // query bUseSafeTimeWithSM
		return (*(DWORD*)((BYTE*)this + 0x45c) >> 2) & 1;

	if (Cmd == 7)
	{
		// Return 0 if both bSimulationActive(bit1) and bUseSafeTimeWithLevel(bit2) are clear
		if ((*(BYTE*)((BYTE*)this + 0x45c) & 6) == 0)
			return 0;
		// else fall through to return 0 at end
	}
	else if (Cmd == 6) // query bCollideRagDoll (bit 0)
	{
		return *(DWORD*)((BYTE*)this + 0x45c) & 1;
	}
	else if (Cmd == 5) // ReinitSimulation
	{
		eventReinitSimulation(0);
	}
	else if (Cmd == 4) // HasAttachPoint: +1 if set, -1 if not
	{
		return (*(BYTE*)((BYTE*)this + 0x458) != 0) ? 1 : -1;
	}
	else if (Cmd == 2) // ClearAttachPoint
	{
		*(BYTE*)((BYTE*)this + 0x458) = 0;
	}
	else if (Cmd == 3) // CheckStopCondition
	{
		if ((*(BYTE*)((BYTE*)this + 0x45c) & 0x40) == 0) // bSimulationActive
			return 1;

		FLOAT ZMin   = *(FLOAT*)((BYTE*)this + 0x470); // m_fZMin
		FLOAT ActorZ = Location.Z;
		if (ZMin > -1e7f && ActorZ < ZMin)
		{
			eventStopSimulation(1);
			return -2;
		}
	}
	else if (Cmd == 33)
	{
		// TODO: FCoords rotation and ZDR impulse application
		// Ghidra: FCoords::operator/ then iterate m_ZDRList (0x480/0x484),
		//         call physics vtable[0x84/4] for impulse per spring constraint
	}
	else if (Cmd == 9) // ApplySpringForces
	{
		// TODO: iterate spring constraints (type==3) at this+0x480, stride 0x2c
		// Ghidra: TransformVectorByTranspose, compute dist to target,
		//         call physics vtable[0x84/4] for impulse
	}
	else if (Cmd == 8) // ApplyConstraints
	{
		// TODO: iterate constraints (type==2), locate connected constraint,
		// Ghidra: FUN_1001c600 helper, nested constraint lookup
	}

	return 0;
	unguard;
}

void AMP2IOKarma::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AMP2IOKarma::RenderEditorInfo);

	if ((*(DWORD*)((BYTE*)this + 0xAC) & 0x4000) != 0)
	{
		// TODO: Complex editor rendering that iterates karma constraint list at (this+0x480),
		// transforms positions by inverse GMath coords, and draws spheres at each constraint point.
		// Involves FLineBatcher, FCoords, FVector::TransformVectorByTranspose, and per-constraint
		// iteration with stride 0x2c. Omitted due to unresolved helper FUN_1000d610/FUN_1000ea00.
	}

	unguard;
}

void AMP2IOKarma::eventReinitSimulation(INT A)
{
	struct { INT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ReinitSimulation), &Parms);
}

void AMP2IOKarma::eventStartSimulation(INT A)
{
	struct { INT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartSimulation), &Parms);
}

void AMP2IOKarma::eventStopSimulation(INT A)
{
	struct { INT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_StopSimulation), &Parms);
}

void AMP2IOKarma::eventZDRSetDamageState(INT A, FLOAT B, FVector C)
{
	struct { 
		INT A;
		FLOAT B;
		FVector C;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ZDRSetDamageState), &Parms);
}

void AMP2IOKarma::execMP2IOKarmaAllNativeFct(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
