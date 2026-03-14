//=============================================================================
//  R6GameOptions.uc : This class is in charge on keeping the different game options
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/27 * Created by Alexandre Dionne
//    2002/06/13 * Added graphic options
//=============================================================================
class R6GameOptions extends Object
    native
    config(USER);

// --- Enums ---
enum EGameOptionsGraphicLevel
{
    eGL_Low,
    eGL_Medium,
    eGL_High
};
enum EGameOptionsEffectLevel
{
    eEL_None,
    eEL_Low,
    eEL_Medium,
    eEL_High
};
enum EGameOptionsNetSpeed
{
	eNS_T1,
	eNS_T3,
	eNS_Cable,
	eNS_ADSL,
	eNS_Modem
};
enum EGameOptionsAudioVirtual
{
    eAV_High,
    eAV_Low,
    eAV_None
};

// --- Variables ---
// var ? CharacterName; // REMOVED IN 1.60
// Time between a change name
var config int ChangeNameTime;
var config string characterName;
// ^ NEW IN 1.60
//=============================================================================
// NON-CONFIG VARIABLES
//=============================================================================
// if the sound card support EAX
var bool EAXCompatible;
var bool m_bChangeResolution;
//#ifdefR6PUNKBUSTER
// if PB is installed
var bool m_bPBInstalled;
// ========================================================
// ========================================================
// NOTE: IF YOU ADD A NEW VARIABLE CONFIG IN THIS CLASS, AND ITS AN OPTIONS
//	     DON`T FORGET TO PUT THE DEFAULT VALUE IN DEFAULT.INI FILE
// ========================================================
// ========================================================
// when the reticule is on a friend
var config Color m_reticuleFriendColour;
// auto selection in MP (force to GREEN, RED or nothing)
var config string MPAutoSelection;
// for german version
var config bool SplashScreen;
// Time between all player are ready and the beginning of the round
var config float CountDownDelayTime;
//=============================================================================
// GAME
//=============================================================================
// Unlimited Practice
var bool UnlimitedPractice;
// Automatically makes the operative run whenever the player gives the move command
var config bool AlwaysRun;
// When ON, if the mouse is pushed the targeting reticule will go down, and if the mouse is pulled, the targeting reticule will go up.
var config bool InvertMouse;
// always have the 3d View active in the planning
var config bool Hide3DView;
// Enable/disable pop-up load planning
var config bool PopUpLoadPlan;
// Enable/disable Quick play pop-up
var config bool PopUpQuickPlay;
// Sets the amount of movement the mouse gives to the targeting reticule.
var config float MouseSensitivity;
// 0= off, 1=?, 2=?, 3=? TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
var config int AutoTargetSlider;
// the ambient volume
var config int AmbientVolume;
// the voices volume
var config int VoicesVolume;
// the music volume
var config int MusicVolume;
// the sound quality
var config int SndQuality;
// 3D Audio Hardware Acceleration
var config bool SndHardware;
// EAX
var config bool EAX;
// the audio virtualization
var config EGameOptionsAudioVirtual AudioVirtual;
// The speed connection
var config EGameOptionsNetSpeed NetSpeed;
// gender of the player (a int for Button ID)
var config int Gender;
// Skins, ArmPatches, etc.
var config string ArmPatchTexture;
// Active PunkBuster in client
var config bool ActivePunkBuster;
// Activate Trigger Lag
var config bool WantTriggerLag;
//=============================================================================
// HUD FILTERS
//=============================================================================
var config bool HUDShowCharacterInfo;
var config bool HUDShowCurrentTeamInfo;
var config bool HUDShowOtherTeamInfo;
var config bool HUDShowWeaponInfo;
var config bool HUDShowFPWeapon;
var config bool HUDShowReticule;
var config bool HUDShowWaypointInfo;
var config bool HUDShowActionIcon;
// show the teammates names
var config bool HUDShowPlayersName;
// show radar in multiplayer
var config bool ShowRadar;
var config Color HUDMPColor;
var config Color HUDMPDarkColor;
// Textures
var config EGameOptionsGraphicLevel TextureDetail;
var config EGameOptionsGraphicLevel LightmapDetail;
// Character's LOD
var config EGameOptionsGraphicLevel RainbowsDetail;
var config EGameOptionsGraphicLevel HostagesDetail;
var config EGameOptionsGraphicLevel TerrosDetail;
// Character's shadow
var config EGameOptionsEffectLevel RainbowsShadowLevel;
var config EGameOptionsEffectLevel HostagesShadowLevel;
var config EGameOptionsEffectLevel TerrosShadowLevel;
// Misc graphics
var config int R6ScreenSizeX;
var config int R6ScreenSizeY;
var config int R6ScreenRefreshRate;
var config bool AnimatedGeometry;
var config bool HideDeadBodies;
var config EGameOptionsEffectLevel GoreLevel;
var config EGameOptionsEffectLevel DecalsDetail;
var config bool ShowRefreshRates;
var config bool LowDetailSmoke;
var config bool AllowChangeResInGame;
var config bool AutoPatchDownload;

// --- Functions ---
//=========================================
// ResetGameToDefault: Reset the game options, use default.ini value
//=========================================
function ResetSoundToDefault(bool _bInGame) {}
//=========================================
// ResetGraphicsToDefault: Reset the graphics options, use default.ini value
//=========================================
function ResetGraphicsToDefault(bool _bInGame) {}
//=========================================
// ResetGameToDefault: Reset the game options, use default.ini value
//=========================================
function ResetGameToDefault() {}
//=========================================
// ResetGraphicsToDefault: Reset the graphics options, use default.ini value
//=========================================
function ResetMultiToDefault() {}
//=========================================
// ResetHudToDefault: Reset the hud options, use default.ini value
//=========================================
function ResetHudToDefault() {}
//=========================================
// ResetPatchServiceToDefault: Reset the patch service options, use default.ini value
//=========================================
function ResetPatchServiceToDefault() {}

defaultproperties
{
}
