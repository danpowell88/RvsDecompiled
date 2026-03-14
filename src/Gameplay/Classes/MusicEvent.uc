//=============================================================================
// MusicEvent.
// OBSOLETE - superceded by ScriptedTrigger
//=============================================================================
class MusicEvent extends Triggers
    notplaceable;

// --- Variables ---
var string Song;
var EMusicTransition Transition;
var bool bAffectAllPlayers;
var bool bOnceOnly;
var bool bSilence;

// --- Functions ---
// When triggered.
function Trigger(Pawn EventInstigator, Actor Other) {}
// When gameplay starts.
function BeginPlay() {}

defaultproperties
{
}
