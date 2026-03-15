//=============================================================================
// Mover - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
	reliable if((int(Role) == int(ROLE_Authority)))
		RealPosition, RealRotation, 
		SimInterpolate, SimOldPos, 
		SimOldRotPitch, SimOldRotRoll, 
		SimOldRotYaw;
}

simulated function StartInterpolation()
{
	GotoState('None');
	bInterpolating = true;
	m_bTickOnlyWhenVisible = false;
	SetPhysics(0);
	return;
}

simulated function Timer()
{
	// End:0x21
	if((Velocity != vect(0.0000000, 0.0000000, 0.0000000)))
	{
		bClientPause = false;
		return;
	}
	// End:0xB3
	if((int(Level.NetMode) == int(NM_Client)))
	{
		// End:0xA8
		if((ClientUpdate == 0))
		{
			// End:0x8E
			if(bClientPause)
			{
				// End:0x70
				if((VSize((RealPosition - Location)) > float(3)))
				{
					SetLocation(RealPosition);					
				}
				else
				{
					RealPosition = Location;
				}
				SetRotation(RealRotation);
				bClientPause = false;				
			}
			else
			{
				// End:0xA5
				if((RealPosition != Location))
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
	foreach BasedActors(Class'Engine.Mover', M)
	{
		M.BaseStarted();		
	}	
	NewKeyNum = byte(Clamp(int(NewKeyNum), 0, (24 - 1)));
	// End:0xAA
	if(((int(NewKeyNum) == int(PrevKeyNum)) && (int(KeyNum) != int(PrevKeyNum))))
	{
		PhysAlpha = (1.0000000 - PhysAlpha);
		OldPos = (BasePos + KeyPos[int(KeyNum)]);
		OldRot = (BaseRot + KeyRot[int(KeyNum)]);		
	}
	else
	{
		OldPos = Location;
		OldRot = Rotation;
		PhysAlpha = 0.0000000;
	}
	SetPhysics(8);
	bInterpolating = true;
	m_bTickOnlyWhenVisible = false;
	PrevKeyNum = KeyNum;
	KeyNum = NewKeyNum;
	PhysRate = (1.0000000 / FMax(Seconds, 0.0050000));
	(ClientUpdate++);
	SimOldPos = OldPos;
	SimOldRotYaw = OldRot.Yaw;
	SimOldRotPitch = OldRot.Pitch;
	SimOldRotRoll = OldRot.Roll;
	SimInterpolate.X = (100.0000000 * PhysAlpha);
	SimInterpolate.Y = (100.0000000 * FMax(0.0100000, PhysRate));
	SimInterpolate.Z = ((256.0000000 * float(PrevKeyNum)) + float(KeyNum));
	return;
}

// Set the specified keyframe.
final function SetKeyframe(byte NewKeyNum, Vector NewLocation, Rotator NewRotation)
{
	KeyNum = byte(Clamp(int(NewKeyNum), 0, (24 - 1)));
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
	(ClientUpdate--);
	// End:0x64
	if(((int(KeyNum) > 0) && (int(KeyNum) < int(OldKeyNum))))
	{
		InterpolateTo(byte((int(KeyNum) - 1)), MoveTime);		
	}
	else
	{
		// End:0xA9
		if(((int(KeyNum) < (int(NumKeys) - 1)) && (int(KeyNum) > int(OldKeyNum))))
		{
			InterpolateTo(byte((int(KeyNum) + 1)), MoveTime);			
		}
		else
		{
			AmbientSound = none;
			// End:0x10D
			if(((ClientUpdate == 0) && (int(Level.NetMode) != int(NM_Client))))
			{
				RealPosition = Location;
				RealRotation = Rotation;
				// End:0x10C
				foreach BasedActors(Class'Engine.Mover', M)
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
	if((C != none))
	{
		// End:0x58
		if(((C.Pawn != none) && (C.PendingMover == self)))
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

	PlaySound(ClosedSound, 3);
	TriggerEvent(ClosedEvent, self, Instigator);
	// End:0x35
	if((SavedTrigger != none))
	{
		SavedTrigger.EndEvent();
	}
	SavedTrigger = none;
	Instigator = none;
	// End:0x5D
	if((myMarker != none))
	{
		myMarker.MoverClosed();
	}
	bClosed = true;
	FinishNotify();
	M = Leader;
	J0x76:

	// End:0xAE [Loop If]
	if((M != none))
	{
		// End:0x97
		if((!M.bClosed))
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
	PlaySound(OpenedSound, 3);
	TriggerEvent(Event, self, Instigator);
	TriggerEvent(OpenedEvent, self, Instigator);
	// End:0x46
	if((myMarker != none))
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
	MakeNoise(1.0000000);
	PlaySound(OpeningSound, 3);
	AmbientSound = MoveAmbientSound;
	TriggerEvent(OpeningEvent, self, Instigator);
	// End:0x65
	if((Follower != none))
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
	InterpolateTo(byte(Max(0, (int(KeyNum) - 1))), MoveTime);
	MakeNoise(1.0000000);
	PlaySound(ClosingSound, 3);
	UntriggerEvent(Event, self, Instigator);
	AmbientSound = MoveAmbientSound;
	TriggerEvent(ClosingEvent, self, Instigator);
	// End:0x83
	if((Follower != none))
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
	if((AntiPortalTag != 'None'))
	{
		// End:0x4A
		foreach AllActors(Class'Engine.AntiPortalActor', AntiPortal, AntiPortalTag)
		{
			AntiPortals.Length = (AntiPortals.Length + 1);
			AntiPortals[(AntiPortals.Length - 1)] = AntiPortal;			
		}		
	}
	// End:0xA4
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		// End:0x89
		if((int(Level.NetMode) == int(NM_Client)))
		{
			SetTimer(4.0000000, true);			
		}
		else
		{
			SetTimer(1.0000000, true);
		}
		// End:0xA4
		if((int(Role) < int(ROLE_Authority)))
		{
			return;
		}
	}
	// End:0xD3
	if((int(Level.NetMode) != int(NM_Client)))
	{
		RealPosition = Location;
		RealRotation = Rotation;
	}
	super.BeginPlay();
	KeyNum = byte(Clamp(int(KeyNum), 0, (24 - 1)));
	PhysAlpha = 0.0000000;
	Move(((BasePos + KeyPos[int(KeyNum)]) - Location));
	SetRotation((BaseRot + KeyRot[int(KeyNum)]));
	// End:0x14B
	if((ReturnGroup == 'None'))
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
	if((!bSlave))
	{
		// End:0x50
		foreach DynamicActors(Class'Engine.Mover', M, Tag)
		{
			// End:0x4F
			if(M.bSlave)
			{
				M.GotoState('None');
				M.SetBase(self);
			}			
		}		
	}
	// End:0xCA
	if(bIsLeader)
	{
		Leader = self;
		// End:0xC6
		foreach DynamicActors(Class'Engine.Mover', M)
		{
			// End:0xC5
			if(((M != self) && (M.ReturnGroup == ReturnGroup)))
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
		if((Leader == none))
		{
			// End:0x10E
			foreach DynamicActors(Class'Engine.Mover', M)
			{
				// End:0x10D
				if(((M != self) && (M.ReturnGroup == ReturnGroup)))
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
	GotoState(, 'None');
	// End:0x3E
	if((Follower != none))
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
	if((bIsLeader || (Leader == self)))
	{
		// End:0x50
		if((int(KeyNum) < int(PrevKeyNum)))
		{
			GotoState(, 'Open');			
		}
		else
		{
			GotoState(, 'Close');
		}
	}
	// End:0x72
	if((Follower != none))
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
	if((Other == none))
	{
		return false;
	}
	// End:0x3A
	if(((Pawn(Other) != none) && (Pawn(Other).Controller == none)))
	{
		return false;
	}
	P = Pawn(Other);
	// End:0xFB
	if((((P != none) && (P.Controller != none)) && P.IsPlayerPawn()))
	{
		// End:0x99
		if((PlayerBumpEvent != 'None'))
		{
			Bump(Other);
		}
		// End:0xFB
		if((((P.Controller != none) && (P.Base != self)) && (P.Controller.PendingMover == self)))
		{
			P.Controller.UnderLift(self);
		}
	}
	// End:0x11F
	if((int(MoverEncroachType) == int(0)))
	{
		Leader.MakeGroupStop();
		return true;		
	}
	else
	{
		// End:0x16B
		if((int(MoverEncroachType) == int(1)))
		{
			Leader.MakeGroupReturn();
			// End:0x166
			if(Other.IsA('Pawn'))
			{
				Pawn(Other).PlayMoverHitSound();
			}
			return true;			
		}
		else
		{
			// End:0x194
			if((int(MoverEncroachType) == int(2)))
			{
				Other.KilledBy(Instigator);
				return false;				
			}
			else
			{
				// End:0x1A6
				if((int(MoverEncroachType) == int(3)))
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
	if((((bUseTriggered && (P != none)) && (!P.IsHumanControlled())) && P.IsPlayerPawn()))
	{
		Trigger(P, P);
		P.Controller.WaitForMover(self);
	}
	// End:0x98
	if(((int(BumpType) != int(2)) && (P == none)))
	{
		return;
	}
	// End:0xC0
	if(((int(BumpType) == int(0)) && (!P.IsPlayerPawn())))
	{
		return;
	}
	// End:0xE6
	if(((int(BumpType) == int(1)) && P.bAmbientCreature))
	{
		return;
	}
	TriggerEvent(BumpEvent, self, P);
	// End:0x127
	if(((P != none) && P.IsPlayerPawn()))
	{
		TriggerEvent(PlayerBumpEvent, self, P);
	}
	return;
}

// NEW IN 1.60
function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	// End:0x7D
	if((bDamageTriggered && (float(iKillValue) >= DamageThreshold)))
	{
		// End:0x6C
		if(((AIController(instigatedBy.Controller) != none) && (instigatedBy.Controller.Focus == self)))
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
	if((LoopSound != none))
	{
		PlaySound(LoopSound, 3);
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
	if((DelayTime > float(0)))
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Sleep(StayOpenTime);
	// End:0x52
	if(bTriggerOnceOnly)
	{
		GotoState('None');
	}
Close:


	DoClose();
	FinishInterpolation();
	FinishedClosing();
	EnableTrigger();
	Sleep(StayOpenTime);
	// End:0x8B
	if(ShouldReTrigger())
	{
		SavedTrigger = none;
		GotoState('StandOpenTimed', 'Open');
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
		if((i < Attached.Length))
		{
			// End:0x2D
			if(CanTrigger(Attached[i]))
			{
				return true;
			}
			(i++);
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
		if(((int(BumpType) != int(2)) && (P == none)))
		{
			return false;
		}
		// End:0x57
		if(((int(BumpType) == int(0)) && (!P.IsPlayerPawn())))
		{
			return false;
		}
		// End:0x82
		if(((int(BumpType) == int(1)) && (Other.Mass < float(10))))
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
		if((!CanTrigger(Other)))
		{
			return;
		}
		SavedTrigger = none;
		GotoState('StandOpenTimed', 'Open');
		return;
	}

	function DisableTrigger()
	{
		Disable('Attach');
		return;
	}

	function EnableTrigger()
	{
		Enable('Attach');
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
		if(((int(BumpType) != int(2)) && (Pawn(Other) == none)))
		{
			return;
		}
		// End:0x51
		if(((int(BumpType) == int(0)) && (!Pawn(Other).IsPlayerPawn())))
		{
			return;
		}
		// End:0x7C
		if(((int(BumpType) == int(1)) && (Other.Mass < float(10))))
		{
			return;
		}
		global.Bump(Other);
		SavedTrigger = none;
		Instigator = Pawn(Other);
		// End:0xC2
		if((Instigator != none))
		{
			Instigator.Controller.WaitForMover(self);
		}
		GotoState('BumpOpenTimed', 'Open');
		return;
	}

	function DisableTrigger()
	{
		Disable('Bump');
		return;
	}

	function EnableTrigger()
	{
		Enable('Bump');
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
		if((SavedTrigger != none))
		{
			SavedTrigger.BeginEvent();
		}
		GotoState('TriggerOpenTimed', 'Open');
		return;
	}

	function DisableTrigger()
	{
		Disable('Trigger');
		return;
	}

	function EnableTrigger()
	{
		Enable('Trigger');
		return;
	}
	stop;
}

state() LoopMove
{
	event Trigger(Actor Other, Pawn EventInstigator)
	{
		Disable('Trigger');
		Enable('UnTrigger');
		SavedTrigger = Other;
		Instigator = EventInstigator;
		// End:0x3E
		if((SavedTrigger != none))
		{
			SavedTrigger.BeginEvent();
		}
		bOpening = true;
		PlaySound(OpeningSound, 3);
		AmbientSound = MoveAmbientSound;
		GotoState('LoopMove', 'Running');
		return;
	}

	event UnTrigger(Actor Other, Pawn EventInstigator)
	{
		Disable('UnTrigger');
		Enable('Trigger');
		SavedTrigger = Other;
		Instigator = EventInstigator;
		GotoState('LoopMove', 'Stopping');
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

	FinishInterpolation();
	InterpolateTo(byte((float(byte((int(KeyNum) + 1))) % float(NumKeys))), MoveTime);
	GotoState('LoopMove', 'Running');
Stopping:


	FinishInterpolation();
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
		if((SavedTrigger != none))
		{
			SavedTrigger.BeginEvent();
		}
		// End:0x61
		if(((int(KeyNum) == 0) || (int(KeyNum) < int(PrevKeyNum))))
		{
			GotoState('TriggerToggle', 'Open');			
		}
		else
		{
			GotoState('TriggerToggle', 'Close');
		}
		return;
	}
Open:

	bClosed = false;
	// End:0x25
	if((DelayTime > float(0)))
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	// End:0x4E
	if((SavedTrigger != none))
	{
		SavedTrigger.EndEvent();
	}
	stop;
Close:


	DoClose();
	FinishInterpolation();
	FinishedClosing();
	stop;	
}

state() TriggerControl
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		(numTriggerEvents++);
		SavedTrigger = Other;
		Instigator = EventInstigator;
		// End:0x37
		if((SavedTrigger != none))
		{
			SavedTrigger.BeginEvent();
		}
		GotoState('TriggerControl', 'Open');
		return;
	}

	function UnTrigger(Actor Other, Pawn EventInstigator)
	{
		(numTriggerEvents--);
		// End:0x4A
		if((numTriggerEvents <= 0))
		{
			numTriggerEvents = 0;
			SavedTrigger = Other;
			Instigator = EventInstigator;
			SavedTrigger.BeginEvent();
			GotoState('TriggerControl', 'Close');
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
	if((DelayTime > float(0)))
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	SavedTrigger.EndEvent();
	// End:0x53
	if(bTriggerOnceOnly)
	{
		GotoState('None');
	}
	stop;
Close:


	DoClose();
	FinishInterpolation();
	FinishedClosing();
	stop;				
}

state() TriggerPound
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		(numTriggerEvents++);
		SavedTrigger = Other;
		Instigator = EventInstigator;
		GotoState('TriggerPound', 'Open');
		return;
	}

	function UnTrigger(Actor Other, Pawn EventInstigator)
	{
		(numTriggerEvents--);
		// End:0x33
		if((numTriggerEvents <= 0))
		{
			numTriggerEvents = 0;
			SavedTrigger = none;
			Instigator = none;
			GotoState('TriggerPound', 'Close');
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
	if((DelayTime > float(0)))
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	Sleep(OtherTime);
Close:


	DoClose();
	FinishInterpolation();
	Sleep(StayOpenTime);
	// End:0x57
	if(bTriggerOnceOnly)
	{
		GotoState('None');
	}
	// End:0x68
	if((SavedTrigger != none))
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
		if(((int(BumpType) != int(2)) && (Pawn(Other) == none)))
		{
			return;
		}
		// End:0x51
		if(((int(BumpType) == int(0)) && (!Pawn(Other).IsPlayerPawn())))
		{
			return;
		}
		// End:0x7C
		if(((int(BumpType) == int(1)) && (Other.Mass < float(10))))
		{
			return;
		}
		global.Bump(Other);
		SavedTrigger = Other;
		Instigator = Pawn(Other);
		Instigator.Controller.WaitForMover(self);
		GotoState('BumpButton', 'Open');
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
		GotoState('BumpButton', 'Close');
		return;
	}
Open:

	bClosed = false;
	Disable('Bump');
	// End:0x2C
	if((DelayTime > float(0)))
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	// End:0x4B
	if(bTriggerOnceOnly)
	{
		GotoState('None');
	}
	// End:0x55
	if(bSlave)
	{
		stop;
	}
Close:


	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable('Bump');
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
			if(((int(KeyNum) == 0) || (int(KeyNum) == (int(NumKeys) - 1))))
			{
				(StepDirection *= float(-1));
				MoverLooped();
			}
			(KeyNum += byte(StepDirection));
			InterpolateTo(KeyNum, MoveTime);			
		}
		else
		{
			InterpolateTo(byte((float(byte((int(KeyNum) + 1))) % float(NumKeys))), MoveTime);
			// End:0x9A
			if((int(KeyNum) == 0))
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


	FinishInterpolation();
	GotoState('ConstantLoop', 'Running');
	stop;			
}

state() LeadInOutLooper
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x42
		if((int(NumKeys) < 3))
		{
			Log("LeadInOutLooper detected with <3 movement keys");
			return;
		}
		InterpolateTo(1, MoveTime);
		return;
	}

// Interpolation ended.
	event KeyFrameReached()
	{
		// End:0x21
		if((int(KeyNum) != 0))
		{
			InterpolateTo(2, MoveTime);
			GotoState('LeadInOutLooping');
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
		GotoState('LeadInOutLooper');
		return;
	}

// Interpolation ended.
	event KeyFrameReached()
	{
		// End:0x63
		if(bOscillatingLoop)
		{
			// End:0x42
			if(((int(KeyNum) == 1) || (int(KeyNum) == (int(NumKeys) - 1))))
			{
				(StepDirection *= float(-1));
				MoverLooped();
			}
			(KeyNum += byte(StepDirection));
			InterpolateTo(KeyNum, MoveTime);			
		}
		else
		{
			(KeyNum++);
			// End:0x8B
			if((int(KeyNum) == int(NumKeys)))
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
		SetPhysics(5);
		SetBase(OldBase);
		return;
	}

// NEW IN 1.60
	simulated function BaseFinished()
	{
		local Actor OldBase;

		OldBase = Base;
		SetPhysics(0);
		SetBase(OldBase);
		// End:0x5A
		if(bToggleDirection)
		{
			(RotationRate.Yaw *= float(-1));
			(RotationRate.Pitch *= float(-1));
			(RotationRate.Roll *= float(-1));
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
