/*=============================================================================
	R6InteractiveObject.cpp
	AR6InteractiveObject, AMP2IOKarma — interactive world objects.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AMP2IOKarma)
IMPLEMENT_CLASS(AR6IActionObject)
IMPLEMENT_CLASS(AR6IOBomb)
IMPLEMENT_CLASS(AR6IOObject)
IMPLEMENT_CLASS(AR6IOSound)
IMPLEMENT_CLASS(AR6InteractiveObject)
IMPLEMENT_CLASS(AR6EnvironmentNode)

IMPLEMENT_FUNCTION(AMP2IOKarma, -1, execMP2IOKarmaAllNativeFct)

// Statics used by AR6InteractiveObject PreNetReceive/PostNetReceive.
static FLOAT GInteractiveObject_OldNetDamagePercentage;

// --- AMP2IOKarma ---

void AMP2IOKarma::CheckForErrors()
{
}

INT AMP2IOKarma::KMP2DynKarmaInterface(INT, FVector, FRotator, AActor *)
{
	return 0;
}

void AMP2IOKarma::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
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

// --- AR6InteractiveObject ---

void AR6InteractiveObject::CheckForErrors()
{
}

void AR6InteractiveObject::PostNetReceive()
{
	guard(AR6InteractiveObject::PostNetReceive);
	AActor::PostNetReceive();

	// If net damage percentage changed, fire the damage state event
	if (m_fNetDamagePercentage != GInteractiveObject_OldNetDamagePercentage)
		eventSetNewDamageState(m_fNetDamagePercentage);

	// Sync replicated skins to actual Skins array
	for (INT i = 0; i < 4; i++)
	{
		if (m_aRepSkins[i] != m_aOldSkins[i])
		{
			if (Skins.Num() < 4)
				Skins.AddZeroed(4);
			m_aOldSkins[i] = m_aRepSkins[i];
			Skins(i) = m_aRepSkins[i];
		}
	}

	unguard;
}

// Verified from Ghidra: function at 0x1c220 is a no-op (body is just 'return').
void AR6InteractiveObject::PostScriptDestroyed()
{
}

void AR6InteractiveObject::PreNetReceive()
{
	guard(AR6InteractiveObject::PreNetReceive);
	AActor::PreNetReceive();
	GInteractiveObject_OldNetDamagePercentage = m_fNetDamagePercentage;
	unguard;
}

void AR6InteractiveObject::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

INT AR6InteractiveObject::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	guard(AR6InteractiveObject::ShouldTrace);

	// R6-specific trace flag: always trace regardless
	if (TraceFlags & 0x800000)
		return 1;

	// Shot-through objects are skipped when shot-through trace requested
	if ((TraceFlags & 0x400000) && m_bShotThrough)
		return 0;

	// Corona visibility check
	if (TraceFlags & TRACE_VisibleNonColliding)
		return m_bBlockCoronas ? 1 : 0;

	// See-through check
	if ((TraceFlags & 0x20000) && m_bSeeThrough)
		return 0;

	// Bullet-goes-through check
	if ((TraceFlags & 0x40000) && m_bBulletGoThrough)
		return 0;

	// Pawn-goes-through check
	if ((TraceFlags & 0x200000) && m_bPawnGoThrough)
		return 0;

	// If tracing for movers, always trace interactive objects
	if (TraceFlags & TRACE_Movers)
		return 1;

	// Fall through to AActor base
	if (!AActor::ShouldTrace(Other, TraceFlags))
		return 0;

	return 1;

	unguard;
}

void AR6InteractiveObject::eventSetNewDamageState(FLOAT A)
{
	struct { FLOAT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetNewDamageState), &Parms);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
