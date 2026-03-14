/*=============================================================================
    McdModel.cpp - McdModel accessor functions (Karma collision SDK).

    Reconstructed from Ghidra decompilation of Engine.dll
    VA range 0x104c3660.

    McdModel internal layout (partial, recovered from accessor functions):
        +0x24   geometry handle or geometry count (int)
=============================================================================*/
#pragma optimize("", off)
#include "ImplSource.h"
#include "MeTypes.h"

/* ===========================================================================
   McdModel getters
=========================================================================== */

/*
 * FUN_104c3660 — read geometry field (model+0x24).
 *
 * Returns the value at offset 0x24 of an McdModel instance.  This is used
 * in ragdoll setup to read the geometry type or geometry ID associated with
 * a collision model.
 * Retail: 10 bytes.  MOV EAX,[ECX+24h]; RET
 */
IMPL_MATCH("Engine.dll", 0x1c3660)
int FUN_104c3660(int param_1)
{
    return *(int*)(param_1 + 0x24);
}
