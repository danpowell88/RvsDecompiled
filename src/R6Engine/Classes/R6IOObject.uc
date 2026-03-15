//=============================================================================
// R6IOObject - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6IOObject : This should allow action moves on the door
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6IOObject extends R6IActionObject
    native
    placeable;

enum eDeviceCircumstantialAction
{
	DCA_None,                       // 0
	DCA_DisarmBomb,                 // 1
	DCA_ArmBomb,                    // 2
	DCA_Device                      // 3
};

enum eStateIOObejct
{
	SIO_Start,                      // 0
	SIO_Interrupt,                  // 1
	SIO_Complete                    // 2
};

var(R6ActionObject) R6Pawn.eDeviceAnimToPlay m_eAnimToPlay;
var R6IOObject.eStateIOObejct m_ObjectState;
var(R6ActionObject) bool m_bToggleType;  // can this object be toggled on/off, or set only once while in-round?
var bool sm_bToggleType;
var(R6ActionObject) bool m_bIsActivated;  // state of the object
var bool sm_bIsActivated;
var(R6ActionObject) float m_fGainTimeWithElectronicsKit;  // 2 sec by default
var float m_fLockObjectTime;  // time the object started to be used. Only one pawn can interact with this object
var Sound m_StartSnd;
var Sound m_InterruptedSnd;
var Sound m_CompletedSnd;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bIsActivated, sm_bIsActivated;
}

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
	sm_bIsActivated = m_bIsActivated;
	sm_bToggleType = m_bToggleType;
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
	super(R6InteractiveObject).ResetOriginalData();
	m_bIsActivated = sm_bIsActivated;
	m_bToggleType = sm_bToggleType;
	m_fLockObjectTime = 0.0000000;
	return;
}

//------------------------------------------------------------------
// LockObjectUse
//	
//------------------------------------------------------------------
simulated function LockObjectUse(bool bIsInUse)
{
	// End:0x20
	if(bIsInUse)
	{
		m_fLockObjectTime = Level.TimeSeconds;		
	}
	else
	{
		m_fLockObjectTime = 0.0000000;
	}
	return;
}

//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//===========================================================================//
simulated function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query)
{
	m_fPlayerCAStartTime = Level.TimeSeconds;
	PerformSoundAction(0);
	LockObjectUse(true);
	return;
}

//===========================================================================//
// R6GetCircumstantialActionProgress()                                       //
//   Update the device planting progress                                     //
//   Should be affected by the skills of the pawn planting it                //
//===========================================================================//
simulated function int R6GetCircumstantialActionProgress(R6AbstractCircumstantialActionQuery Query, Pawn actingPawn)
{
	local float fPercentage;

	fPercentage = ((Level.TimeSeconds - m_fPlayerCAStartTime) / (Query.fPlayerActionTimeRequired * (2.0000000 - R6Pawn(actingPawn).ArmorSkillEffect())));
	(fPercentage *= float(100));
	// End:0x68
	if((fPercentage >= float(100)))
	{
		LockObjectUse(false);
	}
	// End:0x90
	if(((fPercentage >= float(100)) && (int(m_ObjectState) != int(2))))
	{
		PerformSoundAction(2);
	}
	return int(fPercentage);
	return;
}

simulated function R6CircumstantialActionCancel()
{
	LockObjectUse(false);
	PerformSoundAction(1);
	return;
}

simulated function bool HasKit(R6Pawn aPawn)
{
	return false;
	return;
}

//------------------------------------------------------------------
// GetMaxTimeRequired
//	used to unlock an IOObject that was locked
//------------------------------------------------------------------
simulated function float GetMaxTimeRequired()
{
	return 0.0000000;
	return;
}

simulated function float GetTimeRequired(R6Pawn aPawn)
{
	return 0.0000000;
	return;
}

simulated function ToggleDevice(R6Pawn aPawn)
{
	local float fBackup;

	fBackup = m_fLockObjectTime;
	// End:0x2A
	if((!aPawn.m_bIsPlayer))
	{
		m_fLockObjectTime = 0.0000000;
	}
	// End:0x3D
	if(CanToggle())
	{
		LockObjectUse(false);		
	}
	else
	{
		fBackup = m_fLockObjectTime;
	}
	return;
}

simulated function bool CanToggle()
{
	local bool bCanToggle;

	bCanToggle = ((sm_bIsActivated == m_bIsActivated) || (m_bToggleType == true));
	// End:0x67
	if((bCanToggle && (m_fLockObjectTime != float(0))))
	{
		// End:0x65
		if((GetMaxTimeRequired() < (Level.TimeSeconds - m_fLockObjectTime)))
		{
			LockObjectUse(false);			
		}
		else
		{
			return false;
		}
	}
	return bCanToggle;
	return;
}

function PerformSoundAction(R6IOObject.eStateIOObejct eState)
{
	m_ObjectState = eState;
	switch(eState)
	{
		// End:0x54
		case 0:
			// End:0x47
			if(bShowLog)
			{
				Log("****** PerformSoundAction SIO_Start");
			}
			__NFUN_264__(m_StartSnd, 3) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
			// End:0xE2
			break;
		// End:0x9A
		case 1:
			// End:0x8D
			if(bShowLog)
			{
				__NFUN_231__("****** PerformSoundAction SIO_Interrupt");
			}
			__NFUN_264__(m_InterruptedSnd, 3);
			// End:0xE2
			break;
		// End:0xDF
		case 2:
			// End:0xD2
			if(bShowLog)
			{
				__NFUN_231__("****** PerformSoundAction SIO_Complete");
			}
			__NFUN_264__(m_CompletedSnd, 3);
			// End:0xE2
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

defaultproperties
{
	m_eAnimToPlay=2
	m_bToggleType=true
	m_fGainTimeWithElectronicsKit=2.0000000
	RemoteRole=2
	DrawType=8
	bUseCylinderCollision=true
	bDirectional=true
	CollisionRadius=32.0000000
	CollisionHeight=55.0000000
	m_fCircumstantialActionRange=105.0000000
	NetPriority=2.7000000
	StaticMesh=StaticMesh'R6ActionObjects.MpBomb.MpBomb'
}
