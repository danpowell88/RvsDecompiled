//=============================================================================
// R6WindowUbiCDKeyCheck - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowUbiLogIn.uc : This is used to pop up a window that will ask the user
//                  to input his ubi.com account info.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/08 * Created by John Bennett
//=============================================================================
class R6WindowUbiCDKeyCheck extends R6WindowMPManager;

enum eJoinRoomChoice
{
	EJRC_NO,                        // 0
	EJRC_BY_LOBBY_AND_ROOM_ID       // 1
};

var R6WindowUbiCDKeyCheck.eJoinRoomChoice m_eJoinRoomChoice;  // Need to join the ubi.com room
var R6GSServers m_GameService;  // Manages servers from game service
var UWindowWindow m_pSendMessageDest;
var R6WindowPopUpBox m_pPleaseWait;  // Ask user to wait while we get authorization ID
var R6WindowPopUpBox m_pR6EnterCDKey;  // Menu to enter a cd key.
var string m_szPassword;  // Game Password
// NEW IN 1.60
var string m_szLocMod;

// NEW IN 1.60
function Created()
{
	local R6WindowEditBox pR6EditBoxTemp;
	local R6WindowTextLabel pR6TextLabelTemp;

	PopUpBoxCreate();
	m_pPleaseWait = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pPleaseWait.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_Wait", "R6Menu"), 30.0000000, 205.0000000, 170.0000000, 230.0000000, 50.0000000, int(4));
	m_pPleaseWait.CreateClientWindow(Class'R6Window.R6WindowTextLabel');
	m_pPleaseWait.m_ePopUpID = 16;
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
	m_pR6EnterCDKey = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pR6EnterCDKey.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_EnterCDKey", "R6Menu"), 30.0000000, 205.0000000, 170.0000000, 230.0000000, 50.0000000);
	m_pR6EnterCDKey.CreateClientWindow(Class'R6Window.R6WindowEditBox');
	m_pR6EnterCDKey.m_ePopUpID = 17;
	pR6EditBoxTemp = R6WindowEditBox(m_pR6EnterCDKey.m_ClientArea);
	pR6EditBoxTemp.TextColor = Root.Colors.BlueLight;
	pR6EditBoxTemp.SetFont(8);
	m_pR6EnterCDKey.HideWindow();
	m_pPassword = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pPassword.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_Password", "R6Menu"), 30.0000000, 205.0000000, 170.0000000, 230.0000000, 50.0000000);
	m_pPassword.CreateClientWindow(Class'R6Window.R6WindowEditBox');
	m_pPassword.m_ePopUpID = 18;
	m_pPasswordEditBox = R6WindowEditBox(m_pPassword.m_ClientArea);
	m_pPasswordEditBox.TextColor = Root.Colors.BlueLight;
	m_pPasswordEditBox.SetFont(8);
	m_pPasswordEditBox.MaxLength = 16;
	m_pPasswordEditBox.bCaps = false;
	m_pPasswordEditBox.bPassword = true;
	m_pPassword.HideWindow();
	return;
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	// End:0x1B5
	if((int(Result) == int(3)))
	{
		switch(_ePopUpID)
		{
			// End:0xB0
			case 18:
				m_szPassword = R6WindowEditBox(m_pPassword.m_ClientArea).GetValue();
				switch(m_eJoinRoomChoice)
				{
					// End:0x82
					case 1:
						m_GameService.NativeMSCLientJoinServer(m_preJoinRespInfo.iLobbyID, m_preJoinRespInfo.iGroupID, m_szPassword);
						m_pPleaseWait.ShowWindow();
						// End:0xAD
						break;
					// End:0xAA
					case 0:
						m_pPleaseWait.ShowLockPopUp();
						m_pSendMessageDest.SendMessage(4);
						// End:0xAD
						break;
					// End:0xFFFF
					default:
						break;
				}
				// End:0x1B2
				break;
			// End:0xD6
			case 22:
				m_pPassword.ShowWindow();
				m_pPasswordEditBox.SelectAll();
				// End:0x1B2
				break;
			// End:0x12E
			case 25:
				// End:0x12E
				if((R6Console(Root.Console).m_bNonUbiMatchMaking || R6Console(Root.Console).m_bStartedByGSClient))
				{
					Root.ChangeCurrentWidget(38);
				}
			// End:0x133
			case 16:
			// End:0x138
			case 19:
			// End:0x13D
			case 20:
			// End:0x142
			case 21:
			// End:0x161
			case 23:
				m_pSendMessageDest.SendMessage(5);
				HideWindow();
				// End:0x1B2
				break;
			// End:0x1A1
			case 17:
				m_GameService.EnterCDKey(R6WindowEditBox(m_pR6EnterCDKey.m_ClientArea).GetValue());
				m_pPleaseWait.ShowWindow();
				// End:0x1B2
				break;
			// End:0x1AF
			case 26:
				HandleLockedServerPopUp();
				// End:0x1B2
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		// End:0x260
		if((int(Result) == int(4)))
		{
			switch(_ePopUpID)
			{
				// End:0x1D1
				case 16:
				// End:0x1D6
				case 17:
				// End:0x1DB
				case 19:
				// End:0x1E0
				case 20:
				// End:0x1E5
				case 21:
				// End:0x1EA
				case 22:
				// End:0x203
				case 23:
					m_pSendMessageDest.SendMessage(5);
					// End:0x25A
					break;
				// End:0x208
				case 18:
				// End:0x20D
				case 26:
				// End:0x257
				case 25:
					m_pSendMessageDest.SendMessage(5);
					// End:0x254
					if(R6Console(Root.Console).m_bNonUbiMatchMaking)
					{
						Root.ChangeCurrentWidget(38);
					}
					// End:0x25A
					break;
				// End:0xFFFF
				default:
					break;
			}
			HideWindow();
		}
	}
	return;
}

// NEW IN 1.60
function SelectCDKeyBox(bool _bClearEditBox)
{
	local R6WindowEditBox pR6EditBoxTemp;

	pR6EditBoxTemp = R6WindowEditBox(m_pR6EnterCDKey.m_ClientArea);
	// End:0x31
	if(_bClearEditBox)
	{
		pR6EditBoxTemp.Clear();
	}
	pR6EditBoxTemp.SelectAll();
	return;
}

// NEW IN 1.60
function ProcessGSMsg(string _szMsg)
{
	// End:0x3D
	if(bShowLog)
	{
		Log(("R6WindowUbiCDKeyCheck ProcessGSMsg msg = " @ _szMsg));
	}
	switch(_szMsg)
	{
		// End:0x72
		case "UP_HANDLE_PB_SRV_SITUATION":
			ShowWindow();
			HandlePunkBusterSvrSituation();
			// End:0x88D
			break;
		// End:0xF5
		case "UP_ENTER_CD_KEY":
			m_pR6EnterCDKey.ModifyTextWindow(Localize("MultiPlayer", "PopUp_EnterCDKey", "R6Menu"), 205.0000000, 170.0000000, 230.0000000, 30.0000000);
			m_pR6EnterCDKey.ShowWindow();
			SelectCDKeyBox(false);
			ShowWindow();
			// End:0x88D
			break;
		// End:0x179
		case "UP_MOD_ENTER_CD_KEY":
			m_pR6EnterCDKey.ModifyTextWindow(Localize("MultiPlayer", "PopUp_ModEnterCDKey", "R6Menu"), 205.0000000, 170.0000000, 230.0000000, 30.0000000);
			m_pR6EnterCDKey.ShowWindow();
			SelectCDKeyBox(true);
			// End:0x88D
			break;
		// End:0x198
		case "UP_REQUEST_AUTHID":
			ShowWindow();
			// End:0x88D
			break;
		// End:0x1C4
		case "UP_MOD_REQUEST_AUTHID":
			m_pPleaseWait.ShowLockPopUp();
			// End:0x88D
			break;
		// End:0x25E
		case "ACT_ID_REQ_TIMEOUT_ERROR":
			m_pPleaseWait.HideWindow();
			m_pR6EnterCDKey.ModifyTextWindow((m_szLocMod $ Localize("Errors", "CDKeyServerNotResponding", "R6ENGINE")), 205.0000000, 170.0000000, 230.0000000, 30.0000000);
			m_pR6EnterCDKey.ShowWindow();
			// End:0x88D
			break;
		// End:0x287
		case "ACT_ID_REQ_SUCCESS":
			m_GameService.SaveInfo();
			// End:0x88D
			break;
		// End:0x319
		case "ACT_ID_REQ_FAIL_INVALIDCDKEY":
			m_pPleaseWait.HideWindow();
			m_pR6EnterCDKey.ModifyTextWindow((m_szLocMod $ Localize("Errors", "INVALIDCDKEY", "R6ENGINE")), 205.0000000, 170.0000000, 230.0000000, 30.0000000);
			m_pR6EnterCDKey.ShowWindow();
			// End:0x88D
			break;
		// End:0x383
		case "ACT_ID_REQ_FAIL_CDKEYUSED":
			m_pPleaseWait.HideWindow();
			DisplayErrorMsg((m_szLocMod $ Localize("Errors", "CDKeyAlreadyInUse", "R6ENGINE")), 20);
			// End:0x88D
			break;
		// End:0x411
		case "ACT_ID_REQ_FAIL_DEFAULT":
			m_pPleaseWait.HideWindow();
			m_pR6EnterCDKey.ModifyTextWindow((m_szLocMod $ Localize("Errors", "CDKeyTryLater", "R6ENGINE")), 205.0000000, 170.0000000, 230.0000000, 30.0000000);
			m_pR6EnterCDKey.ShowWindow();
			// End:0x88D
			break;
		// End:0x482
		case "AUTH_ID_REQ_TIMEOUT_ERROR":
			m_pPleaseWait.HideWindow();
			DisplayErrorMsg((m_szLocMod $ Localize("Errors", "CDKeyServerNotResponding", "R6ENGINE")), 21);
			// End:0x88D
			break;
		// End:0x4EA
		case "AUTH_ID_REQ_INUSE_ERROR":
			m_pPleaseWait.HideWindow();
			DisplayErrorMsg((m_szLocMod $ Localize("Errors", "CDKeyAlreadyInUse", "R6ENGINE")), 20);
			// End:0x88D
			break;
		// End:0x502
		case "AUTH_ID_REQ_TIMEOUT":
		// End:0x532
		case "AUTH_ID_REQ_SUCCESS":
			m_pPleaseWait.HideWindow();
			HandlePunkBusterSvrSituation();
			// End:0x88D
			break;
		// End:0x5C9
		case "AUTH_ID_REQ_NOTCHALLENGED":
			m_pPleaseWait.HideWindow();
			m_pPleaseWait.ModifyTextWindow(((m_szLocMod $ Localize("Errors", "CDKeyTryLater", "R6ENGINE")) $ ": 3"), 205.0000000, 170.0000000, 230.0000000, 30.0000000);
			m_pPleaseWait.ShowWindow();
			// End:0x88D
			break;
		// End:0x65C
		case "AUTH_ID_REQ_INT_ERROR":
			m_pPleaseWait.HideWindow();
			m_pPleaseWait.ModifyTextWindow(((m_szLocMod $ Localize("Errors", "CDKeyTryLater", "R6ENGINE")) $ ": 5"), 205.0000000, 170.0000000, 230.0000000, 30.0000000);
			m_pPleaseWait.ShowWindow();
			// End:0x88D
			break;
		// End:0x6E5
		case "AUTH_ID_REQ_FAILURE":
			m_pPleaseWait.HideWindow();
			m_pR6EnterCDKey.ModifyTextWindow((m_szLocMod $ Localize("Errors", "INVALIDCDKEY", "R6ENGINE")), 205.0000000, 170.0000000, 230.0000000, 30.0000000);
			m_pR6EnterCDKey.ShowWindow();
			// End:0x88D
			break;
		// End:0x713
		case "AUTH_ID_REQ_FAILURE_DBG":
			m_pPleaseWait.HideWindow();
			// End:0x88D
			break;
		// End:0x743
		case "JOIN_SERVER_REQ_SUCCESS":
			m_pSendMessageDest.SendMessage(4);
			// End:0x88D
			break;
		// End:0x7B4
		case "JOIN_SERVER_FAIL_PASSWORDNOTCORRECT":
			m_pPleaseWait.HideWindow();
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_PassWd", "R6Menu"), 22);
			// End:0x88D
			break;
		// End:0x81F
		case "JOIN_SERVER_FAIL_ROOMFULL":
			m_pPleaseWait.HideWindow();
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_ServerFull", "R6Menu"), 23);
			// End:0x88D
			break;
		// End:0x887
		case "JOIN_SERVER_FAIL_DEFAULT":
			m_pPleaseWait.HideWindow();
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_RoomJoin", "R6Menu"), 19);
			// End:0x88D
			break;
		// End:0xFFFF
		default:
			// End:0x88D
			break;
			break;
	}
	return;
}

// NEW IN 1.60
function DisplayErrorMsg(string _szErrorMsg, UWindowBase.EPopUpID _ePopUpID)
{
	BringToFront();
	super.DisplayErrorMsg(_szErrorMsg, _ePopUpID);
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var bShowLog
// REMOVED IN 1.60: function StartPreJoinProcedure
// REMOVED IN 1.60: function Manager
// REMOVED IN 1.60: function PopUpBoxCreate
