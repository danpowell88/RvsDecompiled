//=============================================================================
// MatAction - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// MatAction: Base class for Matinee actions.
//=============================================================================
class MatAction extends MatObject
	abstract
 native;

var(R6Pawn) Actor.EPhysics m_PhysicsActor;  // Physics of the target Actor during the Action
var(Path) bool bSmoothCorner;  // true by default - when one control point is adjusted, other is moved to keep tangents the same
var(Path) bool bConstantPathVelocity;
//#ifdef R6CODE
var(R6Pawn) bool m_bCollideActor;  // If this Actor.bCollide==true during the action
var(Time) float Duration;  // How many seconds this action should take
var(Path) float PathVelocity;
var float PathLength;
var() InterpolationPoint IntPoint;  // The interpolation point that we want to move to/wait at.
//#ifdef R6MATINEE
var Texture Icon;  // The icon to use in the matinee UI
var(Sub) export editinline array<export editinline MatSubAction> SubActions;  // Sub actions are actions to perform while the main action is happening
var(Path) Vector StartControlPoint;  // Offset from the current interpolation point
var(Path) Vector EndControlPoint;  // Offset from the interpolation point we're moving to (InPointName)
var() string Comment;  // User can enter a comment here that will appear on the GUI viewport
var transient float PctStarting;
var transient float PctEnding;
var transient float PctDuration;
var transient array<Vector> SampleLocations;

event Initialize()
{
	return;
}

//This action must be overloaded to have a more customized behavior
event ActionStart(Actor Viewer)
{
	// End:0x1E
	if(__NFUN_242__(m_bCollideActor, true))
	{
		Viewer.__NFUN_262__(true, true, true);		
	}
	else
	{
		Viewer.__NFUN_262__(true, false, false);
	}
	Viewer.__NFUN_3970__(m_PhysicsActor);
	Viewer.bInterpolating = true;
	return;
}

defaultproperties
{
	bSmoothCorner=true
	StartControlPoint=(X=800.0000000,Y=800.0000000,Z=0.0000000)
	EndControlPoint=(X=-800.0000000,Y=-800.0000000,Z=0.0000000)
}
