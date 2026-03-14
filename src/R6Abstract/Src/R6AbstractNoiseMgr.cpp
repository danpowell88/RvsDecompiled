/*=============================================================================
	R6AbstractNoiseMgr.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(UR6AbstractNoiseMgr)

// --- UR6AbstractNoiseMgr ---

IMPL_MATCH("R6Abstract.dll", 0x10002f70)
void UR6AbstractNoiseMgr::eventR6MakeNoise(BYTE eType, AActor* Source)
{
	struct { BYTE eType; AActor* Source; } Parms;
	Parms.eType = eType;
	Parms.Source = Source;
	ProcessEvent(FindFunctionChecked(R6ABSTRACT_R6MakeNoise), &Parms);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
