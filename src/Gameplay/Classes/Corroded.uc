class Corroded extends DamageType
	abstract;

static function class<Effects> GetPawnDamageEffect( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	return Default.PawnDamageEffect;
}

defaultproperties
{
     bArmorStops=False
     FlashScale=0.000000
     FlashFog=(X=9.375000,Y=14.062500,Z=4.687500)
     DeathString="%o drank a glass of %k's dripping green load."
     FemaleSuicide="%o dissolved in slime."
     MaleSuicide="%o dissolved in slime."
     DamageWeaponName="BioRifle"
}
