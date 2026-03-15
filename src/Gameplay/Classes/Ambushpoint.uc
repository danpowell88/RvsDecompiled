//=============================================================================
// Ambushpoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Ambushpoint.
//=============================================================================
class Ambushpoint extends NavigationPoint
    hidecategories(Lighting,LightColor,Karma,Force);

//at start, ambushing creatures will pick either their current location, or the location of
//some ambushpoint belonging to their team
var byte survivecount;  // used when picking ambushpoint
var() bool bSniping;  // bots should snipe from this position
var() float SightRadius;  // How far bot at this point should look for enemies
var Vector LookDir;  // direction to look while ambushing

function PreBeginPlay()
{
	LookDir = (float(2000) * Vector(Rotation));
	super(Actor).PreBeginPlay();
	return;
}

defaultproperties
{
	SightRadius=5000.0000000
	bDirectional=true
	bObsolete=true
}
