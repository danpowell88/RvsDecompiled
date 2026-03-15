//=============================================================================
// R61stHandsGripHBS - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R61stHandsGripHBS.uc
//=============================================================================
class R61stHandsGripHBS extends R6
    AbstractFirstPersonHands;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripHBSA');
	super.PostBeginPlay();
	return;
}

auto state Waiting
{	stop;
}

state RaiseWeapon
{
	simulated event AnimEnd(int Channel)
	{
		SetDrawType(0);
		super.AnimEnd(Channel);
		return;
	}
	stop;
}

state BringWeaponUp
{
	simulated event AnimEnd(int Channel)
	{
		SetDrawType(0);
		super.AnimEnd(Channel);
		return;
	}
	stop;
}

state DiscardWeapon
{
	simulated function BeginState()
	{
		SetDrawType(2);
		super.BeginState();
		return;
	}
	stop;
}

state PutWeaponDown
{
	simulated function BeginState()
	{
		SetDrawType(2);
		super.BeginState();
		return;
	}
	stop;
}

defaultproperties
{
	DrawType=0
	Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
