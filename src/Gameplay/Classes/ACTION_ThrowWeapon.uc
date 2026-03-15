//=============================================================================
// Scripted action that makes the controlled pawn toss their current weapon away
// with the given velocity vector.
//=============================================================================

class ACTION_ThrowWeapon extends ScriptedAction;

var(Action) vector WeaponVelocity;

function bool InitActionFor(ScriptedController C)
{
/*@@@CODEDROP927 
	if ( (C.Pawn == None) || (C.Pawn.Weapon == None) )
		return false;

	if ( WeaponVelocity == vect(0,0,0) )
		WeaponVelocity = C.Pawn.Velocity + vect(0,0,250) + 300 * vector(C.Pawn.Rotation);
	C.Pawn.TossWeapon(WeaponVelocity);
*/
	return false;	
}

defaultproperties
{
     ActionString="throw weapon"
}