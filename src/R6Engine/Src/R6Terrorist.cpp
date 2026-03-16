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

IMPL_MATCH("R6Engine.dll", 0x1003d0b0)
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

IMPL_MATCH("R6Engine.dll", 0x1003cbf0)
void AR6Terrorist::PreNetReceive()
{
	guard(AR6Terrorist::PreNetReceive);
	GR6Terrorist_OldSpecialAnimValid = m_eSpecialAnimValid;
	GR6Terrorist_OldHealth = m_eHealth;
	GR6Terrorist_OldDefCon = m_eDefCon;
	AR6Pawn::PreNetReceive();
	unguard;
}

IMPL_TODO("FUN_10042934 ftol2-style rounding helper unidentified; complex bone rotation distribution across 7 bones with stance-dependent splits")
void AR6Terrorist::UpdateAiming(FLOAT DeltaTime)
{
	guard(AR6Terrorist::UpdateAiming);

	// TODO(0x10029590, ~1272 bytes): reads target yaw from BYTE at this+0xa30 (*256, sign-extended)
	// and target pitch from this+0xa2f; smoothly interpolates current values (this+0xa3c, this+0xa38)
	// via FUN_10042934 rate helper; clamps pitch to [-10000, 10000]; distributes rotation across
	// "R6 Neck", "R6 Spine", "R6 Spine1", "R6 Spine2", "R6 L Forearm", "R6 L Hand", "R6 R Hand"
	// via SetBoneRotation; stance byte (this+0xa28) selects distribution table; weapon attachment
	// at this+0x4fc modifies split ratios.

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10004c60)
void AR6Terrorist::eventFinishInitialization()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_FinishInitialization), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x100063e0)
void AR6Terrorist::eventLoopSpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_LoopSpecialAnim), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10006410)
void AR6Terrorist::eventPlaySpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlaySpecialAnim), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x100063b0)
void AR6Terrorist::eventStopSpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StopSpecialAnim), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
