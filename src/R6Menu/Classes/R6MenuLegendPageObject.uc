//=============================================================================
//  R6MenuLegendPageObject.uc : Legend page listing map objects and markers that appear on the mission planning map.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/29 * Created by Joel Tremblay
//=============================================================================
class R6MenuLegendPageObject extends R6MenuLegendPage;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

// --- Functions ---
function Created() {}

defaultproperties
{
}
