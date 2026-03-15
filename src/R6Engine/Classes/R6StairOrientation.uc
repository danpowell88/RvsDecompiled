//=============================================================================
// R6StairOrientation - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// R6StairOrientation - automatically placed in StairVolume
============================================================================= */
class R6StairOrientation extends Actor
    native
    notplaceable;

var() R6StairVolume m_pStairVolume;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	// End:0x57
	if((m_pStairVolume == none))
	{
		Log((("WARNING: " $ string(Name)) $ " is not linked to a stair volume. Remove it."));
	}
	return;
}

defaultproperties
{
	m_eDisplayFlag=0
	bStatic=true
	bHidden=true
	m_bSkipHitDetection=true
	m_bSpriteShowFlatInPlanning=true
	Texture=Texture'R6Planning.Icons.PlanIcon_Stairs'
}
