/*=============================================================================
	Core.cpp: Unreal core package implementation.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	Package implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(Core);

/*-----------------------------------------------------------------------------
	Global variables.
-----------------------------------------------------------------------------*/

// Core globals — UT432 base.
CORE_API FMemStack				GMem;
CORE_API FOutputDevice*			GLog					= NULL;
CORE_API FOutputDevice*			GNull					= NULL;
CORE_API FOutputDevice*			GThrow					= NULL;
CORE_API FOutputDeviceError*	GError					= NULL;
CORE_API FFeedbackContext*		GWarn					= NULL;
CORE_API FConfigCache*			GConfig					= NULL;
CORE_API FTransactionBase*		GUndo					= NULL;
CORE_API FOutputDevice*			GLogHook				= NULL;
CORE_API FExec*					GExec					= NULL;
CORE_API FMalloc*				GMalloc					= NULL;
CORE_API FFileManager*			GFileManager			= NULL;
CORE_API USystem*				GSys					= NULL;
CORE_API UProperty*				GProperty				= NULL;
CORE_API UObject*				GPropObject				= NULL;
CORE_API BYTE*					GPropAddr				= NULL;
CORE_API USubsystem*			GWindowManager			= NULL;
CORE_API TCHAR					GErrorHist[4096]		= TEXT("");
CORE_API TCHAR					GTrue[64]				= TEXT("True");
CORE_API TCHAR					GFalse[64]				= TEXT("False");
CORE_API TCHAR					GYes[64]				= TEXT("Yes");
CORE_API TCHAR					GNo[64]					= TEXT("No");
CORE_API TCHAR					GNone[64]				= TEXT("None");
CORE_API TCHAR					GCdPath[256]			= TEXT("");
CORE_API DOUBLE					GSecondsPerCycle		= 0.0;
CORE_API unsigned short*		GMachineCPU				= NULL;
CORE_API DOUBLE					GTempDouble				= 0.0;
CORE_API void					(*GTempFunc)(void*)		= NULL;
CORE_API SQWORD					GTicks					= 0;
CORE_API INT					GScriptCycles			= 0;
CORE_API DWORD					GPageSize				= 0;
CORE_API DWORD					GProcessorCount			= 1;
CORE_API unsigned long			GPhysicalMemory			= 0;
CORE_API DWORD					GUglyHackFlags			= 0;
CORE_API UBOOL					GTimestamp				= 1;
CORE_API UBOOL					GIsScriptable			= 0;
CORE_API UBOOL					GIsEditor				= 0;
CORE_API UBOOL					GIsClient				= 0;
CORE_API UBOOL					GIsServer				= 0;
CORE_API UBOOL					GIsCriticalError		= 0;
CORE_API UBOOL					GIsStarted				= 0;
CORE_API UBOOL					GIsRunning				= 0;
CORE_API UBOOL					GIsSlowTask				= 0;
CORE_API UBOOL					GIsGuarded				= 0;
CORE_API UBOOL					GIsRequestingExit		= 0;
CORE_API UBOOL					GIsStrict				= 0;
CORE_API UBOOL					GScriptEntryTag			= 0;
CORE_API UBOOL					GLazyLoad				= 0;
CORE_API UBOOL					GUnicode				= 0;
CORE_API UBOOL					GUnicodeOS				= 0;
CORE_API FGlobalMath			GMath;
CORE_API FArchive*				GDummySave				= NULL;
CORE_API unsigned short*		GMachineOS				= NULL;
CORE_API unsigned short*		GMachineVideo			= NULL;

// Ravenshield-specific globals (not in UT99).
CORE_API UBOOL					GIsUCC					= 0;
CORE_API UBOOL					GIsGarbageCollecting	= 0;
CORE_API UBOOL					GIsErrorNotABug			= 0;
CORE_API UBOOL					GIsNightmare			= 0;
CORE_API UBOOL					GIsRenderingMenus		= 0;
CORE_API UBOOL					GNightVisionActive		= 0;
CORE_API UBOOL					GShowCollisionModel		= 0;
CORE_API UBOOL					GHideHiddenInEditor		= 0;
CORE_API UBOOL					GEdSelectionLock		= 0;
CORE_API UBOOL					GEdShowFogInViewports	= 0;
CORE_API UBOOL					GUseCullDistance		= 0;
CORE_API UBOOL					GUseCullDistanceProjector = 0;
CORE_API UBOOL					GUseStaticMeshSimpleCollision = 0;
CORE_API FLOAT					GAudioDefaultRadius		= 0.0f;
CORE_API FLOAT					GAudioMaxRadiusMultiplier = 0.0f;
CORE_API FLOAT					GZoomAdjustment			= 0.0f;
CORE_API FLOAT					GZoomAdjustmentSniperMode = 0.0f;
CORE_API FLOAT					GZoomAdjustmentSniperNoZoom = 0.0f;
CORE_API FLOAT					GZoomAdjustmentSniperZoom = 0.0f;
CORE_API BYTE					GCompileMaterialsRevision = 0;
CORE_API BYTE					GIsNullDebugPkg			= 0;
CORE_API INT					GCastDuplicate			= 0;
CORE_API INT					GNativeDuplicate		= 0;
CORE_API INT					GIndexDebugPkg			= 0;
CORE_API DWORD					GRuntimeUCFlags			= 0;
CORE_API void*					GObjetDebugPkg			= NULL;
CORE_API void*					GTagPropertyDebugPkg	= NULL;

// CPU feature detection globals (exported with C linkage from retail).
extern "C"
{
	CORE_API UBOOL GIsMMX        = 0;
	CORE_API UBOOL GIsPentiumPro = 0;
	CORE_API UBOOL GIsSSE        = 0;
}

// Bit-mask lookup for FBitReader / FBitWriter.
BYTE GShift[8] = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 };

// Sentinel checked in UClass::Serialize.
INT googledummy = 0;

class FCoreBootstrapMalloc : public FMalloc
{
public:
	FCoreBootstrapMalloc()
	: Heap( NULL )
	{}

	virtual void* Malloc( DWORD Count, const TCHAR* Tag )
	{
		if( !Count )
			return NULL;
		Init();
		void* Result = HeapAlloc( Heap, 0, Count );
		if( !Result )
			appErrorf( TEXT("Bootstrap allocator out of memory allocating %u bytes for %s"), Count, Tag ? Tag : TEXT("<null>") );
		return Result;
	}

	virtual void* Realloc( void* Original, DWORD Count, const TCHAR* Tag )
	{
		Init();
		if( !Count )
		{
			if( Original )
				HeapFree( Heap, 0, Original );
			return NULL;
		}
		void* Result = Original ? HeapReAlloc( Heap, 0, Original, Count ) : HeapAlloc( Heap, 0, Count );
		if( !Result )
			appErrorf( TEXT("Bootstrap allocator out of memory reallocating %u bytes for %s"), Count, Tag ? Tag : TEXT("<null>") );
		return Result;
	}

	virtual void Free( void* Original )
	{
		if( Original )
		{
			Init();
			HeapFree( Heap, 0, Original );
		}
	}

	virtual void DumpAllocs()
	{}

	virtual void HeapCheck()
	{}

	virtual void Init()
	{
		if( !Heap )
			Heap = GetProcessHeap();
	}

	virtual void Exit()
	{}

	virtual INT GetMemoryBlockSize( void* Ptr )
	{
		Init();
		SIZE_T Size = HeapSize( Heap, 0, Ptr );
		return Size == (SIZE_T)-1 ? 0 : (INT)Size;
	}

private:
	HANDLE Heap;
};

IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
static void appInitPreloadCRCTable()
{
	for( DWORD iCRC=0; iCRC<256; iCRC++ )
	{
		DWORD CRC = iCRC;
		for( INT j=8; j>0; j-- )
			CRC = (CRC & 1) ? (CRC >> 1) ^ 0xEDB88320 : CRC >> 1;
		GCRCTable[iCRC] = CRC;
	}
}

IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
static FCoreBootstrapMalloc& GetCorePreInitMalloc()
{
	static FCoreBootstrapMalloc Malloc;
	return Malloc;
}

#pragma init_seg(lib)
class FCorePreInit
{
public:
	FCorePreInit()
	{
		FCoreBootstrapMalloc& Malloc = GetCorePreInitMalloc();
		Malloc.Init();
		GMalloc = &Malloc;
		appInitPreloadCRCTable();
		if( !FName::GetInitialized() )
			FName::StaticInit();
	}
};

static FCorePreInit GCorePreInit;

/*-----------------------------------------------------------------------------
	FArray::Remove.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1012F370)
void FArray::Remove( INT Index, INT Count, INT ElementSize )
{
	guardSlow(FArray::Remove);
	if( Count )
	{
		appMemmove
		(
			(BYTE*)Data + (Index      ) * ElementSize,
			(BYTE*)Data + (Index+Count) * ElementSize,
			(ArrayNum - Index - Count ) * ElementSize
		);
		ArrayNum -= Count;
	}
	unguardSlow;
}

/*-----------------------------------------------------------------------------
	FArray::Realloc.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10130760)
void FArray::Realloc( INT ElementSize )
{
	guardSlow(FArray::Realloc);
	Data = appRealloc( Data, ArrayMax * ElementSize, TEXT("FArray") );
	unguardSlow;
}

/*-----------------------------------------------------------------------------
	FInterpCurve implementation.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1012CED0)
FLOAT FInterpCurve::Eval( FLOAT Input )
{
	if( Points.Num() == 0 )
		return 0.f;
	if( Points.Num() == 1 || Input <= Points(0).InVal )
		return Points(0).OutVal;
	for( INT i=1; i<Points.Num(); i++ )
	{
		if( Input <= Points(i).InVal )
		{
			FLOAT Alpha = (Input - Points(i-1).InVal) / (Points(i).InVal - Points(i-1).InVal);
			return Points(i-1).OutVal + Alpha * (Points(i).OutVal - Points(i-1).OutVal);
		}
	}
	return Points(Points.Num()-1).OutVal;
}

// Note: DllMain, hInstance, and GPackage are provided by IMPLEMENT_PACKAGE(Core) above.

/*-----------------------------------------------------------------------------
	__FUNC_NAME__ external linkage workaround.
	MSVC 2019 emits guard() function-local statics with internal linkage,
	but the retail Core.def exports them as external symbols (MSVC 7.1
	behavior). We define global extern "C" arrays with the same string
	content and use /alternatename to redirect the mangled symbols.

	When compiling with MSVC 7.1 (_MSC_VER == 1310) this whole block is
	skipped because the compiler already emits the statics with external
	linkage — exactly as the retail binary was built.
-----------------------------------------------------------------------------*/
#if _MSC_VER > 1310
extern "C" {
__declspec(dllexport) const unsigned short _gfn_Reverse[]        = {'F','S','t','r','i','n','g',':',':','R','e','v','e','r','s','e',0};
__declspec(dllexport) const unsigned short _gfn_ParseIntoArray[] = {'F','S','t','r','i','n','g',':',':','P','a','r','s','e','I','n','t','o','A','r','r','a','y',0};
__declspec(dllexport) const unsigned short _gfn_AddDependency[]  = {'U','C','l','a','s','s',':',':','A','d','d','D','e','p','e','n','d','e','n','c','y',0};
__declspec(dllexport) const unsigned short _gfn_SerializeExp[]   = {'F','O','b','j','e','c','t','E','x','p','o','r','t',':',':','S','e','r','i','a','l','i','z','e',0};
__declspec(dllexport) const unsigned short _gfn_SerializeImp[]   = {'F','O','b','j','e','c','t','I','m','p','o','r','t',':',':','S','e','r','i','a','l','i','z','e',0};
__declspec(dllexport) const unsigned short _gfn_OpDelete[]       = {'U','O','b','j','e','c','t',':',':','o','p','e','r','a','t','o','r',' ','d','e','l','e','t','e',0};
}
// Force emission of the above arrays (compiler may optimize away unused consts).
static volatile const void* _gfnRefs[] = {_gfn_Reverse, _gfn_ParseIntoArray, _gfn_AddDependency, _gfn_SerializeExp, _gfn_SerializeImp, _gfn_OpDelete};
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Reverse@FString@@QAE?AV2@XZ@4QBGB=__gfn_Reverse")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??ParseIntoArray@FString@@QAEHPBGPAV?$TArray@VFString@@@@@Z@4QBGB=__gfn_ParseIntoArray")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??AddDependency@UClass@@QAEXPAV2@H@Z@4QBGB=__gfn_AddDependency")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@FObjectExport@@QAEAAVFArchive@@AAV3@@Z@4QBGB=__gfn_SerializeExp")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@FObjectImport@@QAEAAVFArchive@@AAV3@@Z@4QBGB=__gfn_SerializeImp")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2???3UObject@@SAXPAXI@Z@4QBGB=__gfn_OpDelete")
#endif // _MSC_VER > 1310

/*-----------------------------------------------------------------------------
	Force inline functions to emit out-of-line copies for .def export.
	appFloor/appRound are defined inline with ASM in UnVcWin32.h.
	appDebugBreak is defined inline in UnVcWin32.h.
	Taking their address forces the compiler to emit symbols.
-----------------------------------------------------------------------------*/

typedef INT  (*PFN_IntFloat)(FLOAT);
typedef void (*PFN_Void)();
static PFN_IntFloat _forceEmit_appFloor     = &appFloor;
static PFN_IntFloat _forceEmit_appRound     = &appRound;
static PFN_Void    _forceEmit_appDebugBreak = &appDebugBreak;

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
