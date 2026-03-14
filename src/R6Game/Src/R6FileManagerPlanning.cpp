/*=============================================================================
	R6FileManagerPlanning.cpp
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(UR6FileManagerPlanning)

IMPLEMENT_FUNCTION(UR6FileManagerPlanning, -1, execGetNumberOfFiles)
IMPLEMENT_FUNCTION(UR6FileManagerPlanning, -1, execLoadPlanning)
IMPLEMENT_FUNCTION(UR6FileManagerPlanning, -1, execSavePlanning)

// --- UR6FileManagerPlanning ---

IMPL_MATCH("R6Game.dll", 0x10007ae0)
void UR6FileManagerPlanning::execGetNumberOfFiles(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_MATCH("R6Game.dll", 0x100071a0)
void UR6FileManagerPlanning::execLoadPlanning(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_MATCH("R6Game.dll", 0x10007700)
void UR6FileManagerPlanning::execSavePlanning(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
