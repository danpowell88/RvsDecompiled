/*=============================================================================
	Core.h: Local wrapper for CSDK 432Core/Inc/Core.h.

	Identical to the CSDK version except the #include "UnPrim.h" line is
	removed.  Our own src/engine/UnPrim.h provides those types with proper
	DECLARE_CLASS macros so IMPLEMENT_CLASS(UPrimitive) works.

	When EnginePrivate.h -> Engine.h -> "Core.h", MSVC finds this file
	first (same-directory rule) instead of the CSDK version.
=============================================================================*/

#ifndef _INC_CORE
#define _INC_CORE

/*----------------------------------------------------------------------------
	Low level includes.
----------------------------------------------------------------------------*/

#ifndef CORE_API
#define CORE_API DLL_IMPORT
#endif

#include "UnBuild.h"

#define FIXTIME 4294967296.f
class FTime
{
#if __GNUG__
#define TIMETYP long long
#else
#define TIMETYP __int64
#endif
public:
	        FTime      ()               {v=0;}
	        FTime      (float f)        {v=(TIMETYP)(f*FIXTIME);}
	        FTime      (double d)       {v=(TIMETYP)(d*FIXTIME);}
	float   GetFloat   ()               {return v/FIXTIME;}
	FTime   operator+  (float f) const  {return FTime(v+(TIMETYP)(f*FIXTIME));}
	float   operator-  (FTime t) const  {return (v-t.v)/FIXTIME;}
	FTime   operator*  (float f) const  {return FTime(v*f);}
	FTime   operator/  (float f) const  {return FTime(v/f);}
	FTime&  operator+= (float f)        {v=v+(TIMETYP)(f*FIXTIME); return *this;}
	FTime&  operator*= (float f)        {v=(TIMETYP)(v*f); return *this;}
	FTime&  operator/= (float f)        {v=(TIMETYP)(v/f); return *this;}
	int     operator== (FTime t)        {return v==t.v;}
	int     operator!= (FTime t)        {return v!=t.v;}
	int     operator>  (FTime t)        {return v>t.v;}
	FTime&  operator=  (const FTime& t) {v=t.v; return *this;}
private:
	FTime (TIMETYP i) {v=i;}
	TIMETYP v;
};

#if _MSC_VER
	#include "UnVcWin32.h"
#elif __GNUG__
	#include <string.h>
	#include "UnGnuG.h"
#else
	#error Unknown Compiler
#endif

#if !ASM && !__GNUG__
	#define __asm ERROR_ASM_NOT_ALLOWED
#endif

#if __UNIX__
	#include "UnUnix.h"
	#include <signal.h>
#endif

enum {MAXBYTE		= 0xff       };
enum {MAXWORD		= 0xffffU    };
enum {MAXDWORD		= 0xffffffffU};
enum {MAXSBYTE		= 0x7f       };
enum {MAXSWORD		= 0x7fff     };
enum {MAXINT		= 0x7fffffff };
enum {INDEX_NONE	= -1         };
enum {UNICODE_BOM   = 0xfeff     };
enum ENoInit {E_NoInit = 0};

#ifdef _UNICODE
	#ifndef _TCHAR_DEFINED
		typedef UNICHAR  TCHAR;
		typedef UNICHARU TCHARU;
	#endif
	#undef TEXT
	#define TEXT(s) L##s
	#undef US
	#define US FString(L"")
	inline TCHAR    FromAnsi   ( ANSICHAR In ) { return (BYTE)In;                                            }
	inline TCHAR    FromUnicode( UNICHAR In  ) { return In;                                                  }
	inline ANSICHAR ToAnsi     ( TCHAR In    ) { return (_WORD)In<0x100 ? (ANSICHAR)In : (ANSICHAR)MAXSBYTE; }
	inline UNICHAR  ToUnicode  ( TCHAR In    ) { return In;                                                  }
#else
	#ifndef _TCHAR_DEFINED
		typedef ANSICHAR  TCHAR;
		typedef ANSICHARU TCHARU;
	#endif
	#undef TEXT
	#define TEXT(s) s
	#undef US
	#define US FString("")
	inline TCHAR    FromAnsi   ( ANSICHAR In ) { return In;                              }
	inline TCHAR    FromUnicode( UNICHAR In  ) { return (_WORD)In<0x100 ? In : MAXSBYTE; }
	inline ANSICHAR ToAnsi     ( TCHAR In    ) { return (_WORD)In<0x100 ? In : MAXSBYTE; }
	inline UNICHAR  ToUnicode  ( TCHAR In    ) { return (BYTE)In;                        }
#endif

/*----------------------------------------------------------------------------
	Forward declarations.
----------------------------------------------------------------------------*/

class	UObject;
class		UExporter;
class		UFactory;
class		UField;
class			UConst;
class			UEnum;
class			UProperty;
class				UByteProperty;
class				UIntProperty;
class				UBoolProperty;
class				UFloatProperty;
class				UObjectProperty;
class					UClassProperty;
class				UNameProperty;
class				UStructProperty;
class               UStrProperty;
class               UArrayProperty;
class			UStruct;
class				UFunction;
class				UState;
class					UClass;
class		ULinker;
class			ULinkerLoad;
class			ULinkerSave;
class		UPackage;
class		USubsystem;
class			USystem;
class		UTextBuffer;
class       URenderDevice;
class		UPackageMap;

class FName;
class FArchive;
class FCompactIndex;
class FExec;
class FGuid;
class FMemCache;
class FMemStack;
class FPackageInfo;
class FTransactionBase;
class FUnknown;
class FRepLink;
class FArray;
class FLazyLoader;
class FString;
class FMalloc;

template<class T> class TArray;
template<class T> class TTransArray;
template<class T> class TLazyArray;
template<class TK, class TI> class TMap;
template<class TK, class TI> class TMultiMap;

CORE_API extern class FOutputDevice* GNull;

#include "UnNames.h"

/*-----------------------------------------------------------------------------
	Abstract interfaces.
-----------------------------------------------------------------------------*/

class CORE_API FOutputDevice
{
public:
	virtual void Serialize( const TCHAR* V, EName Event )=0;
	void Log( const TCHAR* S );
	void Log( enum EName Type, const TCHAR* S );
	void Log( const FString& S );
	void Log( enum EName Type, const FString& S );
	void Logf( const TCHAR* Fmt, ... );
	void Logf( enum EName Type, const TCHAR* Fmt, ... );
};

class CORE_API FOutputDeviceError : public FOutputDevice
{
public:
	virtual void HandleError()=0;
};

class CORE_API FMalloc
{
public:
	virtual void* Malloc( DWORD Count, const TCHAR* Tag )=0;
	virtual void* Realloc( void* Original, DWORD Count, const TCHAR* Tag )=0;
	virtual void Free( void* Original )=0;
	virtual void DumpAllocs()=0;
	virtual void HeapCheck()=0;
	virtual void Init()=0;
	virtual void Exit()=0;
	// R6 addition: GetMemoryBlockSize at slot 7 (after UT99 methods).
	// CoreClasses.h DLL extract confirms this virtual method exists.
	// Export: ?GetMemoryBlockSize@FMalloc@@UAEHPAX@Z (ordinal 1041)
	virtual INT GetMemoryBlockSize( void* Ptr ) { return 0; }
};

class FConfigCache
{
public:
	// Vtable slots 0-2: basic type getters
	virtual UBOOL GetBool( const TCHAR* Section, const TCHAR* Key, UBOOL& Value, const TCHAR* Filename=NULL )=0;
	virtual UBOOL GetInt( const TCHAR* Section, const TCHAR* Key, INT& Value, const TCHAR* Filename=NULL )=0;
	virtual UBOOL GetFloat( const TCHAR* Section, const TCHAR* Key, FLOAT& Value, const TCHAR* Filename=NULL )=0;
	// Vtable slots 3-4: string getters (TCHAR* buffer version, then FString& version)
	virtual UBOOL GetString( const TCHAR* Section, const TCHAR* Key, TCHAR* Value, INT Size, const TCHAR* Filename=NULL )=0;
	virtual UBOOL GetString( const TCHAR* Section, const TCHAR* Key, class FString& Str, const TCHAR* Filename=NULL )=0;
	// Vtable slots 5-8: more getters
	virtual const TCHAR* GetStr( const TCHAR* Section, const TCHAR* Key, const TCHAR* Filename=NULL )=0;
	virtual UBOOL GetSection( const TCHAR* Section, TCHAR* Value, INT Size, const TCHAR* Filename=NULL )=0;
	virtual TMultiMap<FString,FString>* GetSectionPrivate( const TCHAR* Section, UBOOL Force, UBOOL Const, const TCHAR* Filename=NULL )=0;
	virtual void EmptySection( const TCHAR* Section, const TCHAR* Filename=NULL )=0;
	// Vtable slots 9-12: setters
	virtual void SetBool( const TCHAR* Section, const TCHAR* Key, UBOOL Value, const TCHAR* Filename=NULL )=0;
	virtual void SetInt( const TCHAR* Section, const TCHAR* Key, INT Value, const TCHAR* Filename=NULL )=0;
	virtual void SetFloat( const TCHAR* Section, const TCHAR* Key, FLOAT Value, const TCHAR* Filename=NULL )=0;
	virtual void SetString( const TCHAR* Section, const TCHAR* Key, const TCHAR* Value, const TCHAR* Filename=NULL )=0;
	// Vtable slots 13-15: management
	virtual void Flush( UBOOL Read, const TCHAR* Filename=NULL )=0;
	virtual void Detach( const TCHAR* Filename )=0;
	virtual void Init( const TCHAR* InSystem, const TCHAR* InUser, UBOOL RequireConfig )=0;

	// === R6-specific additions: slots 16-19 ===
	// These 4 methods are called by Engine.dll during UEngine::Init() for
	// per-profile and per-server config file management. They sit between
	// Init() and Exit() in the retail FConfigCache vtable.
	virtual void InitUser( const TCHAR* InProfilesPath, const TCHAR* InUserIni ) {}
	virtual void InitServer( const TCHAR* InServerIni ) {}
	// GetUserIni/GetServerIni MUST return FString& (not void).
	// The retail caller (appInit in Core.dll at offset 0x3268A) reads the
	// return value as a pointer and dereferences [retval+4] (FString::Count)
	// to check whether the ini path is empty. A void return leaves EAX as
	// garbage (e.g. 1), causing a read of address 0x00000005 → crash.
	virtual FString& GetUserIni( class FString& OutIni ) { return OutIni; }
	virtual FString& GetServerIni( class FString& OutIni ) { return OutIni; }

	// Vtable slots 20-22: cleanup (shifted down by 4 from UT99 layout)
	virtual void Exit()=0;
	virtual void Dump( FOutputDevice& Ar )=0;
	virtual ~FConfigCache() {};

	// === More R6-specific additions: slots 23-33 ===
	// These are called during various boot/exit phases. Slot 23 and 28
	// return a pointer whose [+4] field is read by the caller.
	virtual void* R6Reserved1(void* arg) { static BYTE _buf[64] = {}; return _buf; }
	virtual void R6Reserved2() {}
	virtual void R6Reserved3() {}
	virtual void R6Reserved4() {}
	virtual void R6Reserved5() {}
	virtual void* R6Reserved6(void* arg) { static BYTE _buf[64] = {}; return _buf; }
	virtual void R6Reserved7() {}
	virtual void R6Reserved8() {}
	virtual void R6Reserved9() {}
	virtual void R6Reserved10() {}
	virtual void R6Reserved11() {}
};

class CORE_API FExec
{
public:
	virtual UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar )=0;
};

class CORE_API FNotifyHook
{
public:
	virtual void NotifyDestroy( void* Src ) {}
	virtual void NotifyPreChange( void* Src ) {}
	virtual void NotifyPostChange( void* Src ) {}
	virtual void NotifyExec( void* Src, const TCHAR* Cmd ) {}
};

class FContextSupplier
{
public:
	virtual FString GetContext()=0;
};

class CORE_API FFeedbackContext : public FOutputDevice
{
public:
	virtual UBOOL YesNof( const TCHAR* Fmt, ... )=0;
	virtual void BeginSlowTask( const TCHAR* Task, UBOOL StatusWindow, UBOOL Cancelable )=0;
	virtual void EndSlowTask()=0;
	virtual UBOOL VARARGS StatusUpdatef( INT Numerator, INT Denominator, const TCHAR* Fmt, ... )=0;
	virtual void SetContext( FContextSupplier* InSupplier )=0;
};

typedef void( *STRUCT_AR )( FArchive& Ar, void* TPtr );
typedef void( *STRUCT_DTOR )( void* TPtr );
class CORE_API FTransactionBase
{
public:
	virtual void SaveObject( UObject* Object )=0;
	virtual void SaveArray( UObject* Object, FArray* Array, INT Index, INT Count, INT Oper, INT ElementSize, STRUCT_AR Serializer, STRUCT_DTOR Destructor )=0;
	virtual void Apply()=0;
};

enum EFileTimes  { FILETIME_Create=0, FILETIME_LastAccess=1, FILETIME_LastWrite=2 };
enum EFileWrite  { FILEWRITE_NoFail=0x01, FILEWRITE_NoReplaceExisting=0x02, FILEWRITE_EvenIfReadOnly=0x04, FILEWRITE_Unbuffered=0x08, FILEWRITE_Append=0x10, FILEWRITE_AllowRead=0x20 };
enum EFileRead   { FILEREAD_NoFail=0x01 };
class CORE_API FFileManager
{
public:
	// R6 vtable fix: retail Core.dll has Init at slot 0 (confirmed by
	// CoreClasses.h DLL extraction and boot diagnostic showing Init(1)
	// dispatching to CreateFileReader when Init was last).
	virtual void Init(UBOOL Startup) {}
	virtual FArchive* CreateFileReader( const TCHAR* Filename, DWORD ReadFlags=0, FOutputDevice* Error=GNull )=0;
	virtual FArchive* CreateFileWriter( const TCHAR* Filename, DWORD WriteFlags=0, FOutputDevice* Error=GNull )=0;
	virtual INT FileSize( const TCHAR* Filename )=0;
	virtual UBOOL Delete( const TCHAR* Filename, UBOOL RequireExists=0, UBOOL EvenReadOnly=0 )=0;
	virtual UBOOL Copy( const TCHAR* Dest, const TCHAR* Src, UBOOL Replace=1, UBOOL EvenIfReadOnly=0, UBOOL Attributes=0, void (*Progress)(FLOAT Fraction)=NULL )=0;
	virtual UBOOL Move( const TCHAR* Dest, const TCHAR* Src, UBOOL Replace=1, UBOOL EvenIfReadOnly=0, UBOOL Attributes=0 )=0;
	virtual SQWORD GetGlobalTime( const TCHAR* Filename )=0;
	virtual UBOOL SetGlobalTime( const TCHAR* Filename )=0;
	virtual UBOOL MakeDirectory( const TCHAR* Path, UBOOL Tree=0 )=0;
	virtual UBOOL DeleteDirectory( const TCHAR* Path, UBOOL RequireExists=0, UBOOL Tree=0 )=0;
	virtual TArray<FString> FindFiles( const TCHAR* Filename, UBOOL Files, UBOOL Directories )=0;
	virtual UBOOL SetDefaultDirectory( const TCHAR* Filename )=0;
	virtual FString GetDefaultDirectory()=0;
};

/*----------------------------------------------------------------------------
	Global variables.
----------------------------------------------------------------------------*/

CORE_API extern FMemStack				GMem;
CORE_API extern FOutputDevice*			GLog;
CORE_API extern FOutputDevice*			GNull;
CORE_API extern FOutputDevice*		    GThrow;
CORE_API extern FOutputDeviceError*		GError;
CORE_API extern FFeedbackContext*		GWarn;
CORE_API extern FConfigCache*			GConfig;
CORE_API extern FTransactionBase*		GUndo;
CORE_API extern FOutputDevice*			GLogHook;
CORE_API extern FExec*					GExec;
CORE_API extern FMalloc*				GMalloc;
CORE_API extern FFileManager*			GFileManager;
CORE_API extern USystem*				GSys;
CORE_API extern UProperty*				GProperty;
CORE_API extern BYTE*					GPropAddr;
CORE_API extern USubsystem*				GWindowManager;
CORE_API extern TCHAR				    GErrorHist[4096];
CORE_API extern TCHAR                   GTrue[64], GFalse[64], GYes[64], GNo[64], GNone[64];
CORE_API extern TCHAR					GCdPath[];
CORE_API extern DOUBLE GSecondsPerCycle;
CORE_API extern unsigned short *  GMachineCPU;
CORE_API extern	FTime					GTempTime;
CORE_API extern void					(*GTempFunc)(void*);
CORE_API extern SQWORD					GTicks;
CORE_API extern INT                     GScriptCycles;
CORE_API extern DWORD					GPageSize;
CORE_API extern DWORD					GProcessorCount;
CORE_API extern unsigned long GPhysicalMemory;
CORE_API extern DWORD                   GUglyHackFlags;
CORE_API extern UBOOL					GIsScriptable;
CORE_API extern UBOOL					GIsEditor;
CORE_API extern UBOOL					GIsClient;
CORE_API extern UBOOL					GIsServer;
CORE_API extern UBOOL					GIsCriticalError;
CORE_API extern UBOOL					GIsStarted;
CORE_API extern UBOOL					GIsRunning;
CORE_API extern UBOOL					GIsSlowTask;
CORE_API extern UBOOL					GIsGuarded;
CORE_API extern UBOOL					GIsRequestingExit;
CORE_API extern UBOOL					GIsStrict;
CORE_API extern UBOOL                   GScriptEntryTag;
CORE_API extern UBOOL                   GLazyLoad;
CORE_API extern UBOOL					GUnicode;
CORE_API extern UBOOL					GUnicodeOS;
CORE_API extern class FGlobalMath		GMath;
CORE_API extern	URenderDevice*			GRenderDevice;
CORE_API extern class FArchive*         GDummySave;
CORE_API extern DWORD					GCurrentViewport;

CORE_API extern unsigned short *  GMachineOS;
CORE_API extern unsigned short *  GMachineVideo;
CORE_API extern UBOOL					GNightVisionActive;
CORE_API extern FLOAT					GZoomAdjustment;
CORE_API extern FLOAT					GZoomAdjustmentSniperMode;
CORE_API extern FLOAT					GZoomAdjustmentSniperNoZoom;
CORE_API extern FLOAT					GZoomAdjustmentSniperZoom;
CORE_API extern BYTE					GCompileMaterialsRevision;
CORE_API extern UObject*				GPropObject;

extern "C" DLL_EXPORT TCHAR GPackage[];

// Normal includes.
#include "UnFile.h"
#include "UnObjVer.h"
#include "UnArc.h"
#include "UnTemplate.h"
#include "UnName.h"
#include "UnStack.h"
#include "UnObjBas.h"

// The CSDK UnObjBas.h has DECLARE_FUNCTION inside a block comment (the original
// UE2 UObject body is commented out). We need it for our Engine class declarations.
#ifndef DECLARE_FUNCTION
#define DECLARE_FUNCTION(func) void func( FFrame& TheStack, RESULT_DECL );
#endif

#include "UnCoreNet.h"
#include "UnCorObj.h"
#include "UnClass.h"
#include "UnType.h"
#include "UnScript.h"
#include "UFactory.h"
#include "UExporter.h"
#include "UnCache.h"
#include "UnMem.h"
#include "UnCId.h"
#include "UnBits.h"
#include "UnMath.h"

// NOTE: UnPrim.h is deliberately NOT included here.
// Our src/engine/UnPrim.h provides RVS-compatible definitions with
// DECLARE_CLASS, and is included by Engine.h after Core.h.

#if __STATIC_LINK
#include "UnCoreNative.h"
#endif

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
#endif
