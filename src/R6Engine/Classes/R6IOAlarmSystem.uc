//=============================================================================
//  R6IODevice : This should allow action moves on a Recon type device
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6IOAlarmSystem extends R6IODevice;

// --- Variables ---
var Material m_DisarmedTexture;
var Sound m_DisarmingSound;

// --- Functions ---
simulated function ToggleDevice(R6Pawn aPawn) {}
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60

defaultproperties
{
}
