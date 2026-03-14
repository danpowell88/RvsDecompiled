//=============================================================================
// DefensePoint
// A navigation hint marking a position that an AI should defend.
// FortTag links it to a fortification, Priority controls selection order, and
// Team restricts it to a specific team (0 = any).
//=============================================================================
class DefensePoint extends Ambushpoint;

// --- Variables ---
var name FortTag;
var byte Priority;
var byte Team;

defaultproperties
{
}
