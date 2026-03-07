/*=============================================================================
	D3DDrv.cpp: D3DDrv package — Direct3D 8 rendering driver.
	Reconstructed for Ravenshield decompilation project.

	Implements UD3DRenderDevice — the D3D8 backend for Ravenshield's renderer.
	All method bodies are stubs; the real driver contains ~170KB of GPU state
	machine code managing vertex buffers, pixel/vertex shaders, render
	targets, texture stages, and the Bink video playback surface.

	Notable functions reconstructed from Ghidra analysis:
	  FUN_10001020 — SSE-aware memcpy (exported as part of image data path)
	  FD3DRenderInterface — render dispatch class (thunks in _thunks.cpp)

	Divergences from retail byte parity:
	  - All virtual method bodies are stub returns; implementation omitted.
	  - _pad3/_pad7/_pad9/_pad10 in UD3DRenderDevice match the CSDK Unknown*
	    fields; struct size should be identical to retail.
	  - FD3DRenderInterface, FD3DResource, FD3DPixelShader, FD3DVertexShader
	    are forward-declared only; their full implementations are deferred to
	    a later phase when the render loop is reconstructed.
=============================================================================*/

#include "D3DDrvPrivate.h"

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(D3DDrv)

/*-----------------------------------------------------------------------------
	Name/function registration.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) D3DDRV_API FName D3DDRV_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "D3DDrvClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	Class registration.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UD3DRenderDevice)

/*=============================================================================
	UD3DRenderDevice implementation stubs.

	The real implementation is a state machine wrapping IDirect3DDevice8.
	SetRes() calls IDirect3D8::CreateDevice; Lock() begins a frame and
	returns an FD3DRenderInterface the engine uses to issue draw calls;
	Unlock/Present flip the swap chain; Exit destroys the device.
=============================================================================*/

UD3DRenderDevice::UD3DRenderDevice()
{
	// Set default config values. Bitfields cannot be initialised via
	// member-initialiser syntax in C++ — assigned in the constructor body.
	UsePrecaching      = 1;
	UseTrilinear       = 1;
	UseVSync           = 0;
	UseHardwareTL      = 1;
	UseHardwareVS      = 1;
	UseCubemaps        = 1;
	UseTripleBuffering  = 0;
	ReduceMouseLag     = 1;
	AdapterNumber      = 0;
	MaxPixelShaderVersion = 2;
}

UD3DRenderDevice::UD3DRenderDevice(const UD3DRenderDevice& Other)
	: URenderDevice(Other)
	, UsePrecaching(Other.UsePrecaching)
	, UseTrilinear(Other.UseTrilinear)
	, UseVSync(Other.UseVSync)
	, UseHardwareTL(Other.UseHardwareTL)
	, UseHardwareVS(Other.UseHardwareVS)
	, UseCubemaps(Other.UseCubemaps)
	, UseTripleBuffering(Other.UseTripleBuffering)
	, ReduceMouseLag(Other.ReduceMouseLag)
	, AdapterNumber(Other.AdapterNumber)
	, MaxPixelShaderVersion(Other.MaxPixelShaderVersion)
{
}

UD3DRenderDevice& UD3DRenderDevice::operator=(const UD3DRenderDevice& Other)
{
	if (this != &Other)
	{
		URenderDevice::operator=(Other);
		UsePrecaching      = Other.UsePrecaching;
		UseTrilinear       = Other.UseTrilinear;
		UseVSync           = Other.UseVSync;
		UseHardwareTL      = Other.UseHardwareTL;
		UseHardwareVS      = Other.UseHardwareVS;
		UseCubemaps        = Other.UseCubemaps;
		UseTripleBuffering = Other.UseTripleBuffering;
		ReduceMouseLag     = Other.ReduceMouseLag;
		AdapterNumber      = Other.AdapterNumber;
		MaxPixelShaderVersion = Other.MaxPixelShaderVersion;
	}
	return *this;
}

// Note: ~UD3DRenderDevice() is provided by DECLARE_CLASS (ConditionalDestroy).
// No explicit destructor needed here.

void UD3DRenderDevice::StaticConstructor()
{
	guard(UD3DRenderDevice::StaticConstructor);
	// NOTE: Retail binary registers all config BITFIELDs and INTs here.
	// Registration is omitted in this stub because UBoolProperty construction
	// references non-exported UProperty vtable entries (2-param overloads).
	// Config values will not be read from .ini in this build.
	unguard;
}

INT UD3DRenderDevice::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	guard(UD3DRenderDevice::Exec);
	return Super::Exec(Cmd, Ar);
	unguard;
}

INT UD3DRenderDevice::Init()
{
	guard(UD3DRenderDevice::Init);
	// Called after SetRes succeeds. Registers stats, warms shader caches.
	return 1;
	unguard;
}

INT UD3DRenderDevice::SetRes(UViewport* Viewport, INT NewX, INT NewY, INT Fullscreen)
{
	guard(UD3DRenderDevice::SetRes);
	// Creates or resets the IDirect3DDevice8 for the given viewport size.
	return 0;
	unguard;
}

void UD3DRenderDevice::Exit(UViewport* Viewport)
{
	guard(UD3DRenderDevice::Exit);
	unguard;
}

void UD3DRenderDevice::Flush(UViewport* Viewport)
{
	guard(UD3DRenderDevice::Flush);
	unguard;
}

void UD3DRenderDevice::FlushResource(QWORD CacheID)
{
	guard(UD3DRenderDevice::FlushResource);
	unguard;
}

void UD3DRenderDevice::UpdateGamma(UViewport* Viewport)
{
	guard(UD3DRenderDevice::UpdateGamma);
	unguard;
}

void UD3DRenderDevice::RestoreGamma()
{
	guard(UD3DRenderDevice::RestoreGamma);
	unguard;
}

FRenderInterface* UD3DRenderDevice::Lock(UViewport* Viewport, BYTE* HitData, INT* HitSize)
{
	guard(UD3DRenderDevice::Lock);
	// BeginScene on the D3D device and return the FD3DRenderInterface
	// for this frame. NULL signals the engine to skip rendering.
	return NULL;
	unguard;
}

void UD3DRenderDevice::Unlock(FRenderInterface* RI)
{
	guard(UD3DRenderDevice::Unlock);
	// Finalise the frame — flush render interface state.
	unguard;
}

void UD3DRenderDevice::Present(UViewport* Viewport)
{
	guard(UD3DRenderDevice::Present);
	// IDirect3DDevice8::Present — flip the swap chain.
	unguard;
}

void UD3DRenderDevice::ReadPixels(UViewport* Viewport, FColor* Pixels)
{
	guard(UD3DRenderDevice::ReadPixels);
	unguard;
}

void UD3DRenderDevice::SetEmulationMode(EHardwareEmulationMode Mode)
{
	guard(UD3DRenderDevice::SetEmulationMode);
	unguard;
}

FRenderCaps* UD3DRenderDevice::GetRenderCaps()
{
	guard(UD3DRenderDevice::GetRenderCaps);
	return NULL;
	unguard;
}

INT UD3DRenderDevice::OpenVideo(UCanvas* Canvas, char* VideoFile, char* AudioTrack, INT Flags)
{
	guard(UD3DRenderDevice::OpenVideo);
	return 0;
	unguard;
}

void UD3DRenderDevice::CloseVideo(UCanvas* Canvas)
{
	guard(UD3DRenderDevice::CloseVideo);
	unguard;
}

void UD3DRenderDevice::DisplayVideo(UCanvas* Canvas, void* Frame, INT Flags)
{
	guard(UD3DRenderDevice::DisplayVideo);
	unguard;
}

void UD3DRenderDevice::StartVideo(UCanvas* Canvas, INT Width, INT Height, INT Flags)
{
	guard(UD3DRenderDevice::StartVideo);
	unguard;
}

void UD3DRenderDevice::StopVideo(UCanvas* Canvas)
{
	guard(UD3DRenderDevice::StopVideo);
	unguard;
}

void UD3DRenderDevice::Draw3DLine(FVector Start, FVector End, FColor Color, UTexture* Texture, FLOAT ScaleX, FLOAT ScaleY, FLOAT OffsetX, FLOAT OffsetY)
{
	guard(UD3DRenderDevice::Draw3DLine);
	unguard;
}

void UD3DRenderDevice::ChangeDrawingSurface(ER6SwitchSurface Surface, INT Param)
{
	guard(UD3DRenderDevice::ChangeDrawingSurface);
	unguard;
}

void UD3DRenderDevice::HandleFullScreenEffects(INT Param1, INT Param2)
{
	guard(UD3DRenderDevice::HandleFullScreenEffects);
	unguard;
}

void UD3DRenderDevice::GetAvailableResolutions(TArray<FResolutionInfo>& Resolutions)
{
	guard(UD3DRenderDevice::GetAvailableResolutions);
	Resolutions.Empty();
	unguard;
}

DWORD UD3DRenderDevice::GetAvailableVideoMemory()
{
	guard(UD3DRenderDevice::GetAvailableVideoMemory);
	return 0;
	unguard;
}

INT UD3DRenderDevice::SupportsTextureFormat(ETextureFormat Format)
{
	guard(UD3DRenderDevice::SupportsTextureFormat);
	return 0;
	unguard;
}

FD3DResource* UD3DRenderDevice::GetCachedResource(QWORD CacheID)
{
	guard(UD3DRenderDevice::GetCachedResource);
	return NULL;
	unguard;
}

FD3DPixelShader* UD3DRenderDevice::GetPixelShader(EPixelShader Shader)
{
	guard(UD3DRenderDevice::GetPixelShader);
	return NULL;
	unguard;
}

FD3DVertexShader* UD3DRenderDevice::GetVertexShader(EVertexShader Shader, FShaderDeclaration& Decl)
{
	guard(UD3DRenderDevice::GetVertexShader);
	return NULL;
	unguard;
}

INT UD3DRenderDevice::UnSetRes(const TCHAR* Reason, LONG hResult)
{
	guard(UD3DRenderDevice::UnSetRes);
	debugf(NAME_Warning, TEXT("D3DDrv: SetRes failed — %s (hr=0x%08X)"), Reason, (DWORD)hResult);
	return 0;
	unguard;
}

// DllMain is provided by IMPLEMENT_PACKAGE(D3DDrv) — no explicit definition needed.
