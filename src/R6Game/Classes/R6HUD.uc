//============================================================================//
// R6HUD.uc : Rainbow 6 HUD Base Class
// Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//    2001/09/11 * Modified by Lysanne Martin
//    2002/01/07 * Modified by Sebastien Lussier			
//============================================================================//
class R6HUD extends R6AbstractHUD
    native
    config(User);

#exec OBJ LOAD FILE=..\Textures\Inventory_t.utx
#exec OBJ LOAD FILE=..\Textures\R6HUD.utx PACKAGE=R6HUD

// --- Variables ---
var R6PlayerController m_PlayerOwner;
var array<array> m_aIOBombs;
var R6GameReplicationInfo m_GameRepInfo;
var Color m_iCurrentTeamColor;
var bool m_bDisplayTimeBomb;
// Game Mode HUD Filters
var bool m_bGMIsSinglePlayer;
var bool m_bNoDeathCamera;
// For training, update only once
var bool m_bUpdateHUDInTraining;
var bool m_bPressGoCodeCanBlink;
var bool m_bShowPressGoCode;
var bool m_bDisplayRemainingTime;
var bool m_bShowActionIcon;
var bool m_bShowWaypointInfo;
var bool m_bShowWeaponInfo;
var bool m_bShowOtherTeamInfo;
var bool m_bShowCurrentTeamInfo;
// User HUD Filters
var bool m_bShowCharacterInfo;
var bool m_bGMIsCoop;
var bool m_bDrawHUDinScript;
// ^ NEW IN 1.60
var bool m_bGMIsTeamAdverserial;
var Actor m_pNextWayPoint;
var R6RainbowTeam m_pLastRainbowTeam;
var Texture m_FlashbangFlash;
var Texture m_TexNightVision;
var Texture m_TexHeatVision;
var Material m_TexHeatVisionActor;
var Material m_TexHUDElements;
var Material m_pCurrentMaterial;
var Texture m_HeartBeatMaskMul;
var Texture m_HeartBeatMaskAdd;
var Texture m_Waypoint;
var Texture m_WaypointArrow;
var Texture m_InGamePlanningPawnIcon;
var Texture m_LoadingScreen;
var Texture m_TexNoise;
var Material m_TexProneTrail;
var float m_fPosX;
var float m_fPosY;
var float m_fScaleX;
var float m_fScaleY;
// Current Weapon Info
var int m_iBulletCount;
var int m_iMaxBulletCount;
var int m_iMagCount;
var int m_iCurrentMag;
var bool m_bShowFPWeapon;
var bool m_bShowMPRadar;
var bool m_bShowTeamMatesNames;
var FinalBlend m_pAlphaBlend;
var float m_fScale;
//R6RADAR
var Material m_TexRadarTextures[10];
// Upper Left
var Color m_CharacterInfoBoxColor;
var Color m_CharacterInfoOutlineColor;
// Lower Left
var Color m_WeaponBoxColor;
var Color m_WeaponOutlineColor;
// Upper Right
var Color m_TeamBoxColor;
var Color m_TeamBoxOutlineColor;
// Lower Right;
var Color m_OtherTeamBoxColor;
var Color m_OtherTeamOutlineColor;
// Other
var Color m_WPIconBox;
var Color m_WPIconOutlineColor;
var R6HUDState m_HUDElements[16];
var bool m_bLastSniperHold;
var EMovementMode m_eLastMovementMode;
var string m_szMovementMode;
var eTeamState m_eLastTeamState;
var string m_szTeamState;
var eTeamState m_eLastOtherTeamState[2];
var string m_szOtherTeamState[2];
var string m_aszOtherTeamName[2];
var EPlanAction m_eLastPlayerAPAction;
var string m_szLastPlayerAPAction;
var string m_szPressGoCode;
var EGoCode m_eLastGoCode;
var string m_szTeam;

// --- Functions ---
//------------------------------------------------------------------
// StartFadeToBlack
//
//------------------------------------------------------------------
function StartFadeToBlack(int iSec, int iPercentageOfBlack) {}
//------------------------------------------------------------------
//
//
//------------------------------------------------------------------
function DisplayBombTimer(Canvas C) {}
//------------------------------------------------------------------
// DisplayRemainingTime
//
//------------------------------------------------------------------
function DisplayRemainingTime(Canvas C) {}
function ActivateNoDeathCameraMsg(bool bToggleOn) {}
//===========================================================================//
// Tick()                                                                    //
//===========================================================================//
simulated function Tick(float fDelta) {}
simulated event PostFadeRender(Canvas Canvas) {}
//===========================================================================//
// DrawHUD()                                                                 //
//===========================================================================//
function DrawHUD(Canvas C) {}
simulated function InitBombTimer(bool bDisplayTimeBomb) {}
final native function HudStep(int iBox, int iIDStep, optional bool bFlash) {}
// ^ NEW IN 1.60
final native function DrawNativeHUD(Canvas C) {}
// ^ NEW IN 1.60
function DisplayNoDeathCamera(Canvas C) {}
//------------------------------------------------------------------
// StopFadeToBlack
//
//------------------------------------------------------------------
function StopFadeToBlack() {}
function UpdateHudFilter() {}
//===========================================================================//
// PostRender()                                                              //
//  Render HUD and call post render on the player controller                 //
//===========================================================================//
simulated event PostRender(Canvas C) {}
//===========================================================================//
// DisplayMessages()                                                         //
//  Inherited                                                                //
//===========================================================================//
simulated function DisplayMessages(Canvas C) {}
//===========================================================================//
// SetDefaultFontSettings()                                                  //
//===========================================================================//
function SetDefaultFontSettings(Canvas C) {}
//===========================================================================//
// Message()                                                                 //
//  Parse recieved msg - inherited                                           //
//===========================================================================//
simulated function Message(coerce string Msg, name MsgType, PlayerReplicationInfo PRI) {}
//===========================================================================//
// PostBeginPlay()                                                           //
//===========================================================================//
function PostBeginPlay() {}
simulated function ResetOriginalData() {}
//------------------------------------------------------------------
// FUCKING WORKAROUND FOR THE GAME TYPE
//
//------------------------------------------------------------------
function Timer() {}

defaultproperties
{
}
