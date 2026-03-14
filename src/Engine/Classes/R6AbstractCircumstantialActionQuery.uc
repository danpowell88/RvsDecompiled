//=============================================================================
// R6AbstractCircumstantialActionQuery - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
	nativereplication
 notplaceable;

var byte iHasAction;  // Is the CA Initialized ?
var byte iInRange;  // Is this action is in range ?
// Action list - Refer to ID that should be define in the aQueryTarget class
var byte iPlayerActionID;  // Action ID for the player action
var byte iTeamActionID;  // Action ID for the team action
var byte iTeamActionIDList[4];  // Actions IDs for the team action menu
var byte iTeamSubActionsIDList[16];  // Actions Ids for the team action submenus (0-3 are subactions for menu action 0, 4-7 are subaction for menu action 1, ...)
var int iMenuChoice;  // Action ID selected from the rose des vents menu
var int iSubMenuChoice;  // Action ID selected from the rose des vents sub menu
var bool bCanBeInterrupted;  // Is this action interruptible
var float fPlayerActionTimeRequired;  // Time required for the player to start the action (with base skill) - Skill should affect this value
var float m_fPressedTime;  // How long the action key has been pressed
var Actor aQueryOwner;  // Actor who made the query (usually the player pawn)
var Actor aQueryTarget;  // Actor targeted (actor possessing the actions)
var Texture textureIcon;  // Icon associated with this actor action

replication
{
	// Pos:0x000
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		aQueryOwner, aQueryTarget, 
		bCanBeInterrupted, fPlayerActionTimeRequired, 
		iHasAction, iInRange, 
		iPlayerActionID, iTeamActionIDList, 
		iTeamSubActionsIDList, textureIcon;
}

simulated function ResetOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super.ResetOriginalData();
	aQueryTarget = none;
	iHasAction = 0;
	bCanBeInterrupted = false;
	fPlayerActionTimeRequired = 0.0000000;
	iMenuChoice = -1;
	iSubMenuChoice = -1;
	return;
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	return;
}

defaultproperties
{
	RemoteRole=2
	DrawType=0
	bHidden=true
}
