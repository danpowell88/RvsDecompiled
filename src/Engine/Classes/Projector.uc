// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class Projector extends Actor
    native;

#exec Texture Import File=Textures\Proj_IconMasked.pcx Name=Proj_Icon Mips=Off MASKED=1
#exec Texture Import file=Textures\GRADIENT_Fade.tga Name=GRADIENT_Fade Mips=Off UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP
#exec Texture Import file=Textures\GRADIENT_Clip.tga Name=GRADIENT_Clip Mips=Off UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP

// --- Enums ---
enum EProjectorBlending
{
	PB_None,
	PB_Modulate,
    PB_Modulate1X,
	PB_AlphaBlend,
	PB_Add,
    PB_Darken
};

// --- Variables ---
var bool bProjectActor;
// ^ NEW IN 1.60
var int FOV;
// ^ NEW IN 1.60
var name ProjectTag;
// ^ NEW IN 1.60
var bool m_bClipStaticMesh;
// ^ NEW IN 1.60
var bool bClipBSP;
// ^ NEW IN 1.60
var Material ProjTexture;
// ^ NEW IN 1.60
var bool bProjectStaticMesh;
// ^ NEW IN 1.60
var bool bLevelStatic;
// ^ NEW IN 1.60
//R6SHADOW
var bool bLightInfluenced;
var transient Vector OldLocation;
var transient Matrix Matrix;
var transient Matrix GradientMatrix;
var transient const ProjectorRenderInfoPtr RenderInfo;
var transient const Box Box;
var transient const Vector FrustumVertices[8];
var transient const Plane FrustumPlanes[6];
var Texture GradientTexture;
// ^ NEW IN 1.60
var bool bProjectOnlyFirst;
// ^ NEW IN 1.60
var bool bProjectOnParallelBSP;
// ^ NEW IN 1.60
var bool bProjectOnAlpha;
// ^ NEW IN 1.60
var bool bGradient;
// ^ NEW IN 1.60
var bool bProjectOnUnlit;
// ^ NEW IN 1.60
//R6CODE - Project only on floor.
var bool m_bProjectOnlyOnFloor;
//R6CODE - Project on transparent objects.
var bool m_bProjectTransparent;
//R6CODE - Don't project on backfacing geometry and fade with angle.
var bool m_bDirectionalModulation;
var bool m_bRelative;
// ^ NEW IN 1.60
var bool bProjectBullet;
// ^ NEW IN 1.60
var bool bProjectParticles;
// ^ NEW IN 1.60
var bool bProjectTerrain;
// ^ NEW IN 1.60
var bool bProjectBSP;
// ^ NEW IN 1.60
var int MaxTraceDistance;
// ^ NEW IN 1.60
var EProjectorBlending FrameBufferBlendingOp;
// ^ NEW IN 1.60
var EProjectorBlending MaterialBlendingOp;
// ^ NEW IN 1.60

// --- Functions ---
// function ? Untouch(...); // REMOVED IN 1.60
// fix unprog
simulated event Touch(Actor Other) {}
event UpdateShadow() {}
event PostBeginPlay() {}
//R6SHADOW
event LightUpdateDirect(byte bOpacity, float LightDist, Vector LightDir) {}
event UnTouch(Actor Other) {}
// ^ NEW IN 1.60
native function DetachActor(Actor A) {}
native function AttachActor(Actor A) {}
native function AbandonProjector(optional float Lifetime) {}
native function DetachProjector(optional bool Force) {}
// functions
native function AttachProjector() {}

defaultproperties
{
}
