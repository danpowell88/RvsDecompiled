// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class TerrainMaterial extends RenderedMaterial
    native;

// --- Structs ---
struct TerrainMaterialLayer
{
    var Material Texture;
    var BitmapMaterial AlphaWeight;
    var Matrix TextureMatrix;
};

// --- Variables ---
// var ? AlphaWeight; // REMOVED IN 1.60
// var ? Texture; // REMOVED IN 1.60
// var ? TextureMatrix; // REMOVED IN 1.60
var const array<array> Layers;
var const byte RenderMethod;
var const bool FirstPass;

defaultproperties
{
}
