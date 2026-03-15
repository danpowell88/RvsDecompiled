//=============================================================================
// KHinge - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// The Hinge joint class.
//=============================================================================

#exec Texture Import File=Textures\S_KHinge.pcx Name=S_KHinge Mips=Off MASKED=1
class KHinge extends KConstraint
    native
    placeable;

enum EHingeType
{
	HT_Normal,                      // 0
	HT_Springy,                     // 1
	HT_Motor,                       // 2
	HT_Controlled                   // 3
};

// NEW IN 1.60
var(KarmaConstraint) KHinge.EHingeType KHingeType;
var bool KUseAltDesired;
// SPRINGY - around hinge axis, default position being KDesiredAngle (below)
var(KarmaConstraint) float KStiffness;
var(KarmaConstraint) float KDamping;
// MOTOR - tries to achieve angular velocity
var(KarmaConstraint) float KDesiredAngVel;  // 65535 = 1 rotation per second
var(KarmaConstraint) float KMaxTorque;
// CONTROLLED - achieve a certain angle
// Uses AngularVelocity and MaxForce from above.
// Within 'ProportionalGap' of DesiredAngle, 
var(KarmaConstraint) float KDesiredAngle;  // 65535 = 360 degrees
var(KarmaConstraint) float KProportionalGap;  // 65535 = 360 degrees
// This is the alternative 'desired' angle, and the bool that indicates whether to use it.
// See ToggleDesired and ControlDesired below.
var(KarmaConstraint) float KAltDesiredAngle;  // 65535 = 360 degrees
// output - current angular position of joint // 65535 = 360 degrees
var const float KCurrentAngle;

auto state Default
{	stop;
}

state() ToggleMotor
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x2E
		if((int(KHingeType) == int(2)))
		{
			KDesiredAngle = KCurrentAngle;
			KUseAltDesired = false;
			KHingeType = 3;			
		}
		else
		{
			KHingeType = 2;
		}
		KUpdateConstraintParams();
		KConstraintActor1.KWake();
		return;
	}
Begin:

	KHingeType = 3;
	KUseAltDesired = false;
	KUpdateConstraintParams();
	stop;	
}

state() ControlMotor
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x2D
		if((int(KHingeType) != int(2)))
		{
			KHingeType = 2;
			KUpdateConstraintParams();
			KConstraintActor1.KWake();
		}
		return;
	}

	function UnTrigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x40
		if((int(KHingeType) == int(2)))
		{
			KDesiredAngle = KCurrentAngle;
			KUseAltDesired = false;
			KHingeType = 3;
			KUpdateConstraintParams();
			KConstraintActor1.KWake();
		}
		return;
	}
Begin:

	KHingeType = 3;
	KUseAltDesired = false;
	KUpdateConstraintParams();
	stop;	
}

state() ToggleDesired
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x14
		if(KUseAltDesired)
		{
			KUseAltDesired = false;			
		}
		else
		{
			KUseAltDesired = true;
		}
		KUpdateConstraintParams();
		KConstraintActor1.KWake();
		return;
	}
	stop;
}

state() ControlDesired
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		KUseAltDesired = true;
		KUpdateConstraintParams();
		KConstraintActor1.KWake();
		return;
	}

	function UnTrigger(Actor Other, Pawn EventInstigator)
	{
		KUseAltDesired = false;
		KUpdateConstraintParams();
		KConstraintActor1.KWake();
		return;
	}
	stop;
}

defaultproperties
{
	KStiffness=50.0000000
	KProportionalGap=8200.0000000
	bDirectional=true
	Texture=Texture'Engine.S_KHinge'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var EHingeType
