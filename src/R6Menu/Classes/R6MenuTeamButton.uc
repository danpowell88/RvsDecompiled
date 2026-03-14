//=============================================================================
//  R6MenuTeamButton.uc : Coloured team-select button in the planning bar; displays a team-colour dot and activates that team when clicked.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuTeamButton extends R6WindowButton;

// --- Variables ---
var Region m_DotRegion;
var int m_iTeamColor;
var Texture m_DotTexture;

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}
function LMouseDown(float Y, float X) {}
function Tick(float fDelta) {}
function BeforePaint(float Y, float X, Canvas C) {}
function Created() {}

defaultproperties
{
}
