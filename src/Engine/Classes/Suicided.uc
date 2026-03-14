// Suicided — damage type for self-inflicted death (suicide).
// GibModifier=0 means suicide does not trigger gibs.
// Extracted from retail Engine.u.
class Suicided extends DamageType
	abstract;

defaultproperties
{
     GibModifier=0.000000
     DeathString="%o had a sudden heart attack."
}
