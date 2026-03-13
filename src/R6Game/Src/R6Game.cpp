/*=============================================================================
	R6Game.cpp: R6Game package init.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_PACKAGE(R6Game)

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) R6GAME_API FName R6GAME_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6GameClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

IMPLEMENT_CLASS(AR6ActionPoint)
IMPLEMENT_CLASS(AR6InstructionSoundVolume)
IMPLEMENT_CLASS(AR6SoundVolume)
IMPLEMENT_CLASS(AR6WaterVolume)

IMPLEMENT_FUNCTION(AR6InstructionSoundVolume, -1, execUseSound)

// --- AR6ActionPoint ---

void AR6ActionPoint::SetRotationToward(FVector)
{
}

void AR6ActionPoint::TransferFile(FArchive &)
{
}

// --- AR6InstructionSoundVolume ---

void AR6InstructionSoundVolume::execUseSound(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
