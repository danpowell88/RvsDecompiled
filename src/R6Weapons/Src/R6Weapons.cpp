/*=============================================================================
	R6Weapons.cpp: R6Weapons package — weapons, bullets, gadgets, grenades.
	Reconstructed for Ravenshield decompilation project.

	9 classes, 132 exports. Weapon mechanics, bullets, gadgets, grenades,
	demolitions, heartbeat sensor, reticule, smoke cloud.
=============================================================================*/

#include "R6WeaponsPrivate.h"

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(R6Weapons)

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) R6WEAPONS_API FName R6WEAPONS_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6WeaponsClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	IMPLEMENT_CLASS for all 9 exported classes.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(AR6Bullet)
IMPLEMENT_CLASS(AR6DemolitionsGadget)
IMPLEMENT_CLASS(AR6Gadget)
IMPLEMENT_CLASS(AR6Grenade)
IMPLEMENT_CLASS(AR6GrenadeWeapon)
IMPLEMENT_CLASS(AR6HBSGadget)
IMPLEMENT_CLASS(AR6Reticule)
IMPLEMENT_CLASS(AR6SmokeCloud)
IMPLEMENT_CLASS(AR6Weapons)

/*-----------------------------------------------------------------------------
	Native function exports (IMPLEMENT_FUNCTION).
	All dispatched by name (INDEX_NONE / -1).
-----------------------------------------------------------------------------*/

IMPLEMENT_FUNCTION(AR6Bullet, -1, execBulletGoesThroughSurface)
IMPLEMENT_FUNCTION(AR6HBSGadget, -1, execToggleHeartBeatProperties)

/*-----------------------------------------------------------------------------
	AR6Weapons — virtual method stubs.
-----------------------------------------------------------------------------*/

void AR6Weapons::ProcessState(FLOAT DeltaTime)
{
	Super::ProcessState(DeltaTime);
}

INT AR6Weapons::IsBlockedBy(AActor const* Other) const
{
	return Super::IsBlockedBy(Other);
}

void AR6Weapons::PreNetReceive()
{
	Super::PreNetReceive();
}

void AR6Weapons::PostNetReceive()
{
	Super::PostNetReceive();
}

void AR6Weapons::TickAuthoritative(FLOAT DeltaTime)
{
	Super::TickAuthoritative(DeltaTime);
}

INT AR6Weapons::GetHeartBeatStatus()
{
	return 0;
}

void AR6Weapons::ShowWeaponParticles(AR6Pawn*, AR6PlayerController*)
{
}

FLOAT AR6Weapons::ComputeEffectiveAccuracy(FLOAT A, FLOAT B)
{
	return 0.f;
}

FLOAT AR6Weapons::GetMovingModifier(FLOAT A, FLOAT B)
{
	return 0.f;
}

bool AR6Weapons::WeaponIsNotFiring()
{
	return true;
}

void AR6Weapons::eventHideAttachment()
{
	ProcessEvent(FindFunctionChecked(R6WEAPONS_HideAttachment), NULL);
}

/*-----------------------------------------------------------------------------
	AR6Bullet
-----------------------------------------------------------------------------*/

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
	AR6Grenade
-----------------------------------------------------------------------------*/

void AR6Grenade::PostNetReceive()
{
	Super::PostNetReceive();
}

/*-----------------------------------------------------------------------------
	AR6DemolitionsGadget
-----------------------------------------------------------------------------*/

void AR6DemolitionsGadget::PreNetReceive()
{
	Super::PreNetReceive();
}

void AR6DemolitionsGadget::PostNetReceive()
{
	Super::PostNetReceive();
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
	AR6SmokeCloud
-----------------------------------------------------------------------------*/

INT AR6SmokeCloud::IsBlockedBy(AActor const* Other) const
{
	return 0;
}

INT AR6SmokeCloud::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	return 0;
}

/*-----------------------------------------------------------------------------
	AR6HBSGadget
-----------------------------------------------------------------------------*/

INT AR6HBSGadget::GetHeartBeatStatus()
{
	return m_bHeartBeatOn ? 1 : 0;
}

void AR6HBSGadget::execToggleHeartBeatProperties(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	AR6Reticule
-----------------------------------------------------------------------------*/

void AR6Reticule::UpdateReticule(AR6PlayerController* PC, FLOAT DeltaTime)
{
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
