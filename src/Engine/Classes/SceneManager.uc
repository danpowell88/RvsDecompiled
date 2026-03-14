//=============================================================================
// SceneManager
//
// Manages a matinee scene.  Contains a list of action items that will
// be played out in order.
//=============================================================================
class SceneManager extends Info
    native;

#exec Texture Import File=Textures\SceneManager.pcx  Name=S_SceneManager Mips=Off
#exec Texture Import File=Textures\S_MatineeIP.pcx Name=S_MatineeIP Mips=Off MASKED=1
#exec Texture Import File=Textures\S_MatineeIPSel.pcx Name=S_MatineeIPSel Mips=Off MASKED=1
#exec Texture Import File=Textures\S_MatineeTimeMarker.pcx Name=S_MatineeTimeMarker Mips=Off MASKED=1
#exec Texture Import File=Textures\ActionCamMove.pcx  Name=S_ActionCamMove Mips=Off
#exec Texture Import File=Textures\ActionCamPause.pcx  Name=S_ActionCamPause Mips=Off
#exec Texture Import File=Textures\PathLinear.pcx  Name=S_PathLinear Mips=Off MASKED=1
#exec Texture Import File=Textures\PathBezier.pcx  Name=S_PathBezier Mips=Off MASKED=1
#exec Texture Import File=Textures\S_BezierHandle.pcx  Name=S_BezierHandle Mips=Off MASKED=1
#exec Texture Import File=Textures\SubActionIndicator.pcx  Name=SubActionIndicator Mips=Off MASKED=1

// --- Enums ---
enum EAffect
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Structs ---
struct Orientation
{
	var() ECamOrientation	CamOrientation;
	var() actor LookAt;
	var() float EaseIntime;
	var() int bReversePitch;
	var() int bReverseYaw;
	var() int bReverseRoll;

	var int MA;
	var float PctInStart, PctInEnd, PctInDuration;
	var rotator StartingRotation;
};

struct Interpolator
{
	var() int bDone;
	var() float _value;
	var() float _remainingTime;
	var() float _totalTime;
	var() float _speed;
	var() float _acceleration;
};

// --- Variables ---
// var ? MA; // REMOVED IN 1.60
// var ? PctInDuration; // REMOVED IN 1.60
// var ? StartingRotation; // REMOVED IN 1.60
// The actor viewing this scene (the one being affected by the actions)
var transient Actor Viewer;
// The pawn we need to repossess when scene is over
var transient Pawn OldPawn;
// If TRUE, the scene has been initialized and is running
var transient bool bIsSceneStarted;
var config EAffect Affect;
// ^ NEW IN 1.60
var name PlayerScriptTag;
// ^ NEW IN 1.60
var Actor AffectedActor;
// ^ NEW IN 1.60
// If TRUE, this scene is executing.
var transient bool bIsRunning;
// The total time the scene will take to run (in seconds)
var transient float TotalSceneTime;
// How far away we are from the actor we are locked to
var transient Vector DollyOffset;
// The SubActionCameraShake effect fills this var in each frame
var transient Vector CameraShake;
// Interpolation helper for rotations
var transient Interpolator RotInterpolator;
// The previous orientation that was set
var transient Orientation PrevOrientation;
// The current camera orientation
var transient Orientation CamOrientation;
// The list of sub actions which will execute during this scene
var transient array<array> SubActions;
// Sampled locations for camera movement
var transient array<array> SampleLocations;
// Keeps track of the current time using the DeltaTime passed to Tick
var transient float CurrentTime;
var transient float SceneSpeed;
// The currently executing action
var transient MatAction CurrentAction;
// These vars are set by the SceneManager in it's Tick function.  Don't mess with them directly.
// How much of the scene has finished running
var transient float PctSceneComplete;
//Cached values for display:
//The info string displayed by the preview.
var transient string m_DisplayString;
//If true, the preview will replay the scene
var transient bool m_bPreviewReplay;
var bool m_bFixedPosition;
// ^ NEW IN 1.60
//The previous action,
var transient MatAction m_PreviousAction;
var string m_Alias;
// ^ NEW IN 1.60
var name NextSceneTag;
// ^ NEW IN 1.60
var bool bCinematicView;
// ^ NEW IN 1.60
var bool bLooping;
// ^ NEW IN 1.60
var array<array> Actions;
// ^ NEW IN 1.60

// --- Functions ---
// function ? BeginState(...); // REMOVED IN 1.60
// function ? WaitForTag(...); // REMOVED IN 1.60
// Events
event SceneStarted() {}
//#ifdef R6CODE
event Destroyed() {}
event SceneEnded() {}
function Trigger(Pawn EventInstigator, Actor Other) {}
simulated function BeginPlay() {}
final native function SceneDestroyed() {}
// ^ NEW IN 1.60
final native function TerminateAIAction() {}
// ^ NEW IN 1.60
// Native functions
native function float GetTotalSceneTime() {}
// ^ NEW IN 1.60

defaultproperties
{
}
