//=============================================================================
// R6MenuCDKeyManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuCDKeyManager extends UWindowWindow;

var UWindowRootWindow.eGameWidgetID m_eCurrentWID;
var bool m_bPreJoinInProgress;
var bool m_bShowManagerCDKeyLog;
var R6WindowUbiCDKeyCheck m_pCDKeyCheckWindow;
var UWindowWindow m_pProcedureOwner;

function Created()
{
	m_pCDKeyCheckWindow = R6WindowUbiCDKeyCheck(CreateWindow(Root.MenuClassDefines.ClassUbiCDKeyCheck, 0.0000000, 0.0000000, 640.0000000, 480.0000000, self, true));
	m_pCDKeyCheckWindow.m_GameService = R6Console(Root.Console).m_GameService;
	m_pCDKeyCheckWindow.PopUpBoxCreate();
	m_pCDKeyCheckWindow.HideWindow();
	return;
}

function StartCDKeyProcess(optional R6WindowUbiCDKeyCheck.eJoinRoomChoice _eJoinUbiComRoom, optional PreJoinResponseInfo _preJResponseInfo)
{
	// End:0x20
	if(m_bShowManagerCDKeyLog)
	{
		__NFUN_231__("StartCDKeyProcess()");
	}
	Root.RegisterMsgWindow(m_pCDKeyCheckWindow);
	m_pCDKeyCheckWindow.m_pSendMessageDest = self;
	m_pCDKeyCheckWindow.m_eJoinRoomChoice = _eJoinUbiComRoom;
	m_pCDKeyCheckWindow.m_preJoinRespInfo = _preJResponseInfo;
	Class'Engine.Actor'.static.__NFUN_1551__().__NFUN_1288__();
	m_bPreJoinInProgress = true;
	ShowWindow();
	return;
}

function FinishCDKeyProcess()
{
	Root.UnRegisterMsgWindow();
	HideWindow();
	return;
}

function ProcessCDKeyMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
	local string _szIPAddress;

	switch(eMessage)
	{
		// End:0x0C
		case 3:
		// End:0x11A
		case 4:
			m_bPreJoinInProgress = false;
			switch(m_eCurrentWID)
			{
				// End:0x37
				case Root.19:
					LaunchServer();
					// End:0x117
					break;
				// End:0x6F
				case Root.15:
					JoinServer(R6MenuMultiPlayerWidget(m_pProcedureOwner).m_szServerIP, m_pCDKeyCheckWindow.m_szPassword);
					// End:0x117
					break;
				// End:0xB0
				case Root.20:
					JoinServer(R6MenuUbiComWidget(m_pProcedureOwner).m_szIPAddress, m_pCDKeyCheckWindow.m_GameService.m_szGSPassword);
					// End:0x117
					break;
				// End:0xEB
				case Root.22:
					Class'Engine.Actor'.static.__NFUN_1304__(_szIPAddress);
					JoinServer(_szIPAddress, m_pCDKeyCheckWindow.m_szPassword);
					// End:0x117
					break;
				// End:0xFFFF
				default:
					// End:0x114
					if(R6Console(Root.Console).m_bNonUbiMatchMakingHost)
					{
						LaunchServer();
					}
					// End:0x117
					break;
					break;
			}
			// End:0x19B
			break;
		// End:0x195
		case 5:
			m_bPreJoinInProgress = false;
			FinishCDKeyProcess();
			// End:0x160
			if(R6Console(Root.Console).m_bStartedByGSClient)
			{
				Class'Engine.Actor'.static.__NFUN_1551__().__NFUN_1290__();
			}
			// End:0x192
			if(__NFUN_242__(R6Console(Root.Console).m_bNonUbiMatchMaking, true))
			{
				Root.DoQuitGame();
			}
			// End:0x19B
			break;
		// End:0xFFFF
		default:
			// End:0x19B
			break;
			break;
	}
	return;
}

function SetWindowUser(UWindowRootWindow.eGameWidgetID _eGameWID, UWindowWindow _ProcedureOwner)
{
	m_pProcedureOwner = _ProcedureOwner;
	m_eCurrentWID = _eGameWID;
	return;
}

function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
	switch(eMessage)
	{
		// End:0x0C
		case 3:
		// End:0x11
		case 4:
		// End:0x24
		case 5:
			ProcessCDKeyMessage(eMessage);
			// End:0x65
			break;
		// End:0xFFFF
		default:
			__NFUN_231__(__NFUN_168__("WARNING CDKeyManager SendMessage not supported", string(eMessage)));
			// End:0x65
			break;
			break;
	}
	return;
}

function LaunchServer()
{
	local Console pConsole;
	local R6Console pR6Console;
	local R6MenuMPCreateGameTabOptions pMPCreateGTOpt;
	local IpAddr _localAddr;

	pConsole = Root.Console;
	pR6Console = R6Console(pConsole);
	pMPCreateGTOpt = R6MenuMPCreateGameWidget(m_pProcedureOwner).m_pCreateTabOptions;
	pMPCreateGTOpt.SetServerOptions();
	Class'Engine.Actor'.static.__NFUN_1283__();
	// End:0x110
	if(__NFUN_130__(__NFUN_130__(__NFUN_129__(pR6Console.m_bStartedByGSClient), __NFUN_129__(pR6Console.m_bNonUbiMatchMakingHost)), pMPCreateGTOpt.m_pButtonsDef.GetButtonBoxValue(int(10), R6WindowListGeneral(pMPCreateGTOpt.GetList(pMPCreateGTOpt.GetCurrentGameMode(), pMPCreateGTOpt.1)))))
	{
		pConsole.ConsoleCommand(__NFUN_112__("SERVER mod=", Class'Engine.Actor'.static.__NFUN_1524__().m_pCurrentMod.m_szKeyWord));		
	}
	else
	{
		// End:0x146
		if(__NFUN_130__(__NFUN_129__(Class'Engine.Actor'.static.__NFUN_1400__()), __NFUN_155__(GetLevel().iPBEnabled, 0)))
		{
			Class'Engine.Actor'.static.__NFUN_1401__(false, false);
		}
		Class'Engine.Actor'.static.__NFUN_1551__().__NFUN_1285__(pMPCreateGTOpt.m_SelectedMapList[0], pMPCreateGTOpt.m_SelectedModeList[0]);
		pR6Console.m_LanServers.m_ClientBeacon.GetLocalIP(_localAddr);
		pR6Console.szStoreIP = pR6Console.m_LanServers.m_ClientBeacon.IpAddrToString(_localAddr);
		pR6Console.LaunchR6MultiPlayerGame();
		GetLevel().Game.__NFUN_1281__(0);
	}
	return;
}

function JoinServer(string _szIPAddress, optional string _szPassword)
{
	local R6Console pR6Console;
	local string szOptions, szCharacterName, m_ArmorName, m_WeaponNameOne, m_WeaponGadgetNameOne, m_BulletTypeOne,
		m_WeaponNameTwo, m_WeaponGadgetNameTwo, m_BulletTypeTwo, m_GadgetNameOne, m_GadgetNameTwo,
		szAllAuthID;

	local int iPlayerSpawnNumber;

	pR6Console = R6Console(Root.Console);
	iPlayerSpawnNumber = pR6Console.GetSpawnNumber();
	szOptions = "";
	// End:0x62
	if(__NFUN_123__(_szPassword, ""))
	{
		szOptions = __NFUN_112__(__NFUN_112__(szOptions, "?Password="), _szPassword);
	}
	Root.Console.ViewportOwner.Actor.__NFUN_1232__(szCharacterName, m_ArmorName, m_WeaponNameOne, m_WeaponGadgetNameOne, m_BulletTypeOne, m_WeaponNameTwo, m_WeaponGadgetNameTwo, m_BulletTypeTwo, m_GadgetNameOne, m_GadgetNameTwo);
	ReplaceText(szCharacterName, "?", "~");
	ReplaceText(szCharacterName, ",", "~");
	ReplaceText(szCharacterName, "#", "~");
	ReplaceText(szCharacterName, "/", "~");
	szOptions = __NFUN_112__(__NFUN_112__(szOptions, "?Name="), szCharacterName);
	ReplaceText(szOptions, " ", "~");
	szOptions = __NFUN_112__(__NFUN_112__(szOptions, "?UbiUserID="), R6Console(Root.Console).m_GameService.m_szUserID);
	szOptions = __NFUN_112__(__NFUN_112__(szOptions, "?iPB="), string(Class'Engine.PlayerController'.static.__NFUN_1318__()));
	SaveGameServiceConfig();
	Class'Engine.Actor'.static.__NFUN_1551__().__NFUN_1284__(_szIPAddress, szOptions, iPlayerSpawnNumber);
	pR6Console.szStoreIP = _szIPAddress;
	pR6Console.szStoreGamePassWd = _szPassword;
	R6MenuRootWindow(Root).m_bJoinServerProcess = true;
	return;
}

function SaveGameServiceConfig()
{
	R6Console(Root.Console).m_GameService.SaveInfo();
	return;
}

defaultproperties
{
	m_bShowManagerCDKeyLog=true
}