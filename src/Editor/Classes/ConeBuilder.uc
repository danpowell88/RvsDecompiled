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
		__NFUN_183__(Radius, __NFUN_188__(__NFUN_172__(3.1415930, float(Sides))));
		Ofs = 1;
	}
	i = 0;
	J0x3A:

	// End:0xBE [Loop If]
	if(__NFUN_150__(i, Sides))
	{
		Vertex3f(__NFUN_171__(Radius, __NFUN_187__(__NFUN_172__(__NFUN_171__(__NFUN_174__(__NFUN_171__(2.0000000, float(i)), float(Ofs)), 3.1415930), float(Sides)))), __NFUN_171__(Radius, __NFUN_188__(__NFUN_172__(__NFUN_171__(__NFUN_174__(__NFUN_171__(2.0000000, float(i)), float(Ofs)), 3.1415930), float(Sides)))), 0.0000000);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x3A;
	}
	Vertex3f(0.0000000, 0.0000000, Height);
	i = 0;
	J0xDA:

	// End:0x139 [Loop If]
	if(__NFUN_150__(i, Sides))
	{
		Poly3i(direction, __NFUN_146__(N, i), __NFUN_146__(N, Sides), int(__NFUN_174__(float(N), __NFUN_173__(float(__NFUN_146__(i, 1)), float(Sides)))), Item);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xDA;
	}
	return;
}

function bool Build()
{
	local int i;

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
	// End:0x87
	if(__NFUN_130__(Hollow, __NFUN_177__(CapHeight, Height)))
	{
		return BadParameters();
	}
	// End:0xB9
	if(__NFUN_130__(Hollow, __NFUN_130__(__NFUN_180__(CapHeight, Height), __NFUN_180__(InnerRadius, OuterRadius))))
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
		if(__NFUN_181__(OuterRadius, InnerRadius))
		{
			i = 0;
			J0x12A:

			// End:0x199 [Loop If]
			if(__NFUN_150__(i, Sides))
			{
				Poly4i(1, i, int(__NFUN_173__(float(__NFUN_146__(i, 1)), float(Sides))), int(__NFUN_174__(float(__NFUN_146__(Sides, 1)), __NFUN_173__(float(__NFUN_146__(i, 1)), float(Sides)))), __NFUN_146__(__NFUN_146__(Sides, 1), i), 'Bottom');
				__NFUN_165__(i);
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
		if(__NFUN_150__(i, Sides))
		{
			Polyi(i);
			__NFUN_165__(i);
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
