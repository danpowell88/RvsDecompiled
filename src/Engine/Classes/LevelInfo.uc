//=============================================================================
// LevelInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
    nativereplication
    placeable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force,R6Weather);

const RDC_CamFirstPerson = 0x01;
const RDC_CamThirdPerson = 0x02;
const RDC_CamFreeThirdP = 0x04;
const RDC_CamGhost = 0x08;
const RDC_CamFadeToBk = 0x10;
const RDC_CamTeamOnly = 0x20;

enum EPhysicsDetailLevel
{
	PDL_Low,                        // 0
	PDL_Medium,                     // 1
	PDL_High                        // 2
};

enum ELevelAction
{
	LEVACT_None,                    // 0
	LEVACT_Loading,                 // 1
	LEVACT_Saving,                  // 2
	LEVACT_Connecting,              // 3
	LEVACT_Precaching               // 4
};

enum ENetMode
{
	NM_Standalone,                  // 0
	NM_DedicatedServer,             // 1
	NM_ListenServer,                // 2
	NM_Client                       // 3
};

enum ER6SoundState
{
	BANK_UnloadGun,                 // 0
	BANK_UnloadAll                  // 1
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

struct WritableMapVertex
{
	var Vector Position;
	var Color Color;
};

struct WritableMapStroke
{
	var float TimeStamp;
	var int numPoints;
};

struct WritableMapIcon
{
	var float TimeStamp;
	var int iIconIndex;
	var Color Color;
	var int iPosX;
	var int iPosY;
};

struct GameTypeInfo
{
    // **** if modified, update this struct in AZoneInfo.h ****
	var string m_szGameType;
	var string m_szDisplayAsGameType;
	var Actor.EGameModeInfo m_eGameModeInfo;
	var bool m_bTeamAdversarial;
	var bool m_bUsePreRecMessages;
	var bool m_bCanSetNbOfTerroristToSpawn;
	var bool m_bPlayWithNonRainbowNPCs;
	var bool m_bUseRainbowComm;
	var bool m_bDisplayBombTimer;
	var string m_szNameLocalization;
	var string m_szClassName;
	var string m_szGreenTeamObjective;
	var string m_szRedTeamObjective;
	var string m_szGreenShortDescription;
	var string m_szRedShortDescription;
	var string m_szToString;
	var string m_szSaveDirectoryName;
	var string m_szEnglishDirName;
	var string m_szLocalizationFile;
};

// NEW IN 1.60
var LevelInfo.EPhysicsDetailLevel PhysicsDetailLevel;  // Physics simulation detail level (Low/Medium/High)
// NEW IN 1.60
var LevelInfo.ENetMode NetMode;  // Current network mode (Standalone/DedicatedServer/ListenServer/Client)
var(R6Sound) Actor.ETerroristNationality m_eTerroristVoices;  // Terrorist voice for the map.
var(R6Sound) Actor.EHostageNationality m_eHostageVoices;  // Terrorist voice for the map.
// NEW IN 1.60
var(R6GazAlertMode) int m_iCoughTimes;  // Number of cough events triggered per gas-alert cycle
// NEW IN 1.60
var(FreeBackupMode) int m_iNbOfFreeBackupToSpawn;  // Number of free-backup NPCs to spawn in free-backup game mode
// NEW IN 1.60
var(FreeBackupMode) int m_iNbOfFBToSpawnBasedOnNbPlayers;  // Additional free-backup NPCs scaled to the current player count
var int MaxRagdolls;  // Maximum number of simultaneous rag-dolls.
var int HubStackLevel;  // Level index in the hub travel stack
//R6 change level in planning
var(R6Planning) int R6PlanningMaxLevel;  // Highest floor level index available in the planning map
var(R6Planning) int R6PlanningMinLevel;  // Lowest floor level index available in the planning map
var int m_iMotionBlurIntensity;  // Motion blur strength (0 = disabled)
var int m_iLimitedSFXCount;  // Maximum number of simultaneous limited-budget sound effects
//#ifdef R6PUNKBUSTER
//__WITH_PB__
var int iPBEnabled;  // 1 means PB server is running, 0 means not activated or deactivate cmd given but still running
// NEW IN 1.60
var bool m_bShowFloppy;  // If true, show the saving-in-progress floppy disk icon
// NEW IN 1.60
var(ClassicMission) bool m_bIsClassicMission;  // True for Classic-mode missions (original R6 rules)
var bool bKStaticFriction;  // Better rag-doll/ground friction model, but more CPU.
var() bool bKNoInit;  // Start _NO_ Karma for this level. Only really for the Entry level.
var() bool bLonePlayer;  // No multiplayer coordination, i.e. for entranceways.
var bool bBegunPlay;  // Whether gameplay has begun.
var bool bPlayersOnly;  // Only update players.
var bool bHighDetailMode;  // Client high-detail mode.
var bool bDropDetail;  // frame rate is below DesiredFrameRate, so drop high detail actors
var bool bAggressiveLOD;  // frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool bStartup;  // Starting gameplay.
var bool bPathsRebuilt;  // True if path network is valid
//R6InGamePLanning
var bool m_bInGamePlanningActive;  // True while the in-game planning overlay is open
var bool m_bInGamePlanningZoomingIn;  // True while the planning overlay is animating a zoom-in
var bool m_bInGamePlanningZoomingOut;  // True while the planning overlay is animating a zoom-out
var bool m_bGameTypesInitialized;  // True after the game-type info array has been populated
//-----------------------------------------------------------------------------
// Renderer Management.
var() bool bNeverPrecache;  // If true, skip texture/mesh pre-caching for this level
var bool m_bLogBandWidth;  // this bool says whether we want to log bwidth usage
var bool bNextItems;  // Internal flag used during sequential item iteration
//R6MissionObjectives 
var(R6MissionObjectives) bool m_bUseDefaultMoralityRules;  // If true, apply default morality scoring rules for this mission
//#ifdef R6DBGVECTORINFO
var bool m_bShowDebugLine;  // Debug: render the debug vector line each frame
//R6NEWRENDERERFEATURES
var bool m_bShowDebugLights;  // Debug: visualise dynamic light sources
var bool m_bShowDebugLODs;  // Debug: visualise level-of-detail transitions
var bool m_bShowOnlyTransparentSM;  // Debug: render only transparent static meshes
var bool m_bNightVisionActive;  // True while night-vision post-process is active
var bool m_bHeatVisionActive;  // True while heat-vision (thermal) post-process is active
var bool m_bScopeVisionActive;  // True while a weapon scope view is active
var bool m_bAllow3DRendering;  // Master switch; false disables the 3D scene render
var bool m_bSkipMotionBlur;  // used to avoid blur in menus
// R6SOUND
var bool m_bPlaySound;  // If false, all level audio is suppressed
var bool m_bCanStartStartingSound;  // True once the engine is ready to play the level intro sound
var bool m_bSoundFadeFinish;  // True when the sound fade-out has completed
var bool m_bIsResettingLevel;  // True while the level is in the process of a full reset
var bool m_bPBSvRunning;  // true means running, false means not running
//R6HEARTBEAT
var bool m_bHeartBeatOn;  // True while the heartbeat sensor is active
// Time passage.
var() float TimeDilation;  // Normally 1 - scales real time passage.
// Current time.
var float TimeSeconds;  // Time in seconds since level began play.
var float PauseDelay;  // time at which to start pause
// NEW IN 1.60
var float m_fCompteurFrameDetection;  // Frame counter used by the virus-upload detection timer
// NEW IN 1.60
var(MP2VirusUpload) float m_fTempsDetection;  // Time in seconds required for virus upload detection
// NEW IN 1.60
var(MP2VirusUpload) float m_fClignoteTime;  // Blink interval in seconds for the virus-upload indicator
// NEW IN 1.60
var(R6GazAlertMode) float m_fOxygeneTopLevel;  // Maximum oxygen level before gas alert begins decreasing it
// NEW IN 1.60
var(R6GazAlertMode) float m_iCoughSeuil;  // Oxygen threshold at which pawns begin coughing
// NEW IN 1.60
var(R6GazAlertMode) float m_fOxygeneStepDecrease;  // Amount oxygen decreases per step in gas alert mode
// Karma - jag
var float KarmaTimeScale;  // Karma physics timestep scaling.
var float RagdollTimeScale;  // Ragdoll physics timestep scaling. This is applied on top of KarmaTimeScale.
var float KarmaGravScale;  // Allows you to make ragdolls use lower friction than normal.
var float m_fInGamePlanningZoomDistance;  // Camera distance used when the planning overlay is zoomed in
var(Audio) float PlayerDoppler;  // Player doppler shift, 0=none, 1=full.
var() float Brightness;  // Ambient brightness for the level (0.0-1.0)
var float m_fRainbowSkillMultiplier;  // Global skill scaling factor applied to Rainbow operators
var float m_fTerroSkillMultiplier;  // Global skill scaling factor applied to terrorist NPCs
var float NextSwitchCountdown;  // Remaining time in seconds before the next map switch
var(R6MissionObjectives) float m_fTimeLimit;  // Mission time limit in seconds (0 = no limit)
var(R6Sound) float m_fEndGamePauseTime;  // Pause duration in seconds before end-of-game state transition
var float m_fDbgNavPointDistance;  // debug: max distance to player for displaying nav point.
var float m_fDistanceHeartBeatVisible;  // Maximum distance at which heartbeat sensor blips are visible
var PlayerReplicationInfo Pauser;  // If paused, name of person pausing the game.
var LevelSummary Summary;  // Level summary info (title, author, description)
var() Texture Screenshot;  // Screenshot texture displayed on the level selection screen
var Texture DefaultTexture;  // Fallback texture applied to surfaces with no material
var Texture WireframeTexture;  // Texture used to render surfaces in wireframe editor mode
var Texture WhiteSquareTexture;  // Solid white utility texture used for debug rendering
var Texture LargeVertex;  // Large vertex indicator texture used in editor selection
var GameInfo Game;  // Reference to the active GameInfo actor controlling the current game rules
var const NavigationPoint NavigationPointList;  // Linked list of all navigation points in the level
var const Controller ControllerList;  // Linked list of all active controllers in the level
var PhysicsVolume PhysicsVolumeList;  // Linked list of all physics volumes in the level
//#ifdef R6ACTIONSPOT
var const R6ActionSpot m_ActionSpotList;  // Linked list of all R6ActionSpot actors in the level
//Skin names received by the client. If package does not exist, it will be downloaded.
var Material GreenTeamSkin;  // Skin assets received by the client; missing packages are downloaded on connect
var Material GreenHeadSkin;
var Material GreenGogglesSkin;
var Material GreenHandSkin;
var Material GreenMenuSkin;
var Mesh GreenMesh;
var StaticMesh GreenHelmetMesh;
var Material GreenHelmetSkin;
var Material RedTeamSkin;
var Material RedHeadSkin;
var Material RedGogglesSkin;
var Material RedHandSkin;
var Material RedMenuSkin;
var Mesh RedMesh;
var StaticMesh RedHelmetMesh;
var Material RedHelmetSkin;
var(R6MissionObjectives) Sound m_sndMissionComplete;  // Sound played on mission success
//R6Weather
var Emitter m_WeatherEmitter;  // Spawned weather particle emitter actor
var Actor m_WeatherViewTarget;  // Actor used as the weather emitter's view reference
var Sound m_sndPlayMissionIntro;  // Sound played at the start of the mission briefing
var Sound m_sndPlayMissionExtro;  // Sound played at the end-of-mission debriefing
var(R6Sound) Sound m_SurfaceSwitchSnd;  // Sound event containing all the surface sounds - EB April 6th, 2002
var(R6Sound) Sound m_SurfaceSwitchForOtherPawnSnd;  // Sound event containing all the surface sounds for the other pawn- SD July 30th, 2002
var(R6Sound) Sound m_BodyFallSwitchSnd;  // Sound contain only the body fall sounds for player - SD
var(R6Sound) Sound m_BodyFallSwitchForOtherPawnSnd;  // Sound contain only the body fall sounds for the other pawn- SD
var(R6Sound) Sound m_StartingMusic;  // When the Music is set in the level the music is play at the beginning of the game.
var R6DecalManager m_DecalManager;  // Manager actor for bullet-hole and blood decals
var Texture m_pScopeMaskTexture;  // Mask texture applied around the scope view
var Texture m_pScopeAddTexture;  // Additive texture for the scope lens overlay
var R6AbstractHostageMgr m_hostageMgr;  // there's only one instance of hostageMgr
var R6AbstractTerroristMgr m_terroristMgr;  // Manager actor coordinating all terrorist NPCs
var(R6SFX) Material m_pProneTrailMaterial;  // Material rendered as the pawn's prone crawl trail
var R6ServerInfo m_ServerSettings;  // Server configuration info actor
var R6LimitedSFX m_aLimitedSFX[6];  // Pool of limited-budget SFX slots to cap simultaneous sound effects
// #ifdef R6WRITABLEMAP
var(R6DrawingTool) Texture m_tWritableMapTexture;  // Runtime render target texture for the writable tactical map
// NEW IN 1.60
var Class<StaticMeshActor> GreenHelmet;
// NEW IN 1.60
var Class<StaticMeshActor> RedHelmet;
var(R6LevelWeather) Class<R6WeatherEmitter> m_WeatherEmitterClass;  // Emitter class used to spawn the level weather effect
var Class<R6WeatherEmitter> m_RepWeatherEmitterClass;  // Replicated weather emitter class (sent to clients)
//R6Breathing
var(R6Breathing) Class<Emitter> m_BreathingEmitterClass;  // Emitter class for visible breath fog in cold environments
var(R6MissionObjectives) editinline array<editinline R6MissionObjectiveBase> m_aMissionObjectives;  // List of mission objective actors for this level
var array<WritableMapVertex> m_aCurrentStrip;  // Vertex buffer for the stroke currently being drawn on the map
var array<WritableMapVertex> m_aWritableMapStrip;  // Committed vertex strips on the writable map
var array<WritableMapStroke> m_aWritableMapTimeStamp;  // Timestamps for each committed map stroke (for timed fade-out)
var array<WritableMapIcon> m_aWritableMapIcons;  // Icon stamps placed on the writable tactical map
var array<GameTypeInfo> m_aGameTypeInfo;  // Descriptions of all available game-types for this level
//-----------------------------------------------------------------------------
// Legend - used for saving the viewport camera positions
var() Vector CameraLocationDynamic;  // Editor viewport camera position for the dynamic (perspective) view
var() Vector CameraLocationTop;  // Editor viewport camera position for the top-down orthographic view
var() Vector CameraLocationFront;  // Editor viewport camera position for the front orthographic view
var() Vector CameraLocationSide;  // Editor viewport camera position for the side orthographic view
var() Rotator CameraRotationDynamic;  // Editor viewport camera rotation for the dynamic (perspective) view
var(R6Planning) Vector R6PlanningMaxVector;  // World-space AABB maximum corner for the planning map extent
var(R6Planning) Vector R6PlanningMinVector;  // World-space AABB minimum corner for the planning map extent
var Region GreenMenuRegion;  // Zone region used by the Green team menu/insertion display
var Region RedMenuRegion;  // Zone region used by the Red team menu/insertion display
var(R6Sound) SoundZoneAudibleZones m_SoundZoneAudibleZones[64];  // Per-zone bitmask arrays defining which zones are acoustically connected
var Vector m_vPredVector;  // Prediction vector used for extrapolating movement in network play
var Vector m_vPredPredVector;  // Second-order prediction vector for smoother network extrapolation
var() localized string Title;  // Localised display name of this level
var() string Author;  // Who built it.
var() localized string LevelEnterText;  // Message to tell players when they enter.
var() string LocalizedPkg;  // Package to look in for localizations.
var string VisibleGroups;  // List of the group names which were checked when the level was last saved
var(Audio) string Song;  // Filename of the streaming song.
var string m_szGameTypeShown;  // Display string of the current game type shown in UI
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion;  // Engine version.
var string MinNetVersion;  // Min engine version that is net compatible.
var() string DefaultGameType;  // Class name of the default game-type to use if none is specified
var string NextURL;  // URL to travel to at end-of-round or map switch
//R6 Multiplayer SKINS
var(R6MultiPlayerSkins) string GreenTeamPawnClass;  // Class name of the Green team pawn for multiplayer
var(R6MultiPlayerSkins) string RedTeamPawnClass;  // Class name of the Red team pawn for multiplayer
var(R6MissionObjectives) string m_szMissionObjLocalization;  // Localisation key prefix for mission objective text strings
var(R6Sound) string m_csVoicesOneLinersBankName;  // Sound bank name for NPC one-liner voice clips
// NEW IN 1.60
var transient LevelInfo.ELevelAction LevelAction;  // Current loading/saving/connecting state (used by HUD level-action display)
var transient int Year;  // Year.
var transient int Month;  // Month.
var transient int Day;  // Day of month.
var transient int DayOfWeek;  // Day of week.
var transient int Hour;  // Hour.
var transient int Minute;  // Minute.
var transient int Second;  // Second.
var transient int Millisecond;  // Millisecond.
var const transient bool bPhysicsVolumesInitialized;  // true if physicsvolume list initialized
var transient string SelectedGroups;  // A list of selected groups in the group browser (only used in editor)

replication
{
	// Pos:0x000
	reliable if((bNetDirty && (int(Role) == int(ROLE_Authority))))
		Pauser, TimeDilation;

	// Pos:0x018
	reliable if((int(Role) == int(ROLE_Authority)))
		m_RepWeatherEmitterClass;

	// Pos:0x025
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bShowFloppy, m_fCompteurFrameDetection;
}

// Export ULevelInfo::execAddWritableMapPoint(FFrame&, void* const)
native(2801) final function AddWritableMapPoint(Vector point, Color C);

// Export ULevelInfo::execAddEncodedWritableMapStrip(FFrame&, void* const)
native(2802) final function AddEncodedWritableMapStrip(string S);

// Export ULevelInfo::execAddWritableMapIcon(FFrame&, void* const)
native(1608) final function AddWritableMapIcon(string Msg);

// Export ULevelInfo::execSetBankSound(FFrame&, void* const)
native(2711) final function SetBankSound(LevelInfo.ER6SoundState eGameState);

// Export ULevelInfo::execFinalizeLoading(FFrame&, void* const)
native(1604) final function FinalizeLoading();

// Export ULevelInfo::execResetLevelInNative(FFrame&, void* const)
native(1515) final function ResetLevelInNative();

// Export ULevelInfo::execCallLogThisActor(FFrame&, void* const)
native(1516) final function CallLogThisActor(Actor anActor);

// Export ULevelInfo::execGetMapNameLocalisation(FFrame&, void* const)
// NEW IN 1.60
native(1518) final function string GetMapNameLocalisation(string _szMapName);

//------------------------------------------------------------------
// GameTypeUseNbOfTerroristToSpawn
//	
//------------------------------------------------------------------
simulated event bool GameTypeUseNbOfTerroristToSpawn(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4D [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x43
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_bCanSetNbOfTerroristToSpawn;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsGameTypeMultiplayer
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeMultiplayer(string szGameType, optional bool _bNotIncludeGMI_None)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x7A [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x70
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			// End:0x57
			if(_bNotIncludeGMI_None)
			{
				// End:0x57
				if((int(m_aGameTypeInfo[i].m_eGameModeInfo) == int(0)))
				{
					return false;
				}
			}
			return (int(m_aGameTypeInfo[i].m_eGameModeInfo) != int(1));
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsGameTypeAdversarial
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeAdversarial(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x54 [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x4A
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return (int(m_aGameTypeInfo[i].m_eGameModeInfo) == int(3));
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

simulated function bool IsGameTypeTeamAdversarial(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4D [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x43
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_bTeamAdversarial;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsGameTypeCooperative
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeCooperative(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x54 [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x4A
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return (int(m_aGameTypeInfo[i].m_eGameModeInfo) == int(2));
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsGameTypeSquad
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeSquad(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x54 [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x4A
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return (int(m_aGameTypeInfo[i].m_eGameModeInfo) == int(4));
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsGameTypeUsePreRecMessages
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeUsePreRecMessages(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4D [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x43
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_bUsePreRecMessages;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsGameTypeUseNotPlayableNPC
//	
//------------------------------------------------------------------
simulated event bool IsGameTypePlayWithNonRainbowNPCs(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4D [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x43
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_bPlayWithNonRainbowNPCs;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsGameTypeUseRainbowComm
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeUseRainbowComm(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4D [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x43
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_bUseRainbowComm;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// GetGameNameLocalization
//	
//------------------------------------------------------------------
simulated function string GetGameNameLocalization(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4C [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x42
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_szNameLocalization;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return "";
	return;
}

//------------------------------------------------------------------
// GetGameNameLocalization
//	
//------------------------------------------------------------------
function string GameTypeToString(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4C [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x42
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_szToString;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return "";
	return;
}

//------------------------------------------------------------------
// GameTypeLocalizationFile
//	
//------------------------------------------------------------------
function string GameTypeLocalizationFile(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4C [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x42
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_szLocalizationFile;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return "";
	return;
}

//------------------------------------------------------------------
// GetGreenTeamObjective
//	
//------------------------------------------------------------------
simulated function string GetGreenTeamObjective(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4C [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x42
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_szGreenTeamObjective;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return "";
	return;
}

//------------------------------------------------------------------
// GetRedTeamObjective
//	
//------------------------------------------------------------------
simulated function string GetRedTeamObjective(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4C [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x42
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_szRedTeamObjective;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return "";
	return;
}

//------------------------------------------------------------------
// GetGreenShortDescription
//	
//------------------------------------------------------------------
simulated function string GetGreenShortDescription(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4C [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x42
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_szGreenShortDescription;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return "";
	return;
}

//------------------------------------------------------------------
// GetRedShortDescription
//	
//------------------------------------------------------------------
simulated function string GetRedShortDescription(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4C [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x42
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_szRedShortDescription;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return "";
	return;
}

//------------------------------------------------------------------
// GetGameTypeFromClassName
//	
//------------------------------------------------------------------
simulated function string GetGameTypeFromClassName(string szGameClassName)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4C [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x42
		if((m_aGameTypeInfo[i].m_szClassName == szGameClassName))
		{
			return m_aGameTypeInfo[i].m_szGameType;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return "";
	return;
}

//------------------------------------------------------------------
// GetGameTypeClassName
//	
//------------------------------------------------------------------
simulated function string GetGameTypeClassName(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4C [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x42
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_szClassName;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return "";
	return;
}

simulated function GetGameTypeSaveDirectories(out string SaveDirectory, out string EnglishSaveDir)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x70 [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x66
		if((m_aGameTypeInfo[i].m_szGameType == Game.m_szGameTypeFlag))
		{
			SaveDirectory = m_aGameTypeInfo[i].m_szSaveDirectoryName;
			EnglishSaveDir = m_aGameTypeInfo[i].m_szEnglishDirName;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

simulated function bool FindSaveDirectoryNameFromEnglish(out string SaveDirectory, string EnglishSaveDir)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x53 [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x49
		if((EnglishSaveDir == m_aGameTypeInfo[i].m_szEnglishDirName))
		{
			SaveDirectory = m_aGameTypeInfo[i].m_szSaveDirectoryName;
			return true;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// GetGameTypeFromLocName ; The optional parameter is for similar localization name for single and multi.
//	
//------------------------------------------------------------------
simulated function string GetGameTypeFromLocName(string szGameTypeLoc, optional bool _bOnlyMulti)
{
	local int i;
	local bool bFind;

	bFind = true;
	i = 0;
	J0x0F:

	// End:0x85 [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x7B
		if((m_aGameTypeInfo[i].m_szNameLocalization ~= szGameTypeLoc))
		{
			// End:0x61
			if(_bOnlyMulti)
			{
				bFind = (int(m_aGameTypeInfo[i].m_eGameModeInfo) != int(1));
			}
			// End:0x7B
			if(bFind)
			{
				return m_aGameTypeInfo[i].m_szGameType;
			}
		}
		(i++);
		// [Loop Continue]
		goto J0x0F;
	}
	return "RGM_NoRulesMode";
	return;
}

//------------------------------------------------------------------
// GetHostageMgr: singleton pattern
//	
//------------------------------------------------------------------
simulated function Actor GetHostageMgr()
{
	local Class<R6AbstractHostageMgr> DesiredHostageMgrClass;
	local R6ModMgr pModManager;

	// End:0xA6
	if((m_hostageMgr == none))
	{
		pModManager = Class'Engine.Actor'.static.GetModMgr();
		// End:0x6B
		if((pModManager.m_pCurrentMod.m_HostageMgrToSpawn != ""))
		{
			DesiredHostageMgrClass = Class<R6AbstractHostageMgr>(DynamicLoadObject(pModManager.m_pCurrentMod.m_HostageMgrToSpawn, Class'Core.Class'));			
		}
		else
		{
			DesiredHostageMgrClass = Class<R6AbstractHostageMgr>(DynamicLoadObject("R6Engine.R6HostageMgr", Class'Core.Class'));
		}
		m_hostageMgr = Spawn(DesiredHostageMgrClass);
	}
	return m_hostageMgr;
	return;
}

//============================================================================
// Object GetTerroristMgr - 
//============================================================================
function Object GetTerroristMgr()
{
	local Class<R6AbstractTerroristMgr> mgrClass;

	// End:0x59
	if((m_terroristMgr == none))
	{
		mgrClass = Class<R6AbstractTerroristMgr>(DynamicLoadObject("R6Engine.R6TerroristMgr", Class'Core.Class'));
		m_terroristMgr = new mgrClass;
		m_terroristMgr.Initialization(self);
	}
	return m_terroristMgr;
	return;
}

//------------------------------------------------------------------
// GameTypeInfoAdd
//  add the data needed to fill a GameTypeInfo struct
//------------------------------------------------------------------
simulated function GameTypeInfoAdd(string szGameType, string szDisplayAsGameType, Actor.EGameModeInfo eGameModeInfoType, bool bTeamAdversarial, bool bUsePreRecMessage, bool bSetNbTerro, bool bPlayWithNonRainbowNPCs, bool bUseRainbowComm, string szLocalizationFile, string szClassName, string szNameLocalization, string szGreenTeamObjective, string szRedTeamObjective, string szGreenShortDescription, string szRedShortDescription, string szToString)
{
	local int Index;
	local GameTypeInfo GameTypeToAdd;

	Index = 0;
	J0x07:

	// End:0x3D [Loop If]
	if((Index < m_aGameTypeInfo.Length))
	{
		// End:0x33
		if((m_aGameTypeInfo[Index].m_szGameType == szGameType))
		{
			return;
		}
		(Index++);
		// [Loop Continue]
		goto J0x07;
	}
	GameTypeToAdd.m_eGameModeInfo = eGameModeInfoType;
	GameTypeToAdd.m_bTeamAdversarial = bTeamAdversarial;
	GameTypeToAdd.m_bUsePreRecMessages = bUsePreRecMessage;
	GameTypeToAdd.m_bCanSetNbOfTerroristToSpawn = bSetNbTerro;
	GameTypeToAdd.m_bPlayWithNonRainbowNPCs = bPlayWithNonRainbowNPCs;
	GameTypeToAdd.m_bUseRainbowComm = bUseRainbowComm;
	GameTypeToAdd.m_szGameType = szGameType;
	GameTypeToAdd.m_szDisplayAsGameType = szDisplayAsGameType;
	GameTypeToAdd.m_szLocalizationFile = szLocalizationFile;
	GameTypeToAdd.m_szClassName = szClassName;
	GameTypeToAdd.m_szNameLocalization = szNameLocalization;
	GameTypeToAdd.m_szGreenTeamObjective = szGreenTeamObjective;
	GameTypeToAdd.m_szRedTeamObjective = szRedTeamObjective;
	GameTypeToAdd.m_szGreenShortDescription = szGreenShortDescription;
	GameTypeToAdd.m_szRedShortDescription = szRedShortDescription;
	GameTypeToAdd.m_szToString = szToString;
	m_aGameTypeInfo[Index] = GameTypeToAdd;
	return;
}

simulated function GameTypeSaveGameInfo(int iIndex, string szSaveDirectoryName, string szEnglishDirName)
{
	assert((iIndex < m_aGameTypeInfo.Length));
	m_aGameTypeInfo[iIndex].m_szSaveDirectoryName = szSaveDirectoryName;
	m_aGameTypeInfo[iIndex].m_szEnglishDirName = szEnglishDirName;
	return;
}

//------------------------------------------------------------------
// SetGameTypeStrings 
//  
//------------------------------------------------------------------
simulated function SetGameTypeStrings()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x191 [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x73
		if((m_aGameTypeInfo[i].m_szGreenTeamObjective != ""))
		{
			m_aGameTypeInfo[i].m_szGreenTeamObjective = Localize(m_aGameTypeInfo[i].m_szToString, "GreenTeamObj", m_aGameTypeInfo[i].m_szGreenTeamObjective);
		}
		// End:0xCD
		if((m_aGameTypeInfo[i].m_szRedTeamObjective != ""))
		{
			m_aGameTypeInfo[i].m_szRedTeamObjective = Localize(m_aGameTypeInfo[i].m_szToString, "RedTeamObj", m_aGameTypeInfo[i].m_szRedTeamObjective);
		}
		// End:0x12B
		if((m_aGameTypeInfo[i].m_szGreenShortDescription != ""))
		{
			m_aGameTypeInfo[i].m_szGreenShortDescription = Localize(m_aGameTypeInfo[i].m_szToString, "GreenShortDesc", m_aGameTypeInfo[i].m_szGreenShortDescription);
		}
		// End:0x187
		if((m_aGameTypeInfo[i].m_szRedShortDescription != ""))
		{
			m_aGameTypeInfo[i].m_szRedShortDescription = Localize(m_aGameTypeInfo[i].m_szToString, "RedShortDesc", m_aGameTypeInfo[i].m_szRedShortDescription);
		}
		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

simulated function SetGameTypeDisplayBombTimer(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x51 [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x47
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			m_aGameTypeInfo[i].m_bDisplayBombTimer = true;
			// [Explicit Break]
			goto J0x51;
		}
		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	J0x51:

	return;
}

simulated function bool IsGameTypeDisplayBombTimer(string szGameType)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4D [Loop If]
	if((i < m_aGameTypeInfo.Length))
	{
		// End:0x43
		if((m_aGameTypeInfo[i].m_szGameType == szGameType))
		{
			return m_aGameTypeInfo[i].m_bDisplayBombTimer;
		}
		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

// R6CODE+
simulated event PreBeginPlay()
{
	local R6ModMgr pModMgr;
	local R6Mod pCurrentMod;

	// End:0x0B
	if(m_bGameTypesInitialized)
	{
		return;
	}
	m_bGameTypesInitialized = true;
	pModMgr = Class'Engine.Actor'.static.GetModMgr();
	pModMgr.AddGameTypes(self);
	return;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	local R6DecalManager aMgr;

	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super.ResetOriginalData();
	aMgr = m_DecalManager;
	m_DecalManager = none;
	// End:0x3F
	if((aMgr != none))
	{
		aMgr.Destroy();
	}
	m_bCanStartStartingSound = false;
	// End:0x69
	if((!Level.bKNoInit))
	{
		m_DecalManager = Spawn(Class'Engine.R6DecalManager');
	}
	// End:0x83
	if((m_terroristMgr != none))
	{
		m_terroristMgr.ResetOriginalData();
	}
	m_bInGamePlanningActive = false;
	return;
}

// Export ULevelInfo::execGetLocalURL(FFrame&, void* const)
// R6CODE-
//
// Return the URL of this level on the local machine.
//
native simulated function string GetLocalURL();

// Export ULevelInfo::execPBNotifyServerTravel(FFrame&, void* const)
//#ifdef R6PUNKBUSTER
//__WITH_PB__
native(1319) final simulated function PBNotifyServerTravel();

// Export ULevelInfo::execGetAddressURL(FFrame&, void* const)
//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
native simulated function string GetAddressURL();

//
// Jump the server to a new level.
//
event ServerTravel(string URL, bool bItems)
{
	// End:0x57
	if((NextURL == ""))
	{
		bNextItems = bItems;
		NextURL = URL;
		// End:0x4C
		if((Game != none))
		{
			Game.ProcessServerTravel(URL, bItems);			
		}
		else
		{
			NextSwitchCountdown = 0.0000000;
		}
	}
	return;
}

//
// ensure the DefaultPhysicsVolume class is loaded.
//
function ThisIsNeverExecuted()
{
	local DefaultPhysicsVolume P;

	P = none;
	return;
}

function Reset()
{
	GarbageCollect();
	super(Actor).Reset();
	return;
}

simulated function AddPhysicsVolume(PhysicsVolume NewPhysicsVolume)
{
	local PhysicsVolume V;

	V = PhysicsVolumeList;
	J0x0B:

	// End:0x3E [Loop If]
	if((V != none))
	{
		// End:0x27
		if((V == NewPhysicsVolume))
		{
			return;
		}
		V = V.NextPhysicsVolume;
		// [Loop Continue]
		goto J0x0B;
	}
	NewPhysicsVolume.NextPhysicsVolume = PhysicsVolumeList;
	PhysicsVolumeList = NewPhysicsVolume;
	return;
}

simulated function RemovePhysicsVolume(PhysicsVolume DeletedPhysicsVolume)
{
	local PhysicsVolume V, Prev;

	V = PhysicsVolumeList;
	J0x0B:

	// End:0x88 [Loop If]
	if((V != none))
	{
		// End:0x66
		if((V == DeletedPhysicsVolume))
		{
			// End:0x47
			if((Prev == none))
			{
				PhysicsVolumeList = V.NextPhysicsVolume;				
			}
			else
			{
				Prev.NextPhysicsVolume = V.NextPhysicsVolume;
			}
			return;
		}
		Prev = V;
		V = V.NextPhysicsVolume;
		// [Loop Continue]
		goto J0x0B;
	}
	return;
}

// Export ULevelInfo::execNotifyMatchStart(FFrame&, void* const)
//R6ARMPATCHES
native(2612) final function NotifyMatchStart();

//------------------------------------------------------------------
// GetCamSpot
//	
//------------------------------------------------------------------
function Actor GetCamSpot(string szGameType)
{
	local Actor StartSpot;

	// End:0x42
	foreach AllActors(Class'Engine.Actor', StartSpot)
	{
		// End:0x41
		if((StartSpot.IsA('R6CameraSpot') && StartSpot.IsAvailableInGameType(szGameType)))
		{			
			return StartSpot;
		}		
	}	
	return none;
	return;
}

//------------------------------------------------------------------
// ResetLevel
//	
//------------------------------------------------------------------
simulated function ResetLevel(int iNbOfRestart)
{
	local Actor aActor;
	local Pawn aPawn;
	local Controller C, pNextController;
	local PlayerController PC;

	Log((("Resetting Level (total=", string(iNbOfRestart)) $ ")" $ ???));
	m_bIsResettingLevel = true;
	// End:0x51
	foreach AllActors(Class'Engine.Actor', aActor)
	{
		aActor.FirstPassReset();		
	}	
	// End:0x16A
	if((int(NetMode) != int(NM_Client)))
	{
		C = Level.ControllerList;
		J0x76:

		// End:0x16A [Loop If]
		if((C != none))
		{
			PC = PlayerController(C);
			// End:0xB0
			if((PC != none))
			{
				PC.ResettingLevel(iNbOfRestart);
			}
			// End:0x10E
			if((C.Pawn != none))
			{
				aPawn = C.Pawn;
				// End:0xF2
				if((PC != none))
				{
					PC.UnPossess();
				}
				aPawn.Destroy();
				C.Pawn = none;
			}
			pNextController = C.nextController;
			// End:0x140
			if((PC != none))
			{
				C.GotoState('BaseSpectating');				
			}
			else
			{
				// End:0x15C
				if((AIController(C) != none))
				{
					C.Destroy();
				}
			}
			C = pNextController;
			// [Loop Continue]
			goto J0x76;
		}
	}
	// End:0x1A0
	if(m_bResetSystemLog)
	{
		Log("RESET: ResetOriginalData of all actors...");
	}
	// End:0x1FA
	foreach AllActors(Class'Engine.Actor', aActor)
	{
		// End:0x1EA
		if((aActor.bTearOff || aActor.m_bDeleteOnReset))
		{
			// End:0x1E7
			if((!aActor.Destroy()))
			{
			}
			// End:0x1F9
			continue;
		}
		aActor.ResetOriginalData();		
	}	
	ResetLevelInNative();
	GarbageCollect();
	// End:0x243
	foreach AllActors(Class'Engine.Actor', aActor)
	{
		// End:0x242
		if(((PlayerController(aActor) == none) && (GameInfo(aActor) == none)))
		{
			aActor.SetInitialState();
		}		
	}	
	StopAllSounds();
	// End:0x266
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		StopAllMusic();
	}
	ResetVolume_AllTypeSound();
	m_bIsResettingLevel = false;
	return;
}

//-----------------------------------------------------------------------------
// GetMissionObjLocFile
//   return the string for the MObj or the default one
//-----------------------------------------------------------------------------
function string GetMissionObjLocFile(R6MissionObjectiveBase obj)
{
	// End:0x31
	if(((obj != none) && (obj.m_szMissionObjLocalization != "")))
	{
		return obj.m_szMissionObjLocalization;
	}
	return m_szMissionObjLocalization;
	return;
}

// R6Weather
simulated event PostBeginPlay()
{
	// End:0x1B
	if((int(NetMode) != int(NM_Client)))
	{
		m_RepWeatherEmitterClass = m_WeatherEmitterClass;
	}
	// End:0x58
	if((((int(NetMode) == int(NM_Standalone)) || (int(NetMode) == int(NM_ListenServer))) && (m_WeatherEmitterClass != none)))
	{
		m_WeatherEmitter = Spawn(m_WeatherEmitterClass);
	}
	GetTerroristMgr();
	return;
}

simulated function SetWeatherActive(bool bWeatherActive)
{
	// End:0x64
	if((bWeatherActive && (m_WeatherEmitter.Emitters[0].m_iPaused == 1)))
	{
		m_WeatherEmitter.Emitters[0].m_iPaused = 0;
		m_WeatherEmitter.Emitters[0].AllParticlesDead = false;		
	}
	else
	{
		// End:0xC7
		if(((!bWeatherActive) && (m_WeatherEmitter.Emitters[0].m_iPaused == 0)))
		{
			m_WeatherEmitter.Emitters[0].m_iPaused = 1;
			m_WeatherEmitter.Emitters[0].AllParticlesDead = false;
		}
	}
	return;
}

defaultproperties
{
	PhysicsDetailLevel=1
	m_iNbOfFBToSpawnBasedOnNbPlayers=3
	MaxRagdolls=32
	R6PlanningMinLevel=65535
	bKStaticFriction=true
	bHighDetailMode=true
	m_bUseDefaultMoralityRules=true
	m_bAllow3DRendering=true
	m_bPlaySound=true
	TimeDilation=1.0000000
	KarmaTimeScale=0.9000000
	RagdollTimeScale=1.0000000
	KarmaGravScale=1.0000000
	m_fInGamePlanningZoomDistance=5000.0000000
	Brightness=1.0000000
	m_fRainbowSkillMultiplier=1.0000000
	m_fTerroSkillMultiplier=1.0000000
	m_fEndGamePauseTime=8.0000000
	m_fDbgNavPointDistance=2000.0000000
	DefaultTexture=Texture'Engine.DefaultTexture'
	WireframeTexture=Texture'Engine.WireframeTexture'
	WhiteSquareTexture=Texture'Engine.WhiteSquareTexture'
	LargeVertex=Texture'Engine.LargeVertex'
	Title="Untitled"
	VisibleGroups="None"
	GreenTeamPawnClass="R6Characters.R6RainbowMediumBlue"
	RedTeamPawnClass="R6Characters.R6RainbowMediumEuro"
	m_szMissionObjLocalization="R6MissionObjectives"
	bWorldGeometry=true
	bAlwaysRelevant=true
	bHiddenEd=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var EPhysicsDetailLevel
// REMOVED IN 1.60: var ELevelAction
// REMOVED IN 1.60: var ENetMode
// REMOVED IN 1.60: function GetCampaignNameFromParam
