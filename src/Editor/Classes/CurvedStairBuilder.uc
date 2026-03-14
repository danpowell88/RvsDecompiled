//=============================================================================
// CurvedStairBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// CurvedStairBuilder: Builds a curved staircase.
//=============================================================================
class CurvedStairBuilder extends BrushBuilder;

var() int InnerRadius;
// NEW IN 1.60
var() int StepHeight;
// NEW IN 1.60
var() int StepWidth;
// NEW IN 1.60
var() int AngleOfCurve;
// NEW IN 1.60
var() int NumSteps;
// NEW IN 1.60
var() int AddToFirstStep;
var() bool CounterClockwise;
var() name GroupName;

function BuildCurvedStair(int direction)
{
	local Rotator RotStep;
	local Vector vtx, NewVtx;
	local int X, Z, InnerStart, OuterStart, BottomInnerStart, BottomOuterStart,
		Adjustment;

	RotStep.Yaw = __NFUN_145__(int(__NFUN_171__(float(65536), __NFUN_172__(float(AngleOfCurve), 360.0000000))), NumSteps);
	// End:0x55
	if(CounterClockwise)
	{
		__NFUN_159__(RotStep.Yaw, float(-1));
		__NFUN_159__(direction, float(-1));
	}
	InnerStart = GetVertexCount();
	vtx.X = float(InnerRadius);
	X = 0;
	J0x7A:

	// End:0x137 [Loop If]
	if(__NFUN_150__(X, __NFUN_146__(NumSteps, 1)))
	{
		// End:0xA5
		if(__NFUN_154__(X, 0))
		{
			Adjustment = AddToFirstStep;			
		}
		else
		{
			Adjustment = 0;
		}
		NewVtx = __NFUN_276__(vtx, __NFUN_287__(RotStep, float(X)));
		Vertex3f(NewVtx.X, NewVtx.Y, __NFUN_175__(vtx.Z, float(Adjustment)));
		__NFUN_184__(vtx.Z, float(StepHeight));
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x7A;
	}
	OuterStart = GetVertexCount();
	vtx.X = float(__NFUN_146__(InnerRadius, StepWidth));
	vtx.Z = 0.0000000;
	X = 0;
	J0x173:

	// End:0x230 [Loop If]
	if(__NFUN_150__(X, __NFUN_146__(NumSteps, 1)))
	{
		// End:0x19E
		if(__NFUN_154__(X, 0))
		{
			Adjustment = AddToFirstStep;			
		}
		else
		{
			Adjustment = 0;
		}
		NewVtx = __NFUN_276__(vtx, __NFUN_287__(RotStep, float(X)));
		Vertex3f(NewVtx.X, NewVtx.Y, __NFUN_175__(vtx.Z, float(Adjustment)));
		__NFUN_184__(vtx.Z, float(StepHeight));
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x173;
	}
	BottomInnerStart = GetVertexCount();
	vtx.X = float(InnerRadius);
	vtx.Z = 0.0000000;
	X = 0;
	J0x265:

	// End:0x2CB [Loop If]
	if(__NFUN_150__(X, __NFUN_146__(NumSteps, 1)))
	{
		NewVtx = __NFUN_276__(vtx, __NFUN_287__(RotStep, float(X)));
		Vertex3f(NewVtx.X, NewVtx.Y, __NFUN_175__(vtx.Z, float(AddToFirstStep)));
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x265;
	}
	BottomOuterStart = GetVertexCount();
	vtx.X = float(__NFUN_146__(InnerRadius, StepWidth));
	X = 0;
	J0x2F7:

	// End:0x35D [Loop If]
	if(__NFUN_150__(X, __NFUN_146__(NumSteps, 1)))
	{
		NewVtx = __NFUN_276__(vtx, __NFUN_287__(RotStep, float(X)));
		Vertex3f(NewVtx.X, NewVtx.Y, __NFUN_175__(vtx.Z, float(AddToFirstStep)));
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x2F7;
	}
	X = 0;
	J0x364:

	// End:0x51B [Loop If]
	if(__NFUN_150__(X, NumSteps))
	{
		Poly4i(direction, __NFUN_146__(__NFUN_146__(InnerStart, __NFUN_144__(X, 2)), 2), __NFUN_146__(__NFUN_146__(InnerStart, __NFUN_144__(X, 2)), 1), __NFUN_146__(__NFUN_146__(OuterStart, __NFUN_144__(X, 2)), 1), __NFUN_146__(__NFUN_146__(OuterStart, __NFUN_144__(X, 2)), 2), 'steptop');
		Poly4i(direction, __NFUN_146__(__NFUN_146__(InnerStart, __NFUN_144__(X, 2)), 1), __NFUN_146__(InnerStart, __NFUN_144__(X, 2)), __NFUN_146__(OuterStart, __NFUN_144__(X, 2)), __NFUN_146__(__NFUN_146__(OuterStart, __NFUN_144__(X, 2)), 1), 'stepfront');
		Poly4i(direction, __NFUN_146__(BottomInnerStart, X), __NFUN_146__(__NFUN_146__(InnerStart, __NFUN_144__(X, 2)), 1), __NFUN_146__(__NFUN_146__(InnerStart, __NFUN_144__(X, 2)), 2), __NFUN_146__(__NFUN_146__(BottomInnerStart, X), 1), 'innercurve');
		Poly4i(direction, __NFUN_146__(__NFUN_146__(OuterStart, __NFUN_144__(X, 2)), 1), __NFUN_146__(BottomOuterStart, X), __NFUN_146__(__NFUN_146__(BottomOuterStart, X), 1), __NFUN_146__(__NFUN_146__(OuterStart, __NFUN_144__(X, 2)), 2), 'outercurve');
		Poly4i(direction, __NFUN_146__(BottomInnerStart, X), __NFUN_146__(__NFUN_146__(BottomInnerStart, X), 1), __NFUN_146__(__NFUN_146__(BottomOuterStart, X), 1), __NFUN_146__(BottomOuterStart, X), 'Bottom');
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x364;
	}
	Poly4i(direction, __NFUN_146__(BottomInnerStart, NumSteps), __NFUN_146__(InnerStart, __NFUN_144__(NumSteps, 2)), __NFUN_146__(OuterStart, __NFUN_144__(NumSteps, 2)), __NFUN_146__(BottomOuterStart, NumSteps), 'back');
	return;
}

function bool Build()
{
	local int i, j, k;

	// End:0x3B
	if(__NFUN_132__(__NFUN_150__(AngleOfCurve, 1), __NFUN_151__(AngleOfCurve, 360)))
	{
		return BadParameters("Angle is out of range.");
	}
	// End:0x67
	if(__NFUN_132__(__NFUN_132__(__NFUN_150__(InnerRadius, 1), __NFUN_150__(StepWidth, 1)), __NFUN_150__(NumSteps, 1)))
	{
		return BadParameters();
	}
	BeginBrush(false, GroupName);
	BuildCurvedStair(1);
	return EndBrush();
	return;
}

defaultproperties
{
	InnerRadius=240
	StepHeight=16
	StepWidth=256
	AngleOfCurve=90
	NumSteps=4
	GroupName="CStair"
	BitmapFilename="BBCurvedStair"
	ToolTip="Curved Staircase"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var p
