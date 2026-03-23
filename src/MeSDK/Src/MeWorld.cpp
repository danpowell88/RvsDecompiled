/*=============================================================================
    MeWorld.cpp - MathEngine world / global state utility functions.

    Reconstructed from Ghidra decompilation of Engine.dll
    VA range 0x104f3640-0x10506380.
=============================================================================*/
#include "ImplSource.h"
#include "MeTypes.h"

/* ===========================================================================
   World / passthrough utilities
=========================================================================== */

/*
 * FUN_10506380 — identity / passthrough function.
 *
 * Returns its argument unchanged.  In the Karma SDK this is used as a
 * 'get handle' function where the handle IS the pointer cast to int.
 * Retail: 7 bytes.  MOV EAX,ECX; RET  (thiscall variant)
 */
IMPL_MATCH("Engine.dll", 0x10506380)
int FUN_10506380(int param_1)
{
    return param_1;
}

/*
 * FUN_104f3640 — dereference int pointer.
 *
 * Returns the first DWORD at the address held in param_1.  Used by the Karma
 * world code to read a handle from an indirect pointer table.
 * Retail: 9 bytes.  MOV EAX,[ECX]; RET
 */
IMPL_MATCH("Engine.dll", 0x104f3640)
int FUN_104f3640(int* param_1)
{
    return *param_1;
}
