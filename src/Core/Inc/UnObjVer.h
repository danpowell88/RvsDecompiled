/*=============================================================================
	UnObjVer.h: Unreal object version.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

/*-----------------------------------------------------------------------------
	Version coding.
-----------------------------------------------------------------------------*/

// Earliest engine build that is network compatible with this one.
#define ENGINE_MIN_NET_VERSION 400

// Engine build number, for displaying to end users.
#define ENGINE_VERSION 430

// Base protocol version to negotiate in network play.
// Ravenshield retail uses 600 (Ghidra: FArchive ctor writes 600 to ArNetVer).
// UT99 original was 400.
#define ENGINE_NEGOTIATION_VERSION 600

// Prevents incorrect files from being loaded.
#define PACKAGE_FILE_TAG 0x9E2A83C1

// The current Unrealfile version.
// Ravenshield retail uses 118 (Ghidra: FArchive ctor writes 0x76 to ArVer).
// UT99 original was 69.
#define PACKAGE_FILE_VERSION 118

#if 1 //LVer added by Legend on 4/12/2000
//
// Licensee Version Number
// by Paul Du Bois, Infinite Machine
//
// Uses the upper two words of the VersionNum DWORD to encode a licensee-specific
// version WORD.
//
// Ravenshield retail uses 14 (Ghidra: FArchive ctor writes 0x0E).
// UT99 original was 0.
#define PACKAGE_FILE_VERSION_LICENSEE	14

#define VERSION_ENGINE_ONLY				0x00
#endif

// The earliest file version which we can load with complete
// backwards compatibility. Must be at least PACKAGE_FILE_VERSION.
#define PACKAGE_MIN_VERSION 60

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
