//=============================================================================
// R6WeatherVolume - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
/********************************************************************
	created:	2001/06/19
	filename: 	R6WeatherVolume.uc
	author:		Jean-Francois Dube
*********************************************************************/
class R6WeatherVolume extends R6SoundVolume;

event Touch(Actor Other)
{
	(Other.m_bInWeatherVolume++);
	return;
}

event UnTouch(Actor Other)
{
	(Other.m_bInWeatherVolume--);
	return;
}

