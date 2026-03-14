//=============================================================================
// UseTrigger: if a player stands within proximity of this trigger, and hits Use, 
// it will send Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================
class UseTrigger extends Triggers;

// --- Variables ---
var localized string Message;

// --- Functions ---
function UsedBy(Pawn User) {}
function Touch(Actor Other) {}

defaultproperties
{
}
