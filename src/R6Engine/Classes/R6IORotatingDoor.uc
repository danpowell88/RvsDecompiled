//=============================================================================
// R6IORotatingDoor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6IORotatingDoor : This should allow action moves on the door
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/10 * Created by Alexandre Dionne
//    2001/11/26 * Merged with interactive objects - Jean-Francois Dube
//  Note: if you make R6IORotatingDoor native then you will need to take care so
//  that the names in eDoorCircumstantialAction do not conflict with other enums
//=============================================================================
class R6IORotatingDoor extends R6IActionObject
    native
    placeable;

enum eDoorCircumstantialAction
{
	CA_None,                        // 0
	CA_Open,                        // 1
	CA_OpenAndClear,                // 2
	CA_OpenAndGrenade,              // 3
	CA_OpenGrenadeAndClear,         // 4
	CA_Close,                       // 5
	CA_Clear,                       // 6
	CA_Grenade,                     // 7
	CA_GrenadeAndClear,             // 8
	CA_GrenadeFrag,                 // 9
	CA_GrenadeGas,                  // 10
	CA_GrenadeFlash,                // 11
	CA_GrenadeSmoke,                // 12
	CA_Unlock,                      // 13
	CA_Lock,                        // 14
	CA_LockPickStop                 // 15
};

var(R6Damage) int m_iLockHP;  // lock HP to open door with bullets or explosions.
var int m_iCurrentLockHP;  // Current Lock Hit Points
var(R6DoorProperties) int m_iMaxOpeningDeg;  // Determine how many degrees the door can open (In degrees)
var(R6DoorProperties) int m_iInitialOpeningDeg;  // Opening of the door at level creation (In degrees)
//-----------------------------------------------------------------------------
// Internal
var int m_iYawInit;  // Start Yaw point of the door when it's closed
var int m_iYawMax;  // End Yaw point of the door when it's fully opened
var int m_iMaxOpening;  // Determine how many degrees the door can open (In degrees)
var int m_iInitialOpening;  // Opening of the door at level creation (In degrees)
var int m_iCurrentOpening;
var() bool m_bTreatDoorAsWindow;  // should be set to true for shudders and windows that behave like doors.
var(Debug) bool bShowLog;
var bool m_bInProcessOfClosing;
var bool m_bInProcessOfOpening;
var bool m_bUseWheel;
var() bool m_bForceNoFormation;  // force ROOM_None (no formation/single file) on either side of door
//-----------------------------------------------------------------------------
// Editables.
var(R6DoorProperties) bool m_bIsOpeningClockWise;  // Is the door opening Clockwise
var(R6DoorProperties) bool m_bIsDoorLocked;  // Is the door Locked
var bool sm_bIsDoorLocked;
var bool m_bIsDoorClosed;  // Is the door open or not
var() float m_fWindowWidth;  // this field is only used when m_bTreatDoorAsWindow==true
var(R6DoorProperties) float m_fUnlockBaseTime;  // Base time required for opening the door, will be affected by skills
var() R6Door m_DoorActorA;
var() R6Door m_DoorActorB;
//-----------------------------------------------------------------------------
// Audio.
var(R6DoorSounds) Sound m_OpeningSound;  // When start opening.
var(R6DoorSounds) Sound m_OpeningWheelSound;  // When start opening with the wheel.
var(R6DoorSounds) Sound m_ClosingSound;  // When start closing.
var(R6DoorSounds) Sound m_ClosingWheelSound;  // When start closing with the wheel.
var(R6DoorSounds) Sound m_LockSound;  // Try to open when the door is lock.
var(R6DoorSounds) Sound m_UnlockSound;  // When the door is unlock stat the sound.
var(R6DoorSounds) Sound m_MoveAmbientSound;  // Optional ambient sound when moving.
var(R6DoorSounds) Sound m_MoveAmbientSoundStop;  // Stop optional ambient sound closing door.
var(R6DoorSounds) Sound m_LockPickSound;  // Use lock pick when the door is lock
var(R6DoorSounds) Sound m_LockPickSoundStop;  // Stop unlocking the door.
var(R6DoorSounds) Sound m_ExplosionSound;  // Explosion sound.
var array<R6AbstractBullet> m_BreachAttached;  // breach attached to the door (if any)
var Vector m_vNormal;  // The normal at the begining of the action
var Vector m_vCenterOfDoor;  // Center of the door (Location is the pivot point)
var Vector m_vDoorADir2D;  // The direction toward DoorA (direction toward DoorB is -m_vDoorADir2D

replication
{
	// Pos:0x000
	reliable if((bNetInitial && (int(Role) == int(ROLE_Authority))))
		m_DoorActorA, m_DoorActorB, 
		m_bIsDoorLocked, m_bIsOpeningClockWise, 
		m_iInitialOpeningDeg, m_iMaxOpeningDeg;

	// Pos:0x018
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bInProcessOfClosing, m_bInProcessOfOpening, 
		m_bIsDoorClosed, m_iInitialOpening, 
		m_iMaxOpening, m_iYawInit, 
		m_iYawMax;
}

// Export UR6IORotatingDoor::execWillOpenOnTouch(FFrame&, void* const)
native(1511) final function bool WillOpenOnTouch(R6Pawn R6Pawn);

// Export UR6IORotatingDoor::execAddBreach(FFrame&, void* const)
native(2018) final function AddBreach(R6AbstractBullet BreachAttached);

// Export UR6IORotatingDoor::execRemoveBreach(FFrame&, void* const)
native(2019) final function RemoveBreach(R6AbstractBullet BreachAttached);

//------------------------------------------------------------------
// SaveOriginalData
//	
//------------------------------------------------------------------
simulated function SaveOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(true);
	}
	super(R6InteractiveObject).SaveOriginalData();
	sm_bIsDoorLocked = m_bIsDoorLocked;
	sm_Rotation = Rotation;
	return;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	local Rotator rNewRotation, rTempRotation;
	local bool bCA, bBA, bBP;

	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super(R6InteractiveObject).ResetOriginalData();
	m_bBulletGoThrough = false;
	m_bHidePortal = true;
	m_bUseWheel = false;
	m_bIsDoorLocked = sm_bIsDoorLocked;
	m_fPlayerCAStartTime = 0.0000000;
	SetDoorProcessStates(false, false);
	m_iCurrentLockHP = m_iLockHP;
	m_iInitialOpening = ((m_iInitialOpeningDeg * 65536) / 360);
	m_iMaxOpening = ((m_iMaxOpeningDeg * 65536) / 360);
	m_iMaxOpening = Clamp(m_iMaxOpening, 0, 65535);
	m_iInitialOpening = Clamp(m_iInitialOpening, 0, m_iMaxOpening);
	rTempRotation = sm_Rotation;
	rTempRotation.Yaw = (sm_Rotation.Yaw & 65535);
	bCA = bCollideActors;
	bBA = bBlockActors;
	bBP = bBlockPlayers;
	SetCollision(false, false, false);
	SetRotation(rTempRotation);
	SetCollision(bCA, bBA, bBP);
	DesiredRotation = rTempRotation;
	bRotateToDesired = false;
	m_iYawInit = Rotation.Yaw;
	rNewRotation.Yaw = m_iYawInit;
	m_vCenterOfDoor = (Location - (float(64) * Vector(rNewRotation)));
	m_vNormal = Cross(Vector(rNewRotation), vect(0.0000000, 0.0000000, 1.0000000));
	// End:0x1B1
	if((m_DoorActorA != none))
	{
		m_vDoorADir2D = (m_DoorActorA.Location - m_vCenterOfDoor);
	}
	m_vDoorADir2D.Z = 0.0000000;
	m_vDoorADir2D = Normal(m_vDoorADir2D);
	rNewRotation = Rotation;
	// End:0x21B
	if(m_bIsOpeningClockWise)
	{
		m_iYawMax = (m_iYawInit + m_iMaxOpening);
		rNewRotation.Yaw = (Rotation.Yaw + Clamp(m_iInitialOpening, 0, m_iMaxOpening));		
	}
	else
	{
		m_iYawMax = (m_iYawInit - m_iMaxOpening);
		rNewRotation.Yaw = (Rotation.Yaw - Clamp(m_iInitialOpening, 0, m_iMaxOpening));
	}
	m_iYawMax = (m_iYawMax & 65535);
	DesiredRotation = rNewRotation;
	// End:0x2CE
	if((rNewRotation.Yaw != m_iYawInit))
	{
		m_bUseWheel = true;
		SetDoorState(false);
		m_bHidePortal = m_bIsDoorClosed;
		// End:0x2BF
		if((int(Level.NetMode) == int(NM_Client)))
		{
			SetRotation(rNewRotation);
		}
		ClientSetDoor(rNewRotation, true);		
	}
	else
	{
		SetDoorState(true);
	}
	m_BreachAttached.Remove(0, m_BreachAttached.Length);
	return;
}

function PostBeginPlay()
{
	super(R6InteractiveObject).PostBeginPlay();
	m_bBulletGoThrough = false;
	return;
}

//This function should always be defined in subclass
function bool startAction(float fDeltaMouse, Actor actionInstigator)
{
	return true;
	return;
}

function SetDoorProcessStates(bool bOpening, bool bClosing)
{
	m_bInProcessOfOpening = bOpening;
	m_bInProcessOfClosing = bClosing;
	// End:0x35
	if((bOpening || bClosing))
	{
		Enable('Tick');
	}
	return;
}

function bool updateAction(float fDeltaMouse, Actor actionInstigator)
{
	local Rotator rNewRotation, rRotation;
	local float fDoorMouvement;
	local int iMaxDoorMove;
	local float fTempSide;
	local int iNewOpening;

	SetDoorProcessStates(false, false);
	// End:0x19
	if((fDeltaMouse == 0.0000000))
	{
		return false;
	}
	RotationRate.Yaw = default.RotationRate.Yaw;
	// End:0x47
	if((!m_bIsOpeningClockWise))
	{
		(fDeltaMouse *= float(-1));
	}
	fDoorMouvement = fDeltaMouse;
	fDoorMouvement = ((fDoorMouvement * float(m_iMaxOpening)) / m_fMaxMouseMove);
	// End:0xA2
	if(((default.Mass != float(0)) && (Mass != float(0))))
	{
		fDoorMouvement = ((fDoorMouvement * default.Mass) / Mass);
	}
	rNewRotation = Rotation;
	rRotation = Rotation;
	// End:0x104
	if(m_bIsOpeningClockWise)
	{
		iNewOpening = int((float(m_iCurrentOpening) + fDoorMouvement));
		iNewOpening = Clamp(iNewOpening, 0, m_iMaxOpening);
		rNewRotation.Yaw = (m_iYawInit + iNewOpening);		
	}
	else
	{
		iNewOpening = int((float(m_iCurrentOpening) - fDoorMouvement));
		iNewOpening = Clamp(iNewOpening, 0, m_iMaxOpening);
		rNewRotation.Yaw = (m_iYawInit - iNewOpening);
	}
	// End:0x1AE
	if((((!m_bUseWheel) && (rRotation.Yaw == m_iYawInit)) && (rNewRotation.Yaw != m_iYawInit)))
	{
		// End:0x190
		if((m_OpeningWheelSound != none))
		{
			PlaySound(m_OpeningWheelSound, 3);
		}
		AmbientSound = m_MoveAmbientSound;
		AmbientSoundStop = m_MoveAmbientSoundStop;
		m_bUseWheel = true;
	}
	ClientSetDoor(rNewRotation);
	return true;
	return;
}

simulated function R6CircumstantialActionCancel()
{
	performDoorAction(int(15));
	return;
}

//==============================================================================//
// RBrek - 1 sept 2001                                                          //
// To perform a full opening/closing of a door.                                 //
// either stQuery.iTeamActionID or stQuery.iPlayerActionID should be passed...  //
// TODO : replace SetRotation with use of bRotateToDesired                      //
//==============================================================================//
function performDoorAction(int iActionID)
{
	// End:0x18
	if((iActionID == int(5)))
	{
		CloseDoor(none);		
	}
	else
	{
		// End:0x30
		if((iActionID == int(1)))
		{
			OpenDoor(none);			
		}
		else
		{
			// End:0x51
			if((iActionID == int(13)))
			{
				UnlockDoor();
				PlaySound(m_UnlockSound, 3);				
			}
			else
			{
				// End:0x6C
				if((iActionID == int(14)))
				{
					PlaySound(m_LockSound, 3);					
				}
				else
				{
					// End:0x84
					if((iActionID == int(15)))
					{
						PlaySound(m_LockPickSoundStop, 3);
					}
				}
			}
		}
	}
	return;
}

function ClientSetDoor(Rotator rNewRotation, optional bool bForce)
{
	// End:0x34
	if((bForce || (DesiredRotation != rNewRotation)))
	{
		Enable('Tick');
		bRotateToDesired = true;
		DesiredRotation = rNewRotation;
	}
	return;
}

simulated event bool EncroachingOn(Actor Other)
{
	local R6Pawn P;
	local R6AIController AI;

	P = R6Pawn(Other);
	// End:0x89
	if(((P != none) && P.IsAlive()))
	{
		// End:0x87
		if((!P.m_bIsPlayer))
		{
			AI = R6AIController(P.Controller);
			AI.m_BumpedBy = self;
			AI.GotoBumpBackUpState(AI.GetStateName());
		}
		return true;
	}
	return false;
	return;
}

function OpenDoor(Pawn opener, optional int iRotationRate)
{
	local Rotator rNewRotation;

	// End:0x1B
	if((iRotationRate == 0))
	{
		iRotationRate = default.RotationRate.Yaw;
	}
	RotationRate.Yaw = iRotationRate;
	// End:0x41
	if((opener != none))
	{
		Instigator = opener;
	}
	// End:0x5D
	if((Instigator != none))
	{
		Instigator.R6MakeNoise(13);
	}
	rNewRotation = Rotation;
	// End:0x9F
	if((m_iYawInit < m_iYawMax))
	{
		// End:0x9C
		if((Rotation.Yaw > m_iYawMax))
		{
			(rNewRotation.Yaw -= 65536);
		}		
	}
	else
	{
		// End:0xC4
		if((Rotation.Yaw > m_iYawInit))
		{
			(rNewRotation.Yaw -= 65536);
		}
	}
	// End:0x118
	if(((!m_bUseWheel) && (rNewRotation.Yaw == m_iYawInit)))
	{
		// End:0xFA
		if((m_OpeningSound != none))
		{
			PlaySound(m_OpeningSound, 3);
		}
		AmbientSound = m_MoveAmbientSound;
		AmbientSoundStop = m_MoveAmbientSoundStop;
		m_bUseWheel = true;
	}
	rNewRotation.Yaw = m_iYawMax;
	bRotateToDesired = true;
	DesiredRotation = rNewRotation;
	SetDoorProcessStates(true, false);
	ClientSetDoor(rNewRotation);
	return;
}

simulated function CloseDoor(R6Pawn Pawn, optional int iRotationRate)
{
	local Rotator rNewRotation;

	// End:0x1B
	if((iRotationRate == 0))
	{
		iRotationRate = default.RotationRate.Yaw;
	}
	RotationRate.Yaw = iRotationRate;
	// End:0x41
	if((Pawn != none))
	{
		Instigator = Pawn;
	}
	// End:0x5D
	if((Instigator != none))
	{
		Instigator.R6MakeNoise(13);
	}
	rNewRotation = Rotation;
	rNewRotation.Yaw = m_iYawInit;
	bRotateToDesired = true;
	DesiredRotation = rNewRotation;
	SetDoorProcessStates(false, true);
	ClientSetDoor(rNewRotation);
	return;
}

function bool DoorOpenTowardsActor(Actor aActor)
{
	// End:0x32
	if((Dot(Vector(aActor.Rotation), m_vNormal) > float(0)))
	{
		// End:0x2D
		if(m_bIsOpeningClockWise)
		{
			return false;			
		}
		else
		{
			return true;
		}		
	}
	else
	{
		// End:0x40
		if(m_bIsOpeningClockWise)
		{
			return true;			
		}
		else
		{
			return false;
		}
	}
	return;
}

function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iPenetrationFactor, optional int iBulletGroup)
{
	local float fPercentage, fBulletDamMultiplier;
	local int i;

	// End:0x25E
	if(((int(Level.NetMode) == int(NM_Standalone)) || (int(Role) == int(ROLE_Authority))))
	{
		// End:0x166
		if((iBulletGroup == -1))
		{
			// End:0x60
			if((m_iHitPoints < 2500))
			{
				fBulletDamMultiplier = (0.0500000 * float(iPenetrationFactor));				
			}
			else
			{
				fBulletDamMultiplier = (0.0050000 * float(iPenetrationFactor));
			}
			// End:0x103
			if(((m_iCurrentLockHP != 0) && HitLock(vHitLocation)))
			{
				m_iCurrentLockHP = Max((m_iCurrentLockHP - Max(int(((float(iKillValue) * fBulletDamMultiplier) * float(10))), 400)), 0);
				// End:0x100
				if(((m_iYawInit != Rotation.Yaw) || (m_iCurrentLockHP == 0)))
				{
					UnlockDoor();
					OpenDoorWhenHit(vHitLocation, vMomentum, (2048 * iPenetrationFactor), false);
				}				
			}
			else
			{
				m_iCurrentHitPoints = Max(int((float(m_iCurrentHitPoints) - (float(iKillValue) * fBulletDamMultiplier))), 0);
				// End:0x163
				if(((m_iYawInit != Rotation.Yaw) || (m_iCurrentLockHP == 0)))
				{
					OpenDoorWhenHit(vHitLocation, vMomentum, (2048 * iPenetrationFactor), false);
				}
			}			
		}
		else
		{
			m_iCurrentHitPoints = Max((m_iCurrentHitPoints - iKillValue), 0);
			m_iCurrentLockHP = Max((m_iCurrentLockHP - iKillValue), 0);
			// End:0x1B3
			if((m_iCurrentLockHP == 0))
			{
				UnlockDoor();
				OpenDoorWhenHit(vHitLocation, vMomentum, 0, true);
			}
		}
		fPercentage = float(((m_iCurrentHitPoints * 100) / m_iHitPoints));
		SetNewDamageState(fPercentage);
		// End:0x25E
		if(m_bBroken)
		{
			PlaySound(m_ExplosionSound, 3);
			R6AbstractGameInfo(Level.Game).IObjectDestroyed(instigatedBy, self);
			Instigator = instigatedBy;
			R6MakeNoise2(m_fAIBreakNoiseRadius, 2, 4);
			J0x226:

			// End:0x25E [Loop If]
			if((m_BreachAttached.Length != 0))
			{
				// End:0x24A
				if((m_BreachAttached[0] == none))
				{
					m_BreachAttached.Remove(0, 1);					
				}
				else
				{
					m_BreachAttached[0].DoorExploded();
				}
				// [Loop Continue]
				goto J0x226;
			}
		}
	}
	return m_iCurrentHitPoints;
	return;
}

function bool HitLock(Vector vHitVector)
{
	local Vector vTemp2, vTemp3;

	vTemp2 = vHitVector;
	vTemp3 = Location;
	// End:0x5E
	if((((vTemp2.Z - vTemp3.Z) > float(-8)) || ((vTemp2.Z - vTemp3.Z) < float(-24))))
	{
		return false;
	}
	vTemp2.Z = 0.0000000;
	vTemp3.Z = 0.0000000;
	// End:0x97
	if((VSize((vTemp2 - vTemp3)) < float(112)))
	{
		return false;
	}
	return true;
	return;
}

function OpenDoorWhenHit(Vector vHitLocation, Vector vBulletDirection, int YawVariation, bool bExplosion)
{
	local Rotator rBulletAsRotator;
	local Vector vTemp2, vTemp3;
	local int iYawDifference;
	local bool bShootTurnCCW;

	vTemp2 = vHitLocation;
	vTemp2.Z = 0.0000000;
	vTemp3 = Location;
	vTemp3.Z = 0.0000000;
	// End:0x5C
	if(((VSize((vTemp2 - vTemp3)) < float(96)) && (!bExplosion)))
	{
		return;
	}
	rBulletAsRotator = Rotator(vBulletDirection);
	// End:0x8A
	if((rBulletAsRotator.Yaw < 0))
	{
		(rBulletAsRotator.Yaw += 65536);
	}
	iYawDifference = (rBulletAsRotator.Yaw - Rotation.Yaw);
	// End:0xBD
	if((iYawDifference < 0))
	{
		(iYawDifference += 65536);
	}
	// End:0xE1
	if((iYawDifference < 32768))
	{
		YawVariation = (-YawVariation);
		bShootTurnCCW = true;
	}
	(DesiredRotation.Yaw += YawVariation);
	RotationRate.Yaw = 65000;
	// End:0x484
	if((bExplosion == false))
	{
		// End:0x2BB
		if(m_bIsOpeningClockWise)
		{
			// End:0x154
			if((m_bInProcessOfClosing == true))
			{
				// End:0x151
				if((bShootTurnCCW == false))
				{
					SetDoorProcessStates(m_bInProcessOfOpening, false);
					DesiredRotation.Yaw = Rotation.Yaw;
				}				
			}
			else
			{
				// End:0x189
				if((m_bInProcessOfOpening == true))
				{
					// End:0x189
					if((bShootTurnCCW == true))
					{
						SetDoorProcessStates(false, false);
						DesiredRotation.Yaw = Rotation.Yaw;
					}
				}
			}
			// End:0x289
			if((!(((bShootTurnCCW == true) && (m_iYawInit == Rotation.Yaw)) || ((bShootTurnCCW == false) && (m_iYawMax == Rotation.Yaw)))))
			{
				// End:0x23B
				if((m_iYawInit > m_iYawMax))
				{
					// End:0x238
					if(((DesiredRotation.Yaw > m_iYawMax) && (DesiredRotation.Yaw < m_iYawInit)))
					{
						// End:0x228
						if((YawVariation > 0))
						{
							DesiredRotation.Yaw = m_iYawMax;							
						}
						else
						{
							DesiredRotation.Yaw = m_iYawInit;
						}
					}					
				}
				else
				{
					// End:0x262
					if((DesiredRotation.Yaw > m_iYawMax))
					{
						DesiredRotation.Yaw = m_iYawMax;						
					}
					else
					{
						// End:0x286
						if((DesiredRotation.Yaw < m_iYawInit))
						{
							DesiredRotation.Yaw = m_iYawInit;
						}
					}
				}				
			}
			else
			{
				// End:0x2A8
				if((bShootTurnCCW == true))
				{
					DesiredRotation.Yaw = m_iYawInit;					
				}
				else
				{
					DesiredRotation.Yaw = m_iYawMax;
				}
			}			
		}
		else
		{
			// End:0x2F8
			if((m_bInProcessOfClosing == true))
			{
				// End:0x2F5
				if((bShootTurnCCW == true))
				{
					SetDoorProcessStates(m_bInProcessOfOpening, false);
					DesiredRotation.Yaw = Rotation.Yaw;
				}				
			}
			else
			{
				// End:0x32D
				if((m_bInProcessOfOpening == true))
				{
					// End:0x32D
					if((bShootTurnCCW == false))
					{
						SetDoorProcessStates(false, false);
						DesiredRotation.Yaw = Rotation.Yaw;
					}
				}
			}
			// End:0x452
			if((!(((bShootTurnCCW == false) && (m_iYawInit == Rotation.Yaw)) || ((bShootTurnCCW == true) && (m_iYawMax == Rotation.Yaw)))))
			{
				// End:0x404
				if((m_iYawInit < m_iYawMax))
				{
					// End:0x3A9
					if((DesiredRotation.Yaw > 65536))
					{
						(DesiredRotation.Yaw -= 65536);
					}
					// End:0x401
					if(((DesiredRotation.Yaw < m_iYawMax) && (DesiredRotation.Yaw > m_iYawInit)))
					{
						// End:0x3F1
						if((YawVariation < 0))
						{
							DesiredRotation.Yaw = m_iYawMax;							
						}
						else
						{
							DesiredRotation.Yaw = m_iYawInit;
						}
					}					
				}
				else
				{
					// End:0x42B
					if((DesiredRotation.Yaw < m_iYawMax))
					{
						DesiredRotation.Yaw = m_iYawMax;						
					}
					else
					{
						// End:0x44F
						if((DesiredRotation.Yaw > m_iYawInit))
						{
							DesiredRotation.Yaw = m_iYawInit;
						}
					}
				}				
			}
			else
			{
				// End:0x471
				if((bShootTurnCCW == false))
				{
					DesiredRotation.Yaw = m_iYawInit;					
				}
				else
				{
					DesiredRotation.Yaw = m_iYawMax;
				}
			}
		}		
	}
	else
	{
		SetDoorProcessStates(false, false);
		// End:0x594
		if((Rotation.Yaw == m_iYawInit))
		{
			// End:0x4E7
			if(((m_bIsOpeningClockWise && (iYawDifference > 32768)) || ((!m_bIsOpeningClockWise) && (iYawDifference < 32768))))
			{
				OpenDoor(none, 65000);				
			}
			else
			{
				// End:0x542
				if(m_bIsOpeningClockWise)
				{
					// End:0x524
					if((m_iYawInit > m_iYawMax))
					{
						DesiredRotation.Yaw = (((m_iYawMax + m_iYawInit) / 2) + 32768);						
					}
					else
					{
						DesiredRotation.Yaw = ((m_iYawMax + m_iYawInit) / 2);
					}					
				}
				else
				{
					// End:0x576
					if((m_iYawInit < m_iYawMax))
					{
						DesiredRotation.Yaw = (((m_iYawMax + m_iYawInit) / 2) + 32768);						
					}
					else
					{
						DesiredRotation.Yaw = ((m_iYawMax + m_iYawInit) / 2);
					}
				}
			}			
		}
		else
		{
			// End:0x69E
			if((Rotation.Yaw == m_iYawMax))
			{
				// End:0x5EF
				if(((m_bIsOpeningClockWise && (iYawDifference < 32768)) || ((!m_bIsOpeningClockWise) && (iYawDifference > 32768))))
				{
					CloseDoor(none, 65000);					
				}
				else
				{
					// End:0x64C
					if((!m_bIsOpeningClockWise))
					{
						// End:0x62E
						if((m_iYawInit < m_iYawMax))
						{
							DesiredRotation.Yaw = (((m_iYawMax + m_iYawInit) / 2) + 32768);							
						}
						else
						{
							DesiredRotation.Yaw = ((m_iYawMax + m_iYawInit) / 2);
						}						
					}
					else
					{
						// End:0x680
						if((m_iYawInit > m_iYawMax))
						{
							DesiredRotation.Yaw = (((m_iYawMax + m_iYawInit) / 2) + 32768);							
						}
						else
						{
							DesiredRotation.Yaw = ((m_iYawMax + m_iYawInit) / 2);
						}
					}
				}				
			}
			else
			{
				// End:0x6E5
				if(((m_bIsOpeningClockWise && (iYawDifference < 32768)) || ((!m_bIsOpeningClockWise) && (iYawDifference > 32768))))
				{
					CloseDoor(none, 65000);					
				}
				else
				{
					OpenDoor(none, 65000);
				}
			}
		}
	}
	bRotateToDesired = true;
	Enable('Tick');
	// End:0x728
	if((DesiredRotation.Yaw > 65536))
	{
		(DesiredRotation.Yaw -= 65536);		
	}
	else
	{
		// End:0x749
		if((DesiredRotation.Yaw < 0))
		{
			(DesiredRotation.Yaw += 65536);
		}
	}
	// End:0x7A6
	if(((Rotation.Yaw == m_iYawInit) && (DesiredRotation.Yaw != m_iYawInit)))
	{
		// End:0x788
		if((m_OpeningWheelSound != none))
		{
			PlaySound(m_OpeningWheelSound, 3);
		}
		AmbientSound = m_MoveAmbientSound;
		AmbientSoundStop = m_MoveAmbientSoundStop;
		m_bUseWheel = true;
	}
	return;
}

simulated event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	local bool bDisplayOpenIcon;
	local Vector vDistance;
	local bool bOpensTowardsPawn;

	Query.iHasAction = 1;
	// End:0x5B
	if(m_bIsDoorClosed)
	{
		vDistance = (m_vVisibleCenter - PlayerController.Pawn.Location);
		vDistance.Z = 0.0000000;
		fDistance = VSize(vDistance);
	}
	// End:0x7E
	if((fDistance < m_fCircumstantialActionRange))
	{
		Query.iInRange = 1;		
	}
	else
	{
		Query.iInRange = 0;
	}
	// End:0xA3
	if(m_bInProcessOfClosing)
	{
		bDisplayOpenIcon = true;		
	}
	else
	{
		// End:0xB7
		if(m_bInProcessOfOpening)
		{
			bDisplayOpenIcon = false;			
		}
		else
		{
			// End:0xCB
			if(m_bIsDoorClosed)
			{
				bDisplayOpenIcon = true;				
			}
			else
			{
				bDisplayOpenIcon = false;
			}
		}
	}
	// End:0x126
	if((!bDisplayOpenIcon))
	{
		// End:0xFE
		if(m_bTreatDoorAsWindow)
		{
			Query.textureIcon = Texture'R6ActionIcons.CloseWindow';			
		}
		else
		{
			Query.textureIcon = Texture'R6ActionIcons.CloseDoor';
		}
		Query.iPlayerActionID = 5;		
	}
	else
	{
		Query.bCanBeInterrupted = m_bIsDoorLocked;
		// End:0x17A
		if(R6Rainbow(PlayerController.Pawn).m_bHasLockPickKit)
		{
			Query.fPlayerActionTimeRequired = (m_fUnlockBaseTime / 2.0000000);			
		}
		else
		{
			Query.fPlayerActionTimeRequired = m_fUnlockBaseTime;
		}
		// End:0x1BF
		if(m_bIsDoorLocked)
		{
			Query.textureIcon = Texture'R6ActionIcons.UnlockDoor';
			Query.iPlayerActionID = 13;			
		}
		else
		{
			bOpensTowardsPawn = DoorOpenTowardsActor(PlayerController.Pawn);
			// End:0x25A
			if(bOpensTowardsPawn)
			{
				// End:0x223
				if(m_bIsOpeningClockWise)
				{
					// End:0x20C
					if(m_bTreatDoorAsWindow)
					{
						Query.textureIcon = Texture'R6ActionIcons.OpenWin_T_CW';						
					}
					else
					{
						Query.textureIcon = Texture'R6ActionIcons.OpenDoor_T_CW';
					}					
				}
				else
				{
					// End:0x243
					if(m_bTreatDoorAsWindow)
					{
						Query.textureIcon = Texture'R6ActionIcons.OpenWin_T_CCW';						
					}
					else
					{
						Query.textureIcon = Texture'R6ActionIcons.OpenDoor_T_CCW';
					}
				}				
			}
			else
			{
				// End:0x29A
				if(m_bIsOpeningClockWise)
				{
					// End:0x283
					if(m_bTreatDoorAsWindow)
					{
						Query.textureIcon = Texture'R6ActionIcons.OpenWin_A_CW';						
					}
					else
					{
						Query.textureIcon = Texture'R6ActionIcons.OpenDoor_A_CW';
					}					
				}
				else
				{
					// End:0x2BA
					if(m_bTreatDoorAsWindow)
					{
						Query.textureIcon = Texture'R6ActionIcons.OpenWin_A_CCW';						
					}
					else
					{
						Query.textureIcon = Texture'R6ActionIcons.OpenDoor_A_CCW';
					}
				}
			}
			Query.iPlayerActionID = 1;
		}
	}
	// End:0x3D7
	if(m_bIsDoorClosed)
	{
		Query.iTeamActionID = 1;
		Query.iTeamActionIDList[0] = 1;
		// End:0x399
		if((!m_bTreatDoorAsWindow))
		{
			Query.iTeamActionIDList[1] = 2;
			Query.iTeamActionIDList[2] = 3;
			Query.iTeamActionIDList[3] = 4;
			R6FillSubAction(Query, 0, int(0));
			R6FillSubAction(Query, 1, int(0));
			R6FillGrenadeSubAction(Query, 2, PlayerController);
			R6FillGrenadeSubAction(Query, 3, PlayerController);			
		}
		else
		{
			Query.iTeamActionIDList[1] = 0;
			Query.iTeamActionIDList[2] = 0;
			Query.iTeamActionIDList[3] = 0;
		}		
	}
	else
	{
		Query.iTeamActionID = 5;
		Query.iTeamActionIDList[0] = 5;
		// End:0x488
		if((!m_bTreatDoorAsWindow))
		{
			Query.iTeamActionIDList[1] = 6;
			Query.iTeamActionIDList[2] = 7;
			Query.iTeamActionIDList[3] = 8;
			R6FillSubAction(Query, 0, int(0));
			R6FillSubAction(Query, 1, int(0));
			R6FillGrenadeSubAction(Query, 2, PlayerController);
			R6FillGrenadeSubAction(Query, 3, PlayerController);			
		}
		else
		{
			Query.iTeamActionIDList[1] = 0;
			Query.iTeamActionIDList[2] = 0;
			Query.iTeamActionIDList[3] = 0;
		}
	}
	return;
}

function R6FillGrenadeSubAction(out R6AbstractCircumstantialActionQuery Query, int iSubMenu, PlayerController PlayerController)
{
	local int i, j;

	// End:0x3B
	if(R6ActionCanBeExecuted(int(9), PlayerController))
	{
		Query.iTeamSubActionsIDList[((iSubMenu * 4) + i)] = 9;
		(i++);
	}
	// End:0x76
	if(R6ActionCanBeExecuted(int(10), PlayerController))
	{
		Query.iTeamSubActionsIDList[((iSubMenu * 4) + i)] = 10;
		(i++);
	}
	// End:0xB1
	if(R6ActionCanBeExecuted(int(11), PlayerController))
	{
		Query.iTeamSubActionsIDList[((iSubMenu * 4) + i)] = 11;
		(i++);
	}
	// End:0xEC
	if(R6ActionCanBeExecuted(int(12), PlayerController))
	{
		Query.iTeamSubActionsIDList[((iSubMenu * 4) + i)] = 12;
		(i++);
	}
	j = i;
	J0xF7:

	// End:0x12F [Loop If]
	if((j < 4))
	{
		Query.iTeamSubActionsIDList[((iSubMenu * 4) + j)] = 0;
		(j++);
		// [Loop Continue]
		goto J0xF7;
	}
	return;
}

//------------------------------------------------------------------
// SetBroken
//	
//------------------------------------------------------------------
function SetBroken()
{
	super(R6InteractiveObject).SetBroken();
	SetDoorState(false);
	m_bHidePortal = false;
	return;
}

function bool ShouldBeBreached()
{
	// End:0x0B
	if(m_bBroken)
	{
		return false;
	}
	// End:0x16
	if(m_bTreatDoorAsWindow)
	{
		return false;
	}
	// End:0x30
	if(((!m_bIsDoorClosed) || (m_iCurrentOpening != 0)))
	{
		return false;
	}
	return true;
	return;
}

event EndedRotation()
{
	bRotateToDesired = false;
	return;
}

event Tick(float fDelta)
{
	local int rDesYaw;

	// End:0x12
	if(m_bBroken)
	{
		Disable('Tick');
		return;
	}
	// End:0x3E
	if((((!m_bInProcessOfOpening) && (!m_bInProcessOfClosing)) && (!bRotateToDesired)))
	{
		Disable('Tick');
	}
	rDesYaw = DesiredRotation.Yaw;
	// End:0x68
	if((rDesYaw < 0))
	{
		(rDesYaw += 65536);		
	}
	else
	{
		// End:0x83
		if((rDesYaw > 65536))
		{
			(rDesYaw -= 65536);
		}
	}
	// End:0x123
	if((Rotation.Yaw == rDesYaw))
	{
		// End:0xE0
		if((m_bInProcessOfClosing || m_bInProcessOfOpening))
		{
			// End:0xD8
			if(m_bInProcessOfClosing)
			{
				// End:0xC9
				if((m_ClosingSound != none))
				{
					PlaySound(m_ClosingSound, 3);
				}
				AmbientSound = none;
				m_bUseWheel = false;
			}
			SetDoorProcessStates(false, false);
		}
		// End:0x123
		if((m_bUseWheel && (DesiredRotation.Yaw == m_iYawInit)))
		{
			// End:0x114
			if((m_ClosingWheelSound != none))
			{
				PlaySound(m_ClosingWheelSound, 3);
			}
			AmbientSound = none;
			m_bUseWheel = false;
		}
	}
	// End:0x14D
	if(m_bIsOpeningClockWise)
	{
		m_iCurrentOpening = ((Rotation.Yaw - m_iYawInit) & 65535);		
	}
	else
	{
		m_iCurrentOpening = ((m_iYawInit - Rotation.Yaw) & 65535);
	}
	SetDoorState((m_iCurrentOpening < 16384));
	// End:0x1A5
	if((!m_bTreatDoorAsWindow))
	{
		m_vVisibleCenter = (Location - (float(64) * Vector(Rotation)));		
	}
	else
	{
		m_vVisibleCenter = (Location - ((m_fWindowWidth * 0.5000000) * Vector(Rotation)));
	}
	m_bHidePortal = (m_iCurrentOpening == 0);
	return;
}

simulated function UnlockDoor()
{
	// End:0x0D
	if((!m_bIsDoorLocked))
	{
		return;
	}
	m_bIsDoorLocked = false;
	m_DoorActorA.ExtraCost = m_DoorActorA.default.ExtraCost;
	m_DoorActorB.ExtraCost = m_DoorActorB.default.ExtraCost;
	return;
}

simulated function SetDoorState(bool bIsClosed)
{
	m_bIsDoorClosed = bIsClosed;
	// End:0x18
	if(m_bTreatDoorAsWindow)
	{
		return;
	}
	// End:0x92
	if(m_bIsDoorClosed)
	{
		// End:0x55
		if(m_bIsDoorLocked)
		{
			m_DoorActorA.ExtraCost = 1000;
			m_DoorActorB.ExtraCost = 1000;			
		}
		else
		{
			m_DoorActorA.ExtraCost = m_DoorActorA.default.ExtraCost;
			m_DoorActorB.ExtraCost = m_DoorActorB.default.ExtraCost;
		}		
	}
	else
	{
		m_DoorActorA.ExtraCost = 0;
		m_DoorActorB.ExtraCost = 0;
	}
	return;
}

//===========================================================================//
// R6GetCircumstantialActionString()                                         //
//===========================================================================//
simulated function string R6GetCircumstantialActionString(int iAction)
{
	switch(iAction)
	{
		// End:0x34
		case int(5):
			return Localize("RDVOrder", "Order_Close", "R6Menu");
		// End:0x61
		case int(6):
			return Localize("RDVOrder", "Order_Clear", "R6Menu");
		// End:0x90
		case int(7):
			return Localize("RDVOrder", "Order_Grenade", "R6Menu");
		// End:0xC4
		case int(8):
			return Localize("RDVOrder", "Order_GrenadeClear", "R6Menu");
		// End:0xF0
		case int(1):
			return Localize("RDVOrder", "Order_Open", "R6Menu");
		// End:0x121
		case int(2):
			return Localize("RDVOrder", "Order_OpenClear", "R6Menu");
		// End:0x154
		case int(3):
			return Localize("RDVOrder", "Order_OpenGrenade", "R6Menu");
		// End:0x18C
		case int(4):
			return Localize("RDVOrder", "Order_OpenGrenadeClear", "R6Menu");
		// End:0x1BF
		case int(9):
			return Localize("RDVOrder", "Order_FragGrenade", "R6Menu");
		// End:0x1F1
		case int(10):
			return Localize("RDVOrder", "Order_GasGrenade", "R6Menu");
		// End:0x225
		case int(11):
			return Localize("RDVOrder", "Order_FlashGrenade", "R6Menu");
		// End:0x259
		case int(12):
			return Localize("RDVOrder", "Order_SmokeGrenade", "R6Menu");
		// End:0xFFFF
		default:
			return "";
			break;
	}
	return;
}

//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//===========================================================================//
function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query)
{
	m_fPlayerCAStartTime = Level.TimeSeconds;
	PlayLockPickSound();
	return;
}

function PlayLockPickSound()
{
	PlaySound(m_LockPickSound, 3);
	return;
}

//===========================================================================//
// R6GetCircumstantialActionProgress()                                       //
//   Update the door unlocking progress (if it's locked)                     //
//   Should be affected by the skills of the pawn unlocking it               //
//===========================================================================//
function int R6GetCircumstantialActionProgress(R6AbstractCircumstantialActionQuery Query, Pawn actingPawn)
{
	local float fPercentage;

	// End:0x54
	if(m_bIsDoorLocked)
	{
		fPercentage = ((Level.TimeSeconds - m_fPlayerCAStartTime) / (Query.fPlayerActionTimeRequired * (2.0000000 - R6Pawn(actingPawn).ArmorSkillEffect())));		
	}
	else
	{
		fPercentage = 1.0000000;
	}
	return int((fPercentage * float(100)));
	return;
}

//===========================================================================//
// R6ActionCanBeExecuted()												     //
//	Check if the action specified can be executed. Useful to disable choice  //
//	in the rose des vents.													 //
//===========================================================================//
simulated function bool R6ActionCanBeExecuted(int iAction, PlayerController PlayerController)
{
	local R6PlayerController pPlayerCtrl;

	// End:0x10
	if((iAction == int(0)))
	{
		return false;
	}
	pPlayerCtrl = R6PlayerController(PlayerController);
	// End:0x43
	if(((pPlayerCtrl == none) || (pPlayerCtrl.m_TeamManager == none)))
	{
		return false;
	}
	switch(iAction)
	{
		// End:0x6F
		case int(9):
			return pPlayerCtrl.m_TeamManager.HaveRainbowWithGrenadeType(1);
			// End:0xE1
			break;
		// End:0x94
		case int(10):
			return pPlayerCtrl.m_TeamManager.HaveRainbowWithGrenadeType(2);
			// End:0xE1
			break;
		// End:0xB9
		case int(11):
			return pPlayerCtrl.m_TeamManager.HaveRainbowWithGrenadeType(3);
			// End:0xE1
			break;
		// End:0xDE
		case int(12):
			return pPlayerCtrl.m_TeamManager.HaveRainbowWithGrenadeType(4);
			// End:0xE1
			break;
		// End:0xFFFF
		default:
			break;
	}
	return true;
	return;
}

//============================================================================
// Bump - 
//============================================================================
event Bump(Actor Other)
{
	local R6Pawn Pawn;
	local Vector vDoorDir;
	local Rotator rPawnRot;
	local Vector vPawnDir;

	Pawn = R6Pawn(Other);
	// End:0x1D
	if((Pawn == none))
	{
		return;
	}
	// End:0x35
	if(WillOpenOnTouch(Pawn))
	{
		OpenDoor(Pawn);
		return;
	}
	return;
}

//============================================================================
// bool ActorIsOnSideA - 
//============================================================================
function bool ActorIsOnSideA(Actor aActor)
{
	local Vector vActorDir2D;

	vActorDir2D = (aActor.Location - m_vCenterOfDoor);
	vActorDir2D.Z = 0.0000000;
	vActorDir2D = Normal(vActorDir2D);
	return (Dot(vActorDir2D, m_vDoorADir2D) > float(0));
	return;
}

function Vector GetTarget(Actor aActor, float fDistanceFromDoor, optional bool bBackup)
{
	local Vector vTarget;

	// End:0x17
	if(bBackup)
	{
		(fDistanceFromDoor *= float(-1));
	}
	vTarget = m_vCenterOfDoor;
	// End:0x46
	if(ActorIsOnSideA(aActor))
	{
		(vTarget -= (fDistanceFromDoor * m_vDoorADir2D));		
	}
	else
	{
		(vTarget += (fDistanceFromDoor * m_vDoorADir2D));
	}
	vTarget.Z = aActor.Location.Z;
	return vTarget;
	return;
}

defaultproperties
{
	m_iLockHP=1000
	m_iMaxOpeningDeg=90
	m_fUnlockBaseTime=5.0000000
	m_iHitPoints=2000
	Physics=8
	m_eDisplayFlag=1
	m_bUseR6Availability=false
	m_bSkipHitDetection=true
	m_bUseDifferentVisibleCollide=true
	m_bUseOriginalRotationInPlanning=true
	m_bSpriteShowFlatInPlanning=true
	m_bOutlinedInPlanning=false
	m_fCircumstantialActionRange=132.0000000
	NetPriority=2.7000000
	RotationRate=(Pitch=0,Yaw=20000,Roll=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function dbgLogActor
