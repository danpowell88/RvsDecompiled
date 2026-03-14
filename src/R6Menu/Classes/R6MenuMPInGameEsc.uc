//=============================================================================
// R6MenuMPInGameEsc - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPInGameEsc.uc : The first multi player menu window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/03/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMPInGameEsc extends R6MenuWidget;

const C_fNAVBAR_HEIGHT = 55;
const C_fREFRESH_OBJ = 2;

var bool m_bExitGamePopUp;
var bool m_bEscAvailable;
var float m_fTimeForRefreshObj;
var R6MenuMPInGameEscNavBar m_pEscNavBar;
var R6MenuMPInGameObj m_pInGameObj;

//===================================================================================
// Create the window and all the area for displaying game information
//===================================================================================
function Created()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local float fYNavBarPos;

	r6Root = R6MenuInGameMultiPlayerRootWindow(OwnerWindow);
	m_pEscNavBar = R6MenuMPInGameEscNavBar(CreateWindow(Root.MenuClassDefines.ClassInGameEscNavBar, float(r6Root.m_REscPopUp.X), float(__NFUN_147__(__NFUN_146__(__NFUN_146__(r6Root.m_REscPopUp.Y, r6Root.30), r6Root.m_REscPopUp.H), 55)), float(r6Root.m_REscPopUp.W), 55.0000000));
	m_pInGameObj = R6MenuMPInGameObj(CreateWindow(Root.MenuClassDefines.ClassInGameObjectives, float(r6Root.m_REscPopUp.X), float(__NFUN_146__(r6Root.m_REscPopUp.Y, r6Root.30)), float(r6Root.m_REscPopUp.W), float(__NFUN_147__(r6Root.m_REscPopUp.H, 55)), self));
	return;
}

function Tick(float DeltaTime)
{
	// End:0x2B
	if(__NFUN_179__(m_fTimeForRefreshObj, float(2)))
	{
		m_pInGameObj.UpdateObjectives();
		m_fTimeForRefreshObj = 0.0000000;		
	}
	else
	{
		__NFUN_184__(m_fTimeForRefreshObj, DeltaTime);
	}
	return;
}

defaultproperties
{
	m_bEscAvailable=true
	m_fTimeForRefreshObj=2.0000000
}
