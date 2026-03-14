//=============================================================================
// R6InteractiveObjectAction - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6InteractiveObjectAction.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/16 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObjectAction extends Object
	abstract
	editinlinenew;

enum EActionType
{
	ET_Goto,                        // 0
	ET_PlayAnim,                    // 1
	ET_LookAt,                      // 2
	ET_LoopAnim,                    // 3
	ET_LoopRandomAnim,              // 4
	ET_ToggleDevice                 // 5
};

var R6InteractiveObjectAction.EActionType m_eType;
var(Sound) Sound m_eSoundToPlay;
var(Sound) Sound m_eSoundToPlayStop;
var(Sound) Range m_SoundRange;

defaultproperties
{
	m_SoundRange=(Min=20.0000000,Max=60.0000000)
}
