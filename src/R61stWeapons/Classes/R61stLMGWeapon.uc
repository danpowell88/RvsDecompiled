//===============================================================================
//  [R61stLMGWeapon] 
//===============================================================================
class R61stLMGWeapon extends R6AbstractFirstPersonWeapon;

// --- Variables ---
var R61stWeaponStaticMesh m_Bullets[8];
var name m_FireBurstEnd;
var name m_FireBurstCycle;
var name m_FireBurstBegin;
var name m_BipodFireBurstEnd;
var name m_BipodFireBurstBegin;
var name m_BipodFireBurstCycle;
var StaticMesh m_2Wing;
var StaticMesh m_LWing;
var StaticMesh m_RWing;

// --- Functions ---
function PostBeginPlay() {}
function DestroyBullets() {}
function ShowBullets() {}
function HideBullet(int iWhichBullet) {}
function PlayFireAnim() {}
function PlayFireLastAnim() {}
function LoopWeaponBurst() {}
function StartWeaponBurst() {}
function StopWeaponBurst() {}

defaultproperties
{
}
