// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Window.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6WindowPopUpBoxCW extends UWindowDialogClientWindow;

// --- Constants ---
const C_fBUT_HEIGHT =  17;

// --- Variables ---
var R6WindowPopUpButton m_pCancelButton;
// ^ NEW IN 1.60
var R6WindowPopUpButton m_pOKButton;
// ^ NEW IN 1.60
var R6WindowButtonBox m_pDisablePopUpButton;
var MessageBoxResult EnterResult;
var MessageBoxButtons Buttons;
var MessageBoxResult ESCResult;
// ^ NEW IN 1.60

// --- Functions ---
function SetupPopUpBoxClient(optional MessageBoxResult InEnterResult, MessageBoxResult InESCResult, MessageBoxButtons InButtons) {}
function KeyDown(int Key, float Y, float X) {}
function Notify(UWindowDialogControl C, byte E) {}
function AddDisablePopUpButton() {}
function RemoveDisablePopUpButton() {}
function Resized() {}

defaultproperties
{
}
