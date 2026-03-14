//=============================================================================
//  R6EscortPilotGame.uc : Adversarial team mode where one player is the pilot who must reach an extraction
//                         zone; restricts weapon loadout for the pilot role.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Aristomenis Kolokathis
//=============================================================================
class R6EscortPilotGame extends R6AdversarialTeamGame;

// --- Variables ---
// var ? m_szPilotSkin; // REMOVED IN 1.60
var R6PlayerController m_pilotController;
var R6MObjGoToExtraction m_objGoToExtraction;
var R6PlayerController m_previousPilot;
var config bool EnablePilotTertiaryWeapon;
var config bool EnablePilotSecondaryWeapon;
var config bool EnablePilotPrimaryWeapon;
var Sound m_sndPilot;

// --- Functions ---
//------------------------------------------------------------------
// IsTertiaryWeaponRestrictedToPawn
//	restriction for the pilot
//------------------------------------------------------------------
function bool IsTertiaryWeaponRestrictedToPawn(Pawn aPawn) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsSecondaryWeaponRestrictedToPawn
//	restriction for the pilot
//------------------------------------------------------------------
function bool IsSecondaryWeaponRestrictedToPawn(Pawn aPawn) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsPrimaryWeaponRestrictedToPawn
//	restriction for the pilot
//------------------------------------------------------------------
function bool IsPrimaryWeaponRestrictedToPawn(Pawn aPawn) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// RestartPlayer
//
//------------------------------------------------------------------
function RestartPlayer(Controller aPlayer) {}
function R6SetPilotClassInMultiPlayer(Controller PlayerController) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CanAutoBalancePlayer
//
//------------------------------------------------------------------
function bool CanAutoBalancePlayer(R6PlayerController pCtrl) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// EndGame
//
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason) {}
//------------------------------------------------------------------
// PawnKilled
//
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn) {}
//------------------------------------------------------------------
// BroadcastGameTypeDescription
//
//------------------------------------------------------------------
function BroadcastGameTypeDescription() {}
//------------------------------------------------------------------
// R6SetPawnClassInMultiPlayer
//
//------------------------------------------------------------------
function R6SetPawnClassInMultiPlayer(Controller PlayerController) {}
//------------------------------------------------------------------
// InitObjectives
//
//------------------------------------------------------------------
function InitObjectives() {}
//------------------------------------------------------------------
// UnselectPilot
//
//------------------------------------------------------------------
function UnselectPilot() {}
event PostBeginPlay() {}

state InBetweenRoundMenu
{
    function EndState() {}
}

defaultproperties
{
}
