// EngineDecls.h - Class declarations for Engine stubs without headers
#pragma once

class ENGINE_API CBoneDescData {
public:
	int fn_bInitFromLbpFile(const TCHAR*);
	void m_vProcessLbpLine(int,int,FString &);
	CBoneDescData(CBoneDescData const &);
	CBoneDescData();
	~CBoneDescData();
	CBoneDescData& operator=(const CBoneDescData&);
};

class ENGINE_API CCompressedLipDescData {
public:
	int fn_bInitFromMemory(BYTE*);
	int m_bReadCompressedFileFromMemory(BYTE*);
	CCompressedLipDescData& operator=(const CCompressedLipDescData&);
};

class ENGINE_API FBezier {
public:
	FBezier(FBezier const &);
	FBezier();
	virtual ~FBezier();
	FBezier& operator=(const FBezier&);
	float Evaluate(FVector *,int,TArray<FVector> *);
};

class ENGINE_API FBspSection {
public:
	FBspSection(FBspSection const &);
	FBspSection();
	~FBspSection();
	FBspSection& operator=(const FBspSection&);
};

struct ENGINE_API FBspVertex {
	FBspVertex();
	FBspVertex& operator=(const FBspVertex&);
};

class ENGINE_API FCanvasVertex {
public:
	FCanvasVertex(FVector,FColor,float,float);
	FCanvasVertex();
	FCanvasVertex& operator=(const FCanvasVertex&);
};

class ENGINE_API FConvexVolume {
public:
	BYTE SphereCheck(FSphere);
	FConvexVolume(FConvexVolume const &);
	FConvexVolume();
	~FConvexVolume();
	FConvexVolume& operator=(const FConvexVolume&);
	BYTE BoxCheck(FVector,FVector);
	FPoly ClipPolygon(FPoly);
	FPoly ClipPolygonPrecise(FPoly);
};

struct ENGINE_API FDXTCompressionOptions {
	FDXTCompressionOptions();
	FDXTCompressionOptions& operator=(const FDXTCompressionOptions&);
};

class ENGINE_API FDynamicActor {
public:
	void Render(FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *);
	FDynamicActor(FDynamicActor const &);
	FDynamicActor(AActor *);
	~FDynamicActor();
	FDynamicActor& operator=(const FDynamicActor&);
};

class ENGINE_API FDynamicLight {
public:
	float SampleIntensity(FVector,FVector);
	FColor SampleLight(FVector,FVector);
	FDynamicLight(FDynamicLight const &);
	FDynamicLight(AActor *);
	FDynamicLight& operator=(const FDynamicLight&);
};

struct ENGINE_API FFontCharacter {
	FFontCharacter& operator=(const FFontCharacter&);
};

struct ENGINE_API FFontPage {
	FFontPage(FFontPage const &);
	FFontPage();
	~FFontPage();
	FFontPage& operator=(const FFontPage&);
};

class ENGINE_API FKAggregateGeom {
public:
	FKAggregateGeom(FKAggregateGeom const &);
	FKAggregateGeom();
	~FKAggregateGeom();
	FKAggregateGeom& operator=(const FKAggregateGeom&);
	void EmptyElements();
	int GetElementCount();
};

class ENGINE_API FKBoxElem {
public:
	FKBoxElem(float);
	FKBoxElem(float,float,float);
	FKBoxElem();
	~FKBoxElem();
	FKBoxElem& operator=(const FKBoxElem&);
};

class ENGINE_API FKConvexElem {
public:
	FKConvexElem(FKConvexElem const &);
	FKConvexElem();
	~FKConvexElem();
	FKConvexElem& operator=(const FKConvexElem&);
};

class ENGINE_API FKCylinderElem {
public:
	FKCylinderElem(float,float);
	FKCylinderElem();
	~FKCylinderElem();
	FKCylinderElem& operator=(const FKCylinderElem&);
};

class ENGINE_API FKSphereElem {
public:
	FKSphereElem(float);
	FKSphereElem();
	~FKSphereElem();
	FKSphereElem& operator=(const FKSphereElem&);
};

class ENGINE_API FLightMapIndex {
public:
	FLightMapIndex();
	~FLightMapIndex();
	FLightMapIndex& operator=(const FLightMapIndex&);
};

class ENGINE_API FLineVertex {
public:
	FLineVertex(FVector,FColor);
	FLineVertex();
	FLineVertex& operator=(const FLineVertex&);
};

struct ENGINE_API FMipmap {
	FMipmap(FMipmap const &);
	FMipmap(BYTE,BYTE);
	FMipmap(BYTE,BYTE,int);
	FMipmap();
	~FMipmap();
	FMipmap& operator=(const FMipmap&);
	void Clear();
};

struct ENGINE_API FMipmapBase {
	FMipmapBase(BYTE,BYTE);
	FMipmapBase();
	FMipmapBase& operator=(const FMipmapBase&);
};

struct ENGINE_API FOrientation {
	FOrientation();
	FOrientation& operator=(const FOrientation&);
	int operator!=(FOrientation const &) const;
};

class ENGINE_API FR6MatineePreviewProxy {
public:
	virtual void OnEndSequenceNotify(ASceneManager *);
	virtual void OnScrollBarUpdate();
	FR6MatineePreviewProxy(FR6MatineePreviewProxy const &);
	FR6MatineePreviewProxy();
	virtual ~FR6MatineePreviewProxy();
	FR6MatineePreviewProxy& operator=(const FR6MatineePreviewProxy&);
};

class ENGINE_API FReachSpec {
public:
	FReachSpec& operator=(const FReachSpec&);
};

class ENGINE_API FRebuildOptions {
public:
	FRebuildOptions(FRebuildOptions const &);
	FRebuildOptions();
	~FRebuildOptions();
	FRebuildOptions& operator=(const FRebuildOptions&);
	FString GetName();
	void Init();
};

class ENGINE_API FStatGraphLine {
public:
	FStatGraphLine(FStatGraphLine const &);
	FStatGraphLine();
	~FStatGraphLine();
	FStatGraphLine& operator=(const FStatGraphLine&);
	int operator==(FStatGraphLine const &) const;
};

struct ENGINE_API FStaticMeshCollisionNode {
	FStaticMeshCollisionNode();
	FStaticMeshCollisionNode& operator=(const FStaticMeshCollisionNode&);
};

struct ENGINE_API FStaticMeshCollisionTriangle {
	FStaticMeshCollisionTriangle(FStaticMeshCollisionTriangle const &);
	FStaticMeshCollisionTriangle();
	FStaticMeshCollisionTriangle& operator=(const FStaticMeshCollisionTriangle&);
};

class ENGINE_API FStaticMeshMaterial {
public:
	FStaticMeshMaterial(UMaterial *);
	FStaticMeshMaterial& operator=(const FStaticMeshMaterial&);
};

class ENGINE_API FStaticMeshSection {
public:
	FStaticMeshSection();
	FStaticMeshSection& operator=(const FStaticMeshSection&);
};

struct ENGINE_API FStaticMeshTriangle {
	FStaticMeshTriangle();
	FStaticMeshTriangle& operator=(const FStaticMeshTriangle&);
};

struct ENGINE_API FStaticMeshUV {
	FStaticMeshUV& operator=(const FStaticMeshUV&);
};

struct ENGINE_API FStaticMeshVertex {
	FStaticMeshVertex();
	FStaticMeshVertex& operator=(const FStaticMeshVertex&);
};

class ENGINE_API FTags {
public:
	FTags(FTags const &);
	FTags();
	~FTags();
	FTags& operator=(const FTags&);
	void Init();
};

class ENGINE_API FTempLineBatcher {
public:
	void Render(FRenderInterface *,int);
	FTempLineBatcher(FTempLineBatcher const &);
	FTempLineBatcher();
	~FTempLineBatcher();
	FTempLineBatcher& operator=(const FTempLineBatcher&);
	void AddBox(FBox,FColor);
	void AddLine(FVector,FVector,FColor);
};

struct ENGINE_API FTerrainMaterialLayer {
	FTerrainMaterialLayer();
	~FTerrainMaterialLayer();
	FTerrainMaterialLayer& operator=(const FTerrainMaterialLayer&);
};

class ENGINE_API FZoneProperties {
public:
	FZoneProperties(FZoneProperties const &);
	FZoneProperties();
	FZoneProperties& operator=(const FZoneProperties&);
};

class ENGINE_API UTerrainBrush {
public:
	virtual void MouseButtonDown(UViewport *);
	virtual void MouseButtonUp(UViewport *);
	virtual void MouseMove(float,float);
	UTerrainBrush(UTerrainBrush const &);
	UTerrainBrush();
	virtual ~UTerrainBrush();
	UTerrainBrush& operator=(const UTerrainBrush&);
	int BeginPainting(UTexture * *,ATerrainInfo * *);
	void EndPainting(UTexture *,ATerrainInfo *);
	virtual void Execute(int);
	virtual FBox GetRect();
};

class ENGINE_API UTerrainBrushColor {
public:
	UTerrainBrushColor(UTerrainBrushColor const &);
	UTerrainBrushColor();
	virtual ~UTerrainBrushColor();
	UTerrainBrushColor& operator=(const UTerrainBrushColor&);
	virtual void Execute(int);
};

class ENGINE_API UTerrainBrushEdgeTurn {
public:
	UTerrainBrushEdgeTurn(UTerrainBrushEdgeTurn const &);
	UTerrainBrushEdgeTurn();
	virtual ~UTerrainBrushEdgeTurn();
	UTerrainBrushEdgeTurn& operator=(const UTerrainBrushEdgeTurn&);
	virtual void Execute(int);
	virtual FBox GetRect();
};

class ENGINE_API UTerrainBrushFlatten {
public:
	UTerrainBrushFlatten(UTerrainBrushFlatten const &);
	UTerrainBrushFlatten();
	virtual ~UTerrainBrushFlatten();
	UTerrainBrushFlatten& operator=(const UTerrainBrushFlatten&);
	virtual void Execute(int);
};

class ENGINE_API UTerrainBrushNoise {
public:
	UTerrainBrushNoise(UTerrainBrushNoise const &);
	UTerrainBrushNoise();
	virtual ~UTerrainBrushNoise();
	UTerrainBrushNoise& operator=(const UTerrainBrushNoise&);
	virtual void Execute(int);
};

class ENGINE_API UTerrainBrushPaint {
public:
	UTerrainBrushPaint(UTerrainBrushPaint const &);
	UTerrainBrushPaint();
	virtual ~UTerrainBrushPaint();
	UTerrainBrushPaint& operator=(const UTerrainBrushPaint&);
	virtual void Execute(int);
};

class ENGINE_API UTerrainBrushPlanningPaint {
public:
	virtual void MouseButtonDown(UViewport *);
	UTerrainBrushPlanningPaint(UTerrainBrushPlanningPaint const &);
	UTerrainBrushPlanningPaint();
	virtual ~UTerrainBrushPlanningPaint();
	UTerrainBrushPlanningPaint& operator=(const UTerrainBrushPlanningPaint&);
	virtual void Execute(int);
};

class ENGINE_API UTerrainBrushSelect {
public:
	virtual void MouseButtonDown(UViewport *);
	virtual void MouseMove(float,float);
	UTerrainBrushSelect(UTerrainBrushSelect const &);
	UTerrainBrushSelect();
	virtual ~UTerrainBrushSelect();
	UTerrainBrushSelect& operator=(const UTerrainBrushSelect&);
	virtual void Execute(int);
	virtual FBox GetRect();
};

class ENGINE_API UTerrainBrushSmooth {
public:
	UTerrainBrushSmooth(UTerrainBrushSmooth const &);
	UTerrainBrushSmooth();
	virtual ~UTerrainBrushSmooth();
	UTerrainBrushSmooth& operator=(const UTerrainBrushSmooth&);
	virtual void Execute(int);
};

class ENGINE_API UTerrainBrushTexPan {
public:
	virtual void MouseMove(float,float);
	UTerrainBrushTexPan(UTerrainBrushTexPan const &);
	UTerrainBrushTexPan();
	virtual ~UTerrainBrushTexPan();
	UTerrainBrushTexPan& operator=(const UTerrainBrushTexPan&);
};

class ENGINE_API UTerrainBrushTexRotate {
public:
	virtual void MouseMove(float,float);
	UTerrainBrushTexRotate(UTerrainBrushTexRotate const &);
	UTerrainBrushTexRotate();
	virtual ~UTerrainBrushTexRotate();
	UTerrainBrushTexRotate& operator=(const UTerrainBrushTexRotate&);
};

class ENGINE_API UTerrainBrushTexScale {
public:
	virtual void MouseMove(float,float);
	UTerrainBrushTexScale(UTerrainBrushTexScale const &);
	UTerrainBrushTexScale();
	virtual ~UTerrainBrushTexScale();
	UTerrainBrushTexScale& operator=(const UTerrainBrushTexScale&);
};

class ENGINE_API UTerrainBrushVertexEdit {
public:
	UTerrainBrushVertexEdit(UTerrainBrushVertexEdit const &);
	UTerrainBrushVertexEdit();
	virtual ~UTerrainBrushVertexEdit();
	UTerrainBrushVertexEdit& operator=(const UTerrainBrushVertexEdit&);
};

class ENGINE_API UTerrainBrushVisibility {
public:
	UTerrainBrushVisibility(UTerrainBrushVisibility const &);
	UTerrainBrushVisibility();
	virtual ~UTerrainBrushVisibility();
	UTerrainBrushVisibility& operator=(const UTerrainBrushVisibility&);
	virtual void Execute(int);
	virtual FBox GetRect();
};

