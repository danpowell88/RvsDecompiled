//=============================================================================
// Volume:  a bounding volume
// touch() and untouch() notifications to the volume as actors enter or leave it
// enteredvolume() and leftvolume() notifications when center of actor enters the volume
// pawns with bIsPlayer==true  cause playerenteredvolume notifications instead of actorenteredvolume()
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Volume extends Brush
    native;

// --- Variables ---
// this actor gets touch() and untouch notifications as the volume is entered or left
var Actor AssociatedActor;
var name AssociatedActorTag;
// ^ NEW IN 1.60
var localized string LocationName;
// ^ NEW IN 1.60
var int LocationPriority;
// ^ NEW IN 1.60
var DecorationList DecoList;
// ^ NEW IN 1.60

// --- Functions ---
// function ? touch(...); // REMOVED IN 1.60
// function ? untouch(...); // REMOVED IN 1.60
function PostBeginPlay() {}
native function bool Encompasses(Actor Other) {}
// ^ NEW IN 1.60
function DisplayDebug(Canvas Canvas, out float YPos, out float YL) {}

state AssociatedTouch
{
    event UnTouch(Actor Other) {}
// ^ NEW IN 1.60
    event Touch(Actor Other) {}
// ^ NEW IN 1.60
    function BeginState() {}
}

defaultproperties
{
}
