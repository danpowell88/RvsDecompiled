//=============================================================================
// ConeBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ConeBuilder: Builds a 3D cone brush, compatible with cylinder of same size.
//=============================================================================
class ConeBuilder extends BrushBuilder;

var() int Sides;
var() bool AlignToSide;
// NEW IN 1.60
var() bool Hollow;
var() float Height;
// NEW IN 1.60
var() float CapHeight;
// NEW IN 1.60
var() float OuterRadius;
// NEW IN 1.60
var() float InnerRadius;
var() name GroupName;

function BuildCone(int direction, bool AlignToSide, int Sides, float Height, float Radius, name Item)
{
	local int N, i, j, q, Ofs;

	N = GetVertexCount();
	// End:0x33
	if(AlignToSide)
	{
		(Radius /= Cos((3.1415930 / float(Sides))));
		Ofs = 1;
	}
	i = 0;
	J0x3A:

	// End:0xBE [Loop If]
	if((i < Sides))
	{
		Vertex3f((Radius * Sin(((((2.0000000 * float(i)) + float(Ofs)) * 3.1415930) / float(Sides)))), (Radius * Cos(((((2.0000000 * float(i)) + float(Ofs)) * 3.1415930) / float(Sides)))), 0.0000000);
		(i++);
		// [Loop Continue]
		goto J0x3A;
	}
	Vertex3f(0.0000000, 0.0000000, Height);
	i = 0;
	J0xDA:

	// End:0x139 [Loop If]
	if((i < Sides))
	{
		Poly3i(direction, (N + i), (N + Sides), int((float(N) + (float((i + 1)) % float(Sides)))), Item);
		(i++);
		// [Loop Continue]
		goto J0xDA;
	}
	return;
}

function bool Build()
{
	local int i;

	// End:0x13
	if((Sides < 3))
	{
		return BadParameters();
	}
	// End:0x36
	if(((Height <= float(0)) || (OuterRadius <= float(0))))
	{
		return BadParameters();
	}
	// End:0x66
	if((Hollow && ((InnerRadius <= float(0)) || (InnerRadius >= OuterRadius))))
	{
		return BadParameters();
	}
	// End:0x87
	if((Hollow && (CapHeight > Height)))
	{
		return BadParameters();
	}
	// End:0xB9
	if((Hollow && ((CapHeight == Height) && (InnerRadius == OuterRadius))))
	{
		return BadParameters();
	}
	BeginBrush(false, GroupName);
	BuildCone(1, AlignToSide, Sides, Height, OuterRadius, 'Top');
	// End:0x19C
	if(Hollow)
	{
		BuildCone(-1, AlignToSide, Sides, CapHeight, InnerRadius, 'Cap');
		// End:0x199
		if((OuterRadius != InnerRadius))
		{
			i = 0;
			J0x12A:

			// End:0x199 [Loop If]
			if((i < Sides))
			{
				Poly4i(1, i, int((float((i + 1)) % float(Sides))), int((float((Sides + 1)) + (float((i + 1)) % float(Sides)))), ((Sides + 1) + i), 'Bottom');
				(i++);
				// [Loop Continue]
				goto J0x12A;
			}
		}		
	}
	else
	{
		PolyBegin(1, 'Bottom');
		i = 0;
		J0x1AF:

		// End:0x1D3 [Loop If]
		if((i < Sides))
		{
			Polyi(i);
			(i++);
			// [Loop Continue]
			goto J0x1AF;
		}
		PolyEnd();
	}
	return EndBrush();
	return;
}

defaultproperties
{
	Sides=8
	AlignToSide=true
	Height=256.0000000
	CapHeight=256.0000000
	OuterRadius=512.0000000
	InnerRadius=384.0000000
	GroupName="Cone"
	BitmapFilename="BBCone"
	ToolTip="Cone"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var w
