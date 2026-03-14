//=============================================================================
// R6MuzzleLight - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// R6MuzzleLight.
//=============================================================================
class R6MuzzleLight extends Light;

const LightExistence = 0.04;

var float m_fExistForHowlong;

//Tick is used to make sure the light is displayed at least once under low FPS
simulated function Tick(float fDeltaTime)
{
	super(Actor).Tick(fDeltaTime);
	__NFUN_184__(m_fExistForHowlong, fDeltaTime);
	// End:0x29
	if(__NFUN_177__(m_fExistForHowlong, 0.0400000))
	{
		__NFUN_279__();
	}
	return;
}

defaultproperties
{
	DrawType=0
	LightHue=33
	LightSaturation=209
	bStatic=false
	bNoDelete=false
	bDynamicLight=true
	LightBrightness=232.0000000
	LightRadius=40.0000000
}
