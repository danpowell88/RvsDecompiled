/*=============================================================================
	R6Grenade.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6Grenade)

// --- AR6Grenade ---

IMPL_MATCH("R6Weapons.dll", 0x10001150)
void AR6Grenade::PostNetReceive()
{
	Super::PostNetReceive();

	// Sync replicated weapon pointer to local cache.
	// Ghidra 0x1150: field at +0x2c (replicated AR6DemolitionsGadget* m_Weapon) is copied
	// to cache field at +0x3f8; when it transitions to null, reset the 3 FVector components
	// at +0x2f0..+0x2f8 (likely spawn/impact position).
	AActor* pReplWeapon  = *(AActor**)((BYTE*)this + 0x2c);
	AActor** pCachedWeap = (AActor**)((BYTE*)this + 0x3f8);
	if (pReplWeapon == NULL)
	{
		AActor* pOldCache = *pCachedWeap;
		*pCachedWeap = NULL;
		if (pOldCache != NULL)
		{
			*(INT*)((BYTE*)this + 0x2f0) = 0;
			*(INT*)((BYTE*)this + 0x2f4) = 0;
			*(INT*)((BYTE*)this + 0x2f8) = 0;
		}
	}
	else
	{
		*pCachedWeap = pReplWeapon;
	}
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

