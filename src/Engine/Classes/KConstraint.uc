//=============================================================================
// KConstraint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// The Basic constraint class.
//=============================================================================
class KConstraint extends KActor
    abstract
    native
    placeable;

// Disable collision between joined
var(KarmaConstraint) const bool bKDisableCollision;
// Force constraint to re-calculate its position/axis in local ref frames
// Usually true for constraints saved out of UnrealEd, false for everything else
var const bool bKForceFrameUpdate;
// [see KForceExceed below]
var(KarmaConstraint) float KForceThreshold;
// Actors joined effected by this constraint (could be NULL for 'World')
var(KarmaConstraint) edfindable Actor KConstraintActor1;
var(KarmaConstraint) edfindable Actor KConstraintActor2;
// If an KConstraintActor is a skeletal thing, you can specify which bone inside it
// to attach the constraint to. If left blank (the default) it picks the nearest bone.
var(KarmaConstraint) name KConstraintBone1;
var(KarmaConstraint) name KConstraintBone2;
// Body1 ref frame
var Vector KPos1;
var Vector KPriAxis1;
var Vector KSecAxis1;
// Body2 ref frame
var Vector KPos2;
var Vector KPriAxis2;
var Vector KSecAxis2;
// Used internally for Karma stuff - DO NOT CHANGE!
var const transient int KConstraintData;

// Export UKConstraint::execKUpdateConstraintParams(FFrame&, void* const)
// This function is used to re-sync constraint parameters (eg. stiffness) with Karma.
// Call when you change a parameter to get it to actually take effect.
native function KUpdateConstraintParams();

// Export UKConstraint::execKGetConstraintForce(FFrame&, void* const)
native final function KGetConstraintForce(out Vector Force);

// Export UKConstraint::execKGetConstraintTorque(FFrame&, void* const)
native final function KGetConstraintTorque(out Vector Torque);

// Event triggered when magnitude of constraint (linear) force exceeds KForceThreshold
event KForceExceed(float forceMag)
{
	return;
}

defaultproperties
{
	bKDisableCollision=true
	KPriAxis1=(X=1.0000000,Y=0.0000000,Z=0.0000000)
	KSecAxis1=(X=0.0000000,Y=1.0000000,Z=0.0000000)
	KPriAxis2=(X=1.0000000,Y=0.0000000,Z=0.0000000)
	KSecAxis2=(X=0.0000000,Y=1.0000000,Z=0.0000000)
	DrawType=1
	bHidden=true
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
	bProjTarget=false
	bBlockKarma=false
	Texture=Texture'Engine.S_KConstraint'
}
