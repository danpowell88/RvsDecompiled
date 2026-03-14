//=============================================================================
// Material - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Material: Abstract material class
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Material extends Object
	native
	collapsecategories
	noexport
 hidecategories(Object);

enum ESurfaceType
{
	SURF_Generic,                   // 0
	SURF_GenericHardSurface,        // 1
	SURF_DustyConcrete,             // 2
	SURF_CompactSnow,               // 3
	SURF_DeepSnow,                  // 4
	SURF_Dirt,                      // 5
	SURF_HardWood,                  // 6
	SURF_BoomyWood,                 // 7
	SURF_Carpet,                    // 8
	SURF_Grate,                     // 9
	SURF_HardMetal,                 // 10
	SURF_SheetMetal,                // 11
	SURF_WaterPuddle,               // 12
	SURF_DeepWater,                 // 13
	SURF_OilPuddle,                 // 14
	SURF_DirtyGrass,                // 15
	SURF_CleanGrass,                // 16
	SURF_Gravel                     // 17
};

var() Material FallbackMaterial;
var Material DefaultMaterial;
var const transient bool UseFallback;  // Render device should use the fallback.
var const transient bool Validated;  // Material has been validated as renderable.
//#ifdef R6CODE
var(Rainbow) bool m_bForceNoSort;
var(Rainbow) bool m_bDynamicMaterial;
var(Rainbow) bool m_bProneTrail;
var int m_SpecificRenderData;
//#ifdef R6MATERIAL
var(Rainbow) int m_iPenetration;
var(Rainbow) int m_iResistanceFactor;
var(Rainbow) Class<R6WallHit> m_pHitEffect;
var(Rainbow) Class<R6FootStep> m_pFootStep;
var(Rainbow) Material.ESurfaceType m_eSurfIdForSnd;
var Material m_pUnused;  // not able to remove it
var(Rainbow) byte m_iNightVisionFactor;

function Trigger(Actor Other, Actor EventInstigator)
{
	// End:0x24
	if(__NFUN_119__(FallbackMaterial, none))
	{
		FallbackMaterial.Trigger(Other, EventInstigator);
	}
	return;
}

defaultproperties
{
	DefaultMaterial=Texture'Engine.DefaultTexture'
	m_iNightVisionFactor=128
}
