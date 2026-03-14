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
		__NFUN_183__(Radius, __NFUN_188__(__NFUN_172__(3.1415930, float(Sides))));
		Ofs = 1;
	}
	i = 0;
	J0x3A:

	// End:0xF0 [Loop If]
	if(__NFUN_150__(i, Sides))
	{
		j = -1;
		J0x54:

		// End:0xE6 [Loop If]
		if(__NFUN_150__(j, 2))
		{
			Vertex3f(__NFUN_171__(Radius, __NFUN_187__(__NFUN_172__(__NFUN_171__(__NFUN_174__(__NFUN_171__(2.0000000, float(i)), float(Ofs)), 3.1415930), float(Sides)))), __NFUN_171__(Radius, __NFUN_188__(__NFUN_172__(__NFUN_171__(__NFUN_174__(__NFUN_171__(2.0000000, float(i)), float(Ofs)), 3.1415930), float(Sides)))), __NFUN_172__(__NFUN_171__(float(j), Height), float(2)));
			__NFUN_161__(j, 2);
			// [Loop Continue]
			goto J0x54;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x3A;
	}
	i = 0;
	J0xF7:

	// End:0x191 [Loop If]
	if(__NFUN_150__(i, Sides))
	{
		Poly4i(direction, __NFUN_146__(N, __NFUN_144__(i, 2)), __NFUN_146__(__NFUN_146__(N, __NFUN_144__(i, 2)), 1), int(__NFUN_174__(float(N), __NFUN_173__(float(__NFUN_146__(__NFUN_144__(i, 2), 3)), float(__NFUN_144__(2, Sides))))), int(__NFUN_174__(float(N), __NFUN_173__(float(__NFUN_146__(__NFUN_144__(i, 2), 2)), float(__NFUN_144__(2, Sides))))), 'Wall');
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xF7;
	}
	return;
}

function bool Build()
{
	local int i, j, k;

	// End:0x13
	if(__NFUN_150__(Sides, 3))
	{
		return BadParameters();
	}
	// End:0x36
	if(__NFUN_132__(__NFUN_178__(Height, float(0)), __NFUN_178__(OuterRadius, float(0))))
	{
		return BadParameters();
	}
	// End:0x66
	if(__NFUN_130__(Hollow, __NFUN_132__(__NFUN_178__(InnerRadius, float(0)), __NFUN_179__(InnerRadius, OuterRadius))))
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
		if(__NFUN_150__(j, 2))
		{
			i = 0;
			J0xD5:

			// End:0x190 [Loop If]
			if(__NFUN_150__(i, Sides))
			{
				Poly4i(j, __NFUN_146__(__NFUN_144__(i, 2), __NFUN_145__(__NFUN_147__(1, j), 2)), __NFUN_146__(__NFUN_144__(int(__NFUN_173__(float(__NFUN_146__(i, 1)), float(Sides))), 2), __NFUN_145__(__NFUN_147__(1, j), 2)), __NFUN_146__(__NFUN_146__(__NFUN_144__(int(__NFUN_173__(float(__NFUN_146__(i, 1)), float(Sides))), 2), __NFUN_145__(__NFUN_147__(1, j), 2)), __NFUN_144__(Sides, 2)), __NFUN_146__(__NFUN_146__(__NFUN_144__(i, 2), __NFUN_145__(__NFUN_147__(1, j), 2)), __NFUN_144__(Sides, 2)), 'Cap');
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0xD5;
			}
			__NFUN_161__(j, 2);
			// [Loop Continue]
			goto J0xC2;
		}		
	}
	else
	{
		j = -1;
		J0x1AA:

		// End:0x215 [Loop If]
		if(__NFUN_150__(j, 2))
		{
			PolyBegin(j, 'Cap');
			i = 0;
			J0x1CD:

			// End:0x203 [Loop If]
			if(__NFUN_150__(i, Sides))
			{
				Polyi(__NFUN_146__(__NFUN_144__(i, 2), __NFUN_145__(__NFUN_147__(1, j), 2)));
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x1CD;
			}
			PolyEnd();
			__NFUN_161__(j, 2);
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
