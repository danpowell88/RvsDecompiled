//=============================================================================
// ClientBeaconReceiver - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// ClientBeaconReceiver: Receives LAN beacons from servers.
//=============================================================================
class ClientBeaconReceiver extends UdpBeacon
    transient
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

struct BeaconInfo
{
	var IpAddr Addr;  // IP address and port of the beacon sender
	var float Time;   // Level.TimeSeconds when this beacon was last received
	var string Text;  // Raw beacon text string
//#ifdef R6CODE // added by John Bennett - April 2002
	var int iNumPlayers;        // Current player count
	var int iMaxPlayers;        // Maximum allowed players
	var string szCurrGameType;  // Currently active game type
	var string szMapName;       // Name of the current map
	var string szSvrName;       // Server name displayed in the browser
	var bool bDedicated;        // True if this is a dedicated server
	var bool bLocked;           // True if the server requires a password
	var string MapList[32];     // List of maps in the server rotation
	var string szGameType[32];  // Game type for each map in the rotation
	var string szPlayerName[32];      // Names of connected players
	var string szPlayerTime[32];      // Session time for each connected player
	var int iPlayerPingTime[32];      // Ping (ms) for each connected player
	var int iPlayerKillCount[32];     // Kill count for each connected player
//    var string              szGameName[32];         //Actually an array of game types
//    var FLOAT               fMapTime;
	var int iRoundsPerMap;      // Number of rounds played per map
	var float fRndTime;         // Round duration in seconds
	var float fBetTime;         // Time between rounds in seconds
	var float fBombTime;        // Bomb timer duration in seconds
	var bool bShowNames;        // Show enemy names during gameplay
	var bool bInternetServer;   // Server is listed on the internet (not LAN-only)
	var bool bFriendlyFire;     // Friendly fire is enabled
	var bool bAutoBalTeam;      // Auto-balance teams between rounds
	var bool bTKPenalty;        // Team-kill penalty is enabled
	var bool bNewData;  // Flag indicating new data has been received
	var bool bRadar;            // Radar/minimap is enabled
	var int iPort;              // Game port number
	var string szGameVersion;   // Game version string from the server
	var int iLobbyID;           // Lobby server identifier
	var int iGroupID;           // Game group identifier
	var int iBeaconPort;        // Port used for beacon communication
	var int iNumTerro;          // Number of terrorists in the game
	var bool bAIBkp;            // AI backup bots enabled
	var bool bRotateMap;        // Map rotation enabled after each match
	var bool bForceFPWpn;       // Force first-person weapon view
	var string szModName;  // MPF
//#ifdef R6PUNKBUSTER
	var bool bPunkBuster;  // PunkBuster anti-cheat is enabled
};

struct PreJoinResponseInfo
{
	var bool bResponseRcvd;    // True once a PREJOIN response has been received
	var int iLobbyID;          // Lobby server identifier from the response
	var int iGroupID;          // Game group identifier from the response
	var bool bLocked;          // Server requires a password
	var string szGameVersion;  // Server game version
// NEW IN 1.60
	var string szPreJoinModName;  // Mod name used by the server
	var bool bInternetServer;     // Server is registered on the internet
//#ifdef R6CODE // added by John Bennett - April 2002
	var int iNumPlayers;          // Current player count on the server
	var int iMaxPlayers;          // Maximum allowed players
	var int iPunkBusterEnabled;   // Non-zero if PunkBuster is active
};

// NEW IN 1.60
var BeaconInfo Beacons[32];        // Array of beacon data for all discovered servers (up to 32)
// NEW IN 1.60
var PreJoinResponseInfo PreJoinInfo;  // Pre-join query response for the server being joined

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
	if((BindPort(BeaconPort, true, LocalIpAddress) > 0))
	{
		SetTimer(1.0000000, true);
		Log("ClientBeaconReceiver initialized.");		
	}
	else
	{
		Log("ClientBeaconReceiver failed: Beacon port in use.");
	}
	Addr.Addr = BroadcastAddr;
	Addr.Port = ServerBeaconPort;
	BroadcastBeacon(Addr);
	return;
}

function Destroyed()
{
	Log("ClientBeaconReceiver finished.");
	return;
}

function Timer()
{
	local int i, j;

	i = 0;
	J0x07:

	// End:0x7D [Loop If]
	if((i < 32))
	{
		// End:0x73
		if(((Beacons[i].Addr.Addr != 0) && ((Level.TimeSeconds - Beacons[i].Time) < BeaconTimeout)))
		{
			Beacons[(j++)] = Beacons[i];
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	j = j;
	J0x88:

	// End:0xB5 [Loop If]
	if((j < 32))
	{
		Beacons[j].Addr.Addr = 0;
		(j++);
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
	if((i < GetMaxAvailPorts()))
	{
		lAddr.Addr = Addr.Addr;
		lAddr.Port = (Addr.Port + i);
		SendText(lAddr, "REPORT");
		(i++);
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
	if((InStr(szIP, ":") != -1))
	{
		szIP = Left(szIP, InStr(szIP, ":"));
	}
	// End:0x74
	if((!StringToIpAddr(szIP, Addr)))
	{
		return false;
	}
	// End:0x86
	if((Addr.Addr == 0))
	{
		return false;
	}
	// End:0xA4
	if((iBeaconPort != 0))
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

	N = Len(BeaconProduct);
	// End:0x59D
	if((Left(Text, (N + 1)) ~= (BeaconProduct $ " ")))
	{
		szSecondWord = Mid(Text, (N + 1));
		Addr.Port = int(szSecondWord);
		szThirdWord = Mid(szSecondWord, (InStr(szSecondWord, " ") + 1));
		N = Len(KeyWordMarker);
		// End:0x277
		if((Left(szThirdWord, (N + 1)) ~= (KeyWordMarker $ " ")))
		{
			i = 0;
			J0x9E:

			// End:0x101 [Loop If]
			if((i < 32))
			{
				// End:0xF7
				if(((Beacons[i].Addr.Addr == Addr.Addr) && (Beacons[i].Addr.Port == Addr.Port)))
				{
					// [Explicit Break]
					goto J0x101;
				}
				(i++);
				// [Loop Continue]
				goto J0x9E;
			}
			J0x101:

			// End:0x148
			if((i == 32))
			{
				i = 0;
				J0x114:

				// End:0x148 [Loop If]
				if((i < 32))
				{
					// End:0x13E
					if((Beacons[i].Addr.Addr == 0))
					{
						// [Explicit Break]
						goto J0x148;
					}
					(i++);
					// [Loop Continue]
					goto J0x114;
				}
			}
			J0x148:

			// End:0x156
			if((i == 32))
			{
				return;
			}
			pos = InStr(szThirdWord, ModNameMarker);
			// End:0x1F5
			if((pos != -1))
			{
				szStringValue = Mid(szThirdWord, ((pos + Len(ModNameMarker)) + 1));
				pos = InStr(szStringValue, "¶");
				// End:0x1F5
				if((pos != -1))
				{
					szStringValue = Left(szStringValue, (pos - 1));
					// End:0x1F5
					if((!(Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord ~= szStringValue)))
					{
						return;
					}
				}
			}
			Beacons[i].Addr = Addr;
			Beacons[i].Time = Level.TimeSeconds;
			Beacons[i].Text = Mid(Text, (InStr(Text, " ") + 1));
			Beacons[i].bNewData = true;
			DecodeKeyWordString(i, szThirdWord);
			return;			
		}
		else
		{
			// End:0x59D
			if((Left(szThirdWord, (Len(PreJoinQueryMarker) + 1)) ~= (PreJoinQueryMarker $ " ")))
			{
				pos = InStr(Mid(szThirdWord, 1), "¶");
				// End:0x2CB
				if((pos != -1))
				{
					szPreJoinString = Mid(szThirdWord, pos);
				}
				PreJoinInfo.bResponseRcvd = true;
				PreJoinInfo.iLobbyID = 0;
				PreJoinInfo.iGroupID = 0;
				J0x2F0:

				// End:0x59D [Loop If]
				if((pos > 0))
				{
					pos = InStr(Mid(szPreJoinString, 1), "¶");
					// End:0x34F
					if((pos != -1))
					{
						(pos += 1);
						szOneKWMessage = Left(szPreJoinString, (pos - 1));
						szPreJoinString = Mid(szPreJoinString, pos);						
					}
					else
					{
						szOneKWMessage = szPreJoinString;
					}
					// End:0x396
					if((Left(szOneKWMessage, Len(LobbyServerIDMarker)) ~= LobbyServerIDMarker))
					{
						PreJoinInfo.iLobbyID = int(Mid(szOneKWMessage, (InStr(szOneKWMessage, " ") + 1)));						
					}
					else
					{
						// End:0x3D2
						if((Left(szOneKWMessage, Len(GroupIDMarker)) ~= GroupIDMarker))
						{
							PreJoinInfo.iGroupID = int(Mid(szOneKWMessage, (InStr(szOneKWMessage, " ") + 1)));							
						}
						else
						{
							// End:0x41E
							if((Left(szOneKWMessage, Len(LockedMarker)) ~= LockedMarker))
							{
								bBooleanValue = bool(int(Mid(szOneKWMessage, (InStr(szOneKWMessage, " ") + 1))));
								PreJoinInfo.bLocked = bBooleanValue;								
							}
							else
							{
								// End:0x463
								if((Left(szOneKWMessage, Len(GameVersionMarker)) ~= GameVersionMarker))
								{
									szStringValue = Mid(szOneKWMessage, (InStr(szOneKWMessage, " ") + 1));
									PreJoinInfo.szGameVersion = szStringValue;									
								}
								else
								{
									// End:0x4AF
									if((Left(szOneKWMessage, Len(InternetServerMarker)) ~= InternetServerMarker))
									{
										bBooleanValue = bool(int(Mid(szOneKWMessage, (InStr(szOneKWMessage, " ") + 1))));
										PreJoinInfo.bInternetServer = bBooleanValue;										
									}
									else
									{
										// End:0x4EB
										if((Left(szOneKWMessage, Len(NumPlayersMarker)) ~= NumPlayersMarker))
										{
											PreJoinInfo.iNumPlayers = int(Mid(szOneKWMessage, (InStr(szOneKWMessage, " ") + 1)));											
										}
										else
										{
											// End:0x527
											if((Left(szOneKWMessage, Len(MaxPlayersMarker)) ~= MaxPlayersMarker))
											{
												PreJoinInfo.iMaxPlayers = int(Mid(szOneKWMessage, (InStr(szOneKWMessage, " ") + 1)));												
											}
											else
											{
												// End:0x563
												if((Left(szOneKWMessage, Len(PunkBusterMarker)) ~= PunkBusterMarker))
												{
													PreJoinInfo.iPunkBusterEnabled = int(Mid(szOneKWMessage, (InStr(szOneKWMessage, " ") + 1)));													
												}
												else
												{
													// End:0x59A
													if((Left(szOneKWMessage, Len(ModNameMarker)) ~= ModNameMarker))
													{
														PreJoinInfo.szPreJoinModName = Mid(szOneKWMessage, (InStr(szOneKWMessage, " ") + 1));
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
	if((j < 32))
	{
		// End:0x33
		if((Beacons[i].MapList[j] == ""))
		{
			// [Explicit Break]
			goto J0x3D;
		}
		(j++);
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
	if((j < 32))
	{
		// End:0x33
		if((Beacons[i].szPlayerName[j] == ""))
		{
			// [Explicit Break]
			goto J0x3D;
		}
		(j++);
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
	if((j < 32))
	{
		Beacons[i].MapList[j] = "";
		(j++);
		// [Loop Continue]
		goto J0xAC;
	}
	j = 0;
	J0xE2:

	// End:0x111 [Loop If]
	if((j < 32))
	{
		Beacons[i].szPlayerName[j] = "";
		(j++);
		// [Loop Continue]
		goto J0xE2;
	}
	j = 0;
	J0x118:

	// End:0x147 [Loop If]
	if((j < 32))
	{
		Beacons[i].szPlayerTime[j] = "";
		(j++);
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
	if((i < 32))
	{
		Beacons[i].Addr.Addr = 0;
		(i++);
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
	if((Left(Options, 1) == "¶"))
	{
		Result = Mid(Options, 1);
		// End:0x45
		if((InStr(Result, "¶") >= 0))
		{
			Result = Left(Result, InStr(Result, "¶"));
		}
		Options = Mid(Options, 1);
		// End:0x7D
		if((InStr(Options, "¶") >= 0))
		{
			Options = Mid(Options, InStr(Options, "¶"));			
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
	if((InStr(Pair, "=") >= 0))
	{
		Key = Left(Pair, InStr(Pair, "="));
		Value = Mid(Pair, (InStr(Pair, "=") + 1));		
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
		if((Key ~= InKey))
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

	pos = InStr(szKewWordString, "¶");
	// End:0x31
	if((pos != -1))
	{
		szKewWordString = Mid(szKewWordString, pos);
	}
	counter = 0;
	J0x38:

	// End:0xDD [Loop If]
	if(((pos > 0) && (counter < 255)))
	{
		(counter++);
		pos = InStr(Mid(szKewWordString, 1), "¶");
		// End:0xAC
		if((pos != -1))
		{
			(pos += 1);
			szOneKWMessage = Left(szKewWordString, (pos - 1));
			szKewWordString = Mid(szKewWordString, pos);			
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
	if((Left(szKeyWord, Len(GamePortMarker)) ~= GamePortMarker))
	{
		iIntegerValue = int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1)));
		Beacons[iIndex].iPort = iIntegerValue;
	}
	// End:0x97
	if((Left(szKeyWord, Len(NumPlayersMarker)) ~= NumPlayersMarker))
	{
		iIntegerValue = int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1)));
		Beacons[iIndex].iNumPlayers = iIntegerValue;		
	}
	else
	{
		// End:0xE4
		if((Left(szKeyWord, Len(MaxPlayersMarker)) ~= MaxPlayersMarker))
		{
			iIntegerValue = int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1)));
			Beacons[iIndex].iMaxPlayers = iIntegerValue;			
		}
		else
		{
			// End:0x12F
			if((Left(szKeyWord, Len(MapNameMarker)) ~= MapNameMarker))
			{
				szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
				Beacons[iIndex].szMapName = szStringValue;				
			}
			else
			{
				// End:0x17A
				if((Left(szKeyWord, Len(SvrNameMarker)) ~= SvrNameMarker))
				{
					szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
					Beacons[iIndex].szSvrName = szStringValue;					
				}
				else
				{
					// End:0x1C5
					if((Left(szKeyWord, Len(GameTypeMarker)) ~= GameTypeMarker))
					{
						szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
						Beacons[iIndex].szCurrGameType = szStringValue;						
					}
					else
					{
						// End:0x217
						if((Left(szKeyWord, Len(DecicatedMarker)) ~= DecicatedMarker))
						{
							bBooleanValue = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
							Beacons[iIndex].bDedicated = bBooleanValue;							
						}
						else
						{
							// End:0x269
							if((Left(szKeyWord, Len(LockedMarker)) ~= LockedMarker))
							{
								bBooleanValue = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
								Beacons[iIndex].bLocked = bBooleanValue;								
							}
							else
							{
								// End:0x374
								if((Left(szKeyWord, Len(MapListMarker)) ~= MapListMarker))
								{
									szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
									j = 0;
									J0x2A2:

									// End:0x2D1 [Loop If]
									if((j < 32))
									{
										Beacons[iIndex].MapList[j] = "";
										(j++);
										// [Loop Continue]
										goto J0x2A2;
									}
									j = 0;
									J0x2D8:

									// End:0x371 [Loop If]
									if((InStr(szStringValue, "/") != -1))
									{
										szStringValue = Mid(szStringValue, (InStr(szStringValue, "/") + 1));
										pos = InStr(szStringValue, "/");
										// End:0x34B
										if((pos != -1))
										{
											Beacons[iIndex].MapList[j] = Left(szStringValue, pos);
											// [Explicit Continue]
											goto J0x367;
										}
										Beacons[iIndex].MapList[j] = szStringValue;
										J0x367:

										(j++);
										// [Loop Continue]
										goto J0x2D8;
									}									
								}
								else
								{
									// End:0x48A
									if((Left(szKeyWord, Len(MenuGmNameMarker)) ~= MenuGmNameMarker))
									{
										szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
										j = 0;
										J0x3AD:

										// End:0x3E7 [Loop If]
										if((j < 32))
										{
											Beacons[iIndex].szGameType[j] = "RGM_AllMode";
											(j++);
											// [Loop Continue]
											goto J0x3AD;
										}
										j = 0;
										J0x3EE:

										// End:0x487 [Loop If]
										if((InStr(szStringValue, "/") != -1))
										{
											szStringValue = Mid(szStringValue, (InStr(szStringValue, "/") + 1));
											pos = InStr(szStringValue, "/");
											// End:0x461
											if((pos != -1))
											{
												Beacons[iIndex].szGameType[j] = Left(szStringValue, pos);
												// [Explicit Continue]
												goto J0x47D;
											}
											Beacons[iIndex].szGameType[j] = szStringValue;
											J0x47D:

											(j++);
											// [Loop Continue]
											goto J0x3EE;
										}										
									}
									else
									{
										// End:0x595
										if((Left(szKeyWord, Len(PlayerListMarker)) ~= PlayerListMarker))
										{
											szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
											j = 0;
											J0x4C3:

											// End:0x4F2 [Loop If]
											if((j < 32))
											{
												Beacons[iIndex].szPlayerName[j] = "";
												(j++);
												// [Loop Continue]
												goto J0x4C3;
											}
											j = 0;
											J0x4F9:

											// End:0x592 [Loop If]
											if((InStr(szStringValue, "/") != -1))
											{
												szStringValue = Mid(szStringValue, (InStr(szStringValue, "/") + 1));
												pos = InStr(szStringValue, "/");
												// End:0x56C
												if((pos != -1))
												{
													Beacons[iIndex].szPlayerName[j] = Left(szStringValue, pos);
													// [Explicit Continue]
													goto J0x588;
												}
												Beacons[iIndex].szPlayerName[j] = szStringValue;
												J0x588:

												(j++);
												// [Loop Continue]
												goto J0x4F9;
											}											
										}
										else
										{
											// End:0x6A0
											if((Left(szKeyWord, Len(PlayerTimeMarker)) ~= PlayerTimeMarker))
											{
												szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
												j = 0;
												J0x5CE:

												// End:0x5FD [Loop If]
												if((j < 32))
												{
													Beacons[iIndex].szPlayerTime[j] = "";
													(j++);
													// [Loop Continue]
													goto J0x5CE;
												}
												j = 0;
												J0x604:

												// End:0x69D [Loop If]
												if((InStr(szStringValue, "/") != -1))
												{
													szStringValue = Mid(szStringValue, (InStr(szStringValue, "/") + 1));
													pos = InStr(szStringValue, "/");
													// End:0x677
													if((pos != -1))
													{
														Beacons[iIndex].szPlayerTime[j] = Left(szStringValue, pos);
														// [Explicit Continue]
														goto J0x693;
													}
													Beacons[iIndex].szPlayerTime[j] = szStringValue;
													J0x693:

													(j++);
													// [Loop Continue]
													goto J0x604;
												}												
											}
											else
											{
												// End:0x7AE
												if((Left(szKeyWord, Len(PlayerPingMarker)) ~= PlayerPingMarker))
												{
													szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
													j = 0;
													J0x6D9:

													// End:0x707 [Loop If]
													if((j < 32))
													{
														Beacons[iIndex].iPlayerPingTime[j] = 0;
														(j++);
														// [Loop Continue]
														goto J0x6D9;
													}
													j = 0;
													J0x70E:

													// End:0x7AB [Loop If]
													if((InStr(szStringValue, "/") != -1))
													{
														szStringValue = Mid(szStringValue, (InStr(szStringValue, "/") + 1));
														pos = InStr(szStringValue, "/");
														// End:0x783
														if((pos != -1))
														{
															Beacons[iIndex].iPlayerPingTime[j] = int(Left(szStringValue, pos));
															// [Explicit Continue]
															goto J0x7A1;
														}
														Beacons[iIndex].iPlayerPingTime[j] = int(szStringValue);
														J0x7A1:

														(j++);
														// [Loop Continue]
														goto J0x70E;
													}													
												}
												else
												{
													// End:0x8BC
													if((Left(szKeyWord, Len(PlayerKillMarker)) ~= PlayerKillMarker))
													{
														szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
														j = 0;
														J0x7E7:

														// End:0x815 [Loop If]
														if((j < 32))
														{
															Beacons[iIndex].iPlayerKillCount[j] = 0;
															(j++);
															// [Loop Continue]
															goto J0x7E7;
														}
														j = 0;
														J0x81C:

														// End:0x8B9 [Loop If]
														if((InStr(szStringValue, "/") != -1))
														{
															szStringValue = Mid(szStringValue, (InStr(szStringValue, "/") + 1));
															pos = InStr(szStringValue, "/");
															// End:0x891
															if((pos != -1))
															{
																Beacons[iIndex].iPlayerKillCount[j] = int(Left(szStringValue, pos));
																// [Explicit Continue]
																goto J0x8AF;
															}
															Beacons[iIndex].iPlayerKillCount[j] = int(szStringValue);
															J0x8AF:

															(j++);
															// [Loop Continue]
															goto J0x81C;
														}														
													}
													else
													{
														// End:0x90B
														if((Left(szKeyWord, Len(RoundsPerMatchMarker)) ~= RoundsPerMatchMarker))
														{
															iIntegerValue = int(float(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
															Beacons[iIndex].iRoundsPerMap = iIntegerValue;															
														}
														else
														{
															// End:0x95C
															if((Left(szKeyWord, Len(RoundTimeMarker)) ~= RoundTimeMarker))
															{
																iIntegerValue = int(float(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
																Beacons[iIndex].fRndTime = float(iIntegerValue);																
															}
															else
															{
																// End:0x9AD
																if((Left(szKeyWord, Len(BetTimeMarker)) ~= BetTimeMarker))
																{
																	iIntegerValue = int(float(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
																	Beacons[iIndex].fBetTime = float(iIntegerValue);																	
																}
																else
																{
																	// End:0x9FE
																	if((Left(szKeyWord, Len(BombTimeMarker)) ~= BombTimeMarker))
																	{
																		iIntegerValue = int(float(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
																		Beacons[iIndex].fBombTime = float(iIntegerValue);																		
																	}
																	else
																	{
																		// End:0xA50
																		if((Left(szKeyWord, Len(ShowNamesMarker)) ~= ShowNamesMarker))
																		{
																			bBooleanValue = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
																			Beacons[iIndex].bShowNames = bBooleanValue;																			
																		}
																		else
																		{
																			// End:0xAA2
																			if((Left(szKeyWord, Len(InternetServerMarker)) ~= InternetServerMarker))
																			{
																				bBooleanValue = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
																				Beacons[iIndex].bInternetServer = bBooleanValue;																				
																			}
																			else
																			{
																				// End:0xAF4
																				if((Left(szKeyWord, Len(FriendlyFireMarker)) ~= FriendlyFireMarker))
																				{
																					bBooleanValue = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
																					Beacons[iIndex].bFriendlyFire = bBooleanValue;																					
																				}
																				else
																				{
																					// End:0xB46
																					if((Left(szKeyWord, Len(AutoBalTeamMarker)) ~= AutoBalTeamMarker))
																					{
																						bBooleanValue = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
																						Beacons[iIndex].bAutoBalTeam = bBooleanValue;																						
																					}
																					else
																					{
																						// End:0xB98
																						if((Left(szKeyWord, Len(TKPenaltyMarker)) ~= TKPenaltyMarker))
																						{
																							bBooleanValue = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
																							Beacons[iIndex].bTKPenalty = bBooleanValue;																							
																						}
																						else
																						{
																							// End:0xBEA
																							if((Left(szKeyWord, Len(AllowRadarMarker)) ~= AllowRadarMarker))
																							{
																								bBooleanValue = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
																								Beacons[iIndex].bRadar = bBooleanValue;																								
																							}
																							else
																							{
																								// End:0xC35
																								if((Left(szKeyWord, Len(GameVersionMarker)) ~= GameVersionMarker))
																								{
																									szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
																									Beacons[iIndex].szGameVersion = szStringValue;																									
																								}
																								else
																								{
																									// End:0xC77
																									if((Left(szKeyWord, Len(LobbyServerIDMarker)) ~= LobbyServerIDMarker))
																									{
																										Beacons[iIndex].iLobbyID = int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1)));																										
																									}
																									else
																									{
																										// End:0xCB9
																										if((Left(szKeyWord, Len(GroupIDMarker)) ~= GroupIDMarker))
																										{
																											Beacons[iIndex].iGroupID = int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1)));																											
																										}
																										else
																										{
																											// End:0xCFB
																											if((Left(szKeyWord, Len(BeaconPortMarker)) ~= BeaconPortMarker))
																											{
																												Beacons[iIndex].iBeaconPort = int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1)));																												
																											}
																											else
																											{
																												// End:0xD3D
																												if((Left(szKeyWord, Len(NumTerroMarker)) ~= NumTerroMarker))
																												{
																													Beacons[iIndex].iNumTerro = int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1)));																													
																												}
																												else
																												{
																													// End:0xD82
																													if((Left(szKeyWord, Len(AIBkpMarker)) ~= AIBkpMarker))
																													{
																														Beacons[iIndex].bAIBkp = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));																														
																													}
																													else
																													{
																														// End:0xDC7
																														if((Left(szKeyWord, Len(RotateMapMarker)) ~= RotateMapMarker))
																														{
																															Beacons[iIndex].bRotateMap = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));																															
																														}
																														else
																														{
																															// End:0xE0C
																															if((Left(szKeyWord, Len(ForceFPWpnMarker)) ~= ForceFPWpnMarker))
																															{
																																Beacons[iIndex].bForceFPWpn = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));																																
																															}
																															else
																															{
																																// End:0xE57
																																if((Left(szKeyWord, Len(ModNameMarker)) ~= ModNameMarker))
																																{
																																	szStringValue = Mid(szKeyWord, (InStr(szKeyWord, " ") + 1));
																																	Beacons[iIndex].szModName = szStringValue;																																	
																																}
																																else
																																{
																																	// End:0xE99
																																	if((Left(szKeyWord, Len(PunkBusterMarker)) ~= PunkBusterMarker))
																																	{
																																		Beacons[iIndex].bPunkBuster = bool(int(Mid(szKeyWord, (InStr(szKeyWord, " ") + 1))));
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
