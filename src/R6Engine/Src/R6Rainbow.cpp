/*=============================================================================
	R6Rainbow.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6Rainbow)

// --- AR6Rainbow ---

IMPL_INFERRED("Updates current yaw/pitch from desired values and calls PawnLook when changed")
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

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
