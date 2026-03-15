//=============================================================================
// CylinderBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// CylinderBuilder: Builds a 3D cylinder brush.
//=============================================================================
class CylinderBuilder extends BrushBuilder;

var() int Sides;
var() bool AlignToSide;
// NEW IN 1.60
var() bool Hollow;
var() float Height;
// NEW IN 1.60
var() float OuterRadius;
// NEW IN 1.60
var() float InnerRadius;
var() name GroupName;

function BuildCylinder(int direction, bool AlignToSide, int Sides, float Height, float Radius)
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

	// End:0xF0 [Loop If]
	if((i < Sides))
	{
		j = -1;
		J0x54:

		// End:0xE6 [Loop If]
		if((j < 2))
		{
			Vertex3f((Radius * Sin(((((2.0000000 * float(i)) + float(Ofs)) * 3.1415930) / float(Sides)))), (Radius * Cos(((((2.0000000 * float(i)) + float(Ofs)) * 3.1415930) / float(Sides)))), ((float(j) * Height) / float(2)));
			(j += 2);
			// [Loop Continue]
			goto J0x54;
		}
		(i++);
		// [Loop Continue]
		goto J0x3A;
	}
	i = 0;
	J0xF7:

	// End:0x191 [Loop If]
	if((i < Sides))
	{
		Poly4i(direction, (N + (i * 2)), ((N + (i * 2)) + 1), int((float(N) + (float(((i * 2) + 3)) % float((2 * Sides))))), int((float(N) + (float(((i * 2) + 2)) % float((2 * Sides))))), 'Wall');
		(i++);
		// [Loop Continue]
		goto J0xF7;
	}
	return;
}

function bool Build()
{
	local int i, j, k;

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
	BeginBrush(false, GroupName);
	BuildCylinder(1, AlignToSide, Sides, Height, OuterRadius);
	// End:0x19F
	if(Hollow)
	{
		BuildCylinder(-1, AlignToSide, Sides, Height, InnerRadius);
		j = -1;
		J0xC2:

		// End:0x19C [Loop If]
		if((j < 2))
		{
			i = 0;
			J0xD5:

			// End:0x190 [Loop If]
			if((i < Sides))
			{
				Poly4i(j, ((i * 2) + ((1 - j) / 2)), ((int((float((i + 1)) % float(Sides))) * 2) + ((1 - j) / 2)), (((int((float((i + 1)) % float(Sides))) * 2) + ((1 - j) / 2)) + (Sides * 2)), (((i * 2) + ((1 - j) / 2)) + (Sides * 2)), 'Cap');
				(i++);
				// [Loop Continue]
				goto J0xD5;
			}
			(j += 2);
			// [Loop Continue]
			goto J0xC2;
		}		
	}
	else
	{
		j = -1;
		J0x1AA:

		// End:0x215 [Loop If]
		if((j < 2))
		{
			PolyBegin(j, 'Cap');
			i = 0;
			J0x1CD:

			// End:0x203 [Loop If]
			if((i < Sides))
			{
				Polyi(((i * 2) + ((1 - j) / 2)));
				(i++);
				// [Loop Continue]
				goto J0x1CD;
			}
			PolyEnd();
			(j += 2);
			// [Loop Continue]
			goto J0x1AA;
		}
	}
	return EndBrush();
	return;
}

defaultproperties
{
	Sides=8
	AlignToSide=true
	Height=256.0000000
	OuterRadius=512.0000000
	InnerRadius=384.0000000
	GroupName="Cylinder"
	BitmapFilename="BBCylinder"
	ToolTip="Cylinder"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var w
