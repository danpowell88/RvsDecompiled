//=============================================================================
// UdpBeacon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UdpBeacon: Base class of beacon sender and receiver.
//=============================================================================
class UdpBeacon extends UdpLink
    transient
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var() globalconfig int ServerBeaconPort;  // Listen port
var() globalconfig int BeaconPort;  // Reply port
var int UdpServerQueryPort;
var int boundport;
var() globalconfig bool DoBeacon;
var() globalconfig float BeaconTimeout;
var() globalconfig string BeaconProduct;
//#ifdef R6CODE // added by John Bennett - April 2002
var string KeyWordMarker;
var string PreJoinQueryMarker;
var string MaxPlayersMarker;
var string NumPlayersMarker;
var string MapNameMarker;
var string GameTypeMarker;
var string LockedMarker;
var string DecicatedMarker;
var string SvrNameMarker;
var string MenuGmNameMarker;
var string MapListMarker;
var string PlayerListMarker;
var string OptionsListMarker;
var string PlayerTimeMarker;
var string PlayerPingMarker;
var string PlayerKillMarker;
var string GamePortMarker;
//var                string     MapTimeMarker;
var string RoundsPerMatchMarker;
var string RoundTimeMarker;
var string BetTimeMarker;
var string BombTimeMarker;
var string ShowNamesMarker;
var string InternetServerMarker;
var string FriendlyFireMarker;
var string AutoBalTeamMarker;
var string TKPenaltyMarker;
var string AllowRadarMarker;
var string GameVersionMarker;
var string LobbyServerIDMarker;
var string GroupIDMarker;
var string BeaconPortMarker;
var string NumTerroMarker;
var string AIBkpMarker;
var string RotateMapMarker;
var string ForceFPWpnMarker;
var string ModNameMarker;  // MPF
//#ifdef R6PUNKBUSTER
var string PunkBusterMarker;
var string LocalIpAddress;

function BeginPlay()
{
	local IpAddr Addr;

	SetServerBeacon(self);
	Level.Game.SetUdpBeacon(self);
	boundport = BindPort(ServerBeaconPort, true, LocalIpAddress);
	// End:0x65
	if((boundport == 0))
	{
		Log("UdpBeacon failed to bind a port.");
		return;
	}
	Addr.Addr = BroadcastAddr;
	Addr.Port = BeaconPort;
	SetTimer(10.0000000, true);
	InitBeaconProduct();
	return;
}

function BroadcastBeacon(IpAddr Addr)
{
	local string textData;

	textData = BuildBeaconText();
	SendText(Addr, ((BeaconProduct @ Mid(Level.GetAddressURL(), (InStr(Level.GetAddressURL(), ":") + 1))) @ textData));
	return;
}

function BroadcastBeaconQuery(IpAddr Addr)
{
	SendText(Addr, (BeaconProduct @ string(UdpServerQueryPort)));
	return;
}

event ReceivedText(IpAddr Addr, string Text)
{
	local R6ServerInfo pServerOptions;
	local bool bServerResistered;

	pServerOptions = Class'Engine.Actor'.static.GetServerOptions();
	// End:0x2F
	if((Text == "REPORT"))
	{
		BroadcastBeacon(Addr);
	}
	// End:0x51
	if((Text == "REPORTQUERY"))
	{
		BroadcastBeaconQuery(Addr);
	}
	// End:0xE0
	if((Text == "PREJOIN"))
	{
		bServerResistered = ((Level.Game.GameReplicationInfo.m_iGameSvrLobbyID != 0) && (Level.Game.GameReplicationInfo.m_iGameSvrGroupID != 0));
		// End:0xE0
		if(((!pServerOptions.InternetServer) || bServerResistered))
		{
			RespondPreJoinQuery(Addr);
		}
	}
	return;
}

function InitBeaconProduct()
{
	BeaconProduct = "rvnshld";
	return;
}

//===============================================================================
// RespondPreJoinQuery: Used to send some data from server to client before
// the client joins a server, intended for a client that is joining using
// the join IP button.
//===============================================================================
function RespondPreJoinQuery(IpAddr Addr)
{
	local string textData;
	local int integerData;
	local R6ServerInfo pServerOptions;
	local PlayerController aPC;
	local int iNumPlayers;

	pServerOptions = Class'Engine.Actor'.static.GetServerOptions();
	textData = PreJoinQueryMarker;
	textData = ((((textData $ " ") $ LobbyServerIDMarker) $ " ") $ string(Level.Game.GameReplicationInfo.m_iGameSvrLobbyID));
	textData = ((((textData $ " ") $ GroupIDMarker) $ " ") $ string(Level.Game.GameReplicationInfo.m_iGameSvrGroupID));
	// End:0xCB
	if(Level.Game.AccessControl.GamePasswordNeeded())
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ LockedMarker) $ " ") $ string(integerData));
	textData = ((((textData $ " ") $ GameVersionMarker) $ " ") $ Level.GetGameVersion(false, (!Class'Engine.Actor'.static.GetModMgr().IsRavenShield())));
	// End:0x156
	if(pServerOptions.InternetServer)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ InternetServerMarker) $ " ") $ string(integerData));
	textData = ((((textData $ " ") $ ModNameMarker) $ " ") $ Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord);
	// End:0x1F0
	if(Level.m_bPBSvRunning)
	{
		textData = (((textData $ " ") $ PunkBusterMarker) $ " 1");		
	}
	else
	{
		textData = (((textData $ " ") $ PunkBusterMarker) $ " 0");
	}
	textData = ((((textData $ " ") $ MaxPlayersMarker) $ " ") $ string(Level.Game.MaxPlayers));
	iNumPlayers = 0;
	// End:0x263
	foreach DynamicActors(Class'Engine.PlayerController', aPC)
	{
		(iNumPlayers++);		
	}	
	textData = ((((textData $ " ") $ NumPlayersMarker) $ " ") $ string(iNumPlayers));
	SendText(Addr, ((BeaconProduct @ Mid(Level.GetAddressURL(), (InStr(Level.GetAddressURL(), ":") + 1))) @ textData));
	return;
}

function Destroyed()
{
	Level.Game.SetUdpBeacon(none);
	super(Actor).Destroyed();
	return;
}

//===============================================================================
// BuildBeaconText: Build a string which contains all the game data
// that will be sent to a client.
//===============================================================================
function string BuildBeaconText()
{
	local string textData;
	local int integerData;
	local string MapListType;
	local MapList myList;
	local Class<MapList> ML;
	local int iCounter;
	local PlayerController aPC;
	local int iNumPlayers;
	local string szIPAddr;
	local float fPlayingTime[32];
	local int iPingTimeMS[32], iKillCount;
	local Controller _Controller;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.GetServerOptions();
	textData = (KeyWordMarker $ " ");
	textData = ((((textData $ " ") $ GamePortMarker) $ " ") $ Mid(Level.GetAddressURL(), (InStr(Level.GetAddressURL(), ":") + 1)));
	// End:0xC2
	if((InStr(Level.Game.GetURLMap(), ".") == -1))
	{
		textData = ((((textData $ " ") $ MapNameMarker) $ " ") $ Level.Game.GetURLMap());		
	}
	else
	{
		textData = ((((textData $ " ") $ MapNameMarker) $ " ") $ Left(Level.Game.GetURLMap(), InStr(Level.Game.GetURLMap(), ".")));
	}
	textData = ((((textData $ " ") $ SvrNameMarker) $ " ") $ Level.Game.GameReplicationInfo.ServerName);
	textData = ((((textData $ " ") $ GameTypeMarker) $ " ") $ Level.Game.m_szCurrGameType);
	textData = ((((textData $ " ") $ MaxPlayersMarker) $ " ") $ string(Level.Game.MaxPlayers));
	// End:0x1E9
	if(Level.Game.AccessControl.GamePasswordNeeded())
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ LockedMarker) $ " ") $ string(integerData));
	// End:0x238
	if((int(Level.NetMode) == int(NM_DedicatedServer)))
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ DecicatedMarker) $ " ") $ string(integerData));
	textData = (((textData $ " ") $ PlayerListMarker) $ " ");
	CheckForPlayerTimeouts();
	iNumPlayers = 0;
	_Controller = Level.ControllerList;
	J0x2A1:

	// End:0x3DE [Loop If]
	if((_Controller != none))
	{
		aPC = PlayerController(_Controller);
		// End:0x3C7
		if((aPC != none))
		{
			textData = ((textData $ "/") $ aPC.PlayerReplicationInfo.PlayerName);
			// End:0x337
			if((NetConnection(aPC.Player) == none))
			{
				szIPAddr = WindowConsole(aPC.Player.Console).szStoreIP;				
			}
			else
			{
				szIPAddr = aPC.GetPlayerNetworkAddress();
			}
			szIPAddr = Left(szIPAddr, InStr(szIPAddr, ":"));
			iPingTimeMS[iNumPlayers] = aPC.PlayerReplicationInfo.Ping;
			iKillCount[iNumPlayers] = aPC.PlayerReplicationInfo.m_iKillCount;
			fPlayingTime[iNumPlayers] = GetPlayingTime(szIPAddr);
			(iNumPlayers++);
		}
		_Controller = _Controller.nextController;
		// [Loop Continue]
		goto J0x2A1;
	}
	textData = (((textData $ " ") $ PlayerTimeMarker) $ " ");
	iCounter = 0;
	J0x401:

	// End:0x43F [Loop If]
	if((iCounter < iNumPlayers))
	{
		textData = ((textData $ "/") $ DisplayTime(int(fPlayingTime[iCounter])));
		(iCounter++);
		// [Loop Continue]
		goto J0x401;
	}
	textData = (((textData $ " ") $ PlayerPingMarker) $ " ");
	iCounter = 0;
	J0x462:

	// End:0x49A [Loop If]
	if((iCounter < iNumPlayers))
	{
		textData = ((textData $ "/") $ string(iPingTimeMS[iCounter]));
		(iCounter++);
		// [Loop Continue]
		goto J0x462;
	}
	textData = (((textData $ " ") $ PlayerKillMarker) $ " ");
	iCounter = 0;
	J0x4BD:

	// End:0x4F5 [Loop If]
	if((iCounter < iNumPlayers))
	{
		textData = ((textData $ "/") $ string(iKillCount[iCounter]));
		(iCounter++);
		// [Loop Continue]
		goto J0x4BD;
	}
	textData = ((((textData $ " ") $ NumPlayersMarker) $ " ") $ string(iNumPlayers));
	textData = ((((textData $ " ") $ RoundsPerMatchMarker) $ " ") $ string(pServerOptions.RoundsPerMatch));
	textData = ((((textData $ " ") $ RoundTimeMarker) $ " ") $ string(pServerOptions.RoundTime));
	textData = ((((textData $ " ") $ BetTimeMarker) $ " ") $ string(pServerOptions.BetweenRoundTime));
	// End:0x5EA
	if((pServerOptions.BombTime > -1))
	{
		textData = ((((textData $ " ") $ BombTimeMarker) $ " ") $ string(pServerOptions.BombTime));
	}
	// End:0x606
	if(pServerOptions.ShowNames)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ ShowNamesMarker) $ " ") $ string(integerData));
	// End:0x64E
	if(pServerOptions.InternetServer)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ InternetServerMarker) $ " ") $ string(integerData));
	// End:0x696
	if(pServerOptions.FriendlyFire)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ FriendlyFireMarker) $ " ") $ string(integerData));
	// End:0x6DE
	if(pServerOptions.Autobalance)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ AutoBalTeamMarker) $ " ") $ string(integerData));
	// End:0x726
	if(pServerOptions.TeamKillerPenalty)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ TKPenaltyMarker) $ " ") $ string(integerData));
	textData = ((((textData $ " ") $ GameVersionMarker) $ " ") $ Level.GetGameVersion(false, (!Class'Engine.Actor'.static.GetModMgr().IsRavenShield())));
	// End:0x7B1
	if(pServerOptions.AllowRadar)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ AllowRadarMarker) $ " ") $ string(integerData));
	textData = ((((textData $ " ") $ LobbyServerIDMarker) $ " ") $ string(Level.Game.GameReplicationInfo.m_iGameSvrLobbyID));
	textData = ((((textData $ " ") $ GroupIDMarker) $ " ") $ string(Level.Game.GameReplicationInfo.m_iGameSvrGroupID));
	textData = ((((textData $ " ") $ BeaconPortMarker) $ " ") $ string(boundport));
	textData = ((((textData $ " ") $ NumTerroMarker) $ " ") $ string(pServerOptions.NbTerro));
	// End:0x8CC
	if(pServerOptions.AIBkp)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ AIBkpMarker) $ " ") $ string(integerData));
	// End:0x914
	if(pServerOptions.RotateMap)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ RotateMapMarker) $ " ") $ string(integerData));
	// End:0x95C
	if(pServerOptions.ForceFPersonWeapon)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = ((((textData $ " ") $ ForceFPWpnMarker) $ " ") $ string(integerData));
	textData = ((((textData $ " ") $ ModNameMarker) $ " ") $ Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord);
	// End:0x9F6
	if(Level.m_bPBSvRunning)
	{
		textData = (((textData $ " ") $ PunkBusterMarker) $ " 1");		
	}
	else
	{
		textData = (((textData $ " ") $ PunkBusterMarker) $ " 0");
	}
	MapListType = "Engine.R6MapList";
	ML = Class<MapList>(DynamicLoadObject(MapListType, Class'Core.Class'));
	myList = Spawn(ML);
	textData = (((textData $ " ") $ MapListMarker) $ " ");
	iCounter = 0;
	J0xA77:

	// End:0xB35 [Loop If]
	if((iCounter < 32))
	{
		// End:0xB2B
		if((myList.Maps[iCounter] != ""))
		{
			// End:0xAEA
			if((InStr(myList.Maps[iCounter], ".") == -1))
			{
				textData = ((textData $ "/") $ myList.Maps[iCounter]);
				// [Explicit Continue]
				goto J0xB2B;
			}
			textData = ((textData $ "/") $ Left(myList.Maps[iCounter], InStr(myList.Maps[iCounter], ".")));
		}
		J0xB2B:

		(iCounter++);
		// [Loop Continue]
		goto J0xA77;
	}
	textData = (((textData $ " ") $ MenuGmNameMarker) $ " ");
	iCounter = 0;
	J0xB58:

	// End:0xBA8 [Loop If]
	if((iCounter < 32))
	{
		textData = ((textData $ "/") $ Level.GetGameTypeFromClassName(R6MapList(myList).GameType[iCounter]));
		(iCounter++);
		// [Loop Continue]
		goto J0xB58;
	}
	myList.Destroy();
	return textData;
	return;
}

function Timer()
{
	local Controller aPC;

	// End:0xD0
	if(((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer))))
	{
		aPC = Level.ControllerList;
		J0x48:

		// End:0xD0 [Loop If]
		if((aPC != none))
		{
			// End:0xB9
			if(((PlayerController(aPC) != none) && (PlayerController(aPC).m_szIpAddr != "")))
			{
				SetPlayingTime(PlayerController(aPC).m_szIpAddr, PlayerController(aPC).m_fLoginTime, Level.TimeSeconds);
			}
			aPC = aPC.nextController;
			// [Loop Continue]
			goto J0x48;
		}
	}
	return;
}

//===============================================================================
// DisplayTime: display the time in min (have to be in sec)
//===============================================================================
function string DisplayTime(int _iTimeToConvert)
{
	local float fTemp;
	local int iMin, iSec, ITemp;
	local string szTemp, szTime;

	iMin = 0;
	iSec = _iTimeToConvert;
	// End:0x54
	if((_iTimeToConvert >= 60))
	{
		fTemp = (float(_iTimeToConvert) / float(60));
		iMin = int(fTemp);
		iSec = (_iTimeToConvert - (iMin * 60));
	}
	// End:0x7F
	if((iSec < 10))
	{
		szTime = ((string(iMin) $ ":0") $ string(iSec));		
	}
	else
	{
		szTemp = string(iSec);
		szTemp = Left(szTemp, 2);
		szTime = ((string(iMin) $ ":") $ szTemp);
	}
	return szTime;
	return;
}

defaultproperties
{
	ServerBeaconPort=8777
	BeaconPort=9777
	DoBeacon=true
	BeaconTimeout=10.0000000
	BeaconProduct="unreal"
	KeyWordMarker="KEYWORD"
	PreJoinQueryMarker="PREJOINQUERY"
	MaxPlayersMarker="¶A1"
	NumPlayersMarker="¶B1"
	MapNameMarker="¶E1"
	GameTypeMarker="¶F1"
	LockedMarker="¶G1"
	DecicatedMarker="¶H1"
	SvrNameMarker="¶I1"
	MenuGmNameMarker="¶J1"
	MapListMarker="¶K1"
	PlayerListMarker="¶L1"
	OptionsListMarker="¶C2"
	PlayerTimeMarker="¶M1"
	PlayerPingMarker="¶N1"
	PlayerKillMarker="¶O1"
	GamePortMarker="¶P1"
	RoundsPerMatchMarker="¶Q1"
	RoundTimeMarker="¶R1"
	BetTimeMarker="¶S1"
	BombTimeMarker="¶T1"
	ShowNamesMarker="¶W1"
	InternetServerMarker="¶X1"
	FriendlyFireMarker="¶Y1"
	AutoBalTeamMarker="¶Z1"
	TKPenaltyMarker="¶A2"
	AllowRadarMarker="¶B2"
	GameVersionMarker="¶D2"
	LobbyServerIDMarker="¶E2"
	GroupIDMarker="¶F2"
	BeaconPortMarker="¶G2"
	NumTerroMarker="¶H2"
	AIBkpMarker="¶I2"
	RotateMapMarker="¶J2"
	ForceFPWpnMarker="¶K2"
	ModNameMarker="¶L2"
	PunkBusterMarker="¶L3"
	RemoteRole=0
}
