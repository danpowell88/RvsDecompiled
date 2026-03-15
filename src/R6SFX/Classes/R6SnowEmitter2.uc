//=============================================================================
// R6SnowEmitter2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// More Snow and a bit windy
//=============================================================================
class R6SnowEmitter2 extends R6WeatherEmitter;

simulated function PostBeginPlay()
{
	Emitters[0].m_iUseFastZCollision = 1;
	Emitters[0].m_iPaused = 1;
	return;
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
}
