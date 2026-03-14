#pragma once
/*=============================================================================
    MeTypes.h - MathEngine/Karma physics SDK type definitions.

    Karma (MathEngine Ltd) was statically compiled into Engine.dll.  All type
    information is recovered from Ghidra decompilation of the .text section in
    the virtual-address range 0x10490000-0x10510000.

    In Ghidra output, opaque Karma handles appear as plain 'int' parameters
    because the SDK was compiled without debug information.  The typedefs below
    restore the semantic names while keeping the same 4-byte representation.
=============================================================================*/

// ---------------------------------------------------------------------------
// Scalar primitive
// ---------------------------------------------------------------------------
typedef float MeReal;       /* MathEngine single-precision float */

// ---------------------------------------------------------------------------
// Opaque body / world / constraint handles
// (32-bit pointer-sized values stored as int in Ghidra decompilation)
// ---------------------------------------------------------------------------
typedef int MdtBody;            /* handle to an MdtBody instance   */
typedef int MdtWorld;           /* handle to an MdtWorld instance  */
typedef int MdtContactGroup;    /* handle to an MdtContactGroup    */
typedef int MdtConstraint;      /* handle to a generic constraint  */
typedef int McdModel;           /* handle to an McdModel           */
typedef int McdGeometry;        /* handle to an McdGeometry        */

// ---------------------------------------------------------------------------
// Struct forward declarations
// (pointer-typed return values visible in Engine class virtual tables)
// ---------------------------------------------------------------------------
struct MdtBaseConstraint;   /* AKConstraint::getKConstraint() return type */
struct _McdModel;           /* AKActor / AActor getKModel() return type   */
struct _KarmaGlobals;       /* KGData — the global MathEngine world state */
struct _KarmaTriListData;   /* static mesh collision geometry             */
