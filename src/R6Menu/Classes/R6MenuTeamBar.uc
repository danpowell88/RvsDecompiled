//=============================================================================
//  R6MenuTeamBar.uc : Planning-screen bar containing team selector buttons and team display buttons for switching between the three operative teams.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/28 * Created by Chaouky Garram
//=============================================================================
class R6MenuTeamBar extends UWindowWindow;

// --- Constants ---
const PosX2; // value unavailable in binary
const ButtonWidth = 28;
const SmallWidth = 14;

// --- Variables ---
var R6MenuTeamButton m_ActiveList[3];
var R6MenuTeamDisplayButton m_DisplayList[3];

// --- Functions ---
function Created() {}
function Paint(Canvas C, float X, float Y) {}
function ResetTeams(int iWhatToReset) {}
function SetTeamActive(int iActive) {}
function Reset() {}
function EscClose() {}

defaultproperties
{
}
