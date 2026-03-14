//=============================================================================
// StaticMeshActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================
class StaticMeshActor extends Actor
    native;

// --- Variables ---
var int SkinsIndex;
var float m_fScale;
var float m_fFrequency;
var float m_fNormalScale;
var float m_fMinZero;
var Vector m_vScalePerAxis;
var bool m_bWave;
var float CullDistanceWave;
var bool m_bBlockCoronas;
var bool m_bUseTesselletation;
var float m_fTesseletationLevel;

defaultproperties
{
}
