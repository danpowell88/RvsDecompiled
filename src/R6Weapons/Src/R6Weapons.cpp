/*=============================================================================
	R6Weapons.cpp: R6Weapons package init and AR6Weapons base class.
	Reconstructed for Ravenshield decompilation project.
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
	AR6Weapons — base weapon class.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(AR6Weapons)

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
	The End.
-----------------------------------------------------------------------------*/
