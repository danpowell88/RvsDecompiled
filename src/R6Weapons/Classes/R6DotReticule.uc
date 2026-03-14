//=============================================================================
//  R6DotReticule.uc : Basic Dot reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/18 * Rima Brek				- Creation
//=============================================================================
class R6DotReticule extends R6Reticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

// --- Variables ---
var Texture m_Dot;

// --- Functions ---
simulated function PostRender(Canvas C) {}

defaultproperties
{
}
