//=============================================================================
// R6MorphMeshActor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MorphMeshActor extends Actor
    native
    placeable;

enum EMvtStat
{
	Mvt_None,                       // 0
	Mvt_Wait,                       // 1
	Mvt_Simple,                     // 2
	Mvt_Loop,                       // 3
	Mvt_Random,                     // 4
	Mvt_End                         // 5
};

var(MP2Movement) R6MorphMeshActor.EMvtStat MvtStat;
var(Display) int SkinsIndex;
var int b_sensMorph;
var(MP2Morphing) bool m_bMorph;
var() bool m_bBlockCoronas;
var(MP2Morphing) float MorphDeltaAlpha;
var float MorphAlpha;
var(MP2Morphing) StaticMesh MorphMesh;

event PreBeginPlay()
{
	super.PreBeginPlay();
	MorphAlpha = 0.0000000;
	m_bMorph = false;
	// End:0x24
	if(bDeleteMe)
	{
		return;
	}
	return;
}

function Tick(float DeltaTime)
{
	return;
}

function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	local int iDamage;

	iDamage = super.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGoup);
	__NFUN_231__(__NFUN_112__("-------------------  morph -------", string(iDamage)));
	// End:0x9B
	if(__NFUN_154__(int(MvtStat), int(1)))
	{
		// End:0x9B
		if(__NFUN_119__(MorphMesh, none))
		{
			b_sensMorph = 1;
			m_bMorph = true;
			MorphAlpha = 0.0000000;
			MvtStat = 2;
		}
	}
	return iDamage;
	return;
}

defaultproperties
{
	SkinsIndex=255
	m_bBlockCoronas=true
	DrawType=8
	bWorldGeometry=true
	bAcceptsProjectors=true
	m_bHandleRelativeProjectors=true
	bShadowCast=true
	bStaticLighting=true
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bEdShouldSnap=true
	m_bForceStaticLighting=true
	CollisionRadius=1.0000000
	CollisionHeight=1.0000000
}