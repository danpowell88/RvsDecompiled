//=============================================================================
// R61stLMGWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stLMGWeapon] 
//===============================================================================
class R61stLMGWeapon extends R6AbstractFirstPersonWeapon;

var R61stWeaponStaticMesh m_Bullets[8];
var StaticMesh m_RWing;
var StaticMesh m_2Wing;
var StaticMesh m_LWing;
var name m_BipodFireBurstBegin;
var name m_BipodFireBurstCycle;
var name m_BipodFireBurstEnd;
var name m_FireBurstBegin;
var name m_FireBurstCycle;
var name m_FireBurstEnd;

function PlayFireAnim()
{
	return;
}

function PlayFireLastAnim()
{
	return;
}

function LoopWeaponBurst()
{
	// End:0x14
	if(m_bWeaponBipodDeployed)
	{
		__NFUN_260__(m_BipodFireBurstCycle);		
	}
	else
	{
		__NFUN_260__(m_FireBurstCycle);
	}
	return;
}

function StartWeaponBurst()
{
	// End:0x14
	if(m_bWeaponBipodDeployed)
	{
		__NFUN_259__(m_BipodFireBurstBegin);		
	}
	else
	{
		__NFUN_259__(m_FireBurstBegin);
	}
	return;
}

function StopWeaponBurst()
{
	// End:0x14
	if(m_bWeaponBipodDeployed)
	{
		__NFUN_259__(m_BipodFireBurstEnd);		
	}
	else
	{
		__NFUN_259__(m_FireBurstEnd);
	}
	return;
}

function HideBullet(int iWhichBullet)
{
	J0x00:
	// End:0x31 [Loop If]
	if(__NFUN_150__(iWhichBullet, 8))
	{
		m_Bullets[__NFUN_147__(7, iWhichBullet)].bHidden = true;
		__NFUN_165__(iWhichBullet);
		// [Loop Continue]
		goto J0x00;
	}
	return;
}

function ShowBullets()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x34 [Loop If]
	if(__NFUN_150__(i, 8))
	{
		m_Bullets[i].bHidden = false;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();
	i = 0;
	J0x0D:

	// End:0xC5 [Loop If]
	if(__NFUN_150__(i, 8))
	{
		m_Bullets[i] = __NFUN_278__(Class'R61stWeapons.R61stWeaponStaticMesh');
		// End:0x56
		if(__NFUN_150__(i, 3))
		{
			m_Bullets[i].SetStaticMesh(m_LWing);			
		}
		else
		{
			// End:0x7F
			if(__NFUN_154__(i, 3))
			{
				m_Bullets[i].SetStaticMesh(m_2Wing);				
			}
			else
			{
				m_Bullets[i].SetStaticMesh(m_RWing);
			}
		}
		m_Bullets[i].SetDrawScale3D(vect(-1.0000000, -1.0000000, 1.0000000));
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x0D;
	}
	AttachToBone(m_Bullets[0], 'Ball_01');
	AttachToBone(m_Bullets[1], 'Ball_02');
	AttachToBone(m_Bullets[2], 'Ball_03');
	AttachToBone(m_Bullets[3], 'Ball_04');
	AttachToBone(m_Bullets[4], 'Ball_05');
	AttachToBone(m_Bullets[5], 'Ball_06');
	AttachToBone(m_Bullets[6], 'Ball_07');
	AttachToBone(m_Bullets[7], 'Ball_08');
	// End:0x173
	if(__NFUN_129__(__NFUN_263__('BipodFireBurst_b')))
	{
		m_BipodFireBurstBegin = m_BipodNeutral;
	}
	// End:0x18B
	if(__NFUN_129__(__NFUN_263__('BipodFireBurst_c')))
	{
		m_BipodFireBurstCycle = m_BipodNeutral;
	}
	// End:0x1A3
	if(__NFUN_129__(__NFUN_263__('BipodFireBurst_e')))
	{
		m_BipodFireBurstEnd = m_BipodNeutral;
	}
	// End:0x1BB
	if(__NFUN_129__(__NFUN_263__('Fireburst_b')))
	{
		m_FireBurstBegin = m_Neutral;
	}
	// End:0x1D3
	if(__NFUN_129__(__NFUN_263__('Fireburst_c')))
	{
		m_FireBurstCycle = m_Neutral;
	}
	// End:0x1EB
	if(__NFUN_129__(__NFUN_263__('Fireburst_e')))
	{
		m_FireBurstEnd = m_Neutral;
	}
	return;
}

function DestroyBullets()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x4D [Loop If]
	if(__NFUN_150__(i, 8))
	{
		// End:0x36
		if(__NFUN_119__(m_Bullets[i], none))
		{
			m_Bullets[i].__NFUN_279__();
		}
		m_Bullets[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

defaultproperties
{
	m_BipodFireBurstBegin="BipodFireBurst_b"
	m_BipodFireBurstCycle="BipodFireBurst_c"
	m_BipodFireBurstEnd="BipodFireBurst_e"
	m_FireBurstBegin="Fireburst_b"
	m_FireBurstCycle="Fireburst_c"
	m_FireBurstEnd="Fireburst_e"
}
