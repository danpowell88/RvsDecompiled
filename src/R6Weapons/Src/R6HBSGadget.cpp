/*=============================================================================
	R6HBSGadget.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6HBSGadget)

IMPLEMENT_FUNCTION(AR6HBSGadget, -1, execToggleHeartBeatProperties)

// --- AR6HBSGadget ---

INT AR6HBSGadget::GetHeartBeatStatus()
{
	return m_bHeartBeatOn ? 1 : 0;
}

void AR6HBSGadget::execToggleHeartBeatProperties(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
