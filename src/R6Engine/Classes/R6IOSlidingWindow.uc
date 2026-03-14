//=============================================================================
// R6IOSlidingWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6SlidingWindow : This should allow action moves a window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
// 
//  Revision history:
//    2001/05/23 * Created by Alexandre Dionne
//    2001/11/26 * Merged with interactive objects - Jean-Francois Dube
//  Note: if you make R6IOSlidingWindow native then you will need to take care so
//  that the names in eWindowCircumstantialAction do not conflict with other enums
//=============================================================================
class R6IOSlidingWindow extends R6IActionObject
    placeable;

enum EOpeningSide
{
	Top,                            // 0
	Bottom,                         // 1
	Left,                           // 2
	Right                           // 3
};

enum eWindowCircumstantialAction
{
	CA_None,                        // 0
	CA_Open,                        // 1
	CA_Close,                       // 2
	CA_Climb,                       // 3
	CA_Grenade,                     // 4
	CA_OpenAndGrenade,              // 5
	CA_GrenadeFrag,                 // 6
	CA_GrenadeGas,                  // 7
	CA_GrenadeFlash,                // 8
	CA_GrenadeSmoke                 // 9
};

var(R6WindowProperties) R6IOSlidingWindow.EOpeningSide eOpening;  // The direction of the window opening
var(R6WindowProperties) int m_iInitialOpening;  // The percentage of initial window opening
var int sm_iInitialOpening;
var(R6WindowProperties) bool m_bIsWindowLocked;  // Is the window Locked
var bool sm_bIsWindowLocked;  // Is the window Locked
var bool m_bIsWindowClosed;  // Is the door open or not
var float C_fWindowOpen;
var(R6WindowProperties) float m_iMaxOpening;  // The maximum value for the window to open
var float m_TotalMovement;
var Vector sm_Location;

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
	sm_Location = Location;
	sm_iInitialOpening = m_iInitialOpening;
	sm_bIsWindowLocked = m_bIsWindowLocked;
	return;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	local Vector vNewLocation, vX, vY, vZ;

	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super(R6InteractiveObject).ResetOriginalData();
	m_ActionInstigator = none;
	__NFUN_267__(sm_Location);
	m_iInitialOpening = sm_iInitialOpening;
	m_bIsWindowLocked = sm_bIsWindowLocked;
	// End:0x14F
	if(__NFUN_151__(m_iInitialOpening, 0))
	{
		vNewLocation = Location;
		__NFUN_229__(Rotation, vX, vY, vZ);
		switch(eOpening)
		{
			// End:0xA3
			case 0:
				m_TotalMovement = float(m_iInitialOpening);
				vNewLocation.Z = __NFUN_174__(Location.Z, float(m_iInitialOpening));
				// End:0x147
				break;
			// End:0xDD
			case 1:
				m_TotalMovement = __NFUN_175__(m_iMaxOpening, float(m_iInitialOpening));
				vNewLocation.Z = __NFUN_175__(Location.Z, float(m_iInitialOpening));
				// End:0x147
				break;
			// End:0x114
			case 2:
				m_TotalMovement = __NFUN_175__(m_iMaxOpening, float(m_iInitialOpening));
				vNewLocation = __NFUN_216__(Location, __NFUN_213__(float(m_iInitialOpening), vX));
				// End:0x147
				break;
			// End:0x144
			case 3:
				m_TotalMovement = float(m_iInitialOpening);
				vNewLocation = __NFUN_215__(Location, __NFUN_213__(float(m_iInitialOpening), vX));
				// End:0x147
				break;
			// End:0xFFFF
			default:
				break;
		}
		__NFUN_267__(vNewLocation);
	}
	m_bIsWindowClosed = __NFUN_151__(m_iInitialOpening, 0);
	return;
}

function bool startAction(float fDeltaMouse, Actor actionInstigator)
{
	// End:0x0D
	if(__NFUN_119__(m_ActionInstigator, none))
	{
		return false;
	}
	m_ActionInstigator = actionInstigator;
	return updateAction(fDeltaMouse, actionInstigator);
	return;
}

function bool updateAction(float fDeltaMouse, Actor actionInstigator)
{
	local Vector vNewLocation, vX, vY, vZ;
	local float fWindowMovement;

	// End:0x11
	if(__NFUN_119__(actionInstigator, m_ActionInstigator))
	{
		return false;
	}
	fWindowMovement = __NFUN_246__(__NFUN_186__(fDeltaMouse), m_fMinMouseMove, m_fMaxMouseMove);
	fWindowMovement = __NFUN_172__(__NFUN_171__(fWindowMovement, m_iMaxOpening), m_fMaxMouseMove);
	// End:0x78
	if(__NFUN_130__(__NFUN_181__(default.Mass, float(0)), __NFUN_181__(Mass, float(0))))
	{
		fWindowMovement = __NFUN_172__(__NFUN_171__(fWindowMovement, default.Mass), Mass);
	}
	// End:0x97
	if(__NFUN_176__(fDeltaMouse, float(0)))
	{
		fWindowMovement = __NFUN_171__(fWindowMovement, -1.0000000);
	}
	m_TotalMovement = __NFUN_174__(m_TotalMovement, fWindowMovement);
	// End:0xD6
	if(__NFUN_176__(m_TotalMovement, float(0)))
	{
		fWindowMovement = __NFUN_175__(fWindowMovement, m_TotalMovement);
		m_TotalMovement = 0.0000000;		
	}
	else
	{
		// End:0x109
		if(__NFUN_177__(m_TotalMovement, m_iMaxOpening))
		{
			fWindowMovement = __NFUN_175__(fWindowMovement, __NFUN_175__(m_TotalMovement, m_iMaxOpening));
			m_TotalMovement = m_iMaxOpening;
		}
	}
	__NFUN_229__(Rotation, vX, vY, vZ);
	vNewLocation = Location;
	switch(eOpening)
	{
		// End:0x155
		case 0:
			vNewLocation.Z = __NFUN_174__(Location.Z, fWindowMovement);
			// End:0x1A2
			break;
		// End:0x179
		case 1:
			vNewLocation.Z = __NFUN_174__(Location.Z, fWindowMovement);
			// End:0x1A2
			break;
		// End:0x17E
		case 2:
		// End:0x19F
		case 3:
			vNewLocation = __NFUN_215__(Location, __NFUN_213__(fWindowMovement, vX));
			// End:0x1A2
			break;
		// End:0xFFFF
		default:
			break;
	}
	__NFUN_267__(vNewLocation);
	return true;
	return;
}

function endAction()
{
	m_ActionInstigator = none;
	return;
}

event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	local bool bIsOpen;

	// End:0x32
	if(__NFUN_177__(m_TotalMovement, __NFUN_171__(m_iMaxOpening, C_fWindowOpen)))
	{
		Query.iHasAction = 1;
		bIsOpen = true;		
	}
	else
	{
		Query.iHasAction = 0;
		bIsOpen = false;
	}
	// End:0x6E
	if(__NFUN_176__(fDistance, m_fCircumstantialActionRange))
	{
		Query.iInRange = 1;		
	}
	else
	{
		Query.iInRange = 0;
	}
	Query.textureIcon = Texture'R6ActionIcons.Climb';
	// End:0x152
	if(bIsOpen)
	{
		Query.iPlayerActionID = 2;
		Query.iTeamActionID = 2;
		Query.iTeamActionIDList[0] = 2;
		Query.iTeamActionIDList[1] = 4;
		Query.iTeamActionIDList[2] = 0;
		Query.iTeamActionIDList[3] = 0;
		R6FillSubAction(Query, 0, int(0));
		R6FillGrenadeSubAction(Query, 1, PlayerController);
		R6FillSubAction(Query, 2, int(0));
		R6FillSubAction(Query, 3, int(0));		
	}
	else
	{
		Query.iPlayerActionID = 1;
		Query.iTeamActionID = 1;
		Query.iTeamActionIDList[0] = 1;
		Query.iTeamActionIDList[1] = 5;
		Query.iTeamActionIDList[2] = 0;
		Query.iTeamActionIDList[3] = 0;
		R6FillSubAction(Query, 0, int(0));
		R6FillGrenadeSubAction(Query, 1, PlayerController);
		R6FillSubAction(Query, 2, int(0));
		R6FillSubAction(Query, 3, int(0));
	}
	return;
}

function R6FillGrenadeSubAction(out R6AbstractCircumstantialActionQuery Query, int iSubMenu, PlayerController PlayerController)
{
	local int i, j;

	// End:0x3B
	if(R6ActionCanBeExecuted(int(6), PlayerController))
	{
		Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), i)] = 6;
		__NFUN_165__(i);
	}
	// End:0x76
	if(R6ActionCanBeExecuted(int(7), PlayerController))
	{
		Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), i)] = 7;
		__NFUN_165__(i);
	}
	// End:0xB1
	if(R6ActionCanBeExecuted(int(8), PlayerController))
	{
		Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), i)] = 8;
		__NFUN_165__(i);
	}
	// End:0xEC
	if(R6ActionCanBeExecuted(int(9), PlayerController))
	{
		Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), i)] = 9;
		__NFUN_165__(i);
	}
	j = i;
	J0xF7:

	// End:0x12F [Loop If]
	if(__NFUN_150__(j, 4))
	{
		Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), j)] = 0;
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0xF7;
	}
	return;
}

defaultproperties
{
	m_bIsWindowClosed=true
	C_fWindowOpen=0.9000000
	m_iMaxOpening=50.0000000
	RemoteRole=2
	DrawType=8
	m_eDisplayFlag=1
	bObsolete=true
	CollisionRadius=10.0000000
	CollisionHeight=10.0000000
}
