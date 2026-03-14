//=============================================================================
// MatSubAction: Base class for Matinee sub actions.
//
// A Matinee action can have any number of sub actions.  These sub actions
// are executed while the main action is running.
//=============================================================================
class MatSubAction extends MatObject
    native
    abstract;

#exec Texture Import File=Textures\SubActionFOV.pcx Name=SubActionFOV Mips=Off
#exec Texture Import File=Textures\SubActionTrigger.pcx Name=SubActionTrigger Mips=Off
#exec Texture Import File=Textures\SubActionOrientation.pcx Name=SubActionOrientation Mips=Off
#exec Texture Import File=Textures\SubActionFade.pcx Name=SubActionFade Mips=Off
#exec Texture Import File=Textures\SubActionGameSpeed.pcx Name=SubActionGameSpeed Mips=Off
#exec Texture Import File=Textures\SubActionSceneSpeed.pcx Name=SubActionSceneSpeed Mips=Off
#exec Texture Import File=Textures\SubActionCameraShake.pcx Name=SubActionCameraShake Mips=Off

// --- Enums ---
enum ESAStatus
{
	SASTATUS_Waiting,	// Waiting to execute
	SASTATUS_Running,	// Is currently executing
	SASTATUS_Ending,	// Is one tick away from expiring
	SASTATUS_Expired,	// Has executed and finished (ignore for rest of scene)
};

// --- Variables ---
var float Delay;
// ^ NEW IN 1.60
var float Duration;
// ^ NEW IN 1.60
// The icon to use in the matinee UI
var Texture Icon;
// The status of this subaction
var ESAStatus Status;
// Desc used by the editor and engine stats
var localized string Desc;
var transient float PctStarting;
var transient float PctEnding;
var transient float PctDuration;
//#ifdef R6CODE
//Pointer to owning SceneManager
var SceneManager m_pSceneManager;

// --- Functions ---
event Initialize() {}

defaultproperties
{
}
