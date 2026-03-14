// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Game.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6AlarmCallToSupport extends R6Alarm;

// --- Enums ---
enum ETerroristTarget
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var array<array> m_IOSoundList;
// ^ NEW IN 1.60
var float m_fTimeStart;
var ETerroristTarget m_eTerroristTarget;
// ^ NEW IN 1.60
var eMovementPace m_ePace;
// ^ NEW IN 1.60
var float m_fActivationTime;
// ^ NEW IN 1.60
var int m_iTerroristGroup;
// ^ NEW IN 1.60
var Sound m_sndAlarmSound;
// ^ NEW IN 1.60
var Sound m_sndAlarmSoundStop;
// ^ NEW IN 1.60

// --- Functions ---
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
function SetAlarm(Vector vLocation) {}
function Tick(float fDeltaTime) {}

state StartUp
{
}

defaultproperties
{
}
