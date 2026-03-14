//=============================================================================
//  [R6HBSSAJammerGadget.uc] Heart Beat Sensor Stant Alone Jammer Gadget
//=============================================================================
class R6HBSSAJammerGadget extends R6DemolitionsGadget;

// --- Functions ---
function Fire(float fValue) {}
delegate ServerPlaceCharge(Vector vLocation) {}
simulated function PlaceChargeAnimation() {}
delegate ServerPlaceChargeAnimation() {}
function SetAmmoStaticMesh() {}
simulated event HideAttachment() {}
event NbBulletChange() {}
function bool CanSwitchToWeapon() {}
// ^ NEW IN 1.60

state NoChargesLeft
{
    function BeginState() {}
}

state ArmingCharge
{
    function Timer() {}
    function Fire(float fValue) {}
    function BeginState() {}
    function FirstPersonAnimOver() {}
}

state GetNextCharge
{
    function BeginState() {}
    function FirstPersonAnimOver() {}
    function Timer() {}
}

state RaiseWeapon
{
    function FirstPersonAnimOver() {}
    simulated function BeginState() {}
    simulated function EndState() {}
}

defaultproperties
{
}
