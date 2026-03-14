//=============================================================================
// Material: Abstract material class
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Material extends Object
    native
    noexport;

#exec Texture Import File=Textures\DefaultTexture.pcx

// --- Enums ---
enum ESurfaceType
{
    SURF_Generic,
    SURF_GenericHardSurface,
    SURF_DustyConcrete,
    SURF_CompactSnow,
    SURF_DeepSnow,
    SURF_Dirt,
    SURF_HardWood,
    SURF_BoomyWood,
    SURF_Carpet,
    SURF_Grate,
    SURF_HardMetal,
    SURF_SheetMetal,
    SURF_WaterPuddle,
    SURF_DeepWater,
    SURF_OilPuddle,
    SURF_DirtyGrass,
    SURF_CleanGrass,
    SURF_Gravel
};

// --- Variables ---
var Material FallbackMaterial;
// ^ NEW IN 1.60
var byte m_iNightVisionFactor;
// not able to remove it
var Material m_pUnused;
var ESurfaceType m_eSurfIdForSnd;
var class<R6FootStep> m_pFootStep;
var class<R6WallHit> m_pHitEffect;
var int m_iResistanceFactor;
//#ifdef R6MATERIAL
var int m_iPenetration;
//#ifdef R6CODE
var int m_SpecificRenderData;
var bool m_bProneTrail;
// ^ NEW IN 1.60
var bool m_bDynamicMaterial;
// ^ NEW IN 1.60
var bool m_bForceNoSort;
// ^ NEW IN 1.60
// Material has been validated as renderable.
var transient const bool Validated;
// Render device should use the fallback.
var transient const bool UseFallback;
var Material DefaultMaterial;

// --- Functions ---
function Trigger(Actor EventInstigator, Actor Other) {}

defaultproperties
{
}
