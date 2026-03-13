/*=============================================================================
	R6WeaponsPrivate.h: R6Weapons private header file.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_R6WEAPONS_PRIVATE
#define _INC_R6WEAPONS_PRIVATE

/*----------------------------------------------------------------------------
	API linkage.
----------------------------------------------------------------------------*/

#undef  R6WEAPONS_API
#define R6WEAPONS_API DLL_EXPORT

#ifndef CORE_API
#define CORE_API DLL_IMPORT
#endif
#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif
#ifndef R6ABSTRACT_API
#define R6ABSTRACT_API DLL_IMPORT
#endif

/*----------------------------------------------------------------------------
	Engine / Core / R6Abstract headers.
----------------------------------------------------------------------------*/

#pragma pack(push, 4)

#include "Engine.h"
#include "R6AbstractClasses.h"
#include "R6WeaponsClasses.h"

/*----------------------------------------------------------------------------
	IMPLEMENT_CLASS macro.
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
	extern "C" DLL_EXPORT UClass* autoclass##TClass;\
	DLL_EXPORT UClass* autoclass##TClass = TClass::StaticClass();

#pragma pack(pop)

/*----------------------------------------------------------------------------
	Pre/PostNetReceive replication delta-detection globals.
	Shared between AR6Weapons and AR6DemolitionsGadget within the same DLL.
	Mirror of DAT_1000cb08 / DAT_1000cb10 / DAT_1000cb14 in the retail binary.
----------------------------------------------------------------------------*/
extern DWORD g_net_old_nbBullets;  // DAT_1000cb08: bullet count snapshot
extern DWORD g_net_old_bit6;       // DAT_1000cb10: gadget bitfield bit 6 snapshot
extern DWORD g_net_old_bit7;       // DAT_1000cb14: gadget bitfield bit 7 snapshot

#endif
