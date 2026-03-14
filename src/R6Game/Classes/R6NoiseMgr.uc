//=============================================================================
//  R6NoiseMgr.uc : Store value for sound loudness of MakeNoise
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/15 * Created by Guillaume Borgia
//=============================================================================
class R6NoiseMgr extends R6AbstractNoiseMgr
    config(sound);

// --- Structs ---
struct STSound
{
    var FLOAT               fSndDist;
    var Actor.ENoiseType    eType;
};

struct STPawnMovement
{
    var FLOAT               fStandSlow;
    var FLOAT               fStandFast;
    var FLOAT               fCrouchSlow;
    var FLOAT               fCrouchFast;
    var FLOAT               fProne;
    var Actor.ENoiseType    eType;
};

// --- Variables ---
// var ? eType; // REMOVED IN 1.60
// var ? fCrouchFast; // REMOVED IN 1.60
// var ? fCrouchSlow; // REMOVED IN 1.60
// var ? fProne; // REMOVED IN 1.60
// var ? fSndDist; // REMOVED IN 1.60
// var ? fStandFast; // REMOVED IN 1.60
// var ? fStandSlow; // REMOVED IN 1.60
// var ? m_SndExplosion; // REMOVED IN 1.60
var config STSound m_SndBulletImpact;
var config STSound m_SndGrenadeImpact;
var config STSound m_SndGrenadeLike;
var config STSound m_sndExplosion;
// ^ NEW IN 1.60
var config STSound m_SndChoking;
var config STSound m_SndTalking;
var config STSound m_SndScreaming;
var config STSound m_SndReload;
var config STSound m_SndEquipping;
var config STSound m_SndDead;
var config STSound m_SndDoor;
var config STPawnMovement m_Rainbow;
var config STPawnMovement m_Terro;
var config STPawnMovement m_Hostage;
var config STSound m_SndBulletRicochet;
// debug
var bool bShowLog;

// --- Functions ---
//============================================================================
// R6MakeNoise -
//============================================================================
event R6MakeNoise(Actor Source, ESoundType ESoundType) {}
//============================================================================
// R6MakePawnMovementNoise -
//============================================================================
event R6MakePawnMovementNoise(R6AbstractPawn Pawn) {}
//============================================================================
// MakeANoise - ESoundType
//============================================================================
function MakeANoise(float fDist, Actor Source, ENoiseType ENoiseType, EPawnType EPawnType, ESoundType ESoundType) {}
//============================================================================
// Init -
//============================================================================
function Init() {}

defaultproperties
{
}
