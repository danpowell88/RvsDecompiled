//=============================================================================
// UWindowLookAndFeel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowLookAndFeel extends UWindowBase;

var() int FrameTitleX;                   // X pixel offset of the title text in the title bar
var() int FrameTitleY;                   // Y pixel offset of the title text in the title bar
var() int ColumnHeadingHeight;           // Height in pixels of column header rows in list controls
var() int EditBoxBevel;                  // MiscBevel style index used for edit box chrome (0-3)
var() float Size_ComboHeight;            // Height of a combo box control
var() float Size_ComboButtonWidth;       // Width of the combo dropdown arrow button
var() float Size_ScrollbarWidth;
var() float Size_ScrollbarButtonHeight;  // Interchange W and H for horizontal SB's
var() float Size_MinScrollbarHeight;     // Minimum scrollbar thumb height
var() float Size_TabAreaHeight;  // The height of the clickable tab area
var() float Size_TabAreaOverhangHeight;  // The height of the tab area overhang
var() float Size_TabSpacing;             // Extra horizontal spacing added per tab
var() float Size_TabXOffset;             // Horizontal offset of the first tab
var() float Size_TabTextOffset;          // Vertical text offset within a tab
var() float Pulldown_ItemHeight;         // Height of each item row in a pulldown menu
var() float Pulldown_VBorder;            // Vertical padding inside a pulldown menu
var() float Pulldown_HBorder;            // Horizontal padding inside a pulldown menu
var() float Pulldown_TextBorder;         // Left indent for text inside a pulldown menu item
var() Texture Active;  // Active widgets, window frames, etc.
var() Texture Inactive;  // Inactive Widgets, window frames, etc.
var() Texture ActiveS;    // Active texture variant for status bar windows
var() Texture InactiveS;  // Inactive texture variant for status bar windows
var() Texture Misc;  // Miscellaneous: backgrounds, bevels, etc.
// 9-patch window frame regions: TL/T/TR=top corners+edge, L/R=sides, BL/B/BR=bottom corners+edge
var() Region FrameTL;
var() Region FrameT;
var() Region FrameTR;
var() Region FrameL;
var() Region FrameR;
var() Region FrameBL;
var() Region FrameB;
var() Region FrameBR;
var() Color FrameActiveTitleColor;       // Title text color when the window is active
var() Color FrameInactiveTitleColor;     // Title text color when the window is inactive
var() Color HeadingActiveTitleColor;     // Column heading text color (active state)
var() Color HeadingInActiveTitleColor;   // Column heading text color (inactive state)
// 9-patch regions for a raised bevel (used for buttons and panels)
var() Region BevelUpTL;
var() Region BevelUpT;
var() Region BevelUpTR;
var() Region BevelUpL;
var() Region BevelUpR;
var() Region BevelUpBL;
var() Region BevelUpB;
var() Region BevelUpBR;
var() Region BevelUpArea;
// 4 styles of miscellaneous bevels (indices 0-3); used for edit boxes, combos, panels
var() Region MiscBevelTL[4];
var() Region MiscBevelT[4];
var() Region MiscBevelTR[4];
var() Region MiscBevelL[4];
var() Region MiscBevelR[4];
var() Region MiscBevelBL[4];
var() Region MiscBevelB[4];
var() Region MiscBevelBR[4];
var() Region MiscBevelArea[4];
var() Region ComboBtnUp;        // Combo dropdown arrow button, normal state
var() Region ComboBtnDown;      // Combo dropdown arrow button, pressed state
var() Region ComboBtnDisabled;  // Combo dropdown arrow button, disabled state
var() Region ComboBtnOver;      // Combo dropdown arrow button, hover state
var() Region HLine;             // Horizontal divider line region used in menus and lists
var() Color EditBoxTextColor;   // Default text color for edit box content
// 3-patch regions for the currently selected tab (left cap, stretched middle, right cap)
var() Region TabSelectedL;
var() Region TabSelectedM;
var() Region TabSelectedR;
// 3-patch regions for unselected tabs
var() Region TabUnselectedL;
var() Region TabUnselectedM;
var() Region TabUnselectedR;
var() Region TabBackground;     // Tiled background region for the tab control area

function Texture GetTexture(UWindowFramedWindow W)
{
	// End:0x36
	if(W.bStatusBar)
	{
		// End:0x2D
		if(W.IsActive())
		{
			return ActiveS;			
		}
		else
		{
			return InactiveS;
		}		
	}
	else
	{
		// End:0x51
		if(W.IsActive())
		{
			return Active;			
		}
		else
		{
			return Inactive;
		}
	}
	return;
}

function Setup()
{
	return;
}

function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C)
{
	return;
}

function Region FW_GetClientArea(UWindowFramedWindow W)
{
	return;
}

function UWindowBase.FrameHitTest FW_HitTest(UWindowFramedWindow W, float X, float Y)
{
	return;
}

function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C)
{
	return;
}

function DrawClientArea(UWindowClientWindow W, Canvas C)
{
	return;
}

function Combo_SetupSizes(UWindowComboControl W, Canvas C)
{
	return;
}

function Combo_Draw(UWindowComboControl W, Canvas C)
{
	return;
}

function Combo_SetupButton(UWindowComboButton W)
{
	return;
}

function Combo_SetupLeftButton(UWindowComboLeftButton W)
{
	return;
}

function Combo_SetupRightButton(UWindowComboRightButton W)
{
	return;
}

function ComboList_DrawBackground(UWindowComboList W, Canvas C)
{
	return;
}

function ComboList_DrawItem(UWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected)
{
	return;
}

function Editbox_SetupSizes(UWindowEditControl W, Canvas C)
{
	return;
}

function Editbox_Draw(UWindowEditControl W, Canvas C)
{
	return;
}

function SB_SetupUpButton(UWindowSBUpButton W)
{
	return;
}

function SB_SetupDownButton(UWindowSBDownButton W)
{
	return;
}

function SB_SetupLeftButton(UWindowSBLeftButton W)
{
	return;
}

function SB_SetupRightButton(UWindowSBRightButton W)
{
	return;
}

function SB_VDraw(UWindowVScrollbar W, Canvas C)
{
	return;
}

function SB_HDraw(UWindowHScrollbar W, Canvas C)
{
	return;
}

function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText)
{
	return;
}

function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H)
{
	return;
}

function Tab_SetupLeftButton(UWindowTabControlLeftButton W)
{
	return;
}

function Tab_SetupRightButton(UWindowTabControlRightButton W)
{
	return;
}

function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P)
{
	return;
}

function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P)
{
	return;
}

function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C)
{
	return;
}

function Menu_DrawMenuBarItem(UWindowMenuBar B, UWindowMenuBarItem i, float X, float Y, float W, float H, Canvas C)
{
	return;
}

function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C)
{
	return;
}

function Menu_DrawPulldownMenuItem(UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected)
{
	return;
}

function Button_DrawSmallButton(UWindowSmallButton B, Canvas C)
{
	return;
}

function PlayMenuSound(UWindowWindow W, UWindowBase.MenuSound S)
{
	return;
}

function ControlFrame_SetupSizes(UWindowControlFrame W, Canvas C)
{
	return;
}

function ControlFrame_Draw(UWindowControlFrame W, Canvas C)
{
	return;
}

function DrawSimpleBorder(UWindowWindow W, Canvas C)
{
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function FW_HitTest
