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

	__NFUN_1311__(self);
	Level.Game.SetUdpBeacon(self);
	boundport = BindPort(ServerBeaconPort, true, LocalIpAddress);
	// End:0x65
	if(__NFUN_154__(boundport, 0))
	{
		__NFUN_231__("UdpBeacon failed to bind a port.");
		return;
	}
	Addr.Addr = BroadcastAddr;
	Addr.Port = BeaconPort;
	__NFUN_280__(10.0000000, true);
	InitBeaconProduct();
	return;
}

function BroadcastBeacon(IpAddr Addr)
{
	local string textData;

	textData = BuildBeaconText();
	SendText(Addr, __NFUN_168__(__NFUN_168__(BeaconProduct, __NFUN_127__(Level.GetAddressURL(), __NFUN_146__(__NFUN_126__(Level.GetAddressURL(), ":"), 1))), textData));
	return;
}

function BroadcastBeaconQuery(IpAddr Addr)
{
	SendText(Addr, __NFUN_168__(BeaconProduct, string(UdpServerQueryPort)));
	return;
}

event ReceivedText(IpAddr Addr, string Text)
{
	local R6ServerInfo pServerOptions;
	local bool bServerResistered;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	// End:0x2F
	if(__NFUN_122__(Text, "REPORT"))
	{
		BroadcastBeacon(Addr);
	}
	// End:0x51
	if(__NFUN_122__(Text, "REPORTQUERY"))
	{
		BroadcastBeaconQuery(Addr);
	}
	// End:0xE0
	if(__NFUN_122__(Text, "PREJOIN"))
	{
		bServerResistered = __NFUN_130__(__NFUN_155__(Level.Game.GameReplicationInfo.m_iGameSvrLobbyID, 0), __NFUN_155__(Level.Game.GameReplicationInfo.m_iGameSvrGroupID, 0));
		// End:0xE0
		if(__NFUN_132__(__NFUN_129__(pServerOptions.InternetServer), bServerResistered))
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

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	textData = PreJoinQueryMarker;
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), LobbyServerIDMarker), " "), string(Level.Game.GameReplicationInfo.m_iGameSvrLobbyID));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), GroupIDMarker), " "), string(Level.Game.GameReplicationInfo.m_iGameSvrGroupID));
	// End:0xCB
	if(Level.Game.AccessControl.GamePasswordNeeded())
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), LockedMarker), " "), string(integerData));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), GameVersionMarker), " "), Level.__NFUN_1419__(false, __NFUN_129__(Class'Engine.Actor'.static.__NFUN_1524__().IsRavenShield())));
	// End:0x156
	if(pServerOptions.InternetServer)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), InternetServerMarker), " "), string(integerData));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), ModNameMarker), " "), Class'Engine.Actor'.static.__NFUN_1524__().m_pCurrentMod.m_szKeyWord);
	// End:0x1F0
	if(Level.m_bPBSvRunning)
	{
		textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), PunkBusterMarker), " 1");		
	}
	else
	{
		textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), PunkBusterMarker), " 0");
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), MaxPlayersMarker), " "), string(Level.Game.MaxPlayers));
	iNumPlayers = 0;
	// End:0x263
	foreach __NFUN_313__(Class'Engine.PlayerController', aPC)
	{
		__NFUN_165__(iNumPlayers);		
	}	
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), NumPlayersMarker), " "), string(iNumPlayers));
	SendText(Addr, __NFUN_168__(__NFUN_168__(BeaconProduct, __NFUN_127__(Level.GetAddressURL(), __NFUN_146__(__NFUN_126__(Level.GetAddressURL(), ":"), 1))), textData));
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

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	textData = __NFUN_112__(KeyWordMarker, " ");
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), GamePortMarker), " "), __NFUN_127__(Level.GetAddressURL(), __NFUN_146__(__NFUN_126__(Level.GetAddressURL(), ":"), 1)));
	// End:0xC2
	if(__NFUN_154__(__NFUN_126__(Level.Game.__NFUN_547__(), "."), -1))
	{
		textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), MapNameMarker), " "), Level.Game.__NFUN_547__());		
	}
	else
	{
		textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), MapNameMarker), " "), __NFUN_128__(Level.Game.__NFUN_547__(), __NFUN_126__(Level.Game.__NFUN_547__(), ".")));
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), SvrNameMarker), " "), Level.Game.GameReplicationInfo.ServerName);
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), GameTypeMarker), " "), Level.Game.m_szCurrGameType);
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), MaxPlayersMarker), " "), string(Level.Game.MaxPlayers));
	// End:0x1E9
	if(Level.Game.AccessControl.GamePasswordNeeded())
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), LockedMarker), " "), string(integerData));
	// End:0x238
	if(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)))
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), DecicatedMarker), " "), string(integerData));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), PlayerListMarker), " ");
	CheckForPlayerTimeouts();
	iNumPlayers = 0;
	_Controller = Level.ControllerList;
	J0x2A1:

	// End:0x3DE [Loop If]
	if(__NFUN_119__(_Controller, none))
	{
		aPC = PlayerController(_Controller);
		// End:0x3C7
		if(__NFUN_119__(aPC, none))
		{
			textData = __NFUN_112__(__NFUN_112__(textData, "/"), aPC.PlayerReplicationInfo.PlayerName);
			// End:0x337
			if(__NFUN_114__(NetConnection(aPC.Player), none))
			{
				szIPAddr = WindowConsole(aPC.Player.Console).szStoreIP;				
			}
			else
			{
				szIPAddr = aPC.GetPlayerNetworkAddress();
			}
			szIPAddr = __NFUN_128__(szIPAddr, __NFUN_126__(szIPAddr, ":"));
			iPingTimeMS[iNumPlayers] = aPC.PlayerReplicationInfo.Ping;
			iKillCount[iNumPlayers] = aPC.PlayerReplicationInfo.m_iKillCount;
			fPlayingTime[iNumPlayers] = GetPlayingTime(szIPAddr);
			__NFUN_165__(iNumPlayers);
		}
		_Controller = _Controller.nextController;
		// [Loop Continue]
		goto J0x2A1;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), PlayerTimeMarker), " ");
	iCounter = 0;
	J0x401:

	// End:0x43F [Loop If]
	if(__NFUN_150__(iCounter, iNumPlayers))
	{
		textData = __NFUN_112__(__NFUN_112__(textData, "/"), DisplayTime(int(fPlayingTime[iCounter])));
		__NFUN_165__(iCounter);
		// [Loop Continue]
		goto J0x401;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), PlayerPingMarker), " ");
	iCounter = 0;
	J0x462:

	// End:0x49A [Loop If]
	if(__NFUN_150__(iCounter, iNumPlayers))
	{
		textData = __NFUN_112__(__NFUN_112__(textData, "/"), string(iPingTimeMS[iCounter]));
		__NFUN_165__(iCounter);
		// [Loop Continue]
		goto J0x462;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), PlayerKillMarker), " ");
	iCounter = 0;
	J0x4BD:

	// End:0x4F5 [Loop If]
	if(__NFUN_150__(iCounter, iNumPlayers))
	{
		textData = __NFUN_112__(__NFUN_112__(textData, "/"), string(iKillCount[iCounter]));
		__NFUN_165__(iCounter);
		// [Loop Continue]
		goto J0x4BD;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), NumPlayersMarker), " "), string(iNumPlayers));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), RoundsPerMatchMarker), " "), string(pServerOptions.RoundsPerMatch));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), RoundTimeMarker), " "), string(pServerOptions.RoundTime));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), BetTimeMarker), " "), string(pServerOptions.BetweenRoundTime));
	// End:0x5EA
	if(__NFUN_151__(pServerOptions.BombTime, -1))
	{
		textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), BombTimeMarker), " "), string(pServerOptions.BombTime));
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
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), ShowNamesMarker), " "), string(integerData));
	// End:0x64E
	if(pServerOptions.InternetServer)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), InternetServerMarker), " "), string(integerData));
	// End:0x696
	if(pServerOptions.FriendlyFire)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), FriendlyFireMarker), " "), string(integerData));
	// End:0x6DE
	if(pServerOptions.Autobalance)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), AutoBalTeamMarker), " "), string(integerData));
	// End:0x726
	if(pServerOptions.TeamKillerPenalty)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), TKPenaltyMarker), " "), string(integerData));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), GameVersionMarker), " "), Level.__NFUN_1419__(false, __NFUN_129__(Class'Engine.Actor'.static.__NFUN_1524__().IsRavenShield())));
	// End:0x7B1
	if(pServerOptions.AllowRadar)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), AllowRadarMarker), " "), string(integerData));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), LobbyServerIDMarker), " "), string(Level.Game.GameReplicationInfo.m_iGameSvrLobbyID));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), GroupIDMarker), " "), string(Level.Game.GameReplicationInfo.m_iGameSvrGroupID));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), BeaconPortMarker), " "), string(boundport));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), NumTerroMarker), " "), string(pServerOptions.NbTerro));
	// End:0x8CC
	if(pServerOptions.AIBkp)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), AIBkpMarker), " "), string(integerData));
	// End:0x914
	if(pServerOptions.RotateMap)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), RotateMapMarker), " "), string(integerData));
	// End:0x95C
	if(pServerOptions.ForceFPersonWeapon)
	{
		integerData = 1;		
	}
	else
	{
		integerData = 0;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), ForceFPWpnMarker), " "), string(integerData));
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), ModNameMarker), " "), Class'Engine.Actor'.static.__NFUN_1524__().m_pCurrentMod.m_szKeyWord);
	// End:0x9F6
	if(Level.m_bPBSvRunning)
	{
		textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), PunkBusterMarker), " 1");		
	}
	else
	{
		textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), PunkBusterMarker), " 0");
	}
	MapListType = "Engine.R6MapList";
	ML = Class<MapList>(DynamicLoadObject(MapListType, Class'Core.Class'));
	myList = __NFUN_278__(ML);
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), MapListMarker), " ");
	iCounter = 0;
	J0xA77:

	// End:0xB35 [Loop If]
	if(__NFUN_150__(iCounter, 32))
	{
		// End:0xB2B
		if(__NFUN_123__(myList.Maps[iCounter], ""))
		{
			// End:0xAEA
			if(__NFUN_154__(__NFUN_126__(myList.Maps[iCounter], "."), -1))
			{
				textData = __NFUN_112__(__NFUN_112__(textData, "/"), myList.Maps[iCounter]);
				// [Explicit Continue]
				goto J0xB2B;
			}
			textData = __NFUN_112__(__NFUN_112__(textData, "/"), __NFUN_128__(myList.Maps[iCounter], __NFUN_126__(myList.Maps[iCounter], ".")));
		}
		J0xB2B:

		__NFUN_165__(iCounter);
		// [Loop Continue]
		goto J0xA77;
	}
	textData = __NFUN_112__(__NFUN_112__(__NFUN_112__(textData, " "), MenuGmNameMarker), " ");
	iCounter = 0;
	J0xB58:

	// End:0xBA8 [Loop If]
	if(__NFUN_150__(iCounter, 32))
	{
		textData = __NFUN_112__(__NFUN_112__(textData, "/"), Level.GetGameTypeFromClassName(R6MapList(myList).GameType[iCounter]));
		__NFUN_165__(iCounter);
		// [Loop Continue]
		goto J0xB58;
	}
	myList.__NFUN_279__();
	return textData;
	return;
}

function Timer()
{
	local Controller aPC;

	// End:0xD0
	if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_154__(int(Level.NetMode), int(NM_ListenServer))))
	{
		aPC = Level.ControllerList;
		J0x48:

		// End:0xD0 [Loop If]
		if(__NFUN_119__(aPC, none))
		{
			// End:0xB9
			if(__NFUN_130__(__NFUN_119__(PlayerController(aPC), none), __NFUN_123__(PlayerController(aPC).m_szIpAddr, "")))
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
	if(__NFUN_153__(_iTimeToConvert, 60))
	{
		fTemp = __NFUN_172__(float(_iTimeToConvert), float(60));
		iMin = int(fTemp);
		iSec = __NFUN_147__(_iTimeToConvert, __NFUN_144__(iMin, 60));
	}
	// End:0x7F
	if(__NFUN_150__(iSec, 10))
	{
		szTime = __NFUN_112__(__NFUN_112__(string(iMin), ":0"), string(iSec));		
	}
	else
	{
		szTemp = string(iSec);
		szTemp = __NFUN_128__(szTemp, 2);
		szTime = __NFUN_112__(__NFUN_112__(string(iMin), ":"), szTemp);
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
