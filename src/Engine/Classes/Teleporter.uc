//=============================================================================
// Teleporter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Teleports actors either between different teleporters within a level
// or to matching teleporters on other levels, or to general Internet URLs.
//=============================================================================
class Teleporter extends SmallNavigationPoint
    native
    placeable
    hidecategories(Lighting,LightColor,Karma,Force);

//-----------------------------------------------------------------------------
// Teleporter destination flags.
var() bool bChangesVelocity;  // Set velocity to TargetVelocity.
var() bool bChangesYaw;  // Sets yaw to teleporter's Rotation.Yaw
var() bool bReversesX;  // Reverses X-component of velocity.
var() bool bReversesY;  // Reverses Y-component of velocity.
var() bool bReversesZ;  // Reverses Z-component of velocity.
// Teleporter flags
var() bool bEnabled;  // Teleporter is turned on;
var float LastFired;
// AI related
var Actor TriggerActor;  // used to tell AI how to trigger me
var Actor TriggerActor2;
//-----------------------------------------------------------------------------
// Product the user must have installed in order to enter the teleporter.
var() name ProductRequired;
//-----------------------------------------------------------------------------
// Teleporter destination directions.
var() Vector TargetVelocity;  // If bChangesVelocity, set target's velocity to this.
//-----------------------------------------------------------------------------
// Teleporter URL can be one of the following forms:
//
// TeleporterName
//		Teleports to a named teleporter in this level.
//		if none, acts only as a teleporter destination
//
// LevelName/TeleporterName
//     Teleports to a different level on this server.
//
// Unreal://Server.domain.com/LevelName/TeleporterName
//     Teleports to a different server on the net.
//
var() string URL;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		URL, bEnabled;

	// Pos:0x00D
	reliable if((bNetInitial && (int(Role) == int(ROLE_Authority))))
		TargetVelocity, bChangesVelocity, 
		bChangesYaw, bReversesX, 
		bReversesY, bReversesZ;
}

function PostBeginPlay()
{
	// End:0x12
	if((URL ~= ""))
	{
		SetCollision(false, false, false);
	}
	// End:0x23
	if((!bEnabled))
	{
		FindTriggerActor();
	}
	super(Actor).PostBeginPlay();
	return;
}

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = none;
	TriggerActor2 = none;
	// End:0x5E
	foreach DynamicActors(Class'Engine.Actor', A)
	{
		// End:0x5D
		if((A.Event == Tag))
		{
			// End:0x4F
			if((TriggerActor == none))
			{
				TriggerActor = A;
				// End:0x5D
				continue;
			}
			TriggerActor2 = A;			
			return;
		}		
	}	
	return;
}

// Accept an actor that has teleported in.
simulated function bool Accept(Actor Incoming, Actor Source)
{
	local Rotator newRot, OldRot;
	local float mag;
	local Vector oldDir;
	local Controller P;

	Disable('Touch');
	newRot = Incoming.Rotation;
	// End:0x93
	if(bChangesYaw)
	{
		OldRot = Incoming.Rotation;
		newRot.Yaw = Rotation.Yaw;
		// End:0x93
		if((Source != none))
		{
			(newRot.Yaw += ((32768 + Incoming.Rotation.Yaw) - Source.Rotation.Yaw));
		}
	}
	// End:0x22C
	if((Pawn(Incoming) != none))
	{
		// End:0x112
		if((int(Role) == int(ROLE_Authority)))
		{
			P = Level.ControllerList;
			J0xC7:

			// End:0x112 [Loop If]
			if((P != none))
			{
				// End:0xFB
				if((P.Enemy == Incoming))
				{
					P.LineOfSightTo(Incoming);
				}
				P = P.nextController;
				// [Loop Continue]
				goto J0xC7;
			}
		}
		// End:0x154
		if((!Pawn(Incoming).SetLocation(Location)))
		{
			Log(((string(self) $ " Teleport failed for ") $ string(Incoming)));
		}
		// End:0x1C8
		if(((int(Role) == int(ROLE_Authority)) || ((Level.TimeSeconds - LastFired) > 0.5000000)))
		{
			Pawn(Incoming).SetRotation(newRot);
			Pawn(Incoming).SetViewRotation(newRot);
			LastFired = Level.TimeSeconds;
		}
		// End:0x218
		if((Pawn(Incoming).Controller != none))
		{
			Pawn(Incoming).Controller.MoveTimer = -1.0000000;
			Pawn(Incoming).SetMoveTarget(self);
		}
		Incoming.PlayTeleportEffect(false, true);		
	}
	else
	{
		// End:0x24B
		if((!Incoming.SetLocation(Location)))
		{
			Enable('Touch');
			return false;
		}
		// End:0x265
		if(bChangesYaw)
		{
			Incoming.SetRotation(newRot);
		}
	}
	Enable('Touch');
	// End:0x28C
	if(bChangesVelocity)
	{
		Incoming.Velocity = TargetVelocity;		
	}
	else
	{
		// End:0x326
		if(bChangesYaw)
		{
			// End:0x2BA
			if((int(Incoming.Physics) == int(1)))
			{
				OldRot.Pitch = 0;
			}
			oldDir = Vector(OldRot);
			mag = Dot(Incoming.Velocity, oldDir);
			Incoming.Velocity = ((Incoming.Velocity - (mag * oldDir)) + (mag * Vector(Incoming.Rotation)));
		}
		// End:0x349
		if(bReversesX)
		{
			(Incoming.Velocity.X *= -1.0000000);
		}
		// End:0x36C
		if(bReversesY)
		{
			(Incoming.Velocity.Y *= -1.0000000);
		}
		// End:0x38F
		if(bReversesZ)
		{
			(Incoming.Velocity.Z *= -1.0000000);
		}
	}
	return true;
	return;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	local Actor A;

	bEnabled = (!bEnabled);
	// End:0x35
	if(bEnabled)
	{
		// End:0x34
		foreach TouchingActors(Class'Engine.Actor', A)
		{
			Touch(A);			
		}		
	}
	return;
}

// Teleporter was touched by an actor.
simulated function Touch(Actor Other)
{
	local Teleporter D, Dest;
	local int i;

	// End:0x0D
	if((!bEnabled))
	{
		return;
	}
	// End:0x1B0
	if((Other.bCanTeleport && (Other.PreTeleport(self) == false)))
	{
		// End:0xCC
		if(((InStr(URL, "/") >= 0) || (InStr(URL, "#") >= 0)))
		{
			// End:0xC9
			if((((int(Role) == int(ROLE_Authority)) && (Pawn(Other) != none)) && Pawn(Other).IsHumanControlled()))
			{
				Level.Game.SendPlayer(PlayerController(Pawn(Other).Controller), URL);
			}			
		}
		else
		{
			// End:0x12B
			foreach AllActors(Class'Engine.Teleporter', D)
			{
				// End:0x12A
				if(((string(D.Tag) ~= URL) && (D != self)))
				{
					Dest[i] = D;
					(i++);
					// End:0x12A
					if((i > 16))
					{
						// End:0x12B
						break;
					}
				}				
			}			
			i = Rand(i);
			// End:0x1B0
			if((Dest[i] != none))
			{
				// End:0x16F
				if(Other.IsA('Pawn'))
				{
					Other.PlayTeleportEffect(false, true);
				}
				Dest[i].Accept(Other, self);
				// End:0x1B0
				if((Pawn(Other) != none))
				{
					TriggerEvent(Event, self, Pawn(Other));
				}
			}
		}
	}
	return;
}

function Actor SpecialHandling(Pawn Other)
{
	local Vector Dist2D;

	// End:0xF3
	if(((bEnabled && (Teleporter(Other.Controller.RouteCache[1]) != none)) && (string(Other.Controller.RouteCache[1].Tag) ~= URL)))
	{
		// End:0xF1
		if((Abs((Location.Z - Other.Location.Z)) < (CollisionHeight + Other.CollisionHeight)))
		{
			Dist2D = (Location - Other.Location);
			Dist2D.Z = 0.0000000;
			// End:0xF1
			if((VSize(Dist2D) < (CollisionRadius + Other.CollisionRadius)))
			{
				Touch(Other);
			}
		}
		return self;
	}
	// End:0x111
	if((TriggerActor == none))
	{
		FindTriggerActor();
		// End:0x111
		if((TriggerActor == none))
		{
			return none;
		}
	}
	// End:0x169
	if(((TriggerActor2 != none) && (VSize((TriggerActor2.Location - Other.Location)) < VSize((TriggerActor.Location - Other.Location)))))
	{
		return TriggerActor2;
	}
	return TriggerActor;
	return;
}

defaultproperties
{
	bChangesYaw=true
	bEnabled=true
	RemoteRole=2
	bCollideActors=true
	bDirectional=true
	Texture=Texture'Engine.S_Teleport'
}
