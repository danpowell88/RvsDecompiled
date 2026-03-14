//=============================================================================
//  R6TacticalGlowLight.uc : Fading light depending on the view angle.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Jean-Francois Dube
//    2001/11/02 * Added net support (Aristo Kolokathis)
//=============================================================================
class R6TacticalGlowLight extends R6GlowLight;

#exec OBJ LOAD FILE="..\textures\Inventory_t.utx" Package="Inventory_t.TacticalLight"

defaultproperties
{
}
