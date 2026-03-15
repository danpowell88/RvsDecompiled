//=============================================================================
// MatSubAction - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// MatSubAction: Base class for Matinee sub actions.
//
// A Matinee action can have any number of sub actions.  These sub actions
// are executed while the main action is running.
//=============================================================================

#exec Texture Import File=Textures\SubActionFOV.pcx Name=SubActionFOV Mips=Off
#exec Texture Import File=Textures\SubActionTrigger.pcx Name=SubActionTrigger Mips=Off
#exec Texture Import File=Textures\SubActionOrientation.pcx Name=SubActionOrientation Mips=Off
#exec Texture Import File=Textures\SubActionFade.pcx Name=SubActionFade Mips=Off
#exec Texture Import File=Textures\SubActionGameSpeed.pcx Name=SubActionGameSpeed Mips=Off
#exec Texture Import File=Textures\SubActionSceneSpeed.pcx Name=SubActionSceneSpeed Mips=Off
#exec Texture Import File=Textures\SubActionCameraShake.pcx Name=SubActionCameraShake Mips=Off
class MatSubAction extends MatObject
    abstract
    native
	editinlinenew;

enum ESAStatus
{
	SASTATUS_Waiting,               // 0
	SASTATUS_Running,               // 1
	SASTATUS_Ending,                // 2
	SASTATUS_Expired                // 3
};

var MatSubAction.ESAStatus Status;  // The status of this subaction
var(Time) float Delay;  // Seconds before it actually executes
var(Time) float Duration;  // How many seconds it should take to complete
var Texture Icon;  // The icon to use in the matinee UI
//#ifdef R6CODE
var SceneManager m_pSceneManager;  // Pointer to owning SceneManager
var localized string Desc;  // Desc used by the editor and engine stats
var transient float PctStarting;
var transient float PctEnding;
var transient float PctDuration;

event Initialize()
{
	return;
}

defaultproperties
{
	Desc="N/A"
}
