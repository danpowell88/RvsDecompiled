// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuOptionsGame extends R6MenuOptionsTab;

// --- Variables ---
var R6WindowTextureBrowser m_pAutoAim;
var R6WindowHScrollbar m_pOptionMouseSens;
var R6WindowButtonBox m_pOptionAlwaysRun;
var R6WindowButtonBox m_pOptionInvertMouse;
var R6WindowButtonBox m_pPopUpLoadPlan;
var R6WindowButtonBox m_pPopUpQuickPlay;
var Region m_pAutoAimTextReg[4];
var Texture m_pAutoAimTexture;
var int m_iRefMouseSens;

// --- Functions ---
function RestoreDefaultValue() {}
function InitPageOptions() {}
function Notify(UWindowDialogControl C, byte E) {}
function UpdateOptionsInEngine() {}
function UpdateOptionsInPage() {}

defaultproperties
{
}
