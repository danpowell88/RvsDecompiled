//=============================================================================
// ScriptedController - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
// ScriptedController
// AI controller which is controlling the pawn through a scripted sequence specified by 
// an AIScript
class ScriptedController extends AIController;

var int ActionNum;
var int AnimsRemaining;
var int NumShots;
var int IterationCounter;
var int IterationSectionStart;
var bool bBroken;
var bool bShootTarget;
var bool bShootSpray;
var bool bPendingShoot;
var bool bFakeShot;  // FIXME - this is currently a hack
var bool bUseScriptFacing;
var Controller PendingController;  // controller which will get this pawn after scripted sequence is complete
var ScriptedSequence SequenceScript;
var LatentScriptedAction CurrentAction;
var Action_PLAYANIM CurrentAnimation;
var Actor ScriptedFocus;
var PlayerController MyPlayerController;
var name FiringMode;

function TakeControlOf(Pawn aPawn)
{
	// End:0x2A
	if(__NFUN_119__(Pawn, aPawn))
	{
		aPawn.PossessedBy(self);
		Pawn = aPawn;
	}
	__NFUN_113__('Scripting');
	return;
}

function SetEnemyReaction(int AlertnessLevel)
{
	return;
}

function DestroyPawn()
{
	// End:0x17
	if(__NFUN_119__(Pawn, none))
	{
		Pawn.__NFUN_279__();
	}
	__NFUN_279__();
	return;
}

function Pawn GetMyPlayer()
{
	// End:0x4A
	if(__NFUN_132__(__NFUN_114__(MyPlayerController, none), __NFUN_114__(MyPlayerController.Pawn, none)))
	{
		// End:0x49
		foreach __NFUN_313__(Class'Engine.PlayerController', MyPlayerController)
		{
			// End:0x48
			if(__NFUN_119__(MyPlayerController.Pawn, none))
			{
				// End:0x49
				break;
			}			
		}		
	}
	// End:0x57
	if(__NFUN_114__(MyPlayerController, none))
	{
		return none;
	}
	return MyPlayerController.Pawn;
	return;
}

function Pawn GetInstigator()
{
	// End:0x11
	if(__NFUN_119__(Pawn, none))
	{
		return Pawn;
	}
	return Instigator;
	return;
}

function Actor GetSoundSource()
{
	// End:0x11
	if(__NFUN_119__(Pawn, none))
	{
		return Pawn;
	}
	return SequenceScript;
	return;
}

function bool CheckIfNearPlayer(float Distance)
{
	local Pawn MyPlayer;

	MyPlayer = GetMyPlayer();
	return __NFUN_130__(__NFUN_130__(__NFUN_119__(MyPlayer, none), __NFUN_176__(__NFUN_225__(__NFUN_216__(Pawn.Location, MyPlayer.Location)), __NFUN_174__(__NFUN_174__(Distance, CollisionRadius), MyPlayer.CollisionRadius))), Pawn.__NFUN_532__());
	return;
}

function SetNewScript(ScriptedSequence NewScript)
{
	MyScript = NewScript;
	SequenceScript = NewScript;
	ActionNum = 0;
	Focus = none;
	CurrentAction = none;
	CurrentAnimation = none;
	ScriptedFocus = none;
	Pawn.SetWalking(false);
	Pawn.ShouldCrouch(false);
	SetEnemyReaction(3);
	SequenceScript.SetActions(self);
	return;
}

function ClearAnimation()
{
	AnimsRemaining = 0;
	bControlAnimations = false;
	CurrentAnimation = none;
	Pawn.PlayWaiting();
	return;
}

function int SetFireYaw(int FireYaw)
{
	FireYaw = __NFUN_156__(FireYaw, 65535);
	// End:0xAD
	if(__NFUN_130__(__NFUN_177__(__NFUN_186__(float(__NFUN_147__(FireYaw, __NFUN_156__(Rotation.Yaw, 65535)))), float(8192)), __NFUN_176__(__NFUN_186__(float(__NFUN_147__(FireYaw, __NFUN_156__(Rotation.Yaw, 65535)))), float(57343))))
	{
		// End:0x96
		if(ClockwiseFrom_IntInt(FireYaw, Rotation.Yaw))
		{
			FireYaw = __NFUN_146__(Rotation.Yaw, 8192);			
		}
		else
		{
			FireYaw = __NFUN_147__(Rotation.Yaw, 8192);
		}
	}
	return FireYaw;
	return;
}

function LeaveScripting()
{
	return;
}

state Scripting
{
	function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
	{
		super(AIController).DisplayDebug(Canvas, YL, YPos);
		Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("AIScript ", string(SequenceScript)), " ActionNum "), string(ActionNum)), false);
		__NFUN_184__(YPos, YL);
		Canvas.__NFUN_2623__(4.0000000, YPos);
		CurrentAction.DisplayDebug(Canvas, YL, YPos);
		return;
	}

	function UnPossess()
	{
		Pawn.UnPossessed();
		// End:0x4C
		if(__NFUN_130__(__NFUN_119__(Pawn, none), __NFUN_119__(PendingController, none)))
		{
			PendingController.bStasis = false;
			PendingController.Possess(Pawn);
		}
		Pawn = none;
		__NFUN_279__();
		return;
	}

	function LeaveScripting()
	{
		UnPossess();
		return;
	}

	function InitForNextAction()
	{
		SequenceScript.SetActions(self);
		// End:0x23
		if(__NFUN_114__(CurrentAction, none))
		{
			LeaveScripting();
			return;
		}
		MyScript = SequenceScript;
		// End:0x3F
		if(__NFUN_114__(CurrentAnimation, none))
		{
			ClearAnimation();
		}
		return;
	}

	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x18
		if(CurrentAction.CompleteWhenTriggered())
		{
			CompleteAction();
		}
		return;
	}

	function Timer()
	{
		// End:0x35
		if(__NFUN_130__(CurrentAction.WaitForPlayer(), CheckIfNearPlayer(CurrentAction.GetDistance())))
		{
			CompleteAction();			
		}
		else
		{
			// End:0x4D
			if(CurrentAction.CompleteWhenTimer())
			{
				CompleteAction();
			}
		}
		return;
	}

	function AnimEnd(int Channel)
	{
		// End:0x1F
		if(CurrentAction.CompleteOnAnim(Channel))
		{
			CompleteAction();
			return;
		}
		// End:0x56
		if(__NFUN_154__(Channel, 0))
		{
			// End:0x53
			if(__NFUN_132__(__NFUN_114__(CurrentAnimation, none), __NFUN_129__(CurrentAnimation.PawnPlayBaseAnim(self, false))))
			{
				ClearAnimation();
			}			
		}
		else
		{
			Pawn.AnimEnd(Channel);
		}
		return;
	}

	function CompleteAction()
	{
		__NFUN_165__(ActionNum);
		__NFUN_113__('Scripting', 'Begin');
		return;
	}

	function SetMoveTarget()
	{
		local Actor NextMoveTarget;

		Focus = ScriptedFocus;
		NextMoveTarget = CurrentAction.GetMoveTargetFor(self);
		// End:0x35
		if(__NFUN_114__(NextMoveTarget, none))
		{
			__NFUN_113__('Broken');
			return;
		}
		// End:0x4B
		if(__NFUN_114__(Focus, none))
		{
			Focus = NextMoveTarget;
		}
		MoveTarget = NextMoveTarget;
		// End:0x9E
		if(__NFUN_129__(__NFUN_520__(MoveTarget)))
		{
			MoveTarget = __NFUN_517__(MoveTarget);
			// End:0x84
			if(__NFUN_114__(MoveTarget, none))
			{
				AbortScript();
				return;
			}
			// End:0x9E
			if(__NFUN_114__(Focus, NextMoveTarget))
			{
				Focus = MoveTarget;
			}
		}
		return;
	}

	function AbortScript()
	{
		LeaveScripting();
		return;
	}

	function Tick(float DeltaTime)
	{
		// End:0x17
		if(bPendingShoot)
		{
			bPendingShoot = false;
			MayShootTarget();
		}
		// End:0x52
		if(__NFUN_130__(__NFUN_129__(bPendingShoot), __NFUN_132__(__NFUN_114__(CurrentAction, none), __NFUN_129__(CurrentAction.StillTicking(self, DeltaTime)))))
		{
			__NFUN_118__('Tick');
		}
		return;
	}

	function MayShootTarget()
	{
		return;
	}

	function EndState()
	{
		bUseScriptFacing = true;
		bFakeShot = false;
		return;
	}
Begin:

	InitForNextAction();
	// End:0x16
	if(bBroken)
	{
		__NFUN_113__('Broken');
	}
	// End:0x2F
	if(CurrentAction.TickedAction())
	{
		__NFUN_117__('Tick');
	}
	// End:0x4D
	if(__NFUN_129__(bShootTarget))
	{
		bFire = 0;
		bAltFire = 0;		
	}
	else
	{
		// End:0x5C
		if(bShootSpray)
		{
			MayShootTarget();
		}
	}
	// End:0xFA
	if(CurrentAction.MoveToGoal())
	{
		Pawn.SetMovementPhysics();
		__NFUN_527__();
KeepMoving:


		SetMoveTarget();
		MayShootTarget();
		__NFUN_502__(MoveTarget, Focus,,,, Pawn.bIsWalking);
		// End:0xF1
		if(__NFUN_132__(__NFUN_119__(MoveTarget, CurrentAction.GetMoveTargetFor(self)), __NFUN_129__(Pawn.ReachedDestination(CurrentAction.GetMoveTargetFor(self)))))
		{
			goto 'KeepMoving';
		}
		CompleteAction();		
	}
	else
	{
		// End:0x177
		if(CurrentAction.TurnToGoal())
		{
			Pawn.SetMovementPhysics();
			Focus = CurrentAction.GetMoveTargetFor(self);
			// End:0x16B
			if(__NFUN_114__(Focus, none))
			{
				FocalPoint = __NFUN_215__(Pawn.Location, __NFUN_213__(float(1000), Vector(SequenceScript.Rotation)));
			}
			__NFUN_508__();
			CompleteAction();			
		}
		else
		{
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			Focus = ScriptedFocus;
			// End:0x1DB
			if(__NFUN_129__(bUseScriptFacing))
			{
				FocalPoint = __NFUN_215__(Pawn.Location, __NFUN_213__(float(1000), Vector(Pawn.Rotation)));				
			}
			else
			{
				// End:0x21B
				if(__NFUN_114__(Focus, none))
				{
					MayShootAtEnemy();
					FocalPoint = __NFUN_215__(Pawn.Location, __NFUN_213__(float(1000), Vector(SequenceScript.Rotation)));
				}
			}
			__NFUN_508__();
			MayShootTarget();
		}
	}
	stop;			
}

state Broken
{Begin:

	__NFUN_232__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(string(Pawn), " Scripted Sequence BROKEN "), string(SequenceScript)), " ACTION "), string(CurrentAction)));
	Pawn.bPhysicsAnimUpdate = false;
	Pawn.StopAnimating();
	// End:0x94
	if(__NFUN_119__(GetMyPlayer(), none))
	{
		PlayerController(GetMyPlayer().Controller).SetViewTarget(Pawn);
	}
	stop;			
}

defaultproperties
{
	IterationSectionStart=-1
	bUseScriptFacing=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function AdjustAim
// REMOVED IN 1.60: function WeaponFireAgain
// REMOVED IN 1.60: function MayShootAtEnemy
