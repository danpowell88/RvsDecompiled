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
