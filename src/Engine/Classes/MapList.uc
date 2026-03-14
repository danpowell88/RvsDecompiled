//=============================================================================
// MapList.
//
// contains a list of maps to cycle through
//
//=============================================================================
class MapList extends Info
    native
    abstract;

// --- Constants ---
const K_NextDefaultMap =  -2;

// --- Variables ---
var config string Maps[32];

// --- Functions ---
function string GetNextMap(int iNextMapNum) {}

defaultproperties
{
}
