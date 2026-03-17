/*=============================================================================
	CorePrivate.h: Unreal core private header file.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_CORE_PRIVATE
#define _INC_CORE_PRIVATE

/*----------------------------------------------------------------------------
	System headers — included BEFORE pragma pack to avoid C2338.
----------------------------------------------------------------------------*/

#ifndef _WINDOWS_
// Target Windows 2000+ — this is the minimum version Ravenshield supports.
// Without _WIN32_WINNT >= 0x0400, IsDebuggerPresent and other NT4+ APIs are
// excluded from <windows.h> even when WIN32_LEAN_AND_MEAN is defined.
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0500
#endif
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif
#include <stdio.h>
#include <malloc.h>
#include <commctrl.h>
#include <tchar.h>
#include <math.h>
#include <objbase.h>
#include <shellapi.h>

/*----------------------------------------------------------------------------
	Core public includes.
----------------------------------------------------------------------------*/

// We are building (exporting) Core.dll.
#undef  CORE_API
#define CORE_API DLL_EXPORT
#define CORE_BUILDING 1

// ENGINE_API is used by UnPrim.h (included via Core.h line 414).
// When building Core, Engine symbols would be imported.
#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif

// MSVC 2019 conformant for-loop scoping breaks MSVC 7.1-era code that leaks
// loop variables.  The SDK headers rely on this non-standard behavior.
#pragma conform(forScope, off)

#pragma pack(push, 4)

#include "Core.h"

// Fix IMPLEMENT_CLASS for MSVC 2019+ and CSDK private members.
// UObject::WithinClass and GUID1-4 are private in CSDK — same fix as EnginePrivate.h.
// Hardcode UObject as WithinClass and zero GUIDs (all Core classes use UObject).
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
	extern "C" DLL_EXPORT UClass* autoclass##TClass;\
	DLL_EXPORT UClass* autoclass##TClass = TClass::StaticClass();

// Ravenshield retail package version (Ghidra 0x1012ad40: writes ver=118=0x76, licenseeVer=14=0xe).
// The SDK ships with 69/0x00, which is the UT99 value. Override for correctness.
#undef  PACKAGE_FILE_VERSION
#define PACKAGE_FILE_VERSION          118
#undef  PACKAGE_FILE_VERSION_LICENSEE
#define PACKAGE_FILE_VERSION_LICENSEE 14

// Additional headers NOT included by Core.h.
#include "UnLinker.h"
#include "UnCoreNative.h"
#include "ImplSource.h"

// SendMessageX / SendMessageLX — Unicode wrappers used by FFeedbackContextWindows.h.
// Normally defined in Window.h (UT99 Window module), needed here for Core builds.
#ifndef SendMessageX
#define SendMessageX(a,b,c,d)  TCHAR_CALL_OS(SendMessageW(a,b,c,d),SendMessageA(a,b,c,d))
#endif
#ifndef SendMessageLX
#define SendMessageLX(a,b,c,d) TCHAR_CALL_OS(SendMessageW(a,b,c,(LPARAM)(d)),SendMessageA(a,b,c,(LPARAM)TCHAR_TO_ANSI(d)))
#endif

// Platform implementations — not part of Core.h's public interface.
#include "FMallocAnsi.h"
#include "FMallocWindows.h"
#include "FOutputDeviceFile.h"
#include "FOutputDeviceWindowsError.h"
#include "FOutputDeviceNull.h"
#include "FOutputDeviceStdout.h"
#include "FFeedbackContextWindows.h"
#include "FFeedbackContextAnsi.h"
// Note: FFileManagerGeneric.h is included by FFileManagerWindows.h.
// Do NOT include it separately — the SDK headers lack include guards.
#include "FFileManagerWindows.h"
#include "FConfigCacheIni.h"
#include "FCodec.h"

// Function source attribution macros (IMPL_MATCH, IMPL_APPROX, etc.)
// Zero compile-time overhead — all macros expand to nothing.
#include "ImplSource.h"

// ULevel — forward declaration required by Core sources that use the
// Ravenshield FactoryCreateText(ULevel*, ...) overload (UnExport.cpp).
// ULevel is defined in Engine; a pointer-only forward decl is sufficient.
class ULevel;

#pragma pack(pop)

/*----------------------------------------------------------------------------
	Shim declarations — types/members used by Core sources but missing
	from the SDK headers.
----------------------------------------------------------------------------*/

// PTRDIFF_T — used in UnFile.cpp for pointer-to-int casts.
#ifndef PTRDIFF_T
#include <stddef.h>
#define PTRDIFF_T ptrdiff_t
#endif

// GShift — bit-mask lookup table for FBitReader/FBitWriter (UnBits.cpp).
extern BYTE GShift[8];

// Duplicate native/cast registration counters (defined in Core.cpp).
extern CORE_API INT GNativeDuplicate;
extern CORE_API INT GCastDuplicate;
extern CORE_API UBOOL GIsUCC;

// CPU feature flags (defined in Core.cpp, used in UnFile.cpp).
extern CORE_API UBOOL GIsMMX;
extern CORE_API UBOOL GIsPentiumPro;
extern CORE_API UBOOL GIsSSE;

// googledummy — sentinel for UClass::Serialize (defined in Core.cpp).
extern INT googledummy;

// CHECK_RUNAWAY — script runaway detection macro (UnScript.cpp).
extern INT GRunawayCount;
extern INT GRunawayLimit;
#define CHECK_RUNAWAY \
	{ if( ++GRunawayCount > GRunawayLimit ) { GRunawayCount=0; appErrorf(TEXT("Runaway loop detected (over %i iterations)"), GRunawayLimit); } }

// appSRand — seeded random float, exported from Core.dll.
CORE_API FLOAT appSRand();
CORE_API void  appSRandInit( INT Seed );
CORE_API void  VARARGS EdLoadErrorf( INT Type, const TCHAR* Fmt, ... );

// appTrunc — float-to-int truncation (used in script math).
inline INT appTrunc( FLOAT F ) { return (INT)F; }

// appAsin — arc sine wrapper (used in UnScript exec* functions).
inline FLOAT appAsin( FLOAT F ) { return (FLOAT)asin((double)F); }

// appRandInit / appRand — seeded random number generator.
CORE_API void appRandInit( INT Seed );
CORE_API INT  appRand();

// RotRand — generate a random rotation.
inline FRotator RotRand( UBOOL bRoll=0 )
{
	FRotator R;
	R.Pitch = appRand() & 0xFFFF;
	R.Yaw   = appRand() & 0xFFFF;
	R.Roll  = bRoll ? (appRand() & 0xFFFF) : 0;
	return R;
}

// FUNC_Probe — Ravenshield function flag for probe functions.
#ifndef FUNC_Probe
#define FUNC_Probe 0x00020000
#endif

// BIG_NUMBER — a very large float for range initialization.
#ifndef BIG_NUMBER
#define BIG_NUMBER 1e30f
#endif

// FInterpCurvePoint — interpolation curve point.
class CORE_API FInterpCurvePoint
{
public:
	FLOAT InVal;
	FLOAT OutVal;
	FInterpCurvePoint() : InVal(0.f), OutVal(0.f) {}
	FInterpCurvePoint( FLOAT In, FLOAT Out ) : InVal(In), OutVal(Out) {}
	INT operator==( const FInterpCurvePoint& Other ) { return InVal==Other.InVal && OutVal==Other.OutVal; }
	FInterpCurvePoint& operator=( const FInterpCurvePoint& Other ) { InVal=Other.InVal; OutVal=Other.OutVal; return *this; }
};

// FInterpCurve — piecewise interpolation curve.
class CORE_API FInterpCurve
{
public:
	TArray<FInterpCurvePoint> Points;
	FInterpCurve() {}
	void AddPoint( FLOAT InVal, FLOAT OutVal ) { new(Points) FInterpCurvePoint(InVal, OutVal); }
	FLOAT Eval( FLOAT Input );
};

// GetFVECTOR / GetFROTATOR — parsing helpers (Engine.dll exports).
// Forward-declared here so Core sources compile; resolved at link time.
CORE_API UBOOL GetFVECTOR( const TCHAR* Stream, FVector& Value );
CORE_API UBOOL GetFVECTOR( const TCHAR* Stream, const TCHAR* Match, FVector& Value );
CORE_API UBOOL GetFROTATOR( const TCHAR* Stream, FRotator& Value, INT ScaleFactor );
CORE_API UBOOL GetFROTATOR( const TCHAR* Stream, const TCHAR* Match, FRotator& Value, INT ScaleFactor );

/*----------------------------------------------------------------------------
	FRange / FRangeVector — ranged value types exported from Core.dll.
	Defined here because CoreClasses.h uses DLL_IMPORT; we need CORE_API.
----------------------------------------------------------------------------*/

class CORE_API FRange
{
public:
	FLOAT Min;
	FLOAT Max;
	FRange();
	FRange( FLOAT InVal );
	FRange( FLOAT InMin, FLOAT InMax );
	FLOAT GetCenter() const;
	FLOAT GetMax() const;
	FLOAT GetMin() const;
	FLOAT GetRand() const;
	FLOAT GetSRand() const;
	FRange GridSnap( const FRange& Grid );
	INT   IsNearlyZero() const;
	INT   IsZero() const;
	FLOAT Size() const;
	INT   Booleanize();
	FLOAT& Component( INT Index );
	FRange  operator+( const FRange& R ) const;
	FRange  operator+( FLOAT F ) const;
	FRange  operator-( const FRange& R ) const;
	FRange  operator-( FLOAT F ) const;
	FRange  operator-() const;
	FRange  operator*( const FRange& R ) const;
	FRange  operator*( FLOAT F ) const;
	FRange  operator/( FLOAT F ) const;
	FRange  operator+=( const FRange& R );
	FRange  operator+=( FLOAT F );
	FRange  operator-=( const FRange& R );
	FRange  operator-=( FLOAT F );
	FRange  operator*=( const FRange& R );
	FRange  operator*=( FLOAT F );
	FRange  operator/=( const FRange& R );
	FRange  operator/=( FLOAT F );
	FRange& operator=( const FRange& R );
	INT     operator==( const FRange& R ) const;
	INT     operator!=( const FRange& R ) const;
};

class CORE_API FRangeVector
{
public:
	FRange X;
	FRange Y;
	FRange Z;
	FRangeVector();
	FRangeVector( FRange InX, FRange InY, FRange InZ );
	FRangeVector( FVector V );
	FVector GetCenter() const;
	FVector GetMax() const;
	FVector GetRand() const;
	FVector GetSRand() const;
	FRange& Component( INT Index );
	FRangeVector GridSnap( const FRangeVector& Grid );
	INT IsNearlyZero() const;
	INT IsZero() const;
	FRangeVector  operator+( const FRangeVector& R ) const;
	FRangeVector  operator+( const FVector& V ) const;
	FRangeVector  operator-( const FRangeVector& R ) const;
	FRangeVector  operator-( const FVector& V ) const;
	FRangeVector  operator-() const;
	FRangeVector  operator*( const FRangeVector& R ) const;
	FRangeVector  operator*( FLOAT F ) const;
	FRangeVector  operator/( FLOAT F ) const;
	FRangeVector  operator+=( const FRangeVector& R );
	FRangeVector  operator+=( const FVector& V );
	FRangeVector  operator-=( const FRangeVector& R );
	FRangeVector  operator-=( const FVector& V );
	FRangeVector  operator*=( const FRangeVector& R );
	FRangeVector  operator*=( FLOAT F );
	FRangeVector  operator/=( const FRangeVector& R );
	FRangeVector  operator/=( FLOAT F );
	FRangeVector& operator=( const FRangeVector& R );
	INT           operator==( const FRangeVector& R ) const;
	INT           operator!=( const FRangeVector& R ) const;
};

/*----------------------------------------------------------------------------
	FFileStream — Ravenshield streaming file I/O (Core.dll export).
----------------------------------------------------------------------------*/

struct FStream;

enum EFileStreamType
{
	FST_Unknown = 0,
	FST_Read    = 1,
	FST_Write   = 2,
};

class CORE_API FFileStream
{
public:
	// Static member variables (exported by retail binary as @@2 symbols).
	static FFileStream* Instance;
	static INT Destroyed;
	static INT MaxStreams;
	static INT StreamIndex;
	static FStream* Streams;

	INT   Create( INT StreamId, const TCHAR* Filename );
	INT   CreateStream( const TCHAR* Filename, INT Offset, INT Size, void* Buffer, EFileStreamType Type, void* Callback );
	INT   Destroy( INT StreamId );
	static void  Destroy();
	void  DestroyStream( INT StreamId, INT bForce );
	void  Enter( INT StreamId );
	static FFileStream* Init( INT InMaxStreams );
	void  Leave( INT StreamId );
	INT   QueryStream( INT StreamId, INT& OutStatus );
	INT   Read( INT StreamId, INT NumBytes );
	void  RequestChunks( INT StreamId, INT NumChunks, void* ChunkInfo );
	FFileStream& operator=( const FFileStream& Other );
private:
	FFileStream();
	~FFileStream();
};

#endif

/*-----------------------------------------------------------------------------
	Ravenshield-specific types not in UT99 headers.
-----------------------------------------------------------------------------*/

class CORE_API FEdLoadError
{
public:
	INT Type;
	FString Desc;
	~FEdLoadError();
	FEdLoadError();
	FEdLoadError( INT InType, TCHAR* InDesc );
	FEdLoadError( const FEdLoadError& Other );
	FEdLoadError& operator=( FEdLoadError Other );
	INT operator==( const FEdLoadError& Other ) const;
};

class CORE_API FEdge
{
public:
	FVector Vertex[2];
	FEdge();
	FEdge( FVector InVertex0, FVector InVertex1 );
	FEdge& operator=( const FEdge& Other );
	INT operator==( const FEdge& Other ) const;
};

class CORE_API FCylinder
{
public:
	FLOAT Radius;
	FLOAT Height;
	FCylinder();
	FCylinder& operator=( const FCylinder& Other );
	INT LineCheck( const FVector& Start, const FVector& End, FVector& HitNormal ) const;
	INT LineIntersection( const FVector& Start, const FVector& End, FLOAT* const HitTime ) const;
};

class CORE_API FPosition
{
public:
	FVector Location;
	FCoords Coords;
	FPosition();
	FPosition( FVector InLocation, FCoords InCoords );
	FPosition& operator=( const FPosition& Other );
};

class CORE_API FArchiveCountMem : public FArchive
{
public:
	FArchiveCountMem( UObject* Src );
	FArchiveCountMem( const FArchiveCountMem& Other );
	virtual ~FArchiveCountMem();
	virtual void CountBytes( SIZE_T InNum, SIZE_T InMax );
	DWORD GetNum();
	DWORD GetMax();
	FArchiveCountMem& operator=( const FArchiveCountMem& Other );
private:
	SIZE_T Num;
	SIZE_T Max;
};

class CORE_API FArchiveDummySave : public FArchive
{
public:
	FArchiveDummySave();
	FArchiveDummySave( const FArchiveDummySave& Other );
	virtual ~FArchiveDummySave();
	FArchiveDummySave& operator=( const FArchiveDummySave& Other );
};

class CORE_API FErrorOutError : public FOutputDeviceError
{
public:
	FErrorOutError();
	FErrorOutError( const FErrorOutError& Other );
	FErrorOutError& operator=( const FErrorOutError& Other );
	void Serialize( const TCHAR* V, EName Event );
	void HandleError();
};

class CORE_API FLogOutError : public FOutputDevice
{
public:
	FLogOutError();
	FLogOutError( const FLogOutError& Other );
	FLogOutError& operator=( const FLogOutError& Other );
	void Serialize( const TCHAR* V, EName Event );
};

class CORE_API FNullOutError : public FOutputDevice
{
public:
	FNullOutError();
	FNullOutError( const FNullOutError& Other );
	FNullOutError& operator=( const FNullOutError& Other );
	void Serialize( const TCHAR* V, EName Event );
};

class CORE_API FThrowOut : public FOutputDevice
{
public:
	FThrowOut();
	FThrowOut( const FThrowOut& Other );
	FThrowOut& operator=( const FThrowOut& Other );
	void Serialize( const TCHAR* V, EName Event );
};

CORE_API INT appIsDebuggerPresent();

// Registry helpers (defined in CoreStubs.cpp).
CORE_API INT RegGet( FString Key, FString Name, FString& Value );
CORE_API INT RegSet( FString Key, FString Name, FString Value );


/*-----------------------------------------------------------------------------
Shim fixes for SDK header incompatibilities in UnClass.cpp
These declarations address MSVC 7.1 build errors
-----------------------------------------------------------------------------*/

// FIX for lines 149, 470, 560, 640, 660, 809:
// "error C2248: 'UObject::WithinClass' : cannot access private typedef"
// "error C2248: 'GUID1' : inaccessible enumerator in 'UField'"
//
// PROBLEM: In UnObjBas.h line 463-464, UObject defines:
//   typedef UObject WithinClass;    // NO public: section before this
//   enum {GUID1=0,GUID2=0,GUID3=0,GUID4=0};  // NO public: section
//
// These are inherited by UField and descendants but remain private.
// The IMPLEMENT_CLASS macro tries to access TClass::WithinClass and TClass::GUID1-4,
// which fails because they're inherited private members.
//
// SOLUTION: Modify UnObjBas.h to make these public, OR create a shim that declares
// them as public in derived classes. Since we can't modify SDK files (gitignored),
// we need to fix this in the project code.
//
// The actual fix must be applied by modifying how IMPLEMENT_CLASS accesses these members,
// or by adding public redeclarations in each class that uses IMPLEMENT_CLASS.

// FIX for lines 298, 363, 438:
// "error C2039: 'SerializeBin' : is not a member of 'UProperty'"
// "error C2039: 'SerializeItem' : is not a member of 'UProperty'"
// "error C2039: 'CleanupDestroyed' : is not a member of 'UProperty'"
//
// PROBLEM: UnType.h line 57-58 has these methods commented out:
//   //virtual void SerializeItem( FArchive& Ar, void* Value ) const=0;
// But UnClass.cpp calls these methods on UProperty objects.
//
// SOLUTION: These methods must be declared in UProperty base class.
// They should be virtual pure methods that subclasses implement.

// FIX applied: UnType.h had inline UStruct::StructCompare causing C2084 conflict
// with UnClass.cpp IMPL_MATCH implementation. The UnType.h inline is commented out.


/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

