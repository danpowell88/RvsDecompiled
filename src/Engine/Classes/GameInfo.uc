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
    native;

// --- Variables ---
// var ? BaseMutator; // REMOVED IN 1.60
// var ? GameRulesModifiers; // REMOVED IN 1.60
// var ? MutatorClass; // REMOVED IN 1.60
// var ? bTeamGame; // REMOVED IN 1.60
// var ? m_bLadderStats; // REMOVED IN 1.60
// Statistics Logging
var StatLog StatLog;
// ReplicationInfo
var GameReplicationInfo GameReplicationInfo;
// AccessControl controls whether players can enter and/or become admins
var AccessControl AccessControl;
var int MaxPlayers;
//#ifndef R6CODE
//var   globalconfig float	  AutoAim;					// How much autoaiming to do (1 = none, 0 = always).
//#endif // #ifndef R6CODE
														// (cosine of max error to correct)
// Scale applied to game rate.
var config globalconfig float GameSpeed;
var array<array> m_BankListToLoad;
var class<GameMessage> GameMessageClass;
// number of human players
var int NumPlayers;
// handles message (text and localized) broadcasts
var BroadcastHandler BroadcastHandler;
var byte Difficulty;
// set when game ends
var bool bGameEnded;
var bool bWaitingToStartMatch;
// type of player controller to spawn for players logging in
var class<PlayerController> PlayerControllerClass;
// Level should be restarted when player dies
var bool bRestartLevel;
// Current number of spectators.
var int NumSpectators;
var localized string DefaultPlayerName;
var config globalconfig bool bLocalLog;
var class<StatLog> StatLogClass;
var config globalconfig bool bWorldLog;
var localized string GameName;
var int CurrentID;
// Maximum number of spectators.
var int MaxSpectators;
// 0=Normal, increasing values=less gore
var config globalconfig int GoreLevel;
//#endif
var bool bAlreadyChanged;
//#ifdef R6CODE
var bool m_bChangedServerConfig;
var config globalconfig bool bChangeLevels;
var bool bDelayedStart;
var bool bOverTime;
// Whether the game is pauseable.
var bool bPauseable;
var localized bool bAlternateMode;
var bool bCanViewOthers;
var float StartTime;
var string DefaultPlayerClassName;
// HUD class this game uses.
var string HUDType;
// Prefix characters for names of maps for this game type.
var string MapPrefix;
// Identifying string used for finding LAN servers.
var string BeaconName;
var string AccessControlClass;
var string BroadcastHandlerClass;
var string PlayerControllerClassName;
var class<GameReplicationInfo> GameReplicationInfoClass;
// ^ NEW IN 1.60
// Does this gametype log?
var bool bLoggingGame;
//#ifdef R6LOAD_IFGAMEMODE
var string m_szGameTypeFlag;
//#ifdef R6CODE
// m_bGameStarted has the game started, usefull in MP in order to prevent other players from joining the game
// exception needs to be made for spectating
var bool m_bGameStarted;
// are we compiling statistics for GameMenuStats page
var bool m_bCompilingStats;
var bool m_bPendingLevelExists;
var bool m_bPlayOutroVideo;
var bool m_bPlayIntroVideo;
var bool m_bUseClarkVoice;
// List of command line options
var string m_szGameOptions;
//#ifdef R6CODE // Added by John Bennett, April 2002
// The current game type being played (Deathmatch, team death match, etc).
var string m_szCurrGameType;
var bool m_bGameOver;
// Message classes.
var class<LocalMessage> DeathMessageClass;
// number of non-human players (AI controlled but participating as a player)
var int NumBots;
// Maplist this game uses.
var string MapListType;
// Type of options dropdown to display.
var string GameOptionsMenuType;
// Type of Multiplayer dropdown to display.
var string MultiplayerUMenuType;
// Type of Game dropdown to display.
var string GameUMenuType;
// Type of settings menu to display.
var string SettingsMenuType;
// Type of rules menu to display.
var string RulesMenuType;
// user interface
//#ifndef R6CODE
//var	  string				  ScoreBoardType;
//#endif
// Type of bot menu to display.
var string BotMenuType;
//#ifndef R6CODE
//var config bool				  bCoopWeaponMode;			// Whether or not weapons stay when picked up.
//#endif // #ifndef R6CODE
// Allow player to change skins in game.
var bool bCanChangeSkin;

// --- Functions ---
// function ? AddDefaultInventory(...); // REMOVED IN 1.60
// function ? BroadcastDeathMessage(...); // REMOVED IN 1.60
// function ? CheckScore(...); // REMOVED IN 1.60
// function ? Kick(...); // REMOVED IN 1.60
// function ? Killed(...); // REMOVED IN 1.60
// function ? NotifyKilled(...); // REMOVED IN 1.60
// function ? ScoreKill(...); // REMOVED IN 1.60
// function ? ScoreObjective(...); // REMOVED IN 1.60
// function ? SendStartMessage(...); // REMOVED IN 1.60
// function ? ToggleRestart(...); // REMOVED IN 1.60
//
// Set gameplay speed.
//
function SetGameSpeed(float t) {}
function string ParseOption(string Options, string InKey) {}
// ^ NEW IN 1.60
event PreLogin(string Options, string Address, out string Error, out string FailCode) {}
// ^ NEW IN 1.60
function EndGame(string Reason, PlayerReplicationInfo Winner) {}
// returns true if name is currently being used
function bool NameInUse(PlayerReplicationInfo PRI, string NameRequested) {}
// ^ NEW IN 1.60
function InitLogging() {}
// Return the server's port number.
function int GetServerPort() {}
// ^ NEW IN 1.60
//#ifdef R6CODE
function SetGamePassword(string szPasswd) {}
//
// Called after setting low or high detail mode.
//
event DetailChange() {}
function int GetIntOption(string ParseString, string Options, int CurrentValue) {}
// ^ NEW IN 1.60
//
// Player exits.
//
function Logout(Controller Exiting) {}
function SetPlayerDefaults(Pawn PlayerPawn) {}
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player) {}
// ^ NEW IN 1.60
// this function will return a unique player name based on the one requested
function string TransformName(string NameRequested, PlayerReplicationInfo PRI) {}
// ^ NEW IN 1.60
//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
event PostLogin(PlayerController NewPlayer) {}
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason) {}
// ^ NEW IN 1.60
//
// Break up a key=value pair into its key and value.
//
function GetKeyValue(string Pair, out string Value, out string Key) {}
function ChangeName(Controller Other, coerce string S, bool bNameChange, optional bool bDontBroadcastNameChange) {}
function ProcessServerTravel(string URL, bool bItems) {}
function string GetInfo() {}
// ^ NEW IN 1.60
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
function RestartGame() {}
function StartMatch() {}
function NavigationPoint FindPlayerStart(Controller Player, optional string incomingName, optional byte InTeam) {}
// ^ NEW IN 1.60
//
// Grab the next option from a string.
//
function bool GrabOption(out string Options, out string Result) {}
// ^ NEW IN 1.60
final native function ProcessR6Availabilty(string szGameType) {}
// ^ NEW IN 1.60
final native function SetCurrentMapNum(int iMapNum) {}
// ^ NEW IN 1.60
function bool SetPause(bool bPause, PlayerController P) {}
// ^ NEW IN 1.60
event InitGame(string Options, out string Error) {}
event PlayerController Login(string Options, out string Error, string Portal) {}
// ^ NEW IN 1.60
function bool AtCapacity(bool bSpectator) {}
// ^ NEW IN 1.60
function SetRoundRestartedByJoinFlag(bool bRestartableByJoin) {}
// weather we should be compiling the stats for in game stats page
function SetCompilingStats(bool bStatsSetting) {}
function EndLogging(string Reason) {}
// %k = Owner's PlayerName (Killer)
// %o = Other's PlayerName (Victim)
// %w = Owner's Weapon ItemName
static native function string ParseKillMessage(string KillerName, string VictimName, string DeathMessage) {}
// ^ NEW IN 1.60
event BroadcastLocalized(optional Object OptionalObject, optional PlayerReplicationInfo RelatedPRI_2, optional PlayerReplicationInfo RelatedPRI_1, optional int Switch, class<LocalMessage> Message, Actor Sender) {}
function KickBan(string S) {}
function BroadcastTeam(optional name type, coerce string Msg, Actor Sender) {}
event Broadcast(optional name type, coerce string Msg, Actor Sender) {}
function SendPlayer(string URL, PlayerController aPlayer) {}
//
// Return whether Viewer is allowed to spectate from the
// point of view of ViewTarget.
//
function bool CanSpectate(Actor ViewTarget, bool bOnlySpectator, PlayerController Viewer) {}
// ^ NEW IN 1.60
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
event AcceptInventory(Pawn PlayerPawn) {}
function bool TooManyBots() {}
// ^ NEW IN 1.60
function int MPSelectOperativeFace(bool bIsFemale) {}
// ^ NEW IN 1.60
function class<Pawn> GetDefaultPlayerClass() {}
// ^ NEW IN 1.60
//
// Restart a player.
//
function RestartPlayer(Controller aPlayer) {}
//
// Return beacon text for serverbeacon.
//
event string GetBeaconText() {}
// ^ NEW IN 1.60
// Deploy all characters in the map after all options were selected in the menus.
//#ifdef R6BUILDPLANNINGPHASE
function DeployCharacters(PlayerController PController) {}
function LogGameParameters() {}
function SetUdpBeacon(InternetInfo _udpBeacon) {}
final native function int GetCurrentMapNum() {}
// ^ NEW IN 1.60
native function string GetNetworkNumber() {}
// ^ NEW IN 1.60
function InitGameReplicationInfo() {}
// Called when game shutsdown.
event GameEnding() {}
function Timer() {}
function Reset() {}
function PostBeginPlay() {}
function PreBeginPlay() {}
// #ifdef R6NOISE
function R6GameInfoMakeNoise(Actor soundsource, ESoundType eType) {}
event UpdateServer() {}
event bool CanPlayOutroVideo() {}
// ^ NEW IN 1.60
event bool CanPlayIntroVideo() {}
// ^ NEW IN 1.60
event PreLogOut(PlayerController ExitingPlayer) {}
function RestartGameMgr() {}
final native function AbortScoreSubmission() {}
//#ifdef R6CODE
function SetJumpingMaps(int iNextMapIndex, bool _flagSetting) {}

defaultproperties
{
}
