"""Add missing FColor methods to Engine.h.

These are standard Unreal Engine FColor utility methods that need
to be exported as part of Engine.dll (dllexport via ENGINE_API).
"""

import re

ENGINE_H = r"c:\Users\danpo\Desktop\rvs\src\engine\Engine.h"

# The old FColor class body - we'll replace the closing part
OLD = '''\tFColor( BYTE InR, BYTE InG, BYTE InB )
\t:\tR(InR), G(InG), B(InB), A(255) {}
\tFColor( BYTE InR, BYTE InG, BYTE InB, BYTE InA )
\t:\tR(InR), G(InG), B(InB), A(InA) {}
\tfriend FArchive& operator<< (FArchive &Ar, FColor &Color )
\t{
\t\treturn Ar << Color.R << Color.G << Color.B << Color.A;
\t}
\tUBOOL operator==( const FColor &C ) const
\t{
\t\treturn *(DWORD*)this == *(DWORD*)&C;
\t}
\tUBOOL operator!=( const FColor& C ) const
\t{
\t\treturn *(DWORD*)this != *(DWORD*)&C;
\t}
};'''

NEW = '''\tFColor( BYTE InR, BYTE InG, BYTE InB )
\t:\tR(InR), G(InG), B(InB), A(255) {}
\tFColor( BYTE InR, BYTE InG, BYTE InB, BYTE InA )
\t:\tR(InR), G(InG), B(InB), A(InA) {}
\tFColor( DWORD InColor )
\t{ *(DWORD*)this = InColor; }
\tFColor( const FPlane& P );

\t// Serialization
\tfriend FArchive& operator<< (FArchive &Ar, FColor &Color )
\t{
\t\treturn Ar << Color.R << Color.G << Color.B << Color.A;
\t}

\t// Comparison
\tUBOOL operator==( const FColor &C ) const
\t{
\t\treturn *(DWORD*)this == *(DWORD*)&C;
\t}
\tUBOOL operator!=( const FColor& C ) const
\t{
\t\treturn *(DWORD*)this != *(DWORD*)&C;
\t}

\t// Arithmetic
\tvoid operator+=( FColor C )
\t{
\t\tR = (BYTE)Min((INT)R + (INT)C.R, 255);
\t\tG = (BYTE)Min((INT)G + (INT)C.G, 255);
\t\tB = (BYTE)Min((INT)B + (INT)C.B, 255);
\t\tA = (BYTE)Min((INT)A + (INT)C.A, 255);
\t}

\t// Accessors
\tDWORD& DWColor()
\t{ return *(DWORD*)this; }
\tconst DWORD& DWColor() const
\t{ return *(const DWORD*)this; }
\tDWORD TrueColor() const
\t{ return *(const DWORD*)this; }
\tDWORD PS2DWColor()
\t{ return *(DWORD*)this; }

\t// Brightness
\tINT Brightness() const
\t{ return Max(Max((INT)R, (INT)G), (INT)B); }
\tFLOAT FBrightness() const
\t{ return Max(Max(R/255.f, G/255.f), B/255.f); }
\tFColor Brighten( INT Amount )
\t{
\t\treturn FColor( (BYTE)Clamp((INT)R+Amount,0,255), (BYTE)Clamp((INT)G+Amount,0,255), (BYTE)Clamp((INT)B+Amount,0,255), A );
\t}

\t// Conversions
\tFPlane Plane() const
\t{ return FPlane(R/255.f, G/255.f, B/255.f, A/255.f); }
\tFColor RedBlueSwap()
\t{ return FColor(B, G, R, A); }
\toperator DWORD() const
\t{ return *(const DWORD*)this; }
\toperator FPlane() const
\t{ return FPlane(R/255.f, G/255.f, B/255.f, A/255.f); }
\toperator FVector() const
\t{ return FVector(R/255.f, G/255.f, B/255.f); }

\t// High color
\tWORD HiColor555() const
\t{ return ((R>>3)<<10) | ((G>>3)<<5) | (B>>3); }
\tWORD HiColor565() const
\t{ return ((R>>3)<<11) | ((G>>2)<<5) | (B>>3); }
};'''

with open(ENGINE_H, 'r') as f:
    content = f.read()

if OLD not in content:
    print("ERROR: Could not find old FColor pattern in Engine.h!")
    exit(1)

content = content.replace(OLD, NEW)

with open(ENGINE_H, 'w') as f:
    f.write(content)

print("Patched FColor with 17 additional methods in Engine.h")
