//=============================================================================
// Counter: waits until it has been triggered 'NumToCount' times, and then
// it sends Trigger/UnTrigger events to actors whose names match 'EventName'.
//=============================================================================
class counter extends Triggers;

#exec Texture Import File=Textures\Counter.pcx Name=S_Counter Mips=Off MASKED=1

// --- Variables ---
var byte NumToCount;
// ^ NEW IN 1.60
// Number to count at startup time.
var byte OriginalNum;
var bool bShowMessage;
// ^ NEW IN 1.60
var localized string CountMessage;
// ^ NEW IN 1.60
var localized string CompleteMessage;
// ^ NEW IN 1.60

// --- Functions ---
//
// Counter was triggered.
//
function Trigger(Pawn EventInstigator, Actor Other) {}
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
function Reset() {}
//
// Init for play.
//
function BeginPlay() {}

defaultproperties
{
}
