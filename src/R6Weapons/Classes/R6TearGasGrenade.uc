//=============================================================================
//  R6TearGasGrenade.uc : TearGas grenade
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Joel Tremblay
//=============================================================================
class R6TearGasGrenade extends R6Grenade;

// --- Variables ---
// Time needed to reach maximum radius
var float m_fExpansionTime;
var bool m_bGrenadeExploded;
// Time at wich the explosion occured
var float m_fStartTime;

// --- Functions ---
function Timer() {}
simulated function Explode() {}
function HurtPawns() {}
simulated event Destroyed() {}

defaultproperties
{
}
