//=============================================================================
//  R6InteractiveObjectAction.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/16 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObjectAction extends Object
    abstract;

// --- Enums ---
enum EActionType
{
    ET_Goto,
    ET_PlayAnim,
    ET_LookAt,
    ET_LoopAnim,
    ET_LoopRandomAnim,
    ET_ToggleDevice
};

// --- Variables ---
var Sound m_eSoundToPlay;         // Sound played when this action begins
// ^ NEW IN 1.60
var Range m_SoundRange;           // Volume/pitch variation range for the action sound
// ^ NEW IN 1.60
var Sound m_eSoundToPlayStop;     // Sound played when this action ends
// ^ NEW IN 1.60
var EActionType m_eType;

defaultproperties
{
}
