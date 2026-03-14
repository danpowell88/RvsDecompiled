// Fell — damage type for fall deaths.
// "Left a small crater" messages indicate a fatal drop.
// Extracted from retail Engine.u.
class Fell extends DamageType
	abstract;

defaultproperties
{
     DeathString="%o left a small crater"
     FemaleSuicide="%o left a small crater"
     MaleSuicide="%o left a small crater"
}
