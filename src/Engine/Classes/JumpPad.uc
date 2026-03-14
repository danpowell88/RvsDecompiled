//=============================
// Jumppad - bounces players/bots up
// not directly placeable.  Make a subclass with appropriate sound effect etc.
//
class JumpPad extends NavigationPoint
    native;

// --- Variables ---
var Actor JumpTarget;
var Vector JumpVelocity;
var Vector JumpModifier;
// ^ NEW IN 1.60

// --- Functions ---
event Touch(Actor Other) {}
event PostTouch(Actor Other) {}

defaultproperties
{
}
