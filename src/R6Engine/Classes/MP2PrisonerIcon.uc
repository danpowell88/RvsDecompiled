//=============================================================================
// MP2PrisonerIcon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class MP2PrisonerIcon extends R6ReferenceIcons
 placeable;

var(LimitSeats) int m_iPrisonerTeam;
var(LimitSeats) bool m_bKnownForOtherTeam;

defaultproperties
{
	m_bKnownForOtherTeam=true
	bStatic=true
}