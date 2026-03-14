//=============================================================================
// UWindowButton - A button
//=============================================================================
class UWindowButton extends UWindowDialogControl;

// --- Variables ---
var bool bDisabled;
var Region UpRegion;
// ^ NEW IN 1.60
var Region OverRegion;
var Region DownRegion;
// ^ NEW IN 1.60
var Region DisabledRegion;
// ^ NEW IN 1.60
var float ImageY;
var float ImageX;
// ^ NEW IN 1.60
var Texture DownTexture;
// ^ NEW IN 1.60
var Texture DisabledTexture;
// ^ NEW IN 1.60
var Texture UpTexture;
// ^ NEW IN 1.60
var Texture OverTexture;
var bool bUseRegion;
var float RegionScale;
var float m_fRotAngleHeight;
var float m_fRotAngleWidth;
var Color m_OverTextColor;
var Color m_DisabledTextColor;
//Different State TextColor
var Color m_SelectedTextColor;
// Rad
var float m_fRotAngle;
var bool m_bUseRotAngle;
var bool bStretched;
var bool m_bSoundStart;
var Sound DownSound;
//Button is Selected
var bool m_bSelected;
var bool m_bDrawButtonBorders;
//R6CODE
var bool m_bPlayButtonSnd;
var bool m_bWaitSoundFinish;
// Can be used to set a special Id to this button
var int m_iButtonID;
var Sound OverSound;
// ^ NEW IN 1.60

// --- Functions ---
function Created() {}
function Paint(Canvas C, float X, float Y) {}
function BeforePaint(Canvas C, float X, float Y) {}
simulated function Click(float X, float Y) {}
function AfterPaint(Canvas C, float X, float Y) {}
function DoubleClick(float X, float Y) {}
function RClick(float X, float Y) {}
function MClick(float X, float Y) {}

defaultproperties
{
}
