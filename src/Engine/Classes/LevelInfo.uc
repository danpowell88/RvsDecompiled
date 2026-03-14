//=============================================================================
// LevelInfo contains information about the current level. There should 
// be one per level and it should be actor 0. UnrealEd creates each level's 
// LevelInfo automatically so you should never have to place one
// manually.
//
// The ZoneInfo properties in the LevelInfo are used to define
// the properties of all zones which don't themselves have ZoneInfo.
//=============================================================================
class LevelInfo extends ZoneInfo
    native
    nativereplication;

#exec Texture Import File=Textures\WireframeTexture.tga
#exec Texture Import File=Textures\WhiteSquareTexture.pcx
#exec Texture Import File=Textures\S_Vertex.tga Name=LargeVertex

// --- Constants ---
const RDC_CamTeamOnly = 0x20;
const RDC_CamFadeToBk = 0x10;
const RDC_CamGhost = 0x08;
const RDC_CamFreeThirdP = 0x04;
const RDC_CamThirdPerson = 0x02;
const RDC_CamFirstPerson = 0x01;

// --- Enums ---
enum ER6SoundState
{
    BANK_UnloadGun,
    BANK_UnloadAll
};
enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string MinNetVersion; // Min engine version that is net compatible.
var bool  m_bLogBandWidth;  // this bool says whether we want to log bwidth usage

//-----------------------------------------------------------------------------
// Gameplay rules

var() string DefaultGameType;
var GameInfo Game;

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var const NavigationPoint NavigationPointList;
var const Controller ControllerList;
var PhysicsVolume PhysicsVolumeList;
//#ifdef R6ACTIONSPOT
var const R6ActionSpot m_ActionSpotList;
//#endif // #ifdef R6ACTIONSPOT

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//R6 Multiplayer SKINS
var(R6MultiPlayerSkins) string  GreenTeamPawnClass;
var(R6MultiPlayerSkins) string  RedTeamPawnClass;

//Skin names received by the client. If package does not exist, it will be downloaded.
var						material  GreenTeamSkin;
var						material  GreenHeadSkin;
var						material  GreenGogglesSkin;
var						material  GreenHandSkin;
var						material  GreenMenuSkin;
var						mesh	  GreenMesh;
var						staticmesh GreenHelmetMesh;
var						material  GreenHelmetSkin;
var						Object.Region    GreenMenuRegion;

var						material  RedTeamSkin;
var						material  RedHeadSkin;
var						material  RedGogglesSkin;
var						material  RedHandSkin;
var						material  RedMenuSkin;
var						mesh	  RedMesh;
var						staticmesh RedHelmetMesh;
var						material  RedHelmetSkin;
var						Object.Region    RedMenuRegion;

//R6MissionObjectives 
var(R6MissionObjectives)	bool		m_bUseDefaultMoralityRules;
var(R6MissionObjectives)	float		m_fTimeLimit;
var(R6MissionObjectives) string         m_szMissionObjLocalization;
var(R6MissionObjectives) editinline Array<R6MissionObjectiveBase> m_aMissionObjectives;
var(R6MissionObjectives) Sound          m_sndMissionComplete;

//R6Weather
var					    Emitter	                m_WeatherEmitter;
var(R6LevelWeather)     class<R6WeatherEmitter> m_WeatherEmitterClass;
var                     class<R6WeatherEmitter> m_RepWeatherEmitterClass;
var                     Actor                   m_WeatherViewTarget;

//R6Breathing
var(R6Breathing)        class<Emitter>  m_BreathingEmitterClass;

//R6Sound
struct SoundZoneAudibleZones
{
    var() bool bZone00;
    var() bool bZone01;
    var() bool bZone02;
    var() bool bZone03;
    var() bool bZone04;
    var() bool bZone05;
    var() bool bZone06;
    var() bool bZone07;
    var() bool bZone08;
    var() bool bZone09;
    var() bool bZone10;
    var() bool bZone11;
    var() bool bZone12;
    var() bool bZone13;
    var() bool bZone14;
    var() bool bZone15;
    var() bool bZone16;
    var() bool bZone17;
    var() bool bZone18;
    var() bool bZone19;
    var() bool bZone20;
    var() bool bZone21;
    var() bool bZone22;
    var() bool bZone23;
    var() bool bZone24;
    var() bool bZone25;
    var() bool bZone26;
    var() bool bZone27;
    var() bool bZone28;
    var() bool bZone29;
    var() bool bZone30;
    var() bool bZone31;
    var() bool bZone32;
    var() bool bZone33;
    var() bool bZone34;
    var() bool bZone35;
    var() bool bZone36;
    var() bool bZone37;
    var() bool bZone38;
    var() bool bZone39;
    var() bool bZone40;
    var() bool bZone41;
    var() bool bZone42;
    var() bool bZone43;
    var() bool bZone44;
    var() bool bZone45;
    var() bool bZone46;
    var() bool bZone47;
    var() bool bZone48;
    var() bool bZone49;
    var() bool bZone50;
    var() bool bZone51;
    var() bool bZone52;
    var() bool bZone53;
    var() bool bZone54;
    var() bool bZone55;
    var() bool bZone56;
    var() bool bZone57;
    var() bool bZone58;
    var() bool bZone59;
    var() bool bZone60;
    var() bool bZone61;
    var() bool bZone62;
    var() bool bZone63;
};
enum ELevelAction
{
	LEVACT_None,
	LEVACT_Loading,
	LEVACT_Saving,
	LEVACT_Connecting,
	LEVACT_Precaching
} LevelAction;

//R6 change level in planning
var(R6Planning) INT R6PlanningMaxLevel;
var(R6Planning) INT R6PlanningMinLevel;
var(R6Planning) vector R6PlanningMaxVector;
var(R6Planning) vector R6PlanningMinVector;

var string		m_szGameTypeShown;
var BOOL        m_bGameTypesInitialized;
var FLOAT       m_fRainbowSkillMultiplier;
var FLOAT       m_fTerroSkillMultiplier;

//-----------------------------------------------------------------------------
// Renderer Management.
var() bool bNeverPrecache;

//-----------------------------------------------------------------------------
// Networking.

var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string MinNetVersion; // Min engine version that is net compatible.
var bool  m_bLogBandWidth;  // this bool says whether we want to log bwidth usage

//-----------------------------------------------------------------------------
// Gameplay rules

var() string DefaultGameType;
var GameInfo Game;

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var const NavigationPoint NavigationPointList;
var const Controller ControllerList;
var PhysicsVolume PhysicsVolumeList;
//#ifdef R6ACTIONSPOT
var const R6ActionSpot m_ActionSpotList;
//#endif // #ifdef R6ACTIONSPOT

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//R6 Multiplayer SKINS
var(R6MultiPlayerSkins) string  GreenTeamPawnClass;
var(R6MultiPlayerSkins) string  RedTeamPawnClass;

//Skin names received by the client. If package does not exist, it will be downloaded.
var						material  GreenTeamSkin;
var						material  GreenHeadSkin;
var						material  GreenGogglesSkin;
var						material  GreenHandSkin;
var						material  GreenMenuSkin;
var						mesh	  GreenMesh;
var						staticmesh GreenHelmetMesh;
var						material  GreenHelmetSkin;
var						Object.Region    GreenMenuRegion;

var						material  RedTeamSkin;
var						material  RedHeadSkin;
var						material  RedGogglesSkin;
var						material  RedHandSkin;
var						material  RedMenuSkin;
var						mesh	  RedMesh;
var						staticmesh RedHelmetMesh;
var						material  RedHelmetSkin;
var						Object.Region    RedMenuRegion;

//R6MissionObjectives 
var(R6MissionObjectives)	bool		m_bUseDefaultMoralityRules;
var(R6MissionObjectives)	float		m_fTimeLimit;
var(R6MissionObjectives) string         m_szMissionObjLocalization;
var(R6MissionObjectives) editinline Array<R6MissionObjectiveBase> m_aMissionObjectives;
var(R6MissionObjectives) Sound          m_sndMissionComplete;

//R6Weather
var					    Emitter	                m_WeatherEmitter;
var(R6LevelWeather)     class<R6WeatherEmitter> m_WeatherEmitterClass;
var                     class<R6WeatherEmitter> m_RepWeatherEmitterClass;
var                     Actor                   m_WeatherViewTarget;

//R6Breathing
var(R6Breathing)        class<Emitter>  m_BreathingEmitterClass;

//R6Sound
struct SoundZoneAudibleZones
{
    var() bool bZone00;
    var() bool bZone01;
    var() bool bZone02;
    var() bool bZone03;
    var() bool bZone04;
    var() bool bZone05;
    var() bool bZone06;
    var() bool bZone07;
    var() bool bZone08;
    var() bool bZone09;
    var() bool bZone10;
    var() bool bZone11;
    var() bool bZone12;
    var() bool bZone13;
    var() bool bZone14;
    var() bool bZone15;
    var() bool bZone16;
    var() bool bZone17;
    var() bool bZone18;
    var() bool bZone19;
    var() bool bZone20;
    var() bool bZone21;
    var() bool bZone22;
    var() bool bZone23;
    var() bool bZone24;
    var() bool bZone25;
    var() bool bZone26;
    var() bool bZone27;
    var() bool bZone28;
    var() bool bZone29;
    var() bool bZone30;
    var() bool bZone31;
    var() bool bZone32;
    var() bool bZone33;
    var() bool bZone34;
    var() bool bZone35;
    var() bool bZone36;
    var() bool bZone37;
    var() bool bZone38;
    var() bool bZone39;
    var() bool bZone40;
    var() bool bZone41;
    var() bool bZone42;
    var() bool bZone43;
    var() bool bZone44;
    var() bool bZone45;
    var() bool bZone46;
    var() bool bZone47;
    var() bool bZone48;
    var() bool bZone49;
    var() bool bZone50;
    var() bool bZone51;
    var() bool bZone52;
    var() bool bZone53;
    var() bool bZone54;
    var() bool bZone55;
    var() bool bZone56;
    var() bool bZone57;
    var() bool bZone58;
    var() bool bZone59;
    var() bool bZone60;
    var() bool bZone61;
    var() bool bZone62;
    var() bool bZone63;
};
enum EPhysicsDetailLevel
{
	PDL_Low,
	PDL_Medium,
	PDL_High
} PhysicsDetailLevel;


// Karma - jag
var float KarmaTimeScale;		// Karma physics timestep scaling.
var float RagdollTimeScale;		// Ragdoll physics timestep scaling. This is applied on top of KarmaTimeScale.
var int   MaxRagdolls;			// Maximum number of simultaneous rag-dolls.
var float KarmaGravScale;		// Allows you to make ragdolls use lower friction than normal.
var bool  bKStaticFriction;		// Better rag-doll/ground friction model, but more CPU.

var()	   bool bKNoInit;				// Start _NO_ Karma for this level. Only really for the Entry level.
// jag

//-----------------------------------------------------------------------------
// Text info about level.

var() localized string Title;
var()           string Author;		    // Who built it.
var() localized string LevelEnterText;  // Message to tell players when they enter.
var()           string LocalizedPkg;    // Package to look in for localizations.
var             PlayerReplicationInfo Pauser;          // If paused, name of person pausing the game.
var		LevelSummary Summary;
var           string VisibleGroups;		    // List of the group names which were checked when the level was last saved
var transient string SelectedGroups;		// A list of selected groups in the group browser (only used in editor)
//-----------------------------------------------------------------------------
// Flags affecting the level.

var() bool           bLonePlayer;     // No multiplayer coordination, i.e. for entranceways.
var bool             bBegunPlay;      // Whether gameplay has begun.
var bool             bPlayersOnly;    // Only update players.
var bool             bHighDetailMode; // Client high-detail mode.
var bool			 bDropDetail;	  // frame rate is below DesiredFrameRate, so drop high detail actors
var bool			 bAggressiveLOD;  // frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool             bStartup;        // Starting gameplay.
var	bool			 bPathsRebuilt;	  // True if path network is valid
var transient const bool		 bPhysicsVolumesInitialized;	// true if physicsvolume list initialized

//R6InGamePLanning
var bool   m_bInGamePlanningActive;
var bool   m_bInGamePlanningZoomingIn;
var bool   m_bInGamePlanningZoomingOut;
var float  m_fInGamePlanningZoomDistance;

//-----------------------------------------------------------------------------
// Legend - used for saving the viewport camera positions
var() vector  CameraLocationDynamic;
var() vector  CameraLocationTop;
var() vector  CameraLocationFront;
var() vector  CameraLocationSide;
var() rotator CameraRotationDynamic;

//-----------------------------------------------------------------------------
// Audio properties.

var(Audio) string	Song;			// Filename of the streaming song.
var(Audio) float	PlayerDoppler;	// Player doppler shift, 0=none, 1=full.

//-----------------------------------------------------------------------------
// Miscellaneous information.

var() float Brightness;
var() texture Screenshot;
var texture DefaultTexture;
var texture WireframeTexture;
var texture WhiteSquareTexture;
var texture LargeVertex;
var int HubStackLevel;
var transient enum ELevelAction
{
	LEVACT_None,
	LEVACT_Loading,
	LEVACT_Saving,
	LEVACT_Connecting,
	LEVACT_Precaching
} LevelAction;

//R6 change level in planning
var(R6Planning) INT R6PlanningMaxLevel;
var(R6Planning) INT R6PlanningMinLevel;
var(R6Planning) vector R6PlanningMaxVector;
var(R6Planning) vector R6PlanningMinVector;

var string		m_szGameTypeShown;
var BOOL        m_bGameTypesInitialized;
var FLOAT       m_fRainbowSkillMultiplier;
var FLOAT       m_fTerroSkillMultiplier;

//-----------------------------------------------------------------------------
// Renderer Management.
var() bool bNeverPrecache;

//-----------------------------------------------------------------------------
// Networking.

var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string MinNetVersion; // Min engine version that is net compatible.
var bool  m_bLogBandWidth;  // this bool says whether we want to log bwidth usage

//-----------------------------------------------------------------------------
// Gameplay rules

var() string DefaultGameType;
var GameInfo Game;

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var const NavigationPoint NavigationPointList;
var const Controller ControllerList;
var PhysicsVolume PhysicsVolumeList;
//#ifdef R6ACTIONSPOT
var const R6ActionSpot m_ActionSpotList;
//#endif // #ifdef R6ACTIONSPOT

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//R6 Multiplayer SKINS
var(R6MultiPlayerSkins) string  GreenTeamPawnClass;
var(R6MultiPlayerSkins) string  RedTeamPawnClass;

//Skin names received by the client. If package does not exist, it will be downloaded.
var						material  GreenTeamSkin;
var						material  GreenHeadSkin;
var						material  GreenGogglesSkin;
var						material  GreenHandSkin;
var						material  GreenMenuSkin;
var						mesh	  GreenMesh;
var						staticmesh GreenHelmetMesh;
var						material  GreenHelmetSkin;
var						Object.Region    GreenMenuRegion;

var						material  RedTeamSkin;
var						material  RedHeadSkin;
var						material  RedGogglesSkin;
var						material  RedHandSkin;
var						material  RedMenuSkin;
var						mesh	  RedMesh;
var						staticmesh RedHelmetMesh;
var						material  RedHelmetSkin;
var						Object.Region    RedMenuRegion;

//R6MissionObjectives 
var(R6MissionObjectives)	bool		m_bUseDefaultMoralityRules;
var(R6MissionObjectives)	float		m_fTimeLimit;
var(R6MissionObjectives) string         m_szMissionObjLocalization;
var(R6MissionObjectives) editinline Array<R6MissionObjectiveBase> m_aMissionObjectives;
var(R6MissionObjectives) Sound          m_sndMissionComplete;

//R6Weather
var					    Emitter	                m_WeatherEmitter;
var(R6LevelWeather)     class<R6WeatherEmitter> m_WeatherEmitterClass;
var                     class<R6WeatherEmitter> m_RepWeatherEmitterClass;
var                     Actor                   m_WeatherViewTarget;

//R6Breathing
var(R6Breathing)        class<Emitter>  m_BreathingEmitterClass;

//R6Sound
struct SoundZoneAudibleZones
{
    var() bool bZone00;
    var() bool bZone01;
    var() bool bZone02;
    var() bool bZone03;
    var() bool bZone04;
    var() bool bZone05;
    var() bool bZone06;
    var() bool bZone07;
    var() bool bZone08;
    var() bool bZone09;
    var() bool bZone10;
    var() bool bZone11;
    var() bool bZone12;
    var() bool bZone13;
    var() bool bZone14;
    var() bool bZone15;
    var() bool bZone16;
    var() bool bZone17;
    var() bool bZone18;
    var() bool bZone19;
    var() bool bZone20;
    var() bool bZone21;
    var() bool bZone22;
    var() bool bZone23;
    var() bool bZone24;
    var() bool bZone25;
    var() bool bZone26;
    var() bool bZone27;
    var() bool bZone28;
    var() bool bZone29;
    var() bool bZone30;
    var() bool bZone31;
    var() bool bZone32;
    var() bool bZone33;
    var() bool bZone34;
    var() bool bZone35;
    var() bool bZone36;
    var() bool bZone37;
    var() bool bZone38;
    var() bool bZone39;
    var() bool bZone40;
    var() bool bZone41;
    var() bool bZone42;
    var() bool bZone43;
    var() bool bZone44;
    var() bool bZone45;
    var() bool bZone46;
    var() bool bZone47;
    var() bool bZone48;
    var() bool bZone49;
    var() bool bZone50;
    var() bool bZone51;
    var() bool bZone52;
    var() bool bZone53;
    var() bool bZone54;
    var() bool bZone55;
    var() bool bZone56;
    var() bool bZone57;
    var() bool bZone58;
    var() bool bZone59;
    var() bool bZone60;
    var() bool bZone61;
    var() bool bZone62;
    var() bool bZone63;
};

// --- Structs ---
struct GameTypeInfo
{
    // **** if modified, update this struct in AZoneInfo.h ****
    var string		        m_szGameType;
	var string				m_szDisplayAsGameType;
    var EGameModeInfo       m_eGameModeInfo;
    var bool                m_bTeamAdversarial;
    var bool                m_bUsePreRecMessages;
    var bool                m_bCanSetNbOfTerroristToSpawn;
    var bool                m_bPlayWithNonRainbowNPCs;
    var bool                m_bUseRainbowComm;
    var bool                m_bDisplayBombTimer;
    var string              m_szNameLocalization;
    var string              m_szClassName;
    var string              m_szGreenTeamObjective;
    var string              m_szRedTeamObjective;
    var string              m_szGreenShortDescription;
    var string              m_szRedShortDescription;
    var string              m_szToString;
    var string              m_szSaveDirectoryName;
    var string              m_szEnglishDirName;
    var string              m_szLocalizationFile;
    // **** if modified, update this struct in AZoneInfo.h ****
};

struct WritableMapVertex
{
	var vector	position;
	var Color	color;
};

struct WritableMapIcon
{
    var float   timeStamp;
    var INT     iIconIndex;
    var Color   color;
    var INT     iPosX;
    var INT     iPosY;
};

struct WritableMapStroke
{
	var float	timeStamp;
	var INT		numPoints;
};

struct SoundZoneAudibleZones
{
    var() bool bZone00;
    var() bool bZone01;
    var() bool bZone02;
    var() bool bZone03;
    var() bool bZone04;
    var() bool bZone05;
    var() bool bZone06;
    var() bool bZone07;
    var() bool bZone08;
    var() bool bZone09;
    var() bool bZone10;
    var() bool bZone11;
    var() bool bZone12;
    var() bool bZone13;
    var() bool bZone14;
    var() bool bZone15;
    var() bool bZone16;
    var() bool bZone17;
    var() bool bZone18;
    var() bool bZone19;
    var() bool bZone20;
    var() bool bZone21;
    var() bool bZone22;
    var() bool bZone23;
    var() bool bZone24;
    var() bool bZone25;
    var() bool bZone26;
    var() bool bZone27;
    var() bool bZone28;
    var() bool bZone29;
    var() bool bZone30;
    var() bool bZone31;
    var() bool bZone32;
    var() bool bZone33;
    var() bool bZone34;
    var() bool bZone35;
    var() bool bZone36;
    var() bool bZone37;
    var() bool bZone38;
    var() bool bZone39;
    var() bool bZone40;
    var() bool bZone41;
    var() bool bZone42;
    var() bool bZone43;
    var() bool bZone44;
    var() bool bZone45;
    var() bool bZone46;
    var() bool bZone47;
    var() bool bZone48;
    var() bool bZone49;
    var() bool bZone50;
    var() bool bZone51;
    var() bool bZone52;
    var() bool bZone53;
    var() bool bZone54;
    var() bool bZone55;
    var() bool bZone56;
    var() bool bZone57;
    var() bool bZone58;
    var() bool bZone59;
    var() bool bZone60;
    var() bool bZone61;
    var() bool bZone62;
    var() bool bZone63;
};

// --- Variables ---
// var ? color; // REMOVED IN 1.60
// var ? iIconIndex; // REMOVED IN 1.60
// var ? iPosX; // REMOVED IN 1.60
// var ? iPosY; // REMOVED IN 1.60
// var ? m_bCanSetNbOfTerroristToSpawn; // REMOVED IN 1.60
// var ? m_bDisplayBombTimer; // REMOVED IN 1.60
// var ? m_bPlayWithNonRainbowNPCs; // REMOVED IN 1.60
// var ? m_bTeamAdversarial; // REMOVED IN 1.60
// var ? m_bUsePreRecMessages; // REMOVED IN 1.60
// var ? m_bUseRainbowComm; // REMOVED IN 1.60
// var ? m_eGameModeInfo; // REMOVED IN 1.60
// var ? m_szClassName; // REMOVED IN 1.60
// var ? m_szDisplayAsGameType; // REMOVED IN 1.60
// var ? m_szEnglishDirName; // REMOVED IN 1.60
// var ? m_szGameType; // REMOVED IN 1.60
// var ? m_szGreenShortDescription; // REMOVED IN 1.60
// var ? m_szGreenTeamObjective; // REMOVED IN 1.60
// var ? m_szLocalizationFile; // REMOVED IN 1.60
// var ? m_szNameLocalization; // REMOVED IN 1.60
// var ? m_szRedShortDescription; // REMOVED IN 1.60
// var ? m_szRedTeamObjective; // REMOVED IN 1.60
// var ? m_szSaveDirectoryName; // REMOVED IN 1.60
// var ? m_szToString; // REMOVED IN 1.60
// var ? numPoints; // REMOVED IN 1.60
// var ? position; // REMOVED IN 1.60
// var ? timeStamp; // REMOVED IN 1.60
var array<array> m_aGameTypeInfo;
var GameInfo Game;
var ENetMode NetMode;
// ^ NEW IN 1.60
// Current time.
// Time in seconds since level began play.
var float TimeSeconds;
var const Controller ControllerList;
//R6Weather
var Emitter m_WeatherEmitter;
var R6AbstractTerroristMgr m_terroristMgr;
var int m_iLimitedSFXCount;
// Second.
var transient int Second;
// Minute.
var transient int Minute;
// Hour.
var transient int Hour;
// Day of month.
var transient int Day;
// Month.
var transient int Month;
// If paused, name of person pausing the game.
var /* replicated */ PlayerReplicationInfo Pauser;
var PhysicsVolume PhysicsVolumeList;
var class<StaticMeshActor> RedHelmet;
// ^ NEW IN 1.60
var class<StaticMeshActor> GreenHelmet;
// ^ NEW IN 1.60
var string RedTeamPawnClass;
// ^ NEW IN 1.60
var string GreenTeamPawnClass;
// ^ NEW IN 1.60
var string NextURL;
//R6InGamePLanning
var bool m_bInGamePlanningActive;
// Millisecond.
var transient int Millisecond;
var bool bKNoInit;
// ^ NEW IN 1.60
var localized string LevelEnterText;
// ^ NEW IN 1.60
var class<R6WeatherEmitter> m_WeatherEmitterClass;
// ^ NEW IN 1.60
var R6DecalManager m_DecalManager;
// there's only one instance of hostageMgr
var R6AbstractHostageMgr m_hostageMgr;
var R6LimitedSFX m_aLimitedSFX[6];
var /* replicated */ float TimeDilation;
// ^ NEW IN 1.60
// Year.
var transient int Year;
var localized string Title;
// ^ NEW IN 1.60
// Client high-detail mode.
var bool bHighDetailMode;
var bool m_bGameTypesInitialized;
// Engine version.
var string EngineVersion;
var const NavigationPoint NavigationPointList;
var float NextSwitchCountdown;
// R6SOUND
var bool m_bPlaySound;
var bool m_bIsResettingLevel;
var bool m_bCanStartStartingSound;
var /* replicated */ class<R6WeatherEmitter> m_RepWeatherEmitterClass;
var string m_szMissionObjLocalization;
// ^ NEW IN 1.60
var Material RedHelmetSkin;
var StaticMesh RedHelmetMesh;
var Mesh RedMesh;
var Material RedHandSkin;
var Material RedGogglesSkin;
var Material RedHeadSkin;
var Material RedTeamSkin;
var Material GreenHelmetSkin;
var StaticMesh GreenHelmetMesh;
var Mesh GreenMesh;
var Material GreenHandSkin;
var Material GreenGogglesSkin;
var Material GreenHeadSkin;
//Skin names received by the client. If package does not exist, it will be downloaded.
var Material GreenTeamSkin;
var bool bNextItems;
// Min engine version that is net compatible.
var string MinNetVersion;
// Machine's name according to the OS.
var string ComputerName;
var string Song;
// ^ NEW IN 1.60
// Starting gameplay.
var bool bStartup;
var string Author;
// ^ NEW IN 1.60
var Texture m_tWritableMapTexture;
// ^ NEW IN 1.60
var float m_fDistanceHeartBeatVisible;
//R6HEARTBEAT
var bool m_bHeartBeatOn;
// true means running, false means not running
var bool m_bPBSvRunning;
//#ifdef R6PUNKBUSTER
//__WITH_PB__
//1 means PB server is running, 0 means not activated or deactivate cmd given but still running
var int iPBEnabled;
var R6ServerInfo m_ServerSettings;
var bool m_bSoundFadeFinish;
var array<array> m_aWritableMapIcons;
var array<array> m_aWritableMapTimeStamp;
var array<array> m_aWritableMapStrip;
var Vector m_vPredPredVector;
var Vector m_vPredVector;
var array<array> m_aCurrentStrip;
var Material m_pProneTrailMaterial;
// ^ NEW IN 1.60
// debug: max distance to player for displaying nav point.
var float m_fDbgNavPointDistance;
// used to avoid blur in menus
var bool m_bSkipMotionBlur;
var int m_iMotionBlurIntensity;
var Texture m_pScopeAddTexture;
var Texture m_pScopeMaskTexture;
var bool m_bAllow3DRendering;
var bool m_bScopeVisionActive;
var bool m_bHeatVisionActive;
var bool m_bNightVisionActive;
var bool m_bShowOnlyTransparentSM;
var bool m_bShowDebugLODs;
//R6NEWRENDERERFEATURES
var bool m_bShowDebugLights;
//#ifdef R6DBGVECTORINFO
var bool m_bShowDebugLine;
var EHostageNationality m_eHostageVoices;
// ^ NEW IN 1.60
var ETerroristNationality m_eTerroristVoices;
// ^ NEW IN 1.60
var SoundZoneAudibleZones m_SoundZoneAudibleZones[64];
// ^ NEW IN 1.60
var float m_fEndGamePauseTime;
// ^ NEW IN 1.60
var string m_csVoicesOneLinersBankName;
// ^ NEW IN 1.60
var Sound m_StartingMusic;
// ^ NEW IN 1.60
var Sound m_BodyFallSwitchForOtherPawnSnd;
// ^ NEW IN 1.60
var Sound m_BodyFallSwitchSnd;
// ^ NEW IN 1.60
var Sound m_SurfaceSwitchForOtherPawnSnd;
// ^ NEW IN 1.60
var Sound m_SurfaceSwitchSnd;
// ^ NEW IN 1.60
var Sound m_sndPlayMissionExtro;
var Sound m_sndPlayMissionIntro;
var class<Emitter> m_BreathingEmitterClass;
// ^ NEW IN 1.60
var Actor m_WeatherViewTarget;
var Sound m_sndMissionComplete;
// ^ NEW IN 1.60
var array<array> m_aMissionObjectives;
// ^ NEW IN 1.60
var float m_fTimeLimit;
// ^ NEW IN 1.60
var bool m_bUseDefaultMoralityRules;
// ^ NEW IN 1.60
var Region RedMenuRegion;
var Material RedMenuSkin;
var Region GreenMenuRegion;
var Material GreenMenuSkin;
//#ifdef R6ACTIONSPOT
var const R6ActionSpot m_ActionSpotList;
var string DefaultGameType;
// ^ NEW IN 1.60
// this bool says whether we want to log bwidth usage
var bool m_bLogBandWidth;
var bool bNeverPrecache;
// ^ NEW IN 1.60
var float m_fTerroSkillMultiplier;
var float m_fRainbowSkillMultiplier;
var string m_szGameTypeShown;
var Vector R6PlanningMinVector;
// ^ NEW IN 1.60
var Vector R6PlanningMaxVector;
// ^ NEW IN 1.60
var int R6PlanningMinLevel;
// ^ NEW IN 1.60
var int R6PlanningMaxLevel;
// ^ NEW IN 1.60
var transient ELevelAction LevelAction;
// ^ NEW IN 1.60
var int HubStackLevel;
var Texture LargeVertex;
var Texture WhiteSquareTexture;
var Texture WireframeTexture;
var Texture DefaultTexture;
var Texture Screenshot;
// ^ NEW IN 1.60
var float Brightness;
// ^ NEW IN 1.60
var float PlayerDoppler;
// ^ NEW IN 1.60
var Rotator CameraRotationDynamic;
// ^ NEW IN 1.60
var Vector CameraLocationSide;
// ^ NEW IN 1.60
var Vector CameraLocationFront;
// ^ NEW IN 1.60
var Vector CameraLocationTop;
// ^ NEW IN 1.60
var Vector CameraLocationDynamic;
// ^ NEW IN 1.60
var float m_fInGamePlanningZoomDistance;
var bool m_bInGamePlanningZoomingOut;
var bool m_bInGamePlanningZoomingIn;
// true if physicsvolume list initialized
var transient const bool bPhysicsVolumesInitialized;
// True if path network is valid
var bool bPathsRebuilt;
// frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool bAggressiveLOD;
// frame rate is below DesiredFrameRate, so drop high detail actors
var bool bDropDetail;
// Only update players.
var bool bPlayersOnly;
// Whether gameplay has begun.
var bool bBegunPlay;
var bool bLonePlayer;
// ^ NEW IN 1.60
// A list of selected groups in the group browser (only used in editor)
var transient string SelectedGroups;
// List of the group names which were checked when the level was last saved
var string VisibleGroups;
var LevelSummary Summary;
var string LocalizedPkg;
// ^ NEW IN 1.60
// Better rag-doll/ground friction model, but more CPU.
var bool bKStaticFriction;
// Allows you to make ragdolls use lower friction than normal.
var float KarmaGravScale;
// Maximum number of simultaneous rag-dolls.
var int MaxRagdolls;
// Ragdoll physics timestep scaling. This is applied on top of KarmaTimeScale.
var float RagdollTimeScale;
// Karma - jag
// Karma physics timestep scaling.
var float KarmaTimeScale;
var bool m_bIsClassicMission;
// ^ NEW IN 1.60
var int m_iNbOfFBToSpawnBasedOnNbPlayers;
// ^ NEW IN 1.60
var int m_iNbOfFreeBackupToSpawn;
// ^ NEW IN 1.60
var int m_iCoughTimes;
// ^ NEW IN 1.60
var float m_fOxygeneStepDecrease;
// ^ NEW IN 1.60
var float m_iCoughSeuil;
// ^ NEW IN 1.60
var float m_fOxygeneTopLevel;
// ^ NEW IN 1.60
var float m_fClignoteTime;
// ^ NEW IN 1.60
var float m_fTempsDetection;
// ^ NEW IN 1.60
var /* replicated */ float m_fCompteurFrameDetection;
// ^ NEW IN 1.60
var /* replicated */ bool m_bShowFloppy;
// ^ NEW IN 1.60
var EPhysicsDetailLevel PhysicsDetailLevel;
// ^ NEW IN 1.60
// time at which to start pause
var float PauseDelay;
// Day of week.
var transient int DayOfWeek;

// --- Functions ---
//============================================================================
// Object GetTerroristMgr -
//============================================================================
function Object GetTerroristMgr() {}
// ^ NEW IN 1.60
// R6CODE+
simulated event PreBeginPlay() {}
//
// Jump the server to a new level.
//
event ServerTravel(bool bItems, string URL) {}
simulated function SetWeatherActive(bool bWeatherActive) {}
final native function AddWritableMapPoint(Vector point, Color C) {}
// ^ NEW IN 1.60
final native function AddEncodedWritableMapStrip(string S) {}
// ^ NEW IN 1.60
final native function AddWritableMapIcon(string Msg) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetHostageMgr: singleton pattern
//
//------------------------------------------------------------------
simulated function Actor GetHostageMgr() {}
// ^ NEW IN 1.60
final native function SetBankSound(ER6SoundState eGameState) {}
// ^ NEW IN 1.60
simulated function GameTypeSaveGameInfo(int iIndex, string szSaveDirectoryName, string szEnglishDirName) {}
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
final native function CallLogThisActor(Actor anActor) {}
// ^ NEW IN 1.60
final native function string GetMapNameLocalisation(string _szMapName) {}
// ^ NEW IN 1.60
//-----------------------------------------------------------------------------
// GetMissionObjLocFile
//   return the string for the MObj or the default one
//-----------------------------------------------------------------------------
function string GetMissionObjLocFile(R6MissionObjectiveBase obj) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetCamSpot
//
//------------------------------------------------------------------
function Actor GetCamSpot(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetGameTypeFromClassName
//
//------------------------------------------------------------------
simulated function string GetGameTypeFromClassName(string szGameClassName) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetRedShortDescription
//
//------------------------------------------------------------------
simulated function string GetRedShortDescription(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetGameTypeClassName
//
//------------------------------------------------------------------
simulated function string GetGameTypeClassName(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetGreenShortDescription
//
//------------------------------------------------------------------
simulated function string GetGreenShortDescription(string szGameType) {}
// ^ NEW IN 1.60
simulated function bool FindSaveDirectoryNameFromEnglish(out string SaveDirectory, string EnglishSaveDir) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetRedTeamObjective
//
//------------------------------------------------------------------
simulated function string GetRedTeamObjective(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetGreenTeamObjective
//
//------------------------------------------------------------------
simulated function string GetGreenTeamObjective(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GameTypeLocalizationFile
//
//------------------------------------------------------------------
function string GameTypeLocalizationFile(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetGameNameLocalization
//
//------------------------------------------------------------------
function string GameTypeToString(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetGameNameLocalization
//
//------------------------------------------------------------------
simulated function string GetGameNameLocalization(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsGameTypeUseRainbowComm
//
//------------------------------------------------------------------
simulated function bool IsGameTypeUseRainbowComm(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsGameTypeUseNotPlayableNPC
//
//------------------------------------------------------------------
simulated event bool IsGameTypePlayWithNonRainbowNPCs(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsGameTypeUsePreRecMessages
//
//------------------------------------------------------------------
simulated function bool IsGameTypeUsePreRecMessages(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsGameTypeSquad
//
//------------------------------------------------------------------
simulated function bool IsGameTypeSquad(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsGameTypeCooperative
//
//------------------------------------------------------------------
simulated function bool IsGameTypeCooperative(string szGameType) {}
// ^ NEW IN 1.60
simulated function bool IsGameTypeTeamAdversarial(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsGameTypeAdversarial
//
//------------------------------------------------------------------
simulated function bool IsGameTypeAdversarial(string szGameType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GameTypeUseNbOfTerroristToSpawn
//
//------------------------------------------------------------------
simulated event bool GameTypeUseNbOfTerroristToSpawn(string szGameType) {}
// ^ NEW IN 1.60
simulated function SetGameTypeDisplayBombTimer(string szGameType) {}
simulated function bool IsGameTypeDisplayBombTimer(string szGameType) {}
// ^ NEW IN 1.60
simulated function AddPhysicsVolume(PhysicsVolume NewPhysicsVolume) {}
simulated function GetGameTypeSaveDirectories(out string SaveDirectory, out string EnglishSaveDir) {}
//
// ensure the DefaultPhysicsVolume class is loaded.
//
function ThisIsNeverExecuted() {}
//------------------------------------------------------------------
// GetGameTypeFromLocName ; The optional parameter is for similar localization name for single and multi.
//
//------------------------------------------------------------------
simulated function string GetGameTypeFromLocName(string szGameTypeLoc, optional bool _bOnlyMulti) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsGameTypeMultiplayer
//
//------------------------------------------------------------------
simulated function bool IsGameTypeMultiplayer(string szGameType, optional bool _bNotIncludeGMI_None) {}
// ^ NEW IN 1.60
simulated function RemovePhysicsVolume(PhysicsVolume DeletedPhysicsVolume) {}
//------------------------------------------------------------------
// ResetLevel
//
//------------------------------------------------------------------
simulated function ResetLevel(int iNbOfRestart) {}
//------------------------------------------------------------------
// GameTypeInfoAdd
//  add the data needed to fill a GameTypeInfo struct
//------------------------------------------------------------------
simulated function GameTypeInfoAdd(string szGameType, string szDisplayAsGameType, EGameModeInfo eGameModeInfoType, bool bTeamAdversarial, bool bUsePreRecMessage, bool bSetNbTerro, bool bPlayWithNonRainbowNPCs, bool bUseRainbowComm, string szLocalizationFile, string szClassName, string szNameLocalization, string szGreenTeamObjective, string szRedTeamObjective, string szGreenShortDescription, string szRedShortDescription, string szToString) {}
//------------------------------------------------------------------
// SetGameTypeStrings
//
//------------------------------------------------------------------
simulated function SetGameTypeStrings() {}
// R6Weather
simulated event PostBeginPlay() {}
final native function NotifyMatchStart() {}
// ^ NEW IN 1.60
function Reset() {}
//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
simulated native function string GetAddressURL() {}
// ^ NEW IN 1.60
final simulated native function PBNotifyServerTravel() {}
// ^ NEW IN 1.60
// R6CODE-
//
// Return the URL of this level on the local machine.
//
simulated native function string GetLocalURL() {}
// ^ NEW IN 1.60
final native function ResetLevelInNative() {}
// ^ NEW IN 1.60
final native function FinalizeLoading() {}
// ^ NEW IN 1.60

defaultproperties
{
}
