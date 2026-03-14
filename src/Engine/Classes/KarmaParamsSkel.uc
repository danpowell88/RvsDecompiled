//=============================================================================
// The Karma physics parameter specific to skeletons.
// NB: All parameters are in KARMA scale!
//=============================================================================
class KarmaParamsSkel extends KarmaParams
    native;

// --- Variables ---
var string KSkeleton;
// ^ NEW IN 1.60
var bool bKDoConvulsions;
// ^ NEW IN 1.60
var Range KConvulseSpacing;
// ^ NEW IN 1.60
// When the skeletal physics starts up, we check this line against the skeleton,
// and apply an impulse with magnitude KShotStrength if we hit a bone.
// This has to be deferred  because ragdoll-startup is.
var transient Vector KShotStart;
var transient Vector KShotEnd;
var transient float KShotStrength;
// This indicates this ragdoll will not be recycled during KMakeRagdollAvailable
var transient bool bKImportantRagdoll;

defaultproperties
{
}
