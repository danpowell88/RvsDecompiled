// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class MP2IOKarma extends R6InteractiveObject
    native;

// --- Enums ---
enum EReactionType
{
    // enum values not recoverable from binary — see 1.56 source
};
enum EZDRType
{
    // enum values not recoverable from binary — see 1.56 source
};
enum EZDRStat
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Structs ---
struct stActorReactionState
{
    var Actor m_actor;
    var int iActorStat;
    var float fDamagePercentage;
};

struct stZDRSound
{
    var byte m_eZDRGroupe;
    var byte m_eZDRSoundType;
    var Sound m_aZDRSound;
    var Actor m_aZDRActor;
    var float m_fZDRVolume;
};

struct stZDR
{
    var byte m_eZDRType;
    var byte m_eZDRStat;
    var float m_fZDRRadius;
    var Vector m_vZDRLocation;
    var array<array> m_ZDRSoundList;
    var int m_iZDRDamageStat;
    var float m_fZDRImpactInterval;
    var float m_fZDRLastImpactTime;
};

// --- Variables ---
var EReactionType m_eReactionType;
var float m_fCurrentLoseTime;
var bool bSimulationActive;
var float m_fCurrentSimAge;
var float m_fScaleStartLinVel;
var EPhysics SavePhysics;
var bool bHideBefore;
var float m_fLoseTime;
var bool m_bOneTime;
var array<array> m_ActorReactionList;
var Vector SaveLocation;
var Rotator SaveRotation;
var EReactionType SaveReactionType;
var bool SavebCollideActors;
var bool SavebBlockActors;
var bool SavebBlockPlayers;
var bool bHideAfter;
var float m_fMaxSimAge;
var float m_fZMin;
var array<array> ImpactSounds;
var float ImpactInterval;
var transient float LastImpactTime;
var bool bCollideRagDoll;
var bool bUseSafeTimeWithLevel;
var bool bUseSafeTimeWithSM;
var bool bHideCollision;
var array<array> m_ZDRList;
var float ImpactVolume;

// --- Functions ---
event KImpact(Actor Other, Vector pos, Vector impactVel, Vector impactNorm) {}
event StopSimulation(int WhatIdo) {}
function Tick(float fDeltaTime) {}
final native function MP2IOKarmaAllNativeFct(int WhatIdo, Actor _owner, optional float _var_int, optional float _var_float) {}
function int R6TakeDamage(Vector vMomentum, int iKillValue, int iStunValue, Vector vHitLocation, Pawn instigatedBy, optional int iBulletGroup, int iBulletToArmorModifier) {}
simulated event ZDRSetDamageState(int iDamageStat, float fPercentage, Vector ZDRLocation) {}
simulated function SaveOriginalData() {}
simulated function ResetOriginalData() {}
event ReinitSimulation(int WhatIdo) {}
event StartSimulation(int WhatIdo) {}
event PreBeginPlay() {}
simulated function Timer() {}

defaultproperties
{
}
