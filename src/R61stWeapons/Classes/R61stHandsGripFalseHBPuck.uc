//=============================================================================
// R61stHandsGripFalseHBPuck - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R61stHandsGripFalseHBPuck.uc
//=============================================================================
class R61stHandsGripFalseHBPuck extends R61stHandsGripGrenade;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsItemFakeHBPuckA');
	super.PostBeginPlay();
	return;
}

state RaiseWeapon
{
	simulated function BeginState()
	{
		SetDrawType(2);
		AssociatedWeapon.SetDrawType(2);
		PlayAnim('Begin', R6Pawn(Owner.Owner).ArmorSkillEffect());
		return;
	}
	stop;
}

