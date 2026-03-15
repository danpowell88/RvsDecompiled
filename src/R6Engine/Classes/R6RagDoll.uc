//=============================================================================
// R6RagDoll - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6RagDoll.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/21 * Created by Guillaume Borgia
//=============================================================================
class R6RagDoll extends R6
    AbstractCorpse
    native;

const NB_PARTICLES = 16;

struct STParticle
{
	var Coords cCurrentPos;       // Current world-space position and orientation of the bone
	var Vector vPreviousOrigin;   // Origin from the previous simulation step (for velocity integration)
	var Vector vBonePosition;     // Rest-pose bone position used as reference
	var float fMass;              // Particle mass, affects how forces are applied
	var int iToward;              // Index of the bone this particle is constrained toward
	var int iRefBone;             // Reference bone index in the skeleton
	var name BoneName;            // Name of the skeleton bone this particle represents
};

struct STSpring
{
	var int iFirst;        // Index of the first particle in the spring constraint
	var int iSecond;       // Index of the second particle in the spring constraint
	var float fMinSquared; // Minimum squared distance allowed between the two particles
	var float fMaxSquared; // Maximum squared distance allowed between the two particles
};

var float m_fAccumulatedTime;      // Physics time accumulator for fixed-step simulation
var R6AbstractPawn m_pawnOwner;    // The pawn this ragdoll was created from
var array<STSpring> m_aSpring;     // Spring constraints linking pairs of particles
// NEW IN 1.60
var STParticle m_aParticle[16];    // Particle array representing ragdoll bone positions (NB_PARTICLES = 16)

function TakeAHit(int iBone, Vector vMomentum)
{
	AddImpulseToBone(iBone, vMomentum);
	return;
}

function RenderCorpseBones(Canvas C)
{
	RenderBones(C);
	return;
}

defaultproperties
{
	RemoteRole=3
	bAlwaysRelevant=true
	m_bShowInHeatVision=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_aParticleNB_PARTICLES
