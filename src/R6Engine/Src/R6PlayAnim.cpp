/*=============================================================================
	R6PlayAnim.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(UR6PlayAnim)

// --- UR6PlayAnim ---

IMPL_MATCH("R6Engine.dll", 0x1000a810)
void UR6PlayAnim::eventAnimFinished()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_AnimFinished), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
