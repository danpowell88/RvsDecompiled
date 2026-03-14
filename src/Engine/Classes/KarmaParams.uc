//=============================================================================
// KarmaParams - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// The Karma physics parameters class.
// This provides 'extra' parameters needed by Karma physics to the Actor class.
// Need one of these (or a subclass) to set Physics to PHYS_Karma.
// (see Actor.uc)
// NB: All parameters are in KARMA scale!
//=============================================================================
class KarmaParams extends KarmaParamsCollision
	native
	editinlinenew;

var() bool KStartEnabled;  // Start simulating body as soon as PHYS_Karma starts
var() bool bKNonSphericalInertia;  // Simulate body without using sphericalised inertia tensor
// NB - the below settings only apply to PHYS_Karma (not PHYS_KarmaRagDoll)
var() bool bHighDetailOnly;  // Only turn on karma physics for this actor if the level PhysicsDetailLevel is PDL_High
var bool bClientOnly;  // Only turn on karma physics for this actor on the client (not server).
var() const bool bKDoubleTickRate;  // Allows higher karma sim rate (double normal) for some objects.
var() bool bKStayUpright;  // Stop this object from being able to rotate (using Angular3 constraint)
var() bool bKAllowRotate;  // Allow this object to rotate about a vertical axis. Ignored unless KStayUpright == true.
var bool bDestroyOnSimError;  // If there is a problem with the physics, destroy, or leave around to be fixed (eg. by network).
var() float KMass;  // Mass used for Karma physics
var() float KLinearDamping;  // Linear velocity damping (drag)
var() float KAngularDamping;  // Angular velocity damping (drag)
var() float KBuoyancy;  // Applies in water volumes. 0 = no buoyancy. 1 = neutrally buoyant
var() float KActorGravScale;  // Scale how gravity affects this actor.
var() float KVelDropBelowThreshold;  // Threshold that when actor drops below, KVelDropBelow event is triggered.
var() Vector KStartLinVel;  // Initial linear velocity for actor
var() Vector KStartAngVel;  // Initial angular velocity for actor
// Used internally for Karma stuff - DO NOT CHANGE!
var const transient int KAng3;
var const transient int KTriList;
var const transient float KLastVel;

defaultproperties
{
	bHighDetailOnly=true
	bClientOnly=true
	bDestroyOnSimError=true
	KMass=1.0000000
	KLinearDamping=0.2000000
	KAngularDamping=0.2000000
	KActorGravScale=1.0000000
	KVelDropBelowThreshold=1000000.0000000
}
