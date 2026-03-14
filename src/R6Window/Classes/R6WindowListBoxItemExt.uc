// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Window.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6WindowListBoxItemExt extends UWindowListBoxItem;

// --- Structs ---
struct stItemDesc
{
    var string szText;
    var float fXPos;
    var float fHeigth;
    var int iLineNumber;
    var float fWidth;
    var bool bDisplay;
    var TextAlign eAlignment;
    var float fYPos;
    var Font TextFont;
    var string szMisc;
};

// --- Variables ---
var array<array> m_AItemDesc;
var stItemDesc m_DescTemp;

// --- Functions ---
function SetItemParam(int _index, stItemDesc _ItemParam) {}
function bool SetItemDescriptionIndex(int _iIndex) {}
function string GetItemText(int _iIndex) {}
function string GetItemMisc(int _iIndex) {}
function HideLine(int _iLineNb) {}
function SetItemParameters(int _index, optional TextAlign _eAlignement, int _iLineNumber, float _fH, float _fW, float _fY, float _fX, Font _TextFont, string _szText) {}
function SetItemText(int _index, string _szText) {}
function SetItemMisc(int _index, string _szMisc) {}
function int Compare(UWindowList B, UWindowList t) {}
function ClearItem() {}

defaultproperties
{
}
