//=============================================================================
// CurvedStairBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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

	RotStep.Yaw = (int((float(65536) * (float(AngleOfCurve) / 360.0000000))) / NumSteps);
	// End:0x55
	if(CounterClockwise)
	{
		(RotStep.Yaw *= float(-1));
		(direction *= float(-1));
	}
	InnerStart = GetVertexCount();
	vtx.X = float(InnerRadius);
	X = 0;
	J0x7A:

	// End:0x137 [Loop If]
	if((X < (NumSteps + 1)))
	{
		// End:0xA5
		if((X == 0))
		{
			Adjustment = AddToFirstStep;			
		}
		else
		{
			Adjustment = 0;
		}
		NewVtx = (vtx >> (RotStep * float(X)));
		Vertex3f(NewVtx.X, NewVtx.Y, (vtx.Z - float(Adjustment)));
		(vtx.Z += float(StepHeight));
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		(X++);
		// [Loop Continue]
		goto J0x7A;
	}
	OuterStart = GetVertexCount();
	vtx.X = float((InnerRadius + StepWidth));
	vtx.Z = 0.0000000;
	X = 0;
	J0x173:

	// End:0x230 [Loop If]
	if((X < (NumSteps + 1)))
	{
		// End:0x19E
		if((X == 0))
		{
			Adjustment = AddToFirstStep;			
		}
		else
		{
			Adjustment = 0;
		}
		NewVtx = (vtx >> (RotStep * float(X)));
		Vertex3f(NewVtx.X, NewVtx.Y, (vtx.Z - float(Adjustment)));
		(vtx.Z += float(StepHeight));
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		(X++);
		// [Loop Continue]
		goto J0x173;
	}
	BottomInnerStart = GetVertexCount();
	vtx.X = float(InnerRadius);
	vtx.Z = 0.0000000;
	X = 0;
	J0x265:

	// End:0x2CB [Loop If]
	if((X < (NumSteps + 1)))
	{
		NewVtx = (vtx >> (RotStep * float(X)));
		Vertex3f(NewVtx.X, NewVtx.Y, (vtx.Z - float(AddToFirstStep)));
		(X++);
		// [Loop Continue]
		goto J0x265;
	}
	BottomOuterStart = GetVertexCount();
	vtx.X = float((InnerRadius + StepWidth));
	X = 0;
	J0x2F7:

	// End:0x35D [Loop If]
	if((X < (NumSteps + 1)))
	{
		NewVtx = (vtx >> (RotStep * float(X)));
		Vertex3f(NewVtx.X, NewVtx.Y, (vtx.Z - float(AddToFirstStep)));
		(X++);
		// [Loop Continue]
		goto J0x2F7;
	}
	X = 0;
	J0x364:

	// End:0x51B [Loop If]
	if((X < NumSteps))
	{
		Poly4i(direction, ((InnerStart + (X * 2)) + 2), ((InnerStart + (X * 2)) + 1), ((OuterStart + (X * 2)) + 1), ((OuterStart + (X * 2)) + 2), 'steptop');
		Poly4i(direction, ((InnerStart + (X * 2)) + 1), (InnerStart + (X * 2)), (OuterStart + (X * 2)), ((OuterStart + (X * 2)) + 1), 'stepfront');
		Poly4i(direction, (BottomInnerStart + X), ((InnerStart + (X * 2)) + 1), ((InnerStart + (X * 2)) + 2), ((BottomInnerStart + X) + 1), 'innercurve');
		Poly4i(direction, ((OuterStart + (X * 2)) + 1), (BottomOuterStart + X), ((BottomOuterStart + X) + 1), ((OuterStart + (X * 2)) + 2), 'outercurve');
		Poly4i(direction, (BottomInnerStart + X), ((BottomInnerStart + X) + 1), ((BottomOuterStart + X) + 1), (BottomOuterStart + X), 'Bottom');
		(X++);
		// [Loop Continue]
		goto J0x364;
	}
	Poly4i(direction, (BottomInnerStart + NumSteps), (InnerStart + (NumSteps * 2)), (OuterStart + (NumSteps * 2)), (BottomOuterStart + NumSteps), 'back');
	return;
}

function bool Build()
{
	local int i, j, k;

	// End:0x3B
	if(((AngleOfCurve < 1) || (AngleOfCurve > 360)))
	{
		return BadParameters("Angle is out of range.");
	}
	// End:0x67
	if((((InnerRadius < 1) || (StepWidth < 1)) || (NumSteps < 1)))
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
