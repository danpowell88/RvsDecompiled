// Gibbed — damage type for gib-triggering events (e.g. explosive death).
// Sets GibModifier to 100 so any hit by this type will trigger a gib death.
// Extracted from retail Engine.u.
class Gibbed extends DamageType
	abstract;

defaultproperties
{
     GibModifier=100.000000
     DeathString="%o exploded in a shower of body parts"
     FemaleSuicide="%o exploded in a shower of body parts"
     MaleSuicide="%o exploded in a shower of body parts"
}
