//=============================================================================
// Ambushpoint.
//=============================================================================
class Ambushpoint extends NavigationPoint
    notplaceable;

// --- Variables ---
// var ? lookdir; // REMOVED IN 1.60
var Vector LookDir;
// ^ NEW IN 1.60
var bool bSniping;
// ^ NEW IN 1.60
var float SightRadius;
// ^ NEW IN 1.60
//at start, ambushing creatures will pick either their current location, or the location of
//some ambushpoint belonging to their team
//used when picking ambushpoint
var byte survivecount;

// --- Functions ---
function PreBeginPlay() {}

defaultproperties
{
}
