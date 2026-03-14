//=============================================================================
//  R6MObjRescueHostage.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
// success: if enough hostage are rescued in the extraction zone
// fail: if there's too much dead hostage/civilian to complete the mission
//
// example: 
//  - rescue all hostage
//  - rescue a specific hostage (specify the m_depZone)
//  - rescue a specific group hostage (specify the m_depZone)
// 
// ** no difference between a hostage and a civilian
//=============================================================================
class R6MObjRescueHostage extends R6MissionObjectiveBase;

// --- Variables ---
var R6DeploymentZone m_depZone;
var int m_iRescuePercentage;
var bool m_bRescueAllRemainingHostage;
var bool m_bCheckPawnKilled;

// --- Functions ---
function EnteredExtractionZone(Pawn aPawn) {}
//------------------------------------------------------------------
// PawnKilled
//
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn) {}
function string GetDescriptionBasedOnNbOfHostages(LevelInfo Level) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Init
//
//------------------------------------------------------------------
function Init() {}

defaultproperties
{
}
