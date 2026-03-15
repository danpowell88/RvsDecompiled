//=============================================================================
// R6MenuTrainingWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuTrainingWidget.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/11 * Created by Alexandre Dionne
//=============================================================================
class R6MenuTrainingWidget extends R6MenuWidget;

var bool bShowLog;
var R6WindowButton m_ButtonStart;
var R6WindowButton m_ButtonMainMenu;
var R6WindowButton m_ButtonOptions;
var R6WindowTextLabel m_LMenuTitle;
var R6MenuHelpWindow m_pHelpWindow;  // the help window (tooltip)
var R6WindowSimpleFramedWindow m_Map;
var Texture m_mapPreviews[9];
//************************************************************************************************
//      Training sections Buttons
//************************************************************************************************
var R6WindowButton m_pButBasics;
var R6WindowButton m_pButShooting;
var R6WindowButton m_pButExplosives;
var R6WindowButton m_pButRoomClearing1;
var R6WindowButton m_pButRoomClearing2;
var R6WindowButton m_pButRoomClearing3;
var R6WindowButton m_pButHostageRescue1;
var R6WindowButton m_pButHostageRescue2;
var R6WindowButton m_pButHostageRescue3;
var R6WindowButton m_pButCurrent;
var Font m_LeftButtonFont;
var Font m_LeftDownSizeFont;
var Color m_TitleTextColor;
var string m_mapNames[9];

function Created()
{
	local Font ButtonFont;
	local int XPos;
	local R6WindowBitMap mapBitmap;

	ButtonFont = Root.Fonts[16];
	m_Map = R6WindowSimpleFramedWindow(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindow', 198.0000000, 72.0000000, 422.0000000, 220.0000000, self));
	m_Map.CreateClientWindow(Class'R6Window.R6WindowBitMap');
	m_Map.m_eCornerType = 3;
	mapBitmap = R6WindowBitMap(m_Map.m_ClientArea);
	mapBitmap.R.X = 0;
	mapBitmap.R.Y = 0;
	mapBitmap.R.W = int(mapBitmap.WinWidth);
	mapBitmap.R.H = int(mapBitmap.WinHeight);
	mapBitmap.m_iDrawStyle = int(1);
	m_pHelpWindow = R6MenuHelpWindow(CreateWindow(Class'R6Menu.R6MenuHelpWindow', 150.0000000, 429.0000000, 340.0000000, 42.0000000, self));
	m_ButtonMainMenu = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 421.0000000, 250.0000000, 25.0000000, self));
	m_ButtonMainMenu.ToolTipString = Localize("Tip", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Text = Localize("SinglePlayer", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Align = 0;
	m_ButtonMainMenu.m_buttonFont = ButtonFont;
	m_ButtonMainMenu.ResizeToText();
	m_ButtonOptions = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 452.0000000, 250.0000000, 25.0000000, self));
	m_ButtonOptions.ToolTipString = Localize("Tip", "ButtonOptions", "R6Menu");
	m_ButtonOptions.Text = Localize("SinglePlayer", "ButtonOptions", "R6Menu");
	m_ButtonOptions.Align = 0;
	m_ButtonOptions.m_buttonFont = ButtonFont;
	m_ButtonOptions.ResizeToText();
	XPos = int((m_pHelpWindow.WinLeft + m_pHelpWindow.WinWidth));
	m_ButtonStart = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(XPos), 452.0000000, ((WinWidth - float(XPos)) - float(20)), 25.0000000, self));
	m_ButtonStart.ToolTipString = Localize("Tip", "ButtonStart", "R6Menu");
	m_ButtonStart.Text = Localize("CustomMission", "ButtonStart1", "R6Menu");
	m_ButtonStart.Align = 1;
	m_ButtonStart.m_buttonFont = ButtonFont;
	m_ButtonStart.ResizeToText();
	m_ButtonStart.m_bWaitSoundFinish = true;
	m_TitleTextColor = Root.Colors.White;
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 18.0000000, (WinWidth - float(20)), 25.0000000, self));
	m_LMenuTitle.Text = Localize("Training", "Title", "R6Menu");
	m_LMenuTitle.Align = 1;
	m_LMenuTitle.m_Font = Root.Fonts[4];
	m_LMenuTitle.TextColor = m_TitleTextColor;
	m_LMenuTitle.m_BGTexture = none;
	m_LMenuTitle.m_bDrawBorders = false;
	return;
}

function ShowWindow()
{
	super(UWindowWindow).ShowWindow();
	Root.SetLoadRandomBackgroundImage("Training");
	return;
}

//=================================================================================
// Setup Help Text
//=================================================================================
function ToolTip(string strTip)
{
	m_pHelpWindow.ToolTip(strTip);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	Root.PaintBackground(C, self);
	return;
}

function CurrentSelectedButton(R6WindowButton _IwasPressed)
{
	local R6WindowBitMap mapBitmap;

	// End:0x1C
	if((m_pButCurrent != none))
	{
		m_pButCurrent.m_bSelected = false;
	}
	_IwasPressed.m_bSelected = true;
	m_pButCurrent = _IwasPressed;
	mapBitmap = R6WindowBitMap(m_Map.m_ClientArea);
	mapBitmap.t = m_mapPreviews[_IwasPressed.m_iButtonID];
	return;
}

//------------------------------------------------------------------
// SetCurrentMissionInTraining
//	set the mission description
//------------------------------------------------------------------
function SetCurrentMissionInTraining()
{
	local R6MissionDescription mission;
	local R6Console R6Console;
	local int iMission;
	local string szMapName1, szMapName2;

	R6Console = R6Console(Root.Console);
	szMapName2 = R6Console.Master.m_StartGameInfo.m_MapName;
	szMapName2 = Caps(szMapName2);
	iMission = 0;
	J0x53:

	// End:0xE8 [Loop If]
	if((iMission < R6Console.m_aMissionDescriptions.Length))
	{
		mission = R6Console.m_aMissionDescriptions[iMission];
		szMapName1 = mission.m_MapName;
		szMapName1 = Caps(szMapName1);
		// End:0xDE
		if((szMapName1 == szMapName2))
		{
			R6Console.Master.m_StartGameInfo.m_CurrentMission = mission;
			return;
		}
		(iMission++);
		// [Loop Continue]
		goto J0x53;
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0xBC
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0x31
			case m_ButtonMainMenu:
				Root.ChangeCurrentWidget(7);
				// End:0xBC
				break;
			// End:0x4D
			case m_ButtonOptions:
				Root.ChangeCurrentWidget(16);
				// End:0xBC
				break;
			// End:0x55
			case m_pButBasics:
			// End:0x5D
			case m_pButShooting:
			// End:0x65
			case m_pButExplosives:
			// End:0x6D
			case m_pButRoomClearing1:
			// End:0x75
			case m_pButRoomClearing2:
			// End:0x7D
			case m_pButRoomClearing3:
			// End:0x85
			case m_pButHostageRescue1:
			// End:0x8D
			case m_pButHostageRescue2:
			// End:0xA8
			case m_pButHostageRescue3:
				CurrentSelectedButton(R6WindowButton(C));
				// End:0xBC
				break;
			// End:0xB9
			case m_ButtonStart:
				StartTraining();
				// End:0xBC
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		// End:0x135
		if((int(E) == 11))
		{
			switch(C)
			{
				// End:0xD9
				case m_pButBasics:
				// End:0xE1
				case m_pButShooting:
				// End:0xE9
				case m_pButExplosives:
				// End:0xF1
				case m_pButRoomClearing1:
				// End:0xF9
				case m_pButRoomClearing2:
				// End:0x101
				case m_pButRoomClearing3:
				// End:0x109
				case m_pButHostageRescue1:
				// End:0x111
				case m_pButHostageRescue2:
				// End:0x132
				case m_pButHostageRescue3:
					CurrentSelectedButton(R6WindowButton(C));
					StartTraining();
					// End:0x135
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
}

function StartTraining()
{
	local R6StartGameInfo StartGameInfo;
	local R6FileManagerPlanning pFileManager;
	local int i, j, iNbTeam;
	local string szMapName, szMenuMapName, szSaveName, szLoadErrorMsg;

	StartGameInfo = R6Console(Root.Console).Master.m_StartGameInfo;
	StartGameInfo.m_MapName = m_mapNames[m_pButCurrent.m_iButtonID];
	SetCurrentMissionInTraining();
	StartGameInfo.m_GameMode = "R6Game.R6TrainingMgr";
	szMapName = StartGameInfo.m_MapName;
	szMapName = Caps(szMapName);
	// End:0x451
	if((((szMapName == "TRAINING_BASICS") || (szMapName == "TRAINING_SHOOTING")) || (szMapName == "TRAINING_EXPLOSIVES")))
	{
		StartGameInfo.m_TeamInfo[0].m_iNumberOfMembers = 1;
		iNbTeam = 1;
		StartGameInfo.m_TeamInfo[0].m_iSpawningPointNumber = 1;
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_CharacterName = Localize("Training", "ROOKIE", "R6Menu");
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_ArmorName = "R6Characters.R6RainbowLightBlue";
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_szSpecialityID = "ID_ASSAULT";
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_FaceTexture = Class'R6Game.R6RookieAssault'.default.m_TMenuFaceSmall;
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_FaceCoords.X = float(Class'R6Game.R6RookieAssault'.default.m_RMenuFaceSmallX);
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_FaceCoords.Y = float(Class'R6Game.R6RookieAssault'.default.m_RMenuFaceSmallY);
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_FaceCoords.Z = float(Class'R6Game.R6RookieAssault'.default.m_RMenuFaceSmallW);
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_FaceCoords.W = float(Class'R6Game.R6RookieAssault'.default.m_RMenuFaceSmallH);
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_WeaponName[0] = "";
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_WeaponName[1] = "";
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_BulletType[0] = "";
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_BulletType[1] = "";
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_WeaponGadgetName[0] = "";
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_WeaponGadgetName[1] = "";
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_GadgetName[0] = "";
		StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_GadgetName[1] = "";
	}
	Root.Console.ViewportOwner.bShowWindowsMouse = false;
	R6Console(Root.Console).LaunchTraining();
	Close();
	return;
}

function CreateButtons()
{
	local float fXOffset, fYOffset, fWidth, fHeight, fYPos;

	fXOffset = 10.0000000;
	fYOffset = 26.0000000;
	fWidth = 200.0000000;
	fHeight = 25.0000000;
	fYPos = 64.0000000;
	m_pButBasics = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButBasics.ToolTipString = Localize("Tip", "ButtonBasics", "R6Menu");
	m_pButBasics.Text = Localize("Training", "ButtonBasics", "R6Menu");
	m_pButBasics.Align = 0;
	m_pButBasics.m_buttonFont = m_LeftButtonFont;
	m_pButBasics.m_iButtonID = 0;
	m_pButBasics.bIgnoreLDoubleClick = false;
	m_pButBasics.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButBasics.ResizeToText();
	(fYPos += fYOffset);
	m_pButShooting = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButShooting.ToolTipString = Localize("Tip", "ButtonShooting", "R6Menu");
	m_pButShooting.Text = Localize("Training", "ButtonShooting", "R6Menu");
	m_pButShooting.Align = 0;
	m_pButShooting.m_buttonFont = m_LeftButtonFont;
	m_pButShooting.m_iButtonID = 1;
	m_pButShooting.bIgnoreLDoubleClick = false;
	m_pButShooting.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButShooting.ResizeToText();
	(fYPos += fYOffset);
	m_pButExplosives = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButExplosives.ToolTipString = Localize("Tip", "ButtonExplosives", "R6Menu");
	m_pButExplosives.Text = Localize("Training", "ButtonExplosives", "R6Menu");
	m_pButExplosives.Align = 0;
	m_pButExplosives.m_buttonFont = m_LeftButtonFont;
	m_pButExplosives.m_iButtonID = 2;
	m_pButExplosives.bIgnoreLDoubleClick = false;
	m_pButExplosives.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButExplosives.ResizeToText();
	(fYPos += fYOffset);
	m_pButRoomClearing1 = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButRoomClearing1.ToolTipString = Localize("Tip", "ButtonClearing1", "R6Menu");
	m_pButRoomClearing1.Text = Localize("Training", "ButtonClearing1", "R6Menu");
	m_pButRoomClearing1.Align = 0;
	m_pButRoomClearing1.m_buttonFont = m_LeftButtonFont;
	m_pButRoomClearing1.m_iButtonID = 3;
	m_pButRoomClearing1.bIgnoreLDoubleClick = false;
	m_pButRoomClearing1.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButRoomClearing1.ResizeToText();
	(fYPos += fYOffset);
	m_pButRoomClearing2 = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButRoomClearing2.ToolTipString = Localize("Tip", "ButtonClearing2", "R6Menu");
	m_pButRoomClearing2.Text = Localize("Training", "ButtonClearing2", "R6Menu");
	m_pButRoomClearing2.Align = 0;
	m_pButRoomClearing2.m_buttonFont = m_LeftButtonFont;
	m_pButRoomClearing2.m_iButtonID = 4;
	m_pButRoomClearing2.bIgnoreLDoubleClick = false;
	m_pButRoomClearing2.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButRoomClearing2.ResizeToText();
	(fYPos += fYOffset);
	m_pButRoomClearing3 = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButRoomClearing3.ToolTipString = Localize("Tip", "ButtonClearing3", "R6Menu");
	m_pButRoomClearing3.Text = Localize("Training", "ButtonClearing3", "R6Menu");
	m_pButRoomClearing3.Align = 0;
	m_pButRoomClearing3.m_buttonFont = m_LeftButtonFont;
	m_pButRoomClearing3.m_iButtonID = 5;
	m_pButRoomClearing3.bIgnoreLDoubleClick = false;
	m_pButRoomClearing3.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButRoomClearing3.ResizeToText();
	(fYPos += fYOffset);
	m_pButHostageRescue1 = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButHostageRescue1.ToolTipString = Localize("Tip", "ButtonHostageRescue1", "R6Menu");
	m_pButHostageRescue1.Text = Localize("Training", "ButtonHostageRescue1", "R6Menu");
	m_pButHostageRescue1.Align = 0;
	m_pButHostageRescue1.m_buttonFont = m_LeftButtonFont;
	m_pButHostageRescue1.m_iButtonID = 6;
	m_pButHostageRescue1.bIgnoreLDoubleClick = false;
	m_pButHostageRescue1.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButHostageRescue1.ResizeToText();
	(fYPos += fYOffset);
	m_pButHostageRescue2 = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButHostageRescue2.ToolTipString = Localize("Tip", "ButtonHostageRescue2", "R6Menu");
	m_pButHostageRescue2.Text = Localize("Training", "ButtonHostageRescue2", "R6Menu");
	m_pButHostageRescue2.Align = 0;
	m_pButHostageRescue2.m_buttonFont = m_LeftButtonFont;
	m_pButHostageRescue2.m_iButtonID = 7;
	m_pButHostageRescue2.bIgnoreLDoubleClick = false;
	m_pButHostageRescue2.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButHostageRescue2.ResizeToText();
	(fYPos += fYOffset);
	m_pButHostageRescue3 = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButHostageRescue3.ToolTipString = Localize("Tip", "ButtonHostageRescue3", "R6Menu");
	m_pButHostageRescue3.Text = Localize("Training", "ButtonHostageRescue3", "R6Menu");
	m_pButHostageRescue3.Align = 0;
	m_pButHostageRescue3.m_buttonFont = m_LeftButtonFont;
	m_pButHostageRescue3.m_iButtonID = 8;
	m_pButHostageRescue3.bIgnoreLDoubleClick = false;
	m_pButHostageRescue3.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0000000);
	m_pButHostageRescue3.ResizeToText();
	CurrentSelectedButton(m_pButBasics);
	return;
}

function bool ButtonsUsingDownSizeFont()
{
	local bool Result;

	// End:0xBA
	if(((((((((m_pButBasics.IsFontDownSizingNeeded() || m_pButShooting.IsFontDownSizingNeeded()) || m_pButExplosives.IsFontDownSizingNeeded()) || m_pButRoomClearing1.IsFontDownSizingNeeded()) || m_pButRoomClearing2.IsFontDownSizingNeeded()) || m_pButRoomClearing3.IsFontDownSizingNeeded()) || m_pButHostageRescue1.IsFontDownSizingNeeded()) || m_pButHostageRescue2.IsFontDownSizingNeeded()) || m_pButHostageRescue3.IsFontDownSizingNeeded()))
	{
		Result = true;
	}
	return Result;
	return;
}

function ForceFontDownSizing()
{
	m_pButBasics.m_buttonFont = m_LeftDownSizeFont;
	m_pButShooting.m_buttonFont = m_LeftDownSizeFont;
	m_pButExplosives.m_buttonFont = m_LeftDownSizeFont;
	m_pButRoomClearing1.m_buttonFont = m_LeftDownSizeFont;
	m_pButRoomClearing2.m_buttonFont = m_LeftDownSizeFont;
	m_pButRoomClearing3.m_buttonFont = m_LeftDownSizeFont;
	m_pButHostageRescue1.m_buttonFont = m_LeftDownSizeFont;
	m_pButHostageRescue2.m_buttonFont = m_LeftDownSizeFont;
	m_pButHostageRescue3.m_buttonFont = m_LeftDownSizeFont;
	m_pButBasics.ResizeToText();
	m_pButShooting.ResizeToText();
	m_pButExplosives.ResizeToText();
	m_pButRoomClearing1.ResizeToText();
	m_pButRoomClearing2.ResizeToText();
	m_pButRoomClearing3.ResizeToText();
	m_pButHostageRescue1.ResizeToText();
	m_pButHostageRescue2.ResizeToText();
	m_pButHostageRescue3.ResizeToText();
	return;
}

defaultproperties
{
	m_mapPreviews[0]=Texture'R6MenuBG.TrainingMenu.Training_basics'
	m_mapPreviews[1]=Texture'R6MenuBG.TrainingMenu.Training_shooting'
	m_mapPreviews[2]=Texture'R6MenuBG.TrainingMenu.Training_explosives'
	m_mapPreviews[3]=Texture'R6MenuBG.TrainingMenu.Training_RoomClear1'
	m_mapPreviews[4]=Texture'R6MenuBG.TrainingMenu.Training_RoomClear2'
	m_mapPreviews[5]=Texture'R6MenuBG.TrainingMenu.Training_RoomClear3'
	m_mapPreviews[6]=Texture'R6MenuBG.TrainingMenu.Training_Hostage1'
	m_mapPreviews[7]=Texture'R6MenuBG.TrainingMenu.Training_Hostage2'
	m_mapPreviews[8]=Texture'R6MenuBG.TrainingMenu.Training_Hostage3'
	m_mapNames[0]="Training_basics"
	m_mapNames[1]="Training_shooting"
	m_mapNames[2]="Training_explosives"
	m_mapNames[3]="Training_RoomClear1"
	m_mapNames[4]="Training_RoomClear2"
	m_mapNames[5]="Training_RoomClear3"
	m_mapNames[6]="Training_Hostage1"
	m_mapNames[7]="Training_Hostage2"
	m_mapNames[8]="Training_Hostage3"
}
