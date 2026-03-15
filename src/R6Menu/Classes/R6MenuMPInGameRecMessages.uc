//=============================================================================
// R6MenuMPInGameRecMessages - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPInGameRecMessages.uc : Multi player menu to choose the pre-recorded messages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/28 * Created by Serge Dore
//=============================================================================
class R6MenuMPInGameRecMessages extends R6MenuWidget;

var bool m_bFirstTimePaint;
var float m_fOffsetTxtPos;
var R6WindowTextLabel m_TextPreRecMessages[5];
var R6WindowPopUpBox m_pInGameRecMessagesPopUp;
var Region m_RRecMsg;

function Created()
{
	local R6WindowTextLabel pR6TextLabelTemp;
	local Color LabelTextColor;

	LabelTextColor.R = 129;
	LabelTextColor.G = 209;
	LabelTextColor.B = 238;
	m_pInGameRecMessagesPopUp = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pInGameRecMessagesPopUp.CreatePopUpFrameWindow(Localize("RecMessages", "ID_HEADER", "R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RRecMsg.X), float(m_RRecMsg.Y), float(m_RRecMsg.W), float(m_RRecMsg.H));
	m_pInGameRecMessagesPopUp.bAlwaysBehind = true;
	m_pInGameRecMessagesPopUp.m_bBGFullScreen = false;
	m_TextPreRecMessages[0] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', float((m_RRecMsg.X + 5)), float((m_RRecMsg.Y + 30)), (WinWidth - float(5)), 25.0000000, self));
	m_TextPreRecMessages[0].Text = ((Localize("Number", "ID_NUM1", "R6RecMessages") $ " ") $ Localize("RecMessages", "ID_MSG1", "R6RecMessages"));
	m_TextPreRecMessages[0].Align = 0;
	m_TextPreRecMessages[0].m_Font = Root.Fonts[5];
	m_TextPreRecMessages[0].TextColor = LabelTextColor;
	m_TextPreRecMessages[0].m_BGTexture = none;
	m_TextPreRecMessages[0].m_bDrawBorders = false;
	m_TextPreRecMessages[1] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', float((m_RRecMsg.X + 5)), float((m_RRecMsg.Y + 50)), (WinWidth - float(5)), 25.0000000, self));
	m_TextPreRecMessages[1].Text = ((Localize("Number", "ID_NUM2", "R6RecMessages") $ " ") $ Localize("RecMessages", "ID_MSG2", "R6RecMessages"));
	m_TextPreRecMessages[1].Align = 0;
	m_TextPreRecMessages[1].m_Font = Root.Fonts[5];
	m_TextPreRecMessages[1].TextColor = LabelTextColor;
	m_TextPreRecMessages[1].m_BGTexture = none;
	m_TextPreRecMessages[1].m_bDrawBorders = false;
	m_TextPreRecMessages[2] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', float((m_RRecMsg.X + 5)), float((m_RRecMsg.Y + 70)), (WinWidth - float(5)), 25.0000000, self));
	m_TextPreRecMessages[2].Text = ((Localize("Number", "ID_NUM3", "R6RecMessages") $ " ") $ Localize("RecMessages", "ID_MSG3", "R6RecMessages"));
	m_TextPreRecMessages[2].Align = 0;
	m_TextPreRecMessages[2].m_Font = Root.Fonts[5];
	m_TextPreRecMessages[2].TextColor = LabelTextColor;
	m_TextPreRecMessages[2].m_BGTexture = none;
	m_TextPreRecMessages[2].m_bDrawBorders = false;
	m_TextPreRecMessages[3] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', float((m_RRecMsg.X + 5)), float((m_RRecMsg.Y + 90)), (WinWidth - float(5)), 25.0000000, self));
	m_TextPreRecMessages[3].Text = ((Localize("Number", "ID_NUM4", "R6RecMessages") $ " ") $ Localize("RecMessages", "ID_MSG4", "R6RecMessages"));
	m_TextPreRecMessages[3].Align = 0;
	m_TextPreRecMessages[3].m_Font = Root.Fonts[5];
	m_TextPreRecMessages[3].TextColor = LabelTextColor;
	m_TextPreRecMessages[3].m_BGTexture = none;
	m_TextPreRecMessages[3].m_bDrawBorders = false;
	m_TextPreRecMessages[4] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', float((m_RRecMsg.X + 5)), float((m_RRecMsg.Y + 110)), (WinWidth - float(5)), 25.0000000, self));
	m_TextPreRecMessages[4].Text = ((Localize("Number", "ID_NUM0", "R6RecMessages") $ " ") $ Localize("ExitMenu", "ID_MSG0", "R6RecMessages"));
	m_TextPreRecMessages[4].Align = 0;
	m_TextPreRecMessages[4].m_Font = Root.Fonts[5];
	m_TextPreRecMessages[4].TextColor = LabelTextColor;
	m_TextPreRecMessages[4].m_BGTexture = none;
	m_TextPreRecMessages[4].m_bDrawBorders = false;
	SetAcceptsFocus();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	super(UWindowWindow).Paint(C, X, Y);
	// End:0x44
	if((!GetPlayerOwner().Pawn.IsAlive()))
	{
		Root.ChangeCurrentWidget(0);
	}
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float fHeight, fWidth;
	local int i;

	// End:0x1AC
	if((!m_bFirstTimePaint))
	{
		m_bFirstTimePaint = true;
		TextSize(C, Localize("RecMessages", "ID_HEADER", "R6RecMessages"), fWidth, fHeight);
		// End:0x8C
		if((fWidth > (float(m_RRecMsg.W) - m_fOffsetTxtPos)))
		{
			m_RRecMsg.W = int((fWidth + m_fOffsetTxtPos));
		}
		i = 0;
		J0x93:

		// End:0x12C [Loop If]
		if((i < 5))
		{
			C.Font = m_TextPreRecMessages[i].m_Font;
			TextSize(C, m_TextPreRecMessages[i].Text, fWidth, fHeight);
			// End:0x122
			if((fWidth > (float(m_RRecMsg.W) - m_fOffsetTxtPos)))
			{
				m_RRecMsg.W = int((fWidth + m_fOffsetTxtPos));
			}
			(i++);
			// [Loop Continue]
			goto J0x93;
		}
		m_pInGameRecMessagesPopUp.ModifyPopUpFrameWindow(Localize("RecMessages", "ID_HEADER", "R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RRecMsg.X), float(m_RRecMsg.Y), float(m_RRecMsg.W), float(m_RRecMsg.H));
	}
	return;
}

function KeyDown(int Key, float X, float Y)
{
	local R6MenuInGameMultiPlayerRootWindow RootWindow;

	RootWindow = R6MenuInGameMultiPlayerRootWindow(OwnerWindow);
	switch(Key)
	{
		// End:0x44
		case int(RootWindow.Console.49):
			RootWindow.ChangeCurrentWidget(29);
			// End:0xFB
			break;
		// End:0x71
		case int(RootWindow.Console.50):
			RootWindow.ChangeCurrentWidget(30);
			// End:0xFB
			break;
		// End:0x9E
		case int(RootWindow.Console.51):
			RootWindow.ChangeCurrentWidget(31);
			// End:0xFB
			break;
		// End:0xCB
		case int(RootWindow.Console.52):
			RootWindow.ChangeCurrentWidget(32);
			// End:0xFB
			break;
		// End:0xF8
		case int(RootWindow.Console.48):
			RootWindow.ChangeCurrentWidget(0);
			// End:0xFB
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local float fBkpOrgX, fBkpOrgY;

	// End:0xC3
	if((int(Msg) == int(11)))
	{
		fBkpOrgX = C.OrgX;
		fBkpOrgY = C.OrgY;
		C.OrgX = 0.0000000;
		C.OrgY = (float((C.SizeY - 480)) * 0.5000000);
		super(UWindowWindow).WindowEvent(Msg, C, X, Y, Key);
		C.OrgX = fBkpOrgX;
		C.OrgY = fBkpOrgY;		
	}
	else
	{
		super(UWindowWindow).WindowEvent(Msg, C, X, Y, Key);
	}
	return;
}

defaultproperties
{
	m_fOffsetTxtPos=15.0000000
	m_RRecMsg=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=43554,ZoneNumber=0)
}
