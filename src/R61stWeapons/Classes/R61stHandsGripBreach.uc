//=============================================================================
//  R61stHandsGripBreach.uc : First-person hand/grip animation for breaching charge placement.
//  Extends R6AbstractFirstPersonHands; drives the FiringWeapon state during charge deployment.
//=============================================================================
class R61stHandsGripBreach extends R6AbstractFirstPersonHands;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

// --- Functions ---
function PostBeginPlay() {}

state FiringWeapon
{
    function AnimEnd(int iChannel) {}
}

defaultproperties
{
}
