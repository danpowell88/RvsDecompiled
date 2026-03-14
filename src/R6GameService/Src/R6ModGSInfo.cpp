/*=============================================================================
	R6ModGSInfo.cpp
=============================================================================*/

#include "R6GameServicePrivate.h"

IMPLEMENT_CLASS(UR6ModGSInfo)

IMPLEMENT_FUNCTION(UR6ModGSInfo, -1, execNativeInitModInfo)

// --- UR6ModGSInfo ---

IMPL_MATCH("R6GameService.dll", 0x1000c7b0)
void UR6ModGSInfo::InitMODCDKey()
{
	guard(UR6ModGSInfo::InitMODCDKey);
	unguard;
}

IMPL_MATCH("R6GameService.dll", 0x10005460)
void UR6ModGSInfo::execNativeInitModInfo(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ModGSInfo::execNativeInitModInfo);
	P_FINISH;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
