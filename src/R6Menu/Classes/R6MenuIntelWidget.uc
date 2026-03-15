//=============================================================================
// R6MenuIntelWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuIntelWidget.uc : This is the Intel menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuIntelWidget extends R6MenuLaptopWidget;

const szScrollTextArraySize = 10;
const K_fVideoWidth = 438;
const K_fVideoHeight = 230;

enum EMenuIntelButtonID
{
	ButtonControlID,                // 0
	ButtonClarkID,                  // 1
	ButtonSweenyID,                 // 2
	ButtonNewsID,                   // 3
	ButtonMissionID                 // 4
};

var int m_iCurrentSpeaker;
var bool m_bAddText;
var bool bShowLog;
var float m_fLaptopPadding;
// NEW IN 1.60
var float m_fPaddingBetweenElements;
var float m_fVideoLeft;
// NEW IN 1.60
var float m_fVideoRight;
// NEW IN 1.60
var float m_fVideoTop;
// NEW IN 1.60
var float m_fVideoBottom;
// NEW IN 1.60
var float m_fLabelHeight;
// NEW IN 1.60
var float m_fSpeakerWidgetWidth;
// NEW IN 1.60
var float m_fSpeakerWidgetHeight;
var float m_fRightTileModulo;
// NEW IN 1.60
var float m_fLeftTileModulo;
// NEW IN 1.60
var float m_fBottomTileModulo;
// NEW IN 1.60
var float m_fRightBGWidth;
// NEW IN 1.60
var float m_fUpBGWidth;
// NEW IN 1.60
var float m_fBottomHeight;
var R6WindowWrappedTextArea m_SrcrollingTextArea;
// NEW IN 1.60
var R6WindowWrappedTextArea m_MissionObjectives;
var R6MenuVideo m_MissionDesc;
var R6WindowBitMap m_2DSpeaker;
var Texture m_TSpeaker;
var R6MenuIntelRadioArea m_SpeakerControls;
var R6WindowTextLabel m_CodeName;
// NEW IN 1.60
var R6WindowTextLabel m_DateTime;
// NEW IN 1.60
var R6WindowTextLabel m_Location;
var Texture m_Texture;
var Font m_labelFont;
var Font m_R6Font14;
var Sound m_sndPlayEvent;
var Region m_RControl;
// NEW IN 1.60
var Region m_RClark;
// NEW IN 1.60
var Region m_RSweeney;
// NEW IN 1.60
var Region m_RNewsWire;
// NEW IN 1.60
var Region m_RMissionOrder;
var string m_szScrollingText;

function Created()
{
	local int labelWidth;

	super.Created();
	m_Texture = Texture(DynamicLoadObject("R6MenuTextures.Gui_BoxScroll", Class'Engine.Texture'));
	m_labelFont = Root.Fonts[9];
	m_R6Font14 = Root.Fonts[5];
	labelWidth = (int((m_Right.WinLeft - m_Left.WinWidth)) / 3);
	m_CodeName = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_Left.WinWidth, m_Top.WinHeight, float(labelWidth), m_fLabelHeight, self));
	m_DateTime = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_CodeName.WinLeft + m_CodeName.WinWidth), m_Top.WinHeight, float(labelWidth), m_fLabelHeight, self));
	m_Location = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_DateTime.WinLeft + m_DateTime.WinWidth), m_Top.WinHeight, m_DateTime.WinWidth, m_fLabelHeight, self));
	m_2DSpeaker = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', (m_Left.WinWidth + m_fLaptopPadding), (m_CodeName.WinTop + m_fLabelHeight), m_fSpeakerWidgetWidth, m_fSpeakerWidgetHeight, self));
	m_2DSpeaker.m_bDrawBorder = true;
	m_2DSpeaker.m_BorderColor = Root.Colors.GrayLight;
	m_2DSpeaker.t = m_TSpeaker;
	m_SpeakerControls = R6MenuIntelRadioArea(CreateWindow(Class'R6Menu.R6MenuIntelRadioArea', m_2DSpeaker.WinLeft, (m_2DSpeaker.WinTop + m_2DSpeaker.WinHeight), m_2DSpeaker.WinWidth, (230.0000000 - m_2DSpeaker.WinHeight), self));
	m_SpeakerControls.m_BorderColor = Root.Colors.GrayLight;
	m_iCurrentSpeaker = -1;
	m_fVideoTop = m_2DSpeaker.WinTop;
	m_fVideoLeft = ((m_Right.WinLeft - float(438)) - m_fLaptopPadding);
	m_fVideoRight = (m_Right.WinLeft - m_fLaptopPadding);
	m_fVideoBottom = (m_fVideoTop + float(230));
	m_fRightTileModulo = (m_fVideoRight % float(m_TBackGround.USize));
	m_fLeftTileModulo = (m_fVideoLeft % float(m_TBackGround.USize));
	m_fBottomTileModulo = (m_fVideoBottom % float(m_TBackGround.VSize));
	m_fRightBGWidth = (WinWidth - m_fVideoRight);
	m_fUpBGWidth = (m_fVideoRight - m_fVideoLeft);
	m_fBottomHeight = (WinHeight - m_fVideoBottom);
	m_MissionDesc = R6MenuVideo(CreateWindow(Class'R6Menu.R6MenuVideo', m_fVideoLeft, m_fVideoTop, 438.0000000, 230.0000000, self));
	m_MissionDesc.m_BorderColor = Root.Colors.GrayLight;
	m_SrcrollingTextArea = R6WindowWrappedTextArea(CreateWindow(Class'R6Window.R6WindowWrappedTextArea', m_fVideoLeft, (m_fVideoBottom + m_fPaddingBetweenElements), 438.0000000, (((m_HelpTextBar.WinTop - m_fPaddingBetweenElements) - m_fVideoBottom) - m_fPaddingBetweenElements), self));
	m_SrcrollingTextArea.m_BorderColor = Root.Colors.GrayLight;
	m_SrcrollingTextArea.SetScrollable(true);
	m_SrcrollingTextArea.VertSB.SetBorderColor(Root.Colors.GrayLight);
	m_SrcrollingTextArea.VertSB.SetHideWhenDisable(true);
	m_SrcrollingTextArea.VertSB.SetEffect(true);
	m_MissionObjectives = R6WindowWrappedTextArea(CreateWindow(Class'R6Window.R6WindowWrappedTextArea', m_2DSpeaker.WinLeft, m_SrcrollingTextArea.WinTop, m_2DSpeaker.WinWidth, m_SrcrollingTextArea.WinHeight, self));
	m_MissionObjectives.m_BorderColor = Root.Colors.GrayLight;
	m_MissionObjectives.SetScrollable(true);
	m_MissionObjectives.VertSB.SetBorderColor(Root.Colors.GrayLight);
	m_MissionObjectives.VertSB.SetHideWhenDisable(true);
	m_MissionObjectives.VertSB.SetEffect(true);
	m_MissionObjectives.m_BorderStyle = int(1);
	GetLevel().m_bPlaySound = false;
	m_NavBar.m_BriefingButton.bDisabled = true;
	return;
}

function Reset()
{
	m_iCurrentSpeaker = -1;
	m_SpeakerControls.Reset();
	return;
}

function HideWindow()
{
	super(UWindowWindow).HideWindow();
	StopIntelWidgetSound();
	GetPlayerOwner().FadeSound(3.0000000, 100, 5);
	return;
}

function ShowWindow()
{
	local int itempSpeaker, i;
	local R6MissionDescription CurrentMission;
	local R6MissionObjectiveMgr moMgr;

	super(UWindowWindow).ShowWindow();
	GetLevel().m_bPlaySound = false;
	// End:0x3E
	if(bShowLog)
	{
		Log("R6MenuIntelWidget::Show()");
	}
	CurrentMission = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission);
	m_CodeName.SetProperties(Localize(CurrentMission.m_MapName, "ID_CODENAME", CurrentMission.LocalizationFile), 2, m_labelFont, Root.Colors.White, false);
	m_DateTime.SetProperties(Localize(CurrentMission.m_MapName, "ID_DATETIME", CurrentMission.LocalizationFile), 2, m_labelFont, Root.Colors.White, false);
	m_Location.SetProperties(Localize(CurrentMission.m_MapName, "ID_LOCATION", CurrentMission.LocalizationFile), 2, m_labelFont, Root.Colors.White, false);
	m_SpeakerControls.AssociateButtons();
	m_MissionDesc.PlayVideo(int(((m_Right.WinLeft - float(438)) - m_fLaptopPadding)), int(((m_SrcrollingTextArea.WinTop - float(230)) - m_fPaddingBetweenElements)), (R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).GetIntelVideoName(CurrentMission) $ ".bik"));
	m_MissionObjectives.Clear();
	GetPlayerOwner().AddSoundBank(CurrentMission.m_AudioBankName, 3);
	GetLevel().FinalizeLoading();
	GetLevel().SetBankSound(0);
	m_MissionObjectives.Clear();
	m_MissionObjectives.m_fXOffSet = 10.0000000;
	m_MissionObjectives.m_fYOffSet = 5.0000000;
	m_MissionObjectives.AddText(Localize("Briefing", "Objectives", "R6Menu"), Root.Colors.BlueLight, Root.Fonts[5]);
	moMgr = R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_missionMgr;
	i = 0;
	J0x35E:

	// End:0x48D [Loop If]
	if((i < moMgr.m_aMissionObjectives.Length))
	{
		// End:0x483
		if(((!moMgr.m_aMissionObjectives[i].m_bMoralityObjective) && moMgr.m_aMissionObjectives[i].m_bVisibleInMenu))
		{
			m_MissionObjectives.AddText(Localize("Game", moMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, moMgr.Level.GetMissionObjLocFile(moMgr.m_aMissionObjectives[i])), Root.Colors.White, Root.Fonts[10]);
			m_MissionObjectives.AddText(" ", Root.Colors.White, Root.Fonts[10]);
		}
		(++i);
		// [Loop Continue]
		goto J0x35E;
	}
	itempSpeaker = m_iCurrentSpeaker;
	m_iCurrentSpeaker = -1;
	// End:0x4C5
	if(bShowLog)
	{
		Log(("itempSpeaker" @ string(itempSpeaker)));
	}
	// End:0x506
	if((!m_SpeakerControls.m_ControlButton.bDisabled))
	{
		// End:0x4FB
		if((itempSpeaker == -1))
		{
			ManageButtonSelection(0);			
		}
		else
		{
			ManageButtonSelection(itempSpeaker);
		}
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, m_fVideoLeft, WinHeight, 0.0000000, 0.0000000, m_fVideoLeft, WinHeight, m_TBackGround);
	DrawStretchedTextureSegment(C, m_fVideoRight, 0.0000000, m_fRightBGWidth, WinHeight, m_fRightTileModulo, 0.0000000, m_fRightBGWidth, WinHeight, m_TBackGround);
	DrawStretchedTextureSegment(C, m_fVideoLeft, 0.0000000, m_fUpBGWidth, m_fVideoTop, m_fLeftTileModulo, 0.0000000, m_fUpBGWidth, m_fVideoTop, m_TBackGround);
	DrawStretchedTextureSegment(C, m_fVideoLeft, m_fVideoBottom, m_fUpBGWidth, m_fBottomHeight, m_fLeftTileModulo, m_fBottomTileModulo, m_fUpBGWidth, m_fBottomHeight, m_TBackGround);
	DrawLaptopFrame(C);
	return;
}

function DisplayText(float _X, float _Y, Font _TextFont, Color _Color, R6WindowWrappedTextArea _R6WindowWrappedTextArea)
{
	_R6WindowWrappedTextArea.m_fXOffSet = _X;
	_R6WindowWrappedTextArea.m_fYOffSet = _Y;
	_R6WindowWrappedTextArea.AddText(m_szScrollingText, _Color, _TextFont);
	return;
}

// set all the text corresponding with _szOriginal#
// return true if at least we find one valid sentence at _szOriginal
function bool SetMissionText(string _szOriginal)
{
	local string szTemp;
	local int i;
	local bool bFindText;
	local R6MissionDescription CurrentMission;

	m_szScrollingText = "";
	// End:0xBA
	if((R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingCampaignBriefing == true))
	{
		CurrentMission = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission);
		m_szScrollingText = Localize(CurrentMission.m_MapName, _szOriginal, CurrentMission.LocalizationFile, true, true);		
	}
	else
	{
		m_szScrollingText = Localize(GetLevel().GameTypeToString(GetLevel().Game.m_szGameTypeFlag), _szOriginal, GetLevel().GameTypeLocalizationFile(GetLevel().Game.m_szGameTypeFlag), true, true);
	}
	return (m_szScrollingText != "");
	return;
}

// depending the selected button, find the text corresponding and fill it in a text array ( this is for R6Mission.int)
// ex ID_CONTROL, ID_CONTROL1, ID_CONTROL2, ID_CONTROL3, etc... 
function ManageButtonSelection(int _eButtonSelection)
{
	local bool bChangeText;
	local R6MissionDescription CurrentMission;

	// End:0x34
	if(bShowLog)
	{
		Log((("ManageButtonSelection" @ string(m_iCurrentSpeaker)) @ string(_eButtonSelection)));
	}
	// End:0x60
	if((m_iCurrentSpeaker == _eButtonSelection))
	{
		// End:0x5E
		if(bShowLog)
		{
			Log("Nothing To Do!");
		}
		return;
	}
	m_iCurrentSpeaker = _eButtonSelection;
	CurrentMission = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission);
	// End:0xC1
	if((m_sndPlayEvent != none))
	{
		GetPlayerOwner().StopSound(m_sndPlayEvent);
	}
	m_sndPlayEvent = none;
	switch(_eButtonSelection)
	{
		// End:0x15A
		case int(0):
			SetMissionText("ID_CONTROL");
			// End:0x143
			if((R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingCampaignBriefing == true))
			{
				m_sndPlayEvent = CurrentMission.m_PlayEventControl;
			}
			m_2DSpeaker.R = m_RControl;
			// End:0x2DA
			break;
		// End:0x1E3
		case int(1):
			SetMissionText("ID_CLARK");
			// End:0x1CC
			if((R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingCampaignBriefing == true))
			{
				m_sndPlayEvent = CurrentMission.m_PlayEventClark;
			}
			m_2DSpeaker.R = m_RClark;
			// End:0x2DA
			break;
		// End:0x26D
		case int(2):
			SetMissionText("ID_SWEENY");
			// End:0x256
			if((R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingCampaignBriefing == true))
			{
				m_sndPlayEvent = CurrentMission.m_PlayEventSweeney;
			}
			m_2DSpeaker.R = m_RSweeney;
			// End:0x2DA
			break;
		// End:0x29E
		case int(3):
			SetMissionText("ID_NEWSWIRE");
			m_2DSpeaker.R = m_RNewsWire;
			// End:0x2DA
			break;
		// End:0x2D4
		case int(4):
			SetMissionText("ID_MISSION_ORDER");
			m_2DSpeaker.R = m_RMissionOrder;
			// End:0x2DA
			break;
		// End:0xFFFF
		default:
			// End:0x2DA
			break;
			break;
	}
	// End:0x30F
	if((m_sndPlayEvent != none))
	{
		GetPlayerOwner().__NFUN_264__(m_sndPlayEvent, 7) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
		GetPlayerOwner().__NFUN_2721__(3.0000000, 15, 5);
	}
	m_SrcrollingTextArea.Clear();
	DisplayText(10.0000000, 4.0000000, Root.Fonts[10], Root.Colors.White, m_SrcrollingTextArea);
	return;
}

function StopIntelWidgetSound()
{
	m_MissionDesc.StopVideo();
	GetPlayerOwner().__NFUN_2725__(m_sndPlayEvent);
	m_sndPlayEvent = none;
	return;
}

defaultproperties
{
	m_bAddText=true
	m_fLaptopPadding=2.0000000
	m_fPaddingBetweenElements=3.0000000
	m_fLabelHeight=18.0000000
	m_fSpeakerWidgetWidth=156.0000000
	m_fSpeakerWidgetHeight=117.0000000
	m_TSpeaker=Texture'R6MenuTextures.Gui_04_a00'
	m_RControl=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=39714,ZoneNumber=0)
	m_RClark=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=29986,ZoneNumber=0)
	m_RSweeney=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=39970,ZoneNumber=0)
	m_RNewsWire=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=39970,ZoneNumber=0)
	m_RMissionOrder=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=79906,ZoneNumber=0)
}
