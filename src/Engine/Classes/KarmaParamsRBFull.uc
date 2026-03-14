//=============================================================================
// This is the full set of Karma parameters, including inertia tensor and 
// centre-of-mass position, which are normally stored with the StaticMesh.
// This gives you a chance to overrids these values.
// NB: All parameters are in KARMA scale!
//=============================================================================
class KarmaParamsRBFull extends KarmaParams
    native;

// --- Variables ---
var float KInertiaTensor[6];
var Vector KCOMOffset;

defaultproperties
{
}
