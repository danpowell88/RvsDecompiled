/*=============================================================================
	R6FileManagerCampaign.cpp
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(UR6FileManagerCampaign)

IMPLEMENT_FUNCTION(UR6FileManagerCampaign, -1, execLoadCampaign)
IMPLEMENT_FUNCTION(UR6FileManagerCampaign, -1, execSaveCampaign)

// --- UR6FileManagerCampaign ---

IMPL_INFERRED("Needs Ghidra analysis")
void UR6FileManagerCampaign::execLoadCampaign(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_INFERRED("Needs Ghidra analysis")
void UR6FileManagerCampaign::execSaveCampaign(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
