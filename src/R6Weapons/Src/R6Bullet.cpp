/*=============================================================================
	R6Bullet.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6Bullet)

IMPLEMENT_FUNCTION(AR6Bullet, -1, execBulletGoesThroughSurface)

// --- AR6Bullet ---

IMPL_MATCH("R6Weapons.dll", 0x10001000)
INT AR6Bullet::IsBlockedBy(AActor const* Other) const
{
	// Ghidra 0x10001000: tests DWORD[2] of AActor bitfield at +0xa8.
	// bit 13 (0x2000) = bBlockActors, bit 18 (0x40000) = m_bBulletGoThrough.
	ALevelInfo* pLevel = Level;
	if (Other != (AActor*)pLevel && !Other->bBlockActors)
		return 0;
	if (!m_bIsGrenade)
	{
		if (Other->m_bBulletGoThrough)
			return 0;
	}
	else if (Other->bBlockActors)
	{
		return 1;
	}
	return Super::IsBlockedBy(Other);
}

IMPL_MATCH("R6Weapons.dll", 0x10001060)
INT AR6Bullet::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	// Ghidra 0x1060: non-grenade bullets don't trace against their own owner.
	if (!m_bIsGrenade && Other == Owner)
		return 0;
	return Super::ShouldTrace(Other, TraceFlags);
}

IMPL_MATCH("R6Weapons.dll", 0x10001110)
FLOAT AR6Bullet::RangeConversion(FLOAT fRange)
{
	// Ghidra 0x1110: (fRange * m_fRangeConversionConst + 1.0) * fRange
	return (fRange * m_fRangeConversionConst + 1.0f) * fRange;
}

IMPL_MATCH("R6Weapons.dll", 0x10001130)
FLOAT AR6Bullet::StunLoss(FLOAT fRange)
{
	// Ghidra 0x1130: fRange * m_fRangeConversionConst * fRange
	return fRange * m_fRangeConversionConst * fRange;
}

IMPL_MATCH("R6Weapons.dll", 0x10003340)
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
