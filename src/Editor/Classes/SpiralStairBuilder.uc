//=============================================================================
// SpiralStairBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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

	RotStep.Yaw = int((float(65536) * ((360.0000000 / float(NumStepsPer360)) / 360.0000000)));
	// End:0x55
	if(CounterClockwise)
	{
		(RotStep.Yaw *= float(-1));
		(direction *= float(-1));
	}
	idx = 0;
	VertexStart = GetVertexCount();
	vtx.X = float(InnerRadius);
	X = 0;
	J0x81:

	// End:0x21F [Loop If]
	if((X < 2))
	{
		NewVtx = (vtx >> (RotStep * float(X)));
		vtx.Z = 0.0000000;
		// End:0xE2
		if((SlopedCeiling && (X == 1)))
		{
			vtx.Z = float(StepHeight);
		}
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		Template[idx].X = NewVtx.X;
		Template[idx].Y = NewVtx.Y;
		Template[idx].Z = vtx.Z;
		(idx++);
		vtx.Z = float(StepThickness);
		// End:0x199
		if((SlopedFloor && (X == 0)))
		{
			(vtx.Z -= float(StepHeight));
		}
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		Template[idx].X = NewVtx.X;
		Template[idx].Y = NewVtx.Y;
		Template[idx].Z = vtx.Z;
		(idx++);
		(X++);
		// [Loop Continue]
		goto J0x81;
	}
	vtx.X = float((InnerRadius + StepWidth));
	X = 0;
	J0x23F:

	// End:0x3DD [Loop If]
	if((X < 2))
	{
		NewVtx = (vtx >> (RotStep * float(X)));
		vtx.Z = 0.0000000;
		// End:0x2A0
		if((SlopedCeiling && (X == 1)))
		{
			vtx.Z = float(StepHeight);
		}
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		Template[idx].X = NewVtx.X;
		Template[idx].Y = NewVtx.Y;
		Template[idx].Z = vtx.Z;
		(idx++);
		vtx.Z = float(StepThickness);
		// End:0x357
		if((SlopedFloor && (X == 0)))
		{
			(vtx.Z -= float(StepHeight));
		}
		Vertex3f(NewVtx.X, NewVtx.Y, vtx.Z);
		Template[idx].X = NewVtx.X;
		Template[idx].Y = NewVtx.Y;
		Template[idx].Z = vtx.Z;
		(idx++);
		(X++);
		// [Loop Continue]
		goto J0x23F;
	}
	X = 0;
	J0x3E4:

	// End:0x679 [Loop If]
	if((X < (NumSteps - 1)))
	{
		// End:0x457
		if(SlopedFloor)
		{
			Poly3i(direction, (VertexStart + 3), (VertexStart + 1), (VertexStart + 5), 'steptop');
			Poly3i(direction, (VertexStart + 3), (VertexStart + 5), (VertexStart + 7), 'steptop');			
		}
		else
		{
			Poly4i(direction, (VertexStart + 3), (VertexStart + 1), (VertexStart + 5), (VertexStart + 7), 'steptop');
		}
		Poly4i(direction, (VertexStart + 0), (VertexStart + 1), (VertexStart + 3), (VertexStart + 2), 'inner');
		Poly4i(direction, (VertexStart + 5), (VertexStart + 4), (VertexStart + 6), (VertexStart + 7), 'Outer');
		Poly4i(direction, (VertexStart + 1), (VertexStart + 0), (VertexStart + 4), (VertexStart + 5), 'stepfront');
		Poly4i(direction, (VertexStart + 2), (VertexStart + 3), (VertexStart + 7), (VertexStart + 6), 'stepback');
		// End:0x5B6
		if(SlopedCeiling)
		{
			Poly3i(direction, (VertexStart + 0), (VertexStart + 2), (VertexStart + 6), 'stepbottom');
			Poly3i(direction, (VertexStart + 0), (VertexStart + 6), (VertexStart + 4), 'stepbottom');			
		}
		else
		{
			Poly4i(direction, (VertexStart + 0), (VertexStart + 2), (VertexStart + 6), (VertexStart + 4), 'stepbottom');
		}
		VertexStart = GetVertexCount();
		Y = 0;
		J0x5FC:

		// End:0x66F [Loop If]
		if((Y < 8))
		{
			NewVtx = (Template[Y] >> (RotStep * float((X + 1))));
			Vertex3f(NewVtx.X, NewVtx.Y, (NewVtx.Z + float((StepHeight * (X + 1)))));
			(Y++);
			// [Loop Continue]
			goto J0x5FC;
		}
		(X++);
		// [Loop Continue]
		goto J0x3E4;
	}
	return;
}

function bool Build()
{
	// End:0x3A
	if(((((InnerRadius < 1) || (StepWidth < 1)) || (NumSteps < 1)) || (NumStepsPer360 < 3)))
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
