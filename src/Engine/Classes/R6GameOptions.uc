//=============================================================================
// R6GameOptions - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
    config(User);

enum EGameOptionsAudioVirtual
{
	eAV_High,                       // 0
	eAV_Low,                        // 1
	eAV_None                        // 2
};

enum EGameOptionsNetSpeed
{
	eNS_T1,                         // 0
	eNS_T3,                         // 1
	eNS_Cable,                      // 2
	eNS_ADSL,                       // 3
	eNS_Modem                       // 4
};

enum EGameOptionsGraphicLevel
{
	eGL_Low,                        // 0
	eGL_Medium,                     // 1
	eGL_High                        // 2
};

enum EGameOptionsEffectLevel
{
	eEL_None,                       // 0
	eEL_Low,                        // 1
	eEL_Medium,                     // 2
	eEL_High                        // 3
};

var config R6GameOptions.EGameOptionsAudioVirtual AudioVirtual;  // the audio virtualization
var config R6GameOptions.EGameOptionsNetSpeed NetSpeed;  // The speed connection
// Textures
var config R6GameOptions.EGameOptionsGraphicLevel TextureDetail;
var config R6GameOptions.EGameOptionsGraphicLevel LightmapDetail;
// Character's LOD
var config R6GameOptions.EGameOptionsGraphicLevel RainbowsDetail;
var config R6GameOptions.EGameOptionsGraphicLevel HostagesDetail;
var config R6GameOptions.EGameOptionsGraphicLevel TerrosDetail;
// Character's shadow
var config R6GameOptions.EGameOptionsEffectLevel RainbowsShadowLevel;
var config R6GameOptions.EGameOptionsEffectLevel HostagesShadowLevel;
var config R6GameOptions.EGameOptionsEffectLevel TerrosShadowLevel;
var config R6GameOptions.EGameOptionsEffectLevel GoreLevel;
var config R6GameOptions.EGameOptionsEffectLevel DecalsDetail;
var config int AutoTargetSlider;  // 0= off, 1=?, 2=?, 3=? TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
var config int AmbientVolume;  // the ambient volume
var config int VoicesVolume;  // the voices volume
var config int MusicVolume;  // the music volume
var config int SndQuality;  // the sound quality
var config int Gender;  // gender of the player (a int for Button ID)
var config int ChangeNameTime;  // Time between a change name
// Misc graphics
var config int R6ScreenSizeX;
var config int R6ScreenSizeY;
var config int R6ScreenRefreshRate;
//=============================================================================
// NON-CONFIG VARIABLES
//=============================================================================
var bool EAXCompatible;  // if the sound card support EAX
var bool m_bChangeResolution;
//#ifdefR6PUNKBUSTER
var bool m_bPBInstalled;  // if PB is installed
var config bool SplashScreen;  // for german version
//=============================================================================
// GAME
//=============================================================================
var bool UnlimitedPractice;  // Unlimited Practice
var config bool AlwaysRun;  // Automatically makes the operative run whenever the player gives the move command
var config bool InvertMouse;  // When ON, if the mouse is pushed the targeting reticule will go down, and if the mouse is pulled, the targeting reticule will go up.
var config bool Hide3DView;  // always have the 3d View active in the planning
var config bool PopUpLoadPlan;  // Enable/disable pop-up load planning
var config bool PopUpQuickPlay;  // Enable/disable Quick play pop-up
var config bool SndHardware;  // 3D Audio Hardware Acceleration
var config bool EAX;  // EAX
var config bool ActivePunkBuster;  // Active PunkBuster in client
var config bool WantTriggerLag;  // Activate Trigger Lag
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
var config bool HUDShowPlayersName;  // show the teammates names
var config bool ShowRadar;  // show radar in multiplayer
var config bool AnimatedGeometry;
var config bool HideDeadBodies;
var config bool ShowRefreshRates;
var config bool LowDetailSmoke;
var config bool AllowChangeResInGame;
var config bool AutoPatchDownload;
var config float CountDownDelayTime;  // Time between all player are ready and the beginning of the round
var config float MouseSensitivity;  // Sets the amount of movement the mouse gives to the targeting reticule.
// ========================================================
// ========================================================
// NOTE: IF YOU ADD A NEW VARIABLE CONFIG IN THIS CLASS, AND ITS AN OPTIONS
//	     DON`T FORGET TO PUT THE DEFAULT VALUE IN DEFAULT.INI FILE
// ========================================================
// ========================================================
var config Color m_reticuleFriendColour;  // when the reticule is on a friend
var config Color HUDMPColor;
var config Color HUDMPDarkColor;
var config string MPAutoSelection;  // auto selection in MP (force to GREEN, RED or nothing)
var config string characterName;  // multiplayer char name
var config string ArmPatchTexture;  // Skins, ArmPatches, etc.

//=========================================
// ResetGameToDefault: Reset the game options, use default.ini value
//=========================================
function ResetGameToDefault()
{
	ResetConfig("AlwaysRun");
	ResetConfig("InvertMouse");
	ResetConfig("Hide3DView");
	ResetConfig("MouseSensitivity");
	ResetConfig("AutoTargetSlider");
	ResetConfig("PopUpLoadPlan");
	ResetConfig("PopUpQuickPlay");
	return;
}

//=========================================
// ResetGameToDefault: Reset the game options, use default.ini value
//=========================================
function ResetSoundToDefault(bool _bInGame)
{
	ResetConfig("AmbientVolume");
	ResetConfig("MovementVolume");
	ResetConfig("VoicesVolume");
	ResetConfig("MusicVolume");
	ResetConfig("SndHardware");
	ResetConfig("EAX");
	ResetConfig("AudioVirtual");
	// End:0xA1
	if((!_bInGame))
	{
		ResetConfig("SndQuality");
	}
	return;
}

//=========================================
// ResetGraphicsToDefault: Reset the graphics options, use default.ini value
//=========================================
function ResetGraphicsToDefault(bool _bInGame)
{
	ResetConfig("R6ScreenSizeX");
	ResetConfig("R6ScreenSizeY");
	ResetConfig("R6ScreenRefreshRate");
	ResetConfig("TextureDetail");
	ResetConfig("LightmapDetail");
	ResetConfig("RainbowsDetail");
	ResetConfig("TerrosDetail");
	ResetConfig("HostagesDetail");
	ResetConfig("AnimatedGeometry");
	ResetConfig("HideDeadBodies");
	ResetConfig("ShowRefreshRates");
	ResetConfig("LowDetailSmoke");
	// End:0x18B
	if((!_bInGame))
	{
		ResetConfig("RainbowsShadowLevel");
		ResetConfig("HostagesShadowLevel");
		ResetConfig("TerrosShadowLevel");
		ResetConfig("DecalsDetail");
		ResetConfig("GoreLevel");
	}
	return;
}

//=========================================
// ResetGraphicsToDefault: Reset the graphics options, use default.ini value
//=========================================
function ResetMultiToDefault()
{
	ResetConfig("CharacterName");
	ResetConfig("NetSpeed");
	ResetConfig("Gender");
	ResetConfig("ArmPatchTexture");
	ResetConfig("WantTriggerLag");
	return;
}

//=========================================
// ResetHudToDefault: Reset the hud options, use default.ini value
//=========================================
function ResetHudToDefault()
{
	ResetConfig("HUDShowCharacterInfo");
	ResetConfig("HUDShowCurrentTeamInfo");
	ResetConfig("HUDShowOtherTeamInfo");
	ResetConfig("HUDShowWeaponInfo");
	ResetConfig("HUDShowFPWeapon");
	ResetConfig("HUDShowReticule");
	ResetConfig("HUDShowWaypointInfo");
	ResetConfig("HUDShowActionIcon");
	ResetConfig("HUDShowPlayersName");
	ResetConfig("ShowRadar");
	return;
}

//=========================================
// ResetPatchServiceToDefault: Reset the patch service options, use default.ini value
//=========================================
function ResetPatchServiceToDefault()
{
	ResetConfig("AutoPatchDownload");
	return;
}

defaultproperties
{
	AudioVirtual=2
	NetSpeed=2
	TextureDetail=2
	LightmapDetail=2
	RainbowsDetail=2
	HostagesDetail=2
	TerrosDetail=2
	RainbowsShadowLevel=1
	GoreLevel=3
	DecalsDetail=2
	AutoTargetSlider=1
	AmbientVolume=100
	VoicesVolume=100
	MusicVolume=100
	SndQuality=1
	ChangeNameTime=60
	R6ScreenSizeX=1024
	R6ScreenSizeY=768
	R6ScreenRefreshRate=-1
	PopUpLoadPlan=true
	PopUpQuickPlay=true
	SndHardware=true
	HUDShowCharacterInfo=true
	HUDShowCurrentTeamInfo=true
	HUDShowOtherTeamInfo=true
	HUDShowWeaponInfo=true
	HUDShowFPWeapon=true
	HUDShowReticule=true
	HUDShowWaypointInfo=true
	HUDShowActionIcon=true
	HUDShowPlayersName=true
	ShowRadar=true
	MouseSensitivity=16.0000000
	m_reticuleFriendColour=(R=0,G=255,B=0,A=0)
	HUDMPColor=(R=129,G=209,B=239,A=75)
	characterName="JOHNDOE"
}
