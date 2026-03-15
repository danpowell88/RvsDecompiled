//=============================================================================
// R6WindowMPManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowMPManager.uc : Manage all the windows to be display when you join a game/create a server/valid CD-Key
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/05/12 * Created by Yannick Joly
//=============================================================================
class R6WindowMPManager extends UWindowWindow;

const k_CharsForSwitchToWrapped = 30;

// NEW IN 1.60
var bool bShowLog;
var R6WindowPopUpBox m_pError;  // Error pop-up
var R6WindowPopUpBox m_pLongError;  // Wrapped Error Pop-Up (for long messages)
var R6WindowPopUpBox m_pPassword;  // Pop up to select a password
var R6WindowEditBox m_pPasswordEditBox;
var PreJoinResponseInfo m_preJoinRespInfo;  // Server info

function PopUpBoxCreate()
{
	local float fX, fY, fWidth, fHeight, fTextHeight;

	local R6WindowTextLabel pR6TextLabelTemp;
	local R6WindowWrappedTextArea pR6WrapLabelTemp;

	fTextHeight = 30.0000000;
	fX = 205.0000000;
	fY = 170.0000000;
	fWidth = 230.0000000;
	fHeight = 50.0000000;
	m_pError = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pError.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_Error_Title", "R6Menu"), fTextHeight, fX, fY, fWidth, fHeight, int(2));
	m_pError.CreateClientWindow(Class'R6Window.R6WindowTextLabel');
	m_pError.m_ePopUpID = 0;
	m_pError.SetPopUpResizable(true);
	pR6TextLabelTemp = R6WindowTextLabel(m_pError.m_ClientArea);
	pR6TextLabelTemp.Text = "- UNREGISTERED ERROR -";
	pR6TextLabelTemp.Align = 2;
	pR6TextLabelTemp.m_Font = Root.Fonts[6];
	pR6TextLabelTemp.TextColor = Root.Colors.BlueLight;
	pR6TextLabelTemp.m_BGTexture = none;
	pR6TextLabelTemp.m_HBorderTexture = none;
	pR6TextLabelTemp.m_VBorderTexture = none;
	pR6TextLabelTemp.m_TextDrawstyle = int(5);
	m_pError.HideWindow();
	fTextHeight = 30.0000000;
	fX = 205.0000000;
	fY = 170.0000000;
	fWidth = 230.0000000;
	fHeight = 77.0000000;
	m_pLongError = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
	m_pLongError.CreateStdPopUpWindow(Localize("MultiPlayer", "PopUp_Error_Title", "R6Menu"), fTextHeight, fX, fY, fWidth, fHeight, int(2));
	m_pLongError.CreateClientWindow(Class'R6Window.R6WindowWrappedTextArea', false, true);
	m_pLongError.m_ePopUpID = 0;
	pR6WrapLabelTemp = R6WindowWrappedTextArea(m_pLongError.m_ClientArea);
	pR6WrapLabelTemp.SetScrollable(true);
	pR6WrapLabelTemp.m_fXOffSet = 5.0000000;
	pR6WrapLabelTemp.m_fYOffSet = 5.0000000;
	pR6WrapLabelTemp.AddText("- UNREGISTERED ERROR -", Root.Colors.BlueLight, Root.Fonts[6]);
	pR6WrapLabelTemp.m_bDrawBorders = false;
	m_pLongError.HideWindow();
	return;
}

function DisplayErrorMsg(string _szErrorMsg, UWindowBase.EPopUpID _ePopUpID)
{
	local R6WindowWrappedTextArea pR6WrapLabelTemp;

	// End:0x57
	if((Len(_szErrorMsg) < 30))
	{
		m_pError.m_ePopUpID = _ePopUpID;
		R6WindowTextLabel(m_pError.m_ClientArea).SetNewText(_szErrorMsg, true);
		m_pError.ShowWindow();		
	}
	else
	{
		m_pLongError.m_ePopUpID = _ePopUpID;
		pR6WrapLabelTemp = R6WindowWrappedTextArea(m_pLongError.m_ClientArea);
		pR6WrapLabelTemp.Clear(true, true);
		pR6WrapLabelTemp.AddText(_szErrorMsg, Root.Colors.BlueLight, Root.Fonts[6]);
		m_pLongError.ShowWindow();
	}
	return;
}

//==============================================================================
// HandlePunkBusterSvrSituation -  handle the punk buster server situation  
//==============================================================================
function HandlePunkBusterSvrSituation()
{
	local bool bHandlePBSrvSituation;
	local R6GameManager pGameMgr;

	pGameMgr = R6GameManager(Class'Engine.Actor'.static.GetGameManager());
	bHandlePBSrvSituation = (m_preJoinRespInfo.bResponseRcvd || (R6Console(Root.Console).m_bStartedByGSClient && (!pGameMgr.NativeInit())));
	// End:0xD0
	if(((bHandlePBSrvSituation && (Class'Engine.Actor'.static.IsPBClientEnabled() == false)) && (m_preJoinRespInfo.iPunkBusterEnabled == 1)))
	{
		DisplayErrorMsg(Localize("MultiPlayer", "PopUp_Error_PunkBuster_Only", "R6Menu"), 25);		
	}
	else
	{
		// End:0x1F6
		if(((bHandlePBSrvSituation && (Class'Engine.Actor'.static.IsPBClientEnabled() == true)) && (m_preJoinRespInfo.iPunkBusterEnabled == 0)))
		{
			R6WindowRootWindow(Root).m_RSimplePopUp.X = 140;
			R6WindowRootWindow(Root).m_RSimplePopUp.Y = 170;
			R6WindowRootWindow(Root).m_RSimplePopUp.W = 360;
			R6WindowRootWindow(Root).m_RSimplePopUp.H = 77;
			Root.SimplePopUp(Localize("MultiPlayer", "Popup_Warning_Title", "R6Menu"), Localize("MultiPlayer", "PopUp_Warning_PunkBuster_Disabled", "R6Menu"), 26, int(1), false, self);			
		}
		else
		{
			HandleLockedServerPopUp();
		}
	}
	return;
}

function HandleLockedServerPopUp()
{
	local string _GamePassword;

	// End:0xD9
	if((m_preJoinRespInfo.bLocked && (!R6Console(Root.Console).m_bStartedByGSClient)))
	{
		m_pPassword.ShowWindow();
		// End:0xC7
		if(R6Console(Root.Console).m_bNonUbiMatchMaking)
		{
			Class'Engine.Actor'.static.NativeNonUbiMatchMakingPassword(_GamePassword);
			// End:0x90
			if((_GamePassword == ""))
			{
				m_pPasswordEditBox.SelectAll();				
			}
			else
			{
				m_pPasswordEditBox.SetValue(_GamePassword);
				m_pPassword.Result = 3;
				m_pPassword.Close();
			}			
		}
		else
		{
			m_pPasswordEditBox.SelectAll();
		}		
	}
	else
	{
		PopUpBoxDone(3, 18);
	}
	return;
}

