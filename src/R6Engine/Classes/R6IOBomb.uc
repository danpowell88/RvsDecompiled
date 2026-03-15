//=============================================================================
// R6IOBomb - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6IOBomb : This should allow action moves on the door
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6IOBomb extends R6IOObject
    native
    placeable;

const C_fBombTimerInterval = 0.1;

enum ESoundBeepBomb
{
	SBB_Normal,                     // 0
	SBB_Fast,                       // 1
	SBB_Faster                      // 2
};

var R6IOBomb.ESoundBeepBomb m_eBeepState;
var(R6ActionObject) int m_iEnergy;
var(Debug) bool bShowLog;
var bool m_bExploded;
var float m_fTimeOfExplosion;
var float m_fTimeLeft;  // if 0, the bomb has unlimited time
var float m_fRepTimeLeft;  // time replicated and computed on the client. send by server every X sec.
var float m_fLastLevelTime;
var(R6ActionObject) float m_fDisarmBombTimeMin;  // Base time required to disarmed the bomb if they have 100%, will be affected by the kit later (Must be higher then 2 seconds)
var(R6ActionObject) float m_fDisarmBombTimeMax;  // Base time required to disarmed the bomb if they have 0%
var(R6ActionObject) float m_fExplosionRadius;  // feel the sake
var(R6ActionObject) float m_fKillBlastRadius;  // killed by the bomb
var(R6ActionObject) Material m_ArmedTexture;
var Sound m_sndActivationBomb;
var Sound m_sndPlayBeepNormal;
var Sound m_sndStopBeepNormal;
var Sound m_sndPlayBeepFast;
var Sound m_sndStopBeepFast;
var Sound m_sndPlayBeepFaster;
var Sound m_sndStopBeepFaster;
var Sound m_sndExplosion;
var Sound m_sndEarthQuake;
var Emitter m_pEmmiter;
var Class<Light> m_pExplosionLight;
var Vector m_vOffset;
var(R6ActionObject) string m_szIdentityID;  // msg shown:                 Bomb A
var string m_szIdentity;  // msg shown:                 Bomb A
var(R6ActionObject) string m_szMsgArmedID;  // msg shown when armed:      Bomb A was armed
var(R6ActionObject) string m_szMsgDisarmedID;  // msg shown when disarmed:   Bomb A was disarmed
var(R6ActionObject) string m_szMissionObjLocalization;  // set the loc file. if none, use the default one

replication
{
	// Pos:0x000
	reliable if((int(Role) < int(ROLE_Authority)))
		ArmBomb, DisarmBomb;

	// Pos:0x00D
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bExploded, m_fRepTimeLeft;
}

simulated function PostBeginPlay()
{
	super(R6InteractiveObject).PostBeginPlay();
	// End:0x28
	if((int(Role) == int(ROLE_Authority)))
	{
		AddSoundBankName("Foley_Bomb");
	}
	StartBombSound();
	m_szIdentity = Localize("Game", m_szIdentityID, GetMissionObjLocFile());
	return;
}

simulated function string GetMissionObjLocFile()
{
	// End:0x15
	if((m_szMissionObjLocalization != ""))
	{
		return m_szMissionObjLocalization;		
	}
	else
	{
		return Level.m_szMissionObjLocalization;
	}
	return;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super.ResetOriginalData();
	// End:0x27
	if(m_bExploded)
	{
		bHidden = false;
	}
	m_bExploded = false;
	m_fTimeLeft = 0.0000000;
	m_fRepTimeLeft = 0.0000000;
	m_fLastLevelTime = 0.0000000;
	StopSoundBomb();
	// End:0x8A
	if((int(Level.NetMode) != int(NM_Client)))
	{
		// End:0x82
		if(m_bIsActivated)
		{
			ArmBomb(none);			
		}
		else
		{
			SetSkin(none, 0);
		}
	}
	// End:0xAC
	if((int(Level.NetMode) == int(NM_Client)))
	{
		SetTimer(0.1000000, true);
	}
	return;
}

simulated function bool CanToggle()
{
	// End:0x0B
	if(m_bExploded)
	{
		return false;
	}
	return super.CanToggle();
	return;
}

simulated function float GetTimeLeft()
{
	// End:0x22
	if((int(Level.NetMode) == int(NM_Client)))
	{
		return m_fRepTimeLeft;		
	}
	else
	{
		return m_fTimeLeft;
	}
	return;
}

simulated function Timer()
{
	local int iRemaining;

	super(R6InteractiveObject).Timer();
	// End:0x4F
	if((int(Level.NetMode) == int(NM_Client)))
	{
		// End:0x4C
		if(m_bIsActivated)
		{
			(m_fRepTimeLeft -= 0.1000000);
			// End:0x4C
			if((m_fRepTimeLeft < float(0)))
			{
				m_fRepTimeLeft = 0.0000000;
			}
		}		
	}
	else
	{
		// End:0xDD
		if((m_bIsActivated && (m_fTimeLeft > float(0))))
		{
			(m_fTimeLeft -= (Level.TimeSeconds - m_fLastLevelTime));
			iRemaining = int(m_fTimeLeft);
			ChangeSoundBomb();
			// End:0xB6
			if(((float(iRemaining) % float(5)) == float(0)))
			{
				m_fRepTimeLeft = m_fTimeLeft;
			}
			// End:0xC9
			if((m_fTimeLeft <= float(0)))
			{
				DetonateBomb();
			}
			m_fLastLevelTime = Level.TimeSeconds;
		}
	}
	return;
}

//------------------------------------------------------------------
// ForceTimeLeft
//	
//------------------------------------------------------------------
function ForceTimeLeft(float fTime)
{
	m_fTimeLeft = fTime;
	m_fRepTimeLeft = fTime;
	m_fLastLevelTime = Level.TimeSeconds;
	return;
}

function ChangeSoundBomb()
{
	switch(m_eBeepState)
	{
		// End:0x45
		case 0:
			// End:0x42
			if((m_fTimeLeft <= float(20)))
			{
				AmbientSound = m_sndPlayBeepFast;
				AmbientSoundStop = m_sndStopBeepFast;
				PlaySound(m_sndPlayBeepFast, 1);
				m_eBeepState = 1;
			}
			// End:0x86
			break;
		// End:0x83
		case 1:
			// End:0x80
			if((m_fTimeLeft <= float(10)))
			{
				AmbientSound = m_sndPlayBeepFaster;
				AmbientSoundStop = m_sndStopBeepFaster;
				PlaySound(m_sndPlayBeepFaster, 1);
				m_eBeepState = 2;
			}
			// End:0x86
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//------------------------------------------------------------------
// DetonateBomb
//	will explode only if the bomb was activated
//------------------------------------------------------------------
simulated function DetonateBomb(optional R6Pawn P)
{
	local R6GrenadeDecal GrenadeDecal;
	local Rotator GrenadeDecalRotation;
	local Light pEffectLight;
	local Vector vDecalLoc;
	local float fKillBlastHalfRadius, fDistFromBomb;
	local Actor aActor;
	local R6Pawn pPawn;
	local R6PlayerController pPC;
	local R6ActorSound pBombSound;

	// End:0x0D
	if((!m_bIsActivated))
	{
		return;
	}
	// End:0x2E
	if(bShowLog)
	{
		Log((" DetonateBomb: " $ string(self)));
	}
	StopSoundBomb();
	m_bExploded = true;
	bHidden = true;
	vDecalLoc = Location;
	(vDecalLoc.Z -= (CollisionHeight - float(2)));
	GrenadeDecal = Spawn(Class'R6Engine.R6GrenadeDecal',,, vDecalLoc, GrenadeDecalRotation);
	m_pEmmiter = Spawn(Class'R6SFX.R6BombFX');
	m_pEmmiter.RemoteRole = ROLE_AutonomousProxy;
	m_pEmmiter.Role = ROLE_Authority;
	pEffectLight = Spawn(m_pExplosionLight);
	R6AbstractGameInfo(Level.Game).IObjectDestroyed(P, self);
	R6AbstractGameInfo(Level.Game).m_bGameOverButAllowDeath = true;
	pBombSound = Spawn(Class'Engine.R6ActorSound',,, Location);
	// End:0x145
	if((pBombSound != none))
	{
		pBombSound.m_eTypeSound = 8;
		pBombSound.m_ImpactSound = m_sndExplosion;
	}
	fKillBlastHalfRadius = (m_fKillBlastRadius / 2.0000000);
	// End:0x289
	foreach CollidingActors(Class'Engine.Actor', aActor, m_fExplosionRadius, Location)
	{
		fDistFromBomb = VSize((aActor.Location - Location));
		// End:0x1AB
		if((fDistFromBomb <= fKillBlastHalfRadius))
		{
			HurtActor(aActor);			
		}
		else
		{
			// End:0x1DE
			if((fDistFromBomb <= m_fKillBlastRadius))
			{
				// End:0x1DE
				if(FastTrace(Location, aActor.Location))
				{
					HurtActor(aActor);
				}
			}
		}
		// End:0x1FA
		if((fDistFromBomb > float(3000)))
		{
			fDistFromBomb = 3000.0000000;
		}
		pPawn = R6Pawn(aActor);
		// End:0x288
		if(((pPawn != none) && pPawn.IsAlive()))
		{
			pPC = R6PlayerController(pPawn.Controller);
			// End:0x288
			if((pPC != none))
			{
				pPC.R6Shake(1.5000000, (3000.0000000 - fDistFromBomb), 0.1000000);
				pPC.ClientPlaySound(m_sndEarthQuake, 3);
			}
		}		
	}	
	R6AbstractGameInfo(Level.Game).m_bGameOverButAllowDeath = false;
	return;
}

//------------------------------------------------------------------
// HurtActor
//	
//------------------------------------------------------------------
function HurtActor(Actor aActor)
{
	local Vector vExplosionMomentum;
	local R6Pawn aPawn;

	// End:0x74
	if(((R6InteractiveObject(aActor) != none) && (aActor != self)))
	{
		vExplosionMomentum = ((aActor.Location - Location) * 0.2500000);
		R6InteractiveObject(aActor).R6TakeDamage(m_iEnergy, m_iEnergy, none, aActor.Location, vExplosionMomentum, 0);
		return;
	}
	aPawn = R6Pawn(aActor);
	// End:0x91
	if((aPawn == none))
	{
		return;
	}
	// End:0xAC
	if((int(aPawn.m_eHealth) >= int(2)))
	{
		return;
	}
	vExplosionMomentum = ((aPawn.Location - Location) * 0.2500000);
	aPawn.ServerForceKillResult(4);
	aPawn.m_bSuicideType = 9;
	aPawn.R6TakeDamage(m_iEnergy, m_iEnergy, aPawn, aPawn.Location, vExplosionMomentum, 0);
	aPawn.ServerForceKillResult(0);
	return;
}

simulated event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	local bool bDisplayBombIcon;
	local Vector vActorDir, vFacingDir;
	local R6Pawn aPawn;

	// End:0x1B
	if(((CanToggle() == false) || (!m_bRainbowCanInteract)))
	{
		return;
	}
	Query.iHasAction = 0;
	aPawn = R6Pawn(PlayerController.Pawn);
	// End:0xBD
	if(m_bIsActivated)
	{
		// End:0xBA
		if(aPawn.m_bCanDisarmBomb)
		{
			Query.iHasAction = 1;
			Query.textureIcon = Texture'R6ActionIcons.Disarm';
			Query.iPlayerActionID = 1;
			Query.iTeamActionID = 1;
			Query.iTeamActionIDList[0] = 1;
		}		
	}
	else
	{
		// End:0x129
		if(aPawn.m_bCanArmBomb)
		{
			Query.iHasAction = 1;
			Query.textureIcon = Texture'R6ActionIcons.ArmingBomb';
			Query.iPlayerActionID = 2;
			Query.iTeamActionID = 2;
			Query.iTeamActionIDList[0] = 2;
		}
	}
	Query.iTeamActionIDList[1] = 0;
	Query.iTeamActionIDList[2] = 0;
	Query.iTeamActionIDList[3] = 0;
	// End:0x204
	if((fDistance < m_fCircumstantialActionRange))
	{
		vFacingDir = Vector(Rotation);
		vFacingDir.Z = 0.0000000;
		vActorDir = Normal((Location - PlayerController.Pawn.Location));
		vActorDir.Z = 0.0000000;
		// End:0x1F0
		if((Dot(vActorDir, vFacingDir) > 0.4000000))
		{
			Query.iInRange = 1;			
		}
		else
		{
			Query.iInRange = 0;
		}		
	}
	else
	{
		Query.iInRange = 0;
	}
	Query.bCanBeInterrupted = true;
	Query.fPlayerActionTimeRequired = GetTimeRequired(R6PlayerController(PlayerController).m_pawn);
	return;
}

simulated function string R6GetCircumstantialActionString(int iAction)
{
	switch(iAction)
	{
		// End:0x39
		case int(1):
			return Localize("RDVOrder", "Order_DisarmBomb", "R6Menu");
		// End:0x68
		case int(2):
			return Localize("RDVOrder", "Order_ArmBomb", "R6Menu");
		// End:0xFFFF
		default:
			return "";
			break;
	}
	return;
}

simulated function ToggleDevice(R6Pawn aPawn)
{
	// End:0x0E
	if((CanToggle() == false))
	{
		return;
	}
	super.ToggleDevice(aPawn);
	// End:0x7E
	if(m_bIsActivated)
	{
		// End:0x7B
		if(aPawn.m_bCanDisarmBomb)
		{
			m_eAnimToPlay = 1;
			DisarmBomb(aPawn);
			// End:0x7B
			if(aPawn.m_bIsPlayer)
			{
				R6PlayerController(aPawn.Controller).PlaySoundActionCompleted(m_eAnimToPlay);
			}
		}		
	}
	else
	{
		// End:0xC5
		if(aPawn.m_bCanArmBomb)
		{
			m_eAnimToPlay = 0;
			ArmBomb(aPawn);
			R6PlayerController(aPawn.Controller).PlaySoundActionCompleted(m_eAnimToPlay);
		}
	}
	return;
}

simulated function bool ArmBomb(R6Pawn aPawn)
{
	// End:0x0B
	if(m_bExploded)
	{
		return false;
	}
	// End:0x23
	if((m_bIsActivated && (aPawn != none)))
	{
		return false;
	}
	PlaySound(m_sndActivationBomb, 3);
	// End:0x48
	if(bShowLog)
	{
		Log(("Arm BOMB " @ string(self)));
	}
	m_bIsActivated = true;
	StartBombSound();
	m_fLastLevelTime = Level.TimeSeconds;
	SetTimer(0.1000000, true);
	m_fRepTimeLeft = m_fTimeOfExplosion;
	m_fTimeLeft = m_fTimeOfExplosion;
	SetSkin(m_ArmedTexture, 0);
	R6AbstractGameInfo(Level.Game).IObjectInteract(aPawn, self);
	return true;
	return;
}

simulated function bool DisarmBomb(R6Pawn aPawn)
{
	// End:0x19
	if(((m_bIsActivated == false) || m_bExploded))
	{
		return false;
	}
	// End:0x72
	if(bShowLog)
	{
		Log(((((("Disarm BOMB" @ string(self)) @ "by pawn") @ string(aPawn)) @ "and his controller") @ string(aPawn.Controller)));
	}
	StopSoundBomb();
	m_bIsActivated = false;
	SetSkin(none, 0);
	SetTimer(0.0000000, false);
	m_fRepTimeLeft = 0.0000000;
	R6AbstractGameInfo(Level.Game).IObjectInteract(aPawn, self);
	return true;
	return;
}

function StartBombSound()
{
	// End:0x8E
	if(m_bIsActivated)
	{
		switch(m_eBeepState)
		{
			// End:0x38
			case 0:
				AmbientSound = m_sndPlayBeepNormal;
				AmbientSoundStop = m_sndStopBeepNormal;
				PlaySound(m_sndPlayBeepNormal, 1);
				// End:0x8B
				break;
			// End:0x60
			case 1:
				AmbientSound = m_sndPlayBeepFast;
				AmbientSoundStop = m_sndStopBeepFast;
				PlaySound(m_sndPlayBeepFast, 1);
				// End:0x8B
				break;
			// End:0x88
			case 2:
				AmbientSound = m_sndPlayBeepFaster;
				AmbientSoundStop = m_sndStopBeepFaster;
				PlaySound(m_sndPlayBeepFaster, 1);
				// End:0x8B
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		AmbientSound = none;
	}
	return;
}

function StopSoundBomb()
{
	// End:0x49
	if(m_bIsActivated)
	{
		switch(m_eBeepState)
		{
			// End:0x22
			case 0:
				PlaySound(m_sndStopBeepNormal, 1);
				// End:0x49
				break;
			// End:0x34
			case 1:
				PlaySound(m_sndStopBeepFast, 1);
				// End:0x49
				break;
			// End:0x46
			case 2:
				PlaySound(m_sndStopBeepFaster, 1);
				// End:0x49
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		m_eBeepState = 0;
		AmbientSound = none;
		AmbientSoundStop = none;
		return;
	}
}

simulated function bool HasKit(R6Pawn aPawn)
{
	return R6Rainbow(aPawn).m_bHasDiffuseKit;
	return;
}

simulated function float GetMaxTimeRequired()
{
	return m_fDisarmBombTimeMax;
	return;
}

simulated function float GetTimeRequired(R6Pawn aPawn)
{
	local float fDisarmingBombTime;

	fDisarmingBombTime = (m_fDisarmBombTimeMin + ((float(1) - aPawn.GetSkill(2)) * (m_fDisarmBombTimeMax - m_fDisarmBombTimeMin)));
	// End:0x61
	if((HasKit(aPawn) && ((fDisarmingBombTime - m_fGainTimeWithElectronicsKit) > float(0))))
	{
		(fDisarmingBombTime -= m_fGainTimeWithElectronicsKit);
	}
	return fDisarmingBombTime;
	return;
}

defaultproperties
{
	m_iEnergy=3000
	m_fDisarmBombTimeMin=4.0000000
	m_fDisarmBombTimeMax=12.0000000
	m_fExplosionRadius=10000.0000000
	m_fKillBlastRadius=2000.0000000
	m_sndActivationBomb=Sound'Foley_Bomb.Play_BombActivationBeep'
	m_sndPlayBeepNormal=Sound'Foley_Bomb.Play_Seq_BombBeep'
	m_sndStopBeepNormal=Sound'Foley_Bomb.Stop_Seq_BombBeep'
	m_sndPlayBeepFast=Sound'Foley_Bomb.Stop_Seq_BombBeep_Go'
	m_sndStopBeepFast=Sound'Foley_Bomb.Stop_Seq_BombBeepFast'
	m_sndPlayBeepFaster=Sound'Foley_Bomb.Stop_Seq_BombBeepFast_Go'
	m_sndStopBeepFaster=Sound'Foley_Bomb.Stop_SeqBombBeepFinal'
	m_sndExplosion=Sound'Foley_Bomb.Bomb_Explosion'
	m_sndEarthQuake=Sound'Foley_Bomb.Play_EarthQuake'
	m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
	m_vOffset=(X=0.0000000,Y=-70.0000000,Z=0.0000000)
	m_szIdentityID="BombA"
	m_szMsgArmedID="BombAArmed"
	m_szMsgDisarmedID="BombADisarmed"
	m_eAnimToPlay=1
	m_StartSnd=Sound'Foley_Bomb.Play_Bomb_Defusing'
	m_InterruptedSnd=Sound'Foley_Bomb.Stop_Go_Bomb_Defusing'
	m_CompletedSnd=Sound'Foley_Bomb.Stop_Go_Bomb_Defused'
	m_bRainbowCanInteract=true
	m_fSoundRadiusActivation=5600.0000000
	m_fCircumstantialActionRange=110.0000000
}
