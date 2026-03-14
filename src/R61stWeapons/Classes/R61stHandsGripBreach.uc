//=============================================================================
//  R61stHandsGripBreach.uc : (add small description)
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
