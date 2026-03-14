// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Window.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6WindowPageSwitch extends UWindowDialogClientWindow;

// --- Variables ---
var R6WindowButton m_pPreviousButton;
var R6WindowButton m_pNextButton;
var int m_iCurrentPages;
var int m_iTotalPages;
var R6WindowTextLabel m_pPageInfo;
var int m_iButtonWidth;
var int m_iButtonHeight;

// --- Functions ---
//===============================================================
// Set the text label param
//===============================================================
function SetLabelText(Color _vTextColor, Font _TextFont, string _szText) {}
//===============================================================
// Set button tool tip string, the same tip for the two button!
//===============================================================
function SetButtonToolTip(string _szRightToolTip, string _szLeftToolTip) {}
//------------------------------------------------------------------
//
//
//------------------------------------------------------------------
function SetTotalPages(int iPage) {}
//------------------------------------------------------------------
//
//
//------------------------------------------------------------------
function SetCurrentPage(int iPage) {}
//------------------------------------------------------------------
//
//
//------------------------------------------------------------------
function UpdatePageNb() {}
//===============================================================
// notify and notify parent if m_bAdviceParent is true
//===============================================================
function Notify(byte E, UWindowDialogControl C) {}
function PreviousPage() {}
function NextPage() {}
//===============================================================
// Create the two buttons (- and +) plus the text label in the center
//===============================================================
function CreateButtons() {}
function Created() {}

defaultproperties
{
}
