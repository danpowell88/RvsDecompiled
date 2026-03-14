//=============================================================================
//  R6WithWeaponReticule.uc : Simple cross reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6WithWeaponReticule extends R6Reticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

// --- Variables ---
var Texture m_LineTexture;
var const int c_iLineWidth;
var const int c_iLineHeight;

// --- Functions ---
// Speed gives us the current speed.
simulated function PostRender(Canvas C) {}

defaultproperties
{
}
