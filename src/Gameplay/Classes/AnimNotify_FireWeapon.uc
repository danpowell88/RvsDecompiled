//=============================================================================
// AnimNotify_FireWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class AnimNotify_FireWeapon extends AnimNotify_Scripted
	editinlinenew
	collapsecategories
 hidecategories(Object);

event Notify(Actor Owner)
{
	Pawn(Owner).bIgnorePlayFiring = true;
	return;
}

