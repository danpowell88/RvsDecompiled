//=============================================================================
// StaticMeshActor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// StaticMeshActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================
class StaticMeshActor extends Actor
    native
    placeable;

// JFDUBE: I didn't use the m_i prefix because I wanted it to appear just after Skins in the editor.
var(Display) int SkinsIndex;
var(Modifier) bool m_bWave;
//R6CNEWRENDERERFEATURES
var() bool m_bBlockCoronas;
var(Tessellation) bool m_bUseTesselletation;
//R6MODIFIERS
var(Modifier) float m_fScale;
var(Modifier) float m_fFrequency;
var(Modifier) float m_fNormalScale;
var(Modifier) float m_fMinZero;
// NEW IN 1.60
var(Modifier) float CullDistanceWave;
var(Tessellation) float m_fTesseletationLevel;
var(Modifier) Vector m_vScalePerAxis;

defaultproperties
{
	SkinsIndex=255
	m_bBlockCoronas=true
	m_fScale=1.0000000
	m_fFrequency=1.0000000
	m_fNormalScale=0.1000000
	CullDistanceWave=1000.0000000
	m_fTesseletationLevel=4.0000000
	m_vScalePerAxis=(X=1.0000000,Y=1.0000000,Z=1.0000000)
	DrawType=8
	bStatic=true
	bWorldGeometry=true
	bAcceptsProjectors=true
	bShadowCast=true
	bStaticLighting=true
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bEdShouldSnap=true
	CollisionRadius=1.0000000
	CollisionHeight=1.0000000
}
