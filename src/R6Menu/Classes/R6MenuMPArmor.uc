// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuMPArmor extends UWindowDialogControl;

// --- Variables ---
var R6WindowButtonGear m_2DArmor;
var R6WindowButtonGear m_2DArmorRed;

// --- Functions ---
function SetArmorBorderColor(UWindowDialogControl _ArmorButton, byte E) {}
function SetButtonsStatus(bool _bDisable, bool _bRedTeam) {}
function SetArmorTexture(Region R, Texture t, bool _bRedTeam) {}
function ForceMouseOver(bool _bForceMouseOver) {}
function SetHighLightGreenArmor(bool _bHighLight) {}
function SetHighLightRedArmor(bool _bHighLight) {}
function Register(UWindowDialogClientWindow W) {}
function bool IsGreenArmorSelect() {}
function bool IsRedArmorSelect() {}
function Created() {}

defaultproperties
{
}
