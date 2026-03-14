//=============================================================================
//  R6ClaymoreGadget.uc : Inventory item representing a claymore mine gadget slot.
//  Extends R6DemolitionsGadget; spawns R6Claymore actors when the player places a mine.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/06 * Created by Rima Brek
//=============================================================================
class R6ClaymoreGadget extends R6DemolitionsGadget;

// --- Functions ---
function PlaceChargeAnimation() {}
delegate ServerPlaceChargeAnimation() {}
function SetAmmoStaticMesh() {}

defaultproperties
{
}
