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

var() int TerrainSectorSize;  // Size of each terrain sector in quads (NxN); default 16
var() Texture TerrainMap;  // 8-bit greyscale heightmap texture driving the terrain geometry
var() Vector TerrainScale;  // World-space scale applied per-axis to the heightmap; default (64,64,64)
var() TerrainLayer Layers[32];  // Up to 32 alpha-blended texture layers painted onto the terrain
var() array<DecorationLayer> DecoLayers;  // Decoration layers used to scatter static mesh objects across the terrain
var() bool Inverted;  // If true, terrain faces point downward (ceiling terrain)
// This option means use half the graphics res for Karma collision.
// Note - Karma ignores per-quad info (eg. 'invisible' and 'edge-turned') with this set to true.
var() bool bKCollisionHalfRes;
//R6TERRAINPLANNINGPAINT
var bool m_bNeedPlanningVBRebuild;  // Dirty flag; set when the planning-overlay vertex buffer must be rebuilt
//
// Internal data
//
var transient int JustLoaded;  // Set non-zero immediately after terrain data is streamed in from disk
var native const array<DecorationLayerData> DecoLayerData;  // Per-layer run-time decoration instance data; built on load
var native const array<TerrainSector> Sectors;  // Array of rendered terrain sector objects (SectorsX * SectorsY entries)
var native const array<Vector> Vertices;  // World-space positions of every height-map vertex
var native const int HeightmapX;  // Width of the height-map texture in pixels
var native const int HeightmapY;  // Height of the height-map texture in pixels
var native const int SectorsX;  // Number of terrain sectors along the X axis
var native const int SectorsY;  // Number of terrain sectors along the Y axis
var native const TerrainPrimitive Primitive;  // Native render primitive representing the entire terrain mesh
var native const array<NormalPair> FaceNormals;  // Per-quad face-normal pairs used for lighting and physics
var native const Vector ToWorld[4];  // 4-vector matrix transforming heightmap space to world space
var native const Vector ToHeightmap[4];  // 4-vector matrix transforming world space back to heightmap space
var native const array<int> SelectedVertices;  // Editor-only: indices of currently selected terrain vertices
var native const int ShowGrid;  // Editor-only: non-zero to render the terrain grid overlay
var const array<int> QuadVisibilityBitmap;  // Bit-packed per-quad visibility flags
var const array<int> EdgeTurnBitmap;  // Bit-packed per-quad edge-turn flags controlling triangle winding
var native const array<int> RenderCombinations;  // Pre-computed layer render-combination indices for batching
var native const array<int> VertexStreams;  // Vertex stream data for hardware T&L rendering
var native const array<Color> VertexColors;  // Per-vertex colour data for vertex-lit terrain
var native const array<Color> PaintedColor;  // editor only
// OLD
var native const Texture OldTerrainMap;  // Legacy heightmap texture kept for old-format map compatibility
var native const array<byte> OldHeightmap;  // Legacy raw heightmap bytes kept for old-format map compatibility
//R6TERRAINPLANNINGPAINT
var native const array<int> m_TerrainPlanningFloorsInfo;  // R6 planning overlay: floor assignment metadata per terrain region
var native const array<int> m_iTerrainPlanningLastFloor;  // R6 planning overlay: last-assigned floor index per terrain region

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
