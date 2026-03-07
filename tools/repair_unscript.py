#!/usr/bin/env python3
"""
repair_unscript.py - Fix corruption in UnScript.cpp

Multiple prior edit sessions left interleaved/garbled text in several zones.
This script surgically replaces the corrupted regions with clean code.
"""

import re
import os

FILE = os.path.join('src', 'core', 'UnScript.cpp')

with open(FILE, 'r', encoding='utf-8') as f:
    lines = f.readlines()

original_count = len(lines)
print(f"Read {original_count} lines from {FILE}")

# === ZONE 1: Lines after execQuatInvert close through State/enable section ===
zone1_start = None
for i in range(len(lines)):
    if 'FQuat(-A.X,-A.Y,-A.Z,A.W)' in lines[i]:
        # Find the closing } of execQuatInvert (may be garbled)
        for j in range(i+1, min(i+5, len(lines))):
            stripped = lines[j].strip()
            if stripped.startswith('unguardexecSlow'):
                continue
            if stripped.startswith('}'):
                zone1_start = j  # This } line (garbled or not) - we replace from here
                break
        break

# Find the State/enable/disable section header
zone1_end = None
for i in range(len(lines)):
    if 'State/enable/disable functions' in lines[i]:
        # The /*--- line is i-1, blank line before that is i-2
        zone1_end = i - 1  # start of /*--- comment
        break

if zone1_start is None or zone1_end is None:
    print(f"ERROR: Could not find zone boundaries (start={zone1_start}, end={zone1_end})")
    exit(1)

print(f"Zone 1: lines {zone1_start+1}-{zone1_end} (corrupted quat/interp/dynarray/object section)")

ZONE1_REPLACEMENT = r"""}

void UObject::execQuatRotateVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execQuatRotateVector);
	P_GET_STRUCT(FQuat,Q);
	P_GET_VECTOR(V);
	// Rotate vector V by quaternion Q: Q * V * Q^-1.
	FQuat VQ(V.X, V.Y, V.Z, 0.f);
	FQuat QInv(-Q.X, -Q.Y, -Q.Z, Q.W);
	FQuat R = Q * VQ * QInv;
	*(FVector*)Result = FVector(R.X, R.Y, R.Z);
	unguardexecSlow;
}

void UObject::execQuatFindBetween( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execQuatFindBetween);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	// Find quaternion that rotates unit vector A to unit vector B.
	A = A.SafeNormal();
	B = B.SafeNormal();
	FVector Cross = A ^ B;
	FLOAT Dot = A | B;
	FLOAT W = appSqrt((A | A) * (B | B)) + Dot;
	FQuat R(Cross.X, Cross.Y, Cross.Z, W);
	FLOAT Size = appSqrt(R.X*R.X + R.Y*R.Y + R.Z*R.Z + R.W*R.W);
	if( Size > SMALL_NUMBER )
	{
		FLOAT InvSize = 1.f / Size;
		R.X *= InvSize; R.Y *= InvSize; R.Z *= InvSize; R.W *= InvSize;
	}
	*(FQuat*)Result = R;
	unguardexecSlow;
}

void UObject::execQuatFromAxisAndAngle( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execQuatFromAxisAndAngle);
	P_GET_VECTOR(Axis);
	P_GET_FLOAT(Angle);
	*(FQuat*)Result = FQuat::AngAxisToFQuat(Axis, Angle);
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	InterpCurve functions.
-----------------------------------------------------------------------------*/

void UObject::execInterpCurveEval( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execInterpCurveEval);
	P_GET_STRUCT(FInterpCurve,Curve);
	P_GET_FLOAT(Input);
	*(FLOAT*)Result = Curve.Eval( Input );
	unguardexecSlow;
}

void UObject::execInterpCurveGetInputDomain( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execInterpCurveGetInputDomain);
	P_GET_STRUCT(FInterpCurve,Curve);
	P_GET_FLOAT_REF(Min);
	P_GET_FLOAT_REF(Max);
	if( Curve.Points.Num() > 0 )
	{
		*Min = Curve.Points(0).InVal;
		*Max = Curve.Points(Curve.Points.Num()-1).InVal;
	}
	else
	{
		*Min = 0.f;
		*Max = 0.f;
	}
	unguardexecSlow;
}

void UObject::execInterpCurveGetOutputRange( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execInterpCurveGetOutputRange);
	P_GET_STRUCT(FInterpCurve,Curve);
	P_GET_FLOAT_REF(Min);
	P_GET_FLOAT_REF(Max);
	*Min = +BIG_NUMBER;
	*Max = -BIG_NUMBER;
	for( INT i=0; i<Curve.Points.Num(); i++ )
	{
		if( Curve.Points(i).OutVal < *Min ) *Min = Curve.Points(i).OutVal;
		if( Curve.Points(i).OutVal > *Max ) *Max = Curve.Points(i).OutVal;
	}
	if( Curve.Points.Num() == 0 )
	{
		*Min = 0.f;
		*Max = 0.f;
	}
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	Dynamic array operations.
-----------------------------------------------------------------------------*/

void UObject::execDynArrayLength( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDynArrayLength);
	GProperty = NULL;
	Stack.Step( Stack.Object, NULL );
	if( GPropAddr )
	{
		FArray* Array = (FArray*)GPropAddr;
		*(INT*)Result = Array->Num();
	}
	else
	{
		*(INT*)Result = 0;
	}
	unguardexecSlow;
}

void UObject::execDynArrayInsert( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDynArrayInsert);
	GProperty = NULL;
	Stack.Step( Stack.Object, NULL );
	P_GET_INT(Index);
	P_GET_INT(Count);
	if( GPropAddr && GProperty )
	{
		UArrayProperty* ArrayProp = CastChecked<UArrayProperty>( GProperty );
		FArray* Array = (FArray*)GPropAddr;
		Array->Insert( Index, Count, ArrayProp->Inner->ElementSize );
		appMemzero( (BYTE*)Array->GetData() + Index*ArrayProp->Inner->ElementSize, Count*ArrayProp->Inner->ElementSize );
	}
	unguardexecSlow;
}

void UObject::execDynArrayRemove( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDynArrayRemove);
	GProperty = NULL;
	Stack.Step( Stack.Object, NULL );
	P_GET_INT(Index);
	P_GET_INT(Count);
	if( GPropAddr && GProperty )
	{
		UArrayProperty* ArrayProp = CastChecked<UArrayProperty>( GProperty );
		FArray* Array = (FArray*)GPropAddr;
		for( INT i=Index; i<Index+Count && i<Array->Num(); i++ )
			ArrayProp->Inner->DestroyValue( (BYTE*)Array->GetData() + i*ArrayProp->Inner->ElementSize );
		Array->Remove( Index, Count, ArrayProp->Inner->ElementSize );
	}
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	Object functions.
-----------------------------------------------------------------------------*/

void UObject::execIsA( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIsA);
	P_GET_NAME(ClassName);
	UClass* TempClass;
	for( TempClass=GetClass(); TempClass; TempClass=(UClass*)TempClass->SuperField )
		if( TempClass->GetFName() == ClassName )
			break;
	*(DWORD*)Result = (TempClass!=NULL);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 197+106, execIsA );

void UObject::execClassIsChildOf( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execClassIsChildOf);
	P_GET_OBJECT(UClass,K);
	P_GET_OBJECT(UClass,C);
	*(DWORD*)Result = (K && C) ? K->IsChildOf(C) : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 258, execClassIsChildOf );

void UObject::execDynamicLoadObject( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDynamicLoadObject);
	P_GET_STR(ObjectName);
	P_GET_OBJECT(UClass,ObjectClass);
	P_GET_UBOOL_OPTX(bMayFail,0);
	*(UObject**)Result = StaticLoadObject( ObjectClass, NULL, *ObjectName, NULL, LOAD_NoWarn|(bMayFail?LOAD_Quiet:0), NULL );
	unguardexecSlow;
}
// REMOVED: bare native (iNative=0 in Core.u) -- no IMPLEMENT_FUNCTION macro.

void UObject::execFindObject( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFindObject);
	P_GET_STR(ObjectName);
	P_GET_OBJECT(UClass,ObjectClass);
	*(UObject**)Result = StaticFindObject( ObjectClass, NULL, *ObjectName );
	unguardexecSlow;
}

void UObject::execCalcDirection( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCalcDirection);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	FVector Dir = (B - A).SafeNormal();
	*(FLOAT*)Result = appAtan2(Dir.Y, Dir.X) * (32768.f / PI);
	unguardexecSlow;
}

void UObject::execCalcRotation( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCalcRotation);
	P_GET_VECTOR(Dir);
	*(FRotator*)Result = Dir.Rotation();
	unguardexecSlow;
}

void UObject::execCompress( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCompress);
	P_GET_STR(In);
	// String compression -- passthrough scaffold. TODO: reverse compression algorithm via Ghidra.
	*(FString*)Result = In;
	unguardexecSlow;
}

void UObject::execExpand( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execExpand);
	P_GET_STR(In);
	// String decompression -- passthrough scaffold. TODO: reverse decompression algorithm via Ghidra.
	*(FString*)Result = In;
	unguardexecSlow;
}

"""

# Apply Zone 1 replacement
new_lines = lines[:zone1_start]
for line in ZONE1_REPLACEMENT.split('\n'):
    new_lines.append(line + '\n')
new_lines.extend(lines[zone1_end:])

# Join for regex-based fixes of smaller corruption zones
content = ''.join(new_lines)

# === ZONE 2: After execGetPropertyText IMPLEMENT_FUNCTION, orphaned lines before execSetPropertyText ===
content = re.sub(
    r'(IMPLEMENT_FUNCTION\( UObject, 462, execGetPropertyText \);\n)'
    r'Private property access[^\n]*\n'
    r'[^\n]*Stack\.Step[^\n]*\n'
    r'(void UObject::execSetPropertyText)',
    r'\1\n\2',
    content
)

# === ZONE 3: After execSetPropertyText closing }, orphaned "I// File I/O scaffold..." lines ===
content = re.sub(
    r'(}\nI// File I/O scaffold[^\n]*\n\t\*\(INT\*\)Result = -1;\n)',
    '}\n\n',
    content
)

# === ZONE 4: GetPrivateProfile garbled section header ===
content = re.sub(
    r'/\*-+\n\tPriPrivate property access[^\n]*\n'
    r'[^\n]*evaluate the expression[^\n]*\n'
    r'[^\n]*no-op passthrough[^\n]*\n'
    r'[^\n]*Stack\.Step[^\n]*\n'
    r'[^\n]*d additions\.\n'
    r'-+\*/',
    '/*-----------------------------------------------------------------------------\n'
    '\tRavenshield INI profile functions.\n'
    '-----------------------------------------------------------------------------*/',
    content
)

# === ZONE 5: execGetPrivateProfileInt orphaned comments ===
content = re.sub(
    r'(P_GET_INT\(Default\);\n)'
    r'\t// Uses Win32 GetPrivateProfileInt\.\n'
    r'\t// Open file handle[^\n]*\n'
    r'\t// Mode:[^\n]*\n'
    r'(\t\*\(INT\*\)Result = -1;)',
    r'\1\2',
    content
)

with open(FILE, 'w', encoding='utf-8') as f:
    f.write(content)

final_lines = content.count('\n')
print(f"Wrote repaired file: {final_lines} lines (was {original_count})")
print("Done!")
