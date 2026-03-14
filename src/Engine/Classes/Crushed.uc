// Crushed — damage type for death-by-crushing (e.g. by a mover or geometry).
// Death messages shown when killed or crushed by another actor/player.
// Extracted from retail Engine.u.
class Crushed extends DamageType
	abstract;

defaultproperties
{
     DeathString="%o was crushed by %k."
     FemaleSuicide="%o was crushed."
     MaleSuicide="%o was crushed."
}
