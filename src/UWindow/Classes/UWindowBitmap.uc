// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowBitmap extends UWindowDialogControl;

// --- Variables ---
// var ? T; // REMOVED IN 1.60
var Region R;
var Texture t;
// ^ NEW IN 1.60
var float m_ImageX;
// ^ NEW IN 1.60
var float m_ImageY;
var bool bStretch;
var bool bCenter;
var int m_iDrawStyle;
var bool m_bHorizontalFlip;
// ^ NEW IN 1.60
//This is ton invert a texture horizontaly on verticaly
var bool m_bVerticalFlip;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}

defaultproperties
{
}
