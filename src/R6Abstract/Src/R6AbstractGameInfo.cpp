/*=============================================================================
	R6AbstractGameInfo.cpp
	AR6AbstractGameInfo, AR6AbstractHUD, AR6AbstractInsertionZone,
	AR6AbstractExtractionZone, UR6AbstractNoiseMgr — abstract game/zone/HUD.
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractExtractionZone)
IMPLEMENT_CLASS(AR6AbstractGameInfo)
IMPLEMENT_CLASS(AR6AbstractHUD)
IMPLEMENT_CLASS(AR6AbstractInsertionZone)
IMPLEMENT_CLASS(UR6AbstractNoiseMgr)

/*-----------------------------------------------------------------------------
	AR6AbstractExtractionZone / AR6AbstractInsertionZone
-----------------------------------------------------------------------------*/

void AR6AbstractExtractionZone::CheckForErrors()
{
	Super::CheckForErrors();
}

void AR6AbstractInsertionZone::CheckForErrors()
{
	Super::CheckForErrors();
}

/*-----------------------------------------------------------------------------
	UR6AbstractNoiseMgr
-----------------------------------------------------------------------------*/

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
