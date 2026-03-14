//=============================================================================
//  R6SoundVolume.uc : This class allow to have sound when the player enter 
//					   and leave a Volume.  All other volume should derive this
//                     class in order to allow sound designer to reuse other 
//                     volume already placed by a level designer
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/01/13 * Created by Eric Begin
//============================================================================//
class R6SoundVolume extends Volume
    native;

// --- Variables ---
var array<array> m_EntrySound;
var ESoundSlot m_eSoundSlot;
var array<array> m_ExitSound;

// --- Functions ---
simulated event Touch(Actor Other) {}
simulated event UnTouch(Actor Other) {}

defaultproperties
{
}
