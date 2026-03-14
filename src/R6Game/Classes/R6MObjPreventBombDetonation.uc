//=============================================================================
//  R6MObjPreventBombDetonation.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
// Only for rainbow human controller
//
// fail: if kill, secure, make noise and is seen
//=============================================================================
class R6MObjPreventBombDetonation extends R6MObjObjectInteraction;

// --- Variables ---
var bool m_bIfDetonateObjectiveIsFailed;
var bool m_bIfDetonateObjectiveIsCompleted;

// --- Functions ---
//------------------------------------------------------------------
// IObjectDestroyed
//
//------------------------------------------------------------------
function IObjectDestroyed(Actor anInteractiveObject, Pawn aPawn) {}

defaultproperties
{
}
