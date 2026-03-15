//=============================================================================
// Projector - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class Projector extends Actor
    native
    placeable;

enum EProjectorBlending
{
	PB_None,                        // 0
	PB_Modulate,                    // 1
	PB_Modulate1X,                  // 2
	PB_AlphaBlend,                  // 3
	PB_Add,                         // 4
	PB_Darken                       // 5
};

var() Projector.EProjectorBlending MaterialBlendingOp;  // The blending operation between the material being projected onto and ProjTexture.
// NEW IN 1.60
var() Projector.EProjectorBlending FrameBufferBlendingOp;
var() int FOV;
var() int MaxTraceDistance;
var() bool bProjectBSP;
var() bool bProjectTerrain;
var() bool bProjectStaticMesh;
var() bool bProjectParticles;
var() bool bProjectActor;
// NEW IN 1.60
var() bool bProjectBullet;
var() bool bLevelStatic;
var() bool bClipBSP;
var() bool m_bClipStaticMesh;  // R6CODE - Clip StaticMeshes for speed.
var() bool m_bRelative;  // R6CODE - Projector is relative to moving actors.
var bool m_bDirectionalModulation;  // R6CODE - Don't project on backfacing geometry and fade with angle.
var bool m_bProjectTransparent;  // R6CODE - Project on transparent objects.
var bool m_bProjectOnlyOnFloor;  // R6CODE - Project only on floor.
var() bool bProjectOnUnlit;
var() bool bGradient;
var() bool bProjectOnAlpha;
var() bool bProjectOnParallelBSP;
// NEW IN 1.60
var() bool bProjectOnlyFirst;
//R6SHADOW
var bool bLightInfluenced;
var() Material ProjTexture;
var() Texture GradientTexture;
var() name ProjectTag;
var const transient Plane FrustumPlanes[6];
var const transient Vector FrustumVertices[8];
var const transient Box Box;
var const transient ProjectorRenderInfoPtr RenderInfo;
var transient Matrix GradientMatrix;
var transient Matrix Matrix;
var transient Vector OldLocation;

// Export UProjector::execAttachProjector(FFrame&, void* const)
// functions
native function AttachProjector();

// Export UProjector::execDetachProjector(FFrame&, void* const)
native function DetachProjector(optional bool Force);

// Export UProjector::execAbandonProjector(FFrame&, void* const)
native function AbandonProjector(optional float Lifetime);

// Export UProjector::execAttachActor(FFrame&, void* const)
native function AttachActor(Actor A);

// Export UProjector::execDetachActor(FFrame&, void* const)
native function DetachActor(Actor A);

event PostBeginPlay()
{
	AttachProjector();
	// End:0x18
	if(bLevelStatic)
	{
		AbandonProjector();
		Destroy();
	}
	// End:0x27
	if(bProjectActor)
	{
		SetCollision(true, false, false);
	}
	return;
}

// fix unprog
simulated event Touch(Actor Other)
{
	// End:0x69
	if(((Other.bAcceptsProjectors && ((ProjectTag == 'None') || (Other.Tag == ProjectTag))) && (bProjectStaticMesh || (Other.StaticMesh == none))))
	{
		AttachActor(Other);
	}
	return;
}

event UnTouch(Actor Other)
{
	DetachActor(Other);
	return;
}

//R6SHADOW
event LightUpdateDirect(Vector LightDir, float LightDist, byte bOpacity)
{
	return;
}

event UpdateShadow()
{
	return;
}

defaultproperties
{
	FrameBufferBlendingOp=1
	MaxTraceDistance=1000
	bProjectBSP=true
	bProjectTerrain=true
	bProjectStaticMesh=true
	bProjectParticles=true
	bProjectActor=true
	m_bProjectTransparent=true
	GradientTexture=Texture'Engine.GRADIENT_Fade'
	bStatic=true
	bHidden=true
	bDirectional=true
	Texture=Texture'Engine.Proj_Icon'
}
