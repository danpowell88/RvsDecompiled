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
class R6IOSlidingWindow extends R6IActionObject;

#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons

// --- Enums ---
enum EOpeningSide{ Top,Bottom, Left, Right};
enum eWindowCircumstantialAction
{
    CA_None,
    CA_Open,
    CA_Close,
	CA_Climb,
	CA_Grenade,
	CA_OpenAndGrenade,

	// Grenade sub menu
	CA_GrenadeFrag,
	CA_GrenadeGas,
	CA_GrenadeFlash,
	CA_GrenadeSmoke
};

// --- Variables ---
var float m_TotalMovement;
var int m_iInitialOpening;        // Initial open position of the window (0 = closed, 100 = fully open)
// ^ NEW IN 1.60
var float m_iMaxOpening;          // Maximum travel distance of the sliding window panel
// ^ NEW IN 1.60
var bool m_bIsWindowLocked;       // True when the window is locked and cannot be slid open
// ^ NEW IN 1.60
//Is the window Locked
var bool sm_bIsWindowLocked;
var EOpeningSide eOpening;        // Which side the window slides open toward (left/right/up/down)
// ^ NEW IN 1.60
var int sm_iInitialOpening;
var Vector sm_Location;
//Is the door open or not
var bool m_bIsWindowClosed;
	// Grenade sub menu
var float C_fWindowOpen;

// --- Functions ---
function bool startAction(Actor actionInstigator, float fDeltaMouse) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
function R6FillGrenadeSubAction(out R6AbstractCircumstantialActionQuery Query, int iSubMenu, PlayerController PlayerController) {}
function bool updateAction(float fDeltaMouse, Actor actionInstigator) {}
// ^ NEW IN 1.60
event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController, float fDistance) {}
//------------------------------------------------------------------
// SaveOriginalData
//
//------------------------------------------------------------------
simulated function SaveOriginalData() {}
function endAction() {}

defaultproperties
{
}
