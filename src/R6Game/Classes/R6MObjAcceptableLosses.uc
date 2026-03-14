//=============================================================================
//  R6MObjAcceptableLosses.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MObjAcceptableLosses extends R6MissionObjectiveBase
    abstract;

// --- Variables ---
var int m_iKillerTeamID;
var EPawnType m_ePawnTypeDead;
var int m_iAcceptableLost;
// ^ NEW IN 1.60
var EPawnType m_ePawnTypeKiller;
var bool m_bConsiderSuicide;
// ^ NEW IN 1.60

// --- Functions ---
//------------------------------------------------------------------
// PawnKilled
//
//------------------------------------------------------------------
function PawnKilled(Pawn killed) {}
function Reset() {}

defaultproperties
{
}
