//=============================================================================
// Damage type applied by explosive decompression or vacuum exposure.
// Bypasses armour and guarantees gibbing (GibModifier=100).
//=============================================================================

class Depressurized extends DamageType abstract;

defaultproperties
{
     bArmorStops=False
     GibModifier=100.000000
     DeathString="%o was depressurized by %k."
     FemaleSuicide="%o was depressurized."
     MaleSuicide="%o was depressurized."
}