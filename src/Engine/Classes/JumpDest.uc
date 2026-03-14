//=============================================================================
// JumpDest.
// specifies positions that can be reached with greater than normal jump
// forced paths will check for greater than normal jump capability
// NOTE these have NO relation to JumpPads
//=============================================================================
class JumpDest extends NavigationPoint
    native;

// --- Variables ---
var Vector NeededJump[8];
var ReachSpec UpstreamPaths[8];
var int NumUpstreamPaths;

// --- Functions ---
event int SpecialCost(Pawn Other, ReachSpec Path) {}
function int GetPathIndex(ReachSpec Path) {}
event bool SuggestMovePreparation(Pawn Other) {}

defaultproperties
{
}
