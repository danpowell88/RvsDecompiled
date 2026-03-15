//=============================================================================
// R61stHandsGripGrenade - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsGripGrenade ] 
//===============================================================================
class R61stHandsGripGrenade extends R6
    AbstractFirstPersonHands;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripGrenadeA');
	super.PostBeginPlay();
	return;
}

auto state Waiting
{
	simulated function Timer()
	{
		local int HowLongBeforeWait;

		PlayAnim('Wait01');
		m_bPlayWaitAnim = true;
		HowLongBeforeWait = Rand(10);
		SetTimer(float((HowLongBeforeWait + 5)), false);
		return;
	}
	stop;
}

state RaiseWeapon
{
	simulated function BeginState()
	{
		SetDrawType(2);
		AssociatedWeapon.SetDrawType(2);
		AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);
		Owner.Owner.PlaySound(R6AbstractWeapon(Owner).m_EquipSnd, 3);
		PlayAnim('Begin', (R6Pawn(Owner.Owner).ArmorSkillEffect() * m_fAnimAcceleration));
		return;
	}
	stop;
}

simulated state FiringWeapon
{
	function EndState()
	{
		return;
	}

	function FireEmpty()
	{
		return;
	}

	function BeginState()
	{
		LoopAnim('Neutral',,, 1);
		return;
	}

	simulated function AnimEnd(int iChannel)
	{
		// End:0x1A
		if(bShowLog)
		{
			Log(("animEnd " $ string(self)));
		}
		// End:0x34
		if(((iChannel != 0) || (Owner == none)))
		{
			return;
		}
		// End:0x90
		if((m_bCanQuitOnAnimEnd == true))
		{
			AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);
			AnimBlendParams(1, 0.0000000);
			LoopAnim('Empty_nt');
			m_bCanQuitOnAnimEnd = false;
			m_bCannotPlayEmpty = false;
			m_bInBurst = false;
			GotoState('None');			
		}
		else
		{
			AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
			LoopAnim('Fire_nt', R6AbstractWeapon(Owner).m_fFireAnimRate, 0.1000000);
		}
		// End:0xE3
		if(bShowLog)
		{
			Log("Calling FPAO");
		}
		R6AbstractWeapon(Owner).FirstPersonAnimOver();
		return;
	}

	simulated function FireGrenadeThrow()
	{
		AssociatedWeapon.SetDrawType(0);
		AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
		PlayAnim('Fire_Up', (R6Pawn(Owner.Owner).ArmorSkillEffect() * 0.8000000));
		m_bCanQuitOnAnimEnd = true;
		// End:0x82
		if(bShowLog)
		{
			Log(("FireGrenadeThrow " $ string(self)));
		}
		return;
	}

	simulated function FireGrenadeRoll()
	{
		AssociatedWeapon.SetDrawType(0);
		AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
		PlayAnim('Fire_Down', (R6Pawn(Owner.Owner).ArmorSkillEffect() * 0.8000000));
		m_bCanQuitOnAnimEnd = true;
		// End:0x81
		if(bShowLog)
		{
			Log(("FireGrenadeRoll " $ string(self)));
		}
		return;
	}

	simulated function FireSingleShot()
	{
		AssociatedWeapon.PlayAnim(AssociatedWeapon.m_Fire, R6Pawn(Owner.Owner).ArmorSkillEffect());
		AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
		PlayAnim('Fire', R6Pawn(Owner.Owner).ArmorSkillEffect());
		m_bCanQuitOnAnimEnd = false;
		// End:0x9F
		if(bShowLog)
		{
			Log(("FireSingleShot " $ string(self)));
		}
		return;
	}
	stop;
}

defaultproperties
{
	DrawType=0
	Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
