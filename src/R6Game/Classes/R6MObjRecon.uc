//=============================================================================
//  R6MObjRecon.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
// Only for rainbow 
//
// fail: if kill, secure, make noise and is seen
//=============================================================================
class R6MObjRecon extends R6MissionObjectiveBase;

// --- Variables ---
var bool m_bCanSeeMe;
var bool m_bCanMakeNoise;
var bool m_bCanSecure;
var bool m_bCanKill;

// --- Functions ---
//------------------------------------------------------------------
// PawnSeen
//
//------------------------------------------------------------------
function PawnSeen(Pawn seen, Pawn witness) {}
//------------------------------------------------------------------
// PawnHeard
//
//------------------------------------------------------------------
function PawnHeard(Pawn seen, Pawn witness) {}
//------------------------------------------------------------------
// PawnKilled
//
//------------------------------------------------------------------
function PawnKilled(Pawn killed) {}
//------------------------------------------------------------------
// Init
//
//------------------------------------------------------------------
function Init() {}
//------------------------------------------------------------------
// PawnSecure
//
//------------------------------------------------------------------
function PawnSecure(Pawn securedPawn) {}

defaultproperties
{
}
