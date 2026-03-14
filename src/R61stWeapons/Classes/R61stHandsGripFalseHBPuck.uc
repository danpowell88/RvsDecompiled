//=============================================================================
//  R61stHandsGripFalseHBPuck.uc
//=============================================================================
class R61stHandsGripFalseHBPuck extends R61stHandsGripGrenade;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

// --- Functions ---
function PostBeginPlay() {}

state RaiseWeapon
{
    simulated function BeginState() {}
}

defaultproperties
{
}
