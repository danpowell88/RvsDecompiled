//=============================================================================
//  R6GrenadeReticule.uc : Grenade reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/06 * Eric Begin				- Creation
//=============================================================================
class R6GrenadeReticule extends R6Reticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

// --- Variables ---
var Texture m_Circle;
var Texture m_Dot;

// --- Functions ---
// Speed gives us the current speed.
simulated function PostRender(Canvas C) {}

defaultproperties
{
}
