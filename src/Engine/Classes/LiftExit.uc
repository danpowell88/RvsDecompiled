//=============================================================================
// LiftExit.
//=============================================================================
class LiftExit extends NavigationPoint
    native;

#exec Texture Import File=Textures\Lift_exit.pcx Name=S_LiftExit Mips=Off MASKED=1

// --- Variables ---
var Mover MyLift;
var byte KeyFrame;
var name LiftTag;
// ^ NEW IN 1.60
var byte SuggestedKeyFrame;
// ^ NEW IN 1.60

// --- Functions ---
function bool SuggestMovePreparation(Pawn Other) {}

defaultproperties
{
}
