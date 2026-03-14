//=============================================================================
// EditorEngine: The UnrealEd subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class EditorEngine extends Engine
    native
    noexport
    transient;

#exec Texture Import File=Textures\Bad.pcx
#exec Texture Import File=Textures\BadHighlight.pcx
#exec Texture Import File=Textures\Bkgnd.pcx
#exec Texture Import File=Textures\BkgndHi.pcx
#exec Texture Import File=Textures\MaterialArrow.pcx MASKED=1
#exec Texture Import File=Textures\MaterialBackdrop.pcx
#exec NEW StaticMesh File="models\TexPropCube.Ase" Name="TexPropCube"
#exec NEW StaticMesh File="models\TexPropSphere.Ase" Name="TexPropSphere"

// --- Variables ---
var config array<array> EditPackages;
// ^ NEW IN 1.60
var const class<Object> CurrentClass;
var const TransBuffer Trans;
var const TextBuffer Results;
var const int Pad[8];
var const Texture Bad;
// ^ NEW IN 1.60
var const Mesh CurrentMesh;
var const StaticMesh CurrentStaticMesh;
var const Texture CurrentTexture;
var const Model TempModel;
// Objects.
var const Level Level;
var config string CurrentMod;
// ^ NEW IN 1.60
var config bool LoadLastMod;
// ^ NEW IN 1.60
var config bool LoadEntirePackageWhenSaving;
// ^ NEW IN 1.60
var config bool UseActorRotationGizmo;
// ^ NEW IN 1.60
var config bool AlwaysShowTerrain;
// ^ NEW IN 1.60
var config string GameCommandLine;
// ^ NEW IN 1.60
var config byte AutosaveTimeMinutes;
// ^ NEW IN 1.60
var config bool AutoSave;
// ^ NEW IN 1.60
var config bool GodMode;
// ^ NEW IN 1.60
var config float FovAngleDegrees;
// ^ NEW IN 1.60
var config bool UseAxisIndicator;
// ^ NEW IN 1.60
var config bool UseSizingBox;
// ^ NEW IN 1.60
var config Rotator RotGridSize;
// ^ NEW IN 1.60
var config bool RotGridEnabled;
// ^ NEW IN 1.60
var config Vector GridSize;
// ^ NEW IN 1.60
var config float SnapDistance;
// ^ NEW IN 1.60
var config bool SnapVertices;
// ^ NEW IN 1.60
var config bool GridEnabled;
// ^ NEW IN 1.60
// Grid.
var const int ConstraintsVtbl;
var const class<Object> BrowseClass;
// Misc.
var const array<array> Tools;
var const Plane AddPlane;
var const Vector AddLocation;
var const Package PackageContext;
var const float MovementSpeed;
var const int ClickFlags;
var const int TerrainEditBrush;
// ^ NEW IN 1.60
var const int Mode;
// ^ NEW IN 1.60
var const int AutoSaveCount;
// ^ NEW IN 1.60
// Other variables.
var config const int AutoSaveIndex;
// Toggles.
var const bool bBootstrapping;
var const bool bFastRebuild;
// ^ NEW IN 1.60
var StaticMesh TexPropSphere;
// Used in UnrealEd for showing materials
var StaticMesh TexPropCube;
// Textures.
var const Texture MaterialBackdrop;
var const Texture MaterialArrow;
// ^ NEW IN 1.60
var const Texture BadHighlight;
// ^ NEW IN 1.60
var const Texture BkgndHi;
// ^ NEW IN 1.60
var const Texture Bkgnd;
// ^ NEW IN 1.60

defaultproperties
{
}
