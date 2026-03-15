//=============================================================================
// R6MObjAcceptableHostageLossesByTerro - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MObjAcceptableHostageLossesByTerro.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MObjAcceptableHostageLossesByTerro extends R6MObjAcceptableLosses
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
	// End:0x4D
	if((!H.m_bCivilian))
	{
		super.PawnKilled(killed);
	}
	return;
}

defaultproperties
{
	m_ePawnTypeKiller=2
	m_ePawnTypeDead=3
	m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_HostageKilled'
	m_szDescription="Acceptable hostage losses by terro"
	m_szDescriptionInMenu="AvoidHostageCasualities"
	m_szDescriptionFailure="HostageWasKilledByTerro"
}
