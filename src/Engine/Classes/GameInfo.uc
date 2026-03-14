//=============================================================================
// GameInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// GameInfo.
//
// The GameInfo defines the game being played: the game rules, scoring, what actors 
// are allowed to exist in this game type, and who may enter the game.  While the 
// GameInfo class is the public interface, much of this functionality is delegated 
// to several classes to allow easy modification of specific game components.  These 
// classes include GameInfo, AccessControl, Mutator, BroadcastHandler, and GameRules.  
// A GameInfo actor is instantiated when the level is initialized for gameplay (in 
// C++ UGameEngine::LoadMap() ).  The class of this GameInfo actor is determined by 
// (in order) either the DefaultGameType if specified in the LevelInfo, or the 
// DefaultGame entry in the game's .ini file (in the Engine.Engine section), unless 
// its a network game in which case the DefaultServerGame entry is used.  
//
//=============================================================================
class GameInfo extends Info
	native
	config
	notplaceable
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var byte Difficulty;
var globalconfig int GoreLevel;  // 0=Normal, increasing values=less gore
var int MaxSpectators;  // Maximum number of spectators.
var int NumSpectators;  // Current number of spectators.
var int MaxPlayers;
var int NumPlayers;  // number of human players
var int NumBots;  // number of non-human players (AI controlled but participating as a player)
var int CurrentID;
var bool bRestartLevel;  // Level should be restarted when player dies
var bool bPauseable;  // Whether the game is pauseable.
//#ifndef R6CODE
//var config bool				  bCoopWeaponMode;			// Whether or not weapons stay when picked up.
//#endif // #ifndef R6CODE
var bool bCanChangeSkin;  // Allow player to change skins in game.
var bool bGameEnded;  // set when game ends
var bool bOverTime;
var localized bool bAlternateMode;
var bool bCanViewOthers;
var bool bDelayedStart;
var bool bWaitingToStartMatch;
var globalconfig bool bChangeLevels;
//#ifdef R6CODE
var bool m_bChangedServerConfig;
//#endif
var bool bAlreadyChanged;
var globalconfig bool bLocalLog;
var globalconfig bool bWorldLog;
var bool bLoggingGame;  // Does this gametype log?
//#ifdef R6CODE
// m_bGameStarted has the game started, usefull in MP in order to prevent other players from joining the game 
// exception needs to be made for spectating
var bool m_bGameStarted;
var bool m_bGameOver;
var bool m_bCompilingStats;  // are we compiling statistics for GameMenuStats page
var bool m_bUseClarkVoice;
var bool m_bPlayIntroVideo;
var bool m_bPlayOutroVideo;
var bool m_bPendingLevelExists;
//#ifndef R6CODE
//var   globalconfig float	  AutoAim;					// How much autoaiming to do (1 = none, 0 = always).
//#endif // #ifndef R6CODE
														// (cosine of max error to correct)
var globalconfig float GameSpeed;  // Scale applied to game rate.
var float StartTime;
var AccessControl AccessControl;  // AccessControl controls whether players can enter and/or become admins
var BroadcastHandler BroadcastHandler;  // handles message (text and localized) broadcasts
var GameReplicationInfo GameReplicationInfo;
// Statistics Logging
var StatLog StatLog;
// Message classes.
var Class<LocalMessage> DeathMessageClass;
var Class<GameMessage> GameMessageClass;
var Class<PlayerController> PlayerControllerClass;  // type of player controller to spawn for players logging in
// ReplicationInfo
var() Class<GameReplicationInfo> GameReplicationInfoClass;
var Class<StatLog> StatLogClass;
var array<string> m_BankListToLoad;
var string DefaultPlayerClassName;
// user interface
//#ifndef R6CODE
//var	  string				  ScoreBoardType;
//#endif
var string BotMenuType;  // Type of bot menu to display.
var string RulesMenuType;  // Type of rules menu to display.
var string SettingsMenuType;  // Type of settings menu to display.
var string GameUMenuType;  // Type of Game dropdown to display.
var string MultiplayerUMenuType;  // Type of Multiplayer dropdown to display.
var string GameOptionsMenuType;  // Type of options dropdown to display.
var string HUDType;  // HUD class this game uses.
var string MapListType;  // Maplist this game uses.
var string MapPrefix;  // Prefix characters for names of maps for this game type.
var string BeaconName;  // Identifying string used for finding LAN servers.
var localized string DefaultPlayerName;
var localized string GameName;
var string AccessControlClass;
var string BroadcastHandlerClass;
var string PlayerControllerClassName;
//#ifdef R6LOAD_IFGAMEMODE
var string m_szGameTypeFlag;
//#ifdef R6CODE // Added by John Bennett, April 2002
var string m_szCurrGameType;  // The current game type being played (Deathmatch, team death match, etc).
var string m_szGameOptions;  // List of command line options

//#ifdef R6CODE
function SetJumpingMaps(bool _flagSetting, int iNextMapIndex)
{
	return;
}

// Export UGameInfo::execAbortScoreSubmission(FFrame&, void* const)
 native(1210) final function AbortScoreSubmission();

function RestartGameMgr()
{
	return;
}

event PreLogOut(PlayerController ExitingPlayer)
{
	return;
}

event bool CanPlayIntroVideo()
{
	return;
}

event bool CanPlayOutroVideo()
{
	return;
}

event UpdateServer()
{
	return;
}

// #ifdef R6NOISE
function R6GameInfoMakeNoise(Actor.ESoundType eType, Actor soundsource)
{
	return;
}

function PreBeginPlay()
{
	StartTime = 0.0000000;
	SetGameSpeed(GameSpeed);
	GameReplicationInfo = __NFUN_278__(GameReplicationInfoClass);
	InitGameReplicationInfo();
	return;
}

function PostBeginPlay()
{
	// End:0x11
	if(bAlternateMode)
	{
		GoreLevel = 2;
	}
	InitLogging();
	super(Actor).PostBeginPlay();
	return;
}

function Reset()
{
	super(Actor).Reset();
	bGameEnded = false;
	bOverTime = false;
	bWaitingToStartMatch = true;
	InitGameReplicationInfo();
	return;
}

function InitLogging()
{
	local bool bLoggingWorld;

	// End:0x0D
	if(__NFUN_129__(bLoggingGame))
	{
		return;
	}
	bLoggingWorld = __NFUN_130__(bWorldLog, __NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_154__(int(Level.NetMode), int(NM_ListenServer))));
	// End:0xDC
	if(__NFUN_132__(bLocalLog, bLoggingWorld))
	{
		StatLog = __NFUN_278__(StatLogClass);
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Initiating logging using ", string(StatLog)), " class "), string(StatLogClass)));
		StatLog.GenerateLogs(bLocalLog, bLoggingWorld);
		StatLog.StartLog();
		LogGameParameters();
	}
	return;
}

function Timer()
{
	BroadcastHandler.UpdateSentText();
	return;
}

// Called when game shutsdown.
event GameEnding()
{
	EndLogging("serverquit");
	return;
}

function InitGameReplicationInfo()
{
	GameReplicationInfo.GameName = GameName;
	GameReplicationInfo.GameClass = string(Class);
	return;
}

// Export UGameInfo::execGetNetworkNumber(FFrame&, void* const)
 native function string GetNetworkNumber();

// Export UGameInfo::execProcessR6Availabilty(FFrame&, void* const)
//#ifdef R6CODE
 native(1514) final function ProcessR6Availabilty(string szGameType);

// Export UGameInfo::execGetCurrentMapNum(FFrame&, void* const)
 native(1280) final function int GetCurrentMapNum();

// Export UGameInfo::execSetCurrentMapNum(FFrame&, void* const)
 native(1281) final function SetCurrentMapNum(int iMapNum);

function SetUdpBeacon(InternetInfo _udpBeacon)
{
	return;
}

function string GetInfo()
{
	local string ResultSet;

	// End:0x41
	if(__NFUN_130__(StatLog.bWorld, __NFUN_129__(StatLog.bWorldBatcherError)))
	{
		ResultSet = "\\worldlog\\true";		
	}
	else
	{
		ResultSet = "\\worldlog\\false";
	}
	// End:0x8E
	if(StatLog.bWorld)
	{
		ResultSet = __NFUN_112__(ResultSet, "\\wantworldlog\\true");		
	}
	else
	{
		ResultSet = __NFUN_112__(ResultSet, "\\wantworldlog\\false");
	}
	return ResultSet;
	return;
}

// Return the server's port number.
function int GetServerPort()
{
	local string S;
	local int i;

	S = Level.GetAddressURL();
	i = __NFUN_126__(S, ":");
	assert(__NFUN_153__(i, 0));
	return int(__NFUN_127__(S, __NFUN_146__(i, 1)));
	return;
}

function bool SetPause(bool bPause, PlayerController P)
{
	// End:0x62
	if(__NFUN_132__(bPauseable, __NFUN_154__(int(Level.NetMode), int(NM_Standalone))))
	{
		// End:0x4D
		if(bPause)
		{
			Level.Pauser = P.PlayerReplicationInfo;			
		}
		else
		{
			Level.Pauser = none;
		}
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

function LogGameParameters()
{
	StatLog.LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(StatLog.GetTimeStamp(), __NFUN_236__(9)), "game"), __NFUN_236__(9)), "GameName"), __NFUN_236__(9)), GameName));
	StatLog.LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(StatLog.GetTimeStamp(), __NFUN_236__(9)), "game"), __NFUN_236__(9)), "GameClass"), __NFUN_236__(9)), string(Class)));
	StatLog.LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(StatLog.GetTimeStamp(), __NFUN_236__(9)), "game"), __NFUN_236__(9)), "GameVersion"), __NFUN_236__(9)), Level.EngineVersion));
	StatLog.LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(StatLog.GetTimeStamp(), __NFUN_236__(9)), "game"), __NFUN_236__(9)), "MinNetVersion"), __NFUN_236__(9)), Level.MinNetVersion));
	StatLog.LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(StatLog.GetTimeStamp(), __NFUN_236__(9)), "game"), __NFUN_236__(9)), "GoreLevel"), __NFUN_236__(9)), string(GoreLevel)));
	StatLog.LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(StatLog.GetTimeStamp(), __NFUN_236__(9)), "game"), __NFUN_236__(9)), "GameSpeed"), __NFUN_236__(9)), string(int(__NFUN_171__(GameSpeed, float(100))))));
	StatLog.LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(StatLog.GetTimeStamp(), __NFUN_236__(9)), "game"), __NFUN_236__(9)), "MaxSpectators"), __NFUN_236__(9)), string(MaxSpectators)));
	StatLog.LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(StatLog.GetTimeStamp(), __NFUN_236__(9)), "game"), __NFUN_236__(9)), "MaxPlayers"), __NFUN_236__(9)), string(MaxPlayers)));
	return;
}

//
// Set gameplay speed.
//
function SetGameSpeed(float t)
{
	local float OldSpeed;

	OldSpeed = GameSpeed;
	GameSpeed = __NFUN_245__(t, 0.1000000);
	Level.TimeDilation = GameSpeed;
	// End:0x43
	if(__NFUN_181__(GameSpeed, OldSpeed))
	{
		__NFUN_536__();
	}
	__NFUN_280__(Level.TimeDilation, true);
	return;
}

//#ifdef R6CODE
function SetGamePassword(string szPasswd)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	AccessControl.SetGamePassword(szPasswd);
	pServerOptions.GamePassword = szPasswd;
	pServerOptions.UsePassword = __NFUN_129__(__NFUN_122__(szPasswd, ""));
	pServerOptions.__NFUN_536__();
	return;
}

//
// Called after setting low or high detail mode.
//
event DetailChange()
{
	local Actor A;
	local ZoneInfo Z;

	// End:0x5A
	if(__NFUN_129__(Level.bHighDetailMode))
	{
		// End:0x59
		foreach __NFUN_313__(Class'Engine.Actor', A)
		{
			// End:0x58
			if(__NFUN_130__(A.bHighDetail, __NFUN_129__(A.bGameRelevant)))
			{
				A.__NFUN_279__();
			}			
		}		
	}
	// End:0x7A
	foreach __NFUN_304__(Class'Engine.ZoneInfo', Z)
	{
		Z.LinkToSkybox();		
	}	
	return;
}

//
// Grab the next option from a string.
//
function bool GrabOption(out string Options, out string Result)
{
	// End:0x8A
	if(__NFUN_122__(__NFUN_128__(Options, 1), "?"))
	{
		Result = __NFUN_127__(Options, 1);
		// End:0x45
		if(__NFUN_153__(__NFUN_126__(Result, "?"), 0))
		{
			Result = __NFUN_128__(Result, __NFUN_126__(Result, "?"));
		}
		Options = __NFUN_127__(Options, 1);
		// End:0x7D
		if(__NFUN_153__(__NFUN_126__(Options, "?"), 0))
		{
			Options = __NFUN_127__(Options, __NFUN_126__(Options, "?"));			
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

event InitGame(string Options, out string Error)
{
	local string InOpt, LeftOpt;
	local int pos;
	local Class<AccessControl> ACClass;
	local Class<BroadcastHandler> BHClass;

	__NFUN_231__(__NFUN_168__("InitGame:", Options));
	MaxPlayers = __NFUN_249__(32, GetIntOption(Options, "MaxPlayers", MaxPlayers));
	Difficulty = byte(GetIntOption(Options, "Difficulty", int(Difficulty)));
	InOpt = ParseOption(Options, "GameSpeed");
	// End:0xA9
	if(__NFUN_123__(InOpt, ""))
	{
		__NFUN_231__(__NFUN_168__("GameSpeed", InOpt));
		SetGameSpeed(float(InOpt));
	}
	BHClass = Class<BroadcastHandler>(DynamicLoadObject(BroadcastHandlerClass, Class'Core.Class'));
	BroadcastHandler = __NFUN_278__(BHClass);
	InOpt = ParseOption(Options, "AccessControl");
	// End:0x119
	if(__NFUN_123__(InOpt, ""))
	{
		ACClass = Class<AccessControl>(DynamicLoadObject(InOpt, Class'Core.Class'));
	}
	// End:0x135
	if(__NFUN_119__(ACClass, none))
	{
		AccessControl = __NFUN_278__(ACClass);		
	}
	else
	{
		ACClass = Class<AccessControl>(DynamicLoadObject(AccessControlClass, Class'Core.Class'));
		AccessControl = __NFUN_278__(ACClass);
	}
	InOpt = ParseOption(Options, "AdminPassword");
	// End:0x19E
	if(__NFUN_123__(InOpt, ""))
	{
		AccessControl.SetAdminPassword(InOpt);
	}
	InOpt = ParseOption(Options, "GamePassword");
	// End:0x1F4
	if(__NFUN_123__(InOpt, ""))
	{
		AccessControl.SetGamePassword(InOpt);
		__NFUN_231__(__NFUN_168__("GamePassword", InOpt));
	}
	InOpt = ParseOption(Options, "LocalLog");
	// End:0x227
	if(__NFUN_124__(InOpt, "true"))
	{
		bLocalLog = true;
	}
	InOpt = ParseOption(Options, "WorldLog");
	// End:0x25A
	if(__NFUN_124__(InOpt, "true"))
	{
		bWorldLog = true;
	}
	return;
}

// Deploy all characters in the map after all options were selected in the menus.
//#ifdef R6BUILDPLANNINGPHASE
function DeployCharacters(PlayerController PController)
{
	__NFUN_231__("Wrong Deploy character");
	return;
}

//
// Return beacon text for serverbeacon.
//
event string GetBeaconText()
{
	return __NFUN_112__(__NFUN_112__(__NFUN_168__(__NFUN_168__(__NFUN_168__(Level.ComputerName, __NFUN_128__(Level.Title, 24)), BeaconName), string(NumPlayers)), "/"), string(MaxPlayers));
	return;
}

function ProcessServerTravel(string URL, bool bItems)
{
	local PlayerController P, LocalPlayer;

	EndLogging("mapchange");
	m_bPendingLevelExists = true;
	// End:0xB4
	foreach __NFUN_313__(Class'Engine.PlayerController', P)
	{
		// End:0xB3
		if(__NFUN_119__(NetConnection(P.Player), none))
		{
			// End:0x99
			if(__NFUN_119__(NetConnection(P.Player), none))
			{
				P.ClientTravel(__NFUN_112__(__NFUN_112__(URL, "?Password="), AccessControl.GetGamePassword()), 2, bItems);
				// End:0xB3
				continue;
			}
			LocalPlayer = P;
			P.PreClientTravel();
		}		
	}	
	// End:0x1BE
	if(__NFUN_130__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)), __NFUN_119__(LocalPlayer, none)))
	{
		Level.NextURL = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(Level.NextURL, "?Skin="), LocalPlayer.GetDefaultURL("Skin")), "?Face="), LocalPlayer.GetDefaultURL("Face")), "?Team="), LocalPlayer.GetDefaultURL("Team")), "?Name="), LocalPlayer.GetDefaultURL("Name")), "?Class="), LocalPlayer.GetDefaultURL("Class")), "?Password="), AccessControl.GetGamePassword());
	}
	// End:0x206
	if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_155__(int(Level.NetMode), int(NM_ListenServer))))
	{
		Level.NextSwitchCountdown = 0.0000000;
	}
	return;
}

// NEW IN 1.60
event PreLogin(string Options, string Address, out string Error, out string FailCode)
{
	local bool bSpectator;
	local string spec;

	spec = ParseOption(Options, "SpectatorOnly");
	bSpectator = __NFUN_123__(spec, "");
	AccessControl.PreLogin(Options, Address, Error, FailCode, bSpectator);
	return;
}

function int GetIntOption(string Options, string ParseString, int CurrentValue)
{
	local string InOpt;

	InOpt = ParseOption(Options, ParseString);
	// End:0x38
	if(__NFUN_123__(InOpt, ""))
	{
		__NFUN_231__(__NFUN_168__(ParseString, InOpt));
		return int(InOpt);
	}
	return CurrentValue;
	return;
}

function bool AtCapacity(bool bSpectator)
{
	// End:0x1B
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		return false;
	}
	// End:0x5C
	if(bSpectator)
	{
		return __NFUN_130__(__NFUN_153__(NumSpectators, MaxSpectators), __NFUN_132__(__NFUN_155__(int(Level.NetMode), int(NM_ListenServer)), __NFUN_151__(NumPlayers, 0)));		
	}
	else
	{
		return __NFUN_130__(__NFUN_151__(MaxPlayers, 0), __NFUN_153__(NumPlayers, MaxPlayers));
	}
	return;
}

// NEW IN 1.60
event PlayerController Login(string Portal, string Options, out string Error)
{
	local NavigationPoint StartSpot;
	local PlayerController NewPlayer;
	local Class<Pawn> DesiredPawnClass;
	local Pawn TestPawn;
	local string InName, InPassword, InChecksum, InClass;
	local byte InTeam;
	local bool bSpectator;

	bSpectator = __NFUN_123__(ParseOption(Options, "SpectatorOnly"), "");
	// End:0x4A
	if(AtCapacity(bSpectator))
	{
		Error = GameMessageClass.default.MaxedOutMessage;
		return none;
	}
	InName = __NFUN_128__(ParseOption(Options, "Name"), 20);
	InTeam = byte(GetIntOption(Options, "Team", 255));
	InPassword = ParseOption(Options, "Password");
	InChecksum = ParseOption(Options, "Checksum");
	__NFUN_231__(__NFUN_168__("Login:", InName));
	// End:0xE6
	if(__NFUN_123__(InPassword, ""))
	{
		__NFUN_231__(__NFUN_168__("Password", InPassword));
	}
	StartSpot = FindPlayerStart(none, InTeam, Portal);
	// End:0x146
	if(__NFUN_114__(StartSpot, none))
	{
		Error = Localize("MPMiscMessages", "FailedPlaceMessage", "R6GameInfo");
		return none;
	}
	// End:0x16C
	if(__NFUN_114__(PlayerControllerClass, none))
	{
		PlayerControllerClass = Class<PlayerController>(DynamicLoadObject(PlayerControllerClassName, Class'Core.Class'));
	}
	NewPlayer = __NFUN_278__(PlayerControllerClass,,, StartSpot.Location, StartSpot.Rotation);
	// End:0x1F0
	if(__NFUN_114__(NewPlayer, none))
	{
		__NFUN_231__(__NFUN_112__("Couldn't spawn player controller of class ", string(PlayerControllerClass)));
		Error = GameMessageClass.default.FailedSpawnMessage;
		return none;
	}
	NewPlayer.StartSpot = StartSpot;
	// End:0x21B
	if(__NFUN_122__(InName, ""))
	{
		InName = DefaultPlayerName;
	}
	// End:0x290
	if(__NFUN_119__(NewPlayer.PlayerReplicationInfo, none))
	{
		// End:0x27C
		if(__NFUN_132__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_122__(NewPlayer.PlayerReplicationInfo.PlayerName, DefaultPlayerName)))
		{
			ChangeName(NewPlayer, InName, false);
		}
		NewPlayer.GameReplicationInfo = GameReplicationInfo;
	}
	NewPlayer.__NFUN_113__('Spectating');
	// End:0x2E1
	if(bSpectator)
	{
		NewPlayer.bOnlySpectator = true;
		NewPlayer.PlayerReplicationInfo.bIsSpectator = true;
		__NFUN_165__(NumSpectators);
		return NewPlayer;
	}
	// End:0x314
	if(__NFUN_119__(NewPlayer.PlayerReplicationInfo, none))
	{
		NewPlayer.PlayerReplicationInfo.PlayerID = __NFUN_165__(CurrentID);
	}
	InClass = ParseOption(Options, "Class");
	// End:0x372
	if(__NFUN_123__(InClass, ""))
	{
		DesiredPawnClass = Class<Pawn>(DynamicLoadObject(InClass, Class'Core.Class'));
		// End:0x372
		if(__NFUN_119__(DesiredPawnClass, none))
		{
			NewPlayer.PawnClass = DesiredPawnClass;
		}
	}
	// End:0x391
	if(__NFUN_119__(StatLog, none))
	{
		StatLog.LogPlayerConnect(NewPlayer);
	}
	NewPlayer.ReceivedSecretChecksum = __NFUN_129__(__NFUN_124__(InChecksum, "NoChecksum"));
	__NFUN_165__(NumPlayers);
	// End:0x40B
	if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_154__(int(Level.NetMode), int(NM_ListenServer))))
	{
		BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);
	}
	// End:0x42A
	if(bDelayedStart)
	{
		NewPlayer.__NFUN_113__('BaseSpectating');
		return NewPlayer;
	}
	// End:0x519
	foreach __NFUN_313__(Class'Engine.Pawn', TestPawn)
	{
		// End:0x518
		if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(TestPawn, none), __NFUN_119__(PlayerController(TestPawn.Controller), none)), __NFUN_114__(PlayerController(TestPawn.Controller).Player, none)), __NFUN_151__(TestPawn.Health, 0)), __NFUN_124__(TestPawn.OwnerName, InName)))
		{
			NewPlayer.__NFUN_279__();
			TestPawn.__NFUN_299__(TestPawn.Controller.Rotation);
			TestPawn.bInitializeAnimation = false;
			TestPawn.PlayWaiting();			
			return PlayerController(TestPawn.Controller);
		}		
	}	
	return NewPlayer;
	return;
}

function StartMatch()
{
	local Controller P;
	local Actor A;

	// End:0x1A
	if(__NFUN_119__(StatLog, none))
	{
		StatLog.LogGameStart();
	}
	// End:0x3A
	foreach __NFUN_304__(Class'Engine.Actor', A)
	{
		A.MatchStarting();		
	}	
	P = Level.ControllerList;
	J0x4F:

	// End:0xCD [Loop If]
	if(__NFUN_119__(P, none))
	{
		// End:0xB6
		if(__NFUN_130__(P.__NFUN_303__('PlayerController'), __NFUN_114__(P.Pawn, none)))
		{
			// End:0x92
			if(bGameEnded)
			{
				return;				
			}
			else
			{
				// End:0xB6
				if(__NFUN_129__(PlayerController(P).bOnlySpectator))
				{
					RestartPlayer(P);
				}
			}
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x4F;
	}
	return;
}

//
// Restart a player.
//
function RestartPlayer(Controller aPlayer)
{
	return;
}

function Class<Pawn> GetDefaultPlayerClass()
{
	return Class<Pawn>(DynamicLoadObject(DefaultPlayerClassName, Class'Core.Class'));
	return;
}

//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
event PostLogin(PlayerController NewPlayer)
{
	local Controller P;
	local Class<HUD> H;

	// End:0x3D
	if(__NFUN_129__(bDelayedStart))
	{
		bRestartLevel = false;
		// End:0x25
		if(bWaitingToStartMatch)
		{
			StartMatch();			
		}
		else
		{
			RestartPlayer(NewPlayer);
		}
		bRestartLevel = default.bRestartLevel;
	}
	NewPlayer.ClientSetMusic(Level.Song, 3);
	H = Class<HUD>(DynamicLoadObject(HUDType, Class'Core.Class'));
	NewPlayer.ClientSetHUD(H, none);
	// End:0xCF
	if(__NFUN_119__(NewPlayer.Pawn, none))
	{
		NewPlayer.Pawn.ClientSetRotation(NewPlayer.Pawn.Rotation);
	}
	return;
}

//
// Player exits.
//
function Logout(Controller Exiting)
{
	local bool bMessage;

	bMessage = true;
	// End:0x61
	if(__NFUN_119__(PlayerController(Exiting), none))
	{
		// End:0x5A
		if(PlayerController(Exiting).bOnlySpectator)
		{
			bMessage = false;
			// End:0x57
			if(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)))
			{
				__NFUN_166__(NumSpectators);
			}			
		}
		else
		{
			__NFUN_166__(NumPlayers);
		}
	}
	// End:0xBB
	if(__NFUN_130__(bMessage, __NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)), __NFUN_154__(int(Level.NetMode), int(NM_ListenServer)))))
	{
		BroadcastLocalizedMessage(GameMessageClass, 4, Exiting.PlayerReplicationInfo);
	}
	// End:0xDA
	if(__NFUN_119__(StatLog, none))
	{
		StatLog.LogPlayerDisconnect(Exiting);
	}
	return;
}

//
// Examine the passed player's inventory, and accept or discard each item.
// AcceptInventory needs to gracefully handle the case of some inventory
// being accepted but other inventory not being accepted (such as the default
// weapon).  There are several things that can go wrong: A weapon's
// AmmoType not being accepted but the weapon being accepted -- the weapon
// should be killed off. Or the player's selected inventory item, active
// weapon, etc. not being accepted, leaving the player weaponless or leaving
// the HUD inventory rendering messed up (AcceptInventory should pick another
// applicable weapon/item as current).
//
event AcceptInventory(Pawn PlayerPawn)
{
	return;
}

function SetPlayerDefaults(Pawn PlayerPawn)
{
	PlayerPawn.JumpZ = PlayerPawn.default.JumpZ;
	PlayerPawn.AirControl = PlayerPawn.default.AirControl;
	return;
}

// Export UGameInfo::execParseKillMessage(FFrame&, void* const)
// %k = Owner's PlayerName (Killer)
// %o = Other's PlayerName (Victim)
// %w = Owner's Weapon ItemName
 native static function string ParseKillMessage(string KillerName, string VictimName, string DeathMessage);

function KickBan(string S)
{
	AccessControl.KickBan(S);
	return;
}

//
// Return whether Viewer is allowed to spectate from the
// point of view of ViewTarget.
//
function bool CanSpectate(PlayerController Viewer, bool bOnlySpectator, Actor ViewTarget)
{
	return true;
	return;
}

function ChangeName(Controller Other, coerce string S, bool bNameChange, optional bool bDontBroadcastNameChange)
{
	local string szNewNameMessage, _szNewName;

	_szNewName = TransformName(Other.PlayerReplicationInfo, S);
	// End:0x2D
	if(__NFUN_122__(_szNewName, ""))
	{
		return;
	}
	// End:0x5A
	if(__NFUN_122__(__NFUN_235__(Other.PlayerReplicationInfo.PlayerName), __NFUN_235__(_szNewName)))
	{
		bDontBroadcastNameChange = true;
	}
	// End:0x79
	if(__NFUN_119__(StatLog, none))
	{
		StatLog.LogNameChange(Other);
	}
	Other.PlayerReplicationInfo.SetPlayerName(_szNewName);
	// End:0xCC
	if(__NFUN_130__(bNameChange, __NFUN_119__(PlayerController(Other), none)))
	{
		BroadcastLocalizedMessage(GameMessageClass, 2, Other.PlayerReplicationInfo);
	}
	return;
}

// this function will return a unique player name based on the one requested
function string TransformName(PlayerReplicationInfo PRI, string NameRequested)
{
	local int _index;

	// End:0x1E
	if(__NFUN_129__(NameInUse(PRI, NameRequested)))
	{
		return NameRequested;		
	}
	else
	{
		_index = 1;
		J0x25:

		// End:0x55 [Loop If]
		if(NameInUse(PRI, __NFUN_112__(__NFUN_112__(__NFUN_112__(NameRequested, "("), string(_index)), ")")))
		{
			__NFUN_165__(_index);
			// [Loop Continue]
			goto J0x25;
		}
		return __NFUN_112__(__NFUN_112__(__NFUN_112__(NameRequested, "("), string(_index)), ")");
	}
	return;
}

// returns true if name is currently being used
function bool NameInUse(PlayerReplicationInfo PRI, string NameRequested)
{
	local PlayerReplicationInfo _PRI;

	// End:0x41
	foreach __NFUN_313__(Class'Engine.PlayerReplicationInfo', _PRI)
	{
		// End:0x40
		if(__NFUN_130__(__NFUN_119__(PRI, _PRI), __NFUN_122__(__NFUN_235__(_PRI.PlayerName), __NFUN_235__(NameRequested))))
		{			
			return true;
		}		
	}	
	return false;
	return;
}

function SendPlayer(PlayerController aPlayer, string URL)
{
	aPlayer.ClientTravel(URL, 2, false);
	return;
}

// #ifndef R6CODE
//function RestartGame()
//{
//	local string NextMap;
//	local MapList myList;
//	local class<MapList> ML;
//    local R6ServerInfo  pServerOptions;
//    
//    pServerOptions = class'Actor'.static.GetServerOptions();
//
//	if ( (GameRulesModifiers != None) && GameRulesModifiers.HandleRestartGame() )
//		return;
//
//	// these server travels should all be relative to the current URL
//	if ( bChangeLevels && !bAlreadyChanged && (MapListType != "") )
//	{
//		// open a the nextmap actor for this game type and get the next map
//		bAlreadyChanged = true;
//		ML = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
//		myList = spawn(ML);
//		NextMap = myList.GetNextMap();
//        pServerOptions.SaveConfig();
//		myList.Destroy();
//		if ( NextMap == "" )
//			NextMap = GetMapName(MapPrefix, NextMap,1);
//
//		if ( NextMap != "" )
//		{
//			Level.ServerTravel(NextMap, false);
//			return;
//		}
//	}
//
//	Level.ServerTravel( "?Restart", true );
//}
// #else R6CODE
function RestartGame()
{
	local string NextMap;
	local MapList myList;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	// End:0xCF
	if(__NFUN_130__(bChangeLevels, __NFUN_129__(bAlreadyChanged)))
	{
		bAlreadyChanged = true;
		myList = pServerOptions.m_ServerMapList;
		// End:0x69
		if(__NFUN_242__(m_bChangedServerConfig, true))
		{
			NextMap = myList.GetNextMap(1);			
		}
		else
		{
			NextMap = myList.GetNextMap(myList.-2);
		}
		// End:0xAC
		if(__NFUN_122__(NextMap, ""))
		{
			NextMap = __NFUN_539__(MapPrefix, NextMap, 1);
		}
		// End:0xCF
		if(__NFUN_123__(NextMap, ""))
		{
			Level.ServerTravel(NextMap, false);
			return;
		}
	}
	Level.ServerTravel("?Restart", true);
	return;
}

event Broadcast(Actor Sender, coerce string Msg, optional name type)
{
	BroadcastHandler.Broadcast(Sender, Msg, type);
	return;
}

function BroadcastTeam(Actor Sender, coerce string Msg, optional name type)
{
	BroadcastHandler.BroadcastTeam(Sender, Msg, type);
	return;
}

event BroadcastLocalized(Actor Sender, Class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	BroadcastHandler.AllowBroadcastLocalized(Sender, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	return;
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;

	P = Level.ControllerList;
	J0x14:

	// End:0x55 [Loop If]
	if(__NFUN_119__(P, none))
	{
		P.ClientGameEnded();
		P.__NFUN_113__('GameEnded');
		P = P.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return true;
	return;
}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	// End:0x1F
	if(__NFUN_129__(CheckEndGame(Winner, Reason)))
	{
		bOverTime = true;
		return;
	}
	bGameEnded = true;
	TriggerEvent('EndGame', self, none);
	EndLogging(Reason);
	return;
}

function EndLogging(string Reason)
{
	// End:0x0D
	if(__NFUN_114__(StatLog, none))
	{
		return;
	}
	StatLog.LogGameEnd(Reason);
	StatLog.StopLog();
	StatLog.__NFUN_279__();
	StatLog = none;
	return;
}

function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
	local NavigationPoint N, BestStart;
	local Teleporter Tel;
	local float BestRating, NewRating;

	// End:0x6E
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(Player, none), __NFUN_119__(Player.StartSpot, none)), __NFUN_132__(bWaitingToStartMatch, __NFUN_130__(__NFUN_119__(Player.PlayerReplicationInfo, none), Player.PlayerReplicationInfo.bWaitingPlayer))))
	{
		return Player.StartSpot;
	}
	// End:0xAD
	if(__NFUN_123__(incomingName, ""))
	{
		// End:0xAC
		foreach __NFUN_304__(Class'Engine.Teleporter', Tel)
		{
			// End:0xAB
			if(__NFUN_124__(string(Tel.Tag), incomingName))
			{				
				return Tel;
			}			
		}		
	}
	N = Level.NavigationPointList;
	J0xC1:

	// End:0x123 [Loop If]
	if(__NFUN_119__(N, none))
	{
		NewRating = RatePlayerStart(N, InTeam, Player);
		// End:0x10C
		if(__NFUN_177__(NewRating, BestRating))
		{
			BestRating = NewRating;
			BestStart = N;
		}
		N = N.nextNavigationPoint;
		// [Loop Continue]
		goto J0xC1;
	}
	// End:0x1AE
	if(__NFUN_114__(BestStart, none))
	{
		__NFUN_231__("Warning - PATHS NOT DEFINED or NO PLAYERSTART");
		// End:0x1AD
		foreach __NFUN_304__(Class'Engine.NavigationPoint', N)
		{
			NewRating = RatePlayerStart(N, 0, Player);
			// End:0x1AC
			if(__NFUN_177__(NewRating, BestRating))
			{
				BestRating = NewRating;
				BestStart = N;
			}			
		}		
	}
	return BestStart;
	return;
}

function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;

	P = PlayerStart(N);
	// End:0x51
	if(__NFUN_119__(P, none))
	{
		// End:0x4B
		if(P.bSinglePlayerStart)
		{
			// End:0x45
			if(P.bEnabled)
			{
				return 1000.0000000;
			}
			return 20.0000000;
		}
		return 10.0000000;
	}
	return 0.0000000;
	return;
}

function bool TooManyBots()
{
	return false;
	return;
}

function int MPSelectOperativeFace(bool bIsFemale)
{
	return -1;
	return;
}

// weather we should be compiling the stats for in game stats page
function SetCompilingStats(bool bStatsSetting)
{
	m_bCompilingStats = bStatsSetting;
	return;
}

function SetRoundRestartedByJoinFlag(bool bRestartableByJoin)
{
	GameReplicationInfo.m_bRestartableByJoin = bRestartableByJoin;
	return;
}

defaultproperties
{
	Difficulty=3
	MaxSpectators=2
	MaxPlayers=16
	bRestartLevel=true
	bPauseable=true
	bCanChangeSkin=true
	bCanViewOthers=true
	bWaitingToStartMatch=true
	bLocalLog=true
	bWorldLog=true
	m_bCompilingStats=true
	GameSpeed=1.0000000
	DeathMessageClass=Class'Engine.LocalMessage'
	GameMessageClass=Class'Engine.GameMessage'
	GameReplicationInfoClass=Class'Engine.GameReplicationInfo'
	StatLogClass=Class'Engine.StatLogFile'
	HUDType="Engine.HUD"
	DefaultPlayerName="Player"
	GameName="Game"
	AccessControlClass="Engine.AccessControl"
	BroadcastHandlerClass="R6Game.R6BroadcastHandler"
	PlayerControllerClassName="Engine.PlayerController"
	m_szGameTypeFlag="RGM_AllMode"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var bTeamGame
// REMOVED IN 1.60: var MutatorClass
// REMOVED IN 1.60: var BaseMutator
// REMOVED IN 1.60: var GameRulesModifiers
// REMOVED IN 1.60: var m_bLadderStats
// REMOVED IN 1.60: function ToggleRestart
// REMOVED IN 1.60: function GetRules
// REMOVED IN 1.60: function SendStartMessage
// REMOVED IN 1.60: function AddDefaultInventory
// REMOVED IN 1.60: function NotifyKilled
// REMOVED IN 1.60: function Killed
// REMOVED IN 1.60: function PreventDeath
// REMOVED IN 1.60: function BroadcastDeathMessage
// REMOVED IN 1.60: function Kick
// REMOVED IN 1.60: function IsOnTeam
// REMOVED IN 1.60: function ReduceDamage
// REMOVED IN 1.60: function ChangeTeam
// REMOVED IN 1.60: function PickTeam
// REMOVED IN 1.60: function ScoreObjective
// REMOVED IN 1.60: function CheckScore
// REMOVED IN 1.60: function ScoreKill
