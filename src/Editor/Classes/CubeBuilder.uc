//=============================================================================
// CubeBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
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
	if(__NFUN_150__(i, 2))
	{
		j = -1;
		J0x2E:

		// End:0xAB [Loop If]
		if(__NFUN_150__(j, 2))
		{
			k = -1;
			J0x45:

			// End:0x9F [Loop If]
			if(__NFUN_150__(k, 2))
			{
				Vertex3f(__NFUN_172__(__NFUN_171__(float(i), dx), float(2)), __NFUN_172__(__NFUN_171__(float(j), dy), float(2)), __NFUN_172__(__NFUN_171__(float(k), dz), float(2)));
				__NFUN_161__(k, 2);
				// [Loop Continue]
				goto J0x45;
			}
			__NFUN_161__(j, 2);
			// [Loop Continue]
			goto J0x2E;
		}
		__NFUN_161__(i, 2);
		// [Loop Continue]
		goto J0x17;
	}
	// End:0x282
	if(_tessellated)
	{
		Poly3i(direction, __NFUN_146__(N, 0), __NFUN_146__(N, 1), __NFUN_146__(N, 3));
		Poly3i(direction, __NFUN_146__(N, 0), __NFUN_146__(N, 3), __NFUN_146__(N, 2));
		Poly3i(direction, __NFUN_146__(N, 2), __NFUN_146__(N, 3), __NFUN_146__(N, 7));
		Poly3i(direction, __NFUN_146__(N, 2), __NFUN_146__(N, 7), __NFUN_146__(N, 6));
		Poly3i(direction, __NFUN_146__(N, 6), __NFUN_146__(N, 7), __NFUN_146__(N, 5));
		Poly3i(direction, __NFUN_146__(N, 6), __NFUN_146__(N, 5), __NFUN_146__(N, 4));
		Poly3i(direction, __NFUN_146__(N, 4), __NFUN_146__(N, 5), __NFUN_146__(N, 1));
		Poly3i(direction, __NFUN_146__(N, 4), __NFUN_146__(N, 1), __NFUN_146__(N, 0));
		Poly3i(direction, __NFUN_146__(N, 3), __NFUN_146__(N, 1), __NFUN_146__(N, 5));
		Poly3i(direction, __NFUN_146__(N, 3), __NFUN_146__(N, 5), __NFUN_146__(N, 7));
		Poly3i(direction, __NFUN_146__(N, 0), __NFUN_146__(N, 2), __NFUN_146__(N, 6));
		Poly3i(direction, __NFUN_146__(N, 0), __NFUN_146__(N, 6), __NFUN_146__(N, 4));		
	}
	else
	{
		Poly4i(direction, __NFUN_146__(N, 0), __NFUN_146__(N, 1), __NFUN_146__(N, 3), __NFUN_146__(N, 2));
		Poly4i(direction, __NFUN_146__(N, 2), __NFUN_146__(N, 3), __NFUN_146__(N, 7), __NFUN_146__(N, 6));
		Poly4i(direction, __NFUN_146__(N, 6), __NFUN_146__(N, 7), __NFUN_146__(N, 5), __NFUN_146__(N, 4));
		Poly4i(direction, __NFUN_146__(N, 4), __NFUN_146__(N, 5), __NFUN_146__(N, 1), __NFUN_146__(N, 0));
		Poly4i(direction, __NFUN_146__(N, 3), __NFUN_146__(N, 1), __NFUN_146__(N, 5), __NFUN_146__(N, 7));
		Poly4i(direction, __NFUN_146__(N, 0), __NFUN_146__(N, 2), __NFUN_146__(N, 6), __NFUN_146__(N, 4));
	}
	return;
}

event bool Build()
{
	// End:0x32
	if(__NFUN_132__(__NFUN_132__(__NFUN_178__(Height, float(0)), __NFUN_178__(Width, float(0))), __NFUN_178__(Breadth, float(0))))
	{
		return BadParameters();
	}
	// End:0x75
	if(__NFUN_130__(Hollow, __NFUN_132__(__NFUN_132__(__NFUN_178__(Height, WallThickness), __NFUN_178__(Width, WallThickness)), __NFUN_178__(Breadth, WallThickness))))
	{
		return BadParameters();
	}
	// End:0xD7
	if(__NFUN_130__(Hollow, Tessellated))
	{
		return BadParameters("The 'Tessellated' option can't be specified with the 'Hollow' option.");
	}
	BeginBrush(false, GroupName);
	BuildCube(1, Breadth, Width, Height, Tessellated);
	// End:0x13D
	if(Hollow)
	{
		BuildCube(-1, __NFUN_175__(Breadth, WallThickness), __NFUN_175__(Width, WallThickness), __NFUN_175__(Height, WallThickness), Tessellated);
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
