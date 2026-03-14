// Damage type applied when a pawn drowns in a water volume.
// Bypasses armour and applies a deep blue view fog to signal oxygen deprivation.
class Drowned extends DamageType abstract;

static function class<Effects> GetPawnDamageEffect( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	return Default.PawnDamageEffect;
}

defaultproperties
{
     bArmorStops=False
     FlashScale=-0.390000
     FlashFog=(X=312.500000,Y=468.750000,Z=468.750000)
     DeathString="%o forgot to come up for air."
     FemaleSuicide="%o forgot to come up for air."
     MaleSuicide="%o forgot to come up for air."
}
