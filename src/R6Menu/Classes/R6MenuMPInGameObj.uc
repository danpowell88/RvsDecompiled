//=============================================================================
//  R6MenuMPInGameObj.uc : Window with the Objectives in-game
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/26 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameObj extends R6MenuEscObjectives;

// --- Variables ---
var array<array> m_AObjectives;
var R6WindowWrappedTextArea m_pGreenTeam;
var R6WindowWrappedTextArea m_pRedTeam;
var string m_AAdvLoc[2];

// --- Functions ---
function UpdateObjectives() {}
function SetNewObjWindowSizes(float _W, float _H, float _Y, bool _bCoopType, float _X) {}
// overwrite the fct in R6MenuEscObjectives
function Created() {}
function CreateObjWindow() {}

defaultproperties
{
}
