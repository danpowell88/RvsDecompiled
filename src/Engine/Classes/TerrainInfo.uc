//=============================================================================
// TerrainInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class TerrainInfo extends Info
	native
	noexport
 placeable;

enum ETexMapAxis
{
	TEXMAPAXIS_XY,                  // 0
	TEXMAPAXIS_XZ,                  // 1
	TEXMAPAXIS_YZ                   // 2
};

enum ESortOrder
{
	SORT_NoSort,                    // 0
	SORT_BackToFront,               // 1
	SORT_FrontToBack                // 2
};

struct NormalPair
{
	var Vector Normal1;
	var Vector Normal2;
};

struct TerrainLayer
{
	var() Material Texture;
	var() Texture AlphaMap;
	var() float UScale;
	var() float VScale;
	var() float UPan;
	var() float VPan;
	var() TerrainInfo.ETexMapAxis TextureMapAxis;
	var() float TextureRotation;
	var() Rotator LayerRotation;
	var Matrix TerrainMatrix;
	var() float KFriction;
	var() float KRestitution;
	var Texture LayerWeightMap;
};

struct DecorationLayer
{
	var() int ShowOnTerrain;
	var() Texture ScaleMap;
	var() Texture DensityMap;
	var() Texture ColorMap;
	var() StaticMesh StaticMesh;
	var() RangeVector ScaleMultiplier;
	var() Range FadeoutRadius;
	var() Range DensityMultiplier;
	var() int MaxPerQuad;
	var() int Seed;
	var() int AlignToTerrain;
	var() TerrainInfo.ESortOrder DrawOrder;
	var() int ShowOnInvisibleTerrain;
	var() int LitDirectional;
	var() int DisregardTerrainLighting;
};

struct DecoInfo
{
	var Vector Location;
	var Rotator Rotation;
	var Vector Scale;
	var Vector TempScale;
	var Color Color;
	var int Distance;
};

struct DecoSectorInfo
{
	var array<DecoInfo> DecoInfo;
	var Vector Location;
	var float Radius;
};

struct DecorationLayerData
{
	var array<DecoSectorInfo> Sectors;
};

var() int TerrainSectorSize;
var() Texture TerrainMap;
var() Vector TerrainScale;
var() TerrainLayer Layers[32];
var() array<DecorationLayer> DecoLayers;
var() bool Inverted;
// This option means use half the graphics res for Karma collision.
// Note - Karma ignores per-quad info (eg. 'invisible' and 'edge-turned') with this set to true.
var() bool bKCollisionHalfRes;
//R6TERRAINPLANNINGPAINT
var bool m_bNeedPlanningVBRebuild;
//
// Internal data
//
var transient int JustLoaded;
var native const array<DecorationLayerData> DecoLayerData;
var native const array<TerrainSector> Sectors;
var native const array<Vector> Vertices;
var native const int HeightmapX;
var native const int HeightmapY;
var native const int SectorsX;
var native const int SectorsY;
var native const TerrainPrimitive Primitive;
var native const array<NormalPair> FaceNormals;
var native const Vector ToWorld[4];
var native const Vector ToHeightmap[4];
var native const array<int> SelectedVertices;
var native const int ShowGrid;
var const array<int> QuadVisibilityBitmap;
var const array<int> EdgeTurnBitmap;
var native const array<int> RenderCombinations;
var native const array<int> VertexStreams;
var native const array<Color> VertexColors;
var native const array<Color> PaintedColor;  // editor only
// OLD
var native const Texture OldTerrainMap;
var native const array<byte> OldHeightmap;
//R6TERRAINPLANNINGPAINT
var native const array<int> m_TerrainPlanningFloorsInfo;
var native const array<int> m_iTerrainPlanningLastFloor;

defaultproperties
{
	TerrainSectorSize=16
	TerrainScale=(X=64.0000000,Y=64.0000000,Z=64.0000000)
	m_bNeedPlanningVBRebuild=true
	bStatic=true
	bWorldGeometry=true
	bStaticLighting=true
	bBlockActors=true
	Texture=Texture'Engine.S_TerrainInfo'
}
