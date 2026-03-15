//=============================================================================
// R6MObjAcceptableRainbowLosses - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MObjAcceptableRainbowLosses.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MObjAcceptableRainbowLosses extends R6MObjAcceptableLosses
	editinlinenew
    hidecategories(Object);

defaultproperties
{
	m_ePawnTypeKiller=4
	m_ePawnTypeDead=1
	m_iAcceptableLost=100
	m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_TeamWipedOut'
	m_szDescription="Acceptable rainbow losses"
	m_szDescriptionInMenu="RaibowTeamMustSurvive"
	m_szDescriptionFailure="YourTeamWasWipedOut"
}
