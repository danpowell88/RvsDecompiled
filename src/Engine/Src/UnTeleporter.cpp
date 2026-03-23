#include "EnginePrivate.h"

// --- ATeleporter ---

IMPL_MATCH("Engine.dll", 0x103d7d70)
void ATeleporter::addReachSpecs(APawn* Scout, INT bOnlyChanged)
{
	guard(ATeleporter::addReachSpecs);
	// Retail 0xd7d70

	UObject* Outer = XLevel->GetOuter();
	UReachSpec* Spec = (UReachSpec*)UObject::StaticConstructObject(UReachSpec::StaticClass(), Outer, NAME_None, 0, NULL, GError, 0);

	// Toggle bit 0x800 (bPathsChanged) in the nav-flags DWORD at +0x3A4:
	// set it if already set or if doing a full rebuild (bOnlyChanged == 0).
	DWORD uVar1 = *(DWORD*)((BYTE*)this + 0x3A4);
	INT   iVar3 = ((uVar1 & 0x800) == 0 && bOnlyChanged != 0) ? 0 : 1;
	*(DWORD*)((BYTE*)this + 0x3A4) = ((DWORD)(iVar3 << 11) ^ uVar1) & 0x800u ^ uVar1;

	// ATeleporter::URL – FString script property at offset 0x408 (not in C++ header)
	FString* URL = (FString*)((BYTE*)this + 0x408);

	TArray<UReachSpec*>* pathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);

	for (INT i = 0; i < XLevel->Actors.Num(); i++)
	{
		AActor* Actor = XLevel->Actors(i);
		if (!Actor) continue;
		if (!Actor->IsA(ATeleporter::StaticClass())) continue;
		if (Actor == this) continue;

		// Connect if the other teleporter's Tag matches our URL, and at least one side's paths have changed
		DWORD otherFlags = *(DWORD*)((BYTE*)Actor + 0x3A4);
		DWORD thisFlags  = *(DWORD*)((BYTE*)this  + 0x3A4);
		if (*URL == *Actor->Tag && (thisFlags & 0x800 || otherFlags & 0x800))
		{
			Spec->Init();
			Spec->End             = (ANavigationPoint*)Actor;
			Spec->CollisionRadius = 40;   // 0x28
			Spec->CollisionHeight = 40;   // 0x28
			Spec->reachFlags      = 0x20; // R_SPECIAL
			Spec->Start           = this;
			Spec->Distance        = 100;

			INT idx = pathList->Add(1);
			(*pathList)(idx) = Spec;

			// Second ConstructObject – result unused in original binary (0xd7d70)
			UObject::StaticConstructObject(UReachSpec::StaticClass(), XLevel->GetOuter(), NAME_None, 0, NULL, GError, 0);
			break;
		}
	}

	ANavigationPoint::addReachSpecs(Scout, bOnlyChanged);
	unguard;
}


