//=============================================================================
// R6WindowEditBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
	if((m_szCurValue != Value))
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
			if((i < Len(Value)))
			{
				m_szValueToDisplay = (m_szValueToDisplay $ "*");
				(i++);
				// [Loop Continue]
				goto J0x6A;
			}			
		}
		else
		{
			// End:0xB1
			if(bCaps)
			{
				m_szValueToDisplay = Caps(Value);				
			}
			else
			{
				m_szValueToDisplay = Value;
			}
		}
		TextSize(C, "W", W, H);
		m_fTextHeight = H;
		m_fYTextPos = ((WinHeight - H) / float(2));
		m_fYTextPos = float(int((m_fYTextPos + 0.5000000)));
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local float fStringLeftOfCaretW, H;

	TextSize(C, Left(m_szValueToDisplay, CaretOffset), fStringLeftOfCaretW, H);
	// End:0x36
	if(m_bDrawEditBoxBG)
	{
		PaintEditBoxBG(C);
	}
	// End:0x57
	if(((fStringLeftOfCaretW + offset) < float(0)))
	{
		offset = (-fStringLeftOfCaretW);
	}
	// End:0xA3
	if(((fStringLeftOfCaretW + offset) > (WinWidth - float(2))))
	{
		offset = ((WinWidth - float(2)) - fStringLeftOfCaretW);
		// End:0xA3
		if((offset > float(0)))
		{
			offset = 0.0000000;
		}
	}
	// End:0xCD
	if(bShowLog)
	{
		Log(("Offset After" @ string(offset)));
		bShowLog = false;
	}
	C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
	// End:0x236
	if((m_CurrentlyEditing && bAllSelected))
	{
		C.Style = 5;
		C.SetDrawColor(Root.Colors.m_LisBoxSelectionColor.R, Root.Colors.m_LisBoxSelectionColor.G, Root.Colors.m_LisBoxSelectionColor.B, byte(Root.Colors.EditBoxSelectAllAlpha));
		DrawStretchedTexture(C, (offset + float(1)), m_fYBGPos, fStringLeftOfCaretW, float(m_RBGEditTexture.H), Texture'UWindow.WhiteTexture');
		C.Style = 5;
		C.SetDrawColor(Root.Colors.m_LisBoxSelectedTextColor.R, Root.Colors.m_LisBoxSelectedTextColor.G, Root.Colors.m_LisBoxSelectedTextColor.B);
	}
	ClipText(C, (offset + float(1)), m_fYTextPos, m_szValueToDisplay);
	// End:0x285
	if((((!m_CurrentlyEditing) || (!bHasKeyboardFocus)) || (!bCanEdit)))
	{
		bShowCaret = false;		
	}
	else
	{
		// End:0x2D0
		if(((GetTime() > (LastDrawTime + 0.3000000)) || (GetTime() < LastDrawTime)))
		{
			LastDrawTime = GetLevel().GetTime();
			bShowCaret = (!bShowCaret);
		}
	}
	// End:0x2FD
	if(bShowCaret)
	{
		ClipText(C, ((offset + fStringLeftOfCaretW) - float(1)), m_fYTextPos, "|");
	}
	return;
}

function PaintEditBoxBG(Canvas C)
{
	C.Style = 5;
	// End:0x35
	if((m_fTextHeight > float(m_RBGEditTexture.H)))
	{
		m_fYBGPos = m_fYTextPos;		
	}
	else
	{
		m_fYBGPos = ((float(m_RBGEditTexture.H) - m_fTextHeight) * 0.5000000);
		m_fYBGPos = float(int((m_fYBGPos + 0.5000000)));
		m_fYBGPos = (m_fYTextPos - m_fYBGPos);
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
