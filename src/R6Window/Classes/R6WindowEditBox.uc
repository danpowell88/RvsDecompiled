//=============================================================================
// R6WindowEditBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowEditBox.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowEditBox extends UWindowEditBox;

var bool bCaps;
var float m_fYTextPos;  // the position of the text in y
var float m_fTextHeight;
var float m_fYBGPos;
var Texture m_TBGEditTexture;
var Region m_RBGEditTexture;  // BackGround texture Region
var string m_szCurValue;  // the current value equal to value of the edit box
var string m_szValueToDisplay;  // what's displaying

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	local int i;

	C.Font = Root.Fonts[Font];
	// End:0x10E
	if(__NFUN_123__(m_szCurValue, Value))
	{
		m_szCurValue = Value;
		super(UWindowDialogControl).BeforePaint(C, X, Y);
		// End:0x98
		if(bPassword)
		{
			m_szValueToDisplay = "";
			i = 0;
			J0x6A:

			// End:0x95 [Loop If]
			if(__NFUN_150__(i, __NFUN_125__(Value)))
			{
				m_szValueToDisplay = __NFUN_112__(m_szValueToDisplay, "*");
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x6A;
			}			
		}
		else
		{
			// End:0xB1
			if(bCaps)
			{
				m_szValueToDisplay = __NFUN_235__(Value);				
			}
			else
			{
				m_szValueToDisplay = Value;
			}
		}
		TextSize(C, "W", W, H);
		m_fTextHeight = H;
		m_fYTextPos = __NFUN_172__(__NFUN_175__(WinHeight, H), float(2));
		m_fYTextPos = float(int(__NFUN_174__(m_fYTextPos, 0.5000000)));
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local float fStringLeftOfCaretW, H;

	TextSize(C, __NFUN_128__(m_szValueToDisplay, CaretOffset), fStringLeftOfCaretW, H);
	// End:0x36
	if(m_bDrawEditBoxBG)
	{
		PaintEditBoxBG(C);
	}
	// End:0x57
	if(__NFUN_176__(__NFUN_174__(fStringLeftOfCaretW, offset), float(0)))
	{
		offset = __NFUN_169__(fStringLeftOfCaretW);
	}
	// End:0xA3
	if(__NFUN_177__(__NFUN_174__(fStringLeftOfCaretW, offset), __NFUN_175__(WinWidth, float(2))))
	{
		offset = __NFUN_175__(__NFUN_175__(WinWidth, float(2)), fStringLeftOfCaretW);
		// End:0xA3
		if(__NFUN_177__(offset, float(0)))
		{
			offset = 0.0000000;
		}
	}
	// End:0xCD
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("Offset After", string(offset)));
		bShowLog = false;
	}
	C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
	// End:0x236
	if(__NFUN_130__(m_CurrentlyEditing, bAllSelected))
	{
		C.Style = 5;
		C.__NFUN_2626__(Root.Colors.m_LisBoxSelectionColor.R, Root.Colors.m_LisBoxSelectionColor.G, Root.Colors.m_LisBoxSelectionColor.B, byte(Root.Colors.EditBoxSelectAllAlpha));
		DrawStretchedTexture(C, __NFUN_174__(offset, float(1)), m_fYBGPos, fStringLeftOfCaretW, float(m_RBGEditTexture.H), Texture'UWindow.WhiteTexture');
		C.Style = 5;
		C.__NFUN_2626__(Root.Colors.m_LisBoxSelectedTextColor.R, Root.Colors.m_LisBoxSelectedTextColor.G, Root.Colors.m_LisBoxSelectedTextColor.B);
	}
	ClipText(C, __NFUN_174__(offset, float(1)), m_fYTextPos, m_szValueToDisplay);
	// End:0x285
	if(__NFUN_132__(__NFUN_132__(__NFUN_129__(m_CurrentlyEditing), __NFUN_129__(bHasKeyboardFocus)), __NFUN_129__(bCanEdit)))
	{
		bShowCaret = false;		
	}
	else
	{
		// End:0x2D0
		if(__NFUN_132__(__NFUN_177__(GetTime(), __NFUN_174__(LastDrawTime, 0.3000000)), __NFUN_176__(GetTime(), LastDrawTime)))
		{
			LastDrawTime = GetLevel().__NFUN_1012__();
			bShowCaret = __NFUN_129__(bShowCaret);
		}
	}
	// End:0x2FD
	if(bShowCaret)
	{
		ClipText(C, __NFUN_175__(__NFUN_174__(offset, fStringLeftOfCaretW), float(1)), m_fYTextPos, "|");
	}
	return;
}

function PaintEditBoxBG(Canvas C)
{
	C.Style = 5;
	// End:0x35
	if(__NFUN_177__(m_fTextHeight, float(m_RBGEditTexture.H)))
	{
		m_fYBGPos = m_fYTextPos;		
	}
	else
	{
		m_fYBGPos = __NFUN_171__(__NFUN_175__(float(m_RBGEditTexture.H), m_fTextHeight), 0.5000000);
		m_fYBGPos = float(int(__NFUN_174__(m_fYBGPos, 0.5000000)));
		m_fYBGPos = __NFUN_175__(m_fYTextPos, m_fYBGPos);
	}
	DrawStretchedTextureSegment(C, 0.0000000, m_fYBGPos, WinWidth, float(m_RBGEditTexture.H), float(m_RBGEditTexture.X), float(m_RBGEditTexture.Y), float(m_RBGEditTexture.W), float(m_RBGEditTexture.H), m_TBGEditTexture);
	return;
}

defaultproperties
{
	m_TBGEditTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_RBGEditTexture=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=29218,ZoneNumber=0)
	m_szCurValue="//N"
	bSelectOnFocus=true
	m_bDrawEditBoxBG=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_bDisplayEditBoxProperties
// REMOVED IN 1.60: var m_bOldShowCaret
// REMOVED IN 1.60: var m_bOldCanEdit
// REMOVED IN 1.60: var m_bOldAllSelected
// REMOVED IN 1.60: var m_bOldCurrentlyEditing
// REMOVED IN 1.60: var m_bOldHasKeyboardFocus
