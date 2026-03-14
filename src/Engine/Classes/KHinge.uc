//=============================================================================
// The Hinge joint class.
//=============================================================================
class KHinge extends KConstraint
    native;

#exec Texture Import File=Textures\S_KHinge.pcx Name=S_KHinge Mips=Off MASKED=1

// --- Enums ---
enum EHingeType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var EHingeType KHingeType;
// ^ NEW IN 1.60
// This is the alternative 'desired' angle, and the bool that indicates whether to use it.
// See ToggleDesired and ControlDesired below.
var bool KUseAltDesired;
// output - current angular position of joint // 65535 = 360 degrees
var const float KCurrentAngle;
var float KDesiredAngle;
// ^ NEW IN 1.60
var float KStiffness;
// ^ NEW IN 1.60
var float KDamping;
// ^ NEW IN 1.60
var float KDesiredAngVel;
// ^ NEW IN 1.60
var float KMaxTorque;
// ^ NEW IN 1.60
var float KProportionalGap;
// ^ NEW IN 1.60
var float KAltDesiredAngle;
// ^ NEW IN 1.60

state Default
{
}

state ToggleMotor
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
}

state ControlMotor
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
    function UnTrigger(Actor Other, Pawn EventInstigator) {}
// ^ NEW IN 1.60
}

state ToggleDesired
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
}

state ControlDesired
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
    function UnTrigger(Actor Other, Pawn EventInstigator) {}
// ^ NEW IN 1.60
}

defaultproperties
{
}
