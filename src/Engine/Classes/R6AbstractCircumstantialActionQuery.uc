//=============================================================================
//  R6CircumstantialActionQuery.uc : describes action that can be performed on an actor
//                                  originally stCircumstantialActionQuery
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/05 * Created by Aristomenis Kolokathis
//=============================================================================
class R6AbstractCircumstantialActionQuery extends Actor
    native
    nativereplication;

// --- Variables ---
// Actions Ids for the team action submenus (0-3 are subactions for menu action 0, 4-7 are subaction for menu action 1, ...)
var /* replicated */ byte iTeamSubActionsIDList[16];
// Actor targeted (actor possessing the actions)
var /* replicated */ Actor aQueryTarget;
// Is the CA Initialized ?
var /* replicated */ byte iHasAction;
// Time required for the player to start the action (with base skill) - Skill should affect this value
var /* replicated */ float fPlayerActionTimeRequired;
// Is this action interruptible
var /* replicated */ bool bCanBeInterrupted;
// Action ID selected from the rose des vents sub menu
var int iSubMenuChoice;
// Action ID selected from the rose des vents menu
var int iMenuChoice;
// Is this action is in range ?
var /* replicated */ byte iInRange;
// Actor who made the query (usually the player pawn)
var /* replicated */ Actor aQueryOwner;
// Action list - Refer to ID that should be define in the aQueryTarget class
// Action ID for the player action
var /* replicated */ byte iPlayerActionID;
// Action ID for the team action
var byte iTeamActionID;
// Actions IDs for the team action menu
var /* replicated */ byte iTeamActionIDList[4];
// Icon associated with this actor action
var /* replicated */ Texture textureIcon;
// How long the action key has been pressed
var float m_fPressedTime;

// --- Functions ---
simulated function ResetOriginalData() {}
function PostBeginPlay() {}

defaultproperties
{
}
