//===============================================================================
//  [R61stHandsGripGrenade ] 
//===============================================================================
class R61stHandsGripGrenade extends R6AbstractFirstPersonHands;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

// --- Functions ---
function PostBeginPlay() {}

state RaiseWeapon
{
    simulated function BeginState() {}
}

state FiringWeapon
{
    simulated function AnimEnd(int iChannel) {}
    function EndState() {}
    function FireEmpty() {}
    function BeginState() {}
    simulated function FireGrenadeThrow() {}
    simulated function FireGrenadeRoll() {}
    simulated function FireSingleShot() {}
}

state Waiting
{
    simulated function Timer() {}
}

defaultproperties
{
}
