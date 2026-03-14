//=============================================================================
//  R6Gadget.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/05 * Created by Rima Brek
//=============================================================================
class R6Gadget extends R6Weapons
    native
    abstract;

// --- Functions ---
simulated function DisableWeaponOrGadget() {}
function GiveMoreAmmo() {}
function SetHoldAttachPoint() {}
simulated function TurnOffEmitters(bool bTurnOff) {}

defaultproperties
{
}
