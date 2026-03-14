//=============================================================================
// LevelInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
var LevelInfo.EPhysicsDetailLevel PhysicsDetailLevel;
// NEW IN 1.60
var LevelInfo.ENetMode NetMode;
var(R6Sound) Actor.ETerroristNationality m_eTerroristVoices;  // Terrorist voice for the map.
var(R6Sound) Actor.EHostageNationality m_eHostageVoices;  // Terrorist voice for the map.
// NEW IN 1.60
var(R6GazAlertMode) int m_iCoughTimes;
// NEW IN 1.60
var(FreeBackupMode) int m_iNbOfFreeBackupToSpawn;
// NEW IN 1.60
var(FreeBackupMode) int m_iNbOfFBToSpawnBasedOnNbPlayers;
var int MaxRagdolls;  // Maximum number of simultaneous rag-dolls.
var int HubStackLevel;
//R6 change level in planning
var(R6Planning) int R6PlanningMaxLevel;
var(R6Planning) int R6PlanningMinLevel;
var int m_iMotionBlurIntensity;
var int m_iLimitedSFXCount;
//#ifdef R6PUNKBUSTER
//__WITH_PB__
var int iPBEnabled;  // 1 means PB server is running, 0 means not activated or deactivate cmd given but still running
// NEW IN 1.60
var bool m_bShowFloppy;
// NEW IN 1.60
var(ClassicMission) bool m_bIsClassicMission;
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
var bool m_bInGamePlanningActive;
var bool m_bInGamePlanningZoomingIn;
var bool m_bInGamePlanningZoomingOut;
var bool m_bGameTypesInitialized;
//-----------------------------------------------------------------------------
// Renderer Management.
var() bool bNeverPrecache;
var bool m_bLogBandWidth;  // this bool says whether we want to log bwidth usage
var bool bNextItems;
//R6MissionObjectives 
var(R6MissionObjectives) bool m_bUseDefaultMoralityRules;
//#ifdef R6DBGVECTORINFO
var bool m_bShowDebugLine;
//R6NEWRENDERERFEATURES
var bool m_bShowDebugLights;
var bool m_bShowDebugLODs;
var bool m_bShowOnlyTransparentSM;
var bool m_bNightVisionActive;
var bool m_bHeatVisionActive;
var bool m_bScopeVisionActive;
var bool m_bAllow3DRendering;
var bool m_bSkipMotionBlur;  // used to avoid blur in menus
// R6SOUND
var bool m_bPlaySound;
var bool m_bCanStartStartingSound;
var bool m_bSoundFadeFinish;
var bool m_bIsResettingLevel;
var bool m_bPBSvRunning;  // true means running, false means not running
//R6HEARTBEAT
var bool m_bHeartBeatOn;
// Time passage.
var() float TimeDilation;  // Normally 1 - scales real time passage.
// Current time.
var float TimeSeconds;  // Time in seconds since level began play.
var float PauseDelay;  // time at which to start pause
// NEW IN 1.60
var float m_fCompteurFrameDetection;
// NEW IN 1.60
var(MP2VirusUpload) float m_fTempsDetection;
// NEW IN 1.60
var(MP2VirusUpload) float m_fClignoteTime;
// NEW IN 1.60
var(R6GazAlertMode) float m_fOxygeneTopLevel;
// NEW IN 1.60
var(R6GazAlertMode) float m_iCoughSeuil;
// NEW IN 1.60
var(R6GazAlertMode) float m_fOxygeneStepDecrease;
// Karma - jag
var float KarmaTimeScale;  // Karma physics timestep scaling.
var float RagdollTimeScale;  // Ragdoll physics timestep scaling. This is applied on top of KarmaTimeScale.
var float KarmaGravScale;  // Allows you to make ragdolls use lower friction than normal.
var float m_fInGamePlanningZoomDistance;
var(Audio) float PlayerDoppler;  // Player doppler shift, 0=none, 1=full.
var() float Brightness;
var float m_fRainbowSkillMultiplier;
var float m_fTerroSkillMultiplier;
var float NextSwitchCountdown;
var(R6MissionObjectives) float m_fTimeLimit;
var(R6Sound) float m_fEndGamePauseTime;
var float m_fDbgNavPointDistance;  // debug: max distance to player for displaying nav point.
var float m_fDistanceHeartBeatVisible;
var PlayerReplicationInfo Pauser;  // If paused, name of person pausing the game.
var LevelSummary Summary;
var() Texture Screenshot;
var Texture DefaultTexture;
var Texture WireframeTexture;
var Texture WhiteSquareTexture;
var Texture LargeVertex;
var GameInfo Game;
var const NavigationPoint NavigationPointList;
var const Controller ControllerList;
var PhysicsVolume PhysicsVolumeList;
//#ifdef R6ACTIONSPOT
var const R6ActionSpot m_ActionSpotList;
//Skin names received by the client. If package does not exist, it will be downloaded.
var Material GreenTeamSkin;
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
var(R6MissionObjectives) Sound m_sndMissionComplete;
//R6Weather
var Emitter m_WeatherEmitter;
var Actor m_WeatherViewTarget;
var Sound m_sndPlayMissionIntro;
var Sound m_sndPlayMissionExtro;
var(R6Sound) Sound m_SurfaceSwitchSnd;  // Sound event containing all the surface sounds - EB April 6th, 2002
var(R6Sound) Sound m_SurfaceSwitchForOtherPawnSnd;  // Sound event containing all the surface sounds for the other pawn- SD July 30th, 2002
var(R6Sound) Sound m_BodyFallSwitchSnd;  // Sound contain only the body fall sounds for player - SD
var(R6Sound) Sound m_BodyFallSwitchForOtherPawnSnd;  // Sound contain only the body fall sounds for the other pawn- SD
var(R6Sound) Sound m_StartingMusic;  // When the Music is set in the level the music is play at the beginning of the game.
var R6DecalManager m_DecalManager;
var Texture m_pScopeMaskTexture;
var Texture m_pScopeAddTexture;
var R6AbstractHostageMgr m_hostageMgr;  // there's only one instance of hostageMgr
var R6AbstractTerroristMgr m_terroristMgr;
var(R6SFX) Material m_pProneTrailMaterial;
var R6ServerInfo m_ServerSettings;
var R6LimitedSFX m_aLimitedSFX[6];
// #ifdef R6WRITABLEMAP
var(R6DrawingTool) Texture m_tWritableMapTexture;
// NEW IN 1.60
var Class<StaticMeshActor> GreenHelmet;
// NEW IN 1.60
var Class<StaticMeshActor> RedHelmet;
var(R6LevelWeather) Class<R6WeatherEmitter> m_WeatherEmitterClass;
var Class<R6WeatherEmitter> m_RepWeatherEmitterClass;
//R6Breathing
var(R6Breathing) Class<Emitter> m_BreathingEmitterClass;
var(R6MissionObjectives) editinline array<editinline R6MissionObjectiveBase> m_aMissionObjectives;
var array<WritableMapVertex> m_aCurrentStrip;
var array<WritableMapVertex> m_aWritableMapStrip;
var array<WritableMapStroke> m_aWritableMapTimeStamp;
var array<WritableMapIcon> m_aWritableMapIcons;
var array<GameTypeInfo> m_aGameTypeInfo;
//-----------------------------------------------------------------------------
// Legend - used for saving the viewport camera positions
var() Vector CameraLocationDynamic;
var() Vector CameraLocationTop;
var() Vector CameraLocationFront;
var() Vector CameraLocationSide;
var() Rotator CameraRotationDynamic;
var(R6Planning) Vector R6PlanningMaxVector;
var(R6Planning) Vector R6PlanningMinVector;
var Region GreenMenuRegion;
var Region RedMenuRegion;
var(R6Sound) SoundZoneAudibleZones m_SoundZoneAudibleZones[64];
var Vector m_vPredVector;
var Vector m_vPredPredVector;
var() localized string Title;
var() string Author;  // Who built it.
var() localized string LevelEnterText;  // Message to tell players when they enter.
var() string LocalizedPkg;  // Package to look in for localizations.
var string VisibleGroups;  // List of the group names which were checked when the level was last saved
var(Audio) string Song;  // Filename of the streaming song.
var string m_szGameTypeShown;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion;  // Engine version.
var string MinNetVersion;  // Min engine version that is net compatible.
var() string DefaultGameType;
var string NextURL;
//R6 Multiplayer SKINS
var(R6MultiPlayerSkins) string GreenTeamPawnClass;
var(R6MultiPlayerSkins) string RedTeamPawnClass;
var(R6MissionObjectives) string m_szMissionObjLocalization;
var(R6Sound) string m_csVoicesOneLinersBankName;
// NEW IN 1.60
var transient LevelInfo.ELevelAction LevelAction;
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
	reliable if(__NFUN_130__(bNetDirty, __NFUN_154__(int(Role), int(ROLE_Authority))))
		Pauser, TimeDilation;

	// Pos:0x018
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_RepWeatherEmitterClass;

	// Pos:0x025
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x43
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_bCanSetNbOfTerroristToSpawn;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x70
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			// End:0x57
			if(_bNotIncludeGMI_None)
			{
				// End:0x57
				if(__NFUN_154__(int(m_aGameTypeInfo[i].m_eGameModeInfo), int(0)))
				{
					return false;
				}
			}
			return __NFUN_155__(int(m_aGameTypeInfo[i].m_eGameModeInfo), int(1));
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x4A
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return __NFUN_154__(int(m_aGameTypeInfo[i].m_eGameModeInfo), int(3));
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x43
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_bTeamAdversarial;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x4A
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return __NFUN_154__(int(m_aGameTypeInfo[i].m_eGameModeInfo), int(2));
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x4A
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return __NFUN_154__(int(m_aGameTypeInfo[i].m_eGameModeInfo), int(4));
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x43
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_bUsePreRecMessages;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x43
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_bPlayWithNonRainbowNPCs;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x43
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_bUseRainbowComm;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x42
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_szNameLocalization;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x42
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_szToString;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x42
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_szLocalizationFile;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x42
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_szGreenTeamObjective;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x42
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_szRedTeamObjective;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x42
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_szGreenShortDescription;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x42
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_szRedShortDescription;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x42
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szClassName, szGameClassName))
		{
			return m_aGameTypeInfo[i].m_szGameType;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x42
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_szClassName;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x66
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, Game.m_szGameTypeFlag))
		{
			SaveDirectory = m_aGameTypeInfo[i].m_szSaveDirectoryName;
			EnglishSaveDir = m_aGameTypeInfo[i].m_szEnglishDirName;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x49
		if(__NFUN_122__(EnglishSaveDir, m_aGameTypeInfo[i].m_szEnglishDirName))
		{
			SaveDirectory = m_aGameTypeInfo[i].m_szSaveDirectoryName;
			return true;
		}
		__NFUN_165__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x7B
		if(__NFUN_124__(m_aGameTypeInfo[i].m_szNameLocalization, szGameTypeLoc))
		{
			// End:0x61
			if(_bOnlyMulti)
			{
				bFind = __NFUN_155__(int(m_aGameTypeInfo[i].m_eGameModeInfo), int(1));
			}
			// End:0x7B
			if(bFind)
			{
				return m_aGameTypeInfo[i].m_szGameType;
			}
		}
		__NFUN_165__(i);
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
	if(__NFUN_114__(m_hostageMgr, none))
	{
		pModManager = Class'Engine.Actor'.static.__NFUN_1524__();
		// End:0x6B
		if(__NFUN_123__(pModManager.m_pCurrentMod.m_HostageMgrToSpawn, ""))
		{
			DesiredHostageMgrClass = Class<R6AbstractHostageMgr>(DynamicLoadObject(pModManager.m_pCurrentMod.m_HostageMgrToSpawn, Class'Core.Class'));			
		}
		else
		{
			DesiredHostageMgrClass = Class<R6AbstractHostageMgr>(DynamicLoadObject("R6Engine.R6HostageMgr", Class'Core.Class'));
		}
		m_hostageMgr = __NFUN_278__(DesiredHostageMgrClass);
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
	if(__NFUN_114__(m_terroristMgr, none))
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
	if(__NFUN_150__(Index, m_aGameTypeInfo.Length))
	{
		// End:0x33
		if(__NFUN_122__(m_aGameTypeInfo[Index].m_szGameType, szGameType))
		{
			return;
		}
		__NFUN_165__(Index);
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
	assert(__NFUN_150__(iIndex, m_aGameTypeInfo.Length));
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x73
		if(__NFUN_123__(m_aGameTypeInfo[i].m_szGreenTeamObjective, ""))
		{
			m_aGameTypeInfo[i].m_szGreenTeamObjective = Localize(m_aGameTypeInfo[i].m_szToString, "GreenTeamObj", m_aGameTypeInfo[i].m_szGreenTeamObjective);
		}
		// End:0xCD
		if(__NFUN_123__(m_aGameTypeInfo[i].m_szRedTeamObjective, ""))
		{
			m_aGameTypeInfo[i].m_szRedTeamObjective = Localize(m_aGameTypeInfo[i].m_szToString, "RedTeamObj", m_aGameTypeInfo[i].m_szRedTeamObjective);
		}
		// End:0x12B
		if(__NFUN_123__(m_aGameTypeInfo[i].m_szGreenShortDescription, ""))
		{
			m_aGameTypeInfo[i].m_szGreenShortDescription = Localize(m_aGameTypeInfo[i].m_szToString, "GreenShortDesc", m_aGameTypeInfo[i].m_szGreenShortDescription);
		}
		// End:0x187
		if(__NFUN_123__(m_aGameTypeInfo[i].m_szRedShortDescription, ""))
		{
			m_aGameTypeInfo[i].m_szRedShortDescription = Localize(m_aGameTypeInfo[i].m_szToString, "RedShortDesc", m_aGameTypeInfo[i].m_szRedShortDescription);
		}
		__NFUN_163__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x47
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			m_aGameTypeInfo[i].m_bDisplayBombTimer = true;
			// [Explicit Break]
			goto J0x51;
		}
		__NFUN_163__(i);
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
	if(__NFUN_150__(i, m_aGameTypeInfo.Length))
	{
		// End:0x43
		if(__NFUN_122__(m_aGameTypeInfo[i].m_szGameType, szGameType))
		{
			return m_aGameTypeInfo[i].m_bDisplayBombTimer;
		}
		__NFUN_163__(i);
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
	pModMgr = Class'Engine.Actor'.static.__NFUN_1524__();
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
	if(__NFUN_119__(aMgr, none))
	{
		aMgr.__NFUN_279__();
	}
	m_bCanStartStartingSound = false;
	// End:0x69
	if(__NFUN_129__(Level.bKNoInit))
	{
		m_DecalManager = __NFUN_278__(Class'Engine.R6DecalManager');
	}
	// End:0x83
	if(__NFUN_119__(m_terroristMgr, none))
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
	if(__NFUN_122__(NextURL, ""))
	{
		bNextItems = bItems;
		NextURL = URL;
		// End:0x4C
		if(__NFUN_119__(Game, none))
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
	__NFUN_2622__();
	super(Actor).Reset();
	return;
}

simulated function AddPhysicsVolume(PhysicsVolume NewPhysicsVolume)
{
	local PhysicsVolume V;

	V = PhysicsVolumeList;
	J0x0B:

	// End:0x3E [Loop If]
	if(__NFUN_119__(V, none))
	{
		// End:0x27
		if(__NFUN_114__(V, NewPhysicsVolume))
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
	if(__NFUN_119__(V, none))
	{
		// End:0x66
		if(__NFUN_114__(V, DeletedPhysicsVolume))
		{
			// End:0x47
			if(__NFUN_114__(Prev, none))
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
	foreach __NFUN_304__(Class'Engine.Actor', StartSpot)
	{
		// End:0x41
		if(__NFUN_130__(StartSpot.__NFUN_303__('R6CameraSpot'), StartSpot.__NFUN_1513__(szGameType)))
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

	__NFUN_231__(__NFUN_112__(__NFUN_112__("Resetting Level (total=", string(iNbOfRestart)), ")"));
	m_bIsResettingLevel = true;
	// End:0x51
	foreach __NFUN_304__(Class'Engine.Actor', aActor)
	{
		aActor.FirstPassReset();		
	}	
	// End:0x16A
	if(__NFUN_155__(int(NetMode), int(NM_Client)))
	{
		C = Level.ControllerList;
		J0x76:

		// End:0x16A [Loop If]
		if(__NFUN_119__(C, none))
		{
			PC = PlayerController(C);
			// End:0xB0
			if(__NFUN_119__(PC, none))
			{
				PC.ResettingLevel(iNbOfRestart);
			}
			// End:0x10E
			if(__NFUN_119__(C.Pawn, none))
			{
				aPawn = C.Pawn;
				// End:0xF2
				if(__NFUN_119__(PC, none))
				{
					PC.UnPossess();
				}
				aPawn.__NFUN_279__();
				C.Pawn = none;
			}
			pNextController = C.nextController;
			// End:0x140
			if(__NFUN_119__(PC, none))
			{
				C.__NFUN_113__('BaseSpectating');				
			}
			else
			{
				// End:0x15C
				if(__NFUN_119__(AIController(C), none))
				{
					C.__NFUN_279__();
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
		__NFUN_231__("RESET: ResetOriginalData of all actors...");
	}
	// End:0x1FA
	foreach __NFUN_304__(Class'Engine.Actor', aActor)
	{
		// End:0x1EA
		if(__NFUN_132__(aActor.bTearOff, aActor.m_bDeleteOnReset))
		{
			// End:0x1E7
			if(__NFUN_129__(aActor.__NFUN_279__()))
			{
			}
			// End:0x1F9
			continue;
		}
		aActor.ResetOriginalData();		
	}	
	__NFUN_1515__();
	__NFUN_2622__();
	// End:0x243
	foreach __NFUN_304__(Class'Engine.Actor', aActor)
	{
		// End:0x242
		if(__NFUN_130__(__NFUN_114__(PlayerController(aActor), none), __NFUN_114__(GameInfo(aActor), none)))
		{
			aActor.SetInitialState();
		}		
	}	
	__NFUN_2712__();
	// End:0x266
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		StopAllMusic();
	}
	__NFUN_2704__();
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
	if(__NFUN_130__(__NFUN_119__(obj, none), __NFUN_123__(obj.m_szMissionObjLocalization, "")))
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
	if(__NFUN_155__(int(NetMode), int(NM_Client)))
	{
		m_RepWeatherEmitterClass = m_WeatherEmitterClass;
	}
	// End:0x58
	if(__NFUN_130__(__NFUN_132__(__NFUN_154__(int(NetMode), int(NM_Standalone)), __NFUN_154__(int(NetMode), int(NM_ListenServer))), __NFUN_119__(m_WeatherEmitterClass, none)))
	{
		m_WeatherEmitter = __NFUN_278__(m_WeatherEmitterClass);
	}
	GetTerroristMgr();
	return;
}

simulated function SetWeatherActive(bool bWeatherActive)
{
	// End:0x64
	if(__NFUN_130__(bWeatherActive, __NFUN_154__(m_WeatherEmitter.Emitters[0].m_iPaused, 1)))
	{
		m_WeatherEmitter.Emitters[0].m_iPaused = 0;
		m_WeatherEmitter.Emitters[0].AllParticlesDead = false;		
	}
	else
	{
		// End:0xC7
		if(__NFUN_130__(__NFUN_129__(bWeatherActive), __NFUN_154__(m_WeatherEmitter.Emitters[0].m_iPaused, 0)))
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
