//=============================================================================
// TerrainMaterial - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class TerrainMaterial extends RenderedMaterial
	native
	collapsecategories
 hidecategories(Object);

struct TerrainMaterialLayer
{
	var Material Texture;
	var BitmapMaterial AlphaWeight;
	var Matrix TextureMatrix;
};

var const byte RenderMethod;
var const bool FirstPass;
var const array<TerrainMaterialLayer> Layers;

