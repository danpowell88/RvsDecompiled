// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuOptionsGraphic extends R6MenuOptionsTab;

// --- Constants ---
const C_szEGameOptionsGraphicLevel =  "EGameOptionsGraphicLevel";
const C_szEGameOptionsEffectLevel =  "EGameOptionsEffectLevel";
const C_iITEM_NONE =  0x01;
const C_iITEM_LOW =  0x02;
const C_iITEM_MEDIUM =  0x04;
const C_iITEM_HIGH =  0x08;
const C_iGORE_ITEMS =  0x0A;
const C_iSHADOW_ITEMS =  0x0B;
const C_iALL_ITEMS =  0x0F;

// --- Variables ---
var string m_pComboLevel[4];
var R6WindowComboControl m_pVideoRes;
var R6WindowButtonBox m_pLowDetailSmoke;
var R6WindowButtonBox m_pHideDeadBodies;
var R6WindowButtonBox m_pAnimGeometry;
var R6WindowComboControl m_pDecalsDetail;
var R6WindowComboControl m_pGoreLevel;
var R6WindowComboControl m_pTerrosShadowLevel;
var R6WindowComboControl m_pHostagesShadowLevel;
var R6WindowComboControl m_pRainbowsShadowLevel;
var R6WindowComboControl m_pTextureDetail;
var R6WindowComboControl m_pLightmapDetail;
var R6WindowComboControl m_pRainbowsDetail;
var R6WindowComboControl m_pHostagesDetail;
var R6WindowComboControl m_pTerrosDetail;
var bool m_bUpdateFileOnly;

// --- Functions ---
function RestoreDefaultValue() {}
function InitPageOptions() {}
function UpdateOptionsInPage() {}
function UpdateOptionsInEngine() {}
function string ConvertToGraphicString(int _iAddItemMask, string _szGraphicsEnumName, optional bool _bCheckFor32MegVideoCard, int _iValueToConvert) {}
function GetResolutionXY(out int iSY, out int iRR, out int iSX) {}
function Notify(UWindowDialogControl C, byte E) {}
function EGameOptionsEffectLevel ConvertToELEnum(string _szValueToConvert) {}
function EGameOptionsGraphicLevel ConvertToGLEnum(string _szValueToConvert) {}
function AddGraphComboControlItem(int _iAddItemMask, R6WindowComboControl _pR6WindowComboControl, optional bool _bCheckFor32MegVideoCard, string _szGraphicsEnumName) {}
function AddVideoResolution(R6WindowComboControl _pR6WindowComboControl) {}
function Created() {}

defaultproperties
{
}
