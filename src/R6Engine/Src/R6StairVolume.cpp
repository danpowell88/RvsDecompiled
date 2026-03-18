/*=============================================================================
	R6StairVolume.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6StairVolume)

// --- AR6StairVolume ---

IMPL_DIVERGE("Ghidra 0x1003b210 (2458b): calls UObject::IsA(param_1, (UClass*)PrivateStaticClass_exref) and StaticFindObjectChecked((UClass*)PrivateStaticClass_exref, ANY, L\"R6Stairs\") — PrivateStaticClass_exref is the R6Stairs actor class defined in R6GameCode.dll, which is not part of this rebuild. Note: function is 2458 bytes, not ~800b as the original TODO stated.")
void AR6StairVolume::AddMyMarker(AActor * param_1)
{
	guard(AR6StairVolume::AddMyMarker);
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1003bbf0)
void AR6StairVolume::CheckForErrors()
{
	guard(AR6StairVolume::CheckForErrors);

	ABrush::CheckForErrors();

	if (!m_pStairOrientation)
	{
		GWarn->Logf(TEXT("%s has no stair orientation marker."), GetName());
	}
	else
	{
		if (!Encompasses(m_pStairOrientation->Location))
		{
			// DIVERGENCE: retail format strings are in data sections; approximate text used.
			GWarn->Logf(TEXT("%s: stair orientation is outside the volume."), GetName());
			GWarn->Logf(TEXT("%s might not be the in %s "),
				m_pStairOrientation->GetName(), GetName());
		}
	}

	// Iterate all level actors; count AR6StairOrientation actors pointing to this volume.
	// Always ends with SetGameType("RGM_AllMode") when the list is exhausted.
	INT Count = 0;
	UObject* LastFound = NULL;
	for (INT i = 0; i < XLevel->Actors.Num(); i++)
	{
		AActor* Actor = XLevel->Actors(i);
		if (!Actor || !Actor->IsA(AR6StairOrientation::StaticClass()))
			continue;

		AR6StairOrientation* SO = (AR6StairOrientation*)Actor;
		if (SO->m_pStairVolume != this)
			continue;

		Count++;
		LastFound = Actor;

		if (Count > 1)
		{
			if (Count == 2)
			{
				GWarn->Logf(TEXT("%s has multiple stair orientation actors."), GetName());
				GWarn->Logf(TEXT("%s might not be the in %s "),
					LastFound->GetName(), GetName());
			}
			GWarn->Logf(TEXT("%s: extra stair orientation actor %s."),
				GetName(), Actor->GetName());
		}
	}

	SetGameType(FString(TEXT("RGM_AllMode")));

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1003b080)
void AR6StairVolume::PostScriptDestroyed()
{
	guard(AR6StairVolume::PostScriptDestroyed);
	SafeDestroyActor(m_pStairOrientation);
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1003af40)
void AR6StairVolume::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6StairVolume::RenderEditorInfo);
	AActor::RenderEditorInfo(SceneNode, RI, DA);
	// Propagate bDirectional editor flag to associated stair orientation actor
	if ((*(DWORD*)((BYTE*)this + 0xAC) & 0x4000) && m_pStairOrientation)
		*(DWORD*)((BYTE*)m_pStairOrientation + 0xAC) |= 0x4000;
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1003b100)
void AR6StairVolume::Spawned()
{
	guard(AR6StairVolume::Spawned);
	m_pStairOrientation = (AR6StairOrientation*)XLevel->SpawnActor(AR6StairOrientation::StaticClass());
	m_pStairOrientation->m_pStairVolume = this;
	m_pStairOrientation->bDirectional = 1;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
