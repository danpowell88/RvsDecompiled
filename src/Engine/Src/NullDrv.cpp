/*=============================================================================
NullDrv.cpp: Null render device stubs (URenderDevice)
Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
inline void* operator new(size_t, void* p) noexcept { return p; }
IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- URenderDevice ---
IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void URenderDevice::StartVideo(UCanvas *,int,int,int)
{
guard(URenderDevice::StartVideo);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void URenderDevice::StaticConstructor()
{
guard(URenderDevice::StaticConstructor);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void URenderDevice::StopVideo(UCanvas *)
{
guard(URenderDevice::StopVideo);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
int URenderDevice::OpenVideo(UCanvas *,char *,char *,int)
{
guard(URenderDevice::OpenVideo);
return 0;
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void URenderDevice::ChangeDrawingSurface(ER6SwitchSurface,int)
{
guard(URenderDevice::ChangeDrawingSurface);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void URenderDevice::CloseVideo(UCanvas *)
{
guard(URenderDevice::CloseVideo);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void URenderDevice::DisplayVideo(UCanvas *,void *,int)
{
guard(URenderDevice::DisplayVideo);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void URenderDevice::Draw3DLine(FVector,FVector,FColor,UTexture *,float,float,float,float)
{
guard(URenderDevice::Draw3DLine);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void URenderDevice::GetAvailableResolutions(TArray<FResolutionInfo> &)
{
guard(URenderDevice::GetAvailableResolutions);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
DWORD URenderDevice::GetAvailableVideoMemory()
{
guard(URenderDevice::GetAvailableVideoMemory);
return 0;
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
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

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
INT UNullRenderDevice::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
guard(UNullRenderDevice::Exec);
return 0;
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
INT UNullRenderDevice::Init()
{
guard(UNullRenderDevice::Init);
return 1;
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
INT UNullRenderDevice::SetRes( UViewport* Viewport, INT NewX, INT NewY, INT NewColorBytes )
{
guard(UNullRenderDevice::SetRes);
return 0;
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void UNullRenderDevice::Exit( UViewport* Viewport )
{
guard(UNullRenderDevice::Exit);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void UNullRenderDevice::Flush( UViewport* Viewport )
{
guard(UNullRenderDevice::Flush);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void UNullRenderDevice::Present( UViewport* Viewport )
{
guard(UNullRenderDevice::Present);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void UNullRenderDevice::Unlock( FRenderInterface* RI )
{
guard(UNullRenderDevice::Unlock);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void UNullRenderDevice::UpdateGamma( UViewport* Viewport )
{
guard(UNullRenderDevice::UpdateGamma);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void UNullRenderDevice::FlushResource( QWORD ResourceId )
{
guard(UNullRenderDevice::FlushResource);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void UNullRenderDevice::ReadPixels( UViewport* Viewport, FColor* Pixels )
{
guard(UNullRenderDevice::ReadPixels);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void UNullRenderDevice::RestoreGamma()
{
guard(UNullRenderDevice::RestoreGamma);
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
FRenderInterface* UNullRenderDevice::Lock( UViewport* Viewport, BYTE* HitData, INT* HitSize )
{
guard(UNullRenderDevice::Lock);
return NULL;
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
FRenderCaps* UNullRenderDevice::GetRenderCaps()
{
guard(UNullRenderDevice::GetRenderCaps);
return NULL;
unguard;
}

IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void UNullRenderDevice::StaticConstructor()
{
guard(UNullRenderDevice::StaticConstructor);
unguard;
}


// --- Moved from EngineStubs.cpp ---
IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void UNullRenderDevice::SetEmulationMode(EHardwareEmulationMode) {}
IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
INT UNullRenderDevice::SupportsTextureFormat(ETextureFormat) { return 1; }
