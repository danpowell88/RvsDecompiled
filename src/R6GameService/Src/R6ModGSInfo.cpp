/*=============================================================================
	R6ModGSInfo.cpp
=============================================================================*/

#include "R6GameServicePrivate.h"

IMPLEMENT_CLASS(UR6ModGSInfo)

IMPLEMENT_FUNCTION(UR6ModGSInfo, -1, execNativeInitModInfo)

// --- UR6ModGSInfo ---

void UR6ModGSInfo::InitMODCDKey()
{
	guard(UR6ModGSInfo::InitMODCDKey);
	unguard;
}

void UR6ModGSInfo::execNativeInitModInfo(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ModGSInfo::execNativeInitModInfo);
	P_FINISH;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
