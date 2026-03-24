/*=============================================================================
NullDrv.cpp: Null render device stubs (URenderDevice)
Reconstructed for Ravenshield decompilation project.
=============================================================================*/

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"

// BLIT_Direct3D from UnCamera.h (can't include directly — redefinition conflicts)
enum { BLIT_Direct3D = 0x0010 };
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- URenderDevice ---
IMPL_EMPTY("NullDrv — headless renderer; retail body is also empty")
void URenderDevice::StartVideo(UCanvas *,int,int,int)
{
guard(URenderDevice::StartVideo);
unguard;
}

IMPL_TODO("NullDrv — headless renderer; retail body is also empty - retail has 424B at 0x10382a10")
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

IMPL_MATCH("Engine.dll", 0x103033a0)
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

IMPL_MATCH("Engine.dll", 0x103033b0)
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

IMPL_MATCH("Engine.dll", 0x1036c9f0)
INT UNullRenderDevice::Init()
{
	// Retail: 41B. Initialize the scratch byte buffer at this+0xf8.
	FArray* arr = (FArray*)((BYTE*)this + 0xf8);
	arr->Empty(1, 0);
	arr->Add(0x10000, 1);
	return 1;
}

IMPL_MATCH("Engine.dll", 0x1036c950)
INT UNullRenderDevice::SetRes( UViewport* Viewport, INT NewX, INT NewY, INT NewColorBytes )
{
guard(UNullRenderDevice::SetRes);
verify( Viewport->ResizeViewport( BLIT_Direct3D, NewX, NewY ) );
return 1;
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

// Ghidra 0x1036c9a0: 9 bytes, no SEH — returns pointer to embedded FRenderInterface at this+0xC8
IMPL_MATCH("Engine.dll", 0x1036c9a0)
FRenderInterface* UNullRenderDevice::Lock( UViewport* Viewport, BYTE* HitData, INT* HitSize )
{
	return (FRenderInterface*)((BYTE*)this + 0xC8);
}

// Ghidra 0x1036c9b0: 7 bytes, no SEH — returns pointer to embedded FRenderCaps at this+0x104
IMPL_MATCH("Engine.dll", 0x1036c9b0)
FRenderCaps* UNullRenderDevice::GetRenderCaps()
{
	return (FRenderCaps*)((BYTE*)this + 0x104);
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
IMPL_MATCH("Engine.dll", 0x10487ce0)
INT UNullRenderDevice::SupportsTextureFormat(ETextureFormat) { return 1; }

