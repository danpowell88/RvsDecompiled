/*=============================================================================
	R6AbstractPawn.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractPawn)

// --- AR6AbstractPawn ---

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
FLOAT AR6AbstractPawn::eventGetSkill(BYTE eSkillName)
{
	struct { BYTE eSkillName; FLOAT ReturnValue; } Parms;
	Parms.eSkillName = eSkillName;
	Parms.ReturnValue = 0.f;
	ProcessEvent(FindFunctionChecked(R6ABSTRACT_GetSkill), &Parms);
	return Parms.ReturnValue;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
