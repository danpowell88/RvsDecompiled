//=============================================================================
// SpiralStairBuilder: Builds a spiral staircase.
//=============================================================================
class SpiralStairBuilder extends BrushBuilder;

// --- Variables ---
var int StepHeight;
var int InnerRadius;
var bool SlopedCeiling;
var bool SlopedFloor;
var int NumSteps;
var int StepWidth;
var int StepThickness;
var int NumStepsPer360;
var name GroupName;
var bool CounterClockwise;

// --- Functions ---
function BuildCurvedStair(int direction) {}
function bool Build() {}
// ^ NEW IN 1.60

defaultproperties
{
}
