// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuUbiComModsWidget extends R6MenuWidget;

// --- Constants ---
const C_fHEIGHT_OF_LABELW =  30;
const C_fWINDOWHEIGHT =  321;
const C_fWINDOWWIDTH =  422;
const C_fYSTARTPOS =  92;
const C_fXSTARTPOS =  189;

// --- Variables ---
var R6WindowButton m_ButtonReturnUbiCom;
var R6WindowButton m_ButtonQuit;
var R6WindowSimpleFramedWindowExt m_pOptionsBorder;
var R6WindowTextLabel m_LMenuTitle;
var R6WindowTextLabelCurved m_pOptionsTextLabel;
var R6MenuOptionsMODSExt m_pListOfMods;

// --- Functions ---
function Notify(UWindowDialogControl C, byte E) {}
function Paint(Canvas C, float Y, float X) {}
function ShowWindow() {}
function Created() {}

defaultproperties
{
}
