/*=============================================================================
	R6Door.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6Door)

// --- AR6Door ---

IMPL_MATCH("R6Engine.dll", 0x1001cfb0)
AActor * AR6Door::AssociatedLevelGeometry()
{
	// Retail 0x1cfb0: shared null-stub, no SEH frame.
	return NULL;
}

IMPL_MATCH("R6Engine.dll", 0x1001cfc0)
void AR6Door::CheckForErrors()
{
	guard(AR6Door::CheckForErrors);

	AActor::CheckForErrors();

	// Validate non-window doors have path connections
	if (m_RotatingDoor && !m_RotatingDoor->m_bTreatDoorAsWindow)
	{
		if (PathList.Num() == 0)
		{
			// NOTE: Exact format string may differ from retail binary
			GWarn->Logf(TEXT("%s has no path connections"), GetName());
		}
		SetGameType(FString(TEXT("RGM_AllMode ")));
	}

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1001d440)
INT AR6Door::PrunePaths()
{
	guard(AR6Door::PrunePaths);

	INT Count = 0;

	for (INT i = 0; i < PathList.Num(); i++)
	{
		for (INT j = 0; j < PathList.Num(); j++)
		{
			if (PathList(i)->End != m_CorrespondingDoor && i != j && PathList(j)->bPruned == 0)
			{
				if (*PathList(j) <= *PathList(i))
				{
					if (PathList(j)->End->FindAlternatePath(PathList(i), PathList(j)->Distance))
					{
						Count++;
						PathList(i)->bPruned = 1;
						j = PathList.Num();
					}
				}
			}
		}
	}

	CleanUpPruned();
	return Count;

	unguard;
}

IMPL_TODO("FLineBatcher drawing stub; Ghidra confirms drawing-only body - retail has 6773B at 0x1001d880")
void AR6Door::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6Door::RenderEditorInfo);
	// Ghidra: draws direction lines and arc spheres for the door's swing when selected.
	// FLineBatcher drawing is a stub in this project.
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10020800)
void AR6Door::addReachSpecs(APawn* Scout, INT bOnlyChanged)
{
	guard(AR6Door::addReachSpecs);

	// Only create reach specs if this door has a rotating door that isn't treated as a window
	if (m_RotatingDoor && !m_RotatingDoor->m_bTreatDoorAsWindow)
	{
		if (m_CorrespondingDoor)
		{
			UReachSpec* Spec = ConstructObject<UReachSpec>(UReachSpec::StaticClass(), XLevel->GetOuter(), NAME_None, RF_Public);
			Spec->Init();
			Spec->CollisionRadius = 40;
			Spec->CollisionHeight = 85;
			Spec->reachFlags = 17;
			Spec->Start = this;
			Spec->End = m_CorrespondingDoor;
			FVector Diff = Location - m_CorrespondingDoor->Location;
			Spec->Distance = (INT)Diff.Size();
			PathList.AddItem(Spec);
		}

		ANavigationPoint::addReachSpecs(Scout, bOnlyChanged);
	}

	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
