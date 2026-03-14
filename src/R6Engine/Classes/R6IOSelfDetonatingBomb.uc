//=============================================================================
//  R6IOSelfDetonatingBomb : MissionPAck1
//  Like IOBomb, but it can self-detonate after a given amount of time
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6IOSelfDetonatingBomb extends R6IOBomb;

// --- Variables ---
var float m_fSelfDetonationTime;
// ^ NEW IN 1.60
// defused message shown for 3 secs
var float m_fDefusedTimeMessage;

// --- Functions ---
// function ? ResetOriginalData(...); // REMOVED IN 1.60
simulated function PostRender2(Canvas C) {}
simulated function PostRender(Canvas C) {}
function StartTimer() {}
simulated function Timer() {}

defaultproperties
{
}
