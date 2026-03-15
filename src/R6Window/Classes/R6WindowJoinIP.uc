//=============================================================================
// R6WindowJoinIP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowJoinIP.uc : This class handles the logic and pop up windows
//                      associated with the user joining a server by using
//                      the Join IP button
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/02 * Created by John Bennett
//=============================================================================
class R6WindowJoinIP extends UWindowWindow;

const K_MAX_TIME_BEACON = 5.0;

enum eJoinIPState
{
	EJOINIP_ENTER_IP,               // 0
	EJOINIP_WAITING_FOR_BEACON,     // 1
	EJOINIP_BEACON_FAIL,            // 2
	EJOINIP_WAITING_FOR_UBICOMLOGIN // 3
};

var R6WindowJoinIP.eJoinIPState eState;  // Enumeration used in state machine for JOIN IO procedure
var bool m_bRoomValid;  // ubi.com room valid
// ASE DEVELOPMENT - Eric Begin - May 11th, 2003
//
// This variable is set locally to prevent hidding and showing windows for nothing.
var bool m_bStartByCmdLine;
var float m_fBeaconTime;  // Time at which beacon was sent to query server
var R6WindowPopUpBox m_pEnterIP;  // The enter IP window
var R6WindowPopUpBox m_pPleaseWait;  // Ask user to wait while we get authorization ID (pop up window)
var R6WindowPopUpBox m_pError;  // Error pop up window
var R6GSServers m_GameService;  // Manages servers from game service
var UWindowWindow m_pSendMessageDest;  // Window to which the send message function will communicate
var string m_szIP;  // IP address entered by user

//=======================================================================
// StartJoinIPProcedure - Called from the menus when the user should
// enter an IP of the server he wishes to join
//=======================================================================
function StartJoinIPProcedure(UWindowWindow _pCurrentWidget, string _szLastIP)
{
	m_pSendMessageDest = _pCurrentWidget;
	ShowWindow();
	eState = 0;
	m_pEnterIP.ShowWindow();
	R6WindowEditBox(m_pEnterIP.m_ClientArea).SetValue(_szLastIP);
	m_bStartByCmdLine = false;
	return;
}

// ASE DEVELOPMENT - Eric Begin - May 11th, 2003
//
// Add a new function to deal with the fact that when the player connect to a server via the
// command line, chances are that he won't be connect on ubi.com.
function StartCmdLineJoinIPProcedure(UWindowWindow _pCurrentWidget, string _szLastIP)
{
	Log("R6WindowJoinIP::StartCmdLineJoinIPProcedure");
	m_pSendMessageDest = _pCurrentWidget;
	ShowWindow();
	eState = 3;
	m_pPleaseWait.ShowWindow();
	Log("R6WindowJoinIP::SetValue");
	R6WindowEditBox(m_pEnterIP.m_ClientArea).SetValue(_szLastIP);
	m_bStartByCmdLine = true;
	return;
}

function Manager(UWindowWindow _pCurrentWidget)
{
	local float elapsedTime;

	switch(eState)
	{
		// End:0x2B
		case 3:
			// End:0x28
			if(m_GameService.m_bLoggedInUbiDotCom)
			{
				PopUpBoxDone(3, 10);
			}
			// End:0x312
			break;
		// End:0x30F
		case 1:
			// End:0x26F
			if(m_GameService.m_ClientBeacon.PreJoinInfo.bResponseRcvd)
			{
				// End:0x12B
				if((Root.Console.ViewportOwner.Actor.GetGameVersion(false, (!Class'Engine.Actor'.static.GetModMgr().IsRavenShield())) != m_GameService.m_ClientBeacon.PreJoinInfo.szGameVersion))
				{
					eState = 2;
					m_pPleaseWait.HideWindow();
					m_pError.ShowWindow();
					R6WindowTextLabel(m_pError.m_ClientArea).SetNewText(Localize("MultiPlayer", "PopUp_Error_BadVersion", "R6Menu"), true);					
				}
				else
				{
					// End:0x170
					if(R6Console(Root.Console).m_bNonUbiMatchMaking)
					{
						_pCurrentWidget.SendMessage(6);
						// End:0x16D
						if((!m_bStartByCmdLine))
						{
							HideWindow();
						}						
					}
					else
					{
						// End:0x20B
						if((!m_GameService.m_ClientBeacon.PreJoinInfo.bInternetServer))
						{
							eState = 2;
							m_pPleaseWait.HideWindow();
							m_pError.ShowWindow();
							R6WindowTextLabel(m_pError.m_ClientArea).SetNewText(Localize("MultiPlayer", "PopUp_Error_LanServer", "R6Menu"), true);							
						}
						else
						{
							m_bRoomValid = ((m_GameService.m_ClientBeacon.PreJoinInfo.iLobbyID != 0) && (m_GameService.m_ClientBeacon.PreJoinInfo.iGroupID != 0));
							_pCurrentWidget.SendMessage(6);
							HideWindow();
						}
					}
				}				
			}
			else
			{
				elapsedTime = (m_GameService.NativeGetSeconds() - m_fBeaconTime);
				// End:0x30C
				if((elapsedTime > 5.0000000))
				{
					eState = 2;
					m_pPleaseWait.HideWindow();
					m_pError.ShowWindow();
					R6WindowTextLabel(m_pError.m_ClientArea).SetNewText(Localize("MultiPlayer", "PopUp_Error_NoServer", "R6Menu"), true);
				}
			}
			// End:0x312
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function PopUpBoxCreate()
{
	local R6WindowEditBox pR6EditBoxTemp;
	local R6WindowTextLabel pR6TextLabelTemp;

	m_pEnterIP = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pEnterIP.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_Join", "R6Menu"), 30.0000000, 205.0000000, 170.0000000, 230.0000000, 50.0000000);
	m_pEnterIP.CreateClientWindow(Class'R6Window.R6WindowEditBox');
	m_pEnterIP.m_ePopUpID = 10;
	pR6EditBoxTemp = R6WindowEditBox(m_pEnterIP.m_ClientArea);
	pR6EditBoxTemp.TextColor = Root.Colors.BlueLight;
	pR6EditBoxTemp.SetFont(8);
	pR6EditBoxTemp.MaxLength = 21;
	m_pEnterIP.HideWindow();
	m_pError = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pError.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_Error_Title", "R6Menu"), 30.0000000, 205.0000000, 170.0000000, 230.0000000, 50.0000000, int(2));
	m_pError.CreateClientWindow(Class'R6Window.R6WindowTextLabel');
	m_pError.m_ePopUpID = 11;
	pR6TextLabelTemp = R6WindowTextLabel(m_pError.m_ClientArea);
	pR6TextLabelTemp.Text = Localize("MultiPlayer", "PopUp_Error_NoServer", "R6Menu");
	pR6TextLabelTemp.Align = 2;
	pR6TextLabelTemp.m_Font = Root.Fonts[6];
	pR6TextLabelTemp.TextColor = Root.Colors.BlueLight;
	pR6TextLabelTemp.m_BGTexture = none;
	pR6TextLabelTemp.m_HBorderTexture = none;
	pR6TextLabelTemp.m_VBorderTexture = none;
	pR6TextLabelTemp.m_TextDrawstyle = int(5);
	m_pError.HideWindow();
	m_pPleaseWait = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pPleaseWait.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_Wait", "R6Menu"), 30.0000000, 205.0000000, 170.0000000, 230.0000000, 50.0000000, int(2));
	m_pPleaseWait.CreateClientWindow(Class'R6Window.R6WindowTextLabel');
	m_pPleaseWait.m_ePopUpID = 12;
	pR6TextLabelTemp = R6WindowTextLabel(m_pPleaseWait.m_ClientArea);
	pR6TextLabelTemp.Text = Localize("MultiPlayer", "PopUp_Cancel", "R6Menu");
	pR6TextLabelTemp.Align = 2;
	pR6TextLabelTemp.m_Font = Root.Fonts[6];
	pR6TextLabelTemp.TextColor = Root.Colors.BlueLight;
	pR6TextLabelTemp.m_BGTexture = none;
	pR6TextLabelTemp.m_HBorderTexture = none;
	pR6TextLabelTemp.m_VBorderTexture = none;
	pR6TextLabelTemp.m_TextDrawstyle = int(5);
	m_pPleaseWait.HideWindow();
	return;
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	// End:0x147
	if((int(Result) == int(3)))
	{
		switch(_ePopUpID)
		{
			// End:0xC4
			case 10:
				m_szIP = R6WindowEditBox(m_pEnterIP.m_ClientArea).GetValue();
				// End:0x8D
				if((m_GameService.m_ClientBeacon.PreJoinQuery(m_szIP, 0) == false))
				{
					PopUpBoxDone(3, 11);
					Log("Invalid IP string entered");
					// [Explicit Continue]
					goto J0x144;
				}
				// End:0xA7
				if((!m_bStartByCmdLine))
				{
					m_pPleaseWait.ShowWindow();
				}
				m_fBeaconTime = m_GameService.NativeGetSeconds();
				eState = 1;
				// End:0x144
				break;
			// End:0x101
			case 12:
				m_pPleaseWait.HideWindow();
				m_pError.HideWindow();
				m_pSendMessageDest.SendMessage(7);
				HideWindow();
				// End:0x144
				break;
			// End:0x13E
			case 11:
				m_pPleaseWait.HideWindow();
				m_pError.HideWindow();
				m_pEnterIP.ShowWindow();
				eState = 0;
				// End:0x144
				break;
			// End:0xFFFF
			default:
				// End:0x144
				break;
				break;
		}
		J0x144:
		
	}
	else
	{
		// End:0x192
		if((int(Result) == int(4)))
		{
			switch(_ePopUpID)
			{
				// End:0x186
				case 10:
					m_pEnterIP.HideWindow();
					m_pSendMessageDest.SendMessage(7);
					// End:0x18C
					break;
				// End:0xFFFF
				default:
					// End:0x18C
					break;
					break;
			}
			HideWindow();
		}
	}
	return;
}

