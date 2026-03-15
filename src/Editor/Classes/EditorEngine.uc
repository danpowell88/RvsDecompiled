//=============================================================================
// EditorEngine - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// EditorEngine: The UnrealEd subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class EditorEngine extends Engine
    transient
    native
    config
    noexport;

// Objects.
var const Level Level;
var const Model TempModel;
var const Texture CurrentTexture;
var const StaticMesh CurrentStaticMesh;
var const Mesh CurrentMesh;
var const Class CurrentClass;
var const TransBuffer Trans;
var const TextBuffer Results;
var const int Pad[8];
// Textures.
var const Texture Bad;
// NEW IN 1.60
var const Texture Bkgnd;
// NEW IN 1.60
var const Texture BkgndHi;
// NEW IN 1.60
var const Texture BadHighlight;
// NEW IN 1.60
var const Texture MaterialArrow;
// NEW IN 1.60
var const Texture MaterialBackdrop;
// Used in UnrealEd for showing materials
var StaticMesh TexPropCube;
var StaticMesh TexPropSphere;
// Toggles.
var const bool bFastRebuild;
// NEW IN 1.60
var const bool bBootstrapping;
// Other variables.
var const config int AutoSaveIndex;
var const int AutoSaveCount;
// NEW IN 1.60
var const int Mode;
// NEW IN 1.60
var const int TerrainEditBrush;
// NEW IN 1.60
var const int ClickFlags;
var const float MovementSpeed;
var const Package PackageContext;
var const Vector AddLocation;
var const Plane AddPlane;
// Misc.
var const array<Object> Tools;
var const Class BrowseClass;
// Grid.
var const int ConstraintsVtbl;
var(Grid) config bool GridEnabled;
var(Grid) config bool SnapVertices;
var(Grid) config float SnapDistance;
var(Grid) config Vector GridSize;
// Rotation grid.
var(RotationGrid) config bool RotGridEnabled;
var(RotationGrid) config Rotator RotGridSize;
// Advanced.
var(Advanced) config bool UseSizingBox;
var(Advanced) config bool UseAxisIndicator;
var(Advanced) config float FovAngleDegrees;
var(Advanced) config bool GodMode;
var(Advanced) config bool AutoSave;
var(Advanced) config byte AutosaveTimeMinutes;
var(Advanced) config string GameCommandLine;
var(Advanced) config array<string> EditPackages;
var(Advanced) config bool AlwaysShowTerrain;
var(Advanced) config bool UseActorRotationGizmo;
var(Advanced) config bool LoadEntirePackageWhenSaving;
// NEW IN 1.60
var(Advanced) config bool LoadLastMod;
// NEW IN 1.60
var(Advanced) config string CurrentMod;

defaultproperties
{
	Bad=Texture'Editor.Bad'
	Bkgnd=Texture'Editor.Bkgnd'
	BkgndHi=Texture'Editor.BkgndHi'
	BadHighlight=Texture'Editor.BadHighlight'
	MaterialArrow=Texture'Editor.MaterialArrow'
	MaterialBackdrop=Texture'Editor.MaterialBackdrop'
	TexPropCube=StaticMesh'Editor.TexPropCube'
	TexPropSphere=StaticMesh'Editor.TexPropSphere'
	GridEnabled=true
	SnapDistance=10.0000000
	GridSize=(X=16.0000000,Y=16.0000000,Z=16.0000000)
	RotGridEnabled=true
	RotGridSize=(Pitch=1024,Yaw=1024,Roll=1024)
	UseAxisIndicator=true
	FovAngleDegrees=90.0000000
	GodMode=true
	AutoSave=true
	AutosaveTimeMinutes=5
	GameCommandLine="-log"
	EditPackages[0]="Core"
	EditPackages[1]="Engine"
	EditPackages[2]="Fire"
	EditPackages[3]="Editor"
	EditPackages[4]="UWindow"
	EditPackages[5]="IpDrv"
	EditPackages[6]="Gameplay"
	EditPackages[7]="R6SFX"
	EditPackages[8]="R6Abstract"
	EditPackages[9]="R6Engine"
	EditPackages[10]="R6Characters"
	EditPackages[11]="R61stWeapons"
	EditPackages[12]="R6Weapons"
	EditPackages[13]="R6WeaponGadgets"
	EditPackages[14]="R63rdWeapons"
	EditPackages[15]="R6Description"
	EditPackages[16]="R6GameService"
	EditPackages[17]="R6Game"
	EditPackages[18]="R6Window"
	EditPackages[19]="R6Menu"
	EditPackages[20]="UnrealEd"
	AlwaysShowTerrain=true
	CacheSizeMegs=32
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var d
// REMOVED IN 1.60: var i
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var w
// REMOVED IN 1.60: var p
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var s
