//===============================================================================
//  [R6AbstractFirstPersonWeapon] 
//===============================================================================
class R6AbstractFirstPersonWeapon extends R6EngineFirstPersonWeapon
    native
    abstract;

// --- Variables ---
var name m_Neutral;
var name m_Fire;
var name m_Reload;
//reload anim with the bipod down
var name m_BipodReload;
var name m_FireLast;
//Bipod is down
var name m_BipodNeutral;
var name m_BipodReloadEmpty;
var name m_ReloadEmpty;
//Raise weapon & Put the bipod down, if any
var name m_BipodRaise;
var bool m_bWeaponBipodDeployed;
var name m_FireEmpty;
//Bring the bipod up
var name m_BipodDeploy;
//First Person gun as static Mesh
var Actor m_smGun;
var name m_Empty;
//Close bipod, and lower weapon
var name m_BipodDiscard;
//Put the bipod down, if any
var name m_BipodClose;
//If the weapon has more than one static mesh.
var Actor m_smGun2;
var bool m_bReloadEmpty;
var name m_WeaponNeutralAnim;

// --- Functions ---
function DestroySM() {}
function StopFiring() {}
function InterruptFiring() {}
function FireEmpty() {}
function FireLastBullet() {}
function FireSingleShot() {}
function FireThreeShots() {}
function LoopBurst() {}
function StartBurst() {}
function StopTimer() {}
function StartTimer() {}
function FireGrenadeThrow() {}
function FireGrenadeRoll() {}
function DestroyBullets() {}
function StartWeaponBurst() {}
function LoopWeaponBurst() {}
function StopWeaponBurst() {}
function PlayWalkingAnimation() {}
function StopWalkingAnimation() {}
function ResetNeutralAnim() {}
simulated function SwitchFPMesh() {}
simulated function SwitchFPAnim() {}
simulated function SetAssociatedWeapon(R6AbstractFirstPersonWeapon AWeapon) {}
// LMG functions
function HideBullet(int iWhichBullet) {}
function PlayFireAnim() {}
function PlayFireLastAnim() {}
simulated function PostBeginPlay() {}
simulated event Destroyed() {}

state Reloading
{
    function BeginState() {}
}

defaultproperties
{
}
