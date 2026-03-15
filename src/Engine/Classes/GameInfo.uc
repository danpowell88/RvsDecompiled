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
	GameReplicationInfo = Spawn(GameReplicationInfoClass);
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
	if((!bLoggingGame))
	{
		return;
	}
	bLoggingWorld = (bWorldLog && ((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer))));
	// End:0xDC
	if((bLocalLog || bLoggingWorld))
	{
		StatLog = Spawn(StatLogClass);
		Log(((("Initiating logging using " $ string(StatLog)) $ " class ") $ string(StatLogClass)));
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
	if((StatLog.bWorld && (!StatLog.bWorldBatcherError)))
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
		ResultSet = (ResultSet $ "\\wantworldlog\\true");		
	}
	else
	{
		ResultSet = (ResultSet $ "\\wantworldlog\\false");
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
	i = InStr(S, ":");
	assert((i >= 0));
	return int(Mid(S, (i + 1)));
	return;
}

function bool SetPause(bool bPause, PlayerController P)
{
	// End:0x62
	if((bPauseable || (int(Level.NetMode) == int(NM_Standalone))))
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
	StatLog.LogEventString(((((((StatLog.GetTimeStamp() $ Chr(9)) $ "game") $ Chr(9)) $ "GameName") $ Chr(9)) $ GameName));
	StatLog.LogEventString(((((((StatLog.GetTimeStamp() $ Chr(9)) $ "game") $ Chr(9)) $ "GameClass") $ Chr(9)) $ string(Class)));
	StatLog.LogEventString(((((((StatLog.GetTimeStamp() $ Chr(9)) $ "game") $ Chr(9)) $ "GameVersion") $ Chr(9)) $ Level.EngineVersion));
	StatLog.LogEventString(((((((StatLog.GetTimeStamp() $ Chr(9)) $ "game") $ Chr(9)) $ "MinNetVersion") $ Chr(9)) $ Level.MinNetVersion));
	StatLog.LogEventString(((((((StatLog.GetTimeStamp() $ Chr(9)) $ "game") $ Chr(9)) $ "GoreLevel") $ Chr(9)) $ string(GoreLevel)));
	StatLog.LogEventString(((((((StatLog.GetTimeStamp() $ Chr(9)) $ "game") $ Chr(9)) $ "GameSpeed") $ Chr(9)) $ string(int((GameSpeed * float(100))))));
	StatLog.LogEventString(((((((StatLog.GetTimeStamp() $ Chr(9)) $ "game") $ Chr(9)) $ "MaxSpectators") $ Chr(9)) $ string(MaxSpectators)));
	StatLog.LogEventString(((((((StatLog.GetTimeStamp() $ Chr(9)) $ "game") $ Chr(9)) $ "MaxPlayers") $ Chr(9)) $ string(MaxPlayers)));
	return;
}

//
// Set gameplay speed.
//
function SetGameSpeed(float t)
{
	local float OldSpeed;

	OldSpeed = GameSpeed;
	GameSpeed = FMax(t, 0.1000000);
	Level.TimeDilation = GameSpeed;
	// End:0x43
	if((GameSpeed != OldSpeed))
	{
		SaveConfig();
	}
	SetTimer(Level.TimeDilation, true);
	return;
}

//#ifdef R6CODE
function SetGamePassword(string szPasswd)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.GetServerOptions();
	AccessControl.SetGamePassword(szPasswd);
	pServerOptions.GamePassword = szPasswd;
	pServerOptions.UsePassword = (!(szPasswd == ""));
	pServerOptions.SaveConfig();
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
	if((!Level.bHighDetailMode))
	{
		// End:0x59
		foreach DynamicActors(Class'Engine.Actor', A)
		{
			// End:0x58
			if((A.bHighDetail && (!A.bGameRelevant)))
			{
				A.Destroy();
			}			
		}		
	}
	// End:0x7A
	foreach AllActors(Class'Engine.ZoneInfo', Z)
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
	if((Left(Options, 1) == "?"))
	{
		Result = Mid(Options, 1);
		// End:0x45
		if((InStr(Result, "?") >= 0))
		{
			Result = Left(Result, InStr(Result, "?"));
		}
		Options = Mid(Options, 1);
		// End:0x7D
		if((InStr(Options, "?") >= 0))
		{
			Options = Mid(Options, InStr(Options, "?"));			
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

event InitGame(string Options, out string Error)
{
	local string InOpt, LeftOpt;
	local int pos;
	local Class<AccessControl> ACClass;
	local Class<BroadcastHandler> BHClass;

	Log(("InitGame:" @ Options));
	MaxPlayers = Min(32, GetIntOption(Options, "MaxPlayers", MaxPlayers));
	Difficulty = byte(GetIntOption(Options, "Difficulty", int(Difficulty)));
	InOpt = ParseOption(Options, "GameSpeed");
	// End:0xA9
	if((InOpt != ""))
	{
		Log(("GameSpeed" @ InOpt));
		SetGameSpeed(float(InOpt));
	}
	BHClass = Class<BroadcastHandler>(DynamicLoadObject(BroadcastHandlerClass, Class'Core.Class'));
	BroadcastHandler = Spawn(BHClass);
	InOpt = ParseOption(Options, "AccessControl");
	// End:0x119
	if((InOpt != ""))
	{
		ACClass = Class<AccessControl>(DynamicLoadObject(InOpt, Class'Core.Class'));
	}
	// End:0x135
	if((ACClass != none))
	{
		AccessControl = Spawn(ACClass);		
	}
	else
	{
		ACClass = Class<AccessControl>(DynamicLoadObject(AccessControlClass, Class'Core.Class'));
		AccessControl = Spawn(ACClass);
	}
	InOpt = ParseOption(Options, "AdminPassword");
	// End:0x19E
	if((InOpt != ""))
	{
		AccessControl.SetAdminPassword(InOpt);
	}
	InOpt = ParseOption(Options, "GamePassword");
	// End:0x1F4
	if((InOpt != ""))
	{
		AccessControl.SetGamePassword(InOpt);
		Log(("GamePassword" @ InOpt));
	}
	InOpt = ParseOption(Options, "LocalLog");
	// End:0x227
	if((InOpt ~= "true"))
	{
		bLocalLog = true;
	}
	InOpt = ParseOption(Options, "WorldLog");
	// End:0x25A
	if((InOpt ~= "true"))
	{
		bWorldLog = true;
	}
	return;
}

// Deploy all characters in the map after all options were selected in the menus.
//#ifdef R6BUILDPLANNINGPHASE
function DeployCharacters(PlayerController PController)
{
	Log("Wrong Deploy character");
	return;
}

//
// Return beacon text for serverbeacon.
//
event string GetBeaconText()
{
	return (((((Level.ComputerName @ Left(Level.Title, 24)) @ BeaconName) @ string(NumPlayers)) $ "/") $ string(MaxPlayers));
	return;
}

function ProcessServerTravel(string URL, bool bItems)
{
	local PlayerController P, LocalPlayer;

	EndLogging("mapchange");
	m_bPendingLevelExists = true;
	// End:0xB4
	foreach DynamicActors(Class'Engine.PlayerController', P)
	{
		// End:0xB3
		if((NetConnection(P.Player) != none))
		{
			// End:0x99
			if((NetConnection(P.Player) != none))
			{
				P.ClientTravel(((URL $ "?Password=") $ AccessControl.GetGamePassword()), 2, bItems);
				// End:0xB3
				continue;
			}
			LocalPlayer = P;
			P.PreClientTravel();
		}		
	}	
	// End:0x1BE
	if(((int(Level.NetMode) == int(NM_ListenServer)) && (LocalPlayer != none)))
	{
		Level.NextURL = ((((((((((((Level.NextURL $ "?Skin=") $ LocalPlayer.GetDefaultURL("Skin")) $ "?Face=") $ LocalPlayer.GetDefaultURL("Face")) $ "?Team=") $ LocalPlayer.GetDefaultURL("Team")) $ "?Name=") $ LocalPlayer.GetDefaultURL("Name")) $ "?Class=") $ LocalPlayer.GetDefaultURL("Class")) $ "?Password=") $ AccessControl.GetGamePassword());
	}
	// End:0x206
	if(((int(Level.NetMode) != int(NM_DedicatedServer)) && (int(Level.NetMode) != int(NM_ListenServer))))
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
	bSpectator = (spec != "");
	AccessControl.PreLogin(Options, Address, Error, FailCode, bSpectator);
	return;
}

function int GetIntOption(string Options, string ParseString, int CurrentValue)
{
	local string InOpt;

	InOpt = ParseOption(Options, ParseString);
	// End:0x38
	if((InOpt != ""))
	{
		Log((ParseString @ InOpt));
		return int(InOpt);
	}
	return CurrentValue;
	return;
}

function bool AtCapacity(bool bSpectator)
{
	// End:0x1B
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		return false;
	}
	// End:0x5C
	if(bSpectator)
	{
		return ((NumSpectators >= MaxSpectators) && ((int(Level.NetMode) != int(NM_ListenServer)) || (NumPlayers > 0)));		
	}
	else
	{
		return ((MaxPlayers > 0) && (NumPlayers >= MaxPlayers));
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

	bSpectator = (ParseOption(Options, "SpectatorOnly") != "");
	// End:0x4A
	if(AtCapacity(bSpectator))
	{
		Error = GameMessageClass.default.MaxedOutMessage;
		return none;
	}
	InName = Left(ParseOption(Options, "Name"), 20);
	InTeam = byte(GetIntOption(Options, "Team", 255));
	InPassword = ParseOption(Options, "Password");
	InChecksum = ParseOption(Options, "Checksum");
	Log(("Login:" @ InName));
	// End:0xE6
	if((InPassword != ""))
	{
		Log(("Password" @ InPassword));
	}
	StartSpot = FindPlayerStart(none, InTeam, Portal);
	// End:0x146
	if((StartSpot == none))
	{
		Error = Localize("MPMiscMessages", "FailedPlaceMessage", "R6GameInfo");
		return none;
	}
	// End:0x16C
	if((PlayerControllerClass == none))
	{
		PlayerControllerClass = Class<PlayerController>(DynamicLoadObject(PlayerControllerClassName, Class'Core.Class'));
	}
	NewPlayer = Spawn(PlayerControllerClass,,, StartSpot.Location, StartSpot.Rotation);
	// End:0x1F0
	if((NewPlayer == none))
	{
		Log(("Couldn't spawn player controller of class " $ string(PlayerControllerClass)));
		Error = GameMessageClass.default.FailedSpawnMessage;
		return none;
	}
	NewPlayer.StartSpot = StartSpot;
	// End:0x21B
	if((InName == ""))
	{
		InName = DefaultPlayerName;
	}
	// End:0x290
	if((NewPlayer.PlayerReplicationInfo != none))
	{
		// End:0x27C
		if(((int(Level.NetMode) != int(NM_Standalone)) || (NewPlayer.PlayerReplicationInfo.PlayerName == DefaultPlayerName)))
		{
			ChangeName(NewPlayer, InName, false);
		}
		NewPlayer.GameReplicationInfo = GameReplicationInfo;
	}
	NewPlayer.GotoState('Spectating');
	// End:0x2E1
	if(bSpectator)
	{
		NewPlayer.bOnlySpectator = true;
		NewPlayer.PlayerReplicationInfo.bIsSpectator = true;
		(NumSpectators++);
		return NewPlayer;
	}
	// End:0x314
	if((NewPlayer.PlayerReplicationInfo != none))
	{
		NewPlayer.PlayerReplicationInfo.PlayerID = (CurrentID++);
	}
	InClass = ParseOption(Options, "Class");
	// End:0x372
	if((InClass != ""))
	{
		DesiredPawnClass = Class<Pawn>(DynamicLoadObject(InClass, Class'Core.Class'));
		// End:0x372
		if((DesiredPawnClass != none))
		{
			NewPlayer.PawnClass = DesiredPawnClass;
		}
	}
	// End:0x391
	if((StatLog != none))
	{
		StatLog.LogPlayerConnect(NewPlayer);
	}
	NewPlayer.ReceivedSecretChecksum = (!(InChecksum ~= "NoChecksum"));
	(NumPlayers++);
	// End:0x40B
	if(((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer))))
	{
		BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);
	}
	// End:0x42A
	if(bDelayedStart)
	{
		NewPlayer.GotoState('BaseSpectating');
		return NewPlayer;
	}
	// End:0x519
	foreach DynamicActors(Class'Engine.Pawn', TestPawn)
	{
		// End:0x518
		if((((((TestPawn != none) && (PlayerController(TestPawn.Controller) != none)) && (PlayerController(TestPawn.Controller).Player == none)) && (TestPawn.Health > 0)) && (TestPawn.OwnerName ~= InName)))
		{
			NewPlayer.Destroy();
			TestPawn.SetRotation(TestPawn.Controller.Rotation);
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
	if((StatLog != none))
	{
		StatLog.LogGameStart();
	}
	// End:0x3A
	foreach AllActors(Class'Engine.Actor', A)
	{
		A.MatchStarting();		
	}	
	P = Level.ControllerList;
	J0x4F:

	// End:0xCD [Loop If]
	if((P != none))
	{
		// End:0xB6
		if((P.IsA('PlayerController') && (P.Pawn == none)))
		{
			// End:0x92
			if(bGameEnded)
			{
				return;				
			}
			else
			{
				// End:0xB6
				if((!PlayerController(P).bOnlySpectator))
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
	if((!bDelayedStart))
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
	if((NewPlayer.Pawn != none))
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
	if((PlayerController(Exiting) != none))
	{
		// End:0x5A
		if(PlayerController(Exiting).bOnlySpectator)
		{
			bMessage = false;
			// End:0x57
			if((int(Level.NetMode) == int(NM_DedicatedServer)))
			{
				(NumSpectators--);
			}			
		}
		else
		{
			(NumPlayers--);
		}
	}
	// End:0xBB
	if((bMessage && ((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer)))))
	{
		BroadcastLocalizedMessage(GameMessageClass, 4, Exiting.PlayerReplicationInfo);
	}
	// End:0xDA
	if((StatLog != none))
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
	if((_szNewName == ""))
	{
		return;
	}
	// End:0x5A
	if((Caps(Other.PlayerReplicationInfo.PlayerName) == Caps(_szNewName)))
	{
		bDontBroadcastNameChange = true;
	}
	// End:0x79
	if((StatLog != none))
	{
		StatLog.LogNameChange(Other);
	}
	Other.PlayerReplicationInfo.SetPlayerName(_szNewName);
	// End:0xCC
	if((bNameChange && (PlayerController(Other) != none)))
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
	if((!NameInUse(PRI, NameRequested)))
	{
		return NameRequested;		
	}
	else
	{
		_index = 1;
		J0x25:

		// End:0x55 [Loop If]
		if(NameInUse(PRI, (((NameRequested $ "(")) $ ")" $ ???)))
		{
			(_index++);
			// [Loop Continue]
			goto J0x25;
		}
		return (((NameRequested $ "(")) $ ")" $ ???);
	}
	return;
}

// returns true if name is currently being used
function bool NameInUse(PlayerReplicationInfo PRI, string NameRequested)
{
	local PlayerReplicationInfo _PRI;

	// End:0x41
	foreach DynamicActors(Class'Engine.PlayerReplicationInfo', _PRI)
	{
		// End:0x40
		if(((PRI != _PRI) && (Caps(_PRI.PlayerName) == Caps(NameRequested))))
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

	pServerOptions = Class'Engine.Actor'.static.GetServerOptions();
	// End:0xCF
	if((bChangeLevels && (!bAlreadyChanged)))
	{
		bAlreadyChanged = true;
		myList = pServerOptions.m_ServerMapList;
		// End:0x69
		if((m_bChangedServerConfig == true))
		{
			NextMap = myList.GetNextMap(1);			
		}
		else
		{
			NextMap = myList.GetNextMap(myList.-2);
		}
		// End:0xAC
		if((NextMap == ""))
		{
			NextMap = GetMapName(MapPrefix, NextMap, 1);
		}
		// End:0xCF
		if((NextMap != ""))
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
	if((P != none))
	{
		P.ClientGameEnded();
		P.GotoState('GameEnded');
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
	if((!CheckEndGame(Winner, Reason)))
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
	if((StatLog == none))
	{
		return;
	}
	StatLog.LogGameEnd(Reason);
	StatLog.StopLog();
	StatLog.Destroy();
	StatLog = none;
	return;
}

function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
	local NavigationPoint N, BestStart;
	local Teleporter Tel;
	local float BestRating, NewRating;

	// End:0x6E
	if((((Player != none) && (Player.StartSpot != none)) && (bWaitingToStartMatch || ((Player.PlayerReplicationInfo != none) && Player.PlayerReplicationInfo.bWaitingPlayer))))
	{
		return Player.StartSpot;
	}
	// End:0xAD
	if((incomingName != ""))
	{
		// End:0xAC
		foreach AllActors(Class'Engine.Teleporter', Tel)
		{
			// End:0xAB
			if((string(Tel.Tag) ~= incomingName))
			{				
				return Tel;
			}			
		}		
	}
	N = Level.NavigationPointList;
	J0xC1:

	// End:0x123 [Loop If]
	if((N != none))
	{
		NewRating = RatePlayerStart(N, InTeam, Player);
		// End:0x10C
		if((NewRating > BestRating))
		{
			BestRating = NewRating;
			BestStart = N;
		}
		N = N.nextNavigationPoint;
		// [Loop Continue]
		goto J0xC1;
	}
	// End:0x1AE
	if((BestStart == none))
	{
		Log("Warning - PATHS NOT DEFINED or NO PLAYERSTART");
		// End:0x1AD
		foreach AllActors(Class'Engine.NavigationPoint', N)
		{
			NewRating = RatePlayerStart(N, 0, Player);
			// End:0x1AC
			if((NewRating > BestRating))
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
	if((P != none))
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
