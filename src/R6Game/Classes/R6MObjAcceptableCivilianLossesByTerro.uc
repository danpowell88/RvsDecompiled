//=============================================================================
// R6MObjAcceptableCivilianLossesByTerro - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MObjAcceptableCivilianLossesByTerro.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MObjAcceptableCivilianLossesByTerro extends R6MObjAcceptableLosses
	editinlinenew
    hidecategories(Object);

function PawnKilled(Pawn killed)
{
	local R6Hostage H;

	// End:0x1E
	if(__NFUN_155__(int(killed.m_ePawnType), int(m_ePawnTypeDead)))
	{
		return;
	}
	H = R6Hostage(killed);
	// End:0x7E
	if(H.m_bCivilian)
	{
		// End:0x73
		if(H.m_bPoliceManMp1)
		{
			m_szDescriptionFailure = "PolicemanWasKilledByTerro";
		}
		super.PawnKilled(killed);
	}
	return;
}

defaultproperties
{
	m_ePawnTypeKiller=2
	m_ePawnTypeDead=3
	m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_MissionFailed'
	m_szDescription="Acceptable civilian losses by terro"
	m_szDescriptionFailure="CivilianWasKilledByTerro"
}
