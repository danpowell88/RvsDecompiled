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
	RotStep.Yaw = __NFUN_145__(65536, __NFUN_144__(NumSheets, 2));
	vtx.X = Radius;
	vtx.Z = __NFUN_172__(Height, float(2));
	X = 0;
	J0x54:

	// End:0xDD [Loop If]
	if(__NFUN_150__(X, __NFUN_144__(NumSheets, 2)))
	{
		NewVtx = __NFUN_276__(vtx, __NFUN_287__(RotStep, float(X)));
		Vertex3f(NewVtx.X, NewVtx.Y, NewVtx.Z);
		Vertex3f(NewVtx.X, NewVtx.Y, __NFUN_175__(NewVtx.Z, Height));
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x54;
	}
	X = 0;
	J0xE4:

	// End:0x195 [Loop If]
	if(__NFUN_150__(X, NumSheets))
	{
		Y = __NFUN_146__(__NFUN_144__(X, 2), 1);
		// End:0x128
		if(__NFUN_153__(Y, __NFUN_144__(NumSheets, 2)))
		{
			__NFUN_162__(Y, __NFUN_144__(NumSheets, 2));
		}
		Poly4i(direction, __NFUN_146__(N, __NFUN_144__(X, 2)), __NFUN_146__(N, Y), __NFUN_146__(__NFUN_146__(N, Y), __NFUN_144__(NumSheets, 2)), __NFUN_146__(__NFUN_146__(N, __NFUN_144__(X, 2)), __NFUN_144__(NumSheets, 2)), 'Sheets', 264);
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0xE4;
	}
	return;
}

function bool Build()
{
	// End:0x13
	if(__NFUN_150__(NumSheets, 2))
	{
		return BadParameters();
	}
	// End:0x36
	if(__NFUN_132__(__NFUN_178__(Height, float(0)), __NFUN_178__(Radius, float(0))))
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
