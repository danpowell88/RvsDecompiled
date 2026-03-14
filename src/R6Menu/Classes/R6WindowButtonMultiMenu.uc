// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6WindowButtonMultiMenu extends R6WindowButton;

// --- Variables ---
var EButtonName m_eButton_Action;
var bool m_bButtonIsReady;
var Region m_ROverButton;
var Region m_ROverButtonFade;
var Texture m_TOverButton;

// --- Functions ---
function BeforePaint(float Y, float X, Canvas C) {}
function Paint(float Y, float X, Canvas C) {}
//=================================================================================
// Process the click
//=================================================================================
simulated function Click(float Y, float X) {}
function SetButLogInOutState(EButtonName _eNewButtonState) {}

defaultproperties
{
}
