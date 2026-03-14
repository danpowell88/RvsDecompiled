//=============================================================================
//  R61stHandsGripHBS.uc
//=============================================================================
class R61stHandsGripHBS extends R6AbstractFirstPersonHands;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

// --- Functions ---
function PostBeginPlay() {}

state RaiseWeapon
{
    simulated event AnimEnd(int Channel) {}
}

state BringWeaponUp
{
    simulated event AnimEnd(int Channel) {}
}

state Waiting
{
}

state DiscardWeapon
{
    simulated function BeginState() {}
}

state PutWeaponDown
{
    simulated function BeginState() {}
}

defaultproperties
{
}
