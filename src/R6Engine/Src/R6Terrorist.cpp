/*=============================================================================
	R6Terrorist.cpp
	AR6Terrorist — terrorist pawn with net replication and special animations.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6Terrorist)

// Statics used by AR6Terrorist PreNetReceive/PostNetReceive.
static BYTE GR6Terrorist_OldSpecialAnimValid;
static BYTE GR6Terrorist_OldHealth;
static BYTE GR6Terrorist_OldDefCon;

// --- AR6Terrorist ---

IMPL_APPROX("Triggers animation events on replicated special-anim and health/DefCon state changes")
void AR6Terrorist::PostNetReceive()
{
	guard(AR6Terrorist::PostNetReceive);

	BYTE CurSpecialAnim = m_eSpecialAnimValid;
	if (GR6Terrorist_OldSpecialAnimValid != CurSpecialAnim)
	{
		if (CurSpecialAnim == 0)
			eventStopSpecialAnim();
		else if (CurSpecialAnim == 1)
			eventPlaySpecialAnim();
		else if (CurSpecialAnim == 2)
			eventLoopSpecialAnim();
	}

	if (GR6Terrorist_OldHealth != m_eHealth || GR6Terrorist_OldDefCon != m_eDefCon)
		eventChangeAnimation();

	AR6Pawn::PostNetReceive();

	unguard;
}

IMPL_APPROX("Caches replicated animation and health bytes before net update for change detection")
void AR6Terrorist::PreNetReceive()
{
	guard(AR6Terrorist::PreNetReceive);
	GR6Terrorist_OldSpecialAnimValid = m_eSpecialAnimValid;
	GR6Terrorist_OldHealth = m_eHealth;
	GR6Terrorist_OldDefCon = m_eDefCon;
	AR6Pawn::PreNetReceive();
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6Terrorist::UpdateAiming(FLOAT DeltaTime)
{
	guard(AR6Terrorist::UpdateAiming);

	// TODO: implement AR6Terrorist::UpdateAiming (Ghidra 0x29590, ~2500 bytes: interpolates
	// m_iCurrentHeadYaw/m_iCurrentAimingPitch and distributes across bones "R6 Neck", "R6 Spine",
	// "R6 Spine1", "R6 Spine2", "R6 L Forearm", "R6 L Hand", "R6 R Hand" via SetBoneRotation;
	// exact rate constants unknown pending full disassembly analysis)

	unguard;
}

IMPL_APPROX("Standard UObject event thunk")
void AR6Terrorist::eventFinishInitialization()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_FinishInitialization), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6Terrorist::eventLoopSpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_LoopSpecialAnim), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6Terrorist::eventPlaySpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlaySpecialAnim), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6Terrorist::eventStopSpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StopSpecialAnim), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
