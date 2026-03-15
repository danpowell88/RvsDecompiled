//=============================================================================
// CubeBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// CubeBuilder: Builds a 3D cube brush.
//=============================================================================
class CubeBuilder extends BrushBuilder;

var() bool Hollow;
var() bool Tessellated;
var() float Height;
// NEW IN 1.60
var() float Width;
// NEW IN 1.60
var() float Breadth;
var() float WallThickness;
var() name GroupName;

function BuildCube(int direction, float dx, float dy, float dz, bool _tessellated)
{
	local int N, i, j, k;

	N = GetVertexCount();
	i = -1;
	J0x17:

	// End:0xB7 [Loop If]
	if((i < 2))
	{
		j = -1;
		J0x2E:

		// End:0xAB [Loop If]
		if((j < 2))
		{
			k = -1;
			J0x45:

			// End:0x9F [Loop If]
			if((k < 2))
			{
				Vertex3f(((float(i) * dx) / float(2)), ((float(j) * dy) / float(2)), ((float(k) * dz) / float(2)));
				(k += 2);
				// [Loop Continue]
				goto J0x45;
			}
			(j += 2);
			// [Loop Continue]
			goto J0x2E;
		}
		(i += 2);
		// [Loop Continue]
		goto J0x17;
	}
	// End:0x282
	if(_tessellated)
	{
		Poly3i(direction, (N + 0), (N + 1), (N + 3));
		Poly3i(direction, (N + 0), (N + 3), (N + 2));
		Poly3i(direction, (N + 2), (N + 3), (N + 7));
		Poly3i(direction, (N + 2), (N + 7), (N + 6));
		Poly3i(direction, (N + 6), (N + 7), (N + 5));
		Poly3i(direction, (N + 6), (N + 5), (N + 4));
		Poly3i(direction, (N + 4), (N + 5), (N + 1));
		Poly3i(direction, (N + 4), (N + 1), (N + 0));
		Poly3i(direction, (N + 3), (N + 1), (N + 5));
		Poly3i(direction, (N + 3), (N + 5), (N + 7));
		Poly3i(direction, (N + 0), (N + 2), (N + 6));
		Poly3i(direction, (N + 0), (N + 6), (N + 4));		
	}
	else
	{
		Poly4i(direction, (N + 0), (N + 1), (N + 3), (N + 2));
		Poly4i(direction, (N + 2), (N + 3), (N + 7), (N + 6));
		Poly4i(direction, (N + 6), (N + 7), (N + 5), (N + 4));
		Poly4i(direction, (N + 4), (N + 5), (N + 1), (N + 0));
		Poly4i(direction, (N + 3), (N + 1), (N + 5), (N + 7));
		Poly4i(direction, (N + 0), (N + 2), (N + 6), (N + 4));
	}
	return;
}

event bool Build()
{
	// End:0x32
	if((((Height <= float(0)) || (Width <= float(0))) || (Breadth <= float(0))))
	{
		return BadParameters();
	}
	// End:0x75
	if((Hollow && (((Height <= WallThickness) || (Width <= WallThickness)) || (Breadth <= WallThickness))))
	{
		return BadParameters();
	}
	// End:0xD7
	if((Hollow && Tessellated))
	{
		return BadParameters("The 'Tessellated' option can't be specified with the 'Hollow' option.");
	}
	BeginBrush(false, GroupName);
	BuildCube(1, Breadth, Width, Height, Tessellated);
	// End:0x13D
	if(Hollow)
	{
		BuildCube(-1, (Breadth - WallThickness), (Width - WallThickness), (Height - WallThickness), Tessellated);
	}
	return EndBrush();
	return;
}

defaultproperties
{
	Height=256.0000000
	Width=256.0000000
	Breadth=256.0000000
	WallThickness=16.0000000
	GroupName="Cube"
	BitmapFilename="BBCube"
	ToolTip="Cube"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var h
