///=============================================================================
// Teleports actors either between different teleporters within a level
// or to matching teleporters on other levels, or to general Internet URLs.
//=============================================================================
class Teleporter extends SmallNavigationPoint
    native;

#exec Texture Import File=Textures\Teleport.pcx Name=S_Teleport Mips=Off MASKED=1

// --- Variables ---
// AI related
//used to tell AI how to trigger me
var Actor TriggerActor;
var /* replicated */ string URL;
// ^ NEW IN 1.60
var /* replicated */ bool bEnabled;
// ^ NEW IN 1.60
var Actor TriggerActor2;
var /* replicated */ bool bChangesYaw;
// ^ NEW IN 1.60
var float LastFired;
var /* replicated */ bool bChangesVelocity;
// ^ NEW IN 1.60
var /* replicated */ bool bReversesX;
// ^ NEW IN 1.60
var /* replicated */ bool bReversesY;
// ^ NEW IN 1.60
var /* replicated */ bool bReversesZ;
// ^ NEW IN 1.60
var /* replicated */ Vector TargetVelocity;
// ^ NEW IN 1.60
var name ProductRequired;
// ^ NEW IN 1.60

// --- Functions ---
function Trigger(Actor Other, Pawn EventInstigator) {}
function FindTriggerActor() {}
function Actor SpecialHandling(Pawn Other) {}
// ^ NEW IN 1.60
// Teleporter was touched by an actor.
simulated function Touch(Actor Other) {}
// Accept an actor that has teleported in.
simulated function bool Accept(Actor Incoming, Actor Source) {}
// ^ NEW IN 1.60
function PostBeginPlay() {}

defaultproperties
{
}
