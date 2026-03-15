//=============================================================================
// Trigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Trigger: senses things happening in its proximity and generates 
// sends Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================
class Trigger extends Triggers
    native
    placeable;

enum ETriggerType
{
	TT_PlayerProximity,             // 0
	TT_PawnProximity,               // 1
	TT_ClassProximity,              // 2
	TT_AnyProximity,                // 3
	TT_Shoot,                       // 4
	TT_HumanPlayerProximity         // 5
};

// NEW IN 1.60
var() Trigger.ETriggerType TriggerType;
// Only trigger once and then go dormant.
var() bool bTriggerOnceOnly;
// For triggers that are activated/deactivated by other triggers.
var() bool bInitiallyActive;
var bool bSavedInitialCollision;
var bool bSavedInitialActive;
//R6Alarms
var(R6Alarm) bool m_bAlarm;
var() float RepeatTriggerTime;  // if > 0, repeat trigger message at this interval is still touching other
var() float ReTriggerDelay;  // minimum time before trigger can be triggered again
var float TriggerTime;
var() float DamageThreshold;  // minimum damage to trigger if TT_Shoot
// AI vars
var Actor TriggerActor;  // actor that triggers this trigger
var Actor TriggerActor2;
var(R6Alarm) R6Alarm m_pAlarm;
var() Class<Actor> ClassProximityType;
// Human readable triggering message.
var() localized string Message;

function PreBeginPlay()
{
	super(Actor).PreBeginPlay();
	// End:0x65
	if(((((int(TriggerType) == int(0)) || (int(TriggerType) == int(1))) || (int(TriggerType) == int(5))) || ((int(TriggerType) == int(2)) && ClassIsChildOf(ClassProximityType, Class'Engine.Pawn'))))
	{
		OnlyAffectPawns(true);
	}
	return;
}

function PostBeginPlay()
{
	// End:0x11
	if((!bInitiallyActive))
	{
		FindTriggerActor();
	}
	// End:0x39
	if((int(TriggerType) == int(4)))
	{
		bHidden = false;
		bProjTarget = true;
		SetDrawType(0);
	}
	bSavedInitialActive = bInitiallyActive;
	bSavedInitialCollision = bCollideActors;
	super(Actor).PostBeginPlay();
	return;
}

function Reset()
{
	super(Actor).Reset();
	bInitiallyActive = bSavedInitialActive;
	SetCollision(bSavedInitialCollision, bBlockActors, bBlockPlayers);
	return;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super(Actor).ResetOriginalData();
	bInitiallyActive = bSavedInitialActive;
	SetCollision(bSavedInitialCollision, bBlockActors, bBlockPlayers);
	return;
}

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = none;
	TriggerActor2 = none;
	// End:0x5E
	foreach AllActors(Class'Engine.Actor', A)
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

function Actor SpecialHandling(Pawn Other)
{
	local Actor A;

	// End:0x18
	if((bTriggerOnceOnly && (!bCollideActors)))
	{
		return none;
	}
	// End:0x40
	if(((int(TriggerType) == int(5)) && (!Other.IsHumanControlled())))
	{
		return none;
	}
	// End:0x68
	if(((int(TriggerType) == int(0)) && (!Other.IsPlayerPawn())))
	{
		return none;
	}
	// End:0xF2
	if((!bInitiallyActive))
	{
		// End:0x84
		if((TriggerActor == none))
		{
			FindTriggerActor();
		}
		// End:0x91
		if((TriggerActor == none))
		{
			return none;
		}
		// End:0xEC
		if(((TriggerActor2 != none) && (VSize((TriggerActor2.Location - Other.Location)) < VSize((TriggerActor.Location - Other.Location)))))
		{
			return TriggerActor2;			
		}
		else
		{
			return TriggerActor;
		}
	}
	// End:0x12E
	if(IsRelevant(Other))
	{
		// End:0x12B
		foreach TouchingActors(Class'Engine.Actor', A)
		{
			// End:0x12A
			if((A == Other))
			{
				Touch(Other);
			}			
		}		
		return self;
	}
	return self;
	return;
}

function CheckTouchList()
{
	local Actor A;

	// End:0x1C
	foreach TouchingActors(Class'Engine.Actor', A)
	{
		Touch(A);		
	}	
	return;
}

//
// See whether the other actor is relevant to this trigger.
//
function bool IsRelevant(Actor Other)
{
	// End:0x0D
	if((!bInitiallyActive))
	{
		return false;
	}
	switch(TriggerType)
	{
		// End:0x40
		case 5:
			return ((Pawn(Other) != none) && Pawn(Other).IsHumanControlled());
		// End:0x6C
		case 0:
			return ((Pawn(Other) != none) && Pawn(Other).IsPlayerPawn());
		// End:0x99
		case 1:
			return ((Pawn(Other) != none) && Pawn(Other).CanTrigger(self));
		// End:0xB5
		case 2:
			return ClassIsChildOf(Other.Class, ClassProximityType);
		// End:0xBC
		case 3:
			return true;
		// End:0xFFFF
		default:
			return;
			break;
	}
}

//
// Called when something touches the trigger.
//
function Touch(Actor Other)
{
	local int i;

	// End:0x18C
	if(IsRelevant(Other))
	{
		// End:0x50
		if((ReTriggerDelay > float(0)))
		{
			// End:0x3C
			if(((Level.TimeSeconds - TriggerTime) < ReTriggerDelay))
			{
				return;
			}
			TriggerTime = Level.TimeSeconds;
		}
		TriggerEvent(Event, self, Other.Instigator);
		// End:0x90
		if(m_bAlarm)
		{
			m_pAlarm.SetAlarm(Other.Location);
		}
		// End:0x127
		if(((Pawn(Other) != none) && (Pawn(Other).Controller != none)))
		{
			i = 0;
			J0xC2:

			// End:0x127 [Loop If]
			if((i < 4))
			{
				// End:0x11D
				if((Pawn(Other).Controller.GoalList[i] == self))
				{
					Pawn(Other).Controller.GoalList[i] = none;
					// [Explicit Break]
					goto J0x127;
				}
				(i++);
				// [Loop Continue]
				goto J0xC2;
			}
		}
		J0x127:

		// End:0x166
		if(((Message != "") && (Other.Instigator != none)))
		{
			Other.Instigator.ClientMessage(Message);
		}
		// End:0x176
		if(bTriggerOnceOnly)
		{
			SetCollision(false);			
		}
		else
		{
			// End:0x18C
			if((RepeatTriggerTime > float(0)))
			{
				SetTimer(RepeatTriggerTime, false);
			}
		}
	}
	return;
}

function Timer()
{
	local bool bKeepTiming;
	local Actor A;

	bKeepTiming = false;
	// End:0x3A
	foreach TouchingActors(Class'Engine.Actor', A)
	{
		// End:0x39
		if(IsRelevant(A))
		{
			bKeepTiming = true;
			Touch(A);
		}		
	}	
	// End:0x4D
	if(bKeepTiming)
	{
		SetTimer(RepeatTriggerTime, false);
	}
	return;
}

function int TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	// End:0xE1
	if((((bInitiallyActive && (int(TriggerType) == int(4))) && (float(iKillValue) >= DamageThreshold)) && (instigatedBy != none)))
	{
		// End:0x7D
		if((ReTriggerDelay > float(0)))
		{
			// End:0x69
			if(((Level.TimeSeconds - TriggerTime) < ReTriggerDelay))
			{
				return 0;
			}
			TriggerTime = Level.TimeSeconds;
		}
		TriggerEvent(Event, self, instigatedBy);
		// End:0xAB
		if(m_bAlarm)
		{
			m_pAlarm.SetAlarm(vHitLocation);
		}
		// End:0xD4
		if((Message != ""))
		{
			instigatedBy.Instigator.ClientMessage(Message);
		}
		// End:0xE1
		if(bTriggerOnceOnly)
		{
			SetCollision(false);
		}
	}
	return 0;
	return;
}

//
// When something untouches the trigger.
//
function UnTouch(Actor Other)
{
	// End:0x28
	if(IsRelevant(Other))
	{
		UntriggerEvent(Event, self, Other.Instigator);
	}
	return;
}

state() NormalTrigger
{	stop;
}

state() OtherTriggerToggles
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		bInitiallyActive = (!bInitiallyActive);
		// End:0x1E
		if(bInitiallyActive)
		{
			CheckTouchList();
		}
		return;
	}
	stop;
}

state() OtherTriggerTurnsOn
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		local bool bWasActive;

		bWasActive = bInitiallyActive;
		bInitiallyActive = true;
		// End:0x26
		if((!bWasActive))
		{
			CheckTouchList();
		}
		return;
	}
	stop;
}

state() OtherTriggerTurnsOff
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		bInitiallyActive = false;
		return;
	}
	stop;
}

defaultproperties
{
	bInitiallyActive=true
	Texture=Texture'Engine.S_Trigger'
	InitialState="NormalTrigger"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var ETriggerType
// REMOVED IN 1.60: function R6TakeDamage
