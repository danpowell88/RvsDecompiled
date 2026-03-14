// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class Door extends NavigationPoint
    native;

#exec Texture Import File=Textures\Door.pcx Name=S_Door Mips=Off MASKED=1

// --- Variables ---
var Mover MyDoor;
var Actor RecommendedTrigger;
var bool bInitiallyClosed;
// ^ NEW IN 1.60
var bool bDoorOpen;
var bool bBlockedWhenClosed;
// ^ NEW IN 1.60
var name DoorTrigger;
// ^ NEW IN 1.60
var name DoorTag;
// ^ NEW IN 1.60
// used during path building
var bool bTempNoCollide;

// --- Functions ---
function Actor SpecialHandling(Pawn Other) {}
// ^ NEW IN 1.60
function bool ProceedWithMove(Pawn Other) {}
// ^ NEW IN 1.60
function PostBeginPlay() {}
event bool SuggestMovePreparation(Pawn Other) {}
// ^ NEW IN 1.60
function MoverOpened() {}
function MoverClosed() {}

defaultproperties
{
}
