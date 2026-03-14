// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class TerrainInfo extends Info
    native
    noexport;

#exec Texture Import File=Textures\Terrain_info.pcx Name=S_TerrainInfo Mips=Off MASKED=1
#exec Texture Import File=Textures\S_WhiteCircle.pcx Name=S_WhiteCircle Mips=Off MASKED=1
#exec Texture Import File=Textures\Bad.pcx Name=TerrainBad Mips=Off
#exec Texture Import File=Textures\DecoPaint.pcx Name=DecoPaint Mips=Off

// --- Enums ---
enum ETexMapAxis
{
	TEXMAPAXIS_XY,
	TEXMAPAXIS_XZ,
	TEXMAPAXIS_YZ,
};
enum ESortOrder
{
	SORT_NoSort,
	SORT_BackToFront,
	SORT_FrontToBack
};

// --- Structs ---
struct NormalPair
{
	var vector Normal1;
	var vector Normal2;
};

struct TerrainLayer
{
	var() Material	Texture;
	var() Texture	AlphaMap;
	var() float		UScale;
	var() float		VScale;
	var() float		UPan;
	var() float		VPan;
	var() ETexMapAxis TextureMapAxis;
	var() float		TextureRotation;
	var() Rotator	LayerRotation;
	var   Matrix	TerrainMatrix;
	var() float		KFriction;
	var() float		KRestitution;
	var   Texture	LayerWeightMap;
};

struct DecorationLayer
{
	var() int			ShowOnTerrain;
	var() Texture		ScaleMap;
	var() Texture		DensityMap;
	var() Texture		ColorMap;
	var() StaticMesh	StaticMesh;
	var() rangevector	ScaleMultiplier;
	var() range			FadeoutRadius;
	var() range			DensityMultiplier;
	var() int			MaxPerQuad;
	var() int			Seed;
	var() int			AlignToTerrain;
	var() ESortOrder	DrawOrder;
	var() int			ShowOnInvisibleTerrain;
	var() int			LitDirectional;
	var() int			DisregardTerrainLighting;
};

struct DecoInfo
{
	var vector	Location;
	var rotator	Rotation;
	var vector	Scale;
	var vector	TempScale;
	var color	Color;
	var int		Distance;
};

struct DecoSectorInfo
{
	var array<DecoInfo>	DecoInfo;
	var vector			Location;
	var float			Radius;
};

struct DecorationLayerData
{
	var array<DecoSectorInfo> Sectors;
};

// --- Variables ---
// var ? Color; // REMOVED IN 1.60
// var ? DecoInfo; // REMOVED IN 1.60
// var ? Distance; // REMOVED IN 1.60
// var ? LayerWeightMap; // REMOVED IN 1.60
// var ? Location; // REMOVED IN 1.60
// var ? Normal1; // REMOVED IN 1.60
// var ? Normal2; // REMOVED IN 1.60
// var ? Radius; // REMOVED IN 1.60
// var ? Rotation; // REMOVED IN 1.60
// var ? Scale; // REMOVED IN 1.60
// var ? TempScale; // REMOVED IN 1.60
// var ? TerrainMatrix; // REMOVED IN 1.60
var native const array<array> m_iTerrainPlanningLastFloor;
//R6TERRAINPLANNINGPAINT
var native const array<array> m_TerrainPlanningFloorsInfo;
var native const array<array> OldHeightmap;
// OLD
var native const Texture OldTerrainMap;
// editor only
var native const array<array> PaintedColor;
var native const array<array> VertexColors;
var native const array<array> VertexStreams;
var native const array<array> RenderCombinations;
var const array<array> EdgeTurnBitmap;
var const array<array> QuadVisibilityBitmap;
var native const int ShowGrid;
var native const array<array> SelectedVertices;
var native const Vector ToHeightmap[4];
var native const Vector ToWorld[4];
var native const array<array> FaceNormals;
var native const TerrainPrimitive Primitive;
var native const int SectorsY;
var native const int SectorsX;
var native const int HeightmapY;
var native const int HeightmapX;
var native const array<array> Vertices;
var native const array<array> Sectors;
var native const array<array> DecoLayerData;
//
// Internal data
//
var transient int JustLoaded;
// This option means use half the graphics res for Karma collision.
// Note - Karma ignores per-quad info (eg. 'invisible' and 'edge-turned') with this set to true.
//R6TERRAINPLANNINGPAINT
var bool m_bNeedPlanningVBRebuild;
var bool bKCollisionHalfRes;
// ^ NEW IN 1.60
var bool Inverted;
// ^ NEW IN 1.60
var array<array> DecoLayers;
// ^ NEW IN 1.60
var TerrainLayer Layers[32];
// ^ NEW IN 1.60
var Vector TerrainScale;
// ^ NEW IN 1.60
var Texture TerrainMap;
// ^ NEW IN 1.60
var int TerrainSectorSize;
// ^ NEW IN 1.60

defaultproperties
{
}
