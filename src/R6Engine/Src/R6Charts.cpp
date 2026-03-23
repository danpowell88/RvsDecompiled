/*=============================================================================
	R6Charts.cpp
	R6Charts — damage/kill/stun chart tables and bullet penetration.
=============================================================================*/

#include "R6EnginePrivate.h"

// --- R6Charts ---

IMPL_MATCH("R6Engine.dll", 0x1003f6c0)
R6Charts::R6Charts()
{
}

IMPL_MATCH("R6Engine.dll", 0x1003f6d0)
R6Charts& R6Charts::operator=(R6Charts const &)
{
	return *this;
}

IMPL_MATCH("R6Engine.dll", 0x1003f780)
INT R6Charts::BulletGoesThroughCharacter(INT iEnergy, INT iGroup, INT iThreshold, INT iSide)
{
	INT iResult = (INT)(iEnergy - (FLOAT)m_iHumanPenetrationTresholds[iGroup][iThreshold] * m_fHumanSidePenetrationFactors[iGroup][iSide]);
	if( iResult > 5000 )
		iResult = 5000;
	return iResult;
}

IMPL_MATCH("R6Engine.dll", 0x1003f6e0)
stResultTable* R6Charts::GetKillTable(eBodyPart ePart)
{
	// Body parts map to 3 groups: Head, Torso (Chest+Abdomen), Limbs (Legs+Arms).
	// Recovered from Ghidra: switch on eBodyPart returning into m_stKillChart.
	switch (ePart)
	{
	case BP_Head:
		return &m_stKillChart.BodyPartGroup[0];
	case BP_Chest:
	case BP_Abdomen:
		return &m_stKillChart.BodyPartGroup[1];
	case BP_Legs:
	case BP_Arms:
		return &m_stKillChart.BodyPartGroup[2];
	default:
		return NULL;
	}
}

IMPL_MATCH("R6Engine.dll", 0x1003f730)
stResultTable* R6Charts::GetStunTable(eBodyPart ePart)
{
	switch (ePart)
	{
	case BP_Head:
		return &m_stStunChart.BodyPartGroup[0];
	case BP_Chest:
	case BP_Abdomen:
		return &m_stStunChart.BodyPartGroup[1];
	case BP_Legs:
	case BP_Arms:
		return &m_stStunChart.BodyPartGroup[2];
	default:
		return NULL;
	}
}

stBodyPart R6Charts::m_stKillChart;
stBodyPart R6Charts::m_stStunChart;
static FLOAT GHumanSidePenetrationFactors[3][2] =
{
	{1.00f, 0.80f},
	{1.00f, 1.25f},
	{1.00f, 1.15f},
};
static INT GHumanPenetrationThresholds[3][3] =
{
	{600, 650, 675},
	{650, 675, 700},
	{450, 600, 650},
};
float (*R6Charts::m_fHumanSidePenetrationFactors)[2] = GHumanSidePenetrationFactors;
int (*R6Charts::m_iHumanPenetrationTresholds)[3] = GHumanPenetrationThresholds;

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
