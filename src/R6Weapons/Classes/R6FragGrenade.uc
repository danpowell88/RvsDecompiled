//=============================================================================
//  R6FragGrenade.uc : Normal frag grenade
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Sebastien Lussier
//=============================================================================
class R6FragGrenade extends R6Grenade;

// --- Variables ---
var float m_fTimerCounter;

// --- Functions ---
function Explode() {}
simulated event Timer() {}
function HurtPawns() {}
function Activate() {}

defaultproperties
{
}
