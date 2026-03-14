//=============================================================================
//  R6MenuTimeLineLock.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================
class R6MenuTimeLineLock extends R6WindowButton;

// --- Variables ---
var Region m_ButtonRegions[8];
var bool m_bLocked;

// --- Functions ---
function LMouseDown(float X, float Y) {}
function ResetCameraLock() {}
function Tick(float fDeltaTime) {}
function BeforePaint(float Y, float X, Canvas C) {}
function Created() {}

defaultproperties
{
}
