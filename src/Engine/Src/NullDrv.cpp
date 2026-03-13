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


// =============================================================================
// UNullRenderDevice (moved from EngineClassImpl.cpp)
// =============================================================================

// UNullRenderDevice
// =============================================================================

INT UNullRenderDevice::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
INT UNullRenderDevice::Init() { return 1; }
INT UNullRenderDevice::SetRes( UViewport* Viewport, INT NewX, INT NewY, INT NewColorBytes ) { return 0; }
void UNullRenderDevice::Exit( UViewport* Viewport ) {}
void UNullRenderDevice::Flush( UViewport* Viewport ) {}
void UNullRenderDevice::Present( UViewport* Viewport ) {}
void UNullRenderDevice::Unlock( FRenderInterface* RI ) {}
void UNullRenderDevice::UpdateGamma( UViewport* Viewport ) {}
void UNullRenderDevice::FlushResource( QWORD ResourceId ) {}
void UNullRenderDevice::ReadPixels( UViewport* Viewport, FColor* Pixels ) {}
void UNullRenderDevice::RestoreGamma() {}
FRenderInterface* UNullRenderDevice::Lock( UViewport* Viewport, BYTE* HitData, INT* HitSize ) { return NULL; }
FRenderCaps* UNullRenderDevice::GetRenderCaps() { return NULL; }
void UNullRenderDevice::StaticConstructor() {}

