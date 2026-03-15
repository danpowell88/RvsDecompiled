//=============================================================================
// UWindowMenuClassDefines - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  UWindowMenuClassDefines.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/24  * Create by Yannick Joly
//=============================================================================
class UWindowMenuClassDefines extends Object
    config(R6ClassDefines);

var config Class<UWindowWindow> ClassMPServerOption;
var config Class<UWindowWindow> ClassButtonsDefines;
// Tab
var config Class<UWindowWindow> ClassMPCreateGameTabOpt;
var config Class<UWindowWindow> ClassMPCreateGameTabAdvOpt;
var config Class<UWindowWindow> ClassMPMenuTabGameModeFilters;
// Widget
var config Class<UWindowWindow> ClassMainWidget;
var config Class<UWindowWindow> ClassIntelWidget;
var config Class<UWindowWindow> ClassPlanningWidget;
var config Class<UWindowWindow> ClassExecuteWidget;
var config Class<UWindowWindow> ClassSinglePlayerWidget;
var config Class<UWindowWindow> ClassCustomMissionWidget;
var config Class<UWindowWindow> ClassTrainingWidget;
var config Class<UWindowWindow> ClassMultiPlayerWidget;
var config Class<UWindowWindow> ClassOptionsWidget;
var config Class<UWindowWindow> ClassCreditsWidget;
var config Class<UWindowWindow> ClassGearWidget;
var config Class<UWindowWindow> ClassMPCreateGameWidget;
var config Class<UWindowWindow> ClassUbiComWidget;
var config Class<UWindowWindow> ClassNonUbiComWidget;
var config Class<UWindowWindow> ClassQuitWidget;
// NEW IN 1.60
var config Class<UWindowWindow> ClassActionPointPupUpMenu;
// NEW IN 1.60
var config Class<UWindowWindow> ClassMovementModePupUpMenu;
// Servers related
var config Class ClassGSServer;
var config Class ClassLanServer;
// Ubi.com, CD-Key and game service related
var config Class<UWindowWindow> ClassUbiLogIn;
var config Class<UWindowWindow> ClassUbiCDKeyCheck;
var config Class<UWindowWindow> ClassQueryServerInfo;
var config Class<UWindowWindow> ClassUbiLoginClient;
// Multiplayer menus
var config Class<UWindowWindow> ClassMultiJoinIP;
// NEW IN 1.60
var config Class<UWindowWindow> ClassWritableMapWidget;
// NEW IN 1.60
var config Class<UWindowWindow> ClassJoinTeamWidget;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInterWidget;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameEsc;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameRecMessages;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameMsgOffensive;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameMsgDefensive;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameMsgReply;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameMsgStatus;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameVote;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameOptionsWidget;
// NEW IN 1.60
var config Class<UWindowWindow> ClassCountDown;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameOperativeSelectorWidget;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameObjectives;
// NEW IN 1.60
var config Class<UWindowWindow> ClassInGameEscNavBar;
// NEW IN 1.60
var config Class ClassGameMenuCom;
// NEW IN 1.60
var config Class<UWindowWindow> ClassMenuCDKeyManager;
// NEW IN 1.60
var config Class<UWindowWindow> ClassOptionsGame;
// NEW IN 1.60
var config Class<UWindowWindow> ClassOptionsSound;
// NEW IN 1.60
var config Class<UWindowWindow> ClassOptionsGraphic;
// NEW IN 1.60
var config Class<UWindowWindow> ClassOptionsHud;
// NEW IN 1.60
var config Class<UWindowWindow> ClassOptionsMulti;
// NEW IN 1.60
var config Class<UWindowWindow> ClassOptionsControls;
// NEW IN 1.60
var config Class<UWindowWindow> ClassOptionsMOD;
// NEW IN 1.60
var config Class<UWindowWindow> ClassOptionsPatchService;
// root
var config string RegularRoot;
var config string InGameMultiRoot;
var config string InGameSingleRoot;

function Created()
{
	local string szMenuDefFile;

	szMenuDefFile = Class'Engine.Actor'.static.GetModMgr().GetMenuDefFile();
	// End:0x49
	if((szMenuDefFile != "R6ClassDefines"))
	{
		LoadConfig("R6ClassDefines");
	}
	LoadConfig(szMenuDefFile);
	return;
}

defaultproperties
{
	ClassMPServerOption=Class'R6Menu.R6MenuMPServerOption'
	ClassButtonsDefines=Class'R6Menu.R6MenuButtonsDefines'
	ClassMPCreateGameTabOpt=Class'R6Menu.R6MenuMPCreateGameTabOptions'
	ClassMPCreateGameTabAdvOpt=Class'R6Menu.R6MenuMPCreateGameTabAdvOptions'
	ClassMPMenuTabGameModeFilters=Class'R6Menu.R6MenuMPMenuTab'
	ClassMainWidget=Class'R6Menu.R6MenuMainWidget'
	ClassIntelWidget=Class'R6Menu.R6MenuIntelWidget'
	ClassPlanningWidget=Class'R6Menu.R6MenuPlanningWidget'
	ClassExecuteWidget=Class'R6Menu.R6MenuExecuteWidget'
	ClassSinglePlayerWidget=Class'R6Menu.R6MenuSinglePlayerWidget'
	ClassCustomMissionWidget=Class'R6Menu.R6MenuCustomMissionWidget'
	ClassTrainingWidget=Class'R6Menu.R6MenuTrainingWidget'
	ClassMultiPlayerWidget=Class'R6Menu.R6MenuMultiPlayerWidget'
	ClassOptionsWidget=Class'R6Menu.R6MenuOptionsWidget'
	ClassCreditsWidget=Class'R6Menu.R6MenuCreditsWidget'
	ClassGearWidget=Class'R6Menu.R6MenuGearWidget'
	ClassMPCreateGameWidget=Class'R6Menu.R6MenuMPCreateGameWidget'
	ClassUbiComWidget=Class'R6Menu.R6MenuUbiComWidget'
	ClassNonUbiComWidget=Class'R6Menu.R6MenuNonUbiWidget'
	ClassQuitWidget=Class'R6Menu.R6MenuQuit'
	ClassActionPointPupUpMenu=Class'R6Menu.R6MenuActionPointMenu'
	ClassMovementModePupUpMenu=Class'R6Menu.R6MenuModeMenu'
	ClassGSServer=Class'R6GameService.R6GSServers'
	ClassLanServer=Class'R6GameService.R6LanServers'
	ClassUbiLogIn=Class'R6Window.R6WindowUbiLogIn'
	ClassUbiCDKeyCheck=Class'R6Window.R6WindowUbiCDKeyCheck'
	ClassQueryServerInfo=Class'R6Window.R6WindowQueryServerInfo'
	ClassUbiLoginClient=Class'R6Window.R6WindowUbiLoginClient'
	ClassMultiJoinIP=Class'R6Window.R6WindowJoinIP'
	ClassWritableMapWidget=Class'R6Menu.R6MenuInGameWritableMapWidget'
	ClassJoinTeamWidget=Class'R6Menu.R6MenuMPJoinTeamWidget'
	ClassInterWidget=Class'R6Menu.R6MenuMPInterWidget'
	ClassInGameEsc=Class'R6Menu.R6MenuMPInGameEsc'
	ClassInGameRecMessages=Class'R6Menu.R6MenuMPInGameRecMessages'
	ClassInGameMsgOffensive=Class'R6Menu.R6MenuMPInGameMsgOffensive'
	ClassInGameMsgDefensive=Class'R6Menu.R6MenuMPInGameMsgDefensive'
	ClassInGameMsgReply=Class'R6Menu.R6MenuMPInGameMsgReply'
	ClassInGameMsgStatus=Class'R6Menu.R6MenuMPInGameMsgStatus'
	ClassInGameVote=Class'R6Menu.R6MenuMPInGameVote'
	ClassInGameOptionsWidget=Class'R6Menu.R6MenuOptionsWidget'
	ClassCountDown=Class'R6Menu.R6MenuMPCountDown'
	ClassInGameOperativeSelectorWidget=Class'R6Menu.R6MenuInGameOperativeSelectorWidget'
	ClassInGameObjectives=Class'R6Menu.R6MenuMPInGameObj'
	ClassInGameEscNavBar=Class'R6Menu.R6MenuMPInGameEscNavBar'
	ClassGameMenuCom=Class'R6Menu.R6MPGameMenuCom'
	ClassMenuCDKeyManager=Class'R6Menu.R6MenuCDKeyManager'
	ClassOptionsGame=Class'R6Menu.R6MenuOptionsGame'
	ClassOptionsSound=Class'R6Menu.R6MenuOptionsSound'
	ClassOptionsGraphic=Class'R6Menu.R6MenuOptionsGraphic'
	ClassOptionsHud=Class'R6Menu.R6MenuOptionsHud'
	ClassOptionsMulti=Class'R6Menu.R6MenuOptionsMulti'
	ClassOptionsControls=Class'R6Menu.R6MenuOptionsControls'
	ClassOptionsMOD=Class'R6Menu.R6MenuOptionsMODS'
	ClassOptionsPatchService=Class'R6Menu.R6MenuOptionsPatchService'
	RegularRoot="R6Menu.R6MenuRootWindow"
	InGameMultiRoot="R6Menu.R6MenuInGameMultiPlayerRootWindow"
	InGameSingleRoot="R6Menu.R6MenuInGameRootWindow"
}
