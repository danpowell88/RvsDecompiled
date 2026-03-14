//=============================================================================
//  R6ShadowProjector.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/21 * Created by Jean-Francois Dube
//=============================================================================
class R6ShadowProjector extends Projector;

#exec OBJ LOAD FILE=..\Textures\Inventory_t.utx PACKAGE=Inventory_t.Shadow

// --- Variables ---
var bool m_bAttached;

// --- Functions ---
function PostBeginPlay() {}
simulated function Tick(float DeltaTime) {}
event UpdateShadow() {}

defaultproperties
{
}
