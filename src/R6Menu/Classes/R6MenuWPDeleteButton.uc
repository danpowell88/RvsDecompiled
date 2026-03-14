//=============================================================================
//  R6MenuWPDeleteButton.uc : Button that deletes the currently selected waypoint node from the active team's mission plan route.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuWPDeleteButton extends R6WindowButton;

#exec OBJ LOAD FILE=..\Textures\R6MenuTextures.utx PACKAGE=R6MenuTextures

// --- Functions ---
function LMouseDown(float Y, float X) {}
simulated function Click(float Y, float X) {}
function Tick(float fDeltaTime) {}
function BeforePaint(float Y, float X, Canvas C) {}
function Created() {}

defaultproperties
{
}
