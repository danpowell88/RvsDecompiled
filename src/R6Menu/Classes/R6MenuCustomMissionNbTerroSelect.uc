//=============================================================================
//  R6MenuCustomMissionNbTerroSelect.uc : Select Terro Count
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/24 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCustomMissionNbTerroSelect extends UWindowDialogClientWindow
    config(USER);

// --- Variables ---
var R6WindowTextLabel m_TitleNbTerro;
var R6WindowCounter m_TerroCounter;
var config int CustomMissionNbTerro;
var const int c_iNbTerroMin;
var const int c_iNbTerroMax;
var float m_fLabelHeight;

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}
function int GetNbTerro() {}
// ^ NEW IN 1.60
function Created() {}

defaultproperties
{
}
