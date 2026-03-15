//=============================================================================
// MP2IOKarma - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class MP2IOKarma extends R6InteractiveObject
    native
    placeable;

enum EReactionType
{
	RT_None,                        // 0
	RT_Break,                       // 1
	RT_Karma,                       // 2
	RT_KarmaAndBreak                // 3
};

enum EZDRType
{
	ZDRT_None,                      // 0
	ZDRT_Break                      // 1
};

enum EZDRStat
{
	ZDRS_None,                      // 0
	ZDRS_Contact                    // 1
};

struct stZDRSound
{
	var() byte m_eZDRGroupe;
	var() byte m_eZDRSoundType;
	var() Sound m_aZDRSound;
	var() Actor m_aZDRActor;
	var() float m_fZDRVolume;
};

struct stZDR
{
	var() byte m_eZDRType;
	var byte m_eZDRStat;
	var() float m_fZDRRadius;
	var() Vector m_vZDRLocation;
	var() array<stZDRSound> m_ZDRSoundList;
	var() int m_iZDRDamageStat;
	var() float m_fZDRImpactInterval;
	var float m_fZDRLastImpactTime;
};

struct stActorReactionState
{
	var() float fDamagePercentage;
	var() int iActorStat;
	var() Actor m_actor;
};

var() MP2IOKarma.EReactionType m_eReactionType;
var Actor.EPhysics SavePhysics;
var MP2IOKarma.EReactionType SaveReactionType;
var() bool bCollideRagDoll;
var() bool bUseSafeTimeWithLevel;
var() bool bUseSafeTimeWithSM;
var() bool bHideBefore;
var() bool bHideAfter;
var() bool bHideCollision;
var bool bSimulationActive;
var() bool m_bOneTime;
var bool SavebCollideActors;
var bool SavebBlockActors;
var bool SavebBlockPlayers;
var() float m_fMaxSimAge;
var() float m_fLoseTime;
var float m_fCurrentLoseTime;
var float m_fCurrentSimAge;
var() float m_fZMin;
var() float m_fScaleStartLinVel;
var() float ImpactVolume;
var() float ImpactInterval;
var() array<stZDR> m_ZDRList;
var() array<Sound> ImpactSounds;
var() array<stActorReactionState> m_ActorReactionList;
var Vector SaveLocation;
var Rotator SaveRotation;
var transient float LastImpactTime;

// Export UMP2IOKarma::execMP2IOKarmaAllNativeFct(FFrame&, void* const)
native(4010) final function MP2IOKarmaAllNativeFct(int WhatIdo, Actor _owner, optional float _var_int, optional float _var_float);

simulated function SaveOriginalData()
{
	super.SaveOriginalData();
	SaveLocation = Location;
	SaveRotation = Rotation;
	SavePhysics = Physics;
	SaveReactionType = m_eReactionType;
	SavebCollideActors = bCollideActors;
	SavebBlockActors = bBlockActors;
	SavebBlockPlayers = bBlockPlayers;
	return;
}

simulated function ResetOriginalData()
{
	local int i;

	super.ResetOriginalData();
	__NFUN_267__(SaveLocation) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
	__NFUN_299__(SaveRotation);
	m_eReactionType = SaveReactionType;
	__NFUN_262__(SavebCollideActors, SavebBlockActors, SavebBlockPlayers);
	KSetBlockKarma(true);
	// End:0x58
	if(__NFUN_155__(int(SavePhysics), int(Physics)))
	{
		__NFUN_3970__(SavePhysics);
	}
	// End:0x6C
	if(bHideBefore)
	{
		bHidden = true;		
	}
	else
	{
		bHidden = false;
	}
	__NFUN_4042__(0, none);
	m_fCurrentLoseTime = -1000.0000000;
	m_fCurrentSimAge = -1.0000000;
	bSimulationActive = false;
	__NFUN_118__('Timer');
	__NFUN_118__('Tick');
	return;
}

event ReinitSimulation(int WhatIdo)
{
	ResetOriginalData();
	return;
}

event StopSimulation(int WhatIdo)
{
	local bool bUseZmin;

	// End:0x1A
	if(__NFUN_177__(m_fZMin, -1000000.0000000))
	{
		bUseZmin = true;		
	}
	else
	{
		bUseZmin = false;
	}
	// End:0x46
	if(__NFUN_132__(m_bOneTime, __NFUN_154__(WhatIdo, 2)))
	{
		m_eReactionType = 0;
		__NFUN_3970__(0);
	}
	// End:0x54
	if(bSimulationActive)
	{
		__NFUN_4010__(0, none);
	}
	// End:0xA4
	if(__NFUN_130__(bHideAfter, __NFUN_132__(__NFUN_130__(__NFUN_154__(WhatIdo, 1), bUseZmin), __NFUN_129__(bUseZmin))))
	{
		__NFUN_262__(false, false, false);
		KSetBlockKarma(false);
		m_eReactionType = 0;
		__NFUN_3970__(0);
		bHidden = true;
	}
	m_fCurrentSimAge = -1.0000000;
	bSimulationActive = false;
	__NFUN_4042__(1, none);
	return;
}

event StartSimulation(int WhatIdo)
{
	// End:0x39
	if(__NFUN_129__(bSimulationActive))
	{
		__NFUN_4010__(1, none, 1.0000000);
		__NFUN_3970__(13);
		KWake();
		// End:0x31
		if(bHideBefore)
		{
			bHidden = false;
		}
		bSimulationActive = true;
	}
	m_fCurrentSimAge = m_fMaxSimAge;
	// End:0x55
	if(m_bOneTime)
	{
		m_eReactionType = 0;
	}
	return;
}

event PreBeginPlay()
{
	local int i;

	super(Actor).PreBeginPlay();
	m_fCurrentSimAge = -1.0000000;
	m_fCurrentLoseTime = -1000.0000000;
	bSimulationActive = false;
	__NFUN_118__('Timer');
	__NFUN_118__('Tick');
	return;
}

simulated function Timer()
{
	__NFUN_118__('Timer');
	return;
}

function Tick(float fDeltaTime)
{
	// End:0x1B
	if(__NFUN_178__(m_fCurrentLoseTime, float(-100)))
	{
		__NFUN_118__('Tick');		
	}
	else
	{
		m_fCurrentLoseTime = __NFUN_175__(m_fCurrentLoseTime, fDeltaTime);
		// End:0x4A
		if(__NFUN_176__(m_fCurrentLoseTime, 0.0000000))
		{
			StartSimulation(0);
			__NFUN_118__('Tick');
		}
	}
	return;
}

event KImpact(Actor Other, Vector pos, Vector impactVel, Vector impactNorm)
{
	local int numSounds, soundNum;

	// End:0x43
	if(__NFUN_177__(Level.TimeSeconds, __NFUN_174__(LastImpactTime, ImpactInterval)))
	{
		numSounds = ImpactSounds.Length;
		// End:0x43
		if(__NFUN_151__(numSounds, 0))
		{
			soundNum = __NFUN_167__(numSounds);
		}
	}
	// End:0x6E
	if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)), __NFUN_154__(int(Role), int(ROLE_Authority))))
	{
	}
	return;
}

simulated event ZDRSetDamageState(int iDamageStat, float fPercentage, Vector ZDRLocation)
{
	local int iState, iRandomMesh, iRandomSkin, iStateToUse;
	local float fRandValue;
	local int iActor, iSkin;
	local stDamageState stState;
	local Vector vTagLocation;
	local Rotator rTagRotator;
	local Actor SpawnedActor;

	// End:0x3F
	if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)), __NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer))))
	{
		m_fNetDamagePercentage = fPercentage;
	}
	// End:0x8C
	if(__NFUN_130__(__NFUN_153__(iDamageStat, m_StateList.Length), __NFUN_150__(iDamageStat, 0)))
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("there is no stat", string(iDamageStat)), "   "), string(m_StateList.Length)));
		return;
	}
	iStateToUse = -1;
	stState = m_StateList[iDamageStat];
	iStateToUse = iDamageStat;
	// End:0xD5
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__("New State = ", string(iState)));
	}
	// End:0xE6
	if(__NFUN_154__(iStateToUse, m_iCurrentState))
	{
		return;
	}
	// End:0xFF
	if(__NFUN_154__(iStateToUse, __NFUN_147__(m_StateList.Length, 1)))
	{
		SetBroken();
	}
	// End:0x12A
	if(__NFUN_155__(iStateToUse, -1))
	{
		stState = m_StateList[iStateToUse];
		m_iCurrentState = iStateToUse;
	}
	fRandValue = __NFUN_171__(__NFUN_195__(), 100.0000000);
	// End:0x237
	if(__NFUN_155__(stState.RandomMeshes.Length, 0))
	{
		iRandomMesh = 0;
		J0x151:

		// End:0x1DA [Loop If]
		if(__NFUN_150__(iRandomMesh, stState.RandomMeshes.Length))
		{
			__NFUN_185__(fRandValue, stState.RandomMeshes[iRandomMesh].fPercentage);
			// End:0x1D0
			if(__NFUN_176__(fRandValue, float(0)))
			{
				ChangeStaticMesh(stState.RandomMeshes[iRandomMesh].Mesh);
				// End:0x1CD
				if(__NFUN_114__(stState.RandomMeshes[iRandomMesh].Mesh, none))
				{
					StopSimulation(2);
				}
				// [Explicit Break]
				goto J0x1DA;
			}
			__NFUN_165__(iRandomMesh);
			// [Loop Continue]
			goto J0x151;
		}
		J0x1DA:

		// End:0x237
		if(__NFUN_177__(fRandValue, float(0)))
		{
			ChangeStaticMesh(stState.RandomMeshes[__NFUN_147__(stState.RandomMeshes.Length, 1)].Mesh);
			// End:0x237
			if(__NFUN_114__(stState.RandomMeshes[__NFUN_147__(stState.RandomMeshes.Length, 1)].Mesh, none))
			{
				StopSimulation(2);
			}
		}
	}
	// End:0x367
	if(__NFUN_155__(stState.RandomSkins.Length, 0))
	{
		iRandomSkin = 0;
		J0x24F:

		// End:0x2F1 [Loop If]
		if(__NFUN_150__(iRandomSkin, stState.RandomSkins.Length))
		{
			__NFUN_185__(fRandValue, stState.RandomSkins[iRandomSkin].fPercentage);
			// End:0x2E7
			if(__NFUN_176__(fRandValue, float(0)))
			{
				iSkin = 0;
				J0x294:

				// End:0x2E4 [Loop If]
				if(__NFUN_150__(iSkin, stState.RandomSkins[iRandomSkin].Skin.Length))
				{
					SetSkin(stState.RandomSkins[iRandomSkin].Skin[iSkin], iSkin);
					__NFUN_165__(iSkin);
					// [Loop Continue]
					goto J0x294;
				}
				// [Explicit Break]
				goto J0x2F1;
			}
			__NFUN_165__(iRandomSkin);
			// [Loop Continue]
			goto J0x24F;
		}
		J0x2F1:

		// End:0x367
		if(__NFUN_177__(fRandValue, float(0)))
		{
			iSkin = 0;
			J0x305:

			// End:0x367 [Loop If]
			if(__NFUN_150__(iSkin, stState.RandomSkins[__NFUN_147__(stState.RandomSkins.Length, 1)].Skin.Length))
			{
				SetSkin(stState.RandomSkins[__NFUN_147__(stState.RandomSkins.Length, 1)].Skin[iSkin], iSkin);
				__NFUN_165__(iSkin);
				// [Loop Continue]
				goto J0x305;
			}
		}
	}
	// End:0x484
	if(__NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer)))
	{
		iActor = 0;
		J0x387:

		// End:0x484 [Loop If]
		if(__NFUN_150__(iActor, stState.ActorList.Length))
		{
			// End:0x3BA
			if(__NFUN_114__(stState.ActorList[iActor].ActorToSpawn, none))
			{
				// [Explicit Continue]
				goto J0x47A;
			}
			// End:0x434
			if(__NFUN_123__(stState.ActorList[iActor].HelperName, ""))
			{
				__NFUN_2008__(stState.ActorList[iActor].HelperName, vTagLocation, rTagRotator);
				SpawnedActor = __NFUN_278__(stState.ActorList[iActor].ActorToSpawn,,, __NFUN_215__(Location, vTagLocation), __NFUN_316__(Rotation, rTagRotator));				
			}
			else
			{
				SpawnedActor = __NFUN_278__(stState.ActorList[iActor].ActorToSpawn,,, ZDRLocation, Rotation);
			}
			// End:0x47A
			if(__NFUN_119__(SpawnedActor, none))
			{
				SpawnedActor.RemoteRole = ROLE_None;
			}
			J0x47A:

			__NFUN_165__(iActor);
			// [Loop Continue]
			goto J0x387;
		}
	}
	// End:0x49F
	if(__NFUN_154__(int(Role), int(ROLE_Authority)))
	{
		PlayInteractiveObjectSound(stState);
	}
	return;
}

function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGroup)
{
	local Actor.eStunResult eStunFromTable;
	local int iKillFromHit;
	local Vector vBulletDirection;
	local int iSndIndex;
	local bool bIsSilenced;
	local KarmaParams localkparams;
	local Vector TearOffMomentum, shotDir;
	local int iActor;
	local stActorReactionState stState;
	local MP2IOKarma IOKarmaActor;

	m_iCurrentHitPoints = __NFUN_250__(__NFUN_147__(m_iCurrentHitPoints, iKillValue), 0);
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("currenyt", string(m_iCurrentHitPoints)), "  "), string(iKillValue)));
	// End:0x46
	if(__NFUN_151__(m_iCurrentHitPoints, 0))
	{
		return 0;
	}
	TearOffMomentum = vMomentum;
	iStunValue = 1000;
	// End:0x75
	if(__NFUN_217__(vMomentum, vect(0.0000000, 0.0000000, 0.0000000)))
	{
		return 1;
	}
	vMomentum = __NFUN_212__(__NFUN_226__(vMomentum), float(__NFUN_144__(iStunValue, 100)));
	switch(m_eReactionType)
	{
		// End:0x9B
		case 2:
		// End:0x12F
		case 3:
			// End:0xB1
			if(__NFUN_180__(m_fScaleStartLinVel, 0.0000000))
			{
				return 1;
			}
			StartSimulation(0);
			vMomentum.X = __NFUN_171__(m_fScaleStartLinVel, vMomentum.X);
			vMomentum.Y = __NFUN_171__(m_fScaleStartLinVel, vMomentum.Y);
			vMomentum.Z = __NFUN_171__(m_fScaleStartLinVel, vMomentum.Z);
			KAddImpulse(vMomentum, vHitLocation);
			// End:0x12F
			if(__NFUN_155__(int(m_eReactionType), int(3)))
			{
				// End:0x163
				break;
			}
		// End:0x160
		case 1:
			super.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, TearOffMomentum, iBulletToArmorModifier, iBulletGroup);
			// End:0x163
			break;
		// End:0xFFFF
		default:
			break;
	}
	iActor = 0;
	J0x16A:

	// End:0x282 [Loop If]
	if(__NFUN_150__(iActor, m_ActorReactionList.Length))
	{
		stState = m_ActorReactionList[iActor];
		// End:0x278
		if(__NFUN_119__(stState.m_actor, none))
		{
			// End:0x1E5
			if(__NFUN_154__(stState.iActorStat, 0))
			{
				stState.m_actor.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, TearOffMomentum, iBulletToArmorModifier, iBulletGroup);
				// [Explicit Continue]
				goto J0x278;
			}
			IOKarmaActor = MP2IOKarma(stState.m_actor);
			// End:0x278
			if(__NFUN_130__(__NFUN_119__(IOKarmaActor, none), __NFUN_155__(int(IOKarmaActor.m_eReactionType), int(0))))
			{
				// End:0x268
				if(__NFUN_177__(IOKarmaActor.m_fLoseTime, 0.0000000))
				{
					IOKarmaActor.m_fCurrentLoseTime = IOKarmaActor.m_fLoseTime;
					IOKarmaActor.__NFUN_117__('Tick');
					// [Explicit Continue]
					goto J0x278;
				}
				IOKarmaActor.StartSimulation(0);
			}
		}
		J0x278:

		__NFUN_165__(iActor);
		// [Loop Continue]
		goto J0x16A;
	}
	return;
}

defaultproperties
{
	bCollideRagDoll=true
	m_fMaxSimAge=10.0000000
	m_fCurrentSimAge=-1.0000000
	m_fZMin=-100000000.0000000
	m_fScaleStartLinVel=1.0000000
	m_bHandleRelativeProjectors=true
}