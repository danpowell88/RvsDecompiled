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

int UEngine::Key(UViewport *,EInputKey)
{
	return 0;
}

int UEngine::LoadBackgroundImage(FString,UTexture *,UTexture *)
{
	return 0;
}

void UEngine::LoadRandomMenuBackgroundImage(FString)
{
}

int UEngine::CacheArmPatch(FGuid *,DWORD *)
{
	return 0;
}

void UEngine::Destroy()
{
}

int UEngine::ExecServerProf(const TCHAR*,int,FOutputDevice &)
{
	return 0;
}

void UEngine::InitAudio()
{
}

int UEngine::InputEvent(UViewport *,EInputKey,EInputAction,float)
{
	return 0;
}


// --- UInteractionMaster ---
int UInteractionMaster::MasterProcessKeyEvent(EInputKey,EInputAction,float)
{
	return 0;
}

int UInteractionMaster::MasterProcessKeyType(EInputKey)
{
	return 0;
}

void UInteractionMaster::MasterProcessMessage(FString const &,float)
{
}

void UInteractionMaster::MasterProcessPostRender(UCanvas *)
{
}

void UInteractionMaster::MasterProcessPreRender(UCanvas *)
{
}

void UInteractionMaster::MasterProcessTick(float)
{
}

void UInteractionMaster::DisplayCopyright()
{
}

int UInteractionMaster::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

