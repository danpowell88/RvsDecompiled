//=============================================================================
//  R6MObjObjectInteraction.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
// Only for rainbow human controller
//
//=============================================================================
class R6MObjObjectInteraction extends R6MissionObjectiveBase;

// --- Variables ---
var R6IOObject m_r6IOObject;
var bool m_bIfDestroyedObjectiveIsFailed;
var bool m_bIfDestroyedObjectiveIsCompleted;
var bool m_bIfDeviceIsDeactivatedObjectiveIsFailed;
var bool m_bIfDeviceIsDeactivatedObjectiveIsCompleted;
var bool m_bIfDeviceIsActivatedObjectiveIsFailed;
var bool m_bIfDeviceIsActivatedObjectiveIsCompleted;

// --- Functions ---
//------------------------------------------------------------------
// IObjectDestroyed
//
//------------------------------------------------------------------
function IObjectDestroyed(Actor anInteractiveObject, Pawn aPawn) {}
//------------------------------------------------------------------
// IObjectInteract
//
//------------------------------------------------------------------
function IObjectInteract(Actor anInteractiveObject, Pawn aPawn) {}
//------------------------------------------------------------------
// Init
//
//------------------------------------------------------------------
function Init() {}

defaultproperties
{
}
