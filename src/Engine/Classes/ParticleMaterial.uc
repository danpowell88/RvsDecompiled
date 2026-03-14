//=============================================================================
// ParticleMaterial - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ParticleMaterial extends RenderedMaterial
	native
	collapsecategories
 hidecategories(Object);

struct ParticleProjectorInfo
{
	var BitmapMaterial BitmapMaterial;
	var Matrix Matrix;
	var int Projected;
	var int BlendMode;
};

var const int ParticleBlending;
var const int BlendBetweenSubdivisions;
var const int RenderTwoSided;
var const int UseTFactor;
var const int AlphaTest;
var const int AlphaRef;
var const int ZTest;
var const int ZWrite;
var const int Wireframe;
var const BitmapMaterial BitmapMaterial;
var const transient int NumProjectors;
var transient bool AcceptsProjectors;
var const transient ParticleProjectorInfo Projectors[8];

