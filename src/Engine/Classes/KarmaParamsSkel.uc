//=============================================================================
// KarmaParamsSkel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// The Karma physics parameter specific to skeletons.
// NB: All parameters are in KARMA scale!
//=============================================================================
class KarmaParamsSkel extends KarmaParams
	native
	editinlinenew;

var() bool bKDoConvulsions;
var() Range KConvulseSpacing;  // Time between convulsions.
var() string KSkeleton;  // Karma Asset to use for this skeleton.
var transient bool bKImportantRagdoll;  // This indicates this ragdoll will not be recycled during KMakeRagdollAvailable
var transient float KShotStrength;
// When the skeletal physics starts up, we check this line against the skeleton,
// and apply an impulse with magnitude KShotStrength if we hit a bone.
// This has to be deferred  because ragdoll-startup is.
var transient Vector KShotStart;
var transient Vector KShotEnd;

defaultproperties
{
	KConvulseSpacing=(Min=0.5000000,Max=1.5000000)
}
