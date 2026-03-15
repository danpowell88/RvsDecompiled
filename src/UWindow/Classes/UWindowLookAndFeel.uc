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

// Returns the Active or Inactive theme texture appropriate for the given framed window.
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

/* Abstract theme interface -- subclasses must override these functions */

// Called once at theme initialization; subclasses configure default property values here.
function Setup()
{
	return;
}

// Draws the window frame chrome: borders, title bar, title text, and optional status bar.
function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C)
{
	return;
}

// Returns the usable client area region (position and size) inside the window frame.
function Region FW_GetClientArea(UWindowFramedWindow W)
{
	return;
}

// Hit-tests a point against the window frame; returns which edge, corner, or title bar was hit.
function UWindowBase.FrameHitTest FW_HitTest(UWindowFramedWindow W, float X, float Y)
{
	return;
}

// Positions and assigns textures to the window's frame buttons (e.g. close box).
function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C)
{
	return;
}

// Draws the client window background.
function DrawClientArea(UWindowClientWindow W, Canvas C)
{
	return;
}

// Computes layout positions and sizes for a combo control's child elements.
function Combo_SetupSizes(UWindowComboControl W, Canvas C)
{
	return;
}

// Draws the combo control's bevel chrome and optional label text.
function Combo_Draw(UWindowComboControl W, Canvas C)
{
	return;
}

// Configures the combo box dropdown arrow button's textures and texture regions.
function Combo_SetupButton(UWindowComboButton W)
{
	return;
}

// Configures the left step button on a combo control (used when bButtons is true).
function Combo_SetupLeftButton(UWindowComboLeftButton W)
{
	return;
}

// Configures the right step button on a combo control (used when bButtons is true).
function Combo_SetupRightButton(UWindowComboRightButton W)
{
	return;
}

// Draws the dropdown list popup background.
function ComboList_DrawBackground(UWindowComboList W, Canvas C)
{
	return;
}

// Draws a single item row in the dropdown list, highlighted if bSelected is true.
function ComboList_DrawItem(UWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected)
{
	return;
}

// Computes layout positions and sizes for an edit control's child elements.
function Editbox_SetupSizes(UWindowEditControl W, Canvas C)
{
	return;
}

// Draws the edit control's bevel chrome and optional label text.
function Editbox_Draw(UWindowEditControl W, Canvas C)
{
	return;
}

// Configures the vertical scrollbar up-arrow button's textures and regions.
function SB_SetupUpButton(UWindowSBUpButton W)
{
	return;
}

// Configures the vertical scrollbar down-arrow button's textures and regions.
function SB_SetupDownButton(UWindowSBDownButton W)
{
	return;
}

// Configures the horizontal scrollbar left-arrow button's textures and regions.
function SB_SetupLeftButton(UWindowSBLeftButton W)
{
	return;
}

// Configures the horizontal scrollbar right-arrow button's textures and regions.
function SB_SetupRightButton(UWindowSBRightButton W)
{
	return;
}

// Draws the vertical scrollbar track and thumb.
function SB_VDraw(UWindowVScrollbar W, Canvas C)
{
	return;
}

// Draws the horizontal scrollbar track and thumb.
function SB_HDraw(UWindowHScrollbar W, Canvas C)
{
	return;
}

// Draws a single tab in the tab control area using selected or unselected chrome.
function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText)
{
	return;
}

// Returns the display width (W) and height (H) for a tab containing the given text.
function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H)
{
	return;
}

// Configures the tab scroll left button (appears when tabs overflow the tab area width).
function Tab_SetupLeftButton(UWindowTabControlLeftButton W)
{
	return;
}

// Configures the tab scroll right button (appears when tabs overflow the tab area width).
function Tab_SetupRightButton(UWindowTabControlRightButton W)
{
	return;
}

// Positions and sizes the page content window within a tab page control.
function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P)
{
	return;
}

// Draws the raised bevel background of the tab page content area.
function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P)
{
	return;
}

// Draws the horizontal menu bar background.
function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C)
{
	return;
}

// Draws a single item on the menu bar, with a highlight if it is currently selected.
function Menu_DrawMenuBarItem(UWindowMenuBar B, UWindowMenuBarItem i, float X, float Y, float W, float H, Canvas C)
{
	return;
}

// Draws the pulldown menu popup background (border and fill).
function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C)
{
	return;
}

// Draws a single item in a pulldown menu, with separator, highlight, check, and submenu arrow support.
function Menu_DrawPulldownMenuItem(UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected)
{
	return;
}

// Draws a small button widget using the current theme.
function Button_DrawSmallButton(UWindowSmallButton B, Canvas C)
{
	return;
}

// Plays a UI sound effect for the given menu action type.
function PlayMenuSound(UWindowWindow W, UWindowBase.MenuSound S)
{
	return;
}

// Computes sizes and positions for the child elements of a control frame.
function ControlFrame_SetupSizes(UWindowControlFrame W, Canvas C)
{
	return;
}

// Draws the control frame widget.
function ControlFrame_Draw(UWindowControlFrame W, Canvas C)
{
	return;
}

// Draws a simple rectangular border around the given window.
function DrawSimpleBorder(UWindowWindow W, Canvas C)
{
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function FW_HitTest
