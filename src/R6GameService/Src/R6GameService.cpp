/*=============================================================================
	R6GameService.cpp: R6GameService package init.
=============================================================================*/

#include "R6GameServicePrivate.h"

IMPLEMENT_PACKAGE(R6GameService)

#define NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) R6GAMESERVICE_API FName R6GAMESERVICE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6GameServiceClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	GMalloc dispatch wrappers.
	Same pattern as Engine.dll's FUN_103012b0/FUN_103012d0 — the retail compiler
	outlined GMalloc virtual dispatch into shared thunks at the start of the
	R6GameService.dll .text section. Every function that allocates or frees
	memory dispatches through these tiny helpers.
	The Malloc/Realloc wrappers use __stdcall; Free uses __cdecl with a tail-call
	JMP (our compiler will generate CALL+RET instead).
-----------------------------------------------------------------------------*/

#pragma comment(linker, "/include:?FUN_10006350@@YGPAXK@Z")
#pragma comment(linker, "/include:?FUN_10006370@@YGPAXPAXK@Z")
#pragma comment(linker, "/include:?FUN_10006390@@YGXPAX@Z")
#pragma comment(linker, "/include:?FUN_10059130@@YAXXZ")

// GMalloc->Malloc(Size, L"GAME_SERVICE") __stdcall dispatcher (24 bytes, blocks 221 functions).
IMPL_MATCH("R6GameService.dll", 0x10006350)
void* __stdcall FUN_10006350(DWORD Size)
{
	return GMalloc->Malloc(Size, TEXT("GAME_SERVICE"));
}

// GMalloc->Realloc(Ptr, NewSize, L"GAME_SERVICE") __stdcall dispatcher (30 bytes).
IMPL_MATCH("R6GameService.dll", 0x10006370)
void* __stdcall FUN_10006370(void* Ptr, DWORD NewSize)
{
	return GMalloc->Realloc(Ptr, NewSize, TEXT("GAME_SERVICE"));
}

// GMalloc->Free(Ptr) dispatcher via tail-call JMP (12 bytes, blocks 386 functions).
// Retail uses JMP [EDX+8] tail-call making it __stdcall from caller's perspective;
// our compiler generates CALL + RET 4 instead, but calling convention matches.
IMPL_MATCH("R6GameService.dll", 0x10006390)
void __stdcall FUN_10006390(void* Ptr)
{
	GMalloc->Free(Ptr);
}

// Empty callback stub — just RET (1 byte, blocks 278 functions).
IMPL_MATCH("R6GameService.dll", 0x10059130)
void FUN_10059130(void)
{
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

