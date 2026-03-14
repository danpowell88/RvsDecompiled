//=============================================================================
// R6NoiseMgr - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6NoiseMgr.uc : Store value for sound loudness of MakeNoise
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/15 * Created by Guillaume Borgia
//=============================================================================
class R6NoiseMgr extends R6
    AbstractNoiseMgr
    config(Sound);

struct STSound
{
	var float fSndDist;
	var Actor.ENoiseType eType;
};

struct STPawnMovement
{
	var float fStandSlow;
	var float fStandFast;
	var float fCrouchSlow;
	var float fCrouchFast;
	var float fProne;
	var Actor.ENoiseType eType;
};

// debug
var bool bShowLog;
var config STSound m_SndBulletImpact;
var config STSound m_SndBulletRicochet;
var config STSound m_SndGrenadeImpact;
var config STSound m_SndGrenadeLike;
var config STSound m_sndExplosion;
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

//============================================================================
// Init - 
//============================================================================
function Init()
{
	__NFUN_536__();
	return;
}

//============================================================================
// MakeANoise - ESoundType
//============================================================================
function MakeANoise(Actor Source, float fDist, Actor.ENoiseType ENoiseType, Actor.EPawnType EPawnType, Actor.ESoundType ESoundType)
{
	// End:0x2F
	if(__NFUN_177__(fDist, 0.0000000))
	{
		Source.__NFUN_512__(fDist, ENoiseType, EPawnType, ESoundType);
	}
	return;
}

//============================================================================
// R6MakeNoise - 
//============================================================================
event R6MakeNoise(Actor.ESoundType ESoundType, Actor Source)
{
	local float fDist;
	local R6AbstractPawn aR6Pawn;
	local Actor.ENoiseType ENoiseType;
	local Actor.EPawnType EPawnType;
	local R6Weapons srcWeapon;

	aR6Pawn = R6AbstractPawn(Source.Instigator);
	// End:0x323
	if(__NFUN_119__(aR6Pawn, none))
	{
		EPawnType = aR6Pawn.m_ePawnType;
		switch(ESoundType)
		{
			// End:0xE0
			case 1:
				srcWeapon = R6Weapons(Source);
				// End:0x61
				if(__NFUN_114__(srcWeapon, none))
				{
					return;
				}
				// End:0x8D
				if(__NFUN_177__(aR6Pawn.m_NextFireSound, aR6Pawn.Level.TimeSeconds))
				{
					return;
				}
				aR6Pawn.m_NextFireSound = __NFUN_174__(aR6Pawn.Level.TimeSeconds, 0.3300000);
				fDist = __NFUN_171__(srcWeapon.m_fFireSoundRadius, 1.5000000);
				ENoiseType = 1;
				// End:0x304
				break;
			// End:0x161
			case 2:
				// End:0x111
				if(__NFUN_177__(aR6Pawn.m_NextBulletImpact, aR6Pawn.Level.TimeSeconds))
				{
					return;
				}
				aR6Pawn.m_NextBulletImpact = __NFUN_174__(aR6Pawn.Level.TimeSeconds, 0.3300000);
				fDist = m_SndBulletImpact.fSndDist;
				ENoiseType = m_SndBulletImpact.eType;
				// End:0x304
				break;
			// End:0x191
			case 3:
				fDist = m_SndGrenadeImpact.fSndDist;
				ENoiseType = m_SndGrenadeImpact.eType;
				EPawnType = 4;
				// End:0x304
				break;
			// End:0x1B9
			case 4:
				fDist = m_SndGrenadeLike.fSndDist;
				ENoiseType = m_SndGrenadeLike.eType;
				// End:0x304
				break;
			// End:0x1E1
			case 5:
				fDist = m_sndExplosion.fSndDist;
				ENoiseType = m_sndExplosion.eType;
				// End:0x304
				break;
			// End:0x209
			case 7:
				fDist = m_SndChoking.fSndDist;
				ENoiseType = m_SndChoking.eType;
				// End:0x304
				break;
			// End:0x231
			case 8:
				fDist = m_SndTalking.fSndDist;
				ENoiseType = m_SndTalking.eType;
				// End:0x304
				break;
			// End:0x259
			case 9:
				fDist = m_SndScreaming.fSndDist;
				ENoiseType = m_SndScreaming.eType;
				// End:0x304
				break;
			// End:0x281
			case 10:
				fDist = m_SndReload.fSndDist;
				ENoiseType = m_SndReload.eType;
				// End:0x304
				break;
			// End:0x2A9
			case 11:
				fDist = m_SndEquipping.fSndDist;
				ENoiseType = m_SndEquipping.eType;
				// End:0x304
				break;
			// End:0x2D9
			case 12:
				fDist = m_SndDead.fSndDist;
				ENoiseType = m_SndDead.eType;
				EPawnType = 4;
				// End:0x304
				break;
			// End:0x301
			case 13:
				fDist = m_SndDoor.fSndDist;
				ENoiseType = m_SndDoor.eType;
				// End:0x304
				break;
			// End:0xFFFF
			default:
				break;
		}
		MakeANoise(Source, fDist, ENoiseType, EPawnType, ESoundType);
	}
	return;
}

//============================================================================
// R6MakePawnMovementNoise - 
//============================================================================
event R6MakePawnMovementNoise(R6AbstractPawn Pawn)
{
	local float fDist;
	local Actor.EPawnType EPawnType;
	local R6Pawn aR6Pawn;
	local bool bIsRunning;
	local STPawnMovement pawnMove;
	local float fStealth;

	aR6Pawn = R6Pawn(Pawn);
	EPawnType = aR6Pawn.m_ePawnType;
	// End:0x42
	if(__NFUN_154__(int(EPawnType), int(2)))
	{
		pawnMove = m_Terro;		
	}
	else
	{
		// End:0x60
		if(__NFUN_154__(int(EPawnType), int(1)))
		{
			pawnMove = m_Rainbow;			
		}
		else
		{
			pawnMove = m_Hostage;
		}
	}
	bIsRunning = aR6Pawn.IsRunning();
	// End:0xA6
	if(aR6Pawn.m_bIsProne)
	{
		fDist = pawnMove.fProne;		
	}
	else
	{
		// End:0xE7
		if(aR6Pawn.bIsCrouched)
		{
			// End:0xD4
			if(bIsRunning)
			{
				fDist = pawnMove.fCrouchFast;				
			}
			else
			{
				fDist = pawnMove.fCrouchSlow;
			}			
		}
		else
		{
			// End:0x103
			if(bIsRunning)
			{
				fDist = pawnMove.fStandFast;				
			}
			else
			{
				fDist = pawnMove.fStandSlow;
			}
		}
	}
	fStealth = Pawn.GetSkill(4);
	fStealth = float(__NFUN_251__(int(fStealth), 0, int(1.5000000)));
	__NFUN_182__(fDist, __NFUN_175__(1.2500000, __NFUN_171__(fStealth, 0.5000000)));
	MakeANoise(Pawn, fDist, pawnMove.eType, EPawnType, 6);
	return;
}

defaultproperties
{
	m_SndBulletImpact=(fSndDist=500.0000000,eType=2)
	m_SndBulletRicochet=(fSndDist=500.0000000,eType=2)
	m_SndGrenadeImpact=(fSndDist=700.0000000,eType=3)
	m_SndGrenadeLike=(fSndDist=700.0000000,eType=1)
	m_sndExplosion=(fSndDist=2500.0000000,eType=2)
	m_SndChoking=(fSndDist=1000.0000000,eType=1)
	m_SndTalking=(fSndDist=1000.0000000,eType=1)
	m_SndScreaming=(fSndDist=2000.0000000,eType=1)
	m_SndReload=(fSndDist=500.0000000,eType=1)
	m_SndEquipping=(fSndDist=600.0000000,eType=1)
	m_SndDead=(fSndDist=600.0000000,eType=4)
	m_SndDoor=(fSndDist=1000.0000000,eType=1)
	m_Rainbow=(fStandSlow=300.0000000,fStandFast=800.0000000,fCrouchSlow=400.0000000,fCrouchFast=800.0000000,fProne=600.0000000,eType=1)
	m_Terro=(fStandSlow=1000.0000000,fStandFast=1500.0000000,fCrouchSlow=1500.0000000,fCrouchFast=2000.0000000,fProne=2000.0000000,eType=1)
	m_Hostage=(fStandSlow=1000.0000000,fStandFast=1500.0000000,fCrouchSlow=1500.0000000,fCrouchFast=2000.0000000,fProne=2000.0000000,eType=1)
}
