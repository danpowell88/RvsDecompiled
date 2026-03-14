//=============================================================================
//  R6CoverSpot.uc : Place where AI can go to take cover from fire
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/08 * Created by Guillaume Borgia
//=============================================================================
class R6CoverSpot extends NavigationPoint
    native
    notplaceable;

#exec OBJ LOAD FILE=..\Textures\R6Engine_T.utx PACKAGE=R6Engine_T

// --- Constants ---
const C_iPawnPeekingRadius =  60;
const C_iPawnRadius =  40;

// --- Enums ---
enum ECoverShotDir
{
    COVERDIR_Over,
    COVERDIR_Left,
    COVERDIR_Right
};

// --- Variables ---
var ECoverShotDir m_eShotDir;

defaultproperties
{
}
