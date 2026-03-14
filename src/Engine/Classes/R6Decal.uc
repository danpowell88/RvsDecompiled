//=============================================================================
// R6Decal - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6Decal.uc 
// Created By       Cyrille Lauzon
// Date             2001/01/18
// Description      R6 base class for wall Decals made with guns.
//----------------------------------------------------------------------------//
// Modification History
//      2002/04/26  Jean-Francois Dube (added ScaleProjector state)
//============================================================================//
class R6Decal extends Projector
	native
 placeable;

var bool m_bActive;
var bool m_bNeedScale;

state ScaleProjector
{
	function BeginState()
	{
		bStasis = false;
		bClipBSP = false;
		m_bClipStaticMesh = false;
		return;
	}

	function EndState()
	{
		bStasis = true;
		return;
	}

	simulated function Tick(float DeltaTime)
	{
		local Vector NewScale3D;
		local Rotator NewRotation;
		local RandomTweenNum RandomValue;

		// End:0x5F
		if(__NFUN_132__(__NFUN_242__(m_bNeedScale, false), __NFUN_130__(__NFUN_179__(DrawScale3D.X, 1.0000000), __NFUN_179__(DrawScale3D.Y, 1.0000000))))
		{
			bClipBSP = true;
			m_bClipStaticMesh = true;
			DetachProjector(true);
			AttachProjector();
			__NFUN_113__('None');			
		}
		else
		{
			DetachProjector(true);
			NewScale3D = DrawScale3D;
			RandomValue.m_fMin = 8.0000000;
			RandomValue.m_fMax = 16.0000000;
			__NFUN_184__(NewScale3D.X, __NFUN_172__(DeltaTime, __NFUN_174__(GetRandomTweenNum(RandomValue), __NFUN_171__(NewScale3D.X, 25.0000000))));
			__NFUN_184__(NewScale3D.Y, __NFUN_172__(DeltaTime, __NFUN_174__(GetRandomTweenNum(RandomValue), __NFUN_171__(NewScale3D.Y, 25.0000000))));
			SetDrawScale3D(NewScale3D);
			NewRotation = Rotation;
			__NFUN_161__(NewRotation.Roll, int(__NFUN_172__(__NFUN_171__(DeltaTime, 65536.0000000), 256.0000000)));
			__NFUN_299__(NewRotation);
			AttachProjector();
		}
		return;
	}
	stop;
}

defaultproperties
{
	FOV=1
	MaxTraceDistance=5
	bProjectParticles=false
	bProjectActor=false
	bProjectOnParallelBSP=true
	RemoteRole=0
	DrawType=0
	bStatic=false
	bStasis=true
	DrawScale=0.4000000
}
