//=============================================================================
// R6RagDoll - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
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
	var Coords cCurrentPos;
	var Vector vPreviousOrigin;
	var Vector vBonePosition;
	var float fMass;
	var int iToward;
	var int iRefBone;
	var name BoneName;
};

struct STSpring
{
	var int iFirst;
	var int iSecond;
	var float fMinSquared;
	var float fMaxSquared;
};

var float m_fAccumulatedTime;
var R6AbstractPawn m_pawnOwner;
var array<STSpring> m_aSpring;
// NEW IN 1.60
var STParticle m_aParticle[16];

function TakeAHit(int iBone, Vector vMomentum)
{
	__NFUN_1804__(iBone, vMomentum);
	return;
}

function RenderCorpseBones(Canvas C)
{
	__NFUN_1802__(C);
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
