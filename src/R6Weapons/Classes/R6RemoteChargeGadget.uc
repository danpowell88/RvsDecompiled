//=============================================================================
//  R6RemoteChargeGadget : Inventory item for the remote-detonated charge gadget slot.
//  Extends R6DemolitionsGadget; manages placing R6RemoteCharge actors and the detonator trigger.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/04 * Created by Rima Brek
//=============================================================================
class R6RemoteChargeGadget extends R6DemolitionsGadget;

// --- Functions ---
function PlaceChargeAnimation() {}
delegate ServerPlaceChargeAnimation() {}
function SetAmmoStaticMesh() {}

defaultproperties
{
}
