//=============================================================================
// LinearStairBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// LinearStairBuilder: Builds a Linear Staircase.
//=============================================================================
class LinearStairBuilder extends BrushBuilder;

var() int StepLength;
// NEW IN 1.60
var() int StepHeight;
// NEW IN 1.60
var() int StepWidth;
// NEW IN 1.60
var() int NumSteps;
// NEW IN 1.60
var() int AddToFirstStep;
var() name GroupName;

event bool Build()
{
	local int i, LastIdx, CurrentX, CurrentY, CurrentZ, Adjustment;

	// End:0x2C
	if(__NFUN_132__(__NFUN_132__(__NFUN_152__(StepLength, 0), __NFUN_152__(StepHeight, 0)), __NFUN_152__(StepWidth, 0)))
	{
		return BadParameters();
	}
	// End:0x7F
	if(__NFUN_132__(__NFUN_152__(NumSteps, 1), __NFUN_151__(NumSteps, 45)))
	{
		return BadParameters("NumSteps must be greater than 1 and less than 45.");
	}
	BeginBrush(false, GroupName);
	CurrentX = 0;
	CurrentY = 0;
	CurrentZ = 0;
	LastIdx = GetVertexCount();
	Vertex3f(0.0000000, 0.0000000, float(__NFUN_143__(StepHeight)));
	Vertex3f(0.0000000, float(StepWidth), float(__NFUN_143__(StepHeight)));
	Vertex3f(float(__NFUN_144__(StepLength, NumSteps)), float(StepWidth), float(__NFUN_143__(StepHeight)));
	Vertex3f(float(__NFUN_144__(StepLength, NumSteps)), 0.0000000, float(__NFUN_143__(StepHeight)));
	Poly4i(1, 0, 1, 2, 3, 'Base');
	__NFUN_161__(LastIdx, 4);
	Vertex3f(float(__NFUN_144__(StepLength, NumSteps)), float(StepWidth), float(__NFUN_143__(StepHeight)));
	Vertex3f(float(__NFUN_144__(StepLength, NumSteps)), float(StepWidth), __NFUN_174__(float(__NFUN_144__(StepHeight, __NFUN_147__(NumSteps, 1))), float(AddToFirstStep)));
	Vertex3f(float(__NFUN_144__(StepLength, NumSteps)), 0.0000000, __NFUN_174__(float(__NFUN_144__(StepHeight, __NFUN_147__(NumSteps, 1))), float(AddToFirstStep)));
	Vertex3f(float(__NFUN_144__(StepLength, NumSteps)), 0.0000000, float(__NFUN_143__(StepHeight)));
	Poly4i(1, 4, 5, 6, 7, 'back');
	__NFUN_161__(LastIdx, 4);
	i = 0;
	J0x213:

	// End:0x336 [Loop If]
	if(__NFUN_150__(i, NumSteps))
	{
		CurrentX = __NFUN_144__(i, StepLength);
		CurrentZ = __NFUN_146__(__NFUN_144__(i, StepHeight), AddToFirstStep);
		Vertex3f(float(CurrentX), float(CurrentY), float(CurrentZ));
		Vertex3f(float(CurrentX), float(__NFUN_146__(CurrentY, StepWidth)), float(CurrentZ));
		Vertex3f(float(__NFUN_146__(CurrentX, StepLength)), float(__NFUN_146__(CurrentY, StepWidth)), float(CurrentZ));
		Vertex3f(float(__NFUN_146__(CurrentX, StepLength)), float(CurrentY), float(CurrentZ));
		Poly4i(1, __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 4)), 3), __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 4)), 2), __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 4)), 1), __NFUN_146__(LastIdx, __NFUN_144__(i, 4)), 'Step');
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x213;
	}
	__NFUN_161__(LastIdx, __NFUN_144__(NumSteps, 4));
	i = 0;
	J0x34D:

	// End:0x6D6 [Loop If]
	if(__NFUN_150__(i, NumSteps))
	{
		CurrentX = __NFUN_144__(i, StepLength);
		CurrentZ = __NFUN_146__(__NFUN_144__(i, StepHeight), AddToFirstStep);
		// End:0x3A0
		if(__NFUN_154__(i, 0))
		{
			Adjustment = AddToFirstStep;			
		}
		else
		{
			Adjustment = 0;
		}
		Vertex3f(float(CurrentX), float(CurrentY), float(CurrentZ));
		Vertex3f(float(CurrentX), float(CurrentY), float(__NFUN_147__(__NFUN_147__(CurrentZ, StepHeight), Adjustment)));
		Vertex3f(float(CurrentX), float(__NFUN_146__(CurrentY, StepWidth)), float(__NFUN_147__(__NFUN_147__(CurrentZ, StepHeight), Adjustment)));
		Vertex3f(float(CurrentX), float(__NFUN_146__(CurrentY, StepWidth)), float(CurrentZ));
		Poly4i(1, __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 3), __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 2), __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 1), __NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 'Rise');
		Vertex3f(float(CurrentX), float(CurrentY), float(CurrentZ));
		Vertex3f(float(CurrentX), float(CurrentY), float(__NFUN_147__(__NFUN_147__(CurrentZ, StepHeight), Adjustment)));
		Vertex3f(float(__NFUN_146__(CurrentX, __NFUN_144__(StepLength, __NFUN_147__(NumSteps, i)))), float(CurrentY), float(__NFUN_147__(__NFUN_147__(CurrentZ, StepHeight), Adjustment)));
		Vertex3f(float(__NFUN_146__(CurrentX, __NFUN_144__(StepLength, __NFUN_147__(NumSteps, i)))), float(CurrentY), float(CurrentZ));
		Poly4i(1, __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 4), __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 5), __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 6), __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 7), 'Side');
		Vertex3f(float(CurrentX), float(__NFUN_146__(CurrentY, StepWidth)), float(CurrentZ));
		Vertex3f(float(CurrentX), float(__NFUN_146__(CurrentY, StepWidth)), float(__NFUN_147__(__NFUN_147__(CurrentZ, StepHeight), Adjustment)));
		Vertex3f(float(__NFUN_146__(CurrentX, __NFUN_144__(StepLength, __NFUN_147__(NumSteps, i)))), float(__NFUN_146__(CurrentY, StepWidth)), float(__NFUN_147__(__NFUN_147__(CurrentZ, StepHeight), Adjustment)));
		Vertex3f(float(__NFUN_146__(CurrentX, __NFUN_144__(StepLength, __NFUN_147__(NumSteps, i)))), float(__NFUN_146__(CurrentY, StepWidth)), float(CurrentZ));
		Poly4i(1, __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 11), __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 10), __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 9), __NFUN_146__(__NFUN_146__(LastIdx, __NFUN_144__(i, 12)), 8), 'Side');
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x34D;
	}
	return EndBrush();
	return;
}

defaultproperties
{
	StepLength=32
	StepHeight=16
	StepWidth=256
	NumSteps=8
	GroupName="LinearStair"
	BitmapFilename="BBLinearStair"
	ToolTip="Linear Staircase"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var p
