//=============================================================================
//  R6CrossReticule.uc : Simple cross reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CrossReticule extends R6Reticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

// --- Variables ---
var Texture m_LineTexture;
var const int c_iLineHeight;
var const int c_iLineWidth;

// --- Functions ---
// Speed gives us the current speed.
simulated function PostRender(Canvas C) {}

defaultproperties
{
}
