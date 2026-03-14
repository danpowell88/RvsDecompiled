//=============================================================================
// Engine: The base class of the global application object classes.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Engine extends Subsystem
    native
    noexport
    transient;

// --- Constants ---
const C_ConsoleMaxStrings =  32;

// --- Variables ---
// var ? m_szCampaignNameFromParam; // REMOVED IN 1.60
var config bool UseSound;
// ^ NEW IN 1.60
var config int CacheSizeMegs;
// ^ NEW IN 1.60
var int m_iConsoleNbStrings;
var byte m_ConsoleUseBigFont[32];
// ^ NEW IN 1.60
var Color m_ConsoleStringsColors[32];
//R6CONSOLE
var string m_ConsoleStrings[32];
var class<Object> m_TickedClassStats;
var int m_iCurrentMapNum;
var int m_lMovieFrame;
var float m_fFakeDeltaTime;
var byte m_szMovieFileName[256];
var bool m_bIsRecording;
var bool m_bEnableLoadingScreen;
var bool m_bMultiScreenShot;
var bool m_bDisplayVersionInfo;
//#ifdef R6CODE
var bool m_bRunningFromEditor;
//#ifdef R6CHARLIGHTVALUE
var bool m_bShowLightValue;
var bool m_bShowNetChannelStats;
var bool m_bUseStaticMeshBatcher;
var bool m_bShowStaticMeshSectionsDebugInfo;
var bool m_bFreezeActorStats;
var bool m_bShowActorTracedStats;
var bool m_bShowActorTraceStats;
var bool m_bShowActorTickStats;
var bool m_bShowActorRenderStats;
//#ifdef R6KARMA
var bool m_bKarmaMemoryStats;
var bool m_bProfStatsTimers;
//#ifdef R6RASTERS
var bool m_bProfStatsFps;
var config Color C_TerrainWire;
// ^ NEW IN 1.60
var config Color C_AnimMesh;
// ^ NEW IN 1.60
var config Color C_ConstraintLine;
// ^ NEW IN 1.60
var config Color C_VolumeBrush;
// ^ NEW IN 1.60
var config Color C_StaticMesh;
// ^ NEW IN 1.60
var config Color C_OrthoBackground;
// ^ NEW IN 1.60
var config Color C_Mover;
// ^ NEW IN 1.60
var config Color C_ZoneWire;
// ^ NEW IN 1.60
var config Color C_ScaleBoxHi;
// ^ NEW IN 1.60
var config Color C_ScaleBox;
// ^ NEW IN 1.60
var config Color C_ActorArrow;
// ^ NEW IN 1.60
var config Color C_WireGridAxis;
// ^ NEW IN 1.60
var config Color C_WireBackground;
// ^ NEW IN 1.60
var config Color C_NonSolidWire;
// ^ NEW IN 1.60
var config Color C_SemiSolidWire;
// ^ NEW IN 1.60
var config Color C_Mask;
// ^ NEW IN 1.60
var config Color C_White;
// ^ NEW IN 1.60
var config Color C_Black;
// ^ NEW IN 1.60
var config Color C_ActorHiWire;
// ^ NEW IN 1.60
var config Color C_ActorWire;
// ^ NEW IN 1.60
var config Color C_Invalid;
// ^ NEW IN 1.60
var config Color C_BrushSnap;
// ^ NEW IN 1.60
var config Color C_BrushVertex;
// ^ NEW IN 1.60
var config Color C_GreyWire;
// ^ NEW IN 1.60
var config Color C_SubtractWire;
// ^ NEW IN 1.60
var config Color C_AddWire;
// ^ NEW IN 1.60
var config Color C_Current;
// ^ NEW IN 1.60
var config Color C_Select;
// ^ NEW IN 1.60
var config Color C_Pivot;
// ^ NEW IN 1.60
var config Color C_BrushWire;
// ^ NEW IN 1.60
var config Color C_GroundHighlight;
// ^ NEW IN 1.60
var config Color C_GroundPlane;
// ^ NEW IN 1.60
var config Color C_WorldBox;
// ^ NEW IN 1.60
// Total engine run time
var float m_fTotalTime;
// Frame delta time
var float m_fDeltaTime;
//R6CODE
var int m_iCurrentDelta;
var float CurrentTickRate;
// ^ NEW IN 1.60
var int ClientCycles;
var int GameCycles;
// ^ NEW IN 1.60
var int TickCycles;
// ^ NEW IN 1.60
var int bShowAudioStats;
// Show Matinee specific information
var int bShowMatineeStats;
var int bShowXboxMemStats;
var int bShowHistograph;
var int bShowNetStats;
// Show animation statistics.
var int bShowAnimStats;
var int bShowGameStats;
var int bShowHardwareStats;
var int bShowRenderStats;
// Stats.
var int bShowFrameRate;
var const RenderDevice GRenDev;
var const AudioSubsystem Audio;
var const Client Client;
// Variables.
var Primitive Cylinder;
var config class<Language> Language;
// ^ NEW IN 1.60
var config class<NetDriver> NetworkDevice;
// ^ NEW IN 1.60
var config class<Interaction> Console;
// ^ NEW IN 1.60
var config class<AudioSubsystem> AudioDevice;
// ^ NEW IN 1.60

defaultproperties
{
}
