//=============================================================================
// MatObject - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// MatObject
//
// A base class for all Matinee classes.  Just a convenient place to store
// common elements like enums.
//=============================================================================
class MatObject extends Object
	abstract
 native;

struct Orientation
{
	var() Object.ECamOrientation CamOrientation;
	var() Actor LookAt;
	var() float EaseIntime;
	var() int bReversePitch;
	var() int bReverseYaw;
	var() int bReverseRoll;
	var int MA;
	var float PctInStart;
// NEW IN 1.60
	var float PctInEnd;
// NEW IN 1.60
	var float PctInDuration;
	var Rotator StartingRotation;
};


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var d
// REMOVED IN 1.60: var n
