//=============================================================================
// R6MenuMPInGameVote - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPInGameVote.uc : Multi player menu vote screen
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/7 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameVote extends R6MenuWidget;

const C_iNUMBER_OF_CHOICES = 3;

var bool m_bFirstTimePaint;
var float m_fOffsetTxtPos;
var R6WindowTextLabel m_AVoteText[4];
var R6WindowPopUpBox m_pPopUpBG;
var Region m_RVote;
var string m_szPlayerNameToKick;

function Created()
{
	local R6WindowTextLabel pR6TextLabelTemp;
	local Color LabelTextColor;

	LabelTextColor.R = 129;
	LabelTextColor.G = 209;
	LabelTextColor.B = 238;
	m_pPopUpBG = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pPopUpBG.CreatePopUpFrameWindow(Localize("MPInGame", "Vote_Title", "R6Menu"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RVote.X), float(m_RVote.Y), float(m_RVote.W), float(m_RVote.H));
	m_pPopUpBG.bAlwaysBehind = true;
	m_AVoteText[0] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', float((m_RVote.X + 5)), float((m_RVote.Y + 30)), (WinWidth - float(5)), 25.0000000, self));
	m_AVoteText[0].Text = ((Localize("Number", "ID_NUM1", "R6RecMessages") $ " ") $ Localize("MPInGame", "Vote_Yes", "R6Menu"));
	m_AVoteText[0].Align = 0;
	m_AVoteText[0].m_Font = Root.Fonts[5];
	m_AVoteText[0].TextColor = LabelTextColor;
	m_AVoteText[0].m_BGTexture = none;
	m_AVoteText[0].m_bDrawBorders = false;
	m_AVoteText[1] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', float((m_RVote.X + 5)), float((m_RVote.Y + 50)), (WinWidth - float(5)), 25.0000000, self));
	m_AVoteText[1].Text = ((Localize("Number", "ID_NUM2", "R6RecMessages") $ " ") $ Localize("MPInGame", "Vote_No", "R6Menu"));
	m_AVoteText[1].Align = 0;
	m_AVoteText[1].m_Font = Root.Fonts[5];
	m_AVoteText[1].TextColor = LabelTextColor;
	m_AVoteText[1].m_BGTexture = none;
	m_AVoteText[1].m_bDrawBorders = false;
	m_AVoteText[2] = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', float((m_RVote.X + 5)), float((m_RVote.Y + 70)), (WinWidth - float(5)), 25.0000000, self));
	m_AVoteText[2].Text = ((Localize("Number", "ID_NUM0", "R6RecMessages") $ " ") $ Localize("ExitMenu", "ID_MSG0", "R6RecMessages"));
	m_AVoteText[2].Align = 0;
	m_AVoteText[2].m_Font = Root.Fonts[5];
	m_AVoteText[2].TextColor = LabelTextColor;
	m_AVoteText[2].m_BGTexture = none;
	m_AVoteText[2].m_bDrawBorders = false;
	SetAcceptsFocus();
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local string szTitle;
	local float fHeight, fWidth;
	local int i;

	super(UWindowWindow).BeforePaint(C, X, Y);
	// End:0x1E8
	if((!m_bFirstTimePaint))
	{
		m_bFirstTimePaint = true;
		// End:0x6D
		if((m_szPlayerNameToKick != ""))
		{
			szTitle = ((Localize("MPInGame", "Vote_Title", "R6Menu") $ " ") $ m_szPlayerNameToKick);			
		}
		else
		{
			szTitle = Localize("MPInGame", "Vote_NextMap_Title", "R6Menu");
		}
		TextSize(C, szTitle, fWidth, fHeight);
		// End:0xF0
		if((fWidth > (float(m_RVote.W) - m_fOffsetTxtPos)))
		{
			m_RVote.W = int((fWidth + m_fOffsetTxtPos));
		}
		i = 0;
		J0xF7:

		// End:0x190 [Loop If]
		if((i < 3))
		{
			C.Font = m_AVoteText[i].m_Font;
			TextSize(C, m_AVoteText[i].Text, fWidth, fHeight);
			// End:0x186
			if((fWidth > (float(m_RVote.W) - m_fOffsetTxtPos)))
			{
				m_RVote.W = int((fWidth + m_fOffsetTxtPos));
			}
			(i++);
			// [Loop Continue]
			goto J0xF7;
		}
		m_pPopUpBG.ModifyPopUpFrameWindow(szTitle, R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(m_RVote.X), float(m_RVote.Y), float(m_RVote.W), float(m_RVote.H));
	}
	return;
}

function KeyDown(int Key, float X, float Y)
{
	local R6MenuInGameMultiPlayerRootWindow R6CurrentRoot;
	local bool bCloseVoteMenu;

	R6CurrentRoot = R6MenuInGameMultiPlayerRootWindow(OwnerWindow);
	bCloseVoteMenu = true;
	switch(Key)
	{
		// End:0x54
		case int(R6CurrentRoot.Console.49):
			R6CurrentRoot.m_R6GameMenuCom.SetVoteResult(true);
			// End:0xB3
			break;
		// End:0x89
		case int(R6CurrentRoot.Console.50):
			R6CurrentRoot.m_R6GameMenuCom.SetVoteResult(false);
			// End:0xB3
			break;
		// End:0xA5
		case int(R6CurrentRoot.Console.48):
			// End:0xB3
			break;
		// End:0xFFFF
		default:
			bCloseVoteMenu = false;
			// End:0xB3
			break;
			break;
	}
	// End:0xCF
	if(bCloseVoteMenu)
	{
		R6CurrentRoot.ChangeWidget(0, true, false);
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
	m_RVote=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=43554,ZoneNumber=0)
}
