//===============================================================================
//  [R6AbstractFirstPersonHands] 
//===============================================================================
class R6AbstractFirstPersonHands extends R6AbstractFirstPersonWeapon
    abstract;

// --- Variables ---
var R6AbstractFirstPersonWeapon AssociatedWeapon;
var bool bShowLog;
// use weapon bipod animation
var bool m_bBipodDeployed;
// once this animation calls anim end qe can quit the state
var bool m_bCanQuitOnAnimEnd;
// this is true while the hands are firing a burst
var bool m_bInBurst;
var float m_fAnimAcceleration;
// If this is false, fireEmpty does not do anything
var bool m_bCannotPlayEmpty;
var name m_HandFire;
var name m_WalkAnim;
// hands are playing a waiting anim
var bool m_bPlayWaitAnim;
var bool bPlayerWalking;
var name m_HandBipodFire;
var name m_WaitAnim1;
var name m_HandBipodReloadEmpty;
var name m_HandReloadEmpty;
var name m_WaitAnim2;
var name m_HandFireLast;
var R6AbstractGadget AssociatedGadget;

// --- Functions ---
function PostBeginPlay() {}
simulated function SetAssociatedGadget(R6AbstractGadget AGadget) {}
simulated function SetAssociatedWeapon(R6AbstractFirstPersonWeapon AWeapon) {}
function ResetNeutralAnim() {}
function PlayWalkingAnimation() {}
function StopWalkingAnimation() {}

state FiringWeapon
{
    function AnimEnd(int iChannel) {}
    function EndState() {}
    function FireEmpty() {}
    function FireSingleShot() {}
    //The original BeginState, for wait Anims()
    function BeginState() {}
    function StopFiring() {}
    function InterruptFiring() {}
    function FireLastBullet() {}
    function FireThreeShots() {}
    function StartBurst() {}
}

state DiscardWeapon
{
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
    simulated event AnimEnd(int Channel) {}
}

state Waiting
{
    simulated function Timer() {}
    function StartTimer() {}
    event AnimEnd(int iChannel) {}
    function StopTimer() {}
    simulated function EndState() {}
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
}

state RaiseWeapon
{
    simulated event AnimEnd(int Channel) {}
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
}

state PutWeaponDown
{
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
    simulated event AnimEnd(int Channel) {}
}

state BringWeaponUp
{
    simulated event AnimEnd(int Channel) {}
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
}

state Reloading
{
    simulated event AnimEnd(int Channel) {}
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
    function EndState() {}
}

state HandsDown
{
    simulated function EndState() {}
    event AnimEnd(int iChannel) {}
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
}

state DeployBipod
{
    event AnimEnd(int iChannel) {}
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
    function EndState() {}
}

state CloseBipod
{
    simulated function EndState() {}
    event AnimEnd(int iChannel) {}
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
}

state ZoomIn
{
    event AnimEnd(int iChannel) {}
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
}

state ZoomOut
{
    event AnimEnd(int iChannel) {}
    //The original BeginState, for wait Anims()
    simulated function BeginState() {}
}

defaultproperties
{
}
