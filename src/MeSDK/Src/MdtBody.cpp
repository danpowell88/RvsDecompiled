/*=============================================================================
    MdtBody.cpp - MdtBody accessor / mutator functions (Karma physics SDK).

    Reconstructed from Ghidra decompilation of Engine.dll
    VA range 0x10493000-0x10496100.

    MdtBody internal layout (offsets recovered from accessor functions):
        +0x130..0x158  rotation matrix rows (3x3 floats, col-major)
        +0x160..0x168  position xyz (3 floats)
        +0x16c..0x174  linear velocity xyz (3 floats)
        +0x178         body flags DWORD
        +0x188..0x190  angular velocity xyz (3 floats)
        +0x194         constraint list head pointer
        +0x1a0         extended flags DWORD
        +0x1a4         pointer to owning MdtWorld
        +0x1a8         user data slot
        +0x1c4         20-byte transform block (used for world add)
        +0x1dc         secondary field (e.g. next body in world list)
        +0x1e0         step size / mass-related float
        +0x1ec         enabled/active flags DWORD
        +0x230         sleep counter / pending update flag
=============================================================================*/
#pragma optimize("", off)
#include "ImplSource.h"
#include "MeTypes.h"
#include <math.h>

/* ---------------------------------------------------------------------------
   Forward declarations for MeSDK-internal helpers not yet in separate TUs.
   All addresses are in the Karma range (VA 0x10490000-0x10510000).
--------------------------------------------------------------------------- */
extern "C" {
    /* FUN_104ee5f0 — insert body into world's body list (VA 0x104ee5f0) */
    void FUN_104ee5f0(int worldListHead, int bodyTransform, int userData);

    /* FUN_104945c0 — iterate to next active constraint on a body (VA 0x104945c0) */
    int  FUN_104945c0(int constraintHandle);

    /* FUN_10493170 — advance body constraint iterator (VA 0x10493170) */
    void FUN_10493170(int* bodyPtr, int constraintHandle);

    /* FUN_104954c0 — apply constraint position update (VA 0x104954c0) */
    void FUN_104954c0(int constraintHandle, int u, int v);

    /* FUN_10506380 — identity/passthrough (VA 0x10506380) — defined in MeWorld.cpp */
    int  FUN_10506380(int param_1);
}

/* ===========================================================================
   MdtBody getters — simple field reads
=========================================================================== */

/*
 * FUN_10493130 — read first-contact field (body+0x164).
 * Called from physKarmaRagDoll_internal to test whether a body is contacting.
 * Retail: 13 bytes.  MOV EAX,[ECX+164h]; RET
 */
IMPL_MATCH("Engine.dll", 0x193130)
int FUN_10493130(int param_1)
{
    return *(int*)(param_1 + 0x164);
}

/*
 * FUN_10496010 — read position-x field (body+0x160).
 * Retail: 13 bytes.
 */
IMPL_MATCH("Engine.dll", 0x196010)
int FUN_10496010(int param_1)
{
    return *(int*)(param_1 + 0x160);
}

/*
 * FUN_10494770 — return pointer to constraint list head (body+0x194).
 * Callers treat the returned int as a handle to the first constraint slot.
 * Retail: 12 bytes.  LEA EAX,[ECX+194h]; RET
 */
IMPL_MATCH("Engine.dll", 0x194770)
int FUN_10494770(int param_1)
{
    return param_1 + 0x194;
}

/*
 * FUN_10494780 — read secondary linked-list pointer (body+0x1dc).
 * Retail: 13 bytes.
 */
IMPL_MATCH("Engine.dll", 0x194780)
int FUN_10494780(int param_1)
{
    return *(int*)(param_1 + 0x1dc);
}

/*
 * FUN_10495dc0 — read mass/step-size float (body+0x1e0).
 * Returns as double (float10 in Ghidra) because of x87 FLD/FSTP round-trip.
 * Retail: 13 bytes.
 */
IMPL_MATCH("Engine.dll", 0x195dc0)
double FUN_10495dc0(int param_1)
{
    return (double)*(float*)(param_1 + 0x1e0);
}

/* ===========================================================================
   MdtBody SetPosition / GetPosition
=========================================================================== */

/*
 * FUN_10494890 — SetPosition(body, x, y, z).
 * Writes 3 floats to offsets +0x160/+0x164/+0x168.
 * Retail: 37 bytes.
 */
IMPL_MATCH("Engine.dll", 0x194890)
void FUN_10494890(int param_1, int param_2, int param_3, int param_4)
{
    *(int*)(param_1 + 0x160) = param_2;
    *(int*)(param_1 + 0x164) = param_3;
    *(int*)(param_1 + 0x168) = param_4;
}

/*
 * FUN_104946d0 — GetPosition(body, out_xyz).
 * Reads 3 floats from +0x160/+0x164/+0x168 into the output array.
 * Retail: 37 bytes.
 */
IMPL_MATCH("Engine.dll", 0x1946d0)
void FUN_104946d0(int param_1, int* param_2)
{
    param_2[0] = *(int*)(param_1 + 0x160);
    param_2[1] = *(int*)(param_1 + 0x164);
    param_2[2] = *(int*)(param_1 + 0x168);
}

/* ===========================================================================
   MdtBody SetLinearVelocity
=========================================================================== */

/*
 * FUN_104948c0 — SetLinearVelocity(body, vx, vy, vz).
 * Writes 3 floats to offsets +0x16c/+0x170/+0x174.
 * Retail: 37 bytes.
 */
IMPL_MATCH("Engine.dll", 0x1948c0)
void FUN_104948c0(int param_1, int param_2, int param_3, int param_4)
{
    *(int*)(param_1 + 0x16c) = param_2;
    *(int*)(param_1 + 0x170) = param_3;
    *(int*)(param_1 + 0x174) = param_4;
}

/* ===========================================================================
   MdtBody flag setters
=========================================================================== */

/*
 * FUN_104934f0 — write body flags DWORD (body+0x178).
 * Retail: 17 bytes.  MOV [ECX+178h],EDX; RET
 */
IMPL_MATCH("Engine.dll", 0x1934f0)
void FUN_104934f0(int param_1, int param_2)
{
    *(int*)(param_1 + 0x178) = param_2;
}

/* ===========================================================================
   MdtBody SetAngularVelocity
=========================================================================== */

/*
 * FUN_10494910 — SetAngularVelocity(body, ax, ay, az).
 * Stores 3 floats at +0x188/+0x18c/+0x190 and sets or clears bit 8 of the
 * extended flags word at +0x1a0 depending on whether the velocity is non-zero
 * (magnitude^2 > 1e-12).
 * Retail: 121 bytes.
 */
IMPL_MATCH("Engine.dll", 0x194910)
void FUN_10494910(int param_1, int param_2, int param_3, int param_4)
{
    *(int*)(param_1 + 0x188) = param_2;
    *(int*)(param_1 + 0x190) = param_4;   /* 0x190 == 400 decimal */
    *(int*)(param_1 + 0x18c) = param_3;

    /* set bit 8 if angular speed is non-negligible */
    if (1e-12f <  *(float*)(param_1 + 0x190) * *(float*)(param_1 + 0x190)
                + *(float*)(param_1 + 0x18c) * *(float*)(param_1 + 0x18c)
                + *(float*)(param_1 + 0x188) * *(float*)(param_1 + 0x188))
    {
        *(unsigned int*)(param_1 + 0x1a0) |= 0x100u;
        return;
    }
    *(unsigned int*)(param_1 + 0x1a0) &= ~0x100u;
}

/* ===========================================================================
   MdtBody EnableBody
=========================================================================== */

/*
 * FUN_104941b0 — EnableBody / add body to simulation world.
 *
 * If bit 0 of flags(+0x1ec) is clear the body has not yet been added to the
 * world.  In that case:
 *   1. Insert the body into the world's internal list (FUN_104ee5f0).
 *   2. Set bit 0 of flags.
 *   3. Increment the world's active-body counter (+0xbc on world struct).
 *   4. Call the optional 'bodyAdded' callback (+0x1cc on world struct).
 * Regardless, clear the 'pending sleep' flag (bit 2 of flags+0x1ec) and
 * zero the sleep counter at +0x230.
 * Retail: 120 bytes.
 */
IMPL_MATCH("Engine.dll", 0x1941b0)
void FUN_104941b0(int param_1)
{
    typedef void (*CodePtr)(int);
    CodePtr pcVar1;

    if ((*(unsigned char*)(param_1 + 0x1ec) & 1) == 0)
    {
        FUN_104ee5f0(
            *(int*)(param_1 + 0x1a4) + 0x68,
            param_1 + 0x1c4,
            *(int*)(param_1 + 0x1a8));

        *(unsigned int*)(param_1 + 0x1ec) |= 1u;

        *(int*)(*(int*)(param_1 + 0x1a4) + 0xbc) =
            *(int*)(*(int*)(param_1 + 0x1a4) + 0xbc) + 1;

        pcVar1 = *(CodePtr*)(*(int*)(param_1 + 0x1a4) + 0x1cc);
        if (pcVar1 != 0)
            pcVar1(param_1);
    }

    *(int*)(param_1 + 0x230) = 0;
    *(unsigned int*)(param_1 + 0x1ec) &= ~4u;
}

/* ===========================================================================
   MdtBody constraint iterator
=========================================================================== */

/*
 * FUN_10493270 — advance to the next active constraint attached to a body.
 *
 * Walks the per-body constraint list: gets the next active entry via
 * FUN_104945c0, updates the iterator (FUN_10493170), then re-applies the
 * constraint position via FUN_104954c0.  Returns the constraint handle (0 if
 * the list is exhausted).
 * Retail: 58 bytes.
 */
IMPL_MATCH("Engine.dll", 0x193270)
int FUN_10493270(int* param_1)
{
    int iVar1;
    int uVar2, uVar3, uVar4;

    iVar1 = FUN_104945c0(*param_1);
    if (iVar1 != 0)
    {
        FUN_10493170(param_1, iVar1);
        uVar4 = param_1[0x16];
        uVar3 = param_1[0x15];
        uVar2 = FUN_10506380(iVar1);
        FUN_104954c0(uVar2, uVar3, uVar4);
    }
    return iVar1;
}

/* ===========================================================================
   MdtBody world-position query (matrix transform + translate)
=========================================================================== */

/*
 * FUN_10493c10 — compute world-space position by applying the body's rotation
 * matrix to an internal local offset and adding the body position.
 *
 * Layout of the body matrix block (col-major 3x3, floats):
 *   col0: +0x130, +0x134, +0x138
 *   col1: +0x140, +0x144, +0x148
 *   col2: +0x150, +0x154, +0x158
 * Local offset vector: +0x194, +0x198, +0x19c  (0x190=400 for first component)
 * Position: +0x160, +0x164, +0x168
 *
 * param_2 receives the resulting 3-float world position.
 * Retail: 157 bytes.
 */
IMPL_MATCH("Engine.dll", 0x193c10)
void FUN_10493c10(int param_1, float* param_2)
{
    param_2[0] = *(float*)(param_1 + 0x130) * *(float*)(param_1 + 0x190)
               + *(float*)(param_1 + 0x140) * *(float*)(param_1 + 0x194)
               + *(float*)(param_1 + 0x150) * *(float*)(param_1 + 0x198)
               + *(float*)(param_1 + 0x160);

    param_2[1] = *(float*)(param_1 + 0x144) * *(float*)(param_1 + 0x194)
               + *(float*)(param_1 + 0x154) * *(float*)(param_1 + 0x198)
               + *(float*)(param_1 + 0x134) * *(float*)(param_1 + 0x190)
               + *(float*)(param_1 + 0x164);

    param_2[2] = *(float*)(param_1 + 0x148) * *(float*)(param_1 + 0x194)
               + *(float*)(param_1 + 0x158) * *(float*)(param_1 + 0x198)
               + *(float*)(param_1 + 0x138) * *(float*)(param_1 + 0x190)
               + *(float*)(param_1 + 0x168);
}
