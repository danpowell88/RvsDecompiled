//=============================================================================
//  UWindowMenuClassDefines.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/24  * Create by Yannick Joly
//=============================================================================
class UWindowMenuClassDefines extends Object
    config(R6ClassDefines);

// --- Variables ---
var config class<UWindowWindow> ClassOptionsPatchService;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassOptionsMOD;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassOptionsControls;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassOptionsMulti;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassOptionsHud;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassMPServerOption;
var config class<UWindowWindow> ClassButtonsDefines;
// root
var config string RegularRoot;
var config string InGameMultiRoot;
var config string InGameSingleRoot;
// Tab
var config class<UWindowWindow> ClassMPCreateGameTabOpt;
var config class<UWindowWindow> ClassMPCreateGameTabAdvOpt;
var config class<UWindowWindow> ClassMPMenuTabGameModeFilters;
// Widget
var config class<UWindowWindow> ClassMainWidget;
var config class<UWindowWindow> ClassIntelWidget;
var config class<UWindowWindow> ClassPlanningWidget;
var config class<UWindowWindow> ClassExecuteWidget;
var config class<UWindowWindow> ClassSinglePlayerWidget;
var config class<UWindowWindow> ClassCustomMissionWidget;
var config class<UWindowWindow> ClassTrainingWidget;
var config class<UWindowWindow> ClassMultiPlayerWidget;
var config class<UWindowWindow> ClassOptionsWidget;
var config class<UWindowWindow> ClassCreditsWidget;
var config class<UWindowWindow> ClassGearWidget;
var config class<UWindowWindow> ClassMPCreateGameWidget;
var config class<UWindowWindow> ClassUbiComWidget;
var config class<UWindowWindow> ClassNonUbiComWidget;
var config class<UWindowWindow> ClassQuitWidget;
var config class<UWindowWindow> ClassActionPointPupUpMenu;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassMovementModePupUpMenu;
// ^ NEW IN 1.60
// Servers related
var config class<Object> ClassGSServer;
var config class<Object> ClassLanServer;
// Ubi.com, CD-Key and game service related
var config class<UWindowWindow> ClassUbiLogIn;
var config class<UWindowWindow> ClassUbiCDKeyCheck;
var config class<UWindowWindow> ClassQueryServerInfo;
var config class<UWindowWindow> ClassUbiLoginClient;
// Multiplayer menus
var config class<UWindowWindow> ClassMultiJoinIP;
var config class<UWindowWindow> ClassWritableMapWidget;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassJoinTeamWidget;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInterWidget;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameEsc;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameRecMessages;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameMsgOffensive;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameMsgDefensive;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameMsgReply;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameMsgStatus;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameVote;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameOptionsWidget;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassCountDown;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameOperativeSelectorWidget;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameObjectives;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassInGameEscNavBar;
// ^ NEW IN 1.60
var config class<Object> ClassGameMenuCom;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassMenuCDKeyManager;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassOptionsGame;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassOptionsSound;
// ^ NEW IN 1.60
var config class<UWindowWindow> ClassOptionsGraphic;
// ^ NEW IN 1.60

// --- Functions ---
function Created() {}

defaultproperties
{
}
