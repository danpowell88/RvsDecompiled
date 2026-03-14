// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ParticleMaterial extends RenderedMaterial
    native;

// --- Structs ---
struct ParticleProjectorInfo
{
	var bitmapmaterial		BitmapMaterial;
	var matrix				Matrix;
	var int					Projected;
	var int					BlendMode;
};

// --- Variables ---
// var ? BlendMode; // REMOVED IN 1.60
// var ? Matrix; // REMOVED IN 1.60
// var ? Projected; // REMOVED IN 1.60
var const int ParticleBlending;
var const int BlendBetweenSubdivisions;
var const int RenderTwoSided;
var const int UseTFactor;
var const BitmapMaterial BitmapMaterial;
var const int AlphaTest;
var const int AlphaRef;
var const int ZTest;
var const int ZWrite;
var const int Wireframe;
var transient bool AcceptsProjectors;
var transient const int NumProjectors;
var transient const ParticleProjectorInfo Projectors[8];

defaultproperties
{
}
