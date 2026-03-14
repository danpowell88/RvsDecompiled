//=============================================================================
// The Basic constraint class.
//=============================================================================
class KConstraint extends KActor
    native
    abstract;

#exec Texture Import File=Textures\S_KConstraint.pcx Name=S_KConstraint Mips=Off MASKED=1

// --- Variables ---
var Actor KConstraintActor1;
// ^ NEW IN 1.60
// Used internally for Karma stuff - DO NOT CHANGE!
var transient const int KConstraintData;
var Actor KConstraintActor2;
// ^ NEW IN 1.60
var name KConstraintBone1;
// ^ NEW IN 1.60
var name KConstraintBone2;
// ^ NEW IN 1.60
var const bool bKDisableCollision;
// ^ NEW IN 1.60
// Body1 ref frame
var Vector KPos1;
var Vector KPriAxis1;
var Vector KSecAxis1;
// Body2 ref frame
var Vector KPos2;
var Vector KPriAxis2;
var Vector KSecAxis2;
// Force constraint to re-calculate its position/axis in local ref frames
// Usually true for constraints saved out of UnrealEd, false for everything else
var const bool bKForceFrameUpdate;
var float KForceThreshold;
// ^ NEW IN 1.60

// --- Functions ---
final native function KGetConstraintForce(out Vector Force) {}
final native function KGetConstraintTorque(out Vector Torque) {}
// This function is used to re-sync constraint parameters (eg. stiffness) with Karma.
// Call when you change a parameter to get it to actually take effect.
native function KUpdateConstraintParams() {}
// Event triggered when magnitude of constraint (linear) force exceeds KForceThreshold
event KForceExceed(float forceMag) {}

defaultproperties
{
}
