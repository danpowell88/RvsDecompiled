//=============================================================================
// SpecialEventTrigger: Receives trigger messages and does some "special event"
// some combination of a message, sound playing, damage, and/or death to the instigator
// if the event of this actor is set, will try to send player on the interpolation path
// with tag matching this event.
//=============================================================================
class SpecialEventTrigger extends Triggers;

#exec Texture Import File=..\engine\Textures\TrigSpcl.pcx Name=S_SpecialEvent Mips=Off MASKED=1

// --- Variables ---
var localized string Message;
var int Damage;
var Sound Sound;
var name InterpolatedActorTag;
var name PlayerScriptTag;
var bool bBroadcast;
var bool bPlayersPlaySoundEffect;
var bool bKillInstigator;
var bool bViewTargetInterpolatedActor;
var bool bThirdPersonViewTarget;
var bool bPlayerJumpToInterpolation;

// --- Functions ---
function Trigger(Pawn EventInstigator, Actor Other) {}

defaultproperties
{
}
