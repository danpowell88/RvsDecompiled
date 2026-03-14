// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuOptionsMulti extends R6MenuOptionsTab;

// --- Variables ---
var string m_pConnectionSpeed[5];
var R6WindowEditControl m_pOptionPlayerName;
var R6MenuArmpatchSelect m_pArmpatchChooser;
var R6WindowButtonBox m_pPunkBusterOpt;
var R6WindowComboControl m_pSpeedConnection;
var R6WindowButtonExt m_pOptionGender;
var Region m_RArmpatchListPos;
var R6WindowButtonBox m_bTriggerLagWanted;
var Region m_RArmpatchBitmapPos;
var bool m_bPBWaitForInit;
var bool m_bPBNotInstalled;

// --- Functions ---
function RestoreDefaultValue() {}
function ManageNotifyForNetwork(UWindowDialogControl C, byte E) {}
function InitPageOptions() {}
function UpdateOptionsInPage() {}
function Notify(UWindowDialogControl C, byte E) {}
function UpdateOptionsInEngine() {}
function EGameOptionsNetSpeed ConvertToNSEnum(string _szValueToConvert) {}
function string ConvertToNetSpeedString(int _iValueToConvert) {}
function SetPBOptValue() {}
function Created() {}
function SetPBOptDisable() {}
function Tick(float DeltaTime) {}

defaultproperties
{
}
