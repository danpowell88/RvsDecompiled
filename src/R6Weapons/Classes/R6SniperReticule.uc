//=============================================================================
//  R6SniperReticule.uc : Reticle for sniper rifle
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/30 * Joel Tremblay				- Creation
//=============================================================================
class R6SniperReticule extends R6CrossReticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

// --- Variables ---
var Texture m_FixedPart;

// --- Functions ---
// Speed gives us the current speed.
simulated function PostRender(Canvas C) {}

defaultproperties
{
}
