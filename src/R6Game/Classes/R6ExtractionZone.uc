//=============================================================================
//  R6ExtractionZone.uc : Trigger volume marking an extraction area; fires events when players or hostages
//                        enter or leave the zone.
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
