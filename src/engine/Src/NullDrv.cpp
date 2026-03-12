/*=============================================================================
	NullDrv.cpp: Null render device stubs (URenderDevice)
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

// --- URenderDevice ---
void URenderDevice::StartVideo(UCanvas *,int,int,int)
{
}

void URenderDevice::StaticConstructor()
{
}

void URenderDevice::StopVideo(UCanvas *)
{
}

int URenderDevice::OpenVideo(UCanvas *,char *,char *,int)
{
	return 0;
}

void URenderDevice::ChangeDrawingSurface(ER6SwitchSurface,int)
{
}

void URenderDevice::CloseVideo(UCanvas *)
{
}

void URenderDevice::DisplayVideo(UCanvas *,void *,int)
{
}

void URenderDevice::Draw3DLine(FVector,FVector,FColor,UTexture *,float,float,float,float)
{
}

void URenderDevice::GetAvailableResolutions(TArray<FResolutionInfo> &)
{
}

DWORD URenderDevice::GetAvailableVideoMemory()
{
	return 0;
}

void URenderDevice::HandleFullScreenEffects(int,int)
{
}

