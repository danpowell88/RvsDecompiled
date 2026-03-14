//=============================================================================
// R6MenuMPInGameMsgDefensive - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPInGameMsgDefensive.uc : Multi player menu to choose the order to be play
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/28 * Created by Serge Dore
//=============================================================================
class R6MenuMPInGameMsgDefensive extends R6MenuWidget;

var bool m_bFirstTimePaint;
var float m_fOffsetTxtPos;
var R6WindowTextLabel m_TextDefensive[7];
var R6WindowPopUpBox m_pInGameGiveOrderPopUp;
var Region m_RMsgSize;

function Created()
{
	local Color LabelTextColor;

	LabelTextColor.R = 129;
	LabelTextColor.G = 209;
	LabelTextColor.B = 238;
	m_pInGameGiveOrderPopUp = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pInGameGiveOrderPopUp.CreatePopUpFrameWindow(Localize("Defensive", "ID_HEADER", "R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RMsgSize.X), float(m_RMsgSize.Y), float(m_RMsgSize.W), float(m_RMsgSize.H));
	m_pInGameGiveOrderPopUp.bAlwaysBehind = true;
	m_pInGameGiveOrderPopUp.m_bBGFullScreen = false;
	m_TextDefensive[0] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float(__NFUN_146__(m_RMsgSize.Y, 30)), __NFUN_175__(WinWidth, float(5)), 25.0000000, self));
	m_TextDefensive[0].Text = __NFUN_112__(__NFUN_112__(Localize("Number", "ID_NUM1", "R6RecMessages"), " "), Localize("Defensive", "ID_MSG21", "R6RecMessages"));
	m_TextDefensive[0].Align = 0;
	m_TextDefensive[0].m_Font = Root.Fonts[5];
	m_TextDefensive[0].TextColor = LabelTextColor;
	m_TextDefensive[0].m_BGTexture = none;
	m_TextDefensive[0].m_bDrawBorders = false;
	m_TextDefensive[1] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float(__NFUN_146__(m_RMsgSize.Y, 50)), __NFUN_175__(WinWidth, float(5)), 25.0000000, self));
	m_TextDefensive[1].Text = __NFUN_112__(__NFUN_112__(Localize("Number", "ID_NUM2", "R6RecMessages"), " "), Localize("Defensive", "ID_MSG22", "R6RecMessages"));
	m_TextDefensive[1].Align = 0;
	m_TextDefensive[1].m_Font = Root.Fonts[5];
	m_TextDefensive[1].TextColor = LabelTextColor;
	m_TextDefensive[1].m_BGTexture = none;
	m_TextDefensive[1].m_bDrawBorders = false;
	m_TextDefensive[2] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float(__NFUN_146__(m_RMsgSize.Y, 70)), __NFUN_175__(WinWidth, float(5)), 25.0000000, self));
	m_TextDefensive[2].Text = __NFUN_112__(__NFUN_112__(Localize("Number", "ID_NUM3", "R6RecMessages"), " "), Localize("Defensive", "ID_MSG23", "R6RecMessages"));
	m_TextDefensive[2].Align = 0;
	m_TextDefensive[2].m_Font = Root.Fonts[5];
	m_TextDefensive[2].TextColor = LabelTextColor;
	m_TextDefensive[2].m_BGTexture = none;
	m_TextDefensive[2].m_bDrawBorders = false;
	m_TextDefensive[3] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float(__NFUN_146__(m_RMsgSize.Y, 90)), __NFUN_175__(WinWidth, float(5)), 25.0000000, self));
	m_TextDefensive[3].Text = __NFUN_112__(__NFUN_112__(Localize("Number", "ID_NUM4", "R6RecMessages"), " "), Localize("Defensive", "ID_MSG24", "R6RecMessages"));
	m_TextDefensive[3].Align = 0;
	m_TextDefensive[3].m_Font = Root.Fonts[5];
	m_TextDefensive[3].TextColor = LabelTextColor;
	m_TextDefensive[3].m_BGTexture = none;
	m_TextDefensive[3].m_bDrawBorders = false;
	m_TextDefensive[4] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float(__NFUN_146__(m_RMsgSize.Y, 110)), __NFUN_175__(WinWidth, float(5)), 25.0000000, self));
	m_TextDefensive[4].Text = __NFUN_112__(__NFUN_112__(Localize("Number", "ID_NUM5", "R6RecMessages"), " "), Localize("Defensive", "ID_MSG25", "R6RecMessages"));
	m_TextDefensive[4].Align = 0;
	m_TextDefensive[4].m_Font = Root.Fonts[5];
	m_TextDefensive[4].TextColor = LabelTextColor;
	m_TextDefensive[4].m_BGTexture = none;
	m_TextDefensive[4].m_bDrawBorders = false;
	m_TextDefensive[5] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float(__NFUN_146__(m_RMsgSize.Y, 130)), __NFUN_175__(WinWidth, float(5)), 25.0000000, self));
	m_TextDefensive[5].Text = __NFUN_112__(__NFUN_112__(Localize("Number", "ID_NUM6", "R6RecMessages"), " "), Localize("Defensive", "ID_MSG26", "R6RecMessages"));
	m_TextDefensive[5].Align = 0;
	m_TextDefensive[5].m_Font = Root.Fonts[5];
	m_TextDefensive[5].TextColor = LabelTextColor;
	m_TextDefensive[5].m_BGTexture = none;
	m_TextDefensive[5].m_bDrawBorders = false;
	m_TextDefensive[6] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, float(__NFUN_146__(m_RMsgSize.Y, 150)), __NFUN_175__(WinWidth, float(5)), 25.0000000, self));
	m_TextDefensive[6].Text = __NFUN_112__(__NFUN_112__(Localize("Number", "ID_NUM0", "R6RecMessages"), " "), Localize("ExitMenu", "ID_MSG0", "R6RecMessages"));
	m_TextDefensive[6].Align = 0;
	m_TextDefensive[6].m_Font = Root.Fonts[5];
	m_TextDefensive[6].TextColor = LabelTextColor;
	m_TextDefensive[6].m_BGTexture = none;
	m_TextDefensive[6].m_bDrawBorders = false;
	SetAcceptsFocus();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	super(UWindowWindow).Paint(C, X, Y);
	// End:0x44
	if(__NFUN_129__(GetPlayerOwner().Pawn.IsAlive()))
	{
		Root.ChangeCurrentWidget(0);
	}
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float fHeight, fWidth;
	local int i;

	// End:0x19A
	if(__NFUN_129__(m_bFirstTimePaint))
	{
		m_bFirstTimePaint = true;
		TextSize(C, Localize("Defensive", "ID_HEADER", "R6RecMessages"), fWidth, fHeight);
		// End:0x7C
		if(__NFUN_177__(fWidth, float(m_RMsgSize.W)))
		{
			m_RMsgSize.W = int(fWidth);
		}
		i = 0;
		J0x83:

		// End:0x11C [Loop If]
		if(__NFUN_150__(i, 7))
		{
			C.Font = m_TextDefensive[i].m_Font;
			TextSize(C, m_TextDefensive[i].Text, fWidth, fHeight);
			// End:0x112
			if(__NFUN_177__(fWidth, __NFUN_175__(float(m_RMsgSize.W), m_fOffsetTxtPos)))
			{
				m_RMsgSize.W = int(__NFUN_174__(fWidth, m_fOffsetTxtPos));
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x83;
		}
		m_pInGameGiveOrderPopUp.ModifyPopUpFrameWindow(Localize("Defensive", "ID_HEADER", "R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RMsgSize.X), float(m_RMsgSize.Y), float(m_RMsgSize.W), float(m_RMsgSize.H));
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
			aRainbow.SetCommunicationAnimation(5);
			aPC.ServerPlayRecordedMsg("Defensive ID_MSG21", 8);
			// End:0x230
			break;
		// End:0xE5
		case int(r6Root.Console.50):
			aPC.ServerPlayRecordedMsg("Defensive ID_MSG22", 0);
			// End:0x230
			break;
		// End:0x137
		case int(r6Root.Console.51):
			aRainbow.SetCommunicationAnimation(2);
			aPC.ServerPlayRecordedMsg("Defensive ID_MSG23", 5);
			// End:0x230
			break;
		// End:0x189
		case int(r6Root.Console.52):
			aRainbow.SetCommunicationAnimation(4);
			aPC.ServerPlayRecordedMsg("Defensive ID_MSG24", 9);
			// End:0x230
			break;
		// End:0x1DB
		case int(r6Root.Console.53):
			aRainbow.SetCommunicationAnimation(4);
			aPC.ServerPlayRecordedMsg("Defensive ID_MSG25", 6);
			// End:0x230
			break;
		// End:0x22D
		case int(r6Root.Console.54):
			aRainbow.SetCommunicationAnimation(2);
			aPC.ServerPlayRecordedMsg("Defensive ID_MSG26", 4);
			// End:0x230
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0x283
	if(__NFUN_130__(__NFUN_153__(Key, int(r6Root.Console.48)), __NFUN_152__(Key, int(r6Root.Console.57))))
	{
		r6Root.ChangeCurrentWidget(0);
	}
	return;
}

function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local float fBkpOrgX, fBkpOrgY;

	// End:0xC3
	if(__NFUN_154__(int(Msg), int(11)))
	{
		fBkpOrgX = C.OrgX;
		fBkpOrgY = C.OrgY;
		C.OrgX = 0.0000000;
		C.OrgY = __NFUN_171__(float(__NFUN_147__(C.SizeY, 480)), 0.5000000);
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
