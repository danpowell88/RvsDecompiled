//=============================================================================
// ShadowProjector - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
		SetCollision(true, false, false);
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
		SetCollision(false, false, false);
	}
	// End:0x1FE
	if((((ShadowActor != none) && (!ShadowActor.bHidden)) && (int(m_bOpacity) > 0)))
	{
		BoundingSphere = ShadowActor.GetRenderBoundingSphere();
		(BoundingSphere.W *= 4.0000000);
		FOV = int((((Atan(((BoundingSphere.W * float(2)) / LightDistance)) * float(180)) / 3.1415930) + float(5)));
		// End:0xEB
		if(((int(ShadowActor.DrawType) == int(2)) && (ShadowActor.Mesh != none)))
		{
			ShadowLocation = ShadowActor.GetBoneCoords('R6 Pelvis', true).Origin;			
		}
		else
		{
			ShadowLocation = ShadowActor.Location;
		}
		ShadowTexture.m_LightLocation = ShadowLocation;
		SetLocation(ShadowLocation);
		SetRotation(Rotator((-LightDirection)));
		SetDrawScale(((LightDistance * Tan((((0.5000000 * float(FOV)) * 3.1415930) / float(180)))) / (0.5000000 * float(ShadowTexture.USize))));
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
			SetCollision(true, false, false);
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
	if((((Other != ShadowActor) && Other.bAcceptsProjectors) && bProjectActor))
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
	if((ShadowTexture != none))
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
