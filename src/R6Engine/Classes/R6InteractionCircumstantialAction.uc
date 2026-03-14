//=============================================================================
//  R6InteractionCircumstantialAction.uc : Interaction associated with the inventory.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by S�bastien Lussier
//=============================================================================
class R6InteractionCircumstantialAction extends R6InteractionRoseDesVents;

#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons
#exec OBJ LOAD FILE=..\Textures\R6HUD.utx PACKAGE=R6HUD
#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

// --- Enums ---
enum eCircumstantialActionPerformer
{
    CACTION_Player,
    CACTION_Team,
    CACTION_TeamFromList,
    CACTION_TeamFromListZulu,
};

// --- Variables ---
var Texture m_TexProgressItem;
var Texture m_TexProgressCircle;
var Texture m_TexFakeReticule;
var Font m_SmallFont_14pt;

// --- Functions ---
function PerformCircumstantialAction(eCircumstantialActionPerformer ePerformer) {}
function bool IsValidMenuChoice(int iChoice) {}
// ^ NEW IN 1.60
function bool ItemHasSubMenu(int iItem) {}
// ^ NEW IN 1.60
function bool CurrentItemHasSubMenu() {}
// ^ NEW IN 1.60
function SetMenuChoice(int iChoice) {}
simulated function bool MenuItemEnabled(int iItem) {}
// ^ NEW IN 1.60
function DrawGotoSpectatorModeIcon(Canvas C) {}
function PostRender(Canvas C) {}
//===========================================================================//
// DrawActionProgress()                                                      //
//===========================================================================//
function DrawActionProgress(Canvas C, float fProgress) {}
function DrawSpectatorReticule(Canvas C) {}
//===========================================================================//
// SetPosAndDrawActionProgress()                                                       //
//===========================================================================//
function SetPosAndDrawActionProgress(Canvas C) {}
function DrawDeadCircumstantialIcon(Canvas C) {}
//===========================================================================//
// DrawTeamActionMnu()                                                       //
//===========================================================================//
function DrawTeamActionMnu(Canvas C, R6CircumstantialActionQuery Query) {}
//===========================================================================//
// DrawCircumstantialActionInfo()                                            //
//  Draw circumstantial action stuff, like the rose des vents and the action //
//  icon if there is one.                                                    //
//===========================================================================//
function DrawCircumstantialActionInfo(Canvas C) {}
event Initialized() {}
function ActionKeyPressed() {}
// Action button was released
function ActionKeyReleased() {}
function GotoSubMenu() {}
function NoItemSelected() {}
function ItemClicked(int iItem) {}
function ItemRightClicked(int iItem) {}
///////////////////////////////////////////////////////////////////////////////
// ActionProgressStart()
///////////////////////////////////////////////////////////////////////////////
function ActionProgressStart() {}
///////////////////////////////////////////////////////////////////////////////
// ActionProgressStop()
///////////////////////////////////////////////////////////////////////////////
function ActionProgressStop() {}
///////////////////////////////////////////////////////////////////////////////
// ActionProgressDone()
///////////////////////////////////////////////////////////////////////////////
function ActionProgressDone() {}

state ActionProgress
{
    function bool KeyEvent(EInputAction eAction, EInputKey eKey, float fDelta) {}
// ^ NEW IN 1.60
}

defaultproperties
{
}
