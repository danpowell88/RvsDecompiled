//=============================================================================
//  R6SoundInstructionVolume.uc : Use for the player in the map training.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/06/20 * Created by Serge Dore
//============================================================================//
class R6InstructionSoundVolume extends R6SoundVolume
    native;

// --- Constants ---
const TimeBetweenStep =  15;

// --- Variables ---
var int m_iSoundIndex;
// ID for display many thing on the HUD.
var int m_IDHudStep;
// Time get in the INT file.
var float m_fTimeHud;
// Current Step hud for internal use only
var int m_iHudStep;
var R6TrainingMgr m_TrainingMgr;
var int m_iBoxNumber;
var bool m_bSoundIsPlaying;
var Sound m_sndIntructionSoundStop;
// use for wait 1 sec to not call IsSoundPlaying at each trame
var float m_fTime;
// When no sound use the timer
var int m_fTimerStep;
// Currently time for the sound
var float m_fTimerSound;

// --- Functions ---
simulated event Touch(Actor Other) {}
simulated event UnTouch(Actor Other) {}
function Tick(float DeltaTime) {}
function SetHudStep() {}
function ReadyToChangeText() {}
function ChangeTextAndSound() {}
function StopInstruction() {}
function SkipToNextInstruction() {}
simulated function ResetOriginalData() {}
final native function bool UseSound() {}
// ^ NEW IN 1.60

defaultproperties
{
}
