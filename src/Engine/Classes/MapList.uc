//=============================================================================
// MapList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// MapList.
//
// contains a list of maps to cycle through
//
//=============================================================================
class MapList extends Info
    abstract
    native
    config
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

const K_NextDefaultMap = -2;

var(Maps) config string Maps[32];

function string GetNextMap(int iNextMapNum)
{
	return;
}

