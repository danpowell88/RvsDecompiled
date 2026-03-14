//=============================================================================
//  R6MenuLegendPageActions.uc : Legend page listing all available operative planning actions (e.g. breach, snipe) with icons and descriptions.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/29 * Created by Joel Tremblay
//=============================================================================
class R6MenuLegendPageActions extends R6MenuLegendPage;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

// --- Functions ---
function Created() {}

defaultproperties
{
}
