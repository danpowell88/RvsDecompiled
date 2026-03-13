/*=============================================================================
	R6HUD.cpp
	AR6HUD — heads-up display rendering (radar, character info, in-game map).
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(AR6HUD)

IMPLEMENT_FUNCTION(AR6HUD, -1, execDrawNativeHUD)
IMPLEMENT_FUNCTION(AR6HUD, -1, execHudStep)

// --- AR6HUD ---

void AR6HUD::Destroy()
{
}

void AR6HUD::DisplayOtherTeamInfo(FCanvasUtil &, UCanvas *, INT, AR6RainbowTeam *, FColor &, INT)
{
}

void AR6HUD::DrawCharacterInfo(AR6Rainbow *, FLOAT, FLOAT, FColor &, FCanvasUtil *, UCanvas *)
{
}

void AR6HUD::DrawInGameMap(FCameraSceneNode *, UViewport *)
{
}

void AR6HUD::DrawRadar(FCameraSceneNode *, UViewport *)
{
}

void AR6HUD::DrawSingleCharacterInfo(AR6Rainbow *, FLOAT, FLOAT, FColor &, FCanvasUtil *, UCanvas *)
{
}

void AR6HUD::Serialize(FArchive &)
{
}

void AR6HUD::Spawned()
{
}

void AR6HUD::UpdateHUDColors(FColor)
{
}

void AR6HUD::execDrawNativeHUD(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6HUD::execHudStep(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
