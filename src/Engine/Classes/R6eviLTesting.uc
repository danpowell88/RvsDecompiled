//================================================================================
// R6eviLTesting.
//================================================================================

class R6eviLTesting extends Actor
	HideCategories(Movement,Collision,Lighting,LightColor,Karma,Force);

native(1356) final function NativeRunAllTests ();

event RunAll ()
{
}

defaultproperties
{
    bHidden=True

}
