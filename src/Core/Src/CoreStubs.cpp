/*=============================================================================
	CoreStubs.cpp: Stub implementations for Core.dll exported symbols.
	Resolves linker errors from the .def file exports that don't yet
	have full implementations.

	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"
#include <math.h>
#include <float.h>

/*-----------------------------------------------------------------------------
	__FUNC_NAME__ external linkage workaround.
	MSVC 2019 emits guard() function-local statics with internal linkage,
	but the retail Core.def exports them as external symbols (MSVC 7.1
	behavior). We define global extern "C" arrays with the same string
	content and use /alternatename to redirect the mangled symbols.
-----------------------------------------------------------------------------*/
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
	Math utility function stubs.
-----------------------------------------------------------------------------*/

CORE_API DOUBLE appAsin( DOUBLE Value )
{
	return asin( Value );
}

CORE_API FLOAT appFractional( FLOAT Value )
{
	return Value - floorf( Value );
}

CORE_API FLOAT appSRand()
{
	return (FLOAT)appRand() / (FLOAT)RAND_MAX * 2.0f - 1.0f;
}

CORE_API void appSRandInit( INT Seed )
{
	appRandInit( Seed );
}

CORE_API INT appIsDebuggerPresent()
{
	return ::IsDebuggerPresent();
}

CORE_API INT appIsPBInstalled()
{
	return 0;
}

CORE_API const INT appMsgf( INT Type, const TCHAR* Fmt, ... )
{
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	if( GWarn )
		GWarn->Serialize( TempStr, NAME_Log );
	return 1;
}

CORE_API FString appGetGMTRef()
{
	return FString(TEXT(""));
}

CORE_API INT appCreateBitmap( const TCHAR* Pattern, INT Width, INT Height, DWORD* Data, FFileManager* FileManager )
{
	return 0;
}

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

CORE_API TCHAR* appItoa( INT Num )
{
	static TCHAR Buf[64];
	appSprintf( Buf, TEXT("%i"), Num );
	return Buf;
}

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

/*-----------------------------------------------------------------------------
	MD5 (RFC 1321) implementation.

	Standard MD5 message-digest algorithm. The state fields of FMD5Context:
	  state[0..3] — running A,B,C,D digest words
	  count[0..1] — total bit count (low/high 32 bits, little-endian)
	  buffer[64]  — partial input block awaiting a full 64-byte chunk
-----------------------------------------------------------------------------*/

// Auxiliary round functions (RFC 1321 §3.4)
#define MD5_F(b,c,d) (((b)&(c))|((~b)&(d)))
#define MD5_G(b,c,d) (((b)&(d))|((c)&(~d)))
#define MD5_H(b,c,d) ((b)^(c)^(d))
#define MD5_I(b,c,d) ((c)^((b)|(~d)))
#define MD5_ROL(x,n) (((x)<<(n))|((x)>>(32-(n))))

// Per-step macro: accumulate, rotate, add
#define MD5_FF(a,b,c,d,x,s,t) { (a)+=MD5_F(b,c,d)+(x)+(DWORD)(t); (a)=MD5_ROL(a,s)+(b); }
#define MD5_GG(a,b,c,d,x,s,t) { (a)+=MD5_G(b,c,d)+(x)+(DWORD)(t); (a)=MD5_ROL(a,s)+(b); }
#define MD5_HH(a,b,c,d,x,s,t) { (a)+=MD5_H(b,c,d)+(x)+(DWORD)(t); (a)=MD5_ROL(a,s)+(b); }
#define MD5_II(a,b,c,d,x,s,t) { (a)+=MD5_I(b,c,d)+(x)+(DWORD)(t); (a)=MD5_ROL(a,s)+(b); }

CORE_API void appMD5Init( FMD5Context* Context )
{
	Context->count[0] = Context->count[1] = 0;
	// Magic initialisation constants from RFC 1321 §3.3
	Context->state[0] = 0x67452301;
	Context->state[1] = 0xefcdab89;
	Context->state[2] = 0x98badcfe;
	Context->state[3] = 0x10325476;
}

// Core compression: processes exactly one 64-byte block.
// State is the current A,B,C,D; Block is the raw 64 input bytes.
CORE_API void appMD5Transform( DWORD* State, BYTE* Block )
{
	DWORD a=State[0], b=State[1], c=State[2], d=State[3];
	DWORD x[16];
	appMD5Decode( x, Block, 64 );

	// Round 1 — F function, k=i, s=7/12/17/22
	MD5_FF(a,b,c,d, x[ 0], 7, 0xd76aa478); MD5_FF(d,a,b,c, x[ 1],12, 0xe8c7b756);
	MD5_FF(c,d,a,b, x[ 2],17, 0x242070db); MD5_FF(b,c,d,a, x[ 3],22, 0xc1bdceee);
	MD5_FF(a,b,c,d, x[ 4], 7, 0xf57c0faf); MD5_FF(d,a,b,c, x[ 5],12, 0x4787c62a);
	MD5_FF(c,d,a,b, x[ 6],17, 0xa8304613); MD5_FF(b,c,d,a, x[ 7],22, 0xfd469501);
	MD5_FF(a,b,c,d, x[ 8], 7, 0x698098d8); MD5_FF(d,a,b,c, x[ 9],12, 0x8b44f7af);
	MD5_FF(c,d,a,b, x[10],17, 0xffff5bb1); MD5_FF(b,c,d,a, x[11],22, 0x895cd7be);
	MD5_FF(a,b,c,d, x[12], 7, 0x6b901122); MD5_FF(d,a,b,c, x[13],12, 0xfd987193);
	MD5_FF(c,d,a,b, x[14],17, 0xa679438e); MD5_FF(b,c,d,a, x[15],22, 0x49b40821);

	// Round 2 — G function, k=(5i+1)%16, s=5/9/14/20
	MD5_GG(a,b,c,d, x[ 1], 5, 0xf61e2562); MD5_GG(d,a,b,c, x[ 6], 9, 0xc040b340);
	MD5_GG(c,d,a,b, x[11],14, 0x265e5a51); MD5_GG(b,c,d,a, x[ 0],20, 0xe9b6c7aa);
	MD5_GG(a,b,c,d, x[ 5], 5, 0xd62f105d); MD5_GG(d,a,b,c, x[10], 9, 0x02441453);
	MD5_GG(c,d,a,b, x[15],14, 0xd8a1e681); MD5_GG(b,c,d,a, x[ 4],20, 0xe7d3fbc8);
	MD5_GG(a,b,c,d, x[ 9], 5, 0x21e1cde6); MD5_GG(d,a,b,c, x[14], 9, 0xc33707d6);
	MD5_GG(c,d,a,b, x[ 3],14, 0xf4d50d87); MD5_GG(b,c,d,a, x[ 8],20, 0x455a14ed);
	MD5_GG(a,b,c,d, x[13], 5, 0xa9e3e905); MD5_GG(d,a,b,c, x[ 2], 9, 0xfcefa3f8);
	MD5_GG(c,d,a,b, x[ 7],14, 0x676f02d9); MD5_GG(b,c,d,a, x[12],20, 0x8d2a4c8a);

	// Round 3 — H function, k=(3i+5)%16, s=4/11/16/23
	MD5_HH(a,b,c,d, x[ 5], 4, 0xfffa3942); MD5_HH(d,a,b,c, x[ 8],11, 0x8771f681);
	MD5_HH(c,d,a,b, x[11],16, 0x6d9d6122); MD5_HH(b,c,d,a, x[14],23, 0xfde5380c);
	MD5_HH(a,b,c,d, x[ 1], 4, 0xa4beea44); MD5_HH(d,a,b,c, x[ 4],11, 0x4bdecfa9);
	MD5_HH(c,d,a,b, x[ 7],16, 0xf6bb4b60); MD5_HH(b,c,d,a, x[10],23, 0xbebfbc70);
	MD5_HH(a,b,c,d, x[13], 4, 0x289b7ec6); MD5_HH(d,a,b,c, x[ 0],11, 0xeaa127fa);
	MD5_HH(c,d,a,b, x[ 3],16, 0xd4ef3085); MD5_HH(b,c,d,a, x[ 6],23, 0x04881d05);
	MD5_HH(a,b,c,d, x[ 9], 4, 0xd9d4d039); MD5_HH(d,a,b,c, x[12],11, 0xe6db99e5);
	MD5_HH(c,d,a,b, x[15],16, 0x1fa27cf8); MD5_HH(b,c,d,a, x[ 2],23, 0xc4ac5665);

	// Round 4 — I function, k=(7i)%16, s=6/10/15/21
	MD5_II(a,b,c,d, x[ 0], 6, 0xf4292244); MD5_II(d,a,b,c, x[ 7],10, 0x432aff97);
	MD5_II(c,d,a,b, x[14],15, 0xab9423a7); MD5_II(b,c,d,a, x[ 5],21, 0xfc93a039);
	MD5_II(a,b,c,d, x[12], 6, 0x655b59c3); MD5_II(d,a,b,c, x[ 3],10, 0x8f0ccc92);
	MD5_II(c,d,a,b, x[10],15, 0xffeff47d); MD5_II(b,c,d,a, x[ 1],21, 0x85845dd1);
	MD5_II(a,b,c,d, x[ 8], 6, 0x6fa87e4f); MD5_II(d,a,b,c, x[15],10, 0xfe2ce6e0);
	MD5_II(c,d,a,b, x[ 6],15, 0xa3014314); MD5_II(b,c,d,a, x[13],21, 0x4e0811a1);
	MD5_II(a,b,c,d, x[ 4], 6, 0xf7537e82); MD5_II(d,a,b,c, x[11],10, 0xbd3af235);
	MD5_II(c,d,a,b, x[ 2],15, 0x2ad7d2bb); MD5_II(b,c,d,a, x[ 9],21, 0xeb86d391);

	State[0]+=a; State[1]+=b; State[2]+=c; State[3]+=d;
	appMemzero( x, sizeof(x) ); // security-wipe
}

// Accumulate up to InputLen bytes, processing 64-byte blocks as they fill.
CORE_API void appMD5Update( FMD5Context* Context, BYTE* Input, INT InputLen )
{
	// Compute byte offset into the current partial buffer.
	DWORD Index = (Context->count[0] >> 3) & 0x3f;

	// Update 64-bit bit count (low word first).
	Context->count[0] += (DWORD)InputLen << 3;
	if( Context->count[0] < ((DWORD)InputLen << 3) )
		Context->count[1]++;
	Context->count[1] += (DWORD)InputLen >> 29;

	DWORD PartLen = 64 - Index;

	INT i = 0;
	// If enough bytes to complete a full block, process it.
	if( (DWORD)InputLen >= PartLen )
	{
		appMemcpy( &Context->buffer[Index], Input, PartLen );
		appMD5Transform( Context->state, Context->buffer );
		// Process remaining full blocks directly.
		for( i = (INT)PartLen; i + 63 < InputLen; i += 64 )
			appMD5Transform( Context->state, &Input[i] );
		Index = 0;
	}
	// Copy remaining bytes into partial buffer.
	appMemcpy( &Context->buffer[Index], &Input[i], InputLen - i );
}

// Finalize: pad, append bit-count, encode digest into 16-byte Digest.
CORE_API void appMD5Final( BYTE* Digest, FMD5Context* Context )
{
	BYTE Bits[8];
	appMD5Encode( Bits, Context->count, 8 );

	// Pad to 56 bytes mod 64 (one 0x80, then zeros).
	static const BYTE Padding[64] = { 0x80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	                                   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	                                   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	                                   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
	DWORD Index   = (Context->count[0] >> 3) & 0x3f;
	DWORD PadLen  = (Index < 56) ? (56 - Index) : (120 - Index);
	appMD5Update( Context, (BYTE*)Padding, (INT)PadLen );
	appMD5Update( Context, Bits, 8 );
	appMD5Encode( Digest, Context->state, 16 );
	appMemzero( Context, sizeof(*Context) ); // security-wipe
}

CORE_API void appMD5Encode( BYTE* Output, DWORD* Input, INT Len )
{
	for( INT i=0, j=0; j<Len; i++, j+=4 )
	{
		Output[j]   = (BYTE)(Input[i] & 0xff);
		Output[j+1] = (BYTE)((Input[i] >> 8) & 0xff);
		Output[j+2] = (BYTE)((Input[i] >> 16) & 0xff);
		Output[j+3] = (BYTE)((Input[i] >> 24) & 0xff);
	}
}

CORE_API void appMD5Decode( DWORD* Output, BYTE* Input, INT Len )
{
	for( INT i=0, j=0; j<Len; i++, j+=4 )
		Output[i] = ((DWORD)Input[j]) | (((DWORD)Input[j+1]) << 8) | (((DWORD)Input[j+2]) << 16) | (((DWORD)Input[j+3]) << 24);
}

/*-----------------------------------------------------------------------------
	Misc utility functions.
-----------------------------------------------------------------------------*/

CORE_API INT FLineExtentBoxIntersection( const FBox& Box, const FVector& Start, const FVector& End, const FVector& Extent, FVector& HitLocation, FVector& HitNormal, FLOAT& HitTime )
{
	// Expand the AABB by the sweep half-extents (Minkowski sum).
	// A point moving from Start to End through this expanded box is equivalent
	// to the swept box hitting the original box.
	FVector ExpandedMin( Box.Min.X - Extent.X, Box.Min.Y - Extent.Y, Box.Min.Z - Extent.Z );
	FVector ExpandedMax( Box.Max.X + Extent.X, Box.Max.Y + Extent.Y, Box.Max.Z + Extent.Z );
	FVector Dir( End.X - Start.X, End.Y - Start.Y, End.Z - Start.Z );

	FLOAT tMin = 0.0f;    // entry time (clamp to [0,1])
	FLOAT tMax = 1.0f;    // exit  time
	INT   HitAxis = -1;
	INT   HitSign = 0;

	// Slab test: for each axis independently compute entry/exit times.
	for( INT i = 0; i < 3; i++ )
	{
		FLOAT Origin = (&Start.X)[i];
		FLOAT D      = (&Dir.X)[i];
		FLOAT bMin   = (&ExpandedMin.X)[i];
		FLOAT bMax   = (&ExpandedMax.X)[i];

		if( Abs(D) < 0.0001f )
		{
			// Ray is parallel to slab — check if origin is inside.
			if( Origin < bMin || Origin > bMax )
				return 0; // parallel and outside: no hit
		}
		else
		{
			FLOAT OOD = 1.0f / D;
			FLOAT t1  = (bMin - Origin) * OOD;
			FLOAT t2  = (bMax - Origin) * OOD;
			INT   sign = 1;
			if( t1 > t2 ) { FLOAT Tmp=t1; t1=t2; t2=Tmp; sign=-1; }

			if( t1 > tMin )
			{
				tMin    = t1;
				HitAxis = i;
				HitSign = (D > 0.0f) ? -sign : sign;
			}
			if( t2 < tMax )
				tMax = t2;

			if( tMin > tMax )
				return 0; // slabs separated: no hit
		}
	}

	if( tMax < 0.0f || tMin > 1.0f )
		return 0; // segment misses (behind start or beyond end)

	HitTime = Clamp( tMin, 0.0f, 1.0f );
	HitLocation = FVector(
		Start.X + Dir.X * HitTime,
		Start.Y + Dir.Y * HitTime,
		Start.Z + Dir.Z * HitTime );

	// Normal points outward from the hit face.
	HitNormal = FVector(0,0,0);
	if( HitAxis >= 0 )
		(&HitNormal.X)[HitAxis] = (FLOAT)HitSign;

	return 1;
}

CORE_API INT GetFileAgeDays( const TCHAR* Filename )
{
	return 0;
}

CORE_API INT GetFVECTOR( const TCHAR* Stream, FVector& Value )
{
	Value = FVector(0,0,0);
	if( !Stream )
		return 0;
	Value.X = appAtof( Stream );
	while( *Stream && *Stream != ',' && *Stream != ' ' ) Stream++;
	if( *Stream ) Stream++;
	Value.Y = appAtof( Stream );
	while( *Stream && *Stream != ',' && *Stream != ' ' ) Stream++;
	if( *Stream ) Stream++;
	Value.Z = appAtof( Stream );
	return 1;
}

CORE_API INT GetFROTATOR( const TCHAR* Stream, FRotator& Value, INT bScaled )
{
	Value = FRotator(0,0,0);
	if( !Stream )
		return 0;
	Value.Pitch = appAtoi( Stream );
	while( *Stream && *Stream != ',' && *Stream != ' ' ) Stream++;
	if( *Stream ) Stream++;
	Value.Yaw = appAtoi( Stream );
	while( *Stream && *Stream != ',' && *Stream != ' ' ) Stream++;
	if( *Stream ) Stream++;
	Value.Roll = appAtoi( Stream );
	return 1;
}

CORE_API INT ParseObject( const TCHAR* Stream, const TCHAR* Match, UClass* Class, UObject*& DestRes, UObject* InParent )
{
	return 0;
}

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

CORE_API INT IsRavenShieldCDInDrive()
{
	return 1;
}

CORE_API void EdClearLoadErrors()
{
}

CORE_API void VARARGS EdLoadErrorf( INT Type, const TCHAR* Fmt, ... )
{
}

CORE_API BYTE GRegisterCast( INT CastCode, const Native& Func )
{
	return 0;
}

// RVS: 6-param Localize versions are now defined in UnFile.cpp directly.

/*-----------------------------------------------------------------------------
	Global variable definitions.
-----------------------------------------------------------------------------*/

CORE_API TArray<FEdLoadError> GEdLoadErrors;
CORE_API TArray<INT> GIndexArrayDebugPkg;
CORE_API TArray<INT> GIntArrayDebugPkg;

class UDebugger;
CORE_API UDebugger* GDebugger = NULL;

Native GCasts[256];

FMatrix FMatrix::Identity;
const FVector FVector::FVector0(0,0,0);
FGuid FGuid::SpecialGUIDArmPatches;

/*-----------------------------------------------------------------------------
	FString constructors and methods.
-----------------------------------------------------------------------------*/

FString::FString( BYTE Arg, INT Digits )
: TArray<TCHAR>()
{
	TCHAR Buf[64];
	appSprintf( Buf, TEXT("%i"), (INT)Arg );
	INT Len = appStrlen(Buf);
	Add( Len + 1 );
	appMemcpy( &(*this)(0), Buf, (Len+1)*sizeof(TCHAR) );
}

FString::FString( SBYTE Arg, INT Digits )
: TArray<TCHAR>()
{
	TCHAR Buf[64];
	appSprintf( Buf, TEXT("%i"), (INT)Arg );
	INT Len = appStrlen(Buf);
	Add( Len + 1 );
	appMemcpy( &(*this)(0), Buf, (Len+1)*sizeof(TCHAR) );
}

FString::FString( _WORD Arg, INT Digits )
: TArray<TCHAR>()
{
	TCHAR Buf[64];
	appSprintf( Buf, TEXT("%i"), (INT)Arg );
	INT Len = appStrlen(Buf);
	Add( Len + 1 );
	appMemcpy( &(*this)(0), Buf, (Len+1)*sizeof(TCHAR) );
}

FString::FString( SWORD Arg, INT Digits )
: TArray<TCHAR>()
{
	TCHAR Buf[64];
	appSprintf( Buf, TEXT("%i"), (INT)Arg );
	INT Len = appStrlen(Buf);
	Add( Len + 1 );
	appMemcpy( &(*this)(0), Buf, (Len+1)*sizeof(TCHAR) );
}

FString::FString( INT Arg, INT Digits )
: TArray<TCHAR>()
{
	TCHAR Buf[64];
	appSprintf( Buf, TEXT("%i"), Arg );
	INT Len = appStrlen(Buf);
	Add( Len + 1 );
	appMemcpy( &(*this)(0), Buf, (Len+1)*sizeof(TCHAR) );
}

FString::FString( DWORD Arg, INT Digits )
: TArray<TCHAR>()
{
	TCHAR Buf[64];
	appSprintf( Buf, TEXT("%u"), Arg );
	INT Len = appStrlen(Buf);
	Add( Len + 1 );
	appMemcpy( &(*this)(0), Buf, (Len+1)*sizeof(TCHAR) );
}

FString::FString( FLOAT Arg, INT Digits, INT RightDigits, UBOOL LeadZero )
: TArray<TCHAR>()
{
	TCHAR Buf[256];
	appSprintf( Buf, TEXT("%f"), Arg );
	INT Len = appStrlen(Buf);
	Add( Len + 1 );
	appMemcpy( &(*this)(0), Buf, (Len+1)*sizeof(TCHAR) );
}

FString::FString( DOUBLE Arg, INT Digits, INT RightDigits, INT LeadZero )
: TArray<TCHAR>()
{
	TCHAR Buf[256];
	appSprintf( Buf, TEXT("%f"), Arg );
	INT Len = appStrlen(Buf);
	Add( Len + 1 );
	appMemcpy( &(*this)(0), Buf, (Len+1)*sizeof(TCHAR) );
}

FString FString::Chr( TCHAR Ch )
{
	TCHAR Buf[2] = { Ch, 0 };
	return FString( Buf );
}

FString FString::Printf( const TCHAR* Fmt, ... )
{
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	return FString( TempStr );
}

FString FString::FormatAsNumber( INT InNumber )
{
	FString Number( InNumber, 0 );
	return Number;
}

FString FString::LeftPad( INT ChCount )
{
	guard(FString::LeftPad);
	INT Pad = ChCount - Len();
	if( Pad > 0 )
	{
		FString Result;
		for( INT i=0; i<Pad; i++ )
			Result += TEXT(" ");
		Result += *this;
		return Result;
	}
	return *this;
	unguard;
}

FString FString::RightPad( INT ChCount )
{
	guard(FString::RightPad);
	INT Pad = ChCount - Len();
	FString Result = *this;
	if( Pad > 0 )
	{
		for( INT i=0; i<Pad; i++ )
			Result += TEXT(" ");
	}
	return Result;
	unguard;
}

FString FString::Reverse()
{
	guard(FString::Reverse);
	FString Result;
	for( INT i=Len()-1; i>=0; i-- )
		Result += Mid(i,1);
	return Result;
	unguard;
}

INT FString::ParseIntoArray( const TCHAR* Delim, TArray<FString>* Array )
{
	guard(FString::ParseIntoArray);
	check(Array);
	Array->Empty();
	FString Src = *this;
	INT DelimLen = appStrlen(Delim);
	TCHAR* Found;
	while( (Found = appStrstr( *Src, Delim )) != NULL )
	{
		INT Pos = (INT)(Found - *Src);
		if( Pos > 0 )
			new(*Array) FString( Src.Left(Pos) );
		Src = Src.Mid( Pos + DelimLen );
	}
	if( Src.Len() > 0 )
		new(*Array) FString( Src );
	return Array->Num();
	unguard;
}

/*-----------------------------------------------------------------------------
	FArchive << FString operator.
-----------------------------------------------------------------------------*/

CORE_API FArchive& operator<<( FArchive& Ar, FString& S )
{
	if( Ar.IsLoading() )
	{
		INT SavedLen;
		Ar << AR_INDEX(SavedLen);
		S.Empty();
		if( SavedLen > 0 )
		{
			S.GetCharArray().Add( SavedLen );
			for( INT i=0; i<SavedLen; i++ )
			{
				ANSICHAR Ch;
				Ar << Ch;
				S.GetCharArray()(i) = FromAnsi(Ch);
			}
		}
		else if( SavedLen < 0 )
		{
			SavedLen = -SavedLen;
			S.GetCharArray().Add( SavedLen );
			for( INT i=0; i<SavedLen; i++ )
			{
				TCHAR Ch;
				Ar << Ch;
				S.GetCharArray()(i) = Ch;
			}
		}
	}
	else
	{
		INT SavedLen = S.Len() ? S.Len()+1 : 0;
		Ar << AR_INDEX(SavedLen);
		for( INT i=0; i<SavedLen; i++ )
		{
			ANSICHAR Ch = ToAnsi( (*S)[i] );
			Ar << Ch;
		}
	}
	return Ar;
}

/*-----------------------------------------------------------------------------
	FMatrix methods.
	Note: FMatrix uses M(i,j) method accessor, not M[i][j] array.
-----------------------------------------------------------------------------*/

// Copy constructor is now defined inline in UnMath.h

FMatrix::~FMatrix()
{
}

FMatrix FMatrix::Inverse()
{
	FMatrix Result;
	Result.SetIdentity();
	return Result;
}

FMatrix FMatrix::Transpose()
{
	FMatrix Result;
	for( INT i=0; i<4; i++ )
		for( INT j=0; j<4; j++ )
			Result.M(i,j) = M(j,i);
	return Result;
}

FMatrix FMatrix::TransposeAdjoint() const
{
	FMatrix TA;
	appMemzero( &TA, sizeof(TA) );
	return TA;
}

FLOAT FMatrix::Determinant() const
{
	return M(0,0) * (
		M(1,1) * (M(2,2) * M(3,3) - M(2,3) * M(3,2)) -
		M(2,1) * (M(1,2) * M(3,3) - M(1,3) * M(3,2)) +
		M(3,1) * (M(1,2) * M(2,3) - M(1,3) * M(2,2))
	) - M(1,0) * (
		M(0,1) * (M(2,2) * M(3,3) - M(2,3) * M(3,2)) -
		M(2,1) * (M(0,2) * M(3,3) - M(0,3) * M(3,2)) +
		M(3,1) * (M(0,2) * M(2,3) - M(0,3) * M(2,2))
	) + M(2,0) * (
		M(0,1) * (M(1,2) * M(3,3) - M(1,3) * M(3,2)) -
		M(1,1) * (M(0,2) * M(3,3) - M(0,3) * M(3,2)) +
		M(3,1) * (M(0,2) * M(1,3) - M(0,3) * M(1,2))
	) - M(3,0) * (
		M(0,1) * (M(1,2) * M(2,3) - M(1,3) * M(2,2)) -
		M(1,1) * (M(0,2) * M(2,3) - M(0,3) * M(2,2)) +
		M(2,1) * (M(0,2) * M(1,3) - M(0,3) * M(1,2))
	);
}

FCoords FMatrix::Coords()
{
	FCoords Result;
	Result.Origin.X = M(3,0); Result.Origin.Y = M(3,1); Result.Origin.Z = M(3,2);
	Result.XAxis.X  = M(0,0); Result.XAxis.Y  = M(0,1); Result.XAxis.Z  = M(0,2);
	Result.YAxis.X  = M(1,0); Result.YAxis.Y  = M(1,1); Result.YAxis.Z  = M(1,2);
	Result.ZAxis.X  = M(2,0); Result.ZAxis.Y  = M(2,1); Result.ZAxis.Z  = M(2,2);
	return Result;
}

FMatrix FMatrix::operator*( FMatrix Other ) const
{
	FMatrix Result;
	for( INT i=0; i<4; i++ )
		for( INT j=0; j<4; j++ )
		{
			Result.M(i,j) = 0.0f;
			for( INT k=0; k<4; k++ )
				Result.M(i,j) += M(i,k) * Other.M(k,j);
		}
	return Result;
}

void FMatrix::operator*=( FMatrix Other )
{
	*this = *this * Other;
}

INT FMatrix::operator==( FMatrix& Other ) const
{
	return appMemcmp( this, &Other, sizeof(FMatrix) ) == 0;
}

INT FMatrix::operator!=( FMatrix& Other ) const
{
	return appMemcmp( this, &Other, sizeof(FMatrix) ) != 0;
}

void FMatrix::SetIdentity()
{
	appMemzero( this, sizeof(*this) );
	M(0,0) = M(1,1) = M(2,2) = M(3,3) = 1.0f;
}

FPlane FMatrix::TransformNormal( const FVector& V ) const
{
	return FPlane(
		V.X * M(0,0) + V.Y * M(1,0) + V.Z * M(2,0),
		V.X * M(0,1) + V.Y * M(1,1) + V.Z * M(2,1),
		V.X * M(0,2) + V.Y * M(1,2) + V.Z * M(2,2),
		0.0f
	);
}

FMatrix FCoords::Matrix() const
{
	FMatrix Result;
	Result.M(0,0) = XAxis.X;  Result.M(0,1) = XAxis.Y;  Result.M(0,2) = XAxis.Z;  Result.M(0,3) = 0.0f;
	Result.M(1,0) = YAxis.X;  Result.M(1,1) = YAxis.Y;  Result.M(1,2) = YAxis.Z;  Result.M(1,3) = 0.0f;
	Result.M(2,0) = ZAxis.X;  Result.M(2,1) = ZAxis.Y;  Result.M(2,2) = ZAxis.Z;  Result.M(2,3) = 0.0f;
	Result.M(3,0) = Origin.X; Result.M(3,1) = Origin.Y; Result.M(3,2) = Origin.Z; Result.M(3,3) = 1.0f;
	return Result;
}

/*-----------------------------------------------------------------------------
	FPlane methods.
-----------------------------------------------------------------------------*/

FPlane FPlane::operator+( const FPlane& V ) const { return FPlane( X+V.X, Y+V.Y, Z+V.Z, W+V.W ); }
FPlane FPlane::operator-( const FPlane& V ) const { return FPlane( X-V.X, Y-V.Y, Z-V.Z, W-V.W ); }
FPlane FPlane::operator*( const FPlane& V )        { return FPlane( X*V.X, Y*V.Y, Z*V.Z, W*V.W ); }
FPlane FPlane::operator*( FLOAT Scale ) const      { return FPlane( X*Scale, Y*Scale, Z*Scale, W*Scale ); }
FPlane FPlane::operator/( FLOAT Scale ) const      { FLOAT RScale = 1.0f/Scale; return FPlane( X*RScale, Y*RScale, Z*RScale, W*RScale ); }
FPlane FPlane::operator+=(const FPlane& V)         { X+=V.X; Y+=V.Y; Z+=V.Z; W+=V.W; return *this; }
FPlane FPlane::operator-=(const FPlane& V)         { X-=V.X; Y-=V.Y; Z-=V.Z; W-=V.W; return *this; }
FPlane FPlane::operator*=( const FPlane& V )       { X*=V.X; Y*=V.Y; Z*=V.Z; W*=V.W; return *this; }
FPlane FPlane::operator*=( FLOAT Scale )           { X*=Scale; Y*=Scale; Z*=Scale; W*=Scale; return *this; }
FPlane FPlane::operator/=( FLOAT Scale )           { FLOAT RScale = 1.0f/Scale; X*=RScale; Y*=RScale; Z*=RScale; W*=RScale; return *this; }

FPlane FPlane::TransformBy( const FCoords& Coords ) const
{
	return FPlane( *this | Coords.XAxis, *this | Coords.YAxis, *this | Coords.ZAxis, W - (*this | Coords.Origin) );
}

FPlane FPlane::TransformBy( const FMatrix& M ) const
{
	return FPlane(
		X*M.M(0,0) + Y*M.M(1,0) + Z*M.M(2,0) + W*M.M(3,0),
		X*M.M(0,1) + Y*M.M(1,1) + Z*M.M(2,1) + W*M.M(3,1),
		X*M.M(0,2) + Y*M.M(1,2) + Z*M.M(2,2) + W*M.M(3,2),
		X*M.M(0,3) + Y*M.M(1,3) + Z*M.M(2,3) + W*M.M(3,3)
	);
}

FPlane FPlane::TransformByUsingAdjointT( const FMatrix& M, const FMatrix& TA ) const
{
	return FPlane(
		X*TA.M(0,0) + Y*TA.M(0,1) + Z*TA.M(0,2),
		X*TA.M(1,0) + Y*TA.M(1,1) + Z*TA.M(1,2),
		X*TA.M(2,0) + Y*TA.M(2,1) + Z*TA.M(2,2),
		W - ( M.M(3,0)*X + M.M(3,1)*Y + M.M(3,2)*Z )
	);
}

FPlane FPlane::TransformPlaneByOrtho( const FMatrix& M ) const
{
	return TransformBy( M );
}

/*-----------------------------------------------------------------------------
	FVector methods.
-----------------------------------------------------------------------------*/

FVector::FVector( FLOAT InVal )
: X(InVal), Y(InVal), Z(InVal)
{
}

FVector FVector::GetNonParallel()
{
	if( Abs(X) < 0.9f )
		return FVector(1,0,0);
	else
		return FVector(0,1,0);
}

FVector FVector::GetNormalized()
{
	FLOAT Sz = Size();
	if( Sz > 0.0001f )
		return *this / Sz;
	return FVector(0,0,0);
}

FVector FVector::RotateAngleAxis( INT Angle, const FVector& Axis ) const
{
	FLOAT S = GMath.SinTab(Angle);
	FLOAT C = GMath.CosTab(Angle);
	FLOAT XX  = Axis.X * Axis.X;
	FLOAT YY  = Axis.Y * Axis.Y;
	FLOAT ZZ  = Axis.Z * Axis.Z;
	FLOAT XY  = Axis.X * Axis.Y;
	FLOAT YZ  = Axis.Y * Axis.Z;
	FLOAT ZX  = Axis.Z * Axis.X;
	FLOAT XS  = Axis.X * S;
	FLOAT YS  = Axis.Y * S;
	FLOAT ZS  = Axis.Z * S;
	FLOAT OMC = 1.f - C;
	return FVector(
		(OMC * XX + C ) * X + (OMC * XY - ZS) * Y + (OMC * ZX + YS) * Z,
		(OMC * XY + ZS) * X + (OMC * YY + C ) * Y + (OMC * YZ - XS) * Z,
		(OMC * ZX - YS) * X + (OMC * YZ + XS) * Y + (OMC * ZZ + C ) * Z
	);
}

FVector FVector::TransformVectorByTranspose( const FCoords& Coords ) const
{
	return FVector(
		X * Coords.XAxis.X + Y * Coords.XAxis.Y + Z * Coords.XAxis.Z,
		X * Coords.YAxis.X + Y * Coords.YAxis.Y + Z * Coords.YAxis.Z,
		X * Coords.ZAxis.X + Y * Coords.ZAxis.Y + Z * Coords.ZAxis.Z
	);
}

FLOAT FVector::GetAbsMax() const
{
	return ::Max( ::Max( Abs(X), Abs(Y) ), Abs(Z) );
}

FLOAT FVector::GetMax() const
{
	return ::Max( ::Max( X, Y ), Z );
}

INT FVector::IsUniform()
{
	return (X == Y) && (Y == Z);
}

FLOAT& FVector::operator[]( INT i )
{
	check(i>=0 && i<3);
	return (&X)[i];
}

/*-----------------------------------------------------------------------------
	FBox methods.
-----------------------------------------------------------------------------*/

bool FBox::Intersect( const FBox& Other ) const
{
	if( Min.X > Other.Max.X || Other.Min.X > Max.X )
		return false;
	if( Min.Y > Other.Max.Y || Other.Min.Y > Max.Y )
		return false;
	if( Min.Z > Other.Max.Z || Other.Min.Z > Max.Z )
		return false;
	return true;
}

FBox FBox::TransformBy( const FMatrix& M ) const
{
	FBox Result(0);
	for( int i=0; i<2; i++ )
		for( int j=0; j<2; j++ )
			for( int k=0; k<2; k++ )
			{
				FVector Pt( GetExtrema(i).X, GetExtrema(j).Y, GetExtrema(k).Z );
				Result += M.TransformFVector( Pt );
			}
	return Result;
}

FVector FBox::GetCenter() const
{
	return FVector( (Min.X+Max.X)*0.5f, (Min.Y+Max.Y)*0.5f, (Min.Z+Max.Z)*0.5f );
}

FVector FBox::GetExtent() const
{
	return FVector( (Max.X-Min.X)*0.5f, (Max.Y-Min.Y)*0.5f, (Max.Z-Min.Z)*0.5f );
}

void FBox::GetCenterAndExtents( FVector& Center, FVector& Extents )
{
	Center  = GetCenter();
	Extents = GetExtent();
}

void FBox::Init()
{
	Min = Max = FVector(0,0,0);
	IsValid = 0;
}

FVector& FBox::operator[]( INT i )
{
	check( i>=0 && i<2 );
	if( i == 0 ) return Min;
	return Max;
}

/*-----------------------------------------------------------------------------
	FRotator methods.
-----------------------------------------------------------------------------*/

FRotator::FRotator( FLOAT InVal )
: Pitch((INT)InVal), Yaw((INT)InVal), Roll((INT)InVal)
{
}

FRotator FRotator::Clamp()
{
	return FRotator( Pitch&65535, Yaw&65535, Roll&65535 );
}

FRotator FRotator::ClampPos()
{
	FRotator R = Clamp();
	if( R.Pitch < 0 ) R.Pitch += 65536;
	if( R.Yaw   < 0 ) R.Yaw   += 65536;
	if( R.Roll  < 0 ) R.Roll  += 65536;
	return R;
}

/*-----------------------------------------------------------------------------
	FSphere methods.
-----------------------------------------------------------------------------*/

FSphere FSphere::TransformBy( const FMatrix& M ) const
{
	FVector Center(X, Y, Z);
	FVector Transformed = M.TransformFVector( Center );
	FSphere Result;
	Result.X = Transformed.X;
	Result.Y = Transformed.Y;
	Result.Z = Transformed.Z;
	Result.W = W;
	return Result;
}

/*-----------------------------------------------------------------------------
	FEdLoadError class.
-----------------------------------------------------------------------------*/

FEdLoadError::FEdLoadError()
: Type(0), Desc()
{
}

FEdLoadError::FEdLoadError( INT InType, TCHAR* InDesc )
: Type(InType), Desc(InDesc)
{
}

FEdLoadError::FEdLoadError( const FEdLoadError& Other )
: Type(Other.Type), Desc(Other.Desc)
{
}

FEdLoadError::~FEdLoadError()
{
}

FEdLoadError& FEdLoadError::operator=( FEdLoadError Other )
{
	Type = Other.Type;
	Desc = Other.Desc;
	return *this;
}

INT FEdLoadError::operator==( const FEdLoadError& Other ) const
{
	return Type == Other.Type && Desc == Other.Desc;
}

/*-----------------------------------------------------------------------------
	FPosition class.
-----------------------------------------------------------------------------*/

FPosition::FPosition()
{
}

FPosition::FPosition( FVector InLocation, FCoords InCoords )
: Location(InLocation), Coords(InCoords)
{
}

FPosition& FPosition::operator=( const FPosition& Other )
{
	Location = Other.Location;
	Coords   = Other.Coords;
	return *this;
}

/*-----------------------------------------------------------------------------
	FCylinder class.
-----------------------------------------------------------------------------*/

FCylinder::FCylinder()
: Radius(0), Height(0)
{
}

FCylinder& FCylinder::operator=( const FCylinder& Other )
{
	Radius = Other.Radius;
	Height = Other.Height;
	return *this;
}

INT FCylinder::LineCheck( const FVector& Start, const FVector& End, FVector& HitNormal ) const
{
	return 0;
}

INT FCylinder::LineIntersection( const FVector& Start, const FVector& End, FLOAT* const HitTime ) const
{
	return 0;
}

/*-----------------------------------------------------------------------------
	FEdge class.
-----------------------------------------------------------------------------*/

FEdge::FEdge()
{
	Vertex[0] = FVector(0,0,0);
	Vertex[1] = FVector(0,0,0);
}

FEdge::FEdge( FVector InVertex0, FVector InVertex1 )
{
	Vertex[0] = InVertex0;
	Vertex[1] = InVertex1;
}

FEdge& FEdge::operator=( const FEdge& Other )
{
	Vertex[0] = Other.Vertex[0];
	Vertex[1] = Other.Vertex[1];
	return *this;
}

INT FEdge::operator==( const FEdge& Other ) const
{
	return (Vertex[0] == Other.Vertex[0] && Vertex[1] == Other.Vertex[1]) ||
	       (Vertex[0] == Other.Vertex[1] && Vertex[1] == Other.Vertex[0]);
}

/*-----------------------------------------------------------------------------
	FArchiveCountMem class.
-----------------------------------------------------------------------------*/

FArchiveCountMem::FArchiveCountMem( UObject* Src )
: Num(0), Max(0)
{
	if( Src )
		Src->Serialize( *this );
}

FArchiveCountMem::FArchiveCountMem( const FArchiveCountMem& Other )
: Num(Other.Num), Max(Other.Max)
{
}

FArchiveCountMem::~FArchiveCountMem()
{
}

void FArchiveCountMem::CountBytes( SIZE_T InNum, SIZE_T InMax )
{
	Num += InNum;
	Max += InMax;
}

DWORD FArchiveCountMem::GetNum()
{
	return (DWORD)Num;
}

DWORD FArchiveCountMem::GetMax()
{
	return (DWORD)Max;
}

FArchiveCountMem& FArchiveCountMem::operator=( const FArchiveCountMem& Other )
{
	Num = Other.Num;
	Max = Other.Max;
	return *this;
}

/*-----------------------------------------------------------------------------
	FArchiveDummySave class.
-----------------------------------------------------------------------------*/

FArchiveDummySave::FArchiveDummySave()
{
	ArIsSaving = 1;
}

FArchiveDummySave::FArchiveDummySave( const FArchiveDummySave& Other )
{
	ArIsSaving = 1;
}

FArchiveDummySave::~FArchiveDummySave()
{
}

FArchiveDummySave& FArchiveDummySave::operator=( const FArchiveDummySave& Other )
{
	return *this;
}

/*-----------------------------------------------------------------------------
	FErrorOutError / FLogOutError / FNullOutError / FThrowOut classes.
-----------------------------------------------------------------------------*/

FErrorOutError::FErrorOutError() {}
FErrorOutError::FErrorOutError( const FErrorOutError& ) {}
FErrorOutError& FErrorOutError::operator=( const FErrorOutError& ) { return *this; }
void FErrorOutError::Serialize( const TCHAR* V, EName Event )
{
	if( GError )
		GError->Serialize( V, Event );
}
void FErrorOutError::HandleError()
{
	if( GError )
		GError->HandleError();
}

FLogOutError::FLogOutError() {}
FLogOutError::FLogOutError( const FLogOutError& ) {}
FLogOutError& FLogOutError::operator=( const FLogOutError& ) { return *this; }
void FLogOutError::Serialize( const TCHAR* V, EName Event )
{
	if( GLog )
		GLog->Serialize( V, Event );
}

FNullOutError::FNullOutError() {}
FNullOutError::FNullOutError( const FNullOutError& ) {}
FNullOutError& FNullOutError::operator=( const FNullOutError& ) { return *this; }
void FNullOutError::Serialize( const TCHAR* V, EName Event )
{
}

FThrowOut::FThrowOut() {}
FThrowOut::FThrowOut( const FThrowOut& ) {}
FThrowOut& FThrowOut::operator=( const FThrowOut& ) { return *this; }
void FThrowOut::Serialize( const TCHAR* V, EName Event )
{
	appThrowf( TEXT("%s"), V );
}

/*-----------------------------------------------------------------------------
	FFrame::Serialize.
-----------------------------------------------------------------------------*/

void FFrame::Serialize( const TCHAR* V, EName Event )
{
}

/*-----------------------------------------------------------------------------
	FObjectExport / FObjectImport Serialize member functions.
	The retail binary exports these as member functions in addition
	to the inline operator<< already in UnLinker.h.
-----------------------------------------------------------------------------*/

FArchive& FObjectExport::Serialize( FArchive& Ar )
{
	guard(FObjectExport::Serialize);
	Ar << AR_INDEX(ClassIndex);
	Ar << AR_INDEX(SuperIndex);
	Ar << PackageIndex;
	Ar << ObjectName;
	Ar << ObjectFlags;
	Ar << AR_INDEX(SerialSize);
	if( SerialSize )
		Ar << AR_INDEX(SerialOffset);
	return Ar;
	unguard;
}

FArchive& FObjectImport::Serialize( FArchive& Ar )
{
	guard(FObjectImport::Serialize);
	Ar << ClassPackage << ClassName;
	Ar << PackageIndex;
	Ar << ObjectName;
	if( Ar.IsLoading() )
	{
		SourceIndex = INDEX_NONE;
		XObject     = NULL;
	}
	return Ar;
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject::operator delete — out-of-line definition.
	Must be out-of-line so the linker can export the symbol via .def.
-----------------------------------------------------------------------------*/

void UObject::operator delete( void* Object, size_t Size )
{
	guard(UObject::operator delete);
	appFree( Object );
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject methods.
-----------------------------------------------------------------------------*/

void UObject::AddObject( INT InIndex )
{
	guard(UObject::AddObject);
	if( InIndex == INDEX_NONE )
	{
		if( GObjAvailable.Num() )
		{
			InIndex = GObjAvailable( GObjAvailable.Num()-1 );
			GObjAvailable.Remove( GObjAvailable.Num()-1 );
		}
		else
		{
			InIndex = GObjObjects.Add();
		}
	}
	GObjObjects(InIndex) = this;
	Index = InIndex;
	unguard;
}

void UObject::HashObject()
{
	guard(UObject::HashObject);
	INT iHash       = GetObjectHash( Name, Outer ? Outer->GetIndex() : 0 );
	HashNext        = GObjHash[iHash];
	GObjHash[iHash] = this;
	unguard;
}

void UObject::UnhashObject( INT OuterIndex )
{
	guard(UObject::UnhashObject);
	INT iHash = GetObjectHash( Name, OuterIndex );
	UObject** Hash = &GObjHash[iHash];
	while( *Hash != NULL )
	{
		if( *Hash == this )
		{
			*Hash = HashNext;
			break;
		}
		Hash = &(*Hash)->HashNext;
	}
	unguard;
}

void UObject::SetLinker( ULinkerLoad* InLinker, INT InLinkerIndex )
{
	guard(UObject::SetLinker);
	_Linker      = InLinker;
	_LinkerIndex = InLinkerIndex;
	unguard;
}

FName UObject::MakeUniqueObjectName( UObject* Parent, UClass* Class )
{
	guard(UObject::MakeUniqueObjectName);
	TCHAR NewBase[NAME_SIZE];
	appSprintf( NewBase, TEXT("%s"), Class->GetName() );
	TCHAR Result[NAME_SIZE];
	do
	{
		appSprintf( Result, TEXT("%s%i"), NewBase, GObjRegisterCount++ );
	}
	while( StaticFindObject( NULL, Parent, Result, 0 ) );
	return FName( Result );
	unguard;
}

ULinkerLoad* UObject::GetLoader( INT i )
{
	guard(UObject::GetLoader);
	if( i >= 0 && i < GObjLoaders.Num() )
		return (ULinkerLoad*)GObjLoaders(i);
	return NULL;
	unguard;
}

INT UObject::ResolveName( UObject*& InPackage, const TCHAR*& InName, INT Create, INT Throw )
{
	guard(UObject::ResolveName);
	while( 1 )
	{
		const TCHAR* Dot = appStrchr( InName, '.' );
		if( !Dot )
			break;
		TCHAR Part[NAME_SIZE];
		appStrncpy( Part, InName, Min<INT>((INT)(Dot-InName)+1, NAME_SIZE) );
		Part[Dot-InName] = 0;
		UObject* NewPackage = StaticFindObject( UPackage::StaticClass(), InPackage, Part, 0 );
		if( !NewPackage )
		{
			if( Create )
				NewPackage = CreatePackage( InPackage, Part );
			else
				return 0;
		}
		InPackage = NewPackage;
		InName = Dot + 1;
	}
	return 1;
	unguard;
}

void UObject::CacheDrivers( INT bForceRefresh )
{
	guard(UObject::CacheDrivers);
	// GObjDrivers/GObjPreferences are populated here from config.
	// Full implementation requires iterating GConfig sections for "Driver=" and
	// "Preferences=" entries and building FRegistryObjectInfo/FPreferencesInfo entries.
	// Stub: no-op — subsystems that depend on this (editor tools) will see empty lists.
	unguard;
}

void UObject::PurgeGarbage()
{
	guard(UObject::PurgeGarbage);
	debugf( NAME_Log, TEXT("Purging garbage") );
	// Destroy all objects still tagged as garbage (tagged by IsReferenced / CollectGarbage).
	// DIVERGENCE: binary also garbage-collects FName entries; we skip that here.
	INT NumDestroyed = 0;
	for( INT i=0; i<GObjObjects.Num(); i++ )
	{
		UObject* Obj = GObjObjects(i);
		if( Obj && (Obj->GetFlags() & RF_TagGarbage) && !(Obj->GetFlags() & RF_Native) )
		{
			Obj->ConditionalDestroy();
			NumDestroyed++;
		}
	}
	// Clear any residual tags so objects are not double-destroyed.
	for( INT i=0; i<GObjObjects.Num(); i++ )
		if( GObjObjects(i) )
			GObjObjects(i)->ClearFlags( RF_TagGarbage );
	debugf( NAME_Log, TEXT("Garbage: purged %i object(s)"), NumDestroyed );
	unguard;
}

void UObject::SafeLoadError( DWORD LoadFlags, const TCHAR* Error, const TCHAR* Fmt, ... )
{
	guard(UObject::SafeLoadError);
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	if( LoadFlags & LOAD_Throw )
		appThrowf( TEXT("%s"), TempStr );
	else if( LoadFlags & LOAD_NoWarn )
		debugf( NAME_Log, TEXT("%s"), TempStr );
	else
		GWarn->Logf( TEXT("%s"), TempStr );
	unguard;
}

UObject& UObject::operator=( const UObject& Other )
{
	return *this;
}

/*-----------------------------------------------------------------------------
	UCommandlet stubs.
-----------------------------------------------------------------------------*/

UCommandlet::UCommandlet( const UCommandlet& Other )
: UObject( Other )
{
}

UCommandlet& UCommandlet::operator=( const UCommandlet& Other )
{
	return *this;
}

/*-----------------------------------------------------------------------------
	UProperty overloaded methods — Ravenshield 3-arg variants.
	These delegate to existing 2-arg base versions.
-----------------------------------------------------------------------------*/

// UProperty base 3-arg overloads.
void UProperty::ExportCpp( FOutputDevice& Out, UBOOL IsLocal, UBOOL IsParm, UBOOL IsStruct ) const
{
	ExportCpp( Out, IsLocal, IsParm );
}

void UProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
}

void UProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const
{
	SerializeItem( Ar, Value );
}

void UProperty::SerializeBin( FArchive& Ar, BYTE* Data ) const
{
	SerializeItem( Ar, Data );
}

void UProperty::CleanupDestroyed( BYTE* Data ) const
{
}

void UProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const
{
	CopySingleValue( Dest, Src );
}

void UProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const
{
	CopyCompleteValue( Dest, Src );
}

// UByteProperty.
void UByteProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UByteProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UByteProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UByteProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { CopyCompleteValue( Dest, Src ); }

// UIntProperty.
void UIntProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UIntProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UIntProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UIntProperty::CopyCompleteValue( void* Dest, void* Src ) const { *(INT*)Dest = *(INT*)Src; }
void UIntProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { CopyCompleteValue( Dest, Src ); }

// UBoolProperty.
void UBoolProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UBoolProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UBoolProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }

// UFloatProperty.
void UFloatProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UFloatProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UFloatProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UFloatProperty::CopyCompleteValue( void* Dest, void* Src ) const { *(FLOAT*)Dest = *(FLOAT*)Src; }
void UFloatProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { CopyCompleteValue( Dest, Src ); }

// UObjectProperty.
void UObjectProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UObjectProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UObjectProperty::CleanupDestroyed( BYTE* Data ) const {}
void UObjectProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UObjectProperty::CopyCompleteValue( void* Dest, void* Src ) const { *(UObject**)Dest = *(UObject**)Src; }
void UObjectProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { CopyCompleteValue( Dest, Src ); }

// UNameProperty.
void UNameProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UNameProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UNameProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UNameProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { UProperty::CopyCompleteValue( Dest, Src ); }

// UStrProperty.
void UStrProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UStrProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UStrProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UStrProperty::Serialize( FArchive& Ar ) { UProperty::Serialize( Ar ); }

// UFixedArrayProperty.
void UFixedArrayProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UFixedArrayProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { Out.Log( TEXT("/* FixedArray */") ); }
void UFixedArrayProperty::CleanupDestroyed( BYTE* Data ) const {}
void UFixedArrayProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UFixedArrayProperty::AddCppProperty( UProperty* Property, INT Count ) {}

// UArrayProperty.
void UArrayProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UArrayProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { Out.Log( TEXT("/* Array */") ); }
void UArrayProperty::CleanupDestroyed( BYTE* Data ) const {}
void UArrayProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { UProperty::CopyCompleteValue( Dest, Src ); }
void UArrayProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UArrayProperty::AddCppProperty( UProperty* Property ) { Inner = Property; }

// UMapProperty.
void UMapProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UMapProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { Out.Log( TEXT("/* Map */") ); }
void UMapProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UMapProperty::DestroyValue( void* Dest ) const {}

// UStructProperty.
void UStructProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UStructProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { Out.Log( TEXT("/* Struct */") ); }
void UStructProperty::CleanupDestroyed( BYTE* Data ) const {}
void UStructProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }

// UDelegateProperty — ExportCppItem already implemented in UnProp.cpp.

// UStruct.
void UStruct::SerializeBin( FArchive& Ar, BYTE* Data, INT MaxReadBytes )
{
	SerializeBin( Ar, Data );
}

/*-----------------------------------------------------------------------------
	NetSerializeItem overloads.
-----------------------------------------------------------------------------*/

UBOOL UBoolProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UFloatProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UIntProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UObjectProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UArrayProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UFixedArrayProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UMapProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UStructProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }

/*-----------------------------------------------------------------------------
	UProperty base class ExportCppItem implementations.
	Needed because we declared virtual (non-pure) in UProperty.
-----------------------------------------------------------------------------*/

void UProperty::ExportCppItem( FOutputDevice& Out ) const
{
}

void UProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const
{
}

/*-----------------------------------------------------------------------------
	Missing UNameProperty::CopyCompleteValue 2-arg.
-----------------------------------------------------------------------------*/

void UNameProperty::CopyCompleteValue( void* Dest, void* Src ) const
{
	*(FName*)Dest = *(FName*)Src;
}

/*-----------------------------------------------------------------------------
	UClassProperty::ImportText — delegates to UObjectProperty.
-----------------------------------------------------------------------------*/

const TCHAR* UClassProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	return UObjectProperty::ImportText( Buffer, Data, PortFlags );
}

/*-----------------------------------------------------------------------------
	Ravenshield UObject overloads.
	These Ravenshield-specific overloads delegate to existing base versions.
-----------------------------------------------------------------------------*/

void UObject::Rename( const TCHAR* NewName )
{
	guard(UObject::Rename);
	INT OldOuterIndex = Outer ? Outer->GetIndex() : 0;
	UnhashObject( OldOuterIndex );
	if( NewName )
		Name = FName( NewName );
	HashObject();
	unguard;
}

void UObject::Rename( const TCHAR* NewName, UObject* NewOuter )
{
	INT OldOuterIndex = Outer ? Outer->GetIndex() : 0;
	UnhashObject( OldOuterIndex );
	if( NewName )
		Name = FName( NewName );
	if( NewOuter )
		Outer = NewOuter;
	HashObject();
}

void UObject::LoadLocalized( INT Flags, UClass* Class )
{
	LoadLocalized();
}

// RVS: ResetConfig 3-param version is now defined in UnObj.cpp directly.

void UObject::SetKey( UClass* Class, const TCHAR* Section )
{
}

void UObject::InitProperties( BYTE* Data, INT DataCount, UClass* DefaultsClass, BYTE* Defaults, INT DefaultsCount, UObject* DestObject, INT bNativeDefaults )
{
	InitProperties( Data, DataCount, DefaultsClass, Defaults, DefaultsCount, DestObject, (UObject*)NULL );
}

UObject* UObject::StaticConstructObject( UClass* Class, UObject* InOuter, FName Name, DWORD Flags, UObject* Template, FOutputDevice* Error, INT Reserved )
{
	return StaticConstructObject( Class, InOuter, Name, Flags, Template, Error, (UObject*)NULL );
}

INT UObject::StaticExec( const TCHAR* Cmd, FOutputDevice& Ar, INT bShowHelp )
{
	return StaticExec( Cmd, Ar );
}

/*-----------------------------------------------------------------------------
	UObject::execVRand — script exec stub for VRand().
-----------------------------------------------------------------------------*/

void UObject::execVRand( FFrame& Stack, void* const Result )
{
	P_FINISH;
	*(FVector*)Result = VRand();
}

/*-----------------------------------------------------------------------------
	UFactory Ravenshield overloads with ULevel* parameter.
	Delegates to base version ignoring ULevel*.
-----------------------------------------------------------------------------*/

UObject* UFactory::FactoryCreateText( ULevel* Level, UClass* Class, UObject* InParent, FName Name, DWORD Flags, UObject* Context, const TCHAR* Type, const TCHAR*& Buffer, const TCHAR* BufferEnd, FFeedbackContext* Warn )
{
	return FactoryCreateText( Class, InParent, Name, Flags, Context, Type, Buffer, BufferEnd, Warn );
}

UObject* UFactory::StaticImportObject( ULevel* Level, UClass* Class, UObject* InOuter, FName Name, DWORD Flags, const TCHAR* Filename, UObject* Context, UFactory* Factory, const TCHAR* Parms, FFeedbackContext* Warn )
{
	return StaticImportObject( Class, InOuter, Name, Flags, Filename, Context, Factory, Parms, Warn );
}

/*-----------------------------------------------------------------------------
	TArray<TCHAR> operator+ and operator+=.
	Explicit template instantiations for .def export.
-----------------------------------------------------------------------------*/

template<>
TArray<TCHAR>& TArray<TCHAR>::operator+( const TArray<TCHAR>& Other )
{
	for( INT i=0; i<Other.Num(); i++ )
		AddItem( Other(i) );
	return *this;
}

template<>
TArray<TCHAR>& TArray<TCHAR>::operator+=( const TArray<TCHAR>& Other )
{
	return operator+( Other );
}

/*-----------------------------------------------------------------------------
	appCreateProc 2-arg overload.
-----------------------------------------------------------------------------*/

CORE_API void* appCreateProc( const TCHAR* URL, const TCHAR* Parms )
{
	return appCreateProc( URL, Parms, 0 );
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
