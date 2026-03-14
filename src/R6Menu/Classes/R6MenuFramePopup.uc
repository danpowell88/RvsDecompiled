// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuFramePopup extends R6WindowFramedWindow;

// --- Variables ---
var int m_iTextureSize;
var R6WindowListRadioButton m_ButtonList;
//default width and height for popups windows
var int m_iFrameWidth;
var float m_fTitleBarHeight;
var bool m_bDisplayLeft;
var bool m_bDisplayUp;
var Texture m_Texture;
var float m_fTitleBarWidth;
var int m_iTeamColor;
var bool m_bInitialized;
var const int m_iNbButton;

// --- Functions ---
function AjustPosition(bool bDisplayUp, bool bDisplayLeft) {}
function Resized() {}
//Should be before created.  Or add a function to that only once.
function BeforePaint(Canvas C, float X, float Y) {}
function Paint(Canvas C, float X, float Y) {}
function ShowWindow() {}

defaultproperties
{
}
