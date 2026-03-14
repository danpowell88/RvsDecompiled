//=============================================================================
//  R6ArmPatchGlow.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/12 * Created by Jean-Francois Dube
//=============================================================================
class R6ArmPatchGlow extends R6GlowLight;

#exec OBJ LOAD FILE="..\textures\Inventory_t.utx" Package="Inventory_t.ArmPatches"

// --- Variables ---
var float m_fMatrixMul;
var name m_AttachedBoneName;

// --- Functions ---
function Tick(float fDeltaTime) {}

defaultproperties
{
}
