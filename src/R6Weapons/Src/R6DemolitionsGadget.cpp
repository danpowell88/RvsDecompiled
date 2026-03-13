/*=============================================================================
	R6DemolitionsGadget.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6DemolitionsGadget)

// --- AR6DemolitionsGadget ---

void AR6DemolitionsGadget::PreNetReceive()
{
	// Ghidra 0x3cd0: calls AR6AbstractWeapon::PreNetReceive directly, then saves snapshots.
	// Skips AR6Weapons::PreNetReceive (which would double-set g_net_old_nbBullets).
	AR6AbstractWeapon::PreNetReceive();
	// Save gadget bitfield bits 6 and 7 for change-detection in PostNetReceive.
	DWORD gadgetFlags = *(DWORD*)((BYTE*)this + 0x62c);
	g_net_old_bit6 = (gadgetFlags >> 6) & 1;
	g_net_old_bit7 = (gadgetFlags >> 7) & 1;
	// Save bullet count (Ghidra: DAT_1000cb08 = this[0x396]).
	g_net_old_nbBullets = *(BYTE*)((BYTE*)this + 0x396);
}

void AR6DemolitionsGadget::PostNetReceive()
{
	// Ghidra 0x4d10: calls AR6AbstractWeapon::PostNetReceive directly, skipping
	// AR6Weapons::PostNetReceive (whose bipod/HideAttachment logic doesn't apply here).
	AR6AbstractWeapon::PostNetReceive();

	// Fire HideAttachment or SetGadgetStaticMesh if gadget bits changed.
	DWORD gadgetFlags = *(DWORD*)((BYTE*)this + 0x62c);
	DWORD curBit6 = (gadgetFlags >> 6) & 1;
	DWORD curBit7 = (gadgetFlags >> 7) & 1;
	if (g_net_old_bit6 != curBit6)
		eventHideAttachment();
	else if (g_net_old_bit7 != curBit7)
		eventSetGadgetStaticMesh();

	// Fire NbBulletChange when bullet count changes (any direction).
	BYTE curNbBullets = *(BYTE*)((BYTE*)this + 0x396);
	if (g_net_old_nbBullets != curNbBullets)
		eventNbBulletChange();
}

void AR6DemolitionsGadget::eventNbBulletChange()
{
	ProcessEvent(FindFunctionChecked(R6WEAPONS_NbBulletChange), NULL);
}

void AR6DemolitionsGadget::eventSetGadgetStaticMesh()
{
	ProcessEvent(FindFunctionChecked(R6WEAPONS_SetGadgetStaticMesh), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
