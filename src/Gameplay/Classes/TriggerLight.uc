//=============================================================================
// TriggerLight - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// TriggerLight.
// A lightsource which can be triggered on or off.
//=============================================================================
class TriggerLight extends Light;

var() bool bInitiallyOn;  // Whether it's initially on.
var() bool bDelayFullOn;  // Delay then go full-on.
var() float ChangeTime;  // Time light takes to change from on to off.
var() float RemainOnTime;  // How long the TriggerPound effect lasts
var float InitialBrightness;  // Initial brightness.
var float Alpha;
// NEW IN 1.60
var float direction;
var float poundTime;
var Actor SavedTrigger;

// Called at start of gameplay.
simulated function BeginPlay()
{
	InitialBrightness = LightBrightness;
	// End:0x2D
	if(bInitiallyOn)
	{
		Alpha = 1.0000000;
		direction = 1.0000000;		
	}
	else
	{
		Alpha = 0.0000000;
		direction = -1.0000000;
	}
	SetDrawType(0);
	return;
}

// Called whenever time passes.
function Tick(float DeltaTime)
{
	(Alpha += ((direction * DeltaTime) / ChangeTime));
	// End:0x58
	if((Alpha > 1.0000000))
	{
		Alpha = 1.0000000;
		Disable('Tick');
		// End:0x55
		if((SavedTrigger != none))
		{
			SavedTrigger.EndEvent();
		}		
	}
	else
	{
		// End:0x93
		if((Alpha < 0.0000000))
		{
			Alpha = 0.0000000;
			Disable('Tick');
			// End:0x93
			if((SavedTrigger != none))
			{
				SavedTrigger.EndEvent();
			}
		}
	}
	// End:0xB3
	if((!bDelayFullOn))
	{
		LightBrightness = (Alpha * InitialBrightness);		
	}
	else
	{
		// End:0xEC
		if((((direction > float(0)) && (Alpha != float(1))) || (Alpha == float(0))))
		{
			LightBrightness = 0.0000000;			
		}
		else
		{
			LightBrightness = InitialBrightness;
		}
	}
	return;
}

state() TriggerTurnsOn
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x1A
		if((SavedTrigger != none))
		{
			SavedTrigger.EndEvent();
		}
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		direction = 1.0000000;
		Enable('Tick');
		return;
	}
	stop;
}

state() TriggerTurnsOff
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x1A
		if((SavedTrigger != none))
		{
			SavedTrigger.EndEvent();
		}
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		direction = -1.0000000;
		Enable('Tick');
		return;
	}
	stop;
}

state() TriggerToggle
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x1A
		if((SavedTrigger != none))
		{
			SavedTrigger.EndEvent();
		}
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		(direction *= float(-1));
		Enable('Tick');
		return;
	}
	stop;
}

state() TriggerControl
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x1A
		if((SavedTrigger != none))
		{
			SavedTrigger.EndEvent();
		}
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		// End:0x4B
		if(bInitiallyOn)
		{
			direction = -1.0000000;			
		}
		else
		{
			direction = 1.0000000;
		}
		Enable('Tick');
		return;
	}

	function UnTrigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x1A
		if((SavedTrigger != none))
		{
			SavedTrigger.EndEvent();
		}
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		// End:0x4B
		if(bInitiallyOn)
		{
			direction = 1.0000000;			
		}
		else
		{
			direction = -1.0000000;
		}
		Enable('Tick');
		return;
	}
	stop;
}

state() TriggerPound
{
	function Timer()
	{
		// End:0x16
		if((poundTime >= RemainOnTime))
		{
			Disable('Timer');
		}
		(poundTime += ChangeTime);
		(direction *= float(-1));
		SetTimer(ChangeTime, false);
		return;
	}

	function Trigger(Actor Other, Pawn EventInstigator)
	{
		// End:0x1A
		if((SavedTrigger != none))
		{
			SavedTrigger.EndEvent();
		}
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		direction = 1.0000000;
		poundTime = ChangeTime;
		SetTimer(ChangeTime, false);
		Enable('Timer');
		Enable('Tick');
		return;
	}
	stop;
}

defaultproperties
{
	RemoteRole=2
	bStatic=false
	bHidden=false
	bMovable=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var n
