//=============================================================================
// AIController - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// AIController, the base class of AI.
//
// Controllers are non-physical actors that can be attached to a pawn to control 
// its actions.  AIControllers implement the artificial intelligence for the pawns they control.  
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class AIController extends Controller
    native
    notplaceable;

var bool bHunting;  // tells navigation code that pawn is hunting another pawn,
										//	so fall back to finding a path to a visible pathnode if none
										//	are reachable
var bool bAdjustFromWalls;  // auto-adjust around corners, with no hitwall notification for controller or pawn
var float Skill;  // skill, scaled by game difficulty (add difficulty to this value)
var AIScript MyScript;

// Export UAIController::execWaitToSeeEnemy(FFrame&, void* const)
native(510) final latent function WaitToSeeEnemy();

event PreBeginPlay()
{
	super.PreBeginPlay();
	// End:0x11
	if(bDeleteMe)
	{
		return;
	}
	// End:0x45
	if((Level.Game != none))
	{
		(Skill += float(Level.Game.Difficulty));
	}
	Skill = FClamp(Skill, 0.0000000, 3.0000000);
	return;
}

function Reset()
{
	super.Reset();
	// End:0x12
	if(bIsPlayer)
	{
		Destroy();
	}
	return;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	TriggerScript(Other, EventInstigator);
	return;
}

function bool TriggerScript(Actor Other, Pawn EventInstigator)
{
	// End:0x26
	if((MyScript != none))
	{
		MyScript.Trigger(EventInstigator, Pawn);
		return true;
	}
	return false;
	return;
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local int i;
	local string t;

	super.DisplayDebug(Canvas, YL, YPos);
	Canvas.DrawColor.B = byte(255);
	Canvas.DrawText(((((((("     Skill " $ string(Skill)) $ " NAVIGATION MoveTarget ") $ GetItemName(string(MoveTarget))) $ " PendingMover ") $ string(PendingMover)) $ " MoveTimer ") $ string(MoveTimer)), false);
	(YPos += YL);
	Canvas.SetPos(4.0000000, YPos);
	Canvas.DrawText(((("      Destination " $ string(Destination)) $ " Focus ") $ GetItemName(string(Focus))), false);
	(YPos += YL);
	Canvas.SetPos(4.0000000, YPos);
	Canvas.DrawText(((("      RouteGoal " $ GetItemName(string(RouteGoal))) $ " RouteDist ") $ string(RouteDist)), false);
	(YPos += YL);
	Canvas.SetPos(4.0000000, YPos);
	i = 0;
	J0x1A4:

	// End:0x237 [Loop If]
	if((i < 16))
	{
		// End:0x1FC
		if((RouteCache[i] == none))
		{
			// End:0x1F6
			if((i > 5))
			{
				t = ((t $ "--") $ GetItemName(string(RouteCache[(i - 1)])));
			}
			// [Explicit Break]
			goto J0x237;
			// [Explicit Continue]
			goto J0x22D;
		}
		// End:0x22D
		if((i < 5))
		{
			t = ((t $ GetItemName(string(RouteCache[i]))) $ "-");
		}
		J0x22D:

		(i++);
		// [Loop Continue]
		goto J0x1A4;
	}
	J0x237:

	Canvas.DrawText(("RouteCache: " $ t), false);
	(YPos += YL);
	Canvas.SetPos(4.0000000, YPos);
	return;
}

function int GetFacingDirection()
{
	local float strafeMag;
	local Vector Focus2D, Loc2D, Dest2D, Dir, LookDir, Y;

	Focus2D = FocalPoint;
	Focus2D.Z = 0.0000000;
	Loc2D = Pawn.Location;
	Loc2D.Z = 0.0000000;
	Dest2D = Destination;
	Dest2D.Z = 0.0000000;
	LookDir = Normal((Focus2D - Loc2D));
	Dir = Normal((Dest2D - Loc2D));
	strafeMag = Dot(LookDir, Dir);
	Y = Cross(LookDir, vect(0.0000000, 0.0000000, 1.0000000));
	// End:0xE6
	if((Dot(Y, (Dest2D - Loc2D)) < float(0)))
	{
		return int((float(49152) + (float(16384) * strafeMag)));		
	}
	else
	{
		return int((float(16384) - (float(16384) * strafeMag)));
	}
	return;
}

// AdjustView() called if Controller's pawn is viewtarget of a player
function AdjustView(float DeltaTime)
{
	local float TargetYaw, TargetPitch;
	local Rotator OldViewRotation, ViewRotation;

	super.AdjustView(DeltaTime);
	ViewRotation = Rotation;
	OldViewRotation = Rotation;
	// End:0x1F9
	if((Enemy == none))
	{
		ViewRotation.Roll = 0;
		// End:0x1F9
		if((DeltaTime < 0.2000000))
		{
			OldViewRotation.Yaw = (OldViewRotation.Yaw & 65535);
			OldViewRotation.Pitch = (OldViewRotation.Pitch & 65535);
			TargetYaw = float((Rotation.Yaw & 65535));
			// End:0xEE
			if((Abs((TargetYaw - float(OldViewRotation.Yaw))) > float(32768)))
			{
				// End:0xE0
				if((TargetYaw < float(OldViewRotation.Yaw)))
				{
					(TargetYaw += float(65536));					
				}
				else
				{
					(TargetYaw -= float(65536));
				}
			}
			TargetYaw = ((float(OldViewRotation.Yaw) * (float(1) - (float(5) * DeltaTime))) + ((TargetYaw * float(5)) * DeltaTime));
			ViewRotation.Yaw = int(TargetYaw);
			TargetPitch = float((Rotation.Pitch & 65535));
			// End:0x1A7
			if((Abs((TargetPitch - float(OldViewRotation.Pitch))) > float(32768)))
			{
				// End:0x199
				if((TargetPitch < float(OldViewRotation.Pitch)))
				{
					(TargetPitch += float(65536));					
				}
				else
				{
					(TargetPitch -= float(65536));
				}
			}
			TargetPitch = ((float(OldViewRotation.Pitch) * (float(1) - (float(5) * DeltaTime))) + ((TargetPitch * float(5)) * DeltaTime));
			ViewRotation.Pitch = int(TargetPitch);
			SetRotation(ViewRotation);
		}
	}
	return;
}

function SetOrders(name NewOrders, Controller OrderGiver)
{
	return;
}

function Actor GetOrderObject()
{
	return none;
	return;
}

function name GetOrders()
{
	return 'None';
	return;
}

event PrepareForMove(NavigationPoint Goal, ReachSpec Path)
{
	return;
}

function WaitForMover(Mover M)
{
	PendingMover = M;
	bPreparingMove = true;
	Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	return;
}

function MoverFinished()
{
	// End:0x2F
	if(PendingMover.myMarker.ProceedWithMove(Pawn))
	{
		PendingMover = none;
		bPreparingMove = false;
	}
	return;
}

function UnderLift(Mover M)
{
	local NavigationPoint N;

	bPreparingMove = false;
	PendingMover = none;
	// End:0xBC
	if(((MoveTarget != none) && MoveTarget.IsA('LiftCenter')))
	{
		N = Level.NavigationPointList;
		J0x44:

		// End:0xBC [Loop If]
		if((N != none))
		{
			// End:0xA5
			if(((N.IsA('LiftExit') && (LiftExit(N).LiftTag == M.Tag)) && actorReachable(N)))
			{
				MoveTarget = N;
				return;
			}
			N = N.nextNavigationPoint;
			// [Loop Continue]
			goto J0x44;
		}
	}
	return;
}

defaultproperties
{
	bAdjustFromWalls=true
	bCanOpenDoors=true
	bCanDoSpecial=true
	MinHitWall=-0.5000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function WeaponFireAgain
// REMOVED IN 1.60: function AdjustToss
// REMOVED IN 1.60: function HearPickup
