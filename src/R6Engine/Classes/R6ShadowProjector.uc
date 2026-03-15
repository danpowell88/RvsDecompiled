//=============================================================================
// R6ShadowProjector - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6ShadowProjector.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/21 * Created by Jean-Francois Dube
//=============================================================================
class R6ShadowProjector extends Projector;

var bool m_bAttached;

function PostBeginPlay()
{
	local Rotator Dir;

	Dir.Pitch = -16384;
	Dir.Yaw = 0;
	Dir.Roll = 0;
	SetRotation(Dir);
	return;
}

event UpdateShadow()
{
	SetLocation(R6Pawn(Owner).GetBoneCoords('R6 Spine', true).Origin);
	AttachProjector();
	m_bAttached = true;
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

defaultproperties
{
	FrameBufferBlendingOp=2
	MaxTraceDistance=200
	bProjectStaticMesh=false
	bProjectParticles=false
	bProjectActor=false
	m_bDirectionalModulation=true
	m_bProjectTransparent=false
	bGradient=true
	bProjectOnParallelBSP=true
	ProjTexture=Texture'Inventory_t.Shadow.ShadowTexSimple'
	RemoteRole=0
	bStatic=false
	DrawScale=1.5000000
	CullDistance=1800.0000000
}
