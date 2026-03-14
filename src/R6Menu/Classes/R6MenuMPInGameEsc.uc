//=============================================================================
//  R6MenuMPInGameEsc.uc : The first multi player menu window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/03/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMPInGameEsc extends R6MenuWidget;

// --- Constants ---
const C_fNAVBAR_HEIGHT =  55;
const C_fREFRESH_OBJ =  2;

// --- Variables ---
var bool m_bEscAvailable;
var float m_fTimeForRefreshObj;
var R6MenuMPInGameObj m_pInGameObj;
var R6MenuMPInGameEscNavBar m_pEscNavBar;
var bool m_bExitGamePopUp;

// --- Functions ---
//===================================================================================
// Create the window and all the area for displaying game information
//===================================================================================
function Created() {}
function Tick(float DeltaTime) {}

defaultproperties
{
}
