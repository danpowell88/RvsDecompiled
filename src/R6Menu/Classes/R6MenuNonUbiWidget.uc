//=============================================================================
// R6MenuNonUbiWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuNonUbiWidget.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2003/07/03 * Created by Yannick Joly
//=============================================================================
class R6MenuNonUbiWidget extends R6MenuWidget;

var bool m_bLoginInProgress;  // procedure to login to ubi.com in progress
var bool m_bJoinIPInProgress;
var bool m_bQueryServerInfoInProgress;
var bool m_bNonUbiMatchMakingClient;
var R6GSServers m_GameService;
var R6WindowUbiLogIn m_pLoginWindow;
var R6WindowJoinIP m_pJoinIPWindow;  // Windows and login for Join IP steps
var R6WindowQueryServerInfo m_pQueryServerInfo;  // Windows and login for logic to query a server for information
var string m_szGamePwd;

function Created()
{
	m_GameService = R6Console(Root.Console).m_GameService;
	m_pLoginWindow = R6WindowUbiLogIn(CreateWindow(Root.MenuClassDefines.ClassUbiLogIn, 0.0000000, 0.0000000, 640.0000000, 480.0000000, self, true));
	m_pLoginWindow.m_GameService = R6Console(Root.Console).m_GameService;
	m_pLoginWindow.PopUpBoxCreate();
	m_pLoginWindow.HideWindow();
	m_pJoinIPWindow = R6WindowJoinIP(CreateWindow(Root.MenuClassDefines.ClassMultiJoinIP, 0.0000000, 0.0000000, 640.0000000, 480.0000000, self, true));
	m_pJoinIPWindow.m_GameService = m_GameService;
	m_pJoinIPWindow.PopUpBoxCreate();
	m_pJoinIPWindow.HideWindow();
	m_pQueryServerInfo = R6WindowQueryServerInfo(CreateWindow(Root.MenuClassDefines.ClassQueryServerInfo, 0.0000000, 0.0000000, 640.0000000, 480.0000000, self, true));
	m_pQueryServerInfo.m_GameService = m_GameService;
	m_pQueryServerInfo.PopUpBoxCreate();
	m_pQueryServerInfo.HideWindow();
	m_bNonUbiMatchMakingClient = R6Console(Root.Console).m_bNonUbiMatchMaking;
	return;
}

function ShowWindow()
{
	R6MenuRootWindow(Root).m_pMenuCDKeyManager.SetWindowUser(Root.22, self);
	// End:0x14D
	if((m_bNonUbiMatchMakingClient || R6Console(Root.Console).m_bAutoLoginFirstPass))
	{
		R6Console(Root.Console).m_bAutoLoginFirstPass = false;
		R6MenuRootWindow(Root).InitBeaconService();
		R6Console(Root.Console).m_GameService.StartAutoLogin();
		// End:0x135
		if((!R6Console(Root.Console).m_GameService.m_bAutoLoginInProgress))
		{
			R6Console(Root.Console).szStoreGamePassWd = R6Console(Root.Console).m_GameService.m_szSavedPwd;
			m_pLoginWindow.StartLogInProcedure(self);
			m_bLoginInProgress = true;			
		}
		else
		{
			m_pLoginWindow.m_pSendMessageDest = self;
			m_bLoginInProgress = true;
		}
	}
	super(UWindowWindow).ShowWindow();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local string szTemp;
	local float W, H;

	C.Style = 5;
	C.SetDrawColor(Root.Colors.Black.R, Root.Colors.Black.G, Root.Colors.Black.B);
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, 0.0000000, 0.0000000, 10.0000000, 10.0000000, Texture'UWindow.WhiteTexture');
	return;
}

function Tick(float Delta)
{
	// End:0x19
	if(m_bLoginInProgress)
	{
		m_pLoginWindow.Manager(self);
	}
	// End:0x32
	if(m_bJoinIPInProgress)
	{
		m_pJoinIPWindow.Manager(self);
	}
	// End:0x4B
	if(m_bQueryServerInfoInProgress)
	{
		m_pQueryServerInfo.Manager(self);
	}
	return;
}

function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
	local string _szIPAddress;

	switch(eMessage)
	{
		// End:0x14
		case 10:
			m_bQueryServerInfoInProgress = false;
		// End:0x19
		case 0:
		// End:0x61
		case 2:
			m_bLoginInProgress = false;
			Class'Engine.Actor'.static.NativeNonUbiMatchMakingAddress(_szIPAddress);
			// End:0x5E
			if(m_bNonUbiMatchMakingClient)
			{
				m_pQueryServerInfo.StartQueryServerInfoProcedure(self, _szIPAddress, 0);
				m_bQueryServerInfoInProgress = true;
			}
			// End:0x10B
			break;
		// End:0x82
		case 1:
			m_bLoginInProgress = false;
			Root.ChangeCurrentWidget(38);
			// End:0x10B
			break;
		// End:0xBD
		case 6:
			m_bJoinIPInProgress = false;
			R6MenuRootWindow(Root).m_pMenuCDKeyManager.JoinServer(m_pJoinIPWindow.m_szIP);
			// End:0x10B
			break;
		// End:0xF8
		case 8:
			QueryReceivedStartPreJoin();
			Log(("m_bRoomValid =" @ string(m_pQueryServerInfo.m_bRoomValid)));
			m_bQueryServerInfoInProgress = false;
			// End:0x10B
			break;
		// End:0x108
		case 9:
			m_bQueryServerInfoInProgress = false;
			// End:0x10B
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function QueryReceivedStartPreJoin()
{
	local R6WindowUbiCDKeyCheck.eJoinRoomChoice eJoinRoom;
	local bool bRoomValid;

	bRoomValid = ((m_GameService.m_ClientBeacon.PreJoinInfo.iLobbyID != 0) && (m_GameService.m_ClientBeacon.PreJoinInfo.iGroupID != 0));
	// End:0x5E
	if(bRoomValid)
	{
		eJoinRoom = 1;		
	}
	else
	{
		eJoinRoom = 0;
	}
	R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess(eJoinRoom, m_GameService.m_ClientBeacon.PreJoinInfo);
	return;
}

function PromptConnectionError()
{
	local R6MenuRootWindow r6Root;
	local string szTemp;

	r6Root = R6MenuRootWindow(Root);
	r6Root.m_RSimplePopUp.X = 140;
	r6Root.m_RSimplePopUp.Y = 170;
	r6Root.m_RSimplePopUp.W = 360;
	r6Root.m_RSimplePopUp.H = 77;
	// End:0x1AD
	if((R6Console(Root.Console).m_szLastError != ""))
	{
		szTemp = Localize("Multiplayer", R6Console(Root.Console).m_szLastError, "R6Menu", true);
		// End:0x113
		if((szTemp == ""))
		{
			szTemp = Localize("Errors", R6Console(Root.Console).m_szLastError, "R6Engine", true);
		}
		// End:0x141
		if((szTemp == ""))
		{
			szTemp = R6Console(Root.Console).m_szLastError;
		}
		r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), szTemp, 24, int(2), false, self);
		R6Console(Root.Console).m_szLastError = "";		
	}
	else
	{
		r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "Popup_ConnectionError", "R6Menu"), 24, int(2), false, self);
	}
	return;
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	R6WindowRootWindow(Root).m_RSimplePopUp = R6WindowRootWindow(Root).default.m_RSimplePopUp;
	// End:0x48
	if((int(Result) == int(3)))
	{
		Root.ChangeCurrentWidget(38);
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pCDKeyCheckWindow
// REMOVED IN 1.60: var m_bPreJoinInProgress
// REMOVED IN 1.60: function JoinServer
