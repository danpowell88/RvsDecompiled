//=============================================================================
//  R6SmokeCloud.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/06 * Created by Guillaume Borgia
//=============================================================================
class R6SmokeCloud extends Actor
    native;

// --- Variables ---
var R6Grenade m_grenade;
// Time needed to reach maximum radius
var float m_fExpansionTime;
var float m_fFinalRadius;
var float m_fCurrentRadius;
var float m_fStartTime;

// --- Functions ---
//============================================================================
// SetCloud -
//============================================================================
function SetCloud(R6Grenade aGrenade, float fExpansionTime, float fDuration, float fFinalRadius) {}
//============================================================================
// Timer -
//============================================================================
event Timer() {}

defaultproperties
{
}
