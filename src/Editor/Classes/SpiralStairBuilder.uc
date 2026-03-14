//=============================================================================
// SpiralStairBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// SpiralStairBuilder: Builds a spiral staircase.
//=============================================================================
class SpiralStairBuilder extends BrushBuilder;

var() int InnerRadius;
// NEW IN 1.60
var() int StepWidth;
// NEW IN 1.60
var() int StepHeight;
// NEW IN 1.60
var() int StepThickness;
// NEW IN 1.60
var() int NumStepsPer360;
// NEW IN 1.60
var() int NumSteps;
var() bool SlopedCeiling;
// NEW IN 1.60
var() bool SlopedFloor;
// NEW IN 1.60
var() bool CounterClockwise;
var() name GroupName;

function BuildCurvedStair(int direction)
{
	local Rotator RotStep, newRot;
	local Vector vtx, NewVtx, Template;
	local int X, Y, idx, VertexStart;

	RotStep.Yaw = int(__NFUN_171__(float(65536), __NFUN_172__(__NFUN_172__(360.0000000, float(NumStepsPer360)), 360.0000000)));
	// End:0x55
	if(CounterClockwise)
	{
		__NFUN_159__(RotStep.Yaw, float(-1));
		__NFUN_159__(direction, float(-1));
	}
	idx = 0;
	VertexStart = GetVertexCount();
	vtx.X = float(InnerRadius);
	X = 0;
	J0x81:

	// End:0x21F [Loop If]
	if(__NFUN_150__(X, 2))
	{
		NewVtx = __NFUN_276__(vtx, __NFUN_287__(RotStep, float(X)));
		vtx.Z = 0.0000000;
		// End:0xE2
		if(__NFUN_130__(SlopedCeiling, __NFUN_154__(X, 1)))
		{
			vtx.Z = float(StepHeight);
		}
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		Template[idx].X = NewVtx.X;
		Template[idx].Y = NewVtx.Y;
		Template[idx].Z = vtx.Z;
		__NFUN_165__(idx);
		vtx.Z = float(StepThickness);
		// End:0x199
		if(__NFUN_130__(SlopedFloor, __NFUN_154__(X, 0)))
		{
			__NFUN_185__(vtx.Z, float(StepHeight));
		}
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		Template[idx].X = NewVtx.X;
		Template[idx].Y = NewVtx.Y;
		Template[idx].Z = vtx.Z;
		__NFUN_165__(idx);
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x81;
	}
	vtx.X = float(__NFUN_146__(InnerRadius, StepWidth));
	X = 0;
	J0x23F:

	// End:0x3DD [Loop If]
	if(__NFUN_150__(X, 2))
	{
		NewVtx = __NFUN_276__(vtx, __NFUN_287__(RotStep, float(X)));
		vtx.Z = 0.0000000;
		// End:0x2A0
		if(__NFUN_130__(SlopedCeiling, __NFUN_154__(X, 1)))
		{
			vtx.Z = float(StepHeight);
		}
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		Template[idx].X = NewVtx.X;
		Template[idx].Y = NewVtx.Y;
		Template[idx].Z = vtx.Z;
		__NFUN_165__(idx);
		vtx.Z = float(StepThickness);
		// End:0x357
		if(__NFUN_130__(SlopedFloor, __NFUN_154__(X, 0)))
		{
			__NFUN_185__(vtx.Z, float(StepHeight));
		}
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		Template[idx].X = NewVtx.X;
		Template[idx].Y = NewVtx.Y;
		Template[idx].Z = vtx.Z;
		__NFUN_165__(idx);
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x23F;
	}
	X = 0;
	J0x3E4:

	// End:0x679 [Loop If]
	if(__NFUN_150__(X, __NFUN_147__(NumSteps, 1)))
	{
		// End:0x457
		if(SlopedFloor)
		{
			Poly3i(direction, __NFUN_146__(VertexStart, 3), __NFUN_146__(VertexStart, 1), __NFUN_146__(VertexStart, 5), 'steptop');
			Poly3i(direction, __NFUN_146__(VertexStart, 3), __NFUN_146__(VertexStart, 5), __NFUN_146__(VertexStart, 7), 'steptop');			
		}
		else
		{
			Poly4i(direction, __NFUN_146__(VertexStart, 3), __NFUN_146__(VertexStart, 1), __NFUN_146__(VertexStart, 5), __NFUN_146__(VertexStart, 7), 'steptop');
		}
		Poly4i(direction, __NFUN_146__(VertexStart, 0), __NFUN_146__(VertexStart, 1), __NFUN_146__(VertexStart, 3), __NFUN_146__(VertexStart, 2), 'inner');
		Poly4i(direction, __NFUN_146__(VertexStart, 5), __NFUN_146__(VertexStart, 4), __NFUN_146__(VertexStart, 6), __NFUN_146__(VertexStart, 7), 'Outer');
		Poly4i(direction, __NFUN_146__(VertexStart, 1), __NFUN_146__(VertexStart, 0), __NFUN_146__(VertexStart, 4), __NFUN_146__(VertexStart, 5), 'stepfront');
		Poly4i(direction, __NFUN_146__(VertexStart, 2), __NFUN_146__(VertexStart, 3), __NFUN_146__(VertexStart, 7), __NFUN_146__(VertexStart, 6), 'stepback');
		// End:0x5B6
		if(SlopedCeiling)
		{
			Poly3i(direction, __NFUN_146__(VertexStart, 0), __NFUN_146__(VertexStart, 2), __NFUN_146__(VertexStart, 6), 'stepbottom');
			Poly3i(direction, __NFUN_146__(VertexStart, 0), __NFUN_146__(VertexStart, 6), __NFUN_146__(VertexStart, 4), 'stepbottom');			
		}
		else
		{
			Poly4i(direction, __NFUN_146__(VertexStart, 0), __NFUN_146__(VertexStart, 2), __NFUN_146__(VertexStart, 6), __NFUN_146__(VertexStart, 4), 'stepbottom');
		}
		VertexStart = GetVertexCount();
		Y = 0;
		J0x5FC:

		// End:0x66F [Loop If]
		if(__NFUN_150__(Y, 8))
		{
			NewVtx = __NFUN_276__(Template[Y], __NFUN_287__(RotStep, float(__NFUN_146__(X, 1))));
			Vertex3f(NewVtx.X, NewVtx.Y, __NFUN_174__(NewVtx.Z, float(__NFUN_144__(StepHeight, __NFUN_146__(X, 1)))));
			__NFUN_165__(Y);
			// [Loop Continue]
			goto J0x5FC;
		}
		__NFUN_165__(X);
		// [Loop Continue]
		goto J0x3E4;
	}
	return;
}

function bool Build()
{
	// End:0x3A
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_150__(InnerRadius, 1), __NFUN_150__(StepWidth, 1)), __NFUN_150__(NumSteps, 1)), __NFUN_150__(NumStepsPer360, 3)))
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
	InnerRadius=64
	StepWidth=256
	StepHeight=16
	StepThickness=32
	NumStepsPer360=8
	NumSteps=8
	SlopedCeiling=true
	GroupName="Spiral"
	BitmapFilename="BBSpiralStair"
	ToolTip="Spiral Staircase"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var r
// REMOVED IN 1.60: var e
