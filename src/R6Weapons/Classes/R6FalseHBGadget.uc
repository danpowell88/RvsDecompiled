//=============================================================================
// R6FalseHBGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
// [R6FalseHBGadget.uc] False Heart Beat Gadget
//===============================================================================
class R6FalseHBGadget extends R6GrenadeWeapon;

function ThrowGrenade()
{
	local Vector vStart;
	local Rotator rFiringDir;
	local R6Pawn pawnOwner;
	local R6FalseHeartBeat aFalseHeartBeat;

	pawnOwner = R6Pawn(Owner);
	// End:0x11C
	if(__NFUN_151__(int(m_iNbBulletsInWeapon), 0))
	{
		__NFUN_140__(m_iNbBulletsInWeapon);
		// End:0x38
		if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
		{
			SetStaticMesh(none);
		}
		GetFiringDirection(vStart, rFiringDir);
		// End:0x77
		if(pawnOwner.m_bIsPlayer)
		{
			vStart = pawnOwner.GetGrenadeStartLocation(m_eThrow);			
		}
		else
		{
			vStart = pawnOwner.GetHandLocation();
		}
		aFalseHeartBeat = __NFUN_278__(Class'R6Engine.R6FalseHeartBeat', self,, vStart, rFiringDir);
		aFalseHeartBeat.Instigator = none;
		aFalseHeartBeat.m_HeartBeatPuckOwner = Pawn(Owner);
		// End:0x102
		if(__NFUN_242__(pawnOwner.m_bIsProne, true))
		{
			aFalseHeartBeat.SetSpeed(__NFUN_171__(m_fMuzzleVelocity, 0.5000000));			
		}
		else
		{
			aFalseHeartBeat.SetSpeed(m_fMuzzleVelocity);
		}
		ClientThrowGrenade();
	}
	return;
}

defaultproperties
{
	m_bPinToRemove=false
	m_fMuzzleVelocity=1000.0000000
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripFalseHBPuck'
	m_pFPWeaponClass=Class'R61stWeapons.R61stFalseHBPuck'
	m_EquipSnd=Sound'Foley_FragGrenade.Play_Frag_Equip'
	m_UnEquipSnd=Sound'Foley_FragGrenade.Play_Frag_Unequip'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_AttachPoint="TagHBPuck"
	m_HUDTexturePos=(W=32.0000000,Y=353.0000000,Z=100.0000000)
	m_NameID="FalseHBGadget"
	DrawScale=1.1000000
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdFalseHBPuck'
}
