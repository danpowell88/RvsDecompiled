//=============================================================================
// R6MenuMPInGameMsgOffensive - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPInGameMsgOffensive.uc : Multi player menu to choose the pre-recorded messages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/28 * Created by Serge Dore
//=============================================================================
class R6MenuMPInGameMsgOffensive extends R6MenuWidget;

var bool m_bFirstTimePaint;
var float m_fOffsetTxtPos;
var R6WindowTextLabel m_TextOffensive[7];
var R6WindowPopUpBox m_pInGameOffensivePopUp;
var Region m_RMsgSize;

function Created()
{
	local Color LabelTextColor;

	LabelTextColor.R = 129;
	LabelTextColor.G = 209;
	LabelTextColor.B = 238;
	m_pInGameOffensivePopUp = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pInGameOffensivePopUp.CreatePopUpFrameWindow(Localize("Offensive", "ID_HEADER", "R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RMsgSize.X), float(m_RMsgSize.Y), float(m_RMsgSize.W), float(m_RMsgSize.H));
	m_pInGameOffensivePopUp.bAlwaysBehind = true;
	m_pInGameOffensivePopUp.m_bBGFullScreen = false;
	m_TextOffensive[0] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float((m_RMsgSize.Y + 30)), (WinWidth - float(5)), 25.0000000, self));
	m_TextOffensive[0].Text = ((Localize("Number", "ID_NUM1", "R6RecMessages") $ " ") $ Localize("Offensive", "ID_MSG11", "R6RecMessages"));
	m_TextOffensive[0].Align = 0;
	m_TextOffensive[0].m_Font = Root.Fonts[5];
	m_TextOffensive[0].TextColor = LabelTextColor;
	m_TextOffensive[0].m_BGTexture = none;
	m_TextOffensive[0].m_bDrawBorders = false;
	m_TextOffensive[1] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float((m_RMsgSize.Y + 50)), (WinWidth - float(5)), 25.0000000, self));
	m_TextOffensive[1].Text = ((Localize("Number", "ID_NUM2", "R6RecMessages") $ " ") $ Localize("Offensive", "ID_MSG12", "R6RecMessages"));
	m_TextOffensive[1].Align = 0;
	m_TextOffensive[1].m_Font = Root.Fonts[5];
	m_TextOffensive[1].TextColor = LabelTextColor;
	m_TextOffensive[1].m_BGTexture = none;
	m_TextOffensive[1].m_bDrawBorders = false;
	m_TextOffensive[2] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float((m_RMsgSize.Y + 70)), (WinWidth - float(5)), 25.0000000, self));
	m_TextOffensive[2].Text = ((Localize("Number", "ID_NUM3", "R6RecMessages") $ " ") $ Localize("Offensive", "ID_MSG13", "R6RecMessages"));
	m_TextOffensive[2].Align = 0;
	m_TextOffensive[2].m_Font = Root.Fonts[5];
	m_TextOffensive[2].TextColor = LabelTextColor;
	m_TextOffensive[2].m_BGTexture = none;
	m_TextOffensive[2].m_bDrawBorders = false;
	m_TextOffensive[3] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float((m_RMsgSize.Y + 90)), (WinWidth - float(5)), 25.0000000, self));
	m_TextOffensive[3].Text = ((Localize("Number", "ID_NUM4", "R6RecMessages") $ " ") $ Localize("Offensive", "ID_MSG14", "R6RecMessages"));
	m_TextOffensive[3].Align = 0;
	m_TextOffensive[3].m_Font = Root.Fonts[5];
	m_TextOffensive[3].TextColor = LabelTextColor;
	m_TextOffensive[3].m_BGTexture = none;
	m_TextOffensive[3].m_bDrawBorders = false;
	m_TextOffensive[4] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float((m_RMsgSize.Y + 110)), (WinWidth - float(5)), 25.0000000, self));
	m_TextOffensive[4].Text = ((Localize("Number", "ID_NUM5", "R6RecMessages") $ " ") $ Localize("Offensive", "ID_MSG15", "R6RecMessages"));
	m_TextOffensive[4].Align = 0;
	m_TextOffensive[4].m_Font = Root.Fonts[5];
	m_TextOffensive[4].TextColor = LabelTextColor;
	m_TextOffensive[4].m_BGTexture = none;
	m_TextOffensive[4].m_bDrawBorders = false;
	m_TextOffensive[5] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float((m_RMsgSize.Y + 130)), (WinWidth - float(5)), 25.0000000, self));
	m_TextOffensive[5].Text = ((Localize("Number", "ID_NUM6", "R6RecMessages") $ " ") $ Localize("Offensive", "ID_MSG16", "R6RecMessages"));
	m_TextOffensive[5].Align = 0;
	m_TextOffensive[5].m_Font = Root.Fonts[5];
	m_TextOffensive[5].TextColor = LabelTextColor;
	m_TextOffensive[5].m_BGTexture = none;
	m_TextOffensive[5].m_bDrawBorders = false;
	m_TextOffensive[6] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float((m_RMsgSize.Y + 150)), (WinWidth - float(5)), 25.0000000, self));
	m_TextOffensive[6].Text = ((Localize("Number", "ID_NUM0", "R6RecMessages") $ " ") $ Localize("ExitMenu", "ID_MSG0", "R6RecMessages"));
	m_TextOffensive[6].Align = 0;
	m_TextOffensive[6].m_Font = Root.Fonts[5];
	m_TextOffensive[6].TextColor = LabelTextColor;
	m_TextOffensive[6].m_BGTexture = none;
	m_TextOffensive[6].m_bDrawBorders = false;
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

	// End:0x19C
	if((!m_bFirstTimePaint))
	{
		m_bFirstTimePaint = true;
		TextSize(C, Localize("RecMessages", "ID_HEADER", "R6RecMessages"), fWidth, fHeight);
		// End:0x7E
		if((fWidth > float(m_RMsgSize.W)))
		{
			m_RMsgSize.W = int(fWidth);
		}
		i = 0;
		J0x85:

		// End:0x11E [Loop If]
		if((i < 7))
		{
			C.Font = m_TextOffensive[i].m_Font;
			TextSize(C, m_TextOffensive[i].Text, fWidth, fHeight);
			// End:0x114
			if((fWidth > (float(m_RMsgSize.W) - m_fOffsetTxtPos)))
			{
				m_RMsgSize.W = int((fWidth + m_fOffsetTxtPos));
			}
			(i++);
			// [Loop Continue]
			goto J0x85;
		}
		m_pInGameOffensivePopUp.ModifyPopUpFrameWindow(Localize("Offensive", "ID_HEADER", "R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RMsgSize.X), float(m_RMsgSize.Y), float(m_RMsgSize.W), float(m_RMsgSize.H));
	}
	return;
}

function KeyDown(int Key, float X, float Y)
{
	local R6Rainbow aRainbow;
	local R6PlayerController aPC;
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(OwnerWindow);
	aPC = R6PlayerController(r6Root.m_R6GameMenuCom.m_PlayerController);
	aRainbow = R6Rainbow(aPC.Pawn);
	switch(Key)
	{
		// End:0xA4
		case int(r6Root.Console.49):
			aRainbow.SetCommunicationAnimation(3);
			aPC.ServerPlayRecordedMsg("Offensive ID_MSG11", 18);
			// End:0x21F
			break;
		// End:0xF6
		case int(r6Root.Console.50):
			aRainbow.SetCommunicationAnimation(1);
			aPC.ServerPlayRecordedMsg("Offensive ID_MSG12", 1);
			// End:0x21F
			break;
		// End:0x148
		case int(r6Root.Console.51):
			aRainbow.SetCommunicationAnimation(3);
			aPC.ServerPlayRecordedMsg("Offensive ID_MSG13", 7);
			// End:0x21F
			break;
		// End:0x19A
		case int(r6Root.Console.52):
			aRainbow.SetCommunicationAnimation(3);
			aPC.ServerPlayRecordedMsg("Offensive ID_MSG14", 3);
			// End:0x21F
			break;
		// End:0x1DB
		case int(r6Root.Console.53):
			aPC.ServerPlayRecordedMsg("Offensive ID_MSG15", 23);
			// End:0x21F
			break;
		// End:0x21C
		case int(r6Root.Console.54):
			aPC.ServerPlayRecordedMsg("Offensive ID_MSG16", 25);
			// End:0x21F
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0x272
	if(((Key >= int(r6Root.Console.48)) && (Key <= int(r6Root.Console.57))))
	{
		r6Root.ChangeCurrentWidget(0);
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
	m_RMsgSize=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=43554,ZoneNumber=0)
}
