//=============================================================================
// ActionMoveCamera:
//
// Moves the camera to a specified interpolation point.
//=============================================================================
class ActionMoveCamera extends MatAction
    native;

#exec Texture Import File=Textures\ActionCamMove.pcx Name=ActionCamMoveIcon Mips=Off

// --- Enums ---
enum EPathStyle
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var config EPathStyle PathStyle;

defaultproperties
{
}
