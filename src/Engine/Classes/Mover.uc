//=============================================================================
// Mover - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// The moving brush class.
// This is a built-in Unreal class and it shouldn't be modified.
// Note that movers by default have bNoDelete==true.  This makes movers and their default properties
// remain on the client side.  If a mover subclass has bNoDelete=false, then its default properties must
// be replicated
//=============================================================================
class Mover extends Actor
    native
    nativereplication
    notplaceable;

enum EMoverEncroachType
{
	ME_StopWhenEncroach,            // 0
	ME_ReturnWhenEncroach,          // 1
	ME_CrushWhenEncroach,           // 2
	ME_IgnoreWhenEncroach           // 3
};

enum EMoverGlideType
{
	MV_MoveByTime,                  // 0
	MV_GlideByTime                  // 1
};

enum EBumpType
{
	BT_PlayerBump,                  // 0
	BT_PawnBump,                    // 1
	BT_AnyBump                      // 2
};

// NEW IN 1.60
var() Mover.EMoverEncroachType MoverEncroachType;
// NEW IN 1.60
var() Mover.EMoverGlideType MoverGlideType;
// NEW IN 1.60
var() Mover.EBumpType BumpType;
//-----------------------------------------------------------------------------
// Keyframe numbers.
var() byte KeyNum;  // Current or destination keyframe.
var byte PrevKeyNum;  // Previous keyframe.
var() const byte NumKeys;  // Number of keyframes in total (0-3).
var() const byte WorldRaytraceKey;  // Raytrace the world with the brush here.
var() const byte BrushRaytraceKey;  // Raytrace the brush here.
var() int EncroachDamage;  // How much to damage encroached actors.
var int numTriggerEvents;  // number of times triggered ( count down to untrigger )
var int SimOldRotPitch;
// NEW IN 1.60
var int SimOldRotYaw;
// NEW IN 1.60
var int SimOldRotRoll;
var int ClientUpdate;
// NEW IN 1.60
var int StepDirection;
// NEW IN 1.60
var() bool bToggleDirection;
//-----------------------------------------------------------------------------
// Mover state.
var() bool bTriggerOnceOnly;  // Go dormant after first trigger.
var() bool bSlave;  // This brush is a slave.
var() bool bUseTriggered;  // Triggered by player grab
var() bool bDamageTriggered;  // Triggered by taking damage
var() bool bDynamicLightMover;  // Apply dynamic lighting to mover.
// NEW IN 1.60
var() bool bUseShortestRotation;
// NEW IN 1.60
var(ReturnGroup) bool bIsLeader;
// NEW IN 1.60
var() bool bOscillatingLoop;
var bool bOpening;
// NEW IN 1.60
var bool bDelaying;
// NEW IN 1.60
var bool bClientPause;
var bool bClosed;  // mover is in closed position, and no longer moving
var bool bPlayerOnly;
var(AI) bool bNoAIRelevance;  // don't warn about this mover during path review
//-----------------------------------------------------------------------------
// Movement parameters.
var() float MoveTime;  // Time to spend moving between keyframes.
var() float StayOpenTime;  // How long to remain open before closing.
var() float OtherTime;  // TriggerPound stay-open time.
var() float DamageThreshold;  // minimum damage to trigger
var() float DelayTime;  // delay before starting to open
var float PhysAlpha;  // Interpolating position, 0.0-1.0.
var float PhysRate;  // Interpolation rate per second.
var Actor SavedTrigger;  // Who we were triggered by.
var Mover Leader;  // for having multiple movers return together
var Mover Follower;
//-----------------------------------------------------------------------------
// Audio.
var(MoverSounds) Sound OpeningSound;  // When start opening.
var(MoverSounds) Sound OpenedSound;  // When finished opening.
var(MoverSounds) Sound ClosingSound;  // When start closing.
var(MoverSounds) Sound ClosedSound;  // When finish closing.
var(MoverSounds) Sound MoveAmbientSound;  // Optional ambient sound when moving.
// NEW IN 1.60
var(MoverSounds) Sound LoopSound;
// AI related
var NavigationPoint myMarker;
var() name PlayerBumpEvent;  // Optional event to cause when the player bumps the mover.
var() name BumpEvent;  // Optional event to cause when any valid bumper bumps the mover.
var(ReturnGroup) name ReturnGroup;  // if none, same as tag
// NEW IN 1.60
var(MoverEvents) name OpeningEvent;
// NEW IN 1.60
var(MoverEvents) name OpenedEvent;
// NEW IN 1.60
var(MoverEvents) name ClosingEvent;
// NEW IN 1.60
var(MoverEvents) name ClosedEvent;
// NEW IN 1.60
var(MoverEvents) name LoopEvent;
// NEW IN 1.60
var() name AntiPortalTag;
// NEW IN 1.60
var array<AntiPortalActor> AntiPortals;
// NEW IN 1.60
var Vector KeyPos[24];
// NEW IN 1.60
var Rotator KeyRot[24];
var Vector BasePos;
// NEW IN 1.60
var Vector OldPos;
// NEW IN 1.60
var Vector OldPrePivot;
// NEW IN 1.60
var Vector SavedPos;
var Rotator BaseRot;
// NEW IN 1.60
var Rotator OldRot;
// NEW IN 1.60
var Rotator SavedRot;
// for client side replication
var Vector SimOldPos;
var Vector SimInterpolate;
var Vector RealPosition;
var Rotator RealRotation;

replication
{
	// Pos:0x000
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		RealPosition, RealRotation, 
		SimInterpolate, SimOldPos, 
		SimOldRotPitch, SimOldRotRoll, 
		SimOldRotYaw;
}

simulated function StartInterpolation()
{
	__NFUN_113__('None');
	bInterpolating = true;
	m_bTickOnlyWhenVisible = false;
	__NFUN_3970__(0);
	return;
}

simulated function Timer()
{
	// End:0x21
	if(__NFUN_218__(Velocity, vect(0.0000000, 0.0000000, 0.0000000)))
	{
		bClientPause = false;
		return;
	}
	// End:0xB3
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
	{
		// End:0xA8
		if(__NFUN_154__(ClientUpdate, 0))
		{
			// End:0x8E
			if(bClientPause)
			{
				// End:0x70
				if(__NFUN_177__(__NFUN_225__(__NFUN_216__(RealPosition, Location)), float(3)))
				{
					__NFUN_267__(RealPosition);					
				}
				else
				{
					RealPosition = Location;
				}
				__NFUN_299__(RealRotation);
				bClientPause = false;				
			}
			else
			{
				// End:0xA5
				if(__NFUN_218__(RealPosition, Location))
				{
					bClientPause = true;
				}
			}			
		}
		else
		{
			bClientPause = false;
		}		
	}
	else
	{
		RealPosition = Location;
		RealRotation = Rotation;
	}
	return;
}

// Interpolate to keyframe KeyNum in Seconds time.
final simulated function InterpolateTo(byte NewKeyNum, float Seconds)
{
	local Mover M;

	// End:0x20
	foreach __NFUN_306__(Class'Engine.Mover', M)
	{
		M.BaseStarted();		
	}	
	NewKeyNum = byte(__NFUN_251__(int(NewKeyNum), 0, __NFUN_147__(24, 1)));
	// End:0xAA
	if(__NFUN_130__(__NFUN_154__(int(NewKeyNum), int(PrevKeyNum)), __NFUN_155__(int(KeyNum), int(PrevKeyNum))))
	{
		PhysAlpha = __NFUN_175__(1.0000000, PhysAlpha);
		OldPos = __NFUN_215__(BasePos, KeyPos[int(KeyNum)]);
		OldRot = __NFUN_316__(BaseRot, KeyRot[int(KeyNum)]);		
	}
	else
	{
		OldPos = Location;
		OldRot = Rotation;
		PhysAlpha = 0.0000000;
	}
	__NFUN_3970__(8);
	bInterpolating = true;
	m_bTickOnlyWhenVisible = false;
	PrevKeyNum = KeyNum;
	KeyNum = NewKeyNum;
	PhysRate = __NFUN_172__(1.0000000, __NFUN_245__(Seconds, 0.0050000));
	__NFUN_165__(ClientUpdate);
	SimOldPos = OldPos;
	SimOldRotYaw = OldRot.Yaw;
	SimOldRotPitch = OldRot.Pitch;
	SimOldRotRoll = OldRot.Roll;
	SimInterpolate.X = __NFUN_171__(100.0000000, PhysAlpha);
	SimInterpolate.Y = __NFUN_171__(100.0000000, __NFUN_245__(0.0100000, PhysRate));
	SimInterpolate.Z = __NFUN_174__(__NFUN_171__(256.0000000, float(PrevKeyNum)), float(KeyNum));
	return;
}

// Set the specified keyframe.
final function SetKeyframe(byte NewKeyNum, Vector NewLocation, Rotator NewRotation)
{
	KeyNum = byte(__NFUN_251__(int(NewKeyNum), 0, __NFUN_147__(24, 1)));
	KeyPos[int(KeyNum)] = NewLocation;
	KeyRot[int(KeyNum)] = NewRotation;
	return;
}

// Interpolation ended.
simulated event KeyFrameReached()
{
	local byte OldKeyNum;
	local Mover M;

	OldKeyNum = PrevKeyNum;
	PrevKeyNum = KeyNum;
	PhysAlpha = 0.0000000;
	__NFUN_166__(ClientUpdate);
	// End:0x64
	if(__NFUN_130__(__NFUN_151__(int(KeyNum), 0), __NFUN_150__(int(KeyNum), int(OldKeyNum))))
	{
		InterpolateTo(byte(__NFUN_147__(int(KeyNum), 1)), MoveTime);		
	}
	else
	{
		// End:0xA9
		if(__NFUN_130__(__NFUN_150__(int(KeyNum), __NFUN_147__(int(NumKeys), 1)), __NFUN_151__(int(KeyNum), int(OldKeyNum))))
		{
			InterpolateTo(byte(__NFUN_146__(int(KeyNum), 1)), MoveTime);			
		}
		else
		{
			AmbientSound = none;
			// End:0x10D
			if(__NFUN_130__(__NFUN_154__(ClientUpdate, 0), __NFUN_155__(int(Level.NetMode), int(NM_Client))))
			{
				RealPosition = Location;
				RealRotation = Rotation;
				// End:0x10C
				foreach __NFUN_306__(Class'Engine.Mover', M)
				{
					M.BaseFinished();					
				}				
			}
		}
	}
	return;
}

// Notify AI that mover finished movement
function FinishNotify()
{
	local Controller C;

	C = Level.ControllerList;
	J0x14:

	// End:0x6F [Loop If]
	if(__NFUN_119__(C, none))
	{
		// End:0x58
		if(__NFUN_130__(__NFUN_119__(C.Pawn, none), __NFUN_114__(C.PendingMover, self)))
		{
			C.MoverFinished();
		}
		C = C.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

// Handle when the mover finishes closing.
function FinishedClosing()
{
	local Mover M;

	__NFUN_264__(ClosedSound, 3);
	TriggerEvent(ClosedEvent, self, Instigator);
	// End:0x35
	if(__NFUN_119__(SavedTrigger, none))
	{
		SavedTrigger.EndEvent();
	}
	SavedTrigger = none;
	Instigator = none;
	// End:0x5D
	if(__NFUN_119__(myMarker, none))
	{
		myMarker.MoverClosed();
	}
	bClosed = true;
	FinishNotify();
	M = Leader;
	J0x76:

	// End:0xAE [Loop If]
	if(__NFUN_119__(M, none))
	{
		// End:0x97
		if(__NFUN_129__(M.bClosed))
		{
			return;
		}
		M = M.Follower;
		// [Loop Continue]
		goto J0x76;
	}
	UntriggerEvent(OpeningEvent, self, Instigator);
	return;
}

// Handle when the mover finishes opening.
function FinishedOpening()
{
	__NFUN_264__(OpenedSound, 3);
	TriggerEvent(Event, self, Instigator);
	TriggerEvent(OpenedEvent, self, Instigator);
	// End:0x46
	if(__NFUN_119__(myMarker, none))
	{
		myMarker.MoverOpened();
	}
	FinishNotify();
	return;
}

// Open the mover.
function DoOpen()
{
	bOpening = true;
	bDelaying = false;
	InterpolateTo(1, MoveTime);
	__NFUN_512__(1.0000000);
	__NFUN_264__(OpeningSound, 3);
	AmbientSound = MoveAmbientSound;
	TriggerEvent(OpeningEvent, self, Instigator);
	// End:0x65
	if(__NFUN_119__(Follower, none))
	{
		Follower.DoOpen();
	}
	return;
}

// Close the mover.
function DoClose()
{
	bOpening = false;
	bDelaying = false;
	InterpolateTo(byte(__NFUN_250__(0, __NFUN_147__(int(KeyNum), 1))), MoveTime);
	__NFUN_512__(1.0000000);
	__NFUN_264__(ClosingSound, 3);
	UntriggerEvent(Event, self, Instigator);
	AmbientSound = MoveAmbientSound;
	TriggerEvent(ClosingEvent, self, Instigator);
	// End:0x83
	if(__NFUN_119__(Follower, none))
	{
		Follower.DoClose();
	}
	return;
}

// When mover enters gameplay.
simulated function BeginPlay()
{
	local AntiPortalActor AntiPortal;

	// End:0x4B
	if(__NFUN_255__(AntiPortalTag, 'None'))
	{
		// End:0x4A
		foreach __NFUN_304__(Class'Engine.AntiPortalActor', AntiPortal, AntiPortalTag)
		{
			AntiPortals.Length = __NFUN_146__(AntiPortals.Length, 1);
			AntiPortals[__NFUN_147__(AntiPortals.Length, 1)] = AntiPortal;			
		}		
	}
	// End:0xA4
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		// End:0x89
		if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
		{
			__NFUN_280__(4.0000000, true);			
		}
		else
		{
			__NFUN_280__(1.0000000, true);
		}
		// End:0xA4
		if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		{
			return;
		}
	}
	// End:0xD3
	if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
	{
		RealPosition = Location;
		RealRotation = Rotation;
	}
	super.BeginPlay();
	KeyNum = byte(__NFUN_251__(int(KeyNum), 0, __NFUN_147__(24, 1)));
	PhysAlpha = 0.0000000;
	__NFUN_266__(__NFUN_216__(__NFUN_215__(BasePos, KeyPos[int(KeyNum)]), Location));
	__NFUN_299__(__NFUN_316__(BaseRot, KeyRot[int(KeyNum)]));
	// End:0x14B
	if(__NFUN_254__(ReturnGroup, 'None'))
	{
		ReturnGroup = Tag;
	}
	Leader = none;
	Follower = none;
	return;
}

// Immediately after mover enters gameplay.
function PostBeginPlay()
{
	local Mover M;

	// End:0x51
	if(__NFUN_129__(bSlave))
	{
		// End:0x50
		foreach __NFUN_313__(Class'Engine.Mover', M, Tag)
		{
			// End:0x4F
			if(M.bSlave)
			{
				M.__NFUN_113__('None');
				M.__NFUN_298__(self);
			}			
		}		
	}
	// End:0xCA
	if(bIsLeader)
	{
		Leader = self;
		// End:0xC6
		foreach __NFUN_313__(Class'Engine.Mover', M)
		{
			// End:0xC5
			if(__NFUN_130__(__NFUN_119__(M, self), __NFUN_254__(M.ReturnGroup, ReturnGroup)))
			{
				M.Leader = self;
				M.Follower = Follower;
				Follower = M;
			}			
		}				
	}
	else
	{
		// End:0x116
		if(__NFUN_114__(Leader, none))
		{
			// End:0x10E
			foreach __NFUN_313__(Class'Engine.Mover', M)
			{
				// End:0x10D
				if(__NFUN_130__(__NFUN_119__(M, self), __NFUN_254__(M.ReturnGroup, ReturnGroup)))
				{					
					return;
				}				
			}			
			Leader = self;
		}
	}
	return;
}

function MakeGroupStop()
{
	bInterpolating = false;
	m_bTickOnlyWhenVisible = default.m_bTickOnlyWhenVisible;
	AmbientSound = none;
	__NFUN_113__(, 'None');
	// End:0x3E
	if(__NFUN_119__(Follower, none))
	{
		Follower.MakeGroupStop();
	}
	return;
}

function MakeGroupReturn()
{
	bInterpolating = false;
	m_bTickOnlyWhenVisible = default.m_bTickOnlyWhenVisible;
	AmbientSound = none;
	// End:0x58
	if(__NFUN_132__(bIsLeader, __NFUN_114__(Leader, self)))
	{
		// End:0x50
		if(__NFUN_150__(int(KeyNum), int(PrevKeyNum)))
		{
			__NFUN_113__(, 'Open');			
		}
		else
		{
			__NFUN_113__(, 'Close');
		}
	}
	// End:0x72
	if(__NFUN_119__(Follower, none))
	{
		Follower.MakeGroupReturn();
	}
	return;
}

// Return true to abort, false to continue.
function bool EncroachingOn(Actor Other)
{
	local Pawn P;

	// End:0x0D
	if(__NFUN_114__(Other, none))
	{
		return false;
	}
	// End:0x3A
	if(__NFUN_130__(__NFUN_119__(Pawn(Other), none), __NFUN_114__(Pawn(Other).Controller, none)))
	{
		return false;
	}
	P = Pawn(Other);
	// End:0xFB
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(P, none), __NFUN_119__(P.Controller, none)), P.IsPlayerPawn()))
	{
		// End:0x99
		if(__NFUN_255__(PlayerBumpEvent, 'None'))
		{
			Bump(Other);
		}
		// End:0xFB
		if(__NFUN_130__(__NFUN_130__(__NFUN_119__(P.Controller, none), __NFUN_119__(P.Base, self)), __NFUN_114__(P.Controller.PendingMover, self)))
		{
			P.Controller.UnderLift(self);
		}
	}
	// End:0x11F
	if(__NFUN_154__(int(MoverEncroachType), int(0)))
	{
		Leader.MakeGroupStop();
		return true;		
	}
	else
	{
		// End:0x16B
		if(__NFUN_154__(int(MoverEncroachType), int(1)))
		{
			Leader.MakeGroupReturn();
			// End:0x166
			if(Other.__NFUN_303__('Pawn'))
			{
				Pawn(Other).PlayMoverHitSound();
			}
			return true;			
		}
		else
		{
			// End:0x194
			if(__NFUN_154__(int(MoverEncroachType), int(2)))
			{
				Other.KilledBy(Instigator);
				return false;				
			}
			else
			{
				// End:0x1A6
				if(__NFUN_154__(int(MoverEncroachType), int(3)))
				{
					return false;
				}
			}
		}
	}
	return;
}

// When bumped by player.
function Bump(Actor Other)
{
	local Pawn P;

	P = Pawn(Other);
	// End:0x79
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(bUseTriggered, __NFUN_119__(P, none)), __NFUN_129__(P.IsHumanControlled())), P.IsPlayerPawn()))
	{
		Trigger(P, P);
		P.Controller.WaitForMover(self);
	}
	// End:0x98
	if(__NFUN_130__(__NFUN_155__(int(BumpType), int(2)), __NFUN_114__(P, none)))
	{
		return;
	}
	// End:0xC0
	if(__NFUN_130__(__NFUN_154__(int(BumpType), int(0)), __NFUN_129__(P.IsPlayerPawn())))
	{
		return;
	}
	// End:0xE6
	if(__NFUN_130__(__NFUN_154__(int(BumpType), int(1)), P.bAmbientCreature))
	{
		return;
	}
	TriggerEvent(BumpEvent, self, P);
	// End:0x127
	if(__NFUN_130__(__NFUN_119__(P, none), P.IsPlayerPawn()))
	{
		TriggerEvent(PlayerBumpEvent, self, P);
	}
	return;
}

// NEW IN 1.60
function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	// End:0x7D
	if(__NFUN_130__(bDamageTriggered, __NFUN_179__(float(iKillValue), DamageThreshold)))
	{
		// End:0x6C
		if(__NFUN_130__(__NFUN_119__(AIController(instigatedBy.Controller), none), __NFUN_114__(instigatedBy.Controller.Focus, self)))
		{
			instigatedBy.Controller.StopFiring();
		}
		self.Trigger(self, instigatedBy);
	}
	return 0;
	return;
}

// NEW IN 1.60
function MoverLooped()
{
	TriggerEvent(LoopEvent, self, Instigator);
	// End:0x26
	if(__NFUN_119__(LoopSound, none))
	{
		__NFUN_264__(LoopSound, 3);
	}
	return;
}

// NEW IN 1.60
function BaseStarted()
{
	return;
}

// NEW IN 1.60
function BaseFinished()
{
	return;
}

state OpenTimedMover
{
// NEW IN 1.60
	function bool ShouldReTrigger()
	{
		return false;
		return;
	}
Open:

	bClosed = false;
	DisableTrigger();
	// End:0x2B
	if(__NFUN_177__(DelayTime, float(0)))
	{
		bDelaying = true;
		__NFUN_256__(DelayTime);
	}
	DoOpen();
	__NFUN_301__();
	FinishedOpening();
	__NFUN_256__(StayOpenTime);
	// End:0x52
	if(bTriggerOnceOnly)
	{
		__NFUN_113__('None');
	}
Close:


	DoClose();
	__NFUN_301__();
	FinishedClosing();
	EnableTrigger();
	__NFUN_256__(StayOpenTime);
	// End:0x8B
	if(ShouldReTrigger())
	{
		SavedTrigger = none;
		__NFUN_113__('StandOpenTimed', 'Open');
	}
	stop;				
}

state() StandOpenTimed extends OpenTimedMover
{
// NEW IN 1.60
	function bool ShouldReTrigger()
	{
		local int i;

		i = 0;
		J0x07:

		// End:0x37 [Loop If]
		if(__NFUN_150__(i, Attached.Length))
		{
			// End:0x2D
			if(CanTrigger(Attached[i]))
			{
				return true;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x07;
		}
		return false;
		return;
	}

// NEW IN 1.60
	function bool CanTrigger(Actor Other)
	{
		local Pawn P;

		P = Pawn(Other);
		// End:0x2F
		if(__NFUN_130__(__NFUN_155__(int(BumpType), int(2)), __NFUN_114__(P, none)))
		{
			return false;
		}
		// End:0x57
		if(__NFUN_130__(__NFUN_154__(int(BumpType), int(0)), __NFUN_129__(P.IsPlayerPawn())))
		{
			return false;
		}
		// End:0x82
		if(__NFUN_130__(__NFUN_154__(int(BumpType), int(1)), __NFUN_176__(Other.Mass, float(10))))
		{
			return false;
		}
		TriggerEvent(BumpEvent, self, P);
		return true;
		return;
	}

	function Attach(Actor Other)
	{
		// End:0x12
		if(__NFUN_129__(CanTrigger(Other)))
		{
			return;
		}
		SavedTrigger = none;
		__NFUN_113__('StandOpenTimed', 'Open');
		return;
	}

	function DisableTrigger()
	{
		__NFUN_118__('Attach');
		return;
	}

	function EnableTrigger()
	{
		__NFUN_117__('Attach');
		return;
	}
	stop;
}

state() BumpOpenTimed extends OpenTimedMover
{
// When bumped by player.
	function Bump(Actor Other)
	{
		// End:0x24
		if(__NFUN_130__(__NFUN_155__(int(BumpType), int(2)), __NFUN_114__(Pawn(Other), none)))
		{
			return;
		}
		// End:0x51
		if(__NFUN_130__(__NFUN_154__(int(BumpType), int(0)), __NFUN_129__(Pawn(Other).IsPlayerPawn())))
		{
			return;
		}
		// End:0x7C
		if(__NFUN_130__(__NFUN_154__(int(BumpType), int(1)), __NFUN_176__(Other.Mass, float(10))))
		{
			return;
		}
		global.Bump(Other);
		SavedTrigger = none;
		Instigator = Pawn(Other);
		// End:0xC2
		if(__NFUN_119__(Instigator, none))
		{
			Instigator.Controller.WaitForMover(self);
		}
		__NFUN_113__('BumpOpenTimed', 'Open');
		return;
	}

	function DisableTrigger()
	{
		__NFUN_118__('Bump');
		return;
	}

	function EnableTrigger()
	{
		__NFUN_117__('Bump');
		return;
	}
	stop;
}

state() TriggerOpenTimed extends OpenTimedMover
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		SavedTrigger = Other;
		Instigator = EventInstigator;
		// End:0x30
		if(__NFUN_119__(SavedTrigger, none))
		{
			SavedTrigger.BeginEvent();
		}
		__NFUN_113__('TriggerOpenTimed', 'Open');
		return;
	}

	function DisableTrigger()
	{
		__NFUN_118__('Trigger');
		return;
	}

	function EnableTrigger()
	{
		__NFUN_117__('Trigger');
		return;
	}
	stop;
}

state() LoopMove
{
	event Trigger(Actor Other, Pawn EventInstigator)
	{
		__NFUN_118__('Trigger');
		__NFUN_117__('UnTrigger');
		SavedTrigger = Other;
		Instigator = EventInstigator;
		// End:0x3E
		if(__NFUN_119__(SavedTrigger, none))
		{
			SavedTrigger.BeginEvent();
		}
		bOpening = true;
		__NFUN_264__(OpeningSound, 3);
		AmbientSound = MoveAmbientSound;
		__NFUN_113__('LoopMove', 'Running');
		return;
	}

	event UnTrigger(Actor Other, Pawn EventInstigator)
	{
		__NFUN_118__('UnTrigger');
		__NFUN_117__('Trigger');
		SavedTrigger = Other;
		Instigator = EventInstigator;
		__NFUN_113__('LoopMove', 'Stopping');
		return;
	}

// Interpolation ended.
	event KeyFrameReached()
	{
		return;
	}

	function BeginState()
	{
		bOpening = false;
		bDelaying = false;
		return;
	}
Running:

	__NFUN_301__();
	InterpolateTo(byte(__NFUN_173__(float(byte(__NFUN_146__(int(KeyNum), 1))), float(NumKeys))), MoveTime);
	__NFUN_113__('LoopMove', 'Running');
Stopping:


	__NFUN_301__();
	FinishedOpening();
	UntriggerEvent(Event, self, Instigator);
	bOpening = false;
	stop;
	stop;	
}

state() TriggerToggle
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		SavedTrigger = Other;
		Instigator = EventInstigator;
		// End:0x30
		if(__NFUN_119__(SavedTrigger, none))
		{
			SavedTrigger.BeginEvent();
		}
		// End:0x61
		if(__NFUN_132__(__NFUN_154__(int(KeyNum), 0), __NFUN_150__(int(KeyNum), int(PrevKeyNum))))
		{
			__NFUN_113__('TriggerToggle', 'Open');			
		}
		else
		{
			__NFUN_113__('TriggerToggle', 'Close');
		}
		return;
	}
Open:

	bClosed = false;
	// End:0x25
	if(__NFUN_177__(DelayTime, float(0)))
	{
		bDelaying = true;
		__NFUN_256__(DelayTime);
	}
	DoOpen();
	__NFUN_301__();
	FinishedOpening();
	// End:0x4E
	if(__NFUN_119__(SavedTrigger, none))
	{
		SavedTrigger.EndEvent();
	}
	stop;
Close:


	DoClose();
	__NFUN_301__();
	FinishedClosing();
	stop;	
}

state() TriggerControl
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		__NFUN_165__(numTriggerEvents);
		SavedTrigger = Other;
		Instigator = EventInstigator;
		// End:0x37
		if(__NFUN_119__(SavedTrigger, none))
		{
			SavedTrigger.BeginEvent();
		}
		__NFUN_113__('TriggerControl', 'Open');
		return;
	}

	function UnTrigger(Actor Other, Pawn EventInstigator)
	{
		__NFUN_166__(numTriggerEvents);
		// End:0x4A
		if(__NFUN_152__(numTriggerEvents, 0))
		{
			numTriggerEvents = 0;
			SavedTrigger = Other;
			Instigator = EventInstigator;
			SavedTrigger.BeginEvent();
			__NFUN_113__('TriggerControl', 'Close');
		}
		return;
	}

	function BeginState()
	{
		numTriggerEvents = 0;
		return;
	}
Open:

	bClosed = false;
	// End:0x25
	if(__NFUN_177__(DelayTime, float(0)))
	{
		bDelaying = true;
		__NFUN_256__(DelayTime);
	}
	DoOpen();
	__NFUN_301__();
	FinishedOpening();
	SavedTrigger.EndEvent();
	// End:0x53
	if(bTriggerOnceOnly)
	{
		__NFUN_113__('None');
	}
	stop;
Close:


	DoClose();
	__NFUN_301__();
	FinishedClosing();
	stop;				
}

state() TriggerPound
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		__NFUN_165__(numTriggerEvents);
		SavedTrigger = Other;
		Instigator = EventInstigator;
		__NFUN_113__('TriggerPound', 'Open');
		return;
	}

	function UnTrigger(Actor Other, Pawn EventInstigator)
	{
		__NFUN_166__(numTriggerEvents);
		// End:0x33
		if(__NFUN_152__(numTriggerEvents, 0))
		{
			numTriggerEvents = 0;
			SavedTrigger = none;
			Instigator = none;
			__NFUN_113__('TriggerPound', 'Close');
		}
		return;
	}

	function BeginState()
	{
		numTriggerEvents = 0;
		return;
	}
Open:

	bClosed = false;
	// End:0x25
	if(__NFUN_177__(DelayTime, float(0)))
	{
		bDelaying = true;
		__NFUN_256__(DelayTime);
	}
	DoOpen();
	__NFUN_301__();
	__NFUN_256__(OtherTime);
Close:


	DoClose();
	__NFUN_301__();
	__NFUN_256__(StayOpenTime);
	// End:0x57
	if(bTriggerOnceOnly)
	{
		__NFUN_113__('None');
	}
	// End:0x68
	if(__NFUN_119__(SavedTrigger, none))
	{
		goto 'Open';
	}
	stop;			
}

state() BumpButton
{
// When bumped by player.
	function Bump(Actor Other)
	{
		// End:0x24
		if(__NFUN_130__(__NFUN_155__(int(BumpType), int(2)), __NFUN_114__(Pawn(Other), none)))
		{
			return;
		}
		// End:0x51
		if(__NFUN_130__(__NFUN_154__(int(BumpType), int(0)), __NFUN_129__(Pawn(Other).IsPlayerPawn())))
		{
			return;
		}
		// End:0x7C
		if(__NFUN_130__(__NFUN_154__(int(BumpType), int(1)), __NFUN_176__(Other.Mass, float(10))))
		{
			return;
		}
		global.Bump(Other);
		SavedTrigger = Other;
		Instigator = Pawn(Other);
		Instigator.Controller.WaitForMover(self);
		__NFUN_113__('BumpButton', 'Open');
		return;
	}

	function BeginEvent()
	{
		bSlave = true;
		return;
	}

	function EndEvent()
	{
		bSlave = false;
		Instigator = none;
		__NFUN_113__('BumpButton', 'Close');
		return;
	}
Open:

	bClosed = false;
	__NFUN_118__('Bump');
	// End:0x2C
	if(__NFUN_177__(DelayTime, float(0)))
	{
		bDelaying = true;
		__NFUN_256__(DelayTime);
	}
	DoOpen();
	__NFUN_301__();
	FinishedOpening();
	// End:0x4B
	if(bTriggerOnceOnly)
	{
		__NFUN_113__('None');
	}
	// End:0x55
	if(bSlave)
	{
		stop;
	}
Close:


	DoClose();
	__NFUN_301__();
	FinishedClosing();
	__NFUN_117__('Bump');
	stop;				
}

state() ConstantLoop
{
// Interpolation ended.
	event KeyFrameReached()
	{
		// End:0x63
		if(bOscillatingLoop)
		{
			// End:0x42
			if(__NFUN_132__(__NFUN_154__(int(KeyNum), 0), __NFUN_154__(int(KeyNum), __NFUN_147__(int(NumKeys), 1))))
			{
				__NFUN_159__(StepDirection, float(-1));
				MoverLooped();
			}
			__NFUN_135__(KeyNum, byte(StepDirection));
			InterpolateTo(KeyNum, MoveTime);			
		}
		else
		{
			InterpolateTo(byte(__NFUN_173__(float(byte(__NFUN_146__(int(KeyNum), 1))), float(NumKeys))), MoveTime);
			// End:0x9A
			if(__NFUN_154__(int(KeyNum), 0))
			{
				MoverLooped();
			}
		}
		return;
	}

	function BeginState()
	{
		bOpening = false;
		bDelaying = false;
		return;
	}
Begin:

	InterpolateTo(1, MoveTime);
Running:


	__NFUN_301__();
	__NFUN_113__('ConstantLoop', 'Running');
	stop;			
}

state() LeadInOutLooper
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x42
		if(__NFUN_150__(int(NumKeys), 3))
		{
			__NFUN_231__("LeadInOutLooper detected with <3 movement keys");
			return;
		}
		InterpolateTo(1, MoveTime);
		return;
	}

// Interpolation ended.
	event KeyFrameReached()
	{
		// End:0x21
		if(__NFUN_155__(int(KeyNum), 0))
		{
			InterpolateTo(2, MoveTime);
			__NFUN_113__('LeadInOutLooping');
		}
		return;
	}

	function BeginState()
	{
		bOpening = false;
		bDelaying = false;
		return;
	}
	stop;
}

state LeadInOutLooping
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		InterpolateTo(0, MoveTime);
		__NFUN_113__('LeadInOutLooper');
		return;
	}

// Interpolation ended.
	event KeyFrameReached()
	{
		// End:0x63
		if(bOscillatingLoop)
		{
			// End:0x42
			if(__NFUN_132__(__NFUN_154__(int(KeyNum), 1), __NFUN_154__(int(KeyNum), __NFUN_147__(int(NumKeys), 1))))
			{
				__NFUN_159__(StepDirection, float(-1));
				MoverLooped();
			}
			__NFUN_135__(KeyNum, byte(StepDirection));
			InterpolateTo(KeyNum, MoveTime);			
		}
		else
		{
			__NFUN_139__(KeyNum);
			// End:0x8B
			if(__NFUN_154__(int(KeyNum), int(NumKeys)))
			{
				KeyNum = 1;
				MoverLooped();
			}
			InterpolateTo(KeyNum, MoveTime);
		}
		return;
	}
	stop;
}

state() RotatingMover
{
// NEW IN 1.60
	simulated function BaseStarted()
	{
		local Actor OldBase;

		bFixedRotationDir = true;
		OldBase = Base;
		__NFUN_3970__(5);
		__NFUN_298__(OldBase);
		return;
	}

// NEW IN 1.60
	simulated function BaseFinished()
	{
		local Actor OldBase;

		OldBase = Base;
		__NFUN_3970__(0);
		__NFUN_298__(OldBase);
		// End:0x5A
		if(bToggleDirection)
		{
			__NFUN_159__(RotationRate.Yaw, float(-1));
			__NFUN_159__(RotationRate.Pitch, float(-1));
			__NFUN_159__(RotationRate.Roll, float(-1));
		}
		return;
	}

	simulated function BeginState()
	{
		bAlwaysRelevant = true;
		RemoteRole = ROLE_None;
		return;
	}
	stop;
}

defaultproperties
{
	MoverEncroachType=1
	MoverGlideType=1
	NumKeys=2
	StepDirection=1
	bToggleDirection=true
	bClosed=true
	MoveTime=1.0000000
	StayOpenTime=4.0000000
	Physics=8
	RemoteRole=2
	bNoDelete=true
	bAcceptsProjectors=true
	m_bHandleRelativeProjectors=true
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true
	bShadowCast=true
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bEdShouldSnap=true
	bPathColliding=true
	m_bTickOnlyWhenVisible=true
	CollisionRadius=160.0000000
	CollisionHeight=160.0000000
	NetPriority=2.7000000
	InitialState="BumpOpenTimed"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var EMoverEncroachType
// REMOVED IN 1.60: var EMoverGlideType
// REMOVED IN 1.60: var EBumpType
// REMOVED IN 1.60: var KeyPos8
// REMOVED IN 1.60: var KeyRot8
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var bAutoDoor
// REMOVED IN 1.60: var w
// REMOVED IN 1.60: var l
// REMOVED IN 1.60: function TakeDamage
