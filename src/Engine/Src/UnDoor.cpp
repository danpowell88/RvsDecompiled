#pragma optimize("", off)
#include "EnginePrivate.h"
// --- ADoor ---
void ADoor::PostaddReachSpecs(APawn *)
{
	guard(ADoor::PostaddReachSpecs);
	// Part 1: set bForce flag on this door's own path specs
	TArray<UReachSpec*>* pl = (TArray<UReachSpec*>*)((BYTE*)this + 0x3d8);
	for (INT i = 0; i < pl->Num(); i++)
		*(DWORD*)((BYTE*)(*pl)(i) + 0x3c) |= 0x10;

	// Part 2: find any specs in the level that point TO this door and mark them too
	BYTE* LevelBase = (BYTE*)(*(DWORD*)((BYTE*)this + 0x144)); // Level (ALevelInfo*)
	for (ANavigationPoint* Nav = *(ANavigationPoint**)(LevelBase + 0x4d0);
		 Nav;
		 Nav = *(ANavigationPoint**)((BYTE*)Nav + 0x3a8))
	{
		TArray<UReachSpec*>* navPl = (TArray<UReachSpec*>*)((BYTE*)Nav + 0x3d8);
		for (INT j = 0; j < navPl->Num(); j++)
		{
			UReachSpec* spec = (*navPl)(j);
			if (*(ADoor**)((BYTE*)spec + 0x4c) == this)
				*(DWORD*)((BYTE*)spec + 0x3c) |= 0x10;
		}
	}
	unguard;
}

void ADoor::PostPath()
{
	guard(ADoor::PostPath);
	// Ghidra 0xd60c0: re-enable collision for linked door actors if bTempNoCollide was set
	if (*(DWORD*)((BYTE*)this + 1000) & 8)
	{
		for (AActor* A = *(AActor**)((BYTE*)this + 0x3ec); A; A = *(AActor**)((BYTE*)A + 0x3e0))
		{
			DWORD f = *(DWORD*)((BYTE*)A + 0xa8);
			A->SetCollision(1, (f >> 0xd) & 1, (f >> 0xe) & 1);
		}
	}
	unguard;
}

void ADoor::PrePath()
{
	guard(ADoor::PrePath);
	// Ghidra 0xd6000: disable collision on linked door actors that block both BSP and actors
	for (AActor* A = *(AActor**)((BYTE*)this + 0x3ec); A; A = *(AActor**)((BYTE*)A + 0x3e0))
	{
		DWORD f = *(DWORD*)((BYTE*)A + 0xa8);
		if ((f & 0x2000) && (f & 0x800))
		{
			A->SetCollision(0, (f >> 0xd) & 1, (f >> 0xe) & 1);
			*(DWORD*)((BYTE*)this + 1000) |= 8;
		}
	}
	unguard;
}

AActor * ADoor::AssociatedLevelGeometry()
{
	// Ghidra 0xd5af0, 7B: return pointer at offset 0x3ec
	return *(AActor**)((BYTE*)this + 0x3ec);
}

void ADoor::FindBase()
{
	guard(ADoor::FindBase);
	// Ghidra 0xd6d10: editor-only; wrap parent FindBase with unknown vtable hooks
	if (GIsEditor)
	{
		// vtable[0x178](this) -- unknown editor pre-FindBase hook
		typedef void (__thiscall* tVoidHook)(ADoor*);
		((tVoidHook*)((BYTE*)(*(void**)this) + 0x178))[0](this);
		ANavigationPoint::FindBase();
		// vtable[0x17c](this) -- unknown editor post-FindBase hook
		((tVoidHook*)((BYTE*)(*(void**)this) + 0x17c))[0](this);
	}
	unguard;
}

int ADoor::HasAssociatedLevelGeometry(AActor * Other)
{
	// Ghidra 0xd5b20, 45B: walk linked list at 0x3ec, next ptr at 0x3e0
	if (Other)
	{
		for (AActor* Node = *(AActor**)((BYTE*)this + 0x3ec); Node; Node = *(AActor**)((BYTE*)Node + 0x3e0))
		{
			if (Node == Other)
				return 1;
		}
	}
	return 0;
}

void ADoor::InitForPathFinding()
{
	guard(ADoor::InitForPathFinding);
	// Ghidra 0xd8030: build linked list of associated movers by DoorTag
	FName DoorTag = *(FName*)((BYTE*)this + 0x3f4);
	if (DoorTag == FName(NAME_None))
		return;

	*(INT*)((BYTE*)this + 0x3ec) = 0; // clear list head

	ULevel* lev = *(ULevel**)((BYTE*)this + 0x328);
	for (INT i = 0; i < lev->Actors.Num(); i++)
	{
		UObject* actor = lev->Actors(i);
		if (!actor || !actor->IsA(AMover::StaticClass()))
			continue;

		INT match = (*(FName*)((BYTE*)actor + 0x19c) == DoorTag) ? 1 : 0;

		if (!match && *(INT*)((BYTE*)this + 0x3ec) != 0)
		{
			FName headTag408 = *(FName*)(*(INT*)((BYTE*)this + 0x3ec) + 0x408);
			if (headTag408 != FName(NAME_None) &&
				*(FName*)((BYTE*)actor + 0x408) == headTag408)
				match = 1;
		}
		if (!match)
			continue;

		// Link this mover into the list
		*(ADoor**)((BYTE*)actor + 0x3fc) = this;
		if (*(INT*)((BYTE*)this + 0x3ec) == 0)
		{
			*(UObject**)((BYTE*)this + 0x3ec) = actor;
			*(UObject**)((BYTE*)actor + 0x3dc) = actor;
			*(INT*)(*(INT*)((BYTE*)this + 0x3ec) + 0x3e0) = 0;
		}
		else
		{
			*(INT*)((BYTE*)actor + 0x3dc) = *(INT*)((BYTE*)this + 0x3ec);
			*(DWORD*)((BYTE*)actor + 0x3e0) = *(DWORD*)(*(INT*)((BYTE*)this + 0x3ec) + 0x3e0);
			*(UObject**)(*(INT*)((BYTE*)this + 0x3ec) + 0x3e0) = actor;
		}
	}

	if (*(INT*)((BYTE*)this + 0x3ec) == 0)
		GWarn->Logf(TEXT("No Mover found for this Door"));
	unguard;
}

int ADoor::IsIdentifiedAs(FName)
{
	return 0;
}


