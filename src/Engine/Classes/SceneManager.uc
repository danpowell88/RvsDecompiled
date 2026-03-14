//=============================================================================
// SceneManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// SceneManager
//
// Manages a matinee scene.  Contains a list of action items that will
// be played out in order.
//=============================================================================
class SceneManager extends Info
	native
	config
	placeable
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

enum EAffect
{
	AFFECT_ViewportCamera,          // 0
	AFFECT_Actor                    // 1
};

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

struct Interpolator
{
	var() int bDone;
	var() float _value;
	var() float _remainingTime;
	var() float _totalTime;
	var() float _speed;
	var() float _acceleration;
};

// NEW IN 1.60
var() config SceneManager.EAffect Affect;
var() bool bLooping;  // If this is TRUE, the path will looping endlessly
var() bool bCinematicView;  // Should the screen go into letterbox mode when playing this scene?
var(R6Scene) bool m_bFixedPosition;  // If true, the intPoints dont affect the Actor
var() Actor AffectedActor;  // The name of the actor which will follow the matinee path (if Affect==AFFECT_Actor)
var() name PlayerScriptTag;  // Tag of sequence that player's pawn should use during sequence
var() name NextSceneTag;  // The tag of the next scenemanager to execute when this one finishes
// Exposed vars
var() export editinline array<export editinline MatAction> Actions;
var(R6Scene) string m_Alias;  // Used for display in the Matinee Dialog
var transient bool m_bPreviewReplay;  // If true, the preview will replay the scene
var transient bool bIsRunning;  // If TRUE, this scene is executing.
var transient bool bIsSceneStarted;  // If TRUE, the scene has been initialized and is running
// These vars are set by the SceneManager in it's Tick function.  Don't mess with them directly.
var transient float PctSceneComplete;  // How much of the scene has finished running
var transient float SceneSpeed;
var transient float TotalSceneTime;  // The total time the scene will take to run (in seconds)
var transient float CurrentTime;  // Keeps track of the current time using the DeltaTime passed to Tick
var transient MatAction m_PreviousAction;  // The previous action,
var transient MatAction CurrentAction;  // The currently executing action
var transient Actor Viewer;  // The actor viewing this scene (the one being affected by the actions)
var transient Pawn OldPawn;  // The pawn we need to repossess when scene is over
var transient array<Vector> SampleLocations;  // Sampled locations for camera movement
var transient array<MatSubAction> SubActions;  // The list of sub actions which will execute during this scene
var transient Orientation CamOrientation;
var transient Orientation PrevOrientation;  // The previous orientation that was set
var transient Interpolator RotInterpolator;  // Interpolation helper for rotations
var transient Vector CameraShake;  // The SubActionCameraShake effect fills this var in each frame
var transient Vector DollyOffset;  // How far away we are from the actor we are locked to
//Cached values for display:
var transient string m_DisplayString;  // The info string displayed by the preview.

// Export USceneManager::execGetTotalSceneTime(FFrame&, void* const)
// Native functions
 native function float GetTotalSceneTime();

// Export USceneManager::execTerminateAIAction(FFrame&, void* const)
//#ifdef R6CODE
 native(2906) final function TerminateAIAction();

// Export USceneManager::execSceneDestroyed(FFrame&, void* const)
 native(2909) final function SceneDestroyed();

simulated function BeginPlay()
{
	super(Actor).BeginPlay();
	// End:0x4D
	if(__NFUN_130__(__NFUN_154__(int(Affect), int(1)), __NFUN_114__(AffectedActor, none)))
	{
		__NFUN_231__("SceneManager : Affected actor is NULL!");
	}
	TotalSceneTime = GetTotalSceneTime();
	bIsRunning = false;
	bIsSceneStarted = false;
	return;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	bIsRunning = true;
	bIsSceneStarted = false;
	__NFUN_118__('Trigger');
	return;
}

// Events
event SceneStarted()
{
	local Controller P;
	local AIScript S;

	Viewer = none;
	// End:0x25
	if(__NFUN_154__(int(Affect), int(1)))
	{
		Viewer = AffectedActor;		
	}
	else
	{
		P = Level.ControllerList;
		J0x39:

		// End:0x1C4 [Loop If]
		if(__NFUN_119__(P, none))
		{
			__NFUN_231__("for PlayerController");
			// End:0x1AD
			if(__NFUN_130__(P.__NFUN_303__('PlayerController'), __NFUN_119__(P.Pawn, none)))
			{
				__NFUN_231__("Is a Player Controller");
				Viewer = P;
				OldPawn = PlayerController(Viewer).Pawn;
				// End:0x177
				if(__NFUN_119__(OldPawn, none))
				{
					OldPawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
					OldPawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
					PlayerController(Viewer).InitMatineeCamera();
					PlayerController(Viewer).UnPossess();
					// End:0x177
					if(__NFUN_255__(PlayerScriptTag, 'None'))
					{
						// End:0x157
						foreach __NFUN_313__(Class'Engine.AIScript', S, PlayerScriptTag)
						{
							// End:0x157
							break;							
						}						
						// End:0x177
						if(__NFUN_119__(S, none))
						{
							S.TakeOver(OldPawn);
						}
					}
				}
				PlayerController(Viewer).StartInterpolation();
				PlayerController(Viewer).myHUD.bHideHUD = true;
				// [Explicit Break]
				goto J0x1C4;
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x39;
		}
	}
	J0x1C4:

	return;
}

event SceneEnded()
{
	bIsSceneStarted = false;
	// End:0x7F
	if(__NFUN_154__(int(Affect), int(0)))
	{
		PlayerController(Viewer).EndMatineeCamera();
		// End:0x7F
		if(__NFUN_119__(PlayerController(Viewer), none))
		{
			// End:0x60
			if(__NFUN_119__(OldPawn, none))
			{
				PlayerController(Viewer).Possess(OldPawn);
			}
			PlayerController(Viewer).myHUD.bHideHUD = false;
		}
	}
	Viewer.FinishedInterpolation();
	__NFUN_117__('Trigger');
	return;
}

//#ifdef R6CODE
event Destroyed()
{
	__NFUN_231__("SceneManager DESTROYED");
	__NFUN_2909__();
	return;
}

defaultproperties
{
	m_Alias="SceneManager"
	Texture=Texture'Engine.S_SceneManager'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var d
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var EAffect
// REMOVED IN 1.60: var eSceneState
// REMOVED IN 1.60: function WaitForTag
// REMOVED IN 1.60: function BeginState
