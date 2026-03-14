//=============================================================================
//  R6MObjCompleteAllAndGoToExtraction.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
//  Complete all mission objectives (except Morality AND mission objectives 
//  that are flagged with m_bIfCompletedMissionIsSuccessfull).
//  
//  Only valid for a human player
//
//  Special: in the manager, added at the end of the list of mission objectives 
//
//  fail: if one of the objectives fails (excluding exceptions_
//  success: if all MO are compledted 
//=============================================================================
class R6MObjCompleteAllAndGoToExtraction extends R6MissionObjectiveBase;

// --- Functions ---
function EnteredExtractionZone(Pawn aPawn) {}
//------------------------------------------------------------------
// isCompleted
//
//------------------------------------------------------------------
function bool isCompleted() {}
// ^ NEW IN 1.60
function Init() {}

defaultproperties
{
}
