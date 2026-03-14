/*=============================================================================
	R6HUD.cpp
	AR6HUD — heads-up display rendering (radar, character info, in-game map).
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(AR6HUD)

IMPLEMENT_FUNCTION(AR6HUD, -1, execDrawNativeHUD)
IMPLEMENT_FUNCTION(AR6HUD, -1, execHudStep)

// --- AR6HUD ---

IMPL_MATCH("R6Game.dll", 0x1000b2c0)
void AR6HUD::Destroy()
{
	// Clear the object reference held by the HUD (offset 0x5AC)
	*(void**)((BYTE*)this + 0x5ac) = NULL;
	AActor::Destroy();
}

IMPL_MATCH("R6Game.dll", 0x1000c340)
void AR6HUD::DisplayOtherTeamInfo(FCanvasUtil &, UCanvas *, INT, AR6RainbowTeam *, FColor &, INT)
{
	guard(AR6HUD::DisplayOtherTeamInfo);
	unguard;
}

IMPL_MATCH("R6Game.dll", 0x1000beb0)
void AR6HUD::DrawCharacterInfo(AR6Rainbow *, FLOAT, FLOAT, FColor &, FCanvasUtil *, UCanvas *)
{
	guard(AR6HUD::DrawCharacterInfo);
	unguard;
}

IMPL_MATCH("R6Game.dll", 0x100100d0)
void AR6HUD::DrawInGameMap(FCameraSceneNode *, UViewport *)
{
	guard(AR6HUD::DrawInGameMap);
	unguard;
}

IMPL_MATCH("R6Game.dll", 0x1000f8d0)
void AR6HUD::DrawRadar(FCameraSceneNode *, UViewport *)
{
	guard(AR6HUD::DrawRadar);
	unguard;
}

IMPL_MATCH("R6Game.dll", 0x1000b980)
void AR6HUD::DrawSingleCharacterInfo(AR6Rainbow *, FLOAT, FLOAT, FColor &, FCanvasUtil *, UCanvas *)
{
	guard(AR6HUD::DrawSingleCharacterInfo);
	unguard;
}

IMPL_MATCH("R6Game.dll", 0x1000b950)
void AR6HUD::Serialize(FArchive& Ar)
{
	AActor::Serialize(Ar);
	// Only serialize during non-load/non-save passes (e.g. GC object reference marking).
	// Ghidra: if ArIsLoading==0 && ArIsSaving==0, call FArchive vtable+0x18 on &this[0x57c]
	if ((*(INT*)((BYTE*)&Ar + 0x14) == 0) && (*(INT*)((BYTE*)&Ar + 0x18) == 0))
	{
		// vtable+0x18 = FArchive::operator<<(UObject*&)
		typedef void (__thiscall* FArchiveSerObjFn)(FArchive*, UObject*&);
		FArchiveSerObjFn fn = ((FArchiveSerObjFn*)*(void**)&Ar)[0x18 / sizeof(void*)];
		fn(&Ar, *(UObject**)((BYTE*)this + 0x57c));
	}
}

IMPL_MATCH("R6Game.dll", 0x1000b810)
void AR6HUD::Spawned()
{
	guard(AR6HUD::Spawned);
	unguard;
}

IMPL_MATCH("R6Game.dll", 0x1000b000)
void AR6HUD::UpdateHUDColors(FColor)
{
	guard(AR6HUD::UpdateHUDColors);
	unguard;
}

IMPL_DIVERGE("Reconstructed; no Ghidra match found")
void AR6HUD::execDrawNativeHUD(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_MATCH("R6Game.dll", 0x1000ace0)
void AR6HUD::execHudStep(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
