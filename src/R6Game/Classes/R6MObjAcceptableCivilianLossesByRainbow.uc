//=============================================================================
// R6MObjAcceptableCivilianLossesByRainbow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MObjAcceptableCivilianLossesByRainbow.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MObjAcceptableCivilianLossesByRainbow extends R6MObjAcceptableLosses
	editinlinenew
    hidecategories(Object);

function PawnKilled(Pawn killed)
{
	local R6Hostage H;

	// End:0x1E
	if((int(killed.m_ePawnType) != int(m_ePawnTypeDead)))
	{
		return;
	}
	H = R6Hostage(killed);
	// End:0x8B
	if(H.m_bCivilian)
	{
		// End:0x80
		if(H.m_bPoliceManMp1)
		{
			m_szDescriptionFailure = "PolicemanWasKilledByRainbow";
			m_sndSoundFailure = Sound'Voices_Control_MissionFailed.Play_MissionFailed';
		}
		super.PawnKilled(killed);
	}
	return;
}

defaultproperties
{
	m_ePawnTypeKiller=1
	m_ePawnTypeDead=3
	m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_CivilianKilled'
	m_szDescription="Acceptable civilian losses by rainbow"
	m_szDescriptionInMenu="AvoidCivilianCasualities"
	m_szDescriptionFailure="CivilianWasKilledByRainbow"
}
