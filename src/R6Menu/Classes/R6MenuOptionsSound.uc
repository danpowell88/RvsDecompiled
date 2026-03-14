// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuOptionsSound extends R6MenuOptionsTab;

// --- Variables ---
var R6WindowButtonBox m_pEAX;
var string m_pSndLocEnum[3];
var R6WindowHScrollbar m_pAmbientVolume;
var R6WindowHScrollbar m_pVoicesVolume;
var R6WindowHScrollbar m_pMusicVolume;
var R6WindowBitMap m_EaxLogo;
var string m_pComboLevel[4];
var R6WindowButtonBox m_pSndHardware;
var R6WindowComboControl m_pAudioVirtual;
var R6WindowComboControl m_pSndQuality;
var int m_iRefAmbientVolume;
var int m_iRefVoicesVolume;
var int m_iRefMusicVolume;
var bool m_bEAXNotSupported;
var Region m_EaxTextureReg;
var Texture m_EaxTexture;

// --- Functions ---
function RestoreDefaultValue() {}
function string ConvertToSndQualityString(int _iValue) {}
function int ConvertToSndQuality(string _szValue) {}
function InitPageOptions() {}
function ManageNotifyForSound(UWindowDialogControl C, byte E) {}
function Notify(UWindowDialogControl C, byte E) {}
function UpdateOptionsInPage() {}
function UpdateOptionsInEngine() {}
function EGameOptionsAudioVirtual ConvertToAVEnum(string _szValueToConvert) {}
function string ConvertToAudioString(int _iValueToConvert) {}
function Created() {}

defaultproperties
{
}
