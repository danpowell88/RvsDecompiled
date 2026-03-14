//=============================================================================
//  R6RagDoll.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/21 * Created by Guillaume Borgia
//=============================================================================
class R6RagDoll extends R6AbstractCorpse
    native;

// --- Constants ---
const NB_PARTICLES =  16;

// --- Structs ---
struct STParticle
{
    var coords  cCurrentPos;
    var vector  vPreviousOrigin;
    var vector  vBonePosition;
    var FLOAT   fMass;
    var INT     iToward;
    var INT     iRefBone;
    var name    boneName;
};

struct STSpring
{
    var INT     iFirst;
    var INT     iSecond;
    var FLOAT   fMinSquared;
    var FLOAT   fMaxSquared;
};

// --- Variables ---
// var ? boneName; // REMOVED IN 1.60
// var ? cCurrentPos; // REMOVED IN 1.60
// var ? fMass; // REMOVED IN 1.60
// var ? fMaxSquared; // REMOVED IN 1.60
// var ? fMinSquared; // REMOVED IN 1.60
// var ? iFirst; // REMOVED IN 1.60
// var ? iRefBone; // REMOVED IN 1.60
// var ? iSecond; // REMOVED IN 1.60
// var ? iToward; // REMOVED IN 1.60
// var ? vBonePosition; // REMOVED IN 1.60
// var ? vPreviousOrigin; // REMOVED IN 1.60
var STParticle m_aParticle[16];
var array<array> m_aSpring;
var R6AbstractPawn m_pawnOwner;
var float m_fAccumulatedTime;

// --- Functions ---
function RenderCorpseBones(Canvas C) {}
function TakeAHit(int iBone, Vector vMomentum) {}

defaultproperties
{
}
