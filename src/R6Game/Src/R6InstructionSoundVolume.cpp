/*=============================================================================
	R6InstructionSoundVolume.cpp
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(AR6InstructionSoundVolume)

IMPLEMENT_FUNCTION(AR6InstructionSoundVolume, -1, execUseSound)

// --- AR6InstructionSoundVolume ---

IMPL_TODO("Needs Ghidra analysis")
void AR6InstructionSoundVolume::execUseSound(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
