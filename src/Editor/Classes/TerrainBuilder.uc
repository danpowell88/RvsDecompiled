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
	Poly4i(direction, (N + 3), (N + 1), (N + 5), (N + 7), 'sky');
	nbottom = GetVertexCount();
	WidthStep = (dx / float(WidthSeg));
	DepthStep = (dy / float(DepthSeg));
	X = 0;
	J0x125:

	// End:0x1AD [Loop If]
	if((X < (WidthSeg + 1)))
	{
		Y = 0;
		J0x13E:

		// End:0x1A3 [Loop If]
		if((Y < (DepthSeg + 1)))
		{
			Vertex3f(((WidthStep * float(X)) - (dx / float(2))), ((DepthStep * float(Y)) - (dy / float(2))), (-(dz / float(2))));
			(Y++);
			// [Loop Continue]
			goto J0x13E;
		}
		(X++);
		// [Loop Continue]
		goto J0x125;
	}
	ntop = GetVertexCount();
	X = 0;
	J0x1C0:

	// End:0x246 [Loop If]
	if((X < (WidthSeg + 1)))
	{
		Y = 0;
		J0x1D9:

		// End:0x23C [Loop If]
		if((Y < (DepthSeg + 1)))
		{
			Vertex3f(((WidthStep * float(X)) - (dx / float(2))), ((DepthStep * float(Y)) - (dy / float(2))), (dz / float(2)));
			(Y++);
			// [Loop Continue]
			goto J0x1D9;
		}
		(X++);
		// [Loop Continue]
		goto J0x1C0;
	}
	X = 0;
	J0x24D:

	// End:0x36A [Loop If]
	if((X < WidthSeg))
	{
		Y = 0;
		J0x263:

		// End:0x360 [Loop If]
		if((Y < DepthSeg))
		{
			Poly3i((-direction), ((nbottom + Y) + ((DepthSeg + 1) * X)), ((nbottom + Y) + ((DepthSeg + 1) * (X + 1))), (((nbottom + 1) + Y) + ((DepthSeg + 1) * (X + 1))), 'ground');
			Poly3i((-direction), ((nbottom + Y) + ((DepthSeg + 1) * X)), (((nbottom + 1) + Y) + ((DepthSeg + 1) * (X + 1))), (((nbottom + 1) + Y) + ((DepthSeg + 1) * X)), 'ground');
			(Y++);
			// [Loop Continue]
			goto J0x263;
		}
		(X++);
		// [Loop Continue]
		goto J0x24D;
	}
	X = 0;
	J0x371:

	// End:0x486 [Loop If]
	if((X < WidthSeg))
	{
		Poly4i((-direction), ((nbottom + DepthSeg) + ((DepthSeg + 1) * X)), ((nbottom + DepthSeg) + ((DepthSeg + 1) * (X + 1))), ((ntop + DepthSeg) + ((DepthSeg + 1) * (X + 1))), ((ntop + DepthSeg) + ((DepthSeg + 1) * X)), 'sky');
		Poly4i((-direction), (nbottom + ((DepthSeg + 1) * (X + 1))), (nbottom + ((DepthSeg + 1) * X)), (ntop + ((DepthSeg + 1) * X)), (ntop + ((DepthSeg + 1) * (X + 1))), 'sky');
		(X++);
		// [Loop Continue]
		goto J0x371;
	}
	Y = 0;
	J0x48D:

	// End:0x57A [Loop If]
	if((Y < DepthSeg))
	{
		Poly4i((-direction), (nbottom + Y), (nbottom + (Y + 1)), (ntop + (Y + 1)), (ntop + Y), 'sky');
		Poly4i((-direction), ((nbottom + ((DepthSeg + 1) * WidthSeg)) + (Y + 1)), ((nbottom + ((DepthSeg + 1) * WidthSeg)) + Y), ((ntop + ((DepthSeg + 1) * WidthSeg)) + Y), ((ntop + ((DepthSeg + 1) * WidthSeg)) + (Y + 1)), 'sky');
		(Y++);
		// [Loop Continue]
		goto J0x48D;
	}
	return;
}

event bool Build()
{
	// End:0x4C
	if((((((Height <= float(0)) || (Width <= float(0))) || (Breadth <= float(0))) || (WidthSegments <= 0)) || (DepthSegments <= 0)))
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
