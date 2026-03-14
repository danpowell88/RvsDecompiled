//------------------------------------------------------------------
// R6ClimbableObject: an object that can be climbed by pawn.
//	An R6ClimbableObject as an orientation that shows the
//  direction of the climbing. They are meant to be used to climb
//  and then go on another box/level/new edge. I have not tested
//  the code when the R6ClimbableObject is placed alone. To use
//  those kind
//------------------------------------------------------------------
class R6ClimbableObject extends R6AbstractClimbableObj
    native;

#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons

// --- Enums ---
enum EClimbHeight 
{
    EClimbNone,
    EClimb64,
    EClimb96,
};
enum eClimbableObjectCircumstantialAction
{
    COBJ_None,
    COBJ_Climb
};

// --- Variables ---
var /* replicated */ Vector m_vClimbDir;
var /* replicated */ R6ClimbablePoint m_climbablePoint;
var R6ClimbablePoint m_insideClimbablePoint;
var /* replicated */ EClimbHeight m_eClimbHeight;
// ^ NEW IN 1.60

// --- Functions ---
event Attach(Actor pActor) {}
event Detach(Actor pActor) {}
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60
event Bump(Actor Other) {}
simulated event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController, float fDistance) {}
simulated function bool IsClimbableBy(R6Pawn P, bool bCheckCylinderTranslation, bool bCheckRotation) {}
// ^ NEW IN 1.60
function PostBeginPlay() {}

defaultproperties
{
}
