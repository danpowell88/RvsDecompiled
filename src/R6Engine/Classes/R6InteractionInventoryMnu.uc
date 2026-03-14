//=============================================================================
//  R6InteractionInventoryMnu.uc : Interaction associated with the inventory.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by S�bastien Lussier
//=============================================================================
class R6InteractionInventoryMnu extends R6InteractionRoseDesVents;

// --- Functions ---
function ItemClicked(int iItem) {}
function PostRender(Canvas C) {}
function bool IsValidMenuChoice(int iChoice) {}
// ^ NEW IN 1.60
function SetMenuChoice(int iChoice) {}
//===========================================================================//
// DrawInventoryMenu()                                                       //
//===========================================================================//
function DrawInventoryMenu(Canvas C) {}
function ActionKeyPressed() {}

defaultproperties
{
}
