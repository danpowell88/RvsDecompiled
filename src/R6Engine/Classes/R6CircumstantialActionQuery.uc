//=============================================================================
//  R6CircumstantialActionQuery.uc : describes action that can be performed on an actor
//                                  originally stCircumstantialActionQuery
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Aristomenis Kolokathis
//=============================================================================
class R6CircumstantialActionQuery extends R6AbstractCircumstantialActionQuery;

// --- Variables ---
var bool m_bNeedsTick;
var bool bShowLog;

// --- Functions ---
simulated function ClientDisplayMenu(bool bDisplay) {}
simulated event Tick(float fDelta) {}
simulated function ClientPerformCircumstantialAction() {}

defaultproperties
{
}
