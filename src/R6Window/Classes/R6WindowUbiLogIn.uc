//=============================================================================
// R6WindowUbiLogIn - extracted from retail RavenShield 1.60
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
class R6WindowUbiLogIn extends R6WindowMPManager;

var R6WindowPopUpBox m_pR6UbiAccount;  // Pop up for ubi account
var R6WindowPopUpBox m_pDisconnected;  // Disconnected from ubi.com
var R6GSServers m_GameService;  // Manages servers from game service
var UWindowWindow m_pSendMessageDest;
// NEW IN 1.60
var string m_szInitError;

//=======================================================================
// StartLogInProcedure - Called from the menus when the user should
// enter his ubi.com userID/password
//=======================================================================
function StartLogInProcedure(UWindowWindow _pCurrentWidget)
{
	m_pSendMessageDest = _pCurrentWidget;
	Root.RegisterMsgWindow(self);
	Class'Engine.Actor'.static.__NFUN_1551__().__NFUN_1289__();
	return;
}

//=======================================================================
// LogInAfterDisconnect - Called from the menus when the connection
// to ubi.com has been lost
//=======================================================================
function LogInAfterDisconnect(UWindowWindow _pCurrentWidget)
{
	m_pSendMessageDest = _pCurrentWidget;
	ShowWindow();
	m_pDisconnected.ShowWindow();
	return;
}

function Manager(UWindowWindow _pCurrentWidget)
{
	m_pSendMessageDest = _pCurrentWidget;
	return;
}

// NEW IN 1.60
function ProcessGSMsg(string _szMsg)
{
	// End:0x38
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("R6WindowUbiLogIn ProcessGSMsg msg = ", _szMsg));
	}
	// End:0x63
	if(__NFUN_122__(m_szInitError, "INITIALIZEMSCLIENT"))
	{
		m_szInitError = _szMsg;
		return;
	}
	switch(_szMsg)
	{
		// End:0x160
		case "LOGIN_START":
			m_pR6UbiAccount.HideWindow();
			m_pDisconnected.HideWindow();
			m_pError.HideWindow();
			ShowWindow();
			R6WindowUbiLoginClient(m_pR6UbiAccount.m_ClientArea).m_pPassword.SetValue(m_GameService.m_szSavedPwd);
			R6WindowUbiLoginClient(m_pR6UbiAccount.m_ClientArea).m_pUserName.SetValue(m_GameService.m_szUserID);
			m_pR6UbiAccount.ShowWindow();
			R6WindowUbiLoginClient(m_pR6UbiAccount.m_ClientArea).m_pUserName.EditBox.LMouseDown(0.0000000, 0.0000000);
			// End:0x500
			break;
		// End:0x1B3
		case "LOGIN_SKIPPED":
			m_pR6UbiAccount.HideWindow();
			m_pDisconnected.HideWindow();
			m_pError.HideWindow();
			m_pSendMessageDest.SendMessage(2);
			// End:0x500
			break;
		// End:0x1E3
		case "LOGIN_ALREADY_IN_PROGRESS":
			Root.UnRegisterMsgWindow();
			// End:0x500
			break;
		// End:0x239
		case "LOGIN_SUCCESS":
			m_pR6UbiAccount.HideWindow();
			m_pDisconnected.HideWindow();
			HideWindow();
			m_GameService.__NFUN_536__();
			m_pSendMessageDest.SendMessage(0);
			// End:0x500
			break;
		// End:0x295
		case "LOGIN_FAIL_PASSWORDNOTCORRECT":
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_PassWd", "R6Menu"), 14);
			// End:0x500
			break;
		// End:0x2EC
		case "LOGIN_FAIL_NOTREGISTERED":
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_UserID", "R6Menu"), 14);
			// End:0x500
			break;
		// End:0x347
		case "LOGIN_FAIL_ALREADYCONNECTED":
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_IdInUse", "R6Menu"), 14);
			// End:0x500
			break;
		// End:0x3A1
		case "LOGIN_FAIL_DATABASEFAILED":
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_DataBase", "R6Menu"), 14);
			// End:0x500
			break;
		// End:0x3F8
		case "LOGIN_FAIL_BANNEDACCOUNT":
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_Banned", "R6Menu"), 14);
			// End:0x500
			break;
		// End:0x451
		case "LOGIN_FAIL_BLOCKEDACCOUNT":
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_Blocked", "R6Menu"), 14);
			// End:0x500
			break;
		// End:0x4A8
		case "LOGIN_FAIL_LOCKEDACCOUNT":
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_Locked", "R6Menu"), 14);
			// End:0x500
			break;
		// End:0x4FA
		case "LOGIN_FAIL_DEFAULT":
			DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_Default", "R6Menu"), 14);
			// End:0x500
			break;
		// End:0xFFFF
		default:
			// End:0x500
			break;
			break;
	}
	return;
}

function PopUpBoxCreate()
{
	local R6WindowUbiLoginClient pR6LoginClientTemp;
	local R6WindowWrappedTextArea pTextZone;
	local float fX, fY, fWidth, fHeight, fTextHeight;

	super.PopUpBoxCreate();
	fTextHeight = 30.0000000;
	fX = 160.0000000;
	fY = 140.0000000;
	fWidth = 300.0000000;
	fHeight = 118.0000000;
	m_pR6UbiAccount = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pR6UbiAccount.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_UbiComUser", "R6Menu"), fTextHeight, fX, fY, fWidth, fHeight);
	m_pR6UbiAccount.CreateClientWindow(Root.MenuClassDefines.ClassUbiLoginClient);
	m_pR6UbiAccount.m_ePopUpID = 13;
	pR6LoginClientTemp = R6WindowUbiLoginClient(m_pR6UbiAccount.m_ClientArea);
	pR6LoginClientTemp.SetupClientWindow(fWidth);
	pR6LoginClientTemp.m_pPassword.SetValue(m_GameService.m_szSavedPwd);
	pR6LoginClientTemp.m_pUserName.SetValue(m_GameService.m_szUserID);
	pR6LoginClientTemp.m_pSavePassword.SetButtonBox(m_GameService.m_bSavePWSave);
	pR6LoginClientTemp.m_pAutoLogIn.SetButtonBox(m_GameService.m_bAutoLISave);
	pR6LoginClientTemp.m_pAutoLogIn.bDisabled = __NFUN_129__(pR6LoginClientTemp.m_pSavePassword.m_bSelected);
	m_pR6UbiAccount.HideWindow();
	fTextHeight = 30.0000000;
	fX = 205.0000000;
	fY = 170.0000000;
	fWidth = 230.0000000;
	fHeight = 77.0000000;
	m_pDisconnected = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pDisconnected.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_Error_Title", "R6Menu"), fTextHeight, fX, fY, fWidth, fHeight);
	m_pDisconnected.CreateClientWindow(Class'R6Window.R6WindowWrappedTextArea');
	m_pDisconnected.m_ePopUpID = 15;
	pTextZone = R6WindowWrappedTextArea(m_pDisconnected.m_ClientArea);
	pTextZone.SetScrollable(true);
	pTextZone.m_fXOffSet = 5.0000000;
	pTextZone.m_fYOffSet = 5.0000000;
	pTextZone.AddText(Localize("MultiPlayer", "PopUp_Reconnect", "R6Menu"), Root.Colors.BlueLight, Root.Fonts[6]);
	pTextZone.m_bDrawBorders = false;
	m_pDisconnected.HideWindow();
	return;
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	local R6WindowUbiLoginClient pUbiLoginClient;

	// End:0x244
	if(__NFUN_154__(int(Result), int(3)))
	{
		switch(_ePopUpID)
		{
			// End:0x1A9
			case 13:
				pUbiLoginClient = R6WindowUbiLoginClient(m_pR6UbiAccount.m_ClientArea);
				m_GameService.SetUbiAccount(pUbiLoginClient.m_pUserName.GetValue(), pUbiLoginClient.m_pPassword.GetValue());
				m_GameService.m_bUbiAccntInfoEntered = true;
				// End:0xC0
				if(pUbiLoginClient.m_pSavePassword.m_bSelected)
				{
					m_GameService.m_szSavedPwd = m_GameService.m_szPassword;					
				}
				else
				{
					m_GameService.m_szSavedPwd = "";
				}
				m_GameService.m_bSavePWSave = pUbiLoginClient.m_pSavePassword.m_bSelected;
				m_GameService.m_bAutoLISave = pUbiLoginClient.m_pAutoLogIn.m_bSelected;
				// End:0x158
				if(__NFUN_129__(m_GameService.__NFUN_3531__()))
				{
					m_szInitError = "INITIALIZEMSCLIENT";
					m_GameService.__NFUN_3502__();
				}
				m_pR6UbiAccount.ShowWindow();
				// End:0x19E
				if(__NFUN_130__(__NFUN_123__(m_szInitError, ""), __NFUN_123__(m_szInitError, "INITIALIZEMSCLIENT")))
				{
					ProcessGSMsg(m_szInitError);
				}
				m_szInitError = "";
				// End:0x241
				break;
			// End:0x1B1
			case 14:
				// End:0x241
				break;
			// End:0x23E
			case 15:
				// End:0x1ED
				if(__NFUN_129__(m_GameService.__NFUN_3531__()))
				{
					m_szInitError = "INITIALIZEMSCLIENT";
					m_GameService.__NFUN_3502__();
				}
				m_pDisconnected.ShowWindow();
				// End:0x233
				if(__NFUN_130__(__NFUN_123__(m_szInitError, ""), __NFUN_123__(m_szInitError, "INITIALIZEMSCLIENT")))
				{
					ProcessGSMsg(m_szInitError);
				}
				m_szInitError = "";
				// End:0x241
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		// End:0x299
		if(__NFUN_154__(int(Result), int(4)))
		{
			switch(_ePopUpID)
			{
				// End:0x272
				case 14:
					m_pError.HideWindow();
					// End:0x299
					break;
				// End:0x277
				case 13:
				// End:0x296
				case 15:
					HideWindow();
					m_pSendMessageDest.SendMessage(1);
					// End:0x299
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		else
		{
		}
		return;
	}
}

function ShowWindow()
{
	bAlwaysAcceptsFocus = true;
	super(UWindowWindow).ShowWindow();
	return;
}

function HideWindow()
{
	Root.UnRegisterMsgWindow();
	bAlwaysAcceptsFocus = false;
	super(UWindowWindow).HideWindow();
	return;
}

