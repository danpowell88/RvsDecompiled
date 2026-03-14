//=============================================================================
// ShadowProjector - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ShadowProjector.
//=============================================================================
class ShadowProjector extends Projector
 placeable;

var byte m_bOpacity;
var() bool bUseLightAverage;
var bool m_bAttached;
var() float LightDistance;
var() Actor ShadowActor;
var ShadowBitmapMaterial ShadowTexture;
var() Vector LightDirection;

simulated event PostBeginPlay()
{
	// End:0x0F
	if(bProjectActor)
	{
		__NFUN_262__(true, false, false);
	}
	ShadowTexture = new (none) Class'Engine.ShadowBitmapMaterial';
	ProjTexture = ShadowTexture;
	return;
}

event UpdateShadow()
{
	local Vector ShadowLocation;
	local Plane BoundingSphere;

	// End:0x0F
	if(bProjectActor)
	{
		__NFUN_262__(false, false, false);
	}
	// End:0x1FE
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(ShadowActor, none), __NFUN_129__(ShadowActor.bHidden)), __NFUN_151__(int(m_bOpacity), 0)))
	{
		BoundingSphere = ShadowActor.GetRenderBoundingSphere();
		__NFUN_182__(BoundingSphere.W, 4.0000000);
		FOV = int(__NFUN_174__(__NFUN_172__(__NFUN_171__(__NFUN_190__(__NFUN_172__(__NFUN_171__(BoundingSphere.W, float(2)), LightDistance)), float(180)), 3.1415930), float(5)));
		// End:0xEB
		if(__NFUN_130__(__NFUN_154__(int(ShadowActor.DrawType), int(2)), __NFUN_119__(ShadowActor.Mesh, none)))
		{
			ShadowLocation = ShadowActor.GetBoneCoords('R6 Pelvis', true).Origin;			
		}
		else
		{
			ShadowLocation = ShadowActor.Location;
		}
		ShadowTexture.m_LightLocation = ShadowLocation;
		__NFUN_267__(ShadowLocation);
		__NFUN_299__(Rotator(__NFUN_211__(LightDirection)));
		SetDrawScale(__NFUN_172__(__NFUN_171__(LightDistance, __NFUN_189__(__NFUN_172__(__NFUN_171__(__NFUN_171__(0.5000000, float(FOV)), 3.1415930), float(180)))), __NFUN_171__(0.5000000, float(ShadowTexture.USize))));
		ShadowTexture.ShadowActor = ShadowActor;
		ShadowTexture.LightDirection = LightDirection;
		ShadowTexture.LightDistance = LightDistance;
		ShadowTexture.LightFOV = float(FOV);
		ShadowTexture.Dirty = true;
		ShadowTexture.m_bOpacity = m_bOpacity;
		AttachProjector();
		m_bAttached = true;
		// End:0x1FE
		if(bProjectActor)
		{
			__NFUN_262__(true, false, false);
		}
	}
	return;
}

simulated function Tick(float DeltaTime)
{
	// End:0x18
	if(m_bAttached)
	{
		m_bAttached = false;
		DetachProjector(true);
	}
	return;
}

event Touch(Actor Other)
{
	// End:0x39
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(Other, ShadowActor), Other.bAcceptsProjectors), bProjectActor))
	{
		AttachActor(Other);
	}
	return;
}

simulated function LightUpdateDirect(Vector LightDir, float LightDist, byte bOpacity)
{
	LightDistance = LightDist;
	LightDirection = LightDir;
	m_bOpacity = bOpacity;
	return;
}

simulated event Destroyed()
{
	// End:0x1B
	if(__NFUN_119__(ShadowTexture, none))
	{
		ShadowTexture.ShadowActor = none;
	}
	return;
}

defaultproperties
{
	m_bOpacity=128
	bUseLightAverage=true
	FrameBufferBlendingOp=2
	MaxTraceDistance=250
	bProjectParticles=false
	bProjectActor=false
	m_bDirectionalModulation=true
	m_bProjectTransparent=false
	bGradient=true
	bProjectOnParallelBSP=true
	bLightInfluenced=true
	RemoteRole=0
	bStatic=false
	CullDistance=3500.0000000
}
