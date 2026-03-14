// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowWin95LookAndFeel extends UWindowLookAndFeel;

#exec TEXTURE IMPORT NAME=ActiveFrame FILE=Textures\ActiveFrame.bmp GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=InactiveFrame FILE=Textures\InactiveFrame.bmp GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=ActiveFrameS FILE=Textures\ActiveFrameS.bmp GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=InactiveFrameS FILE=Textures\InactiveFrameS.bmp GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Misc FILE=Textures\Misc.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=ChkChecked FILE=Textures\ChkChecked.bmp GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=ChkUnchecked FILE=Textures\ChkUnchecked.bmp GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=ChkCheckedDisabled FILE=Textures\ChkCheckedDisabled.bmp GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=ChkUncheckedDisabled FILE=Textures\ChkUncheckedDisabled.bmp GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuBar FILE=Textures\MenuBar.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuHighlightL FILE=Textures\MenuHighlightL.bmp FLAGS=2 GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuHighlightM FILE=Textures\MenuHighlightM.bmp FLAGS=2 GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuHighlightR FILE=Textures\MenuHighlightR.bmp FLAGS=2 GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuArea FILE=Textures\MenuArea.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuTL FILE=Textures\MenuTL.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuT FILE=Textures\MenuT.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuTR FILE=Textures\MenuTR.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuL FILE=Textures\MenuL.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuR FILE=Textures\MenuR.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuBL FILE=Textures\MenuBL.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuB FILE=Textures\MenuB.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuBR FILE=Textures\MenuBR.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuHighlight FILE=Textures\MenuHighlight.bmp GROUP="Icons" MIPS=OFF

// --- Constants ---
const SIZEBORDER =  3;
const BRSIZEBORDER =  15;

// --- Variables ---
var Region SBRightUp;
var Region SBLeftUp;
var Region CloseBoxUp;
var Region FrameSBL;
var Region SBUpUp;
var Region SBDownUp;
var Region SBLeftDown;
var Region SBLeftDisabled;
var Region SBRightDown;
var Region SBRightDisabled;
var Region SBBackground;
var Region FrameSB;
var Region FrameSBR;
var Region SBUpDown;
var Region SBUpDisabled;
var Region SBDownDown;
var Region SBDownDisabled;
var Region CloseBoxDown;
var int CloseBoxOffsetX;
var int CloseBoxOffsetY;

// --- Functions ---
function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C) {}
function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C) {}
function Combo_SetupSizes(UWindowComboControl W, Canvas C) {}
function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H) {}
function Tab_DrawTab(Canvas C, UWindowTabControlTabArea Tab, float X, float Y, float W, string Text, bool bShowText, bool bActiveTab, bool bLeftmostTab, float H) {}
function Editbox_SetupSizes(UWindowEditControl W, Canvas C) {}
function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C) {}
function ComboList_DrawBackground(UWindowComboList W, Canvas C) {}
function DrawClientArea(UWindowClientWindow W, Canvas C) {}
function Menu_DrawPulldownMenuItem(Canvas C, UWindowPulldownMenu M, UWindowPulldownMenuItem Item, float Y, float X, float W, float H, bool bSelected) {}
function Tab_SetupLeftButton(UWindowTabControlLeftButton W) {}
function Tab_SetupRightButton(UWindowTabControlRightButton W) {}
function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C) {}
function FrameHitTest FW_HitTest(float Y, float X, UWindowFramedWindow W) {}
// ^ NEW IN 1.60
function ComboList_DrawItem(Canvas C, UWindowComboList Combo, float Y, float X, float W, float H, string Text, bool bSelected) {}
function SB_SetupLeftButton(UWindowSBLeftButton W) {}
function SB_SetupUpButton(UWindowSBUpButton W) {}
function SB_SetupRightButton(UWindowSBRightButton W) {}
function Editbox_Draw(UWindowEditControl W, Canvas C) {}
function Combo_Draw(UWindowComboControl W, Canvas C) {}
function SB_SetupDownButton(UWindowSBDownButton W) {}
function Combo_SetupButton(UWindowComboButton W) {}
function Menu_DrawMenuBarItem(Canvas C, UWindowMenuBar B, float X, float W, UWindowMenuBarItem i, float Y, float H) {}
function SB_HDraw(UWindowHScrollbar W, Canvas C) {}
function SB_VDraw(UWindowVScrollbar W, Canvas C) {}
function Region FW_GetClientArea(UWindowFramedWindow W) {}
// ^ NEW IN 1.60
function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P) {}
function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P) {}

defaultproperties
{
}
