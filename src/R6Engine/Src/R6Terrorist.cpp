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

void AR6Terrorist::PreNetReceive()
{
	guard(AR6Terrorist::PreNetReceive);
	GR6Terrorist_OldSpecialAnimValid = m_eSpecialAnimValid;
	GR6Terrorist_OldHealth = m_eHealth;
	GR6Terrorist_OldDefCon = m_eDefCon;
	AR6Pawn::PreNetReceive();
	unguard;
}

void AR6Terrorist::UpdateAiming(FLOAT DeltaTime)
{
	guard(AR6Terrorist::UpdateAiming);

	// DIVERGENCE: Ghidra at 0x29590 (~2500 bytes). Interpolates m_iCurrentHeadYaw toward
	// m_wWantedHeadYaw*256 and m_iCurrentAimingPitch toward m_wWantedAimingPitch*256, then
	// distributes the result across bones "R6 Neck", "R6 Spine", "R6 Spine1", "R6 Spine2",
	// "R6 L Forearm", "R6 L Hand", "R6 R Hand" via SetBoneRotation with Alpha=0.1f.
	// The per-frame step amounts are computed as (INT)(DeltaTime * RATE) where RATE is a
	// compile-time constant loaded onto the x87 FPU before calling FUN_10042934 (__ftol).
	// The hidden x87 ST0 argument prevents Ghidra from showing it; exact rate constants
	// are unknown until disassembly is analysed. Left as stub.

	unguard;
}

void AR6Terrorist::eventFinishInitialization()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_FinishInitialization), NULL);
}

void AR6Terrorist::eventLoopSpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_LoopSpecialAnim), NULL);
}

void AR6Terrorist::eventPlaySpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlaySpecialAnim), NULL);
}

void AR6Terrorist::eventStopSpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StopSpecialAnim), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
