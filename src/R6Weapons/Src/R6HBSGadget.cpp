/*=============================================================================
	R6HBSGadget.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6HBSGadget)

IMPLEMENT_FUNCTION(AR6HBSGadget, -1, execToggleHeartBeatProperties)

// --- AR6HBSGadget ---

IMPL_MATCH("R6Weapons.dll", 0x10002300)
INT AR6HBSGadget::GetHeartBeatStatus()
{
	return *(DWORD*)((BYTE*)this + 0x62c) & 1;
}

IMPL_EMPTY("exec binding; ToggleHeartBeatProperties has no native implementation")
void AR6HBSGadget::execToggleHeartBeatProperties(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
