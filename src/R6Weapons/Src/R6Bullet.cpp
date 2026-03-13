/*=============================================================================
	R6Bullet.cpp
=============================================================================*/

#include "R6WeaponsPrivate.h"

IMPLEMENT_CLASS(AR6Bullet)

IMPLEMENT_FUNCTION(AR6Bullet, -1, execBulletGoesThroughSurface)

// --- AR6Bullet ---

INT AR6Bullet::IsBlockedBy(AActor const* Other) const
{
	return Super::IsBlockedBy(Other);
}

INT AR6Bullet::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	return Super::ShouldTrace(Other, TraceFlags);
}

FLOAT AR6Bullet::RangeConversion(FLOAT fRange)
{
	return 0.f;
}

FLOAT AR6Bullet::StunLoss(FLOAT fRange)
{
	return 0.f;
}

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
