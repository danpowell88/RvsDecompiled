// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6FalseHeartBeat extends R6GenericHB
    native;

// --- Variables ---
// Heart Beat time in ms, one for each cicle
var float m_fHeartBeatTime[2];
// Current circle to be start display
var int m_iNoCircleBeat;
// Number of heart beat by minutes.
var float m_fHeartBeatFrequency;
// set to the player pawn that threw the puck (used instead of Instigator)
var Pawn m_HeartBeatPuckOwner;

// --- Functions ---
simulated event bool ProcessHeart(out float fMul1, out float fMul2, float DeltaSeconds) {}
// ^ NEW IN 1.60
simulated function FirstPassReset() {}
simulated event PostBeginPlay() {}

defaultproperties
{
}
