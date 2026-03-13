/*=============================================================================
	R6Rainbow.cpp
	AR6Rainbow, AR6RainbowTeam — rainbow operative pawn and team manager.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6Rainbow)
IMPLEMENT_CLASS(AR6RainbowTeam)

// --- AR6Rainbow ---

void AR6Rainbow::UpdateAiming()
{
	guard(AR6Rainbow::UpdateAiming);

	BYTE desiredYaw = m_u8DesiredYaw;
	if (m_u8CurrentYaw != desiredYaw || m_u8CurrentPitch != m_u8DesiredPitch)
	{
		m_u8CurrentPitch = m_u8DesiredPitch;
		m_u8CurrentYaw = desiredYaw;
		PawnLook(FRotator((INT)m_u8DesiredPitch << 8, (INT)desiredYaw << 8, 0), 1, 0);
	}

	unguard;
}

// --- AR6RainbowTeam ---

void AR6RainbowTeam::eventRequestFormationChange(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_RequestFormationChange), &Parms);
}

void AR6RainbowTeam::eventUpdateTeamFormation(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_UpdateTeamFormation), &Parms);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
