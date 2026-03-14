/*=============================================================================
	UnFile.cpp: Low-level utility code — strings, parsing, memory, timing,
	localization, CRC, DLL loading, platform functions.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

// Suppress C4996: retail used GetVersionExA/wcscpy/wcscat etc. verbatim.
// These are intentional for byte parity — do not change to *_s variants.
#pragma warning(disable: 4996)

#include "CorePrivate.h"
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <malloc.h>
#include <float.h>
#include <sys/stat.h>

/*-----------------------------------------------------------------------------
	CRC table.
-----------------------------------------------------------------------------*/

CORE_API DWORD GCRCTable[256];

IMPL_APPROX("CRC table init; reconstructed")
static void appInitCRCTable()
{
	for( DWORD iCRC=0; iCRC<256; iCRC++ )
	{
		DWORD CRC = iCRC;
		for( DWORD j=0; j<8; j++ )
			CRC = (CRC & 1) ? (CRC >> 1) ^ 0xEDB88320 : CRC >> 1;
		GCRCTable[iCRC] = CRC;
	}
}

/*-----------------------------------------------------------------------------
	Global state.
-----------------------------------------------------------------------------*/

static TCHAR GCmdLine[16384] = TEXT("");
static TCHAR GBaseDir[1024]  = TEXT("");
static TCHAR GPackageName[64] = TEXT("Core");
static TCHAR GLanguage[64]   = TEXT("int");

/*-----------------------------------------------------------------------------
	Initialization.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appInit( const TCHAR* InPackage, const TCHAR* InCmdLine, FMalloc* InMalloc, FOutputDevice* InLog, FOutputDeviceError* InError, FFeedbackContext* InWarn, FFileManager* InFileManager, FConfigCache*(*ConfigFactory)(), UBOOL RequireConfig )
{
	guard(appInit);

	// Init CRC table.
	appInitCRCTable();

	// Init global state.
	GMalloc      = InMalloc;
	GLog         = InLog;
	GError       = InError;
	GWarn        = InWarn;
	GFileManager = InFileManager;

	// Init memory allocator.
	GMalloc->Init();

	// Store command line.
	if( InCmdLine )
		appStrncpy( GCmdLine, InCmdLine, ARRAY_COUNT(GCmdLine) );

	// Store package name.
	if( InPackage )
		appStrncpy( GPackageName, InPackage, ARRAY_COUNT(GPackageName) );

	// Determine base directory.
	{
		TCHAR Temp[256] = TEXT("");
#if UNICODE
		if( GUnicodeOS )
			GetModuleFileNameW( NULL, Temp, ARRAY_COUNT(Temp) );
		else
#endif
		{
			ANSICHAR ATemp[256] = "";
			GetModuleFileNameA( NULL, ATemp, ARRAY_COUNT(ATemp) );
			appStrcpy( Temp, ANSI_TO_TCHAR(ATemp) );
		}
		// Strip filename.
		INT i;
		for( i = appStrlen(Temp)-1; i>0; i-- )
			if( Temp[i-1]==PATH_SEPARATOR[0] || Temp[i-1]=='/' )
				break;
		Temp[i]=0;
		appStrcpy( GBaseDir, Temp );
	}

	// Detect OS unicode support.
	OSVERSIONINFOA OsVersionInfo;
	OsVersionInfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFOA);
	GetVersionExA( &OsVersionInfo );
	GUnicodeOS = (OsVersionInfo.dwPlatformId == VER_PLATFORM_WIN32_NT);

	// Detect CPU features.
	GIsMMX        = 1;
	GIsPentiumPro = 1;
	GIsSSE        = 1;

	// Get system info.
	SYSTEM_INFO SI;
	GetSystemInfo( &SI );
	GPageSize       = SI.dwPageSize;
	GProcessorCount = SI.dwNumberOfProcessors;

	// Get physical memory.
	MEMORYSTATUS MemoryStatus;
	GlobalMemoryStatus( &MemoryStatus );
	GPhysicalMemory = (unsigned long)MemoryStatus.dwTotalPhys;

	// Init timing.
	{
		LARGE_INTEGER Frequency;
		verify( QueryPerformanceFrequency( &Frequency ) );
		GSecondsPerCycle = 1.0 / (DOUBLE)Frequency.QuadPart;
	}

	// Init FName subsystem.
	if( !FName::GetInitialized() )
		FName::StaticInit();

	// Init file manager.
	GFileManager->Init( 1 );

	// Init config.
	if( ConfigFactory )
	{
		GConfig = ConfigFactory();
		GConfig->Init( GPackageName, appCmdLine(), RequireConfig );
	}

	// Init memory stack.
	GMem.Init( 65536 );

	// Mark engine as started.
	GIsStarted = 1;

	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appPreExit()
{
	guard(appPreExit);
	GIsRunning = 0;
	debugf( NAME_Exit, TEXT("Preparing to exit.") );
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appExit()
{
	guard(appExit);

	GIsGuarded = 0;

	// Shut down memory stack.
	GMem.Exit();

	// Shut down name subsystem.
	FName::StaticExit();

	// Shut down config.
	if( GConfig )
	{
		GConfig->Exit();
		delete GConfig;
		GConfig = NULL;
	}

	// Shut down file manager.
	if( GFileManager )
		GFileManager->Init( 0 );

	// Shut down memory allocator.
	if( GMalloc )
		GMalloc->Exit();

	// Mark engine as stopped.
	GIsStarted = 0;

	unguard;
}

/*-----------------------------------------------------------------------------
	Logging and critical errors.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appRequestExit( UBOOL Force )
{
	guard(appRequestExit);
	debugf( TEXT("appRequestExit(%i)"), Force );
	if( Force )
	{
		// Force immediate exit.
		ExitProcess( 0 );
	}
	else
	{
		// Tell the mainloop to exit.
		GIsRequestingExit = 1;
	}
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void VARARGS appFailAssert( const ANSICHAR* Expr, const ANSICHAR* File, INT Line )
{
	TCHAR TempStr[1024];
	appSprintf( TempStr, TEXT("Assertion failed: %s [File:%s] [Line: %i]"), ANSI_TO_TCHAR(Expr), ANSI_TO_TCHAR(File), Line );
	appErrorf( TEXT("%s"), TempStr );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void VARARGS appUnwindf( const TCHAR* Fmt, ... )
{
	TCHAR  TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );

	static INT Pos = 0;
	Pos += appStrlen(GErrorHist+Pos);
	if( Pos < ARRAY_COUNT(GErrorHist)-256 )
	{
		appStrncat( GErrorHist, TEXT(" <- "), ARRAY_COUNT(GErrorHist) );
		appStrncat( GErrorHist, TempStr, ARRAY_COUNT(GErrorHist) );
		appStrncat( GErrorHist, TEXT("\r\n"), ARRAY_COUNT(GErrorHist) );
	}
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appGetSystemErrorMessage( INT Error )
{
	guard(appGetSystemErrorMessage);
	static TCHAR Msg[1024];
	Msg[0] = 0;
	if( Error == 0 )
		Error = GetLastError();
#if UNICODE
	if( GUnicodeOS )
		FormatMessageW( FORMAT_MESSAGE_FROM_SYSTEM, NULL, Error, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), Msg, 1024, NULL );
	else
#endif
	{
		ANSICHAR AMsg[1024];
		FormatMessageA( FORMAT_MESSAGE_FROM_SYSTEM, NULL, Error, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), AMsg, 1024, NULL );
		appStrcpy( Msg, ANSI_TO_TCHAR(AMsg) );
	}
	// Strip trailing whitespace.
	if( appStrlen(Msg) > 0 )
	{
		TCHAR* End = Msg + appStrlen(Msg) - 1;
		while( End >= Msg && (*End == '\r' || *End == '\n' || *End == ' ') )
			*End-- = 0;
	}
	return Msg;
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const void appDebugMessagef( const TCHAR* Fmt, ... )
{
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	MessageBox( NULL, TempStr, TEXT("appDebugMessagef"), MB_OK );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const void appMsgf( const TCHAR* Fmt, ... )
{
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	MessageBox( NULL, TempStr, TEXT("Message"), MB_OK );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const void appGetLastError( void )
{
	debugf( NAME_Warning, TEXT("GetLastError: %s"), appGetSystemErrorMessage() );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void VARARGS appThrowf( const TCHAR* Fmt, ... )
{
	static TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	throw( TempStr );
}

/*-----------------------------------------------------------------------------
	OS functions.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appCmdLine()
{
	return GCmdLine;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appBaseDir()
{
	return GBaseDir;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appPackage()
{
	return GPackageName;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appComputerName()
{
	static TCHAR Result[256] = TEXT("");
	if( !Result[0] )
	{
		DWORD Size = ARRAY_COUNT(Result);
#if UNICODE
		if( GUnicodeOS )
			GetComputerNameW( Result, &Size );
		else
#endif
		{
			ANSICHAR AResult[256];
			GetComputerNameA( AResult, &Size );
			appStrcpy( Result, ANSI_TO_TCHAR(AResult) );
		}
	}
	return Result;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appUserName()
{
	static TCHAR Result[256] = TEXT("");
	if( !Result[0] )
	{
		DWORD Size = ARRAY_COUNT(Result);
#if UNICODE
		if( GUnicodeOS )
			GetUserNameW( Result, &Size );
		else
#endif
		{
			ANSICHAR AResult[256];
			GetUserNameA( AResult, &Size );
			appStrcpy( Result, ANSI_TO_TCHAR(AResult) );
		}
	}
	return Result;
}

/*-----------------------------------------------------------------------------
	DLL handling.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void* appGetDllHandle( const TCHAR* DllName )
{
	guard(appGetDllHandle);
	return TCHAR_CALL_OS( LoadLibraryW(DllName), LoadLibraryA(TCHAR_TO_ANSI(DllName)) );
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appFreeDllHandle( void* DllHandle )
{
	guard(appFreeDllHandle);
	check(DllHandle);
	FreeLibrary( (HMODULE)DllHandle );
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void* appGetDllExport( void* DllHandle, const TCHAR* ExportName )
{
	guard(appGetDllExport);
	check(DllHandle);
	return (void*)GetProcAddress( (HMODULE)DllHandle, TCHAR_TO_ANSI(ExportName) );
	unguard;
}

/*-----------------------------------------------------------------------------
	Timing.
-----------------------------------------------------------------------------*/

// appCycles is provided inline by UnVcWin32.h (ASM rdtsc).

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appSecondsSlow()
{
	LARGE_INTEGER Cycles;
	QueryPerformanceCounter( &Cycles );
	return (DOUBLE)Cycles.QuadPart * GSecondsPerCycle;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appSystemTime( INT& Year, INT& Month, INT& DayOfWeek, INT& Day, INT& Hour, INT& Min, INT& Sec, INT& MSec )
{
	SYSTEMTIME st;
	GetLocalTime( &st );
	Year      = st.wYear;
	Month     = st.wMonth;
	DayOfWeek = st.wDayOfWeek;
	Day       = st.wDay;
	Hour      = st.wHour;
	Min       = st.wMinute;
	Sec       = st.wSecond;
	MSec      = st.wMilliseconds;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appTimestamp()
{
	static TCHAR Result[1024];
	INT Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec;
	appSystemTime( Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec );
	appSprintf( Result, TEXT("%04i.%02i.%02i-%02i.%02i.%02i"), Year, Month, Day, Hour, Min, Sec );
	return Result;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appSleep( FLOAT Seconds )
{
	guard(appSleep);
	Sleep( (DWORD)(Seconds * 1000.0f) );
	unguard;
}

/*-----------------------------------------------------------------------------
	String functions.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const ANSICHAR* appToAnsi( const TCHAR* Str )
{
#if UNICODE
	static ANSICHAR ACh[4096];
	INT Count = 0;
	while( *Str && Count<ARRAY_COUNT(ACh)-1 )
		ACh[Count++] = ToAnsi( *Str++ );
	ACh[Count] = 0;
	return ACh;
#else
	return Str;
#endif
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const UNICHAR* appToUnicode( const TCHAR* Str )
{
#if UNICODE
	return Str;
#else
	static UNICHAR UCh[4096];
	INT Count = 0;
	while( *Str && Count<ARRAY_COUNT(UCh)-1 )
		UCh[Count++] = FromAnsi( *Str++ );
	UCh[Count] = 0;
	return UCh;
#endif
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appFromAnsi( const ANSICHAR* Str )
{
#if UNICODE
	static TCHAR TCh[4096];
	INT Count = 0;
	while( *Str && Count<ARRAY_COUNT(TCh)-1 )
		TCh[Count++] = FromAnsi( *Str++ );
	TCh[Count] = 0;
	return TCh;
#else
	return Str;
#endif
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appFromUnicode( const UNICHAR* Str )
{
#if UNICODE
	return Str;
#else
	static TCHAR TCh[4096];
	INT Count = 0;
	while( *Str && Count<ARRAY_COUNT(TCh)-1 )
		TCh[Count++] = FromUnicode( *Str++ );
	TCh[Count] = 0;
	return TCh;
#endif
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL appIsPureAnsi( const TCHAR* Str )
{
	for( ; *Str; Str++ )
		if( (_WORD)*Str > 0x7f )
			return 0;
	return 1;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API TCHAR* appStrcpy( TCHAR* Dest, const TCHAR* Src )
{
	return (TCHAR*)_tcscpy( Dest, Src );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appStrcpy( const TCHAR* String )
{
	return _tcsclen( String );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appStrlen( const TCHAR* String )
{
	return _tcsclen( String );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API TCHAR* appStrstr( const TCHAR* String, const TCHAR* Find )
{
	return (TCHAR*)_tcsstr( String, Find );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API TCHAR* appStrchr( const TCHAR* String, INT c )
{
	return (TCHAR*)_tcschr( String, c );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API TCHAR* appStrcat( TCHAR* Dest, const TCHAR* Src )
{
	return (TCHAR*)_tcscat( Dest, Src );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appStrcmp( const TCHAR* String1, const TCHAR* String2 )
{
	return _tcscmp( String1, String2 );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appStricmp( const TCHAR* String1, const TCHAR* String2 )
{
	return _tcsicmp( String1, String2 );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appStrncmp( const TCHAR* String1, const TCHAR* String2, INT Count )
{
	return _tcsncmp( String1, String2, Count );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appStrnicmp( const TCHAR* A, const TCHAR* B, INT Count )
{
	return _tcsnicmp( A, B, Count );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API TCHAR* appStaticString1024()
{
	// Rotating buffer of static strings.
	static TCHAR StaticString[32][1024];
	static INT   StaticStringIndex = 0;
	TCHAR* Result = StaticString[StaticStringIndex++ % ARRAY_COUNT(StaticString)];
	Result[0] = 0;
	return Result;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API ANSICHAR* appAnsiStaticString1024()
{
	static ANSICHAR StaticString[32][1024];
	static INT      StaticStringIndex = 0;
	ANSICHAR* Result = StaticString[StaticStringIndex++ % ARRAY_COUNT(StaticString)];
	Result[0] = 0;
	return Result;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appSpc( int Num )
{
	static TCHAR Result[256];
	Num = Min( Num, (int)(ARRAY_COUNT(Result)-1) );
	for( INT i=0; i<Num; i++ )
		Result[i] = ' ';
	Result[Num] = 0;
	return Result;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API TCHAR* appStrncpy( TCHAR* Dest, const TCHAR* Src, int Max )
{
	_tcsncpy( Dest, Src, Max );
	Dest[Max-1] = 0;
	return Dest;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API TCHAR* appStrncat( TCHAR* Dest, const TCHAR* Src, int Max )
{
	INT Len = appStrlen(Dest);
	INT Remaining = Max - Len - 1;
	if( Remaining > 0 )
	{
		appStrncpy( Dest + Len, Src, Remaining + 1 );
	}
	return Dest;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API TCHAR* appStrupr( TCHAR* String )
{
	for( TCHAR* S=String; *S; S++ )
		*S = appToUpper(*S);
	return String;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appStrfind( const TCHAR* Str, const TCHAR* Find )
{
	if( !Find || !*Find )
		return NULL;
	INT FindLen = appStrlen(Find);
	for( ; *Str; Str++ )
	{
		if( appStrnicmp(Str, Find, FindLen)==0 )
			return Str;
	}
	return NULL;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DWORD appStrCrc( const TCHAR* Data )
{
	DWORD CRC = 0xFFFFFFFF;
	while( *Data )
	{
		TCHAR Ch = *Data++;
#if UNICODE
		CRC = (CRC >> 8) ^ GCRCTable[(CRC ^ (BYTE)(Ch      )) & 0xFF];
		CRC = (CRC >> 8) ^ GCRCTable[(CRC ^ (BYTE)(Ch >> 8  )) & 0xFF];
#else
		CRC = (CRC >> 8) ^ GCRCTable[(CRC ^ (BYTE)Ch) & 0xFF];
#endif
	}
	return ~CRC;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DWORD appStrCrcCaps( const TCHAR* Data )
{
	DWORD CRC = 0xFFFFFFFF;
	while( *Data )
	{
		TCHAR Ch = appToUpper(*Data++);
#if UNICODE
		CRC = (CRC >> 8) ^ GCRCTable[(CRC ^ (BYTE)(Ch      )) & 0xFF];
		CRC = (CRC >> 8) ^ GCRCTable[(CRC ^ (BYTE)(Ch >> 8  )) & 0xFF];
#else
		CRC = (CRC >> 8) ^ GCRCTable[(CRC ^ (BYTE)Ch) & 0xFF];
#endif
	}
	return ~CRC;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appAtoi( const TCHAR* Str )
{
	return _tstoi( Str );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API FLOAT appAtof( const TCHAR* Str )
{
	return (FLOAT)_tstof( Str );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appStrtoi( const TCHAR* Start, TCHAR** End, INT Base )
{
	return _tcstol( Start, End, Base );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appSprintf( TCHAR* Dest, const TCHAR* Fmt, ... )
{
	va_list ArgPtr;
	va_start( ArgPtr, Fmt );
	INT Result = _vstprintf( Dest, Fmt, ArgPtr );
	va_end( ArgPtr );
	return Result;
}

#if _MSC_VER
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appGetVarArgs( TCHAR* Dest, INT Count, const TCHAR*& Fmt )
{
	va_list ArgPtr;
	// MSVC 2019 does not allow va_start with reference params.
	// Manually compute the va_list pointer past Fmt on the stack.
	ArgPtr = (va_list)( (BYTE*)&Fmt + sizeof(Fmt) );
	INT Result = _vsntprintf( Dest, Count, Fmt, ArgPtr );
	va_end( ArgPtr );
	return Result;
}
#endif

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appTrimSpaces( ANSICHAR* String )
{
	// Trim trailing spaces.
	INT Len = (INT)strlen( String );
	while( Len > 0 && String[Len-1] == ' ' )
		String[--Len] = 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appQsort( void* Base, INT Num, INT Width, QSORT_COMPARE Compare )
{
	qsort( Base, Num, Width, Compare );
}

/*-----------------------------------------------------------------------------
	Memory functions.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void* appMemmove( void* Dest, const void* Src, INT Count )
{
	return memmove( Dest, Src, Count );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appMemcmp( const void* Buf1, const void* Buf2, INT Count )
{
	return memcmp( Buf1, Buf2, Count );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL appMemIsZero( const void* V, int Count )
{
	BYTE* B = (BYTE*)V;
	while( Count-- > 0 )
		if( *B++ != 0 )
			return 0;
	return 1;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DWORD appMemCrc( const void* Data, INT Length, DWORD CRC )
{
	CRC = ~CRC;
	for( INT i=0; i<Length; i++ )
		CRC = (CRC >> 8) ^ GCRCTable[(CRC ^ ((BYTE*)Data)[i]) & 0xFF];
	return ~CRC;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appMemswap( void* Ptr1, void* Ptr2, DWORD Size )
{
	// Swap using temporary buffer.
	void* Temp = appAlloca(Size);
	appMemcpy( Temp, Ptr1, Size );
	appMemcpy( Ptr1, Ptr2, Size );
	appMemcpy( Ptr2, Temp, Size );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appMemset( void* Dest, INT C, INT Count )
{
	memset( Dest, C, Count );
}

#ifndef DEFINED_appMemcpy
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appMemcpy( void* Dest, const void* Src, INT Count )
{
	memcpy( Dest, Src, Count );
}
#endif

#ifndef DEFINED_appMemzero
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appMemzero( void* Dest, INT Count )
{
	memset( Dest, 0, Count );
}
#endif

/*-----------------------------------------------------------------------------
	Math functions.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appExp( DOUBLE Value )  { return exp(Value); }
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appLoge( DOUBLE Value ) { return log(Value); }
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appFmod( DOUBLE A, DOUBLE B ) { return fmod(A,B); }
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appSin( DOUBLE Value )  { return sin(Value); }
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appCos( DOUBLE Value )  { return cos(Value); }
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appAcos( DOUBLE Value ) { return acos(Value); }
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appTan( DOUBLE Value )  { return tan(Value); }
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appAtan( DOUBLE Value ) { return atan(Value); }
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appAtan2( DOUBLE Y, DOUBLE X ) { return atan2(Y,X); }
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appSqrt( DOUBLE Value ) { return sqrt(Value); }
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API DOUBLE appPow( DOUBLE A, DOUBLE B )   { return pow(A,B); }

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL appIsNan( DOUBLE Value )
{
	return _isnan(Value) != 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appRandInit( INT Seed )
{
	srand( (unsigned)Seed );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appRand()
{
	return rand();
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API FLOAT appFrand()
{
	return rand() / (FLOAT)RAND_MAX;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API FLOAT appRandRange( FLOAT Min, FLOAT Max )
{
	return Min + (Max - Min) * appFrand();
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appRandRange( INT Min, INT Max )
{
	return Min + (appRand() % (Max - Min + 1));
}

// appRound, appFloor are provided inline by UnVcWin32.h (ASM fld/fistp).

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appCeil( FLOAT Value )
{
	return (INT)ceil( Value );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API BYTE appCeilLogTwo( DWORD Arg )
{
	INT Bitmask = 0;
	if( Arg & 0xFFFF0000 ) { Arg >>= 16; Bitmask |= 16; }
	if( Arg & 0x0000FF00 ) { Arg >>= 8;  Bitmask |= 8;  }
	if( Arg & 0x000000F0 ) { Arg >>= 4;  Bitmask |= 4;  }
	if( Arg & 0x0000000C ) { Arg >>= 2;  Bitmask |= 2;  }
	if( Arg & 0x00000002 ) {             Bitmask |= 1;  }
	return (BYTE)Bitmask;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appEnableFastMath( UBOOL Enable )
{
	// On MSVC, control FPU precision.
	if( Enable )
		_controlfp( _PC_24, _MCW_PC );
	else
		_controlfp( _PC_64, _MCW_PC );
}

/*-----------------------------------------------------------------------------
	GUID creation.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API FGuid appCreateGuid()
{
	FGuid Result;
	CoCreateGuid( (GUID*)&Result );
	return Result;
}

/*-----------------------------------------------------------------------------
	Temp files.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appCreateTempFilename( const TCHAR* Path, TCHAR* Result256 )
{
	guard(appCreateTempFilename);
	static INT i = 0;
	do
		appSprintf( Result256, TEXT("%s%05i.tmp"), Path, i++ );
	while( GFileManager->FileSize(Result256) > 0 );
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appCleanFileCache()
{
	guard(appCleanFileCache);
	TArray<FString> Found = GFileManager->FindFiles( TEXT("*.tmp"), 1, 0 );
	for( INT i=0; i<Found.Num(); i++ )
		GFileManager->Delete( *Found(i) );
	unguard;
}

/*-----------------------------------------------------------------------------
	Clipboard.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appClipboardCopy( const TCHAR* Str )
{
	guard(appClipboardCopy);
	if( OpenClipboard(GetActiveWindow()) )
	{
		INT StrLen = (appStrlen(Str)+1) * sizeof(TCHAR);
		verify(EmptyClipboard());
		HGLOBAL GlobalMem = GlobalAlloc( GMEM_MOVEABLE, StrLen );
		check(GlobalMem);
		TCHAR* Data = (TCHAR*)GlobalLock( GlobalMem );
		appStrcpy( Data, Str );
		GlobalUnlock( GlobalMem );
#if UNICODE
		verify(SetClipboardData( CF_UNICODETEXT, GlobalMem ));
#else
		verify(SetClipboardData( CF_TEXT, GlobalMem ));
#endif
		verify(CloseClipboard());
	}
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API FString appClipboardPaste()
{
	guard(appClipboardPaste);
	FString Result;
	if( OpenClipboard(GetActiveWindow()) )
	{
#if UNICODE
		HGLOBAL GlobalMem = GetClipboardData( CF_UNICODETEXT );
#else
		HGLOBAL GlobalMem = GetClipboardData( CF_TEXT );
#endif
		if( GlobalMem )
		{
			TCHAR* Data = (TCHAR*)GlobalLock( GlobalMem );
			if( Data )
				Result = Data;
			GlobalUnlock( GlobalMem );
		}
		CloseClipboard();
	}
	return Result;
	unguard;
}

/*-----------------------------------------------------------------------------
	Unicode conversion helpers.
-----------------------------------------------------------------------------*/

#if UNICODE && !defined(NO_UNICODE_OS_SUPPORT) && !defined(NO_ANSI_OS_SUPPORT)
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API ANSICHAR* winToANSI( ANSICHAR* ACh, const UNICHAR* InUCh, INT Count )
{
	WideCharToMultiByte( CP_ACP, 0, InUCh, -1, ACh, Count, NULL, NULL );
	return ACh;
}
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT winGetSizeANSI( const UNICHAR* InUCh )
{
	return WideCharToMultiByte( CP_ACP, 0, InUCh, -1, NULL, 0, NULL, NULL );
}
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UNICHAR* winToUNICODE( UNICHAR* UCh, const ANSICHAR* InACh, INT Count )
{
	MultiByteToWideChar( CP_ACP, 0, InACh, -1, UCh, Count );
	return UCh;
}
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT winGetSizeUNICODE( const ANSICHAR* InACh )
{
	return MultiByteToWideChar( CP_ACP, 0, InACh, -1, NULL, 0 );
}
#endif

/*-----------------------------------------------------------------------------
	Parsing functions.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL ParseCommand( const TCHAR** Stream, const TCHAR* Match )
{
	while( (**Stream==' ') || (**Stream==9) )
		(*Stream)++;
	if( appStrnicmp(*Stream,Match,appStrlen(Match))==0 )
	{
		*Stream += appStrlen(Match);
		if( !appIsAlnum(**Stream) )
		{
			while( (**Stream==' ') || (**Stream==9) )
				(*Stream)++;
			return 1;
		}
		else
		{
			*Stream -= appStrlen(Match);
			return 0;
		}
	}
	else return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, TCHAR* Value, INT MaxLen )
{
	const TCHAR* Found = appStrfind( Stream, Match );
	const TCHAR* Start;
	if( Found )
	{
		Start = Found + appStrlen(Match);
		if( *Start == '\"' )
		{
			// Quoted value.
			appStrncpy( Value, Start+1, MaxLen );
			TCHAR* End = appStrchr( Value, '\"' );
			if( End )
				*End = 0;
		}
		else
		{
			// Unquoted value.
			appStrncpy( Value, Start, MaxLen );
			TCHAR* End = Value;
			while( *End && *End!=' ' && *End!='\t' && *End!='\r' && *End!='\n' )
				End++;
			*End = 0;
		}
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, BYTE& Value )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Value = (BYTE)appAtoi( Temp );
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, SBYTE& Value )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Value = (SBYTE)appAtoi( Temp );
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, _WORD& Value )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Value = (_WORD)appAtoi( Temp );
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, SWORD& Value )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Value = (SWORD)appAtoi( Temp );
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, INT& Value )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Value = appAtoi( Temp );
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, DWORD& Value )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Value = appAtoi( Temp );
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, FLOAT& Value )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Value = appAtof( Temp );
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, FString& Value )
{
	TCHAR Temp[4096] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Value = Temp;
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, QWORD& Value )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Value = _tcstoui64( Temp, NULL, 10 );
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, SQWORD& Value )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Value = _tcstoi64( Temp, NULL, 10 );
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, FName& Name )
{
	TCHAR Temp[NAME_SIZE] = TEXT("");
	if( Parse(Stream, Match, Temp, NAME_SIZE) )
	{
		Name = FName( Temp );
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, FGuid& Guid )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		Guid.A = Guid.B = Guid.C = Guid.D = 0;
		if( appStrlen(Temp) == 32 )
		{
			TCHAR* End;
			TCHAR A[9], B[9], C[9], D[9];
			appStrncpy( A, Temp,    9 ); A[8] = 0;
			appStrncpy( B, Temp+8,  9 ); B[8] = 0;
			appStrncpy( C, Temp+16, 9 ); C[8] = 0;
			appStrncpy( D, Temp+24, 9 ); D[8] = 0;
			Guid.A = _tcstoul( A, &End, 16 );
			Guid.B = _tcstoul( B, &End, 16 );
			Guid.C = _tcstoul( C, &End, 16 );
			Guid.D = _tcstoul( D, &End, 16 );
		}
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL ParseUBOOL( const TCHAR* Stream, const TCHAR* Match, UBOOL& OnOff )
{
	TCHAR Temp[256] = TEXT("");
	if( Parse(Stream, Match, Temp, ARRAY_COUNT(Temp)) )
	{
		OnOff = !appStricmp(Temp,TEXT("True")) || !appStricmp(Temp,TEXT("Yes")) || !appStricmp(Temp,GTrue) || !appStricmp(Temp,GYes) || !appStricmp(Temp,TEXT("1"));
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL ParseLine( const TCHAR** Stream, TCHAR* Result, INT MaxLen, UBOOL Exact )
{
	INT i = 0;
	UBOOL GotStream = 0;
	UBOOL IsQuoted  = 0;
	UBOOL GotLine   = 0;
	while( **Stream && **Stream!='\n' && **Stream!='\r' && i<MaxLen-1 )
	{
		GotStream = 1;
		if( !Exact )
		{
			// Skip leading whitespace.
			if( !GotLine && (**Stream==' ' || **Stream=='\t') )
			{
				(*Stream)++;
				continue;
			}
		}
		GotLine = 1;
		Result[i++] = *(*Stream)++;
	}
	// Skip line terminator.
	if( **Stream == '\r' )
		(*Stream)++;
	if( **Stream == '\n' )
		(*Stream)++;
	Result[i] = 0;
	return GotStream;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL ParseLine( const TCHAR** Stream, FString& Result, UBOOL Exact )
{
	TCHAR Temp[4096];
	UBOOL GotLine = ParseLine( Stream, Temp, ARRAY_COUNT(Temp), Exact );
	Result = Temp;
	return GotLine;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL ParseToken( const TCHAR*& Str, TCHAR* Result, INT MaxLen, UBOOL UseEscape )
{
	INT Len = 0;

	// Skip preceeding spaces and tabs.
	while( *Str==' ' || *Str=='\t' )
		Str++;
	if( *Str == '"' )
	{
		// Quoted token.
		Str++;
		while( *Str && *Str!='"' && Len<MaxLen-1 )
		{
			if( *Str=='\\' && UseEscape )
			{
				Str++;
				if( *Str )
					Result[Len++] = *Str++;
			}
			else
				Result[Len++] = *Str++;
		}
		if( *Str == '"' )
			Str++;
	}
	else
	{
		// Unquoted, delimited by space.
		while( *Str && *Str!=' ' && *Str!='\t' && Len<MaxLen-1 )
			Result[Len++] = *Str++;
	}
	Result[Len] = 0;
	return Len > 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL ParseToken( const TCHAR*& Str, FString& Arg, UBOOL UseEscape )
{
	TCHAR Temp[4096];
	if( ParseToken( Str, Temp, ARRAY_COUNT(Temp), UseEscape ) )
	{
		Arg = Temp;
		return 1;
	}
	return 0;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API FString ParseToken( const TCHAR*& Str, UBOOL UseEscape )
{
	TCHAR Temp[4096];
	if( ParseToken( Str, Temp, ARRAY_COUNT(Temp), UseEscape ) )
		return FString(Temp);
	return FString(TEXT(""));
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void ParseNext( const TCHAR** Stream )
{
	// Skip over spaces, tabs, cr's, and lf's.
	while( **Stream==' ' || **Stream==9 || **Stream==13 || **Stream==10 )
		(*Stream)++;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL ParseParam( const TCHAR* Stream, const TCHAR* Param )
{
	const TCHAR* Start = Stream;
	if( *Stream )
		while( (Start=appStrfind(Start+1,Param))!=NULL )
			if( Start>Stream && (Start[-1]=='-' || Start[-1]=='/') )
			{
				const TCHAR* End = Start + appStrlen(Param);
				if( *End==0 || *End==' ' || *End=='=' )
					return 1;
			}
	return 0;
}

/*-----------------------------------------------------------------------------
	Localization.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* Localize( const TCHAR* Section, const TCHAR* Key, const TCHAR* Package, const TCHAR* LangExt, UBOOL Optional, UBOOL Optional2 )
{
	guard(Localize);
	static TCHAR Result[4096];
	FString Filename;

	// Construct the localization filename.
	if( LangExt )
		Filename = FString::Printf( TEXT("%s%s.%s"), appBaseDir(), Package, LangExt );
	else
		Filename = FString::Printf( TEXT("%s%s.%s"), appBaseDir(), Package, GLanguage );

	// Try to read the string from the localization file.
	if( GConfig && GConfig->GetString(Section, Key, Result, ARRAY_COUNT(Result), *Filename) )
		return Result;

	// Fall back to English.
	if( appStricmp(GLanguage, TEXT("int"))!=0 )
	{
		Filename = FString::Printf( TEXT("%s%s.int"), appBaseDir(), Package );
		if( GConfig && GConfig->GetString(Section, Key, Result, ARRAY_COUNT(Result), *Filename) )
			return Result;
	}

	// Not found.
	if( !Optional )
		debugf( NAME_Localization, TEXT("No localization: %s.%s.%s (%s)"), Package, Section, Key, GLanguage );

	appSprintf( Result, TEXT("<?%s?%s?%s?>"), Package, Section, Key );
	return Result;
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* LocalizeError( const TCHAR* Key, const TCHAR* Package, const TCHAR* LangExt )
{
	return Localize( TEXT("Errors"), Key, Package, LangExt );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* LocalizeProgress( const TCHAR* Key, const TCHAR* Package, const TCHAR* LangExt )
{
	return Localize( TEXT("Progress"), Key, Package, LangExt );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* LocalizeQuery( const TCHAR* Key, const TCHAR* Package, const TCHAR* LangExt )
{
	return Localize( TEXT("Query"), Key, Package, LangExt );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* LocalizeGeneral( const TCHAR* Key, const TCHAR* Package, const TCHAR* LangExt )
{
	return Localize( TEXT("General"), Key, Package, LangExt );
}

#if UNICODE
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* Localize( const ANSICHAR* Section, const ANSICHAR* Key, const TCHAR* Package, const TCHAR* LangExt, UBOOL Optional, UBOOL Optional2 )
{
	return Localize( ANSI_TO_TCHAR(Section), ANSI_TO_TCHAR(Key), Package, LangExt, Optional, Optional2 );
}
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* LocalizeError( const ANSICHAR* Key, const TCHAR* Package, const TCHAR* LangExt )
{
	return LocalizeError( ANSI_TO_TCHAR(Key), Package, LangExt );
}
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* LocalizeProgress( const ANSICHAR* Key, const TCHAR* Package, const TCHAR* LangExt )
{
	return LocalizeProgress( ANSI_TO_TCHAR(Key), Package, LangExt );
}
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* LocalizeQuery( const ANSICHAR* Key, const TCHAR* Package, const TCHAR* LangExt )
{
	return LocalizeQuery( ANSI_TO_TCHAR(Key), Package, LangExt );
}
IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* LocalizeGeneral( const ANSICHAR* Key, const TCHAR* Package, const TCHAR* LangExt )
{
	return LocalizeGeneral( ANSI_TO_TCHAR(Key), Package, LangExt );
}
#endif

/*-----------------------------------------------------------------------------
	File utility functions.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API const TCHAR* appFExt( const TCHAR* Filename )
{
	const TCHAR* Dot = appStrchr( Filename, '.' );
	while( Dot )
	{
		const TCHAR* NextDot = appStrchr( Dot+1, '.' );
		if( NextDot )
			Dot = NextDot;
		else
			return Dot+1;
	}
	return TEXT("");
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL appUpdateFileModTime( TCHAR* Filename )
{
	guard(appUpdateFileModTime);
	// Open file for append (which updates its modification time), then close immediately.
	FArchive* Writer = GFileManager->CreateFileWriter( Filename, FILEWRITE_Append, GNull );
	if( Writer )
	{
		delete Writer;
		return 1;
	}
	return 0;
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL appFindPackageFile( const TCHAR* In, const FGuid* Guid, TCHAR* Out )
{
	guard(appFindPackageFile);

	// Check caches first.
	TCHAR Filename[256];
	appSprintf( Filename, TEXT("%s"), In );

	// Try direct path.
	if( GFileManager->FileSize(Filename) >= 0 )
	{
		appStrcpy( Out, Filename );
		return 1;
	}

	// Try with .u extension.
	TCHAR TestName[256];
	appSprintf( TestName, TEXT("%s.u"), In );
	if( GFileManager->FileSize(TestName) >= 0 )
	{
		appStrcpy( Out, TestName );
		return 1;
	}

	return 0;
	unguard;
}

/*-----------------------------------------------------------------------------
	Array / file loading functions.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL appLoadFileToArray( TArray<BYTE>& Result, const TCHAR* Filename, FFileManager* FileManager )
{
	guard(appLoadFileToArray);
	FArchive* Reader = FileManager->CreateFileReader( Filename );
	if( !Reader )
		return 0;
	Result.Empty();
	Result.Add( Reader->TotalSize() );
	Reader->Serialize( &Result(0), Result.Num() );
	UBOOL Success = Reader->Close();
	delete Reader;
	return Success;
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL appLoadFileToString( FString& Result, const TCHAR* Filename, FFileManager* FileManager )
{
	guard(appLoadFileToString);
	FArchive* Reader = FileManager->CreateFileReader( Filename );
	if( !Reader )
		return 0;
	INT Size = Reader->TotalSize();
	TArray<ANSICHAR> Buffer;
	Buffer.Add( Size + 1 );
	Reader->Serialize( &Buffer(0), Size );
	Buffer(Size) = 0;
	UBOOL Success = Reader->Close();
	delete Reader;
	Result = appFromAnsi( &Buffer(0) );
	return Success;
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL appSaveArrayToFile( const TArray<BYTE>& Array, const TCHAR* Filename, FFileManager* FileManager )
{
	guard(appSaveArrayToFile);
	FArchive* Writer = FileManager->CreateFileWriter( Filename );
	if( !Writer )
		return 0;
	Writer->Serialize( const_cast<BYTE*>(&Array(0)), Array.Num() );
	UBOOL Success = Writer->Close();
	delete Writer;
	return Success;
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL appSaveStringToFile( const FString& String, const TCHAR* Filename, FFileManager* FileManager )
{
	guard(appSaveStringToFile);
	FArchive* Writer = FileManager->CreateFileWriter( Filename );
	if( !Writer )
		return 0;
	const TCHAR* Str = *String;
	while( *Str )
	{
		ANSICHAR ACh = ToAnsi(*Str++);
		Writer->Serialize( &ACh, 1 );
	}
	UBOOL Success = Writer->Close();
	delete Writer;
	return Success;
	unguard;
}

/*-----------------------------------------------------------------------------
	FString format helper.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API FString appFormat( FString Src, const TMultiMap<FString,FString>& Map )
{
	guard(appFormat);
	FString Result;
	const TCHAR* S = *Src;
	for( INT i=0; i<Src.Len(); i++ )
	{
		if( S[i] == '%' && i+1 < Src.Len() )
		{
			// Found a percent sign — look for key.
			FString Key;
			INT j = i+1;
			while( j < Src.Len() && S[j] != '%' )
				Key = Key + FString::Chr(S[j++]);
			if( j < Src.Len() )
			{
				TArray<FString> Values;
				const_cast<TMultiMap<FString,FString>&>(Map).MultiFind( Key, Values );
				if( Values.Num() )
					Result = Result + Values(0);
				i = j;
				continue;
			}
		}
		Result = Result + FString::Chr(S[i]);
	}
	return Result;
	unguard;
}

/*-----------------------------------------------------------------------------
	Launch URL helper.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void appLaunchURL( const TCHAR* URL, const TCHAR* Parms, FString* Error )
{
	guard(appLaunchURL);
	debugf( TEXT("LaunchURL %s %s"), URL, Parms ? Parms : TEXT("") );
	HINSTANCE Code = ShellExecute( NULL, TEXT("open"), URL, Parms, NULL, SW_SHOWNORMAL );
	if( Error )
	{
		if( (PTRDIFF_T)Code <= 32 )
			*Error = appGetSystemErrorMessage();
		else
			*Error = TEXT("");
	}
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API void* appCreateProc( const TCHAR* URL, const TCHAR* Parms, UBOOL bRealTime )
{
	guard(appCreateProc);
	debugf( TEXT("CreateProc %s %s"), URL, Parms );

	PROCESS_INFORMATION ProcInfo;
	SECURITY_ATTRIBUTES Attr;
	Attr.nLength = sizeof(SECURITY_ATTRIBUTES);
	Attr.lpSecurityDescriptor = NULL;
	Attr.bInheritHandle = TRUE;

	STARTUPINFO StartupInfo = { sizeof(STARTUPINFO) };

	TCHAR CommandLine[16384];
	appSprintf( CommandLine, TEXT("%s %s"), URL, Parms ? Parms : TEXT("") );

	if( !CreateProcess( NULL, CommandLine, &Attr, &Attr, TRUE, DETACHED_PROCESS | (bRealTime ? REALTIME_PRIORITY_CLASS : 0), NULL, NULL, &StartupInfo, &ProcInfo ) )
		return NULL;

	CloseHandle( ProcInfo.hThread );
	return ProcInfo.hProcess;
	unguard;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API UBOOL appGetProcReturnCode( void* ProcHandle, INT* ReturnCode )
{
	guard(appGetProcReturnCode);
	return GetExitCodeProcess( (HANDLE)ProcHandle, (DWORD*)ReturnCode ) && *ReturnCode != STILL_ACTIVE;
	unguard;
}

IMPL_APPROX("Ravenshield-specific PunkBuster check")
CORE_API INT appIsPBInstalled()
{
	// Check for pb\pbsv.dll via GFileManager — returns 1 if present.
	if( GFileManager && GFileManager->FileSize( TEXT("pb\\pbsv.dll") ) >= 0 )
		return 1;
	return 0;
}

IMPL_APPROX("Ravenshield-specific overload of appMsgf")
CORE_API const INT appMsgf( INT Type, const TCHAR* Fmt, ... )
{
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	if( GWarn )
		GWarn->Serialize( TempStr, NAME_Log );
	return 1;
}

IMPL_APPROX("Ravenshield-specific GMT timezone helper")
CORE_API FString appGetGMTRef()
{
	// Compute the local UTC offset as a "+HH:MM" / "-HH:MM" string.
	TIME_ZONE_INFORMATION TZI;
	DWORD dwRet = GetTimeZoneInformation( &TZI );
	INT BiasMinutes = TZI.Bias;
	if( dwRet == TIME_ZONE_ID_DAYLIGHT )
		BiasMinutes += TZI.DaylightBias;
	else if( dwRet == TIME_ZONE_ID_STANDARD )
		BiasMinutes += TZI.StandardBias;
	// Bias is minutes WEST of UTC; negate to get offset EAST.
	INT OffsetMinutes = -BiasMinutes;
	TCHAR Buf[32];
	appSprintf( Buf, TEXT("%+03d:%02d"), OffsetMinutes / 60, Abs(OffsetMinutes % 60) );
	return FString( Buf );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnFile.cpp")
CORE_API INT appCreateBitmap( const TCHAR* Pattern, INT Width, INT Height, DWORD* Data, FFileManager* FileManager )
{
	guard(appCreateBitmap);
	if( !FileManager || !Data || Width <= 0 || Height <= 0 )
		return 0;

	// Find an unused filename: Pattern%05i.bmp
	static INT BitmapIndex = 0;
	TCHAR Filename[256];
	if( BitmapIndex == -1 )
	{
		for( INT i = 0; i < 65536; i++ )
		{
			appSprintf( Filename, TEXT("%s%05i.bmp"), Pattern, i );
			if( FileManager->FileSize( Filename ) < 0 )
				break;
		}
	}
	else
	{
		appSprintf( Filename, TEXT("%s%05i.bmp"), Pattern, BitmapIndex );
		BitmapIndex++;
	}

	// Open file writer.
	FArchive* Ar = FileManager->CreateFileWriter( Filename, 0, GNull );
	if( !Ar )
		return 0;

	// BMP file header (14 bytes).
	INT PixelDataSize = Width * Height * 3;
	INT FileSize      = 0x36 + PixelDataSize;
	WORD  bfType      = 0x4D42; // 'BM'
	DWORD bfSize      = FileSize;
	WORD  bfReserved1 = 0;
	WORD  bfReserved2 = 0;
	DWORD bfOffBits   = 0x36;
	*Ar << bfType << bfSize << bfReserved1 << bfReserved2 << bfOffBits;

	// BMP info header (40 bytes).
	DWORD biSize          = 40;
	INT   biWidth         = Width;
	INT   biHeight        = Height;
	WORD  biPlanes        = 1;
	WORD  biBitCount      = 24;
	DWORD biCompression   = 0;
	DWORD biSizeImage     = PixelDataSize;
	DWORD biXPelsPerMeter = 0;
	DWORD biYPelsPerMeter = 0;
	DWORD biClrUsed       = 0;
	DWORD biClrImportant  = 0;
	*Ar << biSize << biWidth << biHeight << biPlanes << biBitCount
	    << biCompression << biSizeImage
	    << biXPelsPerMeter << biYPelsPerMeter << biClrUsed << biClrImportant;

	// Write pixel data bottom-up (BMP convention), 24-bit RGB from 32-bit BGRA input.
	for( INT y = Height - 1; y >= 0; y-- )
	{
		for( INT x = 0; x < Width; x++ )
		{
			DWORD Pixel = Data[ y * Width + x ];
			BYTE R = (BYTE)(Pixel >> 16);
			BYTE G = (BYTE)(Pixel >>  8);
			BYTE B = (BYTE)(Pixel      );
			*Ar << B << G << R;
		}
	}

	delete Ar;
	return 1;
	unguard;
}

IMPL_APPROX("Ravenshield-specific char-upper helper")
CORE_API TCHAR* appCharUpper( TCHAR* Str )
{
	if( Str )
	{
		for( TCHAR* p = Str; *p; p++ )
		{
			if( *p >= 'a' && *p <= 'z' )
				*p += 'A' - 'a';
		}
	}
	return Str;
}

IMPL_APPROX("Ravenshield-specific integer-to-string helper")
CORE_API TCHAR* appItoa( INT Num )
{
	static TCHAR Buf[64];
	appSprintf( Buf, TEXT("%i"), Num );
	return Buf;
}

IMPL_APPROX("Ravenshield-specific ANSI-to-TCHAR conversion helper")
CORE_API TCHAR* winAnsiToTCHAR( char* Str )
{
	static TCHAR Buf[4096];
	if( Str )
	{
		INT i;
		for( i=0; Str[i] && i < 4095; i++ )
			Buf[i] = (TCHAR)(BYTE)Str[i];
		Buf[i] = 0;
	}
	else
		Buf[0] = 0;
	return Buf;
}

IMPL_APPROX("Ravenshield-specific file age query")
CORE_API INT GetFileAgeDays( const TCHAR* Filename )
{
	// Ghidra 0x149b40 (206 bytes): stat the file and compute age in whole days.
	// FUN_1014e410 converts difftime seconds (on FPU) to days (/ 86400).
	struct _stat buf;
	int result;
	if( GUnicodeOS )
	{
		result = _wstat( (const wchar_t*)Filename, &buf );
	}
	else
	{
		char path[MAX_PATH];
		INT i = 0;
		const TCHAR* src = Filename;
		if( src )
		{
			while( *src ) path[i++] = (char)*src++;
			path[i] = 0;
		}
		else path[0] = 0;
		result = _stat( path, &buf );
	}
	if( result != 0 )
		return 0;
	time_t now;
	time( &now );
	double secs = difftime( now, buf.st_mtime );
	return (INT)(secs / 86400.0);
}

IMPL_APPROX("Ravenshield-specific registry read helper")
CORE_API INT RegGet( FString Key, FString Name, FString& Value )
{
	// Read a REG_SZ value from HKEY_LOCAL_MACHINE\<Key>\<Name>.
	// Returns 1 on success, 0 if the key or value is absent.
	HKEY hKey = NULL;
	if( RegOpenKeyExW( HKEY_LOCAL_MACHINE, *Key, 0, KEY_QUERY_VALUE, &hKey ) != ERROR_SUCCESS )
		return 0;
	WCHAR Buf[4096] = {};
	DWORD BufBytes  = sizeof(Buf);
	DWORD Type      = 0;
	LONG  Res = RegQueryValueExW( hKey, *Name, NULL, &Type, (LPBYTE)Buf, &BufBytes );
	RegCloseKey( hKey );
	if( Res != ERROR_SUCCESS )
		return 0;
	Value = FString( Buf );
	return 1;
}

IMPL_APPROX("Ravenshield-specific registry write helper")
CORE_API INT RegSet( FString Key, FString Name, FString Value )
{
	// Write a REG_SZ value to HKEY_LOCAL_MACHINE\<Key>\<Name>.
	// Creates the key if absent. Returns 1 on success.
	HKEY  hKey    = NULL;
	DWORD dwDisp  = 0;
	if( RegCreateKeyExW( HKEY_LOCAL_MACHINE, *Key, 0, NULL,
	                     REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL,
	                     &hKey, &dwDisp ) != ERROR_SUCCESS )
		return 0;
	const TCHAR* Str = *Value;
	LONG Res = RegSetValueExW( hKey, *Name, 0, REG_SZ,
	                           (const BYTE*)Str,
	                           (appStrlen(Str)+1)*sizeof(TCHAR) );
	RegCloseKey( hKey );
	return ( Res == ERROR_SUCCESS ) ? 1 : 0;
}

IMPL_APPROX("Ravenshield-specific CD presence check")
CORE_API INT IsRavenShieldCDInDrive()
{
	return 1;
}

IMPL_APPROX("Ravenshield-specific 2-arg overload of appCreateProc")
CORE_API void* appCreateProc( const TCHAR* URL, const TCHAR* Parms )
{
	return appCreateProc( URL, Parms, 0 );
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
