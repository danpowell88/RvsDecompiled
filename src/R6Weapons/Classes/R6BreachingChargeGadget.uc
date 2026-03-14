//=============================================================================
//  R6BreachingChargeGadget : Inventory item representing a breaching charge gadget slot.
//  Extends R6DemolitionsGadget; spawns R6BreachingCharge actors when placed by the player.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/04 * Created by Rima Brek
//=============================================================================
class R6BreachingChargeGadget extends R6DemolitionsGadget;

// --- Variables ---
var R6IORotatingDoor m_IORDoor;

// --- Functions ---
function NPCPlaceCharge(Actor aDoor) {}
function bool CharacterOnOtherSide() {}
// ^ NEW IN 1.60
simulated function Tick(float fDeltaTime) {}
function ServerSetDoor(R6IORotatingDoor aDoor) {}
function bool CanPlaceCharge() {}
// ^ NEW IN 1.60
delegate ServerDetonate() {}
simulated function PlaceChargeAnimation() {}
delegate ServerPlaceChargeAnimation() {}
function NPCDetonateCharge() {}
delegate ServerPlaceCharge(Vector vLocation) {}
function SetAmmoStaticMesh() {}
function Explode() {}
simulated function name GetFiringAnimName() {}
// ^ NEW IN 1.60

state ChargeReady
{
	// set timer for placing charge - check demolitions skill...
    function Timer() {}
}

defaultproperties
{
}
