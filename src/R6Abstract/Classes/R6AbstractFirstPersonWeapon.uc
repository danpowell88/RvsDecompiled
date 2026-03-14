//=============================================================================
// R6AbstractFirstPersonWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R6AbstractFirstPersonWeapon] 
//===============================================================================
class R6AbstractFirstPersonWeapon extends R6EngineFirstPersonWeapon
	abstract
 native;

var bool m_bWeaponBipodDeployed;
var bool m_bReloadEmpty;
var Actor m_smGun;  // First Person gun as static Mesh
var Actor m_smGun2;  // If the weapon has more than one static mesh.
var(R6FPAnimations) name m_Empty;
var(R6FPAnimations) name m_Fire;
var(R6FPAnimations) name m_FireEmpty;
var(R6FPAnimations) name m_FireLast;
var(R6FPAnimations) name m_Neutral;
var(R6FPAnimations) name m_Reload;
var(R6FPAnimations) name m_ReloadEmpty;
var(R6FPAnimations) name m_BipodRaise;  // Raise weapon & Put the bipod down, if any
var(R6FPAnimations) name m_BipodDeploy;  // Bring the bipod up
var(R6FPAnimations) name m_BipodDiscard;  // Close bipod, and lower weapon
var(R6FPAnimations) name m_BipodClose;  // Put the bipod down, if any
var(R6FPAnimations) name m_BipodNeutral;  // Bipod is down
var(R6FPAnimations) name m_BipodReload;  // reload anim with the bipod down
var(R6FPAnimations) name m_BipodReloadEmpty;
var name m_WeaponNeutralAnim;

function StopFiring()
{
	return;
}

function InterruptFiring()
{
	return;
}

function FireEmpty()
{
	return;
}

function FireLastBullet()
{
	return;
}

function FireSingleShot()
{
	return;
}

function FireThreeShots()
{
	return;
}

function LoopBurst()
{
	return;
}

function StartBurst()
{
	return;
}

function StopTimer()
{
	return;
}

function StartTimer()
{
	return;
}

function FireGrenadeThrow()
{
	return;
}

function FireGrenadeRoll()
{
	return;
}

function DestroyBullets()
{
	return;
}

function StartWeaponBurst()
{
	return;
}

function LoopWeaponBurst()
{
	return;
}

function StopWeaponBurst()
{
	return;
}

function PlayWalkingAnimation()
{
	return;
}

function StopWalkingAnimation()
{
	return;
}

function ResetNeutralAnim()
{
	return;
}

simulated function SwitchFPMesh()
{
	return;
}

simulated function SwitchFPAnim()
{
	return;
}

simulated function SetAssociatedWeapon(R6AbstractFirstPersonWeapon AWeapon)
{
	return;
}

// LMG functions
function HideBullet(int iWhichBullet)
{
	return;
}

function PlayFireAnim()
{
	// End:0x14
	if(__NFUN_242__(m_bWeaponBipodDeployed, false))
	{
		__NFUN_259__(m_Fire);
	}
	return;
}

function PlayFireLastAnim()
{
	// End:0x14
	if(__NFUN_242__(m_bWeaponBipodDeployed, false))
	{
		__NFUN_259__(m_FireLast);
	}
	return;
}

function DestroySM()
{
	local Actor aActor;

	aActor = m_smGun;
	m_smGun = none;
	// End:0x29
	if(__NFUN_119__(aActor, none))
	{
		aActor.__NFUN_279__();
	}
	aActor = m_smGun2;
	m_smGun2 = none;
	// End:0x52
	if(__NFUN_119__(aActor, none))
	{
		aActor.__NFUN_279__();
	}
	DestroyBullets();
	return;
}

simulated function PostBeginPlay()
{
	// End:0x37
	if(__NFUN_129__(__NFUN_263__(m_Neutral)))
	{
		__NFUN_231__(__NFUN_112__("Missing Neutral Anim for Weapon :", string(self)));
	}
	// End:0x4F
	if(__NFUN_129__(__NFUN_263__(m_Empty)))
	{
		m_Empty = m_Neutral;
	}
	// End:0x67
	if(__NFUN_129__(__NFUN_263__(m_Fire)))
	{
		m_Fire = m_Neutral;
	}
	// End:0x7F
	if(__NFUN_129__(__NFUN_263__(m_FireLast)))
	{
		m_FireLast = m_Fire;
	}
	// End:0x97
	if(__NFUN_129__(__NFUN_263__(m_FireEmpty)))
	{
		m_FireEmpty = m_Neutral;
	}
	// End:0xAF
	if(__NFUN_129__(__NFUN_263__(m_Reload)))
	{
		m_Reload = m_Neutral;
	}
	// End:0xC7
	if(__NFUN_129__(__NFUN_263__(m_ReloadEmpty)))
	{
		m_ReloadEmpty = m_Reload;
	}
	// End:0xDF
	if(__NFUN_129__(__NFUN_263__(m_BipodRaise)))
	{
		m_BipodRaise = m_Neutral;
	}
	// End:0xF7
	if(__NFUN_129__(__NFUN_263__(m_BipodDeploy)))
	{
		m_BipodDeploy = m_Neutral;
	}
	// End:0x10F
	if(__NFUN_129__(__NFUN_263__(m_BipodDiscard)))
	{
		m_BipodDiscard = m_Neutral;
	}
	// End:0x127
	if(__NFUN_129__(__NFUN_263__(m_BipodClose)))
	{
		m_BipodClose = m_Neutral;
	}
	// End:0x13F
	if(__NFUN_129__(__NFUN_263__(m_BipodNeutral)))
	{
		m_BipodNeutral = m_Neutral;
	}
	// End:0x157
	if(__NFUN_129__(__NFUN_263__(m_BipodReload)))
	{
		m_BipodReload = m_BipodNeutral;
	}
	// End:0x16F
	if(__NFUN_129__(__NFUN_263__(m_BipodReloadEmpty)))
	{
		m_BipodReloadEmpty = m_BipodReload;
	}
	return;
}

simulated event Destroyed()
{
	DestroySM();
	super(Actor).Destroyed();
	return;
}

state Reloading
{
	function BeginState()
	{
		return;
	}
	stop;
}

defaultproperties
{
	m_Empty="Empty_nt"
	m_Fire="Fire"
	m_FireEmpty="FireEmpty"
	m_FireLast="FireLast"
	m_Neutral="Neutral"
	m_Reload="Reload"
	m_ReloadEmpty="ReloadEmpty"
	m_BipodRaise="BipodBegin"
	m_BipodDeploy="Bipod_b"
	m_BipodDiscard="BipodEnd"
	m_BipodClose="Bipod_e"
	m_BipodNeutral="Bipod_nt"
	m_BipodReload="BipodReload"
	m_BipodReloadEmpty="BipodReloadEmpty"
	m_WeaponNeutralAnim="Neutral"
	RemoteRole=0
	DrawType=2
	m_bAllowLOD=false
}
