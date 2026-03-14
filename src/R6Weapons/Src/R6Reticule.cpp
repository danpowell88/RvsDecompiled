/*=============================================================================
	R6Reticule.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6Reticule)

// --- AR6Reticule ---

IMPL_APPROX("Ravenshield-specific; reconstructed from context")
void AR6Reticule::UpdateReticule(AR6PlayerController* PC, FLOAT DeltaTime)
{
	guard(AR6Reticule::UpdateReticule);
	if (PC != NULL
		&& *(INT*)((BYTE*)PC + 0x3d8) != 0                           // PC->Pawn != NULL
		&& *(INT*)(*(INT*)((BYTE*)PC + 0x3d8) + 0x4fc) != 0)         // Pawn->field_0x4fc != NULL
	{
		AActor* defaultActor = AR6Reticule::StaticClass()->GetDefaultActor();
		FLOAT defaultSpread = *(FLOAT*)((BYTE*)defaultActor + 0x560); // default class spread
		FLOAT pcSpread      = *(FLOAT*)((BYTE*)PC + 0x3b0);           // PC's current spread

		// Ghidra: (NAN(a)||NAN(b))==(a==b) — evaluates TRUE when a != b (ordered inequality).
		// C++ != has the same effective behaviour; NaN spreads are unreachable in practice.
		if (defaultSpread != pcSpread && !(*(BYTE*)((BYTE*)PC + 0x838) & 4))
			*(FLOAT*)((BYTE*)this + 0x3a4) = defaultSpread / pcSpread; // spread scale ratio
		else
			*(FLOAT*)((BYTE*)this + 0x3a4) = 1.0f;

		*(FLOAT*)((BYTE*)this + 0x3a0) = DeltaTime * *(FLOAT*)((BYTE*)this + 0x3a4);
		*(DWORD*)((BYTE*)this + 0x3a8) = *(DWORD*)((BYTE*)PC + 0x874);
		*(DWORD*)((BYTE*)this + 0x3ac) = *(DWORD*)((BYTE*)PC + 0x878);
	}
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
