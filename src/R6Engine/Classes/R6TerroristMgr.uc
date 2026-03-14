//=============================================================================
//  R6TerroristMgr.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:  Terrorist AI manager for interaction with hostage
//    2001/12/03 * Created by Guillaume Borgia
//=============================================================================
class R6TerroristMgr extends R6AbstractTerroristMgr
    native;

// --- Constants ---
const MAX_Hostage =  16;

// --- Structs ---
struct STHostage
{
    var R6Hostage       hostage;
    var R6TerroristAI   terro;
    var INT             bInZone;
};

// --- Variables ---
// var ? bInZone; // REMOVED IN 1.60
// var ? hostage; // REMOVED IN 1.60
// var ? terro; // REMOVED IN 1.60
var STHostage m_ArrayHostage[16];
var int m_iCurrentMax;
var int m_iCurrentGroupID;
// List of DZone with hostage associated
var const array<array> m_aDeploymentZoneWithHostage;

// --- Functions ---
final native function Init(Actor dummy) {}
// ^ NEW IN 1.60
final native function R6DeploymentZone FindNearestZoneForHostage(R6Terrorist terro) {}
// ^ NEW IN 1.60
function Initialization(Actor dummy) {}
//============================================================================
// IsHostageAssigned -
//============================================================================
function bool IsHostageAssigned(R6Hostage hostage) {}
// ^ NEW IN 1.60
//============================================================================
// AssignHostageTo -
//============================================================================
function AssignHostageTo(R6TerroristAI terro, R6Hostage hostage) {}
//============================================================================
// AssignHostageToZone -
//============================================================================
function AssignHostageToZone(R6Hostage hostage, R6DeploymentZone Zone) {}
//============================================================================
// RemoveHostageAssignment -
//============================================================================
function RemoveHostageAssignment(R6Hostage hostage) {}
//============================================================================
// FindHostageIndex -
//============================================================================
function int FindHostageIndex(R6Hostage hostage) {}
// ^ NEW IN 1.60
//============================================================================
// ResetOriginalData -
//============================================================================
function ResetOriginalData() {}

defaultproperties
{
}
