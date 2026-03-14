// R6IOProvider - Interactive object that provides a resource or service over time.
// Used for oxygen stations and similar timed-interaction devices introduced in MP2.
// Tracks elapsed and remaining interaction time, augmentation rate per second,
// and replicates the time-left value to clients for HUD progress display.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6IOProvider extends R6IOObject;

// --- Variables ---
var float m_fTimeElapsed;
var /* replicated */ float m_fRepTimeLeft;
var float m_fTimeLeft;
var float m_fOxygeneLevelCAStart;
var float m_fLastLevelTime;
var float m_fAugmentationPerSecond;
var float m_fDisarmBombTimeMax;
var Texture m_ProviderIcon;
var bool bShowLog;
var float m_fDisarmBombTimeMin;
var int m_iMP2DeviceAnim;

// --- Functions ---
function ForceTimeLeft(float fTime) {}
simulated function float GetTimeRequired(R6Pawn aPawn) {}
simulated function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query) {}
simulated function ToggleDevice(R6Pawn aPawn) {}
simulated function int R6GetCircumstantialActionProgress(Pawn actingPawn, R6AbstractCircumstantialActionQuery Query) {}
simulated event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController, float fDistance) {}
simulated function ResetOriginalData() {}
simulated function float GetTimeLeft() {}
simulated function Timer() {}
simulated function float GetMaxTimeRequired() {}
simulated function R6CircumstantialActionCancel() {}

defaultproperties
{
}
