//=============================================================================
//  R6MenuTimeLinePlay.uc : Play/pause button for the mission planning timeline; begins or halts animated playback of the planned operative routes.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================
class R6MenuTimeLinePlay extends R6WindowButton;

// --- Variables ---
var Region m_ButtonRegions[8];
var bool m_bPlaying;

// --- Functions ---
function LMouseDown(float X, float Y) {}
function StopPlaying() {}
function StartPlaying() {}
function BeforePaint(float Y, float X, Canvas C) {}
function Created() {}

defaultproperties
{
}
