/*=============================================================================
	R6HUD.cpp
	AR6HUD — heads-up display rendering (radar, character info, in-game map).
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(AR6HUD)

IMPLEMENT_FUNCTION(AR6HUD, -1, execDrawNativeHUD)
IMPLEMENT_FUNCTION(AR6HUD, -1, execHudStep)

// --- AR6HUD ---

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void AR6HUD::Destroy()
{
	// Clear the object reference held by the HUD (offset 0x5AC)
	*(void**)((BYTE*)this + 0x5ac) = NULL;
	AActor::Destroy();
}

IMPL_TODO("Needs Ghidra analysis")
void AR6HUD::DisplayOtherTeamInfo(FCanvasUtil &, UCanvas *, INT, AR6RainbowTeam *, FColor &, INT)
{
	guard(AR6HUD::DisplayOtherTeamInfo);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6HUD::DrawCharacterInfo(AR6Rainbow *, FLOAT, FLOAT, FColor &, FCanvasUtil *, UCanvas *)
{
	guard(AR6HUD::DrawCharacterInfo);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6HUD::DrawInGameMap(FCameraSceneNode *, UViewport *)
{
	guard(AR6HUD::DrawInGameMap);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6HUD::DrawRadar(FCameraSceneNode *, UViewport *)
{
	guard(AR6HUD::DrawRadar);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6HUD::DrawSingleCharacterInfo(AR6Rainbow *, FLOAT, FLOAT, FColor &, FCanvasUtil *, UCanvas *)
{
	guard(AR6HUD::DrawSingleCharacterInfo);
	unguard;
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
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

IMPL_TODO("Needs Ghidra analysis")
void AR6HUD::Spawned()
{
	guard(AR6HUD::Spawned);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6HUD::UpdateHUDColors(FColor)
{
	guard(AR6HUD::UpdateHUDColors);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6HUD::execDrawNativeHUD(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6HUD::execHudStep(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
