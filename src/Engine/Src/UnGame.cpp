/*=============================================================================
	UnGame.cpp: Engine and game-engine core (UEngine, UGameEngine)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- UGameEngine ---
int UGameEngine::ReplaceTexture(FString,UTexture *)
{
	return 0;
}

int UGameEngine::LoadBackgroundImage(FString,UTexture *,UTexture *)
{
	return 0;
}

void UGameEngine::LoadRandomMenuBackgroundImage(FString)
{
}

void UGameEngine::PostRenderFullScreenEffects(FLevelSceneNode *,UViewport *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,APawn *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,UMaterial *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,UMesh *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,UStaticMesh *)
{
}

void UGameEngine::DisplayGameVideo(eGameVideoType)
{
}

void UGameEngine::InitializeMissionDescription(FString &)
{
}


// --- UEngine ---
void UEngine::StaticConstructor()
{
}

int UEngine::ReplaceTexture(FString,UTexture *)
{
	// Ghidra 0x10311900: destructs FString by-value param, returns 0.
	return 0;
}

void UEngine::Serialize(FArchive &Ar)
{
	guard(UEngine::Serialize);
	// Ghidra 0x10393120: UObject::Serialize, then Ar << fields at +0x40,+0x44(Client),+0x48(Audio),+0x4C,
	// then 5 global static UObject* pointers (BSS, always NULL on first run).
	UObject::Serialize(Ar);
	Ar << *(UObject**)((BYTE*)this + 0x40);	// unknown UObject* field before Client
	Ar << (UObject*&)Client;
	Ar << (UAudioSubsystem*&)Audio;
	Ar << *(UObject**)((BYTE*)this + 0x4C);	// unknown UObject* field after Audio
	// NOTE: Divergence — 5 global static UObject* refs (0x1066bcd0-bc) skipped; BSS/NULL at startup.
	unguard;
}

int UEngine::Key(UViewport*, EInputKey Key)
{
	guard(UEngine::Key);
	// Ghidra 0x103927d0: check GIsRunning, then dispatch to Client->InteractionMaster.
	if (GIsRunning && Client)
	{
		UInteractionMaster* IM = *(UInteractionMaster**)((BYTE*)Client + 0x94);
		if (IM)
			return IM->MasterProcessKeyType(Key);
	}
	return 0;
	unguard;
}

int UEngine::LoadBackgroundImage(FString,UTexture *,UTexture *)
{
	// Ghidra 0x103118e0: destructs FString by-value param, returns 1.
	return 1;
}

void UEngine::LoadRandomMenuBackgroundImage(FString)
{
	// Ghidra 0x103118d0: destructs FString by-value param, returns.
}

int UEngine::CacheArmPatch(FGuid *,DWORD *)
{
	return 0;
}

void UEngine::Destroy()
{
	guard(UEngine::Destroy);
	// Ghidra 0x10395d70: clean up engine-wide singletons then call base Destroy.
	RemoveFromRoot();
	Audio  = NULL;	// +0x48
	Client = NULL;	// +0x44
	FURL::StaticExit();
	GEngineMem.Exit();
	GCache.Exit(1);
	// NOTE: Divergence — GModMgr, GGameOptions, GServerOptions, GR6MissionDescription,
	// GR6GameManager cleanup omitted: types not yet declared in this translation unit.
	// NOTE: Divergence — GStatGraph, GTempLineBatcher cleanup omitted: same reason.
	UObject::Destroy();
	unguard;
}

int UEngine::ExecServerProf(const TCHAR*,int,FOutputDevice &)
{
	return 0;
}

void UEngine::InitAudio()
{
	guard(UEngine::InitAudio);
	// Ghidra 0x103938d0: load audio device class from ini and construct it.
	// UseSound flag lives at +0x88 (UBoolProperty registered in StaticConstructor).
	UBOOL UseSound = *(UBOOL*)((BYTE*)this + 0x88);
	if (UseSound && GIsClient)
	{
		if (!ParseParam(appCmdLine(), TEXT("NOSOUND")))
		{
			UClass* AudioClass = UObject::StaticLoadClass(
				UAudioSubsystem::StaticClass(), NULL,
				TEXT("ini:Engine.Engine.AudioDevice"), NULL, 1, NULL);
			// NOTE: Divergence — retail uses FUN_10393500(AudioClass, 0xffffffff) to
			// construct the subsystem; identity of FUN_10393500 not yet established.
			// Using StaticConstructObject as the closest available equivalent.
			Audio = (UAudioSubsystem*)UObject::StaticConstructObject(
				AudioClass, GetTransientPackage(), NAME_None, 0, NULL, GError, NULL);
			if (Audio)
			{
				// vtable[0x68/4 = 26] = UAudioSubsystem::Init()
				typedef int (__thiscall *tInit)(void*);
				int ok = ((tInit)(*(void***)Audio)[0x68/sizeof(void*)])(Audio);
				if (!ok)
				{
					GLog->Logf(NAME_Init, TEXT("Failed to create audio subsystem"));
					if (Audio) Audio->ConditionalDestroy();
					Audio = NULL;
				}
			}
		}
	}
	unguard;
}

int UEngine::InputEvent(UViewport* Viewport, EInputKey Key, EInputAction Action, float Delta)
{
	guard(UEngine::InputEvent);
	// Ghidra 0x10392870: GIsRunning guard, then IM dispatch, then UInput vtable dispatch.
	if (!GIsRunning)
		return 0;

	UInteractionMaster* IM = Client ? *(UInteractionMaster**)((BYTE*)Client + 0x94) : NULL;

	if (!IM || !IM->MasterProcessKeyEvent(Key, Action, Delta))
	{
		// UInput* lives at viewport+0x80; call PreProcess (vtable[0x6c]) and
		// Process (vtable[0x70]) on it.  Offsets confirmed from Ghidra.
		typedef int (__thiscall *tPreProcess)(void*, EInputKey, EInputAction, float);
		typedef int (__thiscall *tProcess)(void*, FOutputDevice*, EInputKey, EInputAction, float);
		void*  InputObj = *(void**)((BYTE*)Viewport + 0x80);
		void** Vtbl     = *(void***)InputObj;
		if (!((tPreProcess)Vtbl[0x6c/sizeof(void*)])(InputObj, Key, Action, Delta))
			return 0;
		if (!((tProcess)Vtbl[0x70/sizeof(void*)])(InputObj, GLog, Key, Action, Delta))
			return 0;
	}
	else if (Action == (EInputAction)3)
	{
		typedef int (__thiscall *tPreProcess)(void*, EInputKey, EInputAction, float);
		void*  InputObj = *(void**)((BYTE*)Viewport + 0x80);
		void** Vtbl     = *(void***)InputObj;
		((tPreProcess)Vtbl[0x6c/sizeof(void*)])(InputObj, Key, (EInputAction)3, Delta);
	}
	return 1;
	unguard;
}


// --- UInteractionMaster ---
int UInteractionMaster::MasterProcessKeyEvent(EInputKey,EInputAction,float)
{
	guard(UInteractionMaster::MasterProcessKeyEvent);
	// Ghidra 0x103b6880: calls FUN_1031ded0 (identity unknown) then eventProcess_KeyEvent
	// thunk, then iterates interactions.  Cannot implement without FUN_1031ded0.
	return 0;
	unguard;
}

int UInteractionMaster::MasterProcessKeyType(EInputKey)
{
	guard(UInteractionMaster::MasterProcessKeyType);
	// Ghidra 0x103b6780: same pattern as MasterProcessKeyEvent via FUN_1031ded0.
	return 0;
	unguard;
}

void UInteractionMaster::MasterProcessMessage(FString const &,float)
{
	guard(UInteractionMaster::MasterProcessMessage);
	// Ghidra 0x103b6bd0: FUN_1031ded0 then eventProcess_Message, iterates interactions.
	unguard;
}

void UInteractionMaster::MasterProcessPostRender(UCanvas *)
{
	guard(UInteractionMaster::MasterProcessPostRender);
	// Ghidra 0x103b6b10: iterates interactions, calls eventProcess_PostRender on each,
	// then calls on master.  Depends on FUN_1031ded0.
	unguard;
}

void UInteractionMaster::MasterProcessPreRender(UCanvas *)
{
	guard(UInteractionMaster::MasterProcessPreRender);
	// Ghidra 0x103b6a50: same pattern as MasterProcessPostRender.
	unguard;
}

void UInteractionMaster::MasterProcessTick(float)
{
	guard(UInteractionMaster::MasterProcessTick);
	// Ghidra 0x103b6980: FUN_1031ded0 then eventProcess_Tick, iterates interactions.
	unguard;
}

void UInteractionMaster::DisplayCopyright()
{
	guard(UInteractionMaster::DisplayCopyright);
	// Ghidra 0x103b6580: logs engine name and copyright strings via LocalizeGeneral.
	// Exact EName values for Logf calls not yet determined.
	unguard;
}

int UInteractionMaster::Exec(const TCHAR*,FOutputDevice &)
{
	// Ghidra 0x103b6660: if Level has interactions, dispatch Exec to first interaction
	// via vtable[0x30]; no guard in retail.
	return 0;
}

