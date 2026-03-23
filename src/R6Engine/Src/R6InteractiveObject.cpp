/*=============================================================================
	R6InteractiveObject.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6InteractiveObject)

// Statics used by AR6InteractiveObject PreNetReceive/PostNetReceive.
static FLOAT GInteractiveObject_OldNetDamagePercentage;

// --- AR6InteractiveObject ---

IMPL_MATCH("R6Engine.dll", 0x1001c490)
void AR6InteractiveObject::CheckForErrors()
{
	guard(AR6InteractiveObject::CheckForErrors);

	// Only check actors of type 8 (interactive objects with a StaticMesh)
	if (((BYTE*)this)[0x2f] == 0x8 && *(int*)((BYTE*)this + 0x170) != 0 &&
		*(int*)((BYTE*)this + 0x444) > 0)
	{
		for (INT stateIdx = 0; stateIdx < *(int*)((BYTE*)this + 0x444); stateIdx++)
		{
			INT stateBase = *(int*)((BYTE*)this + 0x440) + stateIdx * 0x3c;
			INT actorCount = *(int*)(stateBase + 0x20);

			for (INT actorIdx = 0; actorIdx < actorCount; actorIdx++)
			{
				INT actorEntry = *(int*)(stateBase + 0x1c) + actorIdx * 0x10;
				FString* tagName = (FString*)(actorEntry + 4);

				if (*tagName != TEXT(""))
				{
					FString tagCopy = *tagName;
					UStaticMesh* SM = *(UStaticMesh**)((BYTE*)this + 0x170);
					FTags* Tag = SM->GetTag(tagCopy);
					if (Tag == NULL)
					{
						GWarn->Logf(TEXT("Invalid tag <%s> in m_StateList[%d].ActorList[%d]"),
							**tagName, stateIdx, *(int*)(actorEntry + 0xc));
					}
				}
			}
		}
	}

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1001c390)
void AR6InteractiveObject::PostNetReceive()
{
	guard(AR6InteractiveObject::PostNetReceive);
	AActor::PostNetReceive();

	// If net damage percentage changed, fire the damage state event
	if (m_fNetDamagePercentage != GInteractiveObject_OldNetDamagePercentage)
		eventSetNewDamageState(m_fNetDamagePercentage);

	// Sync replicated skins to actual Skins array
	for (INT i = 0; i < 4; i++)
	{
		if (m_aRepSkins[i] != m_aOldSkins[i])
		{
			if (Skins.Num() < 4)
				Skins.AddZeroed(4);
			m_aOldSkins[i] = m_aRepSkins[i];
			Skins(i) = m_aRepSkins[i];
		}
	}

	unguard;
}

// Verified from Ghidra: function at 0x1c220 is a no-op (body is just 'return').
// Verified from Ghidra: function at 0x1c220 is a no-op (body is just 'return').
IMPL_MATCH("R6Engine.dll", 0x1001c220)
void AR6InteractiveObject::PostScriptDestroyed()
{
	guard(AR6InteractiveObject::PostScriptDestroyed);
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1001c1a0)
void AR6InteractiveObject::PreNetReceive()
{
	guard(AR6InteractiveObject::PreNetReceive);
	AActor::PreNetReceive();
	GInteractiveObject_OldNetDamagePercentage = m_fNetDamagePercentage;
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1001c080)
void AR6InteractiveObject::RenderEditorInfo(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AR6InteractiveObject::RenderEditorInfo);

	if ((*(DWORD*)((BYTE*)this + 0xAC) & 0x4000) != 0 &&
		*(FLOAT*)((BYTE*)this + 0x3b4) != 0.0f)
	{
		FLineBatcher Batcher(*(FRenderInterface**)(*(INT*)((BYTE*)SceneNode + 4) + 0x164), 1, 0);

		FPlane Plane;
		Plane.X = 0.75f;  // 0x3f400000
		Plane.Y = 1.0f;   // 0x3f800000
		Plane.Z = 0.0f;
		Plane.W = 0.0f;
		FColor Color(Plane);

		FVector Pos;
		Pos.X = *(FLOAT*)((BYTE*)this + 0x234);
		Pos.Y = *(FLOAT*)((BYTE*)this + 0x238);
		Pos.Z = *(FLOAT*)((BYTE*)this + 0x23c);
		Batcher.DrawSphere(Pos, Color, 10.0f, 8);
	}

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1001bf60)
INT AR6InteractiveObject::ShouldTrace(AActor* Other, DWORD TraceFlags)
{
	guard(AR6InteractiveObject::ShouldTrace);

	// R6-specific trace flag: always trace regardless
	if (TraceFlags & 0x800000)
		return 1;

	// Shot-through objects are skipped when shot-through trace requested
	if ((TraceFlags & 0x400000) && m_bShotThrough)
		return 0;

	// Corona visibility check
	if (TraceFlags & TRACE_VisibleNonColliding)
		return m_bBlockCoronas ? 1 : 0;

	// See-through check
	if ((TraceFlags & 0x20000) && m_bSeeThrough)
		return 0;

	// Bullet-goes-through check
	if ((TraceFlags & 0x40000) && m_bBulletGoThrough)
		return 0;

	// Pawn-goes-through check
	if ((TraceFlags & 0x200000) && m_bPawnGoThrough)
		return 0;

	// If tracing for movers, always trace interactive objects
	if (TraceFlags & TRACE_Movers)
		return 1;

	// Fall through to AActor base
	if (!AActor::ShouldTrace(Other, TraceFlags))
		return 0;

	return 1;

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10008e10)
void AR6InteractiveObject::eventSetNewDamageState(FLOAT A)
{
	struct { FLOAT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetNewDamageState), &Parms);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
