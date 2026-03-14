//=============================================================================
//  R6MObjDeathmatch.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
// success: if there's one pawn alive or one team
//
//=============================================================================
class R6MObjDeathmatch extends R6MissionObjectiveBase;

// --- Variables ---
// -1 no winning team
var int m_iWinningTeam;
// in deathmatch
var PlayerController m_winnerCtrl;
var bool m_bTeamDeathmatch;
// must be bigger than 32...
var int m_aLivingPlayerInTeam[48];

// --- Functions ---
//------------------------------------------------------------------
// PawnKilled
//
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn) {}
//------------------------------------------------------------------
// GetWinningTeam: look the last team alive
//	return -1 is none
//------------------------------------------------------------------
function int GetWinningTeam() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ResetLivingPlayer
//
//------------------------------------------------------------------
function ResetLivingPlayerInTeam() {}
function Reset() {}

defaultproperties
{
}
