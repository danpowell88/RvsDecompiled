//=============================================================================
//  R6MObjNeutralizeTerrorist.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
// fail: if m_bMustSecureTerroInDepZone and the terro is dead
// success: once m_iNeutralizePercentage is reached
//
// example: 
//  - kill or secure all terro in the level
//  - kill or secure a group of terro (specify deployment zone) 
//  - kill or secure a specific terro (specify deployment zone) 
//  - secure a specific terro (specify deployment zone & m_bMustSecureTerroInDepZone) 
//=============================================================================
class R6MObjNeutralizeTerrorist extends R6MissionObjectiveBase;

// --- Variables ---
var R6DeploymentZone m_depZone;
var int m_iNeutralizePercentage;
var bool m_bMustSecureTerroInDepZone;

// --- Functions ---
function PawnSecure(Pawn secured) {}
function PawnKilled(Pawn killed) {}
function Init() {}

defaultproperties
{
}
