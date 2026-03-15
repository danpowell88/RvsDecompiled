//=============================================================================
// R6WindowFramedWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowFramedWindow.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowFramedWindow extends UWindowWindow;

var UWindowBase.TextAlign m_TitleAlign;
var bool m_bTLSizing;
var bool m_bTSizing;
var bool m_bTRSizing;
var bool m_bLSizing;
var bool m_bRSizing;
var bool m_bBLSizing;
var bool m_bBSizing;
var bool m_bBRSizing;
var bool m_bMoving;
var bool m_bSizable;
var bool m_bMovable;
var bool m_bDisplayClose;
var float m_fMoveX;  // co-ordinates where the move was requested
// NEW IN 1.60
var float m_fMoveY;
var float m_fMinWinWidth;
// NEW IN 1.60
var float m_fMinWinHeight;
var float m_fTitleOffSet;
var UWindowWindow m_ClientArea;
var UWindowButton m_CloseBoxButton;
var Class<UWindowWindow> m_ClientClass;
var localized string m_szWindowTitle;
var string m_szStatusBarText;

function Created()
{
	m_ClientArea = CreateWindow(m_ClientClass, float(LookAndFeel.FrameL.W), float(LookAndFeel.FrameT.H), (WinWidth - float((LookAndFeel.FrameL.W + LookAndFeel.FrameR.W))), (WinHeight - float((LookAndFeel.FrameB.H + LookAndFeel.FrameT.H))), OwnerWindow);
	// End:0x138
	if(m_bDisplayClose)
	{
		m_CloseBoxButton = UWindowFrameCloseBox(CreateWindow(Class'UWindow.UWindowFrameCloseBox', (((WinWidth - float(LookAndFeel.FrameTL.W)) - float(R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.W)) - float(1)), 1.0000000, float(R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.W), float(R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.H), self));
	}
	return;
}

function Texture GetLookAndFeelTexture()
{
	return R6WindowLookAndFeel(LookAndFeel).R6GetTexture(self);
	return;
}

function bool IsActive()
{
	return (ParentWindow.ActiveWindow == self);
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	super.BeforePaint(C, X, Y);
	// End:0x24
	if(m_bSizable)
	{
		Resized();
	}
	// End:0x49
	if((m_CloseBoxButton != none))
	{
		R6WindowLookAndFeel(LookAndFeel).R6FW_SetupFrameButtons(self, C);
	}
	// End:0x10E
	if((m_szWindowTitle != ""))
	{
		C.Font = Root.Fonts[8];
		TextSize(C, m_szWindowTitle, W, H);
		switch(m_TitleAlign)
		{
			// End:0xBA
			case 0:
				m_fTitleOffSet = float(LookAndFeel.FrameTL.W);
				// End:0x10E
				break;
			// End:0xEB
			case 1:
				m_fTitleOffSet = ((WinWidth - W) - float(LookAndFeel.FrameTL.W));
				// End:0x10E
				break;
			// End:0x10B
			case 2:
				m_fTitleOffSet = ((WinWidth - W) / float(2));
				// End:0x10E
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

function Paint(Canvas C, float X, float Y)
{
	R6WindowLookAndFeel(LookAndFeel).R6FW_DrawWindowFrame(self, C);
	return;
}

function LMouseDown(float X, float Y)
{
	local UWindowBase.FrameHitTest H;

	super.LMouseDown(X, Y);
	H = R6WindowLookAndFeel(LookAndFeel).R6FW_HitTest(self, X, Y);
	// End:0x7D
	if(m_bMovable)
	{
		// End:0x7D
		if((int(H) == int(8)))
		{
			m_fMoveX = X;
			m_fMoveY = Y;
			m_bMoving = true;
			Root.CaptureMouse();
			return;
		}
	}
	// End:0x180
	if(m_bSizable)
	{
		switch(H)
		{
			// End:0xAB
			case 0:
				m_bTLSizing = true;
				Root.CaptureMouse();
				return;
			// End:0xC9
			case 2:
				m_bTRSizing = true;
				Root.CaptureMouse();
				return;
			// End:0xE7
			case 5:
				m_bBLSizing = true;
				Root.CaptureMouse();
				return;
			// End:0x105
			case 7:
				m_bBRSizing = true;
				Root.CaptureMouse();
				return;
			// End:0x123
			case 1:
				m_bTSizing = true;
				Root.CaptureMouse();
				return;
			// End:0x141
			case 6:
				m_bBSizing = true;
				Root.CaptureMouse();
				return;
			// End:0x15F
			case 3:
				m_bLSizing = true;
				Root.CaptureMouse();
				return;
			// End:0x17D
			case 4:
				m_bRSizing = true;
				Root.CaptureMouse();
				return;
			// End:0xFFFF
			default:
				break;
			}
	}
	else
	{
		return;
	}
}

function Resized()
{
	local Region R;

	// End:0x0D
	if((m_ClientArea == none))
	{
		return;
	}
	R = R6WindowLookAndFeel(LookAndFeel).R6FW_GetClientArea(self);
	m_ClientArea.WinLeft = float(R.X);
	m_ClientArea.WinTop = float(R.Y);
	// End:0xC5
	if(((float(R.W) != m_ClientArea.WinWidth) || (float(R.H) != m_ClientArea.WinHeight)))
	{
		m_ClientArea.SetSize(float(R.W), float(R.H));
	}
	return;
}

function MouseMove(float X, float Y)
{
	local float fOldW, fOldH;
	local UWindowBase.FrameHitTest H;

	H = R6WindowLookAndFeel(LookAndFeel).R6FW_HitTest(self, X, Y);
	// End:0x87
	if(m_bMovable)
	{
		// End:0x7F
		if((m_bMoving && bMouseDown))
		{
			WinLeft = float(int(((WinLeft + X) - m_fMoveX)));
			WinTop = float(int(((WinTop + Y) - m_fMoveY)));			
		}
		else
		{
			m_bMoving = false;
		}
	}
	Cursor = Root.NormalCursor;
	// End:0x13F
	if((m_bSizable && (!m_bMoving)))
	{
		switch(H)
		{
			// End:0xBD
			case 0:
			// End:0xD9
			case 7:
				Cursor = Root.DiagCursor1;
				// End:0x13F
				break;
			// End:0xDE
			case 2:
			// End:0xFA
			case 5:
				Cursor = Root.DiagCursor2;
				// End:0x13F
				break;
			// End:0xFF
			case 3:
			// End:0x11B
			case 4:
				Cursor = Root.WECursor;
				// End:0x13F
				break;
			// End:0x120
			case 1:
			// End:0x13C
			case 6:
				Cursor = Root.NSCursor;
				// End:0x13F
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		// End:0x469
		if(bMouseDown)
		{
			// End:0x1ED
			if(m_bTLSizing)
			{
				Cursor = Root.DiagCursor1;
				fOldW = WinWidth;
				fOldH = WinHeight;
				SetSize(float(Max(int(m_fMinWinWidth), int((WinWidth - X)))), float(Max(int(m_fMinWinHeight), int((WinHeight - Y)))));
				WinLeft = float(int(((WinLeft + fOldW) - WinWidth)));
				WinTop = float(int(((WinTop + fOldH) - WinHeight)));
			}
			// End:0x256
			if(m_bTSizing)
			{
				Cursor = Root.NSCursor;
				fOldH = WinHeight;
				SetSize(WinWidth, float(Max(int(m_fMinWinHeight), int((WinHeight - Y)))));
				WinTop = float(int(((WinTop + fOldH) - WinHeight)));
			}
			// End:0x2CC
			if(m_bTRSizing)
			{
				Cursor = Root.DiagCursor2;
				fOldH = WinHeight;
				SetSize(float(Max(int(m_fMinWinWidth), int(X))), float(Max(int(m_fMinWinHeight), int((WinHeight - Y)))));
				WinTop = float(int(((WinTop + fOldH) - WinHeight)));
			}
			// End:0x335
			if(m_bLSizing)
			{
				Cursor = Root.WECursor;
				fOldW = WinWidth;
				SetSize(float(Max(int(m_fMinWinWidth), int((WinWidth - X)))), WinHeight);
				WinLeft = float(int(((WinLeft + fOldW) - WinWidth)));
			}
			// End:0x36F
			if(m_bRSizing)
			{
				Cursor = Root.WECursor;
				SetSize(float(Max(int(m_fMinWinWidth), int(X))), WinHeight);
			}
			// End:0x3E5
			if(m_bBLSizing)
			{
				Cursor = Root.DiagCursor2;
				fOldW = WinWidth;
				SetSize(float(Max(int(m_fMinWinWidth), int((WinWidth - X)))), float(Max(int(m_fMinWinHeight), int(Y))));
				WinLeft = float(int(((WinLeft + fOldW) - WinWidth)));
			}
			// End:0x41F
			if(m_bBSizing)
			{
				Cursor = Root.NSCursor;
				SetSize(WinWidth, float(Max(int(m_fMinWinHeight), int(Y))));
			}
			// End:0x466
			if(m_bBRSizing)
			{
				Cursor = Root.DiagCursor1;
				SetSize(float(Max(int(m_fMinWinWidth), int(X))), float(Max(int(m_fMinWinHeight), int(Y))));
			}			
		}
		else
		{
			m_bTLSizing = false;
			m_bTSizing = false;
			m_bTRSizing = false;
			m_bLSizing = false;
			m_bRSizing = false;
			m_bBLSizing = false;
			m_bBSizing = false;
			m_bBRSizing = false;
		}
		return;
	}
}

function ToolTip(string strTip)
{
	m_szStatusBarText = strTip;
	return;
}

function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int iKey)
{
	// End:0x3F
	if(((int(Msg) == int(11)) || (!WaitModal())))
	{
		super.WindowEvent(Msg, C, X, Y, iKey);		
	}
	else
	{
		// End:0x90
		if(WaitModal())
		{
			ModalWindow.WindowEvent(Msg, C, (X - ModalWindow.WinLeft), (Y - ModalWindow.WinTop), iKey);
		}
	}
	return;
}

function WindowHidden()
{
	super.WindowHidden();
	LookAndFeel.PlayMenuSound(self, 4);
	return;
}

function SetDisplayClose(bool bNewDisplay)
{
	m_bDisplayClose = bNewDisplay;
	// End:0xC0
	if(m_bDisplayClose)
	{
		// End:0xBD
		if((m_CloseBoxButton == none))
		{
			m_CloseBoxButton = UWindowFrameCloseBox(CreateWindow(Class'UWindow.UWindowFrameCloseBox', (((WinWidth - float(LookAndFeel.FrameTL.W)) - float(R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.W)) - float(1)), 1.0000000, float(R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.W), float(R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.H), self));
			m_CloseBoxButton.ShowWindow();
		}		
	}
	else
	{
		// End:0xDA
		if((m_CloseBoxButton != none))
		{
			m_CloseBoxButton.Close();
		}
	}
	return;
}

defaultproperties
{
	m_bDisplayClose=true
	m_fMinWinWidth=20.0000000
	m_fMinWinHeight=20.0000000
	m_ClientClass=Class'UWindow.UWindowClientWindow'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var Y
// REMOVED IN 1.60: var t
