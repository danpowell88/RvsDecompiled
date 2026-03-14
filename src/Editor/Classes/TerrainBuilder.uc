//=============================================================================
// TerrainBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// TerrainBuilder: Builds a 3D cube brush, with a tessellated bottom.
//=============================================================================
class TerrainBuilder extends BrushBuilder;

var() int WidthSegments;  // How many breaks to have in each direction
// NEW IN 1.60
var() int DepthSegments;
var() float Height;
// NEW IN 1.60
var() float Width;
// NEW IN 1.60
var() float Breadth;
var() name GroupName;

function BuildTerrain(int direction, float dx, float dy, float dz, int WidthSeg, int DepthSeg)
{
	local int N, nbottom, ntop, i, j, k,
		X, Y, idx;

	local float WidthStep, DepthStep;

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
	Poly4i(direction, __NFUN_146__(N, 3), __NFUN_146__(N, 1), __NFUN_146__(N, 5), __NFUN_146__(N, 7), 'sky');
	nbottom = GetVertexCount();
	WidthStep = __NFUN_172__(dx, float(WidthSeg));
	DepthStep = __NFUN_172__(dy, float(DepthSeg));
	X = 0;
	J0x125:

	// End:0x1AD [Loop If]
	if(__NFUN_150__(X, __NFUN_146__(WidthSeg, 1)))
	{
		Y = 0;
		J0x13E:

		// End:0x1A3 [Loop If]
		if(__NFUN_150__(Y, __NFUN_146__(DepthSeg, 1)))
		{
			Vertex3f(__NFUN_175__(__NFUN_171__(WidthStep, float(X)), __NFUN_172__(dx, float(2))), __NFUN_175__(__NFUN_171__(DepthStep, float(Y)), __NFUN_172__(dy, float(2))), __NFUN_169__(__NFUN_172__(dz, float(2))));
			__NFUN_165__(Y);
			// [Loop Continue]
			goto J0x13E;
		}
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x125;
	}
	ntop = GetVertexCount();
	X = 0;
	J0x1C0:

	// End:0x246 [Loop If]
	if(__NFUN_150__(X, __NFUN_146__(WidthSeg, 1)))
	{
		Y = 0;
		J0x1D9:

		// End:0x23C [Loop If]
		if(__NFUN_150__(Y, __NFUN_146__(DepthSeg, 1)))
		{
			Vertex3f(__NFUN_175__(__NFUN_171__(WidthStep, float(X)), __NFUN_172__(dx, float(2))), __NFUN_175__(__NFUN_171__(DepthStep, float(Y)), __NFUN_172__(dy, float(2))), __NFUN_172__(dz, float(2)));
			__NFUN_165__(Y);
			// [Loop Continue]
			goto J0x1D9;
		}
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x1C0;
	}
	X = 0;
	J0x24D:

	// End:0x36A [Loop If]
	if(__NFUN_150__(X, WidthSeg))
	{
		Y = 0;
		J0x263:

		// End:0x360 [Loop If]
		if(__NFUN_150__(Y, DepthSeg))
		{
			Poly3i(__NFUN_143__(direction), __NFUN_146__(__NFUN_146__(nbottom, Y), __NFUN_144__(__NFUN_146__(DepthSeg, 1), X)), __NFUN_146__(__NFUN_146__(nbottom, Y), __NFUN_144__(__NFUN_146__(DepthSeg, 1), __NFUN_146__(X, 1))), __NFUN_146__(__NFUN_146__(__NFUN_146__(nbottom, 1), Y), __NFUN_144__(__NFUN_146__(DepthSeg, 1), __NFUN_146__(X, 1))), 'ground');
			Poly3i(__NFUN_143__(direction), __NFUN_146__(__NFUN_146__(nbottom, Y), __NFUN_144__(__NFUN_146__(DepthSeg, 1), X)), __NFUN_146__(__NFUN_146__(__NFUN_146__(nbottom, 1), Y), __NFUN_144__(__NFUN_146__(DepthSeg, 1), __NFUN_146__(X, 1))), __NFUN_146__(__NFUN_146__(__NFUN_146__(nbottom, 1), Y), __NFUN_144__(__NFUN_146__(DepthSeg, 1), X)), 'ground');
			__NFUN_165__(Y);
			// [Loop Continue]
			goto J0x263;
		}
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x24D;
	}
	X = 0;
	J0x371:

	// End:0x486 [Loop If]
	if(__NFUN_150__(X, WidthSeg))
	{
		Poly4i(__NFUN_143__(direction), __NFUN_146__(__NFUN_146__(nbottom, DepthSeg), __NFUN_144__(__NFUN_146__(DepthSeg, 1), X)), __NFUN_146__(__NFUN_146__(nbottom, DepthSeg), __NFUN_144__(__NFUN_146__(DepthSeg, 1), __NFUN_146__(X, 1))), __NFUN_146__(__NFUN_146__(ntop, DepthSeg), __NFUN_144__(__NFUN_146__(DepthSeg, 1), __NFUN_146__(X, 1))), __NFUN_146__(__NFUN_146__(ntop, DepthSeg), __NFUN_144__(__NFUN_146__(DepthSeg, 1), X)), 'sky');
		Poly4i(__NFUN_143__(direction), __NFUN_146__(nbottom, __NFUN_144__(__NFUN_146__(DepthSeg, 1), __NFUN_146__(X, 1))), __NFUN_146__(nbottom, __NFUN_144__(__NFUN_146__(DepthSeg, 1), X)), __NFUN_146__(ntop, __NFUN_144__(__NFUN_146__(DepthSeg, 1), X)), __NFUN_146__(ntop, __NFUN_144__(__NFUN_146__(DepthSeg, 1), __NFUN_146__(X, 1))), 'sky');
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x371;
	}
	Y = 0;
	J0x48D:

	// End:0x57A [Loop If]
	if(__NFUN_150__(Y, DepthSeg))
	{
		Poly4i(__NFUN_143__(direction), __NFUN_146__(nbottom, Y), __NFUN_146__(nbottom, __NFUN_146__(Y, 1)), __NFUN_146__(ntop, __NFUN_146__(Y, 1)), __NFUN_146__(ntop, Y), 'sky');
		Poly4i(__NFUN_143__(direction), __NFUN_146__(__NFUN_146__(nbottom, __NFUN_144__(__NFUN_146__(DepthSeg, 1), WidthSeg)), __NFUN_146__(Y, 1)), __NFUN_146__(__NFUN_146__(nbottom, __NFUN_144__(__NFUN_146__(DepthSeg, 1), WidthSeg)), Y), __NFUN_146__(__NFUN_146__(ntop, __NFUN_144__(__NFUN_146__(DepthSeg, 1), WidthSeg)), Y), __NFUN_146__(__NFUN_146__(ntop, __NFUN_144__(__NFUN_146__(DepthSeg, 1), WidthSeg)), __NFUN_146__(Y, 1)), 'sky');
		__NFUN_165__(Y);
		// [Loop Continue]
		goto J0x48D;
	}
	return;
}

event bool Build()
{
	// End:0x4C
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_178__(Height, float(0)), __NFUN_178__(Width, float(0))), __NFUN_178__(Breadth, float(0))), __NFUN_152__(WidthSegments, 0)), __NFUN_152__(DepthSegments, 0)))
	{
		return BadParameters();
	}
	BeginBrush(false, GroupName);
	BuildTerrain(1, Breadth, Width, Height, WidthSegments, DepthSegments);
	return EndBrush();
	return;
}

defaultproperties
{
	WidthSegments=4
	DepthSegments=2
	Height=256.0000000
	Width=256.0000000
	Breadth=512.0000000
	GroupName="Terrain"
	BitmapFilename="BBTerrain"
	ToolTip="BSP Based Terrain"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var s
