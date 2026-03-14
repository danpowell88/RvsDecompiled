/*=============================================================================
	R6HBSGadget.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6HBSGadget)

IMPLEMENT_FUNCTION(AR6HBSGadget, -1, execToggleHeartBeatProperties)

// --- AR6HBSGadget ---

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
INT AR6HBSGadget::GetHeartBeatStatus()
{
	return m_bHeartBeatOn ? 1 : 0;
}

IMPL_INTENTIONALLY_EMPTY("exec binding; ToggleHeartBeatProperties has no native implementation")
void AR6HBSGadget::execToggleHeartBeatProperties(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
