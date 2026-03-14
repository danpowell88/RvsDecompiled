// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class LadderVolume extends PhysicsVolume
    native;

// --- Variables ---
var Pawn PendingClimber;
// pawn can move in this direction (or reverse)
var Vector ClimbDir;
var Vector LookDir;
var Rotator WallDir;
// ^ NEW IN 1.60
// list of Ladder actors associated with this LadderVolume
var const Ladder LadderList;
var bool bAutoPath;
// ^ NEW IN 1.60
var name ClimbingAnimation;
// ^ NEW IN 1.60
var name TopAnimation;
// ^ NEW IN 1.60
var bool bNoPhysicalLadder;
// ^ NEW IN 1.60

// --- Functions ---
function bool InUse(Pawn Ignored) {}
// ^ NEW IN 1.60
simulated event PhysicsChangedFor(Actor Other) {}
simulated function PostBeginPlay() {}
simulated event PawnEnteredVolume(Pawn P) {}
simulated event PawnLeavingVolume(Pawn P) {}

defaultproperties
{
}
