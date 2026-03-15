//=============================================================================
// UWindowWin95LookAndFeel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowWin95LookAndFeel extends UWindowLookAndFeel;

// SIZEBORDER: 3px thin strip along each straight edge used for N/S/E/W resize hit-testing
const SIZEBORDER = 3;
// BRSIZEBORDER: 15px wide corner zone for diagonal (NW/NE/SW/SE) resize — large so corners are easy to grab
const BRSIZEBORDER = 15;

var() int CloseBoxOffsetX;      // Close button horizontal offset from the window's right edge
var() int CloseBoxOffsetY;      // Close button vertical offset from the window's top edge
// Scrollbar up-arrow button regions (normal, pressed, disabled)
var() Region SBUpUp;
var() Region SBUpDown;
var() Region SBUpDisabled;
// Scrollbar down-arrow button regions (normal, pressed, disabled)
var() Region SBDownUp;
var() Region SBDownDown;
var() Region SBDownDisabled;
// Scrollbar left-arrow button regions (normal, pressed, disabled)
var() Region SBLeftUp;
var() Region SBLeftDown;
var() Region SBLeftDisabled;
// Scrollbar right-arrow button regions (normal, pressed, disabled)
var() Region SBRightUp;
var() Region SBRightDown;
var() Region SBRightDisabled;
var() Region SBBackground;      // Scrollbar trough (track) background region
// Status bar frame bottom edge regions (left cap, stretched middle, right cap)
var() Region FrameSBL;
var() Region FrameSB;
var() Region FrameSBR;
var() Region CloseBoxUp;        // Close button normal state region
var() Region CloseBoxDown;      // Close button pressed state region

/* Framed Window Drawing Functions */
// Renders the complete 9-slice window frame border using the look-and-feel texture atlas.
// A 9-slice (also called 9-patch) splits the border into: top-left corner, top edge, top-right
// corner, left edge, right edge, bottom-left corner, bottom edge, and bottom-right corner.
// Corners are drawn at their natural size; edges are stretched to fill the gap between them.
// This lets the frame texture look sharp at any window size.
function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C)
{
	local Texture t;
	local Region R, temp;

	// Set draw color to white so the texture is displayed without tinting
	C.DrawColor.R = byte(255);
	C.DrawColor.G = byte(255);
	C.DrawColor.B = byte(255);
	t = W.GetLookAndFeelTexture();
	// Top row of the 9-slice: fixed-size TL corner, stretched top edge, fixed-size TR corner
	R = FrameTL;
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameT;
	W.DrawStretchedTextureSegment(C, float(FrameTL.W), 0.0000000, ((W.WinWidth - float(FrameTL.W)) - float(FrameTR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameTR;
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), 0.0000000, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0x21B
	// Windows with a status bar use a shorter/different bottom graphic (FrameSB*) vs plain windows
	if(W.bStatusBar)
	{
		temp = FrameSBL;		
	}
	else
	{
		temp = FrameBL;
	}
	// Left and right edges: stretch vertically between the top corner and the bottom corner/bar
	R = FrameL;
	W.DrawStretchedTextureSegment(C, 0.0000000, float(FrameTL.H), float(R.W), ((W.WinHeight - float(FrameTL.H)) - float(temp.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameR;
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), float(FrameTL.H), float(R.W), ((W.WinHeight - float(FrameTL.H)) - float(temp.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0x393
	// Bottom row: left cap differs between status-bar and normal windows
	if(W.bStatusBar)
	{
		R = FrameSBL;		
	}
	else
	{
		R = FrameBL;
	}
	W.DrawStretchedTextureSegment(C, 0.0000000, (W.WinHeight - float(R.H)), float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0x4E7
	// Bottom center: status bar windows show a raised status-bar graphic instead of the plain bottom edge
	if(W.bStatusBar)
	{
		R = FrameSB;
		W.DrawStretchedTextureSegment(C, float(FrameBL.W), (W.WinHeight - float(R.H)), ((W.WinWidth - float(FrameSBL.W)) - float(FrameSBR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);		
	}
	else
	{
		R = FrameB;
		W.DrawStretchedTextureSegment(C, float(FrameBL.W), (W.WinHeight - float(R.H)), ((W.WinWidth - float(FrameBL.W)) - float(FrameBR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	}
	// End:0x5B9
	// Bottom-right corner also differs for status bar windows
	if(W.bStatusBar)
	{
		R = FrameSBR;		
	}
	else
	{
		R = FrameBR;
	}
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), (W.WinHeight - float(R.H)), float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	C.Font = W.Root.Fonts[W.0];
	// End:0x6C6
	// Active windows get a brighter/white title; inactive windows get a dimmer color
	if((W.ParentWindow.ActiveWindow == W))
	{
		C.DrawColor = FrameActiveTitleColor;		
	}
	else
	{
		C.DrawColor = FrameInactiveTitleColor;
	}
	// Clip the title text so it never overlaps the close button (22px reserved on the right)
	W.ClipTextWidth(C, float(FrameTitleX), float(FrameTitleY), W.WindowTitle, (W.WinWidth - float(22)));
	// End:0x809
	if(W.bStatusBar)
	{
		// Status bar text drawn in black at 6px from left, 13px from the bottom of the window
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		W.ClipTextWidth(C, 6.0000000, (W.WinHeight - float(13)), W.StatusBarText, (W.WinWidth - float(22)));
		C.DrawColor.R = byte(255);
		C.DrawColor.G = byte(255);
		C.DrawColor.B = byte(255);
	}
	return;
}

// Positions and configures the close [X] button inside the window frame.
// CloseBoxOffsetX/Y define the inward margin from the frame edges (set in defaultproperties).
function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	// Place close button near the top-right corner, inset by the configured offsets
	W.CloseBox.WinLeft = ((W.WinWidth - float(CloseBoxOffsetX)) - float(CloseBoxUp.W));
	W.CloseBox.WinTop = float(CloseBoxOffsetY);
	W.CloseBox.SetSize(float(CloseBoxUp.W), float(CloseBoxUp.H));
	// bUseRegion: button draws a sub-region of the texture atlas rather than the whole texture
	W.CloseBox.bUseRegion = true;
	// All states share the same texture atlas; only the source region changes
	W.CloseBox.UpTexture = t;
	W.CloseBox.DownTexture = t;
	W.CloseBox.OverTexture = t;
	W.CloseBox.DisabledTexture = t;
	W.CloseBox.UpRegion = CloseBoxUp;
	W.CloseBox.DownRegion = CloseBoxDown;
	// Hover (Over) and disabled use the same graphic as the normal (Up) state
	W.CloseBox.OverRegion = CloseBoxUp;
	W.CloseBox.DisabledRegion = CloseBoxUp;
	return;
}

// Returns the rectangle (in window-local coords) available for content, trimmed by the frame borders.
function Region FW_GetClientArea(UWindowFramedWindow W)
{
	local Region R;

	// Client area starts just inside the left and top frame borders
	R.X = FrameL.W;
	R.Y = FrameT.H;
	// Width is reduced by both left and right frame border widths
	R.W = int((W.WinWidth - float((FrameL.W + FrameR.W))));
	// End:0xA9
	// Status bar bottom edge is thicker than the normal bottom border
	if(W.bStatusBar)
	{
		R.H = int((W.WinHeight - float((FrameT.H + FrameSB.H))));		
	}
	else
	{
		R.H = int((W.WinHeight - float((FrameT.H + FrameB.H))));
	}
	return R;
	return;
}

// Determines which part of the window frame a click/drag landed on, returning a FrameHitTest enum.
// This drives resize (drag edges/corners) and move (drag title bar) behaviour.
// The constants SIZEBORDER and BRSIZEBORDER define the hit zone widths.
function UWindowBase.FrameHitTest FW_HitTest(UWindowFramedWindow W, float X, float Y)
{
	// Title bar: a 14px tall strip inset 3px from each side (avoids the resize border)
	// End:0x51
	if(((((X >= float(3)) && (X <= (W.WinWidth - float(3)))) && (Y >= float(3))) && (Y <= float(14))))
	{
		return 8; // HT_TitleBar
	}
	// Top-left corner: within SIZEBORDER of top OR within BRSIZEBORDER of left
	// End:0x92
	if((((X < float(15)) && (Y < float(3))) || ((X < float(3)) && (Y < float(15)))))
	{
		return 0; // HT_NW
	}
	// Top-right corner
	// End:0xF3
	if((((X > (W.WinWidth - float(3))) && (Y < float(15))) || ((X > (W.WinWidth - float(15))) && (Y < float(3)))))
	{
		return 2; // HT_NE
	}
	// Bottom-left corner
	// End:0x154
	if((((X < float(15)) && (Y > (W.WinHeight - float(3)))) || ((X < float(3)) && (Y > (W.WinHeight - float(15))))))
	{
		return 5; // HT_SW
	}
	// Bottom-right corner: large 15x15px grab zone (easy to resize from the corner)
	// End:0x195
	if(((X > (W.WinWidth - float(15))) && (Y > (W.WinHeight - float(15)))))
	{
		return 7; // HT_SE
	}
	// Straight edge hits — checked after corners so corners take priority
	// End:0x1A6
	if((Y < float(3)))
	{
		return 1; // HT_N
	}
	// End:0x1C7
	if((Y > (W.WinHeight - float(3))))
	{
		return 6; // HT_S
	}
	// End:0x1D8
	if((X < float(3)))
	{
		return 3; // HT_W
	}
	// End:0x1F9
	if((X > (W.WinWidth - float(3))))
	{
		return 4; // HT_E
	}
	return 10; // HT_None — inside the window, not on any border
	return;
}

/* Client Area Drawing Functions */
// Fills the entire client area with a solid black background.
// Individual child windows draw their own content on top of this.
function DrawClientArea(UWindowClientWindow W, Canvas C)
{
	W.DrawStretchedTexture(C, 0.0000000, 0.0000000, W.WinWidth, W.WinHeight, Texture'UWindow.BlackTexture');
	return;
}

/* Combo Drawing Functions */
// Calculates all layout sizes and positions for a combo-box control's child elements.
// The control is made up of: a sunken bevel border, a text-input edit box, a dropdown button,
// and optionally left/right spinner arrow buttons (when bButtons is true).
function Combo_SetupSizes(UWindowComboControl W, Canvas C)
{
	local float tW, tH;

	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, tW, tH);
	// Total height = 12px for content + top and bottom bevel thickness (from MiscBevel index 2)
	W.WinHeight = ((12.0000000 + float(MiscBevelT[2].H)) + float(MiscBevelB[2].H));
	// Position the edit-area draw origin based on the label alignment:
	// 0 = TA_Left (label on left, edit on right), 1 = TA_Right, 2 = TA_Center
	switch(W.Align)
	{
		// End:0xF1
		case 0: // TA_Left — edit box at the right side, text label at the left
			W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth);
			W.TextX = 0.0000000;
			// End:0x199
			break;
		// End:0x131
		case 1: // TA_Right — edit box at the left side, text label flush right
			W.EditAreaDrawX = 0.0000000;
			W.TextX = (W.WinWidth - tW);
			// End:0x199
			break;
		// End:0x196
		case 2: // TA_Center — both centered
			W.EditAreaDrawX = ((W.WinWidth - W.EditBoxWidth) / float(2));
			W.TextX = ((W.WinWidth - tW) / float(2));
			// End:0x199
			break;
		// End:0xFFFF
		default:
			break;
	}
	// Vertical center of the edit area (used to align sub-controls)
	W.EditAreaDrawY = ((W.WinHeight - float(2)) / float(2));
	W.TextY = ((W.WinHeight - tH) / float(2));
	// Inset the actual text-entry child window by the bevel border so it sits inside the sunken frame
	W.EditBox.WinLeft = (W.EditAreaDrawX + float(MiscBevelL[2].W));
	W.EditBox.WinTop = float(MiscBevelT[2].H);
	W.Button.WinWidth = float(ComboBtnUp.W);
	// End:0x553
	if(W.bButtons)
	{
		// Spinner mode: drop-down button + left/right increment/decrement arrows all fit inside the bevel
		W.EditBox.WinWidth = (((((W.EditBoxWidth - float(MiscBevelL[2].W)) - float(MiscBevelR[2].W)) - float(ComboBtnUp.W)) - float(SBLeftUp.W)) - float(SBRightUp.W));
		W.EditBox.WinHeight = ((W.WinHeight - float(MiscBevelT[2].H)) - float(MiscBevelB[2].H));
		W.Button.WinLeft = ((((W.WinWidth - float(ComboBtnUp.W)) - float(MiscBevelR[2].W)) - float(SBLeftUp.W)) - float(SBRightUp.W));
		W.Button.WinTop = W.EditBox.WinTop;
		W.LeftButton.WinLeft = (((W.WinWidth - float(MiscBevelR[2].W)) - float(SBLeftUp.W)) - float(SBRightUp.W));
		W.LeftButton.WinTop = W.EditBox.WinTop;
		W.RightButton.WinLeft = ((W.WinWidth - float(MiscBevelR[2].W)) - float(SBRightUp.W));
		W.RightButton.WinTop = W.EditBox.WinTop;
		W.LeftButton.WinWidth = float(SBLeftUp.W);
		W.LeftButton.WinHeight = float(SBLeftUp.H);
		W.RightButton.WinWidth = float(SBRightUp.W);
		W.RightButton.WinHeight = float(SBRightUp.H);		
	}
	else
	{
		// Standard combo: just the edit area and dropdown button
		W.EditBox.WinWidth = (((W.EditBoxWidth - float(MiscBevelL[2].W)) - float(MiscBevelR[2].W)) - float(ComboBtnUp.W));
		W.EditBox.WinHeight = ((W.WinHeight - float(MiscBevelT[2].H)) - float(MiscBevelB[2].H));
		W.Button.WinLeft = ((W.WinWidth - float(ComboBtnUp.W)) - float(MiscBevelR[2].W));
		W.Button.WinTop = W.EditBox.WinTop;
	}
	W.Button.WinHeight = W.EditBox.WinHeight;
	return;
}

// Renders the visible combo-box: a sunken bevel border around the edit area, plus the label text.
// MiscBevel index 2 = the "deep sunken" style used for input fields.
function Combo_Draw(UWindowComboControl W, Canvas C)
{
	W.DrawMiscBevel(C, W.EditAreaDrawX, 0.0000000, W.EditBoxWidth, W.WinHeight, Misc, 2);
	// End:0x102
	if((W.Text != ""))
	{
		C.DrawColor = W.TextColor;
		W.ClipText(C, W.TextX, W.TextY, W.Text);
		// Restore canvas to white after drawing colored text
		C.DrawColor.R = byte(255);
		C.DrawColor.G = byte(255);
		C.DrawColor.B = byte(255);
	}
	return;
}

// Draws the dropdown popup background using a 9-slice border (4px corners, stretched edges, tiled fill).
// The 9 pieces are: TL, T, TR (top row), L, Area, R (middle), BL, B, BR (bottom row).
function ComboList_DrawBackground(UWindowComboList W, Canvas C)
{
	// Four 4x4 corners drawn at their natural size (clipped, not stretched)
	W.DrawClippedTexture(C, 0.0000000, 0.0000000, Texture'UWindow.Icons.MenuTL');
	W.DrawStretchedTexture(C, 4.0000000, 0.0000000, (W.WinWidth - float(8)), 4.0000000, Texture'UWindow.Icons.MenuT');
	W.DrawClippedTexture(C, (W.WinWidth - float(4)), 0.0000000, Texture'UWindow.Icons.MenuTR');
	W.DrawClippedTexture(C, 0.0000000, (W.WinHeight - float(4)), Texture'UWindow.Icons.MenuBL');
	W.DrawStretchedTexture(C, 4.0000000, (W.WinHeight - float(4)), (W.WinWidth - float(8)), 4.0000000, Texture'UWindow.Icons.MenuB');
	W.DrawClippedTexture(C, (W.WinWidth - float(4)), (W.WinHeight - float(4)), Texture'UWindow.Icons.MenuBR');
	// Left and right edges: 4px wide, stretched vertically between the corner pieces
	W.DrawStretchedTexture(C, 0.0000000, 4.0000000, 4.0000000, (W.WinHeight - float(8)), Texture'UWindow.Icons.MenuL');
	W.DrawStretchedTexture(C, (W.WinWidth - float(4)), 4.0000000, 4.0000000, (W.WinHeight - float(8)), Texture'UWindow.Icons.MenuR');
	// Interior fill — the menu background texture tiled/stretched across the center
	W.DrawStretchedTexture(C, 4.0000000, 4.0000000, (W.WinWidth - float(8)), (W.WinHeight - float(8)), Texture'UWindow.Icons.MenuArea');
	return;
}

// Renders a single item row inside the combo dropdown list.
// Selected rows get a highlight texture drawn behind the text; all text is drawn in black.
function ComboList_DrawItem(UWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected)
{
	C.DrawColor.R = byte(255);
	C.DrawColor.G = byte(255);
	C.DrawColor.B = byte(255);
	// End:0xC3
	if(bSelected)
	{
		// Highlight band covers the full row width and height
		Combo.DrawStretchedTexture(C, X, Y, W, H, Texture'UWindow.Icons.MenuHighlight');
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;		
	}
	else
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}
	// TextBorder + 2: left padding from the item edge so text doesn't butt up against the border
	// Y + 3: small vertical padding to center text within the row height
	Combo.ClipText(C, ((X + float(Combo.TextBorder)) + float(2)), (Y + float(3)), Text);
	return;
}

// Configures the dropdown arrow button that opens the combo list.
// All four button states (up/down/over/disabled) use the same texture atlas with different source regions.
function Combo_SetupButton(UWindowComboButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = ComboBtnUp;
	W.DownRegion = ComboBtnDown;
	// Hover uses the same graphic as normal (no separate highlight art)
	W.OverRegion = ComboBtnUp;
	W.DisabledRegion = ComboBtnDisabled;
	return;
}

// Calculates layout for a labelled text-input (edit box) control.
// Nearly identical to Combo_SetupSizes but without a dropdown button or spinner arrows.
// EditBoxBevel selects which MiscBevel style to use (2 = deep sunken, set in defaultproperties).
function Editbox_SetupSizes(UWindowEditControl W, Canvas C)
{
	local float tW, tH;
	local int B;

	// B caches the bevel style index so we don't repeat the property lookup everywhere
	B = EditBoxBevel;
	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, tW, tH);
	// Height = 12px content + top/bottom bevel thicknesses for the selected bevel style
	W.WinHeight = ((12.0000000 + float(MiscBevelT[B].H)) + float(MiscBevelB[B].H));
	switch(W.Align)
	{
		// End:0x102
		case 0: // TA_Left
			W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth);
			W.TextX = 0.0000000;
			// End:0x1AA
			break;
		// End:0x142
		case 1: // TA_Right
			W.EditAreaDrawX = 0.0000000;
			W.TextX = (W.WinWidth - tW);
			// End:0x1AA
			break;
		// End:0x1A7
		case 2: // TA_Center
			W.EditAreaDrawX = ((W.WinWidth - W.EditBoxWidth) / float(2));
			W.TextX = ((W.WinWidth - tW) / float(2));
			// End:0x1AA
			break;
		// End:0xFFFF
		default:
			break;
	}
	W.EditAreaDrawY = ((W.WinHeight - float(2)) / float(2));
	W.TextY = ((W.WinHeight - tH) / float(2));
	// Inset the actual text-entry child window inside the bevel so it sits within the sunken border
	W.EditBox.WinLeft = (W.EditAreaDrawX + float(MiscBevelL[B].W));
	W.EditBox.WinTop = float(MiscBevelT[B].H);
	W.EditBox.WinWidth = ((W.EditBoxWidth - float(MiscBevelL[B].W)) - float(MiscBevelR[B].W));
	W.EditBox.WinHeight = ((W.WinHeight - float(MiscBevelT[B].H)) - float(MiscBevelB[B].H));
	return;
}

// Renders a labelled text-input: draws the sunken bevel border, then the current text label.
function Editbox_Draw(UWindowEditControl W, Canvas C)
{
	// DrawMiscBevel renders the "sunken" border (EditBoxBevel style) that visually frames the text field
	W.DrawMiscBevel(C, W.EditAreaDrawX, 0.0000000, W.EditBoxWidth, W.WinHeight, Misc, EditBoxBevel);
	// End:0x105
	if((W.Text != ""))
	{
		C.DrawColor = W.TextColor;
		W.ClipText(C, W.TextX, W.TextY, W.Text);
		// Restore canvas to white after drawing colored label text
		C.DrawColor.R = byte(255);
		C.DrawColor.G = byte(255);
		C.DrawColor.B = byte(255);
	}
	return;
}

// Renders an individual tab button in a tab-control row.
// The active (selected) tab uses a taller 3-piece graphic (TabSelected*) so it appears to pop
// forward. Inactive tabs use shorter TabUnselected* graphics, sitting below the active tab.
// Each tab is drawn as: left-cap + horizontally-stretched middle + right-cap.
function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText)
{
	local Region R;
	local Texture t;
	local float tW, tH;

	// White tint so the tab texture renders without color modification
	C.DrawColor.R = byte(255);
	C.DrawColor.G = byte(255);
	C.DrawColor.B = byte(255);
	t = Tab.GetLookAndFeelTexture();
	// End:0x2E1
	if(bActiveTab)
	{
		// Active tab: 3-piece stretched graphic — left cap, stretched middle, right cap
		R = TabSelectedL;
		Tab.DrawStretchedTextureSegment(C, X, Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		R = TabSelectedM;
		Tab.DrawStretchedTextureSegment(C, (X + float(TabSelectedL.W)), Y, ((W - float(TabSelectedL.W)) - float(TabSelectedR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		R = TabSelectedR;
		Tab.DrawStretchedTextureSegment(C, ((X + W) - float(R.W)), Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		// Active tab uses bold font (index 1); text is drawn in black
		C.Font = Tab.Root.Fonts[Tab.1];
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		// End:0x2DE
		if(bShowText)
		{
			Tab.TextSize(C, Text, tW, tH);
			// Y+3: active tab is taller so text needs less vertical offset to appear centered
			Tab.ClipText(C, (X + ((W - tW) / float(2))), (Y + float(3)), Text, true);
		}		
	}
	else
	{
		// Inactive tab: same 3-piece pattern with the shorter TabUnselected* graphics
		R = TabUnselectedL;
		Tab.DrawStretchedTextureSegment(C, X, Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		R = TabUnselectedM;
		Tab.DrawStretchedTextureSegment(C, (X + float(TabUnselectedL.W)), Y, ((W - float(TabUnselectedL.W)) - float(TabUnselectedR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		R = TabUnselectedR;
		Tab.DrawStretchedTextureSegment(C, ((X + W) - float(R.W)), Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		// Inactive tab uses normal (non-bold) font (index 0)
		C.Font = Tab.Root.Fonts[Tab.0];
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		// End:0x559
		if(bShowText)
		{
			Tab.TextSize(C, Text, tW, tH);
			// Y+4: inactive tab graphic is 1px shorter, so text drops 1px more to stay centered
			Tab.ClipText(C, (X + ((W - tW) / float(2))), (Y + float(4)), Text, true);
		}
	}
	return;
}

// Configures the scrollbar up-arrow button's texture regions for each interactive state.
// All states share the same texture atlas; each state simply reads from a different sub-region.
function SB_SetupUpButton(UWindowSBUpButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBUpUp;          // normal unpressed state
	W.DownRegion = SBUpDown;      // depressed / clicked state
	W.OverRegion = SBUpUp;        // hover uses same graphic as normal
	W.DisabledRegion = SBUpDisabled;
	return;
}

// Configures the scrollbar down-arrow button.
function SB_SetupDownButton(UWindowSBDownButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBDownUp;
	W.DownRegion = SBDownDown;
	W.OverRegion = SBDownUp;
	W.DisabledRegion = SBDownDisabled;
	return;
}

// Configures the horizontal scrollbar left-arrow button.
function SB_SetupLeftButton(UWindowSBLeftButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBLeftUp;
	W.DownRegion = SBLeftDown;
	W.OverRegion = SBLeftUp;
	W.DisabledRegion = SBLeftDisabled;
	return;
}

// Configures the horizontal scrollbar right-arrow button.
function SB_SetupRightButton(UWindowSBRightButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBRightUp;
	W.DownRegion = SBRightDown;
	W.OverRegion = SBRightUp;
	W.DisabledRegion = SBRightDisabled;
	return;
}

// Renders the vertical scrollbar track and thumb.
// The trough (background) is a single texture stretched to fill the entire bar.
// The thumb (the draggable indicator) is drawn as a raised bevel — light edges on top/left,
// shadow on bottom/right — giving the classic Win95 "raised button" 3D appearance.
function SB_VDraw(UWindowVScrollbar W, Canvas C)
{
	local Region R;
	local Texture t;

	t = W.GetLookAndFeelTexture();
	// Stretch the trough background texture across the full scrollbar area
	R = SBBackground;
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, W.WinWidth, W.WinHeight, float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0xE2
	// Only draw the thumb when the scrollbar is enabled (disabled = content fits without scrolling)
	if((!W.bDisabled))
	{
		// ThumbStart = pixel offset from the top of the bar (proportional to scroll position)
		// Size_ScrollbarWidth = thumb width (equals the bar width — thumb is full-width)
		W.DrawUpBevel(C, 0.0000000, W.ThumbStart, Size_ScrollbarWidth, W.ThumbHeight, t);
	}
	return;
}

// Renders the horizontal scrollbar track and thumb.
// Functionally identical to SB_VDraw but with X/Y and Width/Height axes swapped.
function SB_HDraw(UWindowHScrollbar W, Canvas C)
{
	local Region R;
	local Texture t;

	t = W.GetLookAndFeelTexture();
	// Stretch the trough background across the full horizontal bar
	R = SBBackground;
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, W.WinWidth, W.WinHeight, float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0xE2
	if((!W.bDisabled))
	{
		// ThumbStart = left edge of thumb; ThumbWidth = horizontal size; Size_ScrollbarWidth = height
		W.DrawUpBevel(C, W.ThumbStart, 0.0000000, W.ThumbWidth, Size_ScrollbarWidth, t);
	}
	return;
}

// Positions and configures the left scroll arrow button used to scroll the tab strip left
// when there are more tabs than can fit in the visible area.
// The button sits at the bottom of the tab area row, paired with the right button.
function Tab_SetupLeftButton(UWindowTabControlLeftButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	// Match the button's size to the standard scrollbar arrow dimensions
	W.WinWidth = Size_ScrollbarButtonHeight;
	W.WinHeight = Size_ScrollbarWidth;
	// Align to the bottom of the tab row, leaving room for the right button beside it
	W.WinTop = (Size_TabAreaHeight - W.WinHeight);
	W.WinLeft = (W.ParentWindow.WinWidth - (float(2) * W.WinWidth));
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBLeftUp;
	W.DownRegion = SBLeftDown;
	W.OverRegion = SBLeftUp;
	W.DisabledRegion = SBLeftDisabled;
	return;
}

// Positions and configures the right scroll arrow button for the tab strip.
// Placed immediately to the right of the left button, at the far right of the tab area.
function Tab_SetupRightButton(UWindowTabControlRightButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.WinWidth = Size_ScrollbarButtonHeight;
	W.WinHeight = Size_ScrollbarWidth;
	W.WinTop = (Size_TabAreaHeight - W.WinHeight);
	// Right button occupies the very last slot at the right edge
	W.WinLeft = (W.ParentWindow.WinWidth - W.WinWidth);
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBRightUp;
	W.DownRegion = SBRightDown;
	W.OverRegion = SBRightUp;
	W.DisabledRegion = SBRightDisabled;
	return;
}

// Sizes and positions the tab page content window within the tab control.
// The page is inset 2px on each side and sits below the tab strip row.
// The vertical offset accounts for the active tab "overhang" (TabSelectedM is taller than
// TabUnselectedM), which causes the active tab to visually overlap the page border.
function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P)
{
	P.WinLeft = 2.0000000;
	// WinTop: below the tab strip, adjusted so the raised-bevel border on the page starts
	// exactly where the active tab graphic ends (the overhang bridges the gap visually)
	P.WinTop = ((W.TabArea.WinHeight - float((TabSelectedM.H - TabUnselectedM.H))) + float(3));
	// 4px total horizontal margin (2px each side), 6px total vertical margin
	P.SetSize((W.WinWidth - float(4)), ((W.WinHeight - (W.TabArea.WinHeight - float((TabSelectedM.H - TabUnselectedM.H)))) - float(6)));
	return;
}

// Renders the raised 3D bevel border that surrounds the tab page content area.
// Starts at Size_TabAreaHeight so it sits flush below the tab strip row.
// DrawUpBevel gives the classic Win95 raised-panel look: bright top/left, dark bottom/right.
function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P)
{
	W.DrawUpBevel(C, 0.0000000, Size_TabAreaHeight, W.WinWidth, (W.WinHeight - Size_TabAreaHeight), W.GetLookAndFeelTexture());
	return;
}

// Measures the pixel width a tab should occupy for a given label string.
// Adds Size_TabSpacing (20px padding) to the raw text width for visual breathing room.
function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H)
{
	local float tW, tH;

	// Measure using normal (non-bold) font — the font used by inactive tabs
	C.Font = Tab.Root.Fonts[Tab.0];
	Tab.TextSize(C, Text, tW, tH);
	W = (tW + Size_TabSpacing); // Size_TabSpacing = 20px, gives padding around the text
	H = tH;
	return;
}

// Draws the menu bar strip background texture, centered with 16px margins on each side.
// The MenuBar texture is exactly 16px tall and is stretched horizontally to fill the bar.
function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C)
{
	W.DrawStretchedTexture(C, 16.0000000, 0.0000000, (W.WinWidth - float(32)), 16.0000000, Texture'UWindow.Icons.MenuBar');
	return;
}

// Renders a single item in the menu bar (e.g. "File", "Options").
// If this item is currently selected (menu is open), a 3-piece highlight band is drawn behind it.
// Text is centered horizontally using half of the Spacing value as left padding.
function Menu_DrawMenuBarItem(UWindowMenuBar B, UWindowMenuBarItem i, float X, float Y, float W, float H, Canvas C)
{
	// End:0xA2
	if((B.Selected == i))
	{
		// 3-piece highlight: fixed left cap, stretched middle, fixed right cap
		// Y=1 offsets 1px from the top edge so the highlight sits visually inside the bar
		B.DrawClippedTexture(C, X, 1.0000000, Texture'UWindow.Icons.MenuHighlightL');
		B.DrawClippedTexture(C, ((X + W) - float(1)), 1.0000000, Texture'UWindow.Icons.MenuHighlightR');
		B.DrawStretchedTexture(C, (X + float(1)), 1.0000000, (W - float(2)), 16.0000000, Texture'UWindow.Icons.MenuHighlightM');
	}
	C.Font = B.Root.Fonts[0];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	// Spacing/2 centers the label text horizontally within the item's allocated width slot
	B.ClipText(C, (X + float((B.Spacing / 2))), 2.0000000, i.Caption, true);
	return;
}

// Draws the floating pulldown menu panel background using a 9-slice border.
// This is the same technique as ComboList_DrawBackground but with 2px borders (thinner than the 4px combo border).
function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C)
{
	// 2px corner pieces at each corner (clipped = drawn at natural size, no stretching)
	W.DrawClippedTexture(C, 0.0000000, 0.0000000, Texture'UWindow.Icons.MenuTL');
	W.DrawStretchedTexture(C, 2.0000000, 0.0000000, (W.WinWidth - float(4)), 2.0000000, Texture'UWindow.Icons.MenuT');
	W.DrawClippedTexture(C, (W.WinWidth - float(2)), 0.0000000, Texture'UWindow.Icons.MenuTR');
	W.DrawClippedTexture(C, 0.0000000, (W.WinHeight - float(2)), Texture'UWindow.Icons.MenuBL');
	W.DrawStretchedTexture(C, 2.0000000, (W.WinHeight - float(2)), (W.WinWidth - float(4)), 2.0000000, Texture'UWindow.Icons.MenuB');
	W.DrawClippedTexture(C, (W.WinWidth - float(2)), (W.WinHeight - float(2)), Texture'UWindow.Icons.MenuBR');
	// 2px-wide side edges stretched vertically
	W.DrawStretchedTexture(C, 0.0000000, 2.0000000, 2.0000000, (W.WinHeight - float(4)), Texture'UWindow.Icons.MenuL');
	W.DrawStretchedTexture(C, (W.WinWidth - float(2)), 2.0000000, 2.0000000, (W.WinHeight - float(4)), Texture'UWindow.Icons.MenuR');
	// Interior fill
	W.DrawStretchedTexture(C, 2.0000000, 2.0000000, (W.WinWidth - float(4)), (W.WinHeight - float(4)), Texture'UWindow.Icons.MenuArea');
	return;
}

// Renders a single item row in a pulldown menu, handling all visual states.
function Menu_DrawPulldownMenuItem(UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected)
{
	C.DrawColor.R = byte(255);
	C.DrawColor.G = byte(255);
	C.DrawColor.B = byte(255);
	// Store the item's screen-space top for hit-testing against mouse position
	Item.ItemTop = (Y + M.WinTop);
	// End:0xFF
	// Separator: drawn as a 2px-tall horizontal rule centered in the 15px item height (Y+5)
	if((Item.Caption == "-"))
	{
		C.DrawColor.R = byte(255);
		C.DrawColor.G = byte(255);
		C.DrawColor.B = byte(255);
		M.DrawStretchedTexture(C, X, (Y + float(5)), W, 2.0000000, Texture'UWindow.Icons.MenuDivider');
		return;
	}
	C.Font = M.Root.Fonts[0];
	// End:0x15D
	if(bSelected)
	{
		// Highlight band spans the full item row
		M.DrawStretchedTexture(C, X, Y, W, H, Texture'UWindow.Icons.MenuHighlight');
	}
	// End:0x1B4
	// Disabled items drawn in medium grey (96) instead of black
	if(Item.bDisabled)
	{
		C.DrawColor.R = 96;
		C.DrawColor.G = 96;
		C.DrawColor.B = 96;		
	}
	else
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}
	// End:0x236
	if(Item.bChecked)
	{
		// Checkmark tick drawn at X+1, Y+3 (small margin from the left edge, vertically centered)
		M.DrawClippedTexture(C, (X + float(1)), (Y + float(3)), Texture'UWindow.Icons.MenuTick');
	}
	// End:0x280
	if((Item.SubMenu != none))
	{
		// Sub-menu arrow glyph drawn 9px from the right edge, vertically padded 3px
		M.DrawClippedTexture(C, ((X + W) - float(9)), (Y + float(3)), Texture'UWindow.Icons.MenuSubArrow');
	}
	// TextBorder + 2: left indent that reserves space for the check mark column
	M.ClipText(C, ((X + float(M.TextBorder)) + float(2)), (Y + float(3)), Item.Caption, true);
	return;
}

// Default property values set at class-load time.
// Region values are serialized references into the texture atlas (the binary format preserves
// exact pixel offsets into the spritesheet).  Texture references bind to the imported bitmaps:
//   Active/Inactive     = window frame borders (active = focused/blue, inactive = unfocused/grey)
//   ActiveS/InactiveS   = "S" (status bar) variants — slightly different bottom border graphic
//   Misc                = the main UI spritesheet containing bevels, buttons, scrollbar elements
// Size_* constants control the pixel dimensions used for layout calculations throughout:
//   Size_ScrollbarWidth         = height/width of the scrollbar track and thumb
//   Size_ScrollbarButtonHeight  = width of the arrow buttons at each end of the scrollbar
//   Size_TabAreaHeight          = height of the tab strip row
//   Size_TabSpacing             = extra width added around each tab label (20px padding total)
//   Pulldown_* values           = per-item height and padding for pulldown menu items
defaultproperties
{
	CloseBoxOffsetX=3
	CloseBoxOffsetY=5
	SBUpUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=5154,ZoneNumber=0)
	SBUpDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	SBUpDisabled=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=11298,ZoneNumber=0)
	SBDownUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=5154,ZoneNumber=0)
	SBDownDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	SBDownDisabled=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=11298,ZoneNumber=0)
	SBLeftUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=5154,ZoneNumber=0)
	SBLeftDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=7714,ZoneNumber=0)
	SBLeftDisabled=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=10274,ZoneNumber=0)
	SBRightUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=5154,ZoneNumber=0)
	SBRightDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=7714,ZoneNumber=0)
	SBRightDisabled=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=10274,ZoneNumber=0)
	SBBackground=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	FrameSBL=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=28706,ZoneNumber=0)
	FrameSB=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	FrameSBR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=28706,ZoneNumber=0)
	CloseBoxUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	CloseBoxDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	FrameTitleX=6
	FrameTitleY=4
	ColumnHeadingHeight=13
	EditBoxBevel=2
	Size_ScrollbarWidth=12.0000000
	Size_ScrollbarButtonHeight=10.0000000
	Size_MinScrollbarHeight=6.0000000
	Size_TabAreaHeight=15.0000000
	Size_TabAreaOverhangHeight=2.0000000
	Size_TabSpacing=20.0000000
	Size_TabXOffset=1.0000000
	Pulldown_ItemHeight=15.0000000
	Pulldown_VBorder=3.0000000
	Pulldown_HBorder=3.0000000
	Pulldown_TextBorder=9.0000000
	Active=Texture'UWindow.Icons.ActiveFrame'
	Inactive=Texture'UWindow.Icons.InactiveFrame'
	ActiveS=Texture'UWindow.Icons.ActiveFrameS'
	InactiveS=Texture'UWindow.Icons.InactiveFrameS'
	Misc=Texture'UWindow.Icons.Misc'
	FrameTL=(Zone=FloatProperty'UWindow.UWindowWindow.WinWidth',iLeaf=546,ZoneNumber=0)
	FrameT=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	FrameTR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=32290,ZoneNumber=0)
	FrameL=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=8226,ZoneNumber=0)
	FrameR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=32290,ZoneNumber=0)
	FrameBL=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=32034,ZoneNumber=0)
	FrameB=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	FrameBR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=32290,ZoneNumber=0)
	FrameActiveTitleColor=(R=255,G=255,B=255,A=0)
	FrameInactiveTitleColor=(R=255,G=255,B=255,A=0)
	BevelUpTL=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	BevelUpT=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2594,ZoneNumber=0)
	BevelUpTR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=4642,ZoneNumber=0)
	BevelUpL=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	BevelUpR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=4642,ZoneNumber=0)
	BevelUpBL=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	BevelUpB=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2594,ZoneNumber=0)
	BevelUpBR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=4642,ZoneNumber=0)
	BevelUpArea=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2082,ZoneNumber=0)
	MiscBevelTL[0]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=4386,ZoneNumber=0)
	MiscBevelTL[1]=(Zone=FloatProperty'UWindow.UWindowWindow.WinWidth',iLeaf=802,ZoneNumber=0)
	MiscBevelTL[2]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=8482,ZoneNumber=0)
	MiscBevelT[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelT[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelT[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=546,ZoneNumber=0)
	MiscBevelTR[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelTR[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelTR[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2850,ZoneNumber=0)
	MiscBevelL[0]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=5154,ZoneNumber=0)
	MiscBevelL[1]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=802,ZoneNumber=0)
	MiscBevelL[2]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=9250,ZoneNumber=0)
	MiscBevelR[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelR[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelR[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2850,ZoneNumber=0)
	MiscBevelBL[0]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=7714,ZoneNumber=0)
	MiscBevelBL[1]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=3618,ZoneNumber=0)
	MiscBevelBL[2]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=11298,ZoneNumber=0)
	MiscBevelB[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelB[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelB[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=546,ZoneNumber=0)
	MiscBevelBR[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelBR[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelBR[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2850,ZoneNumber=0)
	MiscBevelArea[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelArea[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelArea[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=546,ZoneNumber=0)
	ComboBtnUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=5154,ZoneNumber=0)
	ComboBtnDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	ComboBtnDisabled=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=11298,ZoneNumber=0)
	HLine=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1314,ZoneNumber=0)
	TabSelectedL=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	TabSelectedM=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1826,ZoneNumber=0)
	TabSelectedR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=14114,ZoneNumber=0)
	TabUnselectedL=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=14626,ZoneNumber=0)
	TabUnselectedM=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=15394,ZoneNumber=0)
	TabUnselectedR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=27938,ZoneNumber=0)
	TabBackground=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function FW_HitTest
