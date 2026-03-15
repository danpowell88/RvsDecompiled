//=============================================================================
// BlockedPath - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// BlockedPath.
// 
//=============================================================================
class BlockedPath extends NavigationPoint
    hidecategories(Lighting,LightColor,Karma,Force);

function Trigger(Actor Other, Pawn EventInstigator)
{
	bBlocked = (!bBlocked);
	return;
}

defaultproperties
{
	bBlocked=true
}
