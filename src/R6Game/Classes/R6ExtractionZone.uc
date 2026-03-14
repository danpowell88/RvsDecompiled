//=============================================================================
//  R6ExtractionZone.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/12 * Created by Chaouky Garram
//=============================================================================
class R6ExtractionZone extends R6AbstractExtractionZone;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

// --- Functions ---
function Touch(Actor Other) {}
function UnTouch(Actor Other) {}

defaultproperties
{
}
