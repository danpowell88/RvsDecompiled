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

INT AMP2IOKarma::KMP2DynKarmaInterface(INT, FVector, FRotator, AActor *)
{
	return 0;
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
