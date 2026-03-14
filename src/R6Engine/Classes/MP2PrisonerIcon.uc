// MP2PrisonerIcon - HUD/map icon representing a prisoner in Mission Pack 2 CTE mode.
// Extends R6ReferenceIcons to show which team the prisoner belongs to and whether
// the prisoner's location is known to the opposing team.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class MP2PrisonerIcon extends R6ReferenceIcons;

// --- Variables ---
var int m_iPrisonerTeam;
var bool m_bKnownForOtherTeam;

defaultproperties
{
}
