//=============================================================================
//  R6MenuDiffCustomMissionSelect.uc : Little Area where you select
//										the custom mission difficulty level
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/29 * Created by Alexandre Dionne
//=============================================================================
class R6MenuDiffCustomMissionSelect extends UWindowDialogClientWindow
    config(USER);

// --- Variables ---
var R6WindowButtonBox m_pButLastSel;
var R6WindowButtonBox m_pButLevel2;
var R6WindowButtonBox m_pButLevel3;
var R6WindowButtonBox m_pButLevel1;
var config int CustomMissionDifficultyLevel;
//this can be used to skip auto save
var bool m_bAutoSave;

// --- Functions ---
//We should receive 1, 2 or 3
function SetDifficulty(int iDifficulty_) {}
function Notify(UWindowDialogControl C, byte E) {}
function Created() {}
function int GetDifficulty() {}
// ^ NEW IN 1.60

defaultproperties
{
}
