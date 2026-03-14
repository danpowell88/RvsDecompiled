// MP2IODevice - Mission Pack 2 interactive device terminal.
// Extends R6IODevice to support the numbered terminal panels used in MP2 missions.
// Tracks which terminal index (panel number) this device represents, and overrides
// the interaction time and circumstantial action query for mission-specific logic.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class MP2IODevice extends R6IODevice;

// --- Variables ---
var int m_iTerminalIndex;

// --- Functions ---
function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup) {}
simulated function float GetTimeRequired(R6Pawn aPawn) {}
simulated event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController, float fDistance) {}

defaultproperties
{
}
