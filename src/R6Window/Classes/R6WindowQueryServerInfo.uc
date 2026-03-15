//=============================================================================
// R6WindowQueryServerInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowQueryServerInfo.uc : Used to get some basic information
//  from a server before allowing the user to join the server.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/15 * Created by John Bennett
//=============================================================================
class R6WindowQueryServerInfo extends R6WindowMPManager;

const K_MAX_TIME_BEACON = 5.0;

var bool m_bWaitingForBeacon;  // Waiting for the beacon response from the server
var bool m_bRoomValid;  // ubi.com room valid
var float m_fBeaconTime;  // Time at which beacon was sent to query server
var R6WindowPopUpBox m_pPleaseWait;  // Ask user to wait
var R6GSServers m_GameService;  // Manages servers from game service
var UWindowWindow m_pSendMessageDest;  // Window to which the send message function will communicate

//=======================================================================
// StartQueryServerInfoProcedure - Called from  the menus when the 
// query procedure is started
//=======================================================================
function StartQueryServerInfoProcedure(UWindowWindow _pCurrentWidget, string _szServerIP, int _iBeaconPort)
{
	// End:0x2B
	if((InStr(_szServerIP, ":") != -1))
	{
		_szServerIP = Left(_szServerIP, InStr(_szServerIP, ":"));
	}
	m_pSendMessageDest = _pCurrentWidget;
	m_GameService.SetLastServerQueried(_szServerIP);
	m_GameService.m_ClientBeacon.PreJoinQuery(_szServerIP, _iBeaconPort);
	ShowWindow();
	m_bWaitingForBeacon = true;
	m_pPleaseWait.ShowWindow();
	m_fBeaconTime = m_GameService.NativeGetSeconds();
	return;
}

function Manager(UWindowWindow _pCurrentWidget)
{
	local float elapsedTime;

	// End:0x25B
	if(m_bWaitingForBeacon)
	{
		// End:0x1AF
		if(m_GameService.m_ClientBeacon.PreJoinInfo.bResponseRcvd)
		{
			m_bWaitingForBeacon = false;
			// End:0xC1
			if((!IsSameGameVersion(m_GameService.m_ClientBeacon.PreJoinInfo.szPreJoinModName, m_GameService.m_ClientBeacon.PreJoinInfo.szGameVersion)))
			{
				m_pPleaseWait.HideWindow();
				DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_BadVersion", "R6Menu"), 29);				
			}
			else
			{
				// End:0x14B
				if((m_GameService.m_ClientBeacon.PreJoinInfo.iNumPlayers >= m_GameService.m_ClientBeacon.PreJoinInfo.iMaxPlayers))
				{
					m_pPleaseWait.HideWindow();
					DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_ServerFull", "R6Menu"), 29);					
				}
				else
				{
					m_bRoomValid = ((m_GameService.m_ClientBeacon.PreJoinInfo.iLobbyID != 0) && (m_GameService.m_ClientBeacon.PreJoinInfo.iGroupID != 0));
					_pCurrentWidget.SendMessage(8);
					HideWindow();
				}
			}			
		}
		else
		{
			elapsedTime = (m_GameService.NativeGetSeconds() - m_fBeaconTime);
			// End:0x25B
			if((elapsedTime > 5.0000000))
			{
				m_bWaitingForBeacon = false;
				// End:0x213
				if(R6Console(Root.Console).m_bNonUbiMatchMaking)
				{
					_pCurrentWidget.SendMessage(10);					
				}
				else
				{
					m_pPleaseWait.HideWindow();
					DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_NoServer", "R6Menu"), 29);
				}
			}
		}
	}
	return;
}

// NEW IN 1.60
function bool IsSameGameVersion(string _szPreJoinModName, string _szPreJoinInfoGameVer)
{
	local R6ModMgr pModMgr;
	local R6Mod pTempCurrentMod, pBkpMod;
	local string szTemp;
	local int i;
	local bool bSameGameVersion;

	pModMgr = Class'Engine.Actor'.static.GetModMgr();
	// End:0x112
	if(((pModMgr.m_szPendingModName != "") && (!(pModMgr.m_szPendingModName ~= pModMgr.m_pCurrentMod.m_szKeyWord))))
	{
		pTempCurrentMod = pModMgr.GetModInstance(_szPreJoinModName);
		// End:0x10F
		if((pTempCurrentMod != none))
		{
			pBkpMod = pModMgr.m_pCurrentMod;
			pModMgr.m_pCurrentMod = pTempCurrentMod;
			szTemp = Root.Console.ViewportOwner.Actor.GetGameVersion(false, (!Class'Engine.Actor'.static.GetModMgr().IsRavenShield()));
			bSameGameVersion = (szTemp ~= _szPreJoinInfoGameVer);
			pModMgr.m_pCurrentMod = pBkpMod;
		}		
	}
	else
	{
		szTemp = Root.Console.ViewportOwner.Actor.GetGameVersion(false, (!Class'Engine.Actor'.static.GetModMgr().IsRavenShield()));
		bSameGameVersion = (szTemp ~= _szPreJoinInfoGameVer);
	}
	return bSameGameVersion;
	return;
}

function PopUpBoxCreate()
{
	local R6WindowEditBox pR6EditBoxTemp;
	local R6WindowTextLabel pR6TextLabelTemp;

	super.PopUpBoxCreate();
	m_pPleaseWait = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pPleaseWait.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_Wait", "R6Menu"), 30.0000000, 205.0000000, 170.0000000, 230.0000000, 50.0000000, 2);
	m_pPleaseWait.CreateClientWindow(Class'R6Window.R6WindowTextLabel');
	m_pPleaseWait.m_ePopUpID = 28;
	m_pPleaseWait.SetPopUpResizable(true);
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
	// End:0xA2
	if((int(Result) == int(3)))
	{
		switch(_ePopUpID)
		{
			// End:0x1C
			case 28:
			// End:0x9C
			case 29:
				// End:0x55
				if(R6Console(Root.Console).m_bNonUbiMatchMaking)
				{
					Root.ChangeCurrentWidget(38);					
				}
				else
				{
					m_pPleaseWait.HideWindow();
					m_pError.HideWindow();
					m_pSendMessageDest.SendMessage(9);
					m_GameService.SetLastServerQueried("0");
					HideWindow();
				}
				// End:0xA2
				break;
			// End:0xFFFF
			default:
				// End:0xA2
				break;
				break;
		}
	}
	return;
}

