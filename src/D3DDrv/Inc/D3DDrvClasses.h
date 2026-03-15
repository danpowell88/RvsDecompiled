/*=============================================================================
	D3DDrvClasses.h: D3DDrv class declarations for Ravenshield.

	Declares:
	  UD3DRenderDevice — Direct3D 8 implementation of URenderDevice.

	The retail D3DDrv.dll has 44 exports, all from UD3DRenderDevice plus
	GPackage, autoclass pointer, and vtable entries.

	Key architecture:
	  UD3DRenderDevice::Lock() returns an FD3DRenderInterface* (sub-class of
	  FRenderInterface) which performs the actual draw calls in the locked
	  frame. This is the render interface pattern Unreal 2.x uses.
=============================================================================*/

#ifndef _INC_D3DDRV_CLASSES
#define _INC_D3DDRV_CLASSES

#ifndef D3DDRV_API
#define D3DDRV_API DLL_IMPORT
#endif

#pragma pack(push, 4)

/*----------------------------------------------------------------------------
	AUTOGENERATE macros — used in D3DDrv.cpp to register FName tokens.
----------------------------------------------------------------------------*/

#ifndef NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) extern D3DDRV_API FName D3DDRV_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

// ---------------------------------------------------------------------------
// UD3DRenderDevice — Direct3D 8 render device.
//
// Config properties control hardware capabilities. The retail binary has
// Unknown padding bytes scattered between BITFIELDs (see D3DDrvClasses.h in
// the CSDK). We replicate the layout below with explicit char padding to
// match the struct size.
// ---------------------------------------------------------------------------
class D3DDRV_API UD3DRenderDevice : public URenderDevice
{
	DECLARE_CLASS(UD3DRenderDevice, URenderDevice, CLASS_Config, D3DDrv)

	// Public default ctor — exported at ordinal @2 by retail D3DDrv.dll.
	UD3DRenderDevice();

	// --- Config bitfields (CPF_Config) ---
	// Each bool property occupies its own 4-byte DWORD in the retail binary
	// (confirmed by Ghidra: UsePrecaching@0x40e4, UseTrilinear@0x40e8, etc.).
	// The anonymous :31 fill members prevent MSVC from packing consecutive
	// BITFIELD :1 entries into a single DWORD.
	BITFIELD UsePrecaching     :  1; // 0x40e4 — CPF_Config: pre-cache resources
	BITFIELD                   : 31; // fill DWORD
	BITFIELD UseTrilinear      :  1; // 0x40e8 — CPF_Config: trilinear texture filtering
	BITFIELD                   : 31; // fill DWORD
	char     _pad3[0x0004];          // 0x40ec — Unknown3 as in CSDK
	BITFIELD UseVSync          :  1; // 0x40f0 — CPF_Config: vertical sync
	BITFIELD                   : 31; // fill DWORD
	BITFIELD UseHardwareTL     :  1; // 0x40f4 — CPF_Config: hardware T&L
	BITFIELD                   : 31; // fill DWORD
	BITFIELD UseHardwareVS     :  1; // 0x40f8 — CPF_Config: hardware vertex shaders
	BITFIELD                   : 31; // fill DWORD
	BITFIELD UseCubemaps       :  1; // 0x40fc — CPF_Config: cube map reflections
	BITFIELD                   : 31; // fill DWORD
	char     _pad7[0x0014];          // 0x4100 — Unknown7 as in CSDK
	BITFIELD UseTripleBuffering :  1; // 0x4114 — CPF_Config: triple-buffer swap chain
	BITFIELD                   : 31; // fill DWORD
	BITFIELD ReduceMouseLag    :  1; // 0x4118 — CPF_Config: flush before Present()
	BITFIELD                   : 31; // fill DWORD
	char     _pad9[0x0004];          // 0x411c — Unknown9 as in CSDK
	INT AdapterNumber;               // 0x4120 — CPF_Config: D3D adapter index (0=primary)
	char     _pad10[0x0004];         // 0x4124 — Unknown10 as in CSDK
	INT MaxPixelShaderVersion;       // 0x4128 — CPF_Config: max PS model (1=PS1.x, 2=PS2.0)

	// --- Virtual interface ---
	virtual INT Exec(const TCHAR* Cmd, FOutputDevice& Ar);

	// URenderDevice overrides
	virtual INT Init();
	virtual INT SetRes(UViewport* Viewport, INT NewX, INT NewY, INT Fullscreen);
	virtual void Exit(UViewport* Viewport);
	virtual void Flush(UViewport* Viewport);
	virtual void FlushResource(QWORD CacheID);
	virtual void UpdateGamma(UViewport* Viewport);
	virtual void RestoreGamma();
	virtual FRenderInterface* Lock(UViewport* Viewport, BYTE* HitData, INT* HitSize);
	virtual void Unlock(FRenderInterface* RI);
	virtual void Present(UViewport* Viewport);
	virtual void ReadPixels(UViewport* Viewport, FColor* Pixels);
	virtual void SetEmulationMode(EHardwareEmulationMode Mode);
	virtual FRenderCaps* GetRenderCaps();

	// Video playback (Bink integration)
	virtual INT OpenVideo(UCanvas* Canvas, char* VideoFile, char* AudioTrack, INT Flags);
	virtual void CloseVideo(UCanvas* Canvas);
	virtual void DisplayVideo(UCanvas* Canvas, void* Frame, INT Flags);
	virtual void StartVideo(UCanvas* Canvas, INT Width, INT Height, INT Flags);
	virtual void StopVideo(UCanvas* Canvas);

	// Debug helpers
	virtual void Draw3DLine(FVector Start, FVector End, FColor Color, UTexture* Texture, FLOAT ScaleX, FLOAT ScaleY, FLOAT OffsetX, FLOAT OffsetY);

	// Ravenshield-specific render device extensions
	virtual void ChangeDrawingSurface(ER6SwitchSurface Surface, INT Param);
	virtual void HandleFullScreenEffects(INT Param1, INT Param2);
	virtual void GetAvailableResolutions(TArray<FResolutionInfo>& Resolutions);
	virtual DWORD GetAvailableVideoMemory();
	virtual INT SupportsTextureFormat(ETextureFormat Format);

	// Resource / shader cache accessors (non-virtual — QAEXXZ mangling)
	FD3DResource*    GetCachedResource(QWORD CacheID);
	FD3DPixelShader* GetPixelShader(EPixelShader Shader);
	FD3DVertexShader* GetVertexShader(EVertexShader Shader, FShaderDeclaration& Decl);

	// Resolution failure helper (logs error and resets adapter state)
	INT UnSetRes(const TCHAR* Reason, LONG hResult);

	// Lifecycle
	void StaticConstructor();

	// Copy ctor and operator= (exported by retail DLL)
	UD3DRenderDevice(const UD3DRenderDevice&);
	UD3DRenderDevice& operator=(const UD3DRenderDevice&);
};

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif

#pragma pack(pop)

#endif // _INC_D3DDRV_CLASSES
