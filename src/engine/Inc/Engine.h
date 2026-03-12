/*=============================================================================
	Engine.h: Unreal engine public header file.
	Local version for Ravenshield Engine module build.

	Replaces the UT99 Engine.h.  Includes our local Core.h (without
	CSDK UnPrim.h), our local UnPrim.h (with DECLARE_CLASS), and our
	local EngineClasses.h (with DECLARE_CLASS for all Engine classes).
=============================================================================*/

#ifndef _INC_ENGINE
#define _INC_ENGINE

/*----------------------------------------------------------------------------
	API.
----------------------------------------------------------------------------*/

#ifndef ENGINE_API
	#define ENGINE_API DLL_IMPORT
#endif

/*-----------------------------------------------------------------------------
	Dependencies.
-----------------------------------------------------------------------------*/

#include "Core.h"

/*-----------------------------------------------------------------------------
	Global variables.
-----------------------------------------------------------------------------*/

ENGINE_API extern class FMemStack	GEngineMem;
ENGINE_API extern class FMemCache	GCache;

/*-----------------------------------------------------------------------------
	Engine public includes.
-----------------------------------------------------------------------------*/

#include "UnPrim.h"

// FColor is defined in UT99 Engine/Inc/UnTex.h, which we don't include.
// Provide the definition here since Engine classes use it as member variables.
#ifndef _INC_FCOLOR
#define _INC_FCOLOR
class ENGINE_API FColor
{
public:
	// Variables.
#if __INTEL_BYTE_ORDER__
	BYTE R,G,B,A;
#else
	BYTE A,B,G,R;
#endif
	FColor() {}
	FColor( BYTE InR, BYTE InG, BYTE InB )
	:	R(InR), G(InG), B(InB), A(255) {}
	FColor( BYTE InR, BYTE InG, BYTE InB, BYTE InA )
	:	R(InR), G(InG), B(InB), A(InA) {}
	FColor( DWORD InColor )
	{ *(DWORD*)this = InColor; }
	FColor( const FPlane& P );

	// Serialization
	friend FArchive& operator<< (FArchive &Ar, FColor &Color )
	{
		return Ar << Color.R << Color.G << Color.B << Color.A;
	}

	// Comparison
	UBOOL operator==( const FColor &C ) const
	{
		return *(DWORD*)this == *(DWORD*)&C;
	}
	UBOOL operator!=( const FColor& C ) const
	{
		return *(DWORD*)this != *(DWORD*)&C;
	}

	// Arithmetic
	void operator+=( FColor C )
	{
		R = (BYTE)Min((INT)R + (INT)C.R, 255);
		G = (BYTE)Min((INT)G + (INT)C.G, 255);
		B = (BYTE)Min((INT)B + (INT)C.B, 255);
		A = (BYTE)Min((INT)A + (INT)C.A, 255);
	}

	// Accessors
	DWORD& DWColor()
	{ return *(DWORD*)this; }
	const DWORD& DWColor() const
	{ return *(const DWORD*)this; }
	DWORD TrueColor() const
	{ return *(const DWORD*)this; }
	DWORD PS2DWColor()
	{ return *(DWORD*)this; }

	// Brightness
	INT Brightness() const
	{ return Max(Max((INT)R, (INT)G), (INT)B); }
	// Retail (48b RVA=0x1EE0): loads byte[2]*2 + byte[1]*3 + byte[0], scale by 1/1536.
	// With RGBA layout (R=byte[0], G=byte[1], B=byte[2]): (2*B + 3*G + R) / 1536.
	FLOAT FBrightness() const
	{ return (2.f*B + 3.f*G + R) / 1536.f; }
	FColor Brighten( INT Amount )
	{
		return FColor( (BYTE)Clamp((INT)R+Amount,0,255), (BYTE)Clamp((INT)G+Amount,0,255), (BYTE)Clamp((INT)B+Amount,0,255), A );
	}

	// Conversions
	FPlane Plane() const
	{ return FPlane(R/255.f, G/255.f, B/255.f, A/255.f); }
	FColor RedBlueSwap()
	{ return FColor(B, G, R, A); }
	operator DWORD() const
	{ return *(const DWORD*)this; }
	operator FPlane() const
	{ return FPlane(R/255.f, G/255.f, B/255.f, A/255.f); }
	operator FVector() const
	{ return FVector(R/255.f, G/255.f, B/255.f); }

	// High color
	// Retail (31b): DWORD-based packing. With RGBA dword=R|G<<8|B<<16|A<<24:
	//   (d>>8)&0xF800 → B[7:3] at bits[15:11]
	//   (d>>6)&0x03E0 → G[7:3] at bits[9:5]   (5-bit G for 555)
	//   d&0xF8        → R[7:3] at bits[7:3]
	_WORD HiColor555() const
	{ DWORD d=DWColor(); return (_WORD)(((d>>8)&0xF800)+((d>>6)&0x03E0)+(d&0xF8)); }
	// Retail (31b): like 555 but G gets 6 bits: (d>>5)&0x07E0
	_WORD HiColor565() const
	{ DWORD d=DWColor(); return (_WORD)(((d>>8)&0xF800)+((d>>5)&0x07E0)+(d&0xF8)); }
};
#endif

// ETravelType is needed by FURL (UnURL.h uses it).
// Defined in UT99 EngineClasses.h but we shadow that, so define here.
#ifndef _INC_ETRAVELTYPE
#define _INC_ETRAVELTYPE
enum ETravelType
{
	TRAVEL_Absolute,
	TRAVEL_Partial,
	TRAVEL_Relative,
};
#endif

#include "UnURL.h"

// Enums needed by ULevel and related classes.
enum EAcceptConnection
{
	ACCEPTC_Reject,
	ACCEPTC_Accept,
	ACCEPTC_Ignore,
};

enum ELevelTick
{
	LEVELTICK_TimeOnly		= 0,
	LEVELTICK_ViewportsOnly	= 1,
	LEVELTICK_All			= 2,
};

enum ESoundOcclusion
{
	OCCLUSION_Default,
	OCCLUSION_None,
	OCCLUSION_BSP,
	OCCLUSION_StaticMeshes,
};

enum ENetRole
{
	ROLE_None,
	ROLE_DumbProxy,
	ROLE_SimulatedProxy,
	ROLE_AutonomousProxy,
	ROLE_Authority,
};

// The net code uses this to send notifications.
class ENGINE_API FNetworkNotify
{
public:
	virtual EAcceptConnection NotifyAcceptingConnection()=0;
	virtual void NotifyAcceptedConnection( class UNetConnection* Connection )=0;
	virtual UBOOL NotifyAcceptingChannel( class UChannel* Channel )=0;
	virtual class ULevel* NotifyGetLevel()=0;
	virtual void NotifyReceivedText( UNetConnection* Connection, const TCHAR* Text )=0;
	virtual UBOOL NotifySendingFile( UNetConnection* Connection, FGuid GUID )=0;
	virtual void NotifyReceivedFile( UNetConnection* Connection, INT PackageIndex, const TCHAR* Error, UBOOL Skipped )=0;
	virtual void NotifyProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds )=0;
};

#include "EngineClasses.h"

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
#endif
