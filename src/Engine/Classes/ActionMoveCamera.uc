//=============================================================================
// ActionMoveCamera - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ActionMoveCamera:
//
// Moves the camera to a specified interpolation point.
//=============================================================================
class ActionMoveCamera extends MatAction
	native
 config;

enum EPathStyle
{
	PATHSTYLE_Linear,               // 0
	PATHSTYLE_Bezier                // 1
};

// NEW IN 1.60
var(Path) config ActionMoveCamera.EPathStyle PathStyle;

defaultproperties
{
	Icon=Texture'Engine.ActionCamMoveIcon'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var EPathStyle
