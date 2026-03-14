//=============================================================================
//  R6CircleDotReticule.uc : Circular reticule with a dot
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CircleDotReticule extends R6CircleReticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

// --- Variables ---
var Texture m_Dot;

// --- Functions ---
simulated function PostRender(Canvas C) {}

defaultproperties
{
}
