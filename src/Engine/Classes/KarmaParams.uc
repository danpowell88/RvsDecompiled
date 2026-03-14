//=============================================================================
// The Karma physics parameters class.
// This provides 'extra' parameters needed by Karma physics to the Actor class.
// Need one of these (or a subclass) to set Physics to PHYS_Karma.
// (see Actor.uc)
// NB: All parameters are in KARMA scale!
//=============================================================================
class KarmaParams extends KarmaParamsCollision
    native;

// --- Variables ---
// Used internally for Karma stuff - DO NOT CHANGE!
var transient const int KAng3;
var transient const int KTriList;
var transient const float KLastVel;
var float KMass;
// ^ NEW IN 1.60
var float KLinearDamping;
// ^ NEW IN 1.60
var float KAngularDamping;
// ^ NEW IN 1.60
var float KBuoyancy;
// ^ NEW IN 1.60
var bool KStartEnabled;
// ^ NEW IN 1.60
var Vector KStartLinVel;
// ^ NEW IN 1.60
var Vector KStartAngVel;
// ^ NEW IN 1.60
// Simulate body without using sphericalised inertia tensor
var bool bKNonSphericalInertia;
var float KActorGravScale;
// ^ NEW IN 1.60
var float KVelDropBelowThreshold;
// ^ NEW IN 1.60
var bool bHighDetailOnly;
// ^ NEW IN 1.60
// NB - the below settings only apply to PHYS_Karma (not PHYS_KarmaRagDoll)
// Only turn on karma physics for this actor on the client (not server).
var bool bClientOnly;
var const bool bKDoubleTickRate;
// ^ NEW IN 1.60
var bool bKStayUpright;
// ^ NEW IN 1.60
var bool bKAllowRotate;
// ^ NEW IN 1.60
// If there is a problem with the physics, destroy, or leave around to be fixed (eg. by network).
var bool bDestroyOnSimError;

defaultproperties
{
}
