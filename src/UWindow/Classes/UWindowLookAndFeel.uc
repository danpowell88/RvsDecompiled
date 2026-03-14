// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowLookAndFeel extends UWindowBase;

// --- Variables ---
var float Size_ScrollbarWidth;
var float Size_ScrollbarButtonHeight;
var Region BevelUpTL;
var float Size_TabAreaHeight;
var Region TabUnselectedM;
var Region TabSelectedM;
var Region FrameTL;
var Region BevelUpBL;
var Region ComboBtnUp;
var Region MiscBevelT[4];
var Region MiscBevelR[4];
var Region MiscBevelB[4];
var Region MiscBevelL[4];
var Region FrameBL;
var float Size_MinScrollbarHeight;
var float Size_ComboHeight;
var Region FrameT;
var Region TabUnselectedL;
var Region TabSelectedL;
var Region MiscBevelTL[4];
var Region BevelUpBR;
var Region FrameL;
var Texture Active;
var Texture Misc;
var Region FrameTR;
var Region FrameR;
var Region FrameB;
var Region FrameBR;
var Region BevelUpTR;
var Region MiscBevelBL[4];
var Color EditBoxTextColor;
var int EditBoxBevel;
var Region TabSelectedR;
var Region TabUnselectedR;
var float Size_ComboButtonWidth;
var float Size_TabAreaOverhangHeight;
var float Size_TabXOffset;
var Texture Inactive;
var Texture ActiveS;
var Texture InactiveS;
var Color FrameActiveTitleColor;
var Color FrameInactiveTitleColor;
var int FrameTitleX;
var int FrameTitleY;
var Region BevelUpT;
var Region BevelUpL;
var Region BevelUpR;
var Region BevelUpB;
var Region BevelUpArea;
var Region MiscBevelBR[4];
var Region MiscBevelArea[4];
var Region ComboBtnDown;
var Region ComboBtnDisabled;
var Region TabBackground;
var float Size_TabSpacing;
var float Pulldown_ItemHeight;
var float Pulldown_VBorder;
var float Pulldown_HBorder;
var float Pulldown_TextBorder;
var Color HeadingActiveTitleColor;
var Color HeadingInActiveTitleColor;
var Region MiscBevelTR[4];
var Region ComboBtnOver;
var int ColumnHeadingHeight;
var Region HLine;
var float Size_TabTextOffset;

// --- Functions ---
function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C) {}
function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C) {}
function Combo_SetupSizes(UWindowComboControl W, Canvas C) {}
function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H) {}
function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText) {}
function Editbox_SetupSizes(UWindowEditControl W, Canvas C) {}
function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C) {}
function DrawClientArea(UWindowClientWindow W, Canvas C) {}
function ComboList_DrawBackground(UWindowComboList W, Canvas C) {}
function Menu_DrawPulldownMenuItem(UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected) {}
function Tab_SetupLeftButton(UWindowTabControlLeftButton W) {}
function Tab_SetupRightButton(UWindowTabControlRightButton W) {}
function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C) {}
function FrameHitTest FW_HitTest(UWindowFramedWindow W, float X, float Y) {}
// ^ NEW IN 1.60
function ComboList_DrawItem(UWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected) {}
function SB_SetupLeftButton(UWindowSBLeftButton W) {}
function SB_SetupUpButton(UWindowSBUpButton W) {}
function SB_SetupRightButton(UWindowSBRightButton W) {}
function Editbox_Draw(UWindowEditControl W, Canvas C) {}
function Combo_Draw(UWindowComboControl W, Canvas C) {}
function SB_SetupDownButton(UWindowSBDownButton W) {}
function Combo_SetupButton(UWindowComboButton W) {}
function Menu_DrawMenuBarItem(UWindowMenuBar B, UWindowMenuBarItem i, float X, float Y, float W, float H, Canvas C) {}
function SB_HDraw(UWindowHScrollbar W, Canvas C) {}
function SB_VDraw(UWindowVScrollbar W, Canvas C) {}
function Region FW_GetClientArea(UWindowFramedWindow W) {}
// ^ NEW IN 1.60
function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P) {}
function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P) {}
function Texture GetTexture(UWindowFramedWindow W) {}
// ^ NEW IN 1.60
function Setup() {}
function Combo_SetupLeftButton(UWindowComboLeftButton W) {}
function Combo_SetupRightButton(UWindowComboRightButton W) {}
function Button_DrawSmallButton(UWindowSmallButton B, Canvas C) {}
function PlayMenuSound(UWindowWindow W, MenuSound S) {}
function ControlFrame_SetupSizes(UWindowControlFrame W, Canvas C) {}
function ControlFrame_Draw(UWindowControlFrame W, Canvas C) {}
function DrawSimpleBorder(UWindowWindow W, Canvas C) {}

defaultproperties
{
}
