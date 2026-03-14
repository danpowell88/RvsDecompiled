// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuOptionsHud extends R6MenuOptionsTab;

// --- Variables ---
var R6WindowButtonBox m_pHudWeaponName;
var R6WindowButtonBox m_pHudShowFPWeapon;
var R6WindowButtonBox m_pHudOtherTInfo;
var R6WindowButtonBox m_pHudCurTInfo;
var R6WindowButtonBox m_pHudCircumIcon;
var R6WindowButtonBox m_pHudWpInfo;
var R6WindowButtonBox m_pHudReticule;
var R6WindowButtonBox m_pHudShowTNames;
var R6WindowButtonBox m_pHudCharInfo;
var R6WindowButtonBox m_pHudShowRadar;
var R6WindowBitMap m_pHudShowRadarTex;
var R6WindowBitMap m_pHudShowTNamesTex;
var R6WindowBitMap m_pHudCharInfoTex;
var R6WindowBitMap m_pHudReticuleTex;
var R6WindowBitMap m_pHudWpInfoTex;
var R6WindowBitMap m_pHudCircumIconTex;
var R6WindowBitMap m_pHudCurTInfoTex;
var R6WindowBitMap m_pHudOtherTInfoTex;
var R6WindowBitMap m_pHudShowFPWeaponTex;
var R6WindowBitMap m_pHudWeaponNameTex;
var R6WindowBitMap m_pHudBGTex;

// --- Functions ---
function RestoreDefaultValue() {}
function InitPageOptions() {}
function UpdateOptionsInPage() {}
function UpdateOptionsInEngine() {}
function R6WindowBitMap CreateHudBitmapWindow(optional bool _bDrawSimpleBorder, Texture _Tex) {}
function Notify(UWindowDialogControl C, byte E) {}
function CreateHudOptionsTex() {}
function UpdateHudOptionsTex() {}

defaultproperties
{
}
