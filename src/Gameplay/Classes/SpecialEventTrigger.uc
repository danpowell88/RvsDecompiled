//=============================================================================
// SpecialEventTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// SpecialEventTrigger: Receives trigger messages and does some "special event"
// some combination of a message, sound playing, damage, and/or death to the instigator
// if the event of this actor is set, will try to send player on the interpolation path
// with tag matching this event.
//=============================================================================
class SpecialEventTrigger extends Triggers;

var() int Damage;  // how much to damage triggering actor
var() bool bBroadcast;  // To broadcast the message to all players.
var() bool bPlayerJumpToInterpolation;  // if true, player is teleported to start of interpolation path
var() bool bPlayersPlaySoundEffect;  // if true, have sound effect played at players' location
var() bool bKillInstigator;  // if true, kill the instigator
var() bool bViewTargetInterpolatedActor;  // if true, playercontroller viewtargets the interpolated actor
var() bool bThirdPersonViewTarget;  // if true, playercontroller third person views the interpolated actor
var() Sound Sound;  // if not none, this sound effect will be played
var() name InterpolatedActorTag;  // tag of actor to send on interpolation path (if none, then instigator is used)
var() name PlayerScriptTag;  // tag of scripted sequence to put player's pawn while player is viewtargeting another actor
var() localized string Message;  // message to display

function Trigger(Actor Other, Pawn EventInstigator)
{
	local PlayerController P;
	local InterpolationPoint i;
	local ScriptedSequence S;
	local ScriptedController C;
	local Actor A;

	// End:0x6E
	if(__NFUN_155__(__NFUN_125__(Message), 0))
	{
		// End:0x40
		if(bBroadcast)
		{
			Level.Game.Broadcast(EventInstigator, Message, 'CriticalEvent');			
		}
		else
		{
			// End:0x6E
			if(__NFUN_130__(__NFUN_155__(__NFUN_125__(Message), 0), __NFUN_119__(EventInstigator, none)))
			{
				EventInstigator.ClientMessage(Message);
			}
		}
	}
	// End:0xB7
	if(__NFUN_119__(Sound, none))
	{
		// End:0xAD
		if(bPlayersPlaySoundEffect)
		{
			// End:0xA9
			foreach __NFUN_313__(Class'Engine.PlayerController', P)
			{
				P.ClientPlaySound(Sound, 3);				
			}						
		}
		else
		{
			__NFUN_264__(Sound, 3);
		}
	}
	// End:0xFC
	if(__NFUN_151__(Damage, 0))
	{
		Other.R6TakeDamage(Damage, Damage, EventInstigator, EventInstigator.Location, vect(0.0000000, 0.0000000, 0.0000000), 0);
	}
	// End:0x109
	if(__NFUN_114__(EventInstigator, none))
	{
		return;
	}
	// End:0x128
	if(__NFUN_119__(AmbientSound, none))
	{
		EventInstigator.AmbientSound = AmbientSound;
	}
	// End:0x14F
	if(bKillInstigator)
	{
		EventInstigator.Died(none, EventInstigator.Location);
	}
	// End:0x300
	if(__NFUN_130__(__NFUN_130__(__NFUN_255__(Event, 'None'), __NFUN_255__(Event, 'None')), __NFUN_154__(int(Level.NetMode), int(NM_Standalone))))
	{
		// End:0x1E3
		if(__NFUN_132__(__NFUN_254__(InterpolatedActorTag, 'None'), __NFUN_254__(InterpolatedActorTag, 'None')))
		{
			// End:0x1DE
			if(EventInstigator.IsPlayerPawn())
			{
				A = EventInstigator;
				// End:0x1DB
				if(A.bInterpolating)
				{
					return;
				}				
			}
			else
			{
				return;
			}			
		}
		else
		{
			// End:0x1FC
			foreach __NFUN_313__(Class'Engine.Actor', A, InterpolatedActorTag)
			{
				// End:0x1FC
				break;				
			}			
			// End:0x21E
			if(__NFUN_132__(__NFUN_114__(A, none), A.bInterpolating))
			{
				return;
			}
			// End:0x300
			if(__NFUN_130__(bViewTargetInterpolatedActor, EventInstigator.IsHumanControlled()))
			{
				PlayerController(EventInstigator.Controller).SetViewTarget(A);
				PlayerController(EventInstigator.Controller).bBehindView = bThirdPersonViewTarget;
				// End:0x300
				if(__NFUN_255__(PlayerScriptTag, 'None'))
				{
					// End:0x2A9
					foreach __NFUN_313__(Class'Gameplay.ScriptedSequence', S, PlayerScriptTag)
					{
						// End:0x2A9
						break;						
					}					
					// End:0x300
					if(__NFUN_119__(S, none))
					{
						EventInstigator.Controller.Pawn = none;
						PlayerController(EventInstigator.Controller).__NFUN_113__('Spectating');
						S.TakeOver(EventInstigator);
					}
				}
			}
		}
	}
	return;
}

defaultproperties
{
	bPlayerJumpToInterpolation=true
	Texture=Texture'Gameplay.S_SpecialEvent'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var DamageType
