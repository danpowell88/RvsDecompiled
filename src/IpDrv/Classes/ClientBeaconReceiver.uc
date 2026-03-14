//=============================================================================
// ClientBeaconReceiver - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ClientBeaconReceiver: Receives LAN beacons from servers.
//=============================================================================
class ClientBeaconReceiver extends UdpBeacon
	transient
	config
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

struct BeaconInfo
{
	var IpAddr Addr;
	var float Time;
	var string Text;
//#ifdef R6CODE // added by John Bennett - April 2002
	var int iNumPlayers;
	var int iMaxPlayers;
	var string szCurrGameType;
	var string szMapName;
	var string szSvrName;
	var bool bDedicated;
	var bool bLocked;
	var string MapList[32];
	var string szGameType[32];
	var string szPlayerName[32];
	var string szPlayerTime[32];
	var int iPlayerPingTime[32];
	var int iPlayerKillCount[32];
//    var string              szGameName[32];         //Actually an array of game types
//    var FLOAT               fMapTime;
	var int iRoundsPerMap;
	var float fRndTime;
	var float fBetTime;
	var float fBombTime;
	var bool bShowNames;
	var bool bInternetServer;
	var bool bFriendlyFire;
	var bool bAutoBalTeam;
	var bool bTKPenalty;
	var bool bNewData;  // Flag indicating new data has been received
	var bool bRadar;
	var int iPort;
	var string szGameVersion;
	var int iLobbyID;
	var int iGroupID;
	var int iBeaconPort;
	var int iNumTerro;
	var bool bAIBkp;
	var bool bRotateMap;
	var bool bForceFPWpn;
	var string szModName;  // MPF
//#ifdef R6PUNKBUSTER
	var bool bPunkBuster;
};

struct PreJoinResponseInfo
{
	var bool bResponseRcvd;
	var int iLobbyID;
	var int iGroupID;
	var bool bLocked;
	var string szGameVersion;
// NEW IN 1.60
	var string szPreJoinModName;
	var bool bInternetServer;
//#ifdef R6CODE // added by John Bennett - April 2002
	var int iNumPlayers;
	var int iMaxPlayers;
	var int iPunkBusterEnabled;
};

// NEW IN 1.60
var BeaconInfo Beacons[32];
// NEW IN 1.60
var PreJoinResponseInfo PreJoinInfo;

function string GetBeaconAddress(int i)
{
	return IpAddrToString(Beacons[i].Addr);
	return;
}

function string GetBeaconText(int i)
{
	return Beacons[i].Text;
	return;
}

function BeginPlay()
{
	local IpAddr Addr;

	InitBeaconProduct();
	// End:0x4E
	if(__NFUN_151__(BindPort(BeaconPort, true, LocalIpAddress), 0))
	{
		__NFUN_280__(1.0000000, true);
		__NFUN_231__("ClientBeaconReceiver initialized.");		
	}
	else
	{
		__NFUN_231__("ClientBeaconReceiver failed: Beacon port in use.");
	}
	Addr.Addr = BroadcastAddr;
	Addr.Port = ServerBeaconPort;
	BroadcastBeacon(Addr);
	return;
}

function Destroyed()
{
	__NFUN_231__("ClientBeaconReceiver finished.");
	return;
}

function Timer()
{
	local int i, j;

	i = 0;
	J0x07:

	// End:0x7D [Loop If]
	if(__NFUN_150__(i, 32))
	{
		// End:0x73
		if(__NFUN_130__(__NFUN_155__(Beacons[i].Addr.Addr, 0), __NFUN_176__(__NFUN_175__(Level.TimeSeconds, Beacons[i].Time), BeaconTimeout)))
		{
			Beacons[__NFUN_165__(j)] = Beacons[i];
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	j = j;
	J0x88:

	// End:0xB5 [Loop If]
	if(__NFUN_150__(j, 32))
	{
		Beacons[j].Addr.Addr = 0;
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0x88;
	}
	return;
}

function BroadcastBeacon(IpAddr Addr)
{
	local int i;
	local IpAddr lAddr;

	i = 0;
	J0x07:

	// End:0x62 [Loop If]
	if(__NFUN_150__(i, __NFUN_1221__()))
	{
		lAddr.Addr = Addr.Addr;
		lAddr.Port = __NFUN_146__(Addr.Port, i);
		SendText(lAddr, "REPORT");
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function bool PreJoinQuery(string szIP, int iBeaconPort)
{
	local IpAddr Addr;

	PreJoinInfo.bResponseRcvd = false;
	PreJoinInfo.iLobbyID = 0;
	PreJoinInfo.iGroupID = 0;
	PreJoinInfo.szGameVersion = "";
	// End:0x5D
	if(__NFUN_155__(__NFUN_126__(szIP, ":"), -1))
	{
		szIP = __NFUN_128__(szIP, __NFUN_126__(szIP, ":"));
	}
	// End:0x74
	if(__NFUN_129__(StringToIpAddr(szIP, Addr)))
	{
		return false;
	}
	// End:0x86
	if(__NFUN_154__(Addr.Addr, 0))
	{
		return false;
	}
	// End:0xA4
	if(__NFUN_155__(iBeaconPort, 0))
	{
		Addr.Port = iBeaconPort;		
	}
	else
	{
		Addr.Port = ServerBeaconPort;
	}
	SendText(Addr, "PREJOIN");
	return true;
	return;
}

event ReceivedText(IpAddr Addr, string Text)
{
	local int i, N, pos;
	local string szSecondWord, szThirdWord, szRemainingText, szOneKWMessage, szPreJoinString;

	local bool bBooleanValue;
	local string szStringValue;

	N = __NFUN_125__(BeaconProduct);
	// End:0x59D
	if(__NFUN_124__(__NFUN_128__(Text, __NFUN_146__(N, 1)), __NFUN_112__(BeaconProduct, " ")))
	{
		szSecondWord = __NFUN_127__(Text, __NFUN_146__(N, 1));
		Addr.Port = int(szSecondWord);
		szThirdWord = __NFUN_127__(szSecondWord, __NFUN_146__(__NFUN_126__(szSecondWord, " "), 1));
		N = __NFUN_125__(KeyWordMarker);
		// End:0x277
		if(__NFUN_124__(__NFUN_128__(szThirdWord, __NFUN_146__(N, 1)), __NFUN_112__(KeyWordMarker, " ")))
		{
			i = 0;
			J0x9E:

			// End:0x101 [Loop If]
			if(__NFUN_150__(i, 32))
			{
				// End:0xF7
				if(__NFUN_130__(__NFUN_154__(Beacons[i].Addr.Addr, Addr.Addr), __NFUN_154__(Beacons[i].Addr.Port, Addr.Port)))
				{
					// [Explicit Break]
					goto J0x101;
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x9E;
			}
			J0x101:

			// End:0x148
			if(__NFUN_154__(i, 32))
			{
				i = 0;
				J0x114:

				// End:0x148 [Loop If]
				if(__NFUN_150__(i, 32))
				{
					// End:0x13E
					if(__NFUN_154__(Beacons[i].Addr.Addr, 0))
					{
						// [Explicit Break]
						goto J0x148;
					}
					__NFUN_165__(i);
					// [Loop Continue]
					goto J0x114;
				}
			}
			J0x148:

			// End:0x156
			if(__NFUN_154__(i, 32))
			{
				return;
			}
			pos = __NFUN_126__(szThirdWord, ModNameMarker);
			// End:0x1F5
			if(__NFUN_155__(pos, -1))
			{
				szStringValue = __NFUN_127__(szThirdWord, __NFUN_146__(__NFUN_146__(pos, __NFUN_125__(ModNameMarker)), 1));
				pos = __NFUN_126__(szStringValue, "¶");
				// End:0x1F5
				if(__NFUN_155__(pos, -1))
				{
					szStringValue = __NFUN_128__(szStringValue, __NFUN_147__(pos, 1));
					// End:0x1F5
					if(__NFUN_129__(__NFUN_124__(Class'Engine.Actor'.static.__NFUN_1524__().m_pCurrentMod.m_szKeyWord, szStringValue)))
					{
						return;
					}
				}
			}
			Beacons[i].Addr = Addr;
			Beacons[i].Time = Level.TimeSeconds;
			Beacons[i].Text = __NFUN_127__(Text, __NFUN_146__(__NFUN_126__(Text, " "), 1));
			Beacons[i].bNewData = true;
			DecodeKeyWordString(i, szThirdWord);
			return;			
		}
		else
		{
			// End:0x59D
			if(__NFUN_124__(__NFUN_128__(szThirdWord, __NFUN_146__(__NFUN_125__(PreJoinQueryMarker), 1)), __NFUN_112__(PreJoinQueryMarker, " ")))
			{
				pos = __NFUN_126__(__NFUN_127__(szThirdWord, 1), "¶");
				// End:0x2CB
				if(__NFUN_155__(pos, -1))
				{
					szPreJoinString = __NFUN_127__(szThirdWord, pos);
				}
				PreJoinInfo.bResponseRcvd = true;
				PreJoinInfo.iLobbyID = 0;
				PreJoinInfo.iGroupID = 0;
				J0x2F0:

				// End:0x59D [Loop If]
				if(__NFUN_151__(pos, 0))
				{
					pos = __NFUN_126__(__NFUN_127__(szPreJoinString, 1), "¶");
					// End:0x34F
					if(__NFUN_155__(pos, -1))
					{
						__NFUN_161__(pos, 1);
						szOneKWMessage = __NFUN_128__(szPreJoinString, __NFUN_147__(pos, 1));
						szPreJoinString = __NFUN_127__(szPreJoinString, pos);						
					}
					else
					{
						szOneKWMessage = szPreJoinString;
					}
					// End:0x396
					if(__NFUN_124__(__NFUN_128__(szOneKWMessage, __NFUN_125__(LobbyServerIDMarker)), LobbyServerIDMarker))
					{
						PreJoinInfo.iLobbyID = int(__NFUN_127__(szOneKWMessage, __NFUN_146__(__NFUN_126__(szOneKWMessage, " "), 1)));						
					}
					else
					{
						// End:0x3D2
						if(__NFUN_124__(__NFUN_128__(szOneKWMessage, __NFUN_125__(GroupIDMarker)), GroupIDMarker))
						{
							PreJoinInfo.iGroupID = int(__NFUN_127__(szOneKWMessage, __NFUN_146__(__NFUN_126__(szOneKWMessage, " "), 1)));							
						}
						else
						{
							// End:0x41E
							if(__NFUN_124__(__NFUN_128__(szOneKWMessage, __NFUN_125__(LockedMarker)), LockedMarker))
							{
								bBooleanValue = bool(int(__NFUN_127__(szOneKWMessage, __NFUN_146__(__NFUN_126__(szOneKWMessage, " "), 1))));
								PreJoinInfo.bLocked = bBooleanValue;								
							}
							else
							{
								// End:0x463
								if(__NFUN_124__(__NFUN_128__(szOneKWMessage, __NFUN_125__(GameVersionMarker)), GameVersionMarker))
								{
									szStringValue = __NFUN_127__(szOneKWMessage, __NFUN_146__(__NFUN_126__(szOneKWMessage, " "), 1));
									PreJoinInfo.szGameVersion = szStringValue;									
								}
								else
								{
									// End:0x4AF
									if(__NFUN_124__(__NFUN_128__(szOneKWMessage, __NFUN_125__(InternetServerMarker)), InternetServerMarker))
									{
										bBooleanValue = bool(int(__NFUN_127__(szOneKWMessage, __NFUN_146__(__NFUN_126__(szOneKWMessage, " "), 1))));
										PreJoinInfo.bInternetServer = bBooleanValue;										
									}
									else
									{
										// End:0x4EB
										if(__NFUN_124__(__NFUN_128__(szOneKWMessage, __NFUN_125__(NumPlayersMarker)), NumPlayersMarker))
										{
											PreJoinInfo.iNumPlayers = int(__NFUN_127__(szOneKWMessage, __NFUN_146__(__NFUN_126__(szOneKWMessage, " "), 1)));											
										}
										else
										{
											// End:0x527
											if(__NFUN_124__(__NFUN_128__(szOneKWMessage, __NFUN_125__(MaxPlayersMarker)), MaxPlayersMarker))
											{
												PreJoinInfo.iMaxPlayers = int(__NFUN_127__(szOneKWMessage, __NFUN_146__(__NFUN_126__(szOneKWMessage, " "), 1)));												
											}
											else
											{
												// End:0x563
												if(__NFUN_124__(__NFUN_128__(szOneKWMessage, __NFUN_125__(PunkBusterMarker)), PunkBusterMarker))
												{
													PreJoinInfo.iPunkBusterEnabled = int(__NFUN_127__(szOneKWMessage, __NFUN_146__(__NFUN_126__(szOneKWMessage, " "), 1)));													
												}
												else
												{
													// End:0x59A
													if(__NFUN_124__(__NFUN_128__(szOneKWMessage, __NFUN_125__(ModNameMarker)), ModNameMarker))
													{
														PreJoinInfo.szPreJoinModName = __NFUN_127__(szOneKWMessage, __NFUN_146__(__NFUN_126__(szOneKWMessage, " "), 1));
													}
												}
											}
										}
									}
								}
							}
						}
					}
					// [Loop Continue]
					goto J0x2F0;
				}
			}
		}
	}
	return;
}

//=========================================================================
// Get functions.  The script compiler would not let me access the Beacon 
// member variable from another class because it was too big.  Instead
// I set up these get functions and a ClearBeacon function to clear values 
// in the Beacon array.
//=========================================================================
function int GetBeaconListSize()
{
	return 32;
	return;
}

function int GetBeaconIntAddress(int i)
{
	return Beacons[i].Addr.Addr;
	return;
}

function int GetMaxPlayers(int i)
{
	return Beacons[i].iMaxPlayers;
	return;
}

function int GetPortNumber(int i)
{
	return Beacons[i].iPort;
	return;
}

function int GetNumPlayers(int i)
{
	return Beacons[i].iNumPlayers;
	return;
}

function string GetFirstMapName(int i)
{
	return Beacons[i].szMapName;
	return;
}

function string GetSvrName(int i)
{
	return Beacons[i].szSvrName;
	return;
}

// MPF
function string GetModName(int i)
{
	return Beacons[i].szModName;
	return;
}

function bool GetLocked(int i)
{
	return Beacons[i].bLocked;
	return;
}

function bool GetDedicated(int i)
{
	return Beacons[i].bDedicated;
	return;
}

function float GetRoundsPerMap(int i)
{
	return float(Beacons[i].iRoundsPerMap);
	return;
}

function float GetRoundTime(int i)
{
	return Beacons[i].fRndTime;
	return;
}

function float GetBetTime(int i)
{
	return Beacons[i].fBetTime;
	return;
}

function float GetBombTime(int i)
{
	return Beacons[i].fBombTime;
	return;
}

function int GetMapListSize(int i)
{
	local int j;

	j = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(j, 32))
	{
		// End:0x33
		if(__NFUN_122__(Beacons[i].MapList[j], ""))
		{
			// [Explicit Break]
			goto J0x3D;
		}
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0x07;
	}
	J0x3D:

	return j;
	return;
}

function string GetOneMapName(int iBeacon, int i)
{
	return Beacons[iBeacon].MapList[i];
	return;
}

function int GetPlayerListSize(int i)
{
	local int j;

	j = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(j, 32))
	{
		// End:0x33
		if(__NFUN_122__(Beacons[i].szPlayerName[j], ""))
		{
			// [Explicit Break]
			goto J0x3D;
		}
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0x07;
	}
	J0x3D:

	return j;
	return;
}

function string GetPlayerName(int iBeacon, int i)
{
	return Beacons[iBeacon].szPlayerName[i];
	return;
}

function string GetPlayerTime(int iBeacon, int i)
{
	return Beacons[iBeacon].szPlayerTime[i];
	return;
}

function int GetPlayerPingTime(int iBeacon, int i)
{
	return Beacons[iBeacon].iPlayerPingTime[i];
	return;
}

function int GetPlayerKillCount(int iBeacon, int i)
{
	return Beacons[iBeacon].iPlayerKillCount[i];
	return;
}

//function string GetGameName( INT iBeacon, INT i )
//{
//	return Beacons[iBeacon].szGameName[i];
//}
function string GetGameType(int iBeacon, int i)
{
	return Beacons[iBeacon].szGameType[i];
	return;
}

function bool GetShowEnemyNames(int i)
{
	return Beacons[i].bShowNames;
	return;
}

function bool GetInternetServer(int i)
{
	return Beacons[i].bInternetServer;
	return;
}

function bool GetFriendlyFire(int i)
{
	return Beacons[i].bFriendlyFire;
	return;
}

function bool GetAutoBalanceTeam(int i)
{
	return Beacons[i].bAutoBalTeam;
	return;
}

function bool GetTKPenalty(int i)
{
	return Beacons[i].bTKPenalty;
	return;
}

function bool GetRadar(int i)
{
	return Beacons[i].bRadar;
	return;
}

function string GetCurrGameType(int i)
{
	return Beacons[i].szCurrGameType;
	return;
}

function bool GetNewDataFlag(int i)
{
	return Beacons[i].bNewData;
	return;
}

function string GetServerGameVersion(int i)
{
	return Beacons[i].szGameVersion;
	return;
}

function SetNewDataFlag(int i, bool bNewData)
{
	Beacons[i].bNewData = bNewData;
	return;
}

function int GetLobbyID(int i)
{
	return Beacons[i].iLobbyID;
	return;
}

function int GetGroupID(int i)
{
	return Beacons[i].iGroupID;
	return;
}

function int GetBeaconPort(int i)
{
	return Beacons[i].iBeaconPort;
	return;
}

function int GetNumTerrorists(int i)
{
	return Beacons[i].iNumTerro;
	return;
}

function bool GetAIBackup(int i)
{
	return Beacons[i].bAIBkp;
	return;
}

function bool GetRotateMap(int i)
{
	return Beacons[i].bRotateMap;
	return;
}

function bool GetForceFirstPersonWeapon(int i)
{
	return Beacons[i].bForceFPWpn;
	return;
}

//#ifdef R6PUNKBUSTER
function bool GetPunkBusterEnabled(int i)
{
	return Beacons[i].bPunkBuster;
	return;
}

//-------------------------------------------------------------------------------
// This functio will clear all the information in the beacon
//-------------------------------------------------------------------------------
function ClearBeacon(int i)
{
	local int j;

	Beacons[i].Addr.Addr = 0;
	Beacons[i].iNumPlayers = 0;
	Beacons[i].iMaxPlayers = 0;
	Beacons[i].szMapName = "";
	Beacons[i].szCurrGameType = "RGM_AllMode";
	Beacons[i].szSvrName = "";
	Beacons[i].bDedicated = false;
	Beacons[i].bLocked = false;
	j = 0;
	J0xAC:

	// End:0xDB [Loop If]
	if(__NFUN_150__(j, 32))
	{
		Beacons[i].MapList[j] = "";
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0xAC;
	}
	j = 0;
	J0xE2:

	// End:0x111 [Loop If]
	if(__NFUN_150__(j, 32))
	{
		Beacons[i].szPlayerName[j] = "";
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0xE2;
	}
	j = 0;
	J0x118:

	// End:0x147 [Loop If]
	if(__NFUN_150__(j, 32))
	{
		Beacons[i].szPlayerTime[j] = "";
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0x118;
	}
	Beacons[i].iRoundsPerMap = 0;
	Beacons[i].fRndTime = 0.0000000;
	Beacons[i].fBetTime = 0.0000000;
	Beacons[i].fBombTime = 0.0000000;
	Beacons[i].bShowNames = false;
	Beacons[i].bInternetServer = false;
	Beacons[i].bFriendlyFire = false;
	Beacons[i].bAutoBalTeam = false;
	Beacons[i].bTKPenalty = false;
	Beacons[i].bRadar = false;
	Beacons[i].iPort = 0;
	Beacons[i].szGameVersion = "";
	Beacons[i].iLobbyID = 0;
	Beacons[i].iGroupID = 0;
	Beacons[i].szModName = "";
	Beacons[i].bPunkBuster = false;
	return;
}

function RefreshServers()
{
	local IpAddr Addr;
	local int i;

	i = 0;
	J0x07:

	// End:0x34 [Loop If]
	if(__NFUN_150__(i, 32))
	{
		Beacons[i].Addr.Addr = 0;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	Addr.Addr = BroadcastAddr;
	Addr.Port = ServerBeaconPort;
	BroadcastBeacon(Addr);
	return;
}

//
// Grab the next option from a string.
//
function bool GrabOption(out string Options, out string Result)
{
	// End:0x8A
	if(__NFUN_122__(__NFUN_128__(Options, 1), "¶"))
	{
		Result = __NFUN_127__(Options, 1);
		// End:0x45
		if(__NFUN_153__(__NFUN_126__(Result, "¶"), 0))
		{
			Result = __NFUN_128__(Result, __NFUN_126__(Result, "¶"));
		}
		Options = __NFUN_127__(Options, 1);
		// End:0x7D
		if(__NFUN_153__(__NFUN_126__(Options, "¶"), 0))
		{
			Options = __NFUN_127__(Options, __NFUN_126__(Options, "¶"));			
		}
		else
		{
			Options = "";
		}
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

//
// Break up a key=value pair into its key and value.
//
function GetKeyValue(string Pair, out string Key, out string Value)
{
	// End:0x44
	if(__NFUN_153__(__NFUN_126__(Pair, "="), 0))
	{
		Key = __NFUN_128__(Pair, __NFUN_126__(Pair, "="));
		Value = __NFUN_127__(Pair, __NFUN_146__(__NFUN_126__(Pair, "="), 1));		
	}
	else
	{
		Key = Pair;
		Value = "";
	}
	return;
}

function string ParseOption(string Options, string InKey)
{
	local string Pair, Key, Value;

	J0x00:
	// End:0x40 [Loop If]
	if(GrabOption(Options, Pair))
	{
		GetKeyValue(Pair, Key, Value);
		// End:0x3D
		if(__NFUN_124__(Key, InKey))
		{
			return Value;
		}
		// [Loop Continue]
		goto J0x00;
	}
	return "";
	return;
}

//=========================================================================
// DecodeKeyWordString - Go through the keyword string and extract
// key word pairs (keyword and associated value).  Call DecodeKeyWordPair
// to decode each pair.
//=========================================================================
function DecodeKeyWordString(int iBeaconIdx, string szKewWordString)
{
	local int pos, counter, i;
	local string szOneKWMessage;

	pos = __NFUN_126__(szKewWordString, "¶");
	// End:0x31
	if(__NFUN_155__(pos, -1))
	{
		szKewWordString = __NFUN_127__(szKewWordString, pos);
	}
	counter = 0;
	J0x38:

	// End:0xDD [Loop If]
	if(__NFUN_130__(__NFUN_151__(pos, 0), __NFUN_150__(counter, 255)))
	{
		__NFUN_165__(counter);
		pos = __NFUN_126__(__NFUN_127__(szKewWordString, 1), "¶");
		// End:0xAC
		if(__NFUN_155__(pos, -1))
		{
			__NFUN_161__(pos, 1);
			szOneKWMessage = __NFUN_128__(szKewWordString, __NFUN_147__(pos, 1));
			szKewWordString = __NFUN_127__(szKewWordString, pos);			
		}
		else
		{
			szOneKWMessage = szKewWordString;
		}
		DecodeKeyWordPair(szOneKWMessage, iBeaconIdx);
		Beacons[iBeaconIdx].bNewData = true;
		// [Loop Continue]
		goto J0x38;
	}
	return;
}

//=========================================================================
// DecodeKeyWordPair - Given a string containing a keyword pair (keyword 
// and associated value) determine which keyword is used, and extract
// the associated value.  Place results in the Beacons array.
//=========================================================================
function DecodeKeyWordPair(string szKeyWord, int iIndex)
{
	local int iIntegerValue;
	local bool bBooleanValue;
	local string szStringValue, szOptionName;
	local int j, N, pos;
	local string InOpt, LeftOpt;

	// End:0x4A
	if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(GamePortMarker)), GamePortMarker))
	{
		iIntegerValue = int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1)));
		Beacons[iIndex].iPort = iIntegerValue;
	}
	// End:0x97
	if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(NumPlayersMarker)), NumPlayersMarker))
	{
		iIntegerValue = int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1)));
		Beacons[iIndex].iNumPlayers = iIntegerValue;		
	}
	else
	{
		// End:0xE4
		if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(MaxPlayersMarker)), MaxPlayersMarker))
		{
			iIntegerValue = int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1)));
			Beacons[iIndex].iMaxPlayers = iIntegerValue;			
		}
		else
		{
			// End:0x12F
			if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(MapNameMarker)), MapNameMarker))
			{
				szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
				Beacons[iIndex].szMapName = szStringValue;				
			}
			else
			{
				// End:0x17A
				if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(SvrNameMarker)), SvrNameMarker))
				{
					szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
					Beacons[iIndex].szSvrName = szStringValue;					
				}
				else
				{
					// End:0x1C5
					if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(GameTypeMarker)), GameTypeMarker))
					{
						szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
						Beacons[iIndex].szCurrGameType = szStringValue;						
					}
					else
					{
						// End:0x217
						if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(DecicatedMarker)), DecicatedMarker))
						{
							bBooleanValue = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
							Beacons[iIndex].bDedicated = bBooleanValue;							
						}
						else
						{
							// End:0x269
							if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(LockedMarker)), LockedMarker))
							{
								bBooleanValue = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
								Beacons[iIndex].bLocked = bBooleanValue;								
							}
							else
							{
								// End:0x374
								if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(MapListMarker)), MapListMarker))
								{
									szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
									j = 0;
									J0x2A2:

									// End:0x2D1 [Loop If]
									if(__NFUN_150__(j, 32))
									{
										Beacons[iIndex].MapList[j] = "";
										__NFUN_165__(j);
										// [Loop Continue]
										goto J0x2A2;
									}
									j = 0;
									J0x2D8:

									// End:0x371 [Loop If]
									if(__NFUN_155__(__NFUN_126__(szStringValue, "/"), -1))
									{
										szStringValue = __NFUN_127__(szStringValue, __NFUN_146__(__NFUN_126__(szStringValue, "/"), 1));
										pos = __NFUN_126__(szStringValue, "/");
										// End:0x34B
										if(__NFUN_155__(pos, -1))
										{
											Beacons[iIndex].MapList[j] = __NFUN_128__(szStringValue, pos);
											// [Explicit Continue]
											goto J0x367;
										}
										Beacons[iIndex].MapList[j] = szStringValue;
										J0x367:

										__NFUN_165__(j);
										// [Loop Continue]
										goto J0x2D8;
									}									
								}
								else
								{
									// End:0x48A
									if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(MenuGmNameMarker)), MenuGmNameMarker))
									{
										szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
										j = 0;
										J0x3AD:

										// End:0x3E7 [Loop If]
										if(__NFUN_150__(j, 32))
										{
											Beacons[iIndex].szGameType[j] = "RGM_AllMode";
											__NFUN_165__(j);
											// [Loop Continue]
											goto J0x3AD;
										}
										j = 0;
										J0x3EE:

										// End:0x487 [Loop If]
										if(__NFUN_155__(__NFUN_126__(szStringValue, "/"), -1))
										{
											szStringValue = __NFUN_127__(szStringValue, __NFUN_146__(__NFUN_126__(szStringValue, "/"), 1));
											pos = __NFUN_126__(szStringValue, "/");
											// End:0x461
											if(__NFUN_155__(pos, -1))
											{
												Beacons[iIndex].szGameType[j] = __NFUN_128__(szStringValue, pos);
												// [Explicit Continue]
												goto J0x47D;
											}
											Beacons[iIndex].szGameType[j] = szStringValue;
											J0x47D:

											__NFUN_165__(j);
											// [Loop Continue]
											goto J0x3EE;
										}										
									}
									else
									{
										// End:0x595
										if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(PlayerListMarker)), PlayerListMarker))
										{
											szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
											j = 0;
											J0x4C3:

											// End:0x4F2 [Loop If]
											if(__NFUN_150__(j, 32))
											{
												Beacons[iIndex].szPlayerName[j] = "";
												__NFUN_165__(j);
												// [Loop Continue]
												goto J0x4C3;
											}
											j = 0;
											J0x4F9:

											// End:0x592 [Loop If]
											if(__NFUN_155__(__NFUN_126__(szStringValue, "/"), -1))
											{
												szStringValue = __NFUN_127__(szStringValue, __NFUN_146__(__NFUN_126__(szStringValue, "/"), 1));
												pos = __NFUN_126__(szStringValue, "/");
												// End:0x56C
												if(__NFUN_155__(pos, -1))
												{
													Beacons[iIndex].szPlayerName[j] = __NFUN_128__(szStringValue, pos);
													// [Explicit Continue]
													goto J0x588;
												}
												Beacons[iIndex].szPlayerName[j] = szStringValue;
												J0x588:

												__NFUN_165__(j);
												// [Loop Continue]
												goto J0x4F9;
											}											
										}
										else
										{
											// End:0x6A0
											if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(PlayerTimeMarker)), PlayerTimeMarker))
											{
												szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
												j = 0;
												J0x5CE:

												// End:0x5FD [Loop If]
												if(__NFUN_150__(j, 32))
												{
													Beacons[iIndex].szPlayerTime[j] = "";
													__NFUN_165__(j);
													// [Loop Continue]
													goto J0x5CE;
												}
												j = 0;
												J0x604:

												// End:0x69D [Loop If]
												if(__NFUN_155__(__NFUN_126__(szStringValue, "/"), -1))
												{
													szStringValue = __NFUN_127__(szStringValue, __NFUN_146__(__NFUN_126__(szStringValue, "/"), 1));
													pos = __NFUN_126__(szStringValue, "/");
													// End:0x677
													if(__NFUN_155__(pos, -1))
													{
														Beacons[iIndex].szPlayerTime[j] = __NFUN_128__(szStringValue, pos);
														// [Explicit Continue]
														goto J0x693;
													}
													Beacons[iIndex].szPlayerTime[j] = szStringValue;
													J0x693:

													__NFUN_165__(j);
													// [Loop Continue]
													goto J0x604;
												}												
											}
											else
											{
												// End:0x7AE
												if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(PlayerPingMarker)), PlayerPingMarker))
												{
													szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
													j = 0;
													J0x6D9:

													// End:0x707 [Loop If]
													if(__NFUN_150__(j, 32))
													{
														Beacons[iIndex].iPlayerPingTime[j] = 0;
														__NFUN_165__(j);
														// [Loop Continue]
														goto J0x6D9;
													}
													j = 0;
													J0x70E:

													// End:0x7AB [Loop If]
													if(__NFUN_155__(__NFUN_126__(szStringValue, "/"), -1))
													{
														szStringValue = __NFUN_127__(szStringValue, __NFUN_146__(__NFUN_126__(szStringValue, "/"), 1));
														pos = __NFUN_126__(szStringValue, "/");
														// End:0x783
														if(__NFUN_155__(pos, -1))
														{
															Beacons[iIndex].iPlayerPingTime[j] = int(__NFUN_128__(szStringValue, pos));
															// [Explicit Continue]
															goto J0x7A1;
														}
														Beacons[iIndex].iPlayerPingTime[j] = int(szStringValue);
														J0x7A1:

														__NFUN_165__(j);
														// [Loop Continue]
														goto J0x70E;
													}													
												}
												else
												{
													// End:0x8BC
													if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(PlayerKillMarker)), PlayerKillMarker))
													{
														szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
														j = 0;
														J0x7E7:

														// End:0x815 [Loop If]
														if(__NFUN_150__(j, 32))
														{
															Beacons[iIndex].iPlayerKillCount[j] = 0;
															__NFUN_165__(j);
															// [Loop Continue]
															goto J0x7E7;
														}
														j = 0;
														J0x81C:

														// End:0x8B9 [Loop If]
														if(__NFUN_155__(__NFUN_126__(szStringValue, "/"), -1))
														{
															szStringValue = __NFUN_127__(szStringValue, __NFUN_146__(__NFUN_126__(szStringValue, "/"), 1));
															pos = __NFUN_126__(szStringValue, "/");
															// End:0x891
															if(__NFUN_155__(pos, -1))
															{
																Beacons[iIndex].iPlayerKillCount[j] = int(__NFUN_128__(szStringValue, pos));
																// [Explicit Continue]
																goto J0x8AF;
															}
															Beacons[iIndex].iPlayerKillCount[j] = int(szStringValue);
															J0x8AF:

															__NFUN_165__(j);
															// [Loop Continue]
															goto J0x81C;
														}														
													}
													else
													{
														// End:0x90B
														if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(RoundsPerMatchMarker)), RoundsPerMatchMarker))
														{
															iIntegerValue = int(float(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
															Beacons[iIndex].iRoundsPerMap = iIntegerValue;															
														}
														else
														{
															// End:0x95C
															if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(RoundTimeMarker)), RoundTimeMarker))
															{
																iIntegerValue = int(float(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
																Beacons[iIndex].fRndTime = float(iIntegerValue);																
															}
															else
															{
																// End:0x9AD
																if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(BetTimeMarker)), BetTimeMarker))
																{
																	iIntegerValue = int(float(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
																	Beacons[iIndex].fBetTime = float(iIntegerValue);																	
																}
																else
																{
																	// End:0x9FE
																	if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(BombTimeMarker)), BombTimeMarker))
																	{
																		iIntegerValue = int(float(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
																		Beacons[iIndex].fBombTime = float(iIntegerValue);																		
																	}
																	else
																	{
																		// End:0xA50
																		if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(ShowNamesMarker)), ShowNamesMarker))
																		{
																			bBooleanValue = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
																			Beacons[iIndex].bShowNames = bBooleanValue;																			
																		}
																		else
																		{
																			// End:0xAA2
																			if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(InternetServerMarker)), InternetServerMarker))
																			{
																				bBooleanValue = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
																				Beacons[iIndex].bInternetServer = bBooleanValue;																				
																			}
																			else
																			{
																				// End:0xAF4
																				if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(FriendlyFireMarker)), FriendlyFireMarker))
																				{
																					bBooleanValue = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
																					Beacons[iIndex].bFriendlyFire = bBooleanValue;																					
																				}
																				else
																				{
																					// End:0xB46
																					if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(AutoBalTeamMarker)), AutoBalTeamMarker))
																					{
																						bBooleanValue = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
																						Beacons[iIndex].bAutoBalTeam = bBooleanValue;																						
																					}
																					else
																					{
																						// End:0xB98
																						if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(TKPenaltyMarker)), TKPenaltyMarker))
																						{
																							bBooleanValue = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
																							Beacons[iIndex].bTKPenalty = bBooleanValue;																							
																						}
																						else
																						{
																							// End:0xBEA
																							if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(AllowRadarMarker)), AllowRadarMarker))
																							{
																								bBooleanValue = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
																								Beacons[iIndex].bRadar = bBooleanValue;																								
																							}
																							else
																							{
																								// End:0xC35
																								if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(GameVersionMarker)), GameVersionMarker))
																								{
																									szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
																									Beacons[iIndex].szGameVersion = szStringValue;																									
																								}
																								else
																								{
																									// End:0xC77
																									if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(LobbyServerIDMarker)), LobbyServerIDMarker))
																									{
																										Beacons[iIndex].iLobbyID = int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1)));																										
																									}
																									else
																									{
																										// End:0xCB9
																										if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(GroupIDMarker)), GroupIDMarker))
																										{
																											Beacons[iIndex].iGroupID = int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1)));																											
																										}
																										else
																										{
																											// End:0xCFB
																											if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(BeaconPortMarker)), BeaconPortMarker))
																											{
																												Beacons[iIndex].iBeaconPort = int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1)));																												
																											}
																											else
																											{
																												// End:0xD3D
																												if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(NumTerroMarker)), NumTerroMarker))
																												{
																													Beacons[iIndex].iNumTerro = int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1)));																													
																												}
																												else
																												{
																													// End:0xD82
																													if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(AIBkpMarker)), AIBkpMarker))
																													{
																														Beacons[iIndex].bAIBkp = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));																														
																													}
																													else
																													{
																														// End:0xDC7
																														if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(RotateMapMarker)), RotateMapMarker))
																														{
																															Beacons[iIndex].bRotateMap = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));																															
																														}
																														else
																														{
																															// End:0xE0C
																															if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(ForceFPWpnMarker)), ForceFPWpnMarker))
																															{
																																Beacons[iIndex].bForceFPWpn = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));																																
																															}
																															else
																															{
																																// End:0xE57
																																if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(ModNameMarker)), ModNameMarker))
																																{
																																	szStringValue = __NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1));
																																	Beacons[iIndex].szModName = szStringValue;																																	
																																}
																																else
																																{
																																	// End:0xE99
																																	if(__NFUN_124__(__NFUN_128__(szKeyWord, __NFUN_125__(PunkBusterMarker)), PunkBusterMarker))
																																	{
																																		Beacons[iIndex].bPunkBuster = bool(int(__NFUN_127__(szKeyWord, __NFUN_146__(__NFUN_126__(szKeyWord, " "), 1))));
																																	}
																																}
																															}
																														}
																													}
																												}
																											}
																										}
																									}
																								}
																							}
																						}
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var BeaconInfo
// REMOVED IN 1.60: var PreJoinResponseInfo
