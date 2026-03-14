// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuPopupListButton extends R6WindowListRadioButton;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

// --- Variables ---
var R6WindowListButtonItem m_ButtonItem[10];
var Font m_FontForButtons;
var Region m_SeperatorLineRegion;
var const int m_iNbButton;
var bool bInitialized;
var Texture m_SeperatorLineTexture;

// --- Functions ---
//Call once
function BeforePaint(Canvas C, float MouseY, float MouseX) {}
function Paint(Canvas C, float MouseY, float MouseX) {}
function DrawItem(UWindowList Item, float X, float Y, float H, float W, Canvas C) {}
function ChangeItemsSize(float fNewWidth) {}

defaultproperties
{
}
