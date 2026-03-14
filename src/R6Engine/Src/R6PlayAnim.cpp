/*=============================================================================
	R6PlayAnim.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(UR6PlayAnim)

// --- UR6PlayAnim ---

IMPL_INFERRED("Standard UObject event thunk")
void UR6PlayAnim::eventAnimFinished()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_AnimFinished), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
