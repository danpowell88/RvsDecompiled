//=============================================================================
// Teleporter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
///=============================================================================
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
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		URL, bEnabled;

	// Pos:0x00D
	reliable if(__NFUN_130__(bNetInitial, __NFUN_154__(int(Role), int(ROLE_Authority))))
		TargetVelocity, bChangesVelocity, 
		bChangesYaw, bReversesX, 
		bReversesY, bReversesZ;
}

function PostBeginPlay()
{
	// End:0x12
	if(__NFUN_124__(URL, ""))
	{
		__NFUN_262__(false, false, false);
	}
	// End:0x23
	if(__NFUN_129__(bEnabled))
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
	foreach __NFUN_313__(Class'Engine.Actor', A)
	{
		// End:0x5D
		if(__NFUN_254__(A.Event, Tag))
		{
			// End:0x4F
			if(__NFUN_114__(TriggerActor, none))
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

	__NFUN_118__('Touch');
	newRot = Incoming.Rotation;
	// End:0x93
	if(bChangesYaw)
	{
		OldRot = Incoming.Rotation;
		newRot.Yaw = Rotation.Yaw;
		// End:0x93
		if(__NFUN_119__(Source, none))
		{
			__NFUN_161__(newRot.Yaw, __NFUN_147__(__NFUN_146__(32768, Incoming.Rotation.Yaw), Source.Rotation.Yaw));
		}
	}
	// End:0x22C
	if(__NFUN_119__(Pawn(Incoming), none))
	{
		// End:0x112
		if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		{
			P = Level.ControllerList;
			J0xC7:

			// End:0x112 [Loop If]
			if(__NFUN_119__(P, none))
			{
				// End:0xFB
				if(__NFUN_114__(P.Enemy, Incoming))
				{
					P.__NFUN_514__(Incoming);
				}
				P = P.nextController;
				// [Loop Continue]
				goto J0xC7;
			}
		}
		// End:0x154
		if(__NFUN_129__(Pawn(Incoming).__NFUN_267__(Location)))
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(string(self), " Teleport failed for "), string(Incoming)));
		}
		// End:0x1C8
		if(__NFUN_132__(__NFUN_154__(int(Role), int(ROLE_Authority)), __NFUN_177__(__NFUN_175__(Level.TimeSeconds, LastFired), 0.5000000)))
		{
			Pawn(Incoming).__NFUN_299__(newRot);
			Pawn(Incoming).SetViewRotation(newRot);
			LastFired = Level.TimeSeconds;
		}
		// End:0x218
		if(__NFUN_119__(Pawn(Incoming).Controller, none))
		{
			Pawn(Incoming).Controller.MoveTimer = -1.0000000;
			Pawn(Incoming).SetMoveTarget(self);
		}
		Incoming.PlayTeleportEffect(false, true);		
	}
	else
	{
		// End:0x24B
		if(__NFUN_129__(Incoming.__NFUN_267__(Location)))
		{
			__NFUN_117__('Touch');
			return false;
		}
		// End:0x265
		if(bChangesYaw)
		{
			Incoming.__NFUN_299__(newRot);
		}
	}
	__NFUN_117__('Touch');
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
			if(__NFUN_154__(int(Incoming.Physics), int(1)))
			{
				OldRot.Pitch = 0;
			}
			oldDir = Vector(OldRot);
			mag = __NFUN_219__(Incoming.Velocity, oldDir);
			Incoming.Velocity = __NFUN_215__(__NFUN_216__(Incoming.Velocity, __NFUN_213__(mag, oldDir)), __NFUN_213__(mag, Vector(Incoming.Rotation)));
		}
		// End:0x349
		if(bReversesX)
		{
			__NFUN_182__(Incoming.Velocity.X, -1.0000000);
		}
		// End:0x36C
		if(bReversesY)
		{
			__NFUN_182__(Incoming.Velocity.Y, -1.0000000);
		}
		// End:0x38F
		if(bReversesZ)
		{
			__NFUN_182__(Incoming.Velocity.Z, -1.0000000);
		}
	}
	return true;
	return;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	local Actor A;

	bEnabled = __NFUN_129__(bEnabled);
	// End:0x35
	if(bEnabled)
	{
		// End:0x34
		foreach __NFUN_307__(Class'Engine.Actor', A)
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
	if(__NFUN_129__(bEnabled))
	{
		return;
	}
	// End:0x1B0
	if(__NFUN_130__(Other.bCanTeleport, __NFUN_242__(Other.PreTeleport(self), false)))
	{
		// End:0xCC
		if(__NFUN_132__(__NFUN_153__(__NFUN_126__(URL, "/"), 0), __NFUN_153__(__NFUN_126__(URL, "#"), 0)))
		{
			// End:0xC9
			if(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(Role), int(ROLE_Authority)), __NFUN_119__(Pawn(Other), none)), Pawn(Other).IsHumanControlled()))
			{
				Level.Game.SendPlayer(PlayerController(Pawn(Other).Controller), URL);
			}			
		}
		else
		{
			// End:0x12B
			foreach __NFUN_304__(Class'Engine.Teleporter', D)
			{
				// End:0x12A
				if(__NFUN_130__(__NFUN_124__(string(D.Tag), URL), __NFUN_119__(D, self)))
				{
					Dest[i] = D;
					__NFUN_165__(i);
					// End:0x12A
					if(__NFUN_151__(i, 16))
					{
						// End:0x12B
						break;
					}
				}				
			}			
			i = __NFUN_167__(i);
			// End:0x1B0
			if(__NFUN_119__(Dest[i], none))
			{
				// End:0x16F
				if(Other.__NFUN_303__('Pawn'))
				{
					Other.PlayTeleportEffect(false, true);
				}
				Dest[i].Accept(Other, self);
				// End:0x1B0
				if(__NFUN_119__(Pawn(Other), none))
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
	if(__NFUN_130__(__NFUN_130__(bEnabled, __NFUN_119__(Teleporter(Other.Controller.RouteCache[1]), none)), __NFUN_124__(string(Other.Controller.RouteCache[1].Tag), URL)))
	{
		// End:0xF1
		if(__NFUN_176__(__NFUN_186__(__NFUN_175__(Location.Z, Other.Location.Z)), __NFUN_174__(CollisionHeight, Other.CollisionHeight)))
		{
			Dist2D = __NFUN_216__(Location, Other.Location);
			Dist2D.Z = 0.0000000;
			// End:0xF1
			if(__NFUN_176__(__NFUN_225__(Dist2D), __NFUN_174__(CollisionRadius, Other.CollisionRadius)))
			{
				Touch(Other);
			}
		}
		return self;
	}
	// End:0x111
	if(__NFUN_114__(TriggerActor, none))
	{
		FindTriggerActor();
		// End:0x111
		if(__NFUN_114__(TriggerActor, none))
		{
			return none;
		}
	}
	// End:0x169
	if(__NFUN_130__(__NFUN_119__(TriggerActor2, none), __NFUN_176__(__NFUN_225__(__NFUN_216__(TriggerActor2.Location, Other.Location)), __NFUN_225__(__NFUN_216__(TriggerActor.Location, Other.Location)))))
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
