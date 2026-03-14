//=============================================================================
// LiftCenter.
//=============================================================================
class LiftCenter extends NavigationPoint
    native;

#exec Texture Import File=Textures\Lift_center.pcx Name=S_LiftCenter Mips=Off MASKED=1

// --- Variables ---
var Mover MyLift;
var Trigger RecommendedTrigger;
var name LiftTrigger;
// ^ NEW IN 1.60
var float MaxDist2D;
// starting vector between MyLift location and LiftCenter location
var Vector LiftOffset;
var name LiftTag;
// ^ NEW IN 1.60

// --- Functions ---
function Actor SpecialHandling(Pawn Other) {}
// ^ NEW IN 1.60
function bool SuggestMovePreparation(Pawn Other) {}
// ^ NEW IN 1.60
function bool ProceedWithMove(Pawn Other) {}
// ^ NEW IN 1.60
function PostBeginPlay() {}

defaultproperties
{
}
