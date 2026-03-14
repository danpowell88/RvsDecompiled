//=============================================================================
//  Ladder.uc : invisible actor used to mark the top and bottom of a ladder
//              (navigation point)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/06/05 * Created by Rima Brek
//=============================================================================
class R6Ladder extends Ladder
    native
    notplaceable;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

// --- Variables ---
var /* replicated */ bool m_bIsTopOfLadder;
// ^ NEW IN 1.60
var R6Ladder m_pOtherFloor;
var bool bShowLog;
var bool m_bSingleFileFormationOnly;
// ^ NEW IN 1.60

// --- Functions ---
//used for initial detection for exiting a ladder - for animation playing purposes...
simulated function Touch(Actor Other) {}
event bool SuggestMovePreparation(Pawn Other) {}
// ^ NEW IN 1.60

defaultproperties
{
}
