//=============================================================================
// R6SmokeCloud - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6SmokeCloud.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/06 * Created by Guillaume Borgia
//=============================================================================
class R6SmokeCloud extends Actor
    native
    notplaceable;

var float m_fStartTime;
var float m_fExpansionTime;  // Time needed to reach maximum radius
var float m_fFinalRadius;
var float m_fCurrentRadius;
var R6Grenade m_grenade;

//============================================================================
// SetCloud - 
//============================================================================
function SetCloud(R6Grenade aGrenade, float fExpansionTime, float fFinalRadius, float fDuration)
{
	m_grenade = aGrenade;
	m_fExpansionTime = fExpansionTime;
	m_fFinalRadius = fFinalRadius;
	LifeSpan = fDuration;
	m_fStartTime = Level.TimeSeconds;
	Instigator = none;
	SetTimer(0.2500000, true);
	return;
}

//============================================================================
// Timer - 
//============================================================================
event Timer()
{
	local float fElapsedTime;

	fElapsedTime = (Level.TimeSeconds - m_fStartTime);
	// End:0x61
	if(((m_grenade != none) && (int(m_grenade.Physics) != int(0))))
	{
		SetLocation((m_grenade.Location + vect(0.0000000, 0.0000000, 125.0000000)));
	}
	// End:0x8C
	if((fElapsedTime < m_fExpansionTime))
	{
		m_fCurrentRadius = ((fElapsedTime / m_fExpansionTime) * m_fFinalRadius);		
	}
	else
	{
		m_fCurrentRadius = m_fFinalRadius;
		SetTimer(0.0000000, false);
	}
	SetCollisionSize(m_fCurrentRadius, CollisionHeight);
	return;
}

defaultproperties
{
	RemoteRole=0
	DrawType=0
	m_bDeleteOnReset=true
	bCollideActors=true
	CollisionRadius=10.0000000
	CollisionHeight=125.0000000
}
