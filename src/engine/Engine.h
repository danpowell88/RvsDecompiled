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
	friend FArchive& operator<< (FArchive &Ar, FColor &Color )
	{
		return Ar << Color.R << Color.G << Color.B << Color.A;
	}
	UBOOL operator==( const FColor &C ) const
	{
		return *(DWORD*)this == *(DWORD*)&C;
	}
	UBOOL operator!=( const FColor& C ) const
	{
		return *(DWORD*)this != *(DWORD*)&C;
	}
};
#endif

#include "EngineClasses.h"

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
#endif
