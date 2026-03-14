/*=============================================================================
    MdtContact.cpp - MdtContactParams accessor / mutator functions.

    Reconstructed from Ghidra decompilation of Engine.dll
    VA range 0x104949e0-0x104966a0.

    MdtContactParams internal layout (recovered from setter functions):
        +0x0c   flags DWORD  (bits: 2=softness-zero, 3=damping-zero, ...)
        +0x18   softness   (MeReal)
        +0x1c   damping    (MeReal)
        +0x20   primary friction   (MeReal)
        +0x24   primary slip       (MeReal)
        +0x2c   secondary friction (MeReal)
        +0x30   secondary slip     (MeReal)
        +0x54   contact group handle (pointer A)
        +0x58   contact group handle (pointer B)
        +0xec   contact list node (offset A, relative to +0x54 slot)
        +0x12c  contact list node (offset B, relative to +0x58 slot)

    MdtContactGroup layout (field +0x160 read by FUN_10496010):
        +0x160  first field (contact count or ID)
=============================================================================*/
#pragma optimize("", off)
#include "ImplSource.h"
#include "MeTypes.h"
#include <math.h>

/* ---------------------------------------------------------------------------
   Forward declarations for MeSDK-internal helpers.
--------------------------------------------------------------------------- */
extern "C" {
    /* FUN_104ee170 — MeMessage error/warning logger (VA 0x104ee170) */
    void FUN_104ee170(int level, const char* msg);

    /* FUN_104966a0 — insert contact into a contact group (VA 0x104966a0) */
    void FUN_104966a0(int groupHandle, int contactNode, int flags, int extra);

    /* FUN_10494a30, FUN_10494a80 — sub-functions for SetNormalFriction (VA 0x10494a30/0x10494a80) */
    void FUN_10494a30(int param_1, int param_2);
    void FUN_10494a80(int param_1, int param_2);

    /* FUN_10494bf0, FUN_10494c50 — sub-functions for SetFriction (VA 0x10494bf0/0x10494c50) */
    void FUN_10494bf0(int param_1, float param_2);
    void FUN_10494c50(int param_1, float param_2);
}

/* ===========================================================================
   MdtContactGroup operations
=========================================================================== */

/*
 * FUN_104953b0 — AddContactToGroup(contact, side, extra).
 *
 * Adds the contact to one of the two attached contact groups.  When param_2
 * is 0 it uses the group at +0x54 / node at +0xec; otherwise the group at
 * +0x58 / node at +0x12c (offset 300 decimal).
 * Retail: 57 bytes.
 */
IMPL_MATCH("Engine.dll", 0x1953b0)
void FUN_104953b0(int param_1, int param_2, int param_3)
{
    if (param_2 == 0)
    {
        FUN_104966a0(*(int*)(param_1 + 0x54), param_1 + 0xec, 0, param_3);
        return;
    }
    FUN_104966a0(*(int*)(param_1 + 0x58), param_1 + 300, 0, param_3);
}

/* ===========================================================================
   MdtContactParams — type
=========================================================================== */

/*
 * FUN_104949e0 — SetContactType(params, type).
 *
 * Validates and stores the contact friction model: 0=no friction, 1=box,
 * 2=friction cone.  Unknown values emit a warning and fall through to 0.
 * Retail: 69 bytes.
 */
IMPL_APPROX("String address of warning message differs from retail; logic is identical")
void FUN_104949e0(int* param_1, int param_2)
{
    if (param_2 != 0)
    {
        if (param_2 == 1) { *param_1 = 1; return; }
        if (param_2 == 2) { *param_1 = 2; return; }
        FUN_104ee170(0xc, "Unknown Contact Type: defaulting to no friction");
    }
    *param_1 = 0;
}

/* ===========================================================================
   MdtContactParams — normal-direction parameters
=========================================================================== */

/*
 * FUN_10494ad0 — SetBothNormalParams(params, value).
 *
 * Delegates to the two normal-direction sub-setters FUN_10494a30 and
 * FUN_10494a80 (primary and secondary normal restitution slots).
 * Retail: 29 bytes.
 */
IMPL_MATCH("Engine.dll", 0x194ad0)
void FUN_10494ad0(int param_1, int param_2)
{
    FUN_10494a30(param_1, param_2);
    FUN_10494a80(param_1, param_2);
}

/*
 * FUN_10494b50 — SetSoftness(params, value).
 *
 * Clamps negative values to 0 (with a warning), stores the value at +0x18,
 * and sets/clears bit 2 of the flags word at +0x0c based on whether the
 * value is essentially zero (< 1e-6).
 * Retail: 91 bytes.
 */
IMPL_APPROX("String address of warning message differs from retail; logic is identical")
void FUN_10494b50(int param_1, float param_2)
{
    if (param_2 < 0.0f)
    {
        FUN_104ee170(0xc, "MdtContactParamsSetSoftness: Negative value clamped to 0.");
        param_2 = 0.0f;
    }
    *(float*)(param_1 + 0x18) = param_2;
    if (fabsf(param_2) < 1e-6f)
    {
        *(unsigned int*)(param_1 + 0x0c) |= 4u;
        return;
    }
    *(unsigned int*)(param_1 + 0x0c) &= ~4u;
}

/*
 * FUN_10494bb0 — SetDamping(params, value).
 *
 * Stores value at +0x1c and sets/clears bit 3 of flags at +0x0c based on
 * whether the damping is essentially zero.
 * Retail: 51 bytes.
 */
IMPL_MATCH("Engine.dll", 0x194bb0)
void FUN_10494bb0(int param_1, float param_2)
{
    *(float*)(param_1 + 0x1c) = param_2;
    if (fabsf(param_2) < 1e-6f)
    {
        *(unsigned int*)(param_1 + 0x0c) |= 8u;
        return;
    }
    *(unsigned int*)(param_1 + 0x0c) &= ~8u;
}

/* ===========================================================================
   MdtContactParams — friction parameters
=========================================================================== */

/*
 * FUN_10494cb0 — SetBothFriction(params, value).
 *
 * Delegates to FUN_10494bf0 and FUN_10494c50 (primary and secondary friction
 * sub-setters that mirror the pattern of FUN_10494cd0).
 * Retail: 29 bytes.
 */
IMPL_MATCH("Engine.dll", 0x194cb0)
void FUN_10494cb0(int param_1, float param_2)
{
    FUN_10494bf0(param_1, param_2);
    FUN_10494c50(param_1, param_2);
}

/*
 * FUN_10494cd0 — SetFriction(params, value).
 *
 * Clamps negative values to 0 (with a warning) then writes to both the
 * primary friction slot (+0x20) and secondary friction slot (+0x2c).
 * Retail: 55 bytes.
 */
IMPL_APPROX("String address of warning message differs from retail; logic is identical")
void FUN_10494cd0(int param_1, float param_2)
{
    if (param_2 < 0.0f)
    {
        FUN_104ee170(0xc, "MdtContactParamsSetFriction: Negative value clamped to 0.");
        param_2 = 0.0f;
    }
    *(float*)(param_1 + 0x20) = param_2;
    *(float*)(param_1 + 0x2c) = param_2;
}

/*
 * FUN_10494d10 — SetSlip(params, value).
 *
 * Clamps negative slip to 0 (with a warning) then writes to both the primary
 * slip slot (+0x24) and secondary slip slot (+0x30).
 * Retail: 55 bytes.
 */
IMPL_APPROX("String address of warning message differs from retail; logic is identical")
void FUN_10494d10(int param_1, float param_2)
{
    if (param_2 < 0.0f)
    {
        FUN_104ee170(0xc, "MdtContactParamsSetPrimarySlip: Negative value clamped to 0.");
        param_2 = 0.0f;
    }
    *(float*)(param_1 + 0x24) = param_2;
    *(float*)(param_1 + 0x30) = param_2;
}
