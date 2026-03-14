//=============================================================================
//  R6MenuTeamDisplayButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuTeamDisplayButton extends R6WindowButton;

// --- Variables ---
var Region m_ActiveRegion;
var int m_iTeamColor;
var Texture m_ActiveTexture;

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}
function LMouseDown(float Y, float X) {}
function Tick(float fDelta) {}
function BeforePaint(float Y, float X, Canvas C) {}
function Created() {}

defaultproperties
{
}
