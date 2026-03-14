//=============================================================================
// Engine - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Engine: The base class of the global application object classes.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Engine extends Subsystem
    transient
    native
    config
    noexport;

const C_ConsoleMaxStrings = 32;

// Drivers.
var(Drivers) config Class<AudioSubsystem> AudioDevice;
var(Drivers) config Class<Interaction> Console;  // The default system console
//#ifndef R6CODE
//var(Drivers) config class<Interaction>	  DefaultMenu;			// The default system menu 
//var(Drivers) config class<Interaction>	  DefaultPlayerMenu;	// The default player menu
//#endif // #ifndef R6CODE
var(Drivers) config Class<NetDriver> NetworkDevice;
var(Drivers) config Class<Language> Language;
// Variables.
var Primitive Cylinder;
var const Client Client;
var const AudioSubsystem Audio;
var const RenderDevice GRenDev;
// Stats.
var int bShowFrameRate;
var int bShowRenderStats;
var int bShowHardwareStats;
var int bShowGameStats;
var int bShowAnimStats;  // Show animation statistics.
var int bShowNetStats;
var int bShowHistograph;
var int bShowXboxMemStats;
var int bShowMatineeStats;  // Show Matinee specific information
var int bShowAudioStats;
var int TickCycles;
// NEW IN 1.60
var int GameCycles;
// NEW IN 1.60
var int ClientCycles;
var(Settings) config int CacheSizeMegs;
var(Settings) config bool UseSound;
var(Settings) float CurrentTickRate;
//R6CODE
var int m_iCurrentDelta;
var float m_fDeltaTime;  // Frame delta time
var float m_fTotalTime;  // Total engine run time
// NEW IN 1.60
var(Colors) config Color C_WorldBox;
// NEW IN 1.60
var(Colors) config Color C_GroundPlane;
// NEW IN 1.60
var(Colors) config Color C_GroundHighlight;
// NEW IN 1.60
var(Colors) config Color C_BrushWire;
// NEW IN 1.60
var(Colors) config Color C_Pivot;
// NEW IN 1.60
var(Colors) config Color C_Select;
// NEW IN 1.60
var(Colors) config Color C_Current;
// NEW IN 1.60
var(Colors) config Color C_AddWire;
// NEW IN 1.60
var(Colors) config Color C_SubtractWire;
// NEW IN 1.60
var(Colors) config Color C_GreyWire;
// NEW IN 1.60
var(Colors) config Color C_BrushVertex;
// NEW IN 1.60
var(Colors) config Color C_BrushSnap;
// NEW IN 1.60
var(Colors) config Color C_Invalid;
// NEW IN 1.60
var(Colors) config Color C_ActorWire;
// NEW IN 1.60
var(Colors) config Color C_ActorHiWire;
// NEW IN 1.60
var(Colors) config Color C_Black;
// NEW IN 1.60
var(Colors) config Color C_White;
// NEW IN 1.60
var(Colors) config Color C_Mask;
// NEW IN 1.60
var(Colors) config Color C_SemiSolidWire;
// NEW IN 1.60
var(Colors) config Color C_NonSolidWire;
// NEW IN 1.60
var(Colors) config Color C_WireBackground;
// NEW IN 1.60
var(Colors) config Color C_WireGridAxis;
// NEW IN 1.60
var(Colors) config Color C_ActorArrow;
// NEW IN 1.60
var(Colors) config Color C_ScaleBox;
// NEW IN 1.60
var(Colors) config Color C_ScaleBoxHi;
// NEW IN 1.60
var(Colors) config Color C_ZoneWire;
// NEW IN 1.60
var(Colors) config Color C_Mover;
// NEW IN 1.60
var(Colors) config Color C_OrthoBackground;
// NEW IN 1.60
var(Colors) config Color C_StaticMesh;
// NEW IN 1.60
var(Colors) config Color C_VolumeBrush;
// NEW IN 1.60
var(Colors) config Color C_ConstraintLine;
// NEW IN 1.60
var(Colors) config Color C_AnimMesh;
// NEW IN 1.60
var(Colors) config Color C_TerrainWire;
//#ifdef R6RASTERS
var bool m_bProfStatsFps;
var bool m_bProfStatsTimers;
//#ifdef R6KARMA
var bool m_bKarmaMemoryStats;
var bool m_bShowActorRenderStats;
var bool m_bShowActorTickStats;
var bool m_bShowActorTraceStats;
var bool m_bShowActorTracedStats;
var bool m_bFreezeActorStats;
var bool m_bShowStaticMeshSectionsDebugInfo;
var bool m_bUseStaticMeshBatcher;
var bool m_bShowNetChannelStats;
//#ifdef R6CHARLIGHTVALUE
var bool m_bShowLightValue;
//#ifdef R6CODE
var bool m_bRunningFromEditor;
var bool m_bDisplayVersionInfo;
var bool m_bMultiScreenShot;
var bool m_bEnableLoadingScreen;
var bool m_bIsRecording;
var byte m_szMovieFileName[256];
var float m_fFakeDeltaTime;
var int m_lMovieFrame;
var int m_iCurrentMapNum;
var Class m_TickedClassStats;
// NEW IN 1.60
var string m_ConsoleStrings[32];
// NEW IN 1.60
var Color m_ConsoleStringsColors[32];
// NEW IN 1.60
var byte m_ConsoleUseBigFont[32];
var int m_iConsoleNbStrings;

defaultproperties
{
	Console=Class'Engine.Console'
	CacheSizeMegs=2
	UseSound=true
	C_WorldBox=(R=0,G=0,B=107,A=255)
	C_GroundPlane=(R=0,G=0,B=63,A=255)
	C_GroundHighlight=(R=0,G=0,B=127,A=255)
	C_BrushWire=(R=255,G=63,B=63,A=255)
	C_Pivot=(R=0,G=255,B=0,A=255)
	C_Select=(R=0,G=0,B=127,A=255)
	C_Current=(R=0,G=0,B=0,A=255)
	C_AddWire=(R=127,G=127,B=255,A=255)
	C_SubtractWire=(R=255,G=192,B=63,A=255)
	C_GreyWire=(R=163,G=163,B=163,A=255)
	C_BrushVertex=(R=0,G=0,B=0,A=255)
	C_BrushSnap=(R=0,G=0,B=0,A=255)
	C_Invalid=(R=163,G=163,B=163,A=255)
	C_ActorWire=(R=127,G=63,B=0,A=255)
	C_ActorHiWire=(R=255,G=127,B=0,A=255)
	C_Black=(R=0,G=0,B=0,A=255)
	C_White=(R=255,G=255,B=255,A=255)
	C_Mask=(R=0,G=0,B=0,A=255)
	C_SemiSolidWire=(R=127,G=255,B=0,A=255)
	C_NonSolidWire=(R=63,G=192,B=32,A=255)
	C_WireBackground=(R=0,G=0,B=0,A=255)
	C_WireGridAxis=(R=119,G=119,B=119,A=255)
	C_ActorArrow=(R=163,G=0,B=0,A=255)
	C_ScaleBox=(R=151,G=67,B=11,A=255)
	C_ScaleBoxHi=(R=223,G=149,B=157,A=255)
	C_ZoneWire=(R=0,G=0,B=0,A=255)
	C_Mover=(R=255,G=0,B=255,A=255)
	C_OrthoBackground=(R=163,G=163,B=163,A=255)
	C_StaticMesh=(R=0,G=255,B=255,A=255)
	C_VolumeBrush=(R=255,G=196,B=225,A=255)
	C_ConstraintLine=(R=0,G=255,B=0,A=255)
	C_AnimMesh=(R=221,G=221,B=28,A=255)
	C_TerrainWire=(R=255,G=255,B=255,A=255)
	m_bUseStaticMeshBatcher=true
	m_bEnableLoadingScreen=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var m_szCampaignNameFromParam
// REMOVED IN 1.60: var color
// REMOVED IN 1.60: var m_ConsoleStringsC_ConsoleMaxStrings
// REMOVED IN 1.60: var m_ConsoleStringsColorsC_ConsoleMaxStrings
