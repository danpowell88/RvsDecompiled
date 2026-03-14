//=============================================================================
//  R6IODevice : This should allow action moves on a Recon type device
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6IODevice extends R6IOObject;

// --- Variables ---
var float m_fPlantTimeMin;
// ^ NEW IN 1.60
var float m_fPlantTimeMax;
// ^ NEW IN 1.60
var bool bShowLog;
// ^ NEW IN 1.60
var Sound m_PhoneBuggingStopSnd;
var Texture m_InteractionIcon;
// ^ NEW IN 1.60
var array<array> m_ArmedTextures;
// ^ NEW IN 1.60
var Sound m_PhoneBuggingSnd;
var Vector m_vOffset;

// --- Functions ---
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60
simulated event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController, float fDistance) {}
simulated function float GetTimeRequired(R6Pawn aPawn) {}
// ^ NEW IN 1.60
simulated function ToggleDevice(R6Pawn aPawn) {}
simulated function bool HasKit(R6Pawn aPawn) {}
// ^ NEW IN 1.60
function PostBeginPlay() {}
simulated function float GetMaxTimeRequired() {}
// ^ NEW IN 1.60

defaultproperties
{
}
