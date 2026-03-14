//=============================================================================
//  R61stHandsGripC4.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/05 * Created by Rima Brek
//=============================================================================
class R61stHandsGripC4 extends R6AbstractFirstPersonHands;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

// --- Functions ---
function PostBeginPlay() {}

state DiscardWeapon
{
    simulated event AnimEnd(int Channel) {}
    function Timer() {}
    simulated function BeginState() {}
}

state DiscardWeaponAfterFire
{
    simulated event AnimEnd(int Channel) {}
    function Timer() {}
    simulated function BeginState() {}
}

state FiringWeapon
{
    function AnimEnd(int iChannel) {}
}

defaultproperties
{
}
