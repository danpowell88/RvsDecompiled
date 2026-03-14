//=============================================================================
//  R6WindowButtonGear.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/15 * Created by Alexandre Dionne
//=============================================================================
class R6WindowButtonGear extends R6WindowButton;

// --- Variables ---
var Texture m_HighLightTexture;
var bool m_HighLight;
var float m_fAlpha;
// force a mouse over
var bool m_bForceMouseOver;

// --- Functions ---
function ForceMouseOver(bool _bForceMouseOver) {}
function Paint(Canvas C, float Y, float X) {}
function LMouseDown(float Y, float X) {}
function MMouseDown(float Y, float X) {}
function RMouseDown(float Y, float X) {}

defaultproperties
{
}
