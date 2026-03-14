//=============================================================================
//  R6DZonePath.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================
class R6DZonePath extends R6DeploymentZone
    native;

// --- Enums ---
enum EInformTeam
{
    INFO_EnterPath,
    INFO_ReachNode,
    INFO_FinishWaiting,
    INFO_Engage,
    INFO_ExitPath,
    INFO_Dead
};

// --- Variables ---
var array<array> m_aNode;
var bool m_bActAsGroup;
var bool bShowLog;
var bool m_bCycle;
var bool m_bSelectNodeInEditor;

// --- Functions ---
// function ? GetTerroIndex(...); // REMOVED IN 1.60
//============================================================================
// BOOL IsLeader -
//============================================================================
function bool IsLeader(R6Terrorist terro) {}
// ^ NEW IN 1.60
function Vector GetRandomPointToNode(R6DZonePathNode Node) {}
// ^ NEW IN 1.60
//============================================================================
// InformTerroTeam -
//============================================================================
function InformTerroTeam(R6TerroristAI terroAI, EInformTeam eInfo) {}
//============================================================================
// GetNodeIndex -
//============================================================================
function int GetNodeIndex(R6DZonePathNode Node) {}
// ^ NEW IN 1.60
//============================================================================
// FindNearestNodeInPath -
//============================================================================
function R6DZonePathNode FindNearestNode(Actor Pawn) {}
// ^ NEW IN 1.60
//============================================================================
// BOOL IsAllTerroWaiting -
//============================================================================
function bool IsAllTerroWaiting() {}
// ^ NEW IN 1.60
//============================================================================
// GetNextNode -
//============================================================================
function R6DZonePathNode GetNextNode(R6DZonePathNode Node) {}
// ^ NEW IN 1.60
//============================================================================
// GetPreviousNode -
//============================================================================
function R6DZonePathNode GetPreviousNode(R6DZonePathNode Node) {}
// ^ NEW IN 1.60
//============================================================================
// StartWaiting -
//============================================================================
function StartWaiting(R6TerroristAI terroAI) {}
//============================================================================
// GetNextNodeForTerro -
//============================================================================
function SetNextNodeForTerro(R6TerroristAI terro) {}
//============================================================================
// GoToNextNode -
//============================================================================
function GoToNextNode(R6TerroristAI terroAI) {}
//============================================================================
// R6Terrorist GetLeader -
//============================================================================
function R6Terrorist GetLeader() {}
// ^ NEW IN 1.60

defaultproperties
{
}
