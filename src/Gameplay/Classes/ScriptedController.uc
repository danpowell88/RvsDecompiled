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
	if((Pawn != aPawn))
	{
		aPawn.PossessedBy(self);
		Pawn = aPawn;
	}
	GotoState('Scripting');
	return;
}

function SetEnemyReaction(int AlertnessLevel)
{
	return;
}

function DestroyPawn()
{
	// End:0x17
	if((Pawn != none))
	{
		Pawn.Destroy();
	}
	Destroy();
	return;
}

function Pawn GetMyPlayer()
{
	// End:0x4A
	if(((MyPlayerController == none) || (MyPlayerController.Pawn == none)))
	{
		// End:0x49
		foreach DynamicActors(Class'Engine.PlayerController', MyPlayerController)
		{
			// End:0x48
			if((MyPlayerController.Pawn != none))
			{
				// End:0x49
				break;
			}			
		}		
	}
	// End:0x57
	if((MyPlayerController == none))
	{
		return none;
	}
	return MyPlayerController.Pawn;
	return;
}

function Pawn GetInstigator()
{
	// End:0x11
	if((Pawn != none))
	{
		return Pawn;
	}
	return Instigator;
	return;
}

function Actor GetSoundSource()
{
	// End:0x11
	if((Pawn != none))
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
	return (((MyPlayer != none) && (VSize((Pawn.Location - MyPlayer.Location)) < ((Distance + CollisionRadius) + MyPlayer.CollisionRadius))) && Pawn.PlayerCanSeeMe());
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
	FireYaw = (FireYaw & 65535);
	// End:0xAD
	if(((Abs(float((FireYaw - (Rotation.Yaw & 65535)))) > float(8192)) && (Abs(float((FireYaw - (Rotation.Yaw & 65535)))) < float(57343))))
	{
		// End:0x96
		if(ClockwiseFrom_IntInt(FireYaw, Rotation.Yaw))
		{
			FireYaw = (Rotation.Yaw + 8192);			
		}
		else
		{
			FireYaw = (Rotation.Yaw - 8192);
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
		Canvas.DrawText(((("AIScript " $ string(SequenceScript)) $ " ActionNum ") $ string(ActionNum)), false);
		(YPos += YL);
		Canvas.SetPos(4.0000000, YPos);
		CurrentAction.DisplayDebug(Canvas, YL, YPos);
		return;
	}

	function UnPossess()
	{
		Pawn.UnPossessed();
		// End:0x4C
		if(((Pawn != none) && (PendingController != none)))
		{
			PendingController.bStasis = false;
			PendingController.Possess(Pawn);
		}
		Pawn = none;
		Destroy();
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
		if((CurrentAction == none))
		{
			LeaveScripting();
			return;
		}
		MyScript = SequenceScript;
		// End:0x3F
		if((CurrentAnimation == none))
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
		if((CurrentAction.WaitForPlayer() && CheckIfNearPlayer(CurrentAction.GetDistance())))
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
		if((Channel == 0))
		{
			// End:0x53
			if(((CurrentAnimation == none) || (!CurrentAnimation.PawnPlayBaseAnim(self, false))))
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
		(ActionNum++);
		GotoState('Scripting', 'Begin');
		return;
	}

	function SetMoveTarget()
	{
		local Actor NextMoveTarget;

		Focus = ScriptedFocus;
		NextMoveTarget = CurrentAction.GetMoveTargetFor(self);
		// End:0x35
		if((NextMoveTarget == none))
		{
			GotoState('Broken');
			return;
		}
		// End:0x4B
		if((Focus == none))
		{
			Focus = NextMoveTarget;
		}
		MoveTarget = NextMoveTarget;
		// End:0x9E
		if((!actorReachable(MoveTarget)))
		{
			MoveTarget = FindPathToward(MoveTarget);
			// End:0x84
			if((MoveTarget == none))
			{
				AbortScript();
				return;
			}
			// End:0x9E
			if((Focus == NextMoveTarget))
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
		if(((!bPendingShoot) && ((CurrentAction == none) || (!CurrentAction.StillTicking(self, DeltaTime)))))
		{
			Disable('Tick');
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
		GotoState('Broken');
	}
	// End:0x2F
	if(CurrentAction.TickedAction())
	{
		Enable('Tick');
	}
	// End:0x4D
	if((!bShootTarget))
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
		WaitForLanding();
KeepMoving:


		SetMoveTarget();
		MayShootTarget();
		MoveToward(MoveTarget, Focus,,,, Pawn.bIsWalking);
		// End:0xF1
		if(((MoveTarget != CurrentAction.GetMoveTargetFor(self)) || (!Pawn.ReachedDestination(CurrentAction.GetMoveTargetFor(self)))))
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
			if((Focus == none))
			{
				FocalPoint = (Pawn.Location + (float(1000) * Vector(SequenceScript.Rotation)));
			}
			FinishRotation();
			CompleteAction();			
		}
		else
		{
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			Focus = ScriptedFocus;
			// End:0x1DB
			if((!bUseScriptFacing))
			{
				FocalPoint = (Pawn.Location + (float(1000) * Vector(Pawn.Rotation)));				
			}
			else
			{
				// End:0x21B
				if((Focus == none))
				{
					MayShootAtEnemy();
					FocalPoint = (Pawn.Location + (float(1000) * Vector(SequenceScript.Rotation)));
				}
			}
			FinishRotation();
			MayShootTarget();
		}
	}
	stop;			
}

state Broken
{Begin:

	Warn(((((string(Pawn) $ " Scripted Sequence BROKEN ") $ string(SequenceScript)) $ " ACTION ") $ string(CurrentAction)));
	Pawn.bPhysicsAnimUpdate = false;
	Pawn.StopAnimating();
	// End:0x94
	if((GetMyPlayer() != none))
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
