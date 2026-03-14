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
	guard(URenderDevice::StartVideo);
	unguard;
}

void URenderDevice::StaticConstructor()
{
	guard(URenderDevice::StaticConstructor);
	unguard;
}

void URenderDevice::StopVideo(UCanvas *)
{
	guard(URenderDevice::StopVideo);
	unguard;
}

int URenderDevice::OpenVideo(UCanvas *,char *,char *,int)
{
	guard(URenderDevice::OpenVideo);
	return 0;
	unguard;
}

void URenderDevice::ChangeDrawingSurface(ER6SwitchSurface,int)
{
	guard(URenderDevice::ChangeDrawingSurface);
	unguard;
}

void URenderDevice::CloseVideo(UCanvas *)
{
	guard(URenderDevice::CloseVideo);
	unguard;
}

void URenderDevice::DisplayVideo(UCanvas *,void *,int)
{
	guard(URenderDevice::DisplayVideo);
	unguard;
}

void URenderDevice::Draw3DLine(FVector,FVector,FColor,UTexture *,float,float,float,float)
{
	guard(URenderDevice::Draw3DLine);
	unguard;
}

void URenderDevice::GetAvailableResolutions(TArray<FResolutionInfo> &)
{
	guard(URenderDevice::GetAvailableResolutions);
	unguard;
}

DWORD URenderDevice::GetAvailableVideoMemory()
{
	guard(URenderDevice::GetAvailableVideoMemory);
	return 0;
	unguard;
}

void URenderDevice::HandleFullScreenEffects(int,int)
{
	guard(URenderDevice::HandleFullScreenEffects);
	unguard;
}


// =============================================================================
// UNullRenderDevice (moved from EngineClassImpl.cpp)
// =============================================================================

// UNullRenderDevice
// =============================================================================

INT UNullRenderDevice::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(UNullRenderDevice::Exec);
	return 0;
	unguard;
}

INT UNullRenderDevice::Init()
{
	guard(UNullRenderDevice::Init);
	return 1;
	unguard;
}

INT UNullRenderDevice::SetRes( UViewport* Viewport, INT NewX, INT NewY, INT NewColorBytes )
{
	guard(UNullRenderDevice::SetRes);
	return 0;
	unguard;
}

void UNullRenderDevice::Exit( UViewport* Viewport )
{
	guard(UNullRenderDevice::Exit);
	unguard;
}

void UNullRenderDevice::Flush( UViewport* Viewport )
{
	guard(UNullRenderDevice::Flush);
	unguard;
}

void UNullRenderDevice::Present( UViewport* Viewport )
{
	guard(UNullRenderDevice::Present);
	unguard;
}

void UNullRenderDevice::Unlock( FRenderInterface* RI )
{
	guard(UNullRenderDevice::Unlock);
	unguard;
}

void UNullRenderDevice::UpdateGamma( UViewport* Viewport )
{
	guard(UNullRenderDevice::UpdateGamma);
	unguard;
}

void UNullRenderDevice::FlushResource( QWORD ResourceId )
{
	guard(UNullRenderDevice::FlushResource);
	unguard;
}

void UNullRenderDevice::ReadPixels( UViewport* Viewport, FColor* Pixels )
{
	guard(UNullRenderDevice::ReadPixels);
	unguard;
}

void UNullRenderDevice::RestoreGamma()
{
	guard(UNullRenderDevice::RestoreGamma);
	unguard;
}

FRenderInterface* UNullRenderDevice::Lock( UViewport* Viewport, BYTE* HitData, INT* HitSize )
{
	guard(UNullRenderDevice::Lock);
	return NULL;
	unguard;
}

FRenderCaps* UNullRenderDevice::GetRenderCaps()
{
	guard(UNullRenderDevice::GetRenderCaps);
	return NULL;
	unguard;
}

void UNullRenderDevice::StaticConstructor()
{
	guard(UNullRenderDevice::StaticConstructor);
	unguard;
}


// --- Moved from EngineStubs.cpp ---
void UNullRenderDevice::SetEmulationMode(EHardwareEmulationMode) {}
INT UNullRenderDevice::SupportsTextureFormat(ETextureFormat) { return 1; }
