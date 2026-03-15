//=============================================================================
// PlayerStart - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Player start location.
//=============================================================================
class PlayerStart extends SmallNavigationPoint
    native
    placeable
    hidecategories(Lighting,LightColor,Karma,Force);

// Players on different teams are not spawned in areas with the
// same TeamNumber unless there are more teams in the level than
// team numbers.
var() byte TeamNumber;  // what team can spawn at this start
var() bool bSinglePlayerStart;  // use first start encountered with this true for single player
var() bool bCoopStart;  // start can be used in coop games
var() bool bEnabled;

defaultproperties
{
	bSinglePlayerStart=true
	bCoopStart=true
	bEnabled=true
	bDirectional=true
	Texture=Texture'Engine.S_Player'
}
