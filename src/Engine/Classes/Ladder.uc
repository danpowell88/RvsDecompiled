//=============================================================================
// Ladder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Ladders are associated with the LadderVolume that encompasses them, and provide AI navigation 
// support for ladder volumes.  Direction should be the direction that climbing pawns
// should face
============================================================================= */
class Ladder extends SmallNavigationPoint
    native
    placeable
    hidecategories(Lighting,LightColor,Karma,Force);

var LadderVolume MyLadder;
var Ladder LadderList;

event bool SuggestMovePreparation(Pawn Other)
{
	// End:0x0D
	if((MyLadder == none))
	{
		return false;
	}
	// End:0x3C
	if((!MyLadder.InUse(Other)))
	{
		MyLadder.PendingClimber = Other;
		return false;
	}
	Other.Controller.bPreparingMove = true;
	Other.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	return true;
	return;
}

defaultproperties
{
	bSpecialMove=true
	bNotBased=true
	bDirectional=true
	Texture=Texture'Engine.S_Ladder'
}
