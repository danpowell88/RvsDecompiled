/*=============================================================================
	D3DDrvPrivate.h: D3DDrv private header — Direct3D 8 rendering driver.
	Copyright 1997-2004 Epic Games, Inc. / Ubisoft Montreal. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_D3DDRV_PRIVATE
#define _INC_D3DDRV_PRIVATE

/*----------------------------------------------------------------------------
	API linkage.
----------------------------------------------------------------------------*/

#undef  D3DDRV_API
#define D3DDRV_API DLL_EXPORT

#ifndef CORE_API
#define CORE_API DLL_IMPORT
#endif
#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif

/*----------------------------------------------------------------------------
	Win32 / Direct3D 8 headers — must come before Engine.h.
----------------------------------------------------------------------------*/

#define WINDOWS_IGNORE_PACKING_MISMATCH

// Same fix as WinDrvPrivate.h: define POINTER_64 before windows.h to prevent
// the DX8 SDK basetsd.h (found first in include paths) from shadowing Win10's,
// which would leave POINTER_64 undefined and break winnt.h(417).
#ifndef POINTER_64
#  define POINTER_64 __ptr64
#endif

#include <windows.h>

// Direct3D 8 — Ravenshield uses D3D8, not D3D9.
// The UT99 D3DDrv uses D3D7 (DIRECT3D_VERSION 0x0700); ours targets 0x0800.
#define DIRECT3D_VERSION 0x0800
#include <d3d8.h>
#include <d3dx8.h>

/*----------------------------------------------------------------------------
	Core / Engine.
----------------------------------------------------------------------------*/

#pragma pack(push, 4)
#include "Engine.h"

/*----------------------------------------------------------------------------
	Forward declarations for D3D resource / shader types.
	These are incomplete internally — only the pointer size matters for ABI.
----------------------------------------------------------------------------*/

class FD3DResource;
class FD3DPixelShader;
class FD3DVertexShader;

/*----------------------------------------------------------------------------
	Ravenshield-specific enums referenced by UD3DRenderDevice.
	Defined here because they appear in virtual method signatures.
----------------------------------------------------------------------------*/

// ER6SwitchSurface — surface target for ChangeDrawingSurface
enum ER6SwitchSurface
{
	R6SS_Default  = 0,
	R6SS_Offscreen = 1,
};

// EPixelShader / EVertexShader — shader program identifiers (internal IDs).
// Actual values are not exposed in the CSDK; use placeholders.
enum EPixelShader
{
	PS_None = 0,
};

enum EVertexShader
{
	VS_None = 0,
};

// FShaderDeclaration — vertex declaration wrapper (opaque; only passed by ref).
struct FShaderDeclaration
{
	DWORD Declarations[64];
};

/*----------------------------------------------------------------------------
	D3DDrv class declarations.
----------------------------------------------------------------------------*/

#include "D3DDrvClasses.h"

/*----------------------------------------------------------------------------
	IMPLEMENT_CLASS override — same MSVC 2019+ fix used by all modules.
----------------------------------------------------------------------------*/

#undef IMPLEMENT_CLASS
#define IMPLEMENT_CLASS(TClass) \
	UClass TClass::PrivateStaticClass \
	( \
		EC_NativeConstructor, \
		sizeof(TClass), \
		TClass::StaticClassFlags, \
		TClass::Super::StaticClass(), \
		UObject::StaticClass(), \
		FGuid(0,0,0,0), \
		TEXT(#TClass)+1, \
		GPackage, \
		StaticConfigName(), \
		RF_Public | RF_Standalone | RF_Transient | RF_Native, \
		(void(*)(void*))TClass::InternalConstructor, \
		(void(UObject::*)())&TClass::StaticConstructor \
	); \
	extern "C" D3DDRV_API UClass* autoclass##TClass;\
	D3DDRV_API UClass* autoclass##TClass = TClass::StaticClass();

#pragma pack(pop)

#endif // _INC_D3DDRV_PRIVATE
