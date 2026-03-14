//=============================================================================
//  R6MenuMPInGameEsc.uc : The first multi player menu window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/03/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMPInGameEsc extends R6MenuWidget;

const C_fNAVBAR_HEIGHT				= 55;			// the height of the nav bar
const C_fREFRESH_OBJ				= 2;			// refresh the objectives

var R6MenuMPInGameEscNavBar			m_pEscNavBar;

var R6MenuMPInGameObj				m_pInGameObj;

var FLOAT							m_fTimeForRefreshObj;

var BOOL							m_bExitGamePopUp;
var BOOL							m_bEscAvailable;

//===================================================================================
// Create the window and all the area for displaying game information
//===================================================================================
function Created()
{
	local R6MenuInGameMultiPlayerRootWindow R6Root; 
	local FLOAT fYNavBarPos;

	R6Root = R6MenuInGameMultiPlayerRootWindow(OwnerWindow);

    m_pEscNavBar = R6MenuMPInGameEscNavBar( CreateWindow(class'R6MenuMPInGameEscNavBar', 
                                            R6Root.m_REscPopUp.X,
                                            R6Root.m_REscPopUp.Y + R6Root.C_iESC_POP_UP_HEIGHT + R6Root.m_REscPopUp.H - C_fNAVBAR_HEIGHT,
                                            R6Root.m_REscPopUp.W,
                                            C_fNAVBAR_HEIGHT));

	m_pInGameObj = R6MenuMPInGameObj(CreateWindow(class'R6MenuMPInGameObj', 
												  r6Root.m_REscPopUp.X, r6Root.m_REscPopUp.Y + r6Root.C_iESC_POP_UP_HEIGHT, 
												  r6Root.m_REscPopUp.W, r6Root.m_REscPopUp.H - C_fNAVBAR_HEIGHT, self));
}

function Tick(float deltaTime)
{
	if (m_fTimeForRefreshObj >= C_fREFRESH_OBJ)
	{
		m_pInGameObj.UpdateObjectives();
		m_fTimeForRefreshObj = 0;
	}
	else
	{
		// Incremant timer for refresh
		m_fTimeForRefreshObj += deltaTime;
	}
}

defaultproperties
{
     m_bEscAvailable=True
     m_fTimeForRefreshObj=2.000000
}
