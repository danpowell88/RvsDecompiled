//=============================================================================
//  R6MObjGoToExtraction.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  fail: if pawn killed
//  success: if he is in a extraction zone
//=============================================================================
class R6MObjGoToExtraction extends R6MissionObjectiveBase;

// --- Variables ---
// the pawn to extract OR
var R6Pawn m_pawnToExtract;
var bool m_bExtractAtLeastOneRainbow;
// ^ NEW IN 1.60

// --- Functions ---
//------------------------------------------------------------------
// SetPawnToExtract
//	specify which pawn to extract
//------------------------------------------------------------------
function SetPawnToExtract(R6Pawn aPawn) {}
//------------------------------------------------------------------
// PawnKilled
//
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn) {}
//------------------------------------------------------------------
// EnteredExtractionZone
//
//------------------------------------------------------------------
function EnteredExtractionZone(Pawn aPawn) {}
function Init() {}
//------------------------------------------------------------------
// Reset
//
//------------------------------------------------------------------
function Reset() {}

defaultproperties
{
}
