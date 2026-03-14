//=============================================================================
// R6eviLTesting - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//================================================================================
// R6eviLTesting.
//================================================================================
class R6eviLTesting extends Actor
    native
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

// Export UR6eviLTesting::execNativeRunAllTests(FFrame&, void* const)
native(1356) final function NativeRunAllTests();

event RunAll()
{
	__NFUN_1356__();
	return;
}

defaultproperties
{
	bHidden=true
}
