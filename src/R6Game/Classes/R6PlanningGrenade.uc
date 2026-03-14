//=============================================================================
//  R6PlanningGrenade.uc : Planning screen icon representing a grenade-throw action at an ActionPoint;
//                         displays different textures per grenade type.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/16 * Created by Chaouky Garram
//=============================================================================
class R6PlanningGrenade extends R6ReferenceIcons
    notplaceable;

// --- Variables ---
// List of the grenade icon texture
var Texture m_pIconTex[4];

// --- Functions ---
function SetGrenadeType(EPlanAction eGrenade) {}

defaultproperties
{
}
