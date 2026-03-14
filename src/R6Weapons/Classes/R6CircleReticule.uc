//=============================================================================
//  R6CircleReticule.uc : Simple circular reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CircleReticule extends R6CrossReticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

// --- Variables ---
var Texture m_Circle;
// This is the size that we want the texture has when we are at the best accuracy
var float m_fBaseReticuleHeight;

// --- Functions ---
// Speed gives us the current speed.
simulated function PostRender(Canvas C) {}

defaultproperties
{
}
