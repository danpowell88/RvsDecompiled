/*=============================================================================
	R6Bullet.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6Bullet)

IMPLEMENT_FUNCTION(AR6Bullet, -1, execBulletGoesThroughSurface)

// --- AR6Bullet ---

IMPL_GHIDRA("R6Weapons.dll", 0x1000)
INT AR6Bullet::IsBlockedBy(AActor const* Other) const
{
	// Ghidra 0x1000: bullets only collide with level geometry and actors with the
	// 0x2000 flag (bit 13 of flags DWORD at +0xa8, reconstructed as bOnlyOwnerSee).
	// DIVERGENCE: bOnlyOwnerSee is the field name per the reconstructed header at that
	// bit position; the actual R6 usage is a "blockable-by-bullet" marker flag.
	ALevelInfo* pLevel = Level;
	if (Other != (AActor*)pLevel && !Other->bOnlyOwnerSee)
		return 0;
	if (!m_bIsGrenade)
	{
		// Non-grenades don't block with actors that have the 0x40000 flag
		// (bit 18 at +0xa8, reconstructed as bTrailerPrePivot).
		if (Other->bTrailerPrePivot)
			return 0;
	}
	else if (Other->bOnlyOwnerSee)
	{
		// Grenades are always blocked by bOnlyOwnerSee actors (world geometry).
		return 1;
	}
	return Super::IsBlockedBy(Other);
}

IMPL_GHIDRA("R6Weapons.dll", 0x1060)
INT AR6Bullet::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	// Ghidra 0x1060: non-grenade bullets don't trace against their own owner.
	if (!m_bIsGrenade && Other == Owner)
		return 0;
	return Super::ShouldTrace(Other, TraceFlags);
}

IMPL_GHIDRA("R6Weapons.dll", 0x1110)
FLOAT AR6Bullet::RangeConversion(FLOAT fRange)
{
	// Ghidra 0x1110: (fRange * m_fRangeConversionConst + 1.0) * fRange
	return (fRange * m_fRangeConversionConst + 1.0f) * fRange;
}

IMPL_GHIDRA("R6Weapons.dll", 0x1130)
FLOAT AR6Bullet::StunLoss(FLOAT fRange)
{
	// Ghidra 0x1130: fRange * m_fRangeConversionConst * fRange
	return fRange * m_fRangeConversionConst * fRange;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6Bullet::execBulletGoesThroughSurface(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AActor, TouchedSurface);
	P_GET_STRUCT(FVector, vHitLocation);
	P_GET_STRUCT_REF(FVector, vBulletVelocity);
	P_GET_STRUCT_REF(FVector, vRealHitLocation);
	P_GET_STRUCT_REF(FVector, vexitLocation);
	P_GET_STRUCT_REF(FVector, vexitNormal);
	P_GET_OBJECT_REF(UClass, TouchedEffects);
	P_GET_OBJECT_REF(UClass, ExitEffects);
	P_FINISH;
	*(BYTE*)Result = 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
