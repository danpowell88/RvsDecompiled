//=============================================================================
// DefensePoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Defensepoint.
//=============================================================================
class DefensePoint extends Ambushpoint
    hidecategories(Lighting,LightColor,Karma,Force);

var() byte Team;
var() byte Priority;
var() name FortTag;  // optional associated fort (for assault game)

