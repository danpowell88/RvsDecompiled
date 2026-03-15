//=============================================================================
// R6InteractiveObject - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6InteractiveObject.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/15 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObject extends Actor
    native
    placeable;

const c_iIObjectSkinMax = 4;

enum EInteractiveAction
{
	IA_PlayAnim,                    // 0
	IA_LookAt                       // 1
};

struct stRandomMesh
{
	var() float fPercentage;
	var() StaticMesh Mesh;
};

struct stRandomSkin
{
	var() float fPercentage;
	var() array<Material> Skin;
};

struct stSpawnedActor
{
	var() Class<Actor> ActorToSpawn;
	var() string HelperName;
};

struct stDamageState
{
	var() float fDamagePercentage;
	var() array<stRandomMesh> RandomMeshes;
	var() array<stRandomSkin> RandomSkins;
	var() array<stSpawnedActor> ActorList;
	var() array<Sound> SoundList;
	var() Sound NewAmbientSound;
	var() Sound NewAmbientSoundStop;
};

var Actor.ENoiseType m_HearNoiseType;
var int m_iActionNumber;
var int m_iActionIndex;
var(R6Damage) int m_iHitPoints;  // Original Hit Points
var int m_iCurrentHitPoints;  // Current Hit Points
var int m_iCurrentState;
var bool m_bCollisionRemovedFromActor;
var bool m_bOriginalCollideActors;
var bool m_bOriginalBlockActors;
var bool m_bOriginalBlockPlayers;
var bool m_bPawnDied;
var(Debug) bool bShowLog;
var bool m_bBroken;
var(R6ActionObject) bool m_bRainbowCanInteract;  // true when AI and player can interact with the object
var bool m_bEndAction;
var(Display) bool m_bBlockCoronas;
var(R6Damage) bool m_bBreakableByFlashBang;
//===========================================================================================================
//	 ####              #                                       #      ##                            
//	  ##              ##                                      ##                                    
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===========================================================================================================
var(R6Action) float m_fRadius;
var(R6Action) float m_fProbability;
var(R6Action) float m_fActionInterval;
var float m_fTimeSinceAction;
var float m_fTimeForNextSound;
var float m_fTimerInterval;
var float m_fPlayerCAStartTime;
// HearNoise buffering
var float m_HearNoiseLoudness;
// Replication specific
var float m_fNetDamagePercentage;
var(R6Damage) float m_fAIBreakNoiseRadius;
var R6AIController m_InteractionOwner;
var(R6Action) Actor m_RemoveCollisionFromActor;
var(R6Action) NavigationPoint m_Anchor;
var(R6Action) Actor m_vEndActionGoto;
var R6InteractiveObjectAction m_CurrentInteractiveObject;
// SeePlayer buffering
var Pawn m_SeePlayerPawn;
var Actor m_HearNoiseNoiseMaker;
// NEW IN 1.60
var Material m_aOldSkins[4];
// NEW IN 1.60
var Material m_aRepSkins[4];
var StaticMesh sm_staticMesh;
var R6Pawn m_User;
var Sound sm_AmbientSound;
var Sound sm_AmbientSoundStop;
// ending actions
var(R6Action) name m_vEndActionAnimName;
var(R6Action) editinline array<editinline R6InteractiveObjectAction> m_ActionList;
var array<Material> sm_aSkins;  // save original skin
var(R6Damage) array<stDamageState> m_StateList;
var(R6Attachments) array<Actor> m_AttachedActors;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		m_aRepSkins, m_fNetDamagePercentage;
}

//============================================================================
// function FirstPassReset - 
//============================================================================
simulated function FirstPassReset()
{
	m_User = none;
	m_InteractionOwner = none;
	m_SeePlayerPawn = none;
	m_HearNoiseNoiseMaker = none;
	m_bEndAction = false;
	return;
}

//------------------------------------------------------------------
// SaveOriginalData
//	
//------------------------------------------------------------------
simulated function SaveOriginalData()
{
	local int iSkin;

	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(true);
	}
	super.SaveOriginalData();
	sm_staticMesh = StaticMesh;
	// End:0x5A
	if((4 < Skins.Length))
	{
		Log("WARNING c_iIObjectSkinMax < Skins.Length");
	}
	iSkin = 0;
	J0x61:

	// End:0xCF [Loop If]
	if((iSkin < Skins.Length))
	{
		// End:0x80
		if((iSkin > 4))
		{
			// [Explicit Break]
			goto J0xCF;
		}
		sm_aSkins[iSkin] = Skins[iSkin];
		m_aOldSkins[iSkin] = Skins[iSkin];
		m_aRepSkins[iSkin] = Skins[iSkin];
		(iSkin++);
		// [Loop Continue]
		goto J0x61;
	}
	J0xCF:

	sm_AmbientSound = AmbientSound;
	sm_AmbientSoundStop = AmbientSoundStop;
	m_fNetDamagePercentage = 100.0000000;
	return;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	local int i;

	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super.ResetOriginalData();
	AmbientSound = sm_AmbientSound;
	AmbientSoundStop = sm_AmbientSoundStop;
	// End:0x7C
	if((((m_fProbability != 0.0000000) && (int(Level.NetMode) == int(NM_Standalone))) || (int(Role) == int(ROLE_Authority))))
	{
		SetTimer(m_fTimerInterval, true);
		m_iCurrentHitPoints = m_iHitPoints;
	}
	m_fNetDamagePercentage = 100.0000000;
	m_iCurrentState = -1;
	m_fTimeSinceAction = 0.0000000;
	m_fTimeForNextSound = 9999999.0000000;
	m_InteractionOwner = none;
	m_bBroken = false;
	// End:0xE6
	if(m_bCollisionRemovedFromActor)
	{
		m_RemoveCollisionFromActor.SetCollision(m_bOriginalCollideActors, m_bOriginalBlockActors, m_bOriginalBlockPlayers);
		m_bCollisionRemovedFromActor = false;
	}
	Skins.Remove(0, Skins.Length);
	i = 0;
	J0xFA:

	// End:0x159 [Loop If]
	if((i < sm_aSkins.Length))
	{
		Skins[i] = sm_aSkins[i];
		m_aOldSkins[i] = Skins[i];
		m_aRepSkins[i] = Skins[i];
		(i++);
		// [Loop Continue]
		goto J0xFA;
	}
	// End:0x173
	if((StaticMesh != sm_staticMesh))
	{
		ChangeStaticMesh(sm_staticMesh);
	}
	return;
}

function PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();
	m_OutlineStaticMesh = StaticMesh;
	i = 0;
	J0x18:

	// End:0x6C [Loop If]
	if((i < m_AttachedActors.Length))
	{
		// End:0x62
		if((m_AttachedActors[i] != none))
		{
			m_AttachedActors[i].SetBase(self);
			m_AttachedActors[i].m_AttachedTo = self;
		}
		(i++);
		// [Loop Continue]
		goto J0x18;
	}
	return;
}

//------------------------------------------------------------------
// SetSkin: set the skin for local player and for replication
//	
//------------------------------------------------------------------
simulated function SetSkin(Material aSkin, int iIndex)
{
	// End:0x0E
	if((iIndex > 4))
	{
		return;
	}
	Skins[iIndex] = aSkin;
	m_aRepSkins[iIndex] = aSkin;
	return;
}

//------------------------------------------------------------------
// ChangeStaticMesh: set the StaticMesh
//	
//------------------------------------------------------------------
simulated function ChangeStaticMesh(StaticMesh sm)
{
	// End:0x21
	if(((sm == none) && (StaticMesh != none)))
	{
		SetCollision(false, false, false);		
	}
	else
	{
		// End:0x4E
		if(((sm != none) && (StaticMesh == none)))
		{
			SetCollision(default.bCollideActors, default.bBlockActors, default.bBlockPlayers);
		}
	}
	SetStaticMesh(sm);
	return;
}

//===========================================================================================================
//	 ####              #                                       #      ##                            
//	  ##              ##                                      ##                                    
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===========================================================================================================
function FinishAction()
{
	return;
}

simulated function Timer()
{
	local R6Pawn P;

	(m_fTimeSinceAction += m_fTimerInterval);
	// End:0x39
	if(((int(Level.NetMode) != int(NM_Standalone)) && (int(Role) != int(ROLE_Authority))))
	{
		return;
	}
	// End:0x12E
	if((m_InteractionOwner != none))
	{
		// End:0x12C
		if(((m_CurrentInteractiveObject != none) && (m_CurrentInteractiveObject.IsA('R6InteractiveObjectActionLoopAnim') || m_CurrentInteractiveObject.IsA('R6InteractiveObjectActionLoopRandomAnim'))))
		{
			// End:0x12C
			if(((m_CurrentInteractiveObject.m_eSoundToPlay != none) && (m_CurrentInteractiveObject.m_eSoundToPlayStop != none)))
			{
				// End:0x12C
				if((m_fTimeSinceAction > m_fTimeForNextSound))
				{
					// End:0xF9
					if((R6Pawn(m_InteractionOwner.Pawn) != none))
					{
						R6Pawn(m_InteractionOwner.Pawn).PlayVoices(m_CurrentInteractiveObject.m_eSoundToPlay, 6, 15);
					}
					(m_fTimeForNextSound += RandRange(m_CurrentInteractiveObject.m_SoundRange.Min, m_CurrentInteractiveObject.m_SoundRange.Max));
				}
			}
		}
		return;
	}
	// End:0x1BC
	if(((FRand() < m_fProbability) && (m_fTimeSinceAction >= m_fActionInterval)))
	{
		// End:0x1BB
		foreach VisibleCollidingActors(Class'R6Engine.R6Pawn', P, m_fRadius, Location)
		{
			// End:0x1BA
			if(((R6AIController(P.Controller) != none) && R6AIController(P.Controller).CanInteractWithObjects(self)))
			{
				m_fTimeSinceAction = 0.0000000;
				PerformAction(P);
				// End:0x1BB
				break;
			}			
		}		
	}
	return;
}

//------------------------------------------------------------------
// SetBroken
//  object is broken, so stop the timer.
//------------------------------------------------------------------
simulated function SetBroken()
{
	m_bBroken = true;
	StopInteraction();
	SetTimer(0.0000000, false);
	return;
}

function StopInteraction()
{
	// End:0x14
	if(Level.m_bIsResettingLevel)
	{
		return;
	}
	// End:0x8D
	if((m_InteractionOwner != none))
	{
		m_InteractionOwner.PerformAction_StopInteraction();
		m_InteractionOwner.m_bCantInterruptIO = false;
		m_InteractionOwner.m_InteractionObject = none;
		m_InteractionOwner = none;
		m_bEndAction = false;
		// End:0x8D
		if(m_bCollisionRemovedFromActor)
		{
			m_RemoveCollisionFromActor.SetCollision(m_bOriginalCollideActors, m_bOriginalBlockActors, m_bOriginalBlockPlayers);
			m_bCollisionRemovedFromActor = false;
		}
	}
	return;
}

function StopInteractionWithEndingActions()
{
	// End:0x14
	if(Level.m_bIsResettingLevel)
	{
		return;
	}
	// End:0x38
	if((!m_bEndAction))
	{
		m_bEndAction = true;
		m_iActionIndex = m_iActionNumber;
		FinishAction();
	}
	return;
}

function PerformAction(R6Pawn P)
{
	m_InteractionOwner = R6AIController(P.Controller);
	m_InteractionOwner.m_InteractionObject = self;
	m_iActionIndex = -1;
	m_iActionNumber = m_ActionList.Length;
	// End:0xA4
	if((m_RemoveCollisionFromActor != none))
	{
		m_bOriginalCollideActors = m_RemoveCollisionFromActor.bCollideActors;
		m_bOriginalBlockActors = m_RemoveCollisionFromActor.bBlockActors;
		m_bOriginalBlockPlayers = m_RemoveCollisionFromActor.bBlockPlayers;
		m_RemoveCollisionFromActor.SetCollision(false, false, false);
		m_bCollisionRemovedFromActor = true;
	}
	GotoState('PA_ExecuteStartInteraction');
	return;
}

function SwitchToNextAction()
{
	(m_iActionIndex++);
	// End:0x1F
	if((m_iActionIndex >= m_iActionNumber))
	{
		GotoState('PA_ExecutePlayEnding');
		return;
	}
	m_CurrentInteractiveObject = m_ActionList[m_iActionIndex];
	// End:0xC3
	if(((m_CurrentInteractiveObject.m_eSoundToPlay != none) && (m_CurrentInteractiveObject.m_eSoundToPlayStop != none)))
	{
		R6Pawn(m_InteractionOwner.Pawn).PlayVoices(m_CurrentInteractiveObject.m_eSoundToPlay, 6, 15);
		// End:0xC3
		if((m_iActionIndex == 0))
		{
			m_fTimeForNextSound = RandRange(m_CurrentInteractiveObject.m_SoundRange.Min, m_CurrentInteractiveObject.m_SoundRange.Max);
		}
	}
	switch(m_CurrentInteractiveObject.m_eType)
	{
		// End:0xE2
		case 2:
			GotoState('PA_ExecuteLookAt');
			// End:0x130
			break;
		// End:0xF1
		case 0:
			GotoState('PA_ExecuteGoto');
			// End:0x130
			break;
		// End:0x100
		case 1:
			GotoState('PA_ExecutePlayAnim');
			// End:0x130
			break;
		// End:0x10F
		case 3:
			GotoState('PA_ExecuteLoopAnim');
			// End:0x130
			break;
		// End:0x11E
		case 4:
			GotoState('PA_ExecuteLoopRandomAnim');
			// End:0x130
			break;
		// End:0x12D
		case 5:
			GotoState('PA_ExecuteToggleDevice');
			// End:0x130
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//===========================================================================================================
//	#####                                           
//	 ## ##                                          
//	 ##  ##  ####   ##  ##   ####    ### ##  ####   
//	 ##  ##     ##  #######     ##  ##  ##  ##  ##  
//	 ##  ##  #####  #######  #####  ##  ##  ######  
//	 ## ##  ##  ##  ## # ## ##  ##   #####  ##      
//	#####    ### ## ##   ##  ### ##     ##   ####   
//	                                #####           
//===========================================================================================================
function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGroup)
{
	local float fPercentage;

	// End:0x0B
	if(m_bBroken)
	{
		return 0;
	}
	// End:0x136
	if(((int(Level.NetMode) == int(NM_Standalone)) || (int(Role) == int(ROLE_Authority))))
	{
		// End:0x78
		if(bShowLog)
		{
			Log(((("m_iCurrentHitPoints = " $ string(m_iCurrentHitPoints)) $ " Damage: ") $ string(iKillValue)));
		}
		m_iCurrentHitPoints = Max((m_iCurrentHitPoints - iKillValue), 0);
		fPercentage = float(((m_iCurrentHitPoints * 100) / m_iHitPoints));
		// End:0xE5
		if(bShowLog)
		{
			Log(((("New Hit Point = " $ string(m_iCurrentHitPoints)) $ " Percentage: ") $ string(fPercentage)));
		}
		SetNewDamageState(fPercentage);
		// End:0x136
		if(m_bBroken)
		{
			R6AbstractGameInfo(Level.Game).IObjectDestroyed(instigatedBy, self);
			Instigator = instigatedBy;
			R6MakeNoise2(m_fAIBreakNoiseRadius, 2, 4);
		}
	}
	// End:0x14B
	if((m_bBulletGoThrough == true))
	{
		return iKillValue;		
	}
	else
	{
		return 0;
	}
	return;
}

simulated event SetNewDamageState(float fPercentage)
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
	iStateToUse = -1;
	iState = 0;
	J0x51:

	// End:0xBC [Loop If]
	if((iState < m_StateList.Length))
	{
		stState = m_StateList[iState];
		// End:0xB2
		if(((fPercentage <= stState.fDamagePercentage) && (stState.fDamagePercentage <= m_StateList[iState].fDamagePercentage)))
		{
			iStateToUse = iState;
		}
		(iState++);
		// [Loop Continue]
		goto J0x51;
	}
	// End:0xDE
	if(bShowLog)
	{
		Log(("New State = " $ string(iState)));
	}
	// End:0xEF
	if((iStateToUse == m_iCurrentState))
	{
		return;
	}
	// End:0x108
	if((iStateToUse == (m_StateList.Length - 1)))
	{
		SetBroken();
	}
	// End:0x133
	if((iStateToUse != -1))
	{
		stState = m_StateList[iStateToUse];
		m_iCurrentState = iStateToUse;
	}
	fRandValue = (FRand() * 100.0000000);
	// End:0x1F1
	if((stState.RandomMeshes.Length != 0))
	{
		iRandomMesh = 0;
		J0x15A:

		// End:0x1C0 [Loop If]
		if((iRandomMesh < stState.RandomMeshes.Length))
		{
			(fRandValue -= stState.RandomMeshes[iRandomMesh].fPercentage);
			// End:0x1B6
			if((fRandValue < float(0)))
			{
				ChangeStaticMesh(stState.RandomMeshes[iRandomMesh].Mesh);
				// [Explicit Break]
				goto J0x1C0;
			}
			(iRandomMesh++);
			// [Loop Continue]
			goto J0x15A;
		}
		J0x1C0:

		// End:0x1F1
		if((fRandValue > float(0)))
		{
			ChangeStaticMesh(stState.RandomMeshes[(stState.RandomMeshes.Length - 1)].Mesh);
		}
	}
	// End:0x321
	if((stState.RandomSkins.Length != 0))
	{
		iRandomSkin = 0;
		J0x209:

		// End:0x2AB [Loop If]
		if((iRandomSkin < stState.RandomSkins.Length))
		{
			(fRandValue -= stState.RandomSkins[iRandomSkin].fPercentage);
			// End:0x2A1
			if((fRandValue < float(0)))
			{
				iSkin = 0;
				J0x24E:

				// End:0x29E [Loop If]
				if((iSkin < stState.RandomSkins[iRandomSkin].Skin.Length))
				{
					SetSkin(stState.RandomSkins[iRandomSkin].Skin[iSkin], iSkin);
					(iSkin++);
					// [Loop Continue]
					goto J0x24E;
				}
				// [Explicit Break]
				goto J0x2AB;
			}
			(iRandomSkin++);
			// [Loop Continue]
			goto J0x209;
		}
		J0x2AB:

		// End:0x321
		if((fRandValue > float(0)))
		{
			iSkin = 0;
			J0x2BF:

			// End:0x321 [Loop If]
			if((iSkin < stState.RandomSkins[(stState.RandomSkins.Length - 1)].Skin.Length))
			{
				SetSkin(stState.RandomSkins[(stState.RandomSkins.Length - 1)].Skin[iSkin], iSkin);
				(iSkin++);
				// [Loop Continue]
				goto J0x2BF;
			}
		}
	}
	// End:0x411
	if((int(Level.NetMode) != int(NM_DedicatedServer)))
	{
		iActor = 0;
		J0x341:

		// End:0x411 [Loop If]
		if((iActor < stState.ActorList.Length))
		{
			// End:0x374
			if((stState.ActorList[iActor].ActorToSpawn == none))
			{
				// [Explicit Continue]
				goto J0x407;
			}
			// End:0x3B2
			if((stState.ActorList[iActor].HelperName != ""))
			{
				GetTagInformations(stState.ActorList[iActor].HelperName, vTagLocation, rTagRotator);
			}
			SpawnedActor = Spawn(stState.ActorList[iActor].ActorToSpawn,,, (Location + vTagLocation), (Rotation + rTagRotator));
			// End:0x407
			if((SpawnedActor != none))
			{
				SpawnedActor.RemoteRole = ROLE_None;
			}
			J0x407:

			(iActor++);
			// [Loop Continue]
			goto J0x341;
		}
	}
	// End:0x42C
	if((int(Role) == int(ROLE_Authority)))
	{
		PlayInteractiveObjectSound(stState);
	}
	return;
}

function PlayInteractiveObjectSound(stDamageState stState)
{
	local int iSound;

	iSound = 0;
	J0x07:

	// End:0x3B [Loop If]
	if((iSound < stState.SoundList.Length))
	{
		PlaySound(stState.SoundList[iSound], 3);
		(iSound++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

state PA_Execute
{
//===========================================================================================================
//	 ####              #                                       #      ##                            
//	  ##              ##                                      ##                                    
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===========================================================================================================
	function FinishAction()
	{
		SwitchToNextAction();
		return;
	}
	stop;
}

state PA_ExecuteStartInteraction extends PA_Execute
{Begin:

	m_InteractionOwner.PerformAction_StartInteraction();
	stop;				
}

state PA_ExecuteLookAt extends PA_Execute
{Begin:

	m_InteractionOwner.PerformAction_LookAt(R6InteractiveObjectActionLookAt(m_CurrentInteractiveObject).m_Target);
	stop;	
}

state PA_ExecuteGoto extends PA_Execute
{Begin:

	m_InteractionOwner.PerformAction_Goto(R6InteractiveObjectActionGoto(m_CurrentInteractiveObject).m_Target);
	stop;	
}

state PA_ExecuteToggleDevice extends PA_Execute
{
	function ActionDetonateAllBombs()
	{
		local int i;
		local R6InteractiveObjectActionToggleDevice ioAction;

		ioAction = R6InteractiveObjectActionToggleDevice(m_CurrentInteractiveObject);
		J0x10:

		// End:0x64 [Loop If]
		if((i < ioAction.m_aIOBombs.Length))
		{
			ioAction.m_aIOBombs[i].DetonateBomb(R6Pawn(m_InteractionOwner.Pawn));
			(++i);
			// [Loop Continue]
			goto J0x10;
		}
		return;
	}

	function ActionToggleDevice()
	{
		local R6InteractiveObjectActionToggleDevice ioAction;

		ioAction = R6InteractiveObjectActionToggleDevice(m_CurrentInteractiveObject);
		// End:0x4F
		if((ioAction.m_iodevice != none))
		{
			ioAction.m_iodevice.ToggleDevice(R6Pawn(m_InteractionOwner.Pawn));
		}
		return;
	}
Begin:

	ActionToggleDevice();
	ActionDetonateAllBombs();
	FinishAction();
	stop;	
}

state PA_ExecutePlayAnim extends PA_Execute
{Begin:

	m_InteractionOwner.PerformAction_PlayAnim(R6InteractiveObjectActionPlayAnim(m_CurrentInteractiveObject).m_vAnimName);
	stop;	
}

state PA_ExecuteLoopAnim extends PA_Execute
{Begin:

	m_InteractionOwner.PerformAction_LoopAnim(R6InteractiveObjectActionLoopAnim(m_CurrentInteractiveObject).m_vAnimName, RandRange(R6InteractiveObjectActionLoopAnim(m_CurrentInteractiveObject).m_LoopTime.Min, R6InteractiveObjectActionLoopAnim(m_CurrentInteractiveObject).m_LoopTime.Max));
	stop;			
}

state PA_ExecuteLoopRandomAnim extends PA_Execute
{
//===========================================================================================================
//	 ####              #                                       #      ##                            
//	  ##              ##                                      ##                                    
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===========================================================================================================
	function FinishAction()
	{
		// End:0x18
		if((m_iActionIndex >= m_iActionNumber))
		{
			SwitchToNextAction();			
		}
		else
		{
			GotoState('PA_ExecuteLoopRandomAnim');
		}
		return;
	}
Begin:

	m_InteractionOwner.PerformAction_PlayAnim(R6InteractiveObjectActionLoopRandomAnim(m_CurrentInteractiveObject).GetNextAnim());
	stop;				
}

state PA_ExecutePlayEnding extends PA_Execute
{
//===========================================================================================================
//	 ####              #                                       #      ##                            
//	  ##              ##                                      ##                                    
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===========================================================================================================
	function FinishAction()
	{
		GotoState('PA_ExecuteGotoEnding');
		return;
	}
Begin:

	// End:0x26
	if((m_vEndActionAnimName != 'None'))
	{
		m_InteractionOwner.PerformAction_PlayAnim(m_vEndActionAnimName);		
	}
	else
	{
		FinishAction();
	}
	stop;			
}

state PA_ExecuteGotoEnding extends PA_Execute
{
//===========================================================================================================
//	 ####              #                                       #      ##                            
//	  ##              ##                                      ##                                    
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===========================================================================================================
	function FinishAction()
	{
		StopInteraction();
		return;
	}
Begin:

	// End:0x33
	if((m_vEndActionGoto != none))
	{
		m_InteractionOwner.R6SetMovement(5);
		m_InteractionOwner.PerformAction_Goto(m_vEndActionGoto);		
	}
	else
	{
		FinishAction();
	}
	stop;		
}

defaultproperties
{
	m_fRadius=128.0000000
	m_fActionInterval=10.0000000
	m_fTimerInterval=1.0000000
	m_fAIBreakNoiseRadius=500.0000000
	bNoDelete=true
	m_bUseR6Availability=true
	bAcceptsProjectors=true
	bAlwaysRelevant=true
	bSkipActorPropertyReplication=true
	bShadowCast=true
	bStaticLighting=true
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bPathColliding=true
	m_bForceStaticLighting=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_aOldSkinsc_iIObjectSkinMax
// REMOVED IN 1.60: var m_aRepSkinsc_iIObjectSkinMax
