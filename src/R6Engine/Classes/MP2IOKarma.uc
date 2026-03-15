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
	SetLocation(SaveLocation);
	SetRotation(SaveRotation);
	m_eReactionType = SaveReactionType;
	SetCollision(SavebCollideActors, SavebBlockActors, SavebBlockPlayers);
	KSetBlockKarma(true);
	// End:0x58
	if((int(SavePhysics) != int(Physics)))
	{
		SetPhysics(SavePhysics);
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
	KMP2IOKarmaAllNativeFct(0, none);
	m_fCurrentLoseTime = -1000.0000000;
	m_fCurrentSimAge = -1.0000000;
	bSimulationActive = false;
	Disable('Timer');
	Disable('Tick');
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
	if((m_fZMin > -1000000.0000000))
	{
		bUseZmin = true;		
	}
	else
	{
		bUseZmin = false;
	}
	// End:0x46
	if((m_bOneTime || (WhatIdo == 2)))
	{
		m_eReactionType = 0;
		SetPhysics(0);
	}
	// End:0x54
	if(bSimulationActive)
	{
		MP2IOKarmaAllNativeFct(0, none);
	}
	// End:0xA4
	if((bHideAfter && (((WhatIdo == 1) && bUseZmin) || (!bUseZmin))))
	{
		SetCollision(false, false, false);
		KSetBlockKarma(false);
		m_eReactionType = 0;
		SetPhysics(0);
		bHidden = true;
	}
	m_fCurrentSimAge = -1.0000000;
	bSimulationActive = false;
	KMP2IOKarmaAllNativeFct(1, none);
	return;
}

event StartSimulation(int WhatIdo)
{
	// End:0x39
	if((!bSimulationActive))
	{
		MP2IOKarmaAllNativeFct(1, none, 1.0000000);
		SetPhysics(13);
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
	Disable('Timer');
	Disable('Tick');
	return;
}

simulated function Timer()
{
	Disable('Timer');
	return;
}

function Tick(float fDeltaTime)
{
	// End:0x1B
	if((m_fCurrentLoseTime <= float(-100)))
	{
		Disable('Tick');		
	}
	else
	{
		m_fCurrentLoseTime = (m_fCurrentLoseTime - fDeltaTime);
		// End:0x4A
		if((m_fCurrentLoseTime < 0.0000000))
		{
			StartSimulation(0);
			Disable('Tick');
		}
	}
	return;
}

event KImpact(Actor Other, Vector pos, Vector impactVel, Vector impactNorm)
{
	local int numSounds, soundNum;

	// End:0x43
	if((Level.TimeSeconds > (LastImpactTime + ImpactInterval)))
	{
		numSounds = ImpactSounds.Length;
		// End:0x43
		if((numSounds > 0))
		{
			soundNum = Rand(numSounds);
		}
	}
	// End:0x6E
	if(((int(Level.NetMode) == int(NM_Standalone)) || (int(Role) == int(ROLE_Authority))))
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
	if(((int(Level.NetMode) == int(NM_ListenServer)) || (int(Level.NetMode) == int(NM_DedicatedServer))))
	{
		m_fNetDamagePercentage = fPercentage;
	}
	// End:0x8C
	if(((iDamageStat >= m_StateList.Length) && (iDamageStat < 0)))
	{
		Log(((("there is no stat" $ string(iDamageStat)) $ "   ") $ string(m_StateList.Length)));
		return;
	}
	iStateToUse = -1;
	stState = m_StateList[iDamageStat];
	iStateToUse = iDamageStat;
	// End:0xD5
	if(bShowLog)
	{
		Log(("New State = " $ string(iState)));
	}
	// End:0xE6
	if((iStateToUse == m_iCurrentState))
	{
		return;
	}
	// End:0xFF
	if((iStateToUse == (m_StateList.Length - 1)))
	{
		SetBroken();
	}
	// End:0x12A
	if((iStateToUse != -1))
	{
		stState = m_StateList[iStateToUse];
		m_iCurrentState = iStateToUse;
	}
	fRandValue = (FRand() * 100.0000000);
	// End:0x237
	if((stState.RandomMeshes.Length != 0))
	{
		iRandomMesh = 0;
		J0x151:

		// End:0x1DA [Loop If]
		if((iRandomMesh < stState.RandomMeshes.Length))
		{
			(fRandValue -= stState.RandomMeshes[iRandomMesh].fPercentage);
			// End:0x1D0
			if((fRandValue < float(0)))
			{
				ChangeStaticMesh(stState.RandomMeshes[iRandomMesh].Mesh);
				// End:0x1CD
				if((stState.RandomMeshes[iRandomMesh].Mesh == none))
				{
					StopSimulation(2);
				}
				// [Explicit Break]
				goto J0x1DA;
			}
			(iRandomMesh++);
			// [Loop Continue]
			goto J0x151;
		}
		J0x1DA:

		// End:0x237
		if((fRandValue > float(0)))
		{
			ChangeStaticMesh(stState.RandomMeshes[(stState.RandomMeshes.Length - 1)].Mesh);
			// End:0x237
			if((stState.RandomMeshes[(stState.RandomMeshes.Length - 1)].Mesh == none))
			{
				StopSimulation(2);
			}
		}
	}
	// End:0x367
	if((stState.RandomSkins.Length != 0))
	{
		iRandomSkin = 0;
		J0x24F:

		// End:0x2F1 [Loop If]
		if((iRandomSkin < stState.RandomSkins.Length))
		{
			(fRandValue -= stState.RandomSkins[iRandomSkin].fPercentage);
			// End:0x2E7
			if((fRandValue < float(0)))
			{
				iSkin = 0;
				J0x294:

				// End:0x2E4 [Loop If]
				if((iSkin < stState.RandomSkins[iRandomSkin].Skin.Length))
				{
					SetSkin(stState.RandomSkins[iRandomSkin].Skin[iSkin], iSkin);
					(iSkin++);
					// [Loop Continue]
					goto J0x294;
				}
				// [Explicit Break]
				goto J0x2F1;
			}
			(iRandomSkin++);
			// [Loop Continue]
			goto J0x24F;
		}
		J0x2F1:

		// End:0x367
		if((fRandValue > float(0)))
		{
			iSkin = 0;
			J0x305:

			// End:0x367 [Loop If]
			if((iSkin < stState.RandomSkins[(stState.RandomSkins.Length - 1)].Skin.Length))
			{
				SetSkin(stState.RandomSkins[(stState.RandomSkins.Length - 1)].Skin[iSkin], iSkin);
				(iSkin++);
				// [Loop Continue]
				goto J0x305;
			}
		}
	}
	// End:0x484
	if((int(Level.NetMode) != int(NM_DedicatedServer)))
	{
		iActor = 0;
		J0x387:

		// End:0x484 [Loop If]
		if((iActor < stState.ActorList.Length))
		{
			// End:0x3BA
			if((stState.ActorList[iActor].ActorToSpawn == none))
			{
				// [Explicit Continue]
				goto J0x47A;
			}
			// End:0x434
			if((stState.ActorList[iActor].HelperName != ""))
			{
				GetTagInformations(stState.ActorList[iActor].HelperName, vTagLocation, rTagRotator);
				SpawnedActor = Spawn(stState.ActorList[iActor].ActorToSpawn,,, (Location + vTagLocation), (Rotation + rTagRotator));				
			}
			else
			{
				SpawnedActor = Spawn(stState.ActorList[iActor].ActorToSpawn,,, ZDRLocation, Rotation);
			}
			// End:0x47A
			if((SpawnedActor != none))
			{
				SpawnedActor.RemoteRole = ROLE_None;
			}
			J0x47A:

			(iActor++);
			// [Loop Continue]
			goto J0x387;
		}
	}
	// End:0x49F
	if((int(Role) == int(ROLE_Authority)))
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

	m_iCurrentHitPoints = Max((m_iCurrentHitPoints - iKillValue), 0);
	Log(((("currenyt" $ string(m_iCurrentHitPoints)) $ "  ") $ string(iKillValue)));
	// End:0x46
	if((m_iCurrentHitPoints > 0))
	{
		return 0;
	}
	TearOffMomentum = vMomentum;
	iStunValue = 1000;
	// End:0x75
	if((vMomentum == vect(0.0000000, 0.0000000, 0.0000000)))
	{
		return 1;
	}
	vMomentum = (Normal(vMomentum) * float((iStunValue * 100)));
	switch(m_eReactionType)
	{
		// End:0x9B
		case 2:
		// End:0x12F
		case 3:
			// End:0xB1
			if((m_fScaleStartLinVel == 0.0000000))
			{
				return 1;
			}
			StartSimulation(0);
			vMomentum.X = (m_fScaleStartLinVel * vMomentum.X);
			vMomentum.Y = (m_fScaleStartLinVel * vMomentum.Y);
			vMomentum.Z = (m_fScaleStartLinVel * vMomentum.Z);
			KAddImpulse(vMomentum, vHitLocation);
			// End:0x12F
			if((int(m_eReactionType) != int(3)))
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
	if((iActor < m_ActorReactionList.Length))
	{
		stState = m_ActorReactionList[iActor];
		// End:0x278
		if((stState.m_actor != none))
		{
			// End:0x1E5
			if((stState.iActorStat == 0))
			{
				stState.m_actor.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, TearOffMomentum, iBulletToArmorModifier, iBulletGroup);
				// [Explicit Continue]
				goto J0x278;
			}
			IOKarmaActor = MP2IOKarma(stState.m_actor);
			// End:0x278
			if(((IOKarmaActor != none) && (int(IOKarmaActor.m_eReactionType) != int(0))))
			{
				// End:0x268
				if((IOKarmaActor.m_fLoseTime > 0.0000000))
				{
					IOKarmaActor.m_fCurrentLoseTime = IOKarmaActor.m_fLoseTime;
					IOKarmaActor.Enable('Tick');
					// [Explicit Continue]
					goto J0x278;
				}
				IOKarmaActor.StartSimulation(0);
			}
		}
		J0x278:

		(iActor++);
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