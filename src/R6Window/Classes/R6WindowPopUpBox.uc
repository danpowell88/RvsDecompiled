//=============================================================================
// R6WindowPopUpBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowPopUpBox.uc : This provides the simple frame for all the pop-up window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/04 * Created by Yannick Joly
//=============================================================================
class R6WindowPopUpBox extends UWindowWindow;

// Right-edge pixel offset in the title label reserved for the countdown timer display
const C_fTITLE_TIME_OFFSET = 10;
// Fixed pixel height of the button bar strip at the bottom of the popup (holds OK/Cancel buttons)
const K_FBUTTON_HEIGHT_REGION = 25;
// Horizontal inset between the popup border and the client area (was 10 in original SDK; changed to 1 by Alex)
const K_BORDER_HOR_OFF = 1;
// Vertical inset between the popup border and the client area
const K_BORDER_VER_OFF = 1;

// Index constants for the m_sBorderForm[4] array; each value selects one side of the popup rectangle
enum eBorderType
{
	Border_Top,                     // 0
	Border_Bottom,                  // 1
	Border_Left,                    // 2
	Border_Right                    // 3
};

// Controls which corner-decoration sprites are rendered; title label uses Top_Corners, frame uses Bottom_Corners
enum eCornerType
{
	No_Corners,                     // 0
	Top_Corners,                    // 1
	Bottom_Corners,                 // 2
	All_Corners                     // 3
};

// One decorated line segment forming a side of the popup border.
// Positions are absolute window-local coordinates (resolved from m_RWindowBorder origin in SetBorderParam).
struct stBorderForm
{
	var Color vColor;   // line color
	var float fXPos;    // absolute X start position
	var float fYPos;    // absolute Y start position
	var float fWidth;   // segment width  (1 = 1-pixel thin line for left/right sides)
	var float fHeight;  // segment height (1 = 1-pixel thin line for top/bottom sides)
	var bool bActive;   // if false, this side is skipped during paint
};

// NEW IN 1.60
var R6WindowPopUpBox.eCornerType m_eCornerType; // which corners of the frame currently have decoration sprites
var UWindowBase.EPopUpID m_ePopUpID;            // identifies this popup instance (used to look up per-popup game options)
var UWindowBase.MessageBoxResult Result;        // current result to report when the popup closes (may change on button press)
var UWindowBase.MessageBoxResult DefaultResult; // baseline result to restore when popup is reused (set in SetupPopUpBox)
var int m_DrawStyle;                            // Unreal draw style for the background (5 = DRAWSTYLE_Translucent)
var int m_iPopUpButtonsType;                    // cached button layout enum; needed to re-apply layout on resize
var bool m_bNoBorderToDraw;
var bool m_bBGFullScreen;  // true if you want the bck for all the screen, false the bck is only for the pop up size
var bool m_bBGClientArea;  // true, draw client area and header background
var bool m_bDetectKey;  // detect escape and enter key
var bool m_bForceButtonLine;  // force to draw the button line
var bool m_bDisablePopUpActive;  // the disable pop-up button is there
var bool m_bPopUpLock;  // if true, popup will not close, only hidewindow will close it
var bool m_bTextWindowOnly;          // when true, client/button areas are hidden — purely informational popup
var bool m_bResizePopUpOnTextLabel;  // auto-resize popup width to fit the title text (measured each Paint)
var bool m_bHideAllChild;            // single-frame suppression flag: hides child windows during a resize measurement frame
var float m_fHBorderHeight;  // Border size
// NEW IN 1.60
var float m_fVBorderWidth;
//////////////////////////////
//Please make sure you set the Padding correctly if you use the offsets values
//////////////////////////////
var float m_fHBorderPadding;  // Allow the borders not to start in corners
// NEW IN 1.60
var float m_fVBorderPadding;
var float m_fHBorderOffset;  // Border offset if you want the borders to
// NEW IN 1.60
var float m_fVBorderOffset;
var Texture m_BGTexture;  // Put = None when no background is needed
var Texture m_HBorderTexture;
// NEW IN 1.60
var Texture m_VBorderTexture;
var Texture m_topLeftCornerT;
var UWindowWindow m_ClientArea;          // main content area (custom child window placed inside the frame)
var UWindowWindow m_ButClientArea;       // button bar area at the bottom (R6WindowPopUpBoxCW instance)
var R6WindowTextLabelExt m_pTextLabel;   // title / message text label at the top of the popup
//This is to create the window that needs the frame
var Class<UWindowWindow> m_ClientClass;  // class used to instantiate m_ClientArea or m_ButClientArea
var Region m_BGTextureRegion;       // sub-region of m_BGTexture atlas used for the fill (X=70,Y=45,W=9,H=18 in defaults)
var Region m_HBorderTextureRegion;  // horizontal border stripe source region in the atlas
// NEW IN 1.60
var Region m_VBorderTextureRegion;  // vertical border stripe source region in the atlas
var Region m_topLeftCornerR;        // top-left corner sprite source region (6x8 px in defaults)
var Region m_RWindowBorder;         // bounding rectangle of the frame/content area below the title label
var Region SimpleBorderRegion;      // 1x1 solid-pixel source region, tiled to draw the button separator line
var stBorderForm m_sBorderForm[4];  // 0=top, 1=bottom, 2=left, 3=right — indexed by eBorderType
var Color m_eCornerColor[4];        // per-corner color indexed by eCornerType (0=none,1=top,2=bottom,3=all)
var Color m_vFullBGColor;  // the full back ground color
var Color m_vClientAreaColor;  // inside the frame pop-up -- include the header

// default initialisation
// we have to set after the create window the parameters you want
function Created()
{
	local int i;

	// All four border segments start inactive (not drawn); color defaulted to blue but bActive=false
	i = 0;
	J0x07:

	// End:0x9A [Loop If]
	if((i < 4))
	{
		m_sBorderForm[i].vColor = Root.Colors.BlueLight;
		m_sBorderForm[i].fXPos = 0.0000000;
		m_sBorderForm[i].fYPos = 0.0000000;
		m_sBorderForm[i].fWidth = 1.0000000;
		m_sBorderForm[i].bActive = false;
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	// All corners default to white; indices match eCornerType (All=3, Top=1, Bottom=2)
	m_eCornerColor[int(3)] = Root.Colors.White;
	m_eCornerColor[int(1)] = Root.Colors.White;
	m_eCornerColor[int(2)] = Root.Colors.White;
	// Background colors pulled from the global color table so all popups share the same palette
	m_vFullBGColor = Root.Colors.m_cBGPopUpContour;
	m_vClientAreaColor = Root.Colors.m_cBGPopUpWindow;
	m_ClientArea = none;
	return;
}

// Pass any UWindowWindow subclass here to have it hosted inside this popup's frame.
// _bButtonBar=true creates a 25px-tall button strip along the bottom edge (parented to OwnerWindow
// so it receives input events independently). _bDrawClientOnBorder=true overlaps the border by 1px.
function CreateClientWindow(Class<UWindowWindow> ClientClass, optional bool _bButtonBar, optional bool _bDrawClientOnBorder)
{
	m_ClientClass = ClientClass;
	// End:0x66
	if(_bButtonBar)
	{
		// Button bar: full width, K_FBUTTON_HEIGHT_REGION (25px) tall, docked to the bottom of m_RWindowBorder
		m_ButClientArea = CreateWindow(m_ClientClass, float(m_RWindowBorder.X), float(((m_RWindowBorder.Y + m_RWindowBorder.H) - 25)), float(m_RWindowBorder.W), 25.0000000, OwnerWindow);		
	}
	else
	{
		// End:0xD0
		if(_bDrawClientOnBorder)
		{
			// Overlap the 1px border so the client fills right to the edge — content draws over the border line
			m_ClientArea = CreateWindow(m_ClientClass, float((m_RWindowBorder.X + 1)), float((m_RWindowBorder.Y - 1)), float((m_RWindowBorder.W - (2 * 1))), float(((m_RWindowBorder.H + (2 * 1)) - 25)), OwnerWindow);			
		}
		else
		{
			// Standard inset: 1px for the border + 1px extra breathing room on each side
			m_ClientArea = CreateWindow(m_ClientClass, float(((m_RWindowBorder.X + 1) + 1)), float(m_RWindowBorder.Y), float(((m_RWindowBorder.W - (2 * 1)) - 1)), float((m_RWindowBorder.H - 25)), OwnerWindow);
		}
	}
	return;
}

// Called each frame before Paint. If the title text is wider than the current label box,
// the popup is widened to fit and re-centered — preventing title text from being clipped.
function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, XOff, fWinWidth;
	local string _szTitleText;
	local float _TextHeight, _X, _Y, _fWidth, _fHeight;

	// End:0x135
	if((m_pTextLabel != none))
	{
		// Measure the title text using the popup title font (Fonts[8]) with a 2-space margin on each side
		C.Font = Root.Fonts[8];
		_szTitleText = m_pTextLabel.GetTextLabel(0);
		TextSize(C, (("  " $ _szTitleText) $ "  "), W, H);
		// End:0x135
		if((W > m_pTextLabel.WinWidth))
		{
			// Text overflows: compute the extra width and re-center the popup horizontally
			XOff = (W - m_pTextLabel.WinWidth);
			_TextHeight = m_pTextLabel.WinHeight;
			_X = (m_pTextLabel.WinLeft - (XOff / float(2)));  // shift left by half the overflow to keep centered
			_Y = m_pTextLabel.WinTop;
			_fWidth = (m_pTextLabel.WinWidth + XOff);
			_fHeight = float(m_RWindowBorder.H);
			ModifyPopUpFrameWindow(_szTitleText, _TextHeight, _X, _Y, _fWidth, _fHeight);
		}
	}
	return;
}

// Main draw entry point. Delegates frame/background rendering to R6WindowLookAndFeel.
// Handles the resize-measurement frame suppression, text-only mode, and button separator line.
function Paint(Canvas C, float X, float Y)
{
	// End:0x7F
	if(m_bResizePopUpOnTextLabel)
	{
		// During a resize frame, push the "pre-calculate" flag to child windows so they
		// defer layout. m_bHideAllChild is set true by ResizePopUp/ShowWindow and cleared here.
		if((m_pTextLabel != none))
		{
			m_pTextLabel.m_bPreCalculatePos = m_bHideAllChild;
		}
		// End:0x4B
		if((m_ClientArea != none))
		{
			m_ClientArea.m_bPreCalculatePos = m_bHideAllChild;
		}
		// End:0x6C
		if((m_ButClientArea != none))
		{
			m_ButClientArea.m_bPreCalculatePos = m_bHideAllChild;
		}
		// End:0x7F
		if(m_bHideAllChild)
		{
			// Skip this paint frame entirely while child positions are being recalculated
			m_bHideAllChild = false;
			return;
		}
	}
	// Delegate border/background rendering to the current look-and-feel; reads m_sBorderForm, m_BGTexture, etc.
	R6WindowLookAndFeel(LookAndFeel).DrawPopUpFrameWindow(self, C);
	// End:0xD8
	if(m_bTextWindowOnly)
	{
		// Text-only mode: hide interactive child windows and exit — this popup is purely informational
		if((m_ClientArea != none))
		{
			m_ClientArea.HideWindow();
		}
		// End:0xD6
		if((m_ButClientArea != none))
		{
			m_ButClientArea.HideWindow();
		}
		return;
	}
	// End:0x186
	if(((m_ButClientArea != none) || m_bForceButtonLine))
	{
		// Draw a 1px white separator line between the content area and the button bar.
		// SimpleBorderRegion is a 1x1 pixel from the atlas, stretched to (WinWidth-2) wide by 1px tall.
		C.SetDrawColor(byte(255), byte(255), byte(255));
		DrawStretchedTextureSegment(C, float((m_RWindowBorder.X + 1)), float(((m_RWindowBorder.Y + m_RWindowBorder.H) - 25)), float((m_RWindowBorder.W - 2)), 1.0000000, float(SimpleBorderRegion.X), float(SimpleBorderRegion.Y), float(SimpleBorderRegion.W), float(SimpleBorderRegion.H), m_BGTexture);
	}
	return;
}

//===========================================================================
// function to create a std pop up window with clientwindow (for button)
//===========================================================================
// Convenience factory for a standard confirmation dialog: title label + frame + OK/Cancel buttons.
// _fTextHeight is the pixel height of the title strip; _fHeight is the content area height below it.
// _iButtonsType maps to MessageBoxButtons (default=0 → MB_OKCancel).
function CreateStdPopUpWindow(string _szPopUpTitle, float _fTextHeight, float _fXPos, float _fYPos, float _fWidth, float _fHeight, optional int _iButtonsType)
{
	CreateTextWindow(_szPopUpTitle, _fXPos, _fYPos, _fWidth, _fTextHeight);
	// Frame starts at _fYPos + _fTextHeight so it sits directly below the title label
	CreatePopUpFrame(_fXPos, (_fYPos + _fTextHeight), _fWidth, _fHeight);
	CreateClientWindow(Class'R6Window.R6WindowPopUpBoxCW', true);
	SetButtonsType(_iButtonsType);
	return;
}

//===========================================================================
// function to create a std pop up window (only the visual)
//===========================================================================
// Visual-only variant of CreateStdPopUpWindow — creates title + frame but no button bar.
// Used when the caller manages buttons itself via a custom m_ClientArea.
function CreatePopUpFrameWindow(string _szPopUpTitle, float _fTextHeight, float _fXPos, float _fYPos, float _fWidth, float _fHeight)
{
	CreateTextWindow(_szPopUpTitle, _fXPos, _fYPos, _fWidth, _fTextHeight);
	CreatePopUpFrame(_fXPos, (_fYPos + _fTextHeight), _fWidth, _fHeight);
	return;
}

// Re-layouts an already-created popup with new position and size — called by BeforePaint when title
// text overflows, or by ResizePopUp when auto-width is recalculated.  Recreates m_RWindowBorder and
// repositions both button bar and content area to match.
function ModifyPopUpFrameWindow(string _szPopUpTitle, float _fTextHeight, float _fXPos, float _fYPos, float _fWidth, float _fHeight, optional int _iButtonsType)
{
	m_bTextWindowOnly = false;
	ModifyTextWindow(_szPopUpTitle, _fXPos, _fYPos, _fWidth, _fTextHeight);
	// Rebuild m_RWindowBorder and border segments with the new dimensions
	CreatePopUpFrame(_fXPos, (_fYPos + _fTextHeight), _fWidth, _fHeight);
	// End:0xD3
	if((m_ButClientArea != none))
	{
		// Reposition button bar to the bottom 25px of the new frame
		m_ButClientArea.WinLeft = float(m_RWindowBorder.X);
		m_ButClientArea.WinTop = float(((m_RWindowBorder.Y + m_RWindowBorder.H) - 25));
		m_ButClientArea.WinWidth = float(m_RWindowBorder.W);
		m_ButClientArea.WinHeight = 25.0000000;
		SetButtonsType(_iButtonsType);
	}
	// End:0x149
	if((m_ClientArea != none))
	{
		// Reposition content area with 1px horizontal inset, filling everything above the button bar
		m_ClientArea.WinLeft = float((m_RWindowBorder.X + 1));
		m_ClientArea.WinTop = float(m_RWindowBorder.Y);
		m_ClientArea.SetSize(float((m_RWindowBorder.W - (2 * 1))), float((m_RWindowBorder.H - 25)));
	}
	return;
}

//===========================================================================
// function create the text window
//===========================================================================
// Creates the title/message label at the top of the popup with decorative borders.
// SetBorderParam(side, thickness, offset, lineWidth, color): side 0=top uses 7px thickness
// to produce the thick top bar that is the signature visual of R6 popup headers.
function CreateTextWindow(string _szTitleText, float _X, float _Y, float _fWidth, float _fHeight)
{
	m_pTextLabel = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', _X, _Y, _fWidth, _fHeight, self));
	// SetBorderParam(side, thickness, padding, lineWidth, color)
	m_pTextLabel.SetBorderParam(0, 7.0000000, 0.0000000, 1.0000000, Root.Colors.White); // Top: 7px thick signature bar
	m_pTextLabel.SetBorderParam(1, 1.0000000, 0.0000000, 1.0000000, Root.Colors.White); // Bottom: thin divider line
	m_pTextLabel.SetBorderParam(2, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White); // Left: 1px with 1px padding
	m_pTextLabel.SetBorderParam(3, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White); // Right: 1px with 1px padding
	m_pTextLabel.m_Font = Root.Fonts[8]; // Fonts[8] = F_PopUpTitle (popup title font)
	m_pTextLabel.m_vTextColor = Root.Colors.White;
	// Label index 0: main centered title text; bAutoResize=m_bResizePopUpOnTextLabel triggers ResizePopUp when true
	m_pTextLabel.AddTextLabel(_szTitleText, 0.0000000, 0.0000000, _fWidth, 2, false, 0.0000000, m_bResizePopUpOnTextLabel);
	// Label index 1: right-aligned countdown timer slot, C_fTITLE_TIME_OFFSET (10px) from right edge
	m_pTextLabel.AddTextLabel("", (_fWidth - float(10)), 0.0000000, 0.0000000, 1, false, 0.0000000, true);
	m_pTextLabel.m_bTextCenterToWindow = true;
	m_pTextLabel.m_eCornerType = 1; // Top_Corners: corner decorations on top-left and top-right only
	SetCornerColor(1, Root.Colors.White);
	return;
}

// Updates an existing title label in-place (called on resize).
// Clears all text entries and re-adds them with the new width so line-wrapping is recalculated.
function ModifyTextWindow(string _szTitleText, float _X, float _Y, float _fWidth, float _fHeight)
{
	// End:0x1DB
	if((m_pTextLabel != none))
	{
		m_pTextLabel.WinLeft = _X;
		m_pTextLabel.WinTop = _Y;
		m_pTextLabel.WinWidth = _fWidth;
		m_pTextLabel.WinHeight = _fHeight;
		m_pTextLabel.SetBorderParam(0, 7.0000000, 0.0000000, 1.0000000, Root.Colors.White); // Top: 7px thick bar
		m_pTextLabel.SetBorderParam(1, 1.0000000, 0.0000000, 1.0000000, Root.Colors.White); // Bottom: divider
		m_pTextLabel.SetBorderParam(2, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White); // Left
		m_pTextLabel.SetBorderParam(3, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White); // Right
		// Clear existing text entries before re-adding with the new width
		m_pTextLabel.Clear();
		m_pTextLabel.m_vTextColor = Root.Colors.White;
		m_pTextLabel.AddTextLabel(_szTitleText, 0.0000000, 0.0000000, _fWidth, 2, false, 0.0000000, m_bResizePopUpOnTextLabel);
		m_pTextLabel.AddTextLabel("", (_fWidth - float(10)), 0.0000000, 0.0000000, 1, false, 0.0000000, true);
		m_pTextLabel.m_bTextCenterToWindow = true;
	}
	return;
}

// Switches popup to notification-only mode: hides the frame border and button bar,
// leaving only the text label visible. Used for tooltips and non-interactive alerts.
// Both top and bottom borders get 7px making it a fully enclosed box — no frame needed below.
function TextWindowOnly(string _szTitleText, float _X, float _Y, float _fWidth, float _fHeight)
{
	// End:0x1D4
	if((m_pTextLabel != none))
	{
		m_bTextWindowOnly = true;
		SetNoBorder();           // disable the frame border segments
		m_eCornerType = 0;       // No_Corners: no corner sprites on the popup frame itself
		m_RWindowBorder.H = 0;   // collapse frame height so Paint skips the button separator line
		m_pTextLabel.WinLeft = _X;
		m_pTextLabel.WinTop = _Y;
		m_pTextLabel.WinWidth = _fWidth;
		m_pTextLabel.WinHeight = _fHeight;
		// Both top and bottom get 7px thick bars — creates a visually enclosed standalone text box
		m_pTextLabel.SetBorderParam(0, 7.0000000, 0.0000000, 1.0000000, Root.Colors.White); // Top: 7px thick bar
		m_pTextLabel.SetBorderParam(1, 7.0000000, 0.0000000, 1.0000000, Root.Colors.White); // Bottom: 7px thick bar
		m_pTextLabel.SetBorderParam(2, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White); // Left
		m_pTextLabel.SetBorderParam(3, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White); // Right
		m_pTextLabel.m_eCornerType = 3; // All_Corners: render decorations on all four corners
		m_pTextLabel.Clear();
		m_pTextLabel.m_vTextColor = Root.Colors.White;
		m_pTextLabel.AddTextLabel(_szTitleText, 0.0000000, 0.0000000, _fWidth, 2, false);
		m_pTextLabel.m_bTextCenterToWindow = true;
	}
	return;
}

// Updates the countdown timer displayed in the top-right slot of the title label (index 1).
// Turns red when under 10 seconds to warn the player. Pass _iNewTime=-1 to blank the timer,
// or supply _StringInstead to show an arbitrary string (e.g. "DONE") instead of a time value.
function UpdateTimeInTextLabel(int _iNewTime, optional string _StringInstead)
{
	local Color vTimeColor;
	local string szTemp;

	// End:0xC6
	if((m_pTextLabel != none))
	{
		vTimeColor = Root.Colors.White;
		// End:0x51
		if((_iNewTime < 10))
		{
			vTimeColor = Root.Colors.Red; // urgency indicator: time is almost up
		}
		// End:0x6B
		if((_StringInstead != ""))
		{
			szTemp = _StringInstead; // caller-supplied string overrides numeric formatting			
		}
		else
		{
			// End:0x85
			if((_iNewTime == -1))
			{
				szTemp = ""; // -1 is the sentinel for "clear the timer display"				
			}
			else
			{
				szTemp = Class'Engine.Actor'.static.ConvertIntTimeToString(_iNewTime);
			}
		}
		// Update label slot 1 (right-aligned timer slot created in CreateTextWindow)
		m_pTextLabel.ChangeColorLabel(vTimeColor, 1);
		m_pTextLabel.ChangeTextLabel(szTemp, 1);
	}
	return;
}

//===========================================================================
// function create the pop up frame under the text window
//===========================================================================
// Defines m_RWindowBorder (the content rectangle) and activates three border segments.
// The top border is intentionally disabled — the text label's bottom border serves as that edge.
// The -14 for the bottom border width leaves 7px on each side for the bottom corner sprites.
function CreatePopUpFrame(float _X, float _Y, float _fWidth, float _fHeight)
{
	local float fBorderSize, fBorderWidth;

	fBorderSize = 1.0000000;  // 1px distance from frame edge to border line
	fBorderWidth = 1.0000000; // 1px line thickness
	// Store bounding rect used by CreateClientWindow and Paint to position child windows
	m_RWindowBorder.X = int(_X);
	m_RWindowBorder.Y = int(_Y);
	m_RWindowBorder.W = int(_fWidth);
	m_RWindowBorder.H = int(_fHeight);
	ActiveBorder(int(0), false); // top border off — the title label provides that edge
	// Bottom border: starts 7px in from the left (offset 7), placed 1px from the bottom, width = frame - 14 (7px per side for corners)
	SetBorderParam(int(1), 7.0000000, (_fHeight - fBorderSize), (_fWidth - float(14)), fBorderWidth, Root.Colors.White);
	// Left border: 1px from left edge, full height minus 1px top and bottom to avoid overlapping corners
	SetBorderParam(int(2), fBorderSize, 0.0000000, fBorderWidth, (_fHeight - (float(2) * fBorderSize)), Root.Colors.White);
	// Right border: 2px from the right edge (1px border + 1px inset), same height as left
	SetBorderParam(int(3), (_fWidth - float(2)), 0.0000000, fBorderWidth, (_fHeight - (float(2) * fBorderSize)), Root.Colors.White);
	m_eCornerType = 2; // Bottom_Corners: render corner decorations on the bottom-left and bottom-right
	SetCornerColor(int(2), Root.Colors.White);
	return;
}

//===========================================================================
// function to assign each border param
//===========================================================================
// Stores one border segment's parameters and marks it active.
// _X/_Y are relative to m_RWindowBorder origin; they are converted to absolute coords here.
// Automatically clears m_bNoBorderToDraw so LookAndFeel knows to render borders this frame.
function SetBorderParam(int _iBorderType, float _X, float _Y, float _fWidth, float _fHeight, Color _vColor)
{
	m_sBorderForm[_iBorderType].fXPos = (_X + float(m_RWindowBorder.X)); // convert to absolute window coords
	m_sBorderForm[_iBorderType].fYPos = (_Y + float(m_RWindowBorder.Y));
	m_sBorderForm[_iBorderType].fWidth = _fWidth;
	m_sBorderForm[_iBorderType].fHeight = _fHeight;
	m_sBorderForm[_iBorderType].vColor = _vColor;
	m_sBorderForm[_iBorderType].bActive = true;
	m_bNoBorderToDraw = false;
	return;
}

//===========================================================================
// function to active border or not
//===========================================================================
// Enables or disables an individual border side.  After changing the flag, scans all four sides
// to update the m_bNoBorderToDraw shortcut — allowing LookAndFeel to skip the border pass entirely.
// NOTE: the loop body checks m_sBorderForm[_iBorderType] (the same slot) every iteration; this is a
// known SDK bug — it should check m_sBorderForm[i] to scan all slots, but retail does it this way.
// active border or not
function ActiveBorder(int _iBorderType, bool _Active)
{
	local int i;
	local bool bNoBorderToDraw;

	m_sBorderForm[_iBorderType].bActive = _Active;
	bNoBorderToDraw = true; // assume no borders active until proven otherwise
	i = 0;
	J0x27:

	// End:0x5C [Loop If]
	if((i < 4))
	{
		// End:0x52
		if(m_sBorderForm[_iBorderType].bActive) // BUG: should be m_sBorderForm[i] to check all slots
		{
			bNoBorderToDraw = false;
			// [Explicit Break]
			goto J0x5C;
		}
		(i++);
		// [Loop Continue]
		goto J0x27;
	}
	J0x5C:

	m_bNoBorderToDraw = bNoBorderToDraw;
	return;
}

// Unconditionally disables border rendering — used by TextWindowOnly() to produce a border-free label
function SetNoBorder()
{
	m_bNoBorderToDraw = true;
	return;
}

// Sets the color for corner decoration sprites.  All_Corners (3) requires setting Top and Bottom
// separately first because the paint switch renders corners via Top/Bottom paths, not All_Corners.
// set the corner color
function SetCornerColor(int _iCornerType, Color _Color)
{
	// End:0x2E
	if((_iCornerType == int(3))) // All_Corners: propagate to both Top and Bottom sub-entries
	{
		m_eCornerColor[int(1)] = _Color; // Top_Corners
		m_eCornerColor[int(2)] = _Color; // Bottom_Corners
	}
	m_eCornerColor[_iCornerType] = _Color;
	return;
}

//===========================================================================
// ResizePopUp: set a new width for the popup base on the size of the text label 
//===========================================================================
// Called by R6WindowTextLabelExt when auto-resize is enabled and the text width changes.
// Re-centers the popup on the assumed 640px-wide screen, then re-layouts all sub-windows.
// Adding 0.5 before truncation implements rounding (int() truncates, not rounds).
function ResizePopUp(float _fNewWidth)
{
	local float fTemp;
	local int ITemp;

	// Center horizontally: (640 - newWidth) / 2, rounded to nearest pixel
	fTemp = ((640.0000000 - _fNewWidth) * 0.5000000);
	(fTemp += 0.5000000); // round: add 0.5 before integer truncation
	ITemp = int(fTemp);
	// Suppress child window paint for one frame while layout is recalculated
	m_bHideAllChild = true;
	ModifyPopUpFrameWindow(m_pTextLabel.GetTextLabel(0), m_pTextLabel.WinHeight, float(ITemp), m_pTextLabel.WinTop, _fNewWidth, float(m_RWindowBorder.H), m_iPopUpButtonsType);
	return;
}

// Enables or disables the auto-resize-on-text-measurement path.
// When enabling, also sets m_bHideAllChild to suppress one frame of child rendering
// while the initial text measurement and layout takes place.
function SetPopUpResizable(bool _bResizable)
{
	m_bResizePopUpOnTextLabel = _bResizable;
	m_bHideAllChild = _bResizable; // suppress child paint on the first frame after enabling
	return;
}

//===========================================================================
// function to set pop up window button 
//===========================================================================
// Maps a MessageBoxButtons enum value to a concrete button layout and result codes.
// Enum values are decompiled as raw ints: 1=MB_OKCancel, 2=MB_OK, 4=MB_Cancel, 5=MB_None.
// MessageBoxResult values: 0=MR_None, 3=MR_OK, 4=MR_Cancel.
// The ESC result is the default close result; InEnterResult (optional 3rd arg) overrides Enter.
function SetButtonsType(int _iButtonsType)
{
	m_iPopUpButtonsType = _iButtonsType;
	switch(_iButtonsType)
	{
		// End:0x28
		case int(2): // MB_OK: single OK button; both ESC and Enter yield MR_OK (3)
			SetupPopUpBox(2, 3, 3);
			// End:0x62
			break;
		// End:0x3C
		case int(4): // MB_Cancel: cancel-only button; ESC yields MR_OK (3) — dismiss without action
			SetupPopUpBox(4, 3);
			// End:0x62
			break;
		// End:0x50
		case int(5): // MB_None: no buttons; ESC yields MR_None (0) — programmatic close only
			SetupPopUpBox(5, 0);
			// End:0x62
			break;
		// End:0xFFFF
		default: // MB_OKCancel (1): ESC=MR_Cancel (4), Enter=MR_OK (3)
			SetupPopUpBox(1, 4, 3);
			// End:0x62
			break;
			break;
	}
	return;
}

//===========================================================================
// function to set pop up window button 
//===========================================================================
// Configures button layout and result codes.  Passes the button arrangement to R6WindowPopUpBoxCW
// which creates the actual button widgets.  Stores InESCResult as both Result and DefaultResult
// so the popup can be safely reused (Result is reset to DefaultResult on every Close()).
function SetupPopUpBox(UWindowBase.MessageBoxButtons Buttons, UWindowBase.MessageBoxResult InESCResult, optional UWindowBase.MessageBoxResult InEnterResult)
{
	// End:0x2E
	if((m_ButClientArea != none))
	{
		// Delegate button widget creation to the button-bar child window
		R6WindowPopUpBoxCW(m_ButClientArea).SetupPopUpBoxClient(Buttons, InESCResult, InEnterResult);
	}
	Result = InESCResult;         // current close result (may be overwritten by a button press before Close)
	DefaultResult = InESCResult;  // saved baseline to restore in Close() when popup is reused
	return;
}

//===========================================================================
// Close the pop up window and advice owner
//===========================================================================
// Modal close handler — the central result-dispatch point for all popup dialogs.
// Order of operations: lock check → save "disable" preference → release focus → notify callers → reset result.
function Close(optional bool bByParent)
{
	local R6GameOptions pGameOptions;
	local bool bGOSaveConfig;

	// End:0x0B
	if(m_bPopUpLock)
	{
		// Locked popups can only be dismissed via HideWindow() — ignore Close() calls entirely
		return;
	}
	super.Close(bByParent);
	// End:0x132
	if(m_bDisablePopUpActive)
	{
		// "Don't show this again" checkbox was shown — read its state and persist to GameOptions
		if((m_ButClientArea != none))
		{
			pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
			bGOSaveConfig = true;
			// m_bSelected=true means "disable popup", so we negate it to get the "should show" flag
			switch(m_ePopUpID)
			{
				// End:0x83
				case 39: // EPopUpID_QuickPlay
					pGameOptions.PopUpQuickPlay = (!R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected);
					// End:0x11D
					break;
				// End:0xBA
				case 48: // EPopUpID_LoadPlanning
					pGameOptions.PopUpLoadPlan = (!R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected);
					// End:0x11D
					break;
				// End:0xFFFF
				default:
					Log("Need to add your disable/enable pop-up ID in game options to have this feature ON");
					bGOSaveConfig = false;
					// End:0x11D
					break;
					break;
			}
			// End:0x132
			if(bGOSaveConfig)
			{
				pGameOptions.SaveConfig(); // persist to .ini so the preference survives game restart
			}
		}
	}
	// End:0x151
	if((m_ButClientArea != none))
	{
		// Return keyboard focus back to whatever window had it before the popup opened
		R6WindowPopUpBoxCW(m_ButClientArea).CancelAcceptsFocus();
	}
	// Broadcast the result to the owning window — this is the primary callback mechanism
	OwnerWindow.PopUpBoxDone(Result, m_ePopUpID);
	// End:0x18E
	if((m_ClientArea != none))
	{
		// Also notify the content area in case it needs to react (e.g. custom content windows)
		m_ClientArea.PopUpBoxDone(Result, m_ePopUpID);
	}
	// Reset Result to DefaultResult so the popup can be safely shown again without stale data
	Result = DefaultResult;
	return;
}

//===========================================================================
// This allows the client area to get notified of showwindows
//===========================================================================
// Overrides ShowWindow to: trigger the initial resize-measurement frame, hand keyboard focus
// to the button bar (so Enter/Escape work immediately), and propagate Show to the client area.
function ShowWindow()
{
	super.ShowWindow();
	// End:0x17
	if(m_bResizePopUpOnTextLabel)
	{
		// Request one suppressed paint frame so text can be measured and layout recalculated
		m_bHideAllChild = true;
	}
	// End:0x3F
	if(m_bDetectKey)
	{
		// End:0x3F
		if((m_ButClientArea != none))
		{
			// Grant keyboard focus to the button bar so it can intercept Enter/Escape
			R6WindowPopUpBoxCW(m_ButClientArea).SetAcceptsFocus();
		}
	}
	// End:0x59
	if((m_ClientArea != none))
	{
		// Propagate show to the content area — it may have been hidden while the popup was closed
		m_ClientArea.ShowWindow();
	}
	return;
}

// Shows the popup in locked mode: the user cannot close it via normal input.
// Only an explicit HideWindow() call will dismiss it (e.g. from a loading screen completion event).
function ShowLockPopUp()
{
	m_bPopUpLock = true;
	ShowWindow();
	return;
}

// Clears the popup lock before hiding, allowing the next ShowWindow() to be closable normally.
// This is also the intended dismiss path for popups shown with ShowLockPopUp().
function HideWindow()
{
	m_bPopUpLock = false;
	super.HideWindow();
	return;
}

// Routes keyboard events to the button bar when m_bDetectKey is enabled.
// WM_KeyDown = int(9); the button bar's KeyDown handles Enter (accept) and Escape (cancel).
function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	super.WindowEvent(Msg, C, X, Y, Key);
	// End:0x7A
	if(m_bDetectKey)
	{
		// End:0x7A
		if((int(Msg) == int(9))) // WM_KeyDown = 9
		{
			// End:0x7A
			if((m_ButClientArea != none))
			{
				// End:0x7A
				if(m_ButClientArea.IsA('R6WindowPopUpBoxCW'))
				{
					// R6WindowPopUpBoxCW.KeyDown maps Enter→MR_OK and Escape→MR_Cancel then calls Close
					R6WindowPopUpBoxCW(m_ButClientArea).KeyDown(Key, X, Y);
				}
			}
		}
	}
	return;
}

//=========================================================================================
// AddDisableDLG: add a disable text and box to disable-enable pop-up
//=========================================================================================
// Adds a "Don't show this again" checkbox to the button bar and initializes it from saved settings.
// The checkbox state is the logical inverse of the GameOptions flag (checked=disabled, unchecked=enabled).
// Only specific popup IDs (QuickPlay=39, LoadPlanning=48) have persisted preferences.
function AddDisableDLG()
{
	local R6GameOptions pGameOptions;

	// End:0xAC
	if((m_ButClientArea != none))
	{
		R6WindowPopUpBoxCW(m_ButClientArea).AddDisablePopUpButton();
		pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
		// Initialize checkbox state from saved preference for this popup ID.
		// PopUpQuickPlay=true means "show popup", so checkbox should be unchecked (m_bSelected=false).
		switch(m_ePopUpID)
		{
			// End:0x6F
			case 39: // EPopUpID_QuickPlay
				R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected = (!pGameOptions.PopUpQuickPlay);
				// End:0xAC
				break;
			// End:0xA6
			case 48: // EPopUpID_LoadPlanning
				R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected = (!pGameOptions.PopUpLoadPlan);
				// End:0xAC
				break;
			// End:0xFFFF
			default:
				// End:0xAC
				break;
				break;
		}
	}
	m_bDisablePopUpActive = true;
	return;
}

//=========================================================================================
// RemoveDisableDLG: remove a disable text and box to disable-enable pop-up
//=========================================================================================
// Hides the "Don't show again" checkbox and disables the preference-save logic in Close().
function RemoveDisableDLG()
{
	// End:0x1F
	if((m_ButClientArea != none))
	{
		R6WindowPopUpBoxCW(m_ButClientArea).RemoveDisablePopUpButton();
	}
	m_bDisablePopUpActive = false;
	return;
}

// Default property values applied when a popup instance is created.
// All textures reference Gui_BoxScroll, a multipurpose atlas in R6MenuTextures.
// The iLeaf-encoded Region values are a decompiler artifact; decoded values are:
//   m_BGTextureRegion      = (X=70, Y=45, W=9,  H=18) — tileable background panel slice
//   m_HBorderTextureRegion = (X=64, Y=56, W=1,  H=1)  — 1x1 solid pixel, tiled into horizontal lines
//   m_VBorderTextureRegion = (X=64, Y=56, W=1,  H=1)  — 1x1 solid pixel, tiled into vertical lines
//   m_topLeftCornerR       = (X=12, Y=56, W=6,  H=8)  — 6x8 px corner decoration sprite
//   SimpleBorderRegion     = (X=64, Y=56, W=1,  H=1)  — 1x1 solid pixel for the button separator line
defaultproperties
{
	m_DrawStyle=5          // DRAWSTYLE_Translucent — renders the background with alpha blending
	m_bBGFullScreen=true   // darkens/draws over the entire screen behind the popup (not just the popup rect)
	m_bBGClientArea=true   // also draws the inner client area and header background
	m_bDetectKey=true      // keyboard Enter/Escape handled by default (routes through WindowEvent)
	m_fHBorderHeight=2.0000000  // horizontal border stripe height: 2px
	m_fVBorderWidth=2.0000000   // vertical border stripe width: 2px
	m_fHBorderPadding=7.0000000 // 7px gap between horizontal border start and window corner (room for corner sprites)
	m_fVBorderPadding=2.0000000 // 2px gap between vertical border start and window corner
	m_fVBorderOffset=1.0000000  // side borders start 1px inside the window edge
	m_BGTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_HBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_VBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_topLeftCornerT=Texture'R6MenuTextures.Gui_BoxScroll'
	m_ClientClass=Class'UWindow.UWindowClientWindow'
	m_BGTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=17954,ZoneNumber=0)
	m_HBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
	m_VBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
	m_topLeftCornerR=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=3106,ZoneNumber=0)
	SimpleBorderRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eCornerType
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var t
