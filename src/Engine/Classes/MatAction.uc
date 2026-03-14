//=============================================================================
// MatAction: Base class for Matinee actions.
//=============================================================================
class MatAction extends MatObject
    native
    abstract;

// --- Variables ---
var EPhysics m_PhysicsActor;
// ^ NEW IN 1.60
var bool m_bCollideActor;
// ^ NEW IN 1.60
var InterpolationPoint IntPoint;
// ^ NEW IN 1.60
var string Comment;
// ^ NEW IN 1.60
var float Duration;
// ^ NEW IN 1.60
var array<array> SubActions;
// ^ NEW IN 1.60
var bool bSmoothCorner;
// ^ NEW IN 1.60
var Vector StartControlPoint;
// ^ NEW IN 1.60
var Vector EndControlPoint;
// ^ NEW IN 1.60
var bool bConstantPathVelocity;
// ^ NEW IN 1.60
var float PathVelocity;
// ^ NEW IN 1.60
var float PathLength;
var transient array<array> SampleLocations;
var transient float PctStarting;
var transient float PctEnding;
var transient float PctDuration;
//#ifdef R6MATINEE
//The icon to use in the matinee UI
var Texture Icon;

// --- Functions ---
//This action must be overloaded to have a more customized behavior
event ActionStart(Actor Viewer) {}
event Initialize() {}

defaultproperties
{
}
