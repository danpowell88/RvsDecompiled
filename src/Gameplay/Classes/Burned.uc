//=============================================================================
// Damage type applied when a pawn is killed by fire or extreme heat.
// Applies a warm orange-red view fog and uses the "sauteed" kill message.
//=============================================================================

class Burned extends DamageType abstract;

defaultproperties
{
     FlashScale=-0.009375
     FlashFog=(X=16.410000,Y=11.719000,Z=4.687500)
     DeathString="%o was sauteed."
}