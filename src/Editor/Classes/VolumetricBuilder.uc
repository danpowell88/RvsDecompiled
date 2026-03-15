//=============================================================================
// VolumetricBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// VolumetricBuilder: Builds a volumetric brush (criss-crossed sheets).
//=============================================================================
class VolumetricBuilder extends BrushBuilder;

var() int NumSheets;
var() float Height;
// NEW IN 1.60
var() float Radius;
var() name GroupName;

function BuildVolumetric(int direction, int NumSheets, float Height, float Radius)
{
	local int N, X, Y;
	local Rotator RotStep;
	local Vector vtx, NewVtx;

	N = GetVertexCount();
	RotStep.Yaw = (65536 / (NumSheets * 2));
	vtx.X = Radius;
	vtx.Z = (Height / float(2));
	X = 0;
	J0x54:

	// End:0xDD [Loop If]
	if((X < (NumSheets * 2)))
	{
		NewVtx = (vtx >> (RotStep * float(X)));
		Vertex3f(NewVtx.X, NewVtx.Y, NewVtx.Z);
		Vertex3f(NewVtx.X, NewVtx.Y, (NewVtx.Z - Height));
		(X++);
		// [Loop Continue]
		goto J0x54;
	}
	X = 0;
	J0xE4:

	// End:0x195 [Loop If]
	if((X < NumSheets))
	{
		Y = ((X * 2) + 1);
		// End:0x128
		if((Y >= (NumSheets * 2)))
		{
			(Y -= (NumSheets * 2));
		}
		Poly4i(direction, (N + (X * 2)), (N + Y), ((N + Y) + (NumSheets * 2)), ((N + (X * 2)) + (NumSheets * 2)), 'Sheets', 264);
		(X++);
		// [Loop Continue]
		goto J0xE4;
	}
	return;
}

function bool Build()
{
	// End:0x13
	if((NumSheets < 2))
	{
		return BadParameters();
	}
	// End:0x36
	if(((Height <= float(0)) || (Radius <= float(0))))
	{
		return BadParameters();
	}
	BeginBrush(true, GroupName);
	BuildVolumetric(1, NumSheets, Height, Radius);
	return EndBrush();
	return;
}

defaultproperties
{
	NumSheets=2
	Height=128.0000000
	Radius=64.0000000
	GroupName="Volumetric"
	BitmapFilename="BBVolumetric"
	ToolTip="Volumetric (Torches, Chains, etc)"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var s
